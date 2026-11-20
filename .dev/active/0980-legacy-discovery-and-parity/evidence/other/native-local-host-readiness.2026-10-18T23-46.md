# Native Local host readiness research evidence

Timestamp: 2026-10-18T23:46:19Z. Feature: legacy-discovery-and-parity, issue #980. Required task: P11-T7. This is bounded prerequisite research. No live host was launched or changed, and no capability acceptance is claimed.

EVIDENCE_LOCATION_OVERRIDE_REJECTED: the role-default research destination was rejected by the active evidence-location hook and replaced with this canonical feature evidence location. No denied write was performed or bypassed.

## Research Executed

### File Analysis

Reuse `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/research/2026-10-18T02-40-runtime-publishing-research.md` and its P11-T7 checkpoint carry-forward. The parent supplied policy reads and the bounded installed-source inspection requested by this research-only worker. No earlier capability research, credentials, or production files were reexamined.

The parent verified this worker's native attestation: delegation `native_host_readiness`, deployment `task-researcher-c3-elevated`, model `gpt-6-astra`, effort `high`, profile `.codex/agents/task-researcher-c3-elevated.toml`, SHA256 `745b53656436d404d904619fa602673a39e51fc443b5fed1dcdc0e587b2bf117`. Attestation `01a15164-3bd3-7053-a27b-9722af7d656a`, recorded `2026-10-18T23:41:27.7979175Z`, had valid routing, launch authority, and provenance. This is a parent-provided verification, not a second worker attestation read.

### Code Search Results

The parent read the installed Insiders bundle under version directory `a0c6520313/resources/app/out/vs/workbench/workbench.desktop.main.js`. It registers `workbench.action.chat.newLocalChat`. With no current chat widget, it opens the chat view and starts a new Local session. Otherwise its shared clearing helper receives an explicit Local session type. This is an internal selector, not a documented public API guarantee. Verify availability against the executable used for P11-T7.

The installed defaults are `chat.editor.localAgent.enabled=true`, `chat.defaultToCopilotHarness=false`, and `chat.editor.preferCopilotHarness=false`. Persisted selection also exists under `chat.userSelectedSessionType`; defaults do not prove the selected runtime.

### External Research

- #githubRepo: [Pinned chat actions](https://raw.githubusercontent.com/microsoft/vscode/a0c6520313624aceb3f3a80eff7932be6a00405a/src/vs/workbench/contrib/chat/browser/actions/chatActions.ts), lines 95–191, 211–238, 354–425, 1661–1683. The open-chat command accepts a mode and response-wait option. Waiting can end on pending confirmation; it is not a hook-verification result. The clearing helper explicitly creates Local sessions when that type is resolved.
- #githubRepo: [Pinned session selection](https://raw.githubusercontent.com/microsoft/vscode/a0c6520313624aceb3f3a80eff7932be6a00405a/src/vs/workbench/contrib/chat/common/constants.ts), lines 351–409, 457–507, 546–576. Managed policy can require Agent Host even when Local is requested. Settings and remembered selection also affect resolution. No evidence establishes that this machine has such managed policy.
- #fetch: [CLI reference](https://code.visualstudio.com/docs/configure/command-line). Documented chat arguments include custom-agent mode, prompt, context files, and window selection. They do not provide the full Local-selection and terminal-result contract needed here. A separate user-data directory isolates state without establishing model authentication.
- #fetch: [VS Code API](https://code.visualstudio.com/api/references/vscode-api) and [commands reference](https://code.visualstudio.com/api/references/commands). `vscode.commands.executeCommand` is an extension API. The reviewed command reference does not document these chat commands' argument contract. Direct model requests and participant registration do not prove built-in Local harness execution.
- #fetch: [Local hooks](https://code.visualstudio.com/docs/agents/reference/hooks-reference). PreToolUse can deny calls and SubagentStop can block completion. A custom agent must actually run as a subagent to exercise the start/stop events. Payloads can carry session and agent identity; transcript format is not a stable API.

### Project Conventions

