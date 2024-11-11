### This is the backend configuration for the functionality
try {
    $initStoreParams = @{
        Name = (Get-StoreConfig -Name SecretVaultName -Store $script:Config.Name) ?? $script:Config.SecretVaultName
        Type = (Get-StoreConfig -Name SecretVaultType -Store $script:Config.Name) ?? $script:Config.SecretVaultType
    }
    $vault = Initialize-SecretVault @initStoreParams
    $script:Config.SecretVaultName = $vault.Name
    $script:Config.SecretVaultType = $vault.ModuleName
} catch {
    Write-Error "Failed to initialize secret vault: $_"
    return
}

### This is the store config for this module
$storeParams = @{
    Name      = $script:Config.Name
    Variables = @{
        SecretVaultName = $script:Config.SecretVaultName
        SecretVaultType = $script:Config.SecretVaultType
    }
}
try {
    Set-Store @storeParams
} catch {
    Write-Error "Failed to set store parameters: $_"
}
