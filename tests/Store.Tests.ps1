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
        It "Set-Store -Name 'Test1'" {
            { Set-Store -Name 'Test1' } | Should -Not -Throw
        }
        It "Set-Store -Name 'Test2'" {
            { Set-Store -Name 'Test2' } | Should -Not -Throw
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
            $result = Get-Store -Name 'Test'
            $result | Should -HaveCount 1
            $result[0].Name | Should -Be 'Test'
        }
        It "Get-Store -Name 'Test' -AsPlainText" {
            $result = Get-Store -Name 'Test' -AsPlainText
            $result | Should -HaveCount 1
            $result[0].Name | Should -Be 'Test'
        }
        It "Get-Store -Name 'Test*'" {
            $result = Get-Store -Name 'Test*'
            $result | Should -HaveCount 3
            $result.Name | Should -Contain 'Test'
            $result.Name | Should -Contain 'Test1'
            $result.Name | Should -Contain 'Test2'
        }
        It 'Get-Store' {
            $result = Get-Store
            $result | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Set-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Set-StoreConfig' | Should -Not -BeNullOrEmpty
        }
    }
}
