# BLOCKER — [P5-T3] states an unreachable acceptance condition

Timestamp: 2026-08-23T02-34

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P5-T3]
Status: **NOT COMPLETED — reported rather than worked around**

## The task and its acceptance

[P5-T3] requires a fixture `tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json`
"with two radii whose only shared entry is a placeholder token and whose real files are disjoint,
and expected conflict false", with the acceptance "both parity suites report conflict false for the
fixture".

## Why the two halves cannot both hold

A conflict fixture is routed by the presence of the `radius_a` input key to the conflict branch of
both parity harnesses. That branch reads `radius_a` and `radius_b` as **literal recorded radii** and
passes them straight to the conflict relation. It never calls the path classifier.

The conflict relation compares path entries by string equality, directory-prefix containment, and
glob matching only. The chain is `conflicts` -> `_smallest_path_overlap` -> `_entries_overlap`, and
`scripts/dev_tools/_blast_radius_glob.py` shows `_entries_overlap` deciding every case from
`is_glob_entry`, `matches_glob`, `_literal_prefix`, and `_directory_prefix`. No member of that chain
imports or invokes `classify_path_token`.

Consequence: a placeholder token written into a fixture's `radius_a` and `radius_b` is compared as
an ordinary string whether or not the guard exists. The fixture's verdict is therefore **invariant
under this item's fix**, so the fixture can be either satisfiable or discriminating, never both:

- With the placeholder present, the verdict is `true` both before and after the fix, so an expected
  conflict of false can never be produced and the acceptance cannot be met.
- With the placeholder absent, the verdict is `false` both before and after the fix, so the
  acceptance is met by a fixture that is a near-duplicate of the existing
  `tests/fixtures/blast_radius/conflict-none-disjoint.json` and that would have passed identically
  before the guard existed.

The second form is exactly the class of acceptance condition the plan and this repository's
acceptance-gate rules exist to reject: a check whose result does not depend on what the executor
does. It was not authored, and no pass was recorded for it.

## Measurement

Command: `poetry run python <conflict seam probe>`

EXIT_CODE: 0

```text
RAW recorded radii (what the conflict-fixture harness does):
  a.paths: ['<FEATURE>/spec.md', 'scripts/dev_tools/alpha_only_module.py']
  conflict: True [('path_overlap', '<FEATURE>/spec.md ~ <FEATURE>/spec.md')]
NORMALIZED radii (normalize_declared_radius re-runs the classifier):
  a.paths: ['scripts/dev_tools/alpha_only_module.py']
  conflict: False []
```

Both lines were produced **after** the [P2-T4] guard landed. The first line is the conflict-fixture
harness's code path and reports `True`; the second is the normalization seam and reports `False`.

The fixture was additionally authored in the form [P5-T3] specifies and run through the Python
parity suite, which failed as the analysis predicts:

```text
FAILED tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-placeholder-only-overlap] - AssertionError: Fixture conflict-placeholder-only-overlap produced verdict True, expected False.
FAILED tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-placeholder-only-overlap] - AssertionError: Fixture conflict-placeholder-only-overlap produced reasons that differ from its expected block.
2 failed, 73 passed
```

The other three fixtures created in this phase passed in the same run. The unsatisfiable fixture was
then removed from the corpus, because leaving a permanently-failing fixture in place would fail
[P5-T11] and every Phase 8 test gate for a reason unrelated to the code under test.

## Where the plan's own design constraint predicts this

The plan's design-constraint section states that `normalize_declared_radius` calls the classifier
directly per recorded entry, so a guard at the extraction entry point would leave already-recorded
declared radii dirty. That is the correct model, and it identifies `normalize_declared_radius` as
the only seam through which an already-recorded radius is cleaned. [P5-T3] then asks for the
pair-level assertion to be expressed through the conflict-fixture harness, which does not pass
through that seam. The task names the wrong fixture kind for the behaviour it wants to pin.

## Why no workaround was applied

The discriminating construction exists and is shown above: run both recorded radii through
`normalize_declared_radius` and then compare. Reaching it from a conflict fixture would require
adding a new input key to the conflict branch of **both** parity harnesses — a fixture-format
contract extension in two test files, described by no task in this plan, and a new independent
outcome that [P8-T13]'s contract audit would have to account for. That is replanning, not a
micro-action, so it was not done.

## Coverage of the behaviour by tasks that DID complete

The pair-level consequence of the fix is not left unasserted. It is covered by four completed
observations:

| Observation | Task | Artifact |
| --- | --- | --- |
| Placeholder-only overlap reports conflict true pre-fix, in both runtimes, with the negative control false | [P0-T16] | `evidence/baseline/repro-before.md` |
| The same construction reports conflict false post-fix, in both runtimes | [P7-T7] | `evidence/qa-gates/conflict-graph-density.md` |
| Declared-radius normalization strips a placeholder entry and re-resolves the dependent levels | [P5-T8], [P5-T9] | the two normalization test files |
| The real-path conflict channel is unperturbed, proven against a fixture committed before the fix existed and unmodified by it | [P5-T7] | `evidence/qa-gates/negative-control-reuse.md` |

The [P0-T16] and [P7-T7] pair is the strongest of these: it is the same before-and-after comparison
[P5-T3] was reaching for, taken through the derivation seam the guard actually governs, so it does
discriminate.

## Downstream effects recorded rather than absorbed

- **Newly added fixtures: three, not four.** The corpus stands at 35 files, not 36.
- **Corpus floors.** [P5-T5] and [P5-T6] still set both floors to 30 exactly as written. With 35
  files on disk the floor holds and remains non-vacuous, so neither task is affected.
- **[P5-T12].** Its acceptance names "exactly four paths". The observed set is three. That task's
  artifact records the observed three and cites this blocker; it is not marked complete.

## Requested plan revision

Replace [P5-T3] with a task that expresses the pair-level assertion through the seam the guard
governs. Either of these is satisfiable and discriminating:

1. A derivation-fixture pair plus an explicit pair assertion in the two parity suites' existing
   verification-integrity style, which already runs recorded radii through
   `normalize_declared_radius` before computing conflict edges.
2. A named normalization-plus-conflict test in each runtime (not a corpus fixture): build two radii
   carrying a shared placeholder token, normalize both, assert the conflict verdict is false, and
   assert that the same two radii un-normalized still overlap, which pins the seam explicitly.
