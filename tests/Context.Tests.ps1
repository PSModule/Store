[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Test code only'
)]
[CmdletBinding()]
param()
<#
Describe 'Private functions' {
    Context 'Function: ConvertTo-ContextJson' {
        It 'Function is be available' {
            Get-Command -Name 'ConvertTo-ContextJson' | Should -Not -BeNullOrEmpty
        }
        It 'ConvertTo-ContextJson -Context $Context - Should return a JSON string' {
            $githubLoginContext = [PSCustomObject]@{
                Username          = 'john_doe'
                AuthToken         = 'ghp_12345ABCDE67890FGHIJ' | ConvertTo-SecureString -AsPlainText -Force #gitleaks:allow
                LoginTime         = Get-Date
                IsTwoFactorAuth   = $true
                TwoFactorMethods  = @('TOTP', 'SMS')
                LastLoginAttempts = @(
                    [PSCustomObject]@{
                        Timestamp = (Get-Date).AddHours(-1)
                        IP        = '192.168.1.101' | ConvertTo-SecureString -AsPlainText -Force
                        Success   = $true
                    },
                    [PSCustomObject]@{
                        Timestamp = (Get-Date).AddDays(-1)
                        IP        = '203.0.113.5' | ConvertTo-SecureString -AsPlainText -Force
                        Success   = $false
                    }
                )
                UserPreferences   = @{
                    Theme         = 'dark'
                    DefaultBranch = 'main'
                    Notifications = [PSCustomObject]@{
                        Email = $true
                        Push  = $false
                        SMS   = $true
                    }
                    CodeReview    = @('PR Comments', 'Inline Suggestions')
                }
                Repositories      = @(
                    [PSCustomObject]@{
                        Name        = 'Repo1'
                        IsPrivate   = $true
                        CreatedDate = (Get-Date).AddMonths(-6)
                        Stars       = 42
                        Languages   = @('Python', 'JavaScript')
                    },
                    [PSCustomObject]@{
                        Name        = 'Repo2'
                        IsPrivate   = $false
                        CreatedDate = (Get-Date).AddYears(-1)
                        Stars       = 130
                        Languages   = @('C#', 'HTML', 'CSS')
                    }
                )
                AccessScopes      = @('repo', 'user', 'gist', 'admin:org')
                ApiRateLimits     = [PSCustomObject]@{
                    Limit     = 5000
                    Remaining = 4985
                    ResetTime = (Get-Date).AddMinutes(30)
                }
                SessionMetaData   = [PSCustomObject]@{
                    SessionID   = 'sess_abc123'
                    Device      = 'Windows-PC'
                    Location    = [PSCustomObject]@{
                        Country = 'USA'
                        City    = 'New York'
                    }
                    BrowserInfo = [PSCustomObject]@{
                        Name    = 'Chrome'
                        Version = '118.0.1'
                    }
                }
            }
            $json = ConvertTo-ContextJson -Context $githubLoginContext
            Write-Verbose $json -Verbose
            $object = ConvertFrom-Json -InputObject $json
            $object.AuthToken | Should -Be '[SECURESTRING]ghp_12345ABCDE67890FGHIJ'
            $object.UserPreferences.CodeReview | Should -Be @('PR Comments', 'Inline Suggestions')
            $object.UserPreferences.Notifications.Push | Should -Be $false
            $object.Repositories[0].Languages | Should -Be @('Python', 'JavaScript')
            $object.Repositories[1].IsPrivate | Should -Be $false
            $object.ApiRateLimits.Remaining | Should -Be 4985
            $object.SessionMetaData.Location.City | Should -Be 'New York'
            $object.LastLoginAttempts[0].IP | Should -Be '[SECURESTRING]192.168.1.101'
        }
    }

    Context 'Function: ConvertFrom-ContextJson' {
        It 'Function is be available' {
            Get-Command -Name 'ConvertFrom-ContextJson' | Should -Not -BeNullOrEmpty
        }
        It 'ConvertFrom-ContextJson -JsonString $JsonString - Should return a context object' {
            $json = '{"LoginTime":"2024-11-21T17:01:19.3045811+01:00","SessionMetaData":{"SessionID":"sess_abc123","Location":{"Country":"USA","City":"New York"},"BrowserInfo":{"Name":"Chrome","Version":"118.0.1"},"Device":"Windows-PC"},"ApiRateLimits":{"Limit":5000,"ResetTime":"2024-11-21T17:31:19.3075083+01:00","Remaining":4985},"Repositories":[{"Name":"Repo1","Stars":42,"IsPrivate":true,"CreatedDate":"2024-05-21T17:01:19.3066076+02:00","Languages":["Python","JavaScript"]},{"Name":"Repo2","Stars":130,"IsPrivate":false,"CreatedDate":"2023-11-21T17:01:19.3070833+01:00","Languages":["C#","HTML","CSS"]}],"LastLoginAttempts":[{"Success":true,"IP":"[SECURESTRING]192.168.1.101","Timestamp":"2024-11-21T16:01:19.3046096+01:00"},{"Success":false,"IP":"[SECURESTRING]203.0.113.5","Timestamp":"2024-11-20T17:01:19.3056804+01:00"}],"Username":"john_doe","IsTwoFactorAuth":true,"AuthToken":"[SECURESTRING]ghp_12345ABCDE67890FGHIJ","AccessScopes":["repo","user","gist","admin:org"],"UserPreferences":[{"Notifications":{"SMS":true,"Email":true,"Push":false},"Theme":"dark","CodeReview":["PR Comments","Inline Suggestions"],"DefaultBranch":"main"}],"TwoFactorMethods":["TOTP","SMS"]}'
            $object = ConvertFrom-ContextJson -JsonString $json
            $object.AuthToken | Should -BeOfType [System.Security.SecureString]
            $object.AuthToken | ConvertFrom-SecureString -AsPlainText | Should -Be 'ghp_12345ABCDE67890FGHIJ'
            $object.UserPreferences.CodeReview | Should -Be @('PR Comments', 'Inline Suggestions')
            $object.UserPreferences.Notifications.Push | Should -Be $false
            $object.Repositories[0].Languages | Should -Be @('Python', 'JavaScript')
            $object.Repositories[1].IsPrivate | Should -Be $false
            $object.ApiRateLimits.Remaining | Should -Be 4985
            $object.SessionMetaData.Location.City | Should -Be 'New York'
            $object.LastLoginAttempts[0].IP | ConvertFrom-SecureString -AsPlainText | Should -Be '192.168.1.101'
        }
    }
}
#>
BeforeAll {
    Get-SecretInfo | Remove-Secret
}
Describe 'Context' {
    Context 'Function: Set-Context' {
        It "Set-Context -ID 'TestID1'" {
            { Set-Context -ID 'TestID1' } | Should -Not -Throw

            $result = Get-Context -ID 'TestID1'
            $result | Should -Not -BeNullOrEmpty
            $result.ID | Should -Be 'TestID1'
        }
        It "Set-Context -ID 'TestID2' -Context @{}" {
            { Set-Context -ID 'TestID2' -Context @{} } | Should -Not -Throw

            $result = Get-Context -ID 'TestID2'
            $result | Should -Not -BeNullOrEmpty
            $result.ID | Should -Be 'TestID2'
        }
        It "Set-Context -ID 'TestID2' -Context @{} - Again" {
            { Set-Context -ID 'TestID2' -Context @{} } | Should -Not -Throw

            $result = Get-Context -ID 'TestID2'
            $result | Should -Not -BeNullOrEmpty
            $result.ID | Should -Be 'TestID2'
        }
    }

    Context 'Function: Get-Context' {
        It 'Get-Context - Should return all contexts' {
            Write-Verbose (Get-Context | Out-String) -Verbose
            (Get-Context).Count | Should -BeGreaterThan 1
        }
        It "Get-Context -ID '*' - Should return all contexts" {
            Write-Verbose (Get-Context -ID '*' | Out-String) -Verbose
            (Get-Context -ID '*').Count | Should -BeGreaterOrEqual 3
        }
        It "Get-Context -ID 'TestID*' - Should return all contexts" {
            Write-Verbose (Get-Context -ID 'TestID*' | Out-String) -Verbose
            (Get-Context -ID 'TestID*').Count | Should -Be 2
        }
        It "Get-Context -ID '' - Should return no contexts" {
            Write-Verbose (Get-Context -ID '' | Out-String) -Verbose
            { Get-Context -ID '' } | Should -Not -Throw
            Get-Context -ID '' | Should -BeNullOrEmpty
        }
        It 'Get-Context -ID $null - Should return no contexts' {
            Write-Verbose (Get-Context -ID $null | Out-String) -Verbose
            { Get-Context -ID $null } | Should -Not -Throw
            Get-Context -ID $null | Should -BeNullOrEmpty
        }
    }

    Context 'Function: Remove-Context' {
        It "Remove-Context -ID 'AContextID' - Should remove the context" {
            Get-SecretInfo | Remove-Secret

            { 1..10 | ForEach-Object {
                    Set-Context -Context @{} -ID "Temp$_"
                }
            } | Should -Not -Throw

            (Get-Context -ID 'Temp*').Count | Should -Be 10

            { 1..10 | ForEach-Object {
                    Remove-Context -ID "Temp$_"
                }
            } | Should -Not -Throw
            (Get-Context -ID 'Temp*').Count | Should -Be 0
        }
    }

    Context 'Function: Rename-Context' {
        BeforeEach {
            # Ensure no contexts exist before starting tests
            Get-Context | ForEach-Object {
                Remove-Context -ID $_.ID
            }
        }

        AfterEach {
            # Cleanup any contexts created during tests
            Get-Context | ForEach-Object {
                Remove-Context -ID $_.ID
            }
        }

        It 'Renames the context successfully' {
            $ID = 'TestContext'
            $newID = 'RenamedContext'

            Set-Context -ID $ID

            # Rename the context
            Rename-Context -ID $ID -NewID $newID

            # Verify the old context no longer exists
            Get-Context -ID $ID | Should -BeNullOrEmpty
            Get-Context -ID $newID | Should -Not -BeNullOrEmpty
        }

        It 'Throws an error when renaming a non-existent context' {
            { Rename-Context -ID 'NonExistentContext' -NewID 'NewContext' } | Should -Throw
        }

        It 'Renaming a context to an existing context throws without force' {
            $existingID = 'ExistingContext'

            Set-Context -ID $existingID
            Set-Context -ID 'TestContext'

            # Attempt to rename the context to an existing context
            { Rename-Context -ID 'TestContext' -NewID $existingID } | Should -Throw
        }

        It 'Renaming a context to an existing context does not throw with force' {
            $existingID = 'ExistingContext'

            Set-Context -ID $existingID
            Set-Context -ID 'TestContext'

            # Attempt to rename the context to an existing context
            { Rename-Context -ID 'TestContext' -NewID $existingID -Force } | Should -Not -Throw
        }
    }

    # Context 'Scenarios' {
    #     It 'Context can hold a complex object' {
    #         $githubLoginContext = [PSCustomObject]@{
    #             Username          = 'john_doe'
    #             AuthToken         = 'ghp_12345ABCDE67890FGHIJ' | ConvertTo-SecureString -AsPlainText -Force #gitleaks:allow
    #             LoginTime         = Get-Date
    #             IsTwoFactorAuth   = $true
    #             TwoFactorMethods  = @('TOTP', 'SMS')
    #             LastLoginAttempts = @(
    #                 [PSCustomObject]@{
    #                     Timestamp = (Get-Date).AddHours(-1)
    #                     IP        = '192.168.1.101' | ConvertTo-SecureString -AsPlainText -Force
    #                     Success   = $true
    #                 },
    #                 [PSCustomObject]@{
    #                     Timestamp = (Get-Date).AddDays(-1)
    #                     IP        = '203.0.113.5' | ConvertTo-SecureString -AsPlainText -Force
    #                     Success   = $false
    #                 }
    #             )
    #             UserPreferences   = @{
    #                 Theme         = 'dark'
    #                 DefaultBranch = 'main'
    #                 Notifications = [PSCustomObject]@{
    #                     Email = $true
    #                     Push  = $false
    #                     SMS   = $true
    #                 }
    #                 CodeReview    = @('PR Comments', 'Inline Suggestions')
    #             }
    #             Repositories      = @(
    #                 [PSCustomObject]@{
    #                     Name        = 'Repo1'
    #                     IsPrivate   = $true
    #                     CreatedDate = (Get-Date).AddMonths(-6)
    #                     Stars       = 42
    #                     Languages   = @('Python', 'JavaScript')
    #                 },
    #                 [PSCustomObject]@{
    #                     Name        = 'Repo2'
    #                     IsPrivate   = $false
    #                     CreatedDate = (Get-Date).AddYears(-1)
    #                     Stars       = 130
    #                     Languages   = @('C#', 'HTML', 'CSS')
    #                 }
    #             )
    #             AccessScopes      = @('repo', 'user', 'gist', 'admin:org')
    #             ApiRateLimits     = [PSCustomObject]@{
    #                 Limit     = 5000
    #                 Remaining = 4985
    #                 ResetTime = (Get-Date).AddMinutes(30)
    #             }
    #             SessionMetaData   = [PSCustomObject]@{
    #                 SessionID   = 'sess_abc123'
    #                 Device      = 'Windows-PC'
    #                 Location    = [PSCustomObject]@{
    #                     Country = 'USA'
    #                     City    = 'New York'
    #                 }
    #                 BrowserInfo = [PSCustomObject]@{
    #                     Name    = 'Chrome'
    #                     Version = '118.0.1'
    #                 }
    #             }
    #         }

    #         # Test to see if it can be run multiple times
    #         Set-Context -Context $githubLoginContext -ID 'BigComplexObjectWith[specialchars]'
    #         Set-Context -Context $githubLoginContext -ID 'BigComplexObjectWith[specialchars]'
    #         Set-Context -Context $githubLoginContext -ID 'BigComplexObjectWith[specialchars]'
    #         Write-Verbose (Get-Context -ID 'BigComplexObjectWith[specialchars]') -Verbose
    #         $object = Get-Context -ID 'BigComplexObjectWith[specialchars]'
    #         $object.ApiRateLimits.Remaining | Should -Be 4985
    #         $object.AuthToken | Should -BeOfType [System.Security.SecureString]
    #         $object.AuthToken | ConvertFrom-SecureString -AsPlainText | Should -Be 'ghp_12345ABCDE67890FGHIJ'
    #         $object.LastLoginAttempts[0].IP | Should -BeOfType [System.Security.SecureString]
    #         $object.LastLoginAttempts[0].IP | ConvertFrom-SecureString -AsPlainText | Should -Be '192.168.1.101'
    #         $object.LoginTime | Should -BeOfType [datetime]
    #         $object.Repositories[0].Languages | Should -Be @('Python', 'JavaScript')
    #         $object.Repositories[1].IsPrivate | Should -BeOfType [bool]
    #         $object.Repositories[1].IsPrivate | Should -Be $false
    #         $object.SessionMetaData.Location.City | Should -BeOfType [string]
    #         $object.SessionMetaData.Location.City | Should -Be 'New York'
    #         $object.UserPreferences | Should -BeOfType [PSCustomObject]
    #         $object.UserPreferences.GetType().Name | Should -Be 'PSCustomObject'
    #         $object.UserPreferences.CodeReview.GetType().BaseType.Name | Should -Be 'Array'
    #         $object.UserPreferences.CodeReview.Count | Should -Be 2
    #         $object.UserPreferences.CodeReview | Should -Be @('PR Comments', 'Inline Suggestions')
    #         $object.UserPreferences.CodeReview.GetType().BaseType.Name | Should -Be 'Array'
    #         $object.UserPreferences.CodeReview[0] | Should -Be 'PR Comments'
    #         $object.UserPreferences.Notifications.Push | Should -Be $false
    #     }
    #     It 'Can list multiple contexts' {
    #         Get-SecretInfo | Remove-Secret

    #         $Context = @{
    #             Name         = 'Test3'
    #             AccessToken  = 'MySecret'
    #             RefreshToken = 'MyRefreshedSecret'
    #         }

    #         { Set-Context -Context $Context -ID 'Other/Test3' } | Should -Not -Throw

    #         $Context = @{
    #             Name         = 'Test4'
    #             AccessToken  = 'MySecret'
    #             RefreshToken = 'MyRefreshedSecret'
    #         }

    #         { Set-Context -Context $Context -ID 'Other/Test4' } | Should -Not -Throw

    #         $Context = @{
    #             Name         = 'Test5'
    #             AccessToken  = 'MySecret'
    #             RefreshToken = 'MyRefreshedSecret'
    #         }

    #         { Set-Context -Context $Context -ID 'Other/Test5' } | Should -Not -Throw

    #         (Get-Context -ID 'Other/Test*').Count | Should -Be 3

    #         { 3..5 | ForEach-Object {
    #                 Remove-Context -ID "Other/Test$_"
    #             }
    #         } | Should -Not -Throw
    #         (Get-Context -ID 'Other/Test*').Count | Should -Be 0
    #     }
    #     It 'Can get a context with special characters' {
    #         Get-SecretInfo | Remove-Secret

    #         $Context = @{
    #             Name        = 'qweqwe3'
    #             AccessToken = 'test'
    #         }
    #         { Set-Context -Context $Context -ID 'MyModule/ThisIsATest[bot]' } | Should -Not -Throw

    #         $result = Get-Context -ID 'MyModule/ThisIsATest[bot]'
    #         $result | Should -Not -BeNullOrEmpty
    #         $result.Name | Should -Be 'qweqwe3'

    #         { Remove-Context -ID 'MyModule/ThisIsATest[bot]' } | Should -Not -Throw
    #     }
    #     It 'Only lists context, not other secrets' {
    #         Set-Secret -Name 'Test' -Secret 'Test'
    #         Set-Context -ID 'Test' -Context @{ Name = 'Test' }
    #         $result = Get-Context
    #         Write-Verbose ($result | Out-String) -Verbose
    #         $result.Count | Should -Be 1

    #         Remove-Context -ID 'Test'
    #         Get-SecretInfo -Name 'Test' | Remove-Secret
    #     }
    # }

    # Context 'Function: Set-ContextSetting' {
    #     It "Set-ContextSetting -Name 'Test' -Value 'Test' -ID 'TestContext'" {
    #         Get-SecretInfo | Remove-Secret

    #         Write-Verbose 'Setup: Create a Context'
    #         Set-Context -Context @{ Name = 'Test'; Secret = 'Test' } -ID 'TestContext'

    #         Write-Verbose 'Test: Set-ContextSetting'
    #         { Set-ContextSetting -Name 'Test' -Value 'Test' -ID 'TestContext' } | Should -Not -Throw
    #         { Set-ContextSetting -Name 'Test' -Value 'Test' -ID 'TestContext' } | Should -Not -Throw

    #         Write-Verbose 'Verify: The ContextSetting should exist'
    #         $result = Get-ContextSetting -Name 'Name' -ID 'TestContext'
    #         Write-Verbose ($result | Out-String) -Verbose
    #         $result | Should -Be 'Test'

    #         Write-Verbose 'Cleanup: Remove the Context'
    #         Remove-Context -ID 'TestContext'
    #     }
    #     It "Set-ContextSetting -Name 'Test' -Value 'Test' -ID 'Test55'" {
    #         Write-Verbose 'Test: Set-ContextSetting'
    #         { Set-ContextSetting -Name 'Test' -Value 'Test' -ID 'Test55' } | Should -Throw
    #     }
    #     It "Set-ContextSetting -Name 'Name' -Value 'Cake' -ID 'Test'" {
    #         Write-Verbose 'Setup: Create a Context'
    #         Set-Context -Context @{ Name = 'Test'; Secret = 'Test' } -ID 'TestSomething'

    #         Write-Verbose 'Test: Set-ContextSetting'
    #         { Set-ContextSetting -Name 'Name' -Value 'Cake' -ID 'TestSomething' } | Should -Not -Throw

    #         Write-Verbose 'Verify: The ContextSetting should exist'
    #         $result = Get-Context -ID 'TestSomething'
    #         $result | Should -Not -BeNullOrEmpty

    #         Write-Verbose 'Cleanup: Remove the Context'
    #         Remove-Context -ID 'TestSomething'
    #     }
    # }

    # Context 'Function: Get-ContextSetting' {
    #     It "Get-ContextSetting -Name 'Test' -ID 'Test'" {
    #         Write-Verbose 'Setup: Create a Context'
    #         Set-Context -Context @{ Name = 'Test'; Secret = 'Test' } -ID 'Test'
    #         Set-ContextSetting -Name 'Test' -Value 'Test' -ID 'Test'

    #         Write-Verbose 'Test: Get-ContextSetting'
    #         Get-ContextSetting -Name 'Test' -ID 'Test' | Should -Be 'Test'

    #         Write-Verbose 'Verify: The ContextSetting should exist'
    #         $result = Get-ContextSetting -Name 'Test' -ID 'Test'
    #         $result | Should -Not -BeNullOrEmpty

    #         Write-Verbose 'Cleanup: Remove the Context'
    #         Remove-Context -ID 'Test'
    #     }
    #     It "Get-ContextSetting -Name 'Test' -ID 'Test55'" {
    #         Write-Verbose 'Test: Get-ContextSetting'
    #         { Get-ContextSetting -Name 'Test' -ID 'Test55' } | Should -Throw -Because 'Context does not exist'
    #     }
    # }

    # Context 'Function: Remove-ContextSetting' {
    #     It "Remove-ContextSetting -Name 'Test' -ID 'Test'" {
    #         Write-Verbose 'Setup: Create a Context'
    #         Set-Context -Context @{ Name = 'Test'; Secret = 'Test' } -ID 'Test'
    #         Set-ContextSetting -Name 'Test' -Value 'Test' -ID 'Test'

    #         Write-Verbose 'Test: Remove-ContextSetting'
    #         { Get-ContextSetting -Name 'Test' -ID 'Test' } | Should -Not -BeNullOrEmpty
    #         { Remove-ContextSetting -Name 'Test' -ID 'Test' } | Should -Not -Throw
    #         { Remove-ContextSetting -Name 'Test' -ID 'Test' } | Should -Not -Throw

    #         Write-Verbose 'Verify: The ContextSetting should no longer exist'
    #         $result = Get-ContextSetting -Name 'Test' -ID 'Test'
    #         $result | Should -BeNullOrEmpty

    #         Write-Verbose 'Cleanup: Remove the Context'
    #         Remove-Context -ID 'Test'
    #     }
    #     It "Remove-ContextSetting -Name 'Test' -Context 'Test55'" {
    #         Write-Verbose 'Test: Remove-ContextSetting'
    #         { Remove-ContextSetting -Name 'Test' -ID 'Test55' } | Should -Throw -Because 'Context does not exist'
    #     }
    # }
}
