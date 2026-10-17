# Targeted Run: HostTooling (Issue #847)

Timestamp: 2026-10-09T23-51
Task: [P1-T3]
Route substitution: per `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md` (row "Targeted runs (P1-T3, ...)"), the in-process `Invoke-Pester` targeted run is replaced by (1) `mcp__drm-copilot__run_poshqc_test` for pass/fail, read through JRP from the junit file it writes, and (2) a CI `_poshqc.yml` dispatch on the pushed phase head for per-file coverage, because the MCP runner's installed 127-file allow-list omits the new modules. Thresholds and the JRP/CRP derivations are unchanged.
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the agent worktree and `scan_folders` = `["tests/scripts/dev-tools"]`; JRP read with `poetry run python -I <scratchpad>/junit847.py artifacts/pester/pester-junit.xml tests/scripts/dev-tools/HostTooling.Tests.ps1`
EXIT_CODE: 0
Output Summary:
- MCP call disposition: `ok: true` (EXIT_CODE 0 records the call disposition; the MCP tool returns no captured output).
- Junit freshness: `artifacts/pester/pester-junit.xml` mtime 2026-10-09T23:51:00Z, written by this call (call issued at 2026-10-09T23:5x UTC).
- JRP step 5 (whole dev-tools run): tests=452 failures=0 errors=0 disabled=2; failed testcases: 0.
- JRP steps 2-3: `tests/scripts/dev-tools/HostTooling.Tests.ps1` cases=19 notPassed=0 -> PASS.
- Derived EXIT_CODE per P1-T3 rule (Failed, FailedBlocks, FailedContainers all 0): 0 for the pass/fail part (failures=0, errors=0 in the junit).
- CRP per-file `scripts/dev-tools/HostTooling.psm1` (CI): `FILE HostTooling.psm1 covered=36 missed=2 total=38 pct=94.74 required=33 gap=0 PASS`.
  - Source: CI `workflow_dispatch` of `_poshqc.yml`, run 38006685402 on head 92e5f9f0b, job `PowerShell QC` 114076981391, conclusion success. Artifacts downloaded to `artifacts/ci/run-38006685402/` (git-ignored); reduction file `artifacts/ci/run-38006685402/reduction.txt`, produced by `poetry run python <scratchpad>/reduce847.py artifacts/ci/run-38006685402/powershell-coverage.xml artifacts/ci/run-38006685402/pester-junit.xml`.
  - CI JRP steps 2-3: suite `tests/scripts/dev-tools/HostTooling.Tests.ps1` cases=19 notPassed=0 -> PASS.
  - CI analyzer log line: `PSScriptAnalyzer passed: no findings under D:\a\drm-copilot\drm-copilot` (Analyze PowerShell step).
- Result: JRP and CRP parts both PASS; [P1-T3] verified.
