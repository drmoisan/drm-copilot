# Frozen Implementation Constants — Issue #440 (F7)

Timestamp: 2026-08-08T21-09

Task: [P0-T11]

Source of record: `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/other/upstream-contract-verification.2026-08-08T21-09.md`

## Halt-Gate Evaluation

Evaluated all sixteen Upstream Contract Assumption rows recorded by [P0-T9] and [P0-T10].

| Metric | Value |
| --- | --- |
| Rows evaluated | 16 (U1-U16) |
| PASS | 16 |
| FAIL | 0 |

**Halt gate result: NOT TRIGGERED. Execution may proceed to Phase 1.**

No `HALT: re-planning required` artifact was written, because no assumption failed. Per plan Binding Constraint 10, a failing row would have halted execution rather than being worked around; that branch did not apply.

Three rows carry recorded qualifications. None is a failure: in each case the observed contract is narrower than the assumption's strongest possible reading, and in each case the plan already contains the branch that handles the narrower reading (P3-T1's degradation branch, P4-T4's reserved-name precedence, P4-T3's two-way branch). The qualifications are frozen below as implementation constants rather than deferred.

---

## Frozen Constant 1 — U9 Lifecycle Timestamp Field Names (consumed by P3-T1)

| Role | Frozen field name |
| --- | --- |
| Item start marker | `worktree_created_at` |
| Merge confirmation | `merged_at` |

**Provenance:** `.claude/rules/parallel-orchestration.md` Cache Doctrine, and the items projection table header of `docs/features/templates/parallel/parallel-status.md` (line 39), which names the columns `worktree_created_at | merged_at | worktree_removed_at`. Both sources spell the names identically.

**Mandatory degradation rule (frozen).** F3 neither requires nor validates either field: `REQUIRED_KEYS` in `scripts/dev_tools/validate_parallel_orchestrator_state.py` contains no timestamp field, and `validate_item_record` in `scripts/dev_tools/_parallel_state_common.py` checks no per-item timestamp. A schema-valid checkpoint may therefore legitimately omit both. Consequently:

- P3-T1 sets these two names as module constants in `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`.
- The temporal reading of the invariant applies the timestamp-ordering comparison **only when both timestamps are present as strings**. Whenever either is absent, is not a string, or is null, the check **degrades to structural-plus-status** and must not infer, default, or synthesize a timestamp value.
- The status-based temporal reading (`b` has started — non-null start timestamp **or** `merge_status` past `not_started` — while `a.merge_status` is not in `{merged, worktree_removed}`) remains available when timestamps are absent, because it keys on the `merge_status` enum, which F3 does validate.

**Explicitly frozen negative:** there is no F3-guaranteed `in_flight_at` and no F3-guaranteed `started_at`. A repository-wide search of `.claude/` found no parallel-surface occurrence of `in_flight_at`; `started_at` appears only in F3's own research document for issue #444 as an optional unvalidated field, which is not a shipped contract. No Phase 3 implementation may reference either name.

**Verdict recorded for the plan's either/or:** the field names ARE resolved (so the names branch applies), AND the degradation branch is simultaneously mandatory because the fields are optional. Both are frozen; they are not alternatives here.

## Frozen Constant 2 — U14 `SKILL.md` Section Name (consumed by P4-T4)

```
## Enforcement Hooks (F7)
```

**Provenance:** `.claude/skills/parallel-orchestrate/SKILL.md` line 439, a reserved placeholder F5 authored, whose body at line 441 reads: `Reserved for F7; content is appended by that feature and must not be relocated.`

**Frozen decision.** F5's reserved name supersedes the plan's fallback name `## Cohort Barrier Enforcement (F7)`, per plan Binding Constraint 2 ("if the Phase 0 check (assumption U14) finds that F5 reserved a named placeholder section for F7, that reserved name is used verbatim instead"). P4-T4 therefore:

