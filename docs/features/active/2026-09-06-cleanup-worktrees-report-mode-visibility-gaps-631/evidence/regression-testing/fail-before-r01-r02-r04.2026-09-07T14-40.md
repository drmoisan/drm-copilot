Timestamp: 2026-09-07T20:49
Command: bash scripts/bash/shell-qc.sh test --coverage (dispatched via `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2` on commit 43d2a76c, which carries remediation Phases 1-2 only (fixtures and test rewrites) with Phases 3-6 (the production fixes) held out via `git stash`; run https://github.com/drmoisan/drm-copilot/actions/runs/34160727312)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: bats TAP output reports `1..343` planned tests. Exactly 8 `not ok` lines, matching the plan's predicted expected-red set precisely by title:
  not ok 200 child_of_not_merged: CHILD_OF is emitted alongside the branch's own full-ladder verdict
  not ok 204 child_of_subject_merged_clean: the subject's own MERGED_CLEAN verdict is reported
  not ok 205 child_of_subject_content_neutral: the subject's own MERGED_CONTENT_NEUTRAL verdict is reported
  not ok 206 child_of_subject_merged_equivalent: the subject's own MERGED_EQUIVALENT verdict is reported
  not ok 230 apply mode deletes a delete-eligible branch that is an ancestor of a NOT_MERGED branch
  not ok 292 cleanup_wt_scan_roots derives both roots from the main worktree path
  not ok 294 cleanup_wt_scan_roots emits no root when the worktree listing hard-fails
  not ok 295 run_report performs exactly one filesystem scan
No other test failed (335 of 343 passed). This confirms the Phase 2 test rewrites and new fixtures are correctly targeted at the not-yet-landed Phase 3-6 production fixes (R-01 CHILD_OF short-circuit removal, R-04 scan-root derivation, R-02 duplicate-scan hoist) rather than being vacuous. Per P2-T15/P2-T16's fail-closed evidence rule, this is the required fail-before proof for the [expect-fail] tag.
