<#
.SYNOPSIS
    Pure check-poll helpers for scripts/dev-tools/Invoke-FullReleaseFlow.ps1.

.DESCRIPTION
    The three functions in this file are pure: they make no external call and
    perform no filesystem access, network access, or wait. They live in this
    sibling file because scripts/dev-tools/Invoke-FullReleaseFlow.ps1 stood one
    line under the 500-line cap (issue #931). This file declares no entry-point
    block and is dot-sourced by scripts/dev-tools/Invoke-FullReleaseFlow.ps1.
#>


function ConvertFrom-CheckPollOutput {
    <#
    .SYNOPSIS
        Parses gh check poll output into check objects without throwing.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory = $true)]
        [object[]]$Output
    )
    $failed = [pscustomobject]@{ Succeeded = $false; Checks = @() }
    $text = $Output -join "`n"
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $failed
    }
    try {
        $parsed = @($text | ConvertFrom-Json -ErrorAction Stop)
    }
    catch [System.ArgumentException] {
        return $failed
    }
    foreach ($item in $parsed) {
        if ($item -isnot [System.Management.Automation.PSCustomObject]) {
            return $failed
        }
    }

    return [pscustomobject]@{ Succeeded = $true; Checks = $parsed }
}

function Get-CheckSetVerdict {
    <#
    .SYNOPSIS
        Classifies a check set as pass, fail, unknown, pending, or empty.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowEmptyCollection()]
        [Parameter(Mandatory = $true)]
        [object[]]$Checks
    )
    if ($Checks.Count -eq 0) {
        return [pscustomobject]@{ Verdict = 'empty'; Detail = '' }
    }
    $known = @('pass', 'skipping', 'pending', 'fail', 'cancel')
    $buckets = @(foreach ($check in $Checks) {
            $property = $check.PSObject.Properties['bucket']
            if ($null -eq $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
                '(missing)'
            }
            else {
                [string]$property.Value
            }
        })
    if ($buckets -ccontains 'fail' -or $buckets -ccontains 'cancel') {
        return [pscustomobject]@{ Verdict = 'fail'; Detail = '' }
    }

    $unknown = @($buckets | Where-Object { $_ -cnotin $known })
    if ($unknown.Count -gt 0) {
        return [pscustomobject]@{ Verdict = 'unknown'; Detail = $unknown[0] }
    }

    if ($buckets -ccontains 'pending') {
        return [pscustomobject]@{ Verdict = 'pending'; Detail = '' }
    }

    return [pscustomobject]@{ Verdict = 'pass'; Detail = '' }
}

function Test-UnregisteredCheckPollOutput {
    <#
    .SYNOPSIS
        Reports whether failed gh check poll output means no check has registered yet.
    .DESCRIPTION
        gh pr checks exits non-zero with the error text 'no checks reported on
        the <branch> branch' while the pull request head has no check. Any other
        failure text, such as an authentication or network error, returns $false
        so the caller can fail at once instead of retrying.
    .OUTPUTS
        Boolean.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory = $true)]
        [object[]]$Output
    )
    foreach ($line in @($Output)) {
        if (([string]$line).Contains('no checks reported')) {
            return $true
        }
    }

    return $false
}
