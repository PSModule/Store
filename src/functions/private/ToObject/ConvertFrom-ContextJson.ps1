function ConvertFrom-ContextJson {
    param (
        [Parameter(Mandatory)]
        [string] $JsonString
    )

    $hashtableObject = $JsonString | ConvertFrom-Json -Depth 100 -AsHashtable
    return Convert-ContextHashtableToObjectRecursive $hashtableObject
}
