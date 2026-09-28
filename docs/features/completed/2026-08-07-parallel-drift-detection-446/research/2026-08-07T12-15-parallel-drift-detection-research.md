# F8 `parallel-drift-detection` (Issue #446) — Research

- Date: 2026-08-07
- Epic: `parallel-orchestration`, child F8
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` (cited below as §N)
- Epic narrative: `docs/features/epics/parallel-orchestration/epic.md`
- Issue: `docs/features/active/2026-08-07-parallel-drift-detection-446/issue.md`
- Evidence labels: **Verified** = read in this worktree at the cited path. **Assumed** = upstream contract not yet on the branch; cited to the design document and marked for reconciliation at execution time.

## 1. Scope Summary

Deliver the §7 six-step radius-drift procedure, evaluated at each child's pre-review commit, plus the §9 drift gate that blocks a child's transition to review while an unresolved `drift_events[]` entry exists. Non-negotiable constraints restated for the planner:

1. Halt the **later-started** item of a newly conflicting pair, never the drifting item (§7, final paragraph). Do not "fix" this.
2. Reuse the R1–R5 remediation loop unmodified; the drift finding is a synthetic Blocking finding processed exactly like a local finding.
3. Drift detection is the execution-time half of the §13.1 paired mitigation (F1 V1 is the plan-time half); neither eliminates the risk.
4. Surface name is `parallel` throughout.
5. Additive only: adapt epic prior art near-verbatim into new `parallel`-named files; do not modify epic implementations.

## 2. Upstream Availability (Verified)

The epic integration branch content available in this worktree is scaffold-only. Verified by filesystem enumeration (no Bash tool available in this session; `git` was not executed — absence was established by glob/grep over the worktree):

| Upstream | Expected artifact | Status |
| --- | --- | --- |
| F1 `parallel-blast-radius` | `scripts/dev_tools/compute_blast_radius.py`, `.claude/lib/blast-radius/BlastRadius.psm1`, feature folder | **Absent.** No `docs/features/active/*parallel*` folder exists other than this feature's own. No `scripts/dev_tools/*parallel*` file exists. |
| F3 `parallel-schema-validators` | `validate_parallel_orchestrator_state.py`, `route_id: parallel`, `.claude/rules/parallel-orchestration.md` | **Absent.** `scripts/dev_tools/` contains no parallel validator; `config/orchestration-routing.json` contains no `parallel` route (`parallel` matches only the epic route description and `parallelism` block, lines 101, 235–237). |
| F5 `parallel-orchestrator-surface` | `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md` | **Absent.** `.claude/skills/*/SKILL.md` enumeration (49 skills) contains no `parallel-*` skill; `.claude/agents/*.md` (22 agents) contains no `parallel-*` agent. |
| F6 `parallel-mutation-protocol` | mutation/admission/recolor implementation | **Absent** (same enumerations). |

No upstream `spec.md` exists for F1, F3, F5, or F6. Every upstream contract cited in this document is therefore **Assumed** from the design document and must be reconciled against the real upstream artifacts at execution time (F1/F3/F5 land in waves 0–3 before F8 executes in wave 4; F6 lands concurrently with F8).

The only parallel-orchestration artifacts present are `docs/features/epics/parallel-orchestration/epic.md` and this feature's own folder (`issue.md`, `spec.md`, `user-story.md`, and an unpopulated plan template `plan.2026-08-07T11-11.md`).

## 3. Prior Art to Adapt (Verified)

### 3.1 Epic orchestrator surface and the pre-review hook point

- `.claude/agents/epic-orchestrator.md` — the parent agent delegates exclusively via `Agent(orchestrator)` per child (worktree isolation, background) and `Agent(pr-author)`; it never delegates to `atomic-planner`/`atomic-executor`/`feature-review` directly (lines 101–118). F5's `parallel-orchestrator` will mirror this; F8's checkpoint-side steps (record, quiesce, recompute, halt, requeue) belong to the parent.
- `.claude/skills/orchestrate/SKILL.md` `## Pre-Feature-Review Commit` (lines 170–179) — the child orchestrator stages (`git add -A`), obtains a commit message, commits, and only then delegates to `feature-review`. **This is the §7 hook point**: "evaluated at each child's pre-review commit" maps to the moment between step 3 (successful commit) and step 4 (feature-review delegation).
- Epic-mode precedent for extending child behavior via a kickoff marker: `.claude/skills/epic-orchestrate/SKILL.md` `## Merge-on-Green Kickoff Parameter` (lines 121–132) — the parent's delegation prompt carries a literal marker line (`Epic mode: true. ... epic_checkpoint_path: ...`) that switches on child-side behavior (S9 step 6 merge). §9 already stipulates the analogous `Parallel mode: true` marker for the parallel cohort-barrier hook. F5 owns the parallel kickoff line; F8 consumes it (integration contract, section 8).

### 3.2 R1–R5 remediation loop and the synthetic-finding shape

Authoritative loop definition — `.claude/skills/orchestrate/SKILL.md`:

- `## Post-Review Outcome Evaluation` (lines 181–187): the orchestrator locates `remediation-inputs.<timestamp>.md` in the active feature folder (highest ISO-8601 timestamp) and counts lines matching `BLOCKING` or `Severity: Blocking` (case-sensitive); count >= 1 enters the loop.
- `## Remediation Loop (R1–R5)` (lines 189–200): R1 `atomic-planner` plans from the remediation-inputs path; R2 `atomic-executor` preflights; R3 executes; pre-R4 commit; R4 `feature-review` re-audits; R5 exits on zero blocking findings. `remediation_pass` cap is 3.
- `## Remediation Loop — CI-Failure Handling` (lines 265–273): the exact synthetic-Blocking-finding precedent — a failure is written as `remediation-inputs.<timestamp>.md`, converted to a synthetic finding with severity `Blocking`, and "the existing R1-R5 remediation loop processes that finding exactly as it processes a local blocking finding. No new loop is introduced."
- Epic merge-conflict precedent — `.claude/skills/epic-orchestrate/SKILL.md` `## Merge-Conflict Handling (Fan-In)` (lines 178–203): the synthetic finding is written to the **child feature's own active folder** (not the epic folder), severity `Blocking`, "the same shape the existing CI-failure handling already uses." F8's drift finding follows this precedent exactly, substituting the escaped-path evidence for the conflict-marker evidence.

Concrete file shape (Verified sample: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/remediation-inputs.2026-07-09T15-35.md`):

```markdown
# Remediation Inputs — <Source> (Issue #<N>)

- Cycle: <n>
- Entry timestamp: <yyyy-MM-ddTHH-mm>
- Source: <what produced the finding>

## Synthetic Blocking Finding (from <source>)

- Severity: Blocking
- <finding-specific evidence lines>

## Root Cause ...
## Required Changes ...
## Verification ...
```

The load-bearing element is the literal line `- Severity: Blocking` (matched case-sensitively by the Post-Review Outcome Evaluation counter). Timestamp format is `yyyy-MM-ddTHH-mm` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

**Dual-convention caution (Verified):** `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (lines 59–82) defines a newer folder-per-cycle layout `remediation/<entry-ts>/remediation-inputs.md`. The orchestrate skill's detection logic (line 185) and both existing synthetic-finding producers (CI failure, epic merge conflict) use the flat `remediation-inputs.<timestamp>.md` form in the feature folder root. **Recommendation:** the drift finding uses the flat form, matching the epic merge-conflict precedent and the consumption path that actually triggers the loop. The planner should note the dual convention and not attempt to unify it in this feature (additive-only constraint).

### 3.3 Validator structure and helper-module split

- `scripts/dev_tools/validate_epic_orchestrator_state.py` (Verified, 493 lines) — the pattern F3's `validate_parallel_orchestrator_state.py` will follow: a top-level `validate_<x>_state_text(text, *, require_complete=False, ...) -> list[str]` that parses JSON, runs one `_validate_*` helper per concern, returns error strings, never mutates input, stays under 500 lines by delegating to sibling helper modules (`_epic_orchestrator_state_resolution.py`, `_epic_orchestrator_state_launch_binding.py`, imported at lines 21–33).
- Helper-module naming convention (Verified by enumeration of `scripts/dev_tools/`): `_orchestrator_state_complexity.py`, `_orchestrator_state_model_routing.py`, `_orchestrator_state_model_routing_gate.py`, `_orchestrator_state_human_interaction.py`, etc. Key-gated additive invariants (run only when the key is present) are the documented style — see `.claude/rules/orchestrator-state.md` ("Scope and Backward Compatibility" sections).
- Error-message style (Verified): literal, context-prefixed strings, one error per violated invariant — e.g., `EPIC_WAVE_BARRIER_VIOLATION: {folder} started before dependency {dep} merged` (`validate_epic_orchestrator_state.py` lines 303–306); `Epic checkpoint feature '{folder}' has invalid merge_status: {value!r}` (lines 236–239).
- MCP wiring — `scripts/dev_tools/validate_orchestration_artifacts.py` dispatches on `artifact_type` subparsers (`orchestrator-state` line 180, `epic-orchestrator-state` line 223). F3 owns adding `parallel-orchestrator-state`; F8 only adds an invariant inside the validator F3 creates.

### 3.4 Reference-implementation-plus-parity pattern

- `scripts/dev_tools/epic_wave_computation.py` (Verified, 153 lines) — a pure, file-I/O-free function with a dedicated exception type, exhaustive docstrings per `.claude/rules/self-explanatory-code-commenting.md`, and a mirrored test `tests/scripts/dev_tools/test_epic_wave_computation.py`. It is Python-only; cross-language parity in this repository is exercised where a PowerShell counterpart exists (`.claude/lib/model-routing/ModelRouting.psm1` versus `compute_complexity_floor.py` / `resolve_delegation_model.py`; `.claude/lib/` currently holds only `model-routing` and `orchestrator-state` modules — Verified). F8's decision logic should follow the `epic_wave_computation.py` shape: pure functions, injected inputs, no filesystem access.

### 3.5 Enforcement hooks — gate pattern

Verified hook wiring in `.claude/settings.json`: `PreToolUse` matchers `Bash` (includes `enforce-epic-worktree-removal-gate.ps1`, line 116), `Write|Edit`, and `Agent` (includes `enforce-epic-wave-barrier.ps1` line 178 and `enforce-epic-invocation-origin.ps1` line 186).

- `.claude/hooks/enforce-epic-wave-barrier.ps1` (Verified) — the closest analog for the drift gate. Structure: script-scoped constants (checkpoint path, marker `Epic mode: true`), an injectable checkpoint-read seam (`Get-...CheckpointContent`) so Pester tests mock the boundary without temp files, prompt-scanning resolution of the target feature folder (`docs[\\/]+features[\\/]+active[\\/]+...`, longest match wins), fail-closed deny (`EPIC_WAVE_BARRIER_BLOCKED`) on unreadable checkpoint or unresolved target, allow/deny decisions emitted as `hookSpecificOutput` JSON, and a dot-source guard for tests.
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (Verified) — same skeleton on the `Bash` matcher: regex-match the command, extract the argument, read the checkpoint, allow only on a safe status set, deny fail-closed with `EPIC_WORKTREE_REMOVAL_BLOCKED`.
- Hook tests live at `tests/scripts/claude-hooks/<hook-name>.Tests.ps1` (Verified: `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1`).

**Hook-versus-validator split for the drift gate.** §9's rationale (Verified in design doc and restated in `.claude/skills/epic-orchestrate/SKILL.md` lines 205–226): hooks fire per call with no cross-call state visibility, so no single hook can validate batch/temporal properties; the validator provides the retrospective backstop. Recommendation: implement the drift gate as **both** —

1. **Layer 1** — `.claude/hooks/enforce-parallel-drift-gate.ps1`, `PreToolUse` on the `Agent` matcher, firing when `subagent_type == "feature-review"` and the prompt (or session context) carries the `Parallel mode: true` marker; it reads the parallel checkpoint, resolves the item, and denies with `PARALLEL_DRIFT_GATE_BLOCKED` when the item has an unresolved drift event whose synthetic finding has not yet been written. The hook performs **presence gating only** (checkpoint-state reads, no glob matching and no git execution in PowerShell), which keeps it deterministic, keeps all path-matching semantics in the single Python implementation, and avoids a cross-language glob-parity burden.
2. **Layer 2** — a key-gated invariant in `validate_parallel_orchestrator_state.py` (helper module `_parallel_orchestrator_state_drift.py`): an item whose latest `drift_events[]` entry is unresolved must not be in a review-progressed `merge_status` (`pr_open`, `ci_green`, `merged`, `worktree_removed`), error prefix `PARALLEL_DRIFT_GATE_VIOLATION:`.

## 4. Recommended Approach

Three cooperating components, mirroring the epic two-layer + reference-implementation pattern:

1. **Python reference implementation** `scripts/dev_tools/parallel_drift_detection.py` — pure functions (no I/O): escape detection against declared globs, later-started selection with deterministic tie-break, and drift-event record construction. A thin CLI wrapper module (separate file, keeping the pure module I/O-free per `.claude/rules/general-code-change.md` I/O-boundary rule) lets the parent agent invoke detection with `git diff --name-only` output.
2. **Procedure section** appended to `.claude/skills/parallel-orchestrate/SKILL.md` (created by F5) as one explicitly named new H2 section documenting all six §7 steps, the drift gate, and the child-side evaluation point (the child's Pre-Feature-Review Commit step under the `Parallel mode: true` marker).
3. **Enforcement**: the Layer-1 hook and Layer-2 validator invariant from section 3.5, wired into `.claude/settings.json` (`Agent` matcher list) — an additive settings edit consistent with how `enforce-epic-wave-barrier.ps1` was registered.

**Rejected alternatives (brief).**
- *Hook-only drift gate performing detection itself (git diff + glob matching in PowerShell):* rejected — duplicates the path-matching semantics in a second language, creating a parity obligation the feature does not otherwise need, and a hook cannot record `drift_events[]` or drive quiesce/halt (per-call, no cross-call state).
- *Validator-only gate (no hook):* rejected — violates the §9 two-layer mandate; the violation would be detected only retrospectively at SubagentStop, after review had already run.
- *A new drift-specific remediation loop:* rejected — explicitly prohibited; the CI-failure and epic merge-conflict handlers prove the synthetic-finding injection path requires zero loop changes.
- *Storing a quiesce boolean in the checkpoint:* rejected — F3 owns the schema and §12 defines no quiesce field; quiesce is derivable from `drift_events[]` (section 5, step 3).

## 5. Step-by-Step Design Answers

### Step 1 — diff base

**Recommendation:** in the child worktree at the pre-review commit, compute `BASE = git merge-base origin/main HEAD` and run `git diff --name-only <BASE> HEAD` (equivalently `git diff --name-only origin/main...HEAD`).

Justification (Verified prior art):
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` line 263: "Diff selection: merge-base+head when both known, else the working tree" — `collect_pr_context` diffs `mergeBase..headSha`.
- `.claude/skills/pr-base-branch-merge-base/SKILL.md`: base resolution is merge-base-ancestry driven, never guessed.
- §6: cohort items branch from the `main` tip, and cohort N+1 branches from `main` only after cohort N merges, so `origin/main` is the correct single base for every parallel item (unlike epic children, which branch from the integration branch). Using the merge-base (three-dot) rather than two-dot `origin/main..HEAD` excludes commits that landed on `main` after the branch point, so concurrently merged peer items never appear as spurious drift. Deterministic given a fixed HEAD; the pre-review commit fixes HEAD.
- Rename handling: `--name-only` lists both old and new paths for renames under the diff default; both must be radius-covered (fail closed, §5.4 spirit).

### Step 1 — glob matching

**Repo prior art (Verified):** `scripts/dev_tools/discovery/analyzer/inventory.py` uses `fnmatch.fnmatchcase` on POSIX (`PurePosixPath`) paths, documented there as "deterministic and platform-independent" (lines 23–24, 33–34, 93–94). PowerShell `-like` appears in hooks only for command-text matching, not path-set matching.

**Recommendation:** the matcher is **F1's contract, not F8's**. F1's V1 coverage validation ("every concrete path ... subsumed by `blast_radius.paths`", §5.3) and F8's escape detection are the same predicate evaluated at different times; if they diverge, a plan that passes V1 can drift-flag its own planned paths (false positives) or vice versa (false negatives). F8 must import and reuse F1's path-subsumption function (assumed name `path_covered(path, patterns) -> bool` in `scripts/dev_tools/compute_blast_radius.py`; **Assumed**, §5.3/§10-F1). If, at execution time, F1 exposes no reusable predicate, implement `fnmatch.fnmatchcase` over forward-slash-normalized repo-relative paths (matching `inventory.py`) and record the deviation for reconciliation. Cross-language parity is **not required** for F8 under the recommended design, because no PowerShell component performs path matching (section 3.5).

Semantics note for the planner: `fnmatchcase`'s `*` matches path separators (no `**` distinction). Whichever semantics F1 chose, F8 inherits them; F8's tests must include the glob boundary cases the issue seeds (`issue.md`, Test Conditions) against F1's real matcher.

### Step 2 — `drift_events[]` entry shape and `action` values

§12 shape (**Assumed**, F3-owned): `{ item_key, declared, observed, escaped_paths[], at, action }`.

- `item_key` — the item's `issue_num` (§11: `issue_num` is the primary key; epic.md Shared Design #3).
- `declared` / `observed` — the declared `blast_radius.paths` set and the observed changed-path set (with `source: declared` / `source: observed` provenance per §5.2).
- `escaped_paths[]` — observed paths not subsumed by declared patterns.
- `at` — ISO-8601 timestamp.
- `action` — §12 does not enumerate values. The §7 procedure implies exactly two detection-time outcomes plus one resolution outcome. **Recommended enum** (to be reconciled with F3's spec if it enumerates one):
  - `blocking_finding_raised` — escape recorded; synthetic Blocking finding written into the child's `remediation-inputs.<ts>.md`; recomputation found no new conflict with any in-flight item (steps 2–4 only).
  - `halted_later_started` — escape recorded and finding raised, and recomputation found a new conflict, so the later-started item of the pair was halted (`blocked_drift`) and requeued (steps 2–5).
  - `resolved` — appended (as a new entry for the same `item_key`, event-log style, mirroring the append-only `mutations[]` convention of §8.6) when the child remediation cycle that consumed the finding exits with `blocking_count == 0`.

`drift_events[]` is append-only; F8 populates values and never adds schema fields (F3 ownership constraint, `issue.md` Constraints).

### Step 3 — quiesce

**Recommendation:** quiesce is a **derived state, not a stored field**: admission of new items into the current cohort is suspended while any `drift_events[]` entry is unresolved (latest entry for an `item_key` has `action != "resolved"`). Rationale: §12 defines no quiesce field and F3 owns the schema; deriving quiesce from the event log makes it self-clearing on resolution and keeps the checkpoint contract untouched. The minimal contract F8 needs from F6 (which owns admission control, §8.3): **F6's admission decision must consult a single predicate exported by F8's Python module** — `has_unresolved_drift(drift_events) -> bool` — and defer admission into the current cohort while it returns `True` (deferral into a future cohort, F6's existing path, remains allowed). This is integration contract IC-6a (section 8).

### Steps 4/5 — later-started determination

§12 `items[]` carries unenumerated "lifecycle timestamps" (**Assumed**, F3-owned). Epic precedent (Verified): the epic checkpoint's per-feature lifecycle timestamps include `worktree_created_at`, `merge_confirmed_at`, `worktree_removed_at`, and the wave-barrier validator uses `worktree_created_at` as the start-of-execution marker (`validate_epic_orchestrator_state.py` lines 281–301).

**Recommendation:** "started" means "entered `in_flight`". Use the item's `in_flight_at` timestamp if F3 defines one; otherwise `worktree_created_at` (the epic-precedented start marker). The later-started item of a conflicting pair is:

```
later(a, b) = argmax over {a, b} of the tuple (start_ts, item_key)
```

lexicographic comparison, `item_key` compared as an integer (`issue_num`) ascending. Tie-break justification: when timestamps are equal (same-minute cohort fan-out is the normal case — the epic launches a whole wave in one message), the item with the **larger** `issue_num` is deemed later-started, so the smaller key survives. This is consistent with the repo's ascending-item-key determinism convention (§6: Welsh-Powell ties broken by ascending item key; `max_concurrency` slots filled in ascending item-key order), which always privileges the smaller key. A missing start timestamp on exactly one item makes the timestamped item earlier-started (a never-started item cannot be earlier than a started one); both missing falls through to the item-key tie-break. The halt decision must be a pure function in `parallel_drift_detection.py` so the issue's determinism test condition ("identical inputs produce identical halt/requeue decisions") is testable directly.

The halted item's `merge_status` becomes `blocked_drift` (§12 enum; **Assumed**, F3-owned) and its lifecycle state becomes `blocked` (§8.2) pending requeue.

### Step 5 — requeue through F6's recolor path

§8.6 and the issue's Constraints require the drift-induced requeue to append `mutations[]` and increment `recolor_generation` through the **same** recolor path F6 uses. Minimal interface F8 needs from F6 (integration contract IC-6b, section 8; **Assumed** — F6 does not exist yet):

```
requeue_via_recolor(checkpoint_state, *, item_key, reason) ->
    updated cohorts[] (unstarted subgraph only, pinned in-flight set untouched — §8.1),
    recolor_generation incremented by one,
    mutations[] appended with one entry:
      { op: "drift_requeue", item_key, at, prior_state: "in_flight",
        new_state: "blocked_drift", disposition: null, recolor_generation: <new> }
```

F8 must not implement its own recoloring. The `op` value name (`drift_requeue` versus F6's naming) is a reconciliation point; §8.6 says "drift-induced requeue appends to `mutations[]`" without naming the op. If F6's entry point is not yet callable when F8 executes (wave-4 concurrency), F8's plan must stub the call behind a single narrow seam (one function in F8's module that F6's landing replaces or that delegates to F6's function name once known) — never a second recolor implementation.

### Step 6 — R1–R5 injection point

**No change to the loop is required. Verified end-to-end:**

1. F8 writes `docs/features/active/<child-slug>/remediation-inputs.<yyyy-MM-ddTHH-mm>.md` in the child's own active feature folder, using the section-3.2 shape with the literal line `- Severity: Blocking`, naming the escaped paths, the declared patterns, and the required action (bring the diff back inside the radius, or justify and re-declare — the remediation plan decides).
2. The child orchestrator's Post-Review Outcome Evaluation (`.claude/skills/orchestrate/SKILL.md` lines 185–187) finds the highest-timestamped file, counts the Blocking line, and enters R1 with the file path as primary context (line 193). `atomic-planner` plans (R1), `atomic-executor` preflights (R2) and executes (R3), `feature-review` re-audits (R4), R5 exits on zero blocking findings — all pre-existing, byte-unmodified. The `remediation_pass` cap of 3 (line 200) is shared, matching the CI-failure precedent (line 272).
3. The writer of the file: the **parallel-orchestrator** (which detects the escape and owns the checkpoint), writing into the child's feature folder — exactly as `epic-orchestrator`'s merge-conflict procedure has the finding written "in the **child feature's own active folder** (not the epic folder)" (`.claude/skills/epic-orchestrate/SKILL.md` lines 191–194). Note the child folder lives in the child's worktree; the parent writes via the child worktree path recorded in `items[].worktree_path` (§12). This is the same cross-worktree visibility the epic surface already exercises.

### Drift gate — definition of "unresolved" and gate point

**Recommended definition:** a `drift_events[]` entry for item K is **unresolved** until a `resolved` entry for K (with `at` later than the escape entry) is appended — which the parallel-orchestrator does exactly when the child remediation cycle that consumed the synthetic finding exits with `blocking_count == 0`.

Justification against existing exit-gate semantics (Verified): `.claude/rules/orchestrator-state.md` remediation-cycle invariant 3 defines "resolved" for a blocking finding as `exit_condition_met == true` with `blocking_count == 0`; `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` `## Exit Gate` states the same. Deriving drift resolution from that existing gate — rather than a new per-event resolution field (F3 owns the schema and §12 defines none) or a bare "file exists" check — reuses the one place the repository already decides that a Blocking finding is closed. The alternative "matching entry in the child's checkpoint" was rejected because the parallel validator validates the **parallel** checkpoint and cannot reach into per-worktree child checkpoints; the `resolved` event mirrors the child's exit gate into the parent's own state.

**Gate point.** §9's one-line statement ("blocks a child's transition to review while an unresolved `drift_events[]` entry exists") must be reconciled with the fact that resolution itself requires review (R4 is a `feature-review` delegation). Recommended reading, to be confirmed by the planner:

- The Layer-1 hook denies a `feature-review` delegation for an item whose latest drift event is unresolved **and** whose synthetic finding file has not yet been written — i.e., it enforces "detection outcome surfaced before any review runs." Once the finding exists, review (initial or R4) proceeds, because the loop is the resolution mechanism and the existing PR-creation gate condition 1 (`.claude/skills/orchestrate/SKILL.md` lines 277–287, zero blocking findings) already prevents merge while the finding is open.
- The Layer-2 validator invariant enforces the durable form: unresolved drift forbids `merge_status` in `{pr_open, ci_green, merged, worktree_removed}` for that item.

This keeps the gate meaningful (nothing review-ward happens on an unsurfaced escape; nothing merges on an unresolved one) without deadlocking the loop that resolves the event.

## 6. Wave-4 Contention Plan (Mandatory)

- `.claude/skills/parallel-orchestrate/SKILL.md` **does not exist yet** (Verified, section 2); F5 (wave 3) creates it and, per the epic's wave-4 contention note, reserves named placeholder sections. **F8 claims the section name `## Radius Drift Detection and Drift Gate`** (one H2 section, appended in place of F5's placeholder of that name if present, otherwise appended at the end; no reflow or reorder of any existing section). F6 is expected to claim a mutation-protocol section and F7 an enforcement-hooks section; F8's plan must not touch either.
- `validate_parallel_orchestrator_state.py` (F3-owned, wave 1): F8's edit is confined to (a) one import line and (b) one key-gated `errors.extend(_validate_drift_events(state))`-style call, following the exact pattern of `validate_epic_orchestrator_state.py` lines 21–33 and 445–480 and the key-gated dispatch documented in `.claude/rules/orchestrator-state.md`. All F8 logic lives in a **new** helper module: **`scripts/dev_tools/_parallel_orchestrator_state_drift.py`**, following the verified `_orchestrator_state_*.py` split convention (section 3.3). F6 and F7 are expected to take distinct helper filenames (e.g., `_parallel_orchestrator_state_mutations.py`, `_parallel_orchestrator_state_cohort_barrier.py`); no shared helper file.
- `.claude/settings.json` hook registration: F8 appends exactly one entry to the `Agent` matcher hook list (after line 187's existing entries). F7 will append its own entries to the same list; append-only, no reordering.

## 7. Testing and Quality Gates

- **Tier:** T4 (dev tooling / build scripts per `.claude/rules/quality-tiers.md` `## Tiers`); everything F8 ships lives under `scripts/dev_tools/` and `.claude/hooks/`. Note the epic-wide known constraint (epic.md, F1 section): **`quality-tiers.yml` does not exist at the repo root** (Verified by glob); F1 resolves that. Tier does not change coverage: line >= 85% and branch >= 75% are uniform T1–T4.
- **Property-based tests:** not required (T4; the T1/T2 obligation in `.claude/rules/general-unit-test.md` does not apply). Confirmatory: `hypothesis` is not a dependency in `pyproject.toml` (Verified; the only textual match in `tests/` is the `business_outcome_hypothesis` field name).
- **Languages in scope:** Python (detection module, CLI wrapper, validator helper) and PowerShell (Layer-1 hook). No TypeScript (the MCP `artifact_type` wiring is F3's).
- **Python toolchain (Verified, `.claude/rules/python.md`):** `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`. The no-poetry feature `docs/features/active/2026-07-21-native-bash-toolchain-no-poetry-393/` removed Poetry from the **bash/shell** toolchain only (Verified in its spec.md lines 10–41); `pyproject.toml` still declares `[tool.poetry]` (Verified) and the Python rule file still specifies `poetry run` invocation.
- **PowerShell toolchain (Verified, `.claude/rules/powershell.md`):** `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test` (Pester v5, repo runsettings). No type-check stage.
- **Test locations (Verified layout):**
  - `tests/scripts/dev_tools/test_parallel_drift_detection.py` (mirrors `tests/scripts/dev_tools/test_epic_wave_computation.py`).
  - `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py` (mirrors `test_validate_epic_orchestrator_state*.py` naming).
  - `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` (mirrors `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1`); mock the checkpoint-read seam, never write temp files (temp files in tests are prohibited repo-wide).
- **Determinism:** timestamps entering the halt decision are inputs, never read from the wall clock inside the pure functions (clock-injection rule, `.claude/rules/general-unit-test.md` `## Determinism Infrastructure`; Python seam per `.claude/rules/python.md` "Dependency seams").
- **Test conditions already seeded** in `issue.md` / `spec.md` (escape-detection matrix, later-started selection, gate block/permit, record shapes and `recolor_generation` increment, remediation-inputs integration, determinism) map one-to-one onto the recommended module boundaries above.

## 8. Integration Contracts (F8's required imports; all **Assumed** until upstream lands)

| ID | From | Contract | Design source | Fallback if absent at execution time |
| --- | --- | --- | --- | --- |
| IC-1a | F1 | Path-subsumption predicate reused for escape detection (same matcher V1 uses), assumed in `scripts/dev_tools/compute_blast_radius.py` | §5.3, §10-F1 | Implement `fnmatch.fnmatchcase` over POSIX-normalized paths per `inventory.py` precedent; record deviation |
| IC-1b | F1 | `conflicts(a, b)` relation for step-4 recomputation with the observed radius substituted for the drifting item's declared radius | §5.4 | Blocking — do not reimplement the relation; if unavailable, the plan must sequence step 4/5 behind F1's landing (F1 is wave 0, so absence indicates a broken branch state) |
| IC-3a | F3 | Checkpoint schema: `drift_events[]` field, `items[]` lifecycle timestamps (start marker: `in_flight_at` or `worktree_created_at`), `blocked_drift` in the `merge_status` enum, `recolor_generation`, `mutations[]` | §12, §8.6 | Blocking — F8 populates, never defines; reconcile field names against F3's spec |
| IC-3b | F3 | `validate_parallel_orchestrator_state.py` exists with the epic-validator structure so F8 can add its key-gated invariant + helper module | §10-F3 | Blocking — same as IC-1b |
| IC-5a | F5 | `Parallel mode: true` kickoff marker line including `parallel_checkpoint_path` (analog of the epic-mode line, `.claude/skills/epic-orchestrate/SKILL.md` lines 121–132) so the hook and the child-side evaluation can locate the parallel checkpoint from a child-worktree cwd | §9 Layer 1 | Reconcile marker text verbatim against F5's skill; the hook constant must match byte-for-byte |
| IC-5b | F5 | `.claude/skills/parallel-orchestrate/SKILL.md` exists with a reserved placeholder section for F8 (recommended name `## Radius Drift Detection and Drift Gate`); `items[].worktree_path` recorded so the parent can write the child's remediation-inputs file | epic.md Wave-4 note, §12 | If no placeholder exists, append the named section at the end without reflowing |
| IC-6a | F6 | Admission control consults `has_unresolved_drift(drift_events) -> bool` (exported by F8) and defers current-cohort admission while true | §7 step 3, §8.3 | F8 exports the predicate regardless; the consultation edge is F6's to wire — record as a cross-feature acceptance dependency |
| IC-6b | F6 | Single recolor entry point `requeue_via_recolor(...)` (section 5, step 5): pins in-flight items (§8.1), recolors the unstarted subgraph, increments `recolor_generation`, appends the `mutations[]` entry | §8.6, §8.1 | Stub behind one narrow seam in F8's module; never a second recolor implementation |

## 9. Recommended File Manifest

Production files (all new; every file well under the 500-line cap of `.claude/rules/general-code-change.md`):

| Path | Content | Est. lines |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | Pure reference implementation: `detect_escaped_paths(changed, declared)`, `select_halted_item(a, b)` (later-started + tie-break), `build_drift_event(...)`, `has_unresolved_drift(events)`; docstring-heavy per commenting policy | ~220 |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | Thin CLI wrapper (argparse; reads diff output/checkpoint paths; isolates I/O from the pure module) | ~130 |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | Key-gated validator helper: `drift_events[]` shape checks, unresolved-drift-versus-`merge_status` invariant (`PARALLEL_DRIFT_GATE_VIOLATION:` messages) | ~180 |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | Layer-1 Agent-matcher deterrent (`PARALLEL_DRIFT_GATE_BLOCKED`), adapted near-verbatim from `enforce-epic-wave-barrier.ps1` | ~220 |
| `.claude/skills/parallel-orchestrate/SKILL.md` (edit) | One new H2 section `## Radius Drift Detection and Drift Gate` | ~70 added |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` (edit, F3 file) | One import + one key-gated dispatch call | ~5 added |
| `.claude/settings.json` (edit) | One hook entry appended to the `Agent` matcher | ~4 added |

File-size risk: none of the new files approaches 500 lines under this split; the split of pure logic (`parallel_drift_detection.py`) from CLI I/O and from the validator helper is what keeps each file small. If detection and halt-selection tests reveal the pure module trending past ~400 lines, split `parallel_drift_halt.py` (halt/tie-break/requeue-decision) out of it.

Test files:

| Path | Covers | Est. lines |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_parallel_drift_detection.py` | Escape matrix (none/single/multiple/glob boundaries), later-started selection incl. equal-timestamp and missing-timestamp tie-breaks, event shapes, `has_unresolved_drift`, determinism | ~300 |
| `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` | CLI parsing/dispatch with seams mocked | ~120 |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py` | Key-gated invariant: absent key = zero errors; unresolved event + progressed status = one error per item; resolved event passes | ~220 |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | Allow on non-feature-review targets / no marker / resolved events; deny on unresolved-without-finding; fail-closed on unreadable checkpoint | ~250 |

## 10. Open Points for the Planner

1. Reconcile every **Assumed** contract in section 8 against the real F1/F3/F5 artifacts (on the integration branch by wave 4) before preflight; F6's two contracts (IC-6a/IC-6b) are concurrent-wave contracts and need the stub-seam treatment described in section 5 step 5.
2. Confirm the `action` enum with F3's landed schema; adopt F3's names if it enumerates one.
3. Confirm the drift-gate reading in section 5 (finding-surfaced-before-review + merge-progression forbidden while unresolved) — it is an interpretation of §9's one-line statement, chosen to avoid deadlocking R4.
4. The child-side evaluation step (running the detection CLI at the child's Pre-Feature-Review Commit under `Parallel mode: true`) is documented in F8's SKILL.md section; it must not modify `.claude/skills/orchestrate/SKILL.md` (additive-only constraint) — the parallel-orchestrate skill section and the kickoff marker carry the child-side instruction, mirroring how epic-mode behavior is carried by the epic kickoff line.
