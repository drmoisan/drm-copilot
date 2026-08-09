# Upstream Contract Reconciliation — F8 Radius Drift Detection (issue #446)

Timestamp: 2026-08-08T21-19
Phase: 1 (tasks [P1-T1] through [P1-T4])
Integration head: `c939b5b8` (`Merge pull request #455 from drmoisan/feature/parallel-orchestrator-surface-441`)
Worktree root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`
Scope: reconciliation only. No production code was written in this phase.

## Landing Status Summary

| Upstream | Wave | Issue | Landed? | Evidence |
| --- | --- | --- | --- | --- |
| F1 blast radius | 0 | #447 | YES | `scripts/dev_tools/compute_blast_radius.py`, `_blast_radius_conflicts.py`, `_blast_radius_glob.py` all present; F1 `spec.md` acceptance criteria checked `[x]` |
| F1 follow-up (under-reporting gaps) | — | #452 | YES | commit `7a835c38` |
| F3 schema/validators | 1 | #444 | YES | `scripts/dev_tools/validate_parallel_orchestrator_state.py` (336 lines), `_parallel_state_common.py`, `_parallel_state_records.py`, `_parallel_state_structures.py`; `.claude/rules/parallel-orchestration.md` |
| F2 cohort scheduler | 1 | #445 | YES | `scripts/dev_tools/parallel_cohort_computation.py` (468 lines) |
| F4 planner surface | 2 | #443 | YES | `scripts/dev_tools/validate_parallel_planner_state.py`, `parallel_kickoff_contract.py` |
| F5 orchestrator surface | 3 | #441 | YES | `.claude/skills/parallel-orchestrate/SKILL.md` (445 lines), `.claude/agents/parallel-orchestrator.md` |
| F6 mutation protocol | 4 | #442 | **NO — executing concurrently** | see IC-6a / IC-6b |
| F7 enforcement hooks | 4 | #440 | **NO — executing concurrently** | F7 extension seam in the validator is still empty |

No `Status: BLOCKED` entry is recorded anywhere in this artifact. Every wave-0..wave-3 contract
(IC-1a, IC-1b, IC-3a, IC-3b, IC-5a, IC-5b) resolved against a landed artifact. The plan's P1-T1 and
P1-T2 BLOCKED fallbacks are not triggered, and no downstream task is left unmet for a missing
upstream contract.

---

## IC-1a — Path-Subsumption Predicate

- **Adopted symbol:** `is_path_subsumed`
- **Source file:** `scripts/dev_tools/_blast_radius_glob.py` (line 140)
- **Signature (verbatim, line 140):**
  ```python
  def is_path_subsumed(path: str, covering_paths: Sequence[str]) -> bool:
  ```
- **Adopted import for F8:** `from scripts.dev_tools._blast_radius_glob import is_path_subsumed`
- **Deviation:** none against the plan's requirement (a reusable subsumption predicate exists, so
  the `fnmatch.fnmatchcase` fallback of P1-T1 is NOT used and MUST NOT be used). One correction to
  the orchestrator's stated provenance is recorded below.

### Semantics (verbatim docstring, lines 141-160)

> Report whether a concrete path is covered by a collection of entries.
>
> Implements the coverage relation validation rule V1 applies: exact match,
> listed-directory prefix, or glob match.
>
> Returns:
>     bool: ``True`` when at least one entry covers the path. An empty
>     collection covers nothing, so the result is ``False``.

Body (lines 161-176), quoted so F8 does not re-derive the three rules:

```python
    # Test entries in order and return on the first cover; the three rules are
    # independent, so traversal order affects speed only, never the verdict.
    for entry in covering_paths:
        if entry == path:
            return True

        # A wildcard entry is a pattern matched with the shared glob subset. A
        # wildcard-free entry cannot be a pattern, so it is treated as a listed
        # directory covering everything beneath it.
        if "*" in entry or "?" in entry:
            if matches_glob(entry, path):
                return True
        elif path.startswith(entry.rstrip("/") + "/"):
            return True

    return False
