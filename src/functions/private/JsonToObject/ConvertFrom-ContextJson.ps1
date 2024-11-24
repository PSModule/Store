function ConvertFrom-ContextJson {
    <#
        .SYNOPSIS
        Converts a JSON string to a context object.

        .DESCRIPTION
        Converts a JSON string to a context object.
        [SECURESTRING] prefixed text is converted to SecureString objects.
        Other values are converted to their original types, like ints, booleans, string, arrays, and nested objects.

        .EXAMPLE
        ConvertFrom-ContextJson -JsonString '{
            "Name": "Test",
            "Token": "[SECURESTRING]TestToken",
            "Nested": {
                "Name": "Nested",
                "Token": "[SECURESTRING]NestedToken"
            }
        }'

        This example converts a JSON string to a context object, where the 'Token' and 'Nested.Token' values are SecureString objects.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # JSON string to convert to context object
        [Parameter(Mandatory)]
        [string] $JsonString
    )
    try {
        $hashtableObject = $JsonString | ConvertFrom-Json -Depth 100 -AsHashtable
        return Convert-ContextHashtableToObjectRecursive $hashtableObject
    } catch {
        Write-Error $_
        throw 'Failed to convert JSON to object'
    }
}
