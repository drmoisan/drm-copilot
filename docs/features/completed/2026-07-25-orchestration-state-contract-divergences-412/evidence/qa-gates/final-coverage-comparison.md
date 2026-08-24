# Phase 6 [P6-T15] — Baseline vs. post-change coverage comparison (Issue #412)

Timestamp: 2026-07-25T18-59

Sources: baselines from [P0-T5] (Python), [P0-T8] (PowerShell), [P0-T13] (TypeScript);
post-change values from [P6-T4] (Python), [P6-T7] (PowerShell), [P6-T13] (TypeScript).

Uniform repository thresholds (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`):
line coverage >= 85%, branch coverage >= 75%, no regression on changed lines.

## Repository-wide comparison

| Language | Metric | Baseline | Post-change | Delta | Threshold | Result |
|---|---|---|---|---|---|---|
| Python | Line | 90.99% (11154 / 12259) | 91.00% (11175 / 12280) | +0.01 pp | >= 85% | pass |
| Python | Branch | 81.83% (3640 / 4448) | 81.84% (3642 / 4450) | +0.01 pp | >= 75% | pass |
| Python | Tests | 2084 passed / 0 failed | 2123 passed / 0 failed | +39 tests | 0 failures | pass |
| PowerShell | Line | 90.22% (2150 / 2383) | 90.26% (2159 / 2392) | +0.04 pp | see note | pass |
| PowerShell | Command | 89.68% (2929 / 3266) | 89.73% (2945 / 3282) | +0.05 pp | see note | pass |
| PowerShell | Branch | not reported by Pester 5 (CoverageGutters format measures commands, not branches) | not reported by Pester 5 (CoverageGutters format measures commands, not branches) | n/a | n/a | tooling limitation |
| PowerShell | Tests | 1354 passed / 0 failed | 1391 passed / 0 failed | +37 tests | 0 failures | pass |
| TypeScript | Line | 96.33% (37643 / 39074) | 96.34% (37690 / 39121) | +0.01 pp | >= 85% | pass |
| TypeScript | Branch | 89.21% (5201 / 5830) | 89.22% (5206 / 5835) | +0.01 pp | >= 75% | pass |
| TypeScript | Suites / tests | 168 suites / 2031 tests passed | 168 suites / 2035 tests passed | +4 tests | 0 failures | pass |

PowerShell branch note: Pester 5 with the `CoverageGutters` output format emits command
(`INSTRUCTION`) and line counters only; it does not emit branch counters. This is a tooling
limitation recorded per task text, not a missing evidence field, and it does not trigger the
fail-closed rule. The numeric line/branch `>= 85% / >= 75%` gate is asserted for Python and
TypeScript, which is where branch data exists.

## Changed-file coverage — every production file modified in Phases 1–5

### Python (Phases 1–2), from `artifacts/python/lcov.info`

| File | Line % | Branch % | Line >= 85% | Branch >= 75% |
|---|---|---|---|---|
| `scripts/dev_tools/validate_orchestrator_state.py` | 97.50% (156 / 160) | 92.86% (78 / 84) | pass | pass |
| `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` | 100.00% (19 / 19) | 100.00% (10 / 10) | pass | pass |
| `scripts/dev_tools/_orchestrator_state_step_status.py` (new in [P1-T4]) | 100.00% (24 / 24) | 100.00% (10 / 10) | pass | pass |
| `scripts/dev_tools/compute_complexity_floor.py` | 100.00% (16 / 16) | 100.00% (2 / 2) | pass | pass |

### PowerShell (Phases 3–4), from `artifacts/pester/powershell-coverage.xml`

| File | Commands covered / analyzed | Command % | Lines covered / analyzed | Line % | Branch |
|---|---|---|---|---|---|
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 144 / 149 | 96.64% | 103 / 106 | 97.17% | not reported by Pester 5 (CoverageGutters format measures commands, not branches) |
| `.claude/lib/model-routing/ModelRouting.psm1` | 51 / 51 | 100.00% | 46 / 46 | 100.00% | not reported by Pester 5 (CoverageGutters format measures commands, not branches) |

The byte mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/**`
carry identical content (verified byte-identical in [P6-T14]) and are not separately instrumented.

### TypeScript (Phase 5), from `extensions/drm-copilot/coverage/lcov.info`

| File | Baseline line % | Post line % | Baseline branch % | Post branch % | Threshold | Result |
|---|---|---|---|---|---|---|
| `src/lib/validate/orchestrator-state-core.ts` | 98.28% (399 / 406) | 98.45% (446 / 453) | 94.20% (65 / 69) | 94.52% (69 / 73) | 85 / 75 (per-file `coverageThreshold`) | pass |

## Conclusion

- Every recorded value is numeric; no placeholder and no `UNVERIFIED` appears in this artifact.
  The only non-numeric cell is the PowerShell branch cell, which records the Pester 5 tooling
  limitation as directed by the task text.
- Line coverage >= 85% and branch coverage >= 75% hold for Python and TypeScript, both repo-wide
  and on every changed production file.
- No coverage regression on changed lines in any language: every repo-wide and per-file metric is
  equal to or higher than its baseline.
- Acceptance ([P6-T15]) met: the outcome is PASS, not remediation-required.
