# Baseline — The Six Fail-Closed-Correct Flag Call Sites (pre-edit bodies)

Timestamp: 2026-09-07T21-07
Task: [P0-T10]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: sed -n '<start>,<end>p' <file> for each of the six enclosing functions (see per-section headings)
EXIT_CODE: 0

## Purpose

These six call sites read `Test-CommandLineFlag` or `Get-CommandLineFlagValue` and treat flag
absence as **missing authorization**, which is the fail-closed direction. They are correct as they
stand and this cycle must leave every one of them byte-unchanged. This artifact records their
pre-edit bodies so `[P5-T3]` has a definite comparison basis.

Counting the bundle mirrors, which are byte-identical copies, the set is twelve files. The six
canonical sites are the ones enumerated below.

## Line-number confirmation against the plan's Scope table

Each of the six flag-read lines was read individually and matches the Scope table exactly:

| # | File | Line | Reader | Observed line |
|---|---|---|---|---|
| 1 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 164 | `Test-CommandLineFlag '--force'` | `$hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'` |
| 2 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 94 | `Test-CommandLineFlag '--force'` | identical text to #1 |
| 3 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 58 | `Test-CommandLineFlag '--force'` | same, with `$Command` in place of `$CommandText` |
| 4 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 109 | `Get-CommandLineFlagValue '--base'` | `$baseValue = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--base'` |
| 5 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 169 | `Get-CommandLineFlagValue '--merge'` | `$flagValue = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'` |
| 6 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 61 | `Get-CommandLineFlagValue '--merge'` | same, with `$Command` in place of `$CommandText` |

Zero divergence from the Scope table.

## Why absence is fail-closed at each site

| # | One-sentence reason |
|---|---|
| 1 | When `$hasForce` is `$null`/false the resolved worktree path is `$null`, so the checkpoint lookup matches no recorded `worktree_path` and the gate returns `EPIC_WORKTREE_REMOVAL_BLOCKED` rather than an allow. |
| 2 | Identical body to #1: an unread `--force` yields a `$null` path, no checkpoint record matches, and the gate denies. |
| 3 | Identical body to #1 against the Codex idiom: an unread `--force` yields a `$null` path and the Codex decision denies. |
| 4 | `$null -eq $baseValue` is the first disjunct of the guard at line 110, so an unreadable `--base` returns `EPIC_BASE_BRANCH_MISMATCH` — a deny — rather than falling through to the allow. |
| 5 | A `$null` return means no explicit PR number was resolved, and the parallel branch denies on `$null`; absence never widens the allow. |
| 6 | Identical to #5 against the Codex idiom: `$null` means no explicit PR number and the Codex readiness test denies. |

Sites 5 and 6 sit in files this plan edits. Edit 2 and Edit 3 change the **scope filter** in those
files — the Claude block at lines 392–400 and the Codex block at lines 128–134 — and do not touch
the PR-number resolver recorded here. `Get-EpicMergeGateCommandPrNumber` and
`Get-CodexMergeCommandPrNumber` must both come through this cycle byte-unchanged.

## Pre-edit function bodies

### 1. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` — `Get-EpicWorktreeRemovalCommandPath`, lines 135-175

Command: sed -n '135,175p' .claude/hooks/enforce-epic-worktree-removal-gate.ps1

```powershell
function Get-EpicWorktreeRemovalCommandPath {
    <#
    .SYNOPSIS
        Extract the target worktree path argument from a git worktree remove command.
    .DESCRIPTION
        The operand comes from the segment that structurally invokes git worktree remove,
        so a 'cd <path> &&' segment chained before the removal contributes nothing and a
        quoted mention of the phrase resolves to no operand at all. Quotes around the path
        are already stripped by the tokenizer.

        '--force' is a zero-argument flag, so it never contributes an operand and may be
        written on either side of the target path. Its presence is read structurally through
        Test-CommandLineFlag rather than by searching the raw text, so a '--force' spelling
        that appears inside an unrelated quoted argument cannot change how the operand list
        is read. When no operand resolves, a present '--force' is reported in its place, so
        the checkpoint lookup fails closed on a value that matches no recorded worktree_path
        - the same value the previous raw-text pattern returned for that input.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $CommandText
    )

    $hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'
    $operands = @(Get-CommandLineOperand -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))

    if ($operands.Count -gt 0) {
        return $operands[0]
    }
    if ($hasForce) {
        return '--force'
    }
    return $null
}

```

### 2. `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` — `Get-ParallelWorktreeRemovalCommandPath`, lines 60-105

Command: sed -n '60,105p' .claude/hooks/enforce-parallel-worktree-removal-gate.ps1

