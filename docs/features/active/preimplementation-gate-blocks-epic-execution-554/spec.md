# preimplementation-gate-blocks-epic-execution (Spec)

- **Issue:** #554
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-26T13-10
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** `full-bug`
- **Acceptance-Criteria Source:** this file, exclusively

## Document Role and the Absent User Story

Work mode is `full-bug`. Under `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug`
resolves the authoritative acceptance-criteria source to `spec.md` only. This document is that
single source. `issue.md` carries a pointer section, not a second source, and nothing is checked
off there.

`user-story.md` is deliberately **not** created for this feature. The judgement, stated explicitly
as required: this defect is a decision-procedure fault inside a `PreToolUse` enforcement hook. It
has no user-facing narrative, no persona whose goal changes, and no externally observable surface
other than whether an orchestration delegation is permitted to proceed. The affected actor is an
automated orchestration agent, and the requirement is fully expressible as a behavioural contract
over a classifier and three readiness predicates. A user story would restate the acceptance
criteria in a weaker form and introduce a second, non-authoritative requirement source. The
requirements do not justify one.

---

## Superseded Requirement

**The maintainer amendment comment of 2026-08-26 supersedes the original issue body's Expected
Behavior on one point, and the amendment governs wherever the two disagree.**

The issue body's Expected Behavior asked that an epic-execution delegation be evaluated for
readiness *"against the epic checkpoint the prompt itself names"*. **That statement is RETRACTED.**
It is retracted as a gate weakness, not as an editorial correction: a delegation that names its own
readiness file chooses its own gate, which destroys the gate.

The corrected, governing requirement is:

1. The readiness source is resolved from the **recognized mode marker** via a **fixed table**
   declared in the hook. It is **never** resolved from a path parsed out of the prompt.
2. A prompt-declared `epic_checkpoint_path` or `parallel_checkpoint_path` whose value **disagrees**
   with the mode's canonical path must cause the gate to **DENY**. The prompt-declared value is a
   cross-check operand only; it is never the source.

The precedent for the corrected posture already exists in this repository and is cited rather than
invented: `.claude/hooks/enforce-epic-wave-barrier.ps1` declares
`$script:EpicCheckpointPath = 'artifacts/orchestration/epic-orchestrator-state.json'` as a
script-scope constant and reads no path from any prompt.
`.claude/hooks/enforce-parallel-cohort-barrier.ps1` and `.claude/hooks/enforce-epic-merge-gate.ps1`
take the same posture. The fix extends that one-row table to four rows; it does not invent a
mechanism.

