$usingIDFunctions = @('Get-Context', 'Set-Context', 'Remove-Context', 'Rename-Context')

Register-ArgumentCompleter -CommandName $usingIDFunctions -ParameterName 'ID' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-ContextInfo | Where-Object { $_.ID -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.ID, $_.ID, 'ParameterValue', $_.ID)
        }
}
