#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }

filter Remove-ContextSetting {
    <#
        .SYNOPSIS
        Remove a setting from the context.

        .DESCRIPTION
        This function removes a setting from the specified context.
        It supports wildcard patterns for the name and does accept pipeline input.

        .PARAMETER Name
        Name of a setting to remove.

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
    param(
        # The name of the setting to remove.
        [Parameter(Mandatory)]
        [Alias('Setting')]
        [string] $Name,

        # The name of the context where the setting will be removed.
        [Parameter(Mandatory)]
        [Alias('ContextID')]
        [string] $ID
    )

    $null = Get-ContextVault
    $contextObj = Get-Context -ID $ID

    if (-not $contexts) {
        throw "Context [$ID] not found"
    }

    if ($PSCmdlet.ShouldProcess("[$($contextObj.Name)]", "Remove [$Name]")) {
        Write-Verbose "Setting [$Name] in [$($contextObj.Name)]"
        $contextObj.PSObject.Properties.Remove($Name)
        Set-Context -Context $contextObj -ID $ID
    }
}
