# R2 CR-R1 Fail-Before Run (issue #935, remediation cycle 2) [expect-fail]

Timestamp: 2026-10-16T09-20
Task: [P1-T3]
Command: MCP `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = worktree root and `scan_folders` = `["tests/scripts/claude-hooks"]`
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- Call disposition: raised. Error text: `Command exited with code 2.`
- State at run time: P1-T1 and P1-T2 edits applied to `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`; `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` unchanged from HEAD `0ca099348`.

Code path:
- Rows 7 and 8 of `Describe 'issue #935 CR-R1 separate-value edge cases'` (`common parameter -ErrorAction followed by its value`, `common parameter -OutVariable followed by its value`) are the expected failures. `Test-EpicStateIsolationSeparateValue` returns `$true` only when the parameter name is in `$valueParameter`; `ErrorAction` and `OutVariable` are absent from that list, so both rows receive `$false` where they expect `$true`.
- Rows 1 to 6 are expected to pass: rows 1 to 5 pin the current boundary behaviour (last element, following parameter, attached argument, abbreviated name, non-parameter element) and row 6 (`-Prefix Pre`) is the positive control, `Prefix` being in the list.
- The only changes since the green P0-T8 run (`FEATURE/evidence/baseline/r2-ps-test.2026-10-16T09-12.md`) are the P1-T1 and P1-T2 test-file edits.
- The process exit code 2 is consistent with two failing rows; per the MCP observation rule this is not read as a row count, and per-row results come from CI.

Cited line (derived at task time):
- Command: `grep -n -F -e "'WorkingDirectory'" tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`
- Output (one line): `58:        'RedirectStandardOutput', 'RequiredVersion', 'Scope', 'Variable', 'Verb', 'WindowStyle', 'WorkingDirectory'` — the last line of the `$valueParameter` list, which ends without any common parameter.

Acceptance: the call raised and `EXIT_CODE: 1` is recorded; the `grep -n` printed exactly one line and it is cited above. PASS.
