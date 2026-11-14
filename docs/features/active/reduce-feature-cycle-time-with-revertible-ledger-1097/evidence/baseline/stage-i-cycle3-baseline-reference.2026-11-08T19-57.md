# Stage I Cycle 3 Baseline Reference

Timestamp: 2026-11-08T19-57
Command: no suite was run; figures read from the greatest stage-i-powershell-test.*.md, stage-i-python-test.*.md, stage-i-typescript-test.*.md, stage-i-powershell-static.*.md, stage-i-python-static.*.md, stage-i-typescript-static.*.md, and stage-i-ledger-state.*.md under evidence/baseline/
EXIT_CODE: 0
Output Summary:
  PowerShell test (stage-i-powershell-test.2026-11-08T16-40.md): ExitCode 0; 19872 testcases, 19862 passed, 0 failed, 0 errors, 10 skipped. Repo-wide line 95.6% (35614 of 37254). OrchestratorStateEpicWaveBarrier.psm1 100% (109 of 109); .claude/hooks/enforce-epic-wave-barrier.ps1 97.92% (94 of 96); .codex/hooks/enforce-epic-wave-barrier.ps1 95.74% (135 of 141).
  Python test (stage-i-python-test.2026-11-08T16-40.md): 16538 passed, 6 skipped, 0 failed. Repo-wide line 97.11% (34287 of 35308), branch 94.36% (12644 of 13400). scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py line 100.00% (35 of 35), branch 100.00% (16 of 16).
  TypeScript test (stage-i-typescript-test.2026-11-08T16-42.md): 338 suites, 5446 tests passed, 0 failed. src/lib/validate/epic-orchestrator-state-core.ts lines 98.78% (486 of 492), branches 93.55% (87 of 93). Totals: statements 97.13% (63473 of 65347), branches 93.81% (9666 of 10303), functions 92.09% (1900 of 2063), lines 97.13% (63473 of 65347).
  New stage I files with no pre-change run (judged against thresholds; cycle 3 requires 100% lines for both siblings): .claude/hooks/epic-wave-barrier-early-start.ps1, .codex/hooks/epic-wave-barrier-early-start.ps1, extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-wave-barrier.ts.
  PowerShell static (stage-i-powershell-static.2026-11-08T16-22.md): 4 files checked, 0 needing format; PSSA 0 findings.
  Python static (stage-i-python-static.2026-11-08T16-22.md): Black 0 files needing format; Ruff 0 findings; Pyright 0 errors, 0 warnings.
  TypeScript static (stage-i-typescript-static.2026-11-08T16-22.md): Prettier 0 files needing format; ESLint 0 findings; tsc 0 errors.
  Ledger state (stage-i-ledger-state.2026-11-08T16-43.md): Test-ProcessReductionLedger IsValid True, 0 errors, 9 index rows; Invoke-ProcessReductionChain IsValid True, 0 errors, 9 entries.
