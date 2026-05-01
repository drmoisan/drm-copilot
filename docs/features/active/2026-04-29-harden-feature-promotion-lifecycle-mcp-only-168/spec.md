# 2026-04-29-harden-feature-promotion-lifecycle-mcp-only — Spec

- **Issue:** #168
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-29T08-56
- **Status:** Draft
- **Version:** 0.1

## Overview

The Claude-side `feature-promotion-lifecycle` skill still documents fallback script paths and alternate execution routes, which weakens the contract that agent sessions must use the `drmCopilotExtension` MCP tool surface for promotion work. The current Bash pre-tool hook only blocks destructive shell patterns, so direct Bash invocations of promotion scripts can still bypass the intended MCP path, and the checkpoint documentation does not yet spell out the raw promotion receipt fields that should be retained under `delegation_receipts.promotion`.

This gap makes promotion behavior less deterministic, less auditable, and easier to drift away from the supported agent workflow. Hardening the skill, hook registration, and checkpoint schema documentation would make MCP invocation mandatory for agent sessions without changing the underlying promotion scripts or MCP server implementation.


## Behavior

Harden the Claude-side promotion lifecycle so agent sessions have exactly one authoritative execution path for promotion work:

1. Rewrite `.claude/skills/feature-promotion-lifecycle/SKILL.md` so it is MCP-only for agent sessions, requires a preflight check that the promotion MCP tools are available before continuing, and requires the orchestrator to capture the raw MCP receipts for potential-entry creation, issue promotion, and active-feature-folder creation.
2. Remove the fallback-script sections and all remaining direct script references from that skill, including `dev_tools`, `dev-tools`, and `poetry run python -m scripts...` guidance.
3. Replace the current alternatives language with a single note that the related VS Code command-palette commands may exist for interactive use but are not authoritative for agent sessions.
4. Add or update `.claude/settings.json` so a PreToolUse Bash hook is registered for promotion guardrails, and add a hook under `.claude/hooks/` that blocks Bash invocations containing any of `new-potential-entry.ps1`, `new_potential_bug_entry`, `potential_to_issue`, or `new_active_feature_folder` and returns the required error message.
5. Confirm and document additive checkpoint-schema support for `delegation_receipts.promotion.potential_entry`, `delegation_receipts.promotion.issue`, and `delegation_receipts.promotion.feature_folder`, with each field retaining the raw MCP receipt payload captured during the promotion lifecycle.

Main execution path:

- The orchestrator reads the hardened lifecycle skill before promotion work begins and verifies that the required `drmCopilotExtension` promotion MCP tools are available in the connected Claude session.
- If the preflight passes, promotion continues only through the MCP operations already permitted in `.claude/settings.json`; no agent-session branch of the lifecycle may route to direct PowerShell or Python script execution.
- After each successful promotion operation, the orchestrator persists the raw MCP output into `artifacts/orchestration/orchestrator-state.json` under the matching `delegation_receipts.promotion.*` key so downstream review and resume logic can inspect the unmodified receipt.
- The checkpoint documentation and validator must agree on this persisted shape so a live checkpoint that already contains the nested promotion namespace is treated as valid rather than as schema drift.

Failure and alternative paths:

- If the required MCP tools are unavailable, the lifecycle fails closed at the preflight step and instructs the operator to restore MCP access; the skill no longer treats script fallback as an approved agent-session alternative.
- If a user or agent attempts to invoke one of the promotion scripts directly through Bash, the dedicated PreToolUse hook blocks the call before execution and returns the repository-defined error message.
- Interactive VS Code command-palette commands may still be noted for direct human use with the extension installed, but they remain explicitly non-authoritative for agent sessions and do not replace the MCP-only contract.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- `.claude/skills/feature-promotion-lifecycle/SKILL.md` as the Claude-side lifecycle contract to harden.
	- `.claude/settings.json` as the project-scoped hook and permission registration surface.
	- `CLAUDE_TOOL_INPUT` JSON passed into PreToolUse Bash hooks, containing the attempted Bash command text that the new promotion guard must inspect.
	- `.claude/agents/orchestrator.md` as the canonical Claude-side documentation surface for `artifacts/orchestration/orchestrator-state.json` persistence.
	- `scripts/dev_tools/validate_orchestration_artifacts.py` and `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` as the fail-closed validation and regression-test surfaces for the checkpoint schema.
	- Existing Claude hook patterns under `.claude/hooks/` and `tests/scripts/claude-hooks/` that define the repository-standard JSON allow/block response behavior.
