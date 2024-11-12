### This is the backend configuration for the functionality
try {
    $initContextParams = @{
        Name = (Get-ContextSetting -Name VaultName -Context $script:Config.Name) ?? $script:Config.Context.VaultName
        Type = (Get-ContextSetting -Name VaultType -Context $script:Config.Name) ?? $script:Config.Context.VaultType
    }
    Initialize-ContextVault @initContextParams
    $script:Config.Context.VaultName = $vault.Name
    $script:Config.Context.VaultType = $vault.ModuleName
    Write-Verbose "Initialized secret vault [$($script:Config.Context.VaultName)] of type [$($script:Config.Context.VaultType)]"
} catch {
    Write-Error $_
    throw "Failed to initialize secret vault"
}

### This is the context config for this module
$contextParams = @{
    Name = $script:Config.Name
}
try {
    Set-Context @contextParams
} catch {
    Write-Error $_
    throw 'Failed to initialize secret vault'
}
