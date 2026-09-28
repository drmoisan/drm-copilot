# Baseline — registry kind distribution

Timestamp: 2026-09-09T00-00

Task: [P0-T7]

This is what makes D4's raised floor satisfiable without re-authoring any existing row. Both
commands were run with an absolute path to the registry file rather than a repository-relative
path, because this session's Bash permission layer refuses a `cd`-chained file-reading
command; the `awk` program, the field separator and the target file are unchanged.

Command: `awk -F'\t' '!/^#/ && NF {print $2}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort | uniq -c`
EXIT_CODE: 0

Command: `awk -F'\t' '!/^#/ && NF && $2=="SEPARATED" {print $1}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort -u`
EXIT_CODE: 0

## Output Summary

First command, verbatim:

```
      2 ARGV
     37 SEPARATED
```

The tally records **37 `SEPARATED`** and **2 `ARGV`**, and no third kind. In particular there
is no `EXEMPT` row in the shipped registry, which is why removing that kind in Phase 3 does
not invalidate a single existing row.

Second command, verbatim:

```
aggregate-all-disposable-gate
aggregate-empty-entry-set
build-artifact-cached-diff-hard-fail
build-artifact-cached-diff-unconfined
build-artifact-vacuous-confinement
build-artifact-worktree-diff-hard-fail
build-artifact-worktree-diff-unconfined
clear-classify-exit-gate
clear-clean-hard-fail
clear-requires-all-disposable
clear-reset-hard-fail
diff-header-skip
find-object-hard-fail
hash-object-hard-fail
hintpath-diff-read-hard-fail
history-hit-nonempty
rename-payload-split-gate
rung1-y-column-gate
rung3-build-artifact-hard-fail
rung3-build-artifact-match
rung3-tracked-only-gate
rung4-tracked-content-equal
rung4-tracked-gate
rung4-tracked-hard-fail
rung4-tracked-path-in-main
rung4-untracked-gate
rung4-untracked-main-present
staged-probe-diffindex-hard-fail
staged-probe-error-map
staged-probe-issue-gate
staged-probe-no-match
staged-probe-revlist-hard-fail
staged-probe-skip-head
staged-probe-tree-match
status-read-hard-fail
unique-verdict-tally
```

36 ids, derived by `wc -l` over that output.

IdsWithNoSeparatedRow: `history-scan-bounded-range`

Exactly one id. Derived mechanically rather than read off by eye: the distinct-id set
(`awk -F'\t' '!/^#/ && NF {print $1}' ... | sort -u`, 37 ids, recorded in the [P0-T6]
artifact) less the 36 ids above, taken with `comm -23`, yields the single id
`history-scan-bounded-range`.

That id is the sole member of the `ARGV_ONLY_IDS` list D4 edit 4 introduces. The reason it
can carry no `SEPARATED` row is structural rather than an authoring gap: the stub keys
`log --find-object` on the object id alone
(`tests/fixtures/cleanup_worktrees/stub-bin/git:321-331`), so changing the bounded-range
endpoint changes the invocation without changing any record, and no scenario can make that
guard separate on the record channel. It separates on the argv channel, which is what its two
`ARGV` rows record.

Consequence for the raised floor: every id except `history-scan-bounded-range` already has a
`SEPARATED` row, and the three rows D3 adds in P2-T4 are all `SEPARATED`. The floor D4 raises
— every marker id pinned by kind, `SEPARATED` except for the ids named in `ARGV_ONLY_IDS` —
is therefore satisfied by the end-state registry with no existing row rewritten.
