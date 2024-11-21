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

    $contextVault = Get-ContextVault

    $ID = "$($script:Config.SecretPrefix)$ID"

    $contextName = Get-SecretInfo -Vault $script:Config.VaultName -Name $ID | Select-Object -ExpandProperty Name

    Write-Verbose "Removing context [$ID] from [$($contextVault.Name)]"
    if ($PSCmdlet.ShouldProcess('Remove-Secret', $contextName)) {
        Write-Verbose "Removing secret [$contextName]"
        Remove-Secret -Name $contextName -Vault $contextVault.Name
    }
}
