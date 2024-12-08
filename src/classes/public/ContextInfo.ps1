class ContextInfo {
    [string] $ID
    [hashtable] $Metadata
    [string] $SecretName
    [string] $SecretType
    [string] $VaultName

    ContextInfo([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    ContextInfo([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