```powershell
function Get-ParallelWorktreeRemovalCommandPath {
    <#
    .SYNOPSIS
        Extract the target worktree path argument from a git worktree remove command.
    .DESCRIPTION
        The operand comes from the segment that structurally invokes git worktree remove,
        so a 'cd <path> &&' segment chained before the removal contributes nothing and a
        quoted mention of the phrase resolves to no operand at all. Quotes around the path
        are already stripped by the tokenizer.

        '--force' is a zero-argument flag, so it never contributes an operand and may be
        written on either side of the target path. Its presence is read structurally through
        Test-CommandLineFlag rather than by searching the raw text, so a '--force' spelling
        that appears inside an unrelated quoted argument cannot change how the operand list
        is read. When no operand resolves, a present '--force' is reported in its place, so
        the checkpoint lookup fails closed on a value that matches no recorded worktree_path
        - the same value the previous raw-text pattern returned for that input.

        This body is identical to Get-EpicWorktreeRemovalCommandPath in
        enforce-epic-worktree-removal-gate.ps1. The two gates fire on the same command and
        now delegate the shared concern to one parser rather than to two patterns that had
        already diverged from the Codex copy.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $CommandText
    )

    $hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'
    $operands = @(Get-CommandLineOperand -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))

    if ($operands.Count -gt 0) {
        return $operands[0]
    }
    if ($hasForce) {
        return '--force'
    }
    return $null
}

```

### 3. `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` — `Get-CodexWorktreeRemovalPath`, lines 36-69

Command: sed -n '36,69p' .codex/hooks/enforce-epic-worktree-removal-gate.ps1

```powershell
function Get-CodexWorktreeRemovalPath {
    <#
    .SYNOPSIS
        Extract the target worktree path from a git worktree remove command.
    .DESCRIPTION
        The operand comes from the segment that structurally invokes git worktree remove, so
        a chained 'cd <path> &&' segment contributes nothing and a quoted mention of the
        phrase resolves to no operand. The tokenizer strips balanced double and single
        quotes, which is what the previous pattern's `double` and `single` alternatives did.

        The previous pattern accepted '--force' only immediately after 'remove'. That
        spelling is preserved and the trailing spelling now works too, because '--force' is a
        zero-argument flag that never contributes an operand wherever it is written. Its
        presence is read structurally through Test-CommandLineFlag rather than by a raw-text
        search. The empty-string-on-miss contract is unchanged: callers test `if ($target)`.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)

    $hasForce = Test-CommandLineFlag -CommandText $Command -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'
    $operands = @(Get-CommandLineOperand -CommandText $Command -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))

    if ($operands.Count -gt 0) {
        return [string]$operands[0]
    }
    if ($hasForce) {
        return '--force'
    }
    return ''
}

```

### 4. `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` — `Test-EpicBaseBranchOverride`, lines 45-115

Command: sed -n '45,115p' .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1

```powershell
function Test-EpicBaseBranchOverride {
    <#
    .SYNOPSIS
        Sixth ordered check: enforce the epic-mode --base override for gh pr create.
    .DESCRIPTION
        Reads the per-feature checkpoint via the injectable Get-PrAuthorCheckpointContent
        seam. When the checkpoint has epic_mode == true, a gh pr create command text MUST
        contain --base <epic_context.integration_branch> with the exact branch value recorded
        in the checkpoint; a missing --base, or a --base value that does not match, is denied
        with reason EPIC_BASE_BRANCH_MISMATCH. When epic_mode is absent or false, when the
        checkpoint is unreadable, or when the command is not gh pr create (the base branch is
        set at create time, not edit time), this check is a no-op and standalone behavior is
        unchanged.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $CommandText
    )

    # The epic-mode base-branch override only constrains gh pr create; gh pr edit does not
    # re-target the base branch, so non-create commands are out of scope for this check.
    # The test is structural, so a quoted mention of the phrase is out of scope and a
    # relocating spelling carrying a gh global option is in scope (issue #545).
    if (-not (Test-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create'))) {
        return $null
    }

    $checkpointRaw = Get-PrAuthorCheckpointContent
    if ([string]::IsNullOrWhiteSpace($checkpointRaw)) {
        return $null
    }

    try {
        $checkpoint = $checkpointRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        return $null
    }

    $checkpointProps = @($checkpoint.PSObject.Properties.Name)
    if ($checkpointProps -notcontains 'epic_mode' -or -not [bool]$checkpoint.epic_mode) {
        return $null
    }

    $integrationBranch = $null
    if ($checkpointProps -contains 'epic_context' -and $null -ne $checkpoint.epic_context) {
        $epicContextProps = @($checkpoint.epic_context.PSObject.Properties.Name)
        if ($epicContextProps -contains 'integration_branch') {
            $integrationBranch = [string]$checkpoint.epic_context.integration_branch
        }
    }

    if ([string]::IsNullOrWhiteSpace($integrationBranch)) {
        return "EPIC_BASE_BRANCH_MISMATCH: checkpoint has epic_mode == true but no ``epic_context.integration_branch`` is recorded; ``gh pr create`` cannot be verified against the required ``--base`` value."
    }

    # The --base value is taken from the matched segment's tokens, so a chained segment that
    # happens to carry a --base token contributes nothing here. The comparison stays
    # case-sensitive, as the previous -cnotmatch form was, because a branch name is.
    $baseValue = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--base'
    if ($null -eq $baseValue -or $baseValue -cne $integrationBranch) {
        return "EPIC_BASE_BRANCH_MISMATCH: ``gh pr create`` must pass ``--base $integrationBranch`` (``epic_context.integration_branch``) under ``epic_mode``; the command does not carry a matching ``--base`` argument."
    }

    return $null
}
```

