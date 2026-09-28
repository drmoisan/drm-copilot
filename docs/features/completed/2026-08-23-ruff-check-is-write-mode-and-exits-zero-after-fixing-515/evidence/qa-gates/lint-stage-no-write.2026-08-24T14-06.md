# QA Gate — Lint Stage Performs No Write (P3-T3)

Timestamp: 2026-08-24T14-06

Task: [P3-T3]
Issue: #515
Tree state: post-change. The Phase 2 deletion has been applied.

Command: `git status --porcelain` (before), then `poetry run ruff check`, then `git status --porcelain` (after)

EXIT_CODE: 0

The recorded exit code is the exit code of `poetry run ruff check`. Per this task's
definition, **the acceptance condition is snapshot equality; the exit code is evidence,
not the condition.** The spec is explicit that a criterion stating only "the lint stage
exits 0" is insufficient, because that formulation is satisfiable by a run that rewrote
production files.

## Snapshot A — `git status --porcelain` immediately BEFORE `poetry run ruff check`

```text
 M docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
 M pyproject.toml
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/
?? tests/scripts/dev_tools/test_ruff_config_alignment.py
```

## Lint invocation

```text
$ poetry run ruff check
All checks passed!
(exit 0)
```

Note that the **bare** form was run here, without `--no-fix`. That is deliberate and is
what makes this gate meaningful: the bare form is the one every agent-facing call site
and the CI workflow step use, and it is the form that was write-mode before the Phase 2
deletion.

## Snapshot B — `git status --porcelain` immediately AFTER `poetry run ruff check`

```text
 M docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/plan.2026-08-23T23-21.md
 M pyproject.toml
?? docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/
?? tests/scripts/dev_tools/test_ruff_config_alignment.py
```

## Byte-identity verification

**The two snapshot texts are byte-identical.** This was verified mechanically rather than
by visual inspection. Both snapshots were captured to files and compared:

```text
$ cmp p3t3-before.txt p3t3-after.txt
CMP_EXIT=0

$ sha256sum p3t3-before.txt p3t3-after.txt
36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e *p3t3-before.txt
36dbc1c059b0ccbaf574b561776aa42f1d299e4b588fa8025fc89c5e4e0a0f3e *p3t3-after.txt
```

`cmp` exits 0 (no differing byte) and the two SHA-256 digests are equal. The comparison
files were written outside the repository working tree, so the verification itself added
no entry to either snapshot.

Output Summary: **The lint stage performed no write. Snapshot A and Snapshot B are
byte-identical** — confirmed by `cmp` exiting 0 and by an identical SHA-256 digest
(`36dbc1c0...0a0f3e`) for both captures. The bare `poetry run ruff check` invocation
reported `All checks passed!` and exited 0. Four working-tree entries are present in both
snapshots, and all four are expected products of this plan's own authorized work: the
modified plan file and the untracked evidence subtree (this plan's own documents), the
modified `pyproject.toml` (the P2-T1 single-line deletion), and the untracked
`tests/scripts/dev_tools/test_ruff_config_alignment.py` (the P1-T1 module). No entry
appeared, disappeared, or changed across the lint invocation.

## Non-discrimination note for later readers

On a clean tree with no fixable violation present, this snapshot pair is
**non-discriminating in isolation**: it would compare equal whether or not fix mode had
been removed, because a linter in fix mode with nothing to fix writes nothing. The P0-T4
baseline confirms exactly that precondition — the tree carried 0 findings of any kind
before the change, so there was never anything for the fix mode to act on at repository
scope.

This gate is nevertheless mandatory because the spec's acceptance criterion 8 requires
precisely this pair of snapshots around the bare lint invocation. The discriminating
power of Phase 3 sits in **P3-T4**, which runs the same bare command against scratch
inputs that do carry violations — one fixable, one not — and shows the fixable input is
left byte-identical. Read the two artifacts together: this one shows the repository is
untouched by the real lint stage, and P3-T4 shows that the untouched result is caused by
the configuration change rather than by an absence of anything to fix.
