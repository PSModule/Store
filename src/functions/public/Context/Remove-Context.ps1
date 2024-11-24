#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }
#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

filter Remove-Context {
    <#
        .SYNOPSIS
        Removes a context from the context vault.

        .DESCRIPTION
        This function removes a context from the vault. It supports removing a single context by name,
        multiple contexts using wildcard patterns, and can also accept input from the pipeline.
        If the specified context(s) exist, they will be removed from the vault.

        .EXAMPLE
        Remove-Context

        Removes all contexts from the vault.

        .EXAMPLE
        Remove-Context -ID 'MySecret'

        Removes the context called 'MySecret' from the vault.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the context to remove from the vault.
        [Parameter()]
        [Alias('ContextID')]
        [string] $ID
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        $null = Get-ContextVault
        $vaultName = $script:Config.VaultName
    }

    process {
        try {
            $ID = "$($script:Config.SecretPrefix)$ID"

            if ($PSCmdlet.ShouldProcess('Remove-Secret', $context.Name)) {
                Get-SecretInfo -Vault $vaultName | Where-Object { $_.Name -eq $ID } | Remove-Secret
            }
        } catch {
            Write-Error $_
            throw 'Failed to remove context'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
