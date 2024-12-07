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
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param()

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $vaultName = $script:Config.VaultName
        $secretPrefix = $script:Config.SecretPrefix
    }

    process {
        Write-Debug "Retrieving all context info from [$vaultName]"

        Get-SecretInfo -Vault $vaultName -Verbose:$false -Name "$secretPrefix*" | ForEach-Object {
            [pscustomobject]@{
                Name      = $_.Name -replace "^$secretPrefix"
                Metadata  = $_.Metadata
                Type      = $_.Type
                VaultName = $_.VaultName
            }
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
