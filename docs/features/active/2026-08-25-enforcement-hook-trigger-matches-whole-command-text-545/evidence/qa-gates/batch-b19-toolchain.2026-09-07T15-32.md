# Batch B19 — batch toolchain gate (Claude `enforce-parallel-abandon-gate.ps1`, both copies)

Timestamp: 2026-09-07T15-32

Task: [P10-T16]

Batch B19 contents: production `.claude/hooks/enforce-parallel-abandon-gate.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1`;
test `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter: **31 paths.** Porcelain capture AFTER the formatter: the same
**31 paths**. Both captures were taken with `git status --porcelain` into recorded files and compared
mechanically.

**Set-difference count (paths in the after-set and absent from the before-set): 0.** Computed with
`comm -13` over the two sorted captures.

Corroborating observation beyond the exit code: the edited hook's SHA-256 is
`be07ecffd852f22f6b5dc103f519253028fbe6cb66f52baac8c48c9d9808aee6` both before and after the
formatter run — the same value recorded by the [P10-T15] mirror comparison. The formatter neither
created a path nor rewrote a file in this batch, so no restart from stage 1 was required.

## Stage 2 — linting

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Result: `ok: true`, equivalent to a repository-wide total of **0** diagnostics.

| Measure | Value |
| --- | --- |
| Error-severity diagnostics on the files this batch touched | 0 |
| Repository-wide total | 0 |
| [P0-T6] baseline repository-wide total | 0 |
| At or below baseline? | yes (equal) |

## Stage 3 — targeted Pester over both suites

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-suite
and per-case results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after
stages 1 and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count; neither suite this task measures contributes to it)

| Suite | tests | failures | errors | skipped | Baseline passed count |
| --- | --- | --- | --- | --- | --- |
| `enforce-parallel-abandon-gate.Tests.ps1` (existing) | 24 | **0** | 0 | 0 | **24**, equal |
| `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` (owned by this batch) | 3 | **0** | 0 | 0 | n/a, new |

The [P0-T10] baseline figure is row 2 of
`evidence/baseline/baseline-targeted-pester.2026-09-07T11-14.md`, which recorded 24 tests, 24 passed,
0 failed for the existing suite.

The existing `It` named **`allows when the confirmation marker precedes the disposition token`** at
line 62 of that suite **passes unmodified**. It drives
`run --confirm-abandon --disposition abandon`, which is a single segment carrying both the abandon
disposition and the confirmation marker, so the same-segment requirement introduced by [P10-T15] is
satisfied and the decision is still allow. Every one of the suite's 24 cases is listed as passing in
the run record, including `denies when extra whitespace separates the disposition token parts` and
`allows the detach disposition, which is not destructive`.

All three cases in the suite this batch owns pass:

| Case | Before [P10-T15] | After [P10-T15] |
| --- | --- | --- |
| AT-11 takes a grep whose quoted search term is the disposition token out of scope | FAIL | **PASS** |
| AT-12 brings the equals-joined spelling of the disposition option into scope | FAIL | **PASS** |
| does not accept a confirmation marker that sits in a different segment from the disposition token | FAIL | **PASS** |

These close known-red inventory rows 39, 40, and 41.

### Reconciliation of the folder-wide failure count

`tests/scripts/claude-hooks`: 1520 tests, **1** failure, 0 errors, 0 skipped.

- 1 from `enforce-pr-author-skill.Tests.ps1`, case
  `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` — the documented
  pre-existing, ambient-state-dependent baseline failure recorded in the known-red inventory's
  appendix. Out of scope.

The known-red inventory contributes **0** failures. Every one of its 41 rows is now closed.

## Token-seam pytest

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -q`

EXIT_CODE: 0

Result: **10 passed in 0.04s. Zero failed tests.** The seam test parses the hook at run time and
extracts the consumer-side values from the two named `$script:` assignments, so it fails on a change
of their shape. It passes, which confirms both token literals kept their single-assignment form and
their exact values. The command was run without a leading `cd`, because a `cd`-chained read command is
denied by `validate-bash.ps1` — see the live observation below.