```

Glob vocabulary is a deliberate fnmatch subset implemented via regex translation
(`_glob_to_regex_text` / `matches_glob`, lines 74-137), documented at
`_blast_radius_glob.py:31-33`:

> - The glob vocabulary is a deliberate fnmatch subset (``**``, ``*``, ``?``);
> ... agree with fnmatch on their semantics.

### CORRECTION to the orchestrator's stated finding (IC-1a provenance)

The orchestrator stated: "This predicate carries the issue #452 correction that honours
listed-directory prefixes." That is imprecise in one direction that matters for citation accuracy,
though it does not change the operational conclusion.

Verified provenance:

- `is_path_subsumed` already honoured listed-directory prefixes **before** #452. Its pre-#452 home
  was `scripts/dev_tools/_blast_radius_extraction.py:458`, and the pre-#452 body is byte-identical
  to the current one (verified with `git show 7a835c38^:scripts/dev_tools/_blast_radius_extraction.py`,
  lines 478-494, which contain the same `elif path.startswith(entry.rstrip("/") + "/")` branch).
- The #452 correction was applied to the **other side of the relation** — the `conflicts` path
  comparison (`_entries_overlap`, `_blast_radius_glob.py:273-316`) — to make it agree with
  `is_path_subsumed`. Commit `7a835c38` message, Gap 2, verbatim:

  > Gap 2: the conflicts path comparison treated a listed directory and a glob
  > beneath it as disjoint while is_path_subsumed treated a file under that
  > directory as covered, so two radii that provably share files could report
  > no path_overlap. The comparison now honours listed-directory prefixes on
  > both sides of the relation.

- F1's amended `spec.md:53` states the same symmetry, verbatim:

  > Listed-directory semantics are honoured symmetrically by V1 (`is_path_subsumed` /
  > `Test-PathSubsumed`) and by `conflicts` (`_entries_overlap` / `Test-EntryOverlap`), which is
  > what issue #452 corrected.

- `_blast_radius_glob.py` itself was **created** by commit `7a835c38` as a pure module split
  (`git log --diff-filter=A` returns only `7a835c38`), which is why the file appears to be
  entirely #452-authored. Commit message: "Splits _blast_radius_glob.py and
  _blast_radius_thresholds.py out of oversized modules as pure moves, to stay within the 500-line
  limit."

Operational conclusion (unchanged): `is_path_subsumed` is the reference, fail-closed coverage
relation, both sides of the relation now agree, and F8 MUST import it rather than reimplement it or
fall back to `fnmatch.fnmatchcase`. The #452 attribution belongs to the *symmetry* of the relation
(and to `_entries_overlap`), not to `is_path_subsumed`'s own body.

### Import-location note (facade does not re-export)

`is_path_subsumed` is **not** in `compute_blast_radius.__all__` (`compute_blast_radius.py:60-70`,
which lists only `BlastRadius`, `ConflictReason`, `ConflictResult`, `RadiusFinding`, `conflicts`,
`derive_blast_radius`, `extract_plan_paths`, `radius_from_observed_paths`, `validate_blast_radius`).
The facade imports only `concrete_entries` from `_blast_radius_glob` (line 47). F8 therefore imports
`is_path_subsumed` directly from the underscore-prefixed helper module
`scripts.dev_tools._blast_radius_glob`. This is the only available import location and is recorded
here so the choice is not later read as a boundary violation.

---

## IC-1b — Contention Relation and Observed-Radius Constructor

### Contention relation

- **Adopted symbol:** `conflicts`
- **Source file:** `scripts/dev_tools/_blast_radius_conflicts.py` (line 137); re-exported by the
  facade `scripts/dev_tools/compute_blast_radius.py` (`__all__` line 65, import lines 35-39)
- **Adopted import for F8:** `from scripts.dev_tools.compute_blast_radius import conflicts`
  (facade re-export; preferred over the private module because the facade is the documented public
  surface in F1 `spec.md:80`)
- **Signature (verbatim, `_blast_radius_conflicts.py:137-139`):**
  ```python
  def conflicts(
      a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
  ) -> ConflictResult:
  ```
- **THIRD ARGUMENT CONFIRMED.** `conflicts` takes `config` (the parsed `config/blast-radius.json`).
  Docstring, lines 145-148, verbatim:

  > config (Mapping[str, object]): Parsed ``config/blast-radius.json``. The
  >     relation reads no key from it today; it is validated and kept in the
  >     signature because the contract is frozen for downstream consumers.

  It raises `TypeError` if `config` is not a mapping (`require_mapping(config, "config")`, line 157).
  Consequence for F8: the CLI (P3-T1) must load `config/blast-radius.json` and pass the parsed
  mapping into the pure conflict-recomputation function (P2-T12) as an input, preserving purity.

- **Return type:** `ConflictResult`, a frozen dataclass declared at `_blast_radius_conflicts.py:94-112`
  with exactly two attributes:
  ```python
  conflict: bool
  reasons: tuple[ConflictReason, ...]
  ```
  `__post_init__` (lines 114-134) enforces `conflict == bool(reasons)` and that reason kinds appear in
  `CONFLICT_KINDS` order without repetition. `ConflictReason` (lines 61-91) carries `kind: str` and
  `detail: str`, `kind` restricted to `CONFLICT_KINDS`.
- **Reason kinds and order** (`conflicts` body lines 160-177): `path_overlap`, then `module_overlap`,
  `shared_surface_overlap`, `contract_dependency`. These strings equal F3's
  `conflict_edges[].reason` enum (`VALID_EDGE_REASONS` in `_parallel_state_common.py:72-74`), so a
  recomputed conflict maps onto `conflict_edges[]` without translation.
- **Fail-closed glob semantics** (F1 `spec.md:121`, verbatim excerpt):

  > Glob×glob: **any pair not provably disjoint counts as overlapping** — the implementation may use
  > a conservative shared-literal-prefix test, and when it cannot decide, it returns overlap. This
  > is the fail-closed clause made concrete.

  Implementation: `_entries_overlap` (`_blast_radius_glob.py:273-316`), whose own docstring states
  "Any pair the test cannot separate is reported as overlapping, the fail-closed direction."
- **Empty-radius semantics** (`conflicts` docstring lines 150-152, verbatim): "Two empty radii, and
  an empty radius against a non-empty one, do not conflict." F8 must therefore treat an
  unevaluable radius as conflicting **itself** (P2-T12's fail-closed clause); the relation will not
  do that for it, because emptiness is not overlap.
- **Deviation:** none. The relation exists with the documented name; nothing is reimplemented.

### Observed-radius constructor (the F8-specific F1 deliverable)

- **Adopted symbol:** `radius_from_observed_paths`
- **Source file:** `scripts/dev_tools/compute_blast_radius.py` (line 278); in `__all__` (line 68)
- **Adopted import for F8:** `from scripts.dev_tools.compute_blast_radius import radius_from_observed_paths`
- **Signature (verbatim, lines 278-283):**
  ```python
  def radius_from_observed_paths(
      observed_paths: Sequence[str],
      config: Mapping[str, object],
      *,
      computed_at: str,
  ) -> BlastRadius:
  ```
- **Shipped for drift detection.** Docstring lines 286-288, verbatim:

  > Drift detection supplies the output of a diff listing; the library performs
  > no subprocess call of its own, so the paths arrive as plain strings and are
  > taken verbatim rather than re-classified by the plan-text heuristic.

  F1 `spec.md:89` annotates the same function `# F8: wrap \`git diff --name-only\` output`, and
  `spec.md:145` records the downstream row: "F8 drift detection | `radius_from_observed_paths`
  (source `observed`) + `conflicts` recomputation against declared radii (§7 steps 1 and 4)."
- **Behaviour F8 inherits (body lines 304-313):** `source=RADIUS_SOURCE_OBSERVED` (`"observed"`),
  `modules=resolve_modules(paths, config)`, `shared_surfaces=resolve_shared_surfaces(concrete_entries(paths), config)`,
  `contracts=()` (a diff carries no interface-section text).
- **MANDATE for F8:** build the observed radius by calling `radius_from_observed_paths`, never by
  constructing a `BlastRadius` by hand. Hand construction would skip `resolve_modules` and
  `resolve_shared_surfaces` and therefore silently drop the module and shared-surface disjuncts of
  the contention relation, under-reporting the radius — the failure mode design §13.1 names as
  dominant.

### Issue #452 correction to `config_root_surfaces` / separator-free root surfaces

