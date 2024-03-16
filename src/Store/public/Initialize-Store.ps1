function Initialize-Store {
    [CmdletBinding()]
    param (
        # Name of the store.
        [Parameter(Mandatory)]
        [string] $Name,

        # The name of the secret vault.
        [Parameter()]
        [string] $SecretVaultName = 'SecretStore',

        # The type of the secret vault.
        [Parameter()]
        [string] $SecretVaultType = 'Microsoft.PowerShell.SecretStore'
    )

    Initialize-VariableStore -Name $Name
    Initialize-SecretStore -Name $SecretVaultName -Type $SecretVaultType
}
