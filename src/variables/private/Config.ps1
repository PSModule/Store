$script:Config = [pscustomobject]@{
    SecretPrefix = 'Context:'                         # $script:Config.SecretPrefix
    VaultName    = 'ContextVault'                     # $script:Config.VaultName
    VaultType    = 'Microsoft.PowerShell.SecretStore' # $script:Config.VaultType
}
