#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

filter Get-Context {
    <#
        .SYNOPSIS
        Retrieves a context from the context vault.

        .DESCRIPTION
        Retrieves a context from the context vault.
        If no name is specified, all contexts from the context vault will be retrieved.

        .EXAMPLE
        Get-Context

        Get all contexts from the context vault.

        .EXAMPLE
        Get-Context -ID 'MySecret'

        Get the context called 'MySecret' from the vault.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The name of the context to retrieve from the vault.
        [Parameter()]
        [SupportsWildcards()]
        [Alias('ContextID')]
        [string] $ID
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $null = Get-ContextVault
        $vaultName = $script:Config.VaultName
        $secretPrefix = $script:Config.SecretPrefix
        $fullID = "$secretPrefix$ID"
    }

    process {
        try {
            if (-not $PSBoundParameters.ContainsKey('ID')) {
                Write-Verbose "Retrieving all contexts from [$vaultName]"
                $contexts = Get-SecretInfo -Vault $vaultName | Where-Object { (ConvertFrom-Base64 -Base64String $_.Name) -like "$secretPrefix*" }
            } elseif ([string]::IsNullOrEmpty($ID)) {
                Write-Verbose "Return 0 contexts from [$vaultName]"
                return
            } elseif ($ID.Contains('*')) {
                # If wildcards are used, we can use the -Name parameter to filter the results. Its using the -like operator internally in the module.
                Write-Verbose "Retrieving contexts matching [$ID] from [$vaultName]"
                $contexts = Get-SecretInfo -Vault $vaultName -Name (ConvertTo-Base64 -Base64String $fullID)
            } else {
                # Needs to use Where-Object in order to support special characters, like `[` and `]`.
                Write-Verbose "Retrieving context [$ID] from [$vaultName]"
                $contexts = Get-SecretInfo -Vault $vaultName | Where-Object { (ConvertFrom-Base64 -Base64String $_.Name) -eq $fullID }
            }

            Write-Verbose "Found [$($contexts.Count)] contexts in [$vaultName]"
            $contexts | ForEach-Object {
                Write-Verbose " - $($_.Name)"
                $contextJson = $_ | Get-Secret -AsPlainText
                ConvertFrom-ContextJson -JsonString $contextJson
            }
        } catch {
            Write-Error $_
            throw 'Failed to get context'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Register-ArgumentCompleter -CommandName Get-Context -ParameterName ID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-SecretInfo -Vault $vaultName |
        Where-Object { (ConvertFrom-Base64 -Base64String $_.Name) -like "$($script:Config.SecretPrefix)$wordToComplete*" } |
        ForEach-Object {
            $Name = (ConvertFrom-Base64 -Base64String $_.Name) -replace "^$($script:Config.SecretPrefix)"
            [System.Management.Automation.CompletionResult]::new($Name, $Name, 'ParameterValue', $Name)
        }
}
