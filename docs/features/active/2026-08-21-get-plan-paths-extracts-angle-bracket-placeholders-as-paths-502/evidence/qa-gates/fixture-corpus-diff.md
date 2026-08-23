# QA Gate — Fixture-Corpus Diff — [P5-T12]

Timestamp: 2026-08-23T05-08

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P5-T12] (revision 6 expectation: three paths)

## Command 1 — porcelain status

Command: `git status --porcelain -- tests/fixtures/blast_radius`

EXIT_CODE: 0

```text
```

Empty.

## Command 2 — anchored diff

Command: `git diff --name-status main -- tests/fixtures/blast_radius`

EXIT_CODE: 0

```text
A	tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json
A	tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json
A	tests/fixtures/blast_radius/validation-placeholder-self-consistent.json
```

Resolved `main` SHA: `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`

The same diff taken against the merge base `bee15c0660d382ed74c642d2e028fd136051046f` returns the
identical three-entry result, so this gate's outcome does not depend on the ref position. That second
anchor is taken because `main` is no longer an ancestor of `HEAD`: `origin/main` is 27 commits ahead
after issue #500 merged as pull request #514, and `HEAD` is 9 ahead. This pathspec is untouched by
#500, which is why the two anchors agree here where they diverge elsewhere.

## The union, and why this run is the proof the union form was needed

| Path | Status | Created by |
| --- | --- | --- |
| `tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json` | added (`A`) | [P5-T2] |
| `tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json` | added (`A`) | [P5-T1] |
| `tests/fixtures/blast_radius/validation-placeholder-self-consistent.json` | added (`A`) | [P5-T4] |

**Three paths.** Every entry is one of the three fixtures created by [P5-T1], [P5-T2], and [P5-T4],
and every entry carries an added status.

The commit state **inverted between the two executions of this gate**, which is the clearest possible
demonstration that neither command alone would do:

| Run | Fixture state | Porcelain output | Anchored-diff output |
| --- | --- | --- | --- |
| first execution | untracked | 3 entries, `??` | empty |
| this execution, after commit `fd20019d` | committed | empty | 3 entries, `A` |

Had this gate relied on the porcelain form alone it would now report zero paths and pass vacuously;
had it relied on the anchored diff alone it would have reported zero paths on the first run. The union
returns the same three-path set in both states. This is exactly the vacuity the task text warned
about, observed rather than hypothesised.

`git add --intent-to-add` was again not substituted for either command: it mutates the index, and the
union needs no such side effect. That prohibition is scoped to this task and does not conflict with
the `git add -A` step the five Phase 8 audits require, which need diff *content* and line counts that
no union of status output can supply.

## Zero modified entries — the clause that carries the substantive proof

The union carries **zero** entries with a modified status. Neither command reported an `M` or ` M`
entry under `tests/fixtures/blast_radius`, which proves all **32** pre-existing top-level fixtures are
unmodified in both commit states. The nested
`verification-integrity/verification-integrity-485-486-487.json` capture is likewise unreported and
therefore unmodified, so the stronger statement holds across all 33 pre-existing fixture files.

This is the half of the gate that carries the real risk, and revision 6 left it untouched for that
reason. A change that quietly adjusted an existing fixture's `expected` block to accommodate the new
guard would be invisible to both parity suites, because each suite reads the fixture as its own source
of truth and neither can detect that the truth moved. The zero-modified-entry observation forecloses
that. It is corroborated by [P5-T7]'s dedicated `--exit-code` diff for the reused negative control and
by [P8-T14]'s whole-tree audit.

## Why the count is three and not four

Revision 6 replaced [P5-T3]'s conflict fixture with a named normalization-plus-conflict test per
runtime. Those tests edit two pre-existing files, both outside this pathspec, and create nothing, so
the fixture count fell from four to three and the created-path list from nine to eight. The original
fixture was unsatisfiable in the parity harness; the seam analysis is at
`evidence/other/p5-t3-blocker-conflict-fixture-seam.md` and the replacement tests are recorded at
`evidence/regression-testing/placeholder-pair-normalization-tests.md`.

The on-disk corpus stands at **35** JSON fixtures, so the floors of 30 set by [P5-T5] and [P5-T6]
remain non-vacuous.

## Output Summary

The union of the porcelain status and the `main`-anchored diff names **exactly three** paths, each one
of the three fixtures created by [P5-T1], [P5-T2], and [P5-T4], each carrying an added status. The
union carries **zero** entries with a modified status, proving all 32 pre-existing fixtures are
unmodified in both commit states. Both anchors agree. The commit state inverted between this run and
the previous one, so both halves of the union have now been observed carrying the result on their own.
