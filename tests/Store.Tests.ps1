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
    Context 'Set-StoreConfig' {
        It 'The function should be available' {
            Get-Command -Name 'Set-StoreConfig' | Should -Not -BeNullOrEmpty
        }
    }
}
