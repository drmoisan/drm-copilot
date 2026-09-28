Timestamp: 2026-09-07T18:36
Command: ls/cat over each new fixture scenario directory, plus grep -rn "17 " and grep -rn "four director" over the new test and fixture files
EXIT_CODE: 0
Output Summary:
Per-scenario canned-record count (each exactly one, not four or seventeen or two):
- orphan_dir_present/scan-dirs.out: 1 line (`.claude/worktrees/agent-old|0|NA|128K`)
- orphan_dir_absent/scan-dirs.out: 1 line (`/repo-wt/feat|1|1|64K`)
- stale_ref_present/for-each-ref.refs_remotes_.out: 1 line (`refs/remotes/upstream/feature-old`)
- stale_ref_absent: 0 stale lines (remote.out lists both `origin` and `upstream`, so the one
  remote-tracking ref present is not stale)
- registration_lost_present/scan-dirs.out: 1 line (`/repo-wt/half-gone|1|0|32K`)
- registration_lost_absent/scan-dirs.out: 1 line (`/repo-wt/intact|1|1|32K`, not a lost record)
- child_of_not_merged: 3 branches (feature-child, feature-parent, main), 1 CHILD_OF record
- child_of_merged_equivalent: 3 branches, 0 CHILD_OF records (short-circuit correctly does not fire)
- child_of_ancestry_probe_error: 3 branches, 1 ANCESTRY_ERROR record

SearchScope: tests/shell/test_cleanup_worktrees_report_records.bats,
tests/shell/test_cleanup_worktrees_classification.bats, tests/shell/test_cleanup_worktrees_scan_helper.bats,
tests/shell/test_cleanup_worktrees_scan_seam.bats, and every new fixture directory under
tests/fixtures/cleanup_worktrees/scenarios/{orphan_dir_present,orphan_dir_absent,stale_ref_present,
stale_ref_absent,registration_lost_present,registration_lost_absent,child_of_not_merged,
child_of_merged_equivalent,child_of_ancestry_probe_error}/ and tests/fixtures/cleanup_worktrees/scan_roots/
SearchPatterns: "17 ", "four director"
SearchResult: none (both greps exited 1 / no matches)

No AC or test in this feature's Phases 1-9 asserts a fixed historical numeric count (four dirs / 17
refs / two worktrees) from the 2026-09-06 manual run referenced in spec.md's Test Strategy; detection
is generic and parameterized against single-instance, purpose-built fixtures. This satisfies AC11.
