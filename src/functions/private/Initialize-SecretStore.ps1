﻿#Requires -Modules Microsoft.PowerShell.SecretManagement
#Requires -Modules Microsoft.PowerShell.SecretStore

function Initialize-SecretStore {
    <#
        .SYNOPSIS
        Initialize a secret vault.

        .DESCRIPTION
        Initialize a secret vault. If the vault does not exist, it will be created.

        .EXAMPLE
        Initialize-SecretStore -Name 'SecretStore' -Type 'Microsoft.PowerShell.SecretStore'

        Initializes a secret vault named 'SecretStore' using the 'Microsoft.PowerShell.SecretStore' module.

        .NOTES
        For more information about secret vaults, see
        https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param (
        # The name of the secret vault.
        [Parameter()]
        [string] $Name = 'SecretStore',

        # The type of the secret vault.
        [Parameter()]
        [Alias('ModuleName')]
        [string] $Type = 'Microsoft.PowerShell.SecretStore'
    )

    $vault = Get-SecretVault | Where-Object { $_.ModuleName -eq $Type }
    if (-not $vault) {
        Write-Verbose "[$Type] - Registering"

        switch ($Type) {
            'Microsoft.PowerShell.SecretStore' {
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
            }
        }
        Write-Verbose "[$Type] - Done"
    } else {
        Write-Verbose "[$Type] - already registered"
    }

    $secretStore = Get-SecretVault | Where-Object { $_.Name -eq $Name }
    if (-not $secretStore) {
        Write-Verbose "[$Name] - Registering"
        $secretVault = @{
            Name         = $Name
            ModuleName   = $Type
            DefaultVault = $true
            Description  = 'SecretStore'
        }
        Register-SecretVault @secretVault
        Write-Verbose "[$Name] - Done"
    } else {
        Write-Verbose "[$Name] - already registered"
    }

    Set-StoreVariable -Name 'SecretVaultName' -Value $Name
    Set-StoreVariable -Name 'SecretVaultType' -Value $Type

}
