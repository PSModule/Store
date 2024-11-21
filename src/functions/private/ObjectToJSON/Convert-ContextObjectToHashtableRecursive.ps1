function Convert-ContextObjectToHashtableRecursive {
    <#
        .SYNOPSIS
        Converts a context object to a hashtable.

        .DESCRIPTION
        This function converts a context object to a hashtable.
        Secure strings are converted to a string representation, prefixed with '[SECURESTRING]'.
        Datetime objects are converted to a string representation using the 'o' format specifier.
        Nested context objects are recursively converted to hashtables.

        .EXAMPLE
        Convert-ContextObjectToHashtableRecursive -Object ([PSCustomObject]@{
            Name = 'MySecret'
            AccessToken = '123123123' | ConvertTo-SecureString -AsPlainText -Force
            Nested = @{
                Name = 'MyNestedSecret'
                NestedAccessToken = '123123123' | ConvertTo-SecureString -AsPlainText -Force
            }
        })

        Converts the context object to a hashtable. Converts the AccessToken and NestedAccessToken secure strings to a string representation.
    #>
    [OutputType([hashtable])]
    [CmdletBinding()]
    param (
        # The object to convert.
        [object] $Object
    )
    $result = @{}

    if ($Object -is [hashtable]) {
        Write-Debug 'Converting [hashtable] to [PSCustomObject]'
        $Object = [PSCustomObject]$Object
    } elseif ($Object -is [string] -or $Object -is [int] -or $Object -is [bool]) {
        Write-Debug 'returning as string'
        return $Object
    }

    foreach ($property in $Object.PSObject.Properties) {
        $value = $property.Value
        Write-Debug "Processing [$($property.Name)]"
        Write-Debug "Value type: $($value.GetType().FullName)"
        if ($value -is [datetime]) {
            Write-Debug '- as DateTime'
            $result[$property.Name] = $value.ToString('o')
        } elseif ($value -is [string] -or $Object -is [int] -or $Object -is [bool]) {
            Write-Debug '- as string, int, bool'
            $result[$property.Name] = $value
        } elseif ($value -is [System.Security.SecureString]) {
            Write-Debug '- as SecureString'
            $value = $value | ConvertFrom-SecureString -AsPlainText
            $result[$property.Name] = "[SECURESTRING]$value"
        } elseif ($value -is [System.Collections.IEnumerable]) {
            Write-Debug '- as IEnumerable, including arrays and hashtables'
            $result[$property.Name] = @(
                $value | ForEach-Object {
                    Convert-ContextObjectToHashtableRecursive $_
                }
            )
        } elseif ($value -is [psobject] -or $value -is [PSCustomObject]) {
            Write-Debug '- as PSObject, PSCustomObject'
            $result[$property.Name] = Convert-ContextObjectToHashtableRecursive $value
        } else {
            Write-Debug '- as regular value'
            $result[$property.Name] = $value
        }
    }
    return $result
}
