# 2026-09-29-blocked-reason-premise-falsified-halt (Spec)

- **Issue:** #523
- **Parent (optional):** Epic #771 (`orchestrator-state-contract-correctness`; manifest `docs/features/epics/orchestrator-state-contract-correctness/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T16-15
- **Status:** Draft
- **Version:** 0.1

## Context
The orchestrator checkpoint's `blocked_reason` field is an enum that covers only **mechanical** failure modes (`delegation_launch_failed`, `validator_failed`, and similar). It cannot express a halt in which every delegation and every validator **succeeded** but the work's premise was falsified by evidence gathered during execution.

Environment:
- OS/version: any
- Python version: repository Poetry environment
- Command/flags used: orchestrator-state validation (Python `scripts/dev_tools/validate_orchestrator_state.py`, PowerShell `.claude/lib/orchestrator-state/OrchestratorState.psm1`, TypeScript `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`)
- Data source or fixture: an orchestrator checkpoint recording a halt whose premise was falsified

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Research basis: `research/2026-09-29T16-00-blocked-reason-halt-representation-research.md` (cited below as "research section N"). That research was performed without a shell; line numbers and line counts in it were derived by file reads and must be re-measured by the executor (`wc -l` or equivalent) before any headroom figure is relied on.

Epic position: wave 1, depends on #464. #464 merges into `epic/orchestrator-state-contract-correctness-integration` before #523 executes. This spec assumes the post-#464 layout: the remediation-loop constants and validators live in `scripts/dev_tools/_orchestrator_state_remediation_loop.py`, the bare-module CLI lives in `scripts/dev_tools/validate_orchestrator_state_cli.py`, and `scripts/dev_tools/validate_orchestrator_state.py` carries a `__main__` guard (#464 spec, Design summary items 1-3). The `blocked_reason` checks in `validate_orchestrator_state.py` therefore sit at shifted line numbers (research section 5 estimates about lines 347-349 and 399-402); the executor locates them by content, not by line number.

## Repro & Evidence
Steps to Reproduce:
1. Run an orchestration whose delegations and validators all succeed, but whose measurements falsify the defect hypothesis the plan was built on.
2. Attempt to record the halt in `artifacts/orchestration/orchestrator-state.json` using `blocked_reason`.
3. Observe that no enum member describes the halt; the only non-misrepresenting value is `none`.

Expected:
The halt is expressible in structured checkpoint fields, and a genuinely blocked run is distinguishable from an unblocked one without reading free-form text.

Actual:
During the `quickfiler-suite-determinism-foundation` epic run (2026-08-22), the child for drmoisan/TaskMaster#511/#571 completed Phases 0 through 4 with every delegation and validator green, then halted because its own measurements falsified the defect hypothesis the plan was built on. No enum member describes that.

