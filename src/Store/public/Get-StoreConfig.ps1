function Get-StoreConfig {
    <#
        .SYNOPSIS
        Get configuration value.

        .DESCRIPTION
        Get a named configuration value from the store configuration.

        .EXAMPLE
        Get-StoreConfig -Name ApiBaseUri

        Get the value of ApiBaseUri config.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param (
        # Choose a configuration name to get.
        [Parameter(Mandatory)]
        [string] $Name
    )

    $value = Get-StoreVariable -Name $Name

    if ($null -eq $value) {
        $value = Get-Secret -Name $Name -AsPlainText -Vault $script:Store.SecretVaultName
    }

    $value
}
