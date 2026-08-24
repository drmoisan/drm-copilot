# TypeScript lcov Machine-Readable Verification — R1 (Remediation Cycle 1)

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Command: `pwsh` lcov parse over `extensions/drm-copilot/coverage/lcov.info` aggregating `SF:`/`LF:`/`LH:`/`BRF:`/`BRH:` records per `end_of_record`, filtered to the four in-scope modules; repo-wide totals taken from the `npm run test:coverage` text-summary reporter.
- EXIT_CODE: 0

## Output Summary

### Per-file resolution (all four modules present in the regenerated lcov)

| Module | LH/LF | Line % | BRH/BRF | Branch % | Line >= 85% | Branch >= 75% |
|---|---|---|---|---|---|---|
| `poshqc-scan-config.ts` | 220/228 | 96.49% | 31/35 | 88.57% | PASS | PASS |
| `poshqc-terminal-output.ts` | 140/141 | 99.29% | 16/16 | 100% | PASS | PASS |
| `poshqc-folder-picker.ts` | 190/190 | 100% | 29/29 | 100% | PASS | PASS |
| `poshqc-command-registration.ts` | 181/192 | 94.27% | 18/21 | 85.71% | PASS | PASS |

### Repo-wide totals vs. baseline (no regression)

| Metric | Baseline | Post-remediation | Delta |
|---|---|---|---|
| Lines | 31877/32985 = 96.64% | 32547/33631 = 96.77% | +0.13 pp |
| Branches | 4056/4577 = 88.62% | 4149/4673 = 88.78% | +0.16 pp |

Repo-wide line and branch coverage both increased versus the baseline; there is no regression. The three new modules (`poshqc-scan-config.ts`, `poshqc-terminal-output.ts`, `poshqc-folder-picker.ts`) plus `poshqc-command-registration.ts` are all present in the lcov with line coverage >= 85% and branch coverage >= 75%. R1 is machine-readably resolved.
