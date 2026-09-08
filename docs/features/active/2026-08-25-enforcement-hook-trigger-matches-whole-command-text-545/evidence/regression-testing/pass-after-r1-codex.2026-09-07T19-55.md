# Pass-After — R-1 fixed on the Codex side ([P2-T6])

Timestamp: 2026-09-07T19-55
Task: [P2-T6]
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and `scan_folders` = `["tests/scripts/codex-hooks"]`, then read `artifacts/pester/pester-junit.xml`
EXIT_CODE: 1
ExpectedExitCode: 1

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context. Pester is invoked through `mcp__drm-copilot__run_poshqc_test` with `scan_folders`, and
per-suite and per-case results are read from `artifacts/pester/pester-junit.xml`. Route
substitution, not a skipped stage. The tool's exit code equals the folder-wide failed-test count,
which is 1 here — the single tolerated pre-existing ambient failure.

Paired fail-before artifact: `evidence/regression-testing/fail-before-r1-codex.2026-09-07T19-51.md`.

## (a) `validate-bash-trigger-scoping.Tests.ps1`

```
tests="8" errors="0" failures="0"
```

`tests` **8**, `failures` **0**, `errors` **0**.

| It name | status |
|---|---|
| `R1-X1 denies rm -rf carried inside a bash -c quoted argument` | Passed |
| `R1-X2 denies git reset --hard carried inside an sh -c quoted argument` | Passed |
| `R1-X3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument` | Passed |
| `R1-X4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led` | Passed |
| `R1-X5 denies rm -rf carried inside an unterminated quoted span` | Passed |
| `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force` | Passed |
| `AT-9 denies a relocating git push --force carrying a directory global option` | Passed |
| `AT-10 allows a commit message that quotes a dangerous pattern in prose` | Passed |

All five new cases pass and all three pre-existing AT cases pass. `R1-X5` passing is the Codex-side
evidence that the third disjunct (`$segment.Unbalanced`) is present and effective; it failed against
the same tree before the edit. `R1-X4` and AT-8 still passing are the evidence the fix is not
over-broad in either of the two distinct over-broad shapes.

## (b) `validate-bash-decision-surface.Tests.ps1` and the leg-ordering assertion

```
tests="37" errors="0" failures="0"
```

`tests` **37**, `failures` **0**.

Case `returns the four-token git push origin --force literal ahead of any structural value` carries
`status="Passed"`.

That case is the Codex-side leg-ordering assertion. At
`tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1` line 130 it asserts:

```powershell
Get-BlockedPatternMatch -Command 'git push origin --force' |
    Should -Be 'git push origin --force'
```

Its passing confirms leg 1 is still evaluated in full, over every literal and every segment, before
any leg 2 evaluation on the Codex side as well: the command returns the leg-1 literal
`git push origin --force` rather than leg 2's structural `git push --force`.

## (c) Chained-segment case

Case `matches a literal carried on the second segment of a chained command` carries
`status="Passed"`.

## (d) Complete folder-wide failing set

| # | Suite file | Case name | Classification |
|---|---|---|---|
| 1 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` | row 2 of the plan preamble's tolerated-failures table |

That is the only case in the whole `tests/scripts/codex-hooks` folder carrying `status="Failed"`.
This suite is not modified by this plan; it is an ambient-state failure driven by a gitignored
checkpoint under `artifacts/` and is green on a clean CI checkout.

Output Summary: Codex-side R-1 fix confirmed. `validate-bash-trigger-scoping.Tests.ps1` 8 tests, 0
failures, 0 errors with all five R1-X cases and all three AT cases passing;
`validate-bash-decision-surface.Tests.ps1` 37 tests, 0 failures with the leg-ordering case and the
chained-segment case both passing; folder-wide the only failure is the single tolerated ambient case.
