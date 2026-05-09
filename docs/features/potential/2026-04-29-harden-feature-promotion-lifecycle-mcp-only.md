# harden-feature-promotion-lifecycle-mcp-only (Potential)

- Date captured: 2026-04-29
- Author: Dan Moisan
- Status: Draft

## Problem / Why

The Claude-side `feature-promotion-lifecycle` skill still documents fallback script paths and alternate execution routes, which weakens the contract that agent sessions must use the `drm-copilot` MCP tool surface for promotion work. The current Bash pre-tool hook only blocks destructive shell patterns, so direct Bash invocations of promotion scripts can still bypass the intended MCP path, and the checkpoint documentation does not yet spell out the raw promotion receipt fields that should be retained under `delegation_receipts.promotion`.

This gap makes promotion behavior less deterministic, less auditable, and easier to drift away from the supported agent workflow. Hardening the skill, hook registration, and checkpoint schema documentation would make MCP invocation mandatory for agent sessions without changing the underlying promotion scripts or MCP server implementation.

## Proposed Behavior

Harden the Claude-side promotion lifecycle so agent sessions have exactly one authoritative execution path for promotion work:

1. Rewrite `.claude/skills/feature-promotion-lifecycle/SKILL.md` so it is MCP-only for agent sessions, requires a preflight check that the promotion MCP tools are available before continuing, and requires the orchestrator to capture the raw MCP receipts for potential-entry creation, issue promotion, and active-feature-folder creation.
2. Remove the fallback-script sections and all remaining direct script references from that skill, including `dev_tools`, `dev-tools`, and `poetry run python -m scripts...` guidance.
3. Replace the current alternatives language with a single note that the related VS Code command-palette commands may exist for interactive use but are not authoritative for agent sessions.
4. Add or update `.claude/settings.json` so a PreToolUse Bash hook is registered for promotion guardrails, and add a hook under `.claude/hooks/` that blocks Bash invocations containing any of `new-potential-entry.ps1`, `new_potential_bug_entry`, `potential_to_issue`, or `new_active_feature_folder` and returns the required error message.
5. Confirm and document additive checkpoint-schema support for `delegation_receipts.promotion.potential_entry`, `delegation_receipts.promotion.issue`, and `delegation_receipts.promotion.feature_folder`, with each field retaining the raw MCP receipt payload captured during the promotion lifecycle.

## Acceptance Criteria (early draft)

- [ ] `.claude/skills/feature-promotion-lifecycle/SKILL.md` is rewritten so agent-session promotion guidance is MCP-only, includes an explicit preflight verification that the required promotion MCP tools are available before execution begins, and requires raw receipt capture for the potential-entry, issue-promotion, and active-feature-folder steps.
- [ ] The skill no longer contains fallback-script sections or any remaining direct script guidance, and grep-based verification against `.claude/skills/feature-promotion-lifecycle/` shows no matches for `Fallback`, `fallback`, `dev_tools`, `dev-tools`, or `poetry run python -m scripts`.
- [ ] The only documented non-MCP alternative remaining in `.claude/skills/feature-promotion-lifecycle/SKILL.md` is a single VS Code command-palette note that is explicitly marked non-authoritative for agent sessions.
- [ ] `.claude/settings.json` registers the required PreToolUse Bash hook, and a hook script under `.claude/hooks/` blocks Bash invocations containing `new-potential-entry.ps1`, `new_potential_bug_entry`, `potential_to_issue`, or `new_active_feature_folder` by returning the required error message.
- [ ] The checkpoint contract is documented to support `delegation_receipts.promotion.potential_entry`, `delegation_receipts.promotion.issue`, and `delegation_receipts.promotion.feature_folder`, and those fields are defined as the raw MCP receipts captured from the corresponding promotion operations.
- [ ] The change remains limited to Claude-side skill, settings, hook, and checkpoint-schema documentation/validation surfaces; no underlying `scripts/dev_tools/` promotion modules are modified, and no MCP server implementation changes are introduced.

## Constraints & Risks

- Out of scope: do not modify the underlying promotion implementations under `scripts/dev_tools/`, and do not modify the MCP server implementation.
- The new Bash guard must be narrow enough to block only promotion-script bypass attempts, because `.claude/settings.json` currently allows broad `Bash(poetry run *)` and `Bash(pwsh *)` execution for other workflows.
- Checkpoint changes should be additive and documented clearly so existing in-progress orchestration state can still be resumed or migrated without losing prior receipt data.
- The repository contains mirrored lifecycle content outside `.claude/`; this feature should focus on Claude-side runtime enforcement and documentation unless a separate follow-up is opened for mirror synchronization.

## Test Conditions to Consider

- [ ] Hook coverage that proves the Bash pre-tool guard allows benign commands and blocks each forbidden promotion-script token with the required error message.
- [ ] Skill-content verification that confirms the lifecycle skill contains MCP preflight and receipt-capture requirements and no longer contains the banned fallback/script strings.
- [ ] Checkpoint validation coverage that confirms the documented schema accepts `delegation_receipts.promotion.potential_entry`, `.issue`, and `.feature_folder` as raw MCP receipt payloads.
- [ ] End-to-end orchestration verification that a promotion attempt records raw MCP receipts into the checkpoint and that a direct Bash bypass attempt is rejected before execution.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/harden-feature-promotion-lifecycle-mcp-only/` folder from the template

