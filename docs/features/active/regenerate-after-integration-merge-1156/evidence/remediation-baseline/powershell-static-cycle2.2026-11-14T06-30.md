# PowerShell Static Baseline — remediation cycle 2, [P0-T1]

Timestamp: 2026-11-14T06-30
Command: sh SCRATCH/issue-1156-static.sh (pwsh 7 from the item worktree root; per file a check-only Invoke-Formatter -ScriptDefinition comparison with -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, and Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; read-only, no file written)
EXIT_CODE: 0
Output Summary:
- `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`: formatter differences 0, analyzer findings 0, logical line count 788.
- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.ProcessStart.Tests.ps1`: formatter differences 0, analyzer findings 0 (113 lines).
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`: formatter differences 0, analyzer findings 0 (319 lines).
- Totals: 0 formatter differences, 0 findings. Head eaa4d8e64 (merged with origin/main; origin/main not advanced at 06:29 UTC).
- `Phase 0 baseline` gate runs reused, not re-run: Pester `evidence/qa-gates/pester-gate.2026-11-14T06-14.md` (merged head; 24724 tests, 0 failures; repo-wide 95.94%; adapter 91.28%) and pytest `evidence/baseline/pytest-parallel.2026-11-10T03-53.md` (16598 passed, 0 failed; line 97.11%, branch 94.37%).
- Preflight: single-pass review found no defect; PREFLIGHT: ALL CLEAR, no in-place fix, so no preflight-fix record was written.
