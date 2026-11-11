# Live Two-Process Lock Proof (P3-T3)

Timestamp: 2026-11-11T05-21
Command: sh SCRATCH/issue-1158-lock-proof-docker.sh (one `docker run --rm` of the locally present devcontainer image `issue-1069-local-full:latest` with the worktree mounted at `/work`, running `bash SCRATCH/issue-1158-lock-two-process-proof.sh`: launcher A `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` in the background, then, once A's holder record exists, launcher B `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`; then A's process group is stopped and the lock file is probed with `FileShare.None`)
ExpectedExitCode: 75
EXIT_CODE: 75
Output Summary: Launcher B exited 75 (queue timeout) while launcher A held the lock; B's stderr named A's suite and pid; after A was stopped the lock probe returned Free.

## Observations (Linux, inside the container)

- A holder record: `pid` 138, `suite` `pester`, `worktreeRoot` `/work` (container mount path), `policyVersion` 1, `commandLine` starting `pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1 -ExcludeTag Integration Golden -ExcludeTestFileSuffix ...`.
- B_EXIT_CODE: 75
- B stderr: `TEST_EXECUTION_QUEUE_TIMEOUT: test-execution policy allows one suite per machine; lock held by suite pester (pid 138, worktree /work); waited 20000 ms; retry later.`
- A still running when B exited: yes. B could not open the lock (`FileShare.None` excluded it) and read A's holder record, whose pid and start time it confirmed.
- POST_STOP_PROBE: Free

## Run Conditions

- The image carries Pester 5.9.1; the proof script installed Pester 6.2.0 for the container user before starting A, because PoshQC requires 6.2.0 to 6.99.99. The container is removed after the run.
- The committed `config/test-execution-policy.json` was overlaid read-only inside the container by a copy that adds `machineLock.waitMilliseconds` 20000 and `pollMilliseconds` 1000, so B's bounded wait ended after 20 seconds instead of 90 and A's suite ran for that time only (bounded local load). The lock, holder, and message code paths are the committed ones.
- A first run in the same session (2026-11-11T05-18) exited 75 but reported `an unidentified process (stale record for pid 138)`: on Linux, `Get-Process` start times read by two processes did not compare equal to the tick, and the holder check compared ticks exactly. `Get-TestExecutionLockHolderDescription` in `.claude/hooks/test-execution-lock-decision.ps1` (and its `.codex/hooks` twin) now treats start times less than one second apart as the same process, with the new case `a start time read 10 ms apart` in `tests/scripts/claude-hooks/test-execution-lock-decision.Tests.ps1`; the run recorded above is the run after that fix. The first run's post-stop probe line was invalid (its probe command passed the directory as an unsupported `-Command` argument), and the probe was corrected for the recorded run.
