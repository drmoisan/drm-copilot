# Fail-before exception dossier (P1-T21)

Timestamp: 2026-10-09T20-17
WhyFailingRunImpossible: The AC-6 and AC-7 cases pin output that both validators already emit; this plan changes no production code (research Sections 2.2 to 2.4). A pre-change failing run of those four cases therefore does not exist.

## Alternative Proof

- The P1-T19 artifact (`evidence/regression-testing/python-routing-cases.2026-10-09T20-17.md`) records the two new Python cases passing, 31 passed against a baseline of 29.
- The P1-T20 artifact (`evidence/regression-testing/ts-routing-cases.2026-10-09T20-17.md`) records the two new TypeScript cases passing, 24 passed against a baseline of 22.
- The AC-6 cases assert exact ordered list equality against three literals, which fails on any added, missing, or reordered error.
- The P1-T3 artifact (`evidence/regression-testing/contract-fail-before.2026-10-09T20-18.md`) is the fail-before run for the AC-1, AC-2, AC-3, and AC-5 contract assertions (4 failed, 7 passed before any Markdown edit).

SearchScope: docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/regression-testing/
SearchPatterns: fail-before-*.md, *fail*.md
SearchResult (run before this file was written; excludes it):
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/regression-testing/contract-fail-before.2026-10-09T20-18.md
