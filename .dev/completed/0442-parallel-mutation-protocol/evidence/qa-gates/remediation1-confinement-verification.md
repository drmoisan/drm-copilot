# Remediation Cycle 1 — Shared-File Confinement and Additive-Only Verification

Timestamp: 2026-08-09T09-12

Task: [P7-T10]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442

**Bases used, per the plan's `## Conventions Used in This Plan`.** `a9e2463c` is the base for Checks
**E, G, I, and K** — every check asking what THIS remediation cycle changed. `c939b5b8` is the base
for the whole-branch confinement Checks **A, B, C, D, F, and J**. Check **H** compares working-tree
files against their bundle mirrors and uses no base. `c939b5b8` is never used to prove byte-identity
on a path this feature created.

Note on `git` line-ending warnings: several commands emit
`warning: in the working copy of '<path>', CRLF will be replaced by LF the next time Git touches it`.
`.gitattributes` declares `* text=auto eol=lf`, so LF is the repository's canonical form and `git`
normalizes on comparison. These warnings are informational and affect no verdict below.

---

## Check A — No epic contention (base `c939b5b8`)

Command: `git diff --stat c939b5b8 -- .` filtered for `.claude/rules/`, `enforce-epic-*`, epic skills,
epic agents, and epic validators
EXIT_CODE: 1 from the filter (no matching line), which is the required outcome for a
no-match filter
Output Summary: **no modified file under `.claude/hooks/enforce-epic-*`, no modified epic skill, agent,
or validator, and no modified file under `.claude/rules/`** appears anywhere in the whole-branch diff.

Command: `git status --porcelain -- .claude/rules .claude/hooks .claude/skills/epic-orchestrate .claude/skills/epic-plan .claude/agents`
EXIT_CODE: 0
Output Summary: **empty output** — no modified and no untracked path under `.claude/rules/`, under
`.claude/hooks/` (so no `enforce-epic-*` hook), under either epic skill, or under `.claude/agents/`.

Independent corroboration: the two pinned-digest assertions in
`test_parallel_orchestrator_surface_contracts.py` for `.claude/agents/epic-orchestrator.md` and
`.claude/skills/epic-orchestrate/SKILL.md` both PASS ([P5-T8]).

**VERDICT A: PASS.**

---

## Check B — Orchestrate SKILL confinement (base `c939b5b8` for the whole-branch view; this cycle's hunks measured against `a9e2463c`)

Heading positions measured in the current file: `## Mutation Protocol (F6)` at line **435**,
`## Enforcement Hooks (F7)` at line **612**.

Command: `git diff -U0 a9e2463c -- .claude/skills/parallel-orchestrate/SKILL.md`, with each new-side
hunk range tested for containment strictly between the F6 and F7 headings
EXIT_CODE: 0
Output Summary: **all seven of this cycle's hunks fall strictly inside the F6 section**:

| New-side hunk lines | Inside F6 section (436-611) |
| --- | --- |
| 443-445 | yes |
| 464 | yes |
| 467-485 | yes |
| 489-499 | yes |
| 508-509 | yes |
| 517-518 | yes |
| 604-607 | yes |

**No added or removed line falls before the `## Mutation Protocol (F6)` heading or at or after the
`## Enforcement Hooks (F7)` heading.**

`## Cohort Barrier and Max-Concurrency Slot Filling` byte-identity, verified by extracting the section
from `git show c939b5b8:` (decoded as UTF-8) and from the working tree and comparing after LF
normalization: **identical: True**. The F7 and F8 section heads are likewise identical to `a9e2463c`.

Command: `grep -n "^## " .claude/skills/parallel-orchestrate/SKILL.md`
EXIT_CODE: 0
Output Summary: the same **16** `##` headings in the same order as the base. The three wave-4 headings
remain in the order `## Mutation Protocol (F6)` (435) -> `## Enforcement Hooks (F7)` (612) ->
`## Radius Drift Detection (F8)` (616). **No section was relocated, reflowed, reordered, or
retitled.** Other sections are referenced only by exact heading text.

**VERDICT B: PASS.**

---

## Check C — Validator confinement (base `c939b5b8`)

Command: `git diff --numstat c939b5b8 -- scripts/dev_tools/validate_parallel_orchestrator_state.py`
EXIT_CODE: 0
Output Summary: **`2 0`** — exactly two added lines and **zero removed lines**. The two added lines,
verbatim:

```
+from scripts.dev_tools import _parallel_orchestrator_state_mutations as mutation_rules
+    errors.extend(mutation_rules.validate_mutation_protocol(state_map, CONTEXT))
```

