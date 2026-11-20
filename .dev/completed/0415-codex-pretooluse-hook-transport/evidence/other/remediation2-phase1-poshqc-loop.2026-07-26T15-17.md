# Phase 1 — PoshQC Loop, Dual-Path (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P1-T3]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Convention:** C2 (dual-path loop), C3 (per-file extraction), RD-5 (stale MCP measured set)
- **HEAD at run time:** `bb12591b048bbf00ffe5a55d91a5287e85231a84`

Timestamp: 2026-07-26T15-17

## Preconditions Verified Before the Loop

Command: `pwsh -NoProfile -Command "(Get-Content -LiteralPath <path>).Count"` and `Get-FileHash` comparison
EXIT_CODE: 0

| Check | Value | Verdict |
|---|---|---|
| `.codex/hooks/enforce-epic-child-worktree-binding.ps1` line count | 334 | PASS (<= 500) |
| `.codex/hooks/enforce-epic-planning-only.ps1` line count | 292 | PASS (<= 500, unedited at this phase) |
| `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` line count | 173 | PASS (<= 500) |
| `enforce-epic-child-worktree-binding.ps1` root vs bundle `Get-FileHash` | match = True | PASS (Hard Constraint 5) |
| `enforce-epic-planning-only.ps1` root vs bundle `Get-FileHash` | match = True | PASS (Hard Constraint 5) |

## Commands and Exit Codes (one uninterrupted pass, C2 order)

Command: `mcp__drm-copilot__run_poshqc_format` (`workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53`)
EXIT_CODE: 0 (`ok: true`)

Command: `git status --porcelain` (post-format file-change check)
EXIT_CODE: 0 — no PowerShell file reformatted. The only working-tree entries were the two Phase 0
evidence documents written moments earlier by this session
(`phase0-instructions-read.md`, `phase0-git-baseline.2026-07-26T15-17.md`). No loop restart required.

Command: `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`) — zero findings.

Command: `mcp__drm-copilot__run_poshqc_test` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`). Per RD-5 this stage executes the PoshQC module bundled in the npx-cached
`@danmoisan/drm-copilot-mcp` v1.0.19, whose runsettings predate this branch; it is run because the
toolchain mandates it, but its coverage measured set is stale and is not cited for any numeric claim.

Command: `pwsh -NoProfile -Command "Import-Module 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53'"`
EXIT_CODE: 0 (`LOCAL_EXIT=0`) — the authoritative CI-path run (mirrors `.github/workflows/_poshqc.yml:38-42`).

All four invocations succeeded in a single uninterrupted pass with no file changes, so the loop
completed without a restart.

## Output Summary

### Test counts (authoritative local run)

```
Tests completed in 104.4s
Tests Passed: 1664, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 94.02% / 0%. 4,246 analyzed Commands in 39 Files.
```

| Metric | Baseline ([P0-T6]) | Phase 1 ([P1-T3]) | Delta |
|---|---|---|---|
| Passed | 1659 | 1664 | +5 |
| Failed | 0 | 0 | 0 |
| Skipped | 9 | 9 | 0 |

The +5 is exactly the five `It` blocks in the new
`tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` suite added by [P1-T2].

### Repo-wide LINE coverage headline (numeric, from the LOCAL run's JaCoCo XML)

Source: `artifacts/pester/powershell-coverage.xml`, report-level `counter[@type='LINE']`.

```
REPO-WIDE LINE: covered=2869 missed=173 total=3042 percent=94.31%
REPO-WIDE BRANCH: not emitted by this toolchain
```

Repo-wide LINE coverage: **94.31%** (2869 / 3042). Verdict versus the >= 85% policy gate: **PASS**.
Unchanged from the [P0-T6] baseline, which is expected: the [P1-T1] fix and [P1-T2] tests target
`enforce-epic-child-worktree-binding.ps1`, which is not yet in `CodeCoverage.Path` — that measurement
gap is the R-COV finding closed at [P4-T1]. PowerShell branch coverage is not separately emitted by
this toolchain (documented limitation, `spec.md:248`).

### Root/bundle parity suites

The parity suites in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` ran green in
this pass, re-verifying byte-identity of the edited hook against its bundle mirror. The independent
`Get-FileHash` comparison recorded in the preconditions table above agrees.

### Cycle-1 `.codex/hooks` per-file band (no regression)

Extracted per C3 from the same XML; identical to the [P0-T6] baseline table:

| Sourcefile | Covered | Missed | Total | Percent |
|---|---|---|---|---|
| `check-powershell-test-purity.ps1` | 62 | 0 | 62 | 100.00% |
| `check-python-test-purity.ps1` | 67 | 0 | 67 | 100.00% |
| `codex-pretooluse-file-mapping.ps1` | 101 | 0 | 101 | 100.00% |
| `enforce-checkpoint-monotonic.ps1` | 103 | 1 | 104 | 99.04% |
| `enforce-completion-consistency.ps1` | 136 | 0 | 136 | 100.00% |
| `enforce-evidence-locations.ps1` | 41 | 0 | 41 | 100.00% |
| `enforce-orchestration-preimplementation-gate.ps1` | 98 | 0 | 98 | 100.00% |
| `enforce-powershell-batch-budget.ps1` | 84 | 3 | 87 | 96.55% |
| `enforce-python-batch-budget.ps1` | 84 | 3 | 87 | 96.55% |

Cycle-1 changed-file band: **96.55% – 100.00%** — no regression versus [P0-T6].
`enforce-completion-helpers.ps1` (33/43, 76.74%) is unchanged pre-existing measured surface outside
this plan's scope, recorded for attribution only.

EXIT_CODE: 0
