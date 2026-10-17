# r2 regression fail-before (P1-T11, expect-fail)

Timestamp: 2026-10-16T15-59
Command: sh "SCRATCH/issue-953-r2-p1-t11.sh" (TARGETED_RUN(r2-before, R2_SET) task text verbatim with ISSUE953_JUNIT = SCRATCH/issue-953-r2-r2-before-junit.xml, followed by JRP steps 2, 4, and 5 on that file)
EXIT_CODE: 9
ExpectedExitCode: 9
Output Summary:
  EXIT_CODE=9 START_UTC=2026-10-16T15:59:08.2622618Z; RUN_VALID=True
  JRP_TOTALS tests=44 failures=9 errors=0 (R2_TARGETED_BASELINE_TESTS 32 + 12 new cases = 44)
  JRP failure checks (step 5), FAIL_BEFORE_TOKENS:
    FAILCHECK WF04-SHARD-COUNT-FROM-MATRIX PASS; message: Expected regular expression '-ShardIndex \$\{\{ matrix\.shard \}\} -ShardCount \$\{\{ strategy\.job-total \}\}' to match '<poshqc-shard job text containing -ShardCount 3>', but it did not match.
    FAILCHECK WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT PASS; message: Expected regular expression '\b1\.\.\d' to not match '<poshqc job text containing @(1..3 | ... and foreach ($shardNumber in 1..3)>', but it did match.
    FAILCHECK SH10-SLICE-WEIGHTED-LPT PASS; message: ParameterBindingException: A parameter cannot be found that matches parameter name 'Weight'.
    FAILCHECK SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER PASS; message: ParameterBindingException: A parameter cannot be found that matches parameter name 'Weight'.
    FAILCHECK SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS PASS; message: Expected an exception with message like '*Weight lists 2 values; TestFile lists 3 files*' to be thrown, but the message was 'A parameter cannot be found that matches parameter name 'Weight'.'.
    FAILCHECK CM02-MERGE-RECOMPUTES-LINE-COUNTERS PASS; message: Expected 0, because METHOD figures cannot be recomputed from merged line hits, so the merged report omits them (CR-8), but got 5.
    FAILCHECK CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES PASS; message: Expected 0, but got 1.
    FAILCHECK TS05-EMPTY-SHARD-SLICE-THROWS PASS; message: Expected an exception with message like '*Shard 3 of 3 selects no test file*' to be thrown, but no exception was thrown.
    FAILCHECK TS06-SHARD-WEIGHTED-BY-FILE-SIZE PASS; message: Expected strings to be the same, but they were different. Expected: '/shard-root/tests/t1.Tests.ps1,/shard-root/tests/t2.Tests.ps1' But was: '/shard-root/tests/t1.Tests.ps1,/shard-root/tests/t3.Tests.ps1'
  JRP token checks (step 4):
    TOKEN SH01-SLICE-ROUND-ROBIN PASS
    TOKEN SH02-SLICE-INVALID-INDEX-THROWS PASS
    TOKEN SH03-MANIFEST-RELATIVE-PATHS PASS
    TOKEN SH04-COMPLETENESS-PASS PASS
    TOKEN SH05-COMPLETENESS-MISSING-FILE-THROWS PASS
    TOKEN SH06-COMPLETENESS-OVERLAP-THROWS PASS
    TOKEN SH07-COMPLETENESS-DIVERGENT-ALL-THROWS PASS
    TOKEN SH08-TESTCOUNT-MISMATCH-THROWS PASS
    TOKEN SH09-TESTCOUNT-MATCH-PASSES PASS
    TOKEN CM01-MERGE-MAX-CI PASS
    TOKEN CM03-MERGE-PRESERVES-DENOMINATOR PASS
    TOKEN CM04-MERGE-MISMATCHED-LINES-THROWS PASS
    TOKEN CM05-MERGE-SINGLE-REPORT-IDENTITY PASS
    TOKEN CM06-MERGE-EMPTY-INPUT-THROWS PASS
    TOKEN CM07-SUMMARY-REPORT-LINE PASS
    TOKEN TS01-SHARD-RUNPATH-SELECTED PASS
    TOKEN TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM PASS
    TOKEN TS03-NO-SHARD-RUNPATH-UNCHANGED PASS
    TOKEN WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS PASS
    TOKEN WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE PASS
    TOKEN WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS PASS
    TOKEN TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON PASS
  The nine failed cases are exactly the FAIL_BEFORE_TOKENS cases; no other case failed.
