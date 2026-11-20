# Fail-Before — R-1 reproduced on the Codex side ([P2-T3], `[expect-fail]`)

Timestamp: 2026-09-07T19-51
Task: [P2-T3] `[expect-fail]`
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and `scan_folders` = `["tests/scripts/codex-hooks"]`, then read `artifacts/pester/pester-junit.xml`
EXIT_CODE: 5
ExpectedExitCode: 5

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context. Pester is invoked through the `mcp__drm-copilot__run_poshqc_test` MCP function with
`scan_folders`, with per-suite and per-case results read from `artifacts/pester/pester-junit.xml`.
Route substitution, not a skipped stage. The observed exit code equals the folder-wide failed-test
count: the four deliberately failing new cases plus the one tolerated pre-existing ambient failure.

## State of the tree at this run

`tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` carries the five new `It` blocks
appended by `[P2-T2]`. `.codex/hooks/validate-bash.ps1` is UNMODIFIED — the R-1 edit of `[P2-T4]`
has not been applied.

## `<testsuite>` for `validate-bash-trigger-scoping.Tests.ps1`

```
tests="8" errors="0" failures="4"
```

`tests` is **8** and `failures` is **4**, as the task requires.

## Per-case `status` for all eight cases in that suite

| # | It name | status | Expected here |
|---|---|---|---|
| 1 | `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force` | Passed | Passed |
| 2 | `AT-9 denies a relocating git push --force carrying a directory global option` | Passed | Passed |
| 3 | `AT-10 allows a commit message that quotes a dangerous pattern in prose` | Passed | Passed |
| 4 | `R1-X1 denies rm -rf carried inside a bash -c quoted argument` | **Failed** | Failed |
| 5 | `R1-X2 denies git reset --hard carried inside an sh -c quoted argument` | **Failed** | Failed |
| 6 | `R1-X3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument` | **Failed** | Failed |
| 7 | `R1-X4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led` | Passed | Passed |
| 8 | `R1-X5 denies rm -rf carried inside an unterminated quoted span` | **Failed** | Failed |

The four cases carrying `status="Failed"` are exactly `R1-X1`, `R1-X2`, `R1-X3`, and `R1-X5`.
`R1-X4` carries `status="Passed"`. All three pre-existing AT cases carry `status="Passed"`.

`R1-X5` is the Codex-side reproduction of the `Unbalanced` weakening. It failed, so the third
disjunct is not already present and the D6 correction is necessary; a pass here would have blocked
the phase pending re-derivation.

## Folder-wide failing set

| # | Suite file | Case name | Classification |
|---|---|---|---|
| 1 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` | tolerated pre-existing ambient failure, row 2 of the plan preamble table |
| 2-5 | `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | `R1-X1`, `R1-X2`, `R1-X3`, `R1-X5` | deliberate `[expect-fail]` reproductions |

No other case in the folder failed.

Output Summary: R-1 reproduced on the Codex side. `validate-bash-trigger-scoping.Tests.ps1` reports
tests 8, failures 4, errors 0; the four failures are exactly `R1-X1`, `R1-X2`, `R1-X3`, `R1-X5`;
`R1-X4` and all three pre-existing AT cases pass. Folder-wide failed count 5, matching the tool's
exit code. The defect is reproduced, so `[P2-T4]` proceeds.
