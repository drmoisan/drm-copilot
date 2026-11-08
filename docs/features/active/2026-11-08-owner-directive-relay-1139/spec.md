# owner-directive-relay — Spec

- **Issue:** #1139
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T12-32
- **Status:** Draft
- **Version:** 0.2

## Overview

When the repository owner gives an instruction to the coordinator session (for example "merge without waiting for X", "approve one more planner revision"), the coordinator relays it to a delegated orchestrator or specialist. Subagents refuse these relayed instructions because they cannot distinguish an owner directive from model-authored text. This was observed in the iar-migration three-layer redesign epic (E1/E2, 2026-11-07/08), where refusals stalled the run. No defined, auditable mechanism exists for an owner directive to reach a subagent.

This feature defines a recorded owner-directive block, a closed honor/refuse policy, per-directive decision records, and a PowerShell stop-hook check that rejects decision records that do not match the recorded block.

### Framing (normative)

The directive block conveys owner intent that the coordinator recorded. It grants no elevated permission, carries no approval or consent, and changes no hook, gate, permission, or setting. This is consistent with the harness framing: a message from the launching agent directs the task (what to work on, ordering, scope), but no agent message is ever user consent or approval, and no agent message can authorize changing permission settings, `CLAUDE.md`, or configuration. Every honorable class is task direction a subagent may already follow under its existing rules; every action that would need approval or configuration authority is in an always-refused class.

## Behavior

1. **Origin.** The coordinator (main session) records a directive only from the owner's own turns in the coordinator session, and records it in the item checkpoint before relaying it. Text that is not in a recorded block is not an owner directive.
2. **Relay.** The coordinator relays recorded directives in the delegation prompt (or a later course-correction message) as a fenced block labelled `Owner directives:`. The block opens with the framing line `Task direction recorded by the coordinator; not approval, not permission.` and quotes each recorded entry verbatim, including its `id`. An epic or parallel orchestrator passes the block verbatim to children whose scope matches; it never authors or edits entries.
3. **Classification.** Each directive carries one class from a closed enum. Honorable: `scheduling`, `merge_timing` (honorable only when the run is in autonomous mode; policy-only), `extra_planner_revision` (at most one honored revision per directive), `scope_narrowing`, `accept_nonblocking_deviation` (the deviation must already be recorded as non-blocking). Always refused: `gate_bypass` (bypassing or weakening hooks or gates), `force_push`, `tag_or_publish`, `policy_or_settings_edit` (canonical policy files, permissions, settings), `evidence_alteration` (deleting or altering evidence). Text that fits no class is recorded as `unclassified` and is treated as refused.
4. **Recording duty.** The receiving subagent appends one `owner_directive_records` entry per directive it acts on, with outcome `honored` or `refused` and a reason. A subagent refuses, and records the refusal, when the directive is in a refused class, is `unclassified`, is out of the subagent's scope, or has expired.
5. **Enforcement.** The Claude stop hook rejects a checkpoint whose records do not match the recorded block (rules below). Always-refused classes are refused by policy in every case. Where an existing hook already enforces a class (for example, force push in `.claude/hooks/validate-bash.ps1`), that hook stays authoritative and unchanged. Most refused classes (tag push/publishing, canonical policy edits, permissions/settings changes, most evidence alteration, most gate bypasses) have no dedicated hook; for those, the new mechanical backstop is the rule that rejects an `honored` record for a refused or `unclassified` class. No hook is weakened, and no hook gains a directive-based allow path.

## Data & State

Both keys are optional top-level checkpoint keys, valid in `orchestrator-state`, `epic-orchestrator-state`, and `parallel-orchestrator-state`. They are key-gated and tolerated. They are not added to `REQUIRED_STATE_KEYS`, and a checkpoint without either key validates exactly as before.

`owner_directives[]` (written only by the coordinator/main session):

