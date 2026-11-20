# P2 Front-Matter Validation - Issue #1021

Timestamp: 2026-11-03T22-41
Task: [P2-T3]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1,tests/scripts/claude-lib/docs/DocsPageMetadata.Tests.ps1 issue-1021-p2-fmv.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suites; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: TOTAL=133 PASSED=133 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0 (DocsPageFrontMatter.Tests.ps1 and DocsPageMetadata.Tests.ps1). CR-3 gate: option A. CI: CI-PESTER.

## Design as executed

- Gate (step 2) under `gate: option A`: `Test-DocsArtifactText -ArtifactKind 'page-metadata'` over `ConvertTo-DocsJsonText` of the parsed front matter; `Test-DocsPageMetadataSchemaGate` and `Get-DocsPageComposedSchemaSet` are not created (option B only).
- CR-4 not accepted: `Get-DocsPageConstraintFinding` is kept and reads `pattern`, `minLength` and `uniqueItems` from the composed schema value; no pattern constant is duplicated.
- Refinement split (spec `### Import graph and allowed import set`, plan `## Pre-Mortem` `File size`): with the validation functions in place `DocsPageFrontMatter.psm1` measured 639 lines, above the 500-line limit of the spec acceptance criterion, so the constraint evaluator moved to `.claude/lib/docs/DocsPageMetadata.psm1` (imports `DocsJson.psm1`, `DocsFinding.psm1`; inside the allowed import set). It holds `Get-DocsPageConstraintFinding`, `Test-DocsPageReviewDate`, `Get-DocsPageValueFinding` (steps 4 and 5), `ConvertTo-DocsPageFieldFinding` (step 6) and `New-DocsPageFieldFinding`. `DocsPageFrontMatter.psm1` imports it and keeps `Test-DocsPageFrontMatter`, which runs steps 1 to 7 in order. The split has its own suite `tests/scripts/claude-lib/docs/DocsPageMetadata.Tests.ps1`, and its classification rows were added to the plan `## Artifact Classification` table in the same change; its bundle copy and `CORE` entry follow in Phase 5.
- Logical line counts (`@(Get-Content -LiteralPath <path>).Count`): `DocsPageFrontMatter.psm1` 422, `DocsPageMetadata.psm1` 303, `DocsPageMarkdown.psm1` 263.

## Tests

- Validation contexts (`DocsPageFrontMatter.Tests.ps1`): `DOCS_PAGE_FIELD_MISSING` per required field with the full `-RequiredField` and none with an empty one; `DOCS_PAGE_FIELD_UNKNOWN` at `/reviewer` with the field line; each per-field invalid code at its catalog pointer (`/owner`, `/last_reviewed`, `/audience`, `/audience/1`, `/diataxis_mode`, `/surface_refs`, `/surface_refs/0`, `/title`, `/extensions`, `/extensions/note`); `Dev_Ops` yields `DOCS_PAGE_AUDIENCE_INVALID` at `/audience/0`; `2026-02-30` yields `DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE` and `2028-02-29` none; `DOCS_PAGE_AUDIENCE_UNDECLARED` at `/audience/1`; fail-closed `DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID` at `''` with `Test-Json` mocked to `False` in the `DocsSchema` module scope (option A), and the gate finding dropped when a field finding explains the failure; each of the three committed in-suite fixtures that `Test-DocsPageFrontMatter` accepts with no finding returns `True` from `Test-Json` against the composed page-metadata schema. Assertions use codes and pointers, never `Test-Json` wording.
- Split-module suite (`DocsPageMetadata.Tests.ps1`): evaluator cases (local reference, pattern, uniqueness, allOf, patternProperties, wrong-type values, unresolvable and foreign references, the composed audience pattern), the calendar check, value checks, the field mapping and the finding factory.
- A parser defect found by the validation tests was fixed in the same task: a one-item block sequence was stored as a scalar because a `$( )` subexpression unrolled the one-element array; `Complete-DocsPageSequence` now assigns with a plain statement, and the parser context `keeps a one-item block sequence as an array` pins it.

## Cross-suite run (informational)

`tests/scripts/claude-lib/docs` in one process: 571 tests, 566 passed, 5 failed. Four failures are in `Docs.Manifest.Tests.ps1` (the new `.claude/lib/docs` files have no `core.json` entry or bundle copy until [P5-T1] and [P5-T2]); one is `DocsSchemaContract.Tests.ps1` `keeps the runtime schema file set equal to schemas/docs/v1 with byte-identical pairs` (`Expected 8, but got 9`), the plan defect recorded in `1020-test-dispositions` and escalated. A reversed-order run of the five touched suites in one process passed 218 of 218. Interim `Invoke-PoshQCTest` line coverage over `tests/scripts/claude-lib/docs`: `DocsPageMarkdown.psm1` 100.00% (102 of 102), `DocsPageFrontMatter.psm1` 100.00% (180 of 180), `DocsPageMetadata.psm1` 100.00% (109 of 109), `DocsSchema.psm1` 100.00% (129 of 129).
