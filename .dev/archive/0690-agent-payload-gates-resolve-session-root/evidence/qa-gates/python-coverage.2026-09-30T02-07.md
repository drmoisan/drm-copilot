# Repository Python Coverage (P1-T2, RF-1)

Timestamp: 2026-09-30T02-07
Command: git log -1 --format=%cI HEAD; sh SCRATCH/run-ps.sh SCRATCH/lcov-totals.ps1 -LcovPath artifacts/python/lcov.info -ChangedFile tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py
EXIT_CODE: 0
Output Summary:
- HEAD commit time: 2026-09-29T22:06:19-04:00 (2026-09-30T02:06:19Z)
- LCOV-MTIME-UTC=2026-09-30T02:07:34Z (later than the HEAD commit time)
- LCOV-LINES LF=16307 LH=15183 LinePercent=93.11
- LCOV-BRANCHES BRF=5924 BRH=5090 BranchPercent=85.92
- CHANGED-FILE-IN-LCOV=False: the changed Python file is test code outside the coverage measurement; no per-file threshold applies.
- P1-T1 failing nodes: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts (KL-510, pre-existing).
- Disposition: PASS (line 93.11 >= 85, branch 85.92 >= 75)
