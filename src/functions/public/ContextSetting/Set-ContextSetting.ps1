#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }
#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

function Set-ContextSetting {
    <#
        .SYNOPSIS
        Sets a setting in a context.

        .DESCRIPTION
        Sets a setting in the specified context.

        .EXAMPLE
        Set-ContextSetting -Name 'ApiBaseUri' -Value 'https://api.github.com' -Context 'GitHub'

        Sets a setting called 'ApiBaseUri' in the context called 'GitHub'.

        .EXAMPLE
        $secret = 'myAccessToken' | ConvertTo-SecureString -AsPlainText -Force
        Set-ContextSetting -Name 'Secret' -Value $secret -Context 'GitHub'

        Sets a secret in the configuration context called 'GitHub'.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the setting to set.
        [Parameter(Mandatory)]
        [string] $Name,

        # The value to set for the specified setting. This can be a plain text string or a secure string.
        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [object] $Value,

        # The name of the context where the setting will be set.
        [Parameter(Mandatory)]
        [Alias('ContextID')]
        [string] $ID
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $context = Get-Context -ID $ID

            if (-not $context) {
                throw "Context [$ID] not found"
            }

            if ($PSCmdlet.ShouldProcess($Name, "Set value [$Value]")) {
                Write-Debug "Setting [$Name] to [$Value] in [$ID]"
                if ($context.PSObject.Properties[$Name]) {
                    $context.$Name = $Value
                } else {
                    $context | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
                }
                Set-Context -Context $context -ID $ID
            }
        } catch {
            Write-Error $_
            throw 'Failed to set context setting'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Register-ArgumentCompleter -CommandName Get-ContextSetting -ParameterName ID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-ContextInfo | Where-Object { $_.Name -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
        }
}
