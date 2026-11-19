# Baseline YAML Static (P0-T3)

Timestamp: 2026-11-19T08-34
Command: sh SCRATCH/issue-1050-static.sh yaml-all (actionlint -version; actionlint over the 14 tracked .github/workflows/*.yml files; scripts/dev-tools/run-actionlint.ps1 over the same files)
EXIT_CODE: 0
Output Summary: actionlint 1.7.12; zero findings over the 14 existing workflow files; wrapper exit 0.

| Step | Command | Exit code | Findings |
| --- | --- | --- | --- |
| Version | `actionlint -version` | 0 | `1.7.12` |
| Direct run | `actionlint <14 tracked workflow files>` | 0 | 0 |
| Wrapper (gate result per D5) | `scripts/dev-tools/run-actionlint.ps1 <14 tracked workflow files>` | 0 | 0 |
