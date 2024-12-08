class Context {
    # The context ID.
    # Context:<Something you choose>
    [string] $ID

    Context() {}

    # Creates a context object with the specified ID.
    Context([string]$ID) {
        $this.ID = $ID
    }

    # Creates a context object from a hashtable of key-vaule pairs.
    Context([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    Context([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    # Returns the context ID.
    [string] ToString() {
        return $this.ID
    }
}
