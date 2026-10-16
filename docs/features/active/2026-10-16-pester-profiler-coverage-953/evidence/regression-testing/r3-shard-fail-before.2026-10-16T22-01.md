# r3 CR-18 and CR-19 Tests, Fail-Before (P3-T4, expect-fail)

Timestamp: 2026-10-16T22-01
Command: TARGETED_RUN(shard-before, R3_SHARD_SET) through the Tool route (SCRATCH/issue-953-r3-p3-t4.sh): the TARGETED_RUN text with JUnit SCRATCH/issue-953-r3-shard-before-junit.xml and log SCRATCH/issue-953-r3-shard-before.log, followed by the validity check, JRP totals, the JRP failure check (step 5) for R3_NEW_TOKENS, and the JRP token check (step 4) for R3_SHARD_OLD_TOKENS.
EXIT_CODE: 3
ExpectedExitCode: 3
Output Summary:
- EXIT_CODE=3 START_UTC=2026-10-16T22:01:45.5105262Z; VALID=True
- JRP tests=23 failures=3 errors=0 (R3_TARGETED_BASELINE_TESTS 20 + 3 = 23)
- FAILURE_CHECK SH13-SLICE-NEGATIVE-WEIGHT-THROWS hits=1 failed=1 PASS; message: Expected an exception with message like '*Weight must not be negative; 'b' has weight -1*' to be thrown, but no exception was thrown.
- FAILURE_CHECK SH14-WEIGHT-IGNORES-LINE-ENDINGS hits=1 failed=1 PASS; message: CommandNotFoundException: The term 'Get-PoshQCShardTestFileWeight' is not recognized as a name of a cmdlet, function, script file, or executable program.
- FAILURE_CHECK SH15-SELECT-WEIGHS-CHECKED-IN-FILES-BY-NORMALIZED-TEXT hits=1 failed=1 PASS; message: CommandNotFoundException: The term 'Get-PoshQCShardTestFileWeight' is not recognized as a name of a cmdlet, function, script file, or executable program.
- TOKEN_CHECK, each hits=1 PASS: SH01-SLICE-ROUND-ROBIN, SH02-SLICE-INVALID-INDEX-THROWS, SH03-MANIFEST-RELATIVE-PATHS, SH04-COMPLETENESS-PASS, SH05-COMPLETENESS-MISSING-FILE-THROWS, SH06-COMPLETENESS-OVERLAP-THROWS, SH07-COMPLETENESS-DIVERGENT-ALL-THROWS, SH08-TESTCOUNT-MISMATCH-THROWS, SH09-TESTCOUNT-MATCH-PASSES, SH10-SLICE-WEIGHTED-LPT, SH11-SLICE-EQUAL-WEIGHTS-ORDINAL-PATH-ORDER, SH12-SLICE-WEIGHT-COUNT-MISMATCH-THROWS, TS01-SHARD-RUNPATH-SELECTED, TS02-SHARD-FILELIST-WRITTEN-VIA-SEAM, TS03-NO-SHARD-RUNPATH-UNCHANGED, TS04-DEFAULT-FILELIST-SEAM-WRITES-UTF8-JSON, TS05-EMPTY-SHARD-SLICE-THROWS, TS06-SHARD-WEIGHTED-BY-FILE-SIZE
- Result: expected failure state confirmed; every acceptance condition holds.
