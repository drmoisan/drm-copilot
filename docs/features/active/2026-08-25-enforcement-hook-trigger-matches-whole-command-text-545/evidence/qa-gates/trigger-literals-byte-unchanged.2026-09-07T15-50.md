# [P12-T3] Trigger literals — byte-unchanged inspection

Timestamp: 2026-09-07T15-50

Command:

```
git show origin/epic/cleanup-merged-worktrees-hardening-integration:<path>   # before text, per file
```

compared against the on-disk after text of the same `<path>`, for each of the 14 files named below.

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: the before-and-after comparison is performed by a Python script rather than a
PowerShell one-liner, because `pwsh` is not invocable in this session. The script reads the before
text from `git show <base>:<path>` and the after text from the on-disk file, and compares exact
strings; it introduces no normalization, no whitespace folding, and no case folding. The comparison
is therefore a byte comparison of decoded UTF-8 text.

Source enumeration: `evidence/qa-gates/scope-and-size.2026-09-07T15-46.md` ([P12-T1]). Base ref:
`origin/epic/cleanup-merged-worktrees-hardening-integration` at `288ca2148d159bf2f7a1cbfff6bad3ee5c8d791b`.

## Output Summary

Every trigger literal named by the task is quoted below with its before text and its after text.
**All of them are identical before and after, with one recorded exception**: the pr-author hook's two
`gh pr create` / `gh pr edit` **regex expressions** do not survive the change, because plan task
[P7-T1] directs that the `$isPrCreate` and `$isPrEdit` decisions be evaluated through
`Test-CommandLineInvocation` instead. [P7-T1] scopes the byte-unchanged obligation for that hook to
those expressions "wherever they remain in the file". Every surviving occurrence of the phrases
`gh pr create` and `gh pr edit` in that file is byte-unchanged; the count is 11 and 8 respectively,
before and after, and 12 of the 13 phrase-bearing lines are byte-identical, the thirteenth being a
comment line extended additively. The exception is stated in full in section 4 below and is carried
into this execution's completion report rather than resolved here.

| Literal group | Copies checked | Byte-identical |
| --- | --- | --- |
| Preimplementation gate: the five trigger pattern strings | 4 | **4 of 4** |
| Promotion hook: the four forbidden-token literals | 4 | **4 of 4** |
| Promotion hook: the `gh issue create`/`new` expression string | 4 | **4 of 4** |
| Promotion hook: the `gh api ... issues` POST expression (whole declaration line) | 4 | **4 of 4** |
| pr-author hook: the `gh pr create` / `gh pr edit` regex expression strings | 2 | **0 of 2 — removed, see section 4** |
| pr-author hook: every surviving `gh pr create` / `gh pr edit` phrase occurrence | 2 | **2 of 2** |
| `validate-bash.ps1`: the six denylist literals | 4 | **4 of 4** |
| `validate-bash.ps1`: `$script:CdChainedReadCommandPattern` (whole declaration line) | 2 | **2 of 2** |
| `enforce-parallel-abandon-gate.ps1`: the two token constants | 2 | **2 of 2** |

## 1. Preimplementation gate — the five trigger pattern strings

Before and after text of the whole `$implementationCommandPatterns` array, **identical**:

```powershell
    $implementationCommandPatterns = @(
        '(^|\s)git\s+(add|commit)\b',
        '(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b',
        '(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b',
        '(^|\s)npx\s+(prettier|eslint|tsc|jest)\b',
        '(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)'
    )
```

Verified identical, before against after, in all four copies:

| Copy | Path | Result |
| --- | --- | --- |
| Claude canonical | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | identical |
| Codex canonical | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | identical |
| Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | identical |
| Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | identical |

Only the text these patterns are evaluated against changed: the after code evaluates them against
`(Read-CommandLineSegment -CommandText $normalizedCommand).ScanText` rather than against the raw
command text. That is rule R2 as the specification states it — the literal text is governed, the
operand is not.

## 2. Promotion hook — four forbidden-token literals and two `gh` expressions

### The four forbidden-token literals

Before and after text of the whole `$forbiddenTokens` array, **identical**:

