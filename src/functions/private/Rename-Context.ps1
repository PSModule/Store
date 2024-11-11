function Rename-Context {
    <#
        .SYNOPSIS
        Renames a secret in the specified vault.

        .DESCRIPTION
        The `Rename-Context` function renames a secret in the specified vault.
        The function retrieves the existing secret's value and metadata (tags) and creates a new secret with the new name.
        If the new secret is created successfully, the old secret is removed.
        If the new secret is not created successfully the new secret is cleaned up.

        .EXAMPLE
        Rename-Context -Name 'OldSecret' -NewName 'NewSecret' -VaultName 'MyVault'

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
        $secretValue = Get-Secret -Name $Name -Vault $VaultName
        $secretInfo = Get-SecretInfo -Name $Name -Vault $VaultName

        # Check if the old secret exists
        if (-not $secretInfo) {
            Write-Verbose "Secret '$Name' not found in vault '$VaultName'."
            return
        }

        # Create a new secret with the new name, copying the value and tags
        Set-Secret -Name $NewName -Secret $secretValue -Vault $VaultName
        Write-Verbose "New secret '$NewName' created in vault '$VaultName'."

        # Verify that the new secret exists
        $newSecretInfo = Get-SecretInfo -Name $NewName -Vault $VaultName
        if ($newSecretInfo) {
            # Remove the old secret
            Remove-Secret -Name $Name -Vault $VaultName
            Write-Verbose "Old secret '$Name' removed from vault '$VaultName'."
        } else {
            Write-Verbose "Failed to create new secret '$NewName'. Old secret was not removed."
        }
    } catch {
        Write-Error "Error occurred: $_"
    }
}
