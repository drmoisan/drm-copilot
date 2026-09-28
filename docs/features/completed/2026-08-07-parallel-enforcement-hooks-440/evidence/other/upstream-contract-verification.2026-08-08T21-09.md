# Upstream Contract Verification (U1-U16) — Issue #440 (F7)

Timestamp: 2026-08-08T21-09

Tasks: [P0-T9] (U1-U11, F3-owned) and [P0-T10] (U12-U16, F5/F4-owned)

Method: each row was verified by reading the named file on the current branch and quoting the observed literal name. No row is asserted from assumption or from a research document.

## Integration Branch Position

```
$ git rev-parse HEAD
c939b5b80c8c297db49febaebdd35dda2c869a3f

$ git log -1 --format="%H %cI %s" epic/parallel-orchestration-integration
5fd90827593960d9fdbef617e29ee3ac8ccf04c7 2026-08-08T20:55:26-04:00 docs(epic): record wave 3 complete and wave 4 concurrent launch

$ git merge-base HEAD epic/parallel-orchestration-integration
c939b5b80c8c297db49febaebdd35dda2c869a3f

$ git diff --stat c939b5b8..5fd90827
 .../epics/parallel-orchestration/epic-status.md    | 43 ++++++++++++++++++----
 1 file changed, 35 insertions(+), 8 deletions(-)
```

The working branch `feature/parallel-enforcement-hooks-440` is based on `c939b5b8`. The integration branch head has advanced one commit to `5fd90827`, and that commit touches exactly one file — `docs/features/epics/parallel-orchestration/epic-status.md`, an epic status document. It modifies no U-row source file. Verification performed against the checked-out tree at `c939b5b8` is therefore byte-equivalent to verification against the integration branch head `5fd90827` for every file cited below.

Latest three commits reachable from the working tree:

```
c939b5b8 Merge pull request #455 from drmoisan/feature/parallel-orchestrator-surface-441
17422a5b docs(parallel-orchestrator): record remediation cycle 1 re-audit
aa987c12 fix(parallel-orchestrator): align persona grants with prescribed actions
```

## Files Read for Verification

| File | Purpose |
| --- | --- |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | U1, U10, F7 seam |
| `scripts/dev_tools/_parallel_state_common.py` | U4, U5, U6, U7 |
| `scripts/dev_tools/_parallel_state_structures.py` | U2, U3, U8 |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | U11 |
| `.claude/rules/parallel-orchestration.md` | U1, U4, U9 (Cache Doctrine), F7 Seam declaration |
| `docs/features/templates/parallel/parallel-status.md` | U9 |
| `.claude/skills/parallel-orchestrate/SKILL.md` | U12, U13, U14 |
| `.claude/agents/parallel-orchestrator.md` | U4, U12, U15 |
| `.claude/agents/parallel-planner.md` | U15 |
| `.claude/settings.json` | U16 |

---

# [P0-T9] — U1 through U11 (F3-owned)

## U1 — Checkpoint path

**Assumed:** `artifacts/orchestration/parallel-orchestrator-state.json`

**Observed** — `scripts/dev_tools/validate_parallel_orchestrator_state.py` lines 4-5 (module docstring):

> Enforce the repository contract for `` `artifacts/orchestration/parallel-orchestrator-state.json` ``

Corroborated by `.claude/rules/parallel-orchestration.md`: "the parallel-orchestrator checkpoint at `artifacts/orchestration/parallel-orchestrator-state.json`", and by `.claude/agents/parallel-orchestrator.md` line 186: "Update `artifacts/orchestration/parallel-orchestrator-state.json` after every completed step."

**Disposition: PASS.** Literal path matches exactly. This is the value frozen into `$script:ParallelCheckpointPath` (P1-T1) and `Get-ParallelWorktreeRemovalGateCheckpointContent` (P1-T3).

## U2 — `cohorts[]` shape `{index, generation, item_keys[]}`

**Observed** — `scripts/dev_tools/_parallel_state_structures.py`, `_validate_cohort_entry` (lines 193, 199, 213):

