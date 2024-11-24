#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

function Get-ContextSetting {
    <#
        .SYNOPSIS
        Retrieve a setting from a context.

        .DESCRIPTION
        This function retrieves a setting from a specified context.

        .EXAMPLE
        Get-ContextSetting -Context 'GitHub' -Name 'APIBaseUri'

        Get the value of the 'APIBaseUri' setting from the 'GitHub' context.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param (
        # The context to get the configuration from.
        [Parameter(Mandatory)]
        [Alias('ContextID')]
        [string] $ID,

        # Name of a setting to get.
        [Parameter(Mandatory)]
        [string] $Name
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        $null = Get-ContextVault
    }

    process {
        try {
            $context = Get-Context -ID $ID

            if (-not $context) {
                throw "Context [$ID] not found"
            }

            Write-Verbose "Returning setting: [$Name]"
            $context.$Name
        } catch {
            Write-Error $_
            throw 'Failed to get context setting'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}

Register-ArgumentCompleter -CommandName Get-ContextSetting -ParameterName ID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-Context | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}

Register-ArgumentCompleter -CommandName Get-ContextSetting -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-Context -ID $fakeBoundParameter.ID | ForEach-Object {
        $_.PSObject.Properties | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
        }
    }
}
