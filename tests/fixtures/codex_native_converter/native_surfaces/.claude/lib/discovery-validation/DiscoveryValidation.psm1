# Fixture: shared discovery validation helper module.
# Sibling helpers are imported from .claude/lib/discovery-validation/ by file name.
function Test-FixtureDiscoveryAuthority {
    <#
    .SYNOPSIS
        Fixture stand-in for an authority check; reports whether a path was supplied.
    .PARAMETER Path
        Candidate authority path; any non-empty value is treated as present.
    #>
    param([string]$Path)
    return $Path -ne ''
}
Export-ModuleMember -Function Test-FixtureDiscoveryAuthority
