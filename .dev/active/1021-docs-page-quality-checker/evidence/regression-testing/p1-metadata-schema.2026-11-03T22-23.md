# P1 Page-Metadata Schema Suite - Issue #1021

Timestamp: 2026-11-03T22-23
Task: [P1-T4]
Command: `sh SCRATCH/issue-1021-failnames.sh tests/scripts/claude-lib/docs/DocsPageMetadataSchema.Tests.ps1 issue-1021-p1-meta.txt` (PowerShell 7 `Invoke-Pester` with the repository run settings over the branch-current suite; `Run.PassThru`)
EXIT_CODE: 0
Output Summary: TOTAL=15 PASSED=15 FAILED=0 SKIPPED=0 NOTRUN=0 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. CI: CI-PESTER.

## Covered assertions

- Canonical and runtime copies byte-identical (SHA-256 through `Get-DocsBytesSha256Hex`).
- `$schema` Draft 2020-12, `$id` `urn:drm-copilot:docs:1.0.0:page-metadata`, root `type` `object`, `additionalProperties` false, no `required`.
- Exactly the seven properties `audience`, `diataxis_mode`, `extensions`, `last_reviewed`, `owner`, `surface_refs`, `title`.
- Every `$ref` is a docs common URN reference (no discovery URN, no file).
- `audience`: `type` array, `minItems` 1, `uniqueItems` true, items docs common `audience-id` (CR-1 accepted); the composed item reference `#/$defs/common.audience-id` resolves to the pattern `^[a-z0-9][a-z0-9-]*$(?![\s\S])`.
- `Join-DocsSchemaText` composes it with no finding.
- `Test-Json` against the composed text: `True` for a full valid instance and for an empty instance; `False` for the `audience` item `Dev_Ops`, an empty or repeated `audience`, an unknown `diataxis_mode`, a non-date `last_reviewed` and an unknown property.
