# Codex merge gate — non-acquisition of the whole-line digit scan (issue #545)

Timestamp: 2026-09-07T14-59

Task: [P9-T9]. Acceptance criterion AC-34.

Command: `sed -n '34,68p' .codex/hooks/enforce-epic-merge-gate.ps1` for the function body below, and
`git -C <worktree> diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .codex/hooks/enforce-epic-merge-gate.ps1`
filtered to added and removed lines containing `-match`, for the regex accounting.

EXIT_CODE: 0

This check is recorded as a **reviewed reading of the post-change source**, not as a bare exit code.
The exit code above belongs to the two commands that produced the text; it is not the finding. The
finding is the reading set out below.

## Post-change body of the Codex copy's PR-number resolution function, in full

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

## The reading

PR-number resolution in this function goes through `Get-CommandLineOperand` and
`Get-CommandLineFlagValue` **only**. There is no third source. Specifically:

1. The positional spelling (`gh pr merge 410 --merge`) resolves through `Get-CommandLineOperand`,
   which returns the non-option tokens following the subcommand path **in the matched segment only**.
2. The flag-led and equals-joined spellings (`gh pr merge --merge 688`, `gh pr merge --merge=410`)
   resolve through `Get-CommandLineFlagValue`, which searches the **matched segment's** tokens.
3. When neither yields an all-digit token the function returns `$null`, which the epic branch treats
   as "the command names no explicit PR number".

Neither retrieval function is given the raw command line as a search space. Both are given the
command word and the subcommand path and locate the invocation structurally, so a `cd <path>` segment
chained before the invocation contributes nothing to either result.

## Regex accounting for the whole file

Complete inventory of `-match` sites in the post-change `.codex/hooks/enforce-epic-merge-gate.ps1`:

| Line | Pattern | What it is applied to | Is it a bare-digit scan? |
| --- | --- | --- | --- |
| 56 | `'^\d+$'` | one already-extracted operand token | **no** — anchored `^`…`$`, so it validates that a single token is entirely digits |
| 62 | `'^\d+$'` | one already-extracted flag value | **no** — same anchored validator |

Both patterns are anchored end to end and are applied to a **single token that the parser already
isolated**, never to a command line. An anchored whole-token validator cannot scan: it has no
capability to find a digit run at an arbitrary offset in a longer string, because `^` and `$` bind it
to the whole subject.

Diff accounting against `origin/epic/cleanup-merged-worktrees-hardening-integration`:

- Added lines containing `-match`: exactly the two anchored validators above.
- Removed lines containing `-match`: one, `if ($Command -match '(?i)\bgh\s+pr\s+merge\s+(\d+)\b') {`
  — the copy's own anchored positional pattern, replaced by the structural resolver.

**No unanchored whole-text digit scan was added.** The Claude copy's pre-change line-154 branch,
`$CommandText -match '(?<![-\w])(\d+)\b'`, has no counterpart anywhere in this file before or after
the change. It was never present in the Codex copy, and this change did not introduce it. The Codex
copy therefore did not acquire the Claude copy's defect while both were moved onto the shared parser,
which is what AC-34 requires.

## Corroborating executed observation

`tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` reports **5 tests, 0
failures**, including `resolves 688 for a cd-prefixed gh pr merge whose PR number follows the merge
flag`. That case would fail if the resolver read the `cd` operand: the path
`C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11` contains the digit run `2026`.

## File-size and parity state

| File | Lines | At or under 500? | SHA-256 |
| --- | --- | --- | --- |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | yes | `11169c09014b1b9165cba04bf4e2a335d467205d6928f4aa2cd98141dc71e4f4` |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | yes | `11169c09014b1b9165cba04bf4e2a335d467205d6928f4aa2cd98141dc71e4f4` |

Output Summary: reviewed reading recorded. The Codex merge gate's post-change PR-number resolution
goes through `Get-CommandLineOperand` and `Get-CommandLineFlagValue` only. The file's complete
`-match` inventory is two occurrences of the anchored whole-token validator `'^\d+$'`, each applied to
a single token the parser already isolated; the diff adds no unanchored pattern and removes the one
anchored positional pattern the copy previously carried. **The Codex merge gate acquired no bare-digit
scan.** The Codex trigger-scoping suite corroborates by execution at 5 tests / 0 failures, and both
Codex copies hash equal at 174 lines.
