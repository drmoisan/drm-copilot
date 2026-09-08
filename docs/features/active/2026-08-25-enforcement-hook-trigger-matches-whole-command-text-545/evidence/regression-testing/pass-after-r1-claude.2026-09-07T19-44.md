# Pass-After — R-1 fixed on the Claude side ([P1-T6])

Timestamp: 2026-09-07T19-44
Task: [P1-T6]
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and `scan_folders` = `["tests/scripts/claude-hooks"]`, then read `artifacts/pester/pester-junit.xml`
EXIT_CODE: 1
ExpectedExitCode: 1

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context. Pester is invoked through `mcp__drm-copilot__run_poshqc_test` with `scan_folders`, and
per-suite and per-case results are read from `artifacts/pester/pester-junit.xml`. Route
substitution, not a skipped stage. The tool's exit code equals the folder-wide failed-test count,
which is 1 here — the single tolerated pre-existing ambient failure. Acceptance below is stated on
`<testsuite>` counts and per-case `status` attributes, not on the exit code.

Paired fail-before artifact: `evidence/regression-testing/fail-before-r1-claude.2026-09-07T19-41.md`
(same four cases, `status="Failed"`, before the `[P1-T4]` edit).

## (a) `validate-bash.TriggerScoping.Tests.ps1`

```
tests="12" errors="0" failures="0" skipped="0" id="51"
```

`tests` **12**, `failures` **0**, `errors` **0**.

| It name | status |
|---|---|
| `R1-C1 denies rm -rf carried inside a bash -c quoted argument` | Passed |
| `R1-C2 denies git reset --hard carried inside an sh -c quoted argument` | Passed |
| `R1-C3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument` | Passed |
| `R1-C4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led` | Passed |
| `R1-C5 denies rm -rf carried inside an unterminated quoted span` | Passed |

All five new cases pass. `R1-C5` passing is the specific evidence that the third disjunct
(`$segment.Unbalanced`) is present and effective; it failed against the same tree before the edit.
`R1-C4` still passing is the evidence that the fix is not over-broad: a fix scanning `RawText` for
every segment regardless of the carve-out condition would have turned it red.

## (b) `validate-bash.Tests.ps1` and the leg-ordering assertion

```
tests="26" errors="0" failures="0" skipped="0" id="50"
```

`tests` **26**, `failures` **0**.

Case `returns the matched pattern for every repository-dangerous command` carries
`status="Passed"`.

That case is the Claude-side leg-ordering assertion. At
`tests/scripts/claude-hooks/validate-bash.Tests.ps1` line 32 it asserts:

```powershell
@{ Command = 'git push origin --force'; Pattern = 'git push origin --force' },
```

Its passing confirms leg 1 is still evaluated in full, over every literal and every segment, before
any leg 2 evaluation: `git push origin --force` returns the leg-1 literal
`git push origin --force` rather than leg 2's structural value `git push --force`. The new second
condition sits inside the existing `foreach ($pattern) { foreach ($segment) }` and returns the
literal, so the ordering is unchanged.

## (c) Pre-existing cases in `validate-bash.TriggerScoping.Tests.ps1`

| It name | status |
|---|---|
| `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force` | Passed |
| `AT-9 denies a relocating git push --force carrying a directory global option` | Passed |
| `AT-10 allows a commit message that quotes a dangerous pattern in prose` | Passed |
| `allows git push origin main because no force flag is present` | Passed |
| `allows git reset --soft HEAD~1 because --soft is not --hard` | Passed |
| `allows a commit message whose quoted text contains a cd-then-read phrase` | Passed |
| `still denies a read command that is not adjacent to the cd segment` | Passed |

All seven pre-existing cases pass, so the over-match fix this remediation cycle must preserve is
intact. AT-8 in particular remains green, which pins the distinct over-broad shape that would scan
`ScanText` unconditionally: its unquoted masked text `git push --force-with-lease origin HEAD`
contains the literal `git push --force`.

## (d) Complete folder-wide failing set

| # | Suite file | Case name | Classification |
|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | row 1 of the plan preamble's tolerated-failures table |

That is the only case in the whole `tests/scripts/claude-hooks` folder carrying `status="Failed"`.
No additional failure exists, so the phase is not blocked. This suite is not modified by this plan;
it is an ambient-state failure driven by the gitignored
`artifacts/orchestration/orchestrator-state.json` and is green on a clean CI checkout.

Output Summary: Claude-side R-1 fix confirmed. `validate-bash.TriggerScoping.Tests.ps1` 12 tests, 0
failures, 0 errors with all five R1-C cases passing; `validate-bash.Tests.ps1` 26 tests, 0 failures
with the leg-ordering case passing and still returning `git push origin --force`; all seven
pre-existing trigger-scoping cases passing; folder-wide the only failure is the single tolerated
ambient case.
