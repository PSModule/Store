function Set-Context {
    <#
        .SYNOPSIS
        Set a context in the vault.

        .DESCRIPTION
        If the context does not exist, it will be created. If it already exists, it will be updated.

        .EXAMPLE
        Set-Context -Name 'MySecret'

        Create a context called 'MySecret' in the vault.

        .EXAMPLE
        Set-Context -Name 'MySecret' -Secret 'MySecret'

        Creates a context called 'MySecret' in the vault with the secret.

        .EXAMPLE
        Set-Context -Name 'MySecret' -Secret 'MySecret' -Variables @{ 'Key' = 'Value' }

        Creates a context called 'MySecret' in the vault with the secret and variables.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the context.
        [Parameter()]
        [Alias('Context', 'ContextName')]
        [string] $Name,

        # The secret of the context.
        [Parameter()]
        [object] $Secret = 'null',

        # The variables of the context.
        [Parameter()]
        [hashtable] $Variables
    )

    Write-Verbose "Connecting to context vault [$($script:Config.Context.VaultName)]"
    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.Context.VaultName }
    if (-not $secretVault) {
        Write-Error $_
        throw "Context vault [$($script:Config.Context.VaultName)] not found"
    }

    $param = @{
        Name  = $Name
        Vault = $script:Config.Context.VaultName
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
