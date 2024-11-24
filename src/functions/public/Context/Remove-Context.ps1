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
        Write-Debug "[$commandName] - Start"
        $null = Get-ContextVault
        $vaultName = $script:Config.VaultName
        $secretPrefix = $script:Config.SecretPrefix
        $fullID = "$secretPrefix$ID"
    }

    process {
        try {

            if ($PSCmdlet.ShouldProcess($fullID, 'Remove secret')) {
                Get-SecretInfo -Vault $vaultName | Where-Object { $_.Name -eq $fullID } | Remove-Secret
            }
        } catch {
            Write-Error $_
            throw 'Failed to remove context'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Register-ArgumentCompleter -CommandName Remove-Context -ParameterName ID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-SecretInfo -Vault $vaultName | Where-Object { $_.Name -like "$($script:Config.SecretPrefix)$wordToComplete*" } | ForEach-Object {
        $Name = $_.Name -replace "^$($script:Config.SecretPrefix)"
        [System.Management.Automation.CompletionResult]::new($Name, $Name, 'ParameterValue', $Name)
    }
}
