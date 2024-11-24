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
    param()

    $vaultName = $script:Config.VaultName
    $secretPrefix = $script:Config.SecretPrefix

    Write-Verbose "Retrieving all context info from [$vaultName]"

    Get-SecretInfo -Vault $vaultName | ForEach-Object {
        $name64 = $_.Name
        if (Test-Base64 -Base64String $name64) {
            $name = ConvertFrom-Base64 -Base64String $name64
            if ($name.StartsWith($secretPrefix)) {
                Write-Verbose " + $name ($name64)"
                [pscustomobject]@{
                    Name64   = $name64
                    Name     = $name
                    Metadata = $_.Metadata
                    Type     = $_.Type
                }
            }
        }
    }
}
