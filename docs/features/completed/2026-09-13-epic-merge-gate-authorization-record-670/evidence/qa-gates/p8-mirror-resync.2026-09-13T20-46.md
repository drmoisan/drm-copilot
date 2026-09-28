# Phase 8 Mirror Re-Sync — Issue #670

Timestamp: 2026-09-17T08-52
Task: [P8-T3]
Loop pass: 2
Command: cp (six repository files over their bundled counterparts) ; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
EXIT_CODE: 1
ExpectedExitCode: 1

## Mirror hash pairs (SHA256)

| Repository path | Bundle path | Repository SHA256 | Bundle SHA256 | Result |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 77C30E88590188AE426ABD8A71825BBEB9EDED4E07E9E95AA1093F71CDE4E24D | 77C30E88590188AE426ABD8A71825BBEB9EDED4E07E9E95AA1093F71CDE4E24D | match |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 08FB2DE608B32EB0F830151C004F172CCE9A83C40477A1A90A1C2112CF1129C3 | 08FB2DE608B32EB0F830151C004F172CCE9A83C40477A1A90A1C2112CF1129C3 | match |
| `.claude/rules/orchestrator-state.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | 0085540BBEC5BE02ACA785547B9F4C361ED3AE83C7EE9FD2AECE7F73A374C892 | 0085540BBEC5BE02ACA785547B9F4C361ED3AE83C7EE9FD2AECE7F73A374C892 | match |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | 6A9743D8A85A234FDE4E4A42633A028F3E5E55D5044B2A5B412387B629199AB1 | 6A9743D8A85A234FDE4E4A42633A028F3E5E55D5044B2A5B412387B629199AB1 | match |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | AF9E593748E00ADC87D3292921DFA90A510B2FF255D2BF8DD5E128389C80162D | AF9E593748E00ADC87D3292921DFA90A510B2FF255D2BF8DD5E128389C80162D | match |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 0302FB41A7C38B58A4E1B8076FD11265C19E39198E8E56CB345E8D1946456636 | 0302FB41A7C38B58A4E1B8076FD11265C19E39198E8E56CB345E8D1946456636 | match |

## Test result

- `1 failed, 16 passed in 0.19s`
- Only failure: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- Assertion message (verbatim): `AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a51b6017c8cb9c138-ac477202.json`
- Cause: open issue #510 (`claude-resource-parity-enumerates-gitignored-state`), pre-existing. The gitignored batch-budget state was rewritten by the PowerShell batch-budget hook during the pass-1 lint-fix edits. The cause is the one stated in [P6-T8].
- Durable substitute: the four mirrored `.claude/**` files (the first four rows above) all have matching SHA256 pairs.

Output Summary:
- Six SHA256 pairs match.
- Pytest: the only failure is the issue #510 node naming a `.claude/state/` path (ExpectedExitCode 1); no other node failed.
