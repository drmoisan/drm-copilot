# Python Tests and Coverage QA

Timestamp: 2026-08-12T07:44:31-04:00
Command: `$env:COVERAGE_FILE='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/.coverage-python-full'; poetry run pytest -o "addopts=" -q --cov --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/python-coverage.json`
EXIT_CODE: 0
Output Summary: Pytest passed 3,963 tests, skipped 5 tests, and failed 0 tests in 15.68 seconds. Repository line coverage was 92.41867954911433% (14,348 covered lines out of 15,525 statements), and repository branch coverage was 84.75398475398475% (4,892 covered branches out of 5,772). Both values exceed the 85% line and 75% branch floors and improve on the P0-T8 baselines of 92.16381812318608% and 84.24515235457064%.

Coverage JSON SHA-256: `17CEF330834D2F4AB776A1D355580495CE054C814FF31A9375A31C5C60521A4D`
Coverage data SHA-256: `DA637423061ED736814D0D061616C672C80BD07160F80263FB5F754A4DC02509`

## Required per-file line comparisons

Line coverage uses `percent_statements_covered` from the current coverage JSON.

| Status | Production path | Current covered/statements | Current line coverage | P0-T8 baseline | Result |
|---|---|---:|---:|---:|---|
| Added | `scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py` | 95/102 | 93.13725490196079% | 91.00000000000000% | PASS >=90% |
| Added | `scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py` | 136/145 | 93.79310344827586% | 91.60839160839161% | PASS >=90% |
| Added | `scripts/dev_tools/parallel_codex_readiness_filesystem.py` | 163/177 | 92.09039548022600% | 84.97109826589596% | PASS >=90% |
| Added | `scripts/dev_tools/push_down_codex_routing_merge.py` | 100/104 | 96.15384615384616% | 86.13861386138613% | PASS >=90% |
| Added | `scripts/dev_tools/validate_parallel_codex_readiness.py` | 184/202 | 91.08910891089108% | 86.50000000000000% | PASS >=90% |
| Modified | `scripts/dev_tools/parallel_kickoff_contract.py` | 107/109 | 98.16513761467890% | 98.11320754716981% | PASS, +0.05193006750909 pp |
| Modified | `scripts/dev_tools/resolve_codex_deployment.py` | 92/92 | 100.00000000000000% | 98.88888888888889% | PASS, +1.11111111111111 pp |
| Modified | `scripts/dev_tools/resolve_codex_topology.py` | 110/110 | 100.00000000000000% | 99.07407407407408% | PASS, +0.92592592592592 pp |

## Changed-line coverage

A read-only PowerShell comparison parsed zero-context `git diff` hunks from reviewed base `fe0413d4aca1e76b2d02d05701fba79a887d5405` and intersected added production line numbers with executable lines in the current coverage JSON. All 17 changed Python production files had numeric coverage attribution. The changed/new executable-line result was 1,079/1,149 (93.90774586597041%), above the reviewed post-change aggregate of 90.43%; no changed-line coverage regression was found.

Acceptance result: PASS - all tests passed; repository line and branch thresholds passed; each of the five added files exceeded 90% line coverage; each of the three modified files exceeded its individual P0-T8 baseline; and changed-line coverage improved.
