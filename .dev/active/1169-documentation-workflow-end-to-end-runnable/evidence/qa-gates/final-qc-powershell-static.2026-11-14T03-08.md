# Final-QC PowerShell Static (Remediation Cycle 1, P4-T1)

Timestamp: 2026-11-14T03-08
Command: sh SCRATCH/issue-1169-tc.sh R1-P4-T1 "<68 files>" "" (pwsh 7: per file, Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared in memory with the file text, then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, one retry on an analyzer exception); sh SCRATCH/issue-1169-leak.sh (Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
- File set: every .ps1, .psm1, and .psd1 file in `git diff --name-only --diff-filter=d <merge base of origin/main and HEAD>` plus untracked PowerShell files: 68 files (no untracked file).
- Step 1 format (check-only, drift count): 0; exit 0.
- Step 2 analyzer (PSScriptAnalyzer 1.25.0, repository settings): 0 findings; exit 0. One analyzer retry: tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1 raised the known PSScriptAnalyzer NullReferenceException on the first attempt and analyzed cleanly on the retry.
- Step 3 type check: not applicable to PowerShell.
- Leak scan: 774 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures; exit 0.
- `git status --porcelain` before and after the run: identical (the run rewrote no file).
- Change carried into this loop (decision under OD-1, recorded here): codex-hooks/enforce-orchestration-preimplementation-gate-docs.Tests.ps1 gained an `empty text` parse case and the row `classifies <Path> as <Expected> under a narrow profile with a flat artifact path (codex)` (docs/reference/b.md true, docs/documentation-estate/x.json true, docs/other/a.md false). Rationale: the P3 phase gate measured the .codex copy of hook-docs-estate-context.ps1 at 94.83%, below its P0-T2 reference of 96.55%, because no Codex row reached the flat-artifact `continue` or the final `return $false` after CR3; P4-T4 requires no drop. A focused debug run of that suite (not a gate) passed 55 rows and left only one command missed, on a line whose other branch executes. The test file is in this static file set and is clean.
