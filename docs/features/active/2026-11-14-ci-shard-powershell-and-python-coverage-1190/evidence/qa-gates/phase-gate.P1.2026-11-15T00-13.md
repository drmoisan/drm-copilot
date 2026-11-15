# Phase gate P1

Timestamp: 2026-11-15T00-13
Command: stages 1 to 6 for the files changed in Phase 1 (PowerShell only): Invoke-Formatter check and Invoke-ScriptAnalyzer over scripts/ci and tests/scripts/ci; launcher pester suite (one Invoke-PoshQCParallelTest run, 8 workers); launcher pytest suite (one pytest -n auto run). Python static stages run unchanged: git status shows no Python file changed in this phase.
EXIT_CODE: 0
Output Summary: Formatter check: 17 files, 0 would change. PSScriptAnalyzer: 17 files, 0 findings. Pester gate: tests=26882 (baseline 26852, plus the 30 new helper tests), failures=0, errors=0, disabled=22, exit 0. pytest gate: 16941 passed, 6 skipped, 0 failed (baseline 16941 passed, 6 skipped), exit 0. Architecture-boundary and contract stages: covered by the same suites (no separate dependency-cruiser or contract tool applies to the changed files).
Coverage (informational, compared at P4-T2): repo-wide line coverage 96.00% (covered 44336, missed 1847; baseline 96.01%); scripts/ci/Select-PythonTestShard.ps1 89.86% (62 covered, 7 missed: the RootPath parameter default, the default ReadText and write seams, and the guarded entry call); PoshQC.Shard.psm1 100%; Invoke-CiRequiredGate.ps1 90%.
The 0.01 point repo-wide difference comes from the 7 uncovered lines of the new file and is recorded for the P4-T2 comparison.