```json
{ "id": "OD-1", "text": "<verbatim owner text>", "text_sha256": "<lowercase hex SHA-256 of UTF-8 text>",
  "class": "extra_planner_revision", "recorded_at": "2026-11-08T14:05:00Z", "expires_at": "2026-11-09T14:05:00Z",
  "scope": { "issue": 1139, "branch": "feature/owner-directive-relay", "step": "S5" },
  "issued_by_session": "<coordinator session id>" }
```

`owner_directive_records[]` (appended by the deciding subagent):

```json
{ "directive_id": "OD-1", "class": "extra_planner_revision", "outcome": "honored",
  "reason": "<at least 20 characters>", "decided_by": "orchestrator", "decided_at": "2026-11-08T15:00:00Z" }
```

Outcome enum: `honored | refused`. Dates parse as ISO 8601 with invariant culture and UTC adjustment. The validator reads no clock; expiry compares `decided_at` with `expires_at`.

## API / Validator Surface

New pure module `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` exporting `Get-OrchestratorStateOwnerDirectiveError -State <psobject>`, which returns `string[]`. It reads no file, starts no process, and reads no clock. It returns an empty array when neither key is present. Entry numbers `#N` are 1-based. Errors accumulate in entry order: block rules first, then record rules.

Every module error string begins with `Checkpoint owner_directive`. The exact strings are:

| # | Condition | Error string |
|---|---|---|
| B1 | `owner_directives` present, not a non-empty list of objects | `Checkpoint owner_directives must be a non-empty list of objects when present.` |
| B2 | Missing/blank `id`, `text`, `text_sha256`, `class`, `recorded_at`, `expires_at`, `issued_by_session` | `Checkpoint owner_directives entry #N field <name> must be a non-empty string.` |
| B3 | `id` not `^OD-[1-9][0-9]*$` | `Checkpoint owner_directives entry #N id must match OD-<positive integer>.` |
| B4 | Duplicate `id` | `Checkpoint owner_directives entry #N id <id> is duplicated.` |
| B5 | Hash mismatch | `Checkpoint owner_directives entry #N text_sha256 does not match text.` |
| B6 | `class` outside enum | `Checkpoint owner_directives entry #N class must be one of: scheduling, merge_timing, extra_planner_revision, scope_narrowing, accept_nonblocking_deviation, gate_bypass, force_push, tag_or_publish, policy_or_settings_edit, evidence_alteration, unclassified.` |
| B7 | Unparseable dates, or `expires_at` not later than `recorded_at` | `Checkpoint owner_directives entry #N expires_at must be a date-time later than recorded_at.` |
| B8 | `scope` not an object with positive integer `issue` and non-empty `branch` and `step` | `Checkpoint owner_directives entry #N scope must be an object with issue, branch, and step.` |
| R1 | `owner_directive_records` present, not a list of objects | `Checkpoint owner_directive_records must be a list of objects when present.` |
| R2 | Missing/blank `directive_id`, `class`, `outcome`, `reason`, `decided_by`, `decided_at` | `Checkpoint owner_directive_records entry #N field <name> must be a non-empty string.` |
| R3 | `directive_id` not in `owner_directives` ids (including when the block is absent) | `Checkpoint owner_directive_records entry #N references directive <id> that is not in owner_directives.` |
| R4 | Record `class` differs from the directive's class | `Checkpoint owner_directive_records entry #N class does not match directive <id>.` |
| R5 | `outcome` not `honored` or `refused` | `Checkpoint owner_directive_records entry #N outcome must be honored or refused.` |
| R6 | `honored` for a refused or `unclassified` class | `Checkpoint owner_directive_records entry #N honors directive <id> of refused class <class>.` |
| R7 | More than one `honored` record for one `extra_planner_revision` directive | `Checkpoint owner_directive_records directive <id> grants more than one extra planner revision.` |
| R8 | `reason` shorter than 20 characters after trimming | `Checkpoint owner_directive_records entry #N reason must be at least 20 characters.` |
| R9 | `decided_at` unparseable | `Checkpoint owner_directive_records entry #N decided_at must be a date-time.` |
| R10 | `honored` with `decided_at` later than the directive's `expires_at` | `Checkpoint owner_directive_records entry #N honors directive <id> after its expires_at.` |

