[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Test code only'
)]
[CmdletBinding()]
param()

Describe 'Store' {
    Context 'Set-Store' {
        It 'Should be available' {
            Get-Command -Name 'Set-Store' | Should -Not -BeNullOrEmpty
        }
        It "Set-Store -Name 'Test'" {
            { Set-Store -Name 'Test' } | Should -Not -Throw
        }
        It "Set-Store -Name 'Test' - a second time" {
            { Set-Store -Name 'Test' } | Should -Not -Throw
        }
        It "Set-Store -Name 'Test' -Variables @{ 'Test' = 'Test' }" {
            { Set-Store -Name 'Test' -Variables @{ 'Test' = 'Test' } } | Should -Not -Throw
        }
        # Write two tests setting a secret, one as a string, one as a SecureString
        It "Set-Store -Name 'Test' -Secret 'Test' - Secret as String" {
            { Set-Store -Name 'Test' -Secret 'Test' } | Should -Not -Throw
        }
        It "Set-Store -Name 'Test' -Secret 'Test' - Secret as SecureString" {
            $secret = 'Test' | ConvertTo-SecureString -AsPlainText -Force
            { Set-Store -Name 'Test' -Secret $secret } | Should -Not -Throw
        }
    }
    Context 'Get-Store' {
        It 'Should be available' {
            Get-Command -Name 'Get-Store' | Should -Not -BeNullOrEmpty
        }
        It "Get-Store -Name 'Test'" {
            { Get-Store -Name 'Test' } | Should -Not -Throw
        }
        It "Get-Store -Name 'Test' -AsPlainText" {
            { Get-Store -Name 'Test' -AsPlainText } | Should -Not -Throw
        }
    }
    Context 'Set-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Set-StoreConfig' | Should -Not -BeNullOrEmpty
        }
        It 'Should be able to run' {
            { Set-StoreConfig -Name 'Something' -Value 'Something' -Store 'Test' } | Should -Not -Throw
        }
        It 'Should be able to set a secret' {
            $secretValue = 'Something' | ConvertTo-SecureString -AsPlainText -Force
            Set-StoreConfig -Name 'Secret' -Value $secretValue -Store 'Test'
            $secret = Get-StoreConfig -Name 'Secret' -AsPlainText -Store 'Test'
            $secret | Should -Be 'Something'
        }
        It 'Should be able to remove a variable if set to $null' {
            Set-StoreConfig -Name 'Something' -Value $null -Store 'Test'
            $something = Get-StoreConfig -Name 'Something' -Store 'Test'
            $something | Should -BeNullOrEmpty
        }
    }
    Context 'Get-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Get-StoreConfig' | Should -Not -BeNullOrEmpty
        }
        It 'Should NOT be able to run without parameters' {
            { Get-StoreConfig } | Should -Throw
        }
        It 'Should be able to try to get a value that doesnt exists' {
            $value = Get-StoreConfig -Name 'Something' -Store 'Test'
            $value | Should -BeNullOrEmpty
        }
        It 'Should be able to run with parameters' {
            Set-StoreConfig -Name 'Something' -Value 'Something' -Store 'Test'
            { Get-StoreConfig -Name 'Something' -Store 'Test' } | Should -Not -Throw
        }
    }
    Context 'Remove-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Remove-StoreConfig' | Should -Not -BeNullOrEmpty
        }
        It 'Should be able to run' {
            Set-StoreConfig -Name 'Something' -Value 'Something' -Store 'Test'
            { Remove-StoreConfig -Name 'Something' -Store 'Test' } | Should -Not -Throw
        }
    }
    Context 'Remove-Store' {
        It 'Should be available' {
            Get-Command -Name 'Remove-Store' | Should -Not -BeNullOrEmpty
        }
        It 'Should be able to run' {
            { Remove-Store -Name 'Test' } | Should -Not -Throw
        }
    }
}
