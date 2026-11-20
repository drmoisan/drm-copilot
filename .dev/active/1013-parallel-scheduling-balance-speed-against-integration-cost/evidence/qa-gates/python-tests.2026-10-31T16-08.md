# QA Gate — Python Tests and Coverage

Timestamp: 2026-10-31T16-08
Command: poetry run pytest -q -p no:cacheprovider --cov=scripts.dev_tools._blast_radius_scheduling --cov=scripts.dev_tools._blast_radius_aggregate --cov=scripts.dev_tools._blast_radius_combination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1013-final-cov.json
EXIT_CODE: 0
Output Summary: full repository Python suite (including the architecture-boundary and schema-compatibility tests it carries): 16055 passed, 6 skipped, 0 failed in 591.48s. Per-file coverage from the JSON report: `_blast_radius_scheduling.py` line 100.00% (158/158), branch 100.00% (36/36); `_blast_radius_aggregate.py` line 100.00% (35/35), branch 100.00% (10/10); `_blast_radius_combination.py` line 98.75% (79/80), branch 91.67% (22/24). Each is at or above 85% line and 75% branch.

Skips: `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` in `test_blast_radius_regression_452.py` (unconditional marker, unchanged) and the five `manifest_m1_*` accessor-expectation skips of `test_parallel_manifest_bash_parity.py`.
