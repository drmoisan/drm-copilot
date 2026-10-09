# Hook-Load Parse Check (Wave Transition)

Timestamp: 2026-10-08T23-30
Command: sh SCRATCH/parsecheck.sh <worktree-root>  (wraps: pwsh -NoProfile -File SCRATCH/parsecheck.ps1 -Root <worktree-root>; the script calls [System.Management.Automation.Language.Parser]::ParseFile on every *.ps1 and *.psm1 under .claude/hooks, .claude/lib, and .codex/hooks)
EXIT_CODE: 0
Branch: bug/validate-orchestrator-output-session-relative-read-exec-787
Branch tip: 497cb504 (origin/epic/enforcement-hook-precision-integration at branch creation)
Output Summary:
FILES-PARSED: 140
PARSE-FAILURES: 0

Purpose: wave 0 of epic #852 changed enforcement hooks. This check confirms that every PowerShell hook and library file on the branch tip parses without errors before Phase 0 begins.
