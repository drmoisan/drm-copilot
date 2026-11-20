# Pester After Edit (Issue #931)

Timestamp: 2026-10-16T01-42
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <worktree>, scan_folders = ["tests/scripts/dev-tools"])
EXIT_CODE: 0
Output Summary: The final call returned "ok":true. An earlier call in this task returned "ok":false because of one failing new test. The cause was a defect in the new parse helper; it was fixed inside the P1-T8 helper and the call was re-run. No count is asserted from the MCP result. Per-test outcomes of record come from the PR CI artifact at S9.

Call result (final): `"ok":true`
Summary (verbatim, host path replaced with `<worktree>`): `Ran bundled PoshQC test against '<worktree>' with 1 selected scan folder(s).`

## Scope deviation

The call is scoped to `tests/scripts/dev-tools`, which contains every release-flow Pester suite. A full-suite call cannot return within the client MCP idle timeout on this host (two attempts aborted at 1802 s and 1814 s; see `evidence/baseline/ps-test.2026-10-16T01-26.md`). The full suite runs in the PR CI job `poshqc / PowerShell QC`.

## Run history in this task

| Run | Call result | Cause / action |
|---|---|---|
| 1 | `"ok":false`, summary `Command exited with code 1.` | Local junit (`<worktree>/artifacts/pester/pester-junit.xml`, git-ignored) recorded `tests="654" failures="1"`. The failing test was `reports failure for a scalar element` (`CheckClassification.Tests.ps1:149`, `Expected $false, but got $true.`). |
| 2 | `"ok":true` | Fixed after run 1 (see below). |

Root cause of run 1: in PowerShell the `[pscustomobject]` type accelerator resolves to `System.Management.Automation.PSObject`. `$item -isnot [pscustomobject]` is therefore false for a scalar that the pipeline has wrapped in a PSObject. A JSON scalar element such as `[1]` was accepted, which contradicts `## Decisions` item 2. Fix (scripts/dev-tools/Invoke-FullReleaseFlow.ps1, inside `ConvertFrom-CheckPollOutput`): the element test is now `$item -isnot [System.Management.Automation.PSCustomObject]`. The plan text for P1-T8 says to use `-is [pscustomobject]` and not `-is [psobject]`, on the premise that the two differ; they do not. The fix satisfies the contract the plan states. The line count is unchanged (499).

The stderr excerpt returned with run 1 came from unrelated publish-verification tests that write expected stderr text. It was not the failure.

## Supplementary local observations (not an acceptance basis)

Local junit after run 2: `tests="654" errors="0" failures="0" disabled="2"`. Release-flow suites:

| Suite | tests | failures |
|---|---|---|
| Invoke-FullReleaseFlow.Tests.ps1 | 15 | 0 |
| Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | 19 | 0 |
| Invoke-FullReleaseFlow.CheckClassification.Tests.ps1 | 17 | 0 |
| Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | 11 | 0 |

Local coverage for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (class-level LINE counter, scoped run): missed 7, covered 153, valid 160, 95.63%. Per-method LINE missed counts: `ConvertFrom-CheckPollOutput` 0, `Get-CheckSetVerdict` 0, `Wait-ForPullRequestChecks` 0. The 7 missed lines are the mocked wrapper seams, the same as at baseline. The AC6 no-regression value of record comes from the PR CI artifact (baseline 94.26%).
