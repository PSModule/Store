#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }
#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

filter Remove-Context {
    <#
        .SYNOPSIS
        Remove a context from the context vault.

        .DESCRIPTION
        This function removes a context from the vault. It supports removing a single context by name,
        multiple contexts using wildcard patterns, and can also accept input from the pipeline.
        If the specified context(s) exist, they will be removed from the vault.

        .EXAMPLE
        Remove-Context

        Removes all contexts from the vault.

        .EXAMPLE
        Remove-Context -Name 'MySecret'

        Removes the context called 'MySecret' from the vault.

        .EXAMPLE
        Remove-Context -Name 'MySe*'

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
    param(
        # The name of the context to remove from the vault. Supports wildcard patterns.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [SupportsWildcards()]
        [Alias('Context', 'ContextName')]
        [string] $Name = '*'
    )

    $contextVault = Get-ContextVault

    $contexts = @()
    $contexts += Get-Context -Name $Name -AsPlainText

    Write-Verbose "Removing [$($contexts.count)] contexts from vault [$($contextVault.Name)]"
    foreach ($context in $contexts) {
        Write-Verbose "Removing context [$($context['Name'])]"
        $contextName = $($script:Config.Name) + $context['Name']
        if ($PSCmdlet.ShouldProcess('Remove-Secret', $contextName)) {
            Write-Verbose "Removing secret [$contextName]"
            Remove-Secret -Name $contextName -Vault $contextVault.Name
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-Context -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $commandAst, $fakeBoundParameter

    Get-Context -Name $wordToComplete | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
