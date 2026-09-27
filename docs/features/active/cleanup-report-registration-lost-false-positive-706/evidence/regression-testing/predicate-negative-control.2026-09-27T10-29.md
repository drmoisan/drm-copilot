# Predicate Negative Control (P3-T4)

Timestamp: 2026-09-27T10-29
ExpectedExitCode: 1
Mutation (temporary): in `scripts/bash/cleanup_worktrees_scan_helper.sh`, the R1 line `	[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]` was replaced with `	[[ $path == /* ]]` (the pre-fix rule) before this run and restored exactly after it (see `predicate-restored.2026-09-27T10-29.md`).
Command: npx --yes bats --print-output-on-failure --filter 'scan_helper_is_absolute_path returns 0 for slash-leading' tests/shell/test_cleanup_worktrees_scan_helper.bats
EXIT_CODE: 1
Output Summary: 1 test selected; 1 not ok naming test 3 (`scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths`). The output contains `classified relative: [C:/x]` (and the `c:/x` and `C:\x` candidates). Test 3 can fail when the drive-letter rule is removed.

TAP output (verbatim; no absolute path present):

```text
1..1
not ok 1 scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths
# (in test file tests/shell/test_cleanup_worktrees_scan_helper.bats, line 76)
#   `[ "$output" = "" ]' failed
# Last output:
# classified relative: [C:/x]
# classified relative: [c:/x]
# classified relative: [C:\x]
```