exactly one added import line and one added call line, as required.

F7 seam byte-identity: the 8-line block between `# BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION`
and `# END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` is **byte-identical to the base**
(verified: `True`). F6's call line sits OUTSIDE that block. **This remediation cycle added no further
line to this file**; the `2 0` figure is the base plan's and is unchanged.

**VERDICT C: PASS.**

---

## Check D — Settings confinement (base `c939b5b8`)

Command: `git diff --numstat c939b5b8 -- .claude/settings.json`
EXIT_CODE: 0
Output Summary: **`4 0`** — exactly the one added Bash-matcher hook entry (4 lines) and nothing else;
zero removed lines. Unchanged by this remediation cycle.

**VERDICT D: PASS.**

---

## Check E — No schema growth (base `a9e2463c`)

Command: `git diff a9e2463c -- scripts/dev_tools/_parallel_state_common.py scripts/dev_tools/_parallel_state_records.py scripts/dev_tools/_parallel_state_structures.py .claude/rules/parallel-orchestration.md`
EXIT_CODE: **0** with **empty output**.

This proves **no member was added to any of the nine parallel enums** — all nine are declared in
`scripts/dev_tools/_parallel_state_common.py` lines 39-82 (`VALID_ITEM_STATES`, `VALID_MERGE_STATUS`,
`VALID_SOURCES`, `VALID_KINDS`, `VALID_MODES`, `VALID_MUTATION_OPS`, `VALID_DISPOSITIONS`,
`VALID_EDGE_REASONS`, `VALID_DRIFT_ACTIONS`) — and that **no F3 record-shape module changed** and
`.claude/rules/parallel-orchestration.md` is untouched.

Command: `grep -n -A 3 "^MUTATION_ENTRY_FIELDS" scripts/dev_tools/_parallel_orchestrator_state_mutations.py`
compared against `git show a9e2463c:scripts/dev_tools/_parallel_orchestrator_state_mutations.py`
EXIT_CODE: 0
Output Summary: both list the identical seven `mutations[]` field names,
`"op item_key at prior_state new_state disposition recolor_generation"`. **No field was added to
`mutations[]`, `drift_events[]`, or `conflict_edges[]`.**

Note: this cycle DELETED three local op-classification tuples from two F6-owned modules and replaced
them with imports of F3's originals ([P6-T1], [P6-T2]). That is a reduction in restated schema
knowledge, not growth, and it changed no F3 file — Check E's empty diff confirms F3's own modules were
not touched.

**VERDICT E: PASS.**

---

## Check F — Config confinement (base `c939b5b8`)

Command: `git diff c939b5b8 -- pyproject.toml`
EXIT_CODE: 0
Output Summary: **`4 0`** — four added lines, zero removed, ALL inside
`[tool.ruff.lint.per-file-ignores]`: one comment line citing the two mandating policies plus three
`= ["S311"]` entries for the three seeded-RNG test modules. No other table, key, or line changed; no
dependency, dependency group, coverage, pytest, or Pyright setting was touched.

Command: `git diff c939b5b8 -- poetry.lock`
EXIT_CODE: 0
Output Summary: **empty output** — **no dependency changed.** `hypothesis` remains absent.

Recorded deviation: the plan's [P6-T4] specifies "exactly two entries" and a total of three added
lines. **Four lines were added — a third `= ["S311"]` entry** for
`tests/scripts/dev_tools/test_parallel_mutation_pin_stability_properties.py`, the fifth test module
created under the [P7-T9] / scenario-inventory deviation. That module carries the relocated P3
property and its own self-contained seeded `random.Random` generator, so it needs the same
authorization as its two siblings; without the entry `poetry run ruff check .` would fail on S311. The
edit remains confined to the one table.

**VERDICT F: PASS**, with the recorded three-versus-four-line deviation.

---

## Check G — Base plan untouched by this cycle (base `a9e2463c`)

Command: `git diff a9e2463c -- docs/features/active/2026-08-07-parallel-mutation-protocol-442/plan.md`
EXIT_CODE: **0** with **empty output**, proving the fully-executed base plan is **byte-identical** to
the pre-remediation commit. No checkbox was toggled, no line was added or removed, and no
line-count-preserving edit was made.

The whole-branch numstat `170 114` recorded for this path by [P0-T8] is retained as an **informational
baseline only and is explicitly NOT the proof**: numstat equality against `c939b5b8` cannot detect a
line-count-preserving edit, because a line replaced inside the added-line set is still counted as one
addition and the `c939b5b8` line it displaced is still counted as one deletion, leaving `170 114`
unchanged. Byte-identity against `a9e2463c` is the proof, and it holds.

