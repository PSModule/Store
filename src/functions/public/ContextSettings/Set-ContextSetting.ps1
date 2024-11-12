#Requires -Modules Microsoft.PowerShell.SecretManagement

function Set-ContextSetting {
    <#
        .SYNOPSIS
        Sets a setting in a context.

        .DESCRIPTION
        Sets a setting in the specified context.
        To store a secret, use the name 'Secret'.

        .EXAMPLE
        Set-ContextSetting -Name 'ApiBaseUri' -Value 'https://api.github.com' -Context 'GitHub'

        Sets a setting called 'ApiBaseUri' in the context called 'GitHub'.

        .EXAMPLE
        $secret = 'myAccessToken' | ConvertTo-SecureString -AsPlainText -Force
        Set-ContextSetting -Name 'Secret' -Value $secret -Context 'GitHub'

        Sets a secret in the configuration context called 'GitHub'.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the setting to set.
        [Parameter(Mandatory)]
        [string] $Name,

        # The value to set for the specified setting. This can be a plain text string or a secure string.
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [object] $Value,

        # The name of the context where the setting will be set.
        [Parameter(Mandatory)]
        [Alias('ContextName')]
        [string] $Context
    )

    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.Context.VaultName }
    if (-not $secretVault) {
        Write-Error "Vault [$($script:Config.Context.VaultName)] not found"
        return
    }
    Write-Verbose "Retrieving secret info for context [$Context] from vault [$($secretVault.Name)]"
    $secretInfo = Get-SecretInfo -Name $Context -Vault $script:Config.Context.VaultName
    $secretValue = Get-Secret -Name $Context -Vault $script:Config.Context.VaultName
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
                    Write-Verbose "Value is a SecureString, setting secret in vault [$($script:Config.Context.VaultName)]"
                    Set-Secret -Name $Context -SecureStringSecret $Value -Vault $script:Config.Context.VaultName
                } else {
                    Write-Verbose "Value is $($Value.GetType().FullName), setting secret in vault [$($script:Config.Context.VaultName)]"
                    Set-Secret -Name $Context -Value $Value -Vault $script:Config.Context.VaultName
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
                Write-Verbose "Updating secret info for context [$Context] in vault [$($script:Config.Context.VaultName)]"
                Set-SecretInfo -Name $Context -Metadata $metadata -Vault $script:Config.Context.VaultName
            }
        }
    }
}