The amendment comment is reproduced verbatim in
[`## Appendix — Amendment Comment (verbatim)`](#appendix--amendment-comment-verbatim) below, so
this document is self-contained as the acceptance-criteria source.

### Reconciliation of the prior research pass against the amendment

The prior research pass
(`docs/features/active/preimplementation-gate-blocks-epic-execution-554/research/2026-08-26T09-30-preimplementation-gate-epic-execution-554-research.md`)
**already accounts for the amendment.** Verified point by point:

- It records Fault 1 explicitly (section J, "removes the two prose tokens ... and removes the whole-
  payload `ConvertTo-Json` scan"), and section G2 analyses which existing tests depend on the
  seven-token classifier.
- It records the seven-token classifier's exact text and location (section G2, section J shape).
- It records the canonical-path cross-check as "used **only** as a cross-check that must equal the
  table value, otherwise DENY — never as the source" (section J), and confirms both canonical
  values are actually emitted by the kickoff contracts (sections E1, E2).
- It enumerates the ten-case test matrix implications in section K, including the case-6b
  allow-to-deny direction and the Codex case-10 unreachability (section G3).

**No reconciliation gap was found between the research and the amendment.** One place where the
research is *incomplete rather than wrong* is recorded below under Decision D7 and in
[Risks](#risks--mitigations): research F1 correctly reports that `epic_manifest_path` is not a
required key of the epic **orchestrator** checkpoint per
`scripts/dev_tools/validate_epic_orchestrator_state.py`, and advises "do not assume it on the
orchestrator side". That is accurate about the validator but omits that
`.claude/skills/epic-orchestrate/SKILL.md:280-282` **does** mandate the key on the orchestrator
checkpoint, pointing at `docs/features/epics/<epic-slug>/epic.md`. That omission materially changes
the risk assessment for the `epic_manifest_path` predicate and is corrected here.

---

## Context

`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is a `PreToolUse` hook registered
on the `Agent` matcher (among others). It denies every epic-execution `Agent(orchestrator)`
delegation, so a fully prepared epic cannot be executed.

- **Impact / severity:** Blocker. The entire epic execution surface is unreachable. `/epic-plan`
  succeeds and `/epic-run` cannot start, so epic-scale work can be prepared but never executed. The
  same fault applies to the parallel execution surface.
- **Affected environments:** Windows 11 Pro 10.0.26200, and any destination repository carrying the
  pushed-down `.claude` pack. PowerShell 7+.
- **First observed:** 2026-08-25, destination-repo epic `quickfiler-bug-family`, commit `41eb2a5e`.
- **Lineage:** this is the third defect in this hook after issues #535 and #539. Both of those were
  point patches to exemption lists. **A fourth list entry is explicitly not the remedy**; this
  change is a structural repair of the gate's decision procedure.

## Repro & Evidence

Steps to reproduce:

1. Run `/epic-plan` for an epic slug to completion. Every child feature is promoted, planned, and
   preflight-cleared; the epic kickoff document is committed to the integration branch.
2. Run `/epic-run` for the same slug. `epic-orchestrator` writes
   `artifacts/orchestration/epic-orchestrator-state.json` and delegates wave 0's first child feature
   via `Agent(orchestrator)` with the epic-mode kickoff line beginning `Epic mode: true.`
3. The `PreToolUse` `Agent`-matcher hook denies the delegation.

Expected versus actual:

- **Expected (as corrected by the amendment):** the delegation is evaluated for readiness against
  the epic checkpoint selected by the mode table, using a predicate matching the epic checkpoint's
  schema, and a prepared epic executes without manual intervention.
- **Actual:** every epic-execution delegation is denied with a fixed reason naming
  `artifacts/orchestration/orchestrator-state.json` regardless of the mode.

Evidence:

- Four `delegation_failures[]` entries in the destination repository's epic checkpoint, each
  carrying the `PREIMPLEMENTATION_GATE_BLOCKED:` reason string.
- **Fault-1 measured evidence (from the amendment):** four `Agent(orchestrator)` epic-child
  delegations were denied verbatim on 2026-08-25; four structurally identical delegations were
  **allowed** on 2026-08-26 and wave 0 launched. The hook file was byte-identical on both dates.
  Kickoff wording was the only difference. The pass was an incidental classifier miss, disclosed
  rather than relied on. No prompt was reworded to dodge the classifier, and the fix must not make
  rewording the remedy.

Determinism: deterministic given a fixed prompt text and a fixed checkpoint state. The apparent
non-determinism observed across the two dates is entirely explained by Fault 1 (prompt-wording
dependence).

## Root Cause Analysis — two composing faults

### Fault 1 — the delegation classifier is a seven-token substring match over the serialized payload

`Test-ImplementationDelegation`
(`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:182-204`) exempts preparation mode
and then falls through to:

```powershell
$payloadText = ($ToolInput | ConvertTo-Json -Depth 20 -Compress)
return $payloadText -match '(python-typed-engineer|powershell-typed-engineer|typescript-engineer|csharp-typed-engineer|atomic-executor|implementation|execute)'
```

Two independent defects compose in these two lines:

- **The match is over the whole serialized payload, not a named field.** Any field in the
  `tool_input` object — `description`, an embedded context blob, anything — can supply a token and
  change the classification. This directly contradicts the field-scoping property that the sibling
  `Test-PreparationModeDelegation` documents at lines 147-180 and enforces.
- **Two of the seven tokens are free-text prose.** `implementation` and `execute` are ordinary
  English words. Classification therefore depends on prompt wording. The word `execution` does not
  contain the bare token `execute`, so a kickoff phrased with "atomic execution" matches none of the
  seven tokens and is **allowed**, while a semantically identical prompt phrased with "execute" is
  **denied**.

### Fault 2 — readiness is read from a single hard-coded single-feature checkpoint

The hook declares one readiness source
(`$script:CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'`, line 17), reads it
through one seam (`Get-CheckpointContent`, lines 236-245), and applies one predicate
(`Test-OrchestrationReady`, lines 206-234) that requires `issue-num`, `feature-folder`, a route id,
and `lifecycle_ready`, with `feature-folder` starting `docs/features/active/`.

**No epic or parallel execution surface can satisfy that predicate.** The epic checkpoint's schema
carries `route_id`, `epic_feature_folder`, `integration_branch`, `waves[]`, and `features[]`; the
parallel checkpoint's carries `route_id`, `parallel_slug`, `parallel_manifest_path`, `cohorts[]`,
and `items[]`. Neither carries `issue-num`, `feature-folder`, or `lifecycle_ready`. The gate is
therefore unsatisfiable by construction for both surfaces, and the deny reason (line 328) names
`orchestrator-state.json` regardless of which surface is being gated.

The two faults compose: Fault 1 decides *whether* a delegation is gated at all, on evidence that is
not structural; Fault 2 decides *against what* it is gated, on a source that cannot be satisfied.
Fixing either alone leaves the surface broken.

### Affected components

| Path | Role |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Claude-surface gate hook (382 lines, 118 of headroom) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | Codex-surface gate hook (382 lines, 118 of headroom) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | issue #539 pathspec classifier (349 lines) — **not modified**, see D1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/...` | byte-identical bundled mirror |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/...` | byte-identical bundled mirror |

---

## Design Decisions (settled; not open questions)

Section L of the research pass listed five open questions. They are settled here. D6 and D7 are
additional settled decisions this spec adds.

### D1 — The new logic lives in a NEW dot-sourced sibling, not in the existing `-helpers.ps1`

**Decision:** create `enforce-orchestration-preimplementation-gate-modes.ps1` as a new dot-sourced
sibling on each surface. Do **not** add the new logic to
`enforce-orchestration-preimplementation-gate-helpers.ps1`.

This overrides the research pass's "Option A (recommended)" and the amendment's required-fix item 6
suggestion to "put mode resolution and the new predicates in the existing dot-sourced helpers
sibling". Two independent reasons, both load-bearing:

**(a) Contract contradiction.** The existing helpers file's header (lines 1-18) declares its
normative contract to be *"the D4 fail-closed rule table in ... issue #539 ... spec.md"* and
declares the file *"Pure string logic only: no disk, process, network, or environment access."* Its
`.SYNOPSIS` names it a *"Pathspec classifier for the orchestration-bookkeeping staging exemption
(issue #539)"*. Adding checkpoint-shape readiness predicates and a mode/checkpoint dispatch table
there would place logic in a file whose own declared contract excludes it, and would require
amending that header to describe two unrelated normative contracts in one file.

**(b) Line budget.** The existing helpers file is **349 of 500 lines**, leaving **151 lines** of
headroom. The new logic comprises a mode table, a canonical-path map, an implementation-agent
allow-list, mode resolution, a target-token finder, a prompt-declared-path cross-check, and the epic
and parallel readiness predicates. With the comment blocks this repository's PowerShell policy
requires, that is approximately **140 to 215 lines**. The upper end exceeds the headroom outright
and the lower end leaves no safe margin for review iterations. Breaching the 500-line cap in
`.claude/rules/general-code-change.md` is a hard policy violation, not a style preference.

**Consequence the plan must exploit:** leaving `-helpers.ps1` **byte-untouched on all four copies**
is also what makes the amendment's guardrail *"Edit/Write and Bash legs are behaviorally unchanged,
proved by the pre-existing suites passing unmodified"* cheap to demonstrate. The issue #539 staging
exemption cannot have regressed if the file that implements it is byte-identical to `HEAD`. That
file is therefore deliberately absent from the declared blast radius.

**Purity constraint on the new sibling.** The new file is **pure**: no disk, process, network, or
environment access. Every readiness predicate accepts an **already-parsed checkpoint object** (or
`$null`). The per-mode **read seams** stay in the main gate hook, which has 118 lines of headroom —
sufficient for two additional read seams and the dispatch. This preserves the same separation the
existing helpers file established and keeps every new predicate directly unit-testable with literal
fixtures.

### D2 — Test injection is by optional parameters, not by mocking a read seam

**Decision:** keep the existing signature
`Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw <string> -CheckpointRaw <string>`
**exactly as-is**, and **add two optional parameters** `-EpicCheckpointRaw` and
`-ParallelCheckpointRaw`. Each overrides the corresponding per-mode read seam when supplied, and
falls through to the seam when not.

Rationale:

- **All pre-existing cases keep working byte-identically.** Every case in all four pre-existing
  suites supplies `-ToolInputRaw` and, where relevant, `-CheckpointRaw`. Adding optional parameters
  with no default behaviour change means approximately sixty existing cases require zero edits.
- **Parameter injection is preferred over mocking the read seam** because it keeps the decision
  function's determinism directly observable: the function's output is a pure function of its
  arguments for every injected case, with no ambient `Mock` scope required, no mock-signature parity
  obligation (`.claude/rules/powershell.md` mocking rule 2), and no registration-order hazard
  (mocking rule 3). It also matches exactly how every existing case in the four suites already
  supplies checkpoint content.
- **It makes "which checkpoint was consulted" testable.** Supplying `-EpicCheckpointRaw` while
  leaving `-CheckpointRaw` unset, and asserting the resulting decision, proves the epic source was
  the one read. Reusing a single `-CheckpointRaw` for all three modes would make that assertion
  impossible.
- No `Mock`, no disk access, no temporary files. Temporary files in tests are **prohibited** by
  `.claude/rules/general-unit-test.md`.

**Pinned signatures that must survive the refactor** (each is asserted by a pre-existing test):

- `Get-OrchestrationPreimplementationGateBlockDecision -Reason <string>` — single mandatory string
  parameter, pinned by `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`.
- `Test-OrchestrationReady -Payload $null` returns false — null-tolerant.
- `Test-ImplementationDelegation -ToolInput $null` returns false — null-tolerant.

### D3 — Target resolution reuses the wave-barrier technique, and denies when no target resolves

**Decision:** the epic readiness predicate resolves its target from the field-scoped `prompt` the
same way `.claude/hooks/enforce-epic-wave-barrier.ps1` does:

- scan the prompt for the pattern `docs[\\/]+features[\\/]+active[\\/]+[^\s"'`]+`,
- longest unique match wins,
- a match ending in the Markdown extension resolves to its parent directory,
- compare on **basename**.

`issue_num` is accepted as an **alternative** resolution when the prompt carries a resolvable issue
number and the checkpoint records `issue_num` on its feature entries.

**When NO target is resolvable, the decision is DENY.** Deny-by-default is preserved.

**Justification (decisive; do not paraphrase this away):**
`.claude/hooks/enforce-epic-wave-barrier.ps1` is registered on the **same `Agent` `PreToolUse`
matcher** and **already denies** an epic-mode `Agent(orchestrator)` delegation whose prompt carries
no resolvable `docs/features/active/` token — see its explicit
`EPIC_WAVE_BARRIER_BLOCKED: an epic-mode orchestrator delegation must reference the target feature
folder in the prompt` branch. Requiring the token in the preimplementation gate therefore creates
**no new denial surface**: any prompt that would fail this predicate is *already* denied by the
sibling hook on the same matcher. The marginal behavioural cost of this decision is zero.

**Out-of-scope follow-up (do NOT act on it in this feature).** The research pass identified a latent
contract gap at its section E1: `.claude/skills/epic-orchestrate/SKILL.md` does **not** mandate that
the child kickoff prompt carry the child's own `docs/features/active/` basename token, and its
kickoff marker line carries no `issue_num:` key. The dependency-citation line that does carry a
feature-folder path is emitted only for a feature with a non-empty `depends_on`, and it names the
*dependency's* folder, not the target's. A wave-0 child with no dependencies therefore has no
contractually guaranteed target token. The parallel contract, by contrast, **does** mandate the path
token (`.claude/skills/parallel-orchestrate/SKILL.md`).

This is a real gap and it is **inherited, not introduced**, by this fix. **Recommendation: file a
separate issue** to close it by amending the epic kickoff contract. **No `SKILL.md` file is modified
by this feature**, on either surface or in any mirror.

### D4 — The parallel readiness predicate IS in scope

**Decision:** implement the parallel readiness predicate in this change. Do **not** defer it to a
follow-up issue. It is required-fix item 4 of the amendment.

Mirrored against `artifacts/orchestration/parallel-orchestrator-state.json`:

- `route_id` is exactly `parallel`;
- `parallel_slug` is a non-empty string;
- `parallel_manifest_path` is a non-empty string;
- `items` is present and non-empty;
- the resolved target is present as a record in `items[]`.

**Enum ownership.** `.claude/rules/parallel-orchestration.md` fixes all nine parallel enums and
states that consumers *"CONSUME these member sets and NEVER extend them."* This predicate consumes
`route_id`, the item-state enum, and the merge-status enum. It extends none of them and adds no
member.

### D5 — The Codex `Agent` leg is unreachable; the honest deliverable is two things

**Fact, confirmed by research G3:** `.codex/config.toml` registers **no** `PreToolUse` matcher
admitting an `Agent` or `Task` tool name. Its only `PreToolUse` tool matchers are `^Bash$`,
`^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$`, and `^(apply_patch|Edit|Write)$`. The three
subagent-lifecycle matchers are `SubagentStart`/`SubagentStop` matchers keyed on agent names, not
tool matchers.

The amendment's test-matrix case 10 asks for *"the same matrix through the `apply_patch`
transport"*. **That is not reachable.** An `apply_patch` `tool_input` carries no `subagent_type`
field, so an `Agent` delegation cannot arrive by that transport, and the Codex hook's own dispatch
tail routes `Edit`/`Write` through a synthesized `{ file_path }` object that never reaches the
delegation classifier at all.

**Decision — the Codex deliverable is exactly these two things and nothing more:**

1. **Direct unit tests of the shared logic.** Dot-source the Codex copy of the gate hook and its new
   modes sibling, and call the new mode-resolution function and the epic and parallel readiness
   predicates with constructed inputs, asserting the same outcomes the Claude-side tests assert.
   This proves **logic parity** between the two copies without claiming a reachable transport. The
   existing Codex command-exemption suite already establishes this dot-source-and-call pattern.
2. **One assertion test recording the gap.** A test that reads `.codex/config.toml` and asserts that
   no `PreToolUse` matcher admits an `Agent` or `Task` tool name, so the gap is recorded as a
   **deliberate, tested fact** rather than an oversight, cross-referenced to issue #555.

**Explicitly prohibited:** fabricating an `Agent` envelope on the Codex side and asserting a
decision on it. That would assert behaviour on a code path the Codex runtime never exercises, and
would produce a green test that proves nothing about the shipped surface.

**Issue #555 is out of scope.** Its single-surface-readiness concern for the file and command legs
remains a separate issue.

### D6 — Change budget: the plan must sequence into capped batches

`.claude/rules/powershell.md` caps direct mode at **2 production PowerShell files** and caps any
batch at **3 production plus 3 test files**.

This change touches **3 logical production PowerShell units**:

1. the `.claude` main gate hook,
2. the `.codex` main gate hook,
3. the new modes sibling (authored once per surface),

realized as **8 physical `.ps1` files** once the two `extensions/drm-copilot/resources/` mirror trees
are counted.

**Decision:** the plan **must** sequence the work into batches that respect the per-batch cap of 3
production files, and **must state explicitly** that each file under
`extensions/drm-copilot/resources/` is treated as a **mechanical byte-copy of an already-reviewed
source file**, not as an independent production edit. That treatment is what keeps the logical
production count at 3 rather than 8. The plan must state the treatment rather than assume it,
because an unstated assumption here is indistinguishable from a budget breach at review time.

The mirrors are not exempt from verification: each mirrored pair's byte-identity is proved by
SHA-256, per the test strategy below.

### D7 — `epic_manifest_path` is required; this is a deliberate tightening and it is acceptable

**Decision:** the epic readiness predicate **requires** a non-empty `epic_manifest_path` whose value
lies under `docs/features/epics/`.

This is a **deliberate tightening** relative to
`scripts/dev_tools/validate_epic_orchestrator_state.py`, whose `REQUIRED_EPIC_KEYS` set does not
include `epic_manifest_path` (research F1 is correct on this point).

It is acceptable for three reasons:

1. **The authoring contract mandates the key.** `.claude/skills/epic-orchestrate/SKILL.md:280-282`
   states that `artifacts/orchestration/epic-orchestrator-state.json` carries `epic_feature_folder`,
   `epic_manifest_path` *"(which points at `docs/features/epics/<epic-slug>/epic.md`)"*,
   `epic_status_doc_path`, `integration_branch`, and the rest. Any checkpoint written by the skill
   that is supposed to write it therefore carries the key. The predicate is stricter than the
   validator but is **not** stricter than the producer's own contract.
2. **The amendment requires it** as an explicit element of required-fix item 3.
3. **A false deny is cheaply diagnosable and cheaply remediable.** The deny reason names the failed
   predicate, so an operator sees precisely which key is missing; and writing the epic checkpoint is
   itself exempt from this gate through the `$script:CheckpointPaths` WRITE exemption, so adding the
   key is not blocked by the gate that reported it.

**Residual risk is recorded** in [Risks](#risks--mitigations) rather than dismissed.

### D8 — The optional `merge_status` hardening IS included

The amendment's required-fix item 3 offers an optional hardening and requires the answer to be
stated: *"require the target record's `merge_status` in a pre-merge state."*

**Decision: INCLUDE it, for both the epic and the parallel predicate.**

Rationale: the amendment's own acceptance criterion 1 states the delegation is allowed *"when, and
only when, the epic checkpoint proves the epic prepared and the target feature is a real, **not-
yet-merged** record in it."* The hardening is therefore not genuinely optional — it is the operand
of the stated acceptance criterion. Omitting it would ship a predicate that permits re-delegating a
feature whose work is already merged.

Precise rule, consuming existing enums and extending none:

- **Deny** when the target record's `merge_status` is `merged` or `worktree_removed`. These are the
  two terminal-merged members on both surfaces, and they are the same two members
  `enforce-epic-wave-barrier.ps1` and `enforce-parallel-cohort-barrier.ps1` already treat as
  terminal-safe.
- **Allow** for every other member, including the failure members (`merge_conflict`,
  `blocked_conflict_loop_limit` on the epic surface; `blocked_drift`, `blocked_ci_loop_limit` on the
  parallel surface). Re-delegation after a blocked or conflicted state is legitimate remediation and
  must not be gated off.
- An **absent** `merge_status` is treated as `not_started`, matching parallel invariant 7 in
  `.claude/rules/parallel-orchestration.md`, and therefore allows.

---

## Proposed Fix

### Design summary

Replace the delegation classifier with a structural one, and replace the single hard-coded readiness
source with a four-row fixed dispatch table plus three readiness predicates.

### Behavioural contract — the replacement classifier

```
Test-ImplementationDelegation(toolInput):
  subagentType := field-scoped read of 'subagent_type' via Get-ClaudeHookToolInputString
  prompt       := field-scoped read of 'prompt'       via Get-ClaudeHookToolInputString
  if subagentType in {python-typed-engineer, powershell-typed-engineer,
                      typescript-engineer, csharp-typed-engineer, atomic-executor}
        -> implementation, readiness source = single-feature checkpoint
  if subagentType != 'orchestrator' -> not implementation (allow)
  mode := Resolve-OrchestrationDelegationMode(prompt)   # fixed table, prompt field only
  if mode == preparation -> not implementation (allow)
  otherwise -> implementation, readiness source = table[mode].checkpointPath
```

Both field reads are **field-scoped**, via `Get-ClaudeHookToolInputString` on the Claude surface and
the hook's local `Get-StringProperty` on the Codex surface. The whole-payload `ConvertTo-Json` scan
is **removed**. Marker text planted in `description` or any other non-`prompt` field can no longer
influence classification in either direction.

The Codex-side field reader `Get-StringProperty` **trims** its result where
`Get-ClaudeHookToolInputString` does not. This is a real, pre-existing behavioural divergence
between the surfaces. The fix must not silently depend on it: every marker test is a containment
test over the prompt, which is insensitive to leading and trailing whitespace, so the divergence
does not affect any decision this change introduces. The plan must not introduce any predicate whose
outcome depends on untrimmed leading or trailing whitespace in a field value.

### The fixed dispatch table

Every literal below is **reused verbatim** from an existing shipped contract or shipped hook. **Do
not invent markers.**

| Mode | Marker literal matched | Readiness source |
| --- | --- | --- |
| preparation | `Preparation mode: true.` **AND** `route_id: preparation.` (both, **with** trailing periods, exactly as the shipped hook already matches) | none — exempt |
| epic execution | `Epic mode: true` (no trailing period, matching `enforce-epic-wave-barrier.ps1`) | `artifacts/orchestration/epic-orchestrator-state.json` |
| parallel execution | `Parallel mode: true` (no trailing period, matching `enforce-parallel-cohort-barrier.ps1`) | `artifacts/orchestration/parallel-orchestrator-state.json` |
| default / single-feature | no marker | `artifacts/orchestration/orchestrator-state.json` |

The trailing-period asymmetry is deliberate and is not a defect to normalize: the preparation
markers are matched **with** their periods by the shipped hook and that behaviour is pinned by an
existing test; the epic and parallel markers are matched **without** trailing periods by the two
shipped barrier hooks, and matching them the same way is what makes the three hooks agree on the
same `Agent` matcher.

Precedence when more than one marker is present: preparation is evaluated first and exempts. An
execution prompt must never carry preparation markers, and the parallel kickoff contract states a
negative obligation to that effect. Accepting preparation literals inside an execution prompt as an
escape hatch is explicitly prohibited (see Non-Goals); the preparation-first ordering is retained
solely because it is the shipped behaviour and is pinned by existing tests.

### The canonical-path cross-check

When the resolved mode is epic or parallel, and the prompt declares an `epic_checkpoint_path:` or
`parallel_checkpoint_path:` value respectively, that declared value must **equal the mode's
canonical path**. A disagreement is a **DENY**.

Both canonical values are confirmed emitted by the shipped kickoff contracts, so this comparison has
a well-defined target on both surfaces. The declared value is never used to select a source; it is
only ever compared against the table value. An **absent** declared value is not a disagreement and
does not deny on this predicate alone.

### The epic readiness predicate

All conjuncts must hold:

1. `route_id` is exactly `epic`;
2. `epic_feature_folder` is a non-empty string;
3. `epic_manifest_path` is a non-empty string under `docs/features/epics/` (see D7);
4. `integration_branch` is a non-empty string;
5. `features` is present and non-empty;
6. the resolved target (D3) is present as a record in `features[]`;
7. that record's `merge_status` is not `merged` and not `worktree_removed` (see D8).

### The parallel readiness predicate

All conjuncts must hold:

1. `route_id` is exactly `parallel`;
2. `parallel_slug` is a non-empty string;
3. `parallel_manifest_path` is a non-empty string;
4. `items` is present and non-empty;
5. the resolved target is present as a record in `items[]`;
6. that record's `merge_status` is not `merged` and not `worktree_removed` (see D8).

### Diagnosability — the deny reason

The deny reason must **name the checkpoint actually consulted** and **the predicate that failed**,
while preserving the `PREIMPLEMENTATION_GATE_BLOCKED:` prefix.

**Hard constraint the plan must honour:** the **default / single-feature** deny reason must continue
to contain both substrings `route metadata` and `lifecycle readiness`, because
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` asserts both and
must pass **unmodified**.

No existing test pins the literal path `artifacts/orchestration/orchestrator-state.json` inside a
reason string, so naming the actually-consulted checkpoint is free on the Claude surface provided
the two substrings above are retained in the default-mode wording.

### Files and functions impacted

**Modified (main hooks, both surfaces plus mirrors):**

- `Test-ImplementationDelegation` — replaced with the structural classifier above.
- New per-mode read seams for the epic and parallel checkpoints, alongside the existing
  `Get-CheckpointContent`.
- `Invoke-OrchestrationPreimplementationGateDecision` — gains two optional parameters (D2) and
  mode-aware dispatch and reason construction.
- A dot-source line for the new modes sibling.

**New (modes sibling, both surfaces plus mirrors) — pure, no I/O:**

- the mode table and canonical-path map,
- the implementation-agent allow-list,
- mode resolution from a prompt string,
- the target-token finder,
- the prompt-declared-path cross-check,
- the epic readiness predicate,
- the parallel readiness predicate.

**Not modified:** `Test-ImplementationPath`, `Test-ImplementationCommand`,
`Test-PreparationModeDelegation`, `Test-OrchestrationReady`, `Get-...AllowDecision`,
`Get-...BlockDecision`, `Invoke-...EntryPoint`, and the entire `-helpers.ps1` file on all four
copies.

### Backward compatibility

- The `PreToolUse` decision schema is unchanged: `hookEventName`, `permissionDecision`, and
  `permissionDecisionReason` only.
- No configuration key is added or changed.
- No checkpoint schema is changed; every predicate reads existing keys.
- The default / single-feature decision path is behaviourally unchanged for every input that reaches
  it, apart from the removal of the two free-text tokens (which is Fault 1's fix and is asserted
  explicitly as a new allow-to-deny change in test case 6b).

---

## Scope & Non-Goals

### In scope

- The `Agent`-matcher delegation leg of the preimplementation gate, on both the Claude and Codex
  surfaces and in both bundled mirrors.
- The epic and parallel readiness predicates and the mode dispatch table.
- Coverage registration and pack-manifest registration for the new production file.
- New Pester suites on both surfaces.

### Non-goals and prohibitions (all restated; each is binding)

- **Do not widen the seven-token regex as the fix.** Do not add `execution` or `executing` to any
  token list. Doing so re-blocks every epic without addressing Fault 2.
- The free-text tokens `implementation` and `execute` may remain **only** as a widening backstop
  that can **never narrow** a structural decision. A structural classification as implementation is
  never overturned by the absence of a free-text token.
- **Do not make prompt wording the discriminator in either direction.** Rewording a prompt must not
  change any decision.
- **Do not accept preparation-mode literals inside an execution prompt as an escape hatch.**
- **Do not change the Edit/Write path leg (`Test-ImplementationPath`)** or the **Bash command leg
  (`Test-ImplementationCommand`)**, including the issue #539 staging exemption.
- **Do not remove any checkpoint from the `$script:CheckpointPaths` WRITE exemption.**
- **Do not fail open** on an unreadable envelope or a missing checkpoint. Deny-by-default is
  preserved end to end.
- **Do not modify `.github/instructions/**` or `.github/copilot-instructions.md`.** Those are
  canonical policy sources this repository forbids modifying. If any part of the fix appears to
  require it, that is a **blocker to be raised, not a task to be performed**.
- **Do not modify any `.claude/skills/**` or `.claude/rules/**` file**, including the epic kickoff
  contract gap identified in D3.
- **Issue #555 is out of scope.**

---

## Test Strategy

### The amendment's ten-case matrix, as concrete Pester cases

| # | Case | Surface | Expected |
| --- | --- | --- | --- |
| 1 | Epic-mode delegation with a ready epic checkpoint injected via `-EpicCheckpointRaw` | Claude | allow |
| 2 | Epic-mode delegation with the epic checkpoint absent (empty injected content) | Claude | deny; reason names the epic checkpoint |
| 3 | Epic-mode delegation whose `features[]` lacks the target record | Claude | deny; reason names the failed predicate |
| 4 | Epic-mode delegation declaring an `epic_checkpoint_path` other than the canonical value | Claude | deny |
| 5 | `Epic mode: true` planted in a non-`prompt` field with a clean `prompt` | Claude | not epic mode; falls back to the single-feature source |
| 6a | `subagent_type` `atomic-executor`, prompt containing none of the seven tokens, unready single-feature checkpoint | Claude | deny |
| 6b | `subagent_type` `orchestrator`, no mode markers, prompt containing the words "atomic execution" but neither `execute` nor `implementation`, unready single-feature checkpoint | Claude | deny — **this is the case that incorrectly allows today** |
| 7 | Preparation-mode marker pair present | Claude | allow (exempt, unchanged) |
| 8 | Standalone orchestrator, ready single-feature checkpoint / unready single-feature checkpoint | Claude | allow / deny |
| 9 | All four pre-existing suites | both | pass **unmodified** |
| 10 | Codex surface | Codex | direct predicate parity tests **plus** the config assertion — see D5 |

Parallel-mode cases mirror rows 1 through 4 against
`artifacts/orchestration/parallel-orchestrator-state.json` via `-ParallelCheckpointRaw`.

### The Fault-1 wording-independence regression, in BOTH directions

- **Direction (a)** — structural deny survives wording: a payload whose `subagent_type` is an
  allow-listed implementation agent and whose prompt contains none of the seven tokens still denies
  against an unready checkpoint. This preserves an existing deny.
- **Direction (b)** — **a NEW allow-to-deny change, which must be asserted explicitly.** A payload
  whose `subagent_type` is `orchestrator` with no mode markers and a prompt phrased with "atomic
  execution" (containing neither `execute` nor `implementation`) is **allowed today** and must
  **deny** after the fix. This is a behaviour change, not a preservation, and the acceptance
  criteria name it as such.

### Constraints on the test work

- **New Claude-side cases go in a NEW sibling suite.**
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` is at **461 of
  500 lines** and **must not grow**. The new suite is
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`.
- **No existing test file may be edited.** All four pre-existing suites must pass **unmodified**.
  That is the proof obligation for the "Edit/Write and Bash legs unchanged" guardrail:

  1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`
  2. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
  3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`
  4. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`

- **Determinism:** literal string fixtures only. No temporary files (prohibited by
  `.claude/rules/general-unit-test.md`), no filesystem access, no wall clock, no network, no
  external process.

  **One sanctioned exception, and only one.** The Codex transport-gap assertion (decision D5,
  deliverable ii) must read the tracked repository file `.codex/config.toml`, because the fact it
  records is a property of that file and cannot be expressed any other way. That single read is
  permitted. It is not a temporary file, its content is committed and therefore fixed for a given
  checkout, and it must be resolved through a `$PSScriptRoot`-relative `Resolve-Path` so the test
  introduces no working-directory assumption. The substantive prohibitions — temporary files, wall
  clock, network, external process — remain intact, and no other test may read from disk.

### Two hard invariants that keep five pre-existing cases passing

Research G2 identified five pre-existing cases in
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (at lines 356,
365, 374, 383, and 392) that survive the refactor only under the following two conditions. Both are
**hard invariants of this design**, not incidental consequences:

1. **An unmarked `subagent_type` of `orchestrator` must still classify as implementation**, and must
   be evaluated against the default single-feature checkpoint. If an unmarked orchestrator
   delegation were treated as out of scope, four of those five cases would flip from deny to allow
   and fail.
2. **The implementation-agent allow-list must retain `atomic-executor` and the four typed-engineer
   names** (`python-typed-engineer`, `powershell-typed-engineer`, `typescript-engineer`,
   `csharp-typed-engineer`). The case at line 356 supplies `atomic-executor` and asserts deny; the
   suite's default delegation factory supplies `powershell-typed-engineer`.

### Coverage

Any **new** production `.ps1` file must be appended to `CodeCoverage.Path` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` **and** to its bundled mirror at
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. That list is
an explicit per-file allow-list with no directory wildcard for either hooks tree. A new production
file that is not appended sits **outside the coverage denominator**, which the Coverage Exclusion
Policy in `.claude/rules/general-unit-test.md` forbids and which feature-review must treat as
**Blocking**. The two settings files are pinned to exact text parity by a Python parity test, so they
must be updated identically.

Line coverage must remain at or above 85% per `.claude/rules/quality-tiers.md`. Pester does not
measure branch coverage, so no branch-coverage gate applies to this change.

### Toolchain — operational notes

Run in order: format, analyze, test. Restart from format if any stage changes a file.

**Operational note carried forward as a known condition:** the MCP PoshQC test runner reads its
settings from the **installed extension**, so newly added `CodeCoverage.Path` entries are **ignored
by it**. Verifying that the new entries take effect requires invoking the self-hosted module
directly:

```powershell
Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

### Mirror byte-identity must be verified by hash, not by inspection

Each mirrored pair's byte-identity must be verified with **SHA-256** via `Get-FileHash`, and the four
resulting pair hashes recorded in a qa-gates evidence artifact.

Inspection and line-count comparison are **not sufficient**. The repository's own Python parity tests
**cannot observe a line-ending difference**, because they compare `read_text()` results under
Python's universal-newline translation, which normalizes carriage-return/line-feed pairs before
comparison. A hash is the only check in this repository that observes a trailing-byte or
line-ending divergence.

### Known pre-existing local failure — not a regression

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
fails locally for an unrelated reason tracked as **open issue #510** (gitignored `.claude/state`
counter files enumerated by the whole-tree comparison). CI is unaffected. This is recorded here so a
local failure of that test during this feature is **not misread as a regression introduced by this
change**. Deleting the state file is not a durable fix and must not be attempted as one.

---

## Assumptions, Constraints, Dependencies

- **Assumption:** the epic and parallel orchestrator checkpoints are written by their respective
  orchestrate skills with the keys those skills document. D7 records the one place where this
  assumption is stricter than the Python validator, and why it is acceptable.
- **Constraint:** 500-line file cap on every `.ps1` file (`.claude/rules/general-code-change.md`).
  Current headroom: main hooks 118 lines each; existing helpers 151 lines; main Claude test suite 39
  lines.
- **Constraint:** PowerShell change budget (D6).
- **Constraint:** PowerShell 7+ compatibility, enforced by PSScriptAnalyzer settings.
- **Dependency:** none external. No new library, no new configuration key.

## Data / API / Config Impact

- **User-facing or API changes:** none. The hook's decision JSON schema is unchanged.
- **Data or migration considerations:** none. No checkpoint is written or migrated by this change.
- **Logging/telemetry:** the deny reason string becomes mode-specific. The
  `PREIMPLEMENTATION_GATE_BLOCKED:` prefix is preserved so downstream reason-matching is unaffected.
- **Configuration:** two `CodeCoverage.Path` entries and two pack-manifest entries are added. No
  behavioural configuration key changes.

## Risks & Mitigations

| Risk | Mitigation |
| --- | --- |
| The `epic_manifest_path` requirement (D7) denies a real, otherwise-ready epic checkpoint written without that key. | The producing skill contract mandates the key. The deny reason names the failed predicate, so the missing key is immediately visible, and writing the checkpoint is itself exempt from the gate via the `$script:CheckpointPaths` WRITE exemption. Residual risk accepted and recorded. |
| The epic target-token requirement (D3) denies a wave-0 child whose kickoff prompt carries no feature-folder token. | Zero marginal exposure: `enforce-epic-wave-barrier.ps1` already denies that exact case on the same matcher. The underlying contract gap is recommended for a separate issue. |
| A mirror diverges from its source by a trailing byte or line ending that the Python parity tests cannot see. | SHA-256 verification of all four pairs, recorded as a qa-gates evidence artifact. |
| The new production file is omitted from `CodeCoverage.Path` and silently leaves the coverage denominator. | Explicit acceptance criterion, plus the self-hosted verification command that bypasses the installed-extension settings issue. |
| The Codex-side trimming field reader diverges from the Claude-side reader. | Every new predicate is a containment test insensitive to surrounding whitespace; the plan is forbidden from introducing any predicate whose outcome depends on untrimmed edges. |

## Rollout & Follow-up

- Merge to `main`, then push down to consumer repositories so downstream repositories pick up the
  fixed hook.
- Post-merge follow-up issues to file (**not** performed in this feature):
  1. The epic kickoff contract gap from D3 — mandate the child's own `docs/features/active`
     basename token, or an issue-number key, in the epic child kickoff prompt.
  2. Optionally, extraction of a shared mode-resolution module used by all seven mode-aware hooks.
     This is a refactor, not a bug fix, and must not be bundled here.
- Issue #555 remains open and separate.

---

## DECLARED BLAST RADIUS

### Production — modified

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`

### Production — new

- `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`

### Configuration and manifests

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`

### Tests — new

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`

### Feature documents and evidence

- `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`
- `docs/features/active/preimplementation-gate-blocks-epic-execution-554/issue.md`
- `docs/features/active/preimplementation-gate-blocks-epic-execution-554/plan.2026-08-26T08-40.md`
- `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/baseline/`
- `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/`
- `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/regression-testing/`
- `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/issue-updates/`
- `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/other/`

The five `evidence/` entries are directory prefixes, not files; the concrete artifact filenames are
timestamp-bearing and are fixed by the plan. They are recorded at directory granularity because the
feature folder is unique to this item and therefore cannot contend with any other item.

Four statements about this list, made explicitly because a parent process computes conflict edges
from it and an under-declaration is a correctness failure:

**(a)** `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its three
sibling copies — the `.codex` copy and the two `extensions/drm-copilot/resources/` mirrors — are
**deliberately NOT in this radius**. Leaving them byte-untouched is the proof that the issue #539
orchestration-bookkeeping staging exemption is behaviourally unchanged. This is the direct
consequence of decision D1.

**(b)** **No file under `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, and no
`.github/copilot-instructions.md`, is written by this feature.** The epic kickoff contract gap
identified in D3 is recommended for a separate issue and is not closed here.

**(c)** Under `extensions/drm-copilot/resources/` **exactly seven concrete files** are written, and
they are the seven enumerated above:

1. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
2. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
5. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
6. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
7. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`

**No directory-level claim is made anywhere under `extensions/drm-copilot/resources/`.** Four of the
seven are byte-copy mirrors of reviewed source files (entries 1 through 4), one is a text-parity
mirror pinned by a Python test (entry 5), and two are registration manifests (entries 6 and 7).

**(d)** The orchestration checkpoint `artifacts/orchestration/orchestrator-state.json` is written
during this work but is **deliberately excluded** from the declared radius. The repository
`.gitignore` ignores the whole `/artifacts` tree, so the file never appears in a diff and can never
produce a real conflict with another item's diff. Every orchestrated item writes it, so declaring it
would manufacture a `path_overlap` edge against every concurrently prepared item on a file that is
per-worktree state rather than shared repository content. Excluding it is not an under-declaration:
the exclusion is confined to a gitignored path, and `detect_escaped_paths` compares the declared
radius against the paths a diff actually touched, so a genuine write to a tracked path remains
observable.

---

## Acceptance Criteria

This section is the **sole** authoritative acceptance-criteria source for this feature (work mode
`full-bug`). Items 1 through 4 are the amendment's four criteria, restated verbatim.

- [ ] **(Amendment 1, verbatim)** An epic-child `Agent(orchestrator)` delegation per the epic-orchestrate kickoff contract is allowed when, and only when, the epic checkpoint proves the epic prepared and the target feature is a real, not-yet-merged record in it.
- [ ] **(Amendment 2, verbatim)** Reordering or rewording an execution prompt cannot change the gate's decision, in either direction, for any case in the test matrix.
- [ ] **(Amendment 3, verbatim)** A denied delegation's reason names the checkpoint actually consulted and the failed predicate.
- [ ] **(Amendment 4, verbatim)** Standalone orchestration, planner-surface writes, and the #539 staging exemption are behaviorally unchanged.
- [ ] Matrix case 1: a Pester test in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` asserts that an epic-mode delegation with a ready epic checkpoint injected through `-EpicCheckpointRaw` yields an allow decision, and it passes.
- [ ] Matrix case 2: a Pester test asserts that an epic-mode delegation with empty injected epic-checkpoint content yields a deny decision whose reason names the epic checkpoint file, and it passes.
- [ ] Matrix case 3: a Pester test asserts that an epic-mode delegation whose injected epic checkpoint has a features array not containing the target record yields a deny decision, and it passes.
- [ ] Matrix case 4: a Pester test asserts that an epic-mode delegation declaring a non-canonical epic checkpoint path in its prompt yields a deny decision, and it passes.
- [ ] Matrix case 5: a Pester test asserts that an epic-mode marker placed in a non-prompt field, with a clean prompt, resolves to the default single-feature mode rather than epic mode, and it passes.
- [ ] Matrix case 6a: a Pester test asserts that a delegation whose subagent type is an allow-listed implementation agent, with a prompt containing none of the seven legacy tokens and an unready single-feature checkpoint, yields a deny decision, and it passes.
- [ ] Matrix case 6b (**new allow-to-deny behaviour change, asserted explicitly**): a Pester test asserts that a delegation whose subagent type is `orchestrator`, with no mode markers and a prompt phrased with the words "atomic execution" but containing neither of the two legacy free-text tokens, and an unready single-feature checkpoint, yields a **deny** decision, and it passes.
- [ ] Matrix case 7: a Pester test asserts that a delegation carrying both preparation-mode markers in its prompt yields an allow decision, and it passes.
- [ ] Matrix case 8: two Pester tests assert that a standalone orchestrator delegation yields allow against a ready single-feature checkpoint and deny against an unready one, and both pass.
- [ ] Parallel readiness, positive: a Pester test asserts that a parallel-mode delegation with a ready parallel checkpoint injected through `-ParallelCheckpointRaw` yields an allow decision, and it passes.
- [ ] Parallel readiness, negative: a Pester test asserts that a parallel-mode delegation whose injected parallel checkpoint has an items array not containing the target record yields a deny decision naming the parallel checkpoint file, and it passes.
- [ ] Parallel canonical-path cross-check: a Pester test asserts that a parallel-mode delegation declaring a non-canonical parallel checkpoint path in its prompt yields a deny decision, and it passes.
- [ ] Epic target unresolvable: a Pester test asserts that an epic-mode delegation whose prompt contains no resolvable target token and no issue number yields a deny decision, and it passes.
- [ ] Merge-status hardening (decision D8): a Pester test asserts that an epic-mode delegation whose target record carries a terminal-merged merge status yields a deny decision, and a companion test asserts that a target record carrying a failure merge status yields an allow decision; both pass.
- [ ] Codex logic parity (decision D5, deliverable i): Pester tests in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` dot-source the Codex copy and assert the mode-resolution function and both readiness predicates return the same outcomes as the Claude-side tests for the same constructed inputs, and they pass.
- [ ] Codex transport gap recorded (decision D5, deliverable ii): a Pester test reads `.codex/config.toml` and asserts that no PreToolUse matcher admits an Agent or Task tool name, cross-referencing issue #555, and it passes.
- [ ] All four pre-existing Pester suites pass **unmodified**, verified by their absence from the branch diff: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`, and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`.
- [ ] `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` passes unmodified, confirming the block-decision function's single mandatory reason parameter is preserved.
- [ ] The four helpers-file copies are byte-identical to their state at the branch point, verified by their absence from `git diff --name-only` against the merge base.
- [ ] Each of the four mirrored production pairs is SHA-256 byte-identical per surface, verified with `Get-FileHash`, and the four pair hashes are recorded in an artifact under `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/`.
- [ ] `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` each list both new production hook files in `CodeCoverage.Path`, and the PoshQC bundled-parity Python test passes.
- [ ] The two pack manifests each list the new modes hook for their surface, and the push-down pack-manifest completeness Python tests pass.
- [ ] The new production hook files appear in the Pester coverage report produced by the self-hosted invocation `Invoke-PoshQCTest` against the repository settings file, confirming the new `CodeCoverage.Path` entries take effect.
- [ ] Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either modified hook loses coverage.
- [ ] No file whose path begins with `.claude/rules/`, `.claude/skills/`, or `.github/` appears in `git diff --name-only` against the merge base.
- [ ] Deny-by-default is preserved with no new permissive path: Pester tests assert deny for an unparseable payload, for a payload with no tool input key, and for a mode-resolved delegation whose injected checkpoint content is empty, and all pass.
- [ ] Every file written by the branch appears in the `## DECLARED BLAST RADIUS` section of this document, verified by comparing `git diff --name-only` against the merge base with the declared list.
- [ ] The full PowerShell toolchain passes in a single pass: format, then analyze with zero findings, then Pester with coverage.
- [ ] The plan document records the batch sequencing required by decision D6 and states explicitly that each `extensions/drm-copilot/resources/` file is treated as a mechanical byte-copy of an already-reviewed source rather than an independent production edit.
- [ ] Every production `.ps1` file written by this change is at or under 500 lines, verified by line count.
- [ ] A follow-up record for the epic kickoff contract gap described in decision D3 is written under `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/other/`, stating the gap, the recommended contract amendment, and the reason it is out of scope here. Filing the GitHub issue itself is a maintainer action outside this branch: `gh issue create` is denied by a PreToolUse hook, and the sanctioned MCP promotion path writes files under `docs/features/potential/` that are deliberately not in the declared blast radius, so filing it from this branch would make the undeclared-path check fail. This criterion is satisfied by the evidence record; the issue number is appended later if and when one exists.

**Total acceptance-criteria items: 35.** All are unchecked at authoring time. Items are checked off
only under the protocol in `.claude/skills/acceptance-criteria-tracking/SKILL.md`, one at a time,
after the corresponding work is implemented and verified.

---

## Appendix — Amendment Comment (verbatim)

Reproduced exactly from the read-only evidence mirror at
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/issue-updates/issue-554.2026-08-26T12-00.md`,
which in turn reproduces
<https://github.com/drmoisan/drm-copilot/issues/554#issuecomment-5425395081>.

> Amendment (2026-08-26, from the maintainer's expanded work request). This issue as originally filed covers only Fault 2. The full defect is two composing faults, and one statement in the original Expected Behavior is corrected below. This change is the structural fix to the gate's decision procedure — the third defect in this hook after #535 and #539, which were both point patches to exemption lists; a fourth list entry is explicitly not the remedy.
>
> ## Fault 1 (previously unrecorded) — the delegation classifier is a 7-token substring match over the serialized payload
>
> `Test-ImplementationDelegation` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:182-204`) exempts preparation mode and then falls through to:
>
> ```powershell
> $payloadText = ($ToolInput | ConvertTo-Json -Depth 20 -Compress)
> return $payloadText -match '(python-typed-engineer|powershell-typed-engineer|typescript-engineer|csharp-typed-engineer|atomic-executor|implementation|execute)'
> ```
>
> Classification therefore depends on prompt wording. `"execution"` does not contain the bare token `execute`; a kickoff phrased with "atomic execution" matches none of the seven tokens and is allowed, while a semantically identical prompt phrased with "execute" is denied.
>
> **Measured evidence (TaskMaster, `quickfiler-bug-family` epic):** four `Agent(orchestrator)` epic-child delegations were denied verbatim on 2026-08-25; four structurally identical delegations were allowed on 2026-08-26 and wave 0 launched. The hook file was byte-identical on both dates; kickoff wording was the only difference. The pass was an incidental classifier miss, disclosed rather than relied on. No prompt was reworded to dodge the classifier, and the fix must not make rewording the remedy. This evidence is the regression case for Fault 1 (test matrix case 6b below).
>
> ## Correction to the original Expected Behavior — the caller must not name its own readiness file
>
> The original body asks that readiness be evaluated "against the epic checkpoint the prompt itself names." That is retracted as a gate weakness. Corrected requirement: resolve the readiness source from the recognized mode marker via a fixed table, never from a path parsed out of the prompt. If the prompt-declared `epic_checkpoint_path` / `parallel_checkpoint_path` disagrees with the mode's canonical path, deny.
>
> ## Required fix (structural, both faults)
>
> 1. **Classify `Agent` delegations by structure, not substring.** `subagent_type` in the implementation-worker set (`atomic-executor`, the four typed engineers) is implementation regardless of prompt wording, read field-scoped via `Get-ClaudeHookToolInputString`. `subagent_type == 'orchestrator'` is implementation unless the field-scoped `prompt` carries a recognized non-implementation mode marker. Free-text tokens `implementation`/`execute` may remain only as a widening backstop that can never narrow a structural decision. Do not add `execution`/`executing` to the token list — that re-blocks every epic without fixing Fault 2.
> 2. **Polymorphic readiness source keyed on existing contract markers** (reuse verbatim, do not invent):
>    - Preparation (`Preparation mode: true.` + `route_id: preparation.`, emitted by epic-plan SKILL.md:99 / parallel-plan SKILL.md:105) — exempt, unchanged.
>    - Epic child (`Epic mode: true`, epic-orchestrate SKILL.md:118) — `artifacts/orchestration/epic-orchestrator-state.json`.
>    - Parallel item (`Parallel mode: true`, parallel-orchestrate SKILL.md:244) — `artifacts/orchestration/parallel-orchestrator-state.json`.
>    - No marker — `artifacts/orchestration/orchestrator-state.json`, unchanged.
>    Markers are read from the named `prompt` field only, never the serialized payload — the property `Test-PreparationModeDelegation` already documents at lines 147-180. Precedent: `.claude/hooks/enforce-epic-wave-barrier.ps1` implements exactly this shape on the same `Agent` matcher; reuse its resolution approach so the two hooks agree.
> 3. **Epic readiness predicate** (new helper): `route_id == 'epic'`; `epic_feature_folder` non-empty; `epic_manifest_path` non-empty under `docs/features/epics/`; `integration_branch` non-empty; `features[]` present and non-empty; the target feature (resolved from the prompt by `feature_folder` or `issue_num`) exists as a record in `features[]`. Optional hardening, state in the PR whether included: require the target record's `merge_status` in a pre-merge state.
> 4. **Parallel readiness predicate**: mirror against `parallel-orchestrator-state.json` (`route_id == 'parallel'`, `parallel_slug`, `parallel_manifest_path`, non-empty items, target item resolvable). If scoped to epic mode only, say so explicitly and record the parallel gap as a follow-up issue.
> 5. **Diagnosability**: the block reason (line 328) is a fixed string naming `orchestrator-state.json` regardless of the source consulted. Make it name the checkpoint actually read and the predicate that failed.
> 6. **File-size cap**: the hook is 381 lines against the 500-line cap; put mode resolution and the new predicates in the existing dot-sourced helpers sibling.
>
> ## Non-goals and prohibitions
>
> - Do not widen the seven-token regex as the fix; do not make prompt wording the discriminator in either direction.
> - Do not accept preparation-mode literals inside an execution prompt as an escape hatch.
> - Do not change the Edit/Write path leg (`Test-ImplementationPath`) or the Bash command leg (`Test-ImplementationCommand`), including the #539 staging exemption.
> - Do not remove any checkpoint from the `$script:CheckpointPaths` WRITE exemption.
> - Do not fail open on an unreadable envelope or missing checkpoint — deny-by-default is preserved.
>
> ## Scope and propagation
>
> Only the `Agent`-matcher leg changes; Edit/Write and Bash legs are behaviorally unchanged, proved by the pre-existing suites passing unmodified. Propagate to all copies: `.claude/hooks/...` and `.codex/hooks/...` (both main and helpers), plus their `extensions/drm-copilot/resources/claude-customizations/` and `codex-and-agents-customizations/` mirrors, keeping each pair byte-identical per surface. After merge, push down to consumer repositories so TaskMaster picks up the fixed hook. Note per #555: `.codex/config.toml` registers no `Agent` matcher, so the epic denial does not manifest on Codex; #555's single-surface readiness for the file/command legs remains a separate issue and is not in scope here.
>
> ## Required test coverage (Pester, both surfaces, added to the existing suites)
>
> 1. Epic-mode delegation with ready epic checkpoint — allow.
> 2. Same with epic checkpoint absent — deny; reason names the epic checkpoint.
> 3. Same with `features[]` lacking the target record — deny.
> 4. Same with a prompt-declared `epic_checkpoint_path` other than canonical — deny.
> 5. `Epic mode: true` planted in a non-`prompt` field, prompt clean — not epic mode; falls back to singular source.
> 6. Wording-independence regression, both directions: (a) `subagent_type: atomic-executor`, prompt with none of the seven tokens, unready checkpoint — deny; (b) `subagent_type: orchestrator`, no markers, prompt containing "atomic execution"/"execution" but not "execute"/"implementation", unready singular checkpoint — deny (the case that incorrectly allows today).
> 7. Preparation-mode pair still exempt — allow.
> 8. Standalone orchestrator with ready singular checkpoint — allow; unready — deny.
> 9. Existing Edit/Write, Bash, absolute-path, and command-exemption suites pass unmodified on both surfaces.
> 10. Codex surface: the same matrix through the `apply_patch` transport.
>
> ## Acceptance criteria
>
> - An epic-child `Agent(orchestrator)` delegation per the epic-orchestrate kickoff contract is allowed when, and only when, the epic checkpoint proves the epic prepared and the target feature is a real, not-yet-merged record in it.
> - Reordering or rewording an execution prompt cannot change the gate's decision, in either direction, for any case in the test matrix.
> - A denied delegation's reason names the checkpoint actually consulted and the failed predicate.
> - Standalone orchestration, planner-surface writes, and the #539 staging exemption are behaviorally unchanged.

### Two points where this spec deviates from the amendment's letter, deliberately

Both are recorded here rather than silently applied:

1. **Required-fix item 6** instructs that the new logic go in *"the existing dot-sourced helpers
   sibling"*. This spec places it in a **new** sibling instead, for the two reasons given in
   decision **D1** (declared-contract contradiction and line budget). The amendment's underlying
   intent — keep the main hook inside the 500-line cap by dot-sourcing — is satisfied, and the
   change additionally preserves the byte-identity proof for the issue #539 exemption.
2. **Test coverage item 10** asks for the matrix *"through the `apply_patch` transport"* on the
   Codex surface. That transport cannot carry an `Agent` delegation. Decision **D5** substitutes
   direct predicate-parity tests plus a tested record of the transport gap, and explicitly prohibits
   fabricating an `Agent` envelope on that surface.
