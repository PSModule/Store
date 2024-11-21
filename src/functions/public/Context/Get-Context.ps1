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

    $contextVault = Get-ContextVault

    if (-not $PSBoundParameters.ContainsKey('ID')) {
        Write-Verbose "Retrieving all contexts from [$($contextVault.Name)]"
        $contexts = Get-SecretInfo -Vault $contextVault.Name
    } elseif ([string]::IsNullOrEmpty($ID)) {
        Write-Verbose "Return 0 contexts from [$($contextVault.Name)]"
        return
    } else {
        Write-Verbose "Retrieving context [$ID] from [$($contextVault.Name)]"
        $contexts = Get-SecretInfo -Vault $contextVault.Name | Where-Object { $_.Name -eq "$($script:Config.SecretPrefix)$ID" }
    }

    Write-Verbose "Found [$($contexts.Count)] contexts in [$($contextVault.Name)]"
    $contexts | ForEach-Object {
        Write-Verbose " - $_"
        $contextJson = $_ | Get-Secret -AsPlainText
        ConvertFrom-ContextJson -JsonString $contextJson
    }
}