```python
index = entry.get("index")
generation = entry.get("generation")
item_keys = entry.get("item_keys")
```

Literal key names observed: `index`, `generation`, `item_keys`. `index` and `generation` are validated as non-negative integers; `item_keys` must be a list whose every entry resolves to an `items[].issue_num`.

**Disposition: PASS.** All three literal names match the assumption exactly.

## U3 — `conflict_edges[]` shape `{a, b, reason}`

**Observed** — `scripts/dev_tools/_parallel_state_structures.py`, `_validate_edge_endpoints` line 386 and `validate_conflict_edges` line 453:

```python
for field in ("a", "b"):
...
reason = record.get("reason")
```

`reason` is checked against `VALID_EDGE_REASONS` (`_parallel_state_common.py` lines 72-74):

```python
VALID_EDGE_REASONS: tuple[str, ...] = tuple(
    "path_overlap module_overlap shared_surface_overlap contract_dependency".split()
)
```

Endpoints must resolve to distinct `items[].issue_num` values and be normalized `a < b` (lines 405-413), so edge identity is canonical.

**Disposition: PASS.** Literal names `a`, `b`, `reason` match. The `a < b` normalization is additional confirmed detail that Layer 1 and Layer 2 both rely on: a neighbor lookup must consider an edge in both directions because the stored orientation is numeric, not causal.

## U4 — `items[]` field names

**Assumed:** `issue_num`, `feature_folder`, `worktree_path`, `merge_status`, lifecycle timestamps.

**Observed, validated by F3** — `scripts/dev_tools/_parallel_state_common.py`, `validate_item_record` (lines 358, 363, 366) and `_validate_merge_status` (lines 314-316):

```python
issue_num = record.get("issue_num")
if not is_non_empty_string(record.get("feature_folder")):
state = record.get("state")
...
if "merge_status" not in record:
    return []
merge_status = record["merge_status"]
```

Literal validated names: `issue_num`, `feature_folder`, `state`, `merge_status`, `blast_radius`.

**Observed, written but NOT validated by F3** — `.claude/agents/parallel-orchestrator.md` lines 190-192 and `.claude/skills/parallel-orchestrate/SKILL.md` lines 378-380 both enumerate the per-item write set identically:

> `items[]` — each item entry carrying `issue_num`, `feature_folder`, `state`, `blast_radius`, `worktree_path`, `branch_name`, `pr_number`, `pr_url`, `merge_status`, `merge_commit_sha`, and the lifecycle timestamps

`worktree_path` is additionally named in the `.claude/rules/parallel-orchestration.md` Cache Doctrine: "`git worktree list --porcelain` — worktree existence and path (`items[].worktree_path`, `worktree_created_at`, `worktree_removed_at`)".

**Disposition: PASS, with a recorded qualification.** Every assumed literal name exists and is spelled as assumed. Three of them — `worktree_path` and the lifecycle timestamps — are documented write-set fields that F3's validator does not require and does not check, so they are optional at the schema level. This does not break any assumption; it is the reason the plan's fail-closed rule (Binding Constraint 6) and the P3-T1 degradation branch are both necessary: Layer 1's worktree-removal gate must deny when it cannot match a `worktree_path`, and Layer 2's temporal reading must degrade when a timestamp is absent rather than assume a value.

## U5 — Eight-value `merge_status` enum

**Observed** — `scripts/dev_tools/_parallel_state_common.py` lines 46-51:

```python
VALID_MERGE_STATUS: tuple[str, ...] = tuple(
    (
        "not_started worktree_created pr_open ci_green merged worktree_removed "
        "blocked_drift blocked_ci_loop_limit"
    ).split()
)
```

Eight members, in order: `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merged`, `worktree_removed`, `blocked_drift`, `blocked_ci_loop_limit`. Absence is treated as `not_started` (lines 298-315, presence-gated check). Confirmed identically in `.claude/skills/parallel-orchestrate/SKILL.md` lines 384-386 and in the `.claude/rules/parallel-orchestration.md` Enum Ownership table.

