try {
    Initialize-ContextVault
} catch {
    Write-Error $_
    throw 'Failed to initialize secret vault'
}
