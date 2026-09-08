# Fail-Before — R-1 reproduced on the Claude side ([P1-T3], `[expect-fail]`)

Timestamp: 2026-09-07T19-41
Task: [P1-T3] `[expect-fail]`
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and `scan_folders` = `["tests/scripts/claude-hooks"]`, then read `artifacts/pester/pester-junit.xml`
EXIT_CODE: 5
ExpectedExitCode: 5

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context. Pester is invoked through the `mcp__drm-copilot__run_poshqc_test` MCP function with
`scan_folders`, and per-suite and per-case results are read from the JUnit report at
`artifacts/pester/pester-junit.xml`. Route substitution, not a skipped stage.

The tool's exit code is the folder-wide failed-test count. It is 5 here: the four deliberately
failing new cases plus the one tolerated pre-existing ambient failure in
`enforce-pr-author-skill.Tests.ps1`. `ExpectedExitCode` is recorded equal to that observed count
because a failing run is the expected outcome of this task.

## State of the tree at this run

`tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` carries the five new `It` blocks
appended by `[P1-T2]`. `.claude/hooks/validate-bash.ps1` is UNMODIFIED — the R-1 edit of `[P1-T4]`
has not been applied. That is what makes this a reproduction rather than a test defect.

## `<testsuite>` for `validate-bash.TriggerScoping.Tests.ps1`

```
tests="12" errors="0" failures="4" skipped="0" id="51"
```

`tests` is **12** and `failures` is **4**, as the task requires.

## Per-case `status` for all twelve cases in that suite

| # | It name | status | Expected here |
|---|---|---|---|
| 1 | `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force` | Passed | Passed |
| 2 | `AT-9 denies a relocating git push --force carrying a directory global option` | Passed | Passed |
| 3 | `AT-10 allows a commit message that quotes a dangerous pattern in prose` | Passed | Passed |
| 4 | `allows git push origin main because no force flag is present` | Passed | Passed |
| 5 | `allows git reset --soft HEAD~1 because --soft is not --hard` | Passed | Passed |
| 6 | `allows a commit message whose quoted text contains a cd-then-read phrase` | Passed | Passed |
| 7 | `still denies a read command that is not adjacent to the cd segment` | Passed | Passed |
| 8 | `R1-C1 denies rm -rf carried inside a bash -c quoted argument` | **Failed** | Failed |
| 9 | `R1-C2 denies git reset --hard carried inside an sh -c quoted argument` | **Failed** | Failed |
| 10 | `R1-C3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument` | **Failed** | Failed |
| 11 | `R1-C4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led` | Passed | Passed |
| 12 | `R1-C5 denies rm -rf carried inside an unterminated quoted span` | **Failed** | Failed |

The four cases carrying `status="Failed"` are exactly `R1-C1`, `R1-C2`, `R1-C3`, and `R1-C5`.
`R1-C4` carries `status="Passed"`. All seven pre-existing cases carry `status="Passed"`.

## What each failure demonstrates

- `R1-C1`, `R1-C2`, `R1-C3` reproduce the wrapper-led weakening: the segment is wrapper-led, the
  scanner has already selected `RawText` as `ScanText`, and leg 1 never reads that field, so a
  multi-token literal collapsed into one quoted token forms no contiguous token run and
  `Get-BlockedPatternMatch` returns `$null` where the pre-change `String.Contains` returned the
  literal.
- `R1-C5` reproduces the `Unbalanced` weakening specifically. `echo` is not a member of
  `$script:CommandLineWrapperNames`, the line carries no `$(` and no backtick, and the unterminated
  double quote is the only reason the scanner selects `RawText`. A pass on `R1-C5` here would have
  meant the third disjunct was already present and the plan's D6 correction unnecessary; it failed,
  so the third disjunct is falsifiable rather than asserted.
- `R1-C4` passing here confirms the case is a real negative and not an artefact of the defect: it
  already allows before the fix, so if the fix were over-broad and scanned `RawText` for every
  segment regardless of the carve-out condition, this case would turn from pass to fail.

## Folder-wide failing set

| # | Suite file | Case name | Classification |
|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | tolerated pre-existing ambient failure, row 1 of the plan preamble table |
| 2-5 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `R1-C1`, `R1-C2`, `R1-C3`, `R1-C5` | deliberate `[expect-fail]` reproductions |

No other case in the folder failed.

Output Summary: R-1 reproduced on the Claude side. `validate-bash.TriggerScoping.Tests.ps1` reports
tests 12, failures 4, errors 0; the four failures are exactly `R1-C1`, `R1-C2`, `R1-C3`, `R1-C5`;
`R1-C4` and all seven pre-existing cases pass. Folder-wide failed count 5, matching the tool's exit
code. The defect is reproduced, so `[P1-T4]` proceeds.
