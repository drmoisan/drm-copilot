# Final QA — Actionlint — P7-T5

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command: `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1`

EXIT_CODE: 0

## Console output

```
Running actionlint...
```

No diagnostic lines were emitted. The linter prints one line per finding, so an empty finding region
followed by exit code 0 is the clean result.

## In-scope workflow files

Both workflow files this change touches are inside the linter's scan set, which covers
`.github/workflows/`:

| Workflow file | Change made by this plan |
|---|---|
| `.github/workflows/publish-mcp-npm.yml` | Modified — `pull_request` trigger (P4-T1), ref-based publish guard replacing the event-name guard (P4-T2), tag-versus-manifest equality step (P4-T3), post-publish registry poll (P4-T4), exit-code hygiene on added `pwsh` steps (P4-T5) |
| `.github/workflows/verify-published-releases.yml` | Added — Layer C scheduled reconciliation sweep (P5-T4) |

## Comparison against the P0-T6 baseline

The P0-T6 baseline recorded `EXIT_CODE: 0` before any workflow file was touched. This run records
`EXIT_CODE: 0` after both files reached their final state. The baseline was captured precisely so
that a non-zero result here would be attributable to this change; the result is zero, so no
attribution question arises.

This is the third actionlint run of the plan and the second after the workflow edits landed:

| Task | Point in the plan | Exit code |
|---|---|---|
| P0-T6 | Baseline, before any workflow edit | 0 |
| P4-T6 | After the `publish-mcp-npm.yml` edits | 0 |
| P5-T6 | After `verify-published-releases.yml` was added | 0 |
| P7-T5 | Final gate, both files in final state | 0 |

Output Summary: Actionlint completed with exit code 0 against the repository's workflow set,
including `.github/workflows/publish-mcp-npm.yml` and `.github/workflows/verify-published-releases.yml`,
the two files in scope for this change. Zero findings were reported. This satisfies AC25, which
requires `scripts/dev-tools/run-actionlint.ps1` to complete with exit code 0 against the changed and
added workflow files.
