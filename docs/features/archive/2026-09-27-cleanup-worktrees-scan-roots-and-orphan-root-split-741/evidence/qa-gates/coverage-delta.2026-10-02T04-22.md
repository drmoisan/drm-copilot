# P2-T13 Coverage threshold and delta for AC-11 over CHANGED-SH (DEV-2: changed-line coverage derived without A1)

Timestamp: 2026-10-02T04-22
Command: `awk 'BEGIN { printf "DELTA=%.1f\n", 93.8 - 93.7 }'`; `git diff -U0 df5eb303129a30289a7d81775fdadaa40631be63 -- .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` (added line numbers from the `+start,count` hunk headers); Grep/Read of the `<line number="N" hits="H"/>` entries inside each file's `<class>` in SCRATCH/ci-final-sha/cov.xml (FINAL_RUN_ID 36982722154, headSha = FINAL_SHA 10c6ac2951786a80327d0fff4041d6d8bb06885b).
EXIT_CODE: 0
Output Summary:
- DELTA=0.1 (FINAL_AGGREGATE 93.8 - BASELINE_AGGREGATE 93.7). Non-negative.
- Per-file table (baseline from FEATURE/evidence/baseline/shell-coverage-ci.2026-10-02T03-47.md; final from FEATURE/evidence/qa-gates/shell-coverage-ci.2026-10-02T04-21.md):

| File | Baseline rate | Final rate | Added lines (git diff -U0) | Changed instrumented | Changed covered | Changed % | Missed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| cleanup_worktrees_enumerate_lib.sh | 0.924 | 0.953 | 7-12, 18-19, 256-416 | 80 | 79 | 98.8% | [370] |
| cleanup_worktrees_report_records_lib.sh | 0.890 | 0.879 | 9-12, 116-117 | 0 | 0 | n/a | [] |
| cleanup_worktrees_preserve_lib.sh | 0.906 | 0.906 | 161 | 1 | 1 | 100.0% | [] |
| cleanup_worktrees_scan_helper.sh | 0.875 | 0.873 | 43-45, 105 | 2 (45, 105) | 2 | 100.0% | [] |
| cleanup-worktrees.sh | 0.976 | 0.976 | 142-152 | 0 | 0 | n/a | [] |
| Total | aggregate 93.7% | aggregate 93.8% | | 83 | 82 | 98.8% | [enumerate 370] |

- Instrumented-line derivation, enumerate_lib: the class (cov.xml lines 984-1159) carries no entry for added lines 7-12 or 18-19 (comment header); entries for 256-416 are cov.xml lines 1078 (number 269) through 1157 (number 415), 80 entries, of which only number 370 has hits="0". Line 370 is `done < <(printf '%s\n' "${kept[@]}" | LC_ALL=C sort -t '|' -k1,1)`, the terminator of a while loop whose body line 369 has hits="1"; the loop body can only run when the process substitution on line 370 has run, so the hits="0" mark is most likely a kcov line-attribution effect for the process-substitution line, not unexecuted code. It is recorded as missed as reported.
- report_records_lib: all added lines (9-12 header comment, 116-117 doc comment) are comments; the class has no entry for them. scan_helper: added 43-44 are shellcheck directives (not instrumented); 45 (`source .../cleanup_worktrees_enumerate_lib.sh`) hits=1; 105 (`if ! cleanup_wt_is_absolute_path "$target"`) hits=1. preserve_lib: 161 (`elif cleanup_wt_is_absolute_path "$val"`) hits=1 (cov.xml line 2216). cleanup-worktrees.sh: 142-152 are usage heredoc text; the class (cov.xml 1586-1631) has no entry in that range.
- Per-file drops explained:
  - report_records_lib 0.890 -> 0.879: no changed line is instrumented, so no changed line is uncovered. The final class has 165 instrumented lines with 20 misses (85, 86, 90, 91, 129, 131, 143, 146, 147, 184, 248, 288, 289, 290, 292, 296, 300, 304, 366, 425), 145/165 = 0.8788. The change removed the old `cleanup_wt_scan_roots` (base lines 114-151), whose instrumented lines were exercised by the existing override and hard-fail tests. Removing covered lines shrinks the numerator and denominator equally, which lowers the ratio while the uncovered set is unchanged: removal of about 17 covered lines (162/182 = 0.890) reproduces the baseline value. The baseline cov.xml was not available to the executor, so the exact removed count is inferred from the two recorded rates, not read.
  - scan_helper 0.875 -> 0.873: both instrumented changed lines are covered. The final class has 55 instrumented lines with 7 misses (58, 73, 102, 103, 141, 159, 160), 48/55 = 0.8727. The change removed `scan_helper_is_absolute_path` (two instrumented body lines, covered by the #706 predicate tests) and added one covered `source` line; baseline 49/56 = 0.875 is consistent with that net removal of one covered line. Inferred, as above.
- Threshold checks: every final per-file line rate >= 0.850 (lowest 0.873, scan_helper) -> PASS. Every file with instrumented changed lines > 0 has changed coverage >= 0.85 (enumerate 79/80 = 0.988; preserve 1/1; scan_helper 2/2) -> PASS. enumerate_lib instrumented changed-line count 80 > 0 -> PASS.
- Deviation: DEV-2 (A1 not run; values derived by plain `git diff -U0` plus Read/Grep of cov.xml).
- Result: PASS.
