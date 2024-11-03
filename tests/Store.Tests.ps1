[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Test code only'
)]
[CmdletBinding()]
param()

Describe 'Store' {
    Context 'Initialize-Store' {
        It 'Should be available' {
            Get-Command -Name 'Initialize-Store' | Should -Not -BeNullOrEmpty
        }
        It 'Should be able to run' {
            { Initialize-Store -Name 'GitHub' } | Should -Not -Throw
        }
        It 'Should be able to run multiple times without erroring out' {
            { Initialize-Store -Name 'GitHub' } | Should -Not -Throw
        }
    }
    Context 'Get-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Get-StoreConfig' | Should -Not -BeNullOrEmpty
        }
        It 'Should be able to run without parameters' {
            Write-Verbose (Get-StoreConfig | ConvertTo-Json) -Verbose
            { Get-StoreConfig } | Should -Not -Throw
        }
        It 'Should be able to run with parameters' {
            { Get-StoreConfig -Name 'Name' } | Should -Not -Throw
        }
        It 'Should be able to get its own name' {
            $name = Get-StoreConfig -Name 'Name'
            $name | Should -Be 'GitHub'
        }
        It 'Should be able to get its own path' {
            $configFilePath = Get-StoreConfig -Name 'ConfigFilePath'
            $configFilePath | Should -Be (Join-Path -Path $HOME -ChildPath '.github/config.json')
        }
        It 'Should be able to get the secret vault name' {
            $secretVaultName = Get-StoreConfig -Name 'SecretVaultName'
            $secretVaultName | Should -Be 'SecretStore'
        }
        It 'Should be able to get the secret vault type' {
            $secretVaultType = Get-StoreConfig -Name 'SecretVaultType'
            $secretVaultType | Should -Be 'Microsoft.PowerShell.SecretStore'
        }
    }
    Context 'Set-StoreConfig' {
        It 'Should be available' {
            Get-Command -Name 'Set-StoreConfig' | Should -Not -BeNullOrEmpty
        }
        It 'Should be able to run' {
            { Set-StoreConfig -Name 'Something' -Value 'Something' } | Should -Not -Throw
        }
        It 'Should be able to set a variable' {
            Set-StoreConfig -Name 'Something' -Value 'Something'
            $something = Get-StoreConfig -Name 'Something'
            $something | Should -Be 'Something'
        }
        It 'Should be able to set a secret' {
            Set-StoreConfig -Name 'Secret' -Value ('Something' | ConvertTo-SecureString -AsPlainText -Force)
            $secret = Get-StoreConfig -Name 'Secret' -AsPlainText
            $secret | Should -Be 'Something'
        }
        It 'Should be able to remove a variable if set to $null' {
            Set-StoreConfig -Name 'Something' -Value $null
            $something = Get-StoreConfig -Name 'Something'
            $something | Should -BeNullOrEmpty
        }
    }
}
