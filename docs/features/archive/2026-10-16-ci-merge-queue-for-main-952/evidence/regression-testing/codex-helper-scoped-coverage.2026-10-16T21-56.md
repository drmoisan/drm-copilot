# Codex helper scoped coverage run (R1 evidence; remediation-inputs R1 step 1 / CR-15)

Timestamp: 2026-10-16T21-56
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/codex-hooks]
EXIT_CODE: 0
Output Summary:
Scoped run of tests/scripts/codex-hooks only, at HEAD b844048d9 (tree of R_final_3 head 11242f03a plus feature-folder files only)
artifacts/pester/pester-junit.xml (written 21:55:38 UTC by this run): 1806 testcases, 0 failed, 0 skipped, every testcase under tests/scripts/codex-hooks
artifacts/pester/powershell-coverage.xml (written 21:55:06 UTC by this run): .codex/hooks/enforce-epic-merge-gate-command.ps1 line=100.00 (covered 54, missed 0)
CODEX_HELPER_SCOPED_COVERED_LINES=23,26,29,32,45,46,47,64,65,66,67,68,70,71,72,86,87,88,89,90,91,93,107,108,109,111,131,132,134,135,137,158,159,160,161,162,163,164,165,166,168,169,170,171,172,174,177,179,182,183,184,185,186,189
CODEX_HELPER_SCOPED_UNCOVERED_LINES=
CLAUDE_HELPER (not loaded by this scope): covered none
LOCAL_COVERAGE_RUN=PERFORMED

## Result

In a run that contains only the Codex suites, the fourteen Codex helper lines that the full CI run (R_final_2 38933561015 and R_final_3 38967059138) reports as uncredited — 67, 68, 72, 165, 166, 171, 172, 179, 182, 183, 184, 185, 186, 189 — are all credited (`ci` greater than 0), and the file measures 100.00% line coverage. The Codex suites therefore execute every executable line of the Codex helper in-process; the full-run figure of 74.07% is an attribution effect of the combined run, consistent with the issue #936 breakpoint-binding mechanism (the earlier full-run loader `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1` compiles the Codex helper first; later compiled instances carry no bound breakpoints).

## Correction to earlier statements

The cycle-2 diagnosis (`codex-helper-coverage-diagnosis.2026-10-16T20-01.md`) and `coverage-comparison.2026-10-16T21-28.md` state that remediation-inputs R1 step 1 was not performed because no PowerShell launcher was available. That step is performed here through the PoshQC MCP test tool, as the cycle-2 re-audit (CR-15) noted; the MCP runner's coverage population now includes the new helper file (an earlier local run in this session, before the population included it, did not report the helper). The `pwsh` invocation route remains refused by the worktree-isolation guard; the MCP route needs no `pwsh` command text.

The scoped coverage file is a local, gitignored artifact (`artifacts/pester/`) and is not committed; its values are recorded above.
