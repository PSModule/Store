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
        [object] $Secret = 'null',

        # The variables of the store.
        [Parameter()]
        [hashtable] $Variables
    )

    $param = @{
        Name  = $Name
        Vault = $script:Config.SecretVaultName
    }

    #Map secret based on type, to Secret or SecureStringSecret
    if ($Secret -is [System.Security.SecureString]) {
        $param['SecureStringSecret'] = $Secret
    } elseif ($Secret -is [string]) {
        $param['Secret'] = $Secret
    } else {
        throw 'Invalid secret type'
    }

    if ($Variables) {
        $param['Metadata'] = $Variables
    }
    if ($PSCmdlet.ShouldProcess('Set-Secret', $param)) {
        Set-Secret @param
    }
}
