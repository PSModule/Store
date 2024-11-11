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
        It "Get-Store -Name 'Te*'" {
            $result = Get-Store -Name 'Te*'
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
    Context 'Remove-Store' {
        It 'Should remove a store by exact name' {
            # Setup: Create a store
            Set-Store -Name 'TestStore' -Secret 'TestSecret'

            # Test: Remove the store
            { Remove-Store -Name 'TestStore' } | Should -Not -Throw

            # Verify: The store should no longer exist
            $result = Get-Store -Name 'TestStore'
            $result | Should -BeNullOrEmpty
        }
        It 'Should remove stores matching a wildcard pattern' {
            # Setup: Create multiple stores
            Set-Store -Name 'TestStore1' -Secret 'TestSecret1'
            Set-Store -Name 'TestStore2' -Secret 'TestSecret2'
            Set-Store -Name 'TestStore3' -Secret 'TestSecret3'

            # Test: Remove stores matching the pattern
            { Remove-Store -Name 'TestStore*' } | Should -Not -Throw

            # Verify: The stores should no longer exist
            $result = Get-Store -Name 'TestStore*'
            $result | Should -BeNullOrEmpty
        }

        It 'Should remove stores using pipeline input' {
            # Setup: Create multiple stores
            Set-Store -Name 'PipelineStore1' -Secret 'PipelineSecret1'
            Set-Store -Name 'PipelineStore2' -Secret 'PipelineSecret2'

            # Test: Remove stores using pipeline input
            Get-Store -Name 'PipelineStore*' | Remove-Store

            # Verify: The stores should no longer exist
            $result = Get-Store -Name 'PipelineStore*'
            $result | Should -BeNullOrEmpty

        }
    }
}
<#
Describe 'StoreConfig' {
    Context 'Set-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Set-StoreConfig' | Should -Not -BeNullOrEmpty
        }
        It "Set-StoreConfig -Name 'Test' -Value 'Test' -Store 'Test'" {
            { Set-StoreConfig -Name 'Test' -Value 'Test' -Store 'Test' } | Should -Not -Throw
        }
        It "Set-StoreConfig -Name 'Test' -Value 'Test' -Store 'Test' - a second time" {
            { Set-StoreConfig -Name 'Test' -Value 'Test' -Store 'Test' } | Should -Not -Throw
        }
    }
    Context 'Get-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Get-StoreConfig' | Should -Not -BeNullOrEmpty
        }
        It "Get-StoreConfig -Name 'Test' -Store 'Test'" {
            $result = Get-StoreConfig -Name 'Test' -Store 'Test'
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be 'Test'
        }
        It "Get-StoreConfig -Name 'Test' -Store 'Test' -AsPlainText" {
            $result = Get-StoreConfig -Name 'Test' -Store 'Test' -AsPlainText
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be 'Test'
        }
    }
    Context 'Remove-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Remove-StoreConfig' | Should -Not -BeNullOrEmpty
        }
        It "Remove-StoreConfig -Name 'Test' -Store 'Test'" {
            { Remove-StoreConfig -Name 'Test' -Store 'Test' } | Should -Not -Throw
        }
        It "Remove-StoreConfig -Name 'Test' -Store 'Test' - a second time" {
            { Remove-StoreConfig -Name 'Test' -Store 'Test' } | Should -Not -Throw
        }
    }
}
#>