**Disposition: PASS.** Exactly eight values, spelled as assumed. The six non-terminal values that P1-T4 must exercise are `not_started`, `worktree_created`, `pr_open`, `ci_green`, `blocked_drift`, `blocked_ci_loop_limit`.

## U6 — Barrier-satisfying statuses are exactly `merged` and `worktree_removed`

**Observed** — `scripts/dev_tools/_parallel_state_common.py` lines 82-84:

```python
# Merge-status values meaning the item reached a terminal merged outcome; used
# by invariant 8 (state consistency) and invariant 20 (completion gate).
MERGED_MERGE_STATUSES: tuple[str, ...] = ("merged", "worktree_removed")
```

Corroborated by `.claude/skills/parallel-orchestrate/SKILL.md` lines 113-118: "Cohort `N+1` branches from `main` only after every cohort-`N` item is `merged` or `worktree_removed`... A blocked item (`blocked_ci_loop_limit` or `blocked_drift`) is neither `merged` nor `worktree_removed`, so a blocked item holds the barrier."

**Disposition: PASS.** The two-member set matches exactly. `ci_green` is explicitly NOT a member, confirming the plan's acceptance criterion that `ci_green` does not satisfy the barrier.

## U7 — `issue_num` primary key with `feature_folder` hint

**Observed** — `scripts/dev_tools/_parallel_state_structures.py` module docstring lines 19-20:

> `issue_num` is the primary key (assumption A4), so every `item_keys` entry, edge endpoint, mutation `item_key`, and drift `item_key` is an integer that must resolve to an `items[].issue_num`.

Uniqueness is enforced in `_parallel_state_common.py` `validate_items` (lines 402-424), which accumulates `seen`/`duplicates` and emits `has duplicate items[].issue_num`. `feature_folder` is validated only as a non-empty string (line 363) with no uniqueness constraint, which is consistent with its role as a resolution hint rather than a key.

**Disposition: PASS.** `issue_num` is the unique primary key; `feature_folder` is a non-empty, non-unique string. Layer 1's prompt-based target resolution matches on `feature_folder` (per U13) and then reads the resolved record's `issue_num` to look up conflict edges and cohort membership.

## U8 — `recolor_generation` / `cohorts[].generation` current-coloring projection

**Observed** — `scripts/dev_tools/_parallel_state_structures.py`, `_current_generation_cohorts` lines 245-254:

```python
if not is_non_negative_integer(recolor_generation) or not isinstance(cohorts, list):
    return []
records = [
    cast("dict[str, object]", entry)
    for entry in cast("list[object]", cohorts)
    if isinstance(entry, dict)
]
return [r for r in records if r.get("generation") == recolor_generation]
```

This is F3's authoritative projection: the current coloring is the subset of `cohorts[]` whose `generation` equals the top-level `recolor_generation`. Invariant 12 additionally requires each cohort's `generation <= recolor_generation` (lines 205-211), and invariant 13 requires current-generation `index` uniqueness plus exactly-one coverage of every non-exempt item (lines 279-321), with `COHORT_COVERAGE_EXEMPT_STATES = ("withdrawn", "merged", "blocked")`.

**Disposition: PASS.** The projection rule `generation == recolor_generation` matches the assumption exactly and is the rule both Layer 1 (P1-T1 cohort membership) and Layer 2 (P3-T1 cohort projection) must reuse verbatim.

## U9 — Exact lifecycle timestamp field names for item start and merge confirmation

**Assumed:** F3 defines per-item lifecycle timestamp field names usable as a start marker and a merge-confirmation marker.

**Observed in F3's validator and helpers:** none. `REQUIRED_KEYS` in `validate_parallel_orchestrator_state.py` (lines 71-78) contains no timestamp field, and `validate_item_record` / `_validate_merge_status` in `_parallel_state_common.py` check no per-item timestamp. The only `*_at` field F3 validates anywhere on an item is `blast_radius.computed_at` (line 287), which is a radius-computation stamp, not a lifecycle marker.

**Observed in shipped prose** — `.claude/rules/parallel-orchestration.md`, Cache Doctrine:

