# separate-version-bump-from-publish - Refactor Spec

- **Issue:** #214
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-19
- **Status:** Approved for planning
- **Version:** 1.0

## Intent & Outcomes

Separate the release workflow into two phases so that it respects branch protection on `main` and the immutability of the VS Code Marketplace and npm registries.

- **Phase A — version bump as a PR-gated source change.** A local task creates a release branch, patch-bumps both manifests, commits, and opens a PR via `gh`. The bumped versions land on `main` only after review/CI/merge. The local task never publishes and never pushes a publish tag.
- **Phase B — publish as a post-merge, tag-triggered CI operation.** Publish runs in GitHub Actions against a tag that points at the merged commit, so the published artifact's version matches the source of truth. The mcp-server path already works this way; the extension path moves `vsce publish` into a new CI workflow that authenticates with a `VSCE_PAT` secret.

Desired end-state: tags always reference commits that contain the version they name; `main` is always the version source of truth; no local credentials are required to publish; the three diagnosed consistency defects are eliminated.

Diagnosis reference: `artifacts/research/release-version-bump-publish-diagnosis.2026-06-19T20-36.md`.

## Invariants (must not change)

- The `yes`/`no` confirmation gate on any state-changing release task is preserved (token must equal the literal `yes`, case-sensitive; non-`yes` exits non-zero).
- `.github/workflows/publish-mcp-npm.yml` remains structurally correct (tag-trigger `mcp-server-v*`, `npm publish --provenance --access public`, `id-token: write`, publish step gated to `push` events). It is not the source of the defect and is not rewritten.
- Local non-publishing modes that produce a `.vsix` for inspection remain available: `Publish-DrmCopilotExtension.ps1 -DryRun` and `-Package` continue to work and never publish.
- Manifest pre-flight validation and the `vsce ls` forbidden-file scan in `Publish-DrmCopilotExtension.ps1` are preserved.
- External executable calls remain isolated behind wrapper-function seams (`Invoke-GitExe`, `Invoke-NpmExe`, `Invoke-GhExe`/`Invoke-PublishScript`) so Pester tests can mock without touching real git/npm/gh or the network.
- No production or test file exceeds 500 lines.

## Scope (structural changes)

1. **`scripts/powershell/Publish-DrmCopilotExtension.ps1`** — remove the in-place `npm version` bump, the `vsce publish` call, and the `git tag` call from the publish code path. The script's local responsibility ends at producing a `.vsix` (`-Package`) and validating the manifest (`-DryRun`). Marketplace upload and tagging move to CI.
2. **`scripts/dev-tools/Invoke-FullRelease.ps1`** — convert from "bump + publish + push tag locally" to "open a release PR": verify a clean tree, create a release branch, patch-bump both `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json`, commit, and `gh pr create` against `main`. No publish, no publish-tag push.
3. **`scripts/dev-tools/Invoke-MarketplacePublish.ps1`** — repurpose as the extension-only release-PR opener (single-manifest bump + PR) or retire in favor of the full-release PR opener. Final disposition decided in planning; it must not publish or tag.
4. **New `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`** (name subject to planning) — a confirmation-gated, post-merge task that reads the merged versions from `main` and pushes `v<ext-version>` and `mcp-server-v<mcp-version>` tags to trigger the CI publish workflows. This isolates the only remaining tag push to a clearly-named post-merge step.
5. **`.vscode/tasks.json`** — retarget the publish tasks to the new behaviors (open release PR; push release tags). Task labels and `detail` text updated to describe the PR-gated/CI-published model.
6. **New `.github/workflows/publish-extension.yml`** — tag-triggered (`push: tags: v*`) plus `workflow_dispatch`, plus a path-filtered `pull_request` trigger (scoped to `extensions/drm-copilot/**` and the workflow file). Checks out the ref, installs dependencies, builds, packages, and runs `vsce publish` with `--pat ${{ secrets.VSCE_PAT }}`. The publish step is gated to `if: startsWith(github.ref, 'refs/tags/v')` so it runs only on `v*` tag pushes; `pull_request` and `workflow_dispatch` runs exercise build/package without consuming a Marketplace version. The `pull_request` trigger exists so the new workflow can produce a green branch-head run in PR context (GitHub will not dispatch a `workflow_dispatch`-only workflow before it lands on the default branch), satisfying `modified-workflow-needs-green-run`.
7. **Runbooks** under `docs/features/active/separate-version-bump-from-publish-214/runbooks/` for the two one-time human-interaction requirements (`VSCE_PAT` provisioning; release-PR merge approval).

