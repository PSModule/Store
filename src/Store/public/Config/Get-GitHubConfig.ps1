function Get-StoreConfig {
    <#
        .SYNOPSIS
        Get configuration value.

        .DESCRIPTION
        Get a named configuration value from the store configuration.

        .EXAMPLE
        Get-GitHubConfig -Name ApiBaseUri

        Get the current GitHub configuration for the ApiBaseUri.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param (
        # Choose a configuration name to get.
        [Parameter()]
        [string] $Name
    )

    $prefix = $script:SecretVault.Prefix

    switch ($Name) {
        'AccessToken' {
            Get-Secret -Name "$prefix`AccessToken"
        }
        'RefreshToken' {
            Get-Secret -Name "$prefix`RefreshToken"
        }
        default {
            $RefreshTokenSecretInfo = Get-SecretInfo -Name "$prefix`RefreshToken"
            if ($null -ne $RefreshTokenSecretInfo.Metadata) {
                $RefreshTokenMetadata = $RefreshTokenSecretInfo.Metadata | ConvertFrom-HashTable | ConvertTo-HashTable
            }

            $AccessTokenSecretInfo = Get-SecretInfo -Name "$prefix`AccessToken"
            if ($null -ne $AccessTokenSecretInfo.Metadata) {
                $AccessTokenMetadata = $AccessTokenSecretInfo.Metadata | ConvertFrom-HashTable | ConvertTo-HashTable
            }
            $metadata = Join-Object -Main $RefreshTokenMetadata -Overrides $AccessTokenMetadata -AsHashtable

            if ($Name) {
                $metadata.$Name
            } else {
                $metadata.GetEnumerator() | Sort-Object -Property Name
            }
        }
    }
}
