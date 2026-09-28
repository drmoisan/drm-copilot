# Pass-After Reproduction — LACS (issue #671)

Timestamp: 2026-09-17T08-20
Task: [P5-T9]
Command: pwsh -NoProfile -NonInteractive -File <scratchpad>/f671/repro.ps1. One session started at the worktree root via a scratchpad `sh` wrapper. The script dot-sources `./.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, then calls `Test-ExemptOrchestrationStagingCommand -CommandText <row> -ErrorVariable rowErrors 2>$null` for the same 20 rows, in the same order, as [P0-T4]. It creates no temporary file.
EXIT_CODE: 0
ExecutionStatus: EXECUTED against the post-change helpers file (SHA256 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1).
ErrorActionPreference in the session: Continue

Output Summary:
- Rows 2, 3, and 9 return `True`.
- Rows 1, 4-8, and 10-20 return exactly the values recorded in the [P0-T4] fail-before artifact (`evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md`).
- Row 20 still returns `True` with the same parameter-binding error. This matches the fail-before value, as the comparison requires. It also means the pre-existing empty-token fail-open is not closed by this change (see the escalation in the completion report).

## Row-by-row comparison against the fail-before capture

| # | CommandText | Fail-before | Pass-after | Comparison |
| --- | --- | --- | --- | --- |
| 1 | `git add -- docs/features/active/x/spec.md` | True | True | identical |
| 2 | `git -C C:/some/worktree add -- docs/features/active/x/spec.md` | False | True | flipped to True (required) |
| 3 | `git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md` | False | True | flipped to True (required) |
| 4 | `git add -A -- docs/features/active/x/spec.md` | False | False | identical |
| 5 | `git add -- src/foo.ts` | False | False | identical |
| 6 | `cd C:/some/worktree && git add -- docs/features/active/x/spec.md` | False | False | identical |
| 7 | `git add -- docs/features/active/x/spec.md \| tee out.txt` | False | False | identical |
| 8 | `git add -- "docs/features/active/x/spec.md` | False | False | identical |
| 9 | `git -C /repo/wt add -- docs/features/active/x/spec.md` | False | True | flipped to True (required) |
| 10 | `git -CC:/repo/wt add -- docs/features/active/x/spec.md` | False | False | identical |
| 11 | `git -c core.worktree=C:/repo/wt add -- docs/features/active/x/spec.md` | False | False | identical |
| 12 | `git -C C:/repo/wt -C C:/repo/other add -- docs/features/active/x/spec.md` | False | False | identical |
| 13 | `git -C C:/repo/wt` | False | False | identical |
| 14 | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | False | False | identical |
| 15 | `git -C subdir add -- docs/features/active/x/spec.md` | False | False | identical |
| 16 | `git -C //server/share/wt add -- docs/features/active/x/spec.md` | False | False | identical |
| 17 | `git -C C:/repo/wt/../other add -- docs/features/active/x/spec.md` | False | False | identical |
| 18 | `git -C C:/repo/./wt add -- docs/features/active/x/spec.md` | False | False | identical |
| 19 | `git -C C:/repo/wt:branch add -- docs/features/active/x/spec.md` | False | False | identical |
| 20 | `git -C "" add -- docs/features/active/x/spec.md` | True (binding error) | True (binding error) | identical |

The spec's eight-row subset (rows 1-8) also holds: rows 2 and 3 are `True`, and rows 1, 4, 5, 6, 7, and 8 are identical to the fail-before capture.
