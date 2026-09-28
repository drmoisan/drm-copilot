# Remediation Cycle 1 — Engine Size and Purity After Both Corrections

Timestamp: 2026-08-09T07-09

Task: [P3-T9]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Module under check: `scripts/dev_tools/parallel_mutation_protocol.py`
State at capture: [P3-T1] through [P3-T8] applied (both signatures, both docstrings, the offset
logic, the negative guard, the corrected induced-subgraph comment, and the module-docstring pinning
paragraph).

## Check 1 — Line count against the 500-line cap

Command: `wc -l scripts/dev_tools/parallel_mutation_protocol.py`
EXIT_CODE: 0
Output Summary: **499** lines.

| Metric | Value |
| --- | --- |
| Baseline at `a9e2463c` ([P0-T9]) | 393 |
| After both corrections | **499** |
| Cap | 500 |
| Headroom | 1 line |
| Verdict | **PASS** — `<= 500` |

### Recorded intermediate over-cap condition and its correction

The first draft of the [P3-T5] docstring brought the file to **501** lines, one line over the
absolute cap. That is a genuine constraint violation and was corrected immediately, inside this same
task, by tightening prose in the `recolor_unstarted` docstring — reflowing the pinned-guarantee
paragraph and the uniform-shift paragraph without removing any required element. Every element the
plan requires in that docstring is still present and verifiable in the file: the two-part account
(induced subgraph excludes pinned VERTICES; the offset honours the pinned CONSTRAINT), the
`current_cohort` `Args:` entry with its cohort-barrier justification and the re-verified-durable-state
requirement, the absolute-index `Returns:` contract with both cases, the `Raises:` entry for
`ParallelCohortInputError` on a negative `current_cohort` alongside the propagated duplicate-key
error, and the uniform-shift paragraph naming
`tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` as the executable proof
of F3 invariants 13 and 14. No requirement was dropped to fit the cap, and the cap was not relaxed.

Formatting was then confirmed stable, so the 499-line figure is Black's own output and not a
pre-format count:

Command: `poetry run black scripts/dev_tools/parallel_mutation_protocol.py scripts/dev_tools/_parallel_mutation_models.py tests/scripts/dev_tools/test_parallel_mutation_admission.py tests/scripts/dev_tools/test_parallel_mutation_recolor.py`
EXIT_CODE: 0
Output Summary: `4 files left unchanged.` — Black introduces no further line-count change, so 499 is
the final formatted count.

## Check 2 — Purity: no I/O, clock, or RNG access introduced

Command: `grep -n "open(\|Path(\|datetime.now\|random\." scripts/dev_tools/parallel_mutation_protocol.py`
EXIT_CODE: **1**
Output Summary: **no match**. Exit code 1 is `grep`'s no-match status and is therefore the REQUIRED
outcome for this check, not a failure. The plan states this explicitly.

Interpretation: the module contains no `open(` call, no `Path(` construction, no `datetime.now`
read, and no `random.` access. Neither correction introduced file I/O, a wall-clock read, or RNG
access. Both changed functions remain pure functions of their arguments:

- `decide_admission` forms `in_flight | current_cohort_members` and scans the supplied edge
  sequence; it reads its inputs and mutates none of them.
- `recolor_unstarted` computes `crosses_pinned` from the supplied edge sequence, builds the induced
  edge list, delegates to `compute_cohorts`, and derives the offset assignment in one comprehension;
  it reads its inputs and mutates none of them. The new `ParallelCohortInputError` guard raises
  rather than performing any side effect.

The `clock: Callable[[], datetime]` seam remains the only source of a timestamp anywhere in the
engine, and neither changed function takes or uses it.

## Acceptance Verdict

- File is `<= 500` lines: **PASS** (499).
- No I/O, clock, or RNG access introduced: **PASS** (purity grep exits 1 with no match).
