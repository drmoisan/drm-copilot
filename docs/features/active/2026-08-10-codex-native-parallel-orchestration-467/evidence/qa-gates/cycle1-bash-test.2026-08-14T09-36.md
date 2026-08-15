# Cycle 1 Bash Test and Coverage Gate

Timestamp: `2026-08-15T00:25:00.7052450-04:00`

Plan task: `[P5-T14]`

Command: `wsl.exe -d Ubuntu --cd C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25 -- bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/cycle1-bash-kcov.2026-08-14T09-36' bash scripts/bash/shell-qc.sh test --coverage"`

- EXIT_CODE: `0`
- Output Summary: Bats emitted TAP plan `1..255`; all `255/255` tests passed and no `not ok` result was emitted.
- Cobertura path: `evidence/qa-gates/cycle1-bash-kcov.2026-08-14T09-36/cov.xml`.
- Cobertura SHA-256: `0C936506F4C73BAF09ADD135951AF05ADECA81D20720745EEC8237AB59570B7E`.
- Line coverage: `1,339/1,461 = 91.6%` (`PASS`, threshold >=85%).
- Branch coverage: `N/A/not-PASS`. The Bash-specific policy does not establish a source-attributable numeric branch denominator from this kcov report; the report's placeholder branch attributes are not claimed as measured branch coverage.
- Bats warnings were limited to expected missing-tool negative scenarios and did not change the zero process exit or TAP pass count.

Acceptance result: `PASS` for the applicable Bash gates. Numeric line coverage passes, all tests pass, and branch coverage remains explicitly `N/A/not-PASS`.
