function Save-VariableStore {
    <#
        .SYNOPSIS
        Save the variable store from the memory to file system.
    #>
    [CmdletBinding()]
    param ()
    $script:Store | ConvertTo-Json | Set-Content -Path $script:Store.ConfigFileName -Force
}
