# TypeScript Test Coverage Regeneration — R1 (Remediation Cycle 1)

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Command: `npm run test:coverage` (in `extensions/drm-copilot/`; `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)
- EXIT_CODE: 0

## Output Summary

- Test result: 140 suites passed / 140 total; 1640 tests passed / 1640 total; 0 failures.
- `extensions/drm-copilot/coverage/lcov.info` regenerated in this run (post-remediation worktree state).
- Repo-wide coverage (text-summary):
  - Lines: 96.77% (32547/33631)
  - Statements: 96.77% (32547/33631)
  - Branches: 88.78% (4149/4673)
  - Functions: 87.8% (936/1066)
  - The line denominator grew from the baseline 32985 to 33631 and the branch denominator from 4577 to 4673, confirming the three new modules are now included in the regenerated artifact.

### Per-file figures (four in-scope modules)

| Module | Lines | Line % | Branches | Branch % |
|---|---|---|---|---|
| `src/poshqc-scan-config.ts` | 220/228 | 96.49% | 31/35 | 88.57% |
| `src/poshqc-terminal-output.ts` | 140/141 | 99.29% | 16/16 | 100% |
| `src/poshqc-folder-picker.ts` | 190/190 | 100% | 29/29 | 100% |
| `src/poshqc-command-registration.ts` | 181/192 | 94.27% | 18/21 | 85.71% |

All four modules exceed line >= 85% and branch >= 75%. R1 (stale lcov omitting the new modules) is resolved: the regenerated lcov contains all four modules with real per-file coverage.
