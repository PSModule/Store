### This is the backend configuration for the functionality
try {
    $initContextParams = @{
        Name = $script:Config.Context.VaultName
        Type = $script:Config.Context.VaultType
    }
    Initialize-ContextVault @initContextParams
} catch {
    Write-Error $_
    throw "Failed to initialize secret vault"
}