- writes its content under the existing `## Enforcement Hooks (F7)` heading at line 439,
- does NOT create a new section and does NOT introduce the heading `## Cohort Barrier Enforcement (F7)`,
- does NOT rename, reflow, or relocate the heading (the placeholder body explicitly forbids relocation),
- does NOT touch the sibling reserved placeholders `## Mutation Protocol (F6)` (line 435) or `## Radius Drift Detection (F8)` (line 443), which belong to the concurrently-executing F6 and F8,
- does NOT edit the pre-existing F5-authored F7 description at lines 130-145 of `## Cohort Barrier and Max-Concurrency Slot Filling`, which already names both layers, the `PARALLEL_COHORT_BARRIER_BLOCKED` deny reason, the `PARALLEL_COHORT_BARRIER_VIOLATION` invariant, and the per-call-visibility rationale.

The P4-T4 acceptance criterion "`git diff` of the file shows only the one appended section" is satisfied by replacing the placeholder body line under the reserved heading with the feature's content; the heading line itself is unchanged.

## Frozen Constant 3 — U16 `SubagentStop` Registration Decision (consumed by P4-T3)

**Decision: ADD the matcher. The authorized skip branch does NOT apply.**

**Provenance:** a search of `.claude/settings.json` for `parallel-orchestrator` and `parallel-planner` returned no match anywhere in the file. The `SubagentStop` array (lines 191-250) contains six matcher blocks — the multi-persona alternation, `feature-review`, `atomic-planner`, `pr-author`, `orchestrator`, and `epic-orchestrator` — and none names a parallel persona.

P4-T3 must add a `SubagentStop` matcher `parallel-orchestrator` whose single hook command is:

```
pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state
```

modeled on the parameterized `epic-orchestrator` block at `.claude/settings.json` lines 241-249:

```json
{
  "matcher": "epic-orchestrator",
  "hooks": [
    {
      "type": "command",
      "command": "pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state"
    }
  ]
}
```

The `-ArtifactType` value `parallel-orchestrator-state` is the CLI/MCP artifact type verified in U11.

**Scope limit frozen.** The first `SubagentStop` matcher's alternation regex (line 193) also omits `parallel-orchestrator` and `parallel-planner`. P4-T3's task text adds only a new matcher block; extending that alternation is not in this plan and must not be undertaken.

## Frozen Constant 4 — Parallel Invocation-Origin Deny Prefix (consumed by P2-T1, P2-T2)

```
PARALLEL_INVOCATION_ORIGIN_BLOCKED
```

This is the frozen deny-reason prefix for the parallel-family variant added to `.claude/hooks/enforce-epic-invocation-origin.ps1`.

**Byte-identity obligation for the epic variant.** The existing epic deny reason at `.claude/hooks/enforce-epic-invocation-origin.ps1` line 228 must remain byte-identical for epic targets:

```powershell
$reason = "EPIC_INVOCATION_ORIGIN_BLOCKED: Agent($target) must not be invoked from an orchestrator agent. Both epic-planner and epic-orchestrator delegate to Agent(orchestrator), so an orchestrator-originated invocation would nest orchestrator inside its own delegation chain. Invoke $target from the main session instead."
```

P2-T2's exact `-Be` byte-identity assertion is written against the rendered form of this string for an epic target. Note that the string interpolates `$target` in two places and hard-codes the sentence "Both epic-planner and epic-orchestrator delegate to Agent(orchestrator)", which is why the parallel family requires a separate reason variant selected by target rather than a shared template.

Current gated-target list to be extended additively (line 36):

```powershell
$script:GatedSubagentTypes = @('epic-planner', 'epic-orchestrator')
```

P2-T1 adds `parallel-planner` and `parallel-orchestrator` to this array. The prohibited caller remains `$script:ProhibitedCallerAgentType = 'orchestrator'` (line 37), and the existing allow paths are preserved: an absent or empty caller `agent_type` (main-thread invocation) allows, a non-`orchestrator` caller allows, and a non-gated target allows without parsing the hook payload (lines 212-214 return before the payload parse at lines 216-217).

---

## Additional Literal Constants Frozen from Phase 0 Verification

Recorded here so later phases quote verified literals rather than re-deriving them.

