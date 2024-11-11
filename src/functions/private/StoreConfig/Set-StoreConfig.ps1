#Requires -Modules Microsoft.PowerShell.SecretManagement

function Set-StoreConfig {
    <#
        .SYNOPSIS
        Sets a variable or secret in the store.

        .DESCRIPTION
        The `Set-StoreConfig` function sets a variable or secret in the specified store.
        To store a secret, set the name to 'Secret'.

        .EXAMPLE
        Set-StoreConfig -Name 'ApiBaseUri' -Value 'https://api.github.com' -Store 'GitHub'

        Sets a variable called 'ApiBaseUri' in the store called 'GitHub'.

        .EXAMPLE
        $secret = 'myAccessToken' | ConvertTo-SecureString -AsPlainText -Force
        Set-StoreConfig -Name 'Secret' -Value $secret -Store 'GitHub'

        Sets a secret called 'AccessToken' in the configuration store called 'GitHub'.

        .NOTES
        This function requires the Microsoft.PowerShell.SecretManagement module.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the variable or secret to set.
        [Parameter(Mandatory)]
        [string] $Name,

        # The value to set for the specified name. This can be a plain text string or a secure string.
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [object] $Value,

        # The name of the store where the variable or secret will be set.
        [Parameter(Mandatory)]
        [string] $Store
    )

    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.SecretVaultName }
    if (-not $secretVault) {
        Write-Error "Vault [$($script:Config.SecretVaultName)] not found"
        return
    }
    if ($PSCmdlet.ShouldProcess($Name, "Set value [$Value]")) {
        Write-Verbose "Processing [$Name] with value [$Value]"
        if ($Name -eq 'Secret') {
            if ([string]::IsNullOrEmpty($Value)) {
                Write-Verbose "Value is null or empty, setting to 'null'"
                $Value = 'null'
            }
            if ($Value -is [SecureString]) {
                Write-Verbose "Value is a SecureString, setting secret in vault [$($script:Config.SecretVaultName)]"
                Set-Secret -Name $Store -SecureStringSecret $Value -Vault $script:Config.SecretVaultName
            } else {
                Write-Verbose "Value is not a SecureString, setting secret in vault [$($script:Config.SecretVaultName)]"
                Set-Secret -Name $Store -Value $Value -Vault $script:Config.SecretVaultName
            }
        } else {
            Write-Verbose "Retrieving secret info for store [$Store] from vault [$($secretVault.Name)]"
            $secretInfo = Get-SecretInfo -Vault $secretVault.Name | Where-Object { $_.Name -eq $Store }
            if (-not $secretInfo) {
                Write-Error "Store [$Store] not found"
                return
            }
            Write-Verbose 'Secret info retrieved, updating metadata'
            $metadata = ($secretInfo | Select-Object -ExpandProperty Metadata) + @{}
            if ([string]::IsNullOrEmpty($Value)) {
                Write-Verbose "Value is null or empty, removing [$Name] from metadata"
                $metadata.Remove($Name)
            } else {
                Write-Verbose "Setting [$Name] to [$Value] in metadata"
                $metadata[$Name] = $Value
            }
            Write-Verbose "Updating secret info for store [$Store] in vault [$($script:Config.SecretVaultName)]"
            Set-SecretInfo -Name $Store -Metadata $metadata -Vault $script:Config.SecretVaultName
        }
    }
}
