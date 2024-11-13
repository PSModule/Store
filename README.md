# Context

Modules usually have two types of data that would be great to store and manage in a good way: module and user settings and secrets. With this module, we aim
to store this data using a the concept of `Contexts` that are stored locally on the machine where the module is running. It lets module developers
separate user and module data from the module code, so that modules can be created in a way where users can resume from where they left off without
having to reconfigure the module or log in to services that support refreshing sessions with data you can store, i.e., refresh tokens.

The consept of `Contexts` is built on top of the functionality that `Microsoft.PowerShell.SecretManagement` and `Microsoft.PowerShell.SecretStore`
modules provide. The `Context` module manages a set of `secrets` that is stored in a `SecretVault` instance. A context in this case is a collection
of secrets and metadata that is combined to represent a context for a module or a user.

## What is a Context?

A context is an object of a name, a secret and metadata that is combined to represent a context for a module or a user.

A context object looks like this:

```json
{
    "Name": "PSModule/GitHub",
    "Secret": "123456", // As a secure string
    "Metadata": {
        "ApiVersion": "v3",
        "ClientId": "123456",
        "APIEndpoint": "https://api.github.com"
    }
}
```

## Prerequisites

This module relies on [Microsoft.PowerShell.SecretManagement](https://github.com/powershell/SecretManagement) and
[Microsoft.PowerShell.SecretStore](https://github.com/PowerShell/SecretStore). The module automatically installs these modules if they are not
already installed.

## Installation

Install the module from the PowerShell Gallery by running the following command:

```powershell
Install-PSResource -Name Context -TrustRepository -Repository PSGallery
Import-Module -Name Context
```

## Usage

As mentioned earlier, there are two types of data that can be stored using the `Context` module: module and user settings and secrets.
Lets have a look at how to use the module to store these types of data in abit more detail.

### Module settings

To store module data, the module developer can create a context that defines a "namespace" for the module. This context can store settings and secrets
for the module. A module developer can also create additional contexts for additional settings that share the same lifecycle, like settings
associated with a module extension.

Let's say we have a module called `GitHub` that needs to store some settings and secrets. The module developer could initialize a context called
`GitHub` as part of the loading section in the module code. All module configuration would be stored in this context by using the functionality in
this module.

Even the `Context` module uses its own context to store settings and secrets. The context is called `PSModule/Context` and can be seen on the secret
vault.

### User Configuration

To store user data, the module developer can create a new context that defines a "namespace" for the user configuration. So let's say a developer has
implemented this for the `GitHub` module, a user would log in using their details. The module would call upon `Context` functionality to create a new
context under the `GitHub` context.

Imagine a user called `BobMarley` logs in to the `GitHub` module. The following would exist in the context:

- `PSModule/GitHub` containing module configuration, like default user, host, and client ID to use if not otherwise specified.
- `PSModule/GitHub.BobMarley` containing user configuration, details about the user, default values for API calls etc.
- `PSModule/GitHub.BobMarley.AccessToken` containing the access token for the user with the validity stored in the metadata.
- `PSModule/GitHub.BobMarley.RefreshToken` containing the refresh token for the user with the validity stored in the metadata.

Let's say the person also has another account on `GitHub` called `RastaBlasta`. After logging on with the second account, the following context would
also exist in the context:

- `PSModule/GitHub.RastaBlasta` containing user configuration
- `PSModule/GitHub.RastaBlasta.AccessToken` containing the access token for the user with the validity stored in the metadata
- `PSModule/GitHub.RastaBlasta.RefreshToken` containing the refresh token for the user with the validity stored in the metadata

With this the module developer could allow users to set default context, and store a key of the name of that context in the module context. This way
the module could automatically log in the user to the correct account when the module is loaded. The user could also switch between accounts by
changing the default context.

### Setup for a New Module

To set up a new module to use the `Context` module, the following steps should be taken:

1. Create a new context for the module -> `Set-Context -Name 'GitHub'` during the module initialization.
2. Add some module configuration -> `Set-ContextSetting -Context 'GitHub' -Name 'ClientId' -Value '123456'`
3. Get the module configuration -> `Get-ContextSetting -Context 'GitHub' -Name 'ClientId'` -> `123456`
   - `Get-ContextSettign -Context 'GitHub'` -> Returns all module configuration for the `GitHub` context.
4. Remove the module configuration -> `Remove-ContextSetting -Context 'GitHub' -Name 'ClientId'`

### Setup for a New Context

To set up a new context for a user, the following steps should be taken:

1. Create a new context for the user -> `Set-Context -Context 'GitHub.BobMarley'` -> Context `GitHub.BobMarley` is created.
2. Add some user configuration -> `Set-ContextSetting -Context 'GitHub.BobMarley.AccessToken' -Name 'Secret' -Value '123456'` ->
   Secret `GitHub.BobMarley.AccessToken` is created.
3. Get the user configuration -> `Get-ContextSetting -Context 'GitHub.BobMarley.AccessToken' -Name 'Secret' -AsPlainText` -> `123456`
4. Remove the user configuration -> `Remove-Context -Name 'GitHub.BobMarley.AccessToken'` -> Secret `GitHub.BobMarley.AccessToken` is removed.

## Contributing

Coder or not, you can contribute to the project! We welcome all contributions.

### For Users

If you don't code, you still sit on valuable information that can make this project even better. If you experience that the
product does unexpected things, throws errors, or is missing functionality, you can help by submitting bugs and feature requests.
Please see the issues tab on this project and submit a new issue that matches your needs.

### For Developers

If you do code, we'd love to have your contributions. Please read the [Contribution guidelines](CONTRIBUTING.md) for more information.

## Links

- SecretManagement | [GitHub](https://GitHub.com/powershell/SecretManagement) | [Docs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules)
- SecretStore | [GitHub](https://GitHub.com/PowerShell/SecretStore) | [Docs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretstore/?view=ps-modules)
- [Overview of the SecretManagement and SecretStore modules | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules)
