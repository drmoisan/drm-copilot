# Phase 0 baseline: pytest gate with coverage ([P0-T6], stage B)

Timestamp: 2026-11-20T10-49
Command: sh SCRATCH/issue-1016-g-pytest.sh (in the worktree root: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -n auto --cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1016-coverage-baseline.json)
EXIT_CODE: 0
Output Summary: 17101 passed, 6 skipped, 0 failed in 150.26s. Terminal TOTAL: 18321 statements, 614 missed, 6686 branches, 412 partial, 96%. JSON totals: line (statements) 96.65% (17707/18321), branches 92.52% (6186/6686), combined percent_covered 95.55%. 229 measured files; per-file values are kept in SCRATCH/issue-1016-coverage-baseline.json for [P5-T5]. Hand-edit targets: scripts/dev_tools/build_discovery_runtime.py 100.00% (225/225 lines, 102/102 branches); scripts/dev_tools/discovery/init_models.py 100.00% (5/5 lines, 0 branches).
