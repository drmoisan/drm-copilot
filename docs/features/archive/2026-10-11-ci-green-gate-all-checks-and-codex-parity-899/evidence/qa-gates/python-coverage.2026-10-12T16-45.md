# Python Coverage (R-1 artifact)

Timestamp: 2026-10-12T17-15

Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/issue-899-coverage.json

EXIT_CODE: 1

Output Summary:
(a) Pytest summary line (verbatim): `============ 1 failed, 7003 passed, 6 skipped in 73.58s (0:01:13) =============`
    TOTAL row (verbatim): `TOTAL                                                                 17633   1094   6364    505    92%`
(b) Python line coverage: 93.80% (threshold 85.00%)
    Python branch coverage: 88.10% (threshold 75.00%)
(c) LF 17633, LH 16539, BRF 6364, BRH 5607; LCOV_LINE 93.80; LCOV_BRANCH 88.10 (from P1-T2).
(d) Data files: `artifacts/python/lcov.info` (496475 bytes) and `artifacts/python/issue-899-coverage.json`. Both are gitignored under `/artifacts` and therefore not committed.
(e) Baseline comparison: per P0-T3 and P0-T4 the production denominator and numerator are identical on `origin/main`, so baseline line and branch figures equal FINAL_TOTAL_LINE (93.80) and FINAL_TOTAL_BRANCH (88.10) and the change is 0.00 points.
(f) New/changed production code coverage: none (no Python production file changed)
(g) Disposition: FAIL
    Reason (PD3): one non-KL-510 test failed: `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant`. Assertion: the parallel-orchestrate procedure prescribes a command invocation no parallel-orchestrator Bash grant covers: `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>` (and the parsed token `no checks reported`). Full text in the P1-T1 artifact. Both coverage thresholds are met (93.80 >= 85.00; 88.10 >= 75.00); the FAIL disposition is solely from the test failure. REMEDIATION-REQUIRED: python test failure.
(h) Pointers (under docs/features/active/2026-10-11-ci-green-gate-all-checks-and-codex-parity-899/evidence/):
    - remediation-baseline/python-diff.2026-10-12T16-45.md (P0-T3)
    - remediation-baseline/changed-test-imports.2026-10-12T16-45.md (P0-T4)
    - qa-gates/python-coverage-run.2026-10-12T16-45.md (P1-T1)
    - qa-gates/python-coverage-values.2026-10-12T16-45.md (P1-T2)
