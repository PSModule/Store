
### This is the backend configuration for the functionality
$initStoreParams = @{
    Name = (Get-StoreConfig -Name SecretVaultName -Store $script:Config.Name) ?? $script:Config.SecretVaultName
    Type = (Get-StoreConfig -Name SecretVaultType -Store $script:Config.Name) ?? $script:Config.SecretVaultType
}
$vault = Initialize-SecretVault @initStoreParams
$script:Config.SecretVaultName = $vault.Name
$script:Config.SecretVaultType = $vault.ModuleName

### This is the store config for this module
$storeParams = @{
    Name     = $script:Config.Name
    Metadata = @{
        SecretVaultName = $script:Config.SecretVaultName
        SecretVaultType = $script:Config.SecretVaultType
    }
}
Set-Store @storeParams