## Non-Goals

- Certificate-based local signing (Marketplace signs distributed extensions itself).
- Adopting release-please / changesets / semantic-release or any third-party release-management layer.
- Changelog automation or conventional-commit enforcement changes.
- Modifying branch-protection policy itself. Merge approval remains a permitted human step (runbook-backed `exception`).
- Re-publishing or correcting any version already published under the prior workflow (immutable; the only forward path is the next clean version).

## Dependencies / Touchpoints

- `gh` CLI (already authenticated) for PR creation.
- GitHub Actions secrets: existing `NPM_TOKEN`; new `VSCE_PAT` (one-time human provisioning).
- Branch protection on `main` (PR review/status checks gate the bump PR).
- `vsce` (`@vscode/vsce`) installed in the new CI workflow.
- The `modified-workflow-needs-green-run` feature-review policy applies to the new workflow file.

## Risks & Mitigations

- **New workflow cannot be validated locally.** Mitigation: gate the publish step to `push` events and obtain a green `workflow_dispatch` run against branch head to satisfy `modified-workflow-needs-green-run`; lint with `actionlint`.
- **`VSCE_PAT` not yet provisioned.** Mitigation: one-time runbook recorded under `human_interaction.requirements[]` as an `exception`; the workflow is inert (publish step skipped) until a tag is pushed with the secret present.
- **Accidental publish of an unintended version.** Mitigation: version is locked to the merged commit; tags are pushed only by the explicit, confirmation-gated post-merge task.
- **Rollback:** all changes are local scripts, `tasks.json`, and a new workflow file; revert is a single PR revert. No registry artifact is produced by the refactor itself.

## Technical Specifications

- Files/modules expected to change: the four scripts above, `.vscode/tasks.json`, one new workflow file, two runbooks, and Pester tests mirroring the changed scripts under `tests/scripts/...`.
- Public interfaces/contracts affected: VS Code task labels/inputs; PowerShell script parameter sets (removal of publish/tag side-effects). Confirmation-token contract unchanged.
- Data flow: version bump → committed on branch → PR → merge → tag push → CI checkout of tag → publish. No working-tree mutation during publish.
- Logging: preserve existing `Write-Information`/`Write-Error` patterns; stderr for guard failures.

## Test Strategy

- **Pester unit tests** for each changed/new script, mocking `Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe`/publish seams:
  - confirmation-token guard rejects non-`yes` tokens (existing behavior preserved);
  - release-PR opener bumps both manifests and invokes `gh pr create` with the derived title/branch;
  - tag-push task derives `v<version>` and `mcp-server-v<version>` from the committed manifests and pushes both;
  - publish script `-Package`/`-DryRun` paths no longer invoke `vsce publish`, `npm version`, or `git tag`;
  - negative: missing manifest/script reported, not silently ignored; dirty working tree blocks the bump task.
- **Workflow validation:** `actionlint` clean on `publish-extension.yml`; green `workflow_dispatch` run against branch head (satisfies `modified-workflow-needs-green-run`).
- **Coverage:** line >= 85%, branch >= 75% on changed PowerShell; no regression on changed lines.
- **Toolchain (PowerShell):** PoshQC format → PSScriptAnalyzer → Pester, via MCP tools.

## Definition of Done

- [x] Bump and publish are separated: no local task both bumps tracked manifests and publishes/pushes a publish tag.
- [x] `Publish-DrmCopilotExtension.ps1` publish-side effects (`npm version`, `vsce publish`, `git tag`) removed; `-DryRun`/`-Package` preserved.
- [x] Release-PR opener task bumps both manifests on a branch and opens a PR via `gh`; never publishes.
- [x] Post-merge tag-push task pushes `v*` and `mcp-server-v*` from the committed `main` versions, behind a `yes` confirmation.
- [x] New `publish-extension.yml` publishes via `vsce publish --pat ${{ secrets.VSCE_PAT }}`, publish step gated to `push`, with `workflow_dispatch`.
- [x] `tasks.json` retargeted; labels/detail describe the PR-gated/CI-published model.
- [ ] Two human-exception runbooks authored and recorded in orchestrator state (`VSCE_PAT`, merge approval).
- [ ] Pester tests added/updated; coverage thresholds met; PoshQC format → analyze → test clean.
- [ ] `actionlint` clean and a green `workflow_dispatch` run recorded for the new workflow.
