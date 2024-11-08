#Requires -Modules Microsoft.PowerShell.SecretManagement
#Requires -Modules Microsoft.PowerShell.SecretStore

function Initialize-SecretVault {
    <#
        .SYNOPSIS
        Initialize a SecretStore with open config.

        .DESCRIPTION
        Initialize a secret vault. If the vault does not exist, it will be created and registered.

        The SecretStore is created with the following parameters:
        - Authentication: None
        - PasswordTimeout: -1 (infinite)
        - Interaction: None
        - Scope: CurrentUser

        .EXAMPLE
        Initialize-SecretStore

        Initializes a secret vault named 'SecretStore' using the 'Microsoft.PowerShell.SecretStore' module.

        .NOTES
        For more information about secret vaults, see
        https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules
    #>
    [OutputType([Microsoft.PowerShell.SecretManagement.SecretVaultInfo])]
    [CmdletBinding()]
    param (
        # The name of the secret vault.
        [Parameter()]
        [string] $Name = $script:Config.SecretVaultName,

        # The type of the secret vault.
        [Parameter()]
        [string] $Type = $script:Config.SecretVaultType
    )
    $vault = Get-SecretVault | Where-Object { $_.ModuleName -eq $Type }
    if (-not $vault) {
        Write-Verbose "[$Type] - Configuring vault type"

        $vaultParameters = @{
            Authentication  = 'None'
            PasswordTimeout = -1
            Interaction     = 'None'
            Scope           = 'CurrentUser'
            WarningAction   = 'SilentlyContinue'
            Confirm         = $false
            Force           = $true
        }
        Reset-SecretStore @vaultParameters
        Write-Verbose "[$Type] - Done"

        Write-Verbose "[$Name] - Registering vault"
        $secretVault = @{
            Name         = $Name
            ModuleName   = $Type
            DefaultVault = $true
            Description  = 'SecretStore'
        }
        Register-SecretVault @secretVault
        Write-Verbose "[$Name] - Done"
    } else {
        Write-Verbose "[$Name] - Vault already registered"
    }

    Get-SecretVault | Where-Object { $_.ModuleName -eq $Type }

}
