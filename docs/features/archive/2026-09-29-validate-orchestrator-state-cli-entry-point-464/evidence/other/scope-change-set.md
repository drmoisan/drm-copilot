# Scope Boundary, Expected Change Set (Issue #464)

Timestamp: 2026-09-30T09-34
Command: git diff --name-status 5b09b53899ac9dad870f855cbcc359098266e213 -- scripts tests .claude extensions
Command: git status --porcelain -- scripts tests .claude extensions
Command: git diff --name-status bd8de655d04a41039f50816b92cf524a2c23ab00 -- scripts tests .claude extensions
EXIT_CODE: 0 (all commands)
Output Summary:
- Plan-literal run (ref = recorded merge-base SHA; `git status --porcelain` printed nothing): eleven paths. Eight are the expected paths. Three are extra: `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`. Diffing against `origin/epic/orchestrator-state-contract-correctness-integration` itself printed the same eleven paths.
- Cause of the three extra paths: they belong to the release merge (PR #785, commit `ac1166db` "release: bump extension to 1.1.17 and mcp-server to 1.1.17") that is already in the branch base. `git diff --name-only 5b09b53899ac9dad870f855cbcc359098266e213 bd8de655d04a41039f50816b92cf524a2c23ab00` (merge-base to the pre-execution HEAD, before the first execution commit) lists exactly those three paths. The issue #464 work did not touch them.
- Equivalent anchored run (ref = pre-execution HEAD `bd8de655d04a41039f50816b92cf524a2c23ab00`, which isolates the change set of this execution): exactly the eight expected paths and no others:
  - `M .claude/rules/orchestrator-state.md`
  - `M .claude/skills/orchestrate/SKILL.md`
  - `M extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
  - `M extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
  - `A scripts/dev_tools/_orchestrator_state_remediation_loop.py`
  - `M scripts/dev_tools/validate_orchestrator_state.py`
  - `A scripts/dev_tools/validate_orchestrator_state_cli.py`
  - `A tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py`
- Deviation recorded for `## Implementation Notes`: the plan acceptance (union lists exactly eight paths against the merge-base ref) is met only by the pre-execution-HEAD anchor, because the branch base carries the release-bump merge.
