# Invariants diff against the base branch (P3-T7)

Timestamp: 2026-10-16T03-06
Command: git fetch origin main; git merge-base origin/main HEAD; git diff --numstat adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary: Merge base adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99. Exactly seven numstat lines: each targets copy 7 added / 0 deleted; the three edited test files 82/0, 3/0, 3/0; neither the C1bCoverage nor the Parity test file appears. Acceptance met (AC-10).

Merge base (printed by `git merge-base origin/main HEAD`): `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`

```
7	0	.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
7	0	.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
7	0	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
7	0	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
82	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1
3	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1
3	0	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
```
