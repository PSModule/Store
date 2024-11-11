filter Remove-ContextConfig {
    <#
        .SYNOPSIS
        Remove a named value from the context.

        .DESCRIPTION
        This function removes a named value from the specified context.
        It supports wildcard patterns for the name and can accept pipeline input from `Get-ContextConfig`.

        .EXAMPLE
        Remove-ContextConfig -Name 'APIBaseUri' -Context 'GitHub'

        Remove the APIBaseUri value from the 'GitHub' context.

        .EXAMPLE
        Get-ContextConfig -Context 'GitHub' | Remove-ContextConfig -Name 'API*'

        Remove all values starting with 'API' from the 'GitHub' context.

        .EXAMPLE
        Remove-ContextConfig -Name 'API*' -Context 'GitHub'

        Remove all values starting with 'API' from the 'GitHub' context.

        .EXAMPLE
        Get-ContextConfig -Context 'GitHub' | Where-Object { $_.Name -like 'API*' } | Remove-ContextConfig

        Remove all values starting with 'API' from the 'GitHub' context using pipeline input.
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

        # The context to remove the value from.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Context
    )
    if ($PSCmdlet.ShouldProcess("Target", "Remove value [$Name] from context [$Context]")) {
        Set-ContextConfig -Name $Name -Value $null -Context $Context
    }
}
