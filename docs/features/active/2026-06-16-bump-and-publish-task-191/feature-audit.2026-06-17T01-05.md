# Feature Audit: bump-and-publish-task (Issue #191)

**Audit Date:** 2026-06-17
**Audit Type:** Re-audit after remediation (cycle 2)
**Work Mode:** `minor-audit`
**AC Source:** `docs/features/active/2026-06-16-bump-and-publish-task-191/issue.md`, section `## Acceptance Criteria`

## Scope and Baseline

- **Base branch:** `main`
- **Merge-base SHA:** `93d83d5ea01d40b229e2721f057210d9ef698206`
- **Head SHA:** `75e3ec51aafa8f00eed4a426552627d36ac9413d`
- **Diff range:** `93d83d5ea01d40b229e2721f057210d9ef698206..75e3ec51aafa8f00eed4a426552627d36ac9413d`
- **Scope:** full branch diff vs base (not narrowed). Primary code under test:
  - `scripts/dev-tools/Invoke-FullRelease.ps1` (added)
  - `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (added)
  - `.github/workflows/publish-mcp-npm.yml` (modified)
  - `.vscode/tasks.json` (modified)

This is the re-audit following remediation of the two findings from the prior cycle. The acceptance criteria were all evaluated PASS in the prior cycle at the code level; this re-audit confirms they remain PASS against the current head and that the two prior policy/evidence findings (F1, F2) are resolved.

## Acceptance Criteria Inventory

The work mode is `minor-audit`; the authoritative AC source is the explicit `## Acceptance Criteria` section in `issue.md`. Six criteria:

1. A new VS Code task patch-bumps both package manifests in one run.
2. The task publishes the extension to the Marketplace via the existing script.
3. The task creates and pushes a `mcp-server-v<version>` tag to trigger npm publish.
4. The task is gated behind a `yes`/`no` confirmation input.
5. The npm workflow publishes with `--provenance`.
6. Pester tests cover the new release script's guard and orchestration logic.

## Acceptance Criteria Evaluation

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | A new VS Code task patch-bumps both package manifests in one run | PASS | `.vscode/tasks.json` adds the task "Publish: Full Release (bump both + Marketplace + npm tag)" invoking `Invoke-FullRelease.ps1`. The script patch-bumps the mcp-server manifest via `Invoke-NpmExe -NpmArgs @('--prefix', $mcpServerDir, 'version', 'patch', '--no-git-tag-version')` (line 190) and patch-bumps the extension manifest via the delegated `Publish-DrmCopilotExtension.ps1 -VersionBump patch` (line 102). Both manifests bumped in one run. Test 4 asserts the npm bump args. |
| 2 | The task publishes the extension to the Marketplace via the existing script | PASS | `Invoke-PublishScript` delegates to `scripts/powershell/Publish-DrmCopilotExtension.ps1 -Publish -VersionBump patch -Tag` (lines 101-102), invoked at line 201. A missing publish script returns 1 (tested: "missing publish script" Context). |
| 3 | The task creates and pushes a `mcp-server-v<version>` tag to trigger npm publish | PASS | `Get-McpServerTagName` derives `mcp-server-v<version>` (line 150); the script creates the tag (`Invoke-GitExe -GitArgs @('tag', '-a', $mcpTagName, ...)`, line 210) and pushes it (`Invoke-GitExe -GitArgs @('push', 'origin', $mcpTagName)`, line 216). Tests 5 and 6 assert derivation (`mcp-server-v0.0.2`) and exactly two git calls (create + push). The pushed tag matches the workflow trigger `mcp-server-v*`. |
| 4 | The task is gated behind a `yes`/`no` confirmation input | PASS | `.vscode/tasks.json` adds a `pickString` input `FullReleaseConfirm` with options `["no","yes"]` defaulting to `no`, passed as `-ConfirmToken`. The script returns 2 unless `-ConfirmToken -ceq 'yes'` (case-sensitive, line 173). Tests 1-3 assert rejection of `no`, `YES`, `Yes` with code 2 and zero wrapper invocations. |
| 5 | The npm workflow publishes with `--provenance` | PASS | `.github/workflows/publish-mcp-npm.yml` diff changes the publish command to `npm publish --provenance --access public` and adds job-level `permissions: id-token: write, contents: read`. actionlint EXIT 0. The green `workflow_dispatch` run 27657801156 exercised this job (publish step skipped under the `push`-only guard, so no irreversible publish occurred during verification). |
| 6 | Pester tests cover the new release script's guard and orchestration logic | PASS | `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (7 tests) covers the confirmation guard (3 case-sensitivity tests), the mcp-server bump args and derived version, tag derivation, tag create+push, and the missing-publish-script path. Failure-path exit-code branches are additionally exercised by the targeted coverage harness enumerated in `coverage-delta.md`. New-code line coverage 88.0% (>= 85% PASS); branch coverage discharged via the sanctioned tooling-limitation exception. |

## Remediation Verification (prior-cycle findings)

| Finding | Prior verdict | Re-audit verdict | Evidence |
|---------|---------------|-------------------|----------|
| F1 — `modified-workflow-needs-green-run` | BLOCKING | RESOLVED | Green `workflow_dispatch` run 27657801156 (conclusion success) against head `7803ffc`; workflow byte-identical between `7803ffc` and HEAD `75e3ec5` (empty diff for the file); only later commit is evidence-only. `evidence/qa-gates/workflow-green-run.md`. |
| F2 — branch coverage for new PowerShell code | PARTIAL | RESOLVED | Tooling emits zero BRANCH counters (re-confirmed in both coverage XML files); sanctioned tooling-limitation exception with complete per-branch enumeration recorded in `evidence/qa-gates/coverage-delta.md`. New-code line coverage 88.0% PASS. No threshold lowered. |

## Summary

All six acceptance criteria are PASS. Both prior-cycle findings are resolved with recorded evidence. Zero blocking findings remain. The feature is ready for merge.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-06-16-bump-and-publish-task-191/issue.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All six criteria in `issue.md` were already checked `[x]` (delivered and verified in the prior cycle at the code level) and are re-confirmed PASS in this re-audit. No check-state change is required. The criterion text was not modified.
