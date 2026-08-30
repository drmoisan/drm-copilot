# preimplementation-gate-bare-hash-record-resolution (Spec)

- **Issue:** #606
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-30T07-30
- **Status:** Draft
- **Version:** 0.1

## Context
The shared PowerShell mode helper used by the orchestration preimplementation gate fails to parse the keyed human-readable form `Issue number: 644`. It also resolves checkpoint records in a single pass, allowing an earlier issue-only record to hide a later record whose feature-folder identity exactly matches the target; a terminal status on the wrong record can therefore block a ready operation.

Environment:
- OS/version: Windows PowerShell repository environment.
- Python version: Not applicable to production behavior; Python executes the Claude resource parity test.
- Command/flags used: PreToolUse evaluation by `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` using its mode helper.
- Data source or fixture: Orchestration checkpoint `features` and `parallel.items` records, with literal JSON fixtures in the focused Pester suite.

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Pass a prompt containing `Issue number: 644` to `Find-OrchestrationDelegationIssueNumber`.
2. Provide checkpoint records where an earlier sibling has the prompt issue number and terminal `merge_status`, while a later sibling has the exact target feature-folder and a non-terminal status.
3. Evaluate epic `features` or parallel `items` readiness through the gate.

Expected:
The parser returns `644`. The resolver considers all normalized feature-folder candidates before issue fallback, selecting the later exact-folder record and allowing readiness when that record is non-terminal. If no folder matches, it returns the first issue-number match in collection order.

Actual:
The keyed parser does not accept the whitespace-separated form. The single-pass resolver returns the earlier issue-only record before reaching the exact-folder record; a terminal status on that record produces the established `PREIMPLEMENTATION_GATE_BLOCKED` denial with the `merge_status` predicate.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot (not required; deterministic Pester fixtures provide the reproduction).
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED` is the diagnostic prefix that must remain stable.


## Scope & Non-Goals
- In scope: The keyed issue-token parser and record-selection order in `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`; identical publication of that helper to the bundled Claude customization; focused Pester regressions and existing parity validation.
- Out of scope / non-goals: Changes to checkpoint schema, lifecycle readiness, prompt-folder resolution, terminal-status definitions, mode semantics, or broad gate diagnostics.
- Explicitly excluded systems, integrations, or datasets: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, orchestration checkpoint contents, external consumers, and new dependencies.

## Root Cause Analysis
`Find-OrchestrationDelegationIssueNumber` uses a keyed pattern that accepts `issue_num` and `issue-number` but not `Issue number`. `Find-OrchestrationModeRecord` checks feature-folder and issue-number matches during the same collection pass. As a result, issue fallback can return before a later exact folder candidate is inspected. Epic and parallel readiness predicates share this resolver and then reject the selected record for terminal `merge_status`, so correct selection is required before their readiness decision is reliable.


## Proposed Fix

### Design summary (what changes where):
Widen the keyed issue parser separator to include whitespace without changing the captured digits or existing accepted forms. Refactor the shared record resolver into two ordered passes: normalized feature-folder matching across all non-null records, followed by issue-number fallback only when no folder match exists. Copy the final root helper bytes exactly to the bundled Claude customization and add narrowly scoped Pester regressions.

### Boundaries and invariants to preserve:
- `Find-OrchestrationModeRecord -Records -TargetFolder -IssueNumber` continues to return one record or `$null` and consumes the existing `issue_num`, `feature_folder`, and optional `merge_status` keys.
- Exact normalized feature-folder identity takes precedence over issue fallback regardless of collection order; fallback remains the first issue match when no folder matches.
- Case-insensitive parsing, optional `#`, colon/equal separators, underscore/hyphen keyed forms, bare-hash fallback, terminal status handling, and absent-status behavior remain unchanged.
- The deny-reason contract retains its `PREIMPLEMENTATION_GATE_BLOCKED` prefix and existing predicate-based wording; no resolved issue or status details are appended.
- The root and bundled mode-helper files remain raw-byte identical.

### Dependencies or blocked work:
No new dependency or schema migration is required. Focused Pester and resource-parity commands were previously denied before launch by the preimplementation gate; they must be rerun after the now-ready checkpoint permits implementation commands.

### Implementation strategy (what changes, not sequencing):
Modify only the shared mode helper's parser and resolver, publish the same resulting bytes to its bundled mirror, and extend the existing focused Pester suite. Do not alter the main gate decision function, checkpoint data model, or diagnostic construction.
#### Files/modules to change:
- `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`

#### Functions/classes/CLI commands impacted:
- `Find-OrchestrationDelegationIssueNumber`
- `Find-OrchestrationModeRecord`
- The existing epic and parallel readiness predicates that call the shared resolver

#### Data flow and validation changes:
- Prompt text is first parsed for a keyed issue token. The parser must recognize `Issue number: 644` as `644` while continuing to accept current keyed forms and bare hashes.
- Checkpoint records are searched in two stages: all non-null records for a normalized `feature_folder` basename equal to the target, then all non-null records for `issue_num` equal to the parsed issue if no folder match exists.
- Existing readiness predicates evaluate `merge_status` only on the resolver's selected record. Tests must exercise the mixed-record order for both epic `features` and parallel `items` paths.

#### Error handling and logging updates:
- Do not change `Get-OrchestrationModeDenyReason` or the main preimplementation-gate hook. Keep `PREIMPLEMENTATION_GATE_BLOCKED`, the mode, canonical checkpoint path, and failed-predicate diagnostic format unchanged.

#### Rollback/feature-flag considerations (if applicable):