The child set `blocked_reason: none` and recorded the real reason in free-form keys, explicitly declining to pick a mechanical member that would misrepresent the halt. That is the correct call, but it means a genuinely blocked run is indistinguishable from an unblocked one by the enum alone, and any tooling that reads `blocked_reason` to triage halts will mis-triage this class.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `blocked_reason: none` recorded on a halted child checkpoint (TaskMaster#511/#571, 2026-08-22).

## Scope & Non-Goals
- In scope:
  - Extend the `blocked_reason` vocabulary in all three validator runtimes (Python authoritative, PowerShell repo copy plus bundled copy, TypeScript) with `premise_falsified` and four predefined non-mechanical halt members for #484: `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required`.
  - Publish a structured partition of the vocabulary into "not blocked", "blocked for a mechanical reason", and "blocked for a non-mechanical reason", with partition constants in Python and TypeScript, a pure classification helper in Python and TypeScript, and grouped mechanical/non-mechanical arrays in PowerShell.
  - Parity corrections on the edited lines: case-sensitive PowerShell membership and readiness comparisons; a Python non-string guard on the plain-validation membership check.
  - A committed cross-runtime parity corpus with Python, Jest, and Pester readers, and a partition-parity oracle.
  - Documentation of the vocabulary, the partition, producer guidance, and the #484 extension point in the `.agents` orchestrator-workflow skill, `.claude/rules/orchestrator-state.md`, and the `.claude` and `.agents` orchestrate skills, each with its bundled mirror.
- Out of scope / non-goals:
  - Any change to the completion gate, the PR-creation-readiness gate logic (other than the PowerShell operator correction), the SubagentStop hook, or the PR-author preflight. These already block on any value other than `none`/null/absent (research section 3).
  - Any change to existing error-message strings or error ordering.
  - An orthogonal halt field, a structured `halt` object, or any cross-field rule between `blocked_reason` and another field (including `human_interaction.requirements[].response`).
  - Reconciling the documentation-only members in `.agents/skills/orchestrator-workflow/SKILL.md` that the validators reject (`checkpoint_conflict`, `lifecycle_preconditions_missing`, `review_status_missing`, `commit_context_missing`, `no_staged_changes`, `pre_implementation_gate_violation`); recorded as a follow-up.
  - Cross-runtime message rendering for boolean and float `blocked_reason` values (research section 1.3 item 3); recorded as a follow-up.
  - The Python `TypeError` raised for an array or object `blocked_reason` under `require_complete` (`validate_orchestrator_state.py` completion check) and under PR-creation readiness (`scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`). Both are set-membership tests (`not in {None, "none"}`) in gate logic this spec keeps unchanged; recorded as a follow-up.
  - A PR-creation-readiness gate in TypeScript (absent today; research section 1.2); recorded as a follow-up.
  - The epic bounded child return's `blocked_reason` (`.claude/skills/epic-orchestrate/SKILL.md`), which is a different free-form field and is not validated against the enum (research section 2.3).
  - #484's verdict design, producer logic, and remediation-cycle accounting.
- Explicitly excluded systems, integrations, or datasets:
  - Issue #769 files: `.claude/hooks/enforce-powershell-batch-budget.ps1` and its related files and tests.
  - `.codex/agents/*.toml` and `.github/agents/*.agent.md`: neither enumerates `blocked_reason` values (research section 2.1), so neither is edited and no Codex variant regeneration is triggered.
  - Enforcement hooks under `.claude/hooks/`.

## Root Cause Analysis
A premise-falsified halt is the most valuable kind of halt — it is the orchestration system catching a planning error before it reaches `main`. Making it unrepresentable in the structured field pushes it into prose, where automated triage cannot see it.

The enum is defined in three runtimes: `VALID_BLOCKED_REASONS` in `scripts/dev_tools/validate_orchestrator_state.py` (authoritative), `$script:VALID_BLOCKED_REASONS` in `.claude/lib/orchestrator-state/OrchestratorState.psm1` (plus its bundled copy), and `VALID_BLOCKED_REASONS` in `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`.

Additional findings (research sections 1-3):
- The executable definitions are exactly: `scripts/dev_tools/validate_orchestrator_state.py`, `.claude/lib/orchestrator-state/OrchestratorState.psm1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1`, and `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` (research Numeric Derivation Evidence N1). No test asserts cross-runtime equality of these definitions, so drift is undetected today.
- The existing members are `none`, `spawn_agent_unavailable`, `delegation_launch_failed`, `delegate_no_receipt`, `delegate_contract_incomplete`, `validator_failed`, and `user_requested_stop` (research N2).
- Existing cross-runtime divergences on the lines this change edits: PowerShell membership (`-notcontains`) and PR readiness (`-ne 'none'`) are case-insensitive, while Python and TypeScript are case-sensitive; Python raises `TypeError` for an array or object value in plain validation, while PowerShell and TypeScript return the invalid-value error (research section 1.3).

## Proposed Fix

### Design summary (what changes where):

**Decision: extend the flat `blocked_reason` enum (research option (a)); do not add an orthogonal field.**

Justification (research sections 3 and 6):
- Every existing gate already blocks on any `blocked_reason` other than `none`, null, or absent: the Python completion gate and PR-readiness gate, PowerShell C2.1 (`Get-OrchestratorStateCompletionBlockedReasonError`) and `Get-OrchestratorStatePrCreationReadinessError`, the TypeScript completion gate, the SubagentStop hook `.claude/hooks/validate-orchestrator-output.ps1` (which inherits C2.1), and the PR-author preflight (`.claude/hooks/enforce-pr-author-skill-helpers.ps1` via `Invoke-OrchestratorStatePreflight`, which inherits the readiness rule). A new flat member is therefore seen as "not complete" by every gate with no gate edit, which is the intended semantics for a halted run.
- An orthogonal field (research option (b)) is invisible to all of those gates. A checkpoint carrying `blocked_reason: "none"` plus a halt field would pass every gate as complete unless each gate were edited to add a cross-field rule, and triage readers that already read `blocked_reason` would continue to mis-triage the halt, which is the defect this issue reports. It would also require a new validator module per runtime; in PowerShell that means a new `.psm1`, its bundle copy, and registration in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `OrchestratorState.Manifest.Tests.ps1`, and both `pester.runsettings.psd1` files, which are files #509 also edits.
- The hybrid (research option (c), a generic member plus a presence-gated `halt` object) still needs a new `blocked_reason` member, adds two cross-field rules to keep in parity across three runtimes, carries the same registration overhead as (b), and requires two field reads for triage. No acceptance criterion requires the extra structure. #484 may later key a structured evidence record to the flat members if its verdict design needs one.

**Decision: predefine #484's halt members now.**

The research (sections 6.2 and 6.6 item 1) finds that #484 can avoid another contract change only if #523 predefines #484's members, and recommends against predefinition because #484's literals were unsettled. The epic requires that #484 (wave 2) record its external, policy, awaiting-CI, and human-decision halts through the representation #523 defines without another contract change. This spec resolves the objection by settling the names here: #523 fixes the literals, and #484's spec is authored after #523 merges into the integration branch, so #484 consumes settled names rather than renaming them. The members are inert until a producer writes them; accepting an unused value changes no existing output (see Backward-compatibility expectations).

**Vocabulary (exact literals, fixed by #523):**

| Member | Partition | Definition |
|---|---|---|
| `none` | not blocked | The run is not blocked. JSON `null` is equivalent for classification. |
| `spawn_agent_unavailable` | mechanical | Existing member; meaning unchanged. |
| `delegation_launch_failed` | mechanical | Existing member; meaning unchanged. |
| `delegate_no_receipt` | mechanical | Existing member; meaning unchanged. |
| `delegate_contract_incomplete` | mechanical | Existing member; meaning unchanged. |
| `validator_failed` | mechanical | Existing member; meaning unchanged. |
| `user_requested_stop` | mechanical | Existing member; meaning unchanged. |
| `premise_falsified` | non-mechanical | Every delegation and validator succeeded, but evidence gathered during execution falsified the premise on which the plan was built, so continuing would implement an invalid plan. |
| `external_dependency` | non-mechanical | The run cannot proceed because a system, service, runtime, or artifact outside the repository's control is unavailable or mismatched, and no in-repository remediation can resolve it. |
| `policy_hold` | non-mechanical | The run is stopped because proceeding requires a policy decision, exception, or authorization that the orchestrator is not permitted to grant autonomously. |
| `awaiting_ci` | non-mechanical | The run is waiting for a CI result that has not yet completed, and no remediation is warranted until that result is available. |
| `human_decision_required` | non-mechanical | The run requires a human to choose between alternatives or approve a direction before it can continue. |

Partition definitions (published in the rules document and the `.agents` skill):
- **Not blocked:** `none`, JSON `null`, or key absent at a gate. (Plain validation still reports an absent key through the required-key check; that behavior is unchanged.)
- **Mechanical:** the orchestration process itself did not complete a step: a tool or delegation failed, a delegate returned no or an incomplete receipt, a validator failed, or the operator stopped execution. Membership is defined by the published constant, not by the wording; `user_requested_stop` is placed in this partition because it is a process-level interruption and to keep the pre-existing vocabulary in one group.
- **Non-mechanical:** every process step could proceed, but the work cannot continue for a reason that no retry or remediation cycle of the process resolves.

The classification is recoverable from `blocked_reason` alone by looking the value up in the published partition.

**Per-runtime changes:**

1. Python (authoritative). New private module `scripts/dev_tools/_orchestrator_state_blocked_reason.py`, following the `_orchestrator_state_<topic>.py` sibling convention (module docstring with Purpose, Usage, Invariants / Constraints, Side Effects; `from __future__ import annotations`). It defines:
   - `MECHANICAL_BLOCKED_REASONS: frozenset[str]` containing the six existing non-`none` members.
   - `NON_MECHANICAL_BLOCKED_REASONS: frozenset[str]` containing the five new members.
   - `VALID_BLOCKED_REASONS: frozenset[str] = frozenset({"none"}) | MECHANICAL_BLOCKED_REASONS | NON_MECHANICAL_BLOCKED_REASONS`.
   - `BlockedReasonClass = Literal["not_blocked", "mechanical", "non_mechanical"]`.
   - `classify_blocked_reason(value: object) -> BlockedReasonClass`, a pure function: `None` and `"none"` return `"not_blocked"`; a member of the mechanical set returns `"mechanical"`; a member of the non-mechanical set returns `"non_mechanical"`; any other value (an out-of-enum string, a case variant, or a non-string non-`None` value) raises `ValueError` with the message `invalid blocked_reason: {value!r}`. Chosen behavior: **raise**, because the helper is a classifier for already-valid checkpoints and a silent fourth class would let triage tooling treat an invalid value as a known class. Callers pass `None` when the key is absent.
   - The module asserts no invariant at import time beyond the constants; disjointness and union equality are asserted by unit tests.

   `scripts/dev_tools/validate_orchestrator_state.py` replaces its local `VALID_BLOCKED_REASONS` set literal with an import of `VALID_BLOCKED_REASONS` from the new module (isort order among the existing `_orchestrator_state_*` imports), so `validate_orchestrator_state.VALID_BLOCKED_REASONS` remains importable. The plain-validation membership check becomes:
   ```python
   blocked_reason = state_map.get("blocked_reason")
   if blocked_reason is not None and (
       not isinstance(blocked_reason, str)
       or blocked_reason not in VALID_BLOCKED_REASONS
   ):
       errors.append(f"Checkpoint has invalid blocked_reason: {blocked_reason}")
   ```
   The message f-string and its position in the error list are unchanged. The completion check and `_orchestrator_state_pr_creation_readiness.py` are not edited. The executor verifies by search that no code mutates `VALID_BLOCKED_REASONS` (the type changes from `set` to `frozenset`; `frozenset == set` comparisons with equal members remain true).

2. TypeScript. New sibling module `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts`. `orchestrator-state-core.ts` is 467 lines (research section 5); a partition, a union, and a helper added in place would reach or exceed the 500-line cap after Prettier formatting, so they are placed in the sibling module. It exports:
   - `MECHANICAL_BLOCKED_REASONS: ReadonlySet<string>`, `NON_MECHANICAL_BLOCKED_REASONS: ReadonlySet<string>`, and `VALID_BLOCKED_REASONS: ReadonlySet<string>` built as the union of `"none"` and both partitions.
   - `type BlockedReasonClass = "not_blocked" | "mechanical" | "non_mechanical"`.
   - `classifyBlockedReason(value: unknown): BlockedReasonClass` with the same semantics as the Python helper: `null`, `undefined`, and `"none"` return `"not_blocked"`; any other non-member value throws a `RangeError` whose message begins `invalid blocked_reason: `.

   `orchestrator-state-core.ts` removes its local `VALID_BLOCKED_REASONS` definition, imports it from the sibling module for its existing membership check, and re-exports it (`export { VALID_BLOCKED_REASONS } from "./orchestrator-state-blocked-reason";`) so existing importers are unaffected. The membership check logic and message are unchanged. `extensions/drm-copilot/jest.config.cjs` gains a per-file `coverageThreshold` entry for the new module (`lines: 85`, `branches: 75`), because the map has no `global` key and a new production file without an entry is ungated.

3. PowerShell. `.claude/lib/orchestrator-state/OrchestratorState.psm1` is 499 lines (research section 5). The existing `$script:VALID_BLOCKED_REASONS` block (comment plus one member per line) is rewritten in compact grouped form, for example:
   ```powershell
   # blocked_reason vocabulary; mirrors scripts/dev_tools/_orchestrator_state_blocked_reason.py.
   $script:MECHANICAL_BLOCKED_REASONS = @('spawn_agent_unavailable', 'delegation_launch_failed', 'delegate_no_receipt', 'delegate_contract_incomplete', 'validator_failed', 'user_requested_stop')
   $script:NON_MECHANICAL_BLOCKED_REASONS = @('premise_falsified', 'external_dependency', 'policy_hold', 'awaiting_ci', 'human_decision_required')
   $script:VALID_BLOCKED_REASONS = @('none') + $script:MECHANICAL_BLOCKED_REASONS + $script:NON_MECHANICAL_BLOCKED_REASONS
   ```
   The exact wrapping is set by the formatter; the file must measure at or below 500 lines after formatting. In `Get-OrchestratorStateBasePresenceError`, `-notcontains` becomes `-cnotcontains`. In `Get-OrchestratorStatePrCreationReadinessError`, `-ne 'none'` becomes `-cne 'none'`. No new PowerShell module is added, and `Export-ModuleMember` is unchanged. **PowerShell does not expose a classify function**: the line budget does not allow one, and no PowerShell consumer requires it; the grouped arrays are the published partition and are read by tests through `InModuleScope`. The bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1` receives the identical edit in the same commit. `OrchestratorStateCompletionChecks.psm1` (C2.1, already case-sensitive via `-ceq`) and `OrchestratorStateUnconditional.psm1` are not edited.

4. Documentation (details under Data / API / Config Impact).

### Boundaries and invariants to preserve:
- Error-message strings and error ordering are unchanged in every runtime: `Checkpoint has invalid blocked_reason: <value>`, ``Checkpoint completion validation failed: blocked_reason is not `none`.``, and ``Checkpoint PR-creation readiness validation failed: blocked_reason is not `none`.`` (research section 1.2). The membership error keeps its position after the step-status errors and before the receipt errors.
- Gate logic is unchanged apart from the PowerShell `-cne` operator correction: no completion, readiness, hook, or preflight code gains or loses a rule.
- Out-of-enum values continue to be rejected in all three runtimes, including case variants of any member.
- A checkpoint that omits `blocked_reason` or sets it to any existing member validates byte-identically in every mode that exists in a runtime: plain, `require_complete`, PR-creation readiness (Python and PowerShell), and `require_model_routing`.
- The Python, TypeScript, and PowerShell vocabularies and partitions are equal.
- Repository and bundled copies of every edited `.claude/**` and `.agents/**` file are byte-identical.

### Dependencies or blocked work:
- Depends on #464 (merged into the integration branch first). This spec uses #464's layout: `scripts/dev_tools/_orchestrator_state_remediation_loop.py`, `scripts/dev_tools/validate_orchestrator_state_cli.py`, and the `__main__` guard in `validate_orchestrator_state.py`. #464 also edits `.claude/rules/orchestrator-state.md` near its line 95 and inserts `## Bare-Module CLI Contract` after it.
- Concurrent with #509 (wave 1). See Fan-In Coordination.
- Blocks #484 (wave 2), which consumes the non-mechanical members defined here. See Extension Point for #484.

### Implementation strategy (what changes, not sequencing):
The vocabulary moves into a dedicated partition module in Python and TypeScript and into grouped arrays in PowerShell; each validator's existing membership check reads the union. Two operator corrections and one type guard are applied on the lines that already perform the membership and readiness comparisons. A committed JSON corpus and a partition oracle provide cross-runtime parity. Documentation publishes the vocabulary, the partition, and producer guidance.

#### Files/modules to change:
- New: `scripts/dev_tools/_orchestrator_state_blocked_reason.py`.
- Modified: `scripts/dev_tools/validate_orchestrator_state.py` (constant replaced by import; membership guard).
- New: `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts`.
- Modified: `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` (constant replaced by import and re-export).
- Modified: `extensions/drm-copilot/jest.config.cjs` (one `coverageThreshold` entry).
- Modified: `.claude/lib/orchestrator-state/OrchestratorState.psm1` and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorState.psm1`.
- Modified documentation (each with its bundled mirror in the same commit):
  - `.agents/skills/orchestrator-workflow/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`.
  - `.claude/rules/orchestrator-state.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.
  - `.claude/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`.
  - `.agents/skills/orchestrate/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrate/SKILL.md`.
- New fixtures: `tests/fixtures/orchestrator_state_blocked_reason/*.json` and `tests/fixtures/orchestrator_state_blocked_reason_partition.json`.
- New tests: see Test Strategy.
- Search guidance: grep the repository for `user_requested_stop` (excluding `docs/`) to find every document and code file that enumerates the vocabulary; each hit is either an edited file above, a test fragment, or an excluded file listed under Scope & Non-Goals. Any other enumerating hit must be added to this change or recorded with a reason.

#### Functions/classes/CLI commands impacted:
- Python: `classify_blocked_reason` (new); `validate_orchestrator_state_text` membership branch (guard only). `VALID_BLOCKED_REASONS` is re-homed and re-exported. No CLI flag changes in `validate_orchestrator_state_cli.py` or the dispatcher.
- TypeScript: `classifyBlockedReason` (new); `validateOrchestratorStateText` unchanged apart from the imported constant.
- PowerShell: `Get-OrchestratorStateBasePresenceError` (operator), `Get-OrchestratorStatePrCreationReadinessError` (operator); script-scoped arrays.

#### Data flow and validation changes:
1. Plain validation: the required-key check is unchanged. For a present, non-null value, each runtime checks membership in the union vocabulary. Python additionally treats any non-string as invalid. PowerShell compares case-sensitively.
2. `require_complete`: unchanged. Every non-`none` member, including the five new members, yields the existing completion message.
3. PR-creation readiness: Python unchanged; PowerShell compares case-sensitively. Every non-`none` member yields the existing readiness message.
4. Classification: consumers call `classify_blocked_reason` / `classifyBlockedReason` on the stored value to obtain the partition.

#### Error handling and logging updates:
- No new validator messages. The helpers raise `ValueError` (Python) or `RangeError` (TypeScript) for values outside the vocabulary; they are not called by the validators.
- No logging changes.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the change set. A revert would make checkpoints that use the new members fail plain validation again; no checkpoint on `main` uses them at merge time.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Checkpoint field `blocked_reason`: string from the vocabulary table above, or JSON `null`. Required as a key by plain validation (unchanged).
- Python: `classify_blocked_reason(value: object) -> Literal["not_blocked", "mechanical", "non_mechanical"]`; raises `ValueError`.
- TypeScript: `classifyBlockedReason(value: unknown): "not_blocked" | "mechanical" | "non_mechanical"`; throws `RangeError`.
- Partition oracle `tests/fixtures/orchestrator_state_blocked_reason_partition.json`: `{"not_blocked": ["none"], "mechanical": [...], "non_mechanical": [...]}` with members sorted lexically.
- Corpus case file `tests/fixtures/orchestrator_state_blocked_reason/<name>.json`: required keys `name` (equals the file stem), `notes`, `checkpoint`, `expected_errors` (ordered list of plain-validation errors containing the substring `blocked_reason`); optional key `expected_completion_errors` (ordered list of `require_complete` errors containing `blocked_reason`), present only for completion-gating cases. Values of `blocked_reason` in the corpus are limited to strings, `null`, integers, and key absence (boolean, float, array, and object values are excluded because message rendering diverges; research section 6.6 item 5).

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
- Checkpoints that omit `blocked_reason` or use `none`, `null`, or an existing mechanical member produce the same error list, byte for byte, as before the change, in every mode each runtime supports.
- Output changes only for inputs that previously raised or that Python and TypeScript already rejected:
  - PowerShell `-cnotcontains`: a case variant of a member (for example `NONE`, `Validator_Failed`) that PowerShell previously accepted now yields `Checkpoint has invalid blocked_reason: <value>`, matching Python and TypeScript.
  - PowerShell `-cne`: a case variant of `none` that PowerShell readiness previously treated as clear now yields the readiness message; Python readiness already did so.
  - Python `isinstance` guard: an array or object value in plain validation, which previously raised `TypeError`, now yields `Checkpoint has invalid blocked_reason: <rendered value>`.
- The five new members change output only for checkpoints that use them; before the change they were rejected as out-of-enum.
- `validate_orchestrator_state.VALID_BLOCKED_REASONS` and the TypeScript `VALID_BLOCKED_REASONS` export remain importable from their current modules.

#### Performance constraints (latency/throughput/memory):
None. The change is a constant-set lookup.

## Extension Point for #484

- #484 records its external-dependency, policy, awaiting-CI, and human-decision halts by writing `external_dependency`, `policy_hold`, `awaiting_ci`, and `human_decision_required` to `blocked_reason`. These literals are fixed by #523; #484 consumes them and must not rename, remove, or re-partition them. Writing them requires no validator, gate, corpus, or partition change.
- All four are in the non-mechanical partition, so every existing gate treats them as not complete, and a triage reader distinguishes them from `none` and from mechanical failures with `classify_blocked_reason` / `classifyBlockedReason` alone. `awaiting_ci` is a wait rather than a terminal halt, but it is still blocking: a run waiting on CI cannot assert completion.
- #484 decides which producer writes each member and whether a halt consumes a remediation cycle; those are #484 design decisions and do not alter this contract.
- Adding a halt class beyond these five is a contract change: append the literal to the non-mechanical partition in all three runtimes (Python module, TypeScript module, PowerShell repo and bundle arrays), update the partition oracle, add corpus files, and update the documentation listed in this spec. That work is out of scope for #484 by design; a need for it in #484 is a signal to open a separate contract issue.
- The names are settled by this spec, and #484's spec is authored after #523 merges into the integration branch, which addresses the research objection that #484's literals were unsettled (research section 6.6 item 1).

## Relationship to `human_interaction.requirements[].response == "halt"`

`human_interaction.requirements[].response` accepts `halt` (`scripts/dev_tools/_orchestrator_state_human_interaction.py`; `.claude/skills/orchestrate/SKILL.md`), and `Test-HumanInteractionShape` blocks DONE while any `halt` is present. It models an unautomatable human requirement. A human-decision halt may appear in both places: `blocked_reason: "human_decision_required"` classifies the run's halt, and a `human_interaction.requirements[]` entry with `response: "halt"` describes the specific requirement. #523 adds no cross-field rule between them: either may appear without the other, and neither is validated against the other. The rules-document section states this relationship.

## Fan-In Coordination

Files shared with #509 (research section 7). No function is edited by both children.

| File | #523 hunk anchor | #509 hunk anchor | Rule |
|---|---|---|---|
| `.agents/skills/orchestrator-workflow/SKILL.md` and bundle `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` | The `Blocked-reason enum:` block that begins ``- `blocked_reason` MUST be one of:`` (research: lines 145-159) | Near lines 200-201 and 407 (#509 spec) | Edit only the enumeration block and text immediately following it; do not reflow other sections. |
| `.claude/rules/orchestrator-state.md` and bundle `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | New `## Blocked-Reason Vocabulary` section inserted after the `## Invariants (human_interaction block)` section and before `## Complexity-Assessment Scope and Backward Compatibility` | New `issue_adoption` section and a bullet in `## Enforcement` | #523 does not edit `## Enforcement` and does not insert near the require-model-routing text. |
| `extensions/drm-copilot/jest.config.cjs` | One new `coverageThreshold` key for `./src/lib/validate/orchestrator-state-blocked-reason.ts`, inserted adjacent to the `./src/lib/validate/orchestrator-state-core.ts` entry | #509 adds its own threshold entry | Separate keys; resolve any adjacent-line conflict by keeping both entries. |

Files shared with #464 (already merged before #523 executes):

| File | #464 change | #523 change |
|---|---|---|
| `scripts/dev_tools/validate_orchestrator_state.py` | Remediation-loop extraction, import, `__main__` guard | `VALID_BLOCKED_REASONS` import replacing the set literal; membership guard. No edit to the guard or the remediation import. |
| `.claude/rules/orchestrator-state.md` (and bundle) | Flag description near line 95 and a `## Bare-Module CLI Contract` section after it | New section at the anchor above, which is not adjacent to #464's hunks. |

Files not shared under this design: `pack-manifests/core.json`, `OrchestratorState.Manifest.Tests.ps1`, both `pester.runsettings.psd1` files, and the routing modules. If the executor finds that Pester run settings enumerate test paths (rather than discovering them) and the new Pester test files must be registered, that registration becomes a Fan-In item and is recorded with its anchor before commit.

## Promotion Note

#523 pre-existed on GitHub; no `potential_to_issue` receipt exists for it and none is created. Following the epic's shared design, the orchestrator records the substitution under `human_interaction.requirements[]` in the checkpoint, citing #509 as the defect that otherwise makes the receipt unavoidable. #509 is being prepared concurrently and introduces a structured evidence form for pre-existing issues; runs after #509 merges into the integration branch should use that evidence form instead of the `human_interaction` substitution.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - #464 has merged into the integration branch before execution; the executor confirms `scripts/dev_tools/_orchestrator_state_remediation_loop.py` and `scripts/dev_tools/validate_orchestrator_state_cli.py` exist.
  - Line counts in the research were not measured with a shell; the executor re-measures every file named under Constraints before and after editing.
- Constraints (budget, performance, compatibility):
  - No enforcement hook gains a Python leg; no file under `.claude/hooks/` is edited.
  - No issue #769 file is touched (`.claude/hooks/enforce-powershell-batch-budget.ps1` and related files and tests).
  - No production or test file exceeds 500 lines. Specifically: `.claude/lib/orchestrator-state/OrchestratorState.psm1` and its bundle copy (499 before the change) stay at or below 500; `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` stays at or below 500; `scripts/dev_tools/validate_orchestrator_state.py` stays at or below 500. Do not extend `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` (491 lines) or `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` (508 lines, pre-existing overage).
  - No temporary files in tests; corpus files are committed and read in place; readers never write fixtures.
  - Python coverage commands use dotted module names with `--cov-report=term-missing` (a `--cov=<path>.py` form measures nothing).
  - Line coverage >= 85% and branch coverage >= 75% where the tooling measures branch coverage (Pester measures line coverage only).
  - `.claude/rules/` is a policy mirror that agents are instructed not to edit casually. `.claude/rules/orchestrator-state.md` is the documented contract for checkpoint invariants and is also edited by #509 and #464; the #523 edit is a contract-documentation update limited to the new section at the stated anchor.
  - Skill bundle contract (#762): no `python -m scripts.dev_tools...` or `scripts/...` invocation form is added to any `.claude/skills/*/SKILL.md`.
  - `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` requires the fragment ``blocked_reason` MUST be one of:`` to remain in the `.agents` skill and requires the repo and bundle copies to be byte-identical.
- External dependencies (services, libraries, releases):
  - None. No new dependency, release, or version bump.

## Data / API / Config Impact
- User-facing or API changes:
  - Checkpoint vocabulary gains `premise_falsified`, `external_dependency`, `policy_hold`, `awaiting_ci`, and `human_decision_required`.
  - New Python and TypeScript partition constants and classification helpers.
  - `.agents/skills/orchestrator-workflow/SKILL.md` (and bundle): add the five members to the enumeration under ``- `blocked_reason` MUST be one of:``, each with its one-sentence definition, and a short statement of the partition. Leave the six documentation-only members unchanged and do not add or remove any other entry.
  - `.claude/rules/orchestrator-state.md` (and bundle): new `## Blocked-Reason Vocabulary` section at the Fan-In anchor containing the vocabulary table, the partition definitions, the rule that the vocabulary is enforced identically by the three validators with case-sensitive comparison, the relationship to `human_interaction.requirements[].response == "halt"`, and a short paragraph identifying the non-mechanical members reserved for #484 and how a future class is added.
  - `.claude/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrate/SKILL.md` (and bundles): producer guidance stating that `premise_falsified` is used when every delegation and validator succeeded but evidence gathered during execution falsified the plan's premise, that the evidence path is still recorded in free-form keys, and that the preparation-mode terminal checkpoint still sets `blocked_reason: "none"`. The guidance refers to the rules document for the full vocabulary and contains no invocation form.
- Data or migration considerations:
  - None. Existing checkpoints are unaffected.
- Logging/telemetry updates (if any):
  - None.
- Compatibility notes (CLI flags, config schemas, versioning):
  - No CLI flag or schema-version change. The contract change is additive.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: enum acceptance and rejection in all three runtimes; cross-runtime parity fixtures.
- [ ] Integration scenario to retest: existing checkpoints validate byte-identically.
- [ ] Manual verification notes: skill documents enumerating `blocked_reason` values list the new representation.

- Regression tests to add or update:
  - Existing suites run unchanged before and after the change and stay green: `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, `test_validate_orchestrator_state_pr_creation_readiness.py`, `test_validate_orchestrator_state_completion.py`, `test_validate_orchestrator_state_remediation_loop.py`, `test_validate_orchestrator_state_cli.py`; Pester `OrchestratorState.Tests.ps1`, `OrchestratorStateUnconditional.Tests.ps1`, `OrchestratorStateCompletionChecks.Tests.ps1`, `OrchestratorState.Manifest.Tests.ps1`; Jest `orchestrator-state-core.test.ts`, `orchestrator-state-core.completion.test.ts`.
- Unit tests for the fixed behavior and boundaries:
  - Python `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py`: partition disjointness; union equality; `classify_blocked_reason` for `None`, `"none"`, each mechanical member, each non-mechanical member, an out-of-enum string, a case variant, an integer, a list, and a dict (the last five raise `ValueError`); partition equals the oracle file.
  - Python `tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py`: each new member accepted in plain validation; each new member blocked under `require_complete` with the existing message; each new member blocked under PR-creation readiness with the existing message; list and dict values yield the invalid-value error in plain validation with no exception.
  - Jest `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason.test.ts`: the same partition and helper cases (`RangeError` for non-members), partition equals the oracle file, and `VALID_BLOCKED_REASONS` imported from `orchestrator-state-core.ts` is the same set.
  - Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1`: base membership accepts each new member and rejects case variants (`PREMISE_FALSIFIED`, `NONE`, `Validator_Failed`); `Get-OrchestratorStatePrCreationReadinessError` (via `InModuleScope`, in-memory object, no file) blocks each new member and a case variant of `none`; the script-scoped grouped arrays equal the oracle file and `$script:VALID_BLOCKED_REASONS` equals `'none'` plus both arrays.
  - Documentation drift tests (functions prefixed `test_docs_`) in `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py`: every member of `VALID_BLOCKED_REASONS` appears in the `.agents` orchestrator-workflow enumeration and in the `## Blocked-Reason Vocabulary` section of `.claude/rules/orchestrator-state.md` (files read in place).
- Parity corpus `tests/fixtures/orchestrator_state_blocked_reason/*.json`, with readers:
  - Python `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason_parity.py` via `validate_orchestrator_state_text`.
  - Jest `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-parity.test.ts` via `validateOrchestratorStateText` (routing matrix injected when `requireComplete` is set).
  - Pester `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1` via `Get-OrchestratorStateUnconditionalError` and `Get-OrchestratorStateCompletionBlockedReasonError` on `ConvertFrom-Json` output, resolving the corpus relative to `$PSScriptRoot` as `BlastRadius.Parity.Tests.ps1` does.
  - Each reader filters to errors containing `blocked_reason`, compares ordered lists for equality, asserts `name` equals the file stem, and asserts a minimum case count so an empty or unreadable directory fails.
  - Required cases: each new member accepted; `none` and each existing mechanical member accepted with unchanged output; key absent (required-key error only); `null` accepted; an out-of-enum string rejected; case variants rejected (at least `Premise_Falsified` and `NONE`); an integer rejected; `premise_falsified` with `expected_completion_errors` containing the completion message; `none` with an empty `expected_completion_errors`; `human_decision_required` with no `human_interaction` block accepted in plain validation (no cross-field rule).
- Byte-identity regression:
  - Before editing, capture the full (unfiltered) error lists produced by each runtime for checkpoints that omit `blocked_reason`, set it to `null`, `none`, and each existing mechanical member, in every mode the runtime supports (plain, `require_complete`, PR-creation readiness for Python and PowerShell, `require_model_routing`). Re-run after the change and compare byte for byte. Record both captures and the comparison result under `docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/evidence/regression-testing/`.
- Edge cases and negative scenarios: case variants, integers, arrays and objects (Python unit test only), absent key, `null`.
- Error handling and logging verification: helper exception types and message prefixes; validator messages unchanged.
- Coverage impact and targets for changed lines/modules:
  - Python: `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason_parity.py tests/scripts/dev_tools/test_validate_orchestrator_state.py --cov=scripts.dev_tools._orchestrator_state_blocked_reason --cov=scripts.dev_tools.validate_orchestrator_state --cov-branch --cov-report=term-missing`.
  - Jest: per-file threshold for `orchestrator-state-blocked-reason.ts` (85 lines, 75 branches); `orchestrator-state-core.ts` keeps its existing entry.
  - Pester: line coverage for `OrchestratorState.psm1` >= 85% with no reduction on changed lines.
  - Coverage outputs recorded under `docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/evidence/qa-gates/`.
- Toolchain commands to run (format → lint → type-check → test):
  - The seven-stage loop per `.claude/rules/general-code-change.md` for each language touched (Python: Black, Ruff, Pyright, pytest; TypeScript: Prettier, ESLint, TSC, dependency-cruiser, Jest; PowerShell: Invoke-Formatter, PSScriptAnalyzer, Pester), restarting on any failure or auto-fix. Also run `OrchestratorState.Manifest.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`, and `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`.
- Manual validation steps (if required):
  - Measure and record line counts for every file named under Constraints after formatting.
  - Run the `user_requested_stop` search and record that every enumerating hit is covered or excluded with a reason.

## Acceptance Criteria

The first four items are the issue acceptance criteria (AC-1 through AC-4), carried verbatim.

- [ ] `blocked_reason` can express a halt where all delegations and validators succeeded but the premise was falsified (for example a `premise_falsified` member, or an orthogonal `blocked_class` field).
- [ ] The validator accepts the new value and continues to reject values outside the enum.
- [ ] The distinction between "not blocked" and "blocked for a non-mechanical reason" is recoverable from the structured fields alone, without reading free-form text.
- [ ] Existing checkpoints that omit the field, or set it to an existing member, validate byte-identically.
- [ ] AC-5: `scripts/dev_tools/_orchestrator_state_blocked_reason.py` exports `MECHANICAL_BLOCKED_REASONS` (`spawn_agent_unavailable`, `delegation_launch_failed`, `delegate_no_receipt`, `delegate_contract_incomplete`, `validator_failed`, `user_requested_stop`), `NON_MECHANICAL_BLOCKED_REASONS` (`premise_falsified`, `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required`), `VALID_BLOCKED_REASONS` equal to `{"none"} | mechanical | non_mechanical`, and `classify_blocked_reason` returning `"not_blocked"` for `None` and `"none"` and raising `ValueError` for any non-member; `validate_orchestrator_state.VALID_BLOCKED_REASONS` is imported from that module; `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py` covers disjointness, union equality, and every helper branch.
- [ ] AC-6: `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts` exports `MECHANICAL_BLOCKED_REASONS`, `NON_MECHANICAL_BLOCKED_REASONS`, `VALID_BLOCKED_REASONS`, `BlockedReasonClass`, and `classifyBlockedReason` with the same members and semantics (throwing `RangeError` for non-members); `orchestrator-state-core.ts` imports and re-exports `VALID_BLOCKED_REASONS` from it; `jest.config.cjs` has a per-file threshold entry for the new module; `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason.test.ts` passes.
- [ ] AC-7: `.claude/lib/orchestrator-state/OrchestratorState.psm1` defines `$script:MECHANICAL_BLOCKED_REASONS` and `$script:NON_MECHANICAL_BLOCKED_REASONS` in compact grouped form and `$script:VALID_BLOCKED_REASONS` as `'none'` plus both arrays, accepting exactly the Python set; no new PowerShell module, pack-manifest entry, or run-settings entry is added; the bundled copy is byte-identical and committed in the same commit; `OrchestratorState.Manifest.Tests.ps1` passes.
- [ ] AC-8: `tests/fixtures/orchestrator_state_blocked_reason_partition.json` records the partition, and the Python, Jest, and Pester unit tests each assert that their runtime's partition equals it.
- [ ] AC-9: The corpus `tests/fixtures/orchestrator_state_blocked_reason/*.json` (shape `{name, notes, checkpoint, expected_errors}` plus optional `expected_completion_errors`) contains every required case listed in Test Strategy, and passes, read in place with no temporary files, through `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason_parity.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-parity.test.ts`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1`, each enforcing the name-equals-stem and minimum-count guards.
- [ ] AC-10: PowerShell membership uses `-cnotcontains` and PowerShell PR readiness uses `-cne`; `OrchestratorStateBlockedReason.Tests.ps1` proves that `PREMISE_FALSIFIED`, `NONE`, and `Validator_Failed` are rejected by base validation and that a case variant of `none` is blocked by readiness, matching Python and TypeScript.
- [ ] AC-11: Python plain validation of a checkpoint whose `blocked_reason` is a list or dict returns `Checkpoint has invalid blocked_reason: <rendered value>` without raising; proven in `tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py`. The remaining `TypeError` under `require_complete` and PR readiness is recorded as a follow-up.
- [ ] AC-12: Each of the five new members is blocked by `require_complete` with ``Checkpoint completion validation failed: blocked_reason is not `none`.`` in all three runtimes and by PR readiness with the existing readiness message in Python and PowerShell, with no edit to `OrchestratorStateCompletionChecks.psm1`, `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`, `.claude/hooks/validate-orchestrator-output.ps1`, or `.claude/hooks/enforce-pr-author-skill-helpers.ps1`.
- [ ] AC-13: Before/after captures of full error lists for checkpoints that omit `blocked_reason` or set it to `null`, `none`, or each existing mechanical member are byte-identical in every mode each runtime supports (plain, `require_complete`, PR readiness, `require_model_routing`), recorded under `docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/evidence/regression-testing/`; the existing validator suites listed in Test Strategy pass unchanged; no existing message string or error ordering changes.
- [ ] AC-14: `.agents/skills/orchestrator-workflow/SKILL.md` and its bundle copy list the five new members with their definitions and state the partition; the documentation-only members are unchanged; the ``blocked_reason` MUST be one of:`` fragment remains; `test_orchestration_guardrail_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass; the divergence of the documentation-only members is recorded as a follow-up.
- [ ] AC-15: `.claude/rules/orchestrator-state.md` and its bundle copy contain a `## Blocked-Reason Vocabulary` section placed after `## Invariants (human_interaction block)` and before `## Complexity-Assessment Scope and Backward Compatibility`, containing the vocabulary, the partition, the `human_interaction` halt relationship, and the #484 extension note; `## Enforcement` is not edited; `test_push_down_claude_resource_contracts.py` passes.
- [ ] AC-16: `.claude/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, and their bundle copies state when to use `premise_falsified` and that the preparation-mode terminal checkpoint still sets `blocked_reason: "none"`; no invocation form is added; `test_skill_bundle_contract_repo.py` passes.
- [ ] AC-17: The `test_docs_`-prefixed tests in `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py` assert that every member of `VALID_BLOCKED_REASONS` appears in the `.agents` orchestrator-workflow enumeration and in the rules-document `## Blocked-Reason Vocabulary` section, and pass.
- [ ] AC-18: The spec section `## Extension Point for #484` and the rules-document section both state that #484 consumes `external_dependency`, `policy_hold`, `awaiting_ci`, and `human_decision_required` without renaming them, and that any further class is a separate contract change.
- [ ] AC-19: Measured line counts, recorded in the evidence, show `OrchestratorState.psm1` and its bundle copy, `orchestrator-state-core.ts`, `validate_orchestrator_state.py`, and every new production and test file at or below 500 lines; `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` and `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` are not modified.
- [ ] AC-20: Line coverage >= 85% and branch coverage >= 75% for `scripts.dev_tools._orchestrator_state_blocked_reason` and `scripts.dev_tools.validate_orchestrator_state` (dotted `--cov=` form with `--cov-report=term-missing`) and for `orchestrator-state-blocked-reason.ts`; line coverage >= 85% for `OrchestratorState.psm1`; no reduction on changed lines.
- [ ] AC-21: No file under `.claude/hooks/` is modified, no enforcement hook gains a Python leg, and no issue #769 file is modified.
- [ ] AC-22: The checkpoint records the `potential_to_issue` substitution under `human_interaction.requirements[]` citing #509.
- [ ] AC-23: The `user_requested_stop` repository search result is recorded, and every enumerating document or code file is either updated by this change or listed as excluded with a reason.
- [ ] AC-24: Full toolchain pass completed (format → lint → type-check → architecture → test → contract → integration) for Python, TypeScript, and PowerShell with no failing stage in a single pass.

## Risks & Mitigations
- Technical or operational risks:
  - `OrchestratorState.psm1` has one line of headroom; formatter wrapping of the compact arrays could exceed the cap.
  - Predefined members could be renamed by #484, which would itself be a breaking contract change.
  - Documentation edits applied to only one copy fail bundle-parity tests.
  - Concurrent #509 edits to the shared rules and `.agents` documents and to `jest.config.cjs` could conflict at fan-in.
  - The operator corrections change PowerShell output for case-variant inputs; a producer that wrote a case variant would begin to fail PowerShell validation.
  - Research figures were not measured with a shell.
- Mitigations and rollbacks:
  - Run Invoke-Formatter, re-measure, and adjust grouping (for example split each array across two lines and remove a blank line only within the edited block) until the file is at or below 500 lines.
  - The Extension Point section fixes the names, and #484's spec is authored after #523 merges.
  - Apply each documentation edit to both copies in the same commit and run the parity tests.
  - Use the anchors in Fan-In Coordination and keep hunks confined to them.
  - Python and TypeScript already reject case variants, so any such producer was already failing two of the three validators; the corpus records the intended behavior.
  - Re-measure every figure during execution and record it in the evidence.
  - Rollback is a revert of the change set.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge to `epic/orchestrator-state-contract-correctness-integration` (epic #771). No version bump or publish step is specific to this fix.
- Post-fix monitoring or clean-up tasks (follow-ups, not part of #523):
  1. Reconcile the documentation-only members in `.agents/skills/orchestrator-workflow/SKILL.md` (`checkpoint_conflict`, `lifecycle_preconditions_missing`, `review_status_missing`, `commit_context_missing`, `no_staged_changes`, `pre_implementation_gate_violation`) with the validators, including the `checkpoint_conflict` prose in `.codex/agents/*.toml`.
  2. Cross-runtime message rendering for boolean and float `blocked_reason` values.
  3. Python `TypeError` for array or object `blocked_reason` under `require_complete` and PR readiness.
  4. PR-creation-readiness gate absent from the TypeScript validator.
  5. `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` exceeds the 500-line cap (pre-existing).
  6. The `test_orchestration_guardrail_contracts.py` skip reason states that `.codex` and `.agents` are gitignored, which does not match the current `.gitignore`.
- Links: issue #523; epic #771 (`docs/features/epics/orchestrator-state-contract-correctness/epic.md`); upstream #464 (`docs/features/active/2026-09-29-validate-orchestrator-state-cli-entry-point-464/spec.md`); concurrent #509; downstream #484; out-of-scope #769; research `research/2026-09-29T16-00-blocked-reason-halt-representation-research.md`.
