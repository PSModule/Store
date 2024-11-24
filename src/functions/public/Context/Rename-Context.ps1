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
        [string] $NewID,

        # Force the rename even if the new ID already exists.
        [Parameter()]
        [switch] $Force
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $context = Get-Context -ID $ID
        if (-not $context) {
            throw "Context with ID '$ID' not found."
        }

        $existingContext = Get-Context -ID $NewID
        if ($existingContext -and -not $Force) {
            throw "Context with ID '$NewID' already exists."
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

Register-ArgumentCompleter -CommandName Rename-Context -ParameterName ID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-ContextInfo | Where-Object { $_.Name -like "$($script:Config.SecretPrefix)$wordToComplete*" } |
        ForEach-Object {
            $Name = $_.Name -replace "^$($script:Config.SecretPrefix)"
            [System.Management.Automation.CompletionResult]::new($Name, $Name, 'ParameterValue', $Name)
        }
}
