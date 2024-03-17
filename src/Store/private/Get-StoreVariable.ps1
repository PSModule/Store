function Get-StoreVariable {
    <#
        .SYNOPSIS
        Get a variable from the store.

        .EXAMPLE
        Get-StoreVariable -Name 'Name'

        Gets the value of the variable with the name 'Name'.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [string] $Name
    )

    $script:Store[$Name]
}
