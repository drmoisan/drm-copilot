<#
    Allowlist helpers for the enforcement-hook Python-invocation guard (issue #475).

    ALLOWLIST POLICY - THE TABLE IS EMPTY AND MUST REMAIN EMPTY.
    `$script:PythonInvocationAllowlist` is authored with ZERO entries: every Python
    invocation site in the guarded tree is removed within issue #475. Entries may be
    added ONLY by an explicit owner decision recorded in the feature specification; an
    implementer failing this guard must remove the invocation and must NEVER add an
    entry to work around it. Assertion B fails any stale entry.

    This file is dot-sourced from the top of EnforcementHooksNoPythonInvocation.Helpers.ps1
    (issue #935, I-3); its declaration and functions moved there unchanged.
#>

# ALLOWLIST - INTENTIONALLY EMPTY. Read "ALLOWLIST POLICY" above before touching it.
# A would-be entry: @{ Path = '.claude/hooks/example.ps1'; Function = 'Invoke-Example' }
$script:PythonInvocationAllowlist = @()

function Get-PythonInvocationAllowlist {
    <#
    .SYNOPSIS
        Returns the (empty by design) allowlist. A would-be entry is a hashtable
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
