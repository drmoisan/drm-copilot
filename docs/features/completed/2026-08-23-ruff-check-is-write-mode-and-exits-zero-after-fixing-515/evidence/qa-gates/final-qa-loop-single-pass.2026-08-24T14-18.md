# Final QA Gate — Loop Completed in a Single Pass (P4-T6)

Timestamp: 2026-08-24T14-18

Task: [P4-T6]
Issue: #515

Command: `git status --porcelain` (post-P4-T4 snapshot), compared against the Phase 4 entry snapshot recorded verbatim in the P4-T1 artifact

EXIT_CODE: 0

## Operand 1 — Phase 4 entry snapshot (from the P4-T1 artifact `final-python-format.2026-08-24T14-12.md`)

```text
 M docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
 M pyproject.toml
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/
?? tests/scripts/dev_tools/test_ruff_config_alignment.py
```

## Operand 2 — snapshot taken after P4-T4

```text
 M docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
 M pyproject.toml
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/
?? tests/scripts/dev_tools/test_ruff_config_alignment.py
```

## Byte-identity verification

**The two snapshots are byte-identical.** Verified mechanically:

```text
$ cmp p4-entry2.txt p4-exit.txt
CMP_EXIT=0

$ sha256sum p4-entry2.txt p4-exit.txt
36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e *p4-entry2.txt
36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e *p4-exit.txt
```

`cmp` exits 0 and the two SHA-256 digests are equal. Both snapshot files were written
outside the repository working tree, so the verification added no entry to either snapshot.

## Stage exit codes across the recorded pass

| Task | Stage | Command | EXIT_CODE | Changed a file? |
| --- | --- | --- | --- | --- |
| P4-T1 | 1, formatting | `poetry run black --check .` | **0** | no (443 files unchanged) |
| P4-T2 | 2, linting | `poetry run ruff check` | **0** | no (snapshot pair byte-identical) |
| P4-T3 | 3, type checking | `poetry run pyright` | **0** | no (read-only analyzer) |
| P4-T4 | 5, unit tests | `poetry run pytest --cov=... --cov-branch --cov-report=term-missing --cov-report=json:...` | **0** | no repository file (only gitignored `artifacts/` tool output) |

All four of P4-T1 through P4-T4 recorded `EXIT_CODE: 0`.

The intermediate digests corroborate the table stage by stage: the P4-T2 before/after pair,
the P4-T1 entry snapshot, and this exit snapshot all carry the identical digest
`36dbc1c0...0a0f3e`, so no stage in the recorded pass altered the working tree at any point
between the entry snapshot and this exit snapshot.

The only file written during the loop that is not in the snapshots is
`artifacts/python/coverage.json` (and its sibling `artifacts/python/lcov.info`), which is
tool output under the `artifacts/` tree gitignored at `.gitignore:6`. It is therefore not a
repository write, does not appear in either snapshot, and does not perturb this comparison.

## Loop-restart disclosure

The recorded pass above is pass 2 of the Phase 4 loop, and the single-pass verdict is
asserted over that pass. Pass 1 was aborted at P4-T4 by a test failure unrelated to this
plan's diff — filed issue #510, in which the push-down parity walk enumerates gitignored
`.claude/state/**` runtime state. The full cause, the evidence that it is not attributable
to this diff, and the remedy applied (removal of a gitignored, session-scoped state file,
which left `git status --porcelain` byte-identical) are recorded in the P4-T1 artifact
`final-python-format.2026-08-24T14-12.md` and the P4-T4 artifact
`final-python-test-coverage.2026-08-24T14-16.md`.

This disclosure is made explicitly so the single-pass verdict is not read as a claim that
no restart occurred. The restart was performed exactly as this phase's restart rule
requires — from P4-T1, re-recording every artifact in the phase — and no stage of the
recorded pass failed or changed a file. Pass 1's own P4-T1 through P4-T3 stages had also
all exited 0 with the identical snapshot digest; the sole pass-1 failure was the P4-T4
test, and it was cleared by removing a file that is not part of the repository.

Output Summary: **The Phase 4 loop completed in a single pass with no stage having changed
a file.** The Phase 4 entry snapshot and the post-P4-T4 snapshot are byte-identical,
confirmed by `cmp` exiting 0 and by an identical SHA-256 digest
`36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e` for both captures. All
four of P4-T1 through P4-T4 recorded `EXIT_CODE: 0`: black 0 with 443 files unchanged, the
bare lint 0 with 0 findings and a byte-identical bracketing snapshot pair, pyright 0 with 0
errors and 0 warnings across 443 analyzed files, and pytest 0 with 4116 passed, 0 failed,
and 0 errors. This satisfies spec acceptance criterion 10.
