# [P13-T5] Final Python contract suites

Timestamp: 2026-09-07T17-14

Command:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q
poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -q
```

EXIT_CODE: 0

All three commands exited 0. Each exit code was captured directly from `$?` with no pipe in the
command line, so no pipeline stage could mask a non-zero status.

No coverage argument is used on any of the three commands. This change adds and modifies no Python
production file, so there is no Python changed-code denominator and no Python coverage gate has a
subject here. The obligation is that these three modules pass.

## Results, one row per command

| # | Module | Passed | Failed | Deselected | Exit code | Wall time |
|---|---|---|---|---|---|---|
| 1 | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | 10 | 0 | 1 | 0 | 0.11 s |
| 2 | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | 1 | 0 | 0 | 0 | 0.05 s |
| 3 | `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` | 10 | 0 | 0 | 0 | 0.05 s |

Verbatim summary lines:

```
10 passed, 1 deselected in 0.11s
1 passed in 0.05s
10 passed in 0.05s
```

**Zero failed tests across all three commands.**

## Comparison against the [P0-T11] baseline

Baseline artifact: `evidence/baseline/baseline-python-contracts.2026-09-07T10-57.md`.

| Module | Baseline passed | This run passed | Condition |
|---|---|---|---|
| `test_push_down_claude_resource_contracts.py` | 11 (no deselection at baseline) | 10 + 1 deselected = 11 collected | not gated by the acceptance; see the deselection row below |
| `test_poshqc_bundled_parity.py` | 1 | 1 | at or above baseline: **satisfied** |
| `test_parallel_abandon_token_seam.py` | 10 | 10 | at or above baseline: **satisfied** |

The acceptance condition names only the second and third modules for the baseline comparison,
because the first module's passed count is reduced by exactly one by the deselection and a raw
comparison would misread that as a regression. The first module collected 11 cases in both runs and
reports zero failures in both.

## The deselection

**Deselected node ID:**
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

**Reason: open issue #510.** That test compares the bundled Claude payload against the full set of
repository runtime contracts and fails locally on gitignored orchestration state present in an
active worktree, not on any property of this change. It is green on a clean checkout. The issue is
open and is not closed by this change. The same deselection, by the same node ID and with the same
citation, was used by [P4-T15] and [P12-T5] earlier in this plan; this task repeats it verbatim
rather than varying it.

**Independent discharge of the deselected property.** The deselected case asserts that the bundled
Claude payload matches the repository's runtime contracts. The byte-identity component of that
property — that every canonical file and its bundle mirror carry identical content — is discharged
independently by **[P12-T4]**, which recomputed SHA-256 over all 38 copy-set files from current
on-disk content and recorded 19 pairs with equal hashes and zero unequal, in
`evidence/other/pair-hash-parity.2026-09-07T15-52.md`. [P13-T1] confirmed that no copy-set file was
rewritten since, so those hashes describe the final tree. The property the deselection removes from
this run is therefore covered by direct measurement rather than left unverified.

## Output Summary

Three Python contract commands, all exit code 0, **zero failed tests in total**. Module 1:
10 passed, 1 deselected. Module 2: 1 passed, at or above its baseline of 1. Module 3: 10 passed, at
or above its baseline of 10. The deselection is recorded with its node ID and its issue #510
citation, and the deselected case's byte-identity property is discharged independently by [P12-T4].
No coverage argument was used, because this change adds and modifies no Python production file.
