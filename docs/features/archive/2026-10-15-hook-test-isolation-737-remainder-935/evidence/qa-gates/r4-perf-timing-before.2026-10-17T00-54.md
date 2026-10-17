# R4 PERF-5 Baseline Before Any Perf Edit (P4-T1, issue #935)

Timestamp: 2026-10-17T00-54
Command:
- `git rev-parse HEAD`
- `stat -c %y artifacts/pester/pester-junit.xml` (pre and post)
- mcp__drm-copilot__run_poshqc_test (workspace_root = worktree root, scan_folders = ["tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1"])
- D-JUNIT-PERF (1): `awk '/<testsuite / && /EpicStateIsolation[.]Discovery[.]Tests[.]ps1"/ { t = $0; sub(/.* time="/, "", t); sub(/".*/, "", t); n++; print "JUNIT_SUITE_TIME_S=" t } END { print "JUNIT_SUITE_LINES=" n + 0 }' artifacts/pester/pester-junit.xml`
- D-JUNIT-PERF (2): `awk '/<testcase / && /EpicStateIsolation[.]Discovery[.]Tests[.]ps1"/ { total++; n = $0; sub(/.* name="/, "", n); if (index(n, "issue #935 PERF memo.") != 1) names++ } END { printf "JUNIT_TOTAL=%d JUNIT_NAMES=%d\n", total, names }' artifacts/pester/pester-junit.xml`
- D-JUNIT-PERF (3): `awk '/<testcase / && /EpicStateIsolation[.]Discovery[.]Tests[.]ps1"/ { n = $0; sub(/.* name="/, "", n); sub(/" status=.*/, "", n); if (index(n, "issue #935 PERF memo.") != 1) print n }' artifacts/pester/pester-junit.xml | LC_ALL=C sort | sha256sum`
- D-PERF-TIME (verbatim): `pwsh -NoProfile -NonInteractive -Command 'Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop; $c = New-PesterConfiguration; $c.Run.Path = @("tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1"); $c.Run.PassThru = $true; $c.CodeCoverage.Enabled = $false; $c.TestResult.Enabled = $false; $c.Output.Verbosity = "None"; $sw = [System.Diagnostics.Stopwatch]::StartNew(); $r = Invoke-Pester -Configuration $c; $sw.Stop(); $names = @($r.Tests | ForEach-Object { $_.ExpandedPath } | Where-Object { -not $_.StartsWith("issue #935 PERF memo.") } | Sort-Object -CaseSensitive); "PESTER=" + (Get-Module Pester).Version; "RESULT=" + $r.Result + " TOTAL=" + $r.TotalCount + " PASSED=" + $r.PassedCount + " FAILED=" + $r.FailedCount; "WALL_S=" + $sw.Elapsed.TotalSeconds.ToString("F2") + " DISCOVERY_S=" + $r.DiscoveryDuration.TotalSeconds.ToString("F2"); "NAMES=" + $names.Count + " NAMES_SHA256=" + [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($names -join [char]10))); foreach ($t in @($r.Tests | Sort-Object -Property Duration -Descending | Select-Object -First 10)) { "SLOW: " + $t.Duration.TotalSeconds.ToString("F2") + " " + $t.ExpandedPath }'`
EXIT_CODE: 0

PERF-BEFORE-HEAD: 306c798de76f203388a2aa1b210a7cc763a42849

Output Summary:
- MCP call disposition: returned (`ok: true`).
- `stat -c %y artifacts/pester/pester-junit.xml` pre: `2026-10-16 20:45:04.549878700 -0400`; post: `2026-10-16 20:54:00.975145600 -0400` (differ).
- D-JUNIT-PERF output (local, MCP runner, coverage enabled; relative figure only):
  - `JUNIT_SUITE_TIME_S=222.758`
  - `JUNIT_SUITE_LINES=1`
  - `JUNIT_TOTAL=365 JUNIT_NAMES=365`
  - hash (first field of `sha256sum`): `e79dd6123d5425e215d74092988bf36bd53b88a84c469b0bf6c420009ae71e14`
- D-PERF-TIME (local, Pester run directly, coverage disabled; not comparable with CI): the command did not run (refused before execution; it exited no code of its own). Authorized skip branch of the scoped direct-Pester exception; orchestrator note (7) applies.

PERF-TIMING-REFUSED: This agent is isolated in the worktree <worktree root>, but this command runs pwsh in a plain command; what it reads or is handed as shell text cannot be shown not to run git. Refusing to run it — a worktree-isolated agent's git operations must target its own worktree. Run the plain command from <worktree root>.