> - `git worktree list --porcelain` — worktree existence and path (`items[].worktree_path`, `worktree_created_at`, `worktree_removed_at`).
> - `gh pr view --json state,mergedAt,headRefOid` — pull-request state, merge time, and merge commit (`items[].pr_number`, `pr_url`, `merge_status`, `merged_at`, `merge_commit_sha`).

**Observed in the status-doc template** — `docs/features/templates/parallel/parallel-status.md` line 39, the items projection table header:

```
| issue_num | feature_folder | cohort_index | state | merge_status | pr_url | merge_commit_sha | worktree_created_at | merged_at | worktree_removed_at |
```

**Negative search result.** A repository-wide search of `.claude/` for `in_flight_at` and `merge_confirmed_at` returned no parallel-surface match (`merge_confirmed_at` appears only in `.claude/skills/epic-orchestrate/SKILL.md` line 232, the epic surface). `started_at` appears only in the F3 feature's own research document (`docs/features/active/2026-08-07-parallel-schema-validators-444/research/...` line 341), which lists it as an optional, unvalidated field and is not a shipped contract.

**Resolved field names:**

| Role | Frozen field name | Status in F3 |
| --- | --- | --- |
| Item start marker | `worktree_created_at` | documented in the Cache Doctrine and the status-doc template; optional, not validated |
| Merge confirmation | `merged_at` | documented in the Cache Doctrine and the status-doc template; optional, not validated |
| Worktree removal | `worktree_removed_at` | documented; optional, not validated (recorded for completeness; not consumed by the barrier invariant) |

**Disposition: PASS, with a recorded qualification that mandates the degradation branch.** The two field names required by U9 are identifiable and consistently spelled across the two shipped sources, so P3-T1 has concrete module constants to freeze: `worktree_created_at` for item start and `merged_at` for merge confirmation. However, because F3 neither requires nor validates either field, a schema-valid checkpoint may legitimately omit both. The temporal reading of the Layer 2 invariant therefore MUST degrade to structural-plus-status checks whenever either timestamp is absent or is not a string, exactly as P3-T1 specifies. There is no F3-guaranteed `in_flight_at` and no F3-guaranteed `started_at`; a Phase 3 implementation must not assume one exists.

## U10 — Entry-point signature

**Assumed:** `validate_parallel_orchestrator_state_text(text, *, ...) -> list[str]`

**Observed** — `scripts/dev_tools/validate_parallel_orchestrator_state.py` lines 285-287:

```python
def validate_parallel_orchestrator_state_text(
    text: str, *, require_complete: bool = False
) -> list[str]:
```

Confirmed additional contract detail from the docstring and body: the function returns a list of error strings, never mutates its input, returns a single-element list for unparseable text (line 313) and for a non-object root (line 316), and accumulates into a local `errors: list[str]` via `errors.extend(...)` (lines 319-323).

**Disposition: PASS.** Keyword-only signature and `list[str]` return type match the assumption exactly. The `errors.extend(...)` accumulation pattern is what P3-T3's appended call must join.

## U11 — `parallel-orchestrator-state` CLI artifact type

**Observed** — `scripts/dev_tools/validate_orchestration_artifacts.py` lines 261-270 (subparser registration):

```python
parallel_state_parser = subparsers.add_parser("parallel-orchestrator-state")
parallel_state_parser.add_argument("path")
parallel_state_parser.add_argument(
    "--require-complete",
    action="store_true",
    ...
)
```

and lines 350-354 (dispatch):

```python
if args.artifact_type == "parallel-orchestrator-state":
    return validate_parallel_orchestrator_state_text(
        text,
        require_complete=bool(args.require_complete),
    )
```

The sibling type `parallel-planner-state` is registered at line 272 and dispatched at line 355.

**Disposition: PASS.** The literal artifact type string `parallel-orchestrator-state` is registered with a `--require-complete` flag and dispatches to the U10 entry point. This is the value P4-T3's `SubagentStop` registration passes as `-ArtifactType`.

## Layer 2 Extension Seam — Present and Located

Not a numbered U-row, but required by the execution directive.

