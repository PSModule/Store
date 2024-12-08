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
    [OutputType([object])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The ID of the context.
        [Parameter(Mandatory)]
        [string] $ID,

        # The data of the context.
        [Parameter()]
        [object] $Context = @{},

        # Pass the context through the pipeline.
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $null = Get-ContextVault
        $vaultName = $script:Config.VaultName
        $secretPrefix = $script:Config.SecretPrefix
    }

    process {
        try {
            $secret = ConvertTo-ContextJson -Context $Context -ID $ID
        } catch {
            Write-Error $_
            throw 'Failed to convert context to JSON'
        }

        $param = @{
            Name    = "$secretPrefix$ID"
            Secret  = $secret
            Vault   = $vaultName
            Verbose = $false
        }
        Write-Debug ($param | ConvertTo-Json -Depth 5)

        try {
            if ($PSCmdlet.ShouldProcess($ID, 'Set Secret')) {
                Set-Secret @param
            }
        } catch {
            Write-Error $_
            throw 'Failed to set secret'
        }

        if ($PassThru) {
            ConvertFrom-ContextJson -JsonString $secret
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