- Outputs (artifacts, logs, telemetry)
	- Revised skill text that documents only the MCP-first promotion path for agent sessions.
	- An updated `.claude/settings.json` `hooks.PreToolUse` registration that adds a dedicated promotion-bypass guard alongside the existing Bash validator.
	- A new dedicated hook script under `.claude/hooks/` that returns an allow/block decision for Bash promotion-bypass attempts.
	- Updated checkpoint contract wording in `.claude/agents/orchestrator.md` and additive validator support in `scripts/dev_tools/validate_orchestration_artifacts.py`.
	- Updated automated coverage in the existing `tests/scripts/claude-hooks/` and `tests/scripts/dev_tools/` suites that proves the guardrails and checkpoint acceptance behavior.
	- Blocked bypass attempts emitted as deterministic hook output; no new external telemetry sink or artifact type is introduced.
- Config keys and defaults:
	- `.claude/settings.json.hooks.PreToolUse` gains one additional Bash handler for promotion-bypass enforcement; existing `Bash(poetry run *)` and `Bash(pwsh *)` allow rules remain in place for unrelated workflows.
	- `delegation_receipts` remains a required top-level checkpoint field; the feature adds documented support for a nested `promotion` namespace without changing the required top-level key name.
	- No new environment variables, feature flags, or repository configuration keys are introduced.
- Versioning or backward-compatibility constraints:
	- Checkpoint validation must remain backward-compatible with the existing list-based `delegation_receipts` form while also accepting the already-persisted nested `delegation_receipts.promotion.*` object shape.
	- The change is additive for orchestration-state consumers: existing keys such as `objective`, `completed_steps`, and `blocked_reason` remain unchanged.
	- Promotion-module behavior and MCP receipt payload contents are not versioned or transformed by this feature.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- MCP promotion operations in scope:
	- `mcp__drmCopilotExtension__new_potential_entry` with `short_name=<slug>` for potential-entry creation.
	- `mcp__drmCopilotExtension__potential_to_issue` with `potential_path=<workspace-relative markdown path>`, `promotion_type=<feature|bug>`, and `work_mode=<minor-audit|full-feature|full-bug|full>` for issue promotion.
	- `mcp__drmCopilotExtension__new_active_feature_folder` with `feature_name=<folder slug>`, `type=<feature|bug>`, `issue_number=<issue id>`, and `work_mode=<minor-audit|full-feature|full-bug|full>` for active-folder creation.
- Hook surface in scope:
	- `.claude/settings.json` registers a `PreToolUse` matcher for `Bash` that invokes the existing `validate-bash.ps1` hook and the new dedicated promotion-bypass hook.
	- The promotion-bypass hook reads `CLAUDE_TOOL_INPUT`, detects the four forbidden tokens, and returns either an allow decision for benign Bash commands or a deny decision with the required repository error message before execution.
- Checkpoint validation surface in scope:
	- `scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state <path>` remains the canonical validator entry point.
	- The validator must accept both `"delegation_receipts": [ ... ]` and `"delegation_receipts": { "promotion": { "potential_entry": <raw receipt>, "issue": <raw receipt>, "feature_folder": <raw receipt> } }` without rewriting the receipt payload content.
