# Acceptance-Criteria Traceability — Issue #452 v2

Timestamp: 2026-09-27T15-56

AC source: docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md, section "Acceptance Criteria" (22 items, numbered AC-1 through AC-22 in source order). Work mode: full-bug.

Evidence paths are relative to docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/evidence. Where an artifact name has more than one timestamp, the latest supersedes the earlier ones (plan Loop Re-entry and Recovery item 5). Every path below was confirmed to exist on disk when this file was written.

Spec state when written: 20 checked (AC-1 through AC-20), 2 unchecked (AC-21, AC-22).

| AC | Criterion (abridged) | Tasks | Evidence | Status |
| --- | --- | --- | --- | --- |
| AC-1 | Corpus file exists and conforms to the contract | P2-T1, P2-T2, P3-T2 | regression-testing/phase2-corpus-structure.2026-09-27T15-06.md; regression-testing/phase3-python-consumer-run.2026-09-27T15-16.md | checked |
| AC-2 | Pairing rules, both consumers | P3-T2, P4-T2 | regression-testing/phase3-python-consumer-run.2026-09-27T15-16.md; regression-testing/phase4-pester-consumer-run.2026-09-27T15-28.md | checked |
| AC-3 | Both directions per gap, direction consistency | P3-T2, P4-T2 | as for AC-2 | checked |
| AC-4 | Quality-tiers doctrine pin and declared-radius case | P3-T2, P4-T2 | as for AC-2 | checked |
| AC-5 | Plan-line intent rule | P3-T2, P4-T2 | as for AC-2 | checked |
| AC-6 | Phase 0 Python execution evidence | P0-T30, P0-T31 | baseline/phase0-python-runtime-verdicts.2026-09-27T14-56.md | checked |
| AC-7 | Phase 0 PowerShell execution evidence and three-way comparison | P0-T32, P0-T33 | baseline/phase0-powershell-runtime-verdicts.2026-09-27T14-58.md; baseline/phase0-three-way-comparison.2026-09-27T14-59.md | checked |
| AC-8 | Conditional production correction resolved | P1-T1, P8-T1 (drawing on P0-T33, P0-T34) | regression-testing/phase1-correction-resolution.2026-09-27T15-03.md; baseline/phase0-bundled-root-surfaces.2026-09-27T15-00.md; qa-gates/final-non-goals-scope-diff.2026-09-27T15-54.md | checked |
| AC-9 | Python consumer passes | P3-T2 | regression-testing/phase3-python-consumer-run.2026-09-27T15-16.md | checked |
| AC-10 | Python mutation demonstration | P3-T3 | regression-testing/phase3-python-mutation-demonstration.2026-09-27T15-18.md | checked |
| AC-11 | Pester consumer passes with the repository runsettings | P4-T2, P7-T3 | regression-testing/phase4-pester-consumer-run.2026-09-27T15-28.md; qa-gates/final-powershell-pester-coverage.2026-09-27T15-53.md | checked |
| AC-12 | Pester mutation demonstration | P4-T3 | regression-testing/phase4-pester-mutation-demonstration.2026-09-27T15-30.md | checked |
| AC-13 | Bundled-configuration parity in both consumers | P3-T2, P7-T3, P8-T6 | qa-gates/final-bundled-parity.2026-09-27T15-56.md | checked |
| AC-14 | Merge-order independence | P8-T4 | qa-gates/final-merge-order-independence.2026-09-27T15-55.md | checked |
| AC-15 | Tolerance branch resolved and recorded | P0-T29, P5-T1 | baseline/phase0-tolerance-detection.2026-09-27T14-54.md; regression-testing/phase5-tolerance-branch.2026-09-27T15-32.md | checked |
| AC-16 | Loading constraints | P8-T3 | qa-gates/final-loading-constraints.2026-09-27T15-55.md | checked |
| AC-17 | Non-goals untouched | P8-T1 | qa-gates/final-non-goals-scope-diff.2026-09-27T15-54.md | checked |
| AC-18 | 500-line limit | P8-T5 | qa-gates/final-line-counts.2026-09-27T15-55.md | checked |
| AC-19 | Python toolchain in a single pass | P6-T1 through P6-T8, P8-T2 | qa-gates/final-python-black.2026-09-27T15-07.md; qa-gates/final-python-black-check.2026-09-27T15-07.md; qa-gates/final-python-ruff.2026-09-27T15-07.md; qa-gates/final-python-pyright.2026-09-27T15-08.md; qa-gates/final-python-pytest-coverage.2026-09-27T15-40.md (supersedes 2026-09-27T15-09; issue #510 allowance invoked); qa-gates/final-python-pytest-targeted-coverage.2026-09-27T15-40.md (issue #510 allowance invoked); qa-gates/final-python-consumer-coverage.2026-09-27T15-41.md; qa-gates/final-python-no-new-suppression.2026-09-27T15-41.md; qa-gates/final-coverage-delta.2026-09-27T15-54.md | checked |
| AC-20 | PowerShell toolchain in a single pass | P7-T1 through P7-T3, P8-T2 | qa-gates/final-powershell-format.2026-09-27T15-43.md; qa-gates/final-powershell-analyze.2026-09-27T15-43.md; qa-gates/final-powershell-pester-coverage.2026-09-27T15-53.md; qa-gates/final-coverage-delta.2026-09-27T15-54.md | checked |
| AC-21 | Required CI checks green on the pull-request head | P9-T5, P9-T7 | qa-gates/final-ci-pr-head.<timestamp>.md (not yet written) | pending P9-T4 and P9-T5 |
| AC-22 | Pull-request body contains "Fixes #452" | P9-T4 | qa-gates/final-pr-body.<timestamp>.md (not yet written) | pending P9-T4 and P9-T5 |

Local-evidence limit: the AC-19 evidence relies on the issue #510 allowance for one local-only failure caused by gitignored hook state. AC-21 is where that test must pass without an allowance in CI.

Output Summary: 22 entries. AC-1 through AC-20 each name at least one task ID and at least one existing evidence path and are checked in the spec. AC-21 and AC-22 are pending P9-T4 and P9-T5.
