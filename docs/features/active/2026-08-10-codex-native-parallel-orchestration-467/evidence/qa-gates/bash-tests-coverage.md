# Bash Tests and Coverage QA

## Invocation-wrapper failure before test execution

Task: [P12-T3]

Timestamp: 2026-08-12T10:20:26-04:00

Command: attempted PowerShell wrapper for `wsl.exe -d Ubuntu --cd '<workspace>' -- bash -lc "SHELL_QC_KCOV_OUT_DIR='<canonical evidence path>' bash scripts/bash/shell-qc.sh test --coverage"`

EXIT_CODE: 1

Output Summary: PowerShell rejected the wrapper expression with `ParserError: Unexpected token 'SHELL_QC_KCOV_OUT_DIR=...'` before `wsl.exe`, Bats, or kcov executed. This is launcher/configuration evidence only; it is not a Bash test failure and supplies no coverage result. No source or test file changed. The invocation quoting was corrected and the Phase 12 loop restarted at P12-T1 as required.

Acceptance result: NOT ACCEPTED; no test process started.

## Corrected uninterrupted-green test and coverage pass

Task: [P12-T3]

Timestamp: 2026-08-12T10:22:36.6342702-04:00

Command: `wsl.exe -d Ubuntu --cd 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25' -- bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-kcov' bash scripts/bash/shell-qc.sh test --coverage"`

EXIT_CODE: 0

Output Summary: Bats passed all 255 tests. The four BW01 warnings are produced by intentional missing-tool fixture cases; those cases passed and did not change the command result. Kcov reported `Bash coverage (lines): 91.6%`. The retained Cobertura report records 1,339 covered lines out of 1,461 valid lines (`line-rate=0.916`). This equals the P0-T11 baseline of 1,339/1,461 = 91.6%, so line coverage did not regress and remains above the 85% threshold.

Branch coverage: unsupported by the configured Bash/kcov aggregation. Although kcov writes placeholder Cobertura branch attributes (`branch-rate=1.0` and `branches-covered=1.0`), the toolchain does not measure an attributable branch denominator. Branch coverage is explicitly unsupported and is not treated as PASS.

Cobertura Output: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-kcov/cov.xml`

Cobertura SHA-256: `5B91797718E009E311533B4AC07E4024E571BA4A1D78E080B5EA059A4D4CCF80`

Artifact and size checks:
- The canonical `bash-kcov/` evidence subtree contains 87 retained files totaling 2,617,719 bytes, including `cov.xml` and the merged kcov report.
- No `artifacts/pester/kcov-bats` directory or other default-output copy remains.
- The tracked 35-file shell scope contains zero files above 500 lines; the maximum is 479 lines.
- No shell production or test file differs from the merge base, and the tracked shell scope retained SHA-256 `AE93A7F6B30DE0B35CB62816015C10D88874DDFC270B9C3A863D90FF9C6E5EF6` through the final pass.

Acceptance result: PASS.
