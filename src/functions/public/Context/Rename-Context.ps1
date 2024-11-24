function Rename-Context {
    <#
        .SYNOPSIS
        Renames a context.

        .DESCRIPTION
        This function renames a context.
        It retrieves the context with the old ID, sets the context with the new ID, and removes the context with the old ID.

        .EXAMPLE
        Example of how to use the function or script.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The ID of the context to rename.
        [Parameter(Mandatory)]
        [string] $ID,

        # The new ID of the context.
        [Parameter(Mandatory)]
        [string] $NewID
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $context = Get-Context -ID $ID
        if (-not $context) {
            throw "Context with ID '$ID' not found."
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Renaming context '$ID' to '$NewID'")) {
            try {
                Set-Context -ID $NewID -Context $context
            } catch {
                Write-Error $_
                throw 'Failed to set new context'
            }

            try {
                Remove-Context -ID $ID
            } catch {
                Write-Error $_
                throw 'Failed to remove old context'
            }
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
