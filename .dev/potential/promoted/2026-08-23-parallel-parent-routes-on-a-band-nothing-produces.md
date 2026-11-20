# parallel-parent-routes-on-a-band-nothing-produces (Issue #532)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-parent-routes-on-a-band-nothing-produces/ (Issue #532)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #532
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/532
- Last Updated: 2026-08-23
## Summary

`parallel-orchestrate/SKILL.md` requires `parallel-orchestrator` to pass a `model` equal to a
routing receipt's model when it spawns each item's `Agent(orchestrator)`, and explicitly forbids
omitting `model`. Nothing on the parallel surface produces the band that receipt would be resolved
from: the parallel planner has no complexity-assessment step, `complexity_band` is an optional
per-item key, and neither parallel checkpoint validator enforces any model-routing invariant. The
parent is therefore instructed to route on an input that no stage supplies, and the documented
failure mode — silent fallback to the delegate's `opus` frontmatter default — is the outcome.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (contract and validator defect; no runtime execution required)
- Command/flags used: not applicable — established by reading the skills, agents, and validators
- Data source or fixture: `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`, `scripts/dev_tools/validate_parallel_planner_state.py`, `scripts/dev_tools/validate_parallel_orchestrator_state.py`

## Steps to Reproduce

1. Read `.claude/skills/parallel-orchestrate/SKILL.md` lines 292-299. The parent MUST pass `model`
   equal to the routing receipt's model on each `Agent(orchestrator)` spawn, MUST NOT omit it, and
   MUST NOT hard-code `opus`.
2. Search `.claude/skills/parallel-plan/SKILL.md` for a complexity-assessment procedure. There is
   none; `complexity_band` appears only in the checkpoint field list (line 412) and as a
   `parallel-status.md` column (lines 493, 515).
3. Inspect `REQUIRED_ITEM_KEYS` in `scripts/dev_tools/validate_parallel_planner_state.py` lines
   79-84. Neither `complexity_band` nor `model_routing_receipt` is present, though
   `parallel-plan/SKILL.md` line 414 documents both as per-item fields.
4. Grep both parallel checkpoint validators for `model_routing_receipts`, `complexity_assessments`,
   and `complexity_band`. `validate_parallel_orchestrator_state.py` and its three helper modules
   return no match at all.
5. Compare with the epic surface: `validate_epic_planner_state.py` lines 52 and 155 make
   `complexity_band` a required per-feature key, and line 260 cross-checks it against that
   feature's `model_routing_receipt.complexity_band`.

## Expected Behavior

The band a parent routes on is determined before the parent spawns the child, because the spawn
model must be chosen before the child exists. The parallel planner — which has already driven
research, spec, atomic plan, and preflight clearance for every item — assesses each item's band,
records it with a rationale and a matching `model_routing_receipt`, and the planner-checkpoint
validator enforces both as required keys with the band-matches-receipt cross-check the epic surface
already applies.

## Actual Behavior

No stage on the parallel surface produces a band for the parent's own delegation.

- `parallel-plan/SKILL.md` has no `## Complexity Assessment` section. The epic counterpart
  (`epic-plan/SKILL.md` lines 69-75) does.
- `complexity_band` is optional and presence-gated in the parallel planner checkpoint
  (`validate_parallel_planner_state.py` lines 237-243), with the source comment recording absence
  as "the backward-compatible shape".
- `model_routing_receipt` is documented at `parallel-plan/SKILL.md` line 414 but is absent from
  `REQUIRED_ITEM_KEYS`, so nothing requires or checks it.
- The parallel orchestrator checkpoint records no routing state whatsoever. The invariant
  enumeration in `.claude/rules/parallel-orchestration.md` names `delegation_receipts`,
  `skill_receipts`, and `mcp_call_receipts` (invariant 19) and no routing or complexity array, and
  the validator sources confirm it.

The shared routing validator `validate_codex_model_routing_receipts` is wired into
`validate_orchestrator_state.py`, `validate_epic_planner_state.py`, and
`validate_epic_orchestrator_state.py`. It is wired into neither parallel validator.

