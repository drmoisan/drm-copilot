# Code Review: bump-and-publish-task (Issue #191)

**Review Date:** 2026-06-17
**Review Type:** Re-audit after remediation (cycle 2)
**Base Branch:** `main`
**Merge-base SHA:** `93d83d5ea01d40b229e2721f057210d9ef698206`
**Head SHA:** `75e3ec51aafa8f00eed4a426552627d36ac9413d`
**Files Reviewed (full branch diff vs base):**
- `scripts/dev-tools/Invoke-FullRelease.ps1` (added)
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (added)
- `.github/workflows/publish-mcp-npm.yml` (modified)
- `.vscode/tasks.json` (modified)

## Executive Summary

The code is of acceptable quality and is ready for merge. The production script `Invoke-FullRelease.ps1` follows the repository's PowerShell standards: advanced functions with `[CmdletBinding()]` and mandatory named parameters, the preferred wrapper-function seam pattern for all external executable calls (`Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-PublishScript`), pure read/derive helpers (`Get-NpmVersion`, `Get-McpServerTagName`) separated from orchestration, fail-fast error handling with distinct non-zero exit codes per failure path, and a 230-line file well within the 500-line limit. The Pester suite mocks the wrapper seams (never raw `git`/`npm`), maintains mock-signature parity, and uses AST import without temp files or network access.

The workflow change is minimal and correct: it adds `workflow_dispatch` for verification, scopes job-level `permissions` to `id-token: write` / `contents: read` for npm provenance, guards the irreversible publish step with `if: github.event_name == 'push'`, and adds `--provenance` to the publish command. The `.vscode/tasks.json` change adds a confirmation `pickString` input defaulting to `no` and a task that invokes the script via `pwsh -File`, avoiding nested-quoting issues.

No new code-quality issues were identified in this re-audit. The two prior-cycle findings (F1 green-run evidence, F2 branch-coverage exception) were policy/evidence findings tracked in the policy audit; both are now resolved. There are no blocker- or major-severity findings.

This review verifies recorded artifacts and re-reads the diff; it does not modify code (no silent fixes).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Info | `scripts/dev-tools/Invoke-FullRelease.ps1` | `Invoke-FullReleaseGuarded` (lines 153-223) | State-changing actions (npm bump, git tag create/push, Marketplace publish) are gated by a mandatory `-ConfirmToken 'yes'` rather than `SupportsShouldProcess`/`ShouldProcess`. | None required. Optionally document the deviation inline; the current confirmation-token design is acceptable. | `.claude/rules/powershell.md` recommends `ShouldProcess` for state-changing actions, but the confirmation-token gate is an intentional, tested equivalent that also satisfies the immutability-confirmation requirement and matches the existing `Invoke-MarketplacePublish.ps1` task pattern. Non-blocking. | Script header lines 29-34; guard at lines 173-176; covered by three case-sensitivity tests (`no`/`YES`/`Yes` -> return 2). |
| Info | `scripts/dev-tools/Invoke-FullRelease.ps1` | line 207 (`$null = $extensionManifest`) | `$extensionManifest` is assigned and then discarded; the extension manifest path is computed but not used directly (the delegated publish script bumps it). | None required. The discard is explicit and the comment context is clear; optionally remove the unused variable in a future change. | Explicit `$null =` discard avoids an unused-variable analyzer warning and documents intent. PSScriptAnalyzer passes (EXIT 0). Non-blocking. | Lines 180, 207; `evidence/qa-gates/poshqc-analyze.md` EXIT 0. |
| Info | `.github/workflows/publish-mcp-npm.yml` | `Publish to npm` step (`if: github.event_name == 'push'`) | The publish step is correctly guarded so `workflow_dispatch` verification runs do not perform an irreversible publish; the green verification run skipped this step. | None required. Confirmed correct. | The guard is the mechanism that allows a safe green verification run, satisfying `modified-workflow-needs-green-run` without producing an immutable npm release. | `evidence/qa-gates/workflow-green-run.md` (step "Publish to npm: skipped"). |
| Info | `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` | failure-path branches | The success-and-guard paths are asserted in the committed suite; several failure-path exit-code branches (non-zero npm bump, non-zero publish, non-zero tag-create/tag-push, `Get-NpmVersion` throws) are exercised by the targeted coverage harness rather than the committed suite. | None required for merge. Consider promoting the harness-driven failure-path assertions into the committed suite in a future change for durable regression coverage. | The branch enumeration in `coverage-delta.md` maps each failure branch to a covering test; new-code line coverage is 88.0% (PASS). Non-blocking observation. | `evidence/qa-gates/coverage-delta.md` per-branch enumeration; `artifacts/pester/fullrelease-coverage.xml`. |

## Severity Legend

- **Blocker** — must fix before merge.
- **Major** — should fix before merge; material quality or correctness risk.
- **Minor** — should fix; limited risk.
- **Info** — observation or optional improvement; no action required for merge.

No Blocker, Major, or Minor findings were identified. All findings are Info-level.
