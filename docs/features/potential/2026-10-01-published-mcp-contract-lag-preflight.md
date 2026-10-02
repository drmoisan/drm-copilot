# published-mcp-contract-lag-preflight (Potential)

- Date captured: 2026-10-01
- Author: Dan Moisan
- Status: Draft
- Source: follow-up 1 of issue #484 (`docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/spec.md`, `## Out-of-Scope Follow-up: Published-MCP Contract Lag`; issue AC-6)

## Problem / Why

The Codex MCP transport is pinned to the repository's package version (`.codex/config.toml`, kept equal to `packages/mcp-server/package.json` `version` by a test). The package published under that version can predate repository validator and routing changes. Orchestration then fails validation for reasons no repository remediation can fix (issue #467: a Codex agent family added after `@danmoisan/drm-copilot-mcp@1.0.24` was published). The server reports its version only in the MCP `serverInfo` handshake, and nothing compares the published contract with the repository contract.

## Proposed Behavior

Detect the lag at orchestration startup and halt with `blocked_reason: "external_dependency"` rather than consuming remediation cycles.

## Acceptance Criteria (early draft)

- [ ] A deterministic contract fingerprint over `VALID_BLOCKED_REASONS`, `GENERATED_AGENT_FAMILIES`, the routing matrix, and the remediation-loop vocabularies (`REVIEW_VERDICTS`, `REMEDIABILITY_CLASSES`) is computed identically by a Python helper and by the TypeScript server.
- [ ] An MCP tool returns the fingerprint and package version; `.codex/config.toml` `enabled_tools`, its bundle copy, and the `EXPECTED_DRM_COPILOT_TOOLS` test list are updated.
- [ ] An orchestrator S0 preflight in both orchestrate skills compares the two fingerprints and records a mismatch as an `external_dependency` halt with a `human_interaction` `halt` requirement naming the release action.
- [ ] Tests cover fingerprint parity across runtimes and mismatch handling.

## Constraints & Risks

- Non-goals: automatic publishing; changing the pin policy.
- No enforcement hook gains a Python leg; the preflight is an orchestrator step, not a hook.
- The new MCP tool takes effect only after a publish, which is an irreversible release step.
- Estimated C3: about 6-9 production files and 4-6 test files across TypeScript, Python, and configuration.

## Test Conditions to Consider

- [ ] Unit coverage of the fingerprint function in Python and TypeScript, with a shared parity fixture
- [ ] Integration scenario: a published package whose fingerprint differs from the repository's produces an `external_dependency` halt
- [ ] CLI/API examples: the MCP tool's response shape

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/published-mcp-contract-lag-preflight/` folder from the template
