function Get-ConfigFilePath {
    <#
        .SYNOPSIS
        Get the path to the configuration file.

        .DESCRIPTION
        Get the path to the configuration file. The path is determined based on the operating system.

        .EXAMPLE
        Get-ConfigFilePath -Name 'MyApp'

        Returns the path to the configuration file for 'MyApp'.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The name of the configuration file.
        [Parameter(Mandatory)]
        [string] $Name
    )

    $folderName = ".$($Name -replace '^\.')".ToLower()

    Join-Path -Path $HOME -ChildPath $folderName 'config.json'
}