## Live observation of the [P10-T3] change, recorded incidentally

An earlier attempt at the pytest command above was written as
`cd <worktree> && poetry run pytest ... | tail -20` and was **denied** by the fixed
`.claude/hooks/validate-bash.ps1` with the reason
`Forbidden Bash pattern: 'cd ... && tail' (or ';'-chained)`. The `tail` segment is not adjacent to the
`cd` segment; two segments intervene. This is a live, in-session confirmation that the [P10-T3] part
(c) segment walk preserves the non-adjacent reach of the retained pattern, which acceptance criterion
9 requires and which the plan singled out across three preflight rounds.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | `be07ecffd852f22f6b5dc103f519253028fbe6cb66f52baac8c48c9d9808aee6` | 331 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | `be07ecffd852f22f6b5dc103f519253028fbe6cb66f52baac8c48c9d9808aee6` | 331 |

Equal, and both at or under the 500-line cap. The file was 256 lines before this work and is 331
after. The new test suite measures 69 lines and hashes to
`89f834cbf46417f6727603c71103e000d7a84ad80c233cb43b9ade8c2591b890`.

## Byte-unchanged constraint check for lines 41 and 42

`git diff -U0 origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks/enforce-parallel-abandon-gate.ps1`
produces six hunks, the first at `@@ -46,0 +47,7 @@`. Every hunk begins at or after original line 46,
so original lines 41 and 42 are untouched and retain their line numbers. The two dot-source lines were
deliberately placed BELOW the token assignments rather than above them for exactly that reason. A
filter of the diff for either assignment returns no `+` or `-` line. Post-change content of lines 41
and 42, read back from the file:

```powershell
$script:AbandonDispositionToken = '--disposition abandon'
$script:AbandonConfirmToken = '--confirm-abandon'
```

Both remain single assignments of a single-quoted literal, which is the shape the seam test's regexes
require.

## Phase 10 file-size summary

| File | Lines | At or under 500? |
| --- | --- | --- |
| `.claude/hooks/validate-bash.ps1` | 402 | yes |
| `extensions/.../claude-customizations/.claude/hooks/validate-bash.ps1` | 402 | yes |
| `.codex/hooks/validate-bash.ps1` | 295 | yes |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | 295 | yes |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 331 | yes |
| `extensions/.../claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | 331 | yes |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 82 | yes |
| `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | 45 | yes |
| `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 69 | yes |

## Batch budget reset (closes B19)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.claude/hooks/enforce-parallel-abandon-gate.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/claude-hooks/at12-prechange-observation.Tests.ps1",
    ".../tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. `at12-prechange-observation.Tests.ps1` is the throwaway suite created and
deleted within this session to make the [P10-T12] observation an executed run rather than a
derivation; it is recorded here because the counter retains it, and it is no longer on disk. Batch
B19's delivered file count is 2 production and 1 test file, under the 3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files. Phase 11 is not
part of this delegation, so this reset opens no further batch here.

Output Summary: batch B19 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the porcelain path count is 31 before and after, and the edited hook's
SHA-256 is unchanged across the run. Stage 2 analyze returned `ok: true`, equal to **0**
repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports **zero failed
tests in both Pester suites**: the existing suite at **24 / 0**, equal to its [P0-T10] baseline passed
count of 24 and with the named case `allows when the confirmation marker precedes the disposition
token` passing unmodified, and the new suite at **3 / 0**, closing known-red inventory rows 39 through
41. The token-seam pytest reports **10 passed, zero failed**, confirming both token literals kept
their single-assignment shape; lines 41 and 42 are byte-unchanged and retain their line numbers. Both
hook copies hash equal at 331 lines, under the 500-line cap. No stage failed and no stage rewrote a
file, so no restart from stage 1 was required. The closing batch-budget reset exited 0.
