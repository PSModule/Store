function Get-Store {
    <#
        .SYNOPSIS
        Get a store from the vault.

        .DESCRIPTION
        Get a store from the vault.

        .EXAMPLE
        Get-Store -Name 'MySecret'

        Get the store called 'MySecret' from the vault.
    #>
    [OutputType([hashtable])]
    param (
        # The name of the secret vault.
        [Parameter(Mandatory)]
        [string] $Name,

        # Set everything as plain text.
        [Parameter()]
        [switch] $AsPlainText
    )
    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.SecretVaultName }
    if (-not $secretVault) {
        return $null
    }
    $secretInfo = Get-SecretInfo -Vault $secretVault.Name | Where-Object { $_.Name -eq $Name }
    if (-not $secretInfo) {
        return $null
    }
    $metadata = $secretInfo | Select-Object -ExpandProperty Metadata
    $metadata + @{
        Secret = Get-Secret -Name $Name -Vault $script:Config.SecretVaultName -AsPlainText:$AsPlainText
    }
}
