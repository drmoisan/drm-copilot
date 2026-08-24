# Phase 4 — PoshQC Loop, Dual-Path (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P4-T2]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Convention:** C2 (dual-path loop), C3 (per-file extraction), RD-5 (stale MCP measured set)

Timestamp: 2026-07-26T15-17

## Change Under Test

[P4-T1] appended exactly two entries to `CodeCoverage.Path` in both `pester.runsettings.psd1` copies,
preceded by an issue-#415-cycle-2 attribution comment:
`.codex/hooks/enforce-epic-child-worktree-binding.ps1` and `.codex/hooks/enforce-epic-planning-only.ps1`.

| Check | Value | Verdict |
|---|---|---|
| Both entries present in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | lines 115, 116 | PASS |
| Both entries present in `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | lines 115, 116 | PASS |
| `git diff --no-index` between the two copies | exit 0 | PASS (Hard Constraint 5) |
| Line count, each copy | 129 | equal |
| `CoveragePercentTarget` | `0`, unchanged | PASS |
| Pre-existing entries removed | `git diff \| grep "^-"` produced no output | PASS — purely additive (Hard Constraint 8) |
| Total `CodeCoverage.Path` entries | 42 (was 40) | +2 |

## Commands and Exit Codes (one uninterrupted pass, C2 order)

Command: `mcp__drm-copilot__run_poshqc_format` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`)

Command: post-format check — re-measured `(Get-Content ... ).Count` = 129 and re-ran the `git diff --no-index`
parity check (exit 0)
EXIT_CODE: 0 — the formatter changed no file. No loop restart required.

Command: `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`) — zero findings.

Command: `mcp__drm-copilot__run_poshqc_test` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`). As RD-5 predicted, this stage does **not** reflect the new entries: it executes
the PoshQC module bundled in npx-cached `@danmoisan/drm-copilot-mcp` v1.0.19, whose runsettings predate
this branch. Its measured set is stale and no numeric claim is drawn from it.

Command: `pwsh -NoProfile -Command "Import-Module 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53'"`
EXIT_CODE: 0 (`LOCAL_EXIT=0`) — the measurement of record.

All four invocations succeeded in a single uninterrupted pass with no file changes.

## Output Summary

### Test counts (authoritative local run)

```
Tests Passed: 1671, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Covered 93.32% / 0%. 4,594 analyzed Commands in 41 Files.
```

Test counts are unchanged from [P2-T3] (1671 / 0 / 9), which is expected: [P4-T1] changed only what is
measured, not what is tested.

### The new entries are present in the coverage XML (C3 keying)

The measured file count rose from **39 to 41** and analyzed commands from **4,246 to 4,594**. C3
extraction over the package `.../.codex/hooks` returns `sourcefile` entries for both new files:

| Sourcefile | Covered | Missed | Total | Percent |
|---|---|---|---|---|
| `enforce-epic-child-worktree-binding.ps1` | 134 | 26 | 160 | 83.75% |
| `enforce-epic-planning-only.ps1` | 117 | 18 | 135 | 86.67% |

This is the direct closure of the [P0-T6] auditable negative record (`SearchResult: none` for both
filenames by two independent methods). The R-COV measurement gap is closed.

### Repo-wide LINE coverage headline (numeric, from the LOCAL run's JaCoCo XML)

```
REPO-WIDE LINE: covered=3120 missed=217 total=3337 percent=93.50%
REPO-WIDE BRANCH: not emitted by this toolchain
```

Repo-wide LINE coverage: **93.50%** (3120 / 3337). Verdict versus the >= 85% gate: **PASS**. The movement
from 94.31% is denominator growth from the two newly measured hooks; no previously covered line lost
coverage. PowerShell branch coverage is not separately emitted by this toolchain (documented limitation,
`spec.md:248`).

### Consumer-repo safety

Absent paths in `CodeCoverage.Path` are pruned by `PoshQC.Testing.psm1` (issue #409), so the two added
entries are inert in a consumer repository that has no `.codex/hooks/` directory. The
`PoshQC.TestingCoveragePruning.Tests.ps1` suite ran green in this pass.

EXIT_CODE: 0
