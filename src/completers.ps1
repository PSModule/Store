$usingNameFunctions = @('Get-ContextSetting', 'Set-ContextSetting', 'Remove-ContextSetting')
$usingIDFunctions = @('Get-Context', 'Set-Context', 'Remove-Context', 'Rename-Context') + $usingNameFunctions

Register-ArgumentCompleter -CommandName $usingIDFunctions -ParameterName 'ID' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-ContextInfo | Where-Object { $_.Name -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
        }
}

Register-ArgumentCompleter -CommandName $usingNameFunctions -ParameterName 'Name' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-Context -ID $fakeBoundParameter.ID | ForEach-Object {
        $_.PSObject.Properties | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
        }
    }
}