No feature flag is required. Revert the paired helper and focused test changes together if a compatibility regression is identified; the raw-byte parity requirement prevents partial publication.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input prompt text may contain `Issue number: <digits>`, existing underscore/hyphen keyed forms, or a bare `#<digits>` fallback.
- Input records remain PowerShell objects decoded from checkpoint JSON with `issue_num`, `feature_folder`, and optional `merge_status` properties.
- The parser returns the digit string or `$null`; the resolver returns the selected record or `$null`; existing gate decision JSON and deny text are unchanged.

#### Required configuration keys and defaults:
- No new configuration keys or defaults. Existing checkpoint keys and terminal values `merged` and `worktree_removed` remain authoritative.

#### Backward-compatibility expectations:
- Existing accepted prompt forms and bare-hash fallback continue to work. Existing issue-number fallback remains available only after the complete folder search produces no match. Downstream consumers continue receiving the current deny reason contract.

#### Performance constraints (latency/throughput/memory):
- The two-pass in-memory record scan is linear in the record count and introduces no I/O, persistence, network, or dependency change. Gate behavior must remain suitable for synchronous PreToolUse evaluation.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): The active checkpoint is available to the gate; its records use the established property names; the execution environment provides PowerShell 7 and Pester 5 for focused tests.
- Constraints (budget, performance, compatibility): Limit production changes to the live mode helper and its bundled mirror; preserve byte parity and the diagnostic contract; do not add dependencies or modify the checkpoint schema.
- External dependencies (services, libraries, releases): No external service is involved. Python executes the existing repository parity test.

## Data / API / Config Impact
- User-facing or API changes: The gate newly accepts the already human-readable keyed prompt form `Issue number: <digits>`; no new command or API surface is introduced.
- Data or migration considerations: No checkpoint migration; existing records are read with their current fields.
- Logging/telemetry updates (if any): No new logging or telemetry. Existing denial diagnostics remain unchanged.
- Compatibility notes (CLI flags, config schemas, versioning): Existing keyed forms and bare-hash fallback remain supported; root and bundled hook content must remain byte-identical.

## Test Strategy
Seeded from issue:

- [ ] Focused Pester coverage for keyed parsing, ordered folder-first resolution, and both readiness paths.
- [ ] Rerun the deterministic gate scenarios through the focused suite once the checkpoint permits commands.
- [ ] Verify the root and bundled helper copies are raw-byte identical through the existing Claude resource contract test.

- Regression tests to add or update: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`.
- Unit tests (Pester) for the fixed behavior and boundaries: Add a keyed-parser case for `Issue number: 644`; retain coverage for bare `#638`; add epic and parallel cases with an earlier issue-only terminal sibling and a later exact-folder non-terminal sibling.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): Preserve null result when neither key matches, issue fallback when no folder matches, normalized folder matching, and terminal status handling for the correctly resolved record.
- Error handling and logging verification: Assert decision-level diagnostics continue to match the existing `PREIMPLEMENTATION_GATE_BLOCKED` prefix and failed predicate without adding resolution details.
- Coverage impact and targets for changed lines/modules: Cover the parser's whitespace separator and both resolver passes through existing deterministic Pester fixtures; new and changed helper behavior targets at least 90% coverage under repository policy.
- Toolchain commands to run (format → lint → type-check → test): Run applicable PowerShell formatting and PSScriptAnalyzer checks, then `Invoke-Pester -Path 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1' -CI -Output Detailed`; run `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` for raw-byte parity. Restart the applicable toolchain loop from formatting if any formatting step changes files.
- Manual validation steps (if required): Confirm `Issue number: 644` resolves to `644`; confirm a later exact-folder record wins in both readiness modes; confirm the no-folder-match fallback remains available.


## Acceptance Criteria
- [x] `Find-OrchestrationDelegationIssueNumber` returns `644` for `Issue number: 644` while preserving case-insensitive parsing, existing underscore/hyphen keyed forms, optional `#`, colon/equal separators, and bare-hash fallback.
- [x] `Find-OrchestrationModeRecord` searches all normalized `feature_folder` records before issue-number fallback, so a later exact-folder record is selected over an earlier issue-only record; if no folder matches, it returns the first matching issue record.
- [x] The focused Pester suite tests mixed prose with bare `#638` and records ordered with an earlier issue-only terminal sibling before a later exact-folder non-terminal sibling in both epic `features` and parallel `items` readiness paths.
- [x] The root and bundled `enforce-orchestration-preimplementation-gate-modes.ps1` hook copies are raw-byte identical, and the existing Claude resource parity test passes.
- [x] The gate retains the established `PREIMPLEMENTATION_GATE_BLOCKED` diagnostic prefix and predicate-based error contract; resolution details are not appended to the error.

## Risks & Mitigations
- Technical or operational risks: Broadening the parser could inadvertently alter existing capture behavior; changing selection order could remove valid fallback; updating only one hook copy would violate resource publication parity; changing denial text could break downstream reason matching.
- Mitigations and rollbacks: Preserve the existing digits capture and accepted forms; test no-folder-match fallback and both readiness paths; validate byte parity; leave the main gate and deny-reason helper unchanged. Revert the paired helper changes together if required.

## Rollout & Follow-up
- Release/rollout steps: Apply the minimal helper change to the root copy, copy it as identical raw bytes to the bundled resource, then pass focused Pester and resource-parity validation before normal repository delivery.
- Post-fix monitoring or clean-up tasks: Monitor preimplementation-gate denials for unexpected parser or record-selection regressions while retaining existing diagnostic matching. No telemetry work is introduced.
- Links: [Issue #606](https://github.com/drmoisan/drm-copilot/issues/606); `research/20260830-preimplementation-gate-record-resolution-research.md`.
