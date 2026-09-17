# Remediation Pass-After Probe — Payload P rows Q1–Q11 and the twenty rows (issue #671, R1)

Timestamp: 2026-09-17T09-53
Task: [P2-T10]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/probe-full.ps1`. The script dot-sources `probelib.ps1`, which is the same probe used by [P0-T9], unchanged. Rows Q1–Q11 are recorded with `Result`, `ErrorCount`, `Debug`, and `Decision`. The twenty rows of `evidence/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md` lines 19–38 run in the same order and are recorded with `Result`, `ErrorCount`, and `Debug`. Each row runs `$raw = @(Test-ExemptOrchestrationStagingCommand -CommandText $row -ErrorVariable rowErrors 5>&1 2>$null)` under `$DebugPreference = 'Continue'`. The script creates no file.
EXIT_CODE: 0
ErrorActionPreference in the session: Continue
Helpers hash at run time: `AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989` (post-edit; equals [P2-T9])

## Rows Q1–Q11, compared with [P0-T9] (`remediation-fail-before-probe.2026-09-17T08-50.md`)

| Row | Command | Result | ErrorCount | Debug | Decision | [P0-T9] Result / ErrorCount / Decision | Comparison |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Q1 | `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md` | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | deny | False / 0 / deny | identical (Result, Debug, Decision) |
| Q2 | `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md` | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | deny | False / 0 / deny | identical |
| Q3 | `git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md` | False | 0 | (none) | deny | False / 0 / deny | identical |
| Q4 | `git -C C:/repo/wt` | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | allow | False / 0 / allow | identical |
| Q5 | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | allow | False / 0 / allow | identical |
| Q6 | `git add "" -- src/foo.ps1` | False | 0 | (none) | deny | True / 1 / allow | fail-open closed (required) |
| Q7 | `git add -- "" scripts/powershell/Sample.ps1` | False | 0 | (none) | deny | True / 1 / allow | fail-open closed (required) |
| Q8 | `git add -- src/foo.ts ""` | False | 0 | (none) | deny | True / 1 / allow | fail-open closed (required) |
| Q9 | `git -C "" add -- docs/features/active/x/spec.md` | False | 0 | PREIMPL_SELECTOR_MALFORMED: the selector value is empty. | deny | True / 1 / allow | fail-open closed; L8 branch reached (required) |
| Q10 | `git commit -m "" -- src/foo.ts` | False | 0 | (none) | deny | True / 1 / allow | fail-open closed (required) |
| Q11 | `git commit -m "" -- docs/features/active/x/spec.md` | True | 0 | (none) | allow | True / 1 / allow | decision unchanged; binding error gone (required) |

## The twenty rows, compared with `pass-after-lacs-repro.2026-09-14T01-00.md`

| # | Command | Prior pass-after | Result now | ErrorCount | Debug | Comparison |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `git add -- docs/features/active/x/spec.md` | True | True | 0 | (none) | identical |
| 2 | `git -C C:/some/worktree add -- docs/features/active/x/spec.md` | True | True | 0 | (none) | identical |
| 3 | `git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md` | True | True | 0 | (none) | identical |
| 4 | `git add -A -- docs/features/active/x/spec.md` | False | False | 0 | (none) | identical |
| 5 | `git add -- src/foo.ts` | False | False | 0 | (none) | identical |
| 6 | `cd C:/some/worktree && git add -- docs/features/active/x/spec.md` | False | False | 0 | (none) | identical |
| 7 | `git add -- docs/features/active/x/spec.md \| tee out.txt` | False | False | 0 | (none) | identical |
| 8 | `git add -- "docs/features/active/x/spec.md` | False | False | 0 | (none) | identical |
| 9 | `git -C /repo/wt add -- docs/features/active/x/spec.md` | True | True | 0 | (none) | identical |
| 10 | `git -CC:/repo/wt add -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_UNMODELLED_OPTION: the token after the command name is not the -C selector. | identical |
| 11 | `git -c core.worktree=C:/repo/wt add -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_UNMODELLED_OPTION: the token after the command name is not the -C selector. | identical |
| 12 | `git -C C:/repo/wt -C C:/repo/other add -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_REPEATED: the segment carries more than one -C selector. | identical |
| 13 | `git -C C:/repo/wt` | False | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | identical |
| 14 | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value. | identical |
| 15 | `git -C subdir add -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_NOT_ROOTED: the selector value is relative or UNC. | identical |
| 16 | `git -C //server/share/wt add -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_NOT_ROOTED: the selector value is relative or UNC. | identical |
| 17 | `git -C C:/repo/wt/../other add -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_TRAVERSAL: the selector value carries a dot segment. | identical |
| 18 | `git -C C:/repo/./wt add -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_TRAVERSAL: the selector value carries a dot segment. | identical |
| 19 | `git -C C:/repo/wt:branch add -- docs/features/active/x/spec.md` | False | False | 0 | PREIMPL_SELECTOR_NOT_LITERAL: the selector value carries a wildcard or a stray colon. | identical |
| 20 | `git -C "" add -- docs/features/active/x/spec.md` | True (binding error) | False | 0 | PREIMPL_SELECTOR_MALFORMED: the selector value is empty. | changed True -> False: the intended RF-1 outcome |

Output Summary:
- Q1–Q5 record the same `Result`, `Debug`, and `Decision` values as [P0-T9], each with `ErrorCount` 0: PASS.
- Q6–Q10 each record `Result` False, `ErrorCount` 0, and `Decision` deny, and Q9's `Debug` contains `PREIMPL_SELECTOR_MALFORMED: the selector value is empty.`: PASS.
- Q11 records `Result` True, `ErrorCount` 0, `Decision` allow: PASS.
- Twenty rows: rows 2, 3, and 9 are True; rows 1–19 are identical to the prior pass-after artifact: PASS.
- Row 20 is False with `ErrorCount` 0. The change from True is the intended RF-1 outcome: the empty-token fail-open is closed, and the empty selector value now reaches the L8 rejection: PASS.
- All thirty-one probe calls record `ErrorCount` 0: PASS.
- Spec AC 25 probe clause: `git add "" -- src/foo.ps1` (Q6) and `git add -- "" scripts/powershell/Sample.ps1` (Q7) return False with zero error records.