**Observed** — `scripts/dev_tools/validate_parallel_orchestrator_state.py` lines 325-332, inside `validate_parallel_orchestrator_state_text`, positioned after the four existing `errors.extend(...)` calls (lines 320-323) and before the `require_complete` block (lines 334-335):

```python
    # BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
    # F7 (parallel enforcement hooks) owns the retrospective cohort-ordering
    # invariant of design section 9 Layer 2. Its entire edit to this module is
    # one appended `errors.extend(<helper>(state_map, CONTEXT))` call inside
    # this block, plus the helper's import. Nothing else in this function moves,
    # so F7 and F3 cannot contend over the same lines (epic wave-4 rule).
    # Add F7 helper invocations below this line, one per line.
    # END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
```

The seam is explicitly delimited, names F7, and names the `PARALLEL_COHORT_BARRIER_VIOLATION` token. It is the exact location for P3-T3's appended call. `.claude/rules/parallel-orchestration.md` declares the same seam in its `## F7 Seam` section.

**Observation for the Phase 3 executor (recorded, not resolved here).** The seam comment suggests a two-argument call form `errors.extend(<helper>(state_map, CONTEXT))`, whereas plan Binding Constraint 2 and P3-T3 specify the one-argument form `errors.extend(validate_cohort_barrier_ordering(state_map))`. The plan's form is consistent with the plan's required message text, which is `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>` and deliberately does not carry the `Parallel checkpoint` context prefix that `CONTEXT` supplies. The seam comment is a non-binding suggestion about placement; the plan is the authority on the call signature. No U-row is affected and no halt condition arises. Recorded so the Phase 3 executor does not treat the difference as a discovered defect.

---

# [P0-T10] — U12 through U16 (F5/F4-owned)

## U12 — Literal marker text `Parallel mode: true` and its emission site

**Observed** — `.claude/skills/parallel-orchestrate/SKILL.md`, `## Parallel-Mode Kickoff Parameter` (line 172), items 1 at lines 177-183:

> 1. The literal marker line:
>
>    > `Parallel mode: true. parallel_slug: <slug>. parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json. cohort_index: <n>. PR base branch MUST be main; pass --base main to gh pr create.`
>
>    The token `Parallel mode: true` must appear exactly: it is the marker F7's Layer 1 barrier hook matches on.

**Emission site:** the serialized delegation prompt that `parallel-orchestrator` passes when it "delegates an item to `Agent(orchestrator)`" (line 174). The section further records negative obligations at lines 198-206: the prompt never carries `Preparation mode: true`, and never carries the epic-mode marker line, "so the epic wave-barrier hook does not fire on a parallel child."

Corroborated by `.claude/skills/parallel-plan/SKILL.md` line 92: the preparation-mode prompt "contains no `Parallel mode: true`, so F7's future cohort-barrier" hook does not fire on a preparation delegation.

**Disposition: PASS.** The literal marker token is exactly `Parallel mode: true`, is contractually mandated to appear verbatim, is emitted into the `Agent(orchestrator)` delegation prompt by `parallel-orchestrator`, and is contractually absent from the preparation-mode prompt. This is the value frozen into `$script:ParallelModeMarker` (P1-T1), and the absence contract is what makes the P1-T2 "prompt lacking the marker allows" test meaningful.

## U13 — Child prompt includes the target item's `docs/features/active/<folder>` path

**Observed** — `.claude/skills/parallel-orchestrate/SKILL.md` lines 184-186, item 2 of the five prompt elements:

> 2. The item's active feature folder path, written literally as `docs/features/active/<basename>`. The child needs it for its own operation, and F7's Layer 1 hook resolves the target item by scanning the prompt for exactly that path shape, so the path is emitted as a bare path token.

**Disposition: PASS.** The prompt carries the feature folder as a bare `docs/features/active/<basename>` token, and F5 documented that exact shape as F7's resolution mechanism. Layer 1's prompt-based target resolution (P1-T1) matches this token against `items[].feature_folder`, consistent with U7 (`feature_folder` is the resolution hint; `issue_num` is the key).

