# Bash Tests and Coverage Baseline

Timestamp: 2026-08-12T05-30

Command: `wsl.exe -d Ubuntu --cd 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25' -- bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/bash/kcov' bash scripts/bash/shell-qc.sh test --coverage"`

WSL Inner Command: `bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/bash/kcov' bash scripts/bash/shell-qc.sh test --coverage"`

EXIT_CODE: 0

Output Summary: Bats passed all 255 tests. Kcov reported `Bash coverage (lines): 91.6%`; the retained Cobertura file records 1,339 covered lines out of 1,461 valid lines with `line-rate=0.916`. The test output included four Bats BW01 warnings from intentional missing-tool fixture cases; those expected cases passed and did not affect the command exit code.

Cobertura Output: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/bash/kcov/cov.xml`
