# Feature Audit: separate-version-bump-from-publish (#214)

**Audit Date:** 2026-06-19
**Feature Folder:** `docs/features/active/separate-version-bump-from-publish-214`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-06-19-20-36` @ `b3f55e64eb26e12230ed841589edc5866bd6aad7` (PR #216)
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (merge-base `b70045e02d0d3b6290e9ed9799d0dec5ed09425b`)
- **Head branch/commit:** `drm-copilot-wt-2026-06-19-20-36` (commit `b3f55e64eb26e12230ed841589edc5866bd6aad7`)
- **Merge base:** `b70045e02d0d3b6290e9ed9799d0dec5ed09425b`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/separate-version-bump-from-publish-214/evidence/**`
  - Additional evidence: `artifacts/orchestration/orchestrator-state.json` (human_interaction requirements)
- **Feature folder used:** `docs/features/active/separate-version-bump-from-publish-214`
- **Requirements source:** `spec.md` `## Definition of Done` section.
- **Work mode resolution note:** No `issue.md` is present in the feature folder, so the persisted work-mode marker is absent. Per the fail-closed rule, work mode resolves to `full-feature`. For `full-feature` the AC sources are `spec.md` and `user-story.md`; no `user-story.md` exists in this folder, so the authoritative AC source is the `## Definition of Done` section of `spec.md`, consistent with the caller's stated AC source.
- **Scope note:** Audit scope is the full feature-vs-base branch diff. The green workflow run was recorded against `52ca3d61`; the only later commit (`b3f55e6`) is documentation-only and does not change the workflow or `extensions/drm-copilot/**`, so the green run remains authoritative for the head workflow content (verified via `git diff 52ca3d61..HEAD -- .github/workflows/publish-extension.yml extensions/ scripts/ tests/`, which was empty).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/separate-version-bump-from-publish-214/spec.md` `## Definition of Done` — only source (checkbox-based)

### Acceptance criteria (from spec.md `## Definition of Done`)

