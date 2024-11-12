﻿### This is the backend configuration for the functionality
try {
    $initContextParams = @{
        Name = (Get-ContextSetting -Name VaultName -Context $script:Config.Name) ?? $script:Config.Context.VaultName
        Type = (Get-ContextSetting -Name VaultType -Context $script:Config.Name) ?? $script:Config.Context.VaultType
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
    Name      = $script:Config.Name
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
