[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Test code only'
)]
[CmdletBinding()]
param()
Describe 'Context' {
    Context 'Function: Set-Context' {
        It 'Function is be available' {
            Get-Command -Name 'Set-Context' | Should -Not -BeNullOrEmpty
        }
        It 'Set-Context -Context $Context - Value is not empty' {
            $Context = @{
                Name = 'Test'
            }
            { Set-Context -Context $Context } | Should -Not -Throw

            $result = Get-Context -Name 'Test' -AsPlainText
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be 'Test'
        }
        It 'Set-Context -Context $Context - Context can hold a value as SecureString' {
            $Context = @{
                Name        = 'Test'
                AccessToken = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
                Expires     = '2022-01-01'
                Weird       = 'true'
            }
            { Set-Context -Context $Context } | Should -Not -Throw

            $result = @(Get-Context -Name 'Test' -AsPlainText)
            $result.Count | Should -Be 1
            $result | Should -Not -BeNullOrEmpty
            $result.AccessToken | Should -Be 'MySecret'
        }
        It 'Set-Context -Context $Context - Context can hold multiple values as SecureString' {
            $Context = @{
                Name         = 'Test2'
                AccessToken  = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
                RefreshToken = 'MyRefreshedSecret' | ConvertTo-SecureString -AsPlainText -Force
            }

            { Set-Context -Context $Context } | Should -Not -Throw
            { Set-Context -Context $Context } | Should -Not -Throw

            $result = Get-Context -Name 'Test2' -AsPlainText
            $result | Should -Not -BeNullOrEmpty
            $result.AccessToken | Should -Be 'MySecret'
            $result.RefreshToken | Should -Be 'MyRefreshedSecret'

            # { Remove-Context -Name 'Test2' } | Should -Not -Throw
        }
    }

    Context 'Function: Get-Context' {
        It 'Function is be available' {
            Get-Command -Name 'Get-Context' | Should -Not -BeNullOrEmpty
        }

        It 'Get-Context - Should return all contexts' {
            { Get-Context } | Should -Not -Throw
        }

        It "Get-Context -Name '*' - Should return all contexts" {
            (Get-Context -Name '*').Count | Should -Be 2
        }

        It "Get-Context -Name '' - Should return no contexts" {
            { Get-Context -Name '' } | Should -Not -Throw
            Get-Context -Name '' | Should -BeNullOrEmpty
        }
        It 'Get-Context -Name $null - Should return no contexts' {
            { Get-Context -Name $null } | Should -Not -Throw
            Get-Context -Name $null | Should -BeNullOrEmpty
        }
    }

    Context 'Function: Remove-Context' {
        It 'Function is be available' {
            Get-Command -Name 'Remove-Context' | Should -Not -BeNullOrEmpty
        }

        It 'Remove-Context -Name $Name - Should remove the context' {
            { 1..10 | ForEach-Object {
                    Set-Context -Context @{ Name = "Test$_" }
                }
            } | Should -Not -Throw

            $result = Get-Context -Name 'Test*'
            $result.Count | Should -Be 11 # Test + Test1-10

            { Remove-Context -Name 'Test*' } | Should -Not -Throw
            $result = Get-Context -Name 'Test*'
            $result.Count | Should -Be 0
        }
    }

    Context 'Other' {
        It 'Can list multiple contexts' {
            $Context = @{
                Name         = 'Test3'
                AccessToken  = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
                RefreshToken = 'MyRefreshedSecret' | ConvertTo-SecureString -AsPlainText -Force
            }

            { Set-Context -Context $Context } | Should -Not -Throw

            $Context = @{
                Name         = 'Test4'
                AccessToken  = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
                RefreshToken = 'MyRefreshedSecret' | ConvertTo-SecureString -AsPlainText -Force
            }

            { Set-Context -Context $Context } | Should -Not -Throw

            $Context = @{
                Name         = 'Test5'
                AccessToken  = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
                RefreshToken = 'MyRefreshedSecret' | ConvertTo-SecureString -AsPlainText -Force
            }

            { Set-Context -Context $Context } | Should -Not -Throw

            (Get-Context -Name 'Test*').Count | Should -Be 3
        }
        It 'Can delete using a wildcard' {
            { Remove-Context -Name 'Test*' } | Should -Not -Throw
        }
        It 'Can delete contexts using pipeline' {
            $Context = @{
                Name         = 'Test6'
                AccessToken  = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
                RefreshToken = 'MyRefreshedSecret' | ConvertTo-SecureString -AsPlainText -Force
            }

            { Set-Context -Context $Context } | Should -Not -Throw

            $Context = @{
                Name         = 'Test7'
                AccessToken  = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
                RefreshToken = 'MyRefreshedSecret' | ConvertTo-SecureString -AsPlainText -Force
            }

            { Set-Context -Context $Context } | Should -Not -Throw

            $Context = @{
                Name         = 'Test8'
                AccessToken  = 'MySecret' | ConvertTo-SecureString -AsPlainText -Force
                RefreshToken = 'MyRefreshedSecret' | ConvertTo-SecureString -AsPlainText -Force
            }

            { Set-Context -Context $Context } | Should -Not -Throw

            Get-Context -Name 'Test*' | Should -Not -BeNullOrEmpty
            { Get-Context -Name 'Test*' | Remove-Context } | Should -Not -Throw
        }
    }

    Context 'Set-ContextSetting' {
        It 'Should be available' {
            Get-Command -Name 'Set-ContextSetting' | Should -Not -BeNullOrEmpty
        }
        It "Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test'" {
            Write-Verbose 'Setup: Create a Context'
            Set-Context @{ Name = 'Test'; Secret = 'Test' }

            Write-Verbose 'Test: Set-ContextSetting'
            { Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test' } | Should -Not -Throw
            { Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test' } | Should -Not -Throw

            Write-Verbose 'Verify: The ContextSetting should exist'
            $result = Get-ContextSetting -Name 'Name' -Context 'Test' -AsPlainText
            Write-Verbose ($result | Out-String) -Verbose
            $result | Should -Be 'Test'

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test55'" {
            Write-Verbose 'Test: Set-ContextSetting'
            { Set-ContextSetting -Name 'Test' -Value 'Test' -Context 'Test55' } | Should -Throw
        }
        It "Set-ContextSetting -Name 'Name' -Value 'Cake' -Context 'Test'" {
            Write-Verbose 'Setup: Create a Context'
            Set-Context @{ Name = 'Test'; Secret = 'Test' }

            Write-Verbose 'Test: Set-ContextSetting'
            { Set-ContextSetting -Name 'Name' -Value 'Cake' -Context 'Test' } | Should -Not -Throw

            Write-Verbose 'Verify: The ContextSetting should exist'
            $result = Get-Context -Name 'Cake'
            $result | Should -Not -BeNullOrEmpty

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Cake'
        }
    }
    Context 'Get-ContextSetting' {
        It 'Should be available' {
            Get-Command -Name 'Get-ContextSetting' | Should -Not -BeNullOrEmpty
        }
        It "Get-ContextSetting -Name 'Test' -Context 'Test'" {
            Write-Verbose 'Setup: Create a Context'
            Set-Context @{ Name = 'Test'; Secret = 'Test' }
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
            Set-Context @{ Name = 'Test'; Secret = $secret }

            Write-Verbose 'Test: Get-ContextSetting'
            { Get-ContextSetting -Name 'Secret' -Context 'Test' -AsPlainText } | Should -Not -Throw

            Write-Verbose 'Verify: The ContextSetting should exist'
            $result = Get-ContextSetting -Name 'Secret' -Context 'Test' -AsPlainText
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be 'MySecret'

            Write-Verbose 'Cleanup: Remove the Context'
            Remove-Context -Name 'Test'
        }
        It "Get-ContextSetting -Name 'Test' -Context 'Test55'" {
            Write-Verbose 'Test: Get-ContextSetting'
            { Get-ContextSetting -Name 'Test' -Context 'Test55' } | Should -Throw -Because 'Context does not exist'
        }
    }
    Context 'Remove-ContextSetting' {
        It 'Should be available' {
            Get-Command -Name 'Remove-ContextSetting' | Should -Not -BeNullOrEmpty
        }
        It "Remove-ContextSetting -Name 'Test' -Context 'Test'" {
            Write-Verbose 'Setup: Create a Context'
            Set-Context @{ Name = 'Test'; Secret = 'Test' }
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
            { Remove-ContextSetting -Name 'Test' -Context 'Test55' } | Should -Throw -Because 'Context does not exist'
        }
    }
}
