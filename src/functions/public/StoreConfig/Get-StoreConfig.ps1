#Requires -Modules Microsoft.PowerShell.SecretManagement

function Get-StoreConfig {
    <#
        .SYNOPSIS
        Get a named value from the store.

        .DESCRIPTION
        Get a named value from the store.

        .EXAMPLE
        Get-StoreConfig -Name 'ApiBaseUri' -Store 'GitHub'

        Get the value of 'ApiBaseUri' config from the GitHub store.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param (
        # Name of a value to get.
        [Parameter(Mandatory)]
        [string] $Name,

        # Return the value as plain text if it is a secret.
        [Parameter()]
        [switch] $AsPlainText,

        # The store to get the configuration from.
        [Parameter()]
        [string] $Store
    )

    (Get-Store -Name $Store -AsPlainText:$AsPLainText).$Name
}
