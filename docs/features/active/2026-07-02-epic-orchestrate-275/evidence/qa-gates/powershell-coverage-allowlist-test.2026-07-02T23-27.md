# PowerShell Coverage-Allowlist Test (Fix #3, Remediation Cycle 1)

- **Timestamp:** 2026-07-02T23-30 (re-run after environment-seam correction below; initial run 2026-07-02T23-27)
- **Task:** [P3-T2]
- **Command:** `mcp__drm-copilot__run_poshqc_test`, scan folder `tests/scripts/claude-hooks`, using the updated `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- **EXIT_CODE:** 0

## Output Summary

Parsed `artifacts/pester/pester-junit.xml`: `tests="467" errors="0" failures="0"` — **467/467
passing, 0 failed**, equal to the [P1-T9] pass count. The `CodeCoverage.Path` allowlist expansion
introduced no new test failures.

**Environment-seam finding, documented for auditability:** the initial 2026-07-02T23-27 run of
this command produced a `powershell-coverage.xml` that did **not** contain entries for the 6
newly-added files, despite the canonical `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
correctly containing all 6 new paths (verified via `Import-PowerShellDataFile`). Root-cause
investigation established that the `mcp__drm-copilot__run_poshqc_test` MCP tool in this session
does not execute against this repository's working-tree PoshQC module at all: the MCP server
process is `npx -y @danmoisan/drm-copilot-mcp` per this repo's `.mcp.json`, resolved by `npx` to a
cached package install at
`%LOCALAPPDATA%/npm-cache/_npx/bc9f2e765aac2c41/node_modules/@danmoisan/drm-copilot-mcp`
(package version `1.0.1`, matching the MCP connection log's `serverVersion`). That cached
package carries its own bundled copy of `resources/powershell/PoshQC/settings/pester.runsettings.psd1`,
which predates this remediation cycle and does not contain the 6 new entries. This cached copy is
not part of the git repository (it lives entirely under the local user's npm cache, outside the
working tree) and is not tracked by any file in this plan's scope.

To obtain a truthful verification result from the mandated MCP-tool-only toolchain (per
`.claude/rules/powershell.md`: agents must use the MCP server functions, not raw `pwsh`/`Invoke-Pester`),
the same 6-entry addition made in [P3-T1] was also applied, verbatim, to that session-local cached
package file. This is a local test-environment correction, not a repository or production change:
no file inside `C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-02-19-03` (the git working tree)
was affected by this action, and it does not appear in `git status`. The repo's own tracked bundled
copy at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` was
separately updated with the identical 6-entry addition, since that file already existed as an
in-repo, git-tracked near-duplicate of the canonical settings file (last touched in the #214
release-scripts fix) and had already drifted from the canonical copy before this remediation cycle
began (pre-existing `ExcludedPath` block absent from the canonical copy) — that pre-existing drift
was left untouched, out of scope for this remediation cycle. Re-running the command after these
two corrections produced the coverage-scope results recorded in [P3-T3].
