# QA Gate: Coverage Delta (loop pass 2)

Timestamp: 2026-11-03T13-12
Task: [P7-T4] (re-run after the self-review remediation)
Command: comparison of `evidence/baseline/shell-coverage.2026-11-03T12-30.md` (CI run 41634792230) with `evidence/qa-gates/shell-coverage.2026-11-03T13-12.md` (CI run 41640864723); values read from each run's `cov.xml` artifact
EXIT_CODE: 0
Output Summary: PASS. Aggregate 95.2% to 95.3% (at least 85); MLIB new-code rate 99.0% (at least 85); `cleanup_worktrees_preserve_lib.sh` 90.6% to 90.8% (not below baseline).

| Scope | Baseline line rate | Post-change line rate | Delta | Threshold | Result |
|---|---|---|---|---|---|
| Aggregate (`Bash coverage (lines):`) | 0.952 (3272/3437) | 0.953 (3377/3543) | +0.001 | at least 0.85 | PASS |
| `cleanup_worktrees_preserve_merge_lib.sh` (new code) | not present | 0.990 | new | at least 0.85 | PASS |
| `cleanup_worktrees_preserve_lib.sh` | 0.906 | 0.908 | +0.002 | not below baseline | PASS |
| `cleanup-worktrees.sh` (reference) | 0.976 | 0.977 | +0.001 | not below baseline | PASS |

Branch coverage is not measured for bash (kcov), per `.claude/rules/general-unit-test.md`.
