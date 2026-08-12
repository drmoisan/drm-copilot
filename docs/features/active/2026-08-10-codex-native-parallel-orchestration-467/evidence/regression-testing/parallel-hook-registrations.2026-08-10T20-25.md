# Parallel Hook Registrations

Timestamp: 2026-08-10T20-25
Command: inline Python TOML registration validator; `git diff --check -- .codex/config.toml`
EXIT_CODE: 0
Output Summary: P4-T8 parsed the targeted native hook configuration, preserved `22/22` legacy handler tuples, registered `7/7` direct parallel handlers exactly once, resolved every command target, and found zero duplicate handlers or shared-module direct registrations.

## Result

P4-T8 passed. `.codex/config.toml` uses the existing nested-handler schema to register each direct parallel entrypoint exactly once and to route parallel SubagentStart and SubagentStop events through the existing attestation and output-validation dispatchers.

## Native Handler Table

| Event | Matcher | Entrypoint | Timeout | Status metadata |
|---|---|---|---:|---|
| `UserPromptSubmit` | omitted; all prompts | `authorize-root-parallel-invocation.ps1` | 15 | `statusMessage = "Authorizing root parallel entry"` |
| `PreToolUse` | `^(shell_command\|apply_patch\|mcp__.*)$` | `enforce-parallel-root-invocation.ps1` | 30 | omitted, matching adjacent handlers |
| `PreToolUse` | `^(shell_command\|apply_patch\|mcp__.*)$` | `enforce-parallel-child-worktree-binding.ps1` | 30 | omitted, matching adjacent handlers |
| `PreToolUse` | `^spawn_agent$` | `enforce-parallel-cohort-barrier.ps1` | 30 | omitted, matching adjacent handlers |
| `PreToolUse` | `^spawn_agent$` | `enforce-parallel-drift-gate.ps1` | 30 | omitted, matching adjacent handlers |
| `PreToolUse` | `^shell_command$` | `enforce-parallel-worktree-removal-gate.ps1` | 30 | omitted, matching adjacent handlers |
| `PreToolUse` | `^shell_command$` | `enforce-parallel-abandon-gate.ps1` | 30 | omitted, matching adjacent handlers |
| `SubagentStart` | existing persona matcher extended with `parallel-planner\|parallel-orchestrator` | `record-subagent-routing-attestation.ps1` | 15 | existing `statusMessage = "Recording subagent routing attestation"` |
| `SubagentStop` | existing persona matcher extended with `parallel-planner\|parallel-orchestrator` | `validate-codex-subagent-routing.ps1` | 30 | omitted, matching adjacent handlers |

Every handler uses:

- `type = "command"`;
- `command = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/<entrypoint>.ps1"'`;
- an identical `command_windows` value;
- the event-specific timeout and status metadata shown above.

## Shared and Indirect Modules

- `parallel-hook-common.ps1` is sourced by the direct adapters and is not registered.
- `validate-parallel-agent-output.ps1` is sourced and invoked once through the registered `validate-codex-subagent-routing.ps1` SubagentStop dispatcher; direct registration would duplicate validation.
- The existing registered `enforce-completion-consistency.ps1` handler retains its parallel completion dispatch without a duplicate registration.

## Verification Results

- TOML parse: PASS.
- Legacy handler tuples and matcher semantics preserved: 22 of 22.
- Legacy handler removals: 0.
- Total registered handlers: 29, comprising 22 preserved and 7 net-new handlers.
- Direct new parallel registrations: 7 of 7.
- Parallel SubagentStart matcher groups: 1.
- Parallel SubagentStop matcher groups: 1.
- Exact event, matcher, and command tuple duplicates: 0.
- Missing registered command targets: 0.
- Shared-module direct registrations: 0.
- New Claude-only matchers: 0.
- `notify` fields: 0.
- Configuration size: 352 physical lines, within the 500-line limit.
- P4-T8 delta: targeted nested-handler additions plus two matcher-line extensions; no whole-file rewrite.
- `.claude` status entries: 0.
- `.claude` diff entries: 0.
- `.codex/state`: absent.
- `git diff --check -- .codex/config.toml`: PASS.
