# Final QA Gate — Python Formatting (P4-T1)

Timestamp: 2026-08-24T14-12

Task: [P4-T1]
Issue: #515
Stage: Toolchain stage 1 of 7 (formatting), final QA loop, **pass 2**.

Commands, in the order run:

1. `git status --porcelain` (Phase 4 entry snapshot)
2. `poetry run black --check .`

EXIT_CODE (2, black run): 0

## Loop-restart context — why this is pass 2

The Phase 4 loop was restarted from P4-T1 in accordance with this phase's restart rule.
Pass 1 completed P4-T1 through P4-T3 cleanly (black exit 0 with 443 files unchanged; the
bare lint exit 0 with a byte-identical snapshot pair; pyright 0 errors and 0 warnings
across 443 files) and then failed at P4-T4 on a single test unrelated to this plan's diff:

```text
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
================= 1 failed, 4115 passed, 5 skipped in 23.12s ==================
```

```text
E  AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
```

That failure is **filed issue #510**, recorded at
`docs/features/potential/promoted/2026-08-19-claude-resource-parity-enumerates-gitignored-state.md`.
The push-down parity walk enumerates the repository `.claude/**` tree with
`Path.rglob("*")` without reading `.gitignore`, so a gitignored, session-scoped
batch-budget state file under `.claude/state/` is enumerated and reported as missing from
the distribution bundle.

The failure is not attributable to this plan's diff. The test's only inputs are files
under `.claude/**` and under the bundled resources tree; this plan's diff writes
`pyproject.toml` and `tests/scripts/dev_tools/test_ruff_config_alignment.py`, neither of
which is under `.claude/`. The triggering file was created by session tooling at 13:53,
after the P0-T6 baseline run at 13:52 recorded 4112 passed and 0 failed.

The remedy applied is the one the filed issue documents at its Steps to Reproduce step 4:
the gitignored state file was removed. This is not a repository write — the file is
gitignored at `.gitignore:68` (`.claude/state/`), and `git status --porcelain` returned
the identical four-entry text before and after the removal, confirming it does not appear
in the diff and does not alter the working-tree status. Fixing issue #510 itself would
require writing `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
which is outside this plan's two-file scope lock and was therefore not attempted.

Pass-1 artifacts for P4-T1 through P4-T3 were removed and replaced by this pass-2 set, so
each task carries exactly one artifact. No pass-1 result is lost: all pass-1 outcomes are
recorded verbatim above and in the corresponding pass-2 artifacts.

## Phase 4 entry snapshot (verbatim) — P4-T6 reads this as its first operand

```text
 M docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
 M pyproject.toml
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/
?? tests/scripts/dev_tools/test_ruff_config_alignment.py
```

SHA-256 of the captured snapshot file: `36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e`

The digest is recorded so P4-T6's comparison can be performed mechanically rather than by
visual inspection. The snapshot was captured to a file outside the repository working
tree, so the capture itself added no entry to the snapshot.

The four entries are all expected products of this plan's authorized work: the modified
plan file and the untracked evidence subtree (this plan's own documents), the modified
`pyproject.toml` (the P2-T1 single-line deletion), and the untracked new test module
(P1-T1). This text and digest are identical to the pass-1 entry snapshot, which confirms
the state-file removal changed nothing observable in the working tree.

## Formatting run

```text
$ poetry run black --check .
All done! ✨ 🍰 ✨
443 files would be left unchanged.
```

Exit code: **0**.

The read-only `--check` form was used. The bare write-mode `poetry run black .` form was
not run at any point in this plan.

Output Summary: **Zero files would be reformatted; Black reports 443 files would be left
unchanged and exits 0.** The count is 443 against the 442 recorded in the P0-T3 baseline;
the increase of exactly one is `tests/scripts/dev_tools/test_ruff_config_alignment.py`, the
single new Python file this plan adds, which was independently confirmed Black-clean at
P1-T3 before Phase 4 began. `pyproject.toml` is TOML and is not processed by Black, so the
Phase 2 deletion cannot affect this count.

The Phase 4 entry snapshot is reproduced verbatim above and is the first operand of the
P4-T6 single-pass comparison.
