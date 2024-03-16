function Get-StoreVariable {
    param(
        [string] $Name
    )

    Restore-VariableStore
    $script:Store.$Name
}
