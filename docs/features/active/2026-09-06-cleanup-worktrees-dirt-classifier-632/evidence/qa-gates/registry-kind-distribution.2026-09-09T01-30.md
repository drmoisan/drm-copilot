# End-state guard-registry kind distribution

Timestamp: 2026-09-09T01-30
Task: [P3-T5]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

Command: `awk -F'\t' '!/^#/ && NF {print $2}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort | uniq -c`
Command: `awk -F'\t' '!/^#/ && NF && $2=="SEPARATED" {print $1}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort -u`
Command: `grep -oE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh | sort -u | wc -l`

EXIT_CODE: 0

## Output Summary

Kind tally, verbatim:

```
      2 ARGV
     40 SEPARATED
```

40 `SEPARATED`, 2 `ARGV`, no third kind. The `EXEMPT` kind P3-T1 deleted has zero rows;
`grep -cF 'EXEMPT'` over the registry reports `0`.

Distinct ids carrying at least one `SEPARATED` row, verbatim:

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
index-and-worktree-both-hold-content
rename-payload-split-gate
rung1-y-column-gate
rung3-build-artifact-hard-fail
rung3-build-artifact-match
rung3-tracked-only-gate
rung4-index-blob-unaccounted
rung4-tracked-content-equal
rung4-tracked-gate
rung4-tracked-hard-fail
rung4-tracked-path-in-main
rung4-untracked-gate
rung4-untracked-main-present
rung5-index-blob-unaccounted
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

That is 39 distinct ids.

IdsWithNoSeparatedRow: `history-scan-bounded-range`

Derived with
`comm -23 <(grep -oE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh | cut -d: -f2 | sort -u) <(awk -F'\t' '!/^#/ && NF && $2=="SEPARATED" {print $1}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort -u)`,
which emitted exactly that one id. It is the id P3-T3's `ARGV_ONLY_IDS` array exempts from
the `SEPARATED` floor, and it carries an `ARGV` row instead: the stub keys
`log --find-object` on the object id alone, so the bounded-range endpoint changes the
invocation without changing any record.

MarkerIdCount: 40

40 distinct marker ids, equal to the distinct-id count D3 derives (42 registry rows less
the two ids that back two rows each, `hash-object-hard-fail` and
`rung4-untracked-main-present`). 39 ids carry a `SEPARATED` row and the fortieth,
`history-scan-bounded-range`, carries an `ARGV` row, so the raised pin floor holds over
every marker id with no unpinned remainder.
