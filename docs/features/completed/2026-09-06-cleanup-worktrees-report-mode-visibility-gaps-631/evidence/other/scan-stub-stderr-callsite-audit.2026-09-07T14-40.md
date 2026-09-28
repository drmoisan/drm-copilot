# Scan-Stub stderr Argv-Log Call-Site Audit (P1-T2)

Timestamp: 2026-09-07T16-24

Purpose: bound the blast radius of P1-T1, which adds one `printf 'stub-scan: %s\n' "$*" >&2`
invocation-log line to `tests/fixtures/cleanup_worktrees/stub-bin/scan`. That fixture is shared by
every scenario, so this audit enumerates every test call site that wires the stub through the
`CLEANUP_WT_SCAN_BIN` seam and states, for each, whether the new stderr line can reach that site's
`$output`.

SearchScope: `tests/` (whole tree, recursive), plus `scripts/bash/cleanup_worktrees_actions_lib.sh`,
`scripts/bash/cleanup_worktrees_detached_lib.sh`, `scripts/bash/cleanup_worktrees_report_records_lib.sh`,
`scripts/bash/cleanup_worktrees_lib.sh`, and `scripts/bash/cleanup-worktrees.sh` for the reachability
checks.

SearchPatterns:
- `CLEANUP_WT_SCAN_BIN` (recursive, `tests/`)
- `scan_` and `cleanup_wt_scan` (per-file, the two libraries named above)
- `run_report` and `run_apply` (recursive, `tests/shell/`)
- `[ "$output" = ` (recursive, `tests/shell/`)

SearchResult: thirteen matches for `CLEANUP_WT_SCAN_BIN` under `tests/` — ten env-setting sites
across seven `tests/shell/*.bats` files, plus three non-setting prose mentions. Both `scan_` /
`cleanup_wt_scan` searches returned zero matches in
`scripts/bash/cleanup_worktrees_actions_lib.sh` and `scripts/bash/cleanup_worktrees_detached_lib.sh`.

## Non-setting prose mentions (3 of 13)

These three matches mention the variable without setting it, and are listed so the thirteen-match
total accounts for every match the search returns:

- `tests/shell/test_cleanup_worktrees_scan_helper.bats:3` — a file-header comment.
- `tests/shell/test_cleanup_worktrees_scan_seam.bats:16` — a `@test` title
  (`"cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override"`).
- `tests/fixtures/cleanup_worktrees/stub-bin/scan:3` — a file-header comment.

## Env-setting call sites (10 of 13)

### (1) `report()` — `tests/shell/test_cleanup_worktrees_classification.bats:40-49` (env at line 46)

- (a) stderr: **suppressed**. The helper's `bash -c` string ends `run_report 2>/dev/null`.
- (b) `stub-scan:` reaching `$output`: **no**. The redirection discards the whole subshell's stderr,
  including the scan stub's.
- Seam reached: yes, through `run_report`.

### (2) `apply()` — `tests/shell/test_cleanup_worktrees_deletion.bats:25-33` (env at line 30)

- (a) stderr: **retained**. The helper carries no redirection.
- (b) `stub-scan:` reaching `$output`: **no**. The helper invokes `run_apply` only. A search for
  `scan_` / `cleanup_wt_scan` in `scripts/bash/cleanup_worktrees_actions_lib.sh` and
  `scripts/bash/cleanup_worktrees_detached_lib.sh` returns no match in either file, so apply mode
  never reaches the seam and the stub is never executed.

### (3) `tests/shell/test_cleanup_worktrees_cli.bats:34` — inline in `@test "default report mode emits classification lines and performs no mutation"` (lines 30-45)

- (a) stderr: **retained**. The test runs `bash "${WRAPPER}"` with no redirection.
- (b) `stub-scan:` reaching `$output`: **YES**. The wrapper's `main` dispatches `run_report` for the
  empty command (`scripts/bash/cleanup-worktrees.sh:103-105`), which reaches the seam.
- Assertion-safety: the test's assertions are two substring-positive checks on
  `BRANCH|feature-wt|MERGED_CLEAN` (line 38) and `WORKTREE|/repo-wt/feat|feature-wt|` (line 39), and
  four substring-negative checks on `worktree remove` (41), `branch -D` (42), `cherry-pick` (43), and
  `worktree add` (44). The scan stub is invoked as `scan-dirs <root> [...]`
  (`scripts/bash/cleanup_worktrees_report_records_lib.sh:171` and `:173`), so the added line contains
  none of those six tokens and no assertion changes value. The status assertion at line 37 is
  unaffected because a stderr write does not change the exit code.

### (4) `tests/shell/test_cleanup_worktrees_cli.bats:48` — inline in `@test "apply mode emits ACTION lines and destructive argv only for eligible states"` (lines 47-58)

- (a) stderr: **retained**.
- (b) `stub-scan:` reaching `$output`: **no**. `--apply` dispatches `run_apply` only
  (`scripts/bash/cleanup-worktrees.sh:106-108`), which reaches no scan function per the same
  two-file search recorded under site (2).

### (5) `runin()` — `tests/shell/test_cleanup_worktrees_hard_failures.bats:26-37` (env at line 34)

- (a) stderr: **suppressed**. The helper's `bash -c` string ends `$2 2>/dev/null` (line 36).
- (b) `stub-scan:` reaching `$output`: **no**.
- Used with `run_report` (line 96) and `run_apply` (lines 105 and 113).

