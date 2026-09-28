# [P8-T9] Both parity drivers against the extended corpus

Timestamp: 2026-08-08T16-18
Task: [P8-T9]

## Corpus size

On-disk count of `tests/fixtures/blast_radius/*.json`: **26**.

Baseline at [P0-T13]: 21 files, with both anti-vacuity floors at 12. Five fixtures were added by
[P8-T1] through [P8-T5], and both floors were raised to 26 by [P8-T7] and [P8-T8].

| Fixture | Task | Kind |
| --- | --- | --- |
| `derivation-root-surface-reached.json` | [P8-T1] | Gap 1 positive |
| `derivation-root-surface-not-configured.json` | [P8-T2] | Gap 1 negative |
| `conflict-directory-vs-glob.json` | [P8-T3] | Gap 2 concrete×glob |
| `conflict-directory-vs-file.json` | [P8-T4] | Gap 2 concrete×concrete |
| `conflict-sibling-prefix-disjoint.json` | [P8-T5] | Gap 2 non-regression |

## Python parity driver

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_parity.py -q`

EXIT_CODE: 0

Output Summary: `55 passed in 0.09s`. Up from 45 before the five additions (each derivation
fixture contributes two parametrized cases and each conflict fixture contributes two, so five
fixtures add ten cases). The three corpus-shape tests passed:

- `test_corpus_meets_the_documented_minimum_size` — 26 discovered against the floor of 26.
- `test_discovered_fixture_count_equals_the_json_file_count` — glob-discovered count equals the
  directory listing, so the driver reaches every JSON file.
- `test_corpus_covers_both_fixture_kinds` — both derivation and conflict cases are non-empty.

Discovered fixture count: **26**, equal to the on-disk `.json` count.

## PowerShell parity driver

Command: `mcp__drm-copilot__run_poshqc_test` with
`scan_folders: ["tests/scripts/claude-lib/blast-radius"]` and
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5c761b8f1a691079`

EXIT_CODE: 0

Output Summary: `ok: true`. Results parsed from `artifacts/pester/pester-junit.xml`:
`tests=316 failures=0 errors=0 disabled=0`.

Per-file breakdown:

| File | Cases |
| --- | --- |
| `BlastRadius.Parity.Tests.ps1` | 63 |
| `BlastRadiusGlob.Tests.ps1` | 45 |
| `BlastRadiusConfig.Tests.ps1` | 45 |
| `BlastRadiusExtraction.Path.Tests.ps1` | 45 |
| `BlastRadius.Tests.ps1` | 35 |
| `BlastRadius.Validation.Tests.ps1` | 31 |
| `BlastRadius.Conflict.Tests.ps1` | 27 |
| `BlastRadiusExtraction.Tests.ps1` | 21 |
| `BlastRadius.Manifest.Tests.ps1` | 4 |

`BlastRadius.Parity.Tests.ps1` ran with **zero failures**. Its corpus-discovery block confirms the
count directly; the emitted test name carries the interpolated floor:

```
Blast-radius fixture corpus discovery.Non-vacuous iteration.discovers at least 26 fixture files
Blast-radius fixture corpus discovery.Non-vacuous iteration.discovers exactly the number of JSON files in the corpus directory
Blast-radius fixture corpus discovery.Non-vacuous iteration.covers both the derivation and the conflict fixture kind
```

Discovered fixture count: **26**, equal to the on-disk `.json` count.

## Floor equality

| Driver | Constant | Value |
| --- | --- | --- |
| Python | `MINIMUM_FIXTURE_COUNT` in `tests/scripts/dev_tools/test_blast_radius_parity.py` | 26 |
| PowerShell | `$minimumFixtureCount` in `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | 26 |

The two floors are numerically equal and both equal the on-disk count.

Output Summary: both parity drivers exit 0. Each discovers 26 fixtures, equal to the on-disk
`tests/fixtures/blast_radius/*.json` count, and each asserts that equality itself. Python reports
55 passed; PowerShell reports 316 tests with zero failures over the blast-radius scan folder, and
`BlastRadius.Parity.Tests.ps1` ran 63 cases with zero failures. The five new fixtures are consumed
by both languages with no registration edit, and both anti-vacuity floors were raised from 12 to
26.
