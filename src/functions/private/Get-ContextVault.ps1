function Get-ContextVault {
    <#
        .SYNOPSIS
        Retrieves the context vault based on the configured vault name.

        .DESCRIPTION
        Connects to a secret vault specified in the script configuration.
        If the vault name is not set in the configuration, it throws an error.
        If the specified vault is not found, it throws an error.
        Otherwise, it returns the secret vault object.

        .EXAMPLE
        $vault = Get-ContextVault
        $vault.Secrets

        This example retrieves the context vault and lists its secrets.
    #>
    [CmdletBinding()]
    param()

    if (-not $script:Config.Context.VaultName) {
        throw 'Context vault name not set'
    }

    Write-Verbose "Connecting to context vault [$($script:Config.Context.VaultName)]"
    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.Context.VaultName }
    if (-not $secretVault) {
        Write-Error $_
        throw "Context vault [$($script:Config.Context.VaultName)] not found"
    }

    return $secretVault
}