| Constant | Frozen value | Verified in |
| --- | --- | --- |
| Parallel checkpoint path | `artifacts/orchestration/parallel-orchestrator-state.json` | U1 |
| Layer 1 activation marker | `Parallel mode: true` | U12 |
| Prompt target-resolution token shape | `docs/features/active/<basename>` (bare path token) | U13 |
| Layer 1 deny prefix | `PARALLEL_COHORT_BARRIER_BLOCKED` | plan P1-T1; corroborated at `SKILL.md` line 138 |
| Worktree-removal-gate deny prefix | `PARALLEL_WORKTREE_REMOVAL_BLOCKED` | plan P1-T3 |
| Layer 2 message form | `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>` | plan P3-T1; token corroborated at `SKILL.md` line 142 and the seam comment |
| Barrier-satisfying merge statuses | `('merged', 'worktree_removed')` | U6 (`MERGED_MERGE_STATUSES`) |
| Non-terminal merge statuses (P1-T4 coverage set) | `not_started`, `worktree_created`, `pr_open`, `ci_green`, `blocked_drift`, `blocked_ci_loop_limit` | U5 |
| Current-coloring projection rule | `cohorts[]` rows where `generation == recolor_generation` | U8 |
| Cohort entry keys | `index`, `generation`, `item_keys` | U2 |
| Conflict-edge keys | `a`, `b`, `reason` (normalized `a < b`) | U3 |
| Item primary key / resolution hint | `issue_num` (unique positive integer) / `feature_folder` (non-empty string) | U7 |
| Layer 2 entry point | `validate_parallel_orchestrator_state_text(text, *, require_complete: bool = False) -> list[str]` | U10 |
| CLI/MCP artifact type | `parallel-orchestrator-state` | U11 |
| Gated subagent types (after P2-T1) | `epic-planner`, `epic-orchestrator`, `parallel-planner`, `parallel-orchestrator` | U15 |
| Layer 2 seam location | `scripts/dev_tools/validate_parallel_orchestrator_state.py` lines 325-332 | P0-T9 seam check |

## Recorded Advisory for the Phase 3 Executor

The F7 extension seam comment suggests the two-argument call form `errors.extend(<helper>(state_map, CONTEXT))`, while plan Binding Constraint 2 and P3-T3 specify the one-argument form `errors.extend(validate_cohort_barrier_ordering(state_map))`. The plan's form is authoritative and is consistent with the plan's required message text, which deliberately omits the `Parallel checkpoint` context prefix that `CONTEXT` would supply. The seam comment governs placement, not signature. This difference is not a U-row failure and is not a halt condition; it is recorded so the Phase 3 executor does not treat it as a newly discovered defect.

EXIT_CODE: 0

Output Summary: Phase 0 halt gate PASSED — 16 of 16 U-rows PASS, 0 FAIL, so no `upstream-contract-halt` artifact was written and execution may proceed to Phase 1. Four implementation constants are frozen: (1) U9 lifecycle timestamp field names are `worktree_created_at` for item start and `merged_at` for merge confirmation, both documented but optional and unvalidated by F3, so P3-T1's temporal check is additionally required to degrade to structural-plus-status whenever either is absent, and must never reference `in_flight_at` or `started_at`; (2) the U14 `SKILL.md` section name is F5's reserved `## Enforcement Hooks (F7)` at line 439, which supersedes the plan's fallback `## Cohort Barrier Enforcement (F7)`; (3) the U16 decision is ADD — F5 registered no `parallel-orchestrator` `SubagentStop` matcher, so P4-T3's authorized skip branch does not apply and the matcher must be added using the parameterized `epic-orchestrator` form with `-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state`; (4) the parallel invocation-origin deny prefix is `PARALLEL_INVOCATION_ORIGIN_BLOCKED`, with the existing `EPIC_INVOCATION_ORIGIN_BLOCKED` reason string quoted verbatim for P2-T2's byte-identity assertion. Fifteen additional verified literals are tabulated so later phases quote rather than re-derive them.
