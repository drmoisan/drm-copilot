# Reduced-Audit Handoff, Remediation Cycle 1 (P2-T15)

Timestamp: 2026-09-29T20-47
Command: ls docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/remediation-baseline docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/qa-gates docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/other docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/baseline
EXIT_CODE: 0
Output Summary:
- Plan of record: remediation-plan.2026-09-29T20-15.md (cycle 1); AC source: issue.md `## Acceptance Criteria` (AC-1 through AC-5 in document order).
- F-1 closure evidence (P2-T7): qa-gates/r1-timing-comparison.2026-09-29T20-33.md records RATIO=5.32 (213.12 s / 40.09 s) against the 4.00 threshold, PASS.
- Every artifact path below appears in the listing command output.

## Evidence index (paths relative to FEATURE/evidence/)

| AC | Criterion (abridged) | Evidence | Status |
| --- | --- | --- | --- |
| AC-1 | blast-radius suites pass; no fixture or assertion edits | qa-gates/r1-blast-radius-pester-coverage.2026-09-29T20-29.md; qa-gates/r1-cost-and-pairs-equivalence.2026-09-29T20-31.md; qa-gates/r1-full-suite-pester.2026-09-29T20-41.md; qa-gates/r1-scope-and-fixture-immutability.2026-09-29T20-44.md | PASS |
| AC-2 | before/after local timing, coverage disabled, material reduction | baseline/historical-runs-timing.2026-09-29T19-09.md; qa-gates/r1-historical-runs-timing.2026-09-29T20-33.md; qa-gates/r1-timing-comparison.2026-09-29T20-33.md | PASS |
| AC-3 | CI PowerShell QC job lower than 838 s | none yet; the orchestrator writes the CI-duration artifact under qa-gates after the PR run | Orchestrator-verified post-PR per the original plan's "Post-PR verification" section, unchanged: `poshqc / PowerShell QC` of at most 700 s |
| AC-4 | exported signatures and return values unchanged | remediation-baseline/r1-export-subset.2026-09-29T20-13.md; qa-gates/r1-export-subset.2026-09-29T20-43.md; remediation-baseline/r1-cost-and-pairs-pin.2026-09-29T20-15.md; qa-gates/r1-cost-and-pairs-equivalence.2026-09-29T20-31.md | PASS |
| AC-5 | line coverage >= 85% per touched file; no file over 500 lines | qa-gates/r1-coverage-delta.2026-09-29T20-42.md; qa-gates/r1-full-suite-pester.2026-09-29T20-41.md; qa-gates/r1-line-counts.2026-09-29T20-43.md | PASS |

Supporting artifacts: remediation-baseline/phase0-instructions-read.md; remediation-baseline/r1-mode-check.2026-09-29T20-11.md; remediation-baseline/r1-tree-state.2026-09-29T20-11.md; remediation-baseline/r1-scratch-scripts.2026-09-29T20-13.md; remediation-baseline/r1-line-counts.2026-09-29T20-13.md; remediation-baseline/r1-mirror-hashes.2026-09-29T20-13.md; remediation-baseline/r1-pssa.2026-09-29T20-15.md; remediation-baseline/r1-blast-radius-pester-coverage.2026-09-29T20-17.md; other/r1-p1-t1.2026-09-29T20-27.md through other/r1-p1-t9.2026-09-29T20-27.md; qa-gates/r1-format.2026-09-29T20-27.md; qa-gates/r1-lint.2026-09-29T20-28.md; qa-gates/r1-convention-and-uniqueness.2026-09-29T20-30.md; qa-gates/r1-mirror-hashes.2026-09-29T20-43.md; qa-gates/r1-bundle-parity-pytest.2026-09-29T20-46.md (KL-510: STATE-ONLY).
