filter Remove-ContextSetting {
    <#
        .SYNOPSIS
        Remove a setting from the context.

        .DESCRIPTION
        This function removes a setting from the specified context.
        It supports wildcard patterns for the name and does accept pipeline input.

        .EXAMPLE
        Remove-ContextSetting -Name 'APIBaseUri' -Context 'GitHub'

        Remove the APIBaseUri setting from the 'GitHub' context.

        .EXAMPLE
        Get-ContextSetting -Context 'GitHub' | Remove-ContextSetting

        Remove all settings starting with 'API' from the 'GitHub' context.

        .EXAMPLE
        Remove-ContextSetting -Name 'API*' -Context 'GitHub'

        Remove all settings starting with 'API' from the 'GitHub' context.

        .EXAMPLE
        Get-ContextSetting -Context 'GitHub' | Where-Object { $_.Name -like 'API*' } | Remove-ContextSetting

        Remove all settings starting with 'API' from the 'GitHub' context using pipeline input.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Name of a setting to remove.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # The context to remove the setting from.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('ContextName')]
        [string] $Context
    )
    if ($PSCmdlet.ShouldProcess('Target', "Remove value [$Name] from context [$Context]")) {
        Set-ContextSetting -Name $Name -Value $null -Context $Context
    }
}
