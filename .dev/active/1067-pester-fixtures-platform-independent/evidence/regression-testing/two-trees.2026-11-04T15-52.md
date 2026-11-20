# Final QA — two-tree single-process run (P3-T3)

Timestamp: 2026-11-04T15-52
Command: sh SCRATCH/issue-1067-runpaths.sh qa-twotrees "tests/scripts/dev-tools,tests/scripts/powershell/PoshQC" (one fresh pwsh -NoProfile process, files in sorted order, no shuffle)
EXIT_CODE: 0

```
TOTAL Tests=953 Passed=944 Failed=0 Skipped=9 NotRun=0
CONTAINERS Total=61 Failed=0
PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent
PROBE GH-FUNCTION=absent
PROBE GLOBAL_PROMPT_CHANGED=False
PROBE LEAKED_GLOBAL_FUNCTIONS=0 (of 7 names)
```

All 61 `FILE` lines report `failed=0` (count of lines with a non-zero failed value: 0). The 9 skipped tests are the same pre-existing skips as the P0-T8 baseline, outside the change set.

Output Summary: Tests=953 (equal to P0-T8), Failed=0, every FILE line failed=0; at the end of the run PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent and PROBE GH-FUNCTION=absent, against =1 and present in the P0-T8 baseline. No suite under tests/scripts/powershell/PoshQC sets the variable, so this run covers the tests/scripts/dev-tools verification of R1-F1.