- Example invocations with expected outputs (concise):
	- Promotion preflight succeeds: the lifecycle continues with MCP calls only and records each raw receipt into the checkpoint after the tool returns.
	- Promotion preflight fails: the lifecycle stops before any promotion step and reports that the required MCP tools are unavailable for the current agent session.
	- Direct Bash bypass attempt such as a command containing `potential_to_issue`: the hook returns the required deny message and the command does not execute.
	- Validator run against the live nested checkpoint shape: the validator passes when the `promotion` namespace exists and the three documented receipt keys contain raw MCP payloads.
- Contracts and validation rules:
	- The skill must not contain `Fallback`, `fallback`, `dev_tools`, `dev-tools`, or `poetry run python -m scripts` strings after the hardening change.
	- The only remaining non-MCP note in the lifecycle skill is a single VS Code command-palette statement explicitly marked non-authoritative for agent sessions.
	- The hook match must be narrow enough to avoid blocking unrelated `git`, `poetry run`, or `pwsh` commands that do not contain the forbidden promotion tokens.
	- The validator documents container shape and required key names only; it must not reinterpret or normalize raw MCP receipts.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Raw MCP receipts for potential-entry creation, issue promotion, and feature-folder creation flow from the promotion tool call directly into `artifacts/orchestration/orchestrator-state.json` under `delegation_receipts.promotion.potential_entry`, `.issue`, and `.feature_folder`.
	- The feature preserves receipt fidelity: the stored value is the raw MCP payload, not a reduced projection or normalized schema invented by the validator.
	- The Bash hook performs command inspection only; it does not mutate command text, modify checkpoint state, or create side-channel artifacts.
	- The validator continues to enforce required top-level checkpoint keys while broadening only the accepted shape of `delegation_receipts`.
- Caching or persistence details:
	- The persistent state remains `artifacts/orchestration/orchestrator-state.json`, which the orchestrator already uses as its resume checkpoint.
	- No new cache layer is introduced; the only persistent addition is documented acceptance of the nested `promotion` namespace inside the existing checkpoint object.
	- Hook decisions are ephemeral and apply at tool-execution time only.
- Migration or backfill requirements (if any):
	- No data backfill is required because the live checkpoint already contains the nested `delegation_receipts.promotion.*` shape described in the issue research.
	- Validation changes must be additive so older checkpoints that still use a list of delegation receipts continue to validate.
	- Resume logic should continue to read the existing checkpoint file path and top-level key set without requiring a conversion step.

## Constraints & Risks

- Out of scope: do not modify the underlying promotion implementations under `scripts/dev_tools/`, and do not modify the MCP server implementation.
- The new Bash guard must be narrow enough to block only promotion-script bypass attempts, because `.claude/settings.json` currently allows broad `Bash(poetry run *)` and `Bash(pwsh *)` execution for other workflows.
- Checkpoint changes should be additive and documented clearly so existing in-progress orchestration state can still be resumed or migrated without losing prior receipt data.
- The repository contains mirrored lifecycle content outside `.claude/`; this feature should focus on Claude-side runtime enforcement and documentation unless a separate follow-up is opened for mirror synchronization.
- The current live checkpoint shape already diverges from the validator's list-only expectation, so validator updates and documentation updates must land together to avoid codifying two conflicting sources of truth.
- Because `.claude/settings.json` uses project-scoped hooks, an overly broad Bash matcher could disrupt unrelated repository workflows; the deny condition must be token-based and deterministic.
- The existing `validate-bash.ps1` hook follows an older pattern, while newer hooks use structured JSON allow/block responses. The dedicated promotion hook should follow the newer repository convention so its behavior is testable and aligned with the documented Claude Code hook contract.
- Root `.claude` files are the authoritative Claude runtime surfaces for this feature. Mirror synchronization into extension resources is intentionally deferred unless a separate follow-up expands scope.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Update `.claude/skills/feature-promotion-lifecycle/SKILL.md` to remove fallback script guidance, require MCP preflight, and require receipt capture into `delegation_receipts.promotion.*`.
	- Update `.claude/settings.json` to register a dedicated PreToolUse Bash hook for promotion-bypass enforcement without changing the broader Bash permission allowlist.
	- Add a dedicated PowerShell hook under `.claude/hooks/` that inspects `CLAUDE_TOOL_INPUT` and emits a structured allow/block decision for the four forbidden promotion tokens.
	- Update `.claude/agents/orchestrator.md` so the main Claude-side checkpoint contract explicitly documents the `promotion` receipt namespace for `artifacts/orchestration/orchestrator-state.json`.
	- Extend `scripts/dev_tools/validate_orchestration_artifacts.py` and the existing test coverage in `tests/scripts/dev_tools/` so the nested promotion receipt namespace is accepted additively.