```powershell
    $forbiddenTokens = @(
        'new-potential-entry.ps1',
        'new_potential_bug_entry',
        'potential_to_issue',
        'new_active_feature_folder'
    )
```

Verified identical in all four copies: `.claude/hooks/enforce-promotion-mcp-only.ps1`,
`.codex/hooks/enforce-promotion-mcp-only.ps1`, and both bundle mirrors.

### `gh` expression 1 of 2 — the `gh issue create` / `gh issue new` pattern

The literal string is **identical** before and after, in all four copies:

```
'(?i)\bgh\s+issue\s+(?:create|new)\b'
```

The line that carries it changed in its operand and its indentation only, which R2 permits
explicitly. Recorded verbatim so the distinction is auditable:

- Before: `    if ($CommandText -match '(?i)\bgh\s+issue\s+(?:create|new)\b') {`
- After: `        if ($segment.ScanText -match '(?i)\bgh\s+issue\s+(?:create|new)\b') {`

The pattern text between the two single quotes is character-for-character the same. The change is
that the pattern is now evaluated per segment against that segment's `ScanText`, inside a `foreach`
loop, which is why the indentation is four spaces deeper.

### `gh` expression 2 of 2 — the `gh api ... issues` POST pattern

The **whole declaration line** is identical before and after, in all four copies:

```powershell
    $ghApiIssuesPostPattern = '(?i)(?=.*\bgh\s+api\b)(?=.*repos/[^/\s]+/[^/\s]+/issues(?:\b|/[^/\s]*$))(?=.*(?:-X\s+POST|--method\s+POST))'
```

## 3. `validate-bash.ps1` — the six denylist literals

Before and after text of the whole `Get-BlockedBashPattern` return array, **identical**:

```powershell
    return [string[]]@(
        'rm -rf',
        'git push --force',
        'git push origin --force',
        'Remove-Item -Recurse -Force',
        'git reset --hard',
        'git push -f'
    )
```

Verified identical in all four copies: `.claude/hooks/validate-bash.ps1`,
`.codex/hooks/validate-bash.ps1`, and both bundle mirrors.

A naive whole-file substring count reports the strings `git push --force` and `git push -f` twice in
the after text where the before text has them once. That second occurrence is **not** a second
declaration and does not weaken the finding. It is the return value of the flag-conjoined structural
`git` leg added by [P10-T3] part (b), at lines 124 and 125 of the after file:

```powershell
        if ($Token -contains '--force') { return 'git push --force' }
        if ($Token -contains '-f') { return 'git push -f' }
```

That leg returns the same literal text so the hook's reported match value is unchanged for callers.
The declaration block quoted above is the subject of the byte-unchanged obligation, and it is
identical.

### `$script:CdChainedReadCommandPattern`

Retained unmodified as a declared constant. The whole declaration line is identical before and after,
in the Claude canonical copy and its bundle mirror:

```powershell
$script:CdChainedReadCommandPattern = 'cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b'
```

## 4. pr-author hook — the `gh pr create` and `gh pr edit` expressions

This is the one group whose before-and-after text is **not** identical, and the divergence is
directed by the plan rather than incidental.

### What changed

Plan task [P7-T1] directs that the `$isPrCreate` and `$isPrEdit` decisions at base lines 170 and 171
"evaluate through `Test-CommandLineInvocation -CommandWord 'gh'` with subcommand paths
`@('pr','create')` and `@('pr','edit')`". Executing that direction removes the two regex expression
strings, because the structural matcher takes no pattern operand. Recorded verbatim in both Claude
copies:

| | Before | After |
| --- | --- | --- |
| `$isPrCreate` | `    $isPrCreate = $CommandText -match '(?i)\bgh\s+pr\s+create\b'` | `    $isPrCreate = Test-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create')` |
| `$isPrEdit` | `    $isPrEdit = $CommandText -match '(?i)\bgh\s+pr\s+edit\b'` | `    $isPrEdit = Test-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'edit')` |

Occurrence counts of the two regex expression strings, before and after:

