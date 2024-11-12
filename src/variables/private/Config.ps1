$script:Config = @{
    Context = @{
        Name             = 'PSModule.Store'                   # $script:Config.Context.Name
        ContextVaultName = 'SecretStore'                      # $script:Config.Context.VaultName
        ContextVaultType = 'Microsoft.PowerShell.SecretStore' # $script:Config.Context.VaultType
    }
}