- New classes/functions/commands to add or update:
	- Add hook helper logic that parses the incoming Bash tool payload and decides whether the attempted command matches a forbidden promotion-bypass token.
	- Update the orchestration-validator logic in `validate_orchestrator_state_text` so `delegation_receipts` can be either the legacy list form or an object namespace that may contain `promotion.potential_entry`, `promotion.issue`, and `promotion.feature_folder`.
	- Update existing contract tests that assert required wording in the lifecycle skill and Claude runtime surfaces so MCP-only guidance and receipt-capture language become enforced text contracts.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime or test dependencies are required.
	- The feature reuses the existing PowerShell hook pattern, Pytest validator tests, and repository Pester coverage.
- Logging/telemetry additions and locations:
	- The new hook returns the required block message through the Claude hook response channel when a forbidden Bash command is detected.
	- No new external telemetry sink is introduced; checkpoint persistence remains the only durable audit trail for successful promotion operations.
	- Existing validator stdout/stderr behavior remains the enforcement mechanism for checkpoint-schema failures.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Ship the skill update, Bash hook registration, checkpoint documentation, and validator/test changes together so the documented contract and enforced behavior stay aligned.
	- No feature flag or staged rollout is planned because the change is limited to Claude-side runtime guidance and additive validation behavior.
	- There is no approved agent-session fallback path once MCP preflight fails; the failure mode is to stop and remediate MCP availability.

## Definition of Done

- [x] Acceptance criteria are documented in `issue.md`, `user-story.md`, and `spec.md`, and each criterion maps to a verifiable hook, skill-content, checkpoint-validation, or orchestration demo outcome.
- [x] Documented behavior is verified in the Claude runtime surfaces: the lifecycle skill is MCP-only for agent sessions, the orchestrator contract names the `delegation_receipts.promotion.*` fields, and the Bash hook registration is present in `.claude/settings.json`.
- [x] Tests are updated in the existing `tests/scripts/claude-hooks/` and `tests/scripts/dev_tools/` suites to cover hook decisions, skill wording contracts, and additive orchestrator-state validation.
- [x] Edge cases are covered, including unavailable promotion MCP tools, forbidden Bash bypass attempts, benign Bash commands, and both legacy and nested `delegation_receipts` checkpoint shapes.
- [x] Documentation in the active feature folder is updated to reflect the final Claude-side contract and remains consistent with the issue and research artifact.
- [x] Hook block messaging and checkpoint receipt persistence expectations are documented wherever the runtime contract requires them; no additional telemetry sink is introduced.
- [x] The relevant documentation and validation checks pass in a final repository toolchain pass once implementation work is executed.

## Seeded Test Conditions (from potential)
- [ ] Hook coverage that proves the Bash pre-tool guard allows benign commands and blocks each forbidden promotion-script token with the required error message.
- [ ] Skill-content verification that confirms the lifecycle skill contains MCP preflight and receipt-capture requirements and no longer contains the banned fallback/script strings.
- [ ] Checkpoint validation coverage that confirms the documented schema accepts `delegation_receipts.promotion.potential_entry`, `.issue`, and `.feature_folder` as raw MCP receipt payloads.
- [ ] End-to-end orchestration verification that a promotion attempt records raw MCP receipts into the checkpoint and that a direct Bash bypass attempt is rejected before execution.
