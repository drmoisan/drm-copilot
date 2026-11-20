# Kickoff-Contract Module Size Verification — [P2-T6] / [P2-T8]

Timestamp: 2026-08-08T14-17

Rule: `.claude/rules/general-code-change.md` — File Size Limit. No production code,
test code, or reusable script file may exceed 500 lines.

## Split Decision — [P2-T6]

Verdict: **SPLIT FIRED.**

Measured line count of the single-module form of
`scripts/dev_tools/parallel_kickoff_contract.py` after [P2-T1] through [P2-T5]:
**594 lines**, which is at or over the 500-line production limit. The [P2-T6]
conditional therefore fired and the table-parsing helpers were extracted into
`scripts/dev_tools/_parallel_kickoff_tables.py`, following the repository's
existing `_`-prefixed helper-module convention (precedent:
`scripts/dev_tools/_parallel_state_common.py`,
`scripts/dev_tools/_parallel_state_structures.py`,
`scripts/dev_tools/_parallel_state_records.py`).

Rationale for the extraction boundary: the Markdown table primitives are the
largest self-contained block in the module and have no dependency on kickoff
sections, headings, or the invocation grammar. Extracting them yields a one-way
import (contract module imports helper module) with no import cycle.

### Extracted into `scripts/dev_tools/_parallel_kickoff_tables.py`

- `INTEGRITY_COMMIT_RE`, `HASH_HEADERS` (constants consumed only by the
  extracted helpers; re-exported from the contract module via `__all__` so the
  contract module's public surface is unchanged)
- `_parse_cells`, `_is_separator` (module-internal to the helper module)
- `table_rows`, `parse_integrity` (imported back by the contract module)
- `_parse_integrity_table` (module-internal to the helper module; introduced to
  keep `parse_integrity` free of deep nesting per `.claude/rules/python.md`,
  "Avoid long, deeply branching functions")

### Retained in `scripts/dev_tools/parallel_kickoff_contract.py`

- All pattern constants and `ITEM_HEADERS`
- Both frozen dataclasses `KickoffItem` and `ParsedParallelKickoff`
- `_split_sections`, `_parse_items`
- Public entry points `parse_parallel_kickoff`, `validate_parallel_kickoff_text`

Naming note: the two helpers consumed across the module boundary are declared
with public (unprefixed) names because Pyright strict mode reports
`reportPrivateUsage` for a `_`-prefixed symbol imported into another module.
This matches the existing convention in `scripts/dev_tools/_parallel_state_common.py`,
whose cross-module helpers (`is_non_empty_string`, `validate_items`,
`scan_prohibited_keys`) are likewise unprefixed inside a `_`-prefixed module.

## Measured Line Counts — Production Modules ([P2-T6])

| Module | Lines | Under 500 |
| --- | --- | --- |
| `scripts/dev_tools/parallel_kickoff_contract.py` | 380 | yes |
| `scripts/dev_tools/_parallel_kickoff_tables.py` | 261 | yes |

Every produced production module is under 500 lines.

## Measured Line Counts — Test Modules ([P2-T8], appended)

Verdict: **[P2-T8] SPLIT FIRED.**

After the positive scenarios ([P2-T7]) and the structural-heading negative
scenarios, `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` measured
449 lines. Adding the remaining item-table and integrity-table negative
scenarios (sixteen further test functions, three of them parametrized) would
have carried the single module past the 500-line test-file limit, so the
[P2-T8] conditional split was applied as written: the positive and
structural-heading scenarios stay in
`tests/scripts/dev_tools/test_parallel_kickoff_contract.py`, and the item-table
and integrity-table negative scenarios moved to
`tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py`, which
imports the document-builder helpers (`kickoff`, `kickoff_with_integrity`) and
the row constants from the first module at module level.

Cross-test module-level import precedent in the same directory:
`tests/scripts/dev_tools/test_new_active_feature_folder_part2.py` imports
`FakeCodeLauncher` from `tests.scripts.dev_tools.test_new_active_feature_folder`.

| Module | Lines | Under 500 |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` | 449 | yes |
| `tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py` | 312 | yes |

Every produced test module is under 500 lines.

## Final Measured Line Counts (all modules produced by Phase 2)

| Module | Kind | Lines | Under 500 |
| --- | --- | --- | --- |
| `scripts/dev_tools/parallel_kickoff_contract.py` | production | 380 | yes |
| `scripts/dev_tools/_parallel_kickoff_tables.py` | production | 261 | yes |
| `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` | test | 449 | yes |
| `tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py` | test | 312 | yes |

Line counts were re-measured at 2026-08-08T14-20 after [P2-T9] added one further
non-pipe-delimited-row test to close the last uncovered branch in
`scripts/dev_tools/_parallel_kickoff_tables.py`; only
`test_parallel_kickoff_contract_tables.py` changed, from 298 to 312 lines. Both
test modules remain under 500 lines.

## Command-Step Fields (N1 correction, remediation cycle 1, task [P6-T1])

Fields corrected at: 2026-08-08T15-25

This artifact was originally written without the `Command:`, `EXIT_CODE:`, and
`Output Summary:` fields that `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
requires of a command-step evidence artifact. Feature review raised that omission
as Non-blocking finding N1. The fields are supplied below against a fresh
measurement. The original `Timestamp: 2026-08-08T14-17` is retained because it
records when the original measurement was taken, and all split-rationale prose
above is preserved unchanged.

Command: `wc -l scripts/dev_tools/parallel_kickoff_contract.py scripts/dev_tools/_parallel_kickoff_tables.py tests/scripts/dev_tools/test_parallel_kickoff_contract.py tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py`

EXIT_CODE: 0

Output Summary: All four modules are strictly under the 500-line hard limit. The
largest is `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` at 449
lines. One count changed against the values recorded above:
`scripts/dev_tools/parallel_kickoff_contract.py` moved from 380 to 386 lines
because remediation task [P1-T3] added a six-line decision-logic comment above
`RESUME_RE`. The other three counts are unchanged.

### Freshly Measured Counts (2026-08-08T15-25)

| Module | Kind | Lines | Under 500 | Change vs. 2026-08-08T14-20 |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_kickoff_contract.py` | production | 386 | yes | +6 ([P1-T3] comment) |
| `scripts/dev_tools/_parallel_kickoff_tables.py` | production | 261 | yes | unchanged |
| `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` | test | 449 | yes | unchanged |
| `tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py` | test | 312 | yes | unchanged |

Counts are total physical lines as reported by `wc -l`, not non-blank lines,
matching the basis used in [P2-T5], [P3-T10], [P4-T10], and [P8-T10].

Raw output:

```
  386 scripts/dev_tools/parallel_kickoff_contract.py
  261 scripts/dev_tools/_parallel_kickoff_tables.py
  449 tests/scripts/dev_tools/test_parallel_kickoff_contract.py
  312 tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py
 1408 total
```
