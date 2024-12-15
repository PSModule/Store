function ConvertTo-ContextJson {
    <#
        .SYNOPSIS
        Takes an object and converts it to a JSON string.

        .DESCRIPTION
        Takes objects or hashtables and converts them to a JSON string.
        SecureStrings are converted to plain text strings and prefixed with [SECURESTRING]. The conversion is recursive for any nested objects.
        Use ConvertFrom-ContextJson to convert back to an object.

        .EXAMPLE
        ConvertTo-ContextJson -Context ([pscustomobject]@{
            Name = 'MySecret'
            AccessToken = '123123123' | ConvertTo-SecureString -AsPlainText -Force
        })

        Returns a JSON string representation of the object.

        ```json
        {
            "Name": "MySecret",
            "AccessToken ": "[SECURESTRING]123123123"
        }
        ```
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The object to convert to a Context JSON string.
        [Parameter()]
        [object] $Context = @{},

        # The ID of the context.
        [Parameter(Mandatory)]
        [string] $ID
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            $processedObject = Convert-ContextObjectToHashtableRecursive $Context
            $processedObject['ID'] = $ID
            return ($processedObject | ConvertTo-Json -Depth 100 -Compress)
        } catch {
            Write-Error $_
            throw 'Failed to convert object to JSON'
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
