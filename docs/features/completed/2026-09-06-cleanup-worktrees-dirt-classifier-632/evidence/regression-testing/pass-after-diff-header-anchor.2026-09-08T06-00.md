# Pass-after — R5: the diff header skip is anchored

Timestamp: 2026-09-08T06-38

Task: [P4-T6] of `remediation-plan.2026-09-08T05-00.md`
Finding: R5

Command:

```
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
```

EXIT_CODE: 0

TAP plan line: `1..47`
Lines beginning `ok`: 47
Lines beginning `not ok`: 0

## The four required `ok` lines

The two descriptions quoted in [P4-T3]:

```
ok 22 dirt_build_artifact_plus_content: an added content line beginning with plus-plus-plus is counted and the entry is UNIQUE
ok 23 dirt_build_artifact_added_file: a dev-null header is still skipped and the entry is DISPOSABLE_BUILD_ARTIFACT
```

The two pre-existing clear-mode tests that consume the genuine-header fixtures:

```
ok 25 dirt_clear_all_disposable: the clear result record reports OK
ok 30 dirt_clear_clean_failed: a non-zero clean reports FAILED and retries no removal
```

## What changed

The header-skip pattern

```
"+++ "* | "--- "*) continue ;;
```

was replaced by one anchored to the four forms the diff emits:

```
"--- a/"* | "+++ b/"* | "--- /dev/null" | "+++ /dev/null") continue ;;
```

The docstring paragraph above it now records that the skip is anchored, that the default
`a/` and `b/` prefixes are assumed because the library issues `diff --no-color -U0` without
`--no-prefix`, and that a header form the pattern does not match is counted as a changed
content line, which fails closed to `UNIQUE`.

## Why the two clear-mode suites were included

`dirt_clear_all_disposable` and `dirt_clear_clean_failed` each carry a
`diff._repo-wt_dirt.src_Legacy_Legacy.csproj.out` whose first two lines are genuine
`--- a/src/Legacy/Legacy.csproj` and `+++ b/src/Legacy/Legacy.csproj` headers that the
anchored pattern must continue to skip. A mis-anchored replacement would leave those two
entries counted as changed content, resolve them `UNIQUE`, and turn the clear into a
`REFUSED-UNIQUE` — a failure that surfaces nowhere in the verdict suite and would otherwise
first appear three phases later.

Both pass, so the anchoring did not break the skip for the ordinary case.

## Fixture correction

The added line in the `dirt_build_artifact_plus_content` fixture was corrected during
execution: the plan's specified text contained the literal `HintPath`, which made the
confinement test accept the line once the anchoring stopped it being dropped. The
correction, the observation that established it, and the re-captured fail-before run are
recorded in
`evidence/regression-testing/fail-before-diff-header-anchor.2026-09-08T06-00.md`.

Output Summary: All 47 tests across the three suites pass with exit code 0 and 0 `not ok`
lines. The anchored pattern counts an added line whose content begins `+++ ` and still skips
both the `a/`/`b/` and the `/dev/null` header forms.
