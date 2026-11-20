# Existing-Behavior Search — Issue #1026, Remediation Cycle 2 (P0-T3)

Timestamp: 2026-11-03T21-48
Command: git grep -l -F -e "Cleanup leg not applied" -e "sub-code" -e "unchanged deny text" -e "Hook Execution Context" -e "execution-environment" -- tests/
EXIT_CODE: 0
Output Summary: 8 tracked files match (case-sensitive); the set equals the eight files named in DR3 of the plan. No unexpected file.

SearchScope: tracked files under `tests/` (untracked `__pycache__` bytecode excluded)
SearchPatterns: `Cleanup leg not applied`, `sub-code`, `unchanged deny text`, `Hook Execution Context`, `execution-environment`

| Matching file | DR3 disposition |
|---|---|
| `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` | one test updated (DR2), one unchanged |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` | unchanged (comment header) |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` | unchanged (hook deny reason) |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` | unchanged (comment header) |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` | unchanged (hook deny reason) |
| `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` | unchanged, re-run |
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | unchanged, re-run |
| `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` | unchanged, re-run |
