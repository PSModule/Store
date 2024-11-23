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

    try {
        $contextVault = Get-ContextVault

        if (-not $PSBoundParameters.ContainsKey('ID')) {
            Write-Verbose "Retrieving all contexts from [$($contextVault.Name)]"
            $contexts = Get-SecretInfo -Vault $contextVault.Name
        } elseif ([string]::IsNullOrEmpty($ID)) {
            Write-Verbose "Return 0 contexts from [$($contextVault.Name)]"
            return
        } elseif ($ID.Contains('*')) {
            # If wildcards are used, we can use the -Name parameter to filter the results. Its using the -like operator internally in the module.
            Write-Verbose "Retrieving contexts matching [$ID] from [$($contextVault.Name)]"
            $contexts = Get-SecretInfo -Vault $contextVault.Name -Name "$($script:Config.SecretPrefix)$ID"
        } else {
            # Needs to use Where-Object in order to support special characters, like `[` and `]`.
            Write-Verbose "Retrieving context [$ID] from [$($contextVault.Name)]"
            $contexts = Get-SecretInfo -Vault $contextVault.Name | Where-Object { $_.Name -eq "$($script:Config.SecretPrefix)$ID" }
        }

        Write-Verbose "Found [$($contexts.Count)] contexts in [$($contextVault.Name)]"
        $contexts | ForEach-Object {
            Write-Verbose " - $($_.Name)"
            $contextJson = $_ | Get-Secret -AsPlainText
            ConvertFrom-ContextJson -JsonString $contextJson
        }
    } catch {
        throw $_
    }
}
