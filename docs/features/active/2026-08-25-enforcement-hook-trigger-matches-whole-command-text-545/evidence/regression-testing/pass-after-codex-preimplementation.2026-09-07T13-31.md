# Pass-after: Codex preimplementation gate, two suites (issue #545)

Timestamp: 2026-09-07T13-31

Task: [P5-T7]

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `pwsh -NoProfile -Command "Invoke-Pester -Path <suite> -Output Detailed"` form, because
`pwsh`, `powershell`, and `cmd` are not invocable in this session; the runtime worktree-isolation
guard refuses them unconditionally. Per-suite and per-test results were read out of
`artifacts/pester/pester-junit.xml`. Per the [P0-T10] schema record the `testsuite` element carries
no `passed` attribute, so every passed count below is derived as
`tests - failures - errors - skipped`.

## Suite 1 — `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 0 (suite-scoped: 0 failures and 0 errors for this suite)

| Measure | Value |
| --- | --- |
| tests | 23 |
| failures | **0** |
| errors | 0 |
| skipped | 0 |
| passed (derived) | **23** |

The 23 cases are the 19 that mirror the Claude side — five over-match allow cases, six under-match
deny cases, the non-classifying stop case, and seven wrapper deny pins — plus the four Codex-only
`apply_patch` marker-leg assertions. All four marker-leg cases pass, which is the measured evidence
that the two marker legs upstream of the pattern loop are unaffected by this change.

Inventory rows 20 through 32, all thirteen of them, are now green.

## Suite 2 — `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: 0 (suite-scoped: 0 failures and 0 errors for this suite)

| Measure | Value |
| --- | --- |
| tests | 59 |
| failures | **0** |
| errors | 0 |
| skipped | 0 |
| passed (derived) | **59** |

Inventory row 34, `denies a message-body payload that merely contains the staging literal`, is the
Codex half of the single intended assertion reversal and is now green. Every other denial assertion
in this suite still passes unmodified.

## Adjacent suites observed in the same run

| Suite | tests | failures |
| --- | --- | --- |
| `codex-preimplementation-gate-absolute-paths.Tests.ps1` | 35 | 0 |
| `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 55 | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 |

`legacy-codex-hook-contracts.Tests.ps1` is the suite that enforces the 500-line cap and the
root-versus-bundle SHA-256 byte-identity of every Codex hook, at line 106
(`(Get-Content -LiteralPath $path).Count | Should -BeLessOrEqual 500`). Its passing is an independent
confirmation that the edited Codex gate is at or under 500 lines and that the [P5-T6] mirror is
byte-identical. It also drives every Codex hook as a child process, so it confirms the two new
dot-source lines resolve at run time from `.codex/hooks/`.

## Folder-wide reconciliation

`tests/scripts/codex-hooks`: **731 tests, 1 failure, 0 errors** — down from **15** at the batch B5
gate.

| Source of failure | Count | Status |
| --- | --- | --- |
| `codex-pretooluse-integration.Tests.ps1` — `allows every registered handler for every tool name its own matcher admits` | 1 | pre-existing at baseline, recorded in the known-red inventory appendix; caused by `enforce-epic-wave-barrier.ps1` reading the live epic checkpoint, which names item `545` with unmerged `depends_on` edges. Ambient-state dependent, out of inventory and out of scope. |

The drop from 15 to 1 is exactly the fourteen Codex-side inventory rows this task closes: rows 20
through 32 from the trigger-scoping suite and row 34 from the command-exemption suite.

Output Summary: both named suites report **zero failed tests**, with derived passed counts of **23**
and **59**. Fourteen known-red inventory rows are closed. The single remaining folder-wide failure is
the documented pre-existing, ambient-state-dependent case in `codex-pretooluse-integration.Tests.ps1`.
