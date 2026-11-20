# Remediation Inputs: Claude Code architecture v2 (#136)

- **Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
- **Base Branch:** `origin/development`
- **Head Branch:** `feature/claude-code-architecture-136`
- **Triggered By:** `policy-audit.2026-04-13T09-58.md`, `code-review.2026-04-13T09-58.md`, and `feature-audit.2026-04-13T09-58.md`
- **Authoritative Requirements Source For Remediation:** this file

## Required Fixes

1. **Correct the PowerShell test-runner MCP contract in the Claude runtime**
   - **Files:** `.claude/settings.json`, `.claude/rules/powershell.md`, `.claude/agents/atomic-executor.md`, and `docs/engineering/claude-code-architecture.md`
   - **Expected behavior:** The PowerShell **test** runner must use `mcp_drmcopilotext_run_poshqc_test`, matching `.github/instructions/powershell-code-change.instructions.md` and `.github/instructions/powershell-unit-test.instructions.md`. Keep the current format/analyze/autofix symbols aligned with whatever the authoritative instructions require; do not widen the change beyond the stale test-runner symbol unless the policy source explicitly demands it.
   - **Verification commands:**
     - `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders '.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks' }"`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders 'tests/scripts/claude-runtime','tests/scripts/claude-hooks' }"`

2. **Update the runtime regression tests to assert the active PowerShell policy contract**
   - **Files:** `tests/scripts/claude-runtime/claude-settings.Tests.ps1` and `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`
   - **Expected behavior:** The tests must stop asserting the stale `mcp__drmCopilotExtension__run_poshqc_test` symbol and instead validate the active mixed contract from the authoritative PowerShell policy files.
   - **Verification commands:**
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders 'tests/scripts/claude-runtime','tests/scripts/claude-hooks' }"`

3. **Refresh post-fix evidence for the corrected PowerShell contract**
   - **Files:** new evidence under `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/` as needed, plus the three re-audit artifacts if findings are cleared
   - **Expected behavior:** The rerun evidence must prove the corrected symbol is present in runtime files and tests, and must record the current validation command outcomes. If numeric PowerShell changed/new-code coverage still cannot be emitted, record that explicitly with a concrete reason instead of leaving it implicit.
   - **Verification commands:**
     - `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders '.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks' }"`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& { Import-Module './scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root 'c:\Users\DanMoisan\repos\drm-copilot' -ScanFolders 'tests/scripts/claude-runtime','tests/scripts/claude-hooks' }"`

4. **Keep live Claude-session criteria explicit and honest**
   - **Files:** any refreshed review artifact that touches live `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, checkpoint-resume, allowlist-probe, or `SubagentStop` criteria
   - **Expected behavior:** Do not mark live-runtime criteria PASS without captured runtime transcript evidence. If the live Claude session remains unavailable, keep those criteria UNVERIFIED and carry the blocker forward without rewriting history.
   - **Verification commands:**
     - live Claude Code session commands when that environment is available

## Do Not Do

- Do not widen scope beyond the stale PowerShell test-runner contract, the affected runtime tests, and the evidence refresh needed to prove the fix.
- Do not replace the mixed PowerShell MCP contract with a blanket wildcard or an invented naming scheme.
- Do not mark live Claude-session criteria PASS without transcript-level evidence.
- Do not weaken the architecture documentation to hide the contract mismatch.
- Do not create suppressions or policy exceptions to bypass the stale-symbol issue.