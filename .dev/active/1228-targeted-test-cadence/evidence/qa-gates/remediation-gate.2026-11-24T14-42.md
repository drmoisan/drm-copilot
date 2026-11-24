# Remediation Gate - Issue #1228, remediation cycle 2 ([P1-T8]), pass 1

Timestamp: 2026-11-24T14-42
Plan: remediation-plan.2026-11-24T10-50.md
Command: `sh SCRATCH/issue-1228-c2gate.sh c2g1`, which runs in order `sh SCRATCH/issue-1228-pstatic.sh gc2g1` (pwsh 7 at the item worktree root: `Invoke-PoshQCFormat -Root <worktree root>` with `git status --porcelain` before and after, `Invoke-PoshQCAnalyze -Root <worktree root>` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `Invoke-PoshQCLeakScan -Root <worktree root>`, `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` and `-Surface instructions -Check`), `sh SCRATCH/issue-1228-pystatic.sh gc2g1`, then the launcher `pester -TestPath <union>`, `pytest <union>`, and `jest-extension --testPathPatterns` stages
EXIT_CODE: 1
Output Summary:
- Result: FAIL at stage 2; the gate restarts from step 1 in pass 2, written to a new artifact.
- Stage 1, format: `Invoke-PoshQCFormat` EXIT_CODE 0, 1892 files visited, 0 reformatted; `git status --porcelain` identical before and after (True). `black --check` EXIT_CODE 0, "1071 files would be left unchanged."
- Stage 2, lint: `Invoke-PoshQCAnalyze` EXIT_CODE 1: "Invoke-ScriptAnalyzer failed for .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 (System.Management.Automation.ParameterBindingException): A parameter cannot be found that matches parameter name 'Function'." The file is not changed by this cycle or by the branch. `Invoke-PoshQCLeakScan` EXIT_CODE 0 ("Leak scan: 914 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures."); `ruff check .` EXIT_CODE 0.
- Stage 3: `pyright` EXIT_CODE 0, "0 errors, 0 warnings, 0 informations". Stage 6: both harness `-Check` runs EXIT_CODE 0 ("harness-generation: no drift"); Codex generator `--check` EXIT_CODE 0.
- Diagnosis: a standalone re-run of `Invoke-PoshQCAnalyze -Root <worktree root>` (`pwsh -NoProfile -File SCRATCH/issue-1228-c2-analyze.ps1`, started 2026-11-24T14-35-53) exited 0 with no finding, so the failure is a transient analyzer invocation error on an unchanged file, not a finding. No file was changed for it.
- Stage 5 was not completed: the pass-1 process tree (this run's own processes only) was stopped while its Pester stage waited for the machine test-suite lock, because a stage-2 failure requires a restart from step 1.
