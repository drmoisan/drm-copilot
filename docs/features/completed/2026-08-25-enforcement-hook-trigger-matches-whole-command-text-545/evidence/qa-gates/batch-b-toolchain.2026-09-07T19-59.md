# Batch B — Toolchain Gate ([P2-T7])

Timestamp: 2026-09-07T19-59
Task: [P2-T7]

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context. Format, lint, and Pester are invoked through the MCP functions
`mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and
`mcp__drm-copilot__run_poshqc_test`, with per-suite and per-case results read from
`artifacts/pester/pester-junit.xml`. Route substitution; no stage was skipped. PowerShell has no
type-check stage, so the order is format, lint, test.

**Restart record: NO RESTART OCCURRED. All three stages passed in a single pass.**

---

## Stage 1 — Format

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31`, no `scan_folders`
EXIT_CODE: 0
Result value: `ok: true`

The exit code alone gates nothing, because this formatter exits 0 whether or not it rewrote a file.

### SHA-256 before and after stage 1

| File | Before | After | Changed |
|---|---|---|---|
| `.codex/hooks/validate-bash.ps1` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` | `9aed5b36a2284f3aa78fdd56e2dd2513bb1d96e34c4d95e3281a5a302ee43012` | no |
| `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | `380b44d065b833377a916f804ec874a2ee23217950aaa9fb5c5202dc2bab6956` | `380b44d065b833377a916f804ec874a2ee23217950aaa9fb5c5202dc2bab6956` | no |

Neither file was rewritten, so `[P2-T5]` did not need re-running and this task did not restart. The
`[P2-T5]` mirror remains valid.

### Porcelain path counts

Before-set path count: **17**. After-set path count: **17**.
**Set-difference count (paths present after and absent before): 0.**

### Post-stage-1 `git status --porcelain` — the `[P3-T2]` comparison baseline

Recorded verbatim and in full, one line per path, unabridged and unsummarized. This is the set that
`[P3-T2]` performs its set difference against.

```
 M .claude/hooks/validate-bash.ps1
 M .codex/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
 M tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
 M tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-budget-reset.2026-09-07T19-38.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-pair-parity.2026-09-07T19-43.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-toolchain.2026-09-07T19-47.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-budget-reset.2026-09-07T19-48.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-pair-parity.2026-09-07T19-52.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-claude.2026-09-07T19-41.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-codex.2026-09-07T19-51.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-claude.2026-09-07T19-44.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-codex.2026-09-07T19-55.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
```

**Does this listing contain a line naming**
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`**?**
**NO.** The listing carries no `spec.md` entry. `[P3-T1]` has not yet run at the time of this
capture, so `spec.md` is unmodified and porcelain does not list it. This is the state `[P3-T2]`
condition (v) requires.

No restart occurred, so this is the capture taken after the only stage 1 of this task.

---

## Stage 2 — Lint

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = worktree root, no `scan_folders`
EXIT_CODE: 0
Literal result value recorded: **`ok: true`**, equal to the `[P0-T5]` baseline value.

---

## Stage 3 — Test

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/codex-hooks"]`, then read `artifacts/pester/pester-junit.xml`
EXIT_CODE: 1
ExpectedExitCode: 1

Every condition of `[P2-T6]` is reproduced by this run:

| `[P2-T6]` condition | Observed | Result |
|---|---|---|
| (a) `validate-bash-trigger-scoping.Tests.ps1` tests 8, failures 0, errors 0 | `tests="8" errors="0" failures="0"` | PASS |
| (a) `R1-X1`..`R1-X5` all `status="Passed"` | 5 of 5 carry `status="Passed"` | PASS |
| (a) AT-8, AT-9, AT-10 passed | suite `failures="0"`, so all three passed | PASS |
| (b) `validate-bash-decision-surface.Tests.ps1` tests 37, failures 0 | `tests="37" errors="0" failures="0"` | PASS |
| (b) case `returns the four-token git push origin --force literal ahead of any structural value` passed | `status="Passed"` | PASS |
| (c) case `matches a literal carried on the second segment of a chained command` passed | `status="Passed"` | PASS |
| (d) only folder failure is tolerated row 2 | only `codex-pretooluse-integration.Tests.ps1` case `allows every registered handler for every tool name its own matcher admits` | PASS |

---

## Inline acceptance conditions carried from `[P2-T2]` and `[P2-T4]`

`[P2-T2]` — `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`:

| Command | Expected | Observed | Exit | Result |
|---|---|---|---|---|
| `grep -F -c "    It 'R1-X" <file>` | 5 | 5 | 0 | PASS |
| `grep -F -c "    It '" <file>` | 8 | 8 | 0 | PASS |
| `grep -F -c "Context " <file>` | 0 | 0 | 1 (`ExpectedExitCode: 1`) | PASS |
| `wc -l <file>` | at or under 500 | 79 | 0 | PASS |

The count of 8 is the 3 pre-existing blocks plus the 5 appended, so the blocks were appended rather
than substituted. The `Context ` count of 0 with exit 1 confirms the file's flat structure was
preserved: a block indented eight spaces inside an added `Context` would still have satisfied the
count of 8, so this companion condition is what forces the flat structure.

`[P2-T4]` — `.codex/hooks/validate-bash.ps1`:

| Command | Expected | Observed | Exit | Result |
|---|---|---|---|---|
| `grep -F -c "IsWrapperLed" <file>` | 1 | 1 | 0 | PASS |
| `grep -F -c "segment.Unbalanced" <file>` | 1 | 1 | 0 | PASS |
| `grep -F -c "StringComparison]::Ordinal" <file>` | 1 | 1 | 0 | PASS |
| `grep -F -c "'rm -rf'," <file>` | 1 | 1 | 0 | PASS |
| `grep -F -c "CdChainedReadCommand" <file>` | 0 | 0 | 1 (`ExpectedExitCode: 1`) | PASS |
| `wc -l <file>` | at or under 500 | 313 | 0 | PASS |

The `CdChainedReadCommand` count of 0 proves no `cd`-chain rule was introduced into the Codex copy.
The `[P0-T8]` baseline for this file was 295 lines; the edit added 18, the same 13-line
`.DESCRIPTION` paragraph plus separator and 4-line `if` as on the Claude side. The three new tokens
each occur exactly once because none is spelled in the inserted `.DESCRIPTION` paragraph. The first
denylist literal's declaration line survives byte-unchanged.

---

Output Summary: Batch B toolchain gate passed in a single pass with no restart. Stage 1 format
EXIT_CODE 0 with porcelain set-difference 0 and both in-scope SHA-256 values unchanged; stage 2
analyze EXIT_CODE 0 with `ok: true`; stage 3 test reproduces every `[P2-T6]` condition —
`validate-bash-trigger-scoping.Tests.ps1` 8/0/0 with all five R1-X cases passing,
`validate-bash-decision-surface.Tests.ps1` 37/0 with both named cases passing, and the single
tolerated ambient failure as the only folder failure. The post-stage-1 porcelain listing is recorded
verbatim above as the `[P3-T2]` comparison baseline and contains no `spec.md` line.
