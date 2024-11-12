[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Test code only'
)]
[CmdletBinding()]
param()
Describe 'Context' {
    Context 'Set-Context' {
        It 'Should be available' {
            Get-Command -Name 'Set-Context' | Should -Not -BeNullOrEmpty
        }
        It "Set-Context -Name 'Test'" {
            Write-Verbose 'Test: Set-Context'
            { Set-Context -Name 'Test' } | Should -Not -Throw
            { Set-Context -Name 'Test' } | Should -Not -Throw

            Write-Verbose 'Verify: The Context should exist'
            $result = Get-Context -Name 'Test'
            $result | Should -Not -BeNullOrEmpty

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Set-Context -Name 'Test' -Variables @{ 'Test' = 'Test' }" {
            Write-Verbose 'Setup: Create a Context with Variables'
            { Set-Context -Name 'Test' -Variables @{ 'Test' = 'Test' } } | Should -Not -Throw

            Write-Verbose 'Verify: The Context should exist'
            {
                $result = Get-Context -Name 'Test'
                $result | Should -Not -BeNullOrEmpty
                $result.Test | Should -Be 'Test'
            } | Should -Not -Throw

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Set-Context -Name 'Test' -Secret 'Test' - Secret as String" {
            Write-Verbose 'Setup: Create a Context with a Secret'
            { Set-Context -Name 'Test' -Secret 'Test' } | Should -Not -Throw

            Write-Verbose 'Verify: The Context should exist'
            {
                $result = Get-Context -Name 'Test'
                $result | Should -Not -BeNullOrEmpty
                $result.Secret | Should -Be 'Test'
            } | Should -Not -Throw

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Set-Context -Name 'Test' -Secret 'Test' - Secret as SecureString" {
            Write-Verbose 'Setup: Create a Context with a SecureString Secret'
            $secret = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force

            Write-Verbose 'Test: Set-Context'
            { Set-Context -Name 'Test' -Secret $secret } | Should -Not -Throw

            Write-Verbose 'Verify: The Context should exist'
            $result = Get-Context -Name 'Test' -AsPlainText
            $result | Should -Not -BeNullOrEmpty
            $result.Secret | Should -Be 'MySecret'
        }
    }
    Context 'Get-Context' {
        It 'Should be available' {
            Get-Command -Name 'Get-Context' | Should -Not -BeNullOrEmpty
        }
        It "Get-Context -Name 'Test'" {
            Write-Verbose 'Setup: Create a Context'
            Set-Context -Name 'Test' -Secret 'Test'

            Write-Verbose 'Test: Get-Context'
            {
                $result = Get-Context -Name 'Test'
                $result | Should -HaveCount 1
                $result[0].Name | Should -Be 'Test'
            } | Should -Not -Throw

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Get-Context -Name 'Test' -AsPlainText" {
            Write-Verbose 'Setup: Create a Context with a SecureString Secret'
            $secret = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
            Set-Context -Name 'Test' -Secret $secret

            Write-Verbose 'Test: Get-Context'
            {
                $result = Get-Context -Name 'Test' -AsPlainText
                $result | Should -HaveCount 1
                $result[0].Name | Should -Be 'Test'
            } | Should -Not -Throw

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Get-Context -Name 'Te*'" {
            Write-Verbose 'Setup: Create multiple Contexts'
            Set-Context -Name 'Test' -Secret 'Test'
            Set-Context -Name 'Test1' -Secret 'Test1'
            Set-Context -Name 'Test2' -Secret 'Test2'

            Write-Verbose 'Test: Get-Context'
            {
                $result = Get-Context -Name 'Te*'
                $result | Should -HaveCount 3
                $result.Name | Should -Contain 'Test'
                $result.Name | Should -Contain 'Test1'
                $result.Name | Should -Contain 'Test2'
            } | Should -Not -Throw

            Write-Verbose 'Cleanup: Remove the Contexts'
            Remove-Context -Name 'Test*'
        }
        It 'Get-Context (return all)' {
            Write-Verbose 'Setup: Create multiple Contexts'
            Set-Context -Name 'Test' -Secret 'Test'
            Set-Context -Name 'Test1' -Secret 'Test1'
            Set-Context -Name 'Test2' -Secret 'Test2'

            Write-Verbose 'Test: Get-Context'
            {
                $result = Get-Context
                $result.Name | Should -Contain 'Test'
                $result.Name | Should -Contain 'Test1'
                $result.Name | Should -Contain 'Test2'
            } | Should -Not -Throw

            Write-Verbose "Cleanup: Remove the Contexts'
            Remove-Context -Name 'Test*'
        }
    }
    Context 'Set-ContextSetting' {
        It 'Should be available' {
            Get-Command -Name 'Set-ContextSetting' | Should -Not -BeNullOrEmpty
        }
        It "Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test'" {
            Write-Verbose 'Setup: Create a Context'
            Set-Context -Name 'Test' -Secret 'Test'

            Write-Verbose 'Test: Set-ContextSetting'
            { Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test' } | Should -Not -Throw
            { Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test' } | Should -Not -Throw

            Write-Verbose 'Verify: The ContextSetting should exist'
            $result = Get-ContextSetting -Name 'Test' -Context 'Test'
            $result | Should -Not -BeNullOrEmpty

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test55'" {
            Write-Verbose 'Test: Set-ContextSetting'
            { Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test55' } | Should -Throw

            Write-Verbose 'Verify: The ContextSetting should not exist'
            $result = Get-ContextSetting -Name 'Test' -Context 'Test55'
            $result | Should -BeNullOrEmpty
        }
    }
    Context 'Get-ContextSetting' {
        It 'Should be available' {
            Get-Command -Name 'Get-ContextSetting' | Should -Not -BeNullOrEmpty
        }
        It "Get-ContextSetting -Name 'Test' -Context 'Test'" {
            Write-Verbose 'Setup: Create a Context'
            Set-Context -Name 'Test' -Secret 'Test'
            Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test'

            Write-Verbose 'Test: Get-ContextSetting'
            { Get-ContextSetting -Name 'Test' -Context 'Test' } | Should -Not -Throw

            Write-Verbose 'Verify: The ContextSetting should exist'
            $result = Get-ContextSetting -Name 'Test' -Context 'Test'
            $result | Should -Not -BeNullOrEmpty

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Get-ContextSetting -Name 'Test' -Context 'Test' -AsPlainText" {
            Write-Verbose 'Setup: Create a Context with a SecureString Secret'
            $secret = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
            Set-Context -Name 'Test' -Secret $secret

            Write-Verbose 'Test: Get-ContextSetting'
            { Get-ContextSetting -Name 'Secret' -Context 'Test' -AsPlainText } | Should -Not -Throw

            Write-Verbose 'Verify: The ContextSetting should exist'
            $result = Get-ContextSetting -Name 'Secret' -Context 'Test' -AsPlainText
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be 'null'

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Get-ContextSetting -Name 'Test' -Context 'Test55'" {
            Write-Verbose 'Test: Get-ContextSetting'
            { Get-ContextSetting -Name 'Test' -Context 'Test55' } | Should -Throw

            Write-Verbose 'Verify: The ContextSetting should not exist'
            $result = Get-ContextSetting -Name 'Test' -Context 'Test55'
            $result | Should -BeNullOrEmpty
        }
    }
    Context 'Remove-ContextSetting' {
        It 'Should be available' {
            Get-Command -Name 'Remove-ContextSetting' | Should -Not -BeNullOrEmpty
        }
        It "Remove-ContextSetting -Name 'Test' -Context 'Test'" {
            Write-Verbose 'Setup: Create a Context'
            Set-Context -Name 'Test' -Secret 'Test'
            Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test'

            Write-Verbose 'Test: Remove-ContextSetting'
            { Get-ContextSetting -Name 'Test' -Context 'Test' } | Should -Not -BeNullOrEmpty
            { Remove-ContextSetting -Name 'Test' -Context 'Test' } | Should -Not -Throw
            { Remove-ContextSetting -Name 'Test' -Context 'Test' } | Should -Not -Throw

            Write-Verbose 'Verify: The ContextSetting should no longer exist'
            $result = Get-ContextSetting -Name 'Test' -Context 'Test'
            $result | Should -BeNullOrEmpty

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Remove-ContextSetting -Name 'Test' -Context 'Test55'" {
            Write-Verbose 'Test: Remove-ContextSetting'
            { Remove-ContextSetting -Name 'Test' -Context 'Test55' } | Should -Throw

            Write-Verbose 'Verify: The ContextSetting should not exist'
            $result = Get-ContextSetting -Name 'Test' -Context 'Test55'
            $result | Should -BeNullOrEmpty
        }
    }
    Context 'Remove-Context' {
        It 'Should remove a Context by exact name' {
            Write-Verbose 'Setup: Create a Context'
            Set-Context -Name 'TestContext' -Secret 'TestSecret'

            Write-Verbose 'Test: Remove the Context'
            { Remove-Context -Name 'TestContext' } | Should -Not -Throw

            Write-Verbose 'Verify: The Context should no longer exist'
            $result = Get-Context -Name 'TestContext'
            $result | Should -BeNullOrEmpty

            Write-Verbose 'Cleanup: Remove any remaining Contexts'
            Remove-Context -Name 'TestContext'
        }
        It 'Should remove Contexts matching a wildcard pattern' {
            Write-Verbose 'Setup: Create multiple Contexts'
            Set-Context -Name 'TestContext1' -Secret 'TestSecret1'
            Set-Context -Name 'TestContext2' -Secret 'TestSecret2'
            Set-Context -Name 'TestContext3' -Secret 'TestSecret3'

            Write-Verbose 'Test: Remove Contexts matching the pattern'
            { Remove-Context -Name 'TestContext*' } | Should -Not -Throw

            Write-Verbose 'Verify: The Contexts should no longer exist'
            $result = Get-Context -Name 'TestContext*'
            $result | Should -BeNullOrEmpty

            Write-Verbose 'Cleanup: Remove any remaining Contexts'
            Remove-Context -Name 'TestContext*'
        }

        It 'Should remove Contexts using pipeline input' {
            Write-Verbose 'Setup: Create multiple Contexts'
            Set-Context -Name 'PipelineContext1' -Secret 'PipelineSecret1'
            Set-Context -Name 'PipelineContext2' -Secret 'PipelineSecret2'

            Write-Verbose 'Test: Remove Contexts using pipeline input'
            Get-Context -Name 'PipelineContext*' | Remove-Context

            Write-Verbose 'Verify: The Contexts should no longer exist'
            $result = Get-Context -Name 'PipelineContext*'
            $result | Should -BeNullOrEmpty

            Write-Verbose 'Cleanup: Remove any remaining Contexts'
            Remove-Context -Name 'PipelineContext*'
        }
    }
}
