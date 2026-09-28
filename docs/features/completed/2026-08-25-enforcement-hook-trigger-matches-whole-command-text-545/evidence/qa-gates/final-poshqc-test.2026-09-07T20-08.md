# Final QA — Test Stage ([P4-T4])

Timestamp: 2026-09-07T20-08
Task: [P4-T4]
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and `scan_folders` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]`, then read `artifacts/pester/pester-junit.xml`
EXIT_CODE: 2
ExpectedExitCode: 2

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context; the runtime guard refuses them, so a direct `pwsh -NoProfile -Command "Invoke-Pester ..."`
call cannot be made. Pester is invoked through the `mcp__drm-copilot__run_poshqc_test` MCP function
with folder-scoped `scan_folders`, and every value asserted below is read from a `<testsuite>`
element or a `status` attribute in `artifacts/pester/pester-junit.xml`, never from the tool's exit
code. Route substitution, not a skipped stage.

## (f) Single-pass declaration

**Stages 1 through 3 of Phase 4 — `[P4-T2]` format, `[P4-T3]` analyze, `[P4-T4]` test — completed
in a single pass with NO RESTART.** Format left every in-scope SHA-256 unchanged with a porcelain
set difference of 0, analyze returned `ok: true` equal to its baseline, and this test stage carries
no failure outside the two tolerated cases.

The observed exit code is 2, the folder-wide failed-test count across both scanned folders, which is
exactly the two tolerated ambient failures. `ExpectedExitCode` is recorded equal to that value.

## (a) `validate-bash.Tests.ps1`

```
tests="26" errors="0" failures="0"
```

`tests` **26**, `failures` **0**, `errors` **0**.

## (b) `validate-bash.TriggerScoping.Tests.ps1`

```
tests="12" errors="0" failures="0"
```

`tests` **12**, `failures` **0**, `errors` **0**.

| It name | status |
|---|---|
| `R1-C1 denies rm -rf carried inside a bash -c quoted argument` | Passed |
| `R1-C2 denies git reset --hard carried inside an sh -c quoted argument` | Passed |
| `R1-C3 denies Remove-Item -Recurse -Force carried inside a pwsh -Command quoted argument` | Passed |
| `R1-C4 allows a commit message quoting Remove-Item -Recurse -Force because that segment is not wrapper-led` | Passed |
| `R1-C5 denies rm -rf carried inside an unterminated quoted span` | Passed |

Count of `R1-C` cases carrying `status="Passed"`: **5 of 5**.

## (c) `validate-bash-decision-surface.Tests.ps1`

```
tests="37" errors="0" failures="0"
```

`tests` **37**, `failures` **0**, `errors` **0**.

## (d) `validate-bash-trigger-scoping.Tests.ps1`

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

Count of `R1-X` cases carrying `status="Passed"`: **5 of 5**.

## (e) Complete set of cases carrying `status="Failed"` across both folders

| # | Suite file | It name | Tolerated-table row |
|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | row 1 |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` | row 2 |

The failing set is **exactly** the two rows of the plan preamble's tolerated-failures table, and
nothing else. Neither suite is modified by this plan; both are ambient-state failures caused by
gitignored files under `artifacts/` and both are green on a clean CI checkout. No failure outside
that set exists, so Phase 4 does not restart at `[P4-T2]`.

## Folder-wide totals

| Folder | tests | errors | failures |
|---|---|---|---|
| `tests/scripts/claude-hooks` | 1525 | 0 | 1 |
| `tests/scripts/codex-hooks` | 856 | 0 | 1 |

The claude-hooks total rose from the `[P0-T6]` baseline of 1520 to 1525 and the codex-hooks total
from 851 to 856, in both cases by exactly the five cases this cycle added on that side. No case was
removed or renamed.

Output Summary: Final test stage green on all four `validate-bash` suites at the required counts —
26/0/0, 12/0/0, 37/0/0, 8/0/0 — with all ten new pinning cases (`R1-C1`-`R1-C5` and
`R1-X1`-`R1-X5`) carrying `status="Passed"`. Across both folders the complete failing set is the two
tolerated pre-existing ambient cases, matching the tool's exit code of 2. Phase 4 stages 1 through 3
completed in a single pass with no restart.
