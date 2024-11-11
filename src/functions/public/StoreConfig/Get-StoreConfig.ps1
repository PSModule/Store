#Requires -Modules Microsoft.PowerShell.SecretManagement

function Get-StoreConfig {
    <#
        .SYNOPSIS
        Retrieve a named value from the store.

        .DESCRIPTION
        This function retrieves a named value from the specified store.
        If the value is a secret, it can be returned as plain text using the -AsPlainText switch.

        .EXAMPLE
        Get-StoreConfig -Name 'ApiBaseUri' -Store 'GitHub'

        Get the value of 'ApiBaseUri' config from the GitHub store.

        .EXAMPLE
        Get-StoreConfig -Name 'Api*' -Store 'GitHub'

        Get all configuration values from the GitHub store that match the wildcard pattern 'Api*'.
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
        [Parameter(Mandatory)]
        [string] $Store
    )

    Write-Verbose "Getting store configuration for store: [$Store]"
    $storeConfig = Get-Store -Name $Store -AsPlainText:$AsPlainText

    if ($null -eq $storeConfig) {
        Write-Verbose "No configuration found for store: [$Store]"
        return
    }

    Write-Verbose "Filtering configuration properties with name like: [$Name]"
    $matchingProperties = $storeConfig.PSObject.Properties.Where({ $_.Name -like $Name })

    if ($matchingProperties.Count -eq 0) {
        Write-Verbose "No matching properties found for name: [$Name]"
        return
    }

    Write-Verbose "Found matching properties: [$($matchingProperties.Name -join ', ')]"
    $matchingProperties.Value
}