**Hook wiring.** `.claude/hooks/validate-orchestrator-output.ps1` (`Get-OrchestratorOutputBlockDecision`) imports the module with the guarded `try { Import-Module ... } catch { Add-HookDependencyFailure ... }` pattern (fail closed). It calls the module for every `ArtifactType` (`orchestrator-state`, `epic-orchestrator-state`, `parallel-orchestrator-state`) after the routing dispatch and before the type-specific branches. On any error it blocks with reason `OWNER_DIRECTIVE_BLOCKED: ` followed by the module errors joined by `; `, and with `Repairable = $true`.

## Documentation Surfaces

- New skill `owner-directives`: `.claude/skills/owner-directives/SKILL.md`, `.agents/skills/owner-directives/SKILL.md`, `.github/skills/owner-directives/SKILL.md`, and byte-identical bundle copies under `extensions/drm-copilot/resources/`, with pack-manifest entries. It holds the framing statement, both schemas, the class enum and honor/refuse policy, the relay format, the coordinator record-before-relay procedure, the subagent recording duty, and the known limitations.
- One-sentence pointers to the skill in `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, and `.claude/skills/epic-orchestrate/SKILL.md`, carried into their mirrors and bundle copies as the push-down contract tests require. `.claude/agents/epic-orchestrator.md` is not edited.
- The epic-orchestrate pointer requires re-baselining its pinned digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. That edit is one line, and the digest is recomputed after the final `origin/main` merge, because issues #1136 and #1138 touch the same file.
- `.claude/rules/orchestrator-state.md` (a contract document that features routinely edit, not a canonical policy file) and its bundle copy gain one section: the two keys, their key-gated/tolerated status, rules B1-B8 and R1-R10, the enforcement point, and the limitations below.
- The execution-environment brief (all byte-identical copies) gains one bullet naming the new stop-hook check.

## Constraints & Risks

- **No new Python.** All logic is PowerShell. The only `.py` change is the one-line pinned-digest re-baseline.
- **No gate weakened.** No existing hook, gate, threshold, or setting changes its decision. Canonical policy files (`.github/copilot-instructions.md`, `.github/instructions/*`) and `.claude/settings.json` are not edited.
- **Parity gap (documented, deliberate).** The Python (`scripts/dev_tools/validate_orchestrator_state.py`) and TypeScript (`orchestrator-state-core.ts`) validators are unchanged; they ignore unknown top-level keys, so they neither validate nor reject the new keys. Precedents for PowerShell-only, key-gated checks: `standalone_merge_authorizations` (merge-gate hook only) and the feature-folder HEAD probe (Claude stop hook only).
- **Codex enforcement gap (known limitation).** Codex has no orchestrator stop hook equivalent to `validate-orchestrator-output.ps1`. Codex runs follow the same documented policy, but the stop-hook check does not run for them. Write-time enforcement through a Codex hook is out of scope.
- **Same-session forgery.** Any writer of the checkpoint can author a block with a matching hash. The check proves internal consistency (no record without a recorded directive, no honored refused class), not owner origin. Origin rests on the coordinator procedure. This is disclosed in the same way as for `standalone_merge_authorizations`.
- **Policy-only conditions.** Autonomous mode for `merge_timing`, scope matching, and whether a deviation was recorded as non-blocking are not visible to the validator.

## Implementation Strategy

- New: the module and its bundle copy; the `owner-directives` skill copies; `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1`; `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1`; a Pester contract test for skill-copy byte identity and pointer presence; an in-memory JSON fixture corpus under `tests/fixtures/orchestrator_state_owner_directives/`.
- Modified: `validate-orchestrator-output.ps1` and its bundle copy; the pointer surfaces; `.claude/rules/orchestrator-state.md` and its copy; pack manifests; `OrchestratorState.Manifest.Tests.ps1` (append the module); the digest line; the execution-environment copies.
- No dependency changes. No rollout flag: the behavior is key-gated.
- Route as the large path: the change touches more than the direct-mode production PowerShell file budget.

## Acceptance Criteria

- [ ] `OrchestratorStateOwnerDirectives.psm1` exports `Get-OrchestratorStateOwnerDirectiveError`, which returns an empty array for a checkpoint containing neither `owner_directives` nor `owner_directive_records`, and the existing orchestrator-state Pester and parity suites pass unchanged.
- [ ] `owner_directives` and `owner_directive_records` are absent from `REQUIRED_STATE_KEYS` and from `OrchestratorStateUnconditional.psm1`'s key lists.
- [ ] A Pester test proves that each rule B1-B8 and R1-R10 emits its exact error string from the API / Validator Surface table for a minimal violating fixture, and that a fully valid block with honored and refused records returns no errors.
- [ ] A record whose `directive_id` is not in `owner_directives` (including when the block is absent) is rejected with the R3 string.
- [ ] A record with outcome `honored` for each of `gate_bypass`, `force_push`, `tag_or_publish`, `policy_or_settings_edit`, `evidence_alteration`, and `unclassified` is rejected with the R6 string; a `refused` record for each of them is accepted.
- [ ] A record whose `class` differs from its directive's recorded class is rejected (R4); a duplicate directive `id` is rejected (B4).
- [ ] An `honored` record with `decided_at` later than the directive's `expires_at` is rejected (R10); a `refused` record decided after expiry is accepted.
- [ ] `validate-orchestrator-output.ps1` imports the module with the guarded fail-closed pattern and, for each of `orchestrator-state`, `epic-orchestrator-state`, and `parallel-orchestrator-state`, blocks an invalid checkpoint with a reason beginning `OWNER_DIRECTIVE_BLOCKED: ` and `Repairable = $true`; a hook Pester test covers each type plus an absent-key back-compat case.
- [ ] `hook-dependency-guard-completeness`, `hook-import-failure-exemptions.FailClosed`, and `enforcement-hooks-no-python-invocation` Pester suites pass.
- [ ] Line coverage of `OrchestratorStateOwnerDirectives.psm1` is at least 90%, recorded under `evidence/`.
- [ ] The `owner-directives` skill exists in `.claude/skills`, `.agents/skills`, `.github/skills`, and the bundle resource trees with pack-manifest entries. It states the Framing paragraph, both schemas, the class enum with the honor/refuse policy, the fenced `Owner directives:` relay format, the record-before-relay procedure, the recording duty, and the Codex and parity limitations. A Pester contract test asserts that all copies are byte-identical.
- [ ] The orchestrate skill, the orchestrator agent, the parallel-orchestrate skill, and the epic-orchestrate skill each contain a pointer to the `owner-directives` skill (asserted by the contract test); `.claude/agents/epic-orchestrator.md` is unchanged; the only edit to `parallel_orchestrator_surface_expectations.py` is the one-line epic-orchestrate digest, and the frozen-surface test passes.
- [ ] `.claude/rules/orchestrator-state.md` and its bundle copy document both keys as key-gated and tolerated, list rules B1-B8 and R1-R10, name the stop hook as the enforcement point, and state the Python/TypeScript parity gap and the Codex enforcement gap as known limitations.
- [ ] Every copy of the execution-environment brief contains one new bullet naming the owner-directive stop-hook check, and the copies remain byte-identical.
- [ ] Always-refused classes are refused by policy in every case. The documentation lists which refused classes an existing hook enforces (force push via `validate-bash.ps1`) and which are policy-only, backstopped by rule R6. The branch diff contains no change to any hook other than `validate-orchestrator-output.ps1` and its bundle copy, no change to `.claude/settings.json` or canonical policy files, and no directive-based allow path in any hook.
- [ ] The branch diff adds no `.py` file and changes no `.py` file other than the one digest line.
