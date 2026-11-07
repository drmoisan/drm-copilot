<#
    Allowlist helpers for the enforcement-hook Python-invocation guard (issue #475).

    ALLOWLIST POLICY - ONE OWNER-DECIDED ENTRY, NO OTHER ENTRY.
    `$script:PythonInvocationAllowlist` holds exactly one entry: the issue #1031
    Python-native docs analyzer, permitted by owner decision D3 (a language-native
    analyzer for the same language, shipped only in that language's pack) and recorded
    in the epic Q11 default and the 1031 feature specification. Every other Python
    invocation site in the guarded tree stays removed (issue #475). A further entry may
    be added ONLY by an explicit owner decision recorded in a feature specification; an
    implementer failing this guard must remove the invocation and must NEVER add an
    entry to work around it. Assertion B fails any stale entry.

    This file is dot-sourced from the top of EnforcementHooksNoPythonInvocation.Helpers.ps1
    (issue #935, I-3); its declaration and functions moved there unchanged.
#>

# ALLOWLIST - ONE ENTRY. Read "ALLOWLIST POLICY" above before touching it.
$script:PythonInvocationAllowlist = @(
    # Owner decision D3, epic Q11 and docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md:
    # the only interpreter-start function of the Python-native docs analyzers (three seam calls).
    @{ Path = '.claude/lib/docs/DocsAnalyzerPythonNative.psm1'; Function = 'Invoke-DocsPythonNativeInterpreter' }
)

function Get-PythonInvocationAllowlist {
    <#
    .SYNOPSIS
        Returns the allowlist (one owner-decided entry). An entry is a hashtable
        with `Path` (repo-root-relative) and `Function` ('<script>' at file scope).
    .OUTPUTS
        [object[]] The allowlist entries.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    return , @($script:PythonInvocationAllowlist)
}

function Test-PythonInvocationAllowlistMatch {
    <#
    .SYNOPSIS
        Indicates whether an allowlist entry covers a finding (Path and Function
        both match, case-insensitively).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Finding,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Entry
    )

    return (([string]$Entry['Path'] -ieq [string]$Finding.Path) -and
        ([string]$Entry['Function'] -ieq [string]$Finding.Function))
}

function Select-UnallowedPythonInvocationFinding {
    <#
    .SYNOPSIS
        Returns findings no allowlist entry covers (Assertion A input).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Finding,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Allowlist
    )

    $residual = [System.Collections.Generic.List[object]]::new()
    foreach ($item in $Finding) {
        $covered = @($Allowlist | Where-Object { Test-PythonInvocationAllowlistMatch -Finding $item -Entry $_ })
        if ($covered.Count -eq 0) {
            $residual.Add($item)
        }
    }
    return , $residual.ToArray()
}

function Get-UnusedPythonInvocationAllowlistEntry {
    <#
    .SYNOPSIS
        Returns allowlist entries matching no detected finding (Assertion B input).
        Vacuously empty while the allowlist is empty; retained so any future entry
        that goes stale fails the suite instead of masking a removed site.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Finding,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Allowlist
    )

    $stale = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Allowlist) {
        $used = @($Finding | Where-Object { Test-PythonInvocationAllowlistMatch -Finding $_ -Entry $entry })
        if ($used.Count -eq 0) {
            $stale.Add($entry)
        }
    }
    return , $stale.ToArray()
}
