# Remediation Cycle 1 — Spec Amendment to Version 1.2 (Both Design Corrections)

Timestamp: 2026-08-09T06-40

Task: [P1-T13] (recording the amendments made by [P1-T1] through [P1-T12])
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Amended files: `<FEATURE>/spec.md` (version 1.1 -> 1.2), `<FEATURE>/user-story.md` (no version field)
Diff base for the before text: `a9e2463c`

The version is bumped **exactly once** for the whole cycle, to **1.2**. It does not become 1.3.
The AC sets are preserved at exactly 15 (`spec.md` S1-S15) and exactly 9 (`user-story.md` U1-U9),
with no addition, removal, reordering, or renumbering.

## Rationale — Correction C1 (admission checked the in-flight subset)

The pre-1.2 rule admitted a candidate into the current cohort whenever it conflicted with no
`in_flight` item. It was inherited verbatim from the design source
`docs/research/2026-08-07-parallel-orchestration-design-research.md` **line 173**, whose text is:

```
4. **Admission decision.** No conflict with any in-flight item, admit into the current cohort.
   Otherwise defer to a future cohort and recolor the unstarted subgraph.
```

The rule is unsafe because `max_concurrency` caps simultaneously in-flight items independently of
cohort size and each freed slot is refilled with the next unstarted item of the SAME current
cohort in ascending item-key order. The authority for that is
`.claude/skills/parallel-orchestrate/SKILL.md` section
**`## Cohort Barrier and Max-Concurrency Slot Filling`** (cited by exact heading text; the
`**max_concurrency slot filling.**` paragraph reads "`max_concurrency` caps the number of
simultaneously in-flight items independently of cohort size: a cohort of twelve items executes at
most `max_concurrency` items at a time ... refill each freed slot with the next unstarted item of
the current cohort in that same ascending item-key order. A cohort larger than `max_concurrency`
therefore launches in several batches"). The current cohort therefore durably holds not-yet-launched
`scheduled` members.

A cohort is an independent set only because F2's coloring produced it. A candidate inserted into
that cohort without a recolor was not part of that coloring, so nothing establishes its disjointness
from the cohort's unstarted members. The amended rule **strictly generalizes** the previous one,
because every `in_flight` item is itself a member of the current cohort: every candidate the old
rule deferred is still deferred, and the new rule additionally defers a candidate conflicting with
an unstarted current-cohort member. **The pinning invariant is unchanged.**

## Rationale — Correction C2 (recoloring dropped the pinned CONSTRAINT)

Dropping the candidate-to-pinned edges when building the induced subgraph removed the pinned
VERTICES correctly but also removed the pinned CONSTRAINT. F2's `compute_cohorts` places an
edge-free key in cohort 0. The cohort barrier cannot advance `current_cohort` while any item is
`in_flight`, so index 0 is the current cohort in exactly the situation the deferral was meant to
resolve: a candidate deferred BECAUSE it conflicts with an in-flight item becomes an isolated
vertex, is assigned index 0, and rejoins the pinned item it conflicts with.

The corrected rule is the pinned-barrier offset: `crosses_pinned` computed from the FULL edge list
before the induced restriction; `cohort_offset = current_cohort + 1 if crosses_pinned else
current_cohort`; each unstarted key placed at `cohort_offset + local_index`. Because the offset is a
**single uniform shift**, the local-to-absolute map is injective, so F2's distinct color classes
remain distinct cohorts and independence within the unstarted set is preserved exactly by F2's own
guarantee. F3 invariants 13 and 14 remain satisfiable, and that is proven by an **executable
binding test** (`tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` running
F3's landed `validate_parallel_orchestrator_state_text`), not by assertion. **F2
(`scripts/dev_tools/parallel_cohort_computation.py`) is not modified**; the offset is applied
entirely inside F6's `recolor_unstarted`.

## Deliberate Divergence from the Design Research

Both amendments deliberately diverge from
`docs/research/2026-08-07-parallel-orchestration-design-research.md` — C1 from its §8.3 admission
rule at line 173, C2 from the pinning formulation that treats removing the pinned vertices as a
complete account of the pinning constraint. **That design document is NOT amended by this feature.**
It remains the historical design record; `spec.md` 1.2 is the normative source for the corrected
rules. This divergence is recorded in the spec itself, in the `### Design corrections (spec 1.2)`
section added by [P1-T3].

---

## Before / After Text of Every Amended Passage

### 1. FR1 step 4 ([P1-T1], C1)

Before:
```
4. Admission decision:
   - No conflict with any in-flight item: admit into the current cohort. No recompute occurs.
   - Otherwise: defer to a future cohort and recolor the unstarted subgraph (recompute;
     `recolor_generation` increments by exactly one).
```

After:
```
4. Admission decision:
   - No conflict with any member of the current cohort — neither an `in_flight` (pinned) member
     nor an unstarted (`proposed`/`admitted`/`prepared`/`scheduled`) member scheduled into the
     current cohort: admit into the current cohort. No recompute occurs.
   - Otherwise: defer to a future cohort and recolor the unstarted subgraph (recompute;
     `recolor_generation` increments by exactly one).
```

The in-flight-only admission condition is gone. The deferral branch is unchanged in effect.

### 2. FR4 headline and requirements ([P1-T2], C2)

Before (headline):
```
**In-flight items are pinned; scheduling is recomputed only over the not-yet-started subgraph;
recoloring is a pure function of `(remaining subgraph, pinned set)`.**
```

After (headline):
```
**In-flight items are pinned; scheduling is recomputed only over the not-yet-started subgraph;
recoloring is a pure function of `(remaining subgraph, pinned set, pinned cohort index)`.**
```

Before (first requirements bullet):
```
- The recolor function takes the induced subgraph of unstarted items (states
  `proposed | admitted | prepared | scheduled`), the pinned set (states `in_flight`), and the
  current generation; it returns cohort assignments for unstarted items only and never assigns
  or moves a pinned item.
```

After (first requirements bullet, plus one added bullet):
```
- The recolor function takes the induced subgraph of unstarted items (states
  `proposed | admitted | prepared | scheduled`), the pinned set (states `in_flight`), the
  current generation, and the current cohort index that the pinned items occupy; it returns
  cohort assignments for unstarted items only and never assigns or moves a pinned item. The
  returned assignment places every unstarted item at an index at or above `current_cohort`, and
  strictly above `current_cohort` whenever any conflict edge joins an unstarted item to a pinned
  item — the pinned-barrier offset. When no such edge exists the lowest assigned index equals
  `current_cohort` exactly, so unstarted items may share the running cohort and
  `max_concurrency` slot filling is preserved.
- The offset is a single uniform shift applied to every color class, so the mapping from F2's
  local color index to the final absolute index is injective: two unstarted items F2 placed in
  different classes remain in different cohorts, and independence is preserved exactly. No
  non-uniform or per-item remapping is used, because a non-uniform map could collapse two
  distinct classes onto one index and reintroduce a contention violation.
```

The "never assigns or moves a pinned item" requirement is retained verbatim inside the amended
bullet. The purity requirement bullet ("The function is pure: no file I/O, no wall-clock reads, no
mutation of inputs") is unchanged. The delegation bullet ("Coloring delegates to F2's Welsh-Powell
entry point ... F6 must not reimplement the coloring") is unchanged.

### 3. Combined design-correction note ([P1-T3], C1 and C2)

Added as a new section `### Design corrections (spec 1.2)` immediately after FR1 (before FR2). It
did not exist before. Its required content — C1's provenance and unsafety argument with the F5
slot-filling section cited by exact heading text, C2's three composed facts and the four-step offset
rule, the uniform-shift injectivity argument, the F3-invariant-13-and-14 satisfiability claim marked
as proven by executable test, the statement that F2 is not modified, and the deliberate divergence
from the design research — is present in full. Verbatim text is in `spec.md`.

### 4. Recompute Boundary items ([P1-T4])

Before (recompute item 1):
```
1. **Deferred add** — `/parallel-add` where the candidate conflicts with an in-flight item; the
   unstarted subgraph (including the new item) is recolored.
```
After:
```
1. **Deferred add** — `/parallel-add` where the candidate conflicts with any member of the current
   cohort (in-flight or unstarted); the unstarted subgraph (including the new item) is recolored.
```

Before (non-recompute item 1):
```
1. **Admission into the current cohort with no in-flight conflict** — the item joins the
   current cohort; no cohort assignment changes.
```
After:
```
1. **Admission into the current cohort with no conflict against any current-cohort member** — the
   item joins the current cohort; no cohort assignment changes.
```

Added sentence after the non-recompute list:
```
The pinned-barrier offset introduced in FR4 changes only WHICH cohort index an unstarted item
receives; it never changes how many times the generation increments, so a recolor still increments
`recolor_generation` by exactly one and every row of the per-op table below keeps its stated value.
```

**The per-op entry-contents table rows and their values are byte-identical to before this task**,
and the generation arithmetic (including "A sequence of N mutation operations starting at generation
`g` ends at exactly `g + (number of recompute-triggering operations)`") is unchanged.

### 5. API / CLI Surface snippets ([P1-T5])

Before:
```python
def recolor_unstarted(
    unstarted_items: Sequence[str],            # item keys, state in {proposed..scheduled}
    conflict_edges: Sequence[tuple[str, str]], # full graph; induced subgraph taken internally
    pinned: frozenset[str],                    # item keys with state in_flight
    current_generation: int,
) -> RecolorResult:                            # cohorts for unstarted items only,
    ...                                        # generation == current_generation + 1

def decide_admission(
    candidate: str,
    conflict_edges: Sequence[tuple[str, str]], # computed over ALL items incl. in-flight
    in_flight: frozenset[str],
) -> AdmissionDecision:                        # ADMIT_CURRENT_COHORT | DEFER_AND_RECOLOR

def is_closed_mode_complete(items: Mapping[str, ItemRecord]) -> bool: ...
```

After:
```python
def recolor_unstarted(
    unstarted_items: Sequence[int],            # item keys, state in {proposed..scheduled}
    conflict_edges: Sequence[tuple[int, int]], # full graph; induced subgraph taken internally
    pinned: frozenset[int],                    # item keys with state in_flight
    current_generation: int,
    *,
    current_cohort: int,                       # required keyword-only; the pinned items' index
) -> RecolorResult:                            # ABSOLUTE cohort indices for unstarted items only,
    ...                                        # at or above current_cohort, strictly above it
    ...                                        # when an unstarted-to-pinned edge exists;
    ...                                        # generation == current_generation + 1

def decide_admission(
    candidate: int,
    conflict_edges: Sequence[tuple[int, int]], # computed over ALL items incl. in-flight
    in_flight: frozenset[int],                 # the pinning set
    *,
    current_cohort_members: frozenset[int],    # required keyword-only; full current-cohort
                                               # membership, pinned and not-yet-launched
) -> AdmissionDecision:                        # ADMIT_CURRENT_COHORT | DEFER_AND_RECOLOR

def is_closed_mode_complete(items: Mapping[int, ItemRecord]) -> bool: ...
```

Both keyword-only markers (`*`) are present. The stale `str` key types are corrected to `int` for
both functions. `is_closed_mode_complete` is unchanged apart from its key type.

### 6. Test Strategy scenario 4 ([P1-T6], C1)

Before:
```
4. **Admission over ALL items.** A candidate conflicting only with an in-flight item is
   deferred; a candidate conflicting only with an unstarted item is placed by the coloring, not
   rejected; a candidate with no conflicts is admitted into the current cohort with no
   generation change.
```
After: four enumerated cases (in-flight conflict defers and recolors; `scheduled` current-cohort
member conflict defers and recolors, marked as the case the pre-1.2 wording got wrong; unstarted
conflict OUTSIDE the current cohort admits because the cohort barrier keeps the two from running
concurrently; no conflict admits with no generation change). The sentence asserting that an
unstarted conflict is "placed by the coloring, not rejected" without the current-cohort
qualification is **removed**. No other scenario was edited by that task.

### 7. Test Strategy scenario 9 ([P1-T7], C2)

Added; did not exist before. Four cases: strictly-greater index at `current_cohort = 0` and at a
non-zero base; lowest index equals `current_cohort` exactly with no unstarted-to-pinned edge;
uniform offset preserving distinct indices; negative `current_cohort` rejected.

### 8. Property P4 ([P1-T7])

Added after P3 with no renumbering of P1-P3:
```
- **P4 (composed contention invariant):** over arbitrary conflict graphs, arbitrary
  pinned/unstarted partitions, and arbitrary admission-and-recolor sequences, no cohort in the
  resulting assignment contains two items sharing a conflict edge, counting edges to pinned items.
```
P1, P2, and P3 keep their labels and text unchanged. P4 is worded as the FULL-ASSIGNMENT invariant,
not as an admission-only claim.

### 9. AC S2 ([P1-T8], C1)

Before (admission clause only):
`admits into the current cohort only when the candidate conflicts with no in-flight item`
After:
`admits into the current cohort only when the candidate conflicts with no member of the current cohort, in-flight or unstarted`

The rest of S2 and its `[x]` marker are unchanged.

### 10. AC S5 ([P1-T9], C2)

Before (recolor clause only):
`recoloring is a pure function of `(remaining subgraph, pinned set)``
After:
`recoloring is a pure function of `(remaining subgraph, pinned set, pinned cohort index)` and assigns every unstarted item an index strictly above the pinned items' index whenever any unstarted item conflicts with a pinned item`

The existing P1/P2/P3 clause is kept and `P4 (composed contention invariant)` is added to the named
property list within the same criterion. The rest of S5 and its `[x]` marker are unchanged.

### 11. FR9 invariant 3 ([P1-T10], finding R3)

Before:
```
3. The mode-dependent completion invariant per FR7.
```
After: states the two-signal formalization (a `mutations[]` `op == 'close'` record together with an
empty current-generation cohort set, because F3's schema carries no completion field and F6 may add
none), the open-mode terminality requirement, the deliberate non-firing on a healthy in-progress
checkpoint and on an idle `open` run with the reason (firing there would block the next
`/parallel-add`), the citation of the module docstring at
`scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py:16-43` which already documents
the formalization, and the record that F3's own invariant 20 under `require_complete` is what guards
closed-mode completion and is deliberately not duplicated.

### 12. AC S9 ([P1-T10], finding R3)

The clause "and the mode-dependent completion invariant" now reads "and the mode-dependent
completion invariant in its two-signal formalization (a `mutations[]` `op == 'close'` record
together with an empty current-generation cohort set, with the close record required to be terminal
in `open` mode, and no firing on a healthy in-progress checkpoint or an idle `open` run; closed-mode
completion itself is guarded by F3's invariant 20 under `require_complete` and is deliberately not
duplicated)". The rest of S9 and its `[x]` marker are unchanged.

### 13. AC U1 ([P1-T11], C1)

Before (admission clause only):
`admit into the current cohort only when the candidate conflicts with no in-flight item; otherwise defer to a future cohort and recolor the unstarted subgraph`
After:
`admit into the current cohort only when the candidate conflicts with no member of the current cohort, in-flight or unstarted; otherwise defer to a future cohort and recolor the unstarted subgraph`

The rest of U1 and its `[x]` marker are unchanged.

### 14. AC U5 ([P1-T12], C2)

Before (recolor clause only):
`recoloring is a pure function of `(remaining subgraph, pinned set)``
After:
`recoloring is a pure function of `(remaining subgraph, pinned set, pinned cohort index)` and never places an unstarted item in the pinned items' cohort when the two conflict`

The determinism clause ("determinism under mutation against a live in-flight set is proven by unit
and property-based tests") and the `[x]` marker are unchanged.

### 15. Version and Last Updated ([P1-T13])

Before:
```
- **Last Updated:** 2026-08-08T00-00
- **Version:** 1.1 (per-op entry-contents table reconciled to F3's landed `mutations[]` nullability rule)
```
After:
```
- **Last Updated:** 2026-08-09T06-40
- **Version:** 1.2 (design corrections: admission checks the full current cohort, not the in-flight subset; recoloring applies the pinned-barrier offset so a deferred candidate cannot rejoin its pinned conflict; FR9 invariant 3 wording reconciled to the delivered two-signal formalization)
```

Command: `grep -n "Version:" <FEATURE>/spec.md`
EXIT_CODE: 0
Output Summary: exactly one `- **Version:**` line, at line 8, reading `1.2`. The AC counts verified
immediately after the amendments are **15** (`spec.md`) and **9** (`user-story.md`).
