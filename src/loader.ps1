### This is the backend configuration for the functionality
try {
    $initContextParams = @{
        Name = (Get-ContextConfig -Name SecretVaultName -Context $script:Config.Name) ?? $script:Config.SecretVaultName
        Type = (Get-ContextConfig -Name SecretVaultType -Context $script:Config.Name) ?? $script:Config.SecretVaultType
    }
    $vault = Initialize-SecretVault @initContextParams
    $script:Config.SecretVaultName = $vault.Name
    $script:Config.SecretVaultType = $vault.ModuleName
} catch {
    Write-Error "Failed to initialize secret vault: $_"
    return
}

### This is the context config for this module
$contextParams = @{
    Name      = $script:Config.Name
    Variables = @{
        SecretVaultName = $script:Config.SecretVaultName
        SecretVaultType = $script:Config.SecretVaultType
    }
}
try {
    Set-Context @contextParams
} catch {
    Write-Error "Failed to set context parameters: $_"
}