- **Reader:** `config_root_surfaces(config: Mapping[str, object]) -> tuple[str, ...]` at
  `scripts/dev_tools/_blast_radius_validation.py:194`. Docstring lines 195-202, verbatim:

  > Read the separator-free subset of the configured shared surfaces.
  >
  > This is the sole source of separator-free path acceptance (issue #452). The
  > extraction layer has no access to the truth table, so both entry points that
  > must agree — ``derive_blast_radius`` and ``validate_blast_radius`` — call
  > this reader on the same ``config`` mapping and forward the result. Deriving
  > the set from ``config["shared_surfaces"]`` rather than a second hardcoded
  > list is what keeps extraction and surface resolution from desynchronizing.

- **Classifier side:** `_blast_radius_extraction.py:248-253`, verbatim:

  > # A separator-free token is admitted only as an exact ordinal member of the
  > # configured root-surface set (issue #452). Substring, suffix, and
  > # case-insensitive comparison are all rejected: anything looser would
  > # desynchronize this classifier from ``resolve_shared_surfaces``, which
  > # tests plain membership.

- Commit `7a835c38`, Gap 1, verbatim: "the three separator-free entries in the configured
  shared_surfaces list (poetry.lock, package-lock.json, quality-tiers.yml) were unreachable from
  plan or spec text and V2 could not fire for them at plan time."

- **F8 inherits this correction by construction, not by re-derivation.** `config_root_surfaces` is
  consumed inside `derive_blast_radius` (`compute_blast_radius.py:254`, comment at line 253 citing
  issue #452) and inside `validate_blast_radius` (`_blast_radius_validation.py:352-354`, comment at
  line 352 citing issue #452). `radius_from_observed_paths` takes its paths verbatim from the diff
  and resolves shared surfaces through `resolve_shared_surfaces(concrete_entries(paths), config)`,
  which tests plain membership against `config["shared_surfaces"]` — so a separator-free
  repository-root surface appearing in an observed diff is resolved as a shared surface without any
  F8-side token classification. **F8 therefore re-derives nothing here**: it calls the library and
  inherits both #452 corrections. Any F8-side re-derivation of root-surface acceptance would
  reintroduce exactly the desynchronization the #452 comment warns against and is prohibited.

- **Strictly-widening guarantee** (commit `7a835c38`, verbatim): "Both changes are strictly widening.
  The corrected overlap set is a proper superset of the previous one: a 15-pair truth table
  recomputed in both languages records 7 False-to-True transitions and 0 True-to-False, so
  fail-closed semantics are preserved."

---

## IC-3a — Checkpoint Schema (F3-owned; F8 populates, never defines)

Sources read: `.claude/rules/parallel-orchestration.md` (invariants 7, 8, 16, 17, 18; sections
`## Cache Doctrine`, `## Drift-Event Recording Rule (A8)`, `## Enum Ownership (F6/F7/F8 consume,
never extend)`); `scripts/dev_tools/_parallel_state_records.py`;
`scripts/dev_tools/_parallel_state_common.py`; F3 `spec.md` (S2 item table);
`.claude/skills/parallel-orchestrate/SKILL.md` (`## Parallel-Level Checkpoint`,
`## Per-Item Branch and Worktree Lifecycle`).

### `drift_events[]` entry shape (invariant 18)

Rule file, `.claude/rules/parallel-orchestration.md:57`, verbatim:

> 18. **Drift-event shape.** Each `drift_events[]` entry must carry an `item_key` that resolves to an
> `items[].issue_num`, `declared` and `observed` as lists of non-empty strings, an `escaped_paths`
> list that is non-empty and holds non-empty strings (an event with zero escaped paths is not a
> drift event), a non-empty `at`, and an `action` in `{raised_blocking_finding,
> halted_later_started_item}`.

Adopted field names, exactly six, no additions:

| Field | Type / constraint | Enforcement site |
| --- | --- | --- |
| `item_key` | non-boolean `int` resolving to an `items[].issue_num` | `_parallel_state_records.py:296-301` via `_resolves` (lines 59-72) |
| `declared` | list of non-empty strings; may be empty | `_parallel_state_records.py:304-308` |
| `observed` | list of non-empty strings; may be empty | `_parallel_state_records.py:304-308` |
| `escaped_paths` | list of non-empty strings, **MUST be non-empty** | `_parallel_state_records.py:310-315` |
| `at` | non-empty string | `_parallel_state_records.py:316-317` |
| `action` | member of `VALID_DRIFT_ACTIONS` | `_parallel_state_records.py:319-323` |

Validator excerpt (`_parallel_state_records.py:310-315`), verbatim:

```python
        escaped_paths = record.get("escaped_paths")
        if not is_string_list(escaped_paths) or not escaped_paths:
            errors.append(
                f"{entry_context} escaped_paths must be a non-empty list of "
                f"non-empty strings."
            )
```

Comment at lines 302-303, verbatim: "declared and observed are the two path sets compared at
detection time; both may legitimately be empty, unlike escaped_paths."

Entry point: `validate_drift_events(events: object, issue_nums: set[int], context: str) -> list[str]`
(`_parallel_state_records.py:267-269`). A non-list value yields exactly one error; an empty list is
valid ("a run with no drift records no events", lines 279-281).

### `action` enum — EXACTLY TWO MEMBERS, no `resolved`

Constant (`scripts/dev_tools/_parallel_state_common.py:76-80`), verbatim:

```python
# Drift-response actions (spec S4, assumption A8). One event carries the
# strongest action taken; ``halted_later_started_item`` subsumes the finding.
VALID_DRIFT_ACTIONS: tuple[str, ...] = tuple(
    "raised_blocking_finding halted_later_started_item".split()
)
```

- **Adopted members:** `raised_blocking_finding`, `halted_later_started_item`. Nothing else.
- **There is NO `resolved` member.** F3 defines none, in the rule file, the constant, or the
  validator.
- **Adopted constant for F8 to import:** `VALID_DRIFT_ACTIONS` from
  `scripts.dev_tools._parallel_state_common`. F8 validates `build_drift_event`'s `action` against
  this imported constant rather than a locally redefined tuple, so the two can never desynchronize.
- **Enum Ownership is binding.** `.claude/rules/parallel-orchestration.md:148` and the paragraph
  following its table, verbatim:

  > The wave-4 features — F6 (mutation protocol), F7 (enforcement hooks), and F8 (drift detection) —
  > CONSUME these member sets and NEVER extend them. A wave-4 feature that needs a new member must
  > amend this rule file and the validators at spec review, not add the member at implementation
  > time. This constraint exists because the wave-4 features are prepared concurrently and would
  > otherwise add fields to the same files at the same time.

- **RECONCILED DEVIATION (explicit).** The plan's Open Questions note (plan lines 521-523) and
  constraint 8 (plan lines 82-83) anticipated a possible `resolved` enum value and describe
  resolution as "a `resolved` entry for K with a later `at` is appended". **F3 does not define a
  `resolved` value.** Adopting F3's two-member set is mandatory, and adding a third member at
  implementation time is prohibited by the Enum Ownership section. The consequence is recorded as
  the adopted resolution semantics below.

### A8 Drift-Event Recording Rule

`.claude/rules/parallel-orchestration.md:142`ff (`## Drift-Event Recording Rule (A8)`), verbatim:

> `drift_events[].action` is the two-member enum `{raised_blocking_finding,
> halted_later_started_item}`. The recording rule is: one event per drift occurrence, carrying the
> STRONGEST action taken. `halted_later_started_item` subsumes `raised_blocking_finding`, so an
> occurrence that halted a later-started item records exactly one event with
> `action == 'halted_later_started_item'` and does not additionally record a
> `raised_blocking_finding` event for the same occurrence.
>
> The drift-detection feature consumes this enum and this rule without extending either.

Adopted for F8: **one event per drift occurrence**, carrying the strongest action. An occurrence
that halted a later-started item records exactly ONE event with
`action == 'halted_later_started_item'` and does NOT also record a `raised_blocking_finding` event
for the same occurrence.

### ADOPTED RESOLUTION SEMANTICS (IC-3a reconciliation decision)

Rationale for a derivation rather than an enum member: `action` has no `resolved` member, and
`escaped_paths` must be non-empty, so a clean re-evaluation **cannot be recorded as a drift event at
all** (a zero-escape event is rejected by invariant 18 — "an event with zero escaped paths is not a
drift event"). Resolution must therefore be derived from fields that already exist. F8 adds no
schema field and no enum member.

A drift event for item K is **UNRESOLVED** unless at least one of the following holds against the
item's currently recorded `blast_radius`:

- **(a) Radius widened to cover the escape.** Every `escaped_paths` entry of K's latest drift event
  is subsumed by the item's current `blast_radius.paths` under the #452-corrected
  `is_path_subsumed` (IC-1a). Meaning: the declared radius was widened to cover what the item
  actually touched.
- **(b) Radius re-recorded from a later observed diff.** The item's current
  `blast_radius.source == 'observed'` **and** its `blast_radius.computed_at` is strictly greater
  than the latest drift event's `at`. Meaning: the parent re-recorded the radius from a later
  observed diff. This disjunct covers the case where remediation narrowed the diff instead of
  widening the radius.

Field availability verified: `blast_radius` carries `paths`, `modules`, `shared_surfaces`,
`contracts`, `source` in `{derived, declared, observed}`, and a non-empty `computed_at`
(invariant 9, `.claude/rules/parallel-orchestration.md:39`; `BlastRadius` dataclass
`compute_blast_radius.py:96-127`; `RADIUS_SOURCE_OBSERVED = "observed"` at line 77). Both disjuncts
read only fields that already exist.

Properties of the derivation:

- **Fail-closed.** Absent any affirmative parent write, neither disjunct holds and drift stays
  unresolved, so the drift gate keeps denying.
- **Non-deadlocking.** Both disjuncts are concrete, recordable parent actions that the R1-R5
  remediation cycle already drives; neither requires a new enum member, a new field, or a new loop.
- **Pure.** Both disjuncts are computed from function inputs (the event list and the item's
  `blast_radius`); no wall-clock read and no I/O.
- **Deterministic.** `is_path_subsumed` is pure and order-independent in verdict; the
  `computed_at > at` comparison is a total order over the recorded ISO-8601 strings.

**Deviation from the plan, recorded:** plan constraint 8 (lines 82-83) and the Open Questions note
(lines 521-523) assume resolution is signalled by appending a `resolved` drift event. That mechanism
does not exist in F3's landed schema. The two disjuncts above replace it. Downstream plan tasks that
name a `resolved` `action` value — P2-T4 ("using the reconciled enum name for resolution"),
P2-T9 ("a later `resolved` entry for the same `item_key` clears it"), P4-T1, P4-T3 ("a `resolved`
latest event with a progressed status produces no error"), P5-T1, P5-T3 ("allow when the item's
latest drift event is `resolved`"), and P6-T1 — are executed against this derivation instead: the
condition each of those tasks calls "`resolved`" is the negation of `has_unresolved_drift`, computed
by disjunct (a) or (b). No task adds a `resolved` enum member.

### `merge_status` value `blocked_drift` and the invariant-8 joint write

- **Enum (eight members),** `_parallel_state_common.py:46-51`:
  ```python
  VALID_MERGE_STATUS: tuple[str, ...] = tuple(
      (
          "not_started worktree_created pr_open ci_green merged worktree_removed "
          "blocked_drift blocked_ci_loop_limit"
      ).split()
  )
  ```
- **Invariant 8** (`.claude/rules/parallel-orchestration.md:37`), verbatim:

  > 8. **State/merge-status consistency.** An item whose `merge_status` is `merged` or
  > `worktree_removed` must have `state == 'merged'`. An item whose `merge_status` is
  > `blocked_drift` or `blocked_ci_loop_limit` must have `state == 'blocked'`.

- Enforcement (`_parallel_state_common.py:88` and `:328-332`):
  ```python
  BLOCKED_MERGE_STATUSES: tuple[str, ...] = ("blocked_drift", "blocked_ci_loop_limit")
  ...
      if merge_status in BLOCKED_MERGE_STATUSES and state != "blocked":
          return [
              f"{context} merge_status {merge_status!r} requires state "
              f"'blocked'; found: {state!r}."
          ]
  ```
- **RECORDED AS A JOINT WRITE.** The recolor seam (P2-T5) must request **both** writes atomically:
  `merge_status = "blocked_drift"` **and** `state = "blocked"`. Requesting `merge_status` alone
  produces a checkpoint that fails invariant 8 at the next validation. F5 confirms `blocked_drift`
  is F8's alone to write (`SKILL.md:394-395`, verbatim): "Never written by this feature:
  `blocked_drift`, which only F8 writes; `conflict_edges[]`, seeded by `parallel-planner` and
  recomputed only by F8; `mutations[]`, which only F6 appends to; and `drift_events[]`, which only
  F8 appends to."

### `mutations[]` shape (invariant 16) and the `disposition` null rule (invariant 17)

Invariant 16 (`.claude/rules/parallel-orchestration.md:53`), verbatim:

> 16. **Mutation shape.** Each `mutations[]` entry must satisfy the mutation table: `op` in
> `{add, remove, close, requeue}`; `item_key` resolving to an `items[].issue_num` for `add`,
> `remove`, and `requeue`, and null for `close` (a run-level operation); a non-empty `at`;
> `prior_state` and `new_state` either null or in the item-state enum, with `prior_state` null for
> `add` and `close` and `new_state` null for `close`; and `recolor_generation` a non-negative
> integer that is `<=` the top-level `recolor_generation`. Transition legality — which state may
> follow which — is downstream behavior, not schema; this validator checks shape, enum membership,
> and the null rules only.

Invariant 17 (`:55`), verbatim:

> 17. **In-flight removal requires a disposition.** A `mutations[]` entry with `op == 'remove'` and
> `prior_state == 'in_flight'` must carry `disposition` exactly `'detach'` or `'abandon'`. A
> `disposition` on any other entry must be null.

Enforcement: `validate_mutations` (`_parallel_state_records.py:212-264`), delegating to
`_validate_mutation_item_key`, `_validate_mutation_state_field`, `_validate_mutation_disposition`,
`_validate_mutation_generation`. Constants: `VALID_MUTATION_OPS = ("add", "remove", "close",
"requeue")` (`_parallel_state_common.py:64`); `VALID_DISPOSITIONS = ("detach", "abandon")` (`:68`),
with the comment "A null disposition is expressed by absence, not by an enum member" (`:66-67`);
`OPS_REQUIRING_NULL_PRIOR_STATE = ("add", "close")` (`_parallel_state_records.py:53`);
`OPS_REQUIRING_NULL_NEW_STATE = ("close",)` (`:56`).

#### CORRECTION for Phase 2 — the plan's `new_state: "blocked_drift"` is schema-invalid

`_validate_mutation_state_field` (`_parallel_state_records.py:132-143`), verbatim:

```python
    value = entry.get(field)
    if value is None:
        return []
    if op in null_ops:
        return [
            f"{entry_context} {field} must be null for op {op!r}; found: {value!r}."
        ]
    if value not in VALID_ITEM_STATES:
        return [
            f"{entry_context} {field} must be null or one of "
            f"{', '.join(VALID_ITEM_STATES)}; found: {value!r}."
        ]
    return []
```

`prior_state` and `new_state` are validated against `VALID_ITEM_STATES` — the item-state enum
`proposed admitted prepared scheduled in_flight merged withdrawn blocked`
(`_parallel_state_common.py:39-41`). `blocked_drift` is a **`merge_status`**, not an item state, so
plan task P2-T5's stated entry shape
`{ op, item_key, at, prior_state: "in_flight", new_state: "blocked_drift", disposition: null, recolor_generation: <new> }`
would be rejected by invariant 16.

**Adopted (corrected) requeue mutation entry shape for P2-T5:**

```
{ op: "requeue", item_key: <issue_num int>, at: <non-empty ISO-8601 str>,
  prior_state: "in_flight", new_state: "blocked", disposition: null,
  recolor_generation: <current + 1> }
```

with the item's `merge_status` set to `blocked_drift` as the separate, joint write required by
invariant 8 (above). This correction is independently corroborated by F6's own spec, which owns the
mutation table. F6 `spec.md:235`, verbatim row:

> | Drift-induced requeue | `requeue` | item key | `in_flight` | `blocked` | null | `g + 1` |

and F6 `spec.md:117`, verbatim: "drift-induced requeue sets item state `blocked` and per-item
`merge_status` `blocked_drift`". `disposition` is null because invariant 17 permits a non-null
disposition only on an `op == 'remove'` entry with `prior_state == 'in_flight'`; a `requeue` entry
must leave it null.

### Start-of-execution timestamp field

- **ADOPTED FIELD NAME: `worktree_created_at`** (on `items[]`).
- **`in_flight_at` does not exist.** A repo-wide search (`grep -rn "in_flight_at"` across `.py`,
  `.md`, `.ps1`, `.psm1`, `.json`, `.ts`) returns matches only inside F8's own plan, spec, and
  research documents. F3 defines no `in_flight_at`. The orchestrator's statement is confirmed.
- **CORRECTION to the orchestrator's candidate set: F3 defines a third candidate, `started_at`.**
  F3 `spec.md:187` (section `S2`, item field table), verbatim row:

  > | `worktree_created_at`, `started_at`, `merged_at`, `worktree_removed_at` | string or null |
  > optional | lifecycle timestamps; non-empty when string |

  `started_at` was not among the two candidates the orchestrator named. It is recorded here for
  completeness and is **not adopted**, on attestation grounds set out below.

- **Attestation comparison:**

  | Candidate | Rule file | F3 spec | F5 SKILL.md | Status-doc template | Validator | Epic precedent |
  | --- | --- | --- | --- | --- | --- | --- |
  | `worktree_created_at` | YES (`:113`) | YES (`:187`) | implied by "the lifecycle timestamps" (`:380`) | YES (`docs/features/templates/parallel/parallel-status.md:39`) | not shape-checked | YES (`validate_epic_orchestrator_state.py` wave-barrier ordering) |
  | `started_at` | no | YES (`:187`) | no | no | not shape-checked | no |
  | `in_flight_at` | no | no | no | no | no | no |

  `worktree_created_at` is attested by four independent sources; `started_at` by one. Adopting the
  better-attested field is the deterministic choice the orchestrator's instruction directs
  ("adopt `worktree_created_at` ... unless you find a better-attested field" — `started_at` is
  *less* attested, not more).

- **Semantic fit confirmed.** `worktree_created_at` marks the item's execution start, because the
  worktree is created by the item's delegation spawn and `merge_status` becomes `worktree_created`
  at that same moment. `.claude/skills/parallel-orchestrate/SKILL.md:152-153` and `:162-163`,
  verbatim:

  > 2. Each item's worktree is created by that item's delegation spawn,
  >    `Agent(orchestrator, isolation: "worktree", run_in_background: true)`, branched from
  >    `origin/main`.
  > ...
  > 4. Each item's pull request base branch is `main`. Record `worktree_path`, `branch_name`,
  >    `pr_number`, and `pr_url` for the item, and set `merge_status: worktree_created` at spawn.

  `## Cache Doctrine` (`.claude/rules/parallel-orchestration.md:113`), verbatim:

  > - `git worktree list --porcelain` — worktree existence and path (`items[].worktree_path`,
  >   `worktree_created_at`, `worktree_removed_at`).

  Because the field is re-derivable from `git worktree list --porcelain`, an absent or stale value
  is recoverable, which is what makes it a safe halt input.

- **Absence must be tolerated.** No parallel validator shape-checks any lifecycle timestamp: a grep
  for `worktree_created_at|started_at|merged_at|worktree_removed_at` across
  `scripts/dev_tools/_parallel_state_*.py` and `scripts/dev_tools/validate_parallel_*.py` returns
  **zero** matches, and F3's spec marks all four `optional`. P2-T2's missing-timestamp tie-break
  branches are therefore reachable in practice and are required, not defensive padding.

### Other F8-populated fields confirmed present, with no F8 additions

`recolor_generation` (top-level, non-negative int, invariant 12/16 bound), `mutations[]`,
`conflict_edges[]` (read-only for F8 per plan P2-T12), and `drift_events[]` are all in the
checkpoint's required-key set (invariant 1, `.claude/rules/parallel-orchestration.md:29`). F8 adds
no field to any of them.

---

## IC-3b — Validator Dispatch Pattern (F3-owned file, F7-contended)

- **File:** `scripts/dev_tools/validate_parallel_orchestrator_state.py` — **336 lines** (confirmed by
  `wc -l`; matches the orchestrator's stated figure).
- **Aggregation pattern:** `errors.extend(<helper>(state_map, CONTEXT))` inside
  `validate_parallel_orchestrator_state_text`, with `CONTEXT = "Parallel checkpoint"` (line 59).
  Entry-point signature (line 285-287):
  ```python
  def validate_parallel_orchestrator_state_text(
      text: str, *, require_complete: bool = False
  ) -> list[str]:
  ```
- **Structural helpers** live in `scripts/dev_tools/_parallel_state_common.py`,
  `_parallel_state_structures.py`, and `_parallel_state_records.py`, imported in the existing import
  block at lines 38-56. F8's helper `_parallel_orchestrator_state_drift` follows the same
  underscore-prefixed split convention and its single import line goes into that existing block.
- **Aggregation body as landed (lines 319-336), verbatim:**

  ```python
      errors: list[str] = []
      errors.extend(_missing_required_keys(state_map))
      errors.extend(_validate_identity(state_map))
      errors.extend(scan_prohibited_keys(state_map, CONTEXT))
      errors.extend(_validate_collections(state_map))

      # BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
      # F7 (parallel enforcement hooks) owns the retrospective cohort-ordering
      # invariant of design section 9 Layer 2. Its entire edit to this module is
      # one appended `errors.extend(<helper>(state_map, CONTEXT))` call inside
      # this block, plus the helper's import. Nothing else in this function moves,
      # so F7 and F3 cannot contend over the same lines (epic wave-4 rule).
      # Add F7 helper invocations below this line, one per line.
      # END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION

      if require_complete:
          errors.extend(_validate_completion(state_map))
      return errors
  ```

- **F7 SEAM IS F7-OWNED AND CURRENTLY EMPTY.** Lines 325-332 are the comment-delimited block
  `BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` ... `END F7 EXTENSION SEAM --
  PARALLEL_COHORT_BARRIER_VIOLATION`. It contains no helper call, confirming F7 has not landed. The
  rule file records the ownership at `.claude/rules/parallel-orchestration.md` (`## F7 Seam`):
  "The retrospective cohort-ordering invariant `PARALLEL_COHORT_BARRIER_VIOLATION` (design section 9,
  Layer 2) is F7's explicitly assigned addition to the orchestrator validator. It is NOT implemented
  here."
  **F8 MUST NOT add anything inside that block**, and must not touch its comment lines.

- **ADOPTED F8 EDIT LOCATION (P4-T2):** F8's single dispatch call is inserted **immediately after
  the existing line 323, `errors.extend(_validate_collections(state_map))`**, becoming a new line
  324, i.e. **above** the `BEGIN F7 EXTENSION SEAM` comment and outside the seam entirely. F8's
  single import line goes into the existing import block (lines 38-56).

- **Merge-conflict non-overlap, computed:** with git's default three-line diff context, F8's hunk
  spans source lines 321-327 (three lines of leading context 321-323, the inserted line, three
  lines of trailing context 325-327) and F7's hunk spans source lines 329-334 (leading context
  329-331, the inserted line, trailing context 332-334). The two ranges [321..327] and [329..334]
  are **disjoint**, with a two-line gap, so the two concurrent edits merge cleanly and cannot
  produce a git merge conflict. The gap between the two insertion points is eight lines, consistent
  with the orchestrator's "at least seven lines above".

- **Observation (no scope change).** A TypeScript parity port carries the matching seam at
  `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
  (`.claude/rules/parallel-orchestration.md`, `## F7 Seam`: "The TypeScript core ... carries the
  matching comment-delimited seam"). The approved plan assigns F8 no TypeScript task, so none is
  performed. This is recorded only so the asymmetry is visible to review and is not read as an
  omission introduced by F8.

- **Deviation:** none. The pattern, the helper-split convention, and the F7 seam are exactly as the
  plan's P4-T1 and P4-T2 assume.

---

## IC-5a — Kickoff Marker

- **Source:** `.claude/skills/parallel-orchestrate/SKILL.md`, section
  `## Parallel-Mode Kickoff Parameter` (heading at line 172), element 1 at lines 177-179.
- **Full marker line, quoted VERBATIM (SKILL.md line 179, including its blockquote prefix and
  backticks as they appear in the file):**

  ```
     > `Parallel mode: true. parallel_slug: <slug>. parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json. cohort_index: <n>. PR base branch MUST be main; pass --base main to gh pr create.`
  ```

  The marker line as emitted into a delegation prompt (blockquote and backticks stripped):

  ```
  Parallel mode: true. parallel_slug: <slug>. parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json. cohort_index: <n>. PR base branch MUST be main; pass --base main to gh pr create.
  ```

- **EXACT SUBSTRING the Phase-5 hook constant will match byte-for-byte:**

  ```
  Parallel mode: true
  ```

  (19 characters: `P`,`a`,`r`,`a`,`l`,`l`,`e`,`l`,space,`m`,`o`,`d`,`e`,`:`,space,`t`,`r`,`u`,`e`.
  No trailing period; the period in the marker line terminates the first clause and is not part of
  the token.)

- **Authority for byte-exactness (SKILL.md lines 181-183), verbatim:**

  > The token `Parallel mode: true` must appear exactly: it is the marker F7's Layer 1 barrier hook
  > matches on. The clause `PR base branch MUST be main` is the child's explicit base-branch
  > instruction, recorded as prompt text rather than left to a base-branch ancestry heuristic.

- **`parallel_checkpoint_path` element confirmed present** in the marker line with the literal value
  `artifacts/orchestration/parallel-orchestrator-state.json`, which the P5-T1 hook reads.
- **Target-item resolution for the hook** (SKILL.md lines 184-186), verbatim:

  > 2. The item's active feature folder path, written literally as `docs/features/active/<basename>`.
  >    The child needs it for its own operation, and F7's Layer 1 hook resolves the target item by
  >    scanning the prompt for exactly that path shape, so the path is emitted as a bare path token.

  F8's drift-gate hook adopts the same prompt-scanning shape, so both Layer-1 hooks resolve the
  target item identically.
- **Negative obligation relevant to F8's hook** (SKILL.md lines 202-206): the parallel prompt never
  carries the epic-mode marker, so the epic wave-barrier hook does not fire on a parallel child.
  F8's hook must likewise not match the epic marker.
- **`.claude/agents/parallel-orchestrator.md` cross-check:** the agent file does not restate the
  marker; it delegates to the skill (lines 142-143, verbatim): "carrying the parallel-mode kickoff
  prompt defined in the `parallel-orchestrate` skill's `## Parallel-Mode Kickoff Parameter`
  section." The SKILL.md is therefore the single authoritative source for the hook constant.
- **Deviation:** none.

---

## IC-5b — Reserved Placeholder Section and Worktree-Path Field

### RECONCILED DEVIATION — placeholder title differs from the plan's assumption

- **Title actually found: `## Radius Drift Detection (F8)`** at
  `.claude/skills/parallel-orchestrate/SKILL.md:443`.
- **The plan assumed `## Radius Drift Detection and Drift Gate`** (plan constraint 3 at lines 52-53,
  and tasks P6-T1 and P6-T2). That title **does not exist** in the file.
- Section as landed (lines 443-445), verbatim:

  ```
  ## Radius Drift Detection (F8)

  Reserved for F8; content is appended by that feature and must not be relocated.
  ```

- **ADOPTED RESOLUTION:** Phase 6 (P6-T1) appends F8 content **INTO the existing
  `## Radius Drift Detection (F8)` section**, replacing or extending its one-line reserved
  placeholder in place. Phase 6 **does NOT** create a differently-titled section, **does NOT** rename
  or retitle the existing one, and **does NOT** append at end of file. The placeholder's own
  instruction is binding: "content is appended by that feature and must not be relocated."
  P6-T1's and P6-T2's acceptance criteria are read against the actual title
  `## Radius Drift Detection (F8)`.

### Sibling reserved sections — do not touch

Two sibling placeholders are owned by the two concurrently-executing wave-4 features and must not be
touched, relocated, reordered, or retitled by any F8 edit:

- `## Mutation Protocol (F6)` at line 435, body line 437: "Reserved for F6; content is appended by
  that feature and must not be relocated."
- `## Enforcement Hooks (F7)` at line 439, body line 441: "Reserved for F7; content is appended by
  that feature and must not be relocated."

Section order as landed, which F8 preserves exactly: `## Mutation Protocol (F6)` (435),
`## Enforcement Hooks (F7)` (439), `## Radius Drift Detection (F8)` (443). Because F8's section is
the **last** H2 in the file, an in-place fill of its body cannot reflow either sibling.

### Child-worktree locating field

- **Adopted field: `items[].worktree_path`.**
- Attested in three places:
  - `.claude/rules/parallel-orchestration.md:113` (`## Cache Doctrine`), verbatim:
    "`git worktree list --porcelain` — worktree existence and path (`items[].worktree_path`,
    `worktree_created_at`, `worktree_removed_at`)."
  - F3 `spec.md:181` (S2 item table), verbatim row:
    "| `worktree_path` | string or null | optional | non-empty when string |"
  - `.claude/skills/parallel-orchestrate/SKILL.md:162-163`, verbatim: "Record `worktree_path`,
    `branch_name`, `pr_number`, and `pr_url` for the item, and set `merge_status: worktree_created`
    at spawn."
- Type note for P5-T1: the field is **optional and may be null**. The finding-presence seam must
  fail closed (deny) when `worktree_path` is absent or null, consistent with P5-T1's "fails closed
  (deny) on ... an unresolvable target item".
- **Deviation:** none on the field name.

### F5-side confirmations that constrain F8

`.claude/skills/parallel-orchestrate/SKILL.md:394-397`, verbatim:

> Never written by this feature: `blocked_drift`, which only F8 writes; `conflict_edges[]`, seeded by
> `parallel-planner` and recomputed only by F8; `mutations[]`, which only F6 appends to; and
> `drift_events[]`, which only F8 appends to. These are read for projection and for scheduling context
> and are otherwise untouched.

`SKILL.md:159-161`, verbatim, which places drift recording with F8:

> Real path overlap that survives that reconciliation is drift; the
> conflict outcome is handled per `## Per-Item Merge-Conflict Handling`, and drift recording
> itself belongs to F8.

`SKILL.md:370-373` (`## Parallel-Level Checkpoint`), verbatim:

> This section is consumption documentation only. The checkpoint schema is owned by F3, defined once
> as prose invariants in `.claude/rules/parallel-orchestration.md`, and enforced by
> `scripts/dev_tools/validate_parallel_orchestrator_state.py`. Consume that schema; add no field to it
> and extend no enum in it.

---

## IC-6a — Quiesce Predicate Export (cross-feature acceptance dependency)

- **F6 HAS NOT LANDED.** Verified three ways:
  1. `## Mutation Protocol (F6)` in `.claude/skills/parallel-orchestrate/SKILL.md` is still the
     one-line reserved placeholder (line 435 heading, line 437 body: "Reserved for F6; content is
     appended by that feature and must not be relocated.").
  2. `docs/features/active/2026-08-07-parallel-mutation-protocol-442/` contains only `issue.md`,
     `plan.md`, `research/`, `spec.md`, `user-story.md` — no `evidence/` folder, and its `spec.md`
     acceptance criteria are all unchecked (`- [ ]`, e.g. lines 525-526).
  3. No F6 module exists: `grep -rn "requeue_via_recolor|def recolor|recolor("` across `scripts/`
     and `.claude/` (`.py`, `.ps1`, `.psm1`) returns **zero** matches, and
     `grep -rln "parallel_mutation" scripts/ .claude/` returns nothing.
  F6 is issue #442 and is executing concurrently with F8 in a separate worktree.

- **ADOPTED CONTRACT:** F8 exports `has_unresolved_drift(events) -> bool` from
  `scripts/dev_tools/parallel_drift_detection.py` **regardless of F6's landing state**. The export is
  unconditional; F6's landing is not a precondition for it.
- **The consultation edge is F6's to wire, recorded as a cross-feature acceptance dependency, not an
  F8 blocker.** F8 delivers the predicate; F6's admission-control path calls it. Nothing in F8's
  plan depends on that call existing.
- **Additional finding (strengthens the above):** F6's `spec.md` currently contains **no** reference
  to `has_unresolved_drift`, "unresolved drift", or "quiesce" (grep returns zero matches). The
  consultation edge is therefore not yet present in F6's own specification. This is recorded as an
  outstanding cross-feature dependency for F6 to wire, and is captured for the P7-T9 acceptance
  check-off as an F6 acceptance dependency rather than an F8 deliverable, per plan P1-T4 and the
  plan's Open Questions note (lines 524-525).
- **No quiesce field is written anywhere.** Quiesce is derived state only, computed by
  `has_unresolved_drift` from `drift_events[]` plus the resolution derivation adopted under IC-3a.
  This is consistent with the Enum Ownership and "add no field" constraints.
- **Deviation:** none from the plan's stated IC-6a contract. Citation: design §8.6.

---

## IC-6b — Single Recolor Seam

- **F6's recolor entry point is NOT callable on the branch.** Confirmed under IC-6a: no
  `requeue_via_recolor`, no `recolor_unstarted`, and no F6 module exists in `scripts/` or `.claude/`.
- **CORRECTION to the plan's assumed entry-point name.** The plan (constraint 5, lines 64-66, and
  P2-T5) assumes F6's entry point is `requeue_via_recolor(...)`. F6's own `spec.md:270-276` names it
  **`recolor_unstarted`**, with this expected shape (verbatim):

  ```python
  def recolor_unstarted(
      unstarted_items: Sequence[str],            # item keys, state in {proposed..scheduled}
      conflict_edges: Sequence[tuple[str, str]], # full graph; induced subgraph taken internally
      pinned: frozenset[str],                    # item keys with state in_flight
      current_generation: int,
  ) -> RecolorResult:                            # cohorts for unstarted items only,
      ...                                        # generation == current_generation + 1
  ```

  F6's spec explicitly marks these as provisional (`spec.md:267`, verbatim): "Expected engine shapes
  (final names fixed at plan time; normative in intent)." Neither `requeue_via_recolor` nor
  `recolor_unstarted` is bindable now.
- **Signature-instability note:** F6's provisional shapes key items by `str`
  (`Sequence[str]`, `frozenset[str]`), whereas F3's landed schema makes `issue_num` a positive
  **integer** primary key (invariant 5; `_resolves` requires a non-boolean `int`,
  `_parallel_state_records.py:59-72`). F6 must reconcile that at its own plan time. F8's seam
  therefore must not encode F6's provisional signature at all.

- **ADOPTED IC-6b RESOLUTION (stub-seam decision):** Phase 2 implements **exactly ONE** named seam
  function in `scripts/dev_tools/parallel_drift_detection.py` containing a **documented stub** that
  F6's landing replaces or delegates to. There is **no second recolor implementation**, and the seam
  contains **no coloring, cohort, or graph logic**. The stub's docstring cites IC-6b and design
  §8.6, and names F6 (issue #442) as the owner of the operation it requests.

- **The seam RETURNS THE REQUESTED MUTATION INTENT rather than performing the recolor.** Basis:
  `scripts/dev_tools/parallel_cohort_computation.py` (468 lines, F2/#445, landed) exposes **only
  pure cohort computation** and **no reusable recolor entry point**. Its entire public surface is:
  - `compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]`
    (line 350) — Welsh-Powell greedy coloring over a full graph; docstring lines 392-394, verbatim:
    "None. This function is pure: no file I/O, no network, no clock or RNG access, and no mutation
    of either input argument."
  - `compute_concurrency_batches(...)` (line 419) — chunks one cohort into concurrency-capped
    batches.
  - `ParallelCohortInputError` (line 66) and the private helpers `_validate_item_keys`,
    `_validate_edge`, `_build_adjacency`, `_welsh_powell_order`, `_assign_cohort_indices`.

  There is no pinned-subgraph recolor, no generation increment, no `mutations[]` append, and no
  checkpoint write anywhere in that module. `compute_cohorts` colors the **whole** graph and knows
  nothing about pinning in-flight items, which is precisely the capability F6's `recolor_unstarted`
  is specified to add. **Therefore the seam cannot delegate to anything that exists today, and the
  adopted stub returns the requested mutation intent** — the joint write and the single mutation
  entry described below — for the caller (and, after F6 lands, F6's entry point) to apply.

- **Adopted mutation intent the seam returns** (corrected per IC-3a and corroborated by F6
  `spec.md:235`):
  - item `merge_status` → `blocked_drift` **and** item `state` → `blocked` (joint write, invariant 8);
  - exactly ONE `mutations[]` entry
    `{ op: "requeue", item_key: <issue_num int>, at: <injected ISO-8601>, prior_state: "in_flight",
    new_state: "blocked", disposition: null, recolor_generation: <current + 1> }`;
  - `recolor_generation` incremented by exactly one.
- **`mutations[].op` value:** `requeue`, a member of the landed `VALID_MUTATION_OPS`
  (`_parallel_state_common.py:64`) and the op F6's spec assigns to a drift-induced requeue
  (`spec.md:235`). This value is available now and does not depend on F6 landing.
- **Deviation from the plan, recorded:** the plan's assumed entry-point name
  `requeue_via_recolor(...)` is not F6's name (`recolor_unstarted`), and neither is callable; and the
  plan's `new_state: "blocked_drift"` is schema-invalid (corrected to `new_state: "blocked"` plus the
  `merge_status` joint write). Citation: design §8.6.

---

## Phase-2 Prohibition Confirmations

### No `depends_on` and no `integration_branch` anywhere (invariants 10, 11)

Invariants 10 and 11 (`.claude/rules/parallel-orchestration.md:45`, `:47`), verbatim:

> 10. **Prohibited dependency edges.** No object anywhere in the checkpoint may carry a `depends_on`
> key, and no top-level `depends_on` key may be present. Ordering is expressed only as blast-radius
> overlap. Presence is an explicit rejection, not mere absence.
>
> 11. **Prohibited integration-branch fields.** The checkpoint must not carry `integration_branch` or
> `epic_merge_pr` at any level. Each parallel item opens its own pull request against `main`, so
> there is no integration branch and no final integration pull request.

Enforcement constant (`scripts/dev_tools/_parallel_state_common.py:96-101`), verbatim:

```python
# Keys the checkpoint schemas reject wherever they appear. ``depends_on`` is
# rejected because ordering is derived from blast-radius overlap and never
# declared; the integration-branch keys are rejected because each parallel item
# opens its own pull request against ``main`` (spec S8, design section 4).
PROHIBITED_ANY_LEVEL_KEYS: tuple[str, ...] = tuple(
    "depends_on integration_branch epic_merge_pr".split()
)
```

Scanned by `scan_prohibited_keys(state_map, CONTEXT)` at
`validate_parallel_orchestrator_state.py:322`. F5 restates the absence at
`.claude/skills/parallel-orchestrate/SKILL.md:28` ("there is no `depends_on` field on this surface")
and `:71` ("The manifest carries no `depends_on` key at any level and no top-level
`integration_branch` key").

**Confirmed for Phase 2's use:** no F8 code introduces a `depends_on`, `integration_branch`, or
`epic_merge_pr` key at any level, in any module, test fixture, or in-memory checkpoint structure. An
F8-authored fixture carrying one would be rejected by the landed validator, so the prohibition is
enforced, not merely documented.

### Adopted symbols F8 imports rather than redefines

| Purpose | Symbol | Module |
| --- | --- | --- |
| Path subsumption (IC-1a) | `is_path_subsumed` | `scripts.dev_tools._blast_radius_glob` |
| Contention relation (IC-1b) | `conflicts` | `scripts.dev_tools.compute_blast_radius` (facade) |
| Observed radius (IC-1b) | `radius_from_observed_paths` | `scripts.dev_tools.compute_blast_radius` |
| Radius value object | `BlastRadius` | `scripts.dev_tools.compute_blast_radius` |
| Drift action enum (IC-3a) | `VALID_DRIFT_ACTIONS` | `scripts.dev_tools._parallel_state_common` |
| Item-state enum (mutation `new_state`) | `VALID_ITEM_STATES` | `scripts.dev_tools._parallel_state_common` |
| Merge-status enum | `VALID_MERGE_STATUS` | `scripts.dev_tools._parallel_state_common` |

---

## Corrections Made to the Orchestrator's Stated Findings

1. **IC-1a provenance (citation precision).** `is_path_subsumed` did not receive the #452
   correction; its body is byte-identical pre- and post-#452 (it moved from
   `_blast_radius_extraction.py:458` to `_blast_radius_glob.py:140` as a pure module split in commit
   `7a835c38`). #452 corrected the *other* side of the relation, `_entries_overlap`, to agree with
   `is_path_subsumed`. Operational conclusion unchanged: `is_path_subsumed` is the fail-closed form
   F8 must import.
2. **IC-1a import location.** `is_path_subsumed` is not re-exported by the
   `compute_blast_radius` facade, so F8 must import it from the underscore-prefixed module
   `scripts.dev_tools._blast_radius_glob`. Recorded so the import is not later read as a boundary
   violation.
3. **IC-3a start-timestamp candidate set.** F3 defines a third candidate the orchestrator did not
   name: `started_at` (F3 `spec.md:187`). It is **not** adopted, because `worktree_created_at` is
   attested by four independent sources versus one. `worktree_created_at` is adopted as instructed.
4. **Mutation `new_state` is schema-invalid as written in the plan.** `mutations[].new_state` is
   validated against the **item-state** enum, not the merge-status enum
   (`_parallel_state_records.py:139`), so P2-T5's `new_state: "blocked_drift"` would be rejected.
   Corrected to `new_state: "blocked"` plus the `merge_status: blocked_drift` joint write required by
   invariant 8. Independently corroborated by F6 `spec.md:235` and `spec.md:117`.
5. **IC-6b entry-point name.** F6's spec names the recolor entry point `recolor_unstarted`
   (`spec.md:270`), not the plan's assumed `requeue_via_recolor`. Neither is callable; the stub-seam
   decision stands and must not encode F6's provisional signature.
6. **IC-6a is not yet in F6's specification.** F6's `spec.md` contains no reference to
   `has_unresolved_drift` or quiesce, so the consultation edge is an outstanding F6 acceptance
   dependency, not merely an unwired one.
7. **IC-5b placeholder title** confirmed as the orchestrator stated: `## Radius Drift Detection (F8)`,
   not the plan's `## Radius Drift Detection and Drift Gate`. Recorded as a reconciled deviation; no
   correction to the orchestrator was needed.

Everything else in the orchestrator's stated findings was verified against the files and is accurate
as stated, including: all six wave-0..wave-3 features landed with no BLOCKED state; `conflicts`
takes a third `config` argument and returns `ConflictResult` with `.conflict` and `.reasons`;
`radius_from_observed_paths` shipped for drift detection; the `action` enum has exactly two members
with no `resolved`; the A8 strongest-action recording rule; invariant 8's joint-write requirement;
the validator is 336 lines with the `errors.extend(<helper>(state_map, CONTEXT))` pattern and an
empty F7 seam; the F8 dispatch call goes immediately after `_validate_collections` with no
merge-conflict risk; the `Parallel mode: true` token; `items[].worktree_path`; the two sibling
reserved sections; F6 not landed; and `parallel_cohort_computation.py` exposing only pure cohort
computation.
