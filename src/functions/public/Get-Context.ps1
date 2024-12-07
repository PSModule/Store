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
    [OutputType([Context])]
    [CmdletBinding()]
    param(
        # The name of the context to retrieve from the vault.
        [Parameter()]
        [SupportsWildcards()]
        [string] $ID
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        $indent = ((Get-PSCallStack).Count - 1) * " "
        Write-Debug "$indent`[$commandName] - Start"
        $null = Get-ContextVault
        $vaultName = $script:Config.VaultName
        $contextInfos = Get-ContextInfo
    }

    process {
        try {
            if (-not $PSBoundParameters.ContainsKey('ID')) {
                Write-Debug "$indent`Retrieving all contexts from [$vaultName]"
            } elseif ([string]::IsNullOrEmpty($ID)) {
                Write-Debug "$indent`Return 0 contexts from [$vaultName]"
                return
            } elseif ($ID.Contains('*')) {
                Write-Debug "$indent`Retrieving contexts like [$ID] from [$vaultName]"
                $contextInfos = $contextInfos | Where-Object { $_.ID -like $ID }
            } else {
                Write-Debug "$indent`Retrieving context [$ID] from [$vaultName]"
                $contextInfos = $contextInfos | Where-Object { $_.ID -eq $ID }
            }

            Write-Debug "$indent`Found [$($contextInfos.Count)] contexts in [$vaultName]"
            $contextInfos | ForEach-Object {
                $contextJson = Get-Secret -Name $_.SecretName -Vault $vaultName -AsPlainText -Verbose:$false
                [Context](ConvertFrom-ContextJson -JsonString $contextJson)
            }
        } catch {
            Write-Error $_
            throw 'Failed to get context'
        }
    }

    end {
        Write-Debug "$indent`[$commandName] - End"
    }
}
