Timestamp: 2026-09-07T21:07
Command: bash scripts/bash/shell-qc.sh test --coverage (dispatched via `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-report-mode-visibility-gaps-631-r2` on commit 1f702f68, run https://github.com/drmoisan/drm-copilot/actions/runs/34161820865)
EXIT_CODE: 0
Output Summary: bats TAP output reports `1..343` planned tests; grep of the run log for `Z ok [0-9]+ ` matches 343 lines and `Z not ok [0-9]+ ` matches 0 lines, i.e. 343 passed, 0 failed. All twelve tests authored or renamed by this remediation cycle report `ok`, including the eight that were the fail-before evidence's expected-red set:
  ok 200 child_of_not_merged: CHILD_OF is emitted alongside the branch's own full-ladder verdict
  ok 204 child_of_subject_merged_clean: the subject's own MERGED_CLEAN verdict is reported
  ok 205 child_of_subject_content_neutral: the subject's own MERGED_CONTENT_NEUTRAL verdict is reported
  ok 206 child_of_subject_merged_equivalent: the subject's own MERGED_EQUIVALENT verdict is reported
  ok 230 apply mode deletes a delete-eligible branch that is an ancestor of a NOT_MERGED branch
  ok 292 cleanup_wt_scan_roots derives both roots from the main worktree path
  ok 294 cleanup_wt_scan_roots emits no root when the worktree listing hard-fails
  ok 295 run_report performs exactly one filesystem scan
This is not lower than the remediation-baseline count of 335. An intermediate CI run (34161256745, commit 00bbd885) surfaced one additional regression not predicted by preflight: `scan_registration_loss`'s two direct bats tests (`registration_lost_present`/`registration_lost_absent`) depended on `cleanup_wt_scan_roots` resolving roots via `parse_worktree_list`, which the R-04 fix newly introduced, and their fixtures lacked the required `worktree-list.out`. Fixed by adding the same `worktree-list.out` shape already used by the sibling `orphan_dir_present`/`orphan_dir_absent` fixtures (commit 1f702f68); this run confirms the fix and that no other pre-existing test was affected.
