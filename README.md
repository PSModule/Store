# Store

A PowerShell module that manages a store of secrets and variables.

The main purpose of the module is to provide a standard way to store and retrieve
module and user configuration for PowerShell modules. The module builds a very thin overlay of functions ontop of the
`Microsoft.PowerShell.SecretManagement` and `Microsoft.PowerShell.SecretStore` modules. As they do not have a good way to manage modifying specific
values in the metadata of a secret, this module provides a way to do that.

## Prerequisites

This module relies on [Microsoft.PowerShell.SecretManagement](https://GitHub.com/powershell/SecretManagement) and
[Microsoft.PowerShell.SecretStore](https://GitHub.com/PowerShell/SecretStore).

## Installation

Install the module from the PowerShell Gallery by running the following command:

```powershell
Install-PSResource -Name Store -TrustRepository -Repository PSGallery
Import-Module -Name Store
```

## Usage

Modules usually have two types of data that would be great to store, module and user configuration. With this module we aim to store this data
separate from the module code, so that modules can be created in a way where users can resume from where they left off without having to reconfigure
the module or log in to services that support refreshing sessions with data you can store, i.e. refresh tokens.

### Module configuration

To store module configuration, the module developer can create a secret in the store that defines a "namespace" for the module configuration. All
other configurations done by the module will be stored with a name that is prefixed with the namespace. The secret metadata is where the configuration
is stored. The secret value itself it not used for the namespace secrets.

Lets say we have a module called `GitHub` that needs to store configuration. The module developer would initialize a store called 'GitHub'. All module
configuration would be stored in this secret. All other configutations would be stored "in" the `GitHub` store, when in reality they are stored flat
in the SecretStore, but uses a hierarchy based naming convention to group the secrets together.

### User configuration

To store user configuration, the module developer can create a secret in the store that defines a "namespace" for the user configuration within the
store they have defined. So lets say a developer has implemented this for the `GitHub` module, a user would log in using their details. The module
would call upon `Store` functionality to create a new context under the `GitHub` store.

Imagine a user called `BobMarley` logs in to the `GitHub` module. The following would exist in the store:

- `GitHub` containing module configuration, like default user, host and client ID to use if not otherwise specified.
- `GitHub.BobMarley` containing user configuration
- `GitHub.BobMarley.AccessToken` containing the access token for the user with the validity stored in the metadata
- `GitHub.BobMarley.RefreshToken` containing the refresh token for the user with the validity stored in the metadata

Lets say the person also has another account on GitHub called `RastaBlasta`. After logging on with the second account the store would also have:

- `GitHub.RastaBlasta` containing user configuration
- `GitHub.RastaBlasta.AccessToken` containing the access token for the user with the validity stored in the metadata
- `GitHub.RastaBlasta.RefreshToken` containing the refresh token for the user with the validity stored in the metadata

### Setup for a new module

To setup a new module to use the `Store` module, the following steps should be taken:

1. Create a new store for the module -> `Set-Store -Name 'GitHub'`
2. Add some module configuration -> `Set-StoreConfig -Store 'GitHub' -Name 'ClientId' -Value '123456'`
3. Get the module configuration -> `Get-StoreConfig -Store 'GitHub' -Name 'ClientId'` -> `123456`
   - Get-StoreData -Store 'GitHub' -> Returns all module configuration for the `GitHub` store.
4. Remove the module configuration -> `Remove-StoreConfig -Store 'GitHub' -Name 'ClientId'`

### Setup for a new context

To setup a new context for a user, the following steps should be taken:

1. Create a new context for the user -> `Set-Store -Store 'GitHub.BobMarley'` -> Secret `GitHub.BobMarley` is created.
2. Add some user configuration -> `Set-StoreConfig -Store 'GitHub.BobMarley.AccessToken' -Name 'Secret' -Value '123456'` -> Secret `GitHub.BobMarley.AccessToken` is created.
3. Get the user configuration -> `Get-StoreConfig -Store 'GitHub.BobMarley.AccessToken' -Name 'Secret' -AsPlainText` -> `123456`
4. Remove the user configuration -> `Remove-Store -Name 'GitHub.BobMarley.AccessToken'` -> Secret `GitHub.BobMarley.AccessToken` is removed.

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

- SecretManagement | [GitHub](https://GitHub.com/powershell/SecretManagement) | [Docs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules)
- SecretStore | [GitHub](https://GitHub.com/PowerShell/SecretStore) | [Docs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretstore/?view=ps-modules)
- [Overview of the SecretManagement and SecretStore modules | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules)
