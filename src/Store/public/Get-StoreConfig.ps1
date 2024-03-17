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

    $value = Get-StoreVariable -Name $VariableName

    if ($null -eq $value) {
        $value = Get-Secret -Name $SecretName -AsPlainText -Vault $script:Store.SecretVaultName
    }

    if ($null -eq $value) {
        throw "Configuration value not found: $Name"
    }
    
    $value
}
