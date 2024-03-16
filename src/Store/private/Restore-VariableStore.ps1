function Restore-VariableStore {
    <#
        .SYNOPSIS
        Restores the variable store from the file system to memory.
    #>
    [CmdletBinding()]
    param()
    $configFilePath = Get-ConfigFilePath
    $script:Store = Get-Content -Path $configFilePath | ConvertFrom-Json
}
