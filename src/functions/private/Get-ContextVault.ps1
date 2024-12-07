#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

function Get-ContextVault {
    <#
        .SYNOPSIS
        Retrieves the context vault.

        .DESCRIPTION
        Connects to a context vault.
        If the vault name is not set in the configuration, it throws an error.
        If the specified vault is not found, it throws an error.
        Otherwise, it returns the secret vault object.

        .EXAMPLE
        Get-ContextVault

        This example retrieves the context vault.
    #>
    [CmdletBinding()]
    param()

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            if (-not $script:Config.Initialized) {
                Initialize-ContextVault
                Write-Debug "Connected to context vault [$($script:Config.VaultName)]"
            }
        } catch {
            Write-Error $_
            throw 'Failed to initialize secret vault'
        }

        try {
            $secretVault = Get-SecretVault -Verbose:$false | Where-Object { $_.Name -eq $script:Config.VaultName }
            if (-not $secretVault) {
                Write-Error $_
                throw "Context vault [$($script:Config.VaultName)] not found"
            }

            return $secretVault
        } catch {
            Write-Error $_
            throw 'Failed to get context vault'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
