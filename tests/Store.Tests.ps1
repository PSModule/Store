Describe 'Store' {
    Context 'Module' {
        It 'The module should be available' {
            Get-Module -Name 'Store' -ListAvailable | Should -Not -BeNullOrEmpty
            Write-Verbose (Get-Module -Name 'Store' -ListAvailable | Out-String) -Verbose
        }
        It 'The module should be importable' {
            { Import-Module -Name 'Store' } | Should -Not -Throw
        }
    }
}
