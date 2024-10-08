﻿function Set-StoreVariable {
    <#
        .SYNOPSIS
        Set a variable in the store.

        .EXAMPLE
        Set-StoreVariable -Name 'Name' -Value 'MyName'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the variable to set.
        [Parameter(Mandatory)]
        [string] $Name,

        # The value to set.
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $Value
    )

    if ($PSCmdlet.ShouldProcess("Set variable '$Name' to '$Value'")) {
        if ($null -eq $Value) {
            $script:Store.PSObject.Properties.Remove($Name)
        } else {
            $script:Store | Add-Member -MemberType NoteProperty -Name $Name -Value $Value -Force
        }
        $script:Store | ConvertTo-Json -Depth 100 | Set-Content -Path $script:Store.ConfigFilePath -Force
    }
}
