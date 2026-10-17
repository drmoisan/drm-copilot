# Research: Representing a Premise-Falsified Halt in the Orchestrator-State Checkpoint (#523)

- Issue: #523 (epic #771, `orchestrator-state-contract-correctness`, wave 1, depends on #464)
- Branch: `bug/blocked-reason-premise-falsified-halt-523`
- Date: 2026-09-29
- Inputs: `docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/issue.md` (acceptance criteria authoritative), `docs/features/epics/orchestrator-state-contract-correctness/epic.md`, #464 `spec.md` / `plan.2026-09-29T14-20.md` / `research/2026-09-29T14-35-cli-entry-point-research.md`, #509 prepared feature documents, GitHub issue #484.

## 0. Method and Tool Limitations

- This session had file read, search, and web fetch tools only. No shell was available, so `git fetch`, `git show`, `gh issue view`, `wc -l`, and test runs were not executed.
- Line counts below were obtained by a whole-file line-match count (`^` pattern, one match per line), which equals `wc -l` for files ending in a newline. The executor must re-measure with `wc -l` before relying on headroom figures.
- #509: the remote branch `origin/bug/promotion-gate-lacks-preexisting-issue-branch-509` could not be inspected (no shell). #509's prepared documents were read from a sibling agent worktree's working copy at `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/` (`spec.md`, `research/research.2026-09-29T15-15.md`). That folder name differs from the epic manifest entry (`2026-09-29-promotion-gate-lacks-preexisting-issue-branch-509`); #509's spec already records correcting the manifest as a follow-up. Treat the #509 file list as a pre-merge snapshot.
- #484: read through a web fetch of the public issue page. The fetched text states: "The reviewer classifies whether a blocking condition is autonomously remediable. External runtime mismatches, policy decisions, awaiting-CI states, and human-decision requirements halt or wait without creating a remediation plan or consuming a remediation cycle." No field names or verdict literals are defined in the issue.

## 1. Enum Definitions, Checks, Messages, and Absent/Null Handling

### 1.1 Definitions (four code definitions; no other Python, hook, or `.codex/` copy)

| Runtime | File | Definition lines | Members |
|---|---|---|---|
| Python (authoritative) | `scripts/dev_tools/validate_orchestrator_state.py` | 83-91 (`set` literal) | `none`, `spawn_agent_unavailable`, `delegation_launch_failed`, `delegate_no_receipt`, `delegate_contract_incomplete`, `validator_failed`, `user_requested_stop` |
| PowerShell | `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 96-106 (`$script:VALID_BLOCKED_REASONS = @(...)`, comment at 96-97) | same seven |
| PowerShell bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1` | 96-106 | same seven (499 lines, same as repo copy) |
| TypeScript | `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` | 95-104 (`export const VALID_BLOCKED_REASONS: ReadonlySet<string>`) | same seven |

A repository-wide search for `VALID_BLOCKED_REASONS` outside `docs/` finds only these four definitions plus one comment in `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:176`. No `.codex/`, `.claude/hooks/`, or other Python module defines the vocabulary. No test asserts cross-runtime equality of the constant, so drift between the four copies is currently undetected by automation.

### 1.2 Where each runtime checks `blocked_reason`

| Check | Python | PowerShell | TypeScript |
|---|---|---|---|
| Required key | `REQUIRED_STATE_KEYS` line 71; loop 401-403: `Checkpoint missing required key: blocked_reason` | `$script:REQUIRED_STATE_KEYS` line 60; loop 270-274 (same message) | `REQUIRED_STATE_KEYS` line 80; loop 356-360 (same message) |
| Membership (plain validation) | 411-413 | `Get-OrchestratorStateBasePresenceError` 290-295 (called via `OrchestratorStateUnconditional.psm1:127`) | 375-387 |
| Completion gate (`require_complete`) | 463-466 | `OrchestratorStateCompletionChecks.psm1` `Get-OrchestratorStateCompletionBlockedReasonError` 160-189 (row C2.1), wired at `OrchestratorStateCompletion.psm1:414` | 423-432 |
| PR-creation readiness | `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py:112-115` | `OrchestratorState.psm1` `Get-OrchestratorStatePrCreationReadinessError` 333-338 | not implemented in TypeScript (no `requirePrCreationReady` option exists under `extensions/drm-copilot/src`) |

