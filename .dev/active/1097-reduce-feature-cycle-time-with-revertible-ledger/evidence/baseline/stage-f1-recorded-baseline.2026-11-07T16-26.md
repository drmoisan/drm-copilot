# Stage F1 Recorded Baseline (read of the stage E2 Phase 0 baseline)

Timestamp: 2026-11-07T16-26
Command: read of the recorded stage E2 Phase 0 baseline artifacts under FEATURE/evidence/baseline/ (lexicographically greatest of each name): stage-e2-powershell-test-baseline.2026-11-07T14-22.md, stage-e2-python-test-baseline.2026-11-07T14-25.md, stage-e2-typescript-test-baseline.2026-11-07T14-26.md, stage-e2-powershell-static.2026-11-07T14-14.md, stage-e2-python-static.2026-11-07T14-14.md; no suite run
EXIT_CODE: 0
Output Summary:
  Sources read: 5 of 5. No existing baseline artifact was edited.
  Pester (stage-e2-powershell-test-baseline): ExitCode 0; 15656 tests, 15646 passed, 0 failed, 0 errors, 10 disabled. Repo-wide PowerShell line coverage 94.01% (24050 of 25582 lines).
  pytest (stage-e2-python-test-baseline): 16185 passed, 0 failed, 6 skipped. Totals: lines 96.72% (32362 of 33459); branches 93.69% (11766 of 12558).
  Jest (stage-e2-typescript-test-baseline): 330 of 330 suites passed; 5345 of 5345 tests passed, 0 failed. Lines 97.09% (62167 of 64030); branches 93.71% (9447 of 10081).
  PowerShell static (stage-e2-powershell-static): format targets not formatted 0; analyzer findings 0.
  Python static (stage-e2-python-static): Black 0 files to reformat; Ruff 0 findings; Pyright 0 errors; Codex generator --check 0 findings.
  Per-file figures: the five sources record no per-file coverage figure.
    SearchScope: FEATURE/evidence/baseline/ (the five sources above)
    SearchPatterns: per-file coverage rows naming any changed production file (.claude/hooks/validate-planner-output.ps1, .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1, OrchestratorStateReceipts.psm1, OrchestratorStateRemediationAccounting.psm1)
    SearchResult: none
  Changed production files in the diff from the merge base of origin/main and HEAD: the four PowerShell files above and their bundle copies; no Python or TypeScript production file.
