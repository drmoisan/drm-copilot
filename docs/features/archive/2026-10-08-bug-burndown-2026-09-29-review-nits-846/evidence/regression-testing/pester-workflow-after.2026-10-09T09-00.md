# Regression: #723 Pester workflow suite after the change ([P8-T5], AC-30, AC-31 Pester half)

Timestamp: 2026-10-09T21-44
Command: (PowerShell-tool) $r = Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"
EXIT_CODE: 1
Output Summary: PowerShell tool unavailable. The executor's tool set does not include the PowerShell tool, and the delegation forbids routing pwsh, sh, or bash wrapper scripts through the Bash tool, so the command was not executed (EXIT_CODE 1 records the non-execution; no process ran).
Error: PowerShell tool unavailable
Branch: A7-CI
Outcome: LOCAL-PESTER-UNAVAILABLE

Dependent criteria AC-30 and AC-31 stay unchecked and are listed as pending-CI. The CI job `poshqc / PowerShell QC` on the PR head is authoritative; the orchestrator checks them off at S9.

## Supplementary: PoshQC MCP runs (scan_folders ["tests/scripts/workflows"])

These results are recorded verbatim. The MCP result payload carries only an `ok` flag and a summary string composed by the server; it does not carry Pester pass/fail counts, analyzer findings, or formatter change lists, so it is not a substitute for the A7-LOCAL acceptance literal `Passed=11 Failed=0`.

Command: mcp__drm-copilot__run_poshqc_format (workspace_root <worktree>)
Result:

```
{"ok":true,"tool":"run_poshqc_format","workspace_root":"<worktree>","summary":"Ran bundled PoshQC format against '<worktree>' with 1 selected scan folder(s)."}
```

Tree observation: `git hash-object tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` printed 45c0d062e2902624db729b2e282be044c489f5f3 before and after the format run; `git status --porcelain --untracked-files=all` listed no other changed path. The formatter modified no file.

Command: mcp__drm-copilot__run_poshqc_analyze (same workspace_root and scan_folders)
Result:

```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<worktree>","summary":"Ran bundled PoshQC analyze against '<worktree>' with 1 selected scan folder(s)."}
```

Command: mcp__drm-copilot__run_poshqc_test (same workspace_root and scan_folders)
Result:

```
{"ok":true,"tool":"run_poshqc_test","workspace_root":"<worktree>","summary":"Ran bundled PoshQC test against '<worktree>' with 1 selected scan folder(s)."}
```

Static cross-check (not a test run): the workflow's equality step (lines 71-90) and poll step (lines 101-end) each contain exactly one `exit 1` line; the `if ($tagVersion -ne $manifestVersion) {` and `if (-not $resolved) {` blocks contain the `::error::` line and `exit 1` with no intervening `}`; the poll step has one `if:` line (line 102, the ref guard, no always()/failure()/cancelled()); the publish step has no continue-on-error. These observations indicate the new assertions are likely to pass in CI, but they are not verified by a Pester run.

Acceptance (A7-CI): `Outcome: LOCAL-PESTER-UNAVAILABLE` recorded with the error text. PASS (A7-CI branch).
Redaction: absolute worktree path replaced with <worktree> on 2026-10-09T22-23 (policy-audit PA-4); no other content changed.
