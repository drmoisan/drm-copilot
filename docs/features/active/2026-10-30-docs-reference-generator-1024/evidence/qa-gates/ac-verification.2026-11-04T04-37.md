# Acceptance Criteria Verification (issue 1024)

Timestamp: 2026-11-04T04-37
Task: [P9-T10]
Command: Invoke-PoshQCTest over the five property suites, the render suite and the boundary suite (182 tests, 0 failures), then a SCRATCH helper listing the passing JUnit cases whose names end in (seed 11), (seed 23), (seed 47), (seed 101) and (seed 211) for each of the 22 exported pure functions; other criteria cite the evidence artifacts below
EXIT_CODE: 0
Output Summary: spec.md: 26 of 27 checked (AC-27 CI-dependent, pending-CI). user-story.md: 17 of 17 checked. Every one of the 22 exported pure functions has five passing seeded cases. AC-20 and AC-26 carry recorded deviations (see below) that the orchestrator should review.

Source files: `docs/features/active/2026-10-30-docs-reference-generator-1024/spec.md` (`## Acceptance Criteria`, 27 items) and `user-story.md` (`## Acceptance Criteria`, 17 items); work mode `full-feature`.

## spec.md

| AC | Short label | Status | Evidence |
|---|---|---|---|
| AC-1 | byte identity | checked | `DocsReferenceWriter.Properties.Tests.ps1` (`Get-DocsReferenceGeneration` seeded cases), `DocsReferenceIntegration.Tests.ps1`; `qa-gates/pester-final.2026-11-04T04-00.md` |
| AC-2 | prose preservation property | checked | `DocsReferenceMarkers.Properties.Tests.ps1` (`Merge-DocsReferenceBlock`: 4 seeded properties x 5 seeds, all passing); pester-final |
| AC-3 | removed block reported | checked | `DocsReferenceIntegration.Tests.ps1`, `DocsReferenceMarkers.Tests.ps1`; pester-final |
| AC-4 | 1021 `check` zero findings | checked | `DocsReferenceIntegration.Tests.ps1`; pester-final |
| AC-5 | front matter conforms; no pattern constants; preservation | checked | `DocsReferenceIntegration.Tests.ps1`, `DocsReferenceFrontMatter.Tests.ps1`, `DocsReferenceBoundary.Tests.ps1` (pattern-constant test); pester-final |
| AC-6 | envelope validation and key sets | checked | `DocsReferenceIntegration.Tests.ps1`; pester-final |
| AC-7 | dry run | checked | `DocsReferenceWriter.Tests.ps1`; pester-final |
| AC-8 | write mode | checked | `DocsReferenceWriter.Tests.ps1`; pester-final |
| AC-9 | conflict and write failure | checked | `DocsReferenceWriter.Tests.ps1`, `DocsReferenceWriter.Errors.Tests.ps1`; pester-final |
| AC-10 | exit codes | checked | `DocsReferenceWriter.Errors.Tests.ps1`, `DocsReferenceWriter.Tests.ps1`; pester-final |
| AC-11 | finding catalog and page blocking | checked | `DocsReferenceMarkers.Tests.ps1`, `DocsReferenceFrontMatter.Tests.ps1`, `DocsReferencePlan.Tests.ps1`, `DocsReferenceWriter*.Tests.ps1`; pester-final |
| AC-12 | six halted-preflight property tests | checked | seeded listing below (6 functions x 5 seeds) |
| AC-13 | property tests for the other public pure functions plus inventory | checked | seeded listing below (16 functions x 5 seeds); `DocsReferenceBoundary.Tests.ps1` property-test inventory |
| AC-14 | generation rules | checked | `DocsReferencePlan.Tests.ps1`; pester-final |
| AC-15 | marker layout and headings | checked | `DocsReferenceRender.Tests.ps1`, `DocsReferenceWriter.Properties.Tests.ps1`; pester-final |
| AC-16 | determinism and clock-free | checked | `DocsReferenceWriter.Tests.ps1` (every command test with a throwing `UtcNow`); pester-final |
| AC-17 | module boundary | checked | `DocsReferenceBoundary.Tests.ps1`; pester-final |
| AC-18 | dispatch row | checked | `DocsReferenceWriter.Tests.ps1` (membership and `Test-DocsCommandTable`); `git diff EPIC-BASE` of `Invoke-DocsCommand.ps1` shows one added line under the anchor (`other/bundle-parity.2026-11-04T03-27.md`) |
| AC-19 | push-down copies, manifest, contract tests | checked | `other/bundle-parity.2026-11-04T03-27.md` (7 equal SHA-256 pairs), `qa-gates/pushdown-parity.2026-11-04T03-30.md` (Docs.Manifest 7/7, Python 34 passed) |
| AC-20 | no Python or TypeScript; classification table complete | checked, with deviation | `qa-gates/scope-and-purity.2026-11-04T04-32.md` |
| AC-21 | no temporary files | checked | `qa-gates/scope-and-purity.2026-11-04T04-32.md` (0 purity matches); IN-MEMORY suites |
| AC-22 | existing suites unmodified and passing | checked | pester-final (ClaudeLibModuleConvention 6/6, enforcement-hooks-no-python-invocation 33/33, DocsNeutrality 65/65; none modified) |
| AC-23 | file size | checked | `qa-gates/file-size.2026-11-04T04-31.md` |
| AC-24 | coverage at least 85 per new module | checked | `qa-gates/coverage-final.2026-11-04T04-00.md` (100% each; recorded under `qa-gates/` per the plan's evidence-location override) |
| AC-25 | upstream-symbol record | checked at [P0-T3] | `other/upstream-symbols.2026-11-04T01-38.md` |
| AC-26 | test isolation | checked, with deviation | `regression-testing/pester-isolation.2026-11-04T04-31.md` |
| AC-27 | CI-dependent checks | unchecked (pending-CI) | `qa-gates/ci-pending.2026-11-04T04-33.md` |

## user-story.md

US-1 to US-11 follow AC-1 to AC-11; US-12 follows AC-12 and AC-13; US-13 follows AC-14; US-14 follows AC-15; US-15 follows AC-19; US-16 follows AC-20 and AC-21; US-17 follows AC-24. All 17 are checked on the evidence above.

## Seeded cases (passing, per seed)

| Function | 11 | 23 | 47 | 101 | 211 |
|---|---|---|---|---|---|
| `Resolve-DocsReferenceOutputDirectory` (halted preflight) | 1 | 1 | 1 | 1 | 1 |
| `Get-DocsReferenceCandidatePagePath` (halted preflight) | 1 | 1 | 1 | 1 | 1 |
| `Format-DocsReferenceSourceLine` (halted preflight) | 1 | 1 | 1 | 1 | 1 |
| `Split-DocsReferenceFrontMatter` (halted preflight) | 1 | 1 | 1 | 1 | 1 |
| `ConvertFrom-DocsReferencePageText` (halted preflight) | 1 | 1 | 1 | 1 | 1 |
| `Get-DocsReferenceReportLine` (halted preflight) | 1 | 1 | 1 | 1 | 1 |
| `ConvertFrom-DocsReferenceSnapshotText` | 1 | 1 | 1 | 1 | 1 |
| `Test-DocsReferencePathCovered` | 1 | 1 | 1 | 1 | 1 |
| `Get-DocsReferencePagePlan` | 1 | 1 | 1 | 1 | 1 |
| `ConvertTo-DocsReferenceSingleLine` | 1 | 1 | 1 | 1 | 1 |
| `ConvertTo-DocsReferenceCodeSpan` | 1 | 1 | 1 | 1 | 1 |
| `Format-DocsReferencePropertyLine` | 1 | 1 | 1 | 1 | 1 |
| `Get-DocsReferenceBlockLine` | 1 | 1 | 1 | 1 | 1 |
| `Get-DocsReferenceMarkerLine` | 1 | 1 | 1 | 1 | 1 |
| `ConvertFrom-DocsReferenceMarkerLine` | 2 | 2 | 2 | 2 | 2 |
| `ConvertFrom-DocsReferenceBody` | 1 | 1 | 1 | 1 | 1 |
| `Merge-DocsReferenceBlock` | 4 | 4 | 4 | 4 | 4 |
| `Resolve-DocsReferenceFrontMatterValue` | 1 | 1 | 1 | 1 | 1 |
| `ConvertTo-DocsReferenceFrontMatterText` | 1 | 1 | 1 | 1 | 1 |
| `Get-DocsReferenceGeneration` | 1 | 1 | 1 | 1 | 1 |
| `Format-DocsReferenceDiff` | 1 | 1 | 1 | 1 | 1 |
| `ConvertTo-DocsReferenceResult` | 1 | 1 | 1 | 1 | 1 |

## Recorded deviations for orchestrator review

- AC-20: the change edits `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` (1023-owned) to admit the 1024 write boundary; the plan's `## Artifact Classification` table did not list it, so the executor added one row for it during [P9-T10]. No `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs` path changed.
- AC-26: the three seeded shuffled runs pass (390/390 each). The fresh single-process run over `tests/scripts` on this Linux host has 409 failures, all in the pre-existing families #1066 and #1067. None is in a suite that reads a 1024 file, and the two suites that fail only on the branch pass 44/44 in isolation. This criterion was checked on the delegation's instruction to record these failures as pre-existing. The literal clause "fresh single-process run ... pass" is not met on this host. CI (`poshqc / PowerShell QC` shards on `windows-latest`) is the confirming run, and the orchestrator may uncheck AC-26 if it does not accept the host deviation.
