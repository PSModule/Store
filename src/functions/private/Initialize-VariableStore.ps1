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
    Write-Verbose "Variable store folder:      [$folderName]"
    $configFilePath = Join-Path -Path $HOME -ChildPath "$folderName/config.json"
    Write-Verbose "Variable store file:        [$configFilePath]"
    $configFileExists = Test-Path -Path $configFilePath
    Write-Verbose "Variable store file exists: [$configFileExists]"
    if (-not $configFileExists) {
        $null = New-Item -Path $configFilePath -ItemType File -Force
        Set-StoreVariable -Name 'ConfigFilePath' -Value $configFilePath
        Set-StoreVariable -Name 'Name' -Value $Name
    }

    $script:Store = Get-Content -Path $configFilePath | ConvertFrom-Json

}
