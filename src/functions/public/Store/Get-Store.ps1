﻿function Get-Store {
    <#
        .SYNOPSIS
        Retrieves secrets from a specified secret vault.

        .DESCRIPTION
        The `Get-Store` cmdlet retrieves secrets from a specified secret vault.
        You can specify the name of the secret to retrieve or use a wildcard pattern to retrieve multiple secrets.
        If no name is specified, all secrets from the vault will be retrieved.
        Optionally, you can choose to retrieve the secrets as plain text.

        .EXAMPLE
        Get-Store

        Get all stores from the vault.

        .EXAMPLE
        Get-Store -Name 'MySecret'

        Get the store called 'MySecret' from the vault.

        .EXAMPLE
        Get-Store -Name 'My*'

        Get all stores that match the pattern 'My*' from the vault.
    #>
    [OutputType([hashtable])]
    [CmdletBinding()]
    param (
        # The name of the secret to retrieve from the vault. Supports wildcard patterns.
        [Parameter()]
        [string] $Name,

        # Switch to retrieve the secrets as plain text.
        [Parameter()]
        [switch] $AsPlainText
    )

    Write-Verbose "Retrieving secret vault with name [$($script:Config.SecretVaultName)]"
    $secretVault = Get-SecretVault | Where-Object { $_.Name -eq $script:Config.SecretVaultName }
    if (-not $secretVault) {
        Write-Verbose "No secret vault found with name [$($script:Config.SecretVaultName)]"
        return $null
    }

    Write-Verbose "Retrieving secret infos from vault [$($secretVault.Name)]"
    $secretInfos = Get-SecretInfo -Vault $secretVault.Name
    if (-not $secretInfos) {
        Write-Verbose "No secret infos found in vault [$($secretVault.Name)]"
        return $null
    }

    if ($Name) {
        Write-Verbose "Filtering secret infos with name pattern [$Name]"
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
