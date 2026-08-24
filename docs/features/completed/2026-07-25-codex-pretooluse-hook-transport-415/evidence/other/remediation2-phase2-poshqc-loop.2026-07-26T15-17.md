# Phase 2 — PoshQC Loop, Dual-Path (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P2-T3]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Convention:** C2 (dual-path loop), C3 (per-file extraction), RD-5 (stale MCP measured set)

Timestamp: 2026-07-26T15-17

## Change Under Test

[P2-T1] applied the A1 fix to `.codex/hooks/enforce-epic-planning-only.ps1` (RD-1/RD-3): the wrapper
`Invoke-EpicPlanningGit` and the resolver `Get-EpicPlanningCurrentBranch` were inserted above the
dot-source guard, and the entrypoint push block now calls the resolver. [P2-T2] added seven `It`
blocks to `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1`.

| Check | Value | Verdict |
|---|---|---|
| `.codex/hooks/enforce-epic-planning-only.ps1` line count | 310 | PASS (<= 500) |
| bundle mirror line count | 310 | PASS (<= 500) |
| `codex-detached-head-transport.Tests.ps1` line count | 344 | PASS (<= 500) |
| root vs bundle `Get-FileHash` (planning-only) | match = True | PASS (Hard Constraint 5) |
| root vs bundle `Get-FileHash` (worktree-binding) | match = True | PASS (Hard Constraint 5) |
| `git diff --no-index` root vs bundle mirror | exit 0 | PASS |

## Commands and Exit Codes (one uninterrupted pass, C2 order)

Command: `mcp__drm-copilot__run_poshqc_format` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`)

Command: post-format file-change check — `git status --porcelain`, `git diff --stat`, and a re-measure of
`(Get-Content -LiteralPath $path).Count`
EXIT_CODE: 0 — the formatter changed no PowerShell file. Line counts after format are identical to the
pre-format values (`enforce-epic-planning-only.ps1` = 310, `codex-detached-head-transport.Tests.ps1` = 344)
and the diff stat is unchanged from the [P2-T1]/[P2-T2] edits. Root/bundle hashes still match.
No loop restart required.

Command: `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`) — zero findings. No analyzer suppression was added (Hard Constraint 8).

Command: `mcp__drm-copilot__run_poshqc_test` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`). Mandated stage; per RD-5 its coverage measured set is stale (npx-cached
v1.0.19 runsettings) and is not cited for any numeric claim.

Command: `pwsh -NoProfile -Command "Import-Module 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53'"`
EXIT_CODE: 0 (`LOCAL_EXIT=0`) — authoritative CI-path run.

All four invocations succeeded in a single uninterrupted pass with no file changes.

## Output Summary

### Test counts (authoritative local run)

```
Tests Passed: 1671, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Covered 94.02% / 0%. 4,246 analyzed Commands in 39 Files.
```

| Metric | Baseline ([P0-T6]) | Phase 1 ([P1-T3]) | Phase 2 ([P2-T3]) |
|---|---|---|---|
| Passed | 1659 | 1664 | 1671 |
| Failed | 0 | 0 | 0 |
| Skipped | 9 | 9 | 9 |

The +7 versus Phase 1 is exactly the seven `It` blocks [P2-T2] added. Direct suite run:
`Invoke-Pester -Path tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 -Output Detailed`
reported 12 passed / 0 failed across both `Describe` blocks.

### Repo-wide LINE coverage headline (numeric, from the LOCAL run's JaCoCo XML)

```
REPO-WIDE LINE: covered=2869 missed=173 total=3042 percent=94.31%
REPO-WIDE BRANCH: not emitted by this toolchain
```

Repo-wide LINE coverage: **94.31%** (2869 / 3042). Verdict versus the >= 85% policy gate: **PASS**.

The number is identical to baseline and to Phase 1 because neither changed hook is in
`CodeCoverage.Path` yet: the new tests exercise real production code, but that code is outside the
measured denominator until [P4-T1] appends both paths to the runsettings pair. This is the R-COV
finding, and the flat coverage number across Phases 0–2 is direct evidence of it.

### Hard Constraint 2 — the integration test is unweakened

`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` was not modified in this cycle and
ran green in this pass. It remains the permanent net that reproduces the defect class on every CI
detached checkout.

EXIT_CODE: 0
