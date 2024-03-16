function Restore-VariableStore {
    <#
        .SYNOPSIS
        Restores the variable store from the file system to memory.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        # The name of the store to restore.
        [Parameter(Mandatory)]
        [string] $Name
    )
    $configFilePath = Get-ConfigFilePath -Name $Name
    if (Test-Path -Path $configFilePath) {
        $script:Store = Get-Content -Path $configFilePath | ConvertFrom-Json
    } else {
        throw "The configuration file '$configFilePath' does not exist."
    }
}

