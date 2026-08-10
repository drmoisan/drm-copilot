# Upstream Dependency Reconciliation (F1 / F1a / F2 / F3) — parallel-planner-surface (#443)

Timestamp: 2026-08-08T13-56

Tasks covered: [P1-T1], [P1-T2], [P1-T3]
Plan: `docs/features/active/2026-08-07-parallel-planner-surface-443/plan.2026-08-07T11-11.md`
Feature branch: `feature/parallel-planner-surface-443`
Worktree root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59`

## Resolved Refs

Command: `git fetch origin`
EXIT_CODE: 0

Command: `git rev-parse origin/epic/parallel-orchestration-integration`
EXIT_CODE: 0
Output Summary: `1a402e8eaa98e3ff1c7fbe91aebb46029cfa3595`

**`<UPSTREAM>` = `origin/epic/parallel-orchestration-integration` = `1a402e8eaa98e3ff1c7fbe91aebb46029cfa3595`**

Command: `git log -1 --format="%H%n%ad%n%s" origin/epic/parallel-orchestration-integration`
EXIT_CODE: 0
Output Summary:

```
1a402e8eaa98e3ff1c7fbe91aebb46029cfa3595
Sat Aug 8 13:47:55 2026 -0400
docs(epic): record F1a delivery and release wave 2
```

Command: `git rev-parse HEAD` / `git rev-parse --abbrev-ref HEAD` / `git merge-base HEAD origin/epic/parallel-orchestration-integration`
EXIT_CODE: 0
Output Summary:

```
b086cf6958ee4b628f60309cda80aac772304bc8
feature/parallel-planner-surface-443
b086cf6958ee4b628f60309cda80aac772304bc8
```

Worktree HEAD (`b086cf69`) is an ancestor of `<UPSTREAM>`; the branch is exactly one commit behind.

Command: `git diff --name-only b086cf6958ee4b628f60309cda80aac772304bc8 origin/epic/parallel-orchestration-integration`
EXIT_CODE: 0
Output Summary:

```
docs/features/epics/parallel-orchestration/epic-status.md
docs/features/epics/parallel-orchestration/epic.md
```

The single-commit gap is documentation only (epic manifest and status projection). No F1/F2/F3 contract surface differs between the worktree and `<UPSTREAM>`, so every check below returns the same verdict on both surfaces.

Command: `git log --oneline -12 origin/epic/parallel-orchestration-integration`
EXIT_CODE: 0
Output Summary:

```
1a402e8e docs(epic): record F1a delivery and release wave 2
b086cf69 Merge pull request #453 from drmoisan/bug/blast-radius-under-reporting-452
4a90a8df docs(blast-radius): record feature review for issue #452
7a835c38 fix(blast-radius): reach separator-free root surfaces and honour directory prefixes in conflicts
6dfd082b docs(epic): record authorized F1a correction and reopen wave 1
05c48ced docs(epic): record wave 1 complete and hold wave 2
12174c41 merge(epic): fan in F3 parallel-schema-validators (#444)
e6b25a41 docs(parallel): record feature review and cycle-1 reaudit artifacts
dac03eb3 docs(parallel): qualify cross-runtime parity claim in the parallel rule file
3eb6b348 feat(parallel): add parallel manifest and checkpoint schemas with validators
302affb2 docs(epic): add parallel-orchestration status projection
ae6331f7 merge(epic): fan in F1 parallel-blast-radius (#450)
```

---

# [P1-T1] Landing-Status Re-Verification

## Check (a) — feature folders under `docs/features/active/`

### `<UPSTREAM>` ref result

Command: `git ls-tree --name-only origin/epic/parallel-orchestration-integration docs/features/active/`
EXIT_CODE: 0
Output Summary (relevant entries only; 43 entries total):

```
docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452
docs/features/active/2026-08-07-parallel-blast-radius-447
docs/features/active/2026-08-07-parallel-cohort-scheduler-445
docs/features/active/2026-08-07-parallel-planner-surface-443
docs/features/active/2026-08-07-parallel-schema-validators-444
```

### Worktree filesystem result

Command: `ls docs/features/active/`
EXIT_CODE: 0
Output Summary (relevant entries only; 43 entries total):

```
2026-08-07-blast-radius-under-reporting-gaps-452/
2026-08-07-parallel-blast-radius-447/
2026-08-07-parallel-cohort-scheduler-445/
2026-08-07-parallel-planner-surface-443/
2026-08-07-parallel-schema-validators-444/
```

Check (a) verdict: `parallel-blast-radius` (F1), `parallel-cohort-scheduler` (F2), and `parallel-schema-validators` (F3) feature folders are present on **both** surfaces. The F1a correction folder `blast-radius-under-reporting-gaps-452` is present on both surfaces as well.

## Check (b) — production modules under `scripts/dev_tools/`

### `<UPSTREAM>` ref result

Command: `git ls-tree --name-only origin/epic/parallel-orchestration-integration scripts/dev_tools/`
EXIT_CODE: 0
Output Summary (relevant entries only; 89 entries total):

```
scripts/dev_tools/_blast_radius_conflicts.py
scripts/dev_tools/_blast_radius_extraction.py
scripts/dev_tools/_blast_radius_glob.py
scripts/dev_tools/_blast_radius_thresholds.py
scripts/dev_tools/_blast_radius_validation.py
scripts/dev_tools/compute_blast_radius.py
scripts/dev_tools/_parallel_state_common.py
scripts/dev_tools/_parallel_state_records.py
scripts/dev_tools/_parallel_state_structures.py
scripts/dev_tools/parallel_cohort_computation.py
scripts/dev_tools/parallel_manifest_contract.py
scripts/dev_tools/validate_parallel_orchestrator_state.py
scripts/dev_tools/validate_parallel_planner_state.py
```

`scripts/dev_tools/parallel_kickoff_contract.py` is **ABSENT** from this listing.

### Worktree filesystem result

Command: `ls scripts/dev_tools/ | grep -Ei "blast|cohort|parallel"`
EXIT_CODE: 0
Output Summary:

```
_blast_radius_conflicts.py
_blast_radius_extraction.py
_blast_radius_glob.py
_blast_radius_thresholds.py
_blast_radius_validation.py
_parallel_state_common.py
_parallel_state_records.py
_parallel_state_structures.py
compute_blast_radius.py
parallel_cohort_computation.py
parallel_manifest_contract.py
validate_parallel_orchestrator_state.py
validate_parallel_planner_state.py
```

`scripts/dev_tools/parallel_kickoff_contract.py` is **ABSENT** from this listing.

Check (b) verdict: `compute_blast_radius.py` (F1, with five `_blast_radius_*` helper modules), `parallel_cohort_computation.py` (F2), and the `validate_parallel_*` validators plus `parallel_manifest_contract.py` and three `_parallel_state_*` helpers (F3) are present on **both** surfaces. All three upstream features are implementation-landed, not merely spec-landed.

## Check (c) — MCP `VALID_ARTIFACT_TYPES` in `extensions/drm-copilot/src/mcp-tool-inputs.ts`

### `<UPSTREAM>` ref result

Command: `git show origin/epic/parallel-orchestration-integration:extensions/drm-copilot/src/mcp-tool-inputs.ts | grep -n -A 12 "VALID_ARTIFACT_TYPES"`
EXIT_CODE: 0
Output Summary:

```
427:const VALID_ARTIFACT_TYPES = new Set([
428-  "plan",
429-  "policy-audit",
430-  "code-review",
431-  "feature-audit",
432-  "orchestrator-state",
433-  "epic-orchestrator-state",
434-  "epic-planner-state",
435-  "epic-kickoff",
436-  "parallel-orchestrator-state",
437-  "parallel-planner-state",
438-]);
```

### Worktree filesystem result

Command: `grep -n -A 12 "VALID_ARTIFACT_TYPES = new Set" extensions/drm-copilot/src/mcp-tool-inputs.ts`
EXIT_CODE: 0
Output Summary: byte-identical to the `<UPSTREAM>` result above (same line numbers 427-438, same ten members).

Check (c) verdict: two `parallel` artifact types are registered on **both** surfaces — `parallel-orchestrator-state` and `parallel-planner-state`. Exactly as F3's Decision 3.2-A promised, the MCP surface grew by exactly two values. `epic-kickoff` is present as the epic analogue, confirming the pattern F4 is to mirror.

## Check (d) — `.claude/rules/parallel-orchestration.md` and the `parallel` route

### `<UPSTREAM>` ref result — rules file

Command: `MSYS2_ARG_CONV_EXCL='*' git show 'origin/epic/parallel-orchestration-integration:.claude/rules/parallel-orchestration.md' | wc -l`
EXIT_CODE: 0
Output Summary: `184` (file present, 184 lines)

### Worktree filesystem result — rules file

Command: `wc -l .claude/rules/parallel-orchestration.md`
EXIT_CODE: 0
Output Summary: `184` (file present, 184 lines — identical line count)

### `<UPSTREAM>` ref result — `parallel` route

Command: `git show origin/epic/parallel-orchestration-integration:config/orchestration-routing.json | grep -n -B 2 -A 10 '"parallel"'`
EXIT_CODE: 0
Output Summary:

```
100:    "parallel": {
101-      "description": "Parallel path for scheduling independent items into blast-radius cohorts across parallel worktrees; each item PRs to main independently with no integration branch.",
102-      "requires_pr_gate": false,
103-      "required_agents": [ "orchestrator", "pr-author" ],
107-      "required_skills": [ "parallel-orchestrate", "orchestrate", "feature-promotion-lifecycle", ...
```

### Worktree filesystem result — `parallel` route

Command: `grep -n -A 3 '"parallel": {' config/orchestration-routing.json`
EXIT_CODE: 0
Output Summary:

```
100:    "parallel": {
101-      "description": "Parallel path for scheduling independent items into blast-radius cohorts across parallel worktrees; each item PRs to main independently with no integration branch.",
102-      "requires_pr_gate": false,
103-      "required_agents": [
```

Check (d) verdict: the F3-owned rules file and the `route_id: parallel` entry are present on **both** surfaces, at the same location and with the same content.

## Per-Upstream-Feature Verdicts

An upstream feature is treated as landed when its artifacts are present on **either** surface. All four are present on **both**.

| Upstream feature | Issue / PR | Verdict | Landing granularity | Evidence |
| --- | --- | --- | --- | --- |
| **F1 — `parallel-blast-radius`** | #447, merged PR #450 | **landed-divergent** | **implementation-landed** | Check (a): feature folder on both surfaces. Check (b): `compute_blast_radius.py` plus `_blast_radius_conflicts.py`, `_blast_radius_extraction.py`, `_blast_radius_glob.py`, `_blast_radius_thresholds.py`, `_blast_radius_validation.py` on both surfaces. `config/blast-radius.json` present in worktree. |
| **F1a — `blast-radius-under-reporting-gaps`** | #452, merged PR #453 | **landed-consistent** | **implementation-landed** | Check (a): feature folder on both surfaces. Corrections verified in-code (see the F1a disposition below). Commit `7a835c38` on `<UPSTREAM>`. |
| **F2 — `parallel-cohort-scheduler`** | #445, merged PR #449 | **landed-divergent** | **implementation-landed** | Check (a): feature folder on both surfaces. Check (b): `parallel_cohort_computation.py` on both surfaces. |
| **F3 — `parallel-schema-validators`** | #444, merged PR #451 | **landed-consistent** | **implementation-landed** | Check (a): feature folder on both surfaces. Check (b): `validate_parallel_planner_state.py`, `validate_parallel_orchestrator_state.py`, `parallel_manifest_contract.py`, three `_parallel_state_*` helpers on both surfaces. Check (c): two `parallel` artifact types on both surfaces. Check (d): rules file and `parallel` route on both surfaces. |

The `landed-divergent` verdicts for F1 and F2 record contract-detail divergences only (invocation shape and return-value shape). Neither contradicts any non-negotiable constraint in the plan's Scope Summary, and neither invalidates a task acceptance criterion. Both are dispositioned as case-3 supersessions in [P1-T2] below.

---

# [P1-T2] Assumption Reconciliation and Disposition

The spec's `[ASSUMPTION]` entries were authored at commit base `5a0becb0`, when F1/F2/F3 had not landed. Every entry is dispositioned below against the landed contract at `<UPSTREAM>` `1a402e8e`. Each disposition line cites `<UPSTREAM>` `1a402e8eaa98e3ff1c7fbe91aebb46029cfa3595`.

Because the worktree and `<UPSTREAM>` differ only by two documentation files, the landed specs and modules were read directly from the worktree filesystem rather than by `git show <UPSTREAM>:<path>`; the equivalence is established by the `git diff --name-only` result recorded above. Where a worktree read was used, it is equivalent to the `<UPSTREAM>` read for every path involved.

## Blanket status change

Spec section "Upstream Dependency Status and Assumptions" states: "F1 ..., F2 ..., and F3 ... have NOT landed on `epic/parallel-orchestration-integration`. No `parallel` feature folder other than this one exists under `docs/features/active/`; `scripts/dev_tools/` contains no `compute_blast_radius.py`, no `parallel_cohort_computation.py`, and no `validate_parallel_*` validator; the MCP `VALID_ARTIFACT_TYPES` set ... contains no `parallel` artifact type."

**Disposition: SUPERSEDED in full.** Every one of those four negative statements is now false, as [P1-T1] checks (a)-(d) demonstrate on both surfaces. The `[ASSUMPTION]` regime (case 1) does NOT apply to any entry. Phase 3 skill text must cite the landed contracts, not the assumption labels. Cited at `<UPSTREAM>` `1a402e8e`.

## R3 — F1 blast-radius invocation contract `[ASSUMPTION — F1 unlanded; §5.1-§5.4]` (spec line 128)

**Case 3 — landed and divergent (contract details only). Supersede; author Phase 3 against the landed contract.**

| Assumed contract | Landed contract | Disposition |
| --- | --- | --- |
| Call surface: `scripts/dev_tools/compute_blast_radius.py`, importable **and CLI-invocable** (`poetry run python -m scripts.dev_tools.compute_blast_radius ...`), invoked as a CLI subprocess with JSON output via `Bash(poetry run *)` | Module present and importable. **No CLI entry point**: `grep -n "__main__\|def main" scripts/dev_tools/compute_blast_radius.py` returned EXIT_CODE 1 (no match). The cited precedent `scripts/dev_tools/epic_wave_computation.py` returned no match either — the repository's reference-implementation pattern is an import-only library, so the landed shape follows the precedent the assumption cited, and the assumption's CLI clause was the inaccurate part. | **DIVERGENT — supersede.** Phase 3 (P3-T5) must document the invocation as an importable-library call executed through `Bash(poetry run *)` (for example `poetry run python -c "from scripts.dev_tools.compute_blast_radius import derive_blast_radius, ..."`), not as a `python -m` CLI subprocess. The agent tool allowlist in P2-T1 already grants `Bash(poetry run *)`, so no allowlist change is required and P2-T1's acceptance criteria are unaffected. |
| Inputs: approved atomic plan path, feature `spec.md` path, feature folder path, F1-owned shared-surface configuration truth table; module-mapping source F1-defined and opaque to F4 | `derive_blast_radius(plan_text: str, spec_text: str, feature_folder: str, config: Mapping[str, object], *, source: str = RADIUS_SOURCE_DERIVED, computed_at: str) -> BlastRadius`. Inputs are document **text**, not paths; the config is the parsed `config/blast-radius.json` (file verified present in the worktree). | **DIVERGENT (detail) — supersede.** The four input concepts match; the landed surface takes text and a parsed mapping rather than paths. Phase 3 text must name `config/blast-radius.json` and the text-input shape. The module-mapping source remains F1-defined and opaque to F4, as assumed. |
| Output: JSON `{ "paths", "modules", "shared_surfaces", "contracts", "source": "declared", "computed_at" }` | `BlastRadius` frozen dataclass with `RADIUS_KEYS = ("paths", "modules", "shared_surfaces", "contracts", "source", "computed_at")` and a `to_dict()` serializer; `source` restricted to `RADIUS_SOURCES` and settable to `declared` via the keyword-only `source` parameter. | **CONSISTENT.** The serialized key set matches the assumption exactly. Phase 3 may quote the six keys verbatim. |
| Findings list, each `{ rule: "V1"\|"V2"\|"V3", severity: "Blocking"\|"Advisory", detail }` | `scripts/dev_tools/_blast_radius_validation.py` defines `RULE_COVERAGE = "V1"`, `RULE_SHARED_SURFACE = "V2"`, `RULE_OVER_BREADTH = "V3"`; module docstring records "V1 and V2 are Blocking, V3 Advisory with at most one finding"; entry point `validate_blast_radius(...)`. | **CONSISTENT.** Rule identifiers, severities, and the V1/V2-Blocking, V3-Advisory split all match. P3-T5's acceptance criteria are satisfiable as written. |
| Contention relation: a callable `conflicts(a, b)` returning a verdict with `reason` in `{path_overlap, module_overlap, shared_surface_overlap, contract_dependency}`; fails closed | `conflicts(a: BlastRadius, b: BlastRadius, config: Mapping[str, object]) -> ConflictResult` in `scripts/dev_tools/_blast_radius_conflicts.py:137`. **Third required parameter `config`** added. `CONFLICT_KINDS` = `("path_overlap", "module_overlap", "shared_surface_overlap", "contract_dependency")` (lines 44-48). Docstring: "Any pair the test cannot separate is reported as overlapping, the fail-closed direction." | **DIVERGENT (arity) — supersede.** The reason vocabulary and the fail-closed posture match exactly. Phase 3 text must write `conflicts(a, b, config)`, not `conflicts(a, b)`. The landed docstring notes `config` is read by no key today but is kept in the signature because the contract is frozen for downstream consumers. |
| Validation-result behavior (V1/V2 Blocking re-plan loop; V3 Advisory recorded, no state effect; `prepared` = `PREFLIGHT: ALL CLEAR` AND `declared` radius with V1/V2 pass) | This is F4's own procedure, not an F1 interface. The landed F1 severities support it unchanged. F3's landed planner invariant P7 independently requires `preparation_status == 'prepared'`, `preflight_status == 'PREFLIGHT: ALL CLEAR'`, and `blast_radius.source == 'declared'` under the ready gate. | **CONSISTENT and reinforced.** The F3-owned readiness invariant the assumption anticipated at spec line 161 (`[ASSUMPTION — F3 unlanded; §12]`) has landed and matches. |

**Net effect on the plan: none blocking.** All R3 divergences are contract details quoted in deliverable text (module invocation shape, function arity, input types). Per [P1-T2] case 3, Phase 3 content is authored against the landed contract and the supersession is recorded here. No non-negotiable constraint in the Scope Summary is contradicted; F4 still CALLS F1 and reimplements nothing.

## F1a disposition — `blast-radius-under-reporting-gaps` (#452, merged PR #453)

Read: `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/spec.md` (Work Mode `full-bug`; `spec.md` is its sole AC source).

F1a is a correction to the F1 landed contract, delivered after F1 merged and before F4 executes. Its own spec states the consumer deadline explicitly: "The consumer deadline is F4 (`parallel-planner`, issue #443). Design section 5.2 makes the `declared` radius authoritative for scheduling, and F4 computes the declared radius by calling `derive_blast_radius`. Plan-time blindness therefore propagates into the authoritative radius unless F1 is corrected before F4 is executed." That precondition is satisfied: F1a is landed on both surfaces before this Phase 1 executes.

**Gap 1 — separator-free repository-root shared surfaces are now reachable from plan and spec text, sourced from the config `shared_surfaces` list itself.**

Verification command: `grep -n "root_surface\|separator-free\|root surfaces" scripts/dev_tools/_blast_radius_extraction.py`
EXIT_CODE: 0
Output Summary:

```
224:    token: str, *, root_surfaces: Sequence[str] = ()
230:        root_surfaces (Sequence[str]): Configured separator-free repository-root
232:            ``config_root_surfaces``. Membership is exact and ordinal. The empty
247:    # A separator-free token is admitted only as an exact ordinal member of the
255:    if any(token == surface for surface in root_surfaces):
291:    lines: Sequence[str], *, root_surfaces: Sequence[str] = ()
318:            if classify_path_token(token, root_surfaces=root_surfaces) is not None:
325:    plan_text: str, *, root_surfaces: Sequence[str] = ()
358:        root_surfaces=root_surfaces,
```

The correction is present: `classify_path_token`, `extract_plan_paths`, and the intermediate line scanner all carry a keyword-only `root_surfaces` parameter, admission is exact ordinal membership, and the source is the accessor `config_root_surfaces` in `_blast_radius_validation.py:194`, which reads the config `shared_surfaces` list. This matches the delegation's description: the root-surface set is sourced from the config `shared_surfaces` list itself, not from a second hand-maintained list.

Corroborating comment at `_blast_radius_validation.py:349-352`: "The root-surface set comes from the same `config` mapping that V1 and V2 ... radius passing V1 and V2 against its own plan (issue #452)."

**Gap 2 — the conflicts path comparison now honours listed-directory prefixes on both sides, aligning with `is_path_subsumed`.**

Verification: read `scripts/dev_tools/_blast_radius_glob.py:273-316` (`_entries_overlap`, imported by `_blast_radius_conflicts.py:31` and called at `_blast_radius_conflicts.py:202`).
EXIT_CODE: 0
Output Summary (load-bearing excerpt):

```python
    # ... The two directory rules
    # were added by issue #452; without them a plan citing a directory failed to
    # contend with a plan citing a file inside it, which under-reported the
    # radius in the one direction the design cannot tolerate.
    if not a_is_glob and not b_is_glob:
        return (
            entry_a == entry_b
            or entry_a.startswith(_directory_prefix(entry_b))
            or entry_b.startswith(_directory_prefix(entry_a))
        )
    if a_is_glob and not b_is_glob:
        return matches_glob(entry_a, entry_b) or _prefixes_nest(
            _literal_prefix(entry_a), _directory_prefix(entry_b)
        )
    if b_is_glob and not a_is_glob:
        return matches_glob(entry_b, entry_a) or _prefixes_nest(
            _literal_prefix(entry_b), _directory_prefix(entry_a)
        )
```

The correction is present: the concrete-versus-concrete branch is no longer string equality alone, and the mixed glob-versus-concrete branches add a two-way nest between the glob's literal prefix and the concrete entry's directory prefix. The prefix rule is applied on **both** sides, aligning `_entries_overlap` with the anchored listed-directory prefix rule `is_path_subsumed` already applied.

**Direction of both corrections: fail-closed.** Gap 1 admits tokens that were previously dropped, so radii grow. Gap 2 reports overlap for pairs previously reported as non-overlapping, so the conflict edge set grows. A larger radius and a larger edge set both produce more cohorts and fewer concurrently-scheduled items — the conservative direction. The landed `_entries_overlap` docstring states the posture directly: "Any pair the test cannot separate is reported as overlapping, the fail-closed direction."

**F1a verdict: `landed-consistent`, `implementation-landed`.** F1a changes no interface F4 calls: `derive_blast_radius`, `validate_blast_radius`, and `conflicts` retain their landed signatures; only their return values become more inclusive. No F4 spec `[ASSUMPTION]` entry is invalidated by F1a, and no Phase 2-7 task requires revision because of it. Phase 3 text should state that the radius F4 declares is computed by the F1a-corrected derivation, so plan-time blindness to separator-free root surfaces and to directory-prefix contention no longer propagates into the authoritative `declared` radius.

## R4 — F2 cohort-seeding contract `[ASSUMPTION — F2 unlanded; §6]` (spec line 163)

**Case 3 — landed and divergent (contract details only). Supersede; author Phase 3 against the landed contract.**

| Assumed contract | Landed contract | Disposition |
| --- | --- | --- |
| Call surface: `scripts/dev_tools/parallel_cohort_computation.py`, importable **and CLI-invocable**, deterministic greedy coloring in Welsh-Powell order (descending degree, ties broken by ascending item key) | Module present and importable. **No CLI entry point** (`grep -n "__main__\|def main"` returned EXIT_CODE 1). `compute_cohorts` docstring: "Vertices are visited in Welsh-Powell order — sorted by the composite key `(-degree, item_key)` ascending, that is descending distinct-neighbor degree with ties broken by ascending item key". Helper `_welsh_powell_order` at line 266. | **DIVERGENT (invocation) — supersede.** The ordering rule matches the assumption verbatim in effect. Phase 3 (P3-T6) must document an importable-library call through `Bash(poetry run *)` rather than a CLI subprocess. |
| Inputs: the item-key set (item key = `issue_num`) and the undirected conflict edge set derived by F1's `conflicts(a, b)`; **a pinned-set parameter exists for recoloring (§8.1), empty at seeding time** | `compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]`. **No pinned-set parameter exists.** | **DIVERGENT — supersede, with no effect on F4.** The assumption's pinned-set parameter is absent from the landed signature. F4 is unaffected: the assumption itself states the pinned set is empty at seeding time, and P3-T6 requires "an empty pinned set at seeding time". Recoloring under add/remove/drift is explicitly F6/F8 scope and out of F4's scope, so F4 never needs the parameter. Phase 3 text must not reference a pinned-set argument; it should state that the landed seeding entry point takes item keys and conflict edges only, and that recoloring support is F6/F8's concern. |
| Output: `cohorts[]` of `{ index, generation, item_keys[] }`, `item_keys[]` sorted ascending within each cohort | `list[list[int]]`. Cohort index is the outer list position; `generation` is not returned. Docstring records the one-line derivation of the `item_key -> cohort_index` view. | **DIVERGENT (shape) — supersede.** F4 maps the returned list-of-lists into the F3-owned `cohorts[]` object shape, supplying `index` from list position and `generation: 0` itself. This is exactly what P3-T6 already requires F4 to record (`generation: 0`, `item_keys[]` sorted ascending, `recolor_generation: 0`, `current_cohort: 0`), so no acceptance criterion changes. Phase 3 text must state the mapping rather than implying F2 returns the schema shape. |
| `max_concurrency` (default 4, slots filled in ascending item key) recorded by F4, enforced by F5 | `compute_concurrency_batches(cohort_item_keys: Sequence[int], max_concurrency: int) -> list[list[int]]` is landed in the same module. Docstring: "The cohort's keys are sorted ascending inside this function rather than trusting the caller's ordering". F3's landed rules file fixes the `max_concurrency` bound at 1..8 with default 4 (manifest invariant M4, orchestrator invariant 4, planner invariant P2). | **CONSISTENT and reinforced.** The ascending-item-key slot-filling rule and the default of 4 both match. The 1..8 bound is an F3-owned addition F4 records but does not re-litigate. P3-T6's "recorded by F4 but enforced by F5" statement stands. |

**Net effect on the plan: none blocking.** All R4 divergences are contract details quoted in deliverable text. F4 still CALLS F2 exactly once per plan run and reimplements no coloring logic.

## F3 ownership boundary `[ASSUMPTION — F3 unlanded; §11, §12, epic F3 scope entry]` (spec line 183)

**Case 2 — landed and consistent. Record the confirmation; the landed contract supersedes the assumption label.**

The assumption listed five F3-owned surfaces. Each is verified landed:

| Assumed F3-owned surface | Landed evidence | Disposition |
| --- | --- | --- |
| The §11 manifest schema | `scripts/dev_tools/parallel_manifest_contract.py` present on both surfaces (check (b)); invariants M1-M7 stated in `.claude/rules/parallel-orchestration.md` | **CONSISTENT** |
| The §12 checkpoint schema | Planner invariants P1-P9 and orchestrator invariants 1-21 stated in `.claude/rules/parallel-orchestration.md` | **CONSISTENT** |
| `scripts/dev_tools/validate_parallel_planner_state.py` | Present on both surfaces (check (b)); exposes `validate_parallel_planner_state_text(text, *, require_ready_for_execution=False)` | **CONSISTENT** |
| The MCP `artifact_type` wiring in `validate_orchestration_artifacts` | Check (c): `parallel-orchestrator-state` and `parallel-planner-state` registered on both surfaces | **CONSISTENT** |
| `.claude/rules/parallel-orchestration.md` | Check (d): present on both surfaces, 184 lines | **CONSISTENT** |
| `route_id: parallel` in `config/orchestration-routing.json` | Check (d): present on both surfaces at line 100, `requires_pr_gate: false` | **CONSISTENT** |

The assumption's closing sentence — "F4 only writes conforming instances and validates them through F3's validators via `mcp__drm-copilot__validate_orchestration_artifacts`. F4 defines no schema and adds no validator in the base scope" — remains the operative constraint for the base scope, and Phase 3 (P3-T8) can now cite the landed rules file rather than an assumption label.

**Additional landed detail worth carrying into Phase 3:** F3's landed rules file records planner invariant P5 as deliberately absent ("This feature does not recompute the cohort coloring. Recomputation parity against the cohort-computation module is the planner-surface feature's check (the analogue of the epic planner's wave-number cross-check)"). This assigns the recomputation-parity check to F4's surface. It is not a task in the current plan and is noted here for the plan revision described in [P1-T3].

## Checkpoint field-set assumption `[ASSUMPTION — F3 unlanded]` (spec line 362)

**Case 2 — landed and consistent, with one additive observation.**

The spec's assumed top-level field set is `objective`, `parallel_slug`, `parallel_manifest_path`, `mode`, `max_concurrency`, `plan_home_branch`, `items[]`, `cohorts[]`, `conflict_edges[]`, `recolor_generation`, `kickoff_prompt_path`, `completed_steps`, `next_step`, `last_updated`, with `epic_worthiness`, `depends_on`, and `wave` deliberately absent.

F3's landed planner invariant P1 requires: `objective`, `parallel_slug`, `parallel_manifest_path`, `mode`, `max_concurrency`, `items`, `cohorts`, `conflict_edges`, `recolor_generation`, `completed_steps`, `next_step`, `last_updated` — a strict subset of the assumed set. `kickoff_prompt_path` is optional outside the ready gate and is pinned by P9 under `require_ready_for_execution` to exactly `artifacts/orchestration/parallel-kickoff-<parallel_slug>.md`, matching the assumed value. F3's rules file also confirms the deliberate absence: "The planner checkpoint carries no `epic_worthiness` analogue and no `NON_EPIC_RECOMMENDED` branch", and prohibited-key invariants reject `depends_on` and `integration_branch` at any level.

**Observation (additive, not divergent):** `plan_home_branch` is written by F4 per spec R1 but is not among F3's P1 required keys. F3's validator requires a superset of nothing here — P1 checks required-key presence, not key exclusivity, and the only prohibited keys are `depends_on` and `integration_branch`. `plan_home_branch` is therefore a permitted additional field. No conflict.

F3's landed P3 additionally requires per-item `preparation_status`, `research_path`, `plan_path`, and `preflight_status`, and constrains `complexity_band` to `{C1, C2, C3, C4}` when present. P8 pins the ready sentinel to exactly `'PARALLEL_EXECUTION_READY'`, matching the sentinel P3-T8 requires. P7 requires `blast_radius.source == 'declared'` under the ready gate, matching R3's "the `declared` radius is authoritative for scheduling". **CONSISTENT.**

## Per-branch git-integrity assumption `[ASSUMPTION — F3 unlanded]` (spec line 411)

**Case 3 — landed and divergent in ownership, not in contract.**

The assumption stated: "per-item plan blobs are verified against the per-item branch refs by the F3 readiness gate". F3's landed rules file states the opposite ownership: "F3's `require_ready_for_execution` gate is STRUCTURAL ONLY. It enforces the kickoff-PATH invariant (P9 ...) and does not parse or cross-check kickoff CONTENT. The deeper readiness-integrity machinery of the epic surface — git-integrity checks, launch-evidence binding, and kickoff-contract cross-checks — is left to F4, which may layer repository-aware checks behind an additional keyword without changing the schema."

**Disposition: SUPERSEDE — the git-integrity check is F4's, not F3's.** This does not contradict any non-negotiable constraint in the Scope Summary: constraint 9 forbids F4 from *defining or altering* F3-owned surfaces, and layering a repository-aware check behind an additional keyword is precisely what F3's landed rules file invites. However, the base plan contains no task for it. This is the same ownership shift that drives the [P1-T3] contingency, and it is folded into the plan-revision note below rather than executed here. Spec R6 / P3-T8 text must state that the git-integrity verification against per-item branch refs plus `parallel/<slug>-plan` is F4-owned.

## Summary of [P1-T2] dispositions

| Assumption entry (spec line) | Case | Verdict |
| --- | --- | --- |
| Blanket "F1/F2/F3 have NOT landed" (line ~113) | 3 | Superseded in full; the `[ASSUMPTION]` regime does not apply |
| R3 — F1 invocation contract (line 128) | 3 | Superseded on invocation shape, input types, and `conflicts` arity; consistent on output keys, findings shape, V1/V2/V3 severities |
| R3 — F3-owned readiness conjunction (line 161) | 2 | Consistent; F3 P7/P8 landed and match |
| R4 — F2 cohort-seeding contract (line 163) | 3 | Superseded on invocation shape, pinned-set parameter (absent, unused by F4), and return shape; consistent on Welsh-Powell ordering and `max_concurrency` rule |
| F3 ownership boundary (line 183) | 2 | Consistent; all six named surfaces landed |
| Kickoff parser/validator boundary (line 200) | 3 | Superseded — see [P1-T3]; F3 landed WITHOUT the module by design |
| Checkpoint field set (line 362) | 2 | Consistent; F3 P1/P3/P7/P8/P9 landed and compatible |
| Per-branch git-integrity (line 411) | 3 | Superseded — the check is F4-owned, not F3-owned |
| F1a corrections (#452) | n/a — landed-consistent | No assumption invalidated; both corrections verified in-code and fail-closed |

**No case-3 divergence contradicts a non-negotiable constraint in the plan's Scope Summary, and none invalidates a Phase 2-7 task acceptance criterion.** Every R3 and R4 divergence is confined to contract details quoted in deliverable text (module paths, invocation shapes, function arity, return shapes), which [P1-T2] case 3 directs the executor to author against the landed contract with the supersession recorded — as done above. The stop-and-return-for-revision branch of [P1-T2] is therefore **not triggered by [P1-T2] itself**. It is triggered independently by [P1-T3].

---

# [P1-T3] R5 Kickoff-Validation Contingency Evaluation

## Artifact 1 — `scripts/dev_tools/parallel_kickoff_contract.py`

### `<UPSTREAM>` ref result

Command: `git ls-tree --name-only origin/epic/parallel-orchestration-integration scripts/dev_tools/ | grep -c "parallel_kickoff_contract.py"`
EXIT_CODE: 1 (grep exit 1 = zero matching lines)
Output Summary: `0`

**Result: ABSENT on the `<UPSTREAM>` ref.** The full 89-entry `scripts/dev_tools/` tree listing recorded under [P1-T1] check (b) contains no `parallel_kickoff_contract.py`. For contrast, the epic analogue `scripts/dev_tools/epic_kickoff_contract.py` **is** present in that same listing, confirming the module is genuinely absent rather than the check being misdirected.

### Worktree filesystem result

Command: `ls scripts/dev_tools/parallel_kickoff_contract.py`
EXIT_CODE: 2
Output Summary: `ls: cannot access '.../scripts/dev_tools/parallel_kickoff_contract.py': No such file or directory`

**Result: ABSENT on the worktree filesystem.**

## Artifact 2 — `artifact_type: "parallel-kickoff"` in `extensions/drm-copilot/src/mcp-tool-inputs.ts`

### `<UPSTREAM>` ref result

Command: `git show origin/epic/parallel-orchestration-integration:extensions/drm-copilot/src/mcp-tool-inputs.ts | grep -n -A 12 "VALID_ARTIFACT_TYPES"`
EXIT_CODE: 0
Output Summary: the ten-member set reproduced under [P1-T1] check (c). Members present: `plan`, `policy-audit`, `code-review`, `feature-audit`, `orchestrator-state`, `epic-orchestrator-state`, `epic-planner-state`, `epic-kickoff`, `parallel-orchestrator-state`, `parallel-planner-state`.

**Result: `parallel-kickoff` ABSENT on the `<UPSTREAM>` ref.** `epic-kickoff` is present, confirming the analogue exists and the absence is specific to the parallel surface.

### Worktree filesystem result

Command: `grep -n "parallel-kickoff" extensions/drm-copilot/src/mcp-tool-inputs.ts`
EXIT_CODE: 1 (zero matching lines)
Output Summary: no output.

**Result: `parallel-kickoff` ABSENT on the worktree filesystem.**

## F3 Landing Status for the Contingency

Per [P1-T1], F3 counts as landed when its artifacts are present on either surface. F3's artifacts are present on **both** surfaces (check (b) validators, check (c) two artifact types, check (d) rules file and route). **F3 is LANDED.**

## Contingency Verdict

**Verdict: `fired`.**

The [P1-T3] decision table resolves as follows:

| Branch | Condition | Applies? |
| --- | --- | --- |
| Contingency does not fire | F3 unlanded | No — F3 is landed on both surfaces |
| Contingency does not fire | F3 landed **with** `parallel_kickoff_contract.py` | No — the module is ABSENT on both surfaces |
| **Contingency fires** | **F3 landed WITHOUT `parallel_kickoff_contract.py`** | **Yes — F3 landed; module absent on both surfaces; `parallel-kickoff` artifact_type absent on both surfaces** |

## This Outcome Is Adjudicated and Expected — Not an Error

The epic manifest adjudicates this exact boundary in advance. Source: `docs/features/epics/parallel-orchestration/epic.md`, section **"Planner Adjudication: the kickoff-contract boundary (F3 / F4)"** (line 161), verified present in this worktree.

Quoted adjudication (epic.md lines 167-184):

> - **F3** records Decision 3.2-A: the MCP surface grows by **exactly the two promised `artifact_type` values** (`parallel-orchestrator-state`, `parallel-planner-state`). F3 explicitly excludes kickoff-contract cross-checks, leaving them to F4. F3's `require_ready_for_execution` gate is structural only and includes the P9 kickoff-*path* invariant (`artifacts/orchestration/parallel-kickoff-<slug>.md`), not kickoff-*content* parsing.
> - **F4** recommends the module as an F3 deliverable but carries an **explicit contingency**: if F3 lands without `parallel_kickoff_contract.py`, F4 delivers that module and the minimal additive `artifact_type: "parallel-kickoff"` wiring itself and records the deviation.
>
> **Adjudication: F4 owns it.** F3's Decision 3.2-A is a deliberate, AC-pinned scope boundary, so F3 will land without the module by design and F4's contingency is the operative path. This is consistent with ownership by producer: F4 emits the kickoff artifact, so F4 owns the parser that validates its own output. F3 retains the two state `artifact_type` values and the structural kickoff-path invariant. The epic analogue `scripts/dev_tools/epic_kickoff_contract.py` and the `epic-kickoff` `artifact_type` are the patterns to mirror.
>
> No action is required of F3. F4 should treat its contingency branch as the selected path rather than re-checking whether F3 delivered the module.

F3's own landed rule file states the same boundary independently. Source: `.claude/rules/parallel-orchestration.md`, section **"F3 Scope Boundary — kickoff contract deferred to F4"** (line 170), verified identical on the `<UPSTREAM>` ref:

> F3 deliberately excludes the kickoff-prompt contract module `scripts/dev_tools/parallel_kickoff_contract.py` and the `parallel-kickoff` `artifact_type`. Both are F4's scope, and F3 neither creates the module nor registers the artifact type on the CLI or MCP surfaces. The MCP surface grows by exactly two `artifact_type` values: `parallel-orchestrator-state` and `parallel-planner-state`.

**Conclusion:** the `fired` verdict is the adjudicated, expected, correct outcome. It records that F3 executed its AC-pinned scope boundary exactly as designed. It is not an F3 defect, not a regression, and not a missed dependency. F4 owns the kickoff-contract module by producer-ownership adjudication.

## Required Executor Action per [P1-T3]

[P1-T3] directs: "if F3 landed WITHOUT `parallel_kickoff_contract.py`, the contingency fires — stop and report remediation-required, because this plan deliberately contains no production-Python module tasks and must be revised".

Accordingly:

- **Execution STOPS at the end of Phase 1.** No Phase 2-7 task has been executed. Phase 2 through Phase 8 checkboxes in the plan remain unchecked.
- **Outcome: REMEDIATION-REQUIRED.** This is not a PASS and is not reported as one.
- The plan must be revised by `atomic-planner` to add the production-Python module tasks before any dependent Phase 2-7 task executes. The executor does not revise the plan.

## Plan Delta Required (input for `atomic-planner`)

The current plan's Scope Summary states the base scope "introduces no executable production code" and its coverage obligation is no-regression only (spec R10). That premise no longer holds. The revision must add production-Python deliverables and their full toolchain and uniform-coverage obligations:

1. **`scripts/dev_tools/parallel_kickoff_contract.py`** — the kickoff-prompt contract module, mirroring `scripts/dev_tools/epic_kickoff_contract.py`. It must validate the kickoff artifact shape spec R5 / plan P3-T9 defines: heading `# Parallel Kickoff: <slug>`; `## Invocation Prompt` naming `/parallel-run <slug>`, the manifest path, and the resume-boundary sentence; `## Item Summary` strict pipe table with the exact ordered headers `issue_num | feature_folder | cohort | complexity | branch | plan-path`, at least one row, `issue_num` and `cohort` integers, `complexity` in C1-C4; optional `## Integrity` per-item `plan-path | plan-hash` table (40-64 hex, no repeated paths) plus the head commit of `parallel/<slug>-plan`.
2. **The minimal additive `artifact_type: "parallel-kickoff"` wiring** — one member appended to `VALID_ARTIFACT_TYPES` in `extensions/drm-copilot/src/mcp-tool-inputs.ts` (currently ten members, lines 427-438), the matching CLI subparser in `scripts/dev_tools/validate_orchestration_artifacts.py`, and the dispatch entry in `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`. The epic's wave-4 confinement discipline applies: distinct named additions, no reflow or reordering of existing entries.
3. **`tests/scripts/dev_tools/test_parallel_kickoff_contract.py`** — unit tests for the new module covering positive flows, negative flows, edge/boundary cases, and error handling per `.claude/rules/general-unit-test.md`.
4. **TypeScript test coverage** for the wiring change, if the TypeScript surface is modified, per `.claude/rules/typescript.md`.
5. **Toolchain and coverage obligations.** The Phase 8 final QA loop must now measure real new-code coverage instead of recording "no production `.py` file in the change set". Plan task P8-T5 currently asserts the change set contains no production `.py` file; that assertion becomes false and must be rewritten to report new/changed-code coverage as a percentage against the uniform thresholds (line >= 85%, branch >= 75%) and no regression versus the Phase 0 baseline recorded below. If TypeScript is touched, a TypeScript QA loop (`npx prettier`, `npx eslint`, `npx tsc`, `npx jest`) must be added to Phase 8.
6. **Constraint-9 verification task P6-T4 must be amended.** It currently asserts the change set contains **no** `scripts/dev_tools/parallel_kickoff_contract.py` and **no** `extensions/drm-copilot/src/mcp-tool-inputs.ts`. Both assertions become false by design once the contingency is executed. P6-T4 must be rewritten to assert the F3-owned surfaces that remain off-limits (`scripts/dev_tools/validate_parallel_*`, `.claude/rules/parallel-orchestration.md`) while explicitly permitting the two adjudicated F4-owned additions, citing this artifact and the epic adjudication.
7. **Phase 5 mirror obligations extend to any new `.claude` file only.** The new Python module and the TypeScript wiring are not `.claude` resources, so the existing P5-T1/P5-T2/P5-T3 mirror tasks are unaffected. Confirm no new `.claude` file is introduced by the contingency work.
8. **Spec deviation record.** Spec R5's contingency text already authorizes this ("F4 delivers that module and the minimal additive `artifact_type: "parallel-kickoff"` wiring itself and records the boundary deviation in this spec"). The revision should include a task to record the boundary deviation in `spec.md`, citing this artifact and `epic.md` "Planner Adjudication: the kickoff-contract boundary (F3 / F4)".

**Two further items surfaced by [P1-T2] that the revision should consider** (recorded for the planner's judgment; both derive from F3's landed text assigning work to F4, and neither is currently a plan task):

- **F4-owned git-integrity check.** F3's landed rules file leaves "git-integrity checks, launch-evidence binding, and kickoff-contract cross-checks" to F4, layered "behind an additional keyword without changing the schema". The spec's line-411 assumption attributed this to F3; that attribution is superseded.
- **F4-owned cohort recomputation-parity check.** F3's landed planner invariant P5 is deliberately absent and states: "Recomputation parity against the cohort-computation module is the planner-surface feature's check (the analogue of the epic planner's wave-number cross-check)."

## Baseline Coverage Carried Forward for the Revised Plan

From `docs/features/active/2026-08-07-parallel-planner-surface-443/evidence/baseline/pytest-coverage-baseline.2026-08-08T13-56.md`:

- Total line coverage: **91.72%** (12266 / 13373)
- Total branch coverage: **83.58%** (4124 / 4934)
- Tests: 2886 passed, 0 failed, EXIT_CODE 0

These are the no-regression reference values for the revised plan's Phase 8 comparison.

---

## Artifact Result

- [P1-T1]: COMPLETE — `<UPSTREAM>` resolved to `1a402e8eaa98e3ff1c7fbe91aebb46029cfa3595`; checks (a)-(d) executed against both the worktree filesystem and the `<UPSTREAM>` ref with both results recorded; per-upstream-feature verdicts and landing granularity recorded for F1, F1a, F2, and F3.
- [P1-T2]: COMPLETE — one disposition line per `[ASSUMPTION]` entry; case-3 supersede-or-stop decisions stated with rationale; no case-3 divergence contradicts a Scope Summary constraint or invalidates a task acceptance criterion.
- [P1-T3]: COMPLETE — contingency verdict **`fired`**, with file-existence evidence from both surfaces for both checked artifacts. Per [P1-T3]'s acceptance criteria, the plan run terminates in **remediation-required** with no Phase 2-7 task executed.
