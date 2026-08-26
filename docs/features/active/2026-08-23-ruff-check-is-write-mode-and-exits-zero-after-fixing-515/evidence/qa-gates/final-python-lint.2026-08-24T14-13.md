# Final QA Gate — Python Lint (P4-T2)

Timestamp: 2026-08-24T14-13

Task: [P4-T2]
Issue: #515
Stage: Toolchain stage 2 of 7 (linting), final QA loop, **pass 2**.

Command: `poetry run ruff check`, bracketed by `git status --porcelain` immediately before and immediately after

EXIT_CODE: 0

Unlike P3-T3, this task's acceptance condition is a conjunction: the two snapshots must be
byte-identical **AND** the lint exit code must be 0. Both conditions are met.

Pass context: this is pass 2 of the Phase 4 loop. The loop restarted from P4-T1 after
pass 1 failed at P4-T4 on filed issue #510, a push-down parity test that enumerates
gitignored `.claude/state/**` runtime files. The restart cause and remedy are recorded in
full in the P4-T1 artifact `final-python-format.2026-08-24T14-12.md`. Pass 1's lint stage
had also exited 0 with a byte-identical snapshot pair and the identical digest recorded
below, so this stage's result is unchanged across both passes.

## Snapshot A — immediately BEFORE `poetry run ruff check`

```text
 M docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
 M pyproject.toml
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/
?? tests/scripts/dev_tools/test_ruff_config_alignment.py
```

## Lint run

```text
$ poetry run ruff check
All checks passed!
```

Exit code: **0**. Reported finding count: **0**.

The bare form was used — the same form every agent-facing call site and the CI workflow
step at `.github/workflows/_quality-checks.yml` use. Before the Phase 2 deletion this was
a write-mode invocation; the snapshot pair below is what demonstrates it is not one now.

## Snapshot B — immediately AFTER `poetry run ruff check`

```text
 M docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
 M pyproject.toml
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/
?? tests/scripts/dev_tools/test_ruff_config_alignment.py
```

## Byte-identity verification

**The two snapshots are byte-identical.** Verified mechanically:

```text
$ cmp p4t2b-before.txt p4t2b-after.txt
CMP_EXIT=0

$ sha256sum p4t2b-before.txt p4t2b-after.txt
36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e *p4t2b-before.txt
36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e *p4t2b-after.txt
```

`cmp` exits 0 and the two SHA-256 digests are equal. Both snapshot files were written
outside the repository working tree, so the verification added no entry to either snapshot.

Both digests also equal the pass-2 Phase 4 entry-snapshot digest recorded at P4-T1
(`36dbc1c0...0a0f3e`), which additionally confirms the formatting stage that ran between
the entry snapshot and this one changed no file.

Output Summary: **The lint stage exited 0 with 0 findings and performed no write.**
Snapshot A and Snapshot B are byte-identical, confirmed by `cmp` exiting 0 and by an
identical SHA-256 digest `36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e`
for both captures. Reported finding count is 0 (`All checks passed!`). The four
working-tree entries present in both snapshots are unchanged from the P4-T1 entry snapshot
and are all authorized products of this plan.

This is the second of the two artifacts satisfying spec acceptance criterion 8; P3-T3 is
the first. Taken with P3-T4's scratch-input differential, the pair establishes both that
the real lint stage writes nothing and that the absence of a write is caused by the
configuration change rather than by an absence of anything to fix.
