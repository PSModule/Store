#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }
#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretStore'; RequiredVersion = '1.0.6' }

function Initialize-ContextVault {
    <#
        .SYNOPSIS
        Initialize a context vault.

        .DESCRIPTION
        Initialize a context vault. If the vault does not exist, it will be created and registered.

        The SecretStore is created with the following parameters:
        - Authentication: None
        - PasswordTimeout: -1 (infinite)
        - Interaction: None
        - Scope: CurrentUser

        .EXAMPLE
        Initialize-ContextVault

        Initializes a context vault named 'ContextVault' using the 'Microsoft.PowerShell.SecretStore' module.
    #>
    [OutputType([Microsoft.PowerShell.SecretManagement.SecretVaultInfo])]
    [CmdletBinding()]
    param (
        # The name of the secret vault.
        [Parameter()]
        [string] $Name = $script:Config.VaultName,

        # The type of the secret vault.
        [Parameter()]
        [string] $Type = $script:Config.VaultType
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $vault = Get-SecretVault-Verbose:$false | Where-Object { $_.ModuleName -eq $Type }
            if (-not $vault) {
                Write-Debug "[$Type] - Configuring vault type"

                $vaultParameters = @{
                    Authentication  = 'None'
                    PasswordTimeout = -1
                    Interaction     = 'None'
                    Scope           = 'CurrentUser'
                    WarningAction   = 'SilentlyContinue'
                    Confirm         = $false
                    Force           = $true
                    Verbose         = $false
                }
                Reset-SecretStore @vaultParameters
                Write-Debug "[$Type] - Done"

                Write-Debug "[$Name] - Registering vault"
                $secretVault = @{
                    Name         = $Name
                    ModuleName   = $Type
                    DefaultVault = $true
                    Description  = 'SecretStore'
                    Verbose      = $false
                }
                Register-SecretVault @secretVault
                Write-Debug "[$Name] - Done"
            }

            Get-SecretVault -Verbose:$false | Where-Object { $_.ModuleName -eq $Type }
            Write-Debug "[$Name] - Vault registered"
            $script:Config.Initialized = $true
        } catch {
            Write-Error $_
            throw 'Failed to initialize context vault'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
