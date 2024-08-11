function Get-StoreVariable {
    <#
        .SYNOPSIS
        Get a variable from the store.

        .EXAMPLE
        Get-StoreVariable

        Gets all the variables in the store.

        .EXAMPLE
        Get-StoreVariable -Name 'Name'

        Gets the value of the variable with the name 'Name'.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter()]
        [string] $Name
    )

    if (-not $Name) {
        $script:Store
    } else {
        $script:Store[$Name]
    }
}
