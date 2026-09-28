# Canonical Copy Check — LACS (issue #671)

Timestamp: 2026-09-17T08-03
Task: [P1-T5]
Command: pwsh -NoProfile -NonInteractive -File <scratchpad>/parse.ps1 (`[System.Management.Automation.Language.Parser]::ParseFile(<.claude/hooks/...-helpers.ps1>, [ref]$tokens, [ref]$errors)`, `@(Get-Content -LiteralPath <path>).Count`, `Get-FileHash`), then pwsh -NoProfile -NonInteractive -File <scratchpad>/repro.ps1 (the identical 20-row [P0-T4] procedure, default ErrorActionPreference `Continue`); both launched from a scratchpad `sh` wrapper at the worktree root
EXIT_CODE: 0

Output Summary:
- Parse errors: 0.
- Line count: 433 (at most 500; 84 lines added to the 349-line baseline, under the 150-line drift threshold).
- SHA256 at check: 5C906A2AABFB4110FAFC70357E85A5476C5546A1B6D5E1F030518D194A7E13B1.
- Rows 2, 3, and 9 now return `True`.
- Rows 1, 4-8, and 10-20 return the same value the [P0-T4] artifact recorded.

## Row-by-row comparison

| # | CommandText | Fail-before ([P0-T4]) | Now | Same? |
| --- | --- | --- | --- | --- |
| 1 | `git add -- docs/features/active/x/spec.md` | True | True | yes |
| 2 | `git -C C:/some/worktree add -- docs/features/active/x/spec.md` | False | True | flipped (expected) |
| 3 | `git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md` | False | True | flipped (expected) |
| 4 | `git add -A -- docs/features/active/x/spec.md` | False | False | yes |
| 5 | `git add -- src/foo.ts` | False | False | yes |
| 6 | `cd C:/some/worktree && git add -- docs/features/active/x/spec.md` | False | False | yes |
| 7 | `git add -- docs/features/active/x/spec.md \| tee out.txt` | False | False | yes |
| 8 | `git add -- "docs/features/active/x/spec.md` | False | False | yes |
| 9 | `git -C /repo/wt add -- docs/features/active/x/spec.md` | False | True | flipped (expected) |
| 10 | `git -CC:/repo/wt add -- docs/features/active/x/spec.md` | False | False | yes |
| 11 | `git -c core.worktree=C:/repo/wt add -- docs/features/active/x/spec.md` | False | False | yes |
| 12 | `git -C C:/repo/wt -C C:/repo/other add -- docs/features/active/x/spec.md` | False | False | yes |
| 13 | `git -C C:/repo/wt` | False | False | yes |
| 14 | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | False | False | yes |
| 15 | `git -C subdir add -- docs/features/active/x/spec.md` | False | False | yes |
| 16 | `git -C //server/share/wt add -- docs/features/active/x/spec.md` | False | False | yes |
| 17 | `git -C C:/repo/wt/../other add -- docs/features/active/x/spec.md` | False | False | yes |
| 18 | `git -C C:/repo/./wt add -- docs/features/active/x/spec.md` | False | False | yes |
| 19 | `git -C C:/repo/wt:branch add -- docs/features/active/x/spec.md` | False | False | yes |
| 20 | `git -C "" add -- docs/features/active/x/spec.md` | True (with binding error) | True (with binding error) | yes |

Row 20 note: the value is unchanged because the parameter-binding failure at helpers line 221 (unchanged `param` line, no `[AllowEmptyString()]`) occurs before the new selector predicate can run. See the Row 20 finding in `evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md`.
