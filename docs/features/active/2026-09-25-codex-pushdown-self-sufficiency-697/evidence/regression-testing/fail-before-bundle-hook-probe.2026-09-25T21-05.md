# Fail-Before: Bundle Hook Probe (Issue #697, AC-2.4 red)

Timestamp: 2026-09-25T21-05
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `Tests Passed: 2, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0`.
- Passed: `derives 17 PreToolUse hooks and excludes 4 non-PreToolUse registrations from the bundle config`; `leaves no batch-budget state in the bundle`.
- Failed: `returns exit 0 and empty or hookSpecificOutput stdout for every PreToolUse hook and admitted payload from the bundle location`.
- Failure list (exactly four entries, all `enforce-epic-planning-only.ps1`, each exit 1; host paths replaced per rule 3):
  - `enforce-epic-planning-only.ps1 x Bash: exit=1 stdout=[]`
  - `enforce-epic-planning-only.ps1 x apply_patch: exit=1 stdout=[]`
  - `enforce-epic-planning-only.ps1 x Edit: exit=1 stdout=[]`
  - `enforce-epic-planning-only.ps1 x mcp__drm_copilot__run_poshqc_format: exit=1 stdout=[]`
  - Each stderr: `Exception: <WORKSPACE_ROOT>\extensions\drm-copilot\resources\codex-and-agents-customizations\.codex\hooks\enforce-epic-planning-only.ps1:58:9 ... EPIC_PLANNING_ONLY_BLOCKED: semantic MCP registry '<WORKSPACE_ROOT>\extensions\drm-copilot\resources\codex-and-agents-customizations\config\orchestration-handoff-registry.json' does not exist.`
- No other hook appears in the failure list.
