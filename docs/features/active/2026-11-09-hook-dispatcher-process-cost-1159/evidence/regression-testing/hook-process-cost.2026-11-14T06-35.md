# Hook process cost report (-Source Dispatcher)

Timestamp: 2026-11-14T06-35
Command: pwsh -NoProfile -File scripts/dev-tools/Measure-HookProcessCost.ps1 -Source Dispatcher -Iterations 5
EXIT_CODE: 0
Output Summary: 5 iteration(s) per scenario; hook processes per call: claude bash=1, claude write=1, claude agent=1, claude mcp=1, codex bash=1, codex write=1, codex agent=1, codex mcp=1. CPU and wall seconds are reported as median/mean/max. Grandchild processes (git, gh) started by hooks are excluded from the process count and CPU seconds.

Grandchild processes (git, gh) started by hook scripts are excluded: the process count and CPU seconds cover only the hook processes the runtime starts.

| Runtime | Scenario | Tool name | Processes per call | CPU seconds (median/mean/max) | Wall seconds (median/mean/max) | Max hook exit code |
|---|---|---|---|---|---|---|
| claude | bash | `Bash` | 1 | 3.250/3.403/4.109 | 3.689/3.821/5.114 | 0 |
| claude | write | `Write` | 1 | 2.141/2.066/2.297 | 2.440/2.505/3.010 | 0 |
| claude | agent | `Agent` | 1 | 3.031/3.081/3.250 | 3.767/3.702/3.972 | 0 |
| claude | mcp | `mcp__drm-copilot__run_discovery_repo_inventory` | 1 | 1.266/1.328/1.547 | 1.195/1.300/1.721 | 0 |
| codex | bash | `Bash` | 1 | 2.375/2.356/2.891 | 2.485/2.681/3.656 | 0 |
| codex | write | `apply_patch` | 1 | 2.141/2.188/2.469 | 2.271/2.500/3.026 | 0 |
| codex | agent | `Agent` | 1 | 1.125/1.159/1.313 | 1.114/1.204/1.463 | 0 |
| codex | mcp | `mcp__drm-copilot__run_discovery_repo_inventory` | 1 | 1.453/1.603/2.094 | 1.914/2.184/3.773 | 0 |

## Hooks per scenario

- claude bash: .claude/hooks/invoke-pretooluse-dispatch.ps1 (dispatched members: 13)
- claude write: .claude/hooks/invoke-pretooluse-dispatch.ps1 (dispatched members: 14)
- claude agent: .claude/hooks/invoke-pretooluse-dispatch.ps1 (dispatched members: 10)
- claude mcp: .claude/hooks/invoke-pretooluse-dispatch.ps1 (dispatched members: 2)
- codex bash: .codex/hooks/invoke-pretooluse-dispatch.ps1 (dispatched members: 12)
- codex write: .codex/hooks/invoke-pretooluse-dispatch.ps1 (dispatched members: 15)
- codex agent: .codex/hooks/invoke-pretooluse-dispatch.ps1 (dispatched members: 2)
- codex mcp: .codex/hooks/invoke-pretooluse-dispatch.ps1 (dispatched members: 6)

## Payload templates ({{REPOSITORY_ROOT}} is replaced by the repository root at run time)

- claude bash: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Bash","tool_input":{"command":"git status --short"}}`
- claude write: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Write","tool_input":{"file_path":"docs/hook-cost-probe.md","content":"probe\n"}}`
- claude agent: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Agent","tool_input":{"subagent_type":"task-researcher","description":"hook cost probe","prompt":"hook cost probe"}}`
- claude mcp: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"mcp__drm-copilot__run_discovery_repo_inventory","tool_input":{}}`
- codex bash: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Bash","tool_input":{"command":"git status --short"}}`
- codex write: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch\n*** Update File: docs/hook-cost-probe.md\n@@\n-old\n+new\n*** End Patch\n"}}`
- codex agent: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Agent","tool_input":{"subagent_type":"task-researcher","description":"hook cost probe","prompt":"hook cost probe"}}`
- codex mcp: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"mcp__drm-copilot__run_discovery_repo_inventory","tool_input":{}}`

## Verification ([P7-T7])

Launched as `sh SCRATCH/issue-1159-cost.sh Dispatcher SCRATCH/issue-1159-cost-after.md` (exit 0) on Windows after the [P7-T1] integration, with the payload templates of the [P0-T10] report (the tool's fixed scenario set). The process count is 1 for every runtime and scenario. Other sessions' test processes were running on the same machine during this measurement and during the before measurement, so wall times carry that load.
