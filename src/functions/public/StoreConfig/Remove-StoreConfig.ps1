filter Remove-StoreConfig {
    <#
        .SYNOPSIS
        Remove a named value from the store.

        .DESCRIPTION
        This function removes a named value from the specified store.
        It supports wildcard patterns for the name and can accept pipeline input from `Get-StoreConfig`.

        .EXAMPLE
        Remove-StoreConfig -Name 'ApiBaseUri' -Store 'GitHub'

        Remove the ApiBaseUri value from the 'GitHub' store.

        .EXAMPLE
        Get-StoreConfig -Store 'GitHub' | Remove-StoreConfig -Name 'Api*'

        Remove all values starting with 'Api' from the 'GitHub' store.

        .EXAMPLE
        Remove-StoreConfig -Name 'Api*' -Store 'GitHub'

        Remove all values starting with 'Api' from the 'GitHub' store.

        .EXAMPLE
        Get-StoreConfig -Store 'GitHub' | Where-Object { $_.Name -like 'Api*' } | Remove-StoreConfig

        Remove all values starting with 'Api' from the 'GitHub' store using pipeline input.
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

    $configs = Get-StoreConfig -Store $Store | Where-Object { $_.Name -like $Name }
    foreach ($config in $configs) {
        if ($PSCmdlet.ShouldProcess("config [$($config.Name)] from [$Store]", 'Remove')) {
            Set-StoreConfig -Store $Store -Name $config.Name -Value $null
        }
    }
}
