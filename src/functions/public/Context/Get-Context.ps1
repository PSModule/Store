#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

filter Get-Context {
    <#
        .SYNOPSIS
        Retrieves a context from the context vault.

        .DESCRIPTION
        Retrieves contexts from a specified context vault. You can specify the name of the context to retrieve or use a wildcard pattern to retrieve
        multiple contexts. If no name is specified, all contexts from the context vault will be retrieved.
        Optionally, you can choose to retrieve the contexts as plain text by providing the -AsPlainText switch.

        .EXAMPLE
        Get-Context

        Get all contexts from the context vault.

        .EXAMPLE
        Get-Context -Name 'MySecret'

        Get the context called 'MySecret' from the vault.

        .EXAMPLE
        Get-Context -Name 'My*'

        Get all contexts that match the pattern 'My*' from the vault.

        .EXAMPLE
        'My*' | Get-Context

        Get all contexts that match the pattern 'My*' from the vault.
    #>
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param(
        # The name of the context to retrieve from the vault. Supports wildcard patterns.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [SupportsWildcards()]
        [Alias('Context', 'ContextName')]
        [string] $Name = '*',

        # Switch to retrieve all the contexts secrets as plain text.
        [Parameter()]
        [switch] $AsPlainText
    )

    $Name = $($script:Config.Name) + $Name

    $contextVault = Get-ContextVault

    Write-Verbose "Retrieving contexts from vault [$($contextVault.Name)] using pattern [$Name]"
    $contexts = @(Get-SecretInfo -Vault $contextVault.Name | Where-Object { $_.Name -like "$Name" })

    Write-Verbose "Found [$($contexts.Count)] contexts in context vault [$($contextVault.Name)]"
    $contextList = @()
    foreach ($context in $contexts) {
        $contextList += Get-Secret -Name $context.Name -Vault $contextVault.Name -AsPlainText:$AsPlainText
    }
    $contextList
}

Register-ArgumentCompleter -CommandName Get-Context -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $commandAst, $fakeBoundParameter

    Get-SecretInfo -Vault $script:Config.Context.VaultName -Name "$($script:Config.Name)$wordToComplete*" -Verbose:$false |
        ForEach-Object {
            $contextName = $_.Name.Replace($script:Config.Name, '')
            [System.Management.Automation.CompletionResult]::new($contextName, $contextName, 'ParameterValue', $contextName)
        }
}