### (6) `report()` — `tests/shell/test_cleanup_worktrees_detached.bats:31-41` (env at line 38)

- (a) stderr: **retained**, deliberately. That file's header states the reason at lines 11-15: the
  merge is what makes its negative argv assertions meaningful.
- (b) `stub-scan:` reaching `$output`: **YES**. The helper reaches the seam through `run_report`.
- Assertion-safety: the file contains no `[ "$output" = ... ]` equality assertion (verified by a
  search of the whole `tests/shell` tree for `[ "$output" = `, which returns no match in this file),
  and its one count assertion is anchored — `grep -c '^WORKTREE|/repo-wt/det'` at line 54 — so a line
  beginning `stub-scan:` matches nothing and no assertion changes value.

### (7) `runin()` — `tests/shell/test_cleanup_worktrees_detached.bats:43-47` (env at line 44)

- (a) stderr: **retained**.
- (b) `stub-scan:` reaching `$output`: **no**.
- This helper has thirty-two call sites passing four distinct invocations:
  - `is_detached_candidate` — lines 69, 71, 73, 75, 77, 79, 81, 83 (8 sites)
  - `run_apply` — lines 95, 103, 113, 121, 132, 144, 149, 193, 211, 227, 255, 270, 286, 314 (14 sites)
  - `classify_detached_head` — lines 159, 167, 238, 249, 264, 280, 298, 308 (8 sites)
  - `reverify_detached_delete_eligible` — lines 174, 324 (2 sites)
- None of the four reaches a scan function. `run_apply` is defined at
  `scripts/bash/cleanup_worktrees_actions_lib.sh:336`; `is_detached_candidate`,
  `classify_detached_head`, and `reverify_detached_delete_eligible` are defined at
  `scripts/bash/cleanup_worktrees_detached_lib.sh:41`, `:64`, and `:196` respectively. The
  `scan_` / `cleanup_wt_scan` search returns zero matches in either file.

### (8) `rr()` — `tests/shell/test_cleanup_worktrees_report_records.bats:22-28` (env at line 25)

- (a) stderr: **suppressed**. The helper's `bash -c` string ends `$2 2>/dev/null` (line 27).
- (b) `stub-scan:` reaching `$output`: **no**. This suppression is what protects the file's six
  `[ "$output" = ... ]` equality assertions at lines 36, 43, 51, 59, 67, and 74.

### (9) `tests/shell/test_cleanup_worktrees_scan_seam.bats:17` — inline in `@test "cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override"` (lines 16-21)

- (a) stderr: **retained**.
- (b) `stub-scan:` reaching `$output`: **no**. The test invokes only the resolver
  `cleanup_wt_scan_bin` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:42-59`), which prints
  a path and never executes the binary, so the equality assertion at line 20 is unaffected.

### (10) `tests/shell/test_cleanup_worktrees_scan_seam.bats:24` — inline in `@test "cleanup_wt_scan_bin falls back to the bundled scan helper when unset"` (lines 23-28)

- (a) stderr: **retained**.
- (b) `stub-scan:` reaching `$output`: **no**. Same reason as site (9): the resolver body never
  executes the binary.

## Derived findings

1. **No test falls back to the bundled real scan helper.** A search of `tests/shell/` for
   `run_report` and `run_apply` returns matches only in
   `test_cleanup_worktrees_classification.bats`, `test_cleanup_worktrees_cli.bats`,
   `test_cleanup_worktrees_deletion.bats`, `test_cleanup_worktrees_detached.bats`, and
   `test_cleanup_worktrees_hard_failures.bats` — every one of which sets `CLEANUP_WT_SCAN_BIN` in
   the helper or inline env that performs the call. No bats helper reaches `run_report` or
   `run_apply` without setting the seam, so no test executes
   `scripts/bash/cleanup_worktrees_scan_helper.sh` against the real filesystem.
2. **`classify_all()` retains stderr but is not a seam setter.** `classify_all()`
   (`tests/shell/test_cleanup_worktrees_classification.bats:28-38`) deliberately carries no
   `2>/dev/null`, but its `run env` line (36) sets only `CLEANUP_WT_GIT_BIN` and
   `CLEANUP_WT_STUB_SCENARIO` — it is NOT a `CLEANUP_WT_SCAN_BIN` setter. It invokes
   `classify_all_branches` (`scripts/bash/cleanup_worktrees_report_records_lib.sh:317-463`), whose
   body contains no scan call. The seam is therefore unreachable from it on both counts, and the
   `child_of_*` tests that use it cannot see a `stub-scan:` line.

## Blast radius

Exactly two of the ten env-setting sites can carry a `stub-scan:` line into a test's `$output`:

- site (3) — `tests/shell/test_cleanup_worktrees_cli.bats:34`
- site (6) — `report()` in `tests/shell/test_cleanup_worktrees_detached.bats:31-41`

Neither of those two sites carries an `$output` equality assertion or an unanchored line count, so
the line P1-T1 adds changes no assertion's value at either site. Phase 2's dispatch (P2-T16) is the
regression gate for this conclusion: its fail-before artifact must enumerate the `not ok` set and
confirm it contains only the eight tests this plan deliberately turns red.
