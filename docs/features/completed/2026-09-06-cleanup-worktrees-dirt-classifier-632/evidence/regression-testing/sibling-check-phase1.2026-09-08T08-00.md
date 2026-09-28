# Sibling check — the rung-4 narrowing disturbed nothing

Timestamp: 2026-09-08T08-00
Task: [P1-T10]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

Command: npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
EXIT_CODE: 0

TAP plan line: 1..50
OkCount: 50
NotOkCount: 0

These are the three suites that exercise the rung-4 tracked half or the report-mode
non-mutation property. All 50 tests pass after [P1-T6]'s narrowing and [P1-T9]'s count
update.

## Reachability of the new read

Every one of the eighteen tracked (non-`??`) status entries across the checked-in `dirt_*`
scenarios was traced through the ladder. **Six** reach rung 4's tracked half, and therefore
could reach the new `rev-parse --verify --quiet main:<path>` read. Each row's `diff-quiet`
fixture value below was re-read from the fixture file in this task rather than copied from
the plan.

| Scenario | Status entry | `diff-quiet` fixture value | `drc` | New read issued |
|---|---|---|---:|---|
| `dirt_rename_split` | `R  old.md -> new.md` | no fixture, stub default 0 | 0 | **yes** |
| `dirt_build_artifact_mixed` | ` M src/Legacy/Legacy.csproj` | 1 | 1 | no |
| `dirt_build_artifact_plus_content` | ` M src/Legacy/Legacy.csproj` | 1 | 1 | no |
| `dirt_staged_tree_no_match` | `M  src/a.cs` | 1 | 1 | no |
| `dirt_staged_tree_worktree_delta` | `MM src/a.cs` | 1 | 1 | no |
| `dirt_tracked_read_errors` | ` M docs/tracked.md` | 128 | 128 | no |

Six rows. Five of the six supply a non-zero `diff-quiet` fixture, so `((drc == 0))` at the
rung-4 tracked gate is false and the new read is never issued for them; their verdicts
cannot have changed. The measured fixture values are:

```
dirt_build_artifact_mixed        diff-quiet..src_Legacy_Legacy.csproj.rc = [1]
dirt_build_artifact_plus_content diff-quiet..src_Legacy_Legacy.csproj.rc = [1]
dirt_staged_tree_no_match        diff-quiet..src_a.cs.rc                 = [1]
dirt_staged_tree_worktree_delta  diff-quiet..src_a.cs.rc                 = [1]
dirt_tracked_read_errors         diff-quiet..docs_tracked.md.rc          = [128]
dirt_rename_split                (no diff-quiet fixture present)
```

`dirt_rename_split` is the single entry that reaches the new read. Its `R` entry's payload
is split so the classified path is `new.md`; the scenario supplies no
`rev-parse.verify.main_new.md` fixture, so the read replays the documented stub default of
empty stdout and exit 0, `erc` is 0, and the entry **still resolves `CONTENT_ON_MAIN`**.
That verdict is pinned by the test at
`tests/shell/test_cleanup_worktrees_dirt_classify.bats:330`, whose assertion at `:336` is
`DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||R |new.md`, and that test is among the 50 `ok`
lines of this run.

## `dirt_build_artifact_added_file` does not belong in the table

Stated separately, outside the table, because it carries a `diff-quiet` fixture and might
otherwise be assumed to reach rung 4. It does not.

Its status entry is `A  src/Legacy/Legacy.csproj`. Rung 1's gate admits an `A ` entry, but
the scenario supplies no `rev-list.HEAD.out`, so the staged-tree probe replays the stub
default, `staged` is empty, and that branch falls through without emitting. Rung 3 then
resolves it. The directory listing confirms there is **no**
`diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` worktree-diff payload, so the worktree
arm contributes 0 changed lines, while
`diff-cached._repo-wt_dirt.src_Legacy_Legacy.csproj.out` carries exactly one content line:

```
+      <HintPath>..\packages\StyleCop.Analyzers.1.1.118\analyzers\dotnet\cs\StyleCop.Analyzers.dll</HintPath>
```

`total` is therefore 0 + 1 = 1, the vacuous-confinement guard `((total == 0)) && return 1`
does not fire, `dirt_is_build_artifact` returns 0, and the entry resolves
`DISPOSABLE_BUILD_ARTIFACT` at rung 3 — pinned by the test at
`tests/shell/test_cleanup_worktrees_dirt_classify.bats:355`. It never issues
`diff --quiet main`, so its `diff-quiet..src_Legacy_Legacy.csproj.rc` fixture, which does
exist and contains `1`, is never read.

Output Summary: 50 tests across the three suites, 50 ok, 0 not ok, exit 0. Of the six
tracked entries that reach rung 4's tracked half, five never issue the new read because
their `diff-quiet` fixture is non-zero, and the sixth (`dirt_rename_split`) issues it and
still resolves `CONTENT_ON_MAIN` on the stub default. No existing verdict changed.
