<#
.SYNOPSIS
    Shared behavior rows and the row dispatcher for the AgentTargetWorktree resolver suites (issue #1163).

.DESCRIPTION
    Holds the behavior rows of Resolve-AgentTargetWorktree once, as data, so the module suite
    (tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Tests.ps1) and the Codex
    twin suite (tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1) run the same rows
    against their own implementation. Each row names its arguments, an invoker kind
    (Porcelain, Throwing, FailIfCalled), an optional porcelain text, an optional issue-reader
    map, and the expected WorktreeRoot, ReasonCode, Source, Unresolved, and StaleRegistration.
    Unresolved is expected true exactly on the rows that expect a reason code.

    This file defines no function under test and holds no state. Invoke-AgentTargetWorktreeRow
    calls Resolve-AgentTargetWorktree by name, so whichever implementation the dot-sourcing
    suite has loaded answers the row. Every porcelain text is built in memory with POSIX
    roots; no fixture file is read.
#>

function Get-AgentTargetWorktreePorcelain {
    <#
    .SYNOPSIS
        Return in-memory porcelain text for one of the named row topologies.
    .PARAMETER Topology
        Live (main, item, sibling), Restored (a prunable stale item and the live item), or
        StaleOnly (main and a prunable stale item only).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [ValidateSet('Live', 'Restored', 'StaleOnly')] [string] $Topology
    )

    $main = @('worktree /repo', 'HEAD 1111111111111111111111111111111111111111', 'branch refs/heads/main', '')
    $item = @('worktree /repo/.claude/worktrees/item', 'HEAD 2222222222222222222222222222222222222222', 'branch refs/heads/bug/item', '')
    $sibling = @('worktree /repo-wt/sibling', 'HEAD 3333333333333333333333333333333333333333', 'branch refs/heads/bug/sibling', '')
    $stale = @('worktree /host-a/repo/.claude/worktrees/item', 'HEAD 2222222222222222222222222222222222222222', 'branch refs/heads/bug/item', 'prunable gitdir file points to non-existent location', '')
    $lines = switch ($Topology) {
        'Live' { $main + $item + $sibling }
        'Restored' { $main + $stale + $item }
        'StaleOnly' { $main + $stale }
    }
    return ($lines -join "`n")
}