Apply execution-environment and evidence-and-timestamp-conventions. This worker modifies no checkpoint, policy, generated asset, test, or production file. Native operational proof will be stored in canonical feature evidence locations.

## Key Discoveries

### Project Structure

P10 publication must precede P11-T7 acceptance. Discovery assets are not yet available for this proof. Existing CLI authentication findings do not establish Local-session authentication.

### Implementation Patterns

A version-bound extension-host driver can call the installed Local selector and then the open-chat command. It is a candidate for actual native execution, distinct from an extension test that fabricates hook callbacks. Entry points exist; execution and enforcement remain unproved.

### Complete Examples

Candidate sequence inside an actual extension host:

1. Assert the synthetic workspace, workspace trust, and exact host/extension versions.
2. Assert hooks are enabled and published custom agents and hooks are discovered.
3. Execute `workbench.action.chat.newLocalChat`.
4. Execute `workbench.action.chat.open` with the generated probe-agent `mode`, bounded `query`, and `blockOnResponse: true`.
5. Correlate actual hook receipts and session identity with fixture outcomes. Pending confirmation, timeout, missing events, or incorrect runtime identity leave the proof incomplete.

The probe must invoke the required discovery agent as a subagent. Selecting it only as the top-level mode does not establish subagent-event coverage.

### API and Schema Documentation

This candidate relies on internal commands tied to the inspected build. Do not call it a stable public headless API. Absence from public documentation also does not establish impossibility. The supported hook payload contract remains the assertion interface.

### Configuration Examples

Record effective Local availability, hooks, trust, agent identity, and selected harness. Do not disable trust, alter managed policy, copy credentials, or treat defaults as effective-state evidence. Use approved bounded fixture permissions.

### Technical Requirements

Capture actual SubagentStart, tool allow/deny, and subagent stop allow/block behavior. Correlate session and agent identifiers. Verify allowed fixture effects occur and denied effects do not. Demonstrate a stop block prevents acceptance until its condition is resolved. Preserve failures and distinguish host prerequisites from discovery defects.

## Recommended Approach

Use a version-pinned extension-host driver at P11-T7 against the actual installed Local harness after P10 publishes assets. Verify trust, model availability, host policy, command availability, and Local identity; then execute positive and negative scenarios with actual hook and fixture receipts.

**No confirmed external blocker was found. Native acceptance remains unproved.** The unresolved prerequisite is an executed, authenticated, trusted Local session whose event and enforcement results can be collected. Report a concrete observed prerequisite failure if the driver encounters one; missing public API documentation alone is not such a failure.

Rejected alternatives: CLI alone lacks the complete selection/result contract; Copilot CLI/SDK, direct model calls, mocked callbacks, and unit tests do not prove Local enforcement. Manual user QA is outside the approved plan. No host session, installation, or automation was created during this research.

## Implementation Guidance

### Objectives

Resolve P11-T7 with actual native-host evidence while preserving the existing plan and completed work.

### Key Tasks

At the planned phase, implement the bounded driver/fixture work through its specialist owner. Record host prerequisites, execute the event matrix, and fail closed on absent proof. Further research is unnecessary merely to establish that the candidate exists.

### Dependencies

Published assets; a model authenticated to Local; trusted synthetic workspace; effective hooks; permitted Local runtime; available internal commands; bounded fixture permissions and canonical evidence output.

### Success Criteria

The correct runtime and custom subagent emit actual start/tool/stop receipts with positive and negative fixture outcomes matching policy. This research does not check off P11-T7.

## Pre-Mortem

- Review checklists: assert runtime and agent identity; command existence is insufficient.
- Coverage: exercise tool allow/deny and stop allow/block.
- Mirror parity: bind the proof to generated asset hashes.
- File size: keep future driver and fixture code within repository limits.
- Test isolation: use synthetic operational fixtures, not temporary-file unit tests.
- CI-only behavior: callback simulation cannot replace authenticated native evidence.
- Evidence: retain raw host results, fixture assertions, failures, and unproved states under canonical feature evidence paths.
