function Get-ContextInfo {
    <#
        .SYNOPSIS
        Retrieves all context info from the context vault.

        .DESCRIPTION
        Retrieves all context info from the context vault.

        .EXAMPLE
        Get-ContextInfo

        Get all context info from the context vault.

        .EXAMPLE
        Get-ContextInfo -ID 'my-context'

        Get the context info for the context with the ID 'my-context'.

        .EXAMPLE
        Get-ContextInfo -ID 'my-*'

        Get all context info for contexts with IDs starting with 'my-'.
    #>
    [OutputType([ContextInfo])]
    [CmdletBinding()]
    param(
        # The name of the context to retrieve from the vault.
        [Parameter()]
        [SupportsWildcards()]
        [string] $ID = '*'
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Set-ContextVault
        $vaultName = $script:Config.VaultName
        $secretPrefix = $script:Config.SecretPrefix
    }

    process {
        Write-Debug "Retrieving all context info from [$vaultName]"

        Get-SecretInfo -Vault $vaultName -Verbose:$false -Name "$secretPrefix$ID" | ForEach-Object {
            [ContextInfo]@{
                ID         = ($_.Name -replace "^$secretPrefix")
                Metadata   = $_.Metadata + @{}
                SecretName = $_.Name
                SecretType = $_.Type
                VaultName  = $_.VaultName
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
