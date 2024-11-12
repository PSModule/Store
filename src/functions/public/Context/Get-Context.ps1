function Get-Context {
    <#
        .SYNOPSIS
        Retrieves a context from the context vault.

        .DESCRIPTION
        Retrieves contexts from a specified context vault. You can specify the name of the context to retrieve or use a wildcard pattern to retrieve
        multiple contexts. If no name is specified, all contexts from the context vault will be retrieved.
        Optionally, you can choose to retrieve the contexts as plain text by providing the -AsPlainText switch.

        .EXAMPLE
        Get-Context

        Get all contexts from the context vault.

        .EXAMPLE
        Get-Context -Name 'MySecret'

        Get the context called 'MySecret' from the vault.

        .EXAMPLE
        Get-Context -Name 'My*'

        Get all contexts that match the pattern 'My*' from the vault.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The name of the context to retrieve from the vault. Supports wildcard patterns.
        [Parameter()]
        [SupportsWildcards()]
        [Alias('Context', 'ContextName')]
        [string] $Name,

        # Switch to retrieve the contexts as plain text.
        [Parameter()]
        [switch] $AsPlainText
    )

    Write-Verbose "Connecting to context vault [$($script:Config.Context.VaultName)]"
    $contextVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.Context.VaultName }
    if (-not $contextVault) {
        Write-Verbose "No context vault found with name [$($script:Config.Context.VaultName)]"
        return $null
    }

    Write-Verbose "Retrieving context infos from vault [$($contextVault.Name)]"
    $secretInfos = Get-SecretInfo -Vault $contextVault.Name
    if (-not $secretInfos) {
        Write-Verbose "No context infos found in vault [$($contextVault.Name)]"
        return $null
    }

    if ($Name) {
        Write-Verbose "Filtering context infos with name pattern [$Name]"
        $secretInfos = $secretInfos | Where-Object { $_.Name -like $Name }
    }

    $contexts = @()
    foreach ($secretInfo in $secretInfos) {
        $metadata = $secretInfo | Select-Object -ExpandProperty Metadata
        $context = $metadata + @{
            Name   = $secretInfo.Name
            Secret = Get-Secret -Name $secretInfo.Name -Vault $script:Config.Context.VaultName -AsPlainText:$AsPlainText
        }
        $contexts += [pscustomobject]$context
    }

    return $contexts
}

# Register tab completer for the Name parameter
Register-ArgumentCompleter -CommandName Get-Context -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $null)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters # Suppress unused variable warning
    $contextVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.Context.VaultName }
    if (-not $contextVault) {
        return
    }

    $secretInfos = Get-SecretInfo -Vault $contextVault.Name
    if (-not $secretInfos) {
        return
    }

    $secretInfos | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
