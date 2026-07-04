# Code Review: separate-version-bump-from-publish (#214)

**Review Date:** 2026-06-19
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/separate-version-bump-from-publish-214`
**Feature Folder Selection Rule:** Folder suffix `-214` matches the canonical issue number and the autoclose issue in PR context.
**Base Branch:** `main` (merge-base `b70045e02d0d3b6290e9ed9799d0dec5ed09425b`)
**Head Branch:** `drm-copilot-wt-2026-06-19-20-36` @ `b3f55e64eb26e12230ed841589edc5866bd6aad7` (PR #216)
**Review Type:** Initial review

---

## Executive Summary

The change separates the release flow into a PR-gated version-bump phase (local scripts that bump manifests, commit, and open a PR via `gh`) and a post-merge, tag-triggered CI publish phase (a new `publish-extension.yml` workflow plus a dedicated tag-push script). Publish-side effects (`npm version`, `vsce publish`, `git tag`) are removed from the local scripts; the only remaining tag push is isolated in `Invoke-ReleaseTagPush.ps1` behind a `yes` confirmation gate.

**What changed:**
- `Publish-DrmCopilotExtension.ps1`: stripped to local `-DryRun`/`-Package` responsibilities; manifest pre-flight and `vsce ls` forbidden-file scan retained; `vsce`/`npm` calls isolated behind wrapper seams.
- `Invoke-FullRelease.ps1` and `Invoke-MarketplacePublish.ps1`: rewritten as release-PR openers (both-manifest and extension-only respectively); clean-tree check, branch creation, npm `--no-git-tag-version` bump, commit, `gh pr create --base main`.
- `Invoke-ReleaseTagPush.ps1` (new): updates `main`, reads merged manifest versions, derives `v<ext>` and `mcp-server-v<mcp>`, creates and pushes both tags.
- `publish-extension.yml` (new): tag-triggered + `workflow_dispatch` + path-filtered `pull_request`; publish step gated to `v*` tag refs.
- `.vscode/tasks.json`: retargeted task labels/detail and added the post-merge tag-push task; two coverage runsettings extended additively; four Pester suites added/updated.

**Top 3 risks:**
1. The new workflow cannot publish until `VSCE_PAT` is provisioned; this is tracked as a one-time human-interaction exception with a runbook, and the publish step is inert (skipped) until a `v*` tag with the secret present. Low residual risk.
2. The wrapper-seam bodies and host-bound entry-point lines are not unit-covered by design (mocking real executables is prohibited); behavior is verified through the seams. Acceptable per policy.
3. The green branch-head workflow run was recorded at `52ca3d61`; the only later commit (`b3f55e6`) is documentation-only and does not alter the workflow or `extensions/drm-copilot/**`, so the run remains authoritative. Verified by diff.

**PR readiness recommendation:** **Go** — Toolchain is clean, coverage thresholds are met per-file and overall, the workflow has a green branch-head run with a correctly gated publish step, and no Blocker or Major findings were identified.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | `Invoke-ReleaseTagPushGuarded` (lines 188-202) | Tag creation and push are not idempotent: re-running after a partial push (ext tag pushed, mcp tag failed) re-attempts `git tag -a` on the existing tag, which fails and returns exit 1. | Acceptable for a confirmation-gated post-merge task; optionally document the re-run/recovery procedure in the merge-approval runbook. | A failed mid-sequence push requires manual cleanup; this is a usability note, not a correctness defect. | File inspection lines 188-202. |
| Info | `scripts/dev-tools/Invoke-FullRelease.ps1`, `Invoke-MarketplacePublish.ps1`, `Invoke-ReleaseTagPush.ps1` | guard functions | State-changing tasks gate on `-ConfirmToken -cne 'yes'` rather than `SupportsShouldProcess`/`ShouldProcess`. | Keep as-is; this is the established repository pattern and a spec invariant. | `powershell.md` recommends ShouldProcess, but the confirmation-token gate is the explicit, spec-mandated contract for these release tasks and is invariant-preserving. | `spec.md` Invariants; file inspection. |
| Info | `scripts/powershell/Publish-DrmCopilotExtension.ps1` | entry point (lines 337-340) | `vsce`-not-on-PATH path emits `Write-Error` but continues to `Invoke-ExtensionPackage`, which would then fail at the seam. | Optional: `return`/`exit` after the `Write-Error` for a cleaner failure message. | With `$ErrorActionPreference='Stop'`, `Write-Error` terminates; behavior is correct. Minor readability note only. | File inspection lines 337-345. |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The wrapper-seam pattern (`Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe`/`Invoke-VsceExe`/`Get-VsceListing`) is applied consistently with the prescribed `-<Tool>Args [string[]]` signature, enabling deterministic mocking without touching real executables.
- Pure logic is cleanly separated from I/O: `Get-NpmVersion`, `Get-ReleaseBranchName`, `Get-ExtensionTagName`, and `Get-McpServerTagName` are pure and individually testable; the guarded functions orchestrate seams and return explicit exit codes.
- The bump/publish separation is enforced structurally and verified by the absence-invariant checks: no single script both bumps a tracked manifest and publishes or pushes a tag (`dod-absence-checks.2026-06-19T21-18.md`).
- Entry points are gated by `if ($MyInvocation.InvocationName -ne '.')`, keeping host-bound wiring thin and dot-sourceable for tests.

#### API and safety notes

- All functions are advanced functions with `[CmdletBinding()]`, typed `[OutputType]`, and `[Parameter(Mandatory = $true)]` on required inputs. `RepoRoot` is injected, avoiding ambient working-directory assumptions.
- The confirmation gate uses case-sensitive `-cne 'yes'`, preserving the spec invariant; non-`yes` returns exit 2.
- Approved verbs throughout; PSScriptAnalyzer EXIT 0 with zero findings confirms naming and analyzer hygiene.

#### Error handling and logging

- Failures are surfaced explicitly: missing manifest -> stderr + exit 1; dirty tree -> stderr + exit 1; seam failure -> stderr with the captured exit code + exit 1; npm bump failure -> propagates the npm exit code. No broad catch-all handlers.
- Informational progress uses `Write-Information`; guard/seam errors use `Write-StderrLine` (writing to `[Console]::Error`), consistent with the spec's logging requirement.

---

## Test Quality Audit

The four Pester suites exercise positive, negative, edge, and error paths through the wrapper seams. Coverage evidence is present and inspected; per-file line coverage for all four scripts is >= 90%, and overall measured-scope coverage is 94.85% (`coverage-comparison.2026-06-19T21-18.md`). Branch coverage is reported via the instruction-coverage proxy (93.78%) because the repository Pester engine emits no BRANCH counter. No coverage regression on changed lines; the overall percentage change is denominator growth from adding the four production files to the measured scope.

### Reviewed test and QA artifacts

- `tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1` — dry-run/package modes, manifest validation, build path, forbidden-file warning, vsce-package-failure, entry-point dry-run. Mocks wrapper seams only.
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` — token guard, both-manifest bump + `gh pr create`, dirty-tree block, missing-manifest reporting, seam failures, entry-point.
- `tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1` — token guard, single-manifest bump + `gh pr create`, dirty-tree block, missing-manifest reporting, seam failures, entry-point.
- `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` — token guard (case-sensitive), both-tag derivation/push, missing-manifest reporting, pull/tag-create/tag-push seam failures, tag-name builders, entry-point.
- `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/poshqc-test.final.2026-06-19T21-18.md` — 677 pass / 0 fail, EXIT 0.
- `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/coverage-214-perfile-jacoco.2026-06-19T21-18.xml` — per-file JaCoCo counters.
- `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/workflow-green-run.publish-extension.2026-06-19T21-18.md` — green run 27857355771, publish step skipped on PR event.

### Quality assessment prompts

- **Determinism:** Mocks target wrapper seams with param signatures matching production; no network, no live executables, no temporary files. Deterministic across Terminal and Test Explorer.
- **Isolation:** One behavior per `It`; scenario-grouped contexts.
- **Speed:** 677 tests run via PoshQC with EXIT 0; no sleeps/retries.
- **Diagnostics:** Assertions verify exit codes and `Write-StderrLine` message text, so failures localize the faulty path.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | `VSCE_PAT` referenced only as `${{ secrets.VSCE_PAT }}` in the workflow; no plaintext credentials in scripts. |
| No unsafe subprocess or command construction | ✅ PASS | All external calls splat a typed `[string[]]` into the executable (`& git @GitArgs`); no `Invoke-Expression`, no string-built shell commands. |
| Input validation at boundaries | ✅ PASS | Mandatory parameters, manifest existence checks, version-field non-empty validation, clean-tree check. |
| Error handling remains explicit | ✅ PASS | Explicit non-zero exits and stderr reporting on every failure path; no silent catch-all. |
| Configuration / path handling is safe | ✅ PASS | Paths built with `Join-Path`; `RepoRoot` resolved from `$PSScriptRoot`; `-LiteralPath` used for manifest reads. |

---

## Research Log

No external research was required. All findings are grounded in repository policy files (`.claude/rules/*`), the feature-folder evidence artifacts, the PR-context summary, and direct inspection of the changed files and the branch diff.

---

## Verdict

The change is ready for normal PR flow. The implementation is cohesive, applies the prescribed wrapper-seam pattern, removes the diagnosed bump/publish coupling, and isolates the single remaining tag push behind a confirmation gate. The PowerShell toolchain is clean, coverage thresholds are met per-file and overall, and the new workflow has a green branch-head run with a correctly gated publish step. The three Info-level findings are usability/readability notes and do not block merge. This verdict is consistent with the Findings Table and the Go readiness recommendation.
