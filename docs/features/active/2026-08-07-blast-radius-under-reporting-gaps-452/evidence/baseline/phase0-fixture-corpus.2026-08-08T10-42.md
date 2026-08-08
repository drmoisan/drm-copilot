# Phase 0 — Parity Fixture Corpus Baseline

Timestamp: 2026-08-08T10-42
Task: [P0-T13]

Command: `ls tests/fixtures/blast_radius/*.json | wc -l` then
`grep -n "MINIMUM_FIXTURE_COUNT" tests/scripts/dev_tools/test_blast_radius_parity.py` then
`grep -n "minimumFixtureCount" tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`

EXIT_CODE: 0 (all three)

## On-disk corpus: 21 `.json` fixtures

```
conflict-contract.json
conflict-empty-vs-empty.json
conflict-empty-vs-nonempty.json
conflict-glob-concrete.json
conflict-glob-undecidable.json
conflict-module-overlap.json
conflict-multi-reason.json
conflict-none-disjoint.json
conflict-path-overlap.json
conflict-shared-surface.json
derivation-basic.json
derivation-crlf.json
derivation-cr-only.json
derivation-declared-source.json
derivation-empty-plan.json
validation-multi-rule.json
validation-v1-uncovered-path.json
validation-v2-enumerated-surface-passes.json
validation-v2-unenumerated-surface.json
validation-v3-at-threshold.json
validation-v3-over-breadth.json
```

## Anti-vacuity floors

| Driver | Symbol | Location | Current value |
| --- | --- | --- | ---: |
| Python | `MINIMUM_FIXTURE_COUNT` | `tests/scripts/dev_tools/test_blast_radius_parity.py:56` | 12 |
| PowerShell | `$minimumFixtureCount` | `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:57` | 12 |

Output Summary: The on-disk corpus contains exactly 21 `.json` fixtures. Both anti-vacuity floors
are currently 12 and are numerically equal. Phase 8 adds five fixtures (one Gap 1 positive, one
Gap 1 negative, one Gap 2 concrete-by-glob, one Gap 2 concrete-by-concrete, one Gap 2
non-regression), giving a post-change on-disk count of 26, which is the value both floors must be
raised to at [P8-T7] and [P8-T8]. The corpus is ADD-ONLY: none of the 21 filenames above may be
modified or deleted.
