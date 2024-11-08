function Remove-Store {
    <#
        .SYNOPSIS
        Remove a store from the vault.

        .DESCRIPTION
        Remove a store from the vault.

        .EXAMPLE
        Remove-Store -Name 'MySecret'

        Removes the store called 'MySecret' from the vault.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the secret vault.
        [Parameter(Mandatory)]
        [string] $Name
    )
    if ($PSCmdlet.ShouldProcess('Remove-Secret', $Name)) {
        Get-SecretInfo | Where-Object { $_.Name -eq $Name } | ForEach-Object {
            Remove-Secret -Name $_.Name -Vault $script:Config.SecretVaultName
        }
    }
}
