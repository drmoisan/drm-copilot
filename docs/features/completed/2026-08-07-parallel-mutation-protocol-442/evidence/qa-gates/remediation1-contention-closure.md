# Remediation Cycle 1 — Contention-Guarantee Closure Statement (From Executed Results)

Timestamp: 2026-08-09T09-18

Task: [P7-T12]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442

Every claim below cites an executed command and its recorded exit code. **No claim in this artifact
rests on prose reasoning alone.**

## Citations

| # | Claim | Artifact | Command | EXIT_CODE |
| --- | --- | --- | --- | --- |
| 1 | **C1 fail-before** — the shipped engine returned `ADMIT_CURRENT_COHORT` for a candidate conflicting with a `scheduled` current-cohort member | `evidence/regression-testing/remediation1-c1-admission-cohort-independence.md` § Fail-Before | `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_admission.py -v` | **1** |
| 2 | **C1 pass-after** — the same test, assertion unchanged in substance, now passes | same artifact § Pass-After | `poetry run pytest <the four migrated modules> -v` | **0** (43 passed) |
| 3 | **C2 fail-before** — the shipped engine returned `{200: 0, 300: 0}`, placing the deferred candidate on the pinned index 0 | `evidence/regression-testing/remediation1-c2-recolor-pinned-barrier.md` § Fail-Before | `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_recolor.py -v` | **1** |
| 4 | **C2 pass-after** — the same test, assertion unchanged in substance, now passes | same artifact § Pass-After | `poetry run pytest <the four migrated modules> -v` | **0** (43 passed) |
| 5 | Both fail-before failures were `AssertionError`, not `TypeError`, so both demonstrations are BEHAVIORAL against the shipped implementation rather than artifacts of a signature change | both artifacts, verbatim assertion output | as above | **1** |
| 6 | The two regressions were isolated: exactly two failing ids in the whole suite, with the baseline passing count reproduced exactly | `evidence/regression-testing/remediation1-regression-isolation.md` | `poetry run pytest -q` | **1** (`2 failed, 3386 passed`) |
| 7 | **Property P4 passes for every seed**, with all four non-vacuity assertions and the offset-value assertion present and themselves passing | `evidence/regression-testing/remediation1-property-p4-binding.md` § Baseline | `poetry run pytest <contention + recolor + pin-stability> -q` | **0** (50 passed) |
| 8 | P4 **rejects the in-flight-only reversion** | same artifact § Reversion 1 | `poetry run pytest <contention module> -q` with the engine mutated | **1** (`9 failed, 4 passed`) |
| 9 | P4 **rejects a removed offset** | same artifact § Reversion 2 | `poetry run pytest <contention + recolor> -q` with the engine mutated | **1** (`6 failed, 20 passed`) |
| 10 | P4 **rejects an unconditional offset** — the case a pure contention assertion cannot detect | same artifact § Reversion 3 | `poetry run pytest <contention + recolor> -q` with the engine mutated | **1** (`3 failed, 23 passed`) |
| 11 | The engine was restored with no mutation residue | same artifact § Restoration | `grep -n "MUTATION" scripts/dev_tools/parallel_mutation_protocol.py` | **1** (no match) |
| 12 | **The F3 invariant binding module passes with ZERO validator errors in all four positive cases**, binding invariants 12, 13, and 14 by execution against the LANDED validator | `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` | `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py -v` | **0** (5 passed) |
| 13 | The consumer merge obligation is **NECESSARY**, not merely sufficient: two current-generation entries at `current_cohort` DO produce a duplicate-index error | same module, `TestMergeObligationIsNecessary` | same command | **0** (the negative-path assertion passes) |
| 14 | **The scenario inventory shows no dropped or weakened test**: 51 of 55 pre-remediation names present verbatim, 3 authorized `replaced` entries each naming a strictly stronger replacement, 1 `corrected (renamed)` entry | `evidence/regression-testing/remediation1-scenario-inventory.md` | `git show a9e2463c:<paths>` name enumeration and difference | **0** |
| 15 | The 500-line ops module is byte-unchanged | `evidence/qa-gates/remediation1-confinement-verification.md` Check I | `git diff a9e2463c -- tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` | **0**, empty output |
| 16 | F2 was not modified, so the offset lives entirely inside F6's function | same artifact Check J | `git diff c939b5b8 -- scripts/dev_tools/parallel_cohort_computation.py` | **0**, empty output |
| 17 | Full suite green after both corrections | `evidence/qa-gates/remediation1-final-py-test-coverage.md` | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | **0** (3407 passed) |

## Closure Statement

**The guarantee "no two items assigned to the same cohort share a conflict edge, including edges to
pinned items" now holds after any admission decision and any recolor, for the inputs the engine is
given.**

That statement rests on the executed results above, on four legs:

1. **The admit branch** cannot place a candidate in a cohort with a conflicting member, pinned or
   unstarted, because `decide_admission` defers on a conflict with any key in
   `in_flight | current_cohort_members` (citation 2), and reverting that union re-fails both the C1
   regression and P4 (citation 8).
2. **The defer branch** cannot place any unstarted item in the pinned items' cohort when a
   candidate-to-pinned edge exists, because `crosses_pinned` is computed from the FULL edge list before
   the induced restriction and shifts every index to `current_cohort + 1` or above (citations 4 and 9).
3. **Within the unstarted set**, independence is F2's guarantee, preserved exactly because the offset is
   a single uniform shift whose local-to-absolute map is injective; F2 itself is unmodified
   (citation 16), and the offset is neither absent nor unconditional (citations 9 and 10).
4. **The consumer write path** cannot produce a duplicate current-generation cohort index when the
   offset is not applied, because the single-entry-per-index merge obligation is stated in the consumer
   instructions and is proven both sufficient and necessary against the landed F3 validator
   (citations 12 and 13).

The composed guarantee is asserted over the FULL assignment map — pinned items at `current_cohort` plus
the unstarted items at the engine's returned indices — after EVERY step of a generated
admission-and-recolor sequence, across a 12-seed corpus whose non-vacuity is itself asserted
(citation 7).

## Residual Gap Assessment (restated from the remediation plan)

After C1 and C2, **no residual gap remains that is distinct from the pre-existing, already-recorded
caller-side obligation.** The engine's guarantee is complete for the inputs it is given, on the four
legs above.

The **only** remaining way to co-schedule conflicting work is for a **CALLER** to supply an untrue
`current_cohort_members`, `in_flight`, or `current_cohort` value — for example by reading a stale
checkpoint instead of re-deriving durable state. **That is not a new residual and not a gap in the
engine.** A pure function cannot verify the truth of its own arguments. It is the cache-doctrine
obligation **already recorded** in `<FEATURE>/spec.md` § Constraints & Risks item 4 and **already
enforced** by the mandatory re-derivation step in `.claude/skills/parallel-add/SKILL.md`
§ Re-Derive Durable State Before Applying Anything. [P5-T1], [P5-T2], and [P5-T3] additionally added the
explicit caller obligation to write the returned indices verbatim and to derive both new arguments from
re-verified durable state.

## No `docs/features/potential/` Entry Was Created for This Residual

**No `docs/features/potential/` entry was created for the caller-side residual**, because it is not a
new finding: it is the pre-existing cache-doctrine obligation already documented in the spec and
already enforced by the skill procedure. Recording it as a new potential item would duplicate existing
documentation.

Likewise **no potential entry was created for the C2 gap itself**, because C2 was closed in code in this
cycle rather than deferred. The **only** `docs/features/potential/` entry this cycle creates is the R4
TypeScript-parity deferral at `docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md`.
