# harden-claude-pretooluse-hook-schema (Issue #259)

- Date captured: 2026-06-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/harden-claude-pretooluse-hook-schema/ (Issue #259)

- Issue: #259
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/259
- Last Updated: 2026-06-28
- Work Mode: full-feature

## Problem / Why

In the Claude Code / Agent SDK harness, the hook event type determines which block-decision JSON schema the harness honors. At `PreToolUse`, a hook denies a tool call only when it writes the `hookSpecificOutput` form to stdout:

```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<reason>"}}
```

The legacy top-level form `{"decision":"block","reason":"..."}` is ignored at `PreToolUse`, and the tool call proceeds (fail-open). An `exit 1` is also non-blocking at `PreToolUse`.

A survey of `.claude/hooks/` confirms that every PreToolUse-registered hook in drm-copilot currently emits the legacy top-level `decision='block'/'allow'` form (`permissionDecision` appears in no hook), and several rely on `exit 1` to block. These guards are therefore fail-open: they do not actually deny tool calls. This was verified live in the sibling repository rgf-forecast, where a PR was created despite a registered `pr-author` guard because the guard emitted the top-level form at `PreToolUse`.

SubagentStop / PostToolUse / UserPromptSubmit hooks correctly honor the top-level `{"decision":"block","reason":"..."}` form (and `exit 1`); those must not be changed.

## Proposed Behavior

1. Fix the PreToolUse deny-schema across every PreToolUse-registered hook so each guard actually denies via the `hookSpecificOutput`/`permissionDecision` form. Decision logic is unchanged; only the serialization/return shape and the final decision-gate comparison change.
2. Add a serialize-then-parse schema contract test that locks the exact harness-consumed field names for every PreToolUse hook, so any future regression to the top-level form fails CI.
3. Port additive SubagentStop validator hardening (multi-language executor status, multi-language coverage floors, routing-contract delegation, human-interaction shape gate, research-root and automation-feasibility gates) while keeping the SubagentStop top-level `decision:block` / `exit 1` form.
4. Port the checkpoint-monotonic prerequisite gate, the new PreToolUse gate hooks, and (conditionally) the completion-consistency hook, all born on the correct PreToolUse schema.
5. Keep the runtime hooks and their bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` in sync.

## Acceptance Criteria (early draft)

- [ ] Every PreToolUse-registered hook emits the `hookSpecificOutput`/`permissionDecision=deny` shape for blocks and the `permissionDecision=allow` shape for allows; no PreToolUse hook emits a top-level `decision`/`reason` shape or uses `exit 1` to block.
- [ ] `validate-bash` blocks via a pure detector plus a deny-decision builder that writes the `hookSpecificOutput` form, never `exit 1`.
- [ ] A serialize-then-parse contract test asserts `permissionDecision=deny` and `hookEventName=PreToolUse` for every PreToolUse hook.
- [ ] SubagentStop validator hardening (Parts 3.1–3.4) is ported without changing the SubagentStop block form.
- [ ] The checkpoint-monotonic prerequisite gate (Part 4) and new PreToolUse gate hooks (Part 5) are present, registered, and tested on the correct schema.
- [ ] Bundled mirror hooks match runtime hooks; bundle-parity contract tests pass.
- [ ] PoshQC format clean, PSScriptAnalyzer 0 findings on changed files, all Pester hook tests pass, every touched `.ps1` <= 500 lines.

## Constraints & Risks

- PowerShell change subject to the 500-line file cap and the per-batch cap of 3 production + 3 test files; execution must be phased.
- Must not delete or weaken any SubagentStop hook.
- Runtime hooks have a bundled mirror enforced by contract tests; every runtime edit requires a matching mirror edit.
- The live-harness denial is out-of-band and is not a Pester test; the in-repo proving artifact is the contract test.

## Test Conditions to Consider

- [ ] Per-hook deny-shape serialization assertions (contract test).
- [ ] Per-hook positive/negative decision tests retained and updated to the new shape.
- [ ] checkpoint-monotonic prerequisite-gate positive (in-order allow with S3/S4 present) and negative (deny naming missing S3_promotion/S4_atomic_planning) tests.
- [ ] New gate hook tests (preimplementation gate, powershell batch budget, powershell test purity).
- [ ] Bundle-parity contract tests (pytest) and PowerShell Pester suite.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create active feature folder from the template
