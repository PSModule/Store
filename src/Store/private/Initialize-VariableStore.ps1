function Initialize-VariableStore {
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
    $configFilePath = Join-Path -Path $HOME -ChildPath $folderName 'config.json'
    
    if (-not (Test-Path -Path $configFilePath)) {
        New-Item -Path $configFilePath -ItemType File -Force | Out-Null
        Set-StoreVariable -Name 'Name' -Value $Name
        Set-StoreVariable -Name 'ConfigFileName' -Value $configFilePath
    }

    $script:Store = Get-Content -Path $configFilePath | ConvertFrom-Json

}