**VERDICT G: PASS.**

---

## Check H — Bundle parity (no base; working tree versus mirrors)

Command: `diff` between each edited `.claude/**` file and its
`extensions/drm-copilot/resources/claude-customizations/.claude/**` mirror
EXIT_CODE: 0 for all three
Output Summary: **no difference** reported for any pair:

| File | Result |
| --- | --- |
| `.claude/skills/parallel-add/SKILL.md` | IDENTICAL |
| `.claude/skills/parallel-remove/SKILL.md` | IDENTICAL |
| `.claude/skills/parallel-orchestrate/SKILL.md` | IDENTICAL |

Command: `git status --porcelain -- .claude`
EXIT_CODE: 0
Output Summary: exactly three modified paths, all three of which are the files above, so **every
`.claude/**` file this cycle touched is mirrored**. The landed contract suite
`test_push_down_claude_resource_contracts.py` independently passes ([P5-T8]), and
`pack-manifests/core.json` requires no change because no `.claude` file was added or removed.

**VERDICT H: PASS.**

---

## Check I — Ops test module byte-unchanged (base `a9e2463c`)

Command: `git diff a9e2463c -- tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`
EXIT_CODE: **0** with **empty output**, proving this remediation cycle added and removed **no line** in
the 500-line module. It remains at exactly 500 lines. `a9e2463c` is the correct base: `c939b5b8` would
report the whole file as a `500 0` addition because the path is absent from that commit, which [P0-T8]
records as the correct inventory value rather than an anomaly.

**VERDICT I: PASS.**

---

## Check J — F2 untouched (base `c939b5b8`)

Command: `git diff c939b5b8 -- scripts/dev_tools/parallel_cohort_computation.py`
EXIT_CODE: **0** with **empty output**, proving the pinned-barrier offset was added **entirely inside
F6's `recolor_unstarted`** and that no part of F2's coloring, vertex ordering, or `(-degree, item_key)`
tie-break was changed or reimplemented. F6 imports `ParallelCohortInputError` and `compute_cohorts`
from F2 and modifies neither.

**VERDICT J: PASS.**

---

## Check K — `POPULATED_RESERVED_HEADINGS` remains a one-line append (base `a9e2463c`)

Command: `git diff a9e2463c -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
EXIT_CODE: **0** with **empty output** — neither file changed in this cycle.

Command: `grep -n "POPULATED_RESERVED_HEADINGS" tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
EXIT_CODE: 0
Output Summary: **exactly one declaration, at line 83**:

```python
POPULATED_RESERVED_HEADINGS: tuple[str, ...] = ("## Mutation Protocol (F6)",)
```

a **single-element tuple**, proving F6 neither expanded the tuple on F7's or F8's behalf nor altered
the skip guard at `test_parallel_orchestrator_surface_contracts.py:260`, which is present and
unmodified. F7 and F8 each need only one added line.

**VERDICT K: PASS.**

---

## Note on Concurrent Features

If F7 or F8 lines are present in a shared file because their branches merged first, those lines are
part of the base for these comparisons and are not an F6 violation. These checks constrain only F6's
own added and removed lines.

## Summary of Verdicts A-K

| Check | Subject | Base | Verdict |
| --- | --- | --- | --- |
| A | No epic or `.claude/rules/**` contention | `c939b5b8` | **PASS** |
| B | Orchestrate SKILL in-section confinement | `c939b5b8` / hunks vs `a9e2463c` | **PASS** |
| C | Validator: one import + one call, F7 seam intact | `c939b5b8` | **PASS** |
| D | Settings: one added hook entry | `c939b5b8` | **PASS** |
| E | No schema or enum growth | `a9e2463c` | **PASS** |
| F | Config confinement, lock unchanged | `c939b5b8` | **PASS** (3-vs-4-line deviation recorded) |
| G | Base plan byte-identical | `a9e2463c` | **PASS** |
| H | Bundle parity | none | **PASS** |
| I | Ops test module byte-unchanged | `a9e2463c` | **PASS** |
| J | F2 untouched | `c939b5b8` | **PASS** |
| K | `POPULATED_RESERVED_HEADINGS` one-line append | `a9e2463c` | **PASS** |

**Every check A-K passes. No confinement violation was found.** One deviation is recorded (Check F's
fourth added line), and it is confined to the same single `pyproject.toml` table.
