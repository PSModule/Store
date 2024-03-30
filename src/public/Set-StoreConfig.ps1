function Set-StoreConfig {
    <#
        .SYNOPSIS
        Set a configuration variables or secret.

        .DESCRIPTION
        Set a configuration variable or secret in the configuration store.

        .EXAMPLE
        Set-StoreConfig -VariableName "ApiBaseUri" -Value 'https://api.github.com'

        Sets a variable called 'ApiBaseUri' in the configuration store (json file).

        .EXAMPLE
        Set-StoreConfig -SecretName "AccessToken" -Value 'myAccessToken'

        Sets a secret called 'AccessToken' in the configuration store (secret vault).
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of a variable to set.
        [Parameter(Mandatory)]
        [string] $Name,

        # The value to set.
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $Value
    )

    if ($PSCmdlet.ShouldProcess("Set variable '$Name' to '$Value'")) {
        if ($Value -is [SecureString]) {
            Set-Secret -Name $Name -SecureStringSecret $Value
        } else {
            Set-StoreVariable -Name $Name -Value $Value
        }
    }
}