### 5. `.claude/hooks/enforce-epic-merge-gate.ps1` — `Get-EpicMergeGateCommandPrNumber`, lines 131-176

Command: sed -n '131,176p' .claude/hooks/enforce-epic-merge-gate.ps1

```powershell
function Get-EpicMergeGateCommandPrNumber {
    <#
    .SYNOPSIS
        Extract an explicit PR number argument from a gh pr merge command, or $null.
    .DESCRIPTION
        Both spellings are read from the segment that structurally invokes gh pr merge,
        never from the whole command line. The positional form ("gh pr merge 410 --merge")
        resolves through Get-CommandLineOperand and takes the first all-digit operand; the
        flag-led forms ("gh pr merge --merge 410" and "gh pr merge --merge=410") resolve
        through Get-CommandLineFlagValue. A bare "gh pr merge --merge" yields $null, which
        the parallel branch treats as fail-closed.

        The deleted unanchored branch scanned the WHOLE command text for the first run of
        digits once "gh pr merge" appeared anywhere in it, and that failed in both
        directions. Fail-closed: a leading "cd <path>" whose path carries a timestamp
        component supplied a digit run that was not a pull request number, so an authorized
        merge was blocked. False-allow: with authorized item 501 and unauthorized item 777,
        "cd /repo/worktrees/501 && gh pr merge --merge 777" extracted 501, matched the
        authorized item, and permitted the merge of PR 777. Taking the number from the
        matched segment's own operand or flag value closes both directions.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .OUTPUTS
        System.Nullable[int]
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)]
        [string] $CommandText
    )

    foreach ($operand in @(Get-CommandLineOperand -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))) {
        if ($operand -match '^\d+$') {
            return [int]$operand
        }
    }

    $flagValue = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'
    if ($null -ne $flagValue -and $flagValue -match '^\d+$') {
        return [int]$flagValue
    }

    return $null
}

```

### 6. `.codex/hooks/enforce-epic-merge-gate.ps1` — `Get-CodexMergeCommandPrNumber`, lines 34-68

Command: sed -n '34,68p' .codex/hooks/enforce-epic-merge-gate.ps1

```powershell
function Get-CodexMergeCommandPrNumber {
    <#
    .SYNOPSIS
        Resolve the explicit pull-request number of a gh pr merge invocation, or $null.
    .DESCRIPTION
        The number is taken from the segment that structurally invokes `gh pr merge` and
        from nowhere else: the positional spelling through Get-CommandLineOperand, the
        flag-led and equals-joined spellings through Get-CommandLineFlagValue. A leading
        `cd <path>` segment contributes no operand and no flag value, so no digit run
        outside the merge segment can be mistaken for a pull-request number.

        This copy has never carried the Claude copy's unanchored whole-text digit scan and
        deliberately does not acquire one. No regular expression matching a bare digit run
        is introduced here; the only pattern below anchors an all-digit token end to end.
    .OUTPUTS
        System.Nullable[int]
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][string] $Command)

    foreach ($operand in @(Get-CommandLineOperand -CommandText $Command -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))) {
        if ($operand -match '^\d+$') {
            return [int]$operand
        }
    }

    $flagValue = Get-CommandLineFlagValue -CommandText $Command -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'
    if ($null -ne $flagValue -and $flagValue -match '^\d+$') {
        return [int]$flagValue
    }

    return $null
}

```

## Output Summary

All six pre-edit function bodies are reproduced above, one section each, together with the
one-sentence fail-closed rationale for each. The six file paths and line numbers were read
individually and match the plan's Scope table exactly, with zero divergence. Sites 5 and 6 live in
files this cycle edits, but the edits target the scope filter rather than these PR-number resolvers,
so all six must be byte-unchanged when `[P5-T3]` re-verifies them.
