#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }
#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

function Get-Context {
    <#
        .SYNOPSIS
        Retrieves a context from the context vault.

        .DESCRIPTION
        Retrieves contexts from a specified context vault. You can specify the name of the context to retrieve or use a wildcard pattern to retrieve
        multiple contexts. If no name is specified, all contexts from the context vault will be retrieved.
        Optionally, you can choose to retrieve the contexts as plain text by providing the -AsPlainText switch.

        .PARAMETER Name
        The name of the context to retrieve from the vault. Supports wildcard patterns.

        .EXAMPLE
        Get-Context

        Get all contexts from the context vault.

        .EXAMPLE
        Get-Context -Name 'MySecret'

        Get the context called 'MySecret' from the vault.

        .EXAMPLE
        Get-Context -Name 'My*'

        Get all contexts that match the pattern 'My*' from the vault.
    #>
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        # Switch to retrieve all the contexts secrets as plain text.
        [Parameter()]
        [switch] $AsPlainText
    )

    dynamicparam {
        $dynamicParamDictionary = New-DynamicParamDictionary

        $nameParam = @{
            Name                   = 'Name'
            Alias                  = 'Context', 'ContextName'
            Type                   = [string]
            SupportsWildcards      = $true
            ValidateSet            = @('*') + (Get-SecretInfo -Vault $script:Config.Context.VaultName -Name "$($script:Config.Name)*" |
                    Select-Object -ExpandProperty Name | ForEach-Object { $_.Replace($script:Config.Name, '') })
            DynamicParamDictionary = $dynamicParamDictionary
        }
        New-DynamicParam @nameParam

        return $dynamicParamDictionary
    }

    begin {
        $filter = if ([string]::IsNullOrEmpty($PSBoundParameters.Name)) { '*' } else { $PSBoundParameters.Name }
        $Name = $($script:Config.Name) + $filter
    }

    process {
        $contextVault = Get-ContextVault

        Write-Verbose "Retrieving contexts from vault [$($contextVault.Name)] using pattern [$Name]"
        $contexts = Get-SecretInfo -Vault $contextVault.Name | Where-Object { $_.Name -like "$Name" }

        Write-Verbose "Found [$($contexts.Count)] contexts in context vault [$($contextVault.Name)]"
        foreach ($context in $contexts) {
            Get-Secret -Name $context.Name -Vault $contextVault.Name -AsPlainText:$AsPlainText
        }
    }
}
