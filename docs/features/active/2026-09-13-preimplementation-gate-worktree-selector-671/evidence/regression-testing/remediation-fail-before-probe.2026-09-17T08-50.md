# Remediation Fail-Before Probe — Payload P rows Q1–Q11 (issue #671, R1)

Timestamp: 2026-09-17T09-46
Task: [P0-T9] [expect-fail]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/probe-q.ps1`. The script dot-sources `<scratchpad>/f671-r1/probelib.ps1`, which dot-sources `./.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (the guard at that file's lines 483–486 stops the entry point). For each row it sets `$DebugPreference = 'Continue'`, runs `$raw = @(Test-ExemptOrchestrationStagingCommand -CommandText $row -ErrorVariable rowErrors 5>&1 2>$null)`, resets `$DebugPreference = 'SilentlyContinue'`, and records `Result` (the `[bool]` elements of `$raw`), `ErrorCount` (`@($rowErrors).Count`), `Debug` (the `Message` values of the `DebugRecord` elements), and `Decision` (`(Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (@{ tool_name = 'Bash'; tool_input = @{ command = $row } } | ConvertTo-Json -Compress -Depth 5) -CheckpointRaw '{"issue-num":"","feature-folder":"","route_id":"","lifecycle_ready":false}').hookSpecificOutput.permissionDecision`). The script creates no file.
EXIT_CODE: 0
ExpectedOutcome: rows Q6, Q7, and Q9 are expected to show the fail-open (`Result` `True` with a binding error, gate `allow`) against the unmodified helpers file.
ErrorActionPreference in the session: Continue
Helpers hash at run time: `5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1` (unmodified; equals [P0-T4])

## Results

| Row | Command | Result | ErrorCount | Debug | Decision |
| --- | --- | --- | --- | --- | --- |
| Q1 | `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md` | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | deny |
| Q2 | `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md` | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | deny |
| Q3 | `git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md` | False | 0 | (none) | deny |
| Q4 | `git -C C:/repo/wt` | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | allow |
| Q5 | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | allow |
| Q6 | `git add "" -- src/foo.ps1` | True | 1 | (none) | allow |
| Q7 | `git add -- "" scripts/powershell/Sample.ps1` | True | 1 | (none) | allow |
| Q8 | `git add -- src/foo.ts ""` | True | 1 | (none) | allow |
| Q9 | `git -C "" add -- docs/features/active/x/spec.md` | True | 1 | (none) | allow |
| Q10 | `git commit -m "" -- src/foo.ts` | True | 1 | (none) | allow |
| Q11 | `git commit -m "" -- docs/features/active/x/spec.md` | True | 1 | (none) | allow |

Each `ErrorCount` of 1 is the parameter-binding error `Cannot bind argument to parameter 'Token' because it is an empty string.`, raised at `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:428:63` (`if (-not (Test-ExemptOrchestrationSegmentToken -Token $tokens)) {`). For rows Q6–Q11 the console also shows the same error once more, written by the `Decision` call. The plan's `Decision` expression does not redirect the error stream, so that call's gate-level evaluation of the same predicate prints the error.

Output Summary:
- Q1 and Q2: `Result` False, `Decision` deny, and `Debug` contains `PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value.` Matches the expectation.
- Q3: `Result` False, `Decision` deny, no `PREIMPL_SELECTOR_` debug record. Matches.
- Q4 and Q5: `Decision` allow. The old L3a/L3b fixtures are never classified as staging. Matches.
- Q6, Q7, Q9: `Result` True, `ErrorCount` 1, `Decision` allow. This is the fail-before evidence for RF-1 (empty-token fail-open). Matches.
- Q8, Q10, Q11 (recorded as observed): True / 1 / allow for each.
- No deviation in Q1–Q7 or Q9; Phase 1 is not blocked. The static fixture table in the plan is confirmed by execution.
