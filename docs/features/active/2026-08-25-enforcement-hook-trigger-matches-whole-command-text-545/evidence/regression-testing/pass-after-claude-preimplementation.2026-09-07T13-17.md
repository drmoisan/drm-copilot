# Pass-after: Claude preimplementation gate, three suites (issue #545)

Timestamp: 2026-09-07T13-17

Task: [P5-T3]

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `pwsh -NoProfile -Command "Invoke-Pester -Path <suite> -Output Detailed"` form, because
`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime worktree-isolation
guard refuses them unconditionally. Per-suite and per-test results were read out of
`artifacts/pester/pester-junit.xml`, whose schema was recorded verbatim by [P0-T10]: the
`testsuite` element carries `tests`, `failures`, `errors`, and `skipped` but **no `passed`
attribute**, so every passed count below is derived as `tests - failures - errors - skipped`.

## Suite 1 — `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 0 (suite-scoped: 0 failures and 0 errors for this suite)

| Measure | Value |
| --- | --- |
| tests | 19 |
| failures | **0** |
| errors | 0 |
| skipped | 0 |
| passed (derived) | **19** |

This suite is new in [P1-T4], so it has no [P0-T10] baseline passed count. All thirteen of its
known-red inventory rows (rows 7 through 19) are now green.

Output Summary: 19 tests, 0 failures. The five over-match allow cases, the six under-match deny
cases, the non-classifying stop case, and all seven wrapper deny pins pass.

## Suite 2 — `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 0 (suite-scoped: 0 failures and 0 errors for this suite)

| Measure | Value |
| --- | --- |
| tests | 59 |
| failures | **0** |
| errors | 0 |
| skipped | 0 |
| passed (derived) | **59** |
| [P0-T10] baseline passed count | 58 |
| At or above baseline? | **yes** (59 >= 58) |

The count rose by one because [P1-T10] added the paired deny case
`denies the same heredoc body when it feeds a shell wrapper instead of a file`. Inventory row 33,
`denies a message-body payload that merely contains the staging literal`, is the single intended
assertion reversal and is now green: its expected decision changed from deny to allow and the hook
now returns allow, because `cat` is not a member of the wrapper carve-out set so its heredoc body is
masked. Case-name census of the 59 cases in this suite: 51 carry an `It` name beginning `denies` and
8 begin `allows`. One of the 51 is the reversal above, whose `It` name still reads `denies ...` while
its assertion is now `allow`, so **50** cases assert a denial and all 50 pass unmodified. That is the
evidence that no existing denial was weakened.

## Suite 3 — `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 0 (suite-scoped: 0 failures and 0 errors for this suite)

| Measure | Value |
| --- | --- |
| tests | 35 |
| failures | **0** |
| errors | 0 |
| skipped | 0 |
| passed (derived) | **35** |
| [P0-T10] baseline passed count | 35 |
| At or above baseline? | **yes** (equal) |

The three command-payload cases in this suite are unchanged and still deny:
`blocks implementation command payloads before readiness`, `blocks staging and commit command
payloads before readiness`, and `blocks formatter and test command payloads before readiness`. The
last of those carries the `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"`
fixture, which is the same wrapper deny pin as AT-6.

## Adjacent suites observed in the same run

Recorded so the folder-wide numbers reconcile. None is an acceptance condition of this task.

| Suite | tests | failures |
| --- | --- | --- |
| `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 33 | 0 |
| `enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | 7 | 0 |
| `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 87 | 0 |

The classifier and absolute-path suites exercise `Test-ImplementationPath` and the checkpoint-literal
membership check, which this change does not touch; both stay green.

## Folder-wide reconciliation

`tests/scripts/claude-hooks`: **1465 tests, 7 failures, 0 errors**.

| Source of failure | Count | Status |
| --- | --- | --- |
| `hook-command-parser.AcceptanceCases.Tests.ps1` — AT-1, AT-2, AT-3, AT-4, AT-5, AT-7 | 6 | known-red inventory rows 1 through 6; closed by Phases 6, 8, and 9 |
| `enforce-pr-author-skill.Tests.ps1` — `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | 1 | pre-existing at baseline, recorded in the known-red inventory appendix; out of inventory and out of scope for this task |

6 + 1 = 7. Every Claude-side inventory row that Phase 5 owns is closed: rows 7 through 19 from the
trigger-scoping suite and row 33 from the command-exemption suite, fourteen rows in total. The prior
folder-wide failure count was 21 (14 Phase-5 rows + 6 acceptance rows + 1 pre-existing).

Output Summary: all three named suites report **zero failed tests**. Passed counts are 19, 59, and 35
respectively; the two pre-existing suites are at or above their [P0-T10] baselines (59 >= 58 and
35 = 35). Fourteen known-red inventory rows are closed by this task. The seven remaining folder-wide
failures are the six acceptance-case rows closed by later phases plus one pre-existing baseline
failure.
