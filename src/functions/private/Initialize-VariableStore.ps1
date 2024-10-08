﻿function Initialize-VariableStore {
    <#
        .SYNOPSIS
        Initialize the variable store.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [string] $Name
    )

    $folderName = ".$($Name -replace '^\.')".ToLower()
    $configFilePath = Join-Path -Path $HOME -ChildPath "$folderName/config.json"

    if (-not (Test-Path -Path $configFilePath)) {
        $null = New-Item -Path $configFilePath -ItemType File -Force
        Set-StoreVariable -Name 'ConfigFilePath' -Value $configFilePath
        Set-StoreVariable -Name 'Name' -Value $Name
    }

    $script:Store = Get-Content -Path $configFilePath | ConvertFrom-Json

}
