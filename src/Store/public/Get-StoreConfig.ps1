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
    [CmdletBinding(DefaultParameterSetName = 'Variable')]
    param (
        # Choose a configuration name to get.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Variable'
        )]
        [string] $VariableName,

        [Parameter(
            Mandatory,
            ParameterSetName = 'Secret'
        )]
        [string] $SecretName
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Variable' {
            Get-StoreVariable -Name $VariableName
        }
        'Secret' {
            Get-Secret -Name $SecretName -AsPlainText -Vault $script:Store.SecretVaultName
        }
    }
}
