function Rename-Secret {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$NewName,

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

        # Optional: Retrieve tags if they are part of the metadata
        $tags = $secretInfo.Tags

        # Create a new secret with the new name, copying the value and tags
        Set-Secret -Name $NewSecretName -Secret $secretValue -Vault $VaultName -Tags $tags
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
