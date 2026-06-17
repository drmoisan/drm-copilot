# Code Review: bump-and-publish-task (Issue #191)

**Review Date:** 2026-06-17
**Feature Folder:** `docs/features/active/2026-06-16-bump-and-publish-task-191`
**Base Branch:** `main`
**Range:** `93d83d5ea01d40b229e2721f057210d9ef698206..62e7f291c69d4debce2aca82115c7907af7df295`

> Template note: the MCP server tool `resolve_policy_audit_template_asset` (selector `code-review-template`) is not exposed in this review environment. This artifact follows the required shape: `## Executive Summary`, `## Findings Table` with the canonical header.

## Executive Summary

The change set is small, cohesive, and well-structured. The new PowerShell wrapper `Invoke-FullRelease.ps1` isolates all external executable calls behind wrapper-function seams (`Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-PublishScript`), keeping the orchestration function `Invoke-FullReleaseGuarded` deterministic and unit-testable. The confirmation gate is case-sensitive (`-cne 'yes'`) and is exercised for `no`, `YES`, and `Yes`. Error handling is explicit: each step checks an exit code and returns a distinct non-zero code with a stderr diagnostic rather than failing silently. The workflow change correctly pairs `npm publish --provenance` with `permissions: id-token: write`, which is the required token scope for npm provenance attestation.

One process-level blocker applies, not a code defect: the modified workflow `.github/workflows/publish-mcp-npm.yml` has no green run against the current branch head, which the `modified-workflow-needs-green-run` policy treats as Blocking. The remaining items are low-severity observations.

No blockers originate in the source code itself. The single Blocking item is a CI-evidence gap tracked in the policy audit and remediation inputs.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|----------|------|----------|---------|----------------|-----------|----------|
| Blocking (process) | `.github/workflows/publish-mcp-npm.yml` | whole-file modification | Workflow modified with no green workflow run against head SHA `62e7f29...`; branch head is not pushed to any remote. | Push the branch and obtain a green PR-context or `workflow_dispatch` run against the head, then record it in remediation inputs before merge. | `modified-workflow-needs-green-run` provides a second line of defense for CI-gate-modifying changes; the workflow's `run:` paths (provenance publish, id-token permission) are not exercised by any local stage. | `git branch -r --contains 62e7f29` empty; no green-run evidence file in feature folder. |
| Low | `scripts/dev-tools/Invoke-FullRelease.ps1` | lines 153-223 (`Invoke-FullReleaseGuarded`) | State-changing actions (npm bump, git tag create/push, Marketplace publish) are gated by a mandatory `-ConfirmToken 'yes'` rather than `SupportsShouldProcess`/`ShouldProcess`. | Acceptable as-is; if future revision permits, consider `SupportsShouldProcess` to align with `.claude/rules/powershell.md` while retaining the explicit token. | The rule recommends ShouldProcess for state-changing actions; the token design is an intentional, tested equivalent that satisfies the immutability-confirmation requirement. Not a defect. | `.claude/rules/powershell.md` (Coding Standards); script lines 40-44, 173-176. |
| Low | `scripts/dev-tools/Invoke-FullRelease.ps1` | line 207 (`$null = $extensionManifest`) | `$extensionManifest` is computed (line 180) but only assigned to `$null` and never used; the extension manifest bump is delegated to the publish script. | Remove the unused variable and its computation, or add a comment clarifying it is a deliberate placeholder. | Dead local reduces clarity; the variable suggests a direct read that does not occur. Minor. | Script lines 180, 207. |
| Info | `scripts/dev-tools/Invoke-FullRelease.ps1` | lines 188-205 | Sequencing: the mcp-server manifest is bumped (step 1) before the extension publish (step 2). If the extension publish fails, the mcp-server `package.json` has already been bumped on disk but the tag is correctly not pushed. | Acceptable; the partial-bump-without-tag state is recoverable (no immutable artifact published) and the stderr message names the un-pushed tag. Consider documenting the recovery note in the script header. | The design intentionally stops before the immutable tag push on publish failure; the local manifest edit is reversible. Documented behavior, not a defect. | Script lines 190-205; header `.DESCRIPTION` lines 11-21. |
| Info | `.github/workflows/publish-mcp-npm.yml` | line 58 | `npm publish --provenance --access public` requires `id-token: write`, present at the job level (lines 34-36). | None. | Confirms the AC for provenance is correctly wired; `contents: read` is the minimal additional scope. | actionlint EXIT 0; diff lines 34-36, 58. |

## Detailed Observations

### PowerShell design seams (PASS)
The wrapper-seam pattern is applied correctly: `Invoke-GitExe -GitArgs [string[]]`, `Invoke-NpmExe -NpmArgs [string[]]`, and `Invoke-PublishScript -ScriptPath [string]` each splat into the external executable and return `$LASTEXITCODE`. Parameter names avoid the `Args` automatic-variable collision, per `.claude/rules/powershell.md`. The Pester suite mocks these wrappers (not raw `git`/`npm`), preserving Test Explorer parity.

### Error propagation (PASS)
`Invoke-FullReleaseGuarded` returns distinct codes: 2 (unconfirmed), 1 (missing publish script, tag-create failure, tag-push failure), the npm exit code on bump failure, and the publish script's own code on publish failure. Each failure writes a specific stderr message. This satisfies the fail-fast and no-silent-error requirements.

### Entry-point guard (PASS)
The `if ($MyInvocation.InvocationName -ne '.')` guard at lines 226-229 prevents entry-point execution when the script is dot-sourced for testing, which is why those lines appear as uncovered in the targeted coverage run. This is the standard repo pattern for AST/dot-source function import.

### Test quality (PASS)
Tests are independent, isolated, deterministic, and free of temp files and network access. Case-sensitivity of the confirmation token is explicitly covered. The negative path (missing publish script) asserts both the return code and the stderr message, and that no git wrapper was invoked.
