# QA Gate: Coverage Delta

Timestamp: 2026-11-03T12-55
Task: [P7-T4]
Command: comparison of `evidence/baseline/shell-coverage.2026-11-03T12-30.md` (CI run 41634792230) with `evidence/qa-gates/shell-coverage.2026-11-03T12-55.md` (CI run 41638835200); values read from each run's `cov.xml` artifact
EXIT_CODE: 0
Output Summary: PASS. Aggregate 95.2% to 95.3% (at least 85); MLIB new-code rate 97.0% (at least 85); `cleanup_worktrees_preserve_lib.sh` 90.6% to 90.8% (not below baseline).

| Scope | Baseline line rate | Post-change line rate | Delta | Threshold | Result |
|---|---|---|---|---|---|
| Aggregate (`Bash coverage (lines):`) | 0.952 (3272/3437) | 0.953 (3375/3543) | +0.001 | at least 0.85 | PASS |
| `cleanup_worktrees_preserve_merge_lib.sh` (new code) | not present | 0.970 | new | at least 0.85 | PASS |
| `cleanup_worktrees_preserve_lib.sh` | 0.906 | 0.908 | +0.002 | not below baseline | PASS |
| `cleanup-worktrees.sh` (reference) | 0.976 | 0.977 | +0.001 | not below baseline | PASS |

Branch coverage is not measured for bash (kcov), per `.claude/rules/general-unit-test.md`.
