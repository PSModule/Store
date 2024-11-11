function Get-Store {
    <#
        .SYNOPSIS
        Get a store from the vault.

        .DESCRIPTION
        Get a store from the vault.

        .EXAMPLE
        Get-Store -Name 'MySecret'

        Get the store called 'MySecret' from the vault.

        .EXAMPLE
        Get-Store -Name 'My*'

        Get all stores that match the pattern 'My*' from the vault.

        .EXAMPLE
        Get-Store

        Get all stores from the vault.
    #>
    [OutputType([hashtable])]
    param (
        # The name of the secret vault.
        [Parameter()]
        [string] $Name,

        # Set everything as plain text.
        [Parameter()]
        [switch] $AsPlainText
    )

    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.SecretVaultName }
    if (-not $secretVault) {
        return $null
    }

    $secretInfos = Get-SecretInfo -Vault $secretVault.Name
    if (-not $secretInfos) {
        return $null
    }

    if ($Name) {
        if ($Name -like '*') {
            $secretInfos = $secretInfos | Where-Object { $_.Name -like $Name }
        } else {
            $secretInfos = $secretInfos | Where-Object { $_.Name -eq $Name }
        }
    }

    $stores = @()
    foreach ($secretInfo in $secretInfos) {
        $metadata = $secretInfo | Select-Object -ExpandProperty Metadata
        $store = $metadata + @{
            Secret = Get-Secret -Name $secretInfo.Name -Vault $script:Config.SecretVaultName -AsPlainText:$AsPlainText
        }
        $stores += $store
    }

    return $stores
}

# Register tab completer for the Name parameter
Register-ArgumentCompleter -CommandName Get-Store -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $null)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters # Suppress unused variable warning
    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.SecretVaultName }
    if (-not $secretVault) {
        return
    }

    $secretInfos = Get-SecretInfo -Vault $secretVault.Name
    if (-not $secretInfos) {
        return
    }

    $secretInfos | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
