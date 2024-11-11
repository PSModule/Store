function Rename-Context {
    <#
        .SYNOPSIS
        Renames a secret in the specified vault.

        .DESCRIPTION
        The `Rename-Secret` function renames a secret in the specified vault.
        The function retrieves the existing secret's value and metadata (tags) and creates a new secret with the new name.
        If the new secret is created successfully, the old secret is removed.
        If the new secret is not created successfully the new secret is cleaned up.

        .EXAMPLE
        Rename-Secret -Name 'OldSecret' -NewName 'NewSecret' -VaultName 'MyVault'

        .NOTES
        General notes
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param (
        # The name of the secret to rename.
        [Parameter(Mandatory)]
        [string]$Name,

        # The new name for the secret.
        [Parameter(Mandatory)]
        [string]$NewName,

        # The name of the vault where the secret is stored.
        [Parameter(Mandatory)]
        [string]$VaultName
    )

    # Retrieve the existing secret's value and metadata (tags)
    try {
        $secretValue = Get-Secret -Name $OldSecretName -Vault $VaultName
        $secretInfo = Get-SecretInfo -Name $OldSecretName -Vault $VaultName

        # Check if the old secret exists
        if (-not $secretInfo) {
            Write-Verbose "Secret '$OldSecretName' not found in vault '$VaultName'."
            return
        }

        # Create a new secret with the new name, copying the value and tags
        Set-Secret -Name $NewSecretName -Secret $secretValue -Vault $VaultName
        Write-Verbose "New secret '$NewSecretName' created in vault '$VaultName'."

        # Verify that the new secret exists
        $newSecretInfo = Get-SecretInfo -Name $NewSecretName -Vault $VaultName
        if ($newSecretInfo) {
            # Remove the old secret
            Remove-Secret -Name $OldSecretName -Vault $VaultName
            Write-Verbose "Old secret '$OldSecretName' removed from vault '$VaultName'."
        } else {
            Write-Verbose "Failed to create new secret '$NewSecretName'. Old secret was not removed."
        }
    } catch {
        Write-Error "Error occurred: $_"
    }
}
