# Batch B18 — batch toolchain gate (Codex `validate-bash.ps1`, both copies)

Timestamp: 2026-09-07T15-22

Task: [P10-T11]

Batch B18 contents: production `.codex/hooks/validate-bash.ps1` and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`;
test `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`.

## Stage 1 — formatting

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and no
`scan_folders` argument.

EXIT_CODE: 0

Porcelain capture BEFORE the formatter: **25 paths.** Porcelain capture AFTER the formatter: the same
**25 paths**. Both captures were taken with `git status --porcelain` into recorded files and compared
mechanically.

**Set-difference count (paths in the after-set and absent from the before-set): 0.** Computed with
`comm -13` over the two sorted captures.

Corroborating observation beyond the exit code: the edited Codex hook's SHA-256 is
`609c1af789e1f091d4710f77e1ece15c56b0183870cc0d09ba74b2f9fe989ba6` both before and after the
formatter run — the same value recorded by the [P10-T9] mirror comparison. The formatter neither
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

## Stage 3 — targeted Pester over the test file this batch owns

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session; per-suite
and per-case results were read out of `artifacts/pester/pester-junit.xml`. The run was executed after
stages 1 and 2.

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 1 (folder-wide failed-test count)

| Suite | tests | failures | errors | skipped |
| --- | --- | --- | --- | --- |
| `validate-bash-trigger-scoping.Tests.ps1` (owned by this batch) | 3 | **0** | 0 | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | 0 | 0 |

All three cases in the suite this batch owns pass:

| Case | Result |
| --- | --- |
| AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force | PASS |
| AT-9 denies a relocating git push --force carrying a directory global option | PASS |
| AT-10 allows a commit message that quotes a dangerous pattern in prose | PASS |

`legacy-codex-hook-contracts.Tests.ps1` at **43 tests / 0 failures** carries the four Codex-side
contract checks: byte identity between each `.codex` file and its bundle mirror, pack-manifest
completeness, parse success, and the 500-line cap. All four remain green, which independently
confirms the [P10-T9] mirror. That suite's own case at line 179 drives this hook with
`git reset --hard` and expects the marker `git reset --hard`; it still passes, because that command
matches denylist literal 5 as a contiguous token run.

### Reconciliation of the folder-wide failure count

`tests/scripts/codex-hooks`: 752 tests, **1** failure, 0 errors, 0 skipped.

- 1 from `codex-pretooluse-integration.Tests.ps1`, case
  `allows every registered handler for every tool name its own matcher admits` — the documented
  pre-existing, ambient-state-dependent baseline failure recorded in the known-red inventory's
  appendix, driven by this worktree's live epic checkpoint. Out of scope.

The known-red inventory contributes **0** failures on the Codex side.

## Batch-level parity

| File | SHA-256 | Lines |
| --- | --- | --- |
| `.codex/hooks/validate-bash.ps1` | `609c1af789e1f091d4710f77e1ece15c56b0183870cc0d09ba74b2f9fe989ba6` | 295 |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | `609c1af789e1f091d4710f77e1ece15c56b0183870cc0d09ba74b2f9fe989ba6` | 295 |

Equal, and both at or under the 500-line cap. The file was 185 lines before this work and is 295
after. The new test suite measures 45 lines and hashes to
`3b20a5cce3874f611cabb02ca4590727669d519c937ff2f912da1a50b9847442`.

## Byte-unchanged and no-cd-leg constraint check

`git diff -U0 origin/epic/cleanup-merged-worktrees-hardening-integration -- .codex/hooks/validate-bash.ps1`
produces five hunks, bounded at `@@ -16,0 +17,7 @@` (the dot-source lines) and `@@ -31,0 +39,68 @@`
(immediately after `Get-BlockedBashPattern` closes at original line 30). Original lines 22 through 29,
which hold the six denylist literals, are untouched, so **all six literal strings are
byte-unchanged**. A case-insensitive search of the added lines for a `cd`-chained pattern returns
**0** matches: this copy has no `cd`-chained leg and none was added, as [P10-T8] requires.

## Batch budget reset (closes B18, opens B19)

Resolved session id: `worktree-agent-a478b73e41951af31-e3281c7b`. Cross-checked against the files
actually present in `.claude/state/`, which held exactly one file,
`powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json`.

Pre-reset counter contents:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".../.codex/hooks/validate-bash.ps1"
  ],
  "testFiles": [
    ".../tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1"
  ]
}
```

The bundle mirror is absent from the counter because it was written with `cp`, which does not pass
through the PreToolUse hook. Batch B18's real file count is 2 production and 1 test file, under the
3-and-3 cap.

Command: `rm -f ".claude/state/powershell-batch-budget.worktree-agent-a478b73e41951af31-e3281c7b.json"`

EXIT_CODE: 0

Post-reset listing of `.claude/state/`: the directory exists and contains no files. This reset opens
batch B19.

Output Summary: batch B18 toolchain gate PASSES in a single pass. Stage 1 formatting exited 0 with a
set-difference count of **0**; the porcelain path count is 25 before and after, and the edited Codex
hook's SHA-256 is unchanged across the run. Stage 2 analyze returned `ok: true`, equal to **0**
repository-wide diagnostics and equal to the [P0-T6] baseline of 0. Stage 3 reports
**3 tests / 0 failures** for the suite this batch owns and **43 tests / 0 failures** for
`legacy-codex-hook-contracts.Tests.ps1`, so byte identity, pack-manifest completeness, parse success,
and the 500-line cap all remain green. The folder-wide count is 752 tests with 1 failure, the
documented pre-existing ambient-state `codex-pretooluse-integration.Tests.ps1` case. All six denylist
literals are byte-unchanged and no `cd`-chained pattern was added. Both Codex copies hash equal at 295
lines, under the 500-line cap. No stage failed and no stage rewrote a file, so no restart from stage 1
was required. The closing batch-budget reset exited 0.
