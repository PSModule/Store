function Remove-StoreConfig {
    <#
        .SYNOPSIS
        Remove a named value from the store.

        .DESCRIPTION
        Remove a named value from the store.

        .EXAMPLE
        Remove-StoreConfig -Name 'ApiBaseUri' -Store 'GitHub'

        Remove the ApiBaseUri value from the 'GitHub' store.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Name of a value to remove.
        [Parameter(Mandatory)]
        [string] $Name,

        # The store to remove the value from.
        [Parameter()]
        [string] $Store
    )

    if ($PSCmdlet.ShouldProcess("config '$Name' from '$Store'", 'Remove')) {

    }
    Set-StoreConfig -Store $Store -Name $Name -Value $null
}
