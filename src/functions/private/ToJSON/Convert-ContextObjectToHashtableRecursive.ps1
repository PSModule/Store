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
        Convert-ContextObjectToHashtableRecursive -Object @{
            Name = 'MySecret'
            AccessToken = '123123123' | ConvertTo-SecureString -AsPlainText -Force
            Nested = @{
                Name = 'MyNestedSecret'
                NestedAccessToken = '123123123' | ConvertTo-SecureString -AsPlainText -Force
            }
        }

        Converts the context object to a hashtable. Converts the AccessToken and NestedAccessToken secure strings to a string representation.
    #>
    [OutputType([hashtable])]
    [CmdletBinding()]
    param (
        # The object to convert.
        [object] $Object
    )
    $result = @{}

    foreach ($property in $Object.PSObject.Properties) {
        $value = $property.Value
        if ($value -is [datetime]) {
            $result[$property.Name] = $value.ToString('o')
        } elseif ($value -is [System.Security.SecureString]) {
            $plaintext = [Runtime.InteropServices.Marshal]::PtrToStringUni([Runtime.InteropServices.Marshal]::SecureStringToBSTR($value))
            $result[$property.Name] = "[SECURESTRING]$plaintext"
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($value))
        } elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            $result[$property.Name] = @(
                $value | ForEach-Object { Convert-ContextObjectToHashtableRecursive $_ }
            )
        } elseif ($value -is [psobject]) {
            $result[$property.Name] = Convert-ContextObjectToHashtableRecursive $value
        } else {
            $result[$property.Name] = $value
        }
    }
    return $result
}
