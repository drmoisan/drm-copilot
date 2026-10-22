# Fixture: shared discovery validation helper module.
# Sibling helpers are imported from .claude/lib/discovery-validation/ by file name.
function Test-FixtureDiscoveryAuthority {
    param([string]$Path)
    return $Path -ne ''
}
Export-ModuleMember -Function Test-FixtureDiscoveryAuthority