| Expression string | Path | Before | After |
| --- | --- | --- | --- |
| `'(?i)\bgh\s+pr\s+create\b'` | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 1 | **0** |
| `'(?i)\bgh\s+pr\s+create\b'` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 1 | **0** |
| `'(?i)\bgh\s+pr\s+edit\b'` | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 1 | **0** |
| `'(?i)\bgh\s+pr\s+edit\b'` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 1 | **0** |

### What is byte-unchanged

[P7-T1] scopes the obligation to the expressions "wherever they remain in the file". Measured against
that scope, the result is byte-unchanged:

| Phrase | Path | Occurrences before | Occurrences after |
| --- | --- | --- | --- |
| `gh pr create` | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 11 | **11** |
| `gh pr edit` | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 8 | **8** |
| `gh pr create` | `extensions/.../claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 11 | **11** |
| `gh pr edit` | `extensions/.../claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 8 | **8** |

13 lines in each file carry one or both phrases. 12 of the 13 are byte-identical before and after.
The thirteenth is a comment line extended additively; its original text is preserved as its leading
portion:

- Before: `    # Only act on gh pr create or gh pr edit subcommands.`
- After: `    # Only act on gh pr create or gh pr edit subcommands. The test is structural: a segment`

Every `PR_*` reason-code string carrying either phrase is among the 12 byte-identical lines.

### Recorded divergence between the specification and the plan

Specification acceptance criterion AC-07 states that "the pr-author hook's `gh pr create` /
`gh pr edit` expressions are likewise byte-unchanged". Plan task [P7-T1] states that they "stay
byte-unchanged wherever they remain in the file", and directs the replacement that removes them. The
delivered state satisfies [P7-T1] and does not satisfy the unqualified reading of AC-07.

This artifact records the observation and does not resolve it. The two readings cannot both be
satisfied, because the structural matcher [P7-T1] mandates takes no regex operand. The discrepancy is
carried into the execution completion report for the orchestrator.

## 5. `enforce-parallel-abandon-gate.ps1` — the two token constants

Both whole declaration lines are identical before and after, in the Claude canonical copy and its
bundle mirror. Quoted from the after file:

```powershell
$script:AbandonDispositionToken = '--disposition abandon'
$script:AbandonConfirmToken = '--confirm-abandon'
```

Both remain in their single-assignment form, which
`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses at run time and would fail on if
the shape changed.

## Complete result table

| # | Literal group | Path | Before == After |
| --- | --- | --- | --- |
| 1 | 5 preimplementation patterns | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | yes |
| 2 | 5 preimplementation patterns | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | yes |
| 3 | 5 preimplementation patterns | Claude bundle mirror | yes |
| 4 | 5 preimplementation patterns | Codex bundle mirror | yes |
| 5 | 4 forbidden-token literals | `.claude/hooks/enforce-promotion-mcp-only.ps1` | yes |
| 6 | 4 forbidden-token literals | `.codex/hooks/enforce-promotion-mcp-only.ps1` | yes |
| 7 | 4 forbidden-token literals | Claude bundle mirror | yes |
| 8 | 4 forbidden-token literals | Codex bundle mirror | yes |
| 9 | `gh issue create/new` expression string | all four promotion copies | yes |
| 10 | `gh api ... issues` POST declaration line | all four promotion copies | yes |
| 11 | 6 denylist literals | `.claude/hooks/validate-bash.ps1` | yes |
| 12 | 6 denylist literals | `.codex/hooks/validate-bash.ps1` | yes |
| 13 | 6 denylist literals | Claude bundle mirror | yes |
| 14 | 6 denylist literals | Codex bundle mirror | yes |
| 15 | `$script:CdChainedReadCommandPattern` | `.claude/hooks/validate-bash.ps1` and its mirror | yes |
| 16 | 2 abandon token constants | `.claude/hooks/enforce-parallel-abandon-gate.ps1` and its mirror | yes |
| 17 | surviving `gh pr create`/`gh pr edit` phrase occurrences | both pr-author copies | yes |
| 18 | `gh pr create`/`gh pr edit` **regex expression strings** | both pr-author copies | **no — removed by [P7-T1]; see section 4** |
