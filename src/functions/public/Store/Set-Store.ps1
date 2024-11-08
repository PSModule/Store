function Set-Store {
    <#
        .SYNOPSIS
        Set a store in the vault.

        .DESCRIPTION
        If the store does not exist, it will be created. If it already exists, it will be updated.

        .EXAMPLE
        Set-Store -Name 'MySecret'

        Create a store called 'MySecret' in the vault.

        .EXAMPLE
        Set-Store -Name 'MySecret' -Secret 'MySecret'

        Creates a store called 'MySecret' in the vault with the secret.

        .EXAMPLE
        Set-Store -Name 'MySecret' -Secret 'MySecret' -Variables @{ 'Key' = 'Value' }

        Creates a store called 'MySecret' in the vault with the secret and variables.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the store.
        [Parameter()]
        [string] $Name,

        # The secret of the store.
        [Parameter()]
        [string] $Secret = 'null',

        # The variables of the store.
        [Parameter()]
        [hashtable] $Variables
    )
    $param = @{
        Name   = $Name
        Secret = $Secret
        Vault  = $script:Config.SecretVaultName
    }
    if ($Variables) {
        $param.Metadata = $Variables
    }
    if ($PSCmdlet.ShouldProcess('Set-Secret', $param)) {
        Set-Secret @param
    }
}
