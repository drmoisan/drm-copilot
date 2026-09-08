# Sibling check — Phase 3 (R2, the R/C-only rename split)

Timestamp: 2026-09-08T06-22

Task: [P3-T6] of `remediation-plan.2026-09-08T05-00.md`

Command:

```
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
```

EXIT_CODE: 0

TAP plan line: `1..26`
Lines beginning `ok`: 26
Lines beginning `not ok`: 0

## Sibling region checked

The edited line produces the `rel` value that every `DIRTFILE|` record's last field carries,
so the two pre-existing pins that read that value most closely were re-checked:

- The `dirt_pipe_path` field-ordering pin in
  `tests/shell/test_cleanup_worktrees_dirt_classify.bats`, which asserts
  `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|docs/a|b.md` — a path containing the record
  delimiter, recovered intact only because the file path is the last field. It reads the
  same `rel` the edited line produces.
- The `dirt_quoted_path` pin in the same suite, which asserts a C-quoted payload is reported
  verbatim as `UNIQUE` with no unquoting attempted. Its payload also passes through the
  edited line.

Both were exercised in the [P3-T5] run of that suite, recorded at
`evidence/regression-testing/pass-after-rename-split.2026-09-08T06-00.md`, where all 21 tests
passed. This run covers the three suites that were not re-run there.

The clear-mode suite is included because a `rel` value that changed would change which
probes are issued and therefore which verdicts are produced, and a verdict change turns a
clear into a `REFUSED-UNIQUE`. The byte-identity regression suite is included because it
pins report-mode and apply-mode stdout against captures taken before the classifier existed.
The fail-closed suite added in Phase 2 is included because its `MM`/`M ` fixture entries also
pass through the edited line, and neither carries the ` -> ` literal, so a gate that fired on
the wrong condition would show up there.

Output Summary: All 26 tests across the three suites pass with exit code 0 and 0 `not ok`
lines. Restricting the split to `R` and `C` entries changed no pre-existing verdict.
