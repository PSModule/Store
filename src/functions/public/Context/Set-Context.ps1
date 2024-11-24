#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

function Set-Context {
    <#
        .SYNOPSIS
        Set a context and store it in the context vault.

        .DESCRIPTION
        If the context does not exist, it will be created. If it already exists, it will be updated.

        .EXAMPLE
        Set-Context -ID 'PSModule.GitHub' -Context @{ Name = 'MySecret' }

        Create a context called 'MySecret' in the vault.

        .EXAMPLE
        Set-Context -ID 'PSModule.GitHub' -Context @{ Name = 'MySecret'; AccessToken = '123123123' }

        Creates a context called 'MySecret' in the vault with the settings.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The ID of the context.
        [Parameter(Mandatory)]
        [Alias('ContextID')]
        [string] $ID,

        # The data of the context.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        $null = Get-ContextVault
        $vaultName = $script:Config.VaultName
    }

    process {
        try {
            $secret = ConvertTo-ContextJson -Context $Context
        } catch {
            Write-Error $_
            throw 'Failed to convert context to JSON'
        }

        $Name = "$($script:Config.SecretPrefix)$ID"

        $param = @{
            Name   = $Name
            Secret = $secret
            Vault  = $vaultName
        }
        Write-Verbose ($param | ConvertTo-Json -Depth 5)

        try {
            if ($PSCmdlet.ShouldProcess($Name, 'Set Secret')) {
                Set-Secret @param
            }
        } catch {
            Write-Error $_
            throw 'Failed to set secret'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
