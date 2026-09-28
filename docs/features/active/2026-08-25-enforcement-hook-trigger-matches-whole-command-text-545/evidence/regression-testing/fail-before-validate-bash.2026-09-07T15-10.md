# Fail-before — `validate-bash.TriggerScoping.Tests.ps1` against the unfixed hook (issue #545)

Timestamp: 2026-09-07T15-10

Task: [P10-T2] `[expect-fail]`

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session because
`pwsh`, `powershell`, and `cmd` cannot be invoked from any context here. Per-suite and per-case
results, including each failure message, were read out of `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 5

ExpectedExitCode: 1

The exit code the MCP runner reports is the folder-wide failed-test count rather than a plain 1. Of
those 5, **4** belong to the suite this task drives and 1 is the documented pre-existing
`enforce-pr-author-skill.Tests.ps1` failure. The declared expectation of 1 records that a non-zero,
failing outcome is the intended result of this task; the observed value is non-zero as required.

## Suite result — before [P10-T3]

`tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`: **5 tests, 4 failures, 0 errors,
0 skipped.**

| # | `It` name | Result | Observed failure message |
| --- | --- | --- | --- |
| 1 | `AT-8 allows git push --force-with-lease because --force-with-lease is not the token --force` | **FAIL** | `Expected $null or empty, but got 'git push --force'.` |
| 2 | `AT-9 denies a relocating git push --force carrying a directory global option` | **FAIL** | `Expected 'git push --force', but got $null.` |
| 3 | `AT-10 allows a commit message that quotes a dangerous pattern in prose` | **FAIL** | `Expected $null or empty, but got 'rm -rf'.` |
| 4 | `allows a commit message whose quoted text contains a cd-then-read phrase` | **FAIL** | `Expected $null or empty, but got 'Forbidden Bash pattern: 'cd ... && cat' (or ';'-chained). ...'` |
| 5 | `still denies a read command that is not adjacent to the cd segment` | **PASS** | n/a |

Case 5 passing is the intended outcome, not an omission. It is a **preservation pin**: the current
`$script:CdChainedReadCommandPattern` places a lazy `.*?` between the `cd` argument and the
delimiter, so `cd /tmp/x && npm test && grep -n test file.txt` is denied today even though the `grep`
segment is not adjacent to the `cd` segment. Requiring adjacency after [P10-T3] would turn that
existing denial into an allow, which acceptance criterion 9 forbids. The plan states this explicitly
in [P10-T1]: the case is expected to PASS against the unfixed hook.

The four failures are two distinct defects, one in each direction:

- Cases 1 and 3 are **over-match**: `$Command.Contains($pattern)` treats `--force-with-lease` as
  containing `--force`, and treats a quoted commit message mentioning `rm -rf` as a forced deletion.
- Case 2 is **under-match**: `git -C ../wt push --force origin HEAD` is a real forced push, but no
  denylist literal occurs as a substring of it, so the hook allows it today.
- Case 4 is **over-match** on the `cd`-chain leg: the phrase exists only inside a quoted span, and
  the regex is evaluated against the unsegmented, unmasked command string.

## Existing suite state in the same run

`tests/scripts/claude-hooks/validate-bash.Tests.ps1`: **26 tests, 0 failures.** Both named
assertions this change must preserve pass at this point, before the fix:
`returns the matched pattern for every repository-dangerous command` and
`matches every read-command family chained after cd via '&&' or ';'`. They are re-checked after
[P10-T3] under [P10-T6].

## Known-red inventory update performed by this task

The four failing names above were appended to the [P1-T13] known-red inventory artifact
`evidence/regression-testing/known-red-inventory.2026-09-07T11-53.md` as rows 35 through 38, each
carrying **phase 10** as the closing phase and [P10-T3] as the closing task. Before this task the
inventory stood at **0 of 34 rows remaining** (rows 2 and 4 closed at [P9-T11]); it now stands at
**4 of 38 rows remaining**, all four closing within this same phase.

Output Summary: fail-before captured as required. The suite reports **5 tests / 4 failures** against
the unfixed hook, with a non-zero exit code. The four failing cases are AT-8, AT-9, AT-10, and the
quoted `cd`-chain over-match case; each failure message is recorded verbatim above. The fifth case,
`still denies a read command that is not adjacent to the cd segment`, **passes** and is expected to,
because it pins existing non-adjacent reach that acceptance criterion 9 forbids narrowing. The
existing `validate-bash.Tests.ps1` suite is green at 26 tests / 0 failures. The four failing names
were appended to the known-red inventory with phase 10 recorded as the closing phase.
