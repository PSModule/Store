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
        $contextInfos = Get-ContextInfo
    }

    process {
        try {
            if (-not $PSBoundParameters.ContainsKey('ID')) {
                Write-Verbose "Retrieving all contexts from [$vaultName]"
            } elseif ([string]::IsNullOrEmpty($ID)) {
                Write-Verbose "Return 0 contexts from [$vaultName]"
                return
            } elseif ($ID.Contains('*')) {
                Write-Verbose "Retrieving contexts like [$ID] from [$vaultName]"
                $contextInfos = $contextInfos | Where-Object { $_.Name -like $ID }
            } else {
                Write-Verbose "Retrieving context [$ID] from [$vaultName]"
                $contextInfos = $contextInfos | Where-Object { $_.Name -eq $ID }
            }

            Write-Verbose "Found [$($contextInfos.Count)] contexts in [$vaultName]"
            $contextInfos | ForEach-Object {
                $contextJson = Get-Secret -Name $_.Name64 -Vault $vaultName -AsPlainText
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

    Get-ContextInfo | Where-Object { $_.Name -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
        }
}
