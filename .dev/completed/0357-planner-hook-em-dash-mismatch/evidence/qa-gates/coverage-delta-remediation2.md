# Coverage Delta — Baseline vs. Post-Change (Issue #357, Remediation Cycle 2)

**Timestamp:** 2026-07-17T16-30

## Starting state (this cycle)

From `evidence/remediation-baseline/poshqc-test-baseline-remediation2.md`: 73.72% ad hoc line coverage (115/156 commands), canonical `artifacts/pester/powershell-coverage.xml` absent for `.claude/hooks/validate-planner-output.ps1`.

## Post-change state (this cycle)

**Canonical artifact:** Still absent for this file (`evidence/qa-gates/coverage-xml-post-check-remediation2.md`; `grep -n "sourcefilename=\"validate-planner-output" artifacts/pester/powershell-coverage.xml` returns zero matches). This is unchanged from the cycle-start state, despite this cycle's settings-file edit and 14 new covering tests.

**Root cause of the canonical artifact's continued absence (newly discovered this cycle, superseding the shallower root cause stated in `remediation-inputs.2026-07-17T16-00.md`):** `mcp__drm-copilot__run_poshqc_test` is served by the MCP server process launched via `.mcp.json`'s `"command": "npx", "args": ["-y", "@danmoisan/drm-copilot-mcp"]` entry. This resolves and runs a separately npm-published package, cached under the local npx cache, entirely independent of this workspace's `extensions/drm-copilot/` source tree. Confirmed by direct inspection of two locally cached package versions (`1.0.0` and `1.0.16`), whose own `resources/powershell/PoshQC/settings/pester.runsettings.psd1` copies both lack the `.claude/hooks/validate-planner-output.ps1` allowlist entry, and by the fact that this cycle's edit to the workspace's `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` file (verified present and byte-identical to the `scripts/` copy — see `evidence/qa-gates/settings-diff-post-remediation2.md`) produced no change in the canonical artifact's coverage of this file. Editing either workspace copy of the settings file cannot reach the MCP tool's actual runtime settings resolution.

**Best-available real measurement (ad hoc, non-repo-modifying `Invoke-Pester -Configuration` run, `CodeCoverage.OutputPath` explicitly directed to the session scratchpad, not to any tracked file):** **94.23%** line coverage (147 of 156 analyzed commands), 21/21 tests passed.

**Numeric delta (ad hoc measurement): +20.51 percentage points (73.72% -> 94.23%; 32 additional commands covered, 115 -> 147 of 156).**

Coverage status of previously-uncovered lines targeted by this cycle's Phase 1 tests (from `evidence/qa-gates/coverage-delta-remediation1.md`'s remaining-uncovered list: 45, 46, 49, 50, 51, 53, 54, 57, 75, 78, 81, 162, 176, 180, 184, 200, 209, 212, 217, 223, 244, 252, 261, 282, 283, 284, 285, 288): all lines are now covered except 51, 54 (both inside `Get-PlanFileContent`'s null-result and non-array-result branch bodies — this cycle's P1-T2/P1-T3 tests exercise the not-exists and multi-line-exists paths exactly as their task text specifies, which does not reach these two branch bodies), 217 (documented dead-code ternary null-arm, out of scope per this cycle's exclusion clause), and 282, 283, 284, 285, 288 (top-level script-invocation lines, out of scope per this cycle's exclusion clause; covering them requires subprocess execution prohibited by the external-process restriction in `.claude/rules/general-unit-test.md`).

## Explicit pass/fail statement against the 85% uniform line-coverage threshold in `.claude/rules/quality-tiers.md`

**Ad hoc real-code measurement: PASS** (94.23% >= 85%, verified via a non-repo-modifying `Invoke-Pester` run with explicit `CodeCoverage.Path` scoped to this one file).

**Canonical-artifact measurement: FAIL / UNVERIFIABLE within this cycle's authorized change budget.** The canonical `artifacts/pester/powershell-coverage.xml` still reports zero coverage entries for this file, because the MCP tool that produces it resolves its settings from a separately npm-published, npx-cached package outside this workspace, not from either in-repo copy of `pester.runsettings.psd1`. Remediating this would require either (a) publishing a new version of `@danmoisan/drm-copilot-mcp` that includes the new allowlist entry and having the MCP client re-resolve `npx -y @danmoisan/drm-copilot-mcp` against that new version, or (b) pinning/reconfiguring `.mcp.json` to run the workspace's own `extensions/drm-copilot` build instead of the npm-published package — both of which are outside this cycle's authorized change budget (`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, `.claude/hooks/validate-planner-output.ps1`) and are not addressed by this plan. Per the "Do Not Do" list in `remediation-inputs.2026-07-17T16-00.md`, AC 4 in `issue.md` is NOT claimed as fully satisfied; this finding is escalated for the orchestrator/feature-review to triage (likely requiring either a package republish or an `.mcp.json` reconfiguration decision, both outside atomic-executor's authority).

## Branch coverage

Not evaluated for delta purposes. The ad hoc run confirms (again) that Pester 5.6.1's built-in code-coverage engine emits no `BRANCH` JaCoCo counter for any file in this repository's toolchain configuration; this is an accepted, previously documented tooling limitation (see `.claude/agent-memory/atomic-executor/project_powershell_coverage_gotchas.md`), not a regression introduced or resolved by this cycle.
