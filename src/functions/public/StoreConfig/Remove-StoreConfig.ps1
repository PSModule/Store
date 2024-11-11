filter Remove-StoreConfig {
    <#
        .SYNOPSIS
        Remove a named value from the store.

        .DESCRIPTION
        This function removes a named value from the specified store.
        It supports wildcard patterns for the name and can accept pipeline input from `Get-StoreConfig`.

        .EXAMPLE
        Remove-StoreConfig -Name 'APIBaseUri' -Store 'GitHub'

        Remove the APIBaseUri value from the 'GitHub' store.

        .EXAMPLE
        Get-StoreConfig -Store 'GitHub' | Remove-StoreConfig -Name 'API*'

        Remove all values starting with 'API' from the 'GitHub' store.

        .EXAMPLE
        Remove-StoreConfig -Name 'API*' -Store 'GitHub'

        Remove all values starting with 'API' from the 'GitHub' store.

        .EXAMPLE
        Get-StoreConfig -Store 'GitHub' | Where-Object { $_.Name -like 'API*' } | Remove-StoreConfig

        Remove all values starting with 'API' from the 'GitHub' store using pipeline input.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Name of a value to remove.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # The store to remove the value from.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Store
    )
    if ($PSCmdlet.ShouldProcess("Target", "Remove value [$Name] from store [$Store]")) {
        Set-StoreConfig -Name $Name -Value $null -Store $Store
    }
}
