#Requires -Modules Microsoft.PowerShell.SecretManagement

function Get-ContextSetting {
    <#
        .SYNOPSIS
        Retrieve a setting from a context.

        .DESCRIPTION
        This function retrieves a setting from a specified context.
        If the setting is a secret, it can be returned as plain text using the -AsPlainText switch.

        .EXAMPLE
        Get-ContextSetting -Name 'APIBaseUri' -Context 'GitHub'

        Get the value of the 'APIBaseUri' setting from the 'GitHub' context.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param (
        # The context to get the configuration from.
        [Parameter(Mandatory)]
        [Alias('ContextName')]
        [string] $Context,

        # Name of a setting to get.
        [Parameter(Mandatory)]
        [string] $Name,

        # Return the setting as plain text if it is a secret.
        [Parameter()]
        [switch] $AsPlainText
    )

    Write-Verbose "Connecting to context vault [$($script:Config.Context.VaultName)]"
    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.Context.VaultName }
    if (-not $secretVault) {
        Write-Error $_
        throw "Context vault [$($script:Config.Context.VaultName)] not found"
    }

    Write-Verbose "Retrieving secret info for context [$Context] from vault [$($secretVault.Name)]"
    $secretValue = Get-Secret -Name $Context -Vault $script:Config.Context.VaultName
    if (-not $secretValue) {
        Write-Error $_
        throw "Context [$Context] not found"
    }

    Write-Verbose "Getting settings for context: [$Context]"
    $contextSetting = Get-Context -Name $Context -AsPlainText:$AsPlainText

    if ($null -eq $contextSetting) {
        Write-Verbose "No context found called: [$Context]"
        return
    }

    $contextSetting.$Name
}
