# Remediation Cycle 1 — File-Size Cap Verification

Timestamp: 2026-08-09T09-07

Task: [P7-T9]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442

Command: `wc -l` over every touched and every new file
EXIT_CODE: 0

The absolute cap from `.claude/rules/general-code-change.md` § File Size Limit, restated as plan
Constraint 7, is **500 lines** for every production, test, and reusable script file. The per-module
figures in the plan's `## Test-Module Relocation Arithmetic` are planning budgets.

## Measured Line Counts

| File | Measured | Planned budget | `<= 500` cap | Within budget |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_mutation_protocol.py` | **499** | `<= 500` | PASS | PASS |
| `scripts/dev_tools/_parallel_mutation_models.py` | **469** | `<= 500` | PASS | PASS |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | **313** | `<= 500` | PASS | PASS |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | **362** | `<= 500` | PASS | PASS |
| `scripts/dev_tools/_parallel_mutation_entries.py` | **250** | `<= 500` | PASS | PASS |
| `tests/scripts/dev_tools/test_parallel_mutation_admission.py` | **220** | `<= 200` | PASS | **OVER by 20** (deviation below) |
| `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` | **311** | `<= 320` | PASS | PASS |
| `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py` | **493** | `<= 400` | PASS | **OVER by 93** (deviation below) |
| `tests/scripts/dev_tools/test_parallel_mutation_pin_stability_properties.py` | **286** | not budgeted (fifth module) | PASS | n/a (deviation below) |
| `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` | **326** | `<= 260` | PASS | **OVER by 66** (deviation below) |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` | **397** | `<= 500` (approximately 379 computed) | PASS | PASS |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` | **500** | `<= 500` (approximately 418 computed) | PASS | PASS, at the cap |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` | **500** | 500 exactly, byte-unchanged | PASS | PASS |

**Every listed file is `<= 500` lines. The cap is not relaxed for any file.** The highest values are
`test_parallel_mutation_protocol_properties.py` and `test_parallel_mutation_protocol_ops.py` at
exactly 500, and `scripts/dev_tools/parallel_mutation_protocol.py` at 499.

## `test_parallel_mutation_protocol_ops.py` — Byte-Unchanged at Exactly 500

Command: `git diff a9e2463c -- tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`
EXIT_CODE: 0
Output Summary: **empty output** — the module is byte-identical to the pre-remediation commit and
remains at exactly 500 lines. No task in this plan edited it, and [P0-T9] confirmed it contains zero
call sites for either changed function, so no edit was ever required. (Base `a9e2463c` is the correct
base for this check; `c939b5b8` would report the whole file as a `500 0` addition because the path is
absent from that commit, which [P0-T8] records as the correct inventory value.)

## Recorded Budget Deviations

Four planning budgets were exceeded while the **absolute 500-line cap was satisfied everywhere**. In
each case the alternative was either to breach the cap or to delete policy-mandated docstring content,
and the cap plus the commenting policy were treated as binding over the planning figure.

1. **`test_parallel_mutation_admission.py`: 220 vs `<= 200`.** The plan's arithmetic budgeted
   +2 lines per converted call site (9 admission sites = +18) but the correction also ADDED two new
   tests replacing `test_unstarted_conflict_is_placed_by_the_coloring_not_rejected` (approximately
   +25). Applying the plan's own arithmetic honestly to the relocated 87-line class plus the C1 test
   plus the module header lands near 210-220, so the 200 figure was a slight underestimate in the plan
   itself. Two compression passes reduced the module from an initial 270 to 220; further reduction
   would have required removing mandated class and module docstring content.

2. **`test_parallel_mutation_contention_properties.py`: 493 vs `<= 400`.** Property P4 as the plan
   specifies it — full-assignment map replay, a per-step contention assertion, an independent
   offset-value assertion, and four corpus existentials — plus the corrected per-function admission
   property and a self-contained seeded generator measure 493 lines after a full docstring compression
   pass. It is under the cap with 7 lines of headroom.

3. **`test_parallel_mutation_cohort_invariant_binding.py`: 326 vs `<= 260`.** Constructing a
   checkpoint carrying every key F3 invariant 1 requires, plus the five required cases including the
   negative-path duplicate-index case, plus the builder helpers with mandated docstrings, measures 326.

4. **A fifth test module was created: `test_parallel_mutation_pin_stability_properties.py` (286).**
   The plan assigns the relocated P3 property to the contention module, but that module carrying P4,
   the admission property, the generator, AND P3 measured **584 lines — 84 over the absolute cap** —
   after compression. P3 could not return to
   `test_parallel_mutation_protocol_properties.py` either, which is at 500 exactly. Because the plan
   forbids cross-test-module imports, P3 cannot share the contention module's generator from another
   file. The resolution applies the plan's own stated principle verbatim — "Each new property module is
   self-contained: it defines its own seeded `random.Random(seed)` generator and imports from no other
   test module. That duplication is deliberate and is the cost of the 500-line cap" — by giving P3 its
   own self-contained sibling module. Both P3 tests keep their original names and assertions; nothing
   was dropped or weakened. Recorded in full in
   `<FEATURE>/evidence/regression-testing/remediation1-scenario-inventory.md`.

## Acceptance Verdict

- Every listed file is `<= 500` lines: **PASS**.
- `test_parallel_mutation_protocol_ops.py` is still exactly 500 lines and byte-unchanged against
  `a9e2463c`: **PASS**.
- The cap is not relaxed for any file: **PASS**.
- Within planned budget: **PASS for 9 of 12 budgeted files; 3 exceeded their planning budget and a
  fifth module was added**, each recorded above with its justification and each still under the
  absolute cap.
