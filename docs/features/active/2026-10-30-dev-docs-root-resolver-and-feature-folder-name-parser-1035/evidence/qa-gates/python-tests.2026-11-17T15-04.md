# Python Test Gate (Remediation Cycle 1, P3-T2)

Timestamp: 2026-11-17T15-04
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1035-cov-p3.json --junitxml=SCRATCH/issue-1035-junit-p3.xml -q (sh SCRATCH/issue-1035-pytest.sh p3; the P0-T2 form: the launcher runs poetry run pytest -n auto over testpaths `tests` with the integration and golden lanes excluded; artifacts/python/lcov.info written through the project addopts). Figures read with SCRATCH/issue-1035-pyfig.py; the per-module comparison with the Phase 0 JSON report by SCRATCH/issue-1035-pycmp.py.
EXIT_CODE: 0
Output Summary: 17111 passed, 6 skipped, 0 failed, 0 errors (JUnit: 17117 tests). Repo-wide (`--cov=scripts`): line 96.60% (17715/18338), branch 92.38% (6182/6692); Phase 0 (python-tests.2026-11-17T12-36.md in evidence/remediation-baseline/): line 96.24%, branch 92.07%. Run 2026-11-17T15-00-34 to 15-03-54 UTC at HEAD e10f769352dffd18ac3608d74c41fd2c4db6244c.

| Module | Line % (Phase 0) | Line % (final) | Branch % (Phase 0) | Branch % (final) | Target | Status |
| --- | --- | --- | --- | --- | --- | --- |
| scripts.dev_tools.copy_research_to_issue | 50.00 (41/82) | 100.00 (82/82) | 46.15 (12/26) | 100.00 (26/26) | line 85, branch 75 | met |
| scripts.dev_tools.plan_progress_report | 82.35 (84/102) | 99.02 (101/102) | 84.62 (22/26) | 96.15 (25/26) | line 85 | met |
| scripts.dev_tools.atomic_executor.cli | 89.07 (163/183) | 93.44 (171/183) | 73.08 (38/52) | 82.69 (43/52) | branch 75 | met |

Report freshness: the last commit touching a `.py` file is 6ba112a132344802b04d8d4d540dbe83971ae0cd, committed 2026-11-17T08:47:50-05:00 (13:47:50 UTC); artifacts/python/lcov.info was written 2026-11-17T15-03-42 UTC, after that commit.

Per-module comparison with the Phase 0 report (229 modules in both): no line-coverage drop in any module. One module outside the F1 set shows a one-branch difference: scripts/dev_tools/atomic_executor/cli_copilot_runtime.py branch 70.45% (31/44) at Phase 0 and 69.32% (30/44) here, with identical missing lines in both runs. The only differing branch is the arc from the idle-timeout check back to the top of the read loop in `_stream_copilot_output` (taken when an idle timeout is set and the child process is still running after a 0.1 s queue wait), which depends on thread timing in the existing streaming tests. Neither that module nor any test that exercises it changed in this cycle (`git diff --stat <Baseline-Head>` lists neither), so the difference is recorded as a timing-dependent observation, not a regression introduced by this cycle; the gate was not re-run because no fix applies.