function Get-AgentTargetWorktreeRows {
    <#
    .SYNOPSIS
        Return the shared Resolve-AgentTargetWorktree behavior rows.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Returns a list of test rows; the plural name is the documented contract of the shared row helper.')]
    [CmdletBinding()]
    [OutputType([System.Array])]
    param()

    $item = '/repo/.claude/worktrees/item'
    $sibling = '/repo-wt/sibling'
    $stale = '/host-a/repo/.claude/worktrees/item'
    $notDerivable = 'TARGET_WORKTREE_NOT_DERIVABLE'
    $ambiguous = 'TARGET_WORKTREE_AMBIGUOUS'
    $issueLine = 'Canonical issue number for this feature is 1163.'
    $live = Get-AgentTargetWorktreePorcelain -Topology Live
    $restored = Get-AgentTargetWorktreePorcelain -Topology Restored
    $staleOnly = Get-AgentTargetWorktreePorcelain -Topology StaleOnly

    @(
        # AC-4: one row per D2 source, each with a lower-precedence source present that does not decide.
        @{ Name = 'D2 an absolute file path decides over a branch, a prompt, and a working directory'; InvokerKind = 'Porcelain'; Porcelain = $live; Arguments = @{ SessionRoot = '/repo'; FilePath = @("$item/src/a.ps1"); CommandBranch = 'bug/sibling'; DelegationPrompt = 'branch: bug/sibling'; AgentWorkingDirectory = $sibling }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'FilePath'; Unresolved = $false; StaleRegistration = @() } }
        @{ Name = 'D2 a command branch decides over a prompt and a working directory'; InvokerKind = 'Porcelain'; Porcelain = $live; Arguments = @{ SessionRoot = '/repo'; CommandBranch = 'bug/item'; DelegationPrompt = 'branch: bug/sibling'; AgentWorkingDirectory = $sibling }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'CommandOperand'; Unresolved = $false; StaleRegistration = @() } }
        @{ Name = 'D2 a branch label cross-checked with the issue line decides over a working directory'; InvokerKind = 'Porcelain'; Porcelain = $live; ReaderMap = @{ $item = '1163' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "branch: bug/item`n$issueLine"; AgentWorkingDirectory = $sibling }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'DelegationIdentity'; Unresolved = $false; StaleRegistration = @() } }
        @{ Name = 'D2 the issue line alone decides over a working directory'; InvokerKind = 'Porcelain'; Porcelain = $live; ReaderMap = @{ $item = '1163' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = $issueLine; AgentWorkingDirectory = $sibling }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'DelegationIdentity'; Unresolved = $false; StaleRegistration = @() } }
        @{ Name = 'D2 the agent working directory decides over the session root'; InvokerKind = 'Porcelain'; Porcelain = $live; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = 'resume the work'; AgentWorkingDirectory = "$item/src" }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'AgentWorkingDirectory'; Unresolved = $false; StaleRegistration = @() } }
        @{ Name = 'D2 the session root applies when no source is present'; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo' }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $null; Source = 'SessionRoot'; Unresolved = $false; StaleRegistration = @(); InvokerCalls = 0 } }

        # AC-5: the coordinator-root set.
        @{ Name = 'coordinator a branch prompt resolves the item worktree from the coordinator session root'; InvokerKind = 'Porcelain'; Porcelain = $live; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = 'branch: bug/item'; AgentWorkingDirectory = '/repo' }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'DelegationIdentity'; Unresolved = $false; StaleRegistration = @() } }
        @{ Name = 'coordinator no identity and a working directory inside the item resolve the item'; InvokerKind = 'Porcelain'; Porcelain = $live; Arguments = @{ SessionRoot = '/repo'; AgentWorkingDirectory = $item }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'AgentWorkingDirectory'; Unresolved = $false; StaleRegistration = @(); InvokerCalls = 1 } }
        @{ Name = 'coordinator no identity and a working directory equal to the session root list nothing'; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo'; AgentWorkingDirectory = '/repo/' }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $null; Source = 'SessionRoot'; Unresolved = $false; StaleRegistration = @(); InvokerCalls = 0 } }

        # AC-6: the restored-host set.
        @{ Name = 'restored a branch registered once prunable and once live resolves the live root'; InvokerKind = 'Porcelain'; Porcelain = $restored; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = 'branch: bug/item' }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'DelegationIdentity'; Unresolved = $false; StaleRegistration = @($stale) } }
        @{ Name = 'restored an issue-only prompt with a reader keyed by the new root resolves the new root'; InvokerKind = 'Porcelain'; Porcelain = $restored; ReaderMap = @{ $item = '1163'; $stale = '1163' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = $issueLine }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null; Source = 'DelegationIdentity'; Unresolved = $false; StaleRegistration = @($stale) } }

        # AC-7: prunable exclusion for branch, issue, and enclosing-root matching.
        @{ Name = 'prunable a command branch registered only at a prunable root is not derivable and names the repair'; InvokerKind = 'Porcelain'; Porcelain = $staleOnly; Arguments = @{ SessionRoot = '/repo'; CommandBranch = 'bug/item' }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $notDerivable; Source = 'CommandOperand'; Unresolved = $true; StaleRegistration = @($stale); DetailPattern = "(?s)$([regex]::Escape($stale)).*git worktree repair" } }
        @{ Name = 'prunable a prompt branch registered only at a prunable root fails closed and names the repair'; InvokerKind = 'Porcelain'; Porcelain = $staleOnly; Policy = 'FailClosedOnIdentity'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = 'branch: bug/item' }; Expected = @{ WorktreeRoot = $null; ReasonCode = $notDerivable; Source = 'DelegationIdentity'; Unresolved = $true; StaleRegistration = @($stale); DetailPattern = "(?s)$([regex]::Escape($stale)).*git worktree repair" } }
        @{ Name = 'prunable an issue recorded only by a prunable root is not derivable'; InvokerKind = 'Porcelain'; Porcelain = $staleOnly; Policy = 'FailClosedOnIdentity'; ReaderMap = @{ $stale = '1163' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = $issueLine }; Expected = @{ WorktreeRoot = $null; ReasonCode = $notDerivable; Source = 'DelegationIdentity'; Unresolved = $true; StaleRegistration = @($stale) } }
        @{ Name = 'prunable a file path under a prunable root falls back to the session root'; InvokerKind = 'Porcelain'; Porcelain = $restored; Arguments = @{ SessionRoot = '/repo'; FilePath = @("$stale/src/a.ps1") }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $null; Source = 'SessionRoot'; Unresolved = $false; StaleRegistration = @($stale) } }
        @{ Name = 'prunable a working directory under a prunable root falls back to the session root'; InvokerKind = 'Porcelain'; Porcelain = $restored; Arguments = @{ SessionRoot = '/repo'; AgentWorkingDirectory = "$stale/src" }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $null; Source = 'SessionRoot'; Unresolved = $false; StaleRegistration = @($stale) } }

        # Policies and fallbacks.
        @{ Name = 'policy SessionFallback carries the session root for an unresolved branch'; InvokerKind = 'Porcelain'; Porcelain = $live; Policy = 'SessionFallback'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = 'branch: bug/none' }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $notDerivable; Source = 'DelegationIdentity'; Unresolved = $true; StaleRegistration = @() } }
        @{ Name = 'policy FailClosedOnIdentity keeps a null root for an ambiguous prompt'; InvokerKind = 'Porcelain'; Porcelain = $live; Policy = 'FailClosedOnIdentity'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "branch: bug/item`nbranch: bug/sibling" }; Expected = @{ WorktreeRoot = $null; ReasonCode = $ambiguous; Source = 'DelegationIdentity'; Unresolved = $true; StaleRegistration = @() } }
        @{ Name = 'a working directory in no registered worktree falls back to the session root'; InvokerKind = 'Porcelain'; Porcelain = $live; Arguments = @{ SessionRoot = '/repo'; AgentWorkingDirectory = '/elsewhere/dir' }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $null; Source = 'SessionRoot'; Unresolved = $false; StaleRegistration = @() } }
        @{ Name = 'a working directory in the session worktree resolves the session root'; InvokerKind = 'Porcelain'; Porcelain = $live; Arguments = @{ SessionRoot = '/repo'; AgentWorkingDirectory = '/repo/src' }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $null; Source = 'SessionRoot'; Unresolved = $false; StaleRegistration = @() } }
        @{ Name = 'a relative working directory applies the session root without listing'; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo'; AgentWorkingDirectory = 'src' }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $null; Source = 'SessionRoot'; Unresolved = $false; StaleRegistration = @(); InvokerCalls = 0 } }
        @{ Name = 'a throwing listing for a working directory applies the session root'; InvokerKind = 'Throwing'; Arguments = @{ SessionRoot = '/repo'; AgentWorkingDirectory = $item }; Expected = @{ WorktreeRoot = '/repo'; ReasonCode = $null; Source = 'SessionRoot'; Unresolved = $false; StaleRegistration = @(); InvokerCalls = 1; DetailPattern = 'the worktree list failed: synthetic worktree list failure' } }
    )
}

