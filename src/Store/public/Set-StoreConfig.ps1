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
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = 'Variable'
    )]
    param (
        # The variable name to set.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Variable'
        )]
        [string] $VariableName,

        # The SecretName to set.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Secret'
        )]
        [string] $SecretName,

        # The value to set.
        [Parameter(Mandatory)]
        [object] $Value
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Variable' {
            if ($PSCmdlet.ShouldProcess("Set variable '$VariableName' to '$Value'")) {
                Set-StoreVariable -Name $VariableName -Value $Value
            }
        }
        'Secret' {
            if ($PSCmdlet.ShouldProcess("Set secret '$SecretName' to '$Value'")) {
                Set-Secret -Name $SecretName -SecretValue $Value
            }
        }
    }
}