## U14 — F5 reserved placeholder section for F7 in `SKILL.md`

**Observed** — `.claude/skills/parallel-orchestrate/SKILL.md` lines 439-441. Section heading inventory (`^#{2,4} ` scan) confirms three reserved wave-4 placeholders at the end of the file:

```
435:## Mutation Protocol (F6)
439:## Enforcement Hooks (F7)
443:## Radius Drift Detection (F8)
```

The F7 placeholder verbatim:

```markdown
## Enforcement Hooks (F7)

Reserved for F7; content is appended by that feature and must not be relocated.
```

**The exact reserved section heading text is:**

```
## Enforcement Hooks (F7)
```

**Disposition: PASS — a reserved placeholder EXISTS.** Per plan Binding Constraint 2 and the execution directive, the reserved section name takes precedence over the plan's fallback name `## Cohort Barrier Enforcement (F7)`. P4-T4 must therefore write its content under the existing `## Enforcement Hooks (F7)` heading at line 439 and must NOT create a new section, must not rename the heading, and must not relocate it (the placeholder body explicitly forbids relocation). The sibling placeholders `## Mutation Protocol (F6)` (line 435) and `## Radius Drift Detection (F8)` (line 443) belong to F6 and F8 and must not be touched.

Additional F5 content relevant to P4-T4: `.claude/skills/parallel-orchestrate/SKILL.md` lines 130-145 already describe the two-layer F7 design inside `## Cohort Barrier and Max-Concurrency Slot Filling`, naming `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, the `PARALLEL_COHORT_BARRIER_BLOCKED` deny reason, the `PARALLEL_COHORT_BARRIER_VIOLATION` Layer 2 invariant, and the rationale that "no single `PreToolUse` hook can validate a batch of concurrent `Agent` calls: hooks fire per call with no cross-call state visibility." That existing text is F5-owned and must not be edited by P4-T4; the new content goes only under the reserved heading.

## U15 — Exact `subagent_type` strings

**Observed** — `.claude/agents/parallel-orchestrator.md` frontmatter:

```yaml
---
name: parallel-orchestrator
model: opus
```

`.claude/agents/parallel-planner.md` frontmatter:

```yaml
---
name: parallel-planner
model: opus
```

**Disposition: PASS.** The literal persona names, which are the `subagent_type` values, are exactly `parallel-orchestrator` and `parallel-planner`. These are the two strings P2-T1 adds to `$script:GatedSubagentTypes` in `.claude/hooks/enforce-epic-invocation-origin.ps1`, and `parallel-orchestrator` is the `SubagentStop` matcher value for P4-T3.

Additional confirmed detail: both personas declare `tools: - "Agent(orchestrator)"`, so both are authorized to delegate `Agent(orchestrator)`. This is why Layer 1's activation gate keys on `subagent_type == "orchestrator"` plus the `Parallel mode: true` marker rather than on the caller persona.

## U16 — Has F5 already registered a `parallel-orchestrator` `SubagentStop` matcher?

**Observed** — a search of `.claude/settings.json` for `parallel-orchestrator` and `parallel-planner` returned **no matches anywhere in the file**. The `SubagentStop` array (lines 191-250) contains exactly six matcher blocks:

| Matcher | Hook command |
| --- | --- |
| `atomic-planner\|atomic-executor\|feature-review\|task-researcher\|prd-feature\|staged-review\|epic-review\|status-updater\|python-typed-engineer\|powershell-typed-engineer\|csharp-typed-engineer\|typescript-engineer\|orchestrator\|epic-orchestrator\|epic-planner` | inline completion-artifact check, plus `validate-discovery-artifact-gate.ps1` |
| `feature-review` | `validate-feature-review-coverage.ps1` |
| `atomic-planner` | `validate-planner-output.ps1` |
| `pr-author` | `validate-pr-author-output.ps1` |
| `orchestrator` | `validate-orchestrator-output.ps1` |
| `epic-orchestrator` | `validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state` |

The `epic-orchestrator` block (lines 241-249) is the parameterized form the plan directs P4-T3 to copy:

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

**Disposition: PASS (assumption verified; answer is NO).** F5 has NOT registered a `parallel-orchestrator` `SubagentStop` matcher, and neither `parallel-orchestrator` nor `parallel-planner` appears anywhere in `.claude/settings.json`. **P4-T3's authorized skip branch therefore does NOT apply.** P4-T3 must add the `SubagentStop` matcher `parallel-orchestrator` running:

```
pwsh -NoProfile -File .claude/hooks/validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state
```

Recorded for the Phase 4 executor: the first `SubagentStop` matcher's alternation regex (line 193) likewise omits `parallel-orchestrator` and `parallel-planner`. P4-T3 as written adds only a new matcher block and does not modify that regex; extending the alternation is outside this plan's task text and must not be undertaken.

---

## Row Summary

| Row | Assumption | Disposition |
| --- | --- | --- |
| U1 | Checkpoint path `artifacts/orchestration/parallel-orchestrator-state.json` | **PASS** |
| U2 | `cohorts[]` shape `{index, generation, item_keys[]}` | **PASS** |
| U3 | `conflict_edges[]` shape `{a, b, reason}` | **PASS** |
| U4 | `items[]` names `issue_num`, `feature_folder`, `worktree_path`, `merge_status`, lifecycle timestamps | **PASS** (worktree_path and timestamps optional/unvalidated) |
| U5 | Eight-value `merge_status` enum | **PASS** |
| U6 | Barrier-satisfying statuses exactly `merged`, `worktree_removed` | **PASS** |
| U7 | `issue_num` primary key, `feature_folder` hint | **PASS** |
| U8 | `generation == recolor_generation` current-coloring projection | **PASS** |
| U9 | Lifecycle timestamp names for item start and merge confirmation | **PASS** (`worktree_created_at`, `merged_at`; optional, so temporal check must degrade) |
| U10 | `validate_parallel_orchestrator_state_text(text, *, ...) -> list[str]` | **PASS** |
| U11 | `parallel-orchestrator-state` CLI artifact type | **PASS** |
| U12 | Marker `Parallel mode: true` and its emission site | **PASS** |
| U13 | Child prompt carries `docs/features/active/<folder>` | **PASS** |
| U14 | F5 reserved a named F7 placeholder in `SKILL.md` | **PASS** — reserved name is `## Enforcement Hooks (F7)` |
| U15 | `subagent_type` strings `parallel-orchestrator`, `parallel-planner` | **PASS** |
| U16 | F5 already registered a `parallel-orchestrator` `SubagentStop` matcher | **PASS** (verified; answer is NO — P4-T3 must add it) |

