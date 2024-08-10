#Requires -Modules Microsoft.PowerShell.SecretManagement

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
        [string] $Name,

        # Return the value as plain text if it is a secret.
        [Parameter()]
        [switch] $AsPlainText
    )

    $value = Get-StoreVariable -Name $Name

    if (($null -eq $value) -and ((Get-SecretInfo -Vault $script:Store.SecretVaultName).Name -contains $Name)) {
        $value = Get-Secret -Name $Name -AsPlainText:$AsPlainText -Vault $script:Store.SecretVaultName
    }

    $value
}
