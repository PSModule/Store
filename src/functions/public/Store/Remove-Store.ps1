filter Remove-Store {
    <#
        .SYNOPSIS
        Remove a store from the vault.

        .DESCRIPTION
        Remove a store from the vault.

        .EXAMPLE
        Remove-Store -Name 'MySecret'

        Removes the store called 'MySecret' from the vault.

        .EXAMPLE
        'MySecret*' | Remove-Store

        Removes all stores matching the pattern 'MySecret*' from the vault.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the secret vault.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $Name
    )

    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.SecretVaultName }
    if (-not $secretVault) {
        Write-Error 'Secret vault not found.'
        return
    }

    $secretInfos = Get-SecretInfo -Vault $secretVault.Name | Where-Object { $_.Name -like $Name }
    if (-not $secretInfos) {
        Write-Error 'No matching stores found.'
        return
    }

    foreach ($secretInfo in $secretInfos) {
        if ($PSCmdlet.ShouldProcess('Remove-Secret', $secretInfo.Name)) {
            Remove-Secret -Name $secretInfo.Name -Vault $script:Config.SecretVaultName
        }
    }
}