function Invoke-AgentTargetWorktreeRow {
    <#
    .SYNOPSIS
        Run one shared row against whichever Resolve-AgentTargetWorktree the calling suite has loaded.
    .DESCRIPTION
        Builds the row's invoker and issue reader, calls the resolver by name, and returns the
        output with the invoker call count.
    .PARAMETER Row
        The row hashtable.
    .PARAMETER Function
        The resolver to call; Resolve-HookTargetWorktree runs a row without the Policy and
        AgentWorkingDirectory arguments.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [hashtable] $Row,
        [string] $Function = 'Resolve-AgentTargetWorktree'
    )

    $calls = @{ Made = 0 }
    $porcelain = if ($Row.ContainsKey('Porcelain')) { $Row.Porcelain } else { '' }
    $arguments = @{}
    foreach ($name in $Row.Arguments.Keys) { $arguments[$name] = $Row.Arguments[$name] }
    if ($Function -eq 'Resolve-AgentTargetWorktree' -and $Row.ContainsKey('Policy')) { $arguments['Policy'] = $Row.Policy }
    if ($Function -ne 'Resolve-AgentTargetWorktree') { $arguments.Remove('AgentWorkingDirectory') }

    $arguments['WorktreeListInvoker'] = switch ($Row.InvokerKind) {
        'Throwing' { { param($SessionRoot) [void] $SessionRoot; $calls.Made++; throw 'synthetic worktree list failure' }.GetNewClosure() }
        'FailIfCalled' { { param($SessionRoot) [void] $SessionRoot; $calls.Made++; throw 'the worktree list invoker must not be called for this row' }.GetNewClosure() }
        default { { param($SessionRoot) [void] $SessionRoot; $calls.Made++; $porcelain }.GetNewClosure() }
    }
    if ($Row.ContainsKey('ReaderMap')) {
        $readerMap = $Row.ReaderMap
        $arguments['CheckpointIssueReader'] = { param($WorktreeRoot) $readerMap[$WorktreeRoot] }.GetNewClosure()
    }

    $output = @(& $Function @arguments)
    return [pscustomobject]@{ Output = $output; InvokerCalls = $calls.Made }
}

function Assert-AgentTargetWorktreeRow {
    <#
    .SYNOPSIS
        Assert one shared row's result shape and expected values.
    .PARAMETER Row
        The row hashtable.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [hashtable] $Row
    )

    $outcome = Invoke-AgentTargetWorktreeRow -Row $Row
    $outcome.Output.Count | Should -Be 1 -Because "row '$($Row.Name)' returns one result"
    $result = $outcome.Output[0]
    (@($result.PSObject.Properties.Name) -join ',') | Should -BeExactly 'WorktreeRoot,Source,Ambiguous,ReasonCode,Detail,Candidates,Unresolved,StaleRegistration'
    $expected = $Row.Expected
    $result.WorktreeRoot | Should -Be $expected.WorktreeRoot -Because "row '$($Row.Name)' WorktreeRoot"
    $result.ReasonCode | Should -Be $expected.ReasonCode -Because "row '$($Row.Name)' ReasonCode"
    $result.Source | Should -BeExactly $expected.Source -Because "row '$($Row.Name)' Source"
    $result.Unresolved | Should -Be $expected.Unresolved -Because "row '$($Row.Name)' Unresolved"
    $result.Unresolved | Should -Be ($null -ne $expected.ReasonCode) -Because 'Unresolved is true exactly when a reason code is expected'
    (@($result.StaleRegistration) -join ',') | Should -BeExactly (@($expected.StaleRegistration) -join ',') -Because "row '$($Row.Name)' StaleRegistration"
    if ($expected.ContainsKey('InvokerCalls')) { $outcome.InvokerCalls | Should -Be $expected.InvokerCalls -Because "row '$($Row.Name)' invoker calls" }
    if ($expected.ContainsKey('DetailPattern')) { $result.Detail | Should -Match $expected.DetailPattern }
}
