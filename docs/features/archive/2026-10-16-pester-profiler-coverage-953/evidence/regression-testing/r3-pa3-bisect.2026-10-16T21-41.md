# r3 PA-3 Bisection (P1-T5)

Timestamp: 2026-10-16T21-41
Command: Tool route in the background (SCRATCH/issue-953-r3-p1-t5.sh): export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; & (Join-Path $S 'issue-953-r3-bisect.ps1') -ManifestPath (Join-Path $S 'issue-953-ci3-shard1/shard-files.json') -Target 'tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1' -WatchTest 'issue #850 changed-file constraints.baseline mock interception probe' -WorkPrefix (Join-Path $S 'issue-953-r3-bisect') *> (Join-Path $S 'issue-953-r3-bisect.log'); $code = $LASTEXITCODE; Get-Content -LiteralPath (Join-Path $S 'issue-953-r3-bisect.log'); "EXIT_CODE=$code"; exit $code'
EXIT_CODE: 0
Output Summary:
- RUN 1 | full-prefix | FILES=41 | WATCH=Failed | FAILED=1 | STALE_RUN_INSTANCE=YES
- RUN 2 | target-alone | FILES=1 | WATCH=Passed | FAILED=0 | STALE_RUN_INSTANCE=NO
- RUN 3 | prefix-0..19 | FILES=21 | WATCH=Passed | FAILED=0 | STALE_RUN_INSTANCE=NO
- RUN 4 | prefix-0..29 | FILES=31 | WATCH=Passed | FAILED=0 | STALE_RUN_INSTANCE=NO
- RUN 5 | prefix-0..34 | FILES=36 | WATCH=Passed | FAILED=0 | STALE_RUN_INSTANCE=NO
- RUN 6 | prefix-0..37 | FILES=39 | WATCH=Passed | FAILED=0 | STALE_RUN_INSTANCE=NO
- RUN 7 | prefix-0..38 | FILES=40 | WATCH=Passed | FAILED=0 | STALE_RUN_INSTANCE=NO
- RUN 8 | boundary-0..39 | FILES=41 | WATCH=Failed | FAILED=1 | STALE_RUN_INSTANCE=YES
- RUN 9 | below-0..38 | FILES=40 | WATCH=Passed | FAILED=0 | STALE_RUN_INSTANCE=NO
- RUN 10 | last-with-target | FILES=2 | WATCH=Failed | FAILED=1 | STALE_RUN_INSTANCE=YES
- RUN 11 | minimal-with-target | FILES=2 | WATCH=Failed | FAILED=1 | STALE_RUN_INSTANCE=YES
- RUN 12 | minimal-without-target | FILES=1 | WATCH=MISSING:0 | FAILED=0 | STALE_RUN_INSTANCE=YES
- REPRO_FAILS=YES
- TARGET_ALONE=Passed
- BOUNDARY_INDEX=39
- BOUNDARY_FILE=tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
- BOUNDARY_FAILS=Failed
- BELOW_BOUNDARY=Passed
- MINIMAL_SET=tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
- MINIMAL_SET_WITH_TARGET=Failed
- MINIMAL_SET_MESSAGE=Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times
- MECHANISM_STALE_RUN_INSTANCE=YES
- MECHANISM_INSTANCES=epic:1 run:1
- RUNS=12
- SCRATCH/issue-953-r3-bisect-minimal.txt exists and lists the MINIMAL_SET path.
- Note: the MINIMAL_SET file is the Claude-hooks suite `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, not the #936-owned Codex suite of the same base name. Neither file is written by this cycle.
- Result: PASS (every acceptance condition holds).

MINIMAL_SET: tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
MECHANISM: H1 CONFIRMED - after MINIMAL_SET runs, the WorktreeRunResolution instance that EpicScopeResolution calls is not the instance that Mock -ModuleName WorktreeRunResolution binds to
