#Requires -Modules Microsoft.PowerShell.SecretManagement

function Set-ContextConfig {
    <#
        .SYNOPSIS
        Sets a variable or secret in the context.

        .DESCRIPTION
        The `Set-ContextConfig` function sets a variable or secret in the specified context.
        To store a secret, set the name to 'Secret'.

        .EXAMPLE
        Set-ContextConfig -Name 'ApiBaseUri' -Value 'https://api.github.com' -Context 'GitHub'

        Sets a variable called 'ApiBaseUri' in the context called 'GitHub'.

        .EXAMPLE
        $secret = 'myAccessToken' | ConvertTo-SecureString -AsPlainText -Force
        Set-ContextConfig -Name 'Secret' -Value $secret -Context 'GitHub'

        Sets a secret called 'AccessToken' in the configuration context called 'GitHub'.

        .NOTES
        This function requires the Microsoft.PowerShell.SecretManagement module.
    #>
    [OutputType([void])]
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

        # The name of the context where the variable or secret will be set.
        [Parameter(Mandatory)]
        [string] $Context
    )

    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.SecretVaultName }
    if (-not $secretVault) {
        Write-Error "Vault [$($script:Config.SecretVaultName)] not found"
        return
    }
    Write-Verbose "Retrieving secret info for context [$Context] from vault [$($secretVault.Name)]"
    $secretInfo = Get-SecretInfo -Name $Context -Vault $script:Config.SecretVaultName
    $secretValue = Get-Secret -Name $Context -Vault $script:Config.SecretVaultName
    if (-not $secretValue) {
        Write-Error "Context [$Context] not found"
        return
    }

    if ($PSCmdlet.ShouldProcess($Name, "Set value [$Value]")) {
        Write-Verbose "Processing [$Name] with value [$Value]"
        switch ($Name) {
            'Secret' {
                if ([string]::IsNullOrEmpty($Value)) {
                    Write-Verbose "Value is null or empty, setting to 'null'"
                    $Value = 'null'
                }
                if ($Value -is [SecureString]) {
                    Write-Verbose "Value is a SecureString, setting secret in vault [$($script:Config.SecretVaultName)]"
                    Set-Secret -Name $Context -SecureStringSecret $Value -Vault $script:Config.SecretVaultName
                } else {
                    Write-Verbose "Value is $($Value.GetType().FullName), setting secret in vault [$($script:Config.SecretVaultName)]"
                    Set-Secret -Name $Context -Value $Value -Vault $script:Config.SecretVaultName
                }
                break
            }
            'Name' {
                if ([string]::IsNullOrEmpty($Value)) {
                    Write-Error 'Name cannot be null or empty'
                    return
                }
                Set-Secret -Name $Value -SecureStringSecret $secretValue -Vault $Context -Metadata $secretInfo.Metadata
                $newSecretInfo = Get-SecretInfo -Name $Value -Vault $Context
                if ($newSecretInfo) {
                    Remove-Secret -Name $Name -Vault $Context
                } else {
                    Remove-Secret -Name $Value -Vault $Context
                }
                break
            }
            default {
                Write-Verbose 'Updating metadata'
                $metadata = ($secretInfo | Select-Object -ExpandProperty Metadata) + @{}
                if ([string]::IsNullOrEmpty($Value)) {
                    Write-Verbose " - Removing [$Name] from metadata"
                    $metadata.Remove($Name)
                } else {
                    Write-Verbose " - Setting [$Name] to [$Value] in metadata"
                    $metadata[$Name] = $Value
                }
                Write-Verbose "Updating secret info for context [$Context] in vault [$($script:Config.SecretVaultName)]"
                Set-SecretInfo -Name $Context -Metadata $metadata -Vault $script:Config.SecretVaultName
            }
        }
    }
}
