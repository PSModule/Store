### This is the backend configuration for the functionality
try {
    $initContextParams = @{
        Name = (Get-ContextSetting -Name ContextVaultName -Context $script:Config.Context.Name) ?? $script:Config.Context.VaultName
        Type = (Get-ContextSetting -Name ContextVaultType -Context $script:Config.Context.Name) ?? $script:Config.Context.VaultType
    }
    $vault = Initialize-SecretVault @initContextParams
    $script:Config.Context.VaultName = $vault.Name
    $script:Config.Context.VaultType = $vault.ModuleName
} catch {
    Write-Error "Failed to initialize secret vault: $_"
    return
}

### This is the context config for this module
$contextParams = @{
    Name      = $script:Config.Context.Name
    Variables = @{
        ContextVaultName = $script:Config.Context.VaultName
        ContextVaultType = $script:Config.Context.VaultType
    }
}
try {
    Set-Context @contextParams
} catch {
    Write-Error "Failed to set context parameters: $_"
}
