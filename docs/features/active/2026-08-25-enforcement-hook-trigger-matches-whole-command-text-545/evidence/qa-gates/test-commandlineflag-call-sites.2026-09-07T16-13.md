# [P12-T15] `Test-CommandLineFlag` presence-only call sites

Timestamp: 2026-09-07T16-13

Command:

```
grep -n 'Test-CommandLineFlag' .claude/hooks/enforce-epic-merge-gate.ps1
grep -n 'Test-CommandLineFlag' .claude/hooks/enforce-pr-author-skill-helpers.ps1
grep -n 'Test-CommandLineFlag' .claude/hooks/enforce-epic-worktree-removal-gate.ps1
grep -n 'Test-CommandLineFlag' .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
grep -n '^function ' <each of the four files>          # to resolve the enclosing function
```

followed by a byte-level read of each identified line from the on-disk post-change file, with
newline translation disabled, to confirm it is a single physical line carrying its `-FlagName`
argument.

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: not applicable in the toolchain sense — this task reads files and runs no
PowerShell stage. The single-physical-line verification is performed in Python because `pwsh` is not
invocable in this session; it opens each file with `newline=""` so no line-ending translation occurs,
splits on the normalized newline, and inspects the identified line directly.

## Output Summary

**Four call lines across three flags**, all quoted verbatim below from the on-disk post-change files.
**No row is pending.** Every line was confirmed to be a single physical line that carries its
`-FlagName` argument on that same line: none ends in a backtick continuation, and none is continued
into from the preceding line.

| # | File | Function | Flag | Line | Single physical line | `-FlagName` on the same line |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-epic-merge-gate.ps1` | `Invoke-EpicMergeGateDecision` (scope filter) | `--merge` | 397 | yes | yes |
| 2 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `Get-PrAuthorBypassReason` | `--body` | 190 | yes | yes |
| 3 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `Get-EpicWorktreeRemovalCommandPath` | `--force` | 164 | yes | yes |
| 4 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `Get-ParallelWorktreeRemovalCommandPath` | `--force` | 94 | yes | yes |

Three distinct flags are served — `--merge`, `--body`, and `--force` — across four call lines, because
`--force` is used by the two worktree-removal gates in their corresponding path-resolution functions.

## Row 1 — `.claude/hooks/enforce-epic-merge-gate.ps1`, scope filter, `--merge`

- **File:** `.claude/hooks/enforce-epic-merge-gate.ps1`
- **Function:** `Invoke-EpicMergeGateDecision`, declared at line 357
- **Flag:** `--merge`
- **Call line:** 397

Quoted verbatim from the on-disk post-change file:

```powershell
    $hasMergeFlag = Test-CommandLineFlag -CommandText $commandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'
```

Context. The line sits immediately after the structural invocation test and immediately before the
scope short-circuit, so the two together are the gate's scope filter:

```powershell
    $isMergeInvocation = Test-CommandLineInvocation -CommandText $commandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge')
    $hasMergeFlag = Test-CommandLineFlag -CommandText $commandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'
    if (-not $isMergeInvocation -or -not $hasMergeFlag) {
        return Get-EpicMergeGateAllowDecision
    }
```

This is a presence-only use: the return value is consumed as a boolean and no flag value is read.
Reading the flag value here would be wrong, because `--merge` takes no value.

## Row 2 — `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `--body`

- **File:** `.claude/hooks/enforce-pr-author-skill-helpers.ps1`
- **Function:** `Get-PrAuthorBypassReason`, declared at line 144
- **Flag:** `--body`
- **Call line:** 190

Quoted verbatim from the on-disk post-change file:

```powershell
    $hasInlineBody = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--body'
```

Context. The line is preceded by its `--body-file` sibling at line 189, and the pair is the
distinction the hook exists to draw:

```powershell
    $hasBodyFile = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--body-file'
    $hasInlineBody = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'gh' -SubcommandPath $subcommandPath -FlagName '--body'
```

