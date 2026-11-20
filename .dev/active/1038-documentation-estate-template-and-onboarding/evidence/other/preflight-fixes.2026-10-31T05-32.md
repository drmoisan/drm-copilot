# Preflight Fixes - Issue 1038

Timestamp: 2026-10-31T05-32
Plan: docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/plan.2026-10-30T18-59.md

Trivial defects fixed in place, in task text and preamble only. No task was added, removed or reordered.

## Fix 1 - `## Existing Tests Asserting Changed Behavior (dispositions)` (incomplete disposition citation)

- Defect: the [P0-T8] search for `docs/engineering` also matches three static JSON fixtures under `tests/fixtures/blast_radius/`. Because they had no row in the table, [P0-T8] could not list them "with its row number".
- Change: added row 6, which names the three fixture files with the disposition "Unchanged: static JSON fixture data; no test enumerates template or page files through them". No assertion changes.

## Fix 2 - [P4-T3], [P4-T4], `## Test Plan` (evidence location)

- Defect: spec acceptance criterion SAC-24 requires the evidence for the fresh single-process run over `tests/scripts` to be under `evidence/regression-testing/`, and the execution-environment brief `## Test Isolation Checks` requires the same. [P4-T3] wrote that evidence to `evidence/qa-gates/`.
- Change: the [P4-T3] artifact is now `<FEATURE>/evidence/regression-testing/pester-coverage.<timestamp>.md`, and the [P4-T4] consumer and the `## Test Plan` coverage line point to the same location. The asserted content is unchanged.

## Fix 3 - [P3-T6] (literal command shape)

- Defect: the step `validate -Mode docs-complete` omitted `-Revision`, which the 1023 `validate` contract requires. Without it the command exits 2 with `DOCS_CLI_ARGUMENTS`, not with the asserted `DOCS_SNAPSHOT_UNPINNED`.
- Change: the step now reads `validate -Mode docs-complete -Revision $DocumentationEstateRevision1` and states the reason. The asserted finding code is unchanged.
