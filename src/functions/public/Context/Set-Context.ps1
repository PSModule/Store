#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

function Set-Context {
    <#
        .SYNOPSIS
        Set a context in the vault.

        .DESCRIPTION
        If the context does not exist, it will be created. If it already exists, it will be updated.

        .EXAMPLE
        Set-Context -Context @{ Name = 'MySecret' }

        Create a context called 'MySecret' in the vault.

        .EXAMPLE
        Set-Context -Context @{ Name = 'MySecret'; Key = 'Value' }

        Creates a context called 'MySecret' in the vault with the settings.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The data of the context.
        [Parameter()]
        [hashtable] $Context = @{}
    )

    if ([string]::IsNullOrEmpty($Context['Name'])) {
        throw 'The context must have a name.'
    }

    $contextVault = Get-ContextVault

    $Context['Name'] = $($script:Config.Name) + $Context['Name']

    $param = @{
        Name   = $Context['Name']
        Secret = $Context
        Vault  = $contextVault.Name
    }

    if ($PSCmdlet.ShouldProcess('Set-Secret', $param)) {
        Set-Secret @param
    }
}
