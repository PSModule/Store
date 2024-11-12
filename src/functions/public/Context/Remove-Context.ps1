filter Remove-Context {
    <#
        .SYNOPSIS
        Remove a context from the context vault.

        .DESCRIPTION
        This function removes a context from the vault. It supports removing a single context by name,
        multiple contexts using wildcard patterns, and can also accept input from the pipeline.
        If the specified context(s) exist, they will be removed from the vault.

        .EXAMPLE
        Remove-Context -Name 'MySecret'

        Removes the context called 'MySecret' from the vault.

        .EXAMPLE
        'MySecret*' | Remove-Context

        Removes all contexts matching the pattern 'MySecret*' from the vault.

        .EXAMPLE
        Get-Context -Name 'MySecret*' | Remove-Context

        Retrieves all contexts matching the pattern 'MySecret*' and removes them from the vault.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the secret vault.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Context', 'ContextName')]
        [string] $Name
    )

    Write-Verbose "Connecting to context vault [$($script:Config.Context.VaultName)]"
    $contextVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.Context.VaultName }
    if (-not $contextVault) {
        Write-Verbose "Context vault [$($script:Config.Context.VaultName)] not found"
        return $null
    }

    $contexts = Get-SecretInfo -Vault $contextVault.Name | Where-Object { $_.Name -like $Name }
    if (-not $contexts) {
        Write-Error 'No matching contexts found.'
        return
    }

    foreach ($context in $contexts) {
        if ($PSCmdlet.ShouldProcess('Remove-Secret', $context.Name)) {
            Remove-Secret -Name $context.Name -Vault $script:Config.Context.VaultName
        }
    }
}
