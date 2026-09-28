# Batch A — Toolchain Gate ([P1-T7])

Timestamp: 2026-09-07T19-47
Task: [P1-T7]

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context; the runtime guard refuses them. Format, lint, and Pester are invoked through the MCP
functions `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and
`mcp__drm-copilot__run_poshqc_test`, with per-suite and per-case results read from
`artifacts/pester/pester-junit.xml`. Route substitution; no stage was skipped. PowerShell has no
type-check stage, so the order is format, lint, test.

**Restart record: NO RESTART OCCURRED. All three stages passed in a single pass.**

---

## Stage 1 — Format

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31`, no `scan_folders`
EXIT_CODE: 0
Result value: `ok: true`

The exit code alone gates nothing here, because this formatter exits 0 whether or not it rewrote a
file. The acceptance is the tree observation below.

### `git status --porcelain` immediately before stage 1

```
 M .claude/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
 M tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-budget-reset.2026-09-07T19-38.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-pair-parity.2026-09-07T19-43.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-claude.2026-09-07T19-41.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-claude.2026-09-07T19-44.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
```

Before-set path count: **9**

### `git status --porcelain` immediately after stage 1

Byte-identical to the capture above. After-set path count: **9**.

**Set-difference count (paths present after and absent before): 0.**

### SHA-256 before and after stage 1

| File | Before | After | Changed |
|---|---|---|---|
| `.claude/hooks/validate-bash.ps1` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` | `6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78` | no |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `c453b877f32dc07ff18a6c3f18f6793aeadd93fb4af2e9dcae6ba3647ce8aecf` | `c453b877f32dc07ff18a6c3f18f6793aeadd93fb4af2e9dcae6ba3647ce8aecf` | no |

Neither file was rewritten, so `[P1-T5]` did not need re-running and this task did not restart. The
`[P1-T5]` mirror therefore remains valid: the bundle copy still matches the canonical copy at
`6dfcadff76c36737fce9490917d757cd54fed56f8c0e0493ada67684eab0ff78`.

---

## Stage 2 — Lint

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = worktree root, no `scan_folders`
EXIT_CODE: 0
Literal result value recorded: **`ok: true`**, equal to the `[P0-T5]` baseline value.

This tool reports no diagnostic count, so `ok: true` is the only value asserted.

---

## Stage 3 — Test

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-hooks"]`, then read `artifacts/pester/pester-junit.xml`
EXIT_CODE: 1
ExpectedExitCode: 1 (the folder-wide failed-test count, which is the single tolerated ambient failure)

Every condition of `[P1-T6]` is reproduced by this run:

| `[P1-T6]` condition | Observed | Result |
|---|---|---|
| (a) `validate-bash.TriggerScoping.Tests.ps1` tests 12, failures 0, errors 0 | `tests="12" errors="0" failures="0"` | PASS |
| (a) `R1-C1`..`R1-C5` all `status="Passed"` | 5 of 5 carry `status="Passed"` | PASS |
| (b) `validate-bash.Tests.ps1` tests 26, failures 0 | `tests="26" errors="0" failures="0"` | PASS |
| (b) case `returns the matched pattern for every repository-dangerous command` passed | `status="Passed"` | PASS |
| (c) AT-8, AT-9, AT-10 passed | suite `failures="0"`, so all three passed | PASS |
| (d) only folder failure is tolerated row 1 | only `enforce-pr-author-skill.Tests.ps1` case `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | PASS |

---

## Inline acceptance conditions carried from `[P1-T2]` and `[P1-T4]`

These two tasks deliberately name no artifact path; their `grep` and `wc -l` conditions are recorded
here.

`[P1-T2]` — `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`:

| Command | Expected | Observed | Result |
|---|---|---|---|
| `grep -F -c "        It 'R1-C" <file>` | 5 | 5 | PASS |
| `grep -F -c "        It '" <file>` | 12 | 12 | PASS |
| `wc -l <file>` | at or under 500 | 118 | PASS |

The count of 12 is the 7 pre-existing blocks plus the 5 appended, so the five blocks were appended
rather than substituted for existing ones.

`[P1-T4]` — `.claude/hooks/validate-bash.ps1`:

| Command | Expected | Observed | Result |
|---|---|---|---|
| `grep -F -c "IsWrapperLed" <file>` | 1 | 1 | PASS |
| `grep -F -c "segment.Unbalanced" <file>` | 1 | 1 | PASS |
| `grep -F -c "StringComparison]::Ordinal" <file>` | 1 | 1 | PASS |
| `grep -F -c "'rm -rf'," <file>` | 1 | 1 | PASS |
| `grep -F -c "CdChainedReadCommandPattern = " <file>` | 1 | 1 | PASS |
| `wc -l <file>` | at or under 500 | 420 | PASS |

The `[P0-T8]` baseline for this file was 402 lines. The R-1 edit added 18: a 13-line `.DESCRIPTION`
paragraph plus its blank separator, and the 4-line second `if` in the leg-1 inner loop. The three
new tokens each occur exactly once, because none of them is spelled in the inserted `.DESCRIPTION`
paragraph. The first denylist literal's declaration line and the `$script:CdChainedReadCommandPattern`
declaration line both survive byte-unchanged.

---

## Live reproduction of the amended hook denying the executor's own command

Recorded as signal rather than suppressed. After `[P1-T4]` the amended hook is live for this
executor's own `Bash` calls. One executor command was denied by it:

```
F="<path>"; echo "rmrf=$(grep -F -c "'rm -rf'," "$F")"; ...
```

Result: `Blocked dangerous command pattern detected: 'rm -rf'`.

Cause, and why it is correct behaviour rather than a defect: that command line carries a `$( ... )`
command substitution, so `HasLiveSubstitution` is `$true` on the segment, the scanner selects
`RawText` as `ScanText`, and the new second condition finds the literal `rm -rf` in the raw text.
This is exactly the second disjunct of the R-1 fix operating as designed. The plan's traced
predictions remain accurate: the `[P3-T2]` pipeline form and the `[P1-T1]` `rm -f` reset were not
denied, because their denylist-bearing segment has command word `grep`, is balanced, is not
wrapper-led, and carries no live substitution. The denial above was caused by the executor's own use
of command substitution, not by the plan's command forms. The command was reformulated without
command substitution and the same `grep -F -c` count was obtained.

---

Output Summary: Batch A toolchain gate passed in a single pass with no restart. Stage 1 format
EXIT_CODE 0 with porcelain set-difference 0 and both in-scope SHA-256 values unchanged; stage 2
analyze EXIT_CODE 0 with `ok: true`; stage 3 test reproduces every `[P1-T6]` condition —
`validate-bash.TriggerScoping.Tests.ps1` 12/0/0 with all five R1-C cases passing,
`validate-bash.Tests.ps1` 26/0 with the leg-ordering case passing, and the single tolerated ambient
failure as the only folder failure. All inline `[P1-T2]` and `[P1-T4]` counts verified.
