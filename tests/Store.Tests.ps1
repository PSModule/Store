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
            # $Secure = Read-Host -AsSecureString # Enter 'Something'
            # $secret = ConvertFrom-SecureString -SecureString $Secure
            $secret = '01000000d08c9ddf0115d1118c7a00c04fc297eb01000000d8f5081752e7fe41b9e40cd0f11a075a0000000002000000000010660000000100002' +
            '000000094fc82d29efd361cc32d19a3dd4437de50b24014e30e9b82a64e4762931a5234000000000e8000000002000020000000404d00ec9f75e052ffc627e4' +
            '4a3369b4d1569de20a63ce74e65cac9d3e19514c20000000faca3a33c92d77eb6d8abd923b9079baf840bbb89df48928ab61a3cfbe43574d40000000d78b0ee' +
            '4f30363bbce8c2bede340e53e909226df35da40cec6e50a29f063eb18e349db1c7e7cac8561ae4bec87d7c8ce9a8c60b2e5be9bbf83c67551a9587bed'
            Set-StoreConfig -Name 'Secret' -Value ($secret | ConvertTo-SecureString -Force)
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