Only the child-side decision is intact: the child reads the `model_budget.fable_policy` marker and
assesses its own band for its own sub-delegations. That governs `atomic-planner`, `atomic-executor`,
and `feature-review` — not the parent's choice of model for the child itself.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `grep -rn "model_routing_receipts\|complexity_assessments\|complexity_band"` over
  `validate_parallel_orchestrator_state.py`, `_parallel_state_common.py`,
  `_parallel_state_structures.py`, and `_parallel_state_records.py` returns no matches.
  `grep -rln "validate_codex_model_routing_receipts" scripts/dev_tools/` returns
  `_orchestrator_state_codex_model_routing.py`, `validate_epic_orchestrator_state.py`,
  `validate_epic_planner_state.py`, and `validate_orchestrator_state.py` — no parallel module.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. No gate fails and no shipped code is incorrect: an unrouted delegation still runs, just on
the frontmatter default. The damage is that a documented control does not work. Because the
fallback is `opus` for these workers, and the skill states that an omitted `model` "suppresses a
`fable` resolution", `model_budget.fable_policy: preferred` is a no-op on the parallel surface —
the operator sets a budget policy and the surface silently ignores it. This is the same shape as
the verification-gate defects filed previously: an instruction that reads as enforced, is not, and
whose non-enforcement is invisible because the fallback succeeds.

It is not High because the failure direction is toward the more capable model, so output quality is
not degraded; the cost is budget and the credibility of the routing contract. It is not Low because
the parallel surface is the one built to run many items concurrently, which is precisely where a
per-delegation model budget is worth the most.

## Suspected Cause / Notes

Incomplete port of the epic surface. `parallel-plan/SKILL.md` line 414 already lists
`model_routing_receipt` among the per-item fields, and the status-doc contract already reserves a
`complexity` column with a `C1`-`C4` enum (lines 515-516), so the intent to carry the epic
mechanism across was present. The derivation procedure and the validator requirements were not
carried with it, and the parallel planner-state validator encodes the optionality as intentional
backward compatibility, which is how the gap survived review.

Two adjacent facts for whoever picks this up:

- `.claude/rules/parallel-orchestration.md` deliberately omits an `epic_worthiness` analogue, and
  `parallel-plan/SKILL.md` lines 418-420 record that omission. That is a separate and correct
  decision about a scale gate. It should not be read as also settling the per-item band question —
  the band is a routing input, not a worthiness verdict, and the two appear to have been conflated.
- The floor half of a band is mechanically checkable. `compute_complexity_floor` is a pure function
  over `signals_present`, so a validator can enforce floor equality exactly as
  `.claude/rules/orchestrator-state.md` already specifies for the standard checkpoint. Only the
  judgment portion is unverifiable.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: promote `complexity_band` and `model_routing_receipt` to
  `REQUIRED_ITEM_KEYS` in `validate_parallel_planner_state.py`, and add the band-matches-receipt
  cross-check modelled on `validate_epic_planner_state.py` line 260. Each new assertion must be
  shown to fail against a checkpoint that omits the keys before the fix lands, otherwise it asserts
  nothing.
- [x] Integration scenario to retest: a planner checkpoint carrying a band whose `floor` disagrees
  with `compute_complexity_floor(signals_present)` must be rejected, reusing the existing reference
  implementation rather than reimplementing the floor.
- [x] Add a `## Complexity Assessment` section to `parallel-plan/SKILL.md` mirroring
  `epic-plan/SKILL.md` lines 69-75, assessing each item after its atomic plan lands — the point of
  maximum information, since the plan's phase, task, and file counts are the strongest available
  signal and the blast radius is already computed by then.
- [x] Manual verification notes: state in `parallel-orchestrate/SKILL.md` that the parent reads the
  band from the planner checkpoint for its own spawn decision. The obligation is currently stated
  with no named source, which is the root of the defect.
- [ ] Consider whether `/parallel-add` needs the same treatment. It runs its own preparation-mode
  child orchestrator, so the assessment point exists there too; an admitted item otherwise reaches
  the parent with no band by the same route.
- [ ] Consider whether a planning-time band should be re-assessed when an item's plan is later
  amended, or whether staleness is acceptable given the failure direction is toward `opus`.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
