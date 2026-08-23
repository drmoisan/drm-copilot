# QA Gate — Parity Corpus, Both Suites — [P5-T11]

Timestamp: 2026-08-23T02-52

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P5-T11]

## Suite 1 — Python parity

Command: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_parity.py`

EXIT_CODE: 0

Output Summary:

```text
........................................................................ [ 98%]
.                                                                        [100%]
73 passed in 0.10s
```

73 passed, 0 failed.

### Channels asserted

The suite's parametrized cases cover four channels over the corpus:

| Channel | Test |
| --- | --- |
| derived radius | `test_derivation_fixture_reproduces_the_expected_radius` |
| validation findings | `test_derivation_fixture_reproduces_the_expected_findings` |
| conflict verdict | `test_conflict_fixture_reproduces_the_expected_verdict` |
| conflict reasons | `test_conflict_fixture_reproduces_the_expected_reasons` |

### Non-vacuity tests

All three pass:

```text
tests/scripts/dev_tools/test_blast_radius_parity.py::test_corpus_meets_the_documented_minimum_size PASSED
tests/scripts/dev_tools/test_blast_radius_parity.py::test_discovered_fixture_count_equals_the_json_file_count PASSED
tests/scripts/dev_tools/test_blast_radius_parity.py::test_corpus_covers_both_fixture_kinds PASSED
```

The first asserts the corpus meets the floor `MINIMUM_FIXTURE_COUNT`, raised from 26 to 30 by
[P5-T5]. The second asserts the discovery glob reaches every JSON file in the directory, so a
pattern that silently skipped files would be caught rather than reproduced. The third asserts both
fixture kinds are present, so a corpus that had lost all conflict fixtures could not pass vacuously.

## Suite 2 — PowerShell parity

Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` set to
`["tests/scripts/claude-lib/blast-radius"]`, which discovers
`tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`.

EXIT_CODE: 0

The tool returns only an ok flag and a short summary, so every figure below is read from
`artifacts/pester/pester-junit.xml`.

```xml
<testsuites ... name="Pester" tests="401" errors="0" failures="0" disabled="0" time="43.176">
<testsuite name="...\BlastRadius.Parity.Tests.ps1" tests="76" errors="0" failures="0" ... time="30.234">
```

76 tests in the parity suite, 0 errors, 0 failures. The whole folder reports 401 tests with 0
failures.

### Non-vacuity tests

All three pass, read from the JUnit file:

```text
Passed | Blast-radius fixture corpus discovery.Non-vacuous iteration.discovers at least 30 fixture files
Passed | Blast-radius fixture corpus discovery.Non-vacuous iteration.discovers exactly the number of JSON files in the corpus directory
Passed | Blast-radius fixture corpus discovery.Non-vacuous iteration.covers both the derivation and the conflict fixture kind
```

The floor test reads 30, matching the Python constant, which is what [P5-T6] set.

## Byte-comparable results across the whole corpus

Both suites read the same committed fixture files and assert each fixture's `expected` block
verbatim. A divergence between the two implementations on any channel would make one suite fail
against a fixture the other passed, because neither suite may relax an expectation without the other
observing the change. Both suites pass on every fixture, so the two implementations agree on the
whole corpus across all four channels.

The three fixtures added by this item are asserted by both suites. Their per-case outcomes, read
from the JUnit file for the PowerShell side:

```text
Passed | ...Derived radius.reproduces the expected radius for derivation-placeholder-marker-variants
Passed | ...Derived radius.reproduces the expected radius for derivation-placeholder-token-rejected
Passed | ...Derived radius.reproduces the expected radius for validation-placeholder-self-consistent
Passed | ...Validation findings.reproduces the expected findings for derivation-placeholder-marker-variants
Passed | ...Validation findings.reproduces the expected findings for derivation-placeholder-token-rejected
Passed | ...Validation findings.reproduces the expected findings for validation-placeholder-self-consistent
```

## Corpus size

35 JSON fixtures on disk. Three were added by this item:

1. `tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json` ([P5-T1])
2. `tests/fixtures/blast_radius/derivation-placeholder-marker-variants.json` ([P5-T2])
3. `tests/fixtures/blast_radius/validation-placeholder-self-consistent.json` ([P5-T4])

The fourth fixture the plan anticipated, the conflict fixture of [P5-T3], was not added. Its
acceptance condition is unreachable through the conflict-fixture harness, which compares literal
recorded radii and never invokes the classifier the guard lives in. The analysis and its measurement
are recorded at `evidence/other/p5-t3-blocker-conflict-fixture-seam.md`. Both floors remain at 30 as
[P5-T5] and [P5-T6] specify, and with 35 files on disk both floor assertions hold and remain
non-vacuous.

## Output Summary

Both parity suites report exit code 0 with no failures: 73 passed on the Python side, 76 passed in
the PowerShell parity suite within a 401-test folder run. The four channels — radius, findings,
conflict verdict, and conflict reason — agree across the whole 35-fixture corpus, and all three
non-vacuity tests pass in each suite with both floors reading 30.
