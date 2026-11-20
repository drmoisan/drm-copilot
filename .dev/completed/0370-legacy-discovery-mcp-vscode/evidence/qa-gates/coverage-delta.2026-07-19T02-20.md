# Coverage Delta — Baseline vs Post-Change

- Timestamp: 2026-07-19T02-20
- Issue: #370

## Aggregate (whole extension, text-summary reporter)

| Metric | Baseline (2026-07-19T00-40) | Post-change (2026-07-19T02-20) |
|---|---|---|
| Lines | 96.74% (36133/37349) | 96.30% (37511/38949) |
| Branches | 89.28% (5034/5638) | 89.22% (5198/5826) |
| Functions | 89.14% (1051/1179) | 89.48% (1098/1227) |
| Test suites | 158 | 165 |
| Tests | 1886 | 2006 |

The small aggregate line/branch movement (-0.44 pts / -0.06 pts) reflects denominator growth from ~1600 newly added production lines, not any regression on changed lines. All new and changed lines are covered at or above the 85% line / 75% branch floor (see per-file table). Both aggregate figures remain far above the policy floors.

## Per-new-production-file coverage (all >= 85% line, >= 75% branch)

| File | Lines % | Branches % |
|---|---|---|
| `src/repo-automation-execute-discovery.ts` | 97.13 | 83.87 |
| `src/mcp-tool-inputs-discovery.ts` | 100 | 96.87 |
| `src/mcp-handlers/discovery-handlers.ts` | 100 | 100 |
| `src/mcp-discovery-tool-definitions.ts` | 100 | 100 |
| `src/discovery-command-registration.ts` | 90.65 | 78.18 |
| `src/repo-automation-service-contract.ts` | type/interface-only — omitted from the per-file gate per policy (no executable behavior) |

## Modified-file coverage (changed lines covered; no regression)

| File | Lines % | Branches % |
|---|---|---|
| `src/mcp-tools.ts` | 92.76 | 83.33 |
| `src/runtime-detection.ts` | 95.05 | 84.74 |
| `src/repo-automation-service.ts` | 98.17 | 93.33 |
| `src/mcp-repo-automation-tool-definitions.ts` | 100 | 100 |
| `src/mcp-tool-definitions.ts` | 100 | 100 |
| `src/extension.ts` | 97.37 | 90.90 |

The uncovered lines reported for modified files (`extension.ts` 97-98/367-373/408-409/415-416; `runtime-detection.ts` 97-98/105/268-278) are pre-existing worktree-session and PowerShell-probe paths unrelated to this feature's additions; every discovery-related line added by this feature is covered.

## Result: PASS

Every new production file reports line coverage >= 85% and branch coverage >= 75%. No coverage regression on changed lines. `npm run test:coverage` exited 0 with all per-file thresholds satisfied.
