# 2026-06-27-harden-claude-pretooluse-hook-schema — Spec

- **Issue:** #259
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-27T20-46
- **Status:** Draft
- **Version:** 0.1

## Overview

In the Claude Code / Agent SDK harness, the hook event type determines which block-decision JSON schema the harness honors. At `PreToolUse`, a hook denies a tool call only when it writes the `hookSpecificOutput` form to stdout:

```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<reason>"}}
```

The legacy top-level form `{"decision":"block","reason":"..."}` is ignored at `PreToolUse`, and the tool call proceeds (fail-open). An `exit 1` is also non-blocking at `PreToolUse`.

A survey of `.claude/hooks/` confirms that every PreToolUse-registered hook in drm-copilot currently emits the legacy top-level `decision='block'/'allow'` form (`permissionDecision` appears in no hook), and several rely on `exit 1` to block. These guards are therefore fail-open: they do not actually deny tool calls. This was verified live in the sibling repository rgf-forecast, where a PR was created despite a registered `pr-author` guard because the guard emitted the top-level form at `PreToolUse`.

SubagentStop / PostToolUse / UserPromptSubmit hooks correctly honor the top-level `{"decision":"block","reason":"..."}` form (and `exit 1`); those must not be changed.


## Behavior

1. Fix the PreToolUse deny-schema across every PreToolUse-registered hook so each guard actually denies via the `hookSpecificOutput`/`permissionDecision` form. Decision logic is unchanged; only the serialization/return shape and the final decision-gate comparison change.
2. Add a serialize-then-parse schema contract test that locks the exact harness-consumed field names for every PreToolUse hook, so any future regression to the top-level form fails CI.
3. Port additive SubagentStop validator hardening (multi-language executor status, multi-language coverage floors, routing-contract delegation, human-interaction shape gate, research-root and automation-feasibility gates) while keeping the SubagentStop top-level `decision:block` / `exit 1` form.
4. Port the checkpoint-monotonic prerequisite gate, the new PreToolUse gate hooks, and (conditionally) the completion-consistency hook, all born on the correct PreToolUse schema.
5. Keep the runtime hooks and their bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` in sync.


## Inputs / Outputs

- Inputs:
  - The Claude tool-call JSON delivered to each PreToolUse hook on standard input and via the environment variables `CLAUDE_TOOL_INPUT` / `CLAUDE_HOOK_INPUT`. This payload carries the tool name and the tool arguments (for example the Bash command string, or the Write/Edit file path and content) that the hook inspects to reach an allow or deny decision.
  - The orchestrator checkpoint at `artifacts/orchestration/orchestrator-state.json`, read by the gate hooks (`enforce-orchestration-preimplementation-gate.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-feature-folder-order.ps1`, `enforce-completion-consistency.ps1`, `enforce-prd-feature-before-planner.ps1`) to evaluate orchestration-state prerequisites.
- Outputs:
  - A single JSON decision object written to stdout. Two decision shapes apply:
    - **PreToolUse allow/deny (`hookSpecificOutput` form).** A deny is honored only when the hook writes:
      ```json
      {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<reason>"}}
      ```
      An allow uses `permissionDecision` value `allow` in the same envelope, or emits no decision (absence of a deny is treated as allow at PreToolUse).
    - **SubagentStop block (top-level form, unchanged).** SubagentStop validators continue to emit the top-level shape `{"decision":"block","reason":"<reason>"}` together with `exit 1`. This form is honored at SubagentStop and must not be changed.
- Config keys and defaults: No new configuration keys. Hook registration (matchers and file paths) remains in `.claude/settings.json`; the registration set is unchanged by this feature.
- Versioning or backward-compatibility constraints: The PreToolUse decision shape is the harness-consumed contract. SubagentStop / PostToolUse / UserPromptSubmit hooks must retain the top-level `decision`/`exit 1` form. No public CLI or API outside the hook surface changes.

## API / CLI Surface

The surface affected by this feature is the JSON decision contract that each hook writes to stdout. There are no new commands or flags.

- **Canonical PreToolUse decision object (deny):**
  ```json
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<reason>"}}
  ```
  Field names and values are exact:
  - `hookSpecificOutput.hookEventName` is the literal string `PreToolUse`.
  - `hookSpecificOutput.permissionDecision` is one of `allow` or `deny`.
  - `hookSpecificOutput.permissionDecisionReason` carries the deny reason and is required on `deny`.
- **Canonical PreToolUse decision object (allow):**
  ```json
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
  ```
  Equivalently, a hook may emit no decision object on an allow path; the harness treats the absence of a deny as an allow at PreToolUse.
- **SubagentStop decision object (unchanged):** SubagentStop hooks retain the top-level form `{"decision":"block","reason":"<reason>"}` and `exit 1`. This is the form the harness honors at SubagentStop and is out of scope for modification.
- Contracts and validation rules:
  - At PreToolUse, the top-level `{"decision":"block","reason":"..."}` form and `exit 1` are ignored (fail-open). No PreToolUse hook may rely on either to deny.
  - The serialize-then-parse contract test at `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` locks the exact field names above for every PreToolUse hook.

## Data & State

This feature changes the serialization shape of hook decisions; it does not introduce new persistent state.

- Bundled-mirror parity invariant: Every runtime hook under `.claude/hooks/` has a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. The mirror root is confirmed to contain all 21 hook files, matching the runtime set exactly. Parity is enforced by the pytest contract test at `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, which enumerates `.claude/**` files (excluding `settings.local.json` and `.claude/agent-memory/**`) and asserts byte-identical content between the repo-root copy and the bundled copy. Any runtime hook edit that is not replicated to its mirror fails this test.
- `settings.json` is also mirrored: `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` falls within the `.claude/**` parity scope, so any change to the runtime `settings.json` must be replicated to the bundled copy or the parity test fails.
- Data transformations and invariants:
  - The decision-object construction changes from the top-level `decision`/`reason` literal to the `hookSpecificOutput` envelope. The decision logic that selects allow versus deny is unchanged; only the object shape and the final decision-gate comparison change.
  - A known pre-existing parity divergence in `validate-bash.ps1` (the mirror omits `-ErrorAction Stop` on `ConvertFrom-Json` present in the runtime copy) must be resolved in the same batch as the runtime change so the parity test passes.
- Caching or persistence details: Hooks that maintain batch-budget state (`enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`) continue to read and write their state file through their existing injectable seams; the `state` key is stripped from the decision object before emission, as in the current implementation.
- Migration or backfill requirements: None. No persisted artifact format changes.

## Constraints & Risks

- PowerShell change subject to the 500-line file cap and the per-batch cap of 3 production + 3 test files; execution must be phased.
- Must not delete or weaken any SubagentStop hook.
- Runtime hooks have a bundled mirror enforced by contract tests; every runtime edit requires a matching mirror edit.
- The live-harness denial is out-of-band and is not a Pester test; the in-repo proving artifact is the contract test.


## Implementation Strategy

- Implementation scope:
  - **Mechanical schema substitution.** In each PreToolUse hook, replace the block object literal (`decision = 'block'; reason = ...`) with the `hookSpecificOutput` deny shape, and ensure allow paths emit the corresponding allow shape or no decision. The final decision-gate comparison that distinguishes allow from deny is updated to read `permissionDecision` rather than the top-level `decision` field. Decision logic is otherwise unchanged.
  - **`validate-bash.ps1` restructuring.** This hook currently blocks via `Write-Error` + `exit 1` with no stdout JSON. Restructure it into a pure detector (a function returning the matched blocked pattern or `$null`), a pure deny-decision builder that returns the `hookSpecificOutput` object, and an orchestrator that reads the tool input and returns allow or deny. Add the dot-sourcing guard (`if ($MyInvocation.InvocationName -eq '.') { return }`) and replace the `exit 1` deny path with emit + `exit 0`.
  - **`check-powershell-test-purity.ps1` restructuring.** Extract a pure `Get-PowerShellTestPurityBlockDecision` deny-builder (mirroring the Python purity hook), convert the inline plain `@{}` block object to `[ordered]@{}` carrying the `hookSpecificOutput` shape, and add the dot-sourcing guard so the contract test can dot-source it.
  - **JSON serialization depth.** Because the `hookSpecificOutput` envelope is a nested plain hashtable, emission uses `ConvertTo-Json -Depth 5` so the nested object is serialized in full rather than truncated at the default depth.
  - **New contract test.** Add `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, a serialize-then-parse test that dot-sources each PreToolUse hook, invokes its pure decision function with a constructed deny payload, and asserts the emitted JSON contains `hookEventName == 'PreToolUse'` and `permissionDecision == 'deny'`.
- New / updated functions:
  - New in `validate-bash.ps1`: pure pattern detector, pure deny-decision builder, and an `Invoke-ValidateBashDecision` orchestrator.
  - New in `check-powershell-test-purity.ps1`: pure `Get-PowerShellTestPurityBlockDecision`.
  - All other PreToolUse hooks already expose a pure `Invoke-*Decision` or `Get-*BlockDecision` function; these require the schema substitution at the block site and at the entrypoint emission, not new authoring.
- Scope of Parts 3-6: The SubagentStop validator functions (Part 3), the checkpoint-monotonic prerequisite gate (Part 4), the new PreToolUse gate hooks (Part 5), and the completion-consistency hook and helpers (Part 6) already exist in `.claude/hooks/`. For these, the work is the PreToolUse schema fix plus gap verification against the research inventory, not net-new authoring, except where the research identifies a specific gap (for example the `validate-bash.ps1` pure-function extraction and the `check-powershell-test-purity.ps1` function extraction and guard).
- Per-batch phasing: Execution is phased into batches of at most 3 production `.ps1` files plus 3 test `.ps1` files. Each runtime hook is always paired with its bundled mirror in the same batch (2 production files), keeping the parity contract test green at every batch boundary. The recommended 14-batch sequence is enumerated in the research inventory, beginning with `validate-bash.ps1` (highest priority, currently emits nothing on deny).
- Dependency changes: None. No new packages.
- Logging/telemetry additions: None. Hooks write only their decision object to stdout; error paths retain their existing `exit 1` non-deny hard-failure behavior.
- Rollout plan: No feature flags. The change is enforced at merge by the contract test, the per-hook tests, the bundle-parity pytest, and PoshQC gates. The live-harness denial is verified out-of-band and is not a Pester test; the in-repo proving artifact is the contract test.

## Definition of Done

Each acceptance criterion is mapped to its verifying test or check:

- [x] **Every PreToolUse-registered hook emits the `hookSpecificOutput`/`permissionDecision=deny` shape for blocks and the `permissionDecision=allow` shape for allows; no PreToolUse hook emits a top-level `decision`/`reason` shape or uses `exit 1` to block.** — Verified by the serialize-then-parse contract test `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (asserts the `hookSpecificOutput` field set per hook) and by each hook's per-hook Pester test under `tests/scripts/claude-hooks/` (positive/negative decision assertions updated to the new shape).
- [x] **`validate-bash` blocks via a pure detector plus a deny-decision builder that writes the `hookSpecificOutput` form, never `exit 1`.** — Verified by `tests/scripts/claude-hooks/validate-bash.Tests.ps1` exercising the extracted pure detector and deny-decision builder, and by the contract test asserting the emitted `hookSpecificOutput` shape.
- [x] **A serialize-then-parse contract test asserts `permissionDecision=deny` and `hookEventName=PreToolUse` for every PreToolUse hook.** — Verified by the existence and passing of `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`.
- [x] **SubagentStop validator hardening (Parts 3.1–3.4) is ported without changing the SubagentStop block form.** — Verified by the SubagentStop validator Pester tests (`validate-executor-output`, `validate-feature-review-coverage`, `validate-orchestrator-output`, `validate-task-researcher-output`), which assert the multi-language executor status, multi-language coverage floors, routing-contract delegation, human-interaction shape gate, and research-root / automation-feasibility gates while retaining the top-level `decision:block` / `exit 1` form.
- [x] **The checkpoint-monotonic prerequisite gate (Part 4) and new PreToolUse gate hooks (Part 5) are present, registered, and tested on the correct schema.** — Verified by `tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1` (in-order allow with S3/S4 present; deny when `S3_promotion` / `S4_atomic_planning` is missing) and the per-hook tests for the new gate hooks (preimplementation gate, powershell batch budget, powershell test purity), all asserting the `hookSpecificOutput` shape; registration is confirmed in `.claude/settings.json`.
- [x] **Bundled mirror hooks match runtime hooks; bundle-parity contract tests pass.** — Verified by the pytest `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (byte-identical parity across `.claude/**`, including `settings.json`).
- [x] **PoshQC format clean, PSScriptAnalyzer 0 findings on changed files, all Pester hook tests pass, every touched `.ps1` <= 500 lines.** — Verified by the PoshQC format check, PSScriptAnalyzer run on changed files (0 findings), the full Pester hook suite, and the 500-line file-size cap check (projected totals in the research inventory keep every touched file under the cap).

## Seeded Test Conditions (from potential)
- [x] Per-hook deny-shape serialization assertions (contract test).
- [x] Per-hook positive/negative decision tests retained and updated to the new shape.
- [x] checkpoint-monotonic prerequisite-gate positive (in-order allow with S3/S4 present) and negative (deny naming missing S3_promotion/S4_atomic_planning) tests.
- [x] New gate hook tests (preimplementation gate, powershell batch budget, powershell test purity).
- [x] Bundle-parity contract tests (pytest) and PowerShell Pester suite.
