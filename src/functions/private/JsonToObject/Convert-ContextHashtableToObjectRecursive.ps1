function Convert-ContextHashtableToObjectRecursive {
    <#
        .SYNOPSIS
        Converts a hashtable to a context object.

        .DESCRIPTION
        This function is used to convert a hashtable to a context object.
        String values that are prefixed with '[SECURESTRING]', are converted back to SecureString objects.
        Other values are converted to their original types, like ints, booleans, string, arrays, and nested objects.

        .EXAMPLE
        Convert-ContextHashtableToObjectRecursive -Object @{
            Name = 'Test'
            Token = '[SECURESTRING]TestToken'
            Nested = @{
                Name = 'Nested'
                Token = '[SECURESTRING]NestedToken'
            }
        }

        This example converts a hashtable to a context object, where the 'Token' and 'Nested.Token' values are SecureString objects.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'The securestring is read from the object this function reads.'
    )]
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # Hashtable to convert to context object
        [hashtable] $Hashtable
    )
    $result = [pscustomobject]@{}

    foreach ($key in $Hashtable.Keys) {
        $value = $Hashtable[$key]
        if ($value -is [string] -and $value -like '`[SECURESTRING`]*') {
            # Convert [SECURESTRING] prefixed text back to SecureString
            $secureValue = $value -replace '^\[SECURESTRING\]', ''
            $result | Add-Member -NotePropertyName $key -NotePropertyValue ($secureValue | ConvertTo-SecureString -AsPlainText -Force)
        } elseif ($value -is [System.Collections.IEnumerable] -and ($value -isnot [string])) {
            # Handle collections
            $result | Add-Member -NotePropertyName $key -NotePropertyValue @(
                $value | ForEach-Object { Convert-ContextHashtableToObjectRecursive $_ }
            )
        } elseif ($value -is [hashtable]) {
            # Handle nested objects
            $result | Add-Member -NotePropertyName $key -NotePropertyValue (Convert-ContextHashtableToObjectRecursive $value)
        } else {
            # Regular value
            $result | Add-Member -NotePropertyName $key -NotePropertyValue $value
        }
    }
    return $result
}
