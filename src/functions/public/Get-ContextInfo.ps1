function Get-ContextInfo {
    <#
        .SYNOPSIS
        Retrieves all context info from the context vault.

        .DESCRIPTION
        Retrieves all context info from the context vault.

        .EXAMPLE
        Get-ContextInfo

        Get all context info from the context vault.
    #>
    [OutputType([ContextInfo])]
    [CmdletBinding()]
    param()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Set-ContextVault
        $vaultName = $script:Config.VaultName
        $secretPrefix = $script:Config.SecretPrefix
    }

    process {
        Write-Debug "Retrieving all context info from [$vaultName]"

        Get-SecretInfo -Vault $vaultName -Verbose:$false -Name "$secretPrefix*" | ForEach-Object {
            $ID = ($_.Name -replace "^$secretPrefix")
            [ContextInfo]@{
                ID         = $ID
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
