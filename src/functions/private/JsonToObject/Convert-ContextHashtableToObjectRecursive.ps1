function Convert-ContextHashtableToObjectRecursive {
    <#
        .SYNOPSIS
        Converts a hashtable to a context object.

        .DESCRIPTION
        This function is used to convert a hashtable to a context object.
        String values that are prefixed with '[SECURESTRING]', are converted back to SecureString objects.
        Other values are converted to their original types, like ints, booleans, string, arrays, and nested objects.

        .EXAMPLE
        Convert-ContextHashtableToObjectRecursive -Hashtable @{
            Name   = 'Test'
            Token  = '[SECURESTRING]TestToken'
            Nested = @{
                Name  = 'Nested'
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
        [object] $Hashtable
    )
    $result = [pscustomobject]@{}

    foreach ($key in $Hashtable.Keys) {
        $value = $Hashtable[$key]
        Write-Debug "Processing [$key]"
        Write-Debug "Value type: $($value.GetType().FullName)"
        Write-Debug "Value: $value"
        if ($value -is [string] -and $value -like '`[SECURESTRING`]*') {
            Write-Debug "Converting [$key] as [SecureString]"
            $secureValue = $value -replace '^\[SECURESTRING\]', ''
            $result | Add-Member -NotePropertyName $key -NotePropertyValue ($secureValue | ConvertTo-SecureString -AsPlainText -Force)
        } elseif ($value -is [hashtable]) {
            Write-Debug "Converting [$key] as [hashtable]"
            $result | Add-Member -NotePropertyName $key -NotePropertyValue (Convert-ContextHashtableToObjectRecursive $value)
        } elseif ($value -is [array]) {
            Write-Debug "Converting [$key] as [IEnumerable], including arrays and hashtables"
            $result | Add-Member -NotePropertyName $key -NotePropertyValue @(
                $value | ForEach-Object {
                    if ($_ -is [hashtable]) {
                        Convert-ContextHashtableToObjectRecursive $_
                    } else {
                        $_
                    }
                }
            )
        } else {
            Write-Debug "Converting [$key] as regular value"
            $result | Add-Member -NotePropertyName $key -NotePropertyValue $value
        }
    }
    return $result
}
