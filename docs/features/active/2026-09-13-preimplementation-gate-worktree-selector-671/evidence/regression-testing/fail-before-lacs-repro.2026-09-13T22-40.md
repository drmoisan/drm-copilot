# Fail-Before Reproduction — LACS (issue #671) [expect-fail]

Timestamp: 2026-09-17T07-53
Task: [P0-T4]
Command: pwsh -NoProfile -NonInteractive -File <scratchpad>/repro.ps1 (one session started at the worktree root, via a scratchpad `sh` wrapper). The script dot-sources `./.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and, for each of the 20 rows below, calls `Test-ExemptOrchestrationStagingCommand -CommandText <row> -ErrorVariable rowErrors 2>$null`, recording the returned value and any error-stream record. No temporary file is created in the repository.
EXIT_CODE: 0
ExpectedExitCode: 0
ExecutionStatus: EXECUTED against the unmodified helpers file (SHA256 45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B), before any production edit.
ErrorActionPreference in the session: Continue (the PowerShell default, which is also the preference the gate hook runs under; the gate sets none).

Output Summary:
- Rows 2 and 3 (the defect rows) returned `False`, confirming the reported denial of the `git -C <worktree>` form.
- Row 1 (control) returned `True`.
- Rows 4-19 returned `False`, matching the plan's expectation.
- Row 20 (`git -C "" add ...`) returned `True`, which differs from the plan's expected `False`. The call wrote a parameter-binding error ("Cannot bind argument to parameter 'Token' because it is an empty string.") and still returned `True`. See "Row 20 finding" below.

## Results

| # | CommandText | Returned | Error stream |
| --- | --- | --- | --- |
| 1 | `git add -- docs/features/active/x/spec.md` | True | none |
| 2 | `git -C C:/some/worktree add -- docs/features/active/x/spec.md` | False | none |
| 3 | `git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md` | False | none |
| 4 | `git add -A -- docs/features/active/x/spec.md` | False | none |
| 5 | `git add -- src/foo.ts` | False | none |
| 6 | `cd C:/some/worktree && git add -- docs/features/active/x/spec.md` | False | none |
| 7 | `git add -- docs/features/active/x/spec.md \| tee out.txt` | False | none |
| 8 | `git add -- "docs/features/active/x/spec.md` | False | none |
| 9 | `git -C /repo/wt add -- docs/features/active/x/spec.md` | False | none |
| 10 | `git -CC:/repo/wt add -- docs/features/active/x/spec.md` | False | none |
| 11 | `git -c core.worktree=C:/repo/wt add -- docs/features/active/x/spec.md` | False | none |
| 12 | `git -C C:/repo/wt -C C:/repo/other add -- docs/features/active/x/spec.md` | False | none |
| 13 | `git -C C:/repo/wt` | False | none |
| 14 | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | False | none |
| 15 | `git -C subdir add -- docs/features/active/x/spec.md` | False | none |
| 16 | `git -C //server/share/wt add -- docs/features/active/x/spec.md` | False | none |
| 17 | `git -C C:/repo/wt/../other add -- docs/features/active/x/spec.md` | False | none |
| 18 | `git -C C:/repo/./wt add -- docs/features/active/x/spec.md` | False | none |
| 19 | `git -C C:/repo/wt:branch add -- docs/features/active/x/spec.md` | False | none |
| 20 | `git -C "" add -- docs/features/active/x/spec.md` | True | Cannot bind argument to parameter 'Token' because it is an empty string. |

## Row 20 finding (pre-existing fail-open; not caused by this change)

- Mechanism: `ConvertTo-OrchestrationCommandToken` emits an empty-string token for `""`. `Test-ExemptOrchestrationSegmentToken` declares `param([Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Token)` at helpers line 221, without `[AllowEmptyString()]`, so parameter binding rejects the array before the function body runs. Under the default `Continue` preference, that binding error terminates only the enclosing `if` statement at helpers line 344. The `foreach` then continues, and `Test-ExemptOrchestrationStagingCommand` reaches `return $true` at line 348.
- A first run of the same script under `$ErrorActionPreference = 'Stop'` threw at row 20 instead of returning a value; that run is superseded by this one because the gate runs under `Continue`.
- Gate-level confirmation (same session shape, `Invoke-OrchestrationPreimplementationGateDecision` with a not-ready checkpoint `{"route_id":"","lifecycle_ready":false}`):
  - `git -C "" add -- docs/features/active/x/spec.md` => `allow`
  - `git add -- src/foo.ts ""` => `allow`
  - `git commit -m "" -- src/foo.ts` => `allow`
  - `git add -- src/foo.ts` => `deny` (control)
- Impact: any `git add` / `git commit` segment carrying an empty quoted token bypasses the pre-implementation gate, including for production paths. This is independent of the `-C` selector axis.
- Consequence for this plan: the spec's L8 deny row (`issue #671 LACS L8 - empty selector value`) cannot deny through the gate unless line 221 gains `[AllowEmptyString()]`. [P1-T3] allows edits only to the comment at lines 227-229, and [P5-T4] requires every removed line to fall inside the pre-change 227-236 block, so the plan as written cannot make that row pass. This is escalated in the completion report.

Route note: no PowerShell tool is available in this session; `pwsh` 7.6.6 was launched from a scratchpad `sh` wrapper with the working directory set to the worktree root.
