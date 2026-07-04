# Feature Audit: bump-and-publish-task (Issue #191)

**Audit Date:** 2026-06-17
**Feature Folder:** `docs/features/active/2026-06-16-bump-and-publish-task-191`
**Work Mode:** `minor-audit`
**AC Source:** `docs/features/active/2026-06-16-bump-and-publish-task-191/issue.md` — `## Acceptance Criteria` section only (minor-audit).

> Template note: the MCP `feature-audit-template` asset is not exposed in this review environment. This artifact follows the required five-section shape.

## Scope and Baseline

- **Base branch:** `main`
- **Merge-base SHA:** `93d83d5ea01d40b229e2721f057210d9ef698206`
- **Head SHA:** `62e7f291c69d4debce2aca82115c7907af7df295`
- **Range:** `93d83d5..62e7f29`
- **Audit scope:** full branch diff vs base (not a plan/task subset).
- **Changed files in scope:**
  - `scripts/dev-tools/Invoke-FullRelease.ps1` (added)
  - `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (added)
  - `.github/workflows/publish-mcp-npm.yml` (modified)
  - `.vscode/tasks.json` (modified)
  - feature docs and evidence (added)

## Acceptance Criteria Inventory

From `issue.md` `## Acceptance Criteria` (6 items):

1. A new VS Code task patch-bumps both package manifests in one run.
2. The task publishes the extension to the Marketplace via the existing script.
3. The task creates and pushes a `mcp-server-v<version>` tag to trigger npm publish.
4. The task is gated behind a `yes`/`no` confirmation input.
5. The npm workflow publishes with `--provenance`.
6. Pester tests cover the new release script's guard and orchestration logic.

## Acceptance Criteria Evaluation

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | New VS Code task patch-bumps both manifests in one run | PASS | `.vscode/tasks.json` adds task "Publish: Full Release (bump both + Marketplace + npm tag)" invoking `Invoke-FullRelease.ps1`. Script step 1 bumps mcp-server via `npm version patch --no-git-tag-version` (lines 190); the extension manifest patch bump is delegated to `Publish-DrmCopilotExtension.ps1 -VersionBump patch` (line 102, invoked at line 201). Both bumps occur in one run. |
| 2 | Task publishes the extension to Marketplace via existing script | PASS | `Invoke-PublishScript` (lines 89-104) calls `scripts/powershell/Publish-DrmCopilotExtension.ps1 -Publish -VersionBump patch -Tag`; the script path is verified present in the repo. A non-zero publish code stops the run before the tag push (lines 202-205). |
| 3 | Task creates and pushes `mcp-server-v<version>` tag | PASS | `Get-McpServerTagName` derives `mcp-server-v<version>` (lines 136-151, tested -> `mcp-server-v0.0.2`); step 3 creates (`git tag -a`) and pushes (`git push origin <tag>`) via `Invoke-GitExe` (lines 210-220). Pester test asserts exactly two git calls containing the derived tag. |
| 4 | Task gated behind `yes`/`no` confirmation input | PASS | `.vscode/tasks.json` adds `FullReleaseConfirm` pickString input (options `no`/`yes`, default `no`) passed as `-ConfirmToken`. Script rejects any non-`yes` token with code 2 (case-sensitive `-cne 'yes'`, lines 173-176); tested for `no`, `YES`, `Yes`. |
| 5 | npm workflow publishes with `--provenance` | PASS | `.github/workflows/publish-mcp-npm.yml` diff: publish step changed to `npm publish --provenance --access public` (line 58) and `permissions: { id-token: write, contents: read }` added to the publish job (lines 34-36). actionlint EXIT 0. Note: code-correct, but the workflow change carries a Blocking process gate (no green head-SHA run) tracked separately in the policy audit; this does not change the AC code-correctness verdict. |
| 6 | Pester tests cover guard and orchestration logic | PASS | `Invoke-FullRelease.Tests.ps1` (7 tests): confirmation guard (3 cases), bump arguments + derived version, tag derivation, tag create/push, missing-publish-script negative path. Repo-wide Pester EXIT 0 (608 pass). New-file line coverage 88.0%. |

## Summary

All six acceptance criteria are evaluated **PASS** at the code level: the combined-release task and script, the dual-manifest bump, the Marketplace delegation, the `mcp-server-v<version>` tag push, the confirmation gate, the npm provenance change, and the Pester coverage are all present and verified against the branch diff and the feature evidence package.

The feature is **not yet merge-ready** despite all ACs passing, due to two cross-cutting findings recorded in the policy audit:

1. **BLOCKING (process):** `modified-workflow-needs-green-run` — the modified `.github/workflows/publish-mcp-npm.yml` has no green workflow run against head SHA `62e7f29...`. AC #5 is code-correct, but the gate governing CI-modifying changes is unsatisfied.
2. **PARTIAL:** New-code branch coverage cannot be numerically verified (tooling emits no BRANCH counter). Line coverage (88.0%) passes; the branch threshold (>= 75%) is unmeasured.

These are not AC failures; they are policy/evidence gaps that block merge. Remediation is tracked in `remediation-inputs.2026-06-17T00-18.md`.

## Acceptance Criteria Check-off

All six AC items in `issue.md` `## Acceptance Criteria` are already marked `[x]` and each is confirmed **PASS** by this audit; no check-off change is required. The items remain checked, consistent with the evaluation table above.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-06-16-bump-and-publish-task-191/issue.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: none

Merge readiness is gated by the Blocking workflow-green-run finding and the PARTIAL branch-coverage finding, not by any unmet acceptance criterion.
