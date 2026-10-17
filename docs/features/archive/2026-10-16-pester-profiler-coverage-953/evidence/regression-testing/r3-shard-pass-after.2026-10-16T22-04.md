# r3 CR-18 and CR-19 Tests, Pass-After (P4-T8)

Timestamp: 2026-10-16T22-04
Command: TARGETED_RUN(shard-after, R3_SHARD_SET) through the Tool route (SCRATCH/issue-953-r3-p4-t8.sh, JUnit SCRATCH/issue-953-r3-shard-after-junit.xml, log SCRATCH/issue-953-r3-shard-after.log), followed by the validity check and JRP; the JRP token check (step 4) for R3_NEW_TOKENS on the same JUnit file in SCRATCH/issue-953-r3-p4-t8-2.sh.
EXIT_CODE: 0
Output Summary:
- EXIT_CODE=0 START_UTC=2026-10-16T22:04:25.4634540Z; VALID=True
- JRP tests=23 failures=0 errors=0 (R3_TARGETED_BASELINE_TESTS 20 + 3)
- R3_NEW_TOKENS token checks, each hits=1 PASS: SH13-SLICE-NEGATIVE-WEIGHT-THROWS, SH14-WEIGHT-IGNORES-LINE-ENDINGS, SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT
- R3_SHARD_OLD_TOKENS token checks, each hits=1 PASS: SH01 through SH12, TS01 through TS06 (all 18)
- Deviation note: the first script was derived from the P3-T4 script and also printed that task's fail-before FAILURE_CHECK lines, which read FAIL here because the three tests now pass (hits=1 failed=0). Those lines do not apply to pass-after; the required step-4 token check was run on the same JUnit file in a second script.
- Result: PASS.
