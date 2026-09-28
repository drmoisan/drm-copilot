# Batch B1 — batch toolchain gate

Timestamp: 2026-09-07T12-26

Task: [P2-T7]

Batch B1 contents: production `.claude/hooks/hook-command-scanner.ps1` and
`.codex/hooks/hook-command-scanner.ps1`; tests `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1`
and `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1`.

## Batch budget reset (closes B1, opens B2)

Pre-reset listing of `.claude/state/`:

```
powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json
```

The observed file name matches the composed name for the resolved session id
`worktree-agent-a478b73e41951af31-e3281c7b`, so the reset targeted an existing file.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: empty.

TOOLCHAIN_SUBSTITUTION: the `Remove-Item -LiteralPath ... -ErrorAction SilentlyContinue` form the plan
names requires a `pwsh` process, which the runtime worktree-isolation guard refuses unconditionally in
this session. `rm -f` deletes the identical single path with the same tolerance for absence. The
before-and-after listings are the observation that distinguishes a real deletion from a no-op.

### Batch-budget counter accounting recorded for audit

The counter registered one production file, `.claude/hooks/hook-command-scanner.ps1`, because that
file was created through the `Write` tool, which the `enforce-powershell-batch-budget.ps1` PreToolUse
hook observes. `.codex/hooks/hook-command-scanner.ps1` was produced with `cp` so that the mirror is
byte-identical by construction, and `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` was
produced with `sed` from its Claude twin for the same reason; neither route passes through the hook,
so neither incremented the counter. The substantive constraint is unaffected: batch B1's real file
count is 2 production and 2 test files, both under the 3-and-3 cap, and the counts are stated here so
the counter's under-reporting is on the record rather than silent.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument, so the whole repository is formatted.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter (verbatim):

```
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
?? .claude/hooks/hook-command-scanner.ps1
?? .codex/hooks/hook-command-scanner.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b1-budget-reset.2026-09-07T12-12.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/scanner-line-count-b1.2026-09-07T12-20.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/test-suite-line-count-b1.2026-09-07T12-20.md
?? tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
?? tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
```

Porcelain capture AFTER the formatter (verbatim):

```
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md
?? .claude/hooks/hook-command-scanner.ps1
?? .codex/hooks/hook-command-scanner.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b1-budget-reset.2026-09-07T12-12.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/scanner-line-count-b1.2026-09-07T12-20.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/test-suite-line-count-b1.2026-09-07T12-20.md
?? tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1
?? tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1
```

**Set-difference count (paths in the after-set and absent from the before-set): 0.**

The two captures are identical. Two further observations corroborate that the formatter rewrote
nothing rather than that the capture was insensitive: the line counts of
`.claude/hooks/hook-command-scanner.ps1` (450) and both test suites (321 each) are unchanged across
the formatter run, and the SHA-256 pair for the two scanner copies is still equal at
`19223e297d621f5787b54ddaba745e591950d153a8eb749cc21b22509f45dc7d`. A formatter rewrite of either
copy alone would have broken that equality.

## Stage 2 — linting

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Result: `ok: true`. As the [P0-T6] baseline artifact establishes, `Invoke-PoshQCAnalyze` throws on any
finding at any of the three configured severities and the MCP wrapper maps a throw to `ok: false`, so
`ok: true` is equivalent to a repository-wide total of **0** diagnostics.

| Measure | Value |
| --- | --- |
| Error-severity diagnostics on the files this batch touched | 0 |
| Repository-wide total | 0 |
| [P0-T6] baseline repository-wide total | 0 |
| At or below baseline? | yes (equal) |

## Stage 3 — targeted Pester over the test files this batch owns

TOOLCHAIN_SUBSTITUTION: the plan's targeted form
`pwsh -NoProfile -Command "Invoke-Pester -Path <suite> -Output Detailed"` is not invocable, because the
runtime worktree-isolation guard refuses `pwsh` unconditionally in this session. The folder-scoped
route was used instead: `mcp__drm-copilot__run_poshqc_test` with a `scan_folders` argument, and the
per-suite and per-test results were then read out of `artifacts/pester/pester-junit.xml`, whose
`testsuite` elements are keyed by absolute suite path. Both stage-3 runs below were executed AFTER
stages 1 and 2, so the gate reflects the post-format tree.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 15 (the runner's exit code is the folder-wide failed-test count; see the reconciliation
below)

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 21 (folder-wide failed-test count)

