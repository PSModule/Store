function Test-Base64 {
    <#
        .SYNOPSIS
        Test if a string is a valid Base64 string.

        .DESCRIPTION
        Test if a string is a valid Base64 string.

        .EXAMPLE
        Test-Base64 -Base64String 'U29tZSBkYXRh'
        True

        Returns $true as the string is a valid Base64 string.
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [string] $Base64String
    )
    try {
        [Convert]::FromBase64String($Base64String) | Out-Null
        return $true
    } catch {
        return $false
    }
}
