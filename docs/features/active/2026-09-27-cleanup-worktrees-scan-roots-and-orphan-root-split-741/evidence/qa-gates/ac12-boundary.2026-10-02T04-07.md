# P2-T9 Issue #756 boundary (AC-12)

Timestamp: 2026-10-02T04-07
Command: A2 substitute (DEV-2; A2 not written or run): `git show df5eb303129a30289a7d81775fdadaa40631be63:.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh` (plain, redirected to SCRATCH/report_records_lib.base.sh) with Grep for `^(run_report_scans|classify_all_branches)\(\) \{|^\}$` on the base blob and on the working tree; `git diff -U0 df5eb303129a30289a7d81775fdadaa40631be63 -- .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh`; `git diff --exit-code df5eb303129a30289a7d81775fdadaa40631be63 -- tests/shell/test_cleanup_worktrees_report_records.bats`; `git status --porcelain -- tests/shell/test_cleanup_worktrees_report_records.bats`
EXIT_CODE: 0
Output Summary:
- git show: exit 0.
- Function spans (A2 awk program semantics: from `<fn>() {` to the first following line equal to `}`):
  - BASE_SHA: run_report_scans 306-344 (39 lines); classify_all_branches 346-476 (131 lines). Matches the planning-time values in the Appendix.
  - Working tree: run_report_scans 269-307 (39 lines); classify_all_branches 309-439 (131 lines). Offset -37 for both.
- Anchored zero-context diff (exit 0, printed three hunks): `@@ -9,4 +9,4 @@` (header comment), `@@ -114,38 +113,0 @@ scan_stale_refs() {` (removal of cleanup_wt_scan_roots, base 114-151), `@@ -154 +116,2 @@ cleanup_wt_scan_records() {` (docstring line). Net line delta -38 + 1 = -37, equal to the observed span offset. No hunk intersects base lines 306-476, so both function bodies are unchanged line for line.
- Result in A2 form: FUNCTION run_report_scans IDENTICAL lines=39; FUNCTION classify_all_branches IDENTICAL lines=131.
- `git diff --exit-code BASE_SHA -- tests/shell/test_cleanup_worktrees_report_records.bats`: exit 0, no output.
- `git status --porcelain -- tests/shell/test_cleanup_worktrees_report_records.bats`: no output, exit 0. EXIT_CODE above is this last command.
- Deviation DEV-8: A2 replaced by the git show + Grep span comparison and the anchored `-U0` diff, per operator Option A (DEV-2).
- PASS.
