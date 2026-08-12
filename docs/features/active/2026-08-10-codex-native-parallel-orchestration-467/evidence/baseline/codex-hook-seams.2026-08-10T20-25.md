# Native Codex Hook Registration and Process-Test Seams

Timestamp: 2026-08-10T22-38

Command: `rg -n 'PreToolUse|SubagentStop|PermissionRequest|matcher|permissionDecision|CLAUDE_TOOL_INPUT|CLAUDE_SESSION_ID' .codex/config.toml .codex/hooks tests/scripts/codex-hooks`

EXIT_CODE: 0

Output Summary: The current Codex runtime uses the nested TOML command-handler schema. Three `PreToolUse` matcher groups register 18 handlers, two `SubagentStop` matcher groups register two handlers, one `UserPromptSubmit` handler and one `SubagentStart` handler are registered, and no `PermissionRequest` group exists. Existing process tests feed native JSON on stdin, poison legacy Claude environment variables, and assert exact exit/stdout/stderr behavior.

## Reusable registration seams

- `.codex/config.toml`: authoritative event, matcher, command, Windows-command, timeout, and status-message registration surface.
- Native matcher-group form:

  ```toml
  [[hooks.PreToolUse]]
  matcher = "<regex>"

  [[hooks.PreToolUse.hooks]]
  type = "command"
  command = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/<hook>.ps1"'
  command_windows = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/<hook>.ps1"'
  timeout = 30
  ```

- Existing `PreToolUse` matchers are `^Bash$`, `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$`, and `^(apply_patch|Edit|Write)$`.
- Existing `SubagentStop` matchers are `epic-planner|epic-orchestrator|orchestrator|atomic-planner|atomic-executor|feature-review|feature-reviewer|task-researcher|prd-feature|pr-author|typed-engineer|-c` and `feature-review|feature-reviewer`.
- `.codex/hooks/codex-pretooluse-file-mapping.ps1`: shared native stdin parser and `tool_input`-to-file-edit mapper for `apply_patch`, `Edit`, and `Write` handlers.
- `.codex/hooks/validate-codex-subagent-routing.ps1`: reusable `SubagentStop` continuation shape and one-continuation guard.
- `.codex/hooks/record-subagent-routing-attestation.ps1`: existing `SubagentStart` receipt seam.
- `.codex/hooks/enforce-codex-model-routing.ps1`: existing routed-agent admission seam.
- `.codex/hooks/enforce-completion-helpers.ps1` and `.codex/hooks/enforce-completion-consistency.ps1`: existing completion-state validation and native deny-envelope seam.

No native `PermissionRequest` registration or process-test seam exists in the current configuration. Parallel admission controls must therefore use the established registered events unless a separately tested native `PermissionRequest` surface is introduced.

## Reusable registered-process test seams

- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` parses every `PreToolUse` matcher/handler directly from `.codex/config.toml`, verifies every registered script exists, crosses each handler with every admitted candidate tool name, and runs the scripts as child `pwsh` processes.
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` provides the reusable stdin/stdout/stderr/exit-code process harness and allow/deny/malformed matrices for the `apply_patch|Edit|Write` group.
- `tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1` covers empty, whitespace, invalid JSON, missing/null `tool_input`, optional/required `session_id`, and file-edit mapping.
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` verifies the nested handler schema and registration existence.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` provides additional process-level malformed-input and legacy-contract coverage.
- `tests/scripts/codex-hooks/epic-provenance.Tests.ps1` covers `SubagentStop` continuation decisions and provenance/model-routing admission.
- `tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1` covers native completion allow/deny decisions.

## Exact native stream and exit contract

- Input: one JSON object on stdin containing `hook_event_name`, `tool_name`, and a non-null object `tool_input`; stateful handlers may additionally require nonblank `session_id`.
- Allow: exit `0`, empty stdout, and empty stderr.
- Deny: exit `0`, exactly one compact native JSON object on stdout with `hookSpecificOutput.hookEventName = "PreToolUse"`, `permissionDecision = "deny"`, and a stable `permissionDecisionReason`; stderr remains empty. The legacy top-level `decision` deny envelope is prohibited for `PreToolUse`.
- Malformed or unprocessable input: exit `2`, empty stdout, and one stable hook-named diagnostic on stderr. This includes empty stdin, invalid JSON, missing/null `tool_input`, and a missing required `session_id`.
- Legacy isolation: process tests set poisoned `CLAUDE_TOOL_INPUT` and `CLAUDE_SESSION_ID` values; handlers must use stdin and native fields only.
- `SubagentStop` first invalid stop: exit `0` with one JSON object containing `decision = "block"` and `reason`, which requests one continuation.
- `SubagentStop` repeated stop with `stop_hook_active = true`: exit `0` with `continue = false`, `stopReason`, and `systemMessage`, preventing a continuation loop.
- `SubagentStop` malformed input: exit `2`, empty stdout, and a stable stderr diagnostic.

The resolved syntax and contracts are sufficient for Phase 4 registered-process implementation; no unresolved registration syntax remains.
