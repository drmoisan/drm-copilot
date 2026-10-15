# Python Diff Baseline (P0-T5, remediation cycle 2)

Timestamp: 2026-10-12T17-58

Command: git diff --name-status origin/main...HEAD -- "*.py"

EXIT_CODE: 0

Output (verbatim):

```
A	tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
```

Further commands:
- `git status --porcelain --untracked-files=all -- "*.py"`: exit 0, no output
- `git diff --exit-code 75437a6227d0a9c535edcfc11429a2c1a7dcd4c9 HEAD -- tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py`: exit 0, no output

Output Summary:
- The only `.py` path differing from `origin/main` is `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (status `A`); no production Python differs from `origin/main`.
- No untracked or modified `.py` file exists in the worktree.
- The changed test and its support module are unchanged since START, so the import proof in `evidence/remediation-baseline/changed-test-imports.2026-10-12T16-45.md` still applies.
- Baseline Python coverage (PD3 reference): line 93.80%, branch 88.10%, read from the printed line at `evidence/qa-gates/python-coverage-values.2026-10-12T16-45.md` line 10 (`TOTAL_LINE 93.8 TOTAL_BRANCH 88.1 LF 17633 LH 16539 BRF 6364 BRH 5607 SF_TOTAL 214 SF_FOREIGN 0`). This equals the baseline because no production Python differs from `origin/main`.
