# `2026-06-27-harden-claude-pretooluse-hook-schema` — User Story

- Issue: #259
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-27T20-46

## Story Statement

- As the repository maintainer, I want every PreToolUse-registered hook to emit the `hookSpecificOutput`/`permissionDecision=deny` shape that the Claude Code / Agent SDK harness honors, so that a guard that decides to deny an unsafe tool call actually denies it rather than failing open.
- As the repository maintainer, I want a serialize-then-parse contract test that locks the exact harness-consumed field names for every PreToolUse hook, so that any future regression to the ignored top-level `decision`/`reason` form fails CI before it reaches the runtime harness.
- As the repository maintainer, I want the runtime hooks and their bundled mirror to stay byte-identical, so that the guards delivered in the extension behave the same as the guards in the repository.

## Problem / Why

In the Claude Code / Agent SDK harness, the hook event type determines which block-decision JSON schema the harness honors. At `PreToolUse`, a hook denies a tool call only when it writes the `hookSpecificOutput` form to stdout:

```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<reason>"}}
```

The legacy top-level form `{"decision":"block","reason":"..."}` is ignored at `PreToolUse`, and the tool call proceeds (fail-open). An `exit 1` is also non-blocking at `PreToolUse`.

A survey of `.claude/hooks/` confirms that every PreToolUse-registered hook in drm-copilot currently emits the legacy top-level `decision='block'/'allow'` form (`permissionDecision` appears in no hook), and several rely on `exit 1` to block. These guards are therefore fail-open: they do not actually deny tool calls. This was verified live in the sibling repository rgf-forecast, where a PR was created despite a registered `pr-author` guard because the guard emitted the top-level form at `PreToolUse`.

SubagentStop / PostToolUse / UserPromptSubmit hooks correctly honor the top-level `{"decision":"block","reason":"..."}` form (and `exit 1`); those must not be changed.


## Personas & Scenarios

- Persona: Repository maintainer
  - Who they are: The owner of the drm-copilot runtime customizations, responsible for the PreToolUse guards under `.claude/hooks/` and their bundled mirror in the extension.
  - What they care about: That a guard which decides to deny an unsafe tool call (for example a destructive Bash command, a non-MCP promotion, or an out-of-order orchestration step) actually causes the harness to deny that call.
  - Constraints: PowerShell hooks are subject to the 500-line file cap and a per-batch cap of 3 production plus 3 test files; SubagentStop hooks must not be weakened; every runtime hook edit requires a matching mirror edit enforced by a contract test.
  - Goals and frustrations: The current guards emit the legacy top-level `decision`/`reason` form (or rely on `exit 1`), which the harness ignores at PreToolUse. The maintainer needs the guards to be effective rather than fail-open, and needs a CI artifact that prevents the regression from recurring.
  - Context and motivation: The fail-open behavior was verified live in the sibling repository rgf-forecast, where a PR was created despite a registered `pr-author` guard because the guard emitted the top-level form at PreToolUse.
- Scenario: A PreToolUse guard denies an unsafe tool call
  - Who is acting: An agent in the Claude Code / Agent SDK harness attempts a tool call (for example a Bash command matching a blocked pattern) that a registered PreToolUse hook should deny.
  - What triggered the action: The harness invokes the matching PreToolUse hook with the tool-call JSON on stdin and via `CLAUDE_TOOL_INPUT` / `CLAUDE_HOOK_INPUT` before executing the tool.
  - Steps: The hook reads the tool input, runs its pure decision function, determines the call must be denied, and writes the `hookSpecificOutput`/`permissionDecision=deny` object to stdout with `ConvertTo-Json -Depth 5`, then exits 0.
  - Obstacles or decisions: On an allow path the hook emits the allow shape or no decision; on a malformed-input error path the hook retains its existing non-deny `exit 1` behavior.
  - Outcome expected: The harness honors the deny and the tool call does not proceed. The serialize-then-parse contract test confirms the emitted field names match the harness-consumed schema, so the deny is effective and the behavior cannot silently regress.


## Acceptance Criteria

- [x] Every PreToolUse-registered hook emits the `hookSpecificOutput`/`permissionDecision=deny` shape for blocks and the `permissionDecision=allow` shape for allows; no PreToolUse hook emits a top-level `decision`/`reason` shape or uses `exit 1` to block.
- [x] `validate-bash` blocks via a pure detector plus a deny-decision builder that writes the `hookSpecificOutput` form, never `exit 1`.
- [x] A serialize-then-parse contract test asserts `permissionDecision=deny` and `hookEventName=PreToolUse` for every PreToolUse hook.
- [x] SubagentStop validator hardening (Parts 3.1–3.4) is ported without changing the SubagentStop block form.
- [x] The checkpoint-monotonic prerequisite gate (Part 4) and new PreToolUse gate hooks (Part 5) are present, registered, and tested on the correct schema.
- [x] Bundled mirror hooks match runtime hooks; bundle-parity contract tests pass.
- [x] PoshQC format clean, PSScriptAnalyzer 0 findings on changed files, all Pester hook tests pass, every touched `.ps1` <= 500 lines.


## Non-Goals

- Changing the decision logic that determines whether a tool call is allowed or denied. Only the serialization/return shape and the final decision-gate comparison change.
- Changing the SubagentStop, PostToolUse, or UserPromptSubmit hooks, which correctly honor the top-level `{"decision":"block","reason":"..."}` form and `exit 1`. SubagentStop validator hardening is additive and must not change that block form.
- Deleting, weakening, or removing the registration of any existing hook.
- Adding new configuration keys, new dependencies, or new telemetry.
- Reproducing the live-harness denial as an automated Pester test; that verification is out-of-band, and the in-repo proving artifact is the contract test.
