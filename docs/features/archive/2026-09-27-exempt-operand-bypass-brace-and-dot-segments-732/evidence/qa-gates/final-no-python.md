# Final no-Python check (R-NOPY; issue #732)

Timestamp: 2026-10-09T04-57
Task: [P7-T13]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p7-t11-t17.sh nopy (R-NOPY over the hook directories and their bundled mirrors against BASE_SHA)
EXIT_CODE: 0

## Output

```text
PATHSET_COUNT: 14
PATH: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
PY_FINDINGS: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 0
PATH: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
PY_FINDINGS: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
PATH: .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
PY_FINDINGS: .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 0
PATH: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
PY_FINDINGS: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 0
PATH: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
PY_FINDINGS: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
PATH: .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
PY_FINDINGS: .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 0
PATH: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
PY_FINDINGS: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 0
PATH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
PY_FINDINGS: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 0
PATH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
PY_FINDINGS: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
PATH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
PY_FINDINGS: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 0
PATH: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
PY_FINDINGS: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 0
PATH: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
PY_FINDINGS: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 0
PATH: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
PY_FINDINGS: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 0
PATH: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
PY_FINDINGS: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1 0
ADDED_INTERPRETER_WORD_COUNT: 0
```

Output Summary: PATHSET_COUNT 14; PY_FILE lines 0; total PY_FINDINGS 0; ADDED_INTERPRETER_WORD_COUNT 0.


Measurement note: an earlier run of this task counted @(Get-PythonInvocationFinding ...).Count, which wraps the function's unary-comma return and reports 1 for an empty result (14 false findings). The count now pipes the assigned result through Where-Object. Controls with the same helper: a text invoking python and poetry yields 2 findings; Write-Output alone yields 0.
