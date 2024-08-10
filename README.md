# Store

A PowerShell module that manages a store of secrets and variables.
This module is designed to be a simple way to store and retrieve secrets and variables in a PowerShell script or module.

## Prerequisites

This module relies on [Microsoft.PowerShell.SecretManagement](https://github.com/powershell/SecretManagement) and
[Microsoft.PowerShell.SecretStore](https://github.com/PowerShell/SecretStore) by default. You can use other secret vault
providers by installing them and setting them as the provider when calling the function.

## Installation

Provide step-by-step instructions on how to install the module, including any InstallModule commands or manual installation steps.

```powershell
Install-Module -Name Store
Import-Module -Name Store
```

## Usage

Here is a list of example that are typical use cases for the module.
This section should provide a good overview of the module's capabilities.

### Initialize the store

The following command creates a new store with the name 'MyStore'. This results in a `config.json` file being created in `$HOME\.mystore\`.
It also ensures there is a secret vault provider created called 'SecretStore' and sets it as the default provider for the store.

If a store already exists with the type 'Microsoft.PowerShell.SecretStore', it will be used as the default provider for the store.

```powershell
Initialize-Store -Name 'MyStore'
```

### Add a variable to the store

The following command adds a variable to the store with the name 'MyVariable' and the value 'Something'.

```powershell
Add-StoreConfig -Name 'MyVariable' -Value 'Something'
```

As the value is not a secure string, it will be stored in plain text in the store json file.

### Add a secret to the store

The following command adds a secret to the store with the name 'MySecret' and the value 'Something'. The secret is stored in the default provider.

```powershell
Add-StoreConfig -Name 'MySecret' -Value ('Something' | ConvertTo-SecureString -AsPlainText -Force)
```

As the value is a secure string, it will be stored securely in the secret vault.

### Get a variable or secret from the store

The following command gets the value of the variable 'MyVariable' from the store.

```powershell
Get-StoreConfig -Name 'MyVariable'
```

The following command gets the value of the secret 'MySecret' from the store.

```powershell
Get-StoreConfig -Name 'MySecret'
```

## Contributing

Coder or not, you can contribute to the project! We welcome all contributions.

### For Users

If you don't code, you still sit on valuable information that can make this project even better. If you experience that the
product does unexpected things, throw errors or is missing functionality, you can help by submitting bugs and feature requests.
Please see the issues tab on this project and submit a new issue that matches your needs.

### For Developers

If you do code, we'd love to have your contributions. Please read the [Contribution guidelines](CONTRIBUTING.md) for more information.
You can either help by picking up an existing issue or submit a new one if you have an idea for a new feature or improvement.

## Links

- SecretManagement | [GitHub](https://github.com/powershell/SecretManagement) | [Docs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules)
- SecretStore | [GitHub](https://github.com/PowerShell/SecretStore) | [Docs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretstore/?view=ps-modules)
- [Overview of the SecretManagement and SecretStore modules | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules)
