# `2026-04-29-harden-feature-promotion-lifecycle-mcp-only` — User Story

- Issue: #168
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-04-29T08-56

## Story Statement

- As a repository orchestrator maintainer, I want Claude-side promotion guidance to require MCP-only execution and explicit receipt capture, so that every promotion step uses the supported tool surface and leaves an auditable checkpoint trail.
- As a developer resuming or reviewing orchestrated feature setup, I want promotion-script bypass attempts blocked and promotion receipts preserved under stable checkpoint keys, so that promotion runs remain deterministic, reviewable, and safe to resume.

## Problem / Why

The Claude-side `feature-promotion-lifecycle` skill still documents fallback script paths and alternate execution routes, which weakens the contract that agent sessions must use the `drmCopilotExtension` MCP tool surface for promotion work. The current Bash pre-tool hook only blocks destructive shell patterns, so direct Bash invocations of promotion scripts can still bypass the intended MCP path, and the checkpoint documentation does not yet spell out the raw promotion receipt fields that should be retained under `delegation_receipts.promotion`.

This gap makes promotion behavior less deterministic, less auditable, and easier to drift away from the supported agent workflow. Hardening the skill, hook registration, and checkpoint schema documentation would make MCP invocation mandatory for agent sessions without changing the underlying promotion scripts or MCP server implementation.


## Personas & Scenarios

- Persona: Repository orchestration maintainer
  - Maintains the Claude runtime contract in `.claude/`, including skills, hooks, and checkpoint expectations.
  - Cares about deterministic agent behavior, narrow enforcement surfaces, and documentation that matches the runtime implementation.
  - Must keep scope limited to Claude-side guidance, settings, hooks, and checkpoint validation/documentation; cannot change `scripts/dev_tools/` promotion implementations or the MCP server.
  - Wants promotion flows to fail closed when MCP access is unavailable instead of silently drifting to fallback scripts.
  - Is motivated by auditability and resumability: a future reviewer or resumed orchestrator session must be able to see exactly which promotion step ran and what raw MCP receipt it returned.
- Persona: Feature author using orchestrated setup
  - Relies on the orchestrator to create or promote feature artifacts without needing to know the underlying script layout.
  - Cares that promotion either succeeds through the approved MCP path or is blocked early with a clear reason.
  - Is constrained by team-shared `.claude/settings.json` permissions and pre-tool hooks that apply across the repository.
  - Becomes frustrated when a direct Bash invocation appears to work but bypasses checkpoint capture or later fails validation.
  - Wants the resulting `artifacts/orchestration/orchestrator-state.json` file to remain resumable across interrupted sessions.
- Scenario: MCP-only promotion during large-path orchestration
  - The repository orchestration maintainer updates the Claude runtime contract after discovering that the current `feature-promotion-lifecycle` skill still advertises fallback script commands.
  - A feature author starts a large-path workflow that needs potential-entry creation, issue promotion, and active-feature-folder initialization.
  - Before any promotion step runs, the orchestrator checks that the required `drmCopilotExtension` promotion tools are available and then executes the lifecycle only through those MCP operations.
  - During the run, the orchestrator captures each raw MCP receipt and stores it under `delegation_receipts.promotion.potential_entry`, `delegation_receipts.promotion.issue`, and `delegation_receipts.promotion.feature_folder` in `artifacts/orchestration/orchestrator-state.json`.
  - If someone attempts to bypass the lifecycle with a direct Bash invocation that contains a forbidden promotion token, the Bash pre-tool hook blocks the command before execution and returns the required policy message.
  - The maintainer expects the updated skill, settings, hook, and checkpoint validator/documentation surfaces to agree on this behavior, while unrelated Bash usage and the underlying promotion modules remain unchanged.


## Acceptance Criteria

- [x] `.claude/skills/feature-promotion-lifecycle/SKILL.md` is rewritten so agent-session promotion guidance is MCP-only, includes an explicit preflight verification that the required promotion MCP tools are available before execution begins, and requires raw receipt capture for the potential-entry, issue-promotion, and active-feature-folder steps.
- [x] When the required promotion MCP tools are unavailable, the documented lifecycle stops before any promotion step runs and does not direct agent sessions to `scripts/dev_tools/`, `scripts/dev-tools/`, or `poetry run python -m scripts...` fallback commands.
- [x] The skill no longer contains fallback-script sections or any remaining direct script guidance, and grep-based verification against `.claude/skills/feature-promotion-lifecycle/` shows no matches for `Fallback`, `fallback`, `dev_tools`, `dev-tools`, or `poetry run python -m scripts`.
- [x] The only documented non-MCP alternative remaining in `.claude/skills/feature-promotion-lifecycle/SKILL.md` is a single VS Code command-palette note that is explicitly marked non-authoritative for agent sessions.
- [x] `.claude/settings.json` registers the required PreToolUse Bash hook, and a dedicated hook script under `.claude/hooks/` allows benign Bash commands but blocks invocations containing `new-potential-entry.ps1`, `new_potential_bug_entry`, `potential_to_issue`, or `new_active_feature_folder` by returning the required error message before execution.
- [x] The checkpoint contract is documented to support `delegation_receipts.promotion.potential_entry`, `delegation_receipts.promotion.issue`, and `delegation_receipts.promotion.feature_folder`, and those fields are defined as the raw MCP receipts captured from the corresponding promotion operations without lossy normalization.
- [x] `scripts/dev_tools/validate_orchestration_artifacts.py` and its tests accept the current nested `delegation_receipts.promotion.*` checkpoint shape additively while preserving compatibility with the existing list-based `delegation_receipts` validation path.
- [x] The change remains limited to Claude-side skill, settings, hook, and checkpoint-schema documentation/validation surfaces; no underlying `scripts/dev_tools/` promotion modules are modified, and no MCP server implementation changes are introduced.


## Non-Goals

- Modifying the promotion implementations under `scripts/dev_tools/` or `scripts/dev-tools/`.
- Changing the `drmCopilotExtension` MCP server implementation, tool semantics, or receipt payload shape.
- Expanding the Bash guard into a generic shell-policy rewrite beyond the four promotion-bypass tokens named in the issue.
- Synchronizing mirrored lifecycle content outside the root `.claude/` runtime tree unless a separate follow-up explicitly covers mirror updates.
- Redesigning the overall orchestration checkpoint model beyond additive support for `delegation_receipts.promotion.{potential_entry,issue,feature_folder}`.