Exact token comparison is what keeps `--body` from matching `--body-file`; the pre-change code
expressed the same distinction with a negative lookahead over raw text. The named case
`does not match --body against a --body-file token` in
`tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` pins this and reports
Passed.

This is a presence-only use: `$hasInlineBody` is consumed as a boolean in the Case A conditional and
the body value itself is never read from this call.

## Row 3 — `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `--force`

- **File:** `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
- **Function:** `Get-EpicWorktreeRemovalCommandPath`, declared at line 135
- **Flag:** `--force`
- **Call line:** 164

Quoted verbatim from the on-disk post-change file:

```powershell
    $hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'
```

Context. The line is the first statement after the parameter block, and its result is consumed only
after the operand list is found to be empty:

```powershell
    $hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'
    $operands = @(Get-CommandLineOperand -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))

    if ($operands.Count -gt 0) {
        return $operands[0]
    }
    if ($hasForce) {
        return '--force'
    }
```

This is a presence-only use: `--force` takes no value, and the operand path comes from
`Get-CommandLineOperand` rather than from the flag. The function's docstring at line 147 records the
reason the structural test replaced a raw-text search. Acceptance case AT-7 pins the behaviour this
enables — that the worktree path resolves whether `--force` precedes or follows it — and the named
cases `resolves the operand when --force precedes the path` and
`resolves the same operand when --force follows the path` both report Passed.

## Row 4 — `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `--force`

- **File:** `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
- **Function:** `Get-ParallelWorktreeRemovalCommandPath`, declared at line 60 — the function
  corresponding to `Get-EpicWorktreeRemovalCommandPath` in row 3
- **Flag:** `--force`
- **Call line:** 94

Quoted verbatim from the on-disk post-change file:

```powershell
    $hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'
```

Context, structurally identical to row 3:

```powershell
    $hasForce = Test-CommandLineFlag -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force'
    $operands = @(Get-CommandLineOperand -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))

    if ($operands.Count -gt 0) {
        return $operands[0]
    }
    if ($hasForce) {
```

The two worktree-removal gates carry byte-identical call lines because AT-7 requires both functions
to resolve the same operand from the same command text. The named case
`resolves the operand when --force precedes the path` in
`tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` reports
Passed, as does the acceptance case
`AT-7 resolves the worktree path when the force flag precedes it, in both removal gates`.

## Single-physical-line verification, per row

Recorded because a backtick-continued call would allow a quotation of the first physical line to omit
the `-FlagName` argument entirely, which would make this artifact's quotations unfalsifiable. The
call lines were joined onto single physical lines by an earlier task specifically to prevent that.

| # | File | Line | Ends in a backtick continuation | Preceding line ends in a backtick | Contains `Test-CommandLineFlag` | Contains `-FlagName` | Contains the exact `-FlagName '<flag>'` argument |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `enforce-epic-merge-gate.ps1` | 397 | no | no | yes | yes | yes, `-FlagName '--merge'` |
| 2 | `enforce-pr-author-skill-helpers.ps1` | 190 | no | no | yes | yes | yes, `-FlagName '--body'` |
| 3 | `enforce-epic-worktree-removal-gate.ps1` | 164 | no | no | yes | yes | yes, `-FlagName '--force'` |
| 4 | `enforce-parallel-worktree-removal-gate.ps1` | 94 | no | no | yes | yes | yes, `-FlagName '--force'` |

Each of the four quotations above is therefore the complete call, not a fragment of one.

## Why a presence-only predicate is required

`Get-CommandLineFlagValue` cannot serve any of these four sites. `--merge`, `--body`, and `--force`
are valueless flags: a value-reading helper returns `$null` for a present valueless flag, which is
indistinguishable from the absent case. The specification records this as the reason
`Test-CommandLineFlag` exists as a separate D12 member, and the named parser cases pin the two
properties that make it usable here — that it distinguishes an absent flag from a valueless present
flag, and that `--body` does not match `--body-file`.
