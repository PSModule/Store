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

    if ($PSCmdlet.ShouldProcess('Target', "Remove value [$Name] from context [$Context]")) {
        Set-ContextSetting -Name $Name -Value $null -Context $Context
    }
}
