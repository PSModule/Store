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

    $configFilePath = Get-ConfigFilePath -Name $Name
    if (-not (Test-Path -Path $configFilePath)) {
        New-Item -Path $configFilePath -ItemType File -Force | Out-Null
        Set-StoreVariable -Name 'Name' -Value $Name
        Set-StoreVariable -Name 'ConfigFileName' -Value $configFilePath
    }

    Restore-VariableStore -Name $Name
}
