#Requires -Modules Microsoft.PowerShell.SecretManagement

function Get-ContextConfig {
    <#
        .SYNOPSIS
        Retrieve a named value from the context.

        .DESCRIPTION
        This function retrieves a named value from the specified context.
        If the value is a secret, it can be returned as plain text using the -AsPlainText switch.

        .EXAMPLE
        Get-ContextConfig -Name 'ApiBaseUri' -Context 'GitHub'

        Get the value of 'ApiBaseUri' config from the GitHub context.

        .EXAMPLE
        Get-ContextConfig -Name 'Api*' -Context 'GitHub'

        Get all configuration values from the GitHub context that match the wildcard pattern 'Api*'.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param (
        # The context to get the configuration from.
        [Parameter(Mandatory)]
        [string] $Context,

        # Name of a value to get.
        [Parameter(Mandatory)]
        [string] $Name,

        # Return the value as plain text if it is a secret.
        [Parameter()]
        [switch] $AsPlainText
    )

    Write-Verbose "Getting context configuration for context: [$Context]"
    $contextConfig = Get-Context -Name $Context -AsPlainText:$AsPlainText

    if ($null -eq $contextConfig) {
        Write-Verbose "No configuration found for context: [$Context]"
        return
    }

    $contextConfig.$Name
}
