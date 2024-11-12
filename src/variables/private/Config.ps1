$script:Config = [pscustomobject]@{
    Name    = 'PSModule.Store'                         # $script:Config.Context.Name
    Context = [pscustomobject]@{
        VaultName = 'SecretStore'                      # $script:Config.Context.VaultName
        VaultType = 'Microsoft.PowerShell.SecretStore' # $script:Config.Context.VaultType
    }
}