1. Bump and publish are separated: no local task both bumps tracked manifests and publishes/pushes a publish tag.
2. `Publish-DrmCopilotExtension.ps1` publish-side effects (`npm version`, `vsce publish`, `git tag`) removed; `-DryRun`/`-Package` preserved.
3. Release-PR opener task bumps both manifests on a branch and opens a PR via `gh`; never publishes.
4. Post-merge tag-push task pushes `v*` and `mcp-server-v*` from the committed `main` versions, behind a `yes` confirmation.
5. New `publish-extension.yml` publishes via `vsce publish --pat ${{ secrets.VSCE_PAT }}`, publish step gated to `push`, with `workflow_dispatch`.
6. `tasks.json` retargeted; labels/detail describe the PR-gated/CI-published model.
7. Two human-exception runbooks authored and recorded in orchestrator state (`VSCE_PAT`, merge approval).
8. Pester tests added/updated; coverage thresholds met; PoshQC format -> analyze -> test clean.
9. `actionlint` clean and a green `workflow_dispatch` run recorded for the new workflow.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Bump and publish separated; no task both bumps and publishes/tags | PASS | `dod-absence-checks.2026-06-19T21-18.md` invariants 1-4 all SATISFIED; PR openers bump+`gh pr create` only; `Invoke-ReleaseTagPush.ps1` pushes tags but performs no bump. | `dod-absence-checks` grep set | Structural separation confirmed by file inspection. |
| 2 | Publish-side effects removed from `Publish-DrmCopilotExtension.ps1`; `-DryRun`/`-Package` preserved | PASS | File inspection: no `npm version`/`vsce publish`/`git tag`; `-DryRun`/`-Package` parameter sets, manifest pre-flight, and `vsce ls` scan retained. | `Grep 'vsce publish\|npm version\|git tag'` -> 0 matches | `Test-ExtensionManifest` and `Get-ForbiddenPackagedFile` retained. |
| 3 | Release-PR opener bumps both manifests on a branch and opens a PR via `gh`; never publishes | PASS | `Invoke-FullRelease.ps1` lines 199-256: clean-tree check, branch create, `npm version patch --no-git-tag-version` on both manifests, commit, `gh pr create --base main`. No publish/tag. | File inspection | `Invoke-MarketplacePublish.ps1` is the extension-only counterpart. |
| 4 | Post-merge tag-push pushes `v*` and `mcp-server-v*` from committed versions behind `yes` confirmation | PASS | `Invoke-ReleaseTagPush.ps1`: `-cne 'yes'` -> exit 2; `git pull origin main`; reads both manifests; derives `v<ext>`/`mcp-server-v<mcp>`; `git tag -a` + `git push origin` for each. | File inspection lines 155-205 | Tags derived from merged manifest versions, not arbitrary input. |
| 5 | `publish-extension.yml` publishes via `vsce publish --pat`; publish step gated to push; `workflow_dispatch` present | PASS | Workflow lines 62-65: `if: startsWith(github.ref, 'refs/tags/v')` gates `npx --yes @vscode/vsce publish --pat ${{ secrets.VSCE_PAT }}`; `workflow_dispatch:` at line 7; `push: tags: ['v*']` at lines 4-6. | File inspection | Publish gated to `v*` tag refs (the `push` event class for this workflow), satisfying the gating intent. |
| 6 | `tasks.json` retargeted; labels/detail describe PR-gated/CI-published model | PASS | Diff: labels changed to "Release: Open Extension/Full Version-Bump PR" and "Release: Push Release Tags (post-merge)"; detail text describes PR-gated/CI-published model; `ReleaseTagPushConfirm` input added. | `git diff -- .vscode/tasks.json` | Three release tasks wired to the new scripts. |
| 7 | Two human-exception runbooks authored and recorded in orchestrator state | PASS | Runbooks present: `runbooks/vsce-pat-provisioning.runbook.md`, `runbooks/release-pr-merge-approval.runbook.md`. `orchestrator-state.json` `human_interaction.requirements[]` has 2 `exception` entries each with a non-empty `runbook_path` pointing to these files. | inspect `orchestrator-state.json` | DoD checkbox was unchecked in source; evidence shows it is satisfied. Checked off. |
| 8 | Pester tests added/updated; coverage thresholds met; PoshQC format->analyze->test clean | PASS | `poshqc-format.final` EXIT 0; `poshqc-analyze.final` EXIT 0 (0 findings); `poshqc-test.final` EXIT 0 (677 pass/0 fail); per-file coverage all >= 90%, overall 94.85% (`coverage-comparison.2026-06-19T21-18.md`). | `mcp__drm-copilot__run_poshqc_*` | DoD checkbox was unchecked in source; evidence shows it is satisfied. Checked off. |
| 9 | `actionlint` clean and a green run recorded for the new workflow | PASS | `actionlint.publish-extension.2026-06-19T21-18.md` EXIT 0 (0 findings); `workflow-green-run.publish-extension.2026-06-19T21-18.md` run 27857355771 conclusion success, publish step correctly skipped on `pull_request`. | `actionlint`, `gh run view 27857355771` | A green `pull_request` branch-head run satisfies `modified-workflow-needs-green-run` per the rule's `workflow_dispatch`-or-PR clause. DoD checkbox was unchecked; evidence shows it is satisfied. Checked off. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 9 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After merge, provision `VSCE_PAT` per `runbooks/vsce-pat-provisioning.runbook.md` before running the post-merge tag-push task, so the first `v*` tag actually publishes.
2. On the first real release, confirm the `publish` job's publish step executes (not skipped) when the tag ref begins with `refs/tags/v`.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules, all nine `## Definition of Done` criteria evaluated PASS. The source uses markdown checkboxes; three were previously unchecked (items 7, 8, 9) but are satisfied by inspected evidence, so they are now checked off in `spec.md`. The other six were already checked.

### AC Status Summary

- Source: `docs/features/active/separate-version-bump-from-publish-214/spec.md` (`## Definition of Done`)
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` (`## Definition of Done`) | 9 | 9 | 0 | Checkbox-backed; items 7, 8, 9 newly checked based on inspected evidence. |

Source-file checkbox change made: items 7, 8, and 9 in `spec.md` `## Definition of Done` changed from `- [ ]` to `- [x]` to reflect their PASS evaluation.
