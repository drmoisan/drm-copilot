# Phase 0 — Targeted Pester Baseline ([P0-T6])

Timestamp: 2026-09-07T19-36
Task: [P0-T6]
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and `scan_folders` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]`, then read `artifacts/pester/pester-junit.xml`
EXIT_CODE: 2
ExpectedExitCode: 2

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context; the runtime guard refuses them, so a direct `pwsh -NoProfile -Command "Invoke-Pester ..."`
call cannot be made. Pester is therefore invoked through the `mcp__drm-copilot__run_poshqc_test` MCP
function with folder-scoped `scan_folders`, and per-suite and per-case results are read from the
JUnit report the run writes to `artifacts/pester/pester-junit.xml`. Route substitution, not a
skipped stage.

The tool's observed exit code is the folder-wide failed-test count, which is 2 because of the two
pre-existing ambient failures recorded below. Acceptance is therefore stated on per-suite
`<testsuite>` counts and per-case `status` attributes, never on the tool's exit code.

## Per-suite results for the four `validate-bash` suites

| Suite file | tests | failures | errors | skipped | Expected tests | Expected failures | Match |
|---|---|---|---|---|---|---|---|
| `tests/scripts/claude-hooks/validate-bash.Tests.ps1` | 26 | 0 | 0 | 0 | 26 | 0 | yes |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 7 | 0 | 0 | 0 | 7 | 0 | yes |
| `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1` | 37 | 0 | 0 | 0 | 37 | 0 | yes |
| `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | 3 | 0 | 0 | 0 | 3 | 0 | yes |

Raw `<testsuite>` attributes as read (paths abbreviated to the repository-relative form):

```
validate-bash.Tests.ps1                     tests="26" errors="0" failures="0" skipped="0" id="50"
validate-bash.TriggerScoping.Tests.ps1      tests="7"  errors="0" failures="0" skipped="0" id="51"
validate-bash-decision-surface.Tests.ps1    tests="37" errors="0" failures="0" skipped="0" id="97"
validate-bash-trigger-scoping.Tests.ps1     tests="3"  errors="0" failures="0" skipped="0" id="98"
```

## Folder-wide totals

| Folder | tests | errors | failures |
|---|---|---|---|
| `tests/scripts/claude-hooks` | 1520 | 0 | 1 |
| `tests/scripts/codex-hooks` | 851 | 0 | 1 |

## Every failing case, named

Complete set of cases carrying `status="Failed"` across both folders, read from the JUnit report:

| # | Suite file | Case name | Tolerated |
|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | yes — row 1 of the plan preamble's tolerated-failures table |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` | yes — row 2 of the plan preamble's tolerated-failures table |

The failing case set is exactly the two tolerated rows. No failure outside that set exists, so
Phase 1 is not blocked. Neither suite is modified by this plan and neither reproduces on a clean CI
checkout; both are ambient-state failures caused by gitignored files under `artifacts/`.

Output Summary: Targeted Pester baseline green for all four `validate-bash` suites at the expected
counts (26/0, 7/0, 37/0, 3/0). Folder-wide failures 1 + 1 = 2, both tolerated pre-existing ambient
failures, exactly matching the tool's exit code of 2. Coverage headline carried from `[P0-T7]`:
`.claude/hooks/validate-bash.ps1` **94.3182** percent and `.codex/hooks/validate-bash.ps1`
**100.0000** percent line coverage, both from CI run `34145103168` of
`.github/workflows/_poshqc.yml`; no coverage figure was taken from this MCP run.
