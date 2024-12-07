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

        Get-SecretInfo -Vault $vaultName -Verbose:$false | Where-Object { ($_.Name).StartsWith($secretPrefix) } | ForEach-Object {
            # TODO Remove base 64 conversion. Let that be up to the implementation to decide.
            $name64 = $_.Name -replace "^$secretPrefix"
            if (Test-Base64 -Base64String $name64) {
                $name = ConvertFrom-Base64 -Base64String $name64
                Write-Debug " + $name ($name64)"
                [pscustomobject]@{
                    Name64     = $name64
                    SecretName = $_.Name
                    Name       = $name
                    Metadata   = $_.Metadata
                    Type       = $_.Type
                }
            }
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
