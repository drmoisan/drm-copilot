# Task Check — [P1-T2] [expect-fail]

Timestamp: 2026-11-13T18-36
Command: sh SCRATCH/issue-1160-r4-tc.sh (pwsh 7: Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the changed file; Invoke-Pester through New-PesterConfiguration with Run.Path set to the two classification runners)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: static 0 formatter differences, 0 analyzer findings (163 lines); Pester passed 256, failed 32, total 288. The 32 failures are exactly the expected ones: `classifies existing-denial row ED-43` to `ED-50` and `denies existing-denial row ED-43` to `ED-50 with the generic deny text`, in the Claude runner and in the Codex runner (8 rows x 2 tests x 2 runners). Every other row (ED-01 to ED-42, FP-01 to FP-17, NG-01 to NG-09) passes.

- Changed file: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (rows ED-43 to ED-50 appended; header `ExistingDenial` line names D16).
- Selection rule: every test file that dot-sources the changed file: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1`. The bookkeeping-leg runners also dot-source the file but read only the BL and DW tables, which are unchanged; they run in the [P1-T4] gate.
- Row check: 50 existing-denial identifiers, 50 unique; the seven F1 command strings are copied verbatim from `remediation-inputs.2026-11-13T17-44.md` (F1, `Observed:`) in order, and ED-50 is `sort --compress-program pytest big.txt`.