Exact messages:

- Out-of-enum value (all three): `Checkpoint has invalid blocked_reason: <value>` (Python f-string line 413; PowerShell line 294; TypeScript line 385).
- Completion gate (all three): ``Checkpoint completion validation failed: blocked_reason is not `none`.``
- PR readiness (Python and PowerShell): ``Checkpoint PR-creation readiness validation failed: blocked_reason is not `none`.``

### 1.3 Absent, null, and non-string values

- Absent key: the membership check is skipped in all three runtimes, but the required-key loop reports `Checkpoint missing required key: blocked_reason`. An absent `blocked_reason` is therefore not accepted by plain validation. The completion and PR-readiness gates treat absent as clear (Python `not in {None, "none"}`; PowerShell `$null -ne`; TypeScript `!== undefined`).
- JSON `null`: accepted by the membership check and by both gates in all three runtimes.
- Existing cross-runtime divergences observed in the current tree (not introduced by #523):
  1. Case sensitivity. PowerShell membership uses `-notcontains` (line 293) and PR readiness uses `-ne 'none'` (line 336); both are case-insensitive. `NONE` or `Validator_Failed` pass PowerShell plain validation but fail Python and TypeScript. The PowerShell completion check uses `-ceq` (CompletionChecks line 184) and is case-sensitive.
  2. Unhashable values. Python evaluates `blocked_reason not in VALID_BLOCKED_REASONS` (line 412) against a `set`; a JSON array or object value raises `TypeError: unhashable type` instead of returning an error. TypeScript and PowerShell return the invalid-value error.
  3. Message rendering of non-strings. Python renders a boolean as `True`, TypeScript `String(true)` as `true`, PowerShell as `True`; float `1.0` renders `1.0` in Python and `1` in TypeScript and PowerShell.

## 2. Documents That Enumerate or Prescribe `blocked_reason` Values

### 2.1 Full enumerations

Only one document family enumerates the vocabulary:

- `.agents/skills/orchestrator-workflow/SKILL.md` lines 145-159 (`Blocked-reason enum:` / ``- `blocked_reason` MUST be one of:``), and its tracked bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` (same lines; both files 449 lines).

No `.claude/` rule, skill, or agent, no `.github/agents/*.agent.md`, and no `.codex/agents/*.toml` enumerates the values. `.claude/rules/orchestrator-state.md` (159 lines) contains no `blocked_reason` section.

### 2.2 The `.agents` enumeration diverges from the validators

The `.agents` list has 13 members. Seven match the validators. Six are documentation-only and are rejected by all three validators with `Checkpoint has invalid blocked_reason: <value>`:

| Doc-only member | Prescribed as a value to write at |
|---|---|
| `checkpoint_conflict` | `.agents/skills/orchestrator-workflow/SKILL.md:249`; `.codex/agents/orchestrator*.toml:131` and `{python,powershell,csharp}-orchestrator.toml:34/36` ("stop with `checkpoint_conflict`") |
| `lifecycle_preconditions_missing` | same SKILL.md lines 287 and 345 |
| `no_staged_changes` | line 390 |
| `commit_context_missing` | line 391 |
| `review_status_missing` | list only (line 156) |
| `pre_implementation_gate_violation` | list only (line 159) |

Consequence: a Codex orchestrator that follows lines 249, 287, 345, 390, or 391 writes a checkpoint that every validator rejects.

Scope determination: out of #523 scope. The #523 acceptance criteria concern expressing a premise-falsified halt and preserving validation of existing members; reconciling six unrelated mechanical members is a separate contract decision (add them to the validators, or retarget the prose). #523 should add its new member to this list without removing or adding any other entry, and record the divergence as a follow-up potential entry. `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py:134` requires the fragment ``blocked_reason` MUST be one of:`` to remain, and lines 116-126 require the repo and bundle copies to be byte-identical.

### 2.3 Documents that prescribe `blocked_reason: "none"` for preparation mode (no enumeration)

- `.claude/skills/orchestrate/SKILL.md:139` (and bundle): preparation terminal checkpoint sets `blocked_reason: "none"`.
- `.claude/skills/epic-plan/SKILL.md:125` (and bundle); `.agents/skills/epic-plan/SKILL.md:148`; `.agents/skills/orchestrate/SKILL.md:128`; `.codex/agents/orchestrator*.toml:67`.
- Key-list-only mentions: `.claude/agents/orchestrator.md:166`, `.agents/skills/orchestrator-workflow/SKILL.md:108`, `.github/agents/{orchestrator,python-orchestrator,powershell-orchestrator,csharp-orchestrator}.agent.md`, `.codex/agents/orchestrator*.toml:151`.
- A different field with the same name: the epic bounded child return (`.claude/skills/epic-orchestrate/SKILL.md:118,135`; `.claude/skills/orchestrate/SKILL.md:145`; asserted by `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py:65`) carries `blocked_reason` as "a short reason string when the child is blocked, otherwise null". It is not validated against the enum.

## 3. Semantic Consumers

| Consumer | File | Behavior |
|---|---|---|
| Completion gate | Python 463-466; PowerShell C2.1; TypeScript 423-432 | Any value other than absent, null, or `none` blocks completion. |
| PR-creation-ready gate | `_orchestrator_state_pr_creation_readiness.py:112`; `OrchestratorState.psm1:333-338` | Any value other than absent, null, or `none` blocks the first `gh pr create`. |
| SubagentStop hook | `.claude/hooks/validate-orchestrator-output.ps1` (registered at `.claude/agents/orchestrator.md:38-42`) | Runs `Test-OrchestratorStateCompletionReadiness` (lines 254-265) on every orchestrator stop; any error is surfaced as `ROUTING_CONTRACT_BLOCKED: ...` with `exit 1` (lines 395-418). The hook does not read `blocked_reason` directly; it inherits C2.1. |
| PR-author preflight | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:364` → `Invoke-OrchestratorStatePreflight` | Inherits the PR-readiness rule. |
| MCP `validate_orchestration_artifacts` | `orchestrator-state-core.ts` | Membership and completion only. |
| Epic/parallel validators, dashboards | none found | `scripts/dev_tools/validate_epic_orchestrator_state.py` and the parallel validators do not read `blocked_reason`. |
| Preparation terminal contract | `scripts/dev_tools/_orchestrator_state_preparation_terminal.py` (36 lines) | Does not read `blocked_reason`; the preparation `none` requirement is enforced only through C2.1 when completion validation runs. |

Answer: every gate treats `blocked_reason` other than `none`/null/absent as blocking DONE and PR creation. Any new member is therefore automatically treated as "not complete" by all existing gates, which is the correct semantics for a halted run. A structured halt represented outside `blocked_reason` would not be seen by any existing gate unless each gate were edited.

A related existing structure: `human_interaction.requirements[].response` accepts `halt` (`scripts/dev_tools/_orchestrator_state_human_interaction.py:48`; `.claude/skills/orchestrate/SKILL.md:104-119`), and `Test-HumanInteractionShape` blocks DONE while any `halt` is present. It models an unautomatable human requirement, not a falsified premise, and is not read by the Python or TypeScript completion gates.

## 4. Cross-Runtime Parity Fixture Infrastructure

- No shared fixture corpus exists for orchestrator-state today. Existing per-runtime tests build checkpoints in code (`tests/scripts/dev_tools/validate_orchestrator_state_test_support.py` `build_valid_orchestrator_state`; Pester here-string `$script:BaseCheckpointJson` in `OrchestratorStateUnconditional.Tests.ps1:52`; TypeScript builders in `orchestrator-state-core.test.ts:43`).
- Established repository corpus pattern (committed JSON files, read-only, one file per case, ordered expected-message equality, minimum-count guard, name equals file stem): `tests/fixtures/parallel_cohort_barrier/*.json` read by `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` and `extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts`; `tests/fixtures/blast_radius/*.json` read by `tests/scripts/dev_tools/test_blast_radius_parity.py` and `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (resolves the corpus with `Resolve-Path "$PSScriptRoot/../../../../tests/fixtures/blast_radius"`, line 37).
- #509 introduces the first orchestrator-state corpus: `tests/fixtures/orchestrator_state_issue_adoption/*.json` with shape `{name, notes, checkpoint, expected_errors}`, read by `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` (#509 spec AC-12).
- Recommended location for #523 (disjoint from #509): `tests/fixtures/orchestrator_state_blocked_reason/*.json`, same four-key shape as #509, with readers `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason_parity.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-parity.test.ts`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1`.
- Bundle-parity tests that must stay green: `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` (SHA-256 identity of every module with its bundle copy, lines 91-104); `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (repo `.claude/**` vs bundle); `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` and `test_orchestration_guardrail_contracts.py:116-126` (`.agents` vs bundle).
- Repository rule: tests must not create temporary files (`.claude/rules/general-unit-test.md`). Committed corpus files read in place satisfy the rule; readers must not write fixtures at run time.

## 5. Line Counts (500-line cap)

Production:

| File | Lines | Headroom | Note |
|---|---|---|---|
| `scripts/dev_tools/validate_orchestrator_state.py` | 492 | 8 | After #464: the #464 plan (P3-T2, P4-T1) removes original lines 110-179 net of two blank lines (68 lines), adds a 4-line import and the `__main__` guard; #464 research estimates about 433 lines (about 67 headroom). #464's plan requires only a measured count below 500 (P4-T3, P8-T6) and does not assert a number. The blocked_reason checks shift to roughly lines 347-349 and 399-402. |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` (and bundle) | 499 | 1 | Highest risk. One added array line reaches 500; any added comment line exceeds the cap. |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` | 467 | 33 | |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | 418 | 82 | Only touched if C2.1 changes (not recommended). |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | 168 | 332 | |
| `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` | 128 | 372 | Not touched under the recommendation. |
| `.agents/skills/orchestrator-workflow/SKILL.md` (and bundle) | 449 | n/a | Markdown is exempt from the cap. |
| `.claude/rules/orchestrator-state.md` (and bundle) | 159 | n/a | Markdown. |

## 8. Existing Validator Test Files (answered here because section 6 cites them)

| Runtime | File | Lines | Relevant cases |
|---|---|---|---|
| Python | `tests/scripts/dev_tools/test_validate_orchestrator_state.py` | 425 | invalid member 150-178; completion 181-217 |
| Python | `tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py` | 264 | readiness 172-182 |
| Python | `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py` | 130 | |
| Python | `tests/scripts/dev_tools/validate_orchestrator_state_test_support.py` | 225 | builders |
| Pester | `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | 491 | 147-186; 9 lines of headroom, do not extend |
| Pester | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1` | 194 | invalid member 87-90 |
| Pester | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1` | 297 | C2 86-106 |
| Pester | `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | 105 | bundle identity |
| Jest | `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.test.ts` | 381 | invalid member 118-129 |
| Jest | `extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts` | 247 | completion 98-109 |
| Jest | `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` | 508 | already over the cap (pre-existing); do not extend |

## 6. Design Options

### 6.1 Evaluation criteria

AC1 expressible halt; AC2 accept new value and keep rejecting out-of-enum values; AC3 "not blocked" versus "blocked for a non-mechanical reason" recoverable from structured fields; AC4 byte-identical validation of checkpoints that omit the field or use existing members; the #484 extension requirement; interaction with existing gates; file-cap and #509 overlap cost.

### 6.2 Key finding on #484 extensibility

Every option requires a vocabulary change when #484 adds its classes (external, policy, awaiting CI, human decision), because every runtime must reject out-of-vocabulary values (AC2). An orthogonal class field moves that vocabulary into a second enum; it does not remove the change. #484 can avoid a contract change only if #523 predefines #484's members now, which is possible under either option.

### 6.3 Option (a): add `premise_falsified` to the flat `blocked_reason` enum (recommended)

- Change: one member in each of the four definitions; documentation.
- AC1-AC3: `premise_falsified` is a halt whose cause is non-mechanical by name. "Not blocked" is `none` or null; "blocked for a non-mechanical reason" is `premise_falsified`. Recovery needs one field read.
- AC4: set membership grows by one value. For checkpoints that omit `blocked_reason` (required-key error) or use any of the seven existing members, every code path produces the same output as before. Out-of-enum strings still produce the same message.
- Gates: completion, PR readiness, the SubagentStop hook, and the PR-author preflight treat the new member as not complete with no code change, which is the intended semantics.
- #484: #484 adds its members to the same set with the same edit pattern and adds corpus files. This is an additive contract change in #484's own child. The planner should document the mechanical/non-mechanical partition in prose so #484 extends one list.
- Cost: four one-line constant edits, one PowerShell headroom action (section 6.6), no new module, no new registration file, no `jest.config.cjs` edit.

### 6.4 Option (b): orthogonal presence-gated field (`blocked_class` enum or a `halt` object with `class`, `evidence`, and similar members)

- AC3 holds only if consumers read the new field. With `blocked_reason: "none"` plus a `halt` object, every existing gate (Python 463, 112; PowerShell C2.1 and readiness; TypeScript 423) would pass the halted run as complete. Each gate would need a new cross-field rule, which multiplies edits across `validate_orchestrator_state.py`, `_orchestrator_state_pr_creation_readiness.py`, `OrchestratorStateCompletionChecks.psm1`, `OrchestratorState.psm1`, and `orchestrator-state-core.ts`.
- If instead `blocked_reason` must be non-`none` when the object is present, `blocked_reason` still needs a new member, because no mechanical member describes the halt (the core defect). That is option (c).
- Needs a new validator module in each runtime. In PowerShell that means a new `.psm1`, its bundle copy, and registration in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `OrchestratorState.Manifest.Tests.ps1` `$script:ExpectedPaths`, and both `pester.runsettings.psd1` files, which are the same four files #509 edits (see section 7).
- Rejected: it moves the halt out of the field that every gate and triage reader already uses, which reintroduces the mis-triage the issue describes.

### 6.5 Option (c): hybrid, one generic member (for example `halted`) plus a presence-gated `halt` object whose `class` enum starts with `premise_falsified`

- Byte-identical for existing checkpoints if the cross-field rules fire only when the new member or the object is present. Rules would be: `blocked_reason == "halted"` requires a well-formed `halt` object, and a `halt` object requires `blocked_reason == "halted"`.
- Carries structured evidence (for example evidence paths), which is more than the ACs require.
- Costs the new-module and registration overhead of (b) in all three runtimes, adds two cross-field rules to verify for parity, and still requires a class-enum change for #484 unless predefined. A triage reader needs two field reads.
- Rejected for #523: the extra structure is not required by any acceptance criterion, and the PowerShell registration files overlap #509. #484 may introduce a structured halt record if its verdict design needs evidence fields; it can key that record to the flat members.

### 6.6 Recommendation

Adopt option (a) with these specifics:

1. Add `premise_falsified` to the vocabulary in Python, PowerShell (repo and bundle in the same commit), and TypeScript. Do not predefine #484's members. #484's verdict design is unsettled (issue #484 defines no literals, and the epic rates it C4, "requires design"). Unused members would be written by no producer and could be renamed by #484, which would itself be a breaking change.
2. Keep the four existing message strings unchanged. Do not change the completion or PR-readiness checks; they already block on the new member.
3. PowerShell headroom: `OrchestratorState.psm1` is 499 lines. Keep the file at or below 500 lines by writing the vocabulary array in a compact multi-member-per-line form grouped as mechanical and non-mechanical. This leaves headroom for #484. The executor must run the formatter and re-measure with `wc -l`. Do not add a new PowerShell module (it avoids the #509 registration files).
4. Parity corrections on the lines #523 edits, needed so AC2 ("continues to reject values outside the enum") holds in every runtime for the new member:
   - PowerShell membership at line 293: `-notcontains` becomes `-cnotcontains`, so `PREMISE_FALSIFIED` is rejected as it is in Python and TypeScript. PR readiness at line 336: `-ne` becomes `-cne`. Both change results only for case-variant inputs that Python already rejects, so checkpoints using exact existing members are unaffected. #509 AC-16 sets the same case-sensitive precedent.
   - Python line 412: guard with `not isinstance(blocked_reason, str) or ...` so a JSON array or object returns the invalid-value error instead of raising `TypeError`. Output is unchanged for every input that currently does not raise.
5. Do not change boolean or float message rendering. Exclude those inputs from the parity corpus and record them as a follow-up.
6. Documentation: add `premise_falsified` with a one-sentence definition to `.agents/skills/orchestrator-workflow/SKILL.md` lines 145-159 and its bundle copy, and preserve the six doc-only members unchanged. Add a new `## Blocked-Reason Vocabulary` section to `.claude/rules/orchestrator-state.md` and its bundle copy. The section lists the members, states the mechanical/non-mechanical partition, and gives producer guidance: use `premise_falsified` when all delegations and validators succeeded but gathered evidence falsified the plan's premise; record the evidence path in free-form keys as today. Put the enforcement sentence inside the new section, not in the shared `## Enforcement` list (section 7). No `.codex/agents/*.toml` or `.github/agents/*` edit is needed because neither enumerates values, which also avoids the Codex variant regeneration.

## 7. File Overlap with #509 and Avoidance

| File | #523 (recommended) | #509 (prepared spec) | Conflict risk / avoidance |
|---|---|---|---|
| `scripts/dev_tools/validate_orchestrator_state.py` | constant 83-91; check 411-413 (post-#464 line numbers shift) | not edited (#509 spec line 66, 105) | None. |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` (+bundle) | array 96-106; lines 293, 336 | not edited | None. |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` | constant 95-104 | not edited (spec line 66) | None. |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`, `scripts/dev_tools/_orchestrator_state_routing.py` (split), `orchestrator-state-routing.ts` | not edited | edited | None. |
| `core.json`, `OrchestratorState.Manifest.Tests.ps1`, both `pester.runsettings.psd1`, `jest.config.cjs` | not edited under option (a) | edited (new module registration and threshold) | None under (a); options (b)/(c) would add adjacent list insertions in the same four files. |
| `.agents/skills/orchestrator-workflow/SKILL.md` (+bundle) | lines 145-159 | lines 200-201 and 407 (spec line 170) | Separate hunks more than 40 lines apart; low. Edit only the enumeration block. |
| `.claude/rules/orchestrator-state.md` (+bundle) | new section | new `issue_adoption` section plus an `## Enforcement` bullet; #464 edits line 95 and inserts `## Bare-Module CLI Contract` after it | Medium. Do not append to `## Enforcement` (lines 149-159) or insert after line 95. Anchor the new section between the Human-Interaction invariants (ends line 57) and `## Complexity-Assessment Scope` (line 59). Coordinate the anchor with #509's plan before execution. |
| `tests/fixtures/**` | `orchestrator_state_blocked_reason/` | `orchestrator_state_issue_adoption/` | Disjoint directories. |

No function is edited by both children under option (a).

## Behavior Semantics

- Success: a checkpoint with `blocked_reason: "premise_falsified"` and an otherwise valid shape produces no plain-validation error in any runtime.
- Blocking: the same checkpoint fails `require_complete` with the existing C2.1 message and fails PR readiness with the existing readiness message.
- Rejection: any string outside the eight members, including case variants such as `Premise_Falsified`, yields `Checkpoint has invalid blocked_reason: <value>` in all three runtimes. A JSON array or object yields the same message form in Python instead of an exception.
- Unchanged: absent key (required-key error only), `null` (accepted), `none` and the six mechanical members (identical output in every mode).
- Ordering: the membership error keeps its position after the step-status errors and before the receipt errors (Python 405-413; TypeScript 362-387; PowerShell base-presence order 268-295).

## Requirements Mapping

| AC | Design element | Evidence to plan |
|---|---|---|
| AC1 | `premise_falsified` in the four definitions | positive corpus case; per-runtime unit test |
| AC2 | membership check plus case-sensitive PowerShell operators and Python non-string guard | negative corpus cases: unknown string, case variant, integer, array (Python-only unit test for array if message rendering diverges) |
| AC3 | `none`/null = not blocked; `premise_falsified` = blocked, non-mechanical; partition documented in the rules doc | corpus cases pairing `none` and `premise_falsified` under completion gating |
| AC4 | no message or ordering change; set growth only | corpus cases for absent key, `null`, `none`, and each of the six mechanical members, asserting today's exact outputs; existing test suites unchanged and green |
| Manual note | `.agents` enumeration and bundle list the new member | byte-identity tests listed in section 4 |

Proposed file changes: `scripts/dev_tools/validate_orchestrator_state.py`; `.claude/lib/orchestrator-state/OrchestratorState.psm1` and bundle copy; `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`; `.agents/skills/orchestrator-workflow/SKILL.md` and bundle copy; `.claude/rules/orchestrator-state.md` and bundle copy; new corpus directory and three corpus readers; new per-runtime unit test files (below).

## Testing Implications

- Python: new `tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py` (acceptance, rejection, case variant, array guard, completion and readiness blocking). Do not grow `test_validate_orchestrator_state.py` beyond its 75-line headroom. Coverage command must use a dotted module (`--cov=scripts.dev_tools.validate_orchestrator_state --cov-branch --cov-report=term-missing`).
- Pester: add cases to `OrchestratorStateUnconditional.Tests.ps1` (base membership, case variant) and `OrchestratorStateCompletionChecks.Tests.ps1` (C2.1 with the new member), or create a new `OrchestratorStateBlockedReason.Tests.ps1`. Do not extend `OrchestratorState.Tests.ps1` (491 lines). Readiness case-sensitivity can be tested via `Test-OrchestratorStatePrCreationReadiness` only if a checkpoint file is not required; that function reads a path, so prefer testing `Get-OrchestratorStatePrCreationReadinessError`. It is not exported (`Export-ModuleMember` lines 494-499), so the test uses `InModuleScope`. Creating a temporary file is prohibited.
- Jest: extend `orchestrator-state-core.test.ts` (381) and `orchestrator-state-core.completion.test.ts` (247); no new production file, so no `jest.config.cjs` change.
- Parity corpus: `tests/fixtures/orchestrator_state_blocked_reason/*.json`, shape `{name, notes, checkpoint, expected_errors}` plus `expected_completion_blocked_reason_errors` if completion gating is asserted. Each reader filters errors to those containing `blocked_reason` so route, CI, and PR-gate noise from `require_complete` is excluded (the cohort-barrier suite uses the same filtering technique). Readers: Python via `validate_orchestrator_state_text`; PowerShell via `Get-OrchestratorStateUnconditionalError` and `Get-OrchestratorStateCompletionBlockedReasonError` on `ConvertFrom-Json` output; TypeScript via `validateOrchestratorStateText` (with an injected routing matrix when `requireComplete` is set). Values limited to strings, `null`, integers, and key absence. Include a minimum-count guard and a stem-equals-name guard.
- Byte-identical regression: include corpus cases for every existing member and for absent/null, asserting outputs captured before the change. Run the unchanged existing suites listed in section 8 before and after the change.
- Bundle: `OrchestratorState.Manifest.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_orchestration_guardrail_contracts.py`.

## Numeric Derivation Evidence

### N1: number of code definitions of the blocked-reason vocabulary = 4

- Complete Family: every executable definition of the `blocked_reason` vocabulary in any runtime or bundle.
- Exhaustive Search Scope: all repository files outside `docs/`, including `scripts/`, `.claude/`, `.codex/`, `.agents/`, `.github/`, `extensions/drm-copilot/src/`, `extensions/drm-copilot/resources/`, and `tests/`.
- Inclusion Rules: a constant assignment enumerating the member strings.
- Exclusion Rules: comments, Markdown enumerations, test literals.
- Primary Search Strategy or Query Expression: case-insensitive search for `VALID_BLOCKED_REASONS|BLOCKED_REASONS|ValidBlockedReasons`, filtered to assignment lines.
- Primary Member Set: `scripts/dev_tools/validate_orchestrator_state.py:83`; `.claude/lib/orchestrator-state/OrchestratorState.psm1:98`; `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1:98`; `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts:96`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: literal search for the member `delegate_contract_incomplete` outside `docs/`, keeping code files only.
- Cross-check Member Set: `scripts/dev_tools/validate_orchestrator_state.py:88`; `.claude/lib/orchestrator-state/OrchestratorState.psm1:103`; bundle `OrchestratorState.psm1:103`; `orchestrator-state-core.ts:101` (excluded by rule: the two `.agents` SKILL.md copies).
- Cross-check Count: 4.
- Member-set Comparison: identical four files.

### N2: current member count per definition = 7

- Complete Family: members of each of the four N1 definitions.
- Exhaustive Search Scope: the four N1 definition blocks.
- Inclusion Rules: string literals inside the constant.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: read the Python set literal at lines 83-91.
- Primary Member Set: `none`, `spawn_agent_unavailable`, `delegation_launch_failed`, `delegate_no_receipt`, `delegate_contract_incomplete`, `validator_failed`, `user_requested_stop`.
- Primary Count: 7.
- Cross-check Search Strategy or Query Expression: independent reads of the PowerShell array (lines 98-106) and the TypeScript set (lines 96-104).
- Cross-check Member Set: the same seven strings in both.
- Cross-check Count: 7.
- Member-set Comparison: identical sets; the bundle copy has the same 499-line count and the same lines 98-106.

### N3: documentation-only members in `.agents/skills/orchestrator-workflow/SKILL.md` = 6 (list size 13)

- Complete Family: members listed at lines 147-159.
- Exhaustive Search Scope: that file and its bundle copy; validator code in all runtimes.
- Inclusion Rules: listed members absent from the N2 set.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: read lines 145-159 and subtract the N2 set.
- Primary Member Set: `checkpoint_conflict`, `lifecycle_preconditions_missing`, `review_status_missing`, `commit_context_missing`, `no_staged_changes`, `pre_implementation_gate_violation`.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: literal searches outside `docs/` for `review_status_missing|pre_implementation_gate_violation|no_staged_changes|commit_context_missing` and for `checkpoint_conflict|lifecycle_preconditions_missing`, checking for any validator definition.
- Cross-check Member Set: the same six names, found only in `.agents` SKILL.md copies, `.codex/agents/*.toml` prose, one guardrail test fragment, and one unrelated test name (`test_handles_no_staged_changes`); none in any validator.
- Cross-check Count: 6.
- Member-set Comparison: identical.

## Automation Feasibility

The changes involve no third-party user interface and require no human interaction. All work is repository-local: constant and operator edits in three validator runtimes, Markdown edits with bundle mirrors, committed JSON fixtures, and unit tests runnable unattended in the Python, Pester, and Jest toolchains. No `human_interaction.requirements[]` entry is needed for #523 itself (the epic-level substitution note citing #509 for `potential_to_issue` still applies).

## Rejected Alternatives (summary)

- (b) Orthogonal field only: invisible to every existing gate and triage reader unless each gate is edited, and it cannot avoid a new `blocked_reason` member without leaving `none` on a halted run.
- (c) Hybrid member plus `halt` object: satisfies the ACs but adds a module and registration files in each runtime that overlap #509, and still needs a class-enum change for #484.
- Reusing `human_interaction.requirements[].response == "halt"`: models an unautomatable human requirement, not a falsified premise, and is not checked by the Python or TypeScript completion gates.
- Predefining #484's four members: no producer exists and #484 has not fixed its literals.

## Follow-ups to Record (not part of #523)

1. Reconcile the six documentation-only members in `.agents/skills/orchestrator-workflow/SKILL.md` with the validators (and the `checkpoint_conflict` prose in `.codex/agents/*.toml`).
2. Cross-runtime message rendering for boolean and float `blocked_reason` values.
3. PR-creation-readiness gate is absent from the TypeScript validator.
4. `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` is 508 lines (over the cap).
5. The `test_orchestration_guardrail_contracts.py` skip reason says `.codex` and `.agents` are gitignored; `.gitignore` in this tree does not ignore them, and both directories are present in this worktree checkout.
