# Phase 5 — PoshQC Loop, Dual-Path (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P5-T2] (unconditional)
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Convention:** C2 (dual-path loop), C3 (per-file extraction), RD-5 (stale MCP measured set)

Timestamp: 2026-07-26T15-17

## Change Under Test

[P5-T1] added two new test files under `tests/scripts/codex-hooks/` (0 production files, 2 test files —
within the 3-test-file per-batch cap):

| File | Lines | Cases |
|---|---|---|
| `tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1` | 353 | 21 |
| `tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1` | 143 | 10 |

The `NO-GAP` branch of [P5-T1] was **not** available: [P4-T3] measured
`enforce-epic-child-worktree-binding.ps1` at 83.75% raw, below the 85% gate.

Placement rationale: the plan directs cases into
`tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` first, subject to its headroom to 500
lines measured at execution time. That file stood at 344 lines, leaving 156 lines of headroom, while the
28 exercisable missed lines catalogued at [P4-T3] require roughly 450 lines of Arrange–Act–Assert cases
with fixtures. The plan's authorized fallback — up to 2 new files under `tests/scripts/codex-hooks/` with
the suggested names — was therefore used, and the suggested names were kept.

## Loop Restart (recorded per C2)

The first pass of this loop **failed at analyze** and was restarted from format, as C2 requires.

Command: `mcp__drm-copilot__run_poshqc_analyze` (first attempt)
EXIT_CODE: 1 — `PSScriptAnalyzer reported 4 issue(s).`

| Rule | File | Line | Function |
|---|---|---|---|
| `PSUseShouldProcessForStateChangingFunctions` | `codex-planning-only-hook.Tests.ps1` | 28 | `New-PlanningPayload` |
| `PSUseShouldProcessForStateChangingFunctions` | `codex-worktree-binding-hook.Tests.ps1` | 30 | `New-BindingReceipt` |
| `PSUseShouldProcessForStateChangingFunctions` | `codex-worktree-binding-hook.Tests.ps1` | 60 | `New-BindingAttestation` |
| `PSUseShouldProcessForStateChangingFunctions` | `codex-worktree-binding-hook.Tests.ps1` | 76 | `New-BindingPayload` |

Resolution: the four in-test fixture builders were renamed from the `New-` verb (which PSScriptAnalyzer
classifies as state-changing and therefore requiring `ShouldProcess`) to the `Get-` verb, which correctly
describes them — they construct and return in-memory objects and change no system state:
`Get-BindingReceiptFixture`, `Get-BindingAttestationFixture`, `Get-BindingPayloadFixture`,
`Get-PlanningPayloadFixture`. **No analyzer suppression was added** (Hard Constraint 8); the underlying
naming cause was fixed. The loop then restarted from format.

## Commands and Exit Codes (final uninterrupted pass, C2 order)

Command: `mcp__drm-copilot__run_poshqc_format` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`) — no file changed; line counts held at 353 / 143 / 344.

Command: `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`) — zero findings.

Command: `mcp__drm-copilot__run_poshqc_test` (`workspace_root` = REPO)
EXIT_CODE: 0 (`ok: true`). Mandated stage; measured set stale per RD-5, no numeric claim drawn from it.

Command: `pwsh -NoProfile -Command "Import-Module 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53'"`
EXIT_CODE: 0 (`LOCAL_EXIT=0`) — the measurement of record for [P5-T3].

All four invocations succeeded in one uninterrupted pass with no file changes.

## Output Summary

### Test counts (authoritative local run)

```
Tests Passed: 1702, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Covered 93.95% / 0%. 4,594 analyzed Commands in 41 Files.
```

| Metric | [P0-T6] | [P2-T3] | [P4-T2] | [P5-T2] |
|---|---|---|---|---|
| Passed | 1659 | 1671 | 1671 | 1702 |
| Failed | 0 | 0 | 0 | 0 |
| Skipped | 9 | 9 | 9 | 9 |

The +31 versus [P4-T2] is exactly the 21 + 10 cases [P5-T1] added.

### Repo-wide LINE coverage headline (numeric, from the LOCAL run's JaCoCo XML)

```
REPO-WIDE LINE: covered=3148 missed=189 total=3337 percent=94.34%
REPO-WIDE BRANCH: not emitted by this toolchain
```

Repo-wide LINE coverage: **94.34%** (3148 / 3337). Verdict versus the >= 85% gate: **PASS**. This is above
the [P0-T6] baseline of 94.31% *despite* a 295-line larger denominator, because the numerator grew by
279 lines across Phases 1, 2, and 5.

EXIT_CODE: 0
