$script:Config = [pscustomobject]@{
    SecretPrefix = 'Context:'                         # $script:Config.SecretPrefix
    VaultName    = 'SecretStore'                      # $script:Config.VaultName
    VaultType    = 'Microsoft.PowerShell.SecretStore' # $script:Config.VaultType
}
