filter Remove-Context {
    <#
        .SYNOPSIS
        Remove a context from the vault.

        .DESCRIPTION
        This function removes a context from the vault. It supports removing a single context by name,
        multiple contexts using wildcard patterns, and can also accept input from the pipeline.
        If the specified context(s) exist, they will be removed from the vault.

        .EXAMPLE
        Remove-Context -Name 'MySecret'

        Removes the context called 'MySecret' from the vault.

        .EXAMPLE
        'MySecret*' | Remove-Context

        Removes all contexts matching the pattern 'MySecret*' from the vault.

        .EXAMPLE
        Get-Context -Name 'MySecret*' | Remove-Context

        Retrieves all contexts matching the pattern 'MySecret*' and removes them from the vault.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the secret vault.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name
    )

    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.SecretVaultName }
    if (-not $secretVault) {
        Write-Error 'Secret vault not found.'
        return
    }

    $secretInfos = Get-SecretInfo -Vault $secretVault.Name | Where-Object { $_.Name -like $Name }
    if (-not $secretInfos) {
        Write-Error 'No matching contexts found.'
        return
    }

    foreach ($secretInfo in $secretInfos) {
        if ($PSCmdlet.ShouldProcess('Remove-Secret', $secretInfo.Name)) {
            Remove-Secret -Name $secretInfo.Name -Vault $script:Config.SecretVaultName
        }
    }
}