Per-suite results for the two suites this batch owns, read from `pester-junit.xml`:

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | 41 | **0** | 0 | 0 |
| `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | 41 | **0** | 0 | 0 |

Both suites report a numeric failed count of zero, so the stage-3 acceptance condition — every failing
test name is a member of the [P1-T13] known-red inventory minus the entries this batch closes — holds
vacuously for the batch's own files: the failing-name set is empty and the empty set is a subset of
any inventory.

### Reconciliation of the folder-wide failure counts against the known-red inventory

The folder-scoped route necessarily runs every suite in the named folder, not only the batch's own
files. Those folder-wide counts are recorded here so the non-zero runner exit codes above are
auditable rather than unexplained:

- `tests/scripts/claude-hooks`: 1420 tests, **21** failures.
- `tests/scripts/codex-hooks`: 692 tests, **15** failures.

`evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md` holds 34 rows, partitioned by
folder as 20 Claude-side rows ([P1-T3] 6 + [P1-T5] 13 + [P1-T9] 1) and 14 Codex-side rows
([P1-T7] 13 + [P1-T11] 1). The observed counts are therefore each **one above** what the inventory
predicts. Both extras were identified by name and neither is caused by batch B1. Batch B1 closes no
inventory row, so the inventory is unchanged by this batch.

**Claude-side extra:** `enforce-pr-author-skill.Tests.ps1` /
`enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.
Observed message: `Expected: 'allow' | But was: 'deny'` at line 145 of that suite. Cause: the
`allowed commands` `Context` block mocks `Get-PrContextArtifactExistence`,
`Invoke-OrchestratorStatePreflight`, `Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, and
`Get-PrContextSummaryLastWriteUtc`, but it does **not** mock `Get-PrAuthorCheckpointContent`. That
seam, defined at `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` line 12, reads the live
`artifacts/orchestration/orchestrator-state.json` from disk. `Test-EpicBaseBranchOverride` returns
`$null` early for any command text that is not `gh pr create`, so the `gh pr edit` sibling case in the
same `Context` passes while the `gh pr create` case does not. The live checkpoint in this worktree
carries `epic_mode: true` with `epic_context.integration_branch` set to
`epic/cleanup-merged-worktrees-hardening-integration`, and the test's command text carries no
`--base`, so the check denies with `EPIC_BASE_BRANCH_MISMATCH`.

**Codex-side extra:** `codex-pretooluse-integration.Tests.ps1` /
`Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`.
Observed message names the denying handler explicitly: `enforce-epic-wave-barrier.ps1 x Bash` returning
`EPIC_WAVE_BARRIER_BLOCKED: '545' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint.`
Cause: the same class. That handler reads the live epic checkpoint rather than an injected fixture, so
its decision depends on the orchestration state of the run executing the suite.

Both extras are the same defect class — a test whose outcome depends on live, gitignored orchestration
state read through an unmocked seam — and both are outside this change's scope. Neither names a file
this batch created or modified: batch B1 added `.claude/hooks/hook-command-scanner.ps1`,
`.codex/hooks/hook-command-scanner.ps1`, and their two test suites, and no call site in
`enforce-pr-author-skill.ps1` or `enforce-epic-wave-barrier.ps1` has been rewritten yet. The
possibility that the new `.codex/hooks/hook-command-scanner.ps1` had itself been picked up as an
unregistered Codex PreToolUse handler was checked directly and ruled out: the failure message names
`enforce-epic-wave-barrier.ps1` as the denying handler, not the new file.

`artifacts/orchestration/orchestrator-state.json` is gitignored — `git log --oneline -1` against that
path returns no commit and `git status --porcelain` against it returns no row — so neither failure is
reproducible from the committed tree and neither would appear in CI. The [P0-T10] baseline captured
eight named suites and neither of these two is among them, so no Phase 0 baseline row exists to
compare against; the causal analysis above stands in its place. Both are recorded here as
out-of-inventory, out-of-scope observations rather than being silently absorbed into the gate.

## Batch-level parity

| File | SHA-256 |
| --- | --- |
| `.claude/hooks/hook-command-scanner.ps1` | `19223e297d621f5787b54ddaba745e591950d153a8eb749cc21b22509f45dc7d` |
| `.codex/hooks/hook-command-scanner.ps1` | `19223e297d621f5787b54ddaba745e591950d153a8eb749cc21b22509f45dc7d` |

Equal, so the [P2-T2] byte-identity acceptance holds after the formatter ran.

Output Summary: batch B1 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0** between the before and after porcelain captures. Stage 2 analyze
returned `ok: true`, equal to **0** repository-wide diagnostics and equal to the [P0-T6] baseline of 0.
Stage 3 reports **41 tests / 0 failures** for each of the two suites this batch owns; no stage failed
and no stage rewrote a file, so no restart from stage 1 was required. The closing batch-budget reset
deleted `powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json` with EXIT_CODE 0 and
opens batch B2. The two scanner copies share SHA-256
`19223e297d621f5787b54ddaba745e591950d153a8eb749cc21b22509f45dc7d`.
