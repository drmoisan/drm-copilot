<#
.SYNOPSIS
    Dot-sourced standalone-merge authorization helpers for enforce-epic-merge-gate.ps1.

.DESCRIPTION
    Holds the fourth allow condition of the epic merge gate, the standalone-merge
    authorization record, together with the two pure decision-envelope factories the gate
    returns on every path.

    This file is split out of the parent hook, .claude/hooks/enforce-epic-merge-gate.ps1,
    because that file had 13 lines of headroom under the 500-line limit, which a fourth allow
    condition, its predicates, and the rewritten header could not fit (issue #670). The two
    envelope factories were moved here unchanged: they read no script-scoped state and no
    test calls them by name, so the move is a pure relocation with no behaviour change.

    Every function in this file is pure. It reads no file, starts no process, and reads no
    clock; the parent hook supplies the already-parsed checkpoint objects and the live
    envelope session_id. A test can therefore dot-source this file on its own.

    Honest disclosure. The standalone-merge authorization record is a policy-level,
    auditable declaration and is
    not a cryptographic or security control.
    It names a specific pull request, a specific session, an authorizer, a time, and a
    stated basis, so that a standalone merge leaves a reviewable trail and cannot be reached
    by accident or by a record written for a different pull request. authorized_by is a
    declaration only: the hook checks that it is present and non-empty and does not verify
    the identity it names, because the runtime exposes no attested agent identity at Bash
    PreToolUse time. The record is not tamper-proof: any actor able to write
    artifacts/orchestration/*.json inside the authorizing session can write a record,
    because all agents share one filesystem and defaultPermissionMode is bypassPermissions.
    The session_id cross-check binds a record to the session that emitted it, so a stale
    record from a previous run or a record copied between runs authorizes nothing; it does
    not stop same-session forgery. The mechanism converts an untraceable bypass into a
    deliberate, attributable, auditable act. This is a documented accepted trade, not an
    unexamined gap.

.NOTES
    Compatible with PowerShell 7+. No external module dependencies.
#>
[CmdletBinding()]
param()

function Get-EpicMergeGateAllowDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName      = 'PreToolUse'
            permissionDecision = 'allow'
        }
    }
}

function Get-EpicMergeGateBlockDecision {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string] $Reason
    )

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
}
