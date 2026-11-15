# Final Pester gate compared with the Phase 0 baseline

Timestamp: 2026-11-15T01-16
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (launcher pester suite, one Invoke-PoshQCParallelTest run, 8 workers)
EXIT_CODE: 0
Output Summary: tests=26885, failures=0, errors=0, disabled=22 (wall-clock 753.47 s).
Baseline (pester-gate artifact of Phase 0): tests=26852, failures=0, disabled=22. Difference: +33 tests (30 new helper tests, 3 new parameterized cases of the CiChangeScope gating test), no new failing test.
Repo-wide line coverage: 96.00% (covered 44336, missed 1847) against baseline 96.01% (covered 44274, missed 1840). The 0.01 point difference is the 7 uncovered lines of the new file (the RootPath parameter default, the default ReadText and write seams in the entry function parameters, and the guarded entry call); no existing production file lost coverage.
Per-file: scripts/ci/Select-PythonTestShard.ps1 89.86% (62 covered, 7 missed), at least the 85% threshold (new file, no pre-change run); scripts/powershell/PoshQC/PoshQC.Shard.psm1 100% (baseline 100%); scripts/ci/Invoke-CiRequiredGate.ps1 90% (baseline 90%); scripts/ci/CiRequiredGate.psm1 100% (baseline 100%).
Comparison: no new failing test; no per-file drop for any file with a baseline; the new file meets the threshold; repo-wide percentage is 0.01 points lower solely because of the new file's entry lines.