**16 of 16 rows PASS. Zero FAIL. No halt condition.**

EXIT_CODE: 0

Output Summary: All sixteen upstream contract assumptions U1-U16 verified by reading the named files on the current branch, with the observed literal names quoted; all sixteen PASS and zero FAIL, so the Phase 0 halt gate does not trigger. The integration branch head has advanced one commit beyond the feature branch base (`c939b5b8` -> `5fd90827`), and that commit touches only `docs/features/epics/parallel-orchestration/epic-status.md`, so no U-row source file differs. Three rows carry recorded qualifications that constrain later phases: U4 and U9 confirm that `worktree_path` and the lifecycle timestamps `worktree_created_at` / `merged_at` are documented but optional and unvalidated by F3, so Layer 1 must fail closed on an unmatched `worktree_path` and Layer 2's temporal reading must degrade to structural-plus-status when a timestamp is absent; U14 confirms F5 reserved the section `## Enforcement Hooks (F7)` (line 439), which supersedes the plan's fallback name; U16 confirms F5 did NOT register a `parallel-orchestrator` `SubagentStop` matcher, so P4-T3's authorized skip branch does not apply and the matcher must be added. The Layer 2 F7 extension seam is present at `scripts/dev_tools/validate_parallel_orchestrator_state.py` lines 325-332, explicitly delimited and naming both F7 and `PARALLEL_COHORT_BARRIER_VIOLATION`.
