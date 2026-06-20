# separate-version-bump-from-publish - Refactor Plan

- **Issue:** #214
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-19T21-18
- **Status:** Draft
- **Version:** 0.2

## Required References (read, do not restate)

- Spec (authoritative requirements): `docs/features/active/separate-version-bump-from-publish-214/spec.md`
- Diagnosis: `artifacts/research/release-version-bump-publish-diagnosis.2026-06-19T20-36.md`
- Reference workflow pattern: `.github/workflows/publish-mcp-npm.yml`
- PowerShell rules: `.claude/rules/powershell.md`
- General code-change and unit-test rules: `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`
- Quality tiers: `.claude/rules/quality-tiers.md`
- CI workflow authoring rule: `.claude/rules/ci-workflows.md`
- Evidence conventions: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

## Mode

- **Work Mode:** full-feature. No `issue.md` Work Mode marker exists; per mode-source precedence this fails closed to full-feature, and the presence of `spec.md` confirms full-document expectations. Full QA loop obligations apply.

## Strategy

Separate version-bump (PR-gated source change) from publish (post-merge, tag-triggered CI), per the spec end-state. PowerShell scripts are changed behind wrapper-function seams (`Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe`/`Invoke-PublishScript`) so Pester tests mock the seam, never `git`/`gh`/`npm` directly. Each PowerShell phase respects the per-batch cap of at most 3 production files and 3 test files. A new CI workflow `publish-extension.yml` mirrors `publish-mcp-npm.yml` and is gated to `push` events; it is validated with `actionlint` and a green `workflow_dispatch` run against the branch head (the `modified-workflow-needs-green-run` policy applies).

**`Invoke-MarketplacePublish.ps1` disposition (decision):** Repurpose, do not retire. It becomes the extension-only release-PR opener: single-manifest patch-bump of `extensions/drm-copilot/package.json` on a release branch, commit, and `gh pr create` via an `Invoke-GhExe` seam. Justification: (1) the existing `.vscode/tasks.json` task "Publish: Marketplace VSIX (patch + tag)" references this script; retiring would orphan the task and require its removal with no replacement extension-only path; (2) a single-manifest opener is a legitimate, smaller-scope counterpart to the both-manifest `Invoke-FullRelease.ps1` opener; (3) repurposing preserves the confirmation-token guard and an existing test surface rather than deleting and re-creating coverage. The script must not publish or tag after repurposing.

Fail-closed evidence rule: every baseline, final-QA, and coverage-comparison task names its expected artifact path under the feature `evidence/` tree. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing or incomplete, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

Evidence accounting rule: record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

EVIDENCE_LOCATION_OVERRIDE_NOTE: All evidence artifacts resolve to `docs/features/active/separate-version-bump-from-publish-214/evidence/<kind>/`. No `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/` path is used.

## Work Breakdown

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read policy files in required order and record an evidence artifact at `docs/features/active/separate-version-bump-from-publish-214/evidence/baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Binary outcome: artifact exists with all three fields populated.
- [x] [P0-T2] Capture PowerShell format baseline by running `mcp__drm-copilot__run_poshqc_format` (check-only/report mode) and write `docs/features/active/separate-version-bump-from-publish-214/evidence/baseline/poshqc-format.baseline.2026-06-19T21-18.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (files-changed count or "no changes"). Binary outcome: artifact exists with all four fields.
- [x] [P0-T3] Capture PowerShell lint baseline by running `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/separate-version-bump-from-publish-214/evidence/baseline/poshqc-analyze.baseline.2026-06-19T21-18.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (finding count by severity). Binary outcome: artifact exists with all four fields.
- [x] [P0-T4] Capture PowerShell test + coverage baseline by running `mcp__drm-copilot__run_poshqc_test` and write `docs/features/active/separate-version-bump-from-publish-214/evidence/baseline/poshqc-test.baseline.2026-06-19T21-18.md` containing `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with numeric headline values: total tests passed/failed, line coverage percent, branch coverage percent. Binary outcome: artifact exists with all four fields and numeric coverage values (not placeholders).

### Phase 1 — Publish-DrmCopilotExtension.ps1: Remove Publish-Side Effects

Batch: 1 production file (`scripts/powershell/Publish-DrmCopilotExtension.ps1`) + 1 test file.

- [x] [P1-T1] In `scripts/powershell/Publish-DrmCopilotExtension.ps1`, remove the `npm version` bump block (current lines ~192-208, the `if ($VersionBump -and $Mode -ne 'DryRun')` branch and its `npm version $VersionBump --no-git-tag-version` call) and remove the `-VersionBump` parameter from the `param()` block and the corresponding `.PARAMETER VersionBump` doc and `PSReviewUnusedParameter`/positional suppression entries no longer needed. Binary outcome: `Grep` for `npm version` and `VersionBump` in the file returns zero matches.
- [x] [P1-T2] In `scripts/powershell/Publish-DrmCopilotExtension.ps1`, remove the entire `-Publish` code path: the `Publish` parameter and its `[Parameter(ParameterSetName = 'Publish')]`, the publish confirmation/`vsce publish` block (current lines ~301-326), and the `-Tag`/`git tag` block (current lines ~328-339), including the `-Tag` parameter and its `.PARAMETER Tag` doc. Retain `-DryRun` and `-Package` parameter sets, manifest pre-flight validation, and the `vsce ls` forbidden-file scan. Binary outcome: `Grep` for `vsce publish`, `git tag`, `Read-Host`, and `\$Tag` in the file returns zero matches; `-DryRun` and `-Package` parameters remain present.
- [x] [P1-T3] Update the `.SYNOPSIS`/`.DESCRIPTION`/`.NOTES` and `.EXAMPLE` blocks in `scripts/powershell/Publish-DrmCopilotExtension.ps1` so they describe only the `-DryRun` (validate + `vsce ls`) and `-Package` (produce `.vsix`) local modes and state that Marketplace upload and tagging are performed by CI. Binary outcome: no reference to `-Publish`, `vsce login`, `-VersionBump`, or `git tag` remains in the comment-based help; file remains under 500 lines.
- [x] [P1-T4] Create `tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1` mirroring the production path, dot-sourcing functions via the existing `Import-ScriptFunction` helper at `tests/scripts/powershell/Support/TestHelpers.ps1`. Cover: (a) `-DryRun` validates manifest and does not package/publish; (b) `-Package` produces a `.vsix` path and does not invoke `vsce publish`; (c) missing manifest is reported (not silently ignored); (d) absence assertion — no code path invokes `vsce publish`, `npm version`, or `git tag`. Mock only external-tool wrapper seams or `vsce`/`npm` via injected seams introduced where needed; do not mock `git`/`gh`/`npm` directly. Binary outcome: `mcp__drm-copilot__run_poshqc_test` runs this file and all `It` blocks pass.

### Phase 2 — Invoke-FullRelease.ps1 and Invoke-MarketplacePublish.ps1: Convert to Release-PR Openers

Batch: 2 production files + 2 test files.

- [x] [P2-T1] Rewrite `scripts/dev-tools/Invoke-FullRelease.ps1` as a confirmation-gated "open release PR" task. Retain the `-ConfirmToken` guard (`-cne 'yes'` returns 2). Add an `Invoke-GhExe -GhArgs [string[]]` wrapper seam (splat into `gh @GhArgs 2>&1`). The guarded function must: verify a clean working tree via `Invoke-GitExe -GitArgs @('status','--porcelain')` (non-empty output blocks with a reported error and non-zero exit); create a release branch via `Invoke-GitExe`; patch-bump both `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json` via `Invoke-NpmExe -NpmArgs @('--prefix', <dir>, 'version', 'patch', '--no-git-tag-version')`; commit via `Invoke-GitExe`; and open a PR against `main` via `Invoke-GhExe -GhArgs @('pr','create','--base','main', ...)`. Remove all `vsce publish`, extension-publish delegation, `git tag`, and `git push` tag side effects. Binary outcome: `Grep` for `Invoke-PublishScript`, `git tag`, and tag-`push` in the file returns zero matches; `Invoke-GhExe` and `gh pr create` are present; file under 500 lines.
- [x] [P2-T2] Rewrite `scripts/dev-tools/Invoke-MarketplacePublish.ps1` as the extension-only release-PR opener. Retain the `-ConfirmToken` guard (`-cne 'yes'` returns 2). Add an `Invoke-GhExe` wrapper seam and reuse `Invoke-GitExe`/`Invoke-NpmExe` seams. The guarded function must verify clean tree, create a release branch, patch-bump only `extensions/drm-copilot/package.json`, commit, and `gh pr create` against `main`. Remove `Invoke-PublishScript` and all `-Publish`/`-VersionBump`/`-Tag` delegation. Update the comment-based help to describe the extension-only PR-opener behavior. Binary outcome: `Grep` for `Invoke-PublishScript`, `-Publish`, and `git tag` in the file returns zero matches; `gh pr create` present; file under 500 lines.
- [x] [P2-T3] Rewrite `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` to cover the new behavior, importing seams before mocking per `.claude/rules/powershell.md`. Cover: (a) `-ConfirmToken 'no'` returns 2 and invokes no `Invoke-NpmExe`/`Invoke-GitExe`/`Invoke-GhExe`; (b) on `yes`, both manifests are patch-bumped (two `Invoke-NpmExe` calls with the correct `--prefix` paths) and `Invoke-GhExe` is invoked with `pr create --base main`; (c) dirty working tree (non-empty `git status --porcelain` mock output) blocks the bump and returns non-zero before any `Invoke-NpmExe` call; (d) absence assertion — no `git tag`/tag-`push`/publish seam is invoked. Mock signatures match production named parameters (`-GitArgs`, `-NpmArgs`, `-GhArgs`). Binary outcome: `mcp__drm-copilot__run_poshqc_test` runs this file and all `It` blocks pass.
- [x] [P2-T4] Rewrite `tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1` to cover the extension-only opener. Cover: (a) `-ConfirmToken 'no'` returns 2 and invokes no seam; (b) on `yes`, only `extensions/drm-copilot/package.json` is bumped (single `Invoke-NpmExe` call) and `Invoke-GhExe` `pr create --base main` is invoked; (c) dirty tree blocks the bump; (d) absence assertion — no `Invoke-PublishScript`, `vsce publish`, or `git tag` invocation. Mock signatures match production named parameters. Binary outcome: `mcp__drm-copilot__run_poshqc_test` runs this file and all `It` blocks pass.

### Phase 3 — New Invoke-ReleaseTagPush.ps1: Post-Merge Tag Push

Batch: 1 production file + 1 test file.

- [x] [P3-T1] Create `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` as a confirmation-gated post-merge task. Include: `-ConfirmToken` param with `-cne 'yes'` returning 2; `Write-StderrLine`; `Invoke-GitExe -GitArgs [string[]]` wrapper seam; a pure `Get-NpmVersion -ManifestPath` reader; pure tag-name builders for `v<ext-version>` and `mcp-server-v<mcp-version>`; and an `Invoke-ReleaseTagPushGuarded -ConfirmToken -RepoRoot` function that updates `main` (e.g., `Invoke-GitExe -GitArgs @('pull','origin','main')`), reads the merged versions from both manifests, then creates and pushes both tags via `Invoke-GitExe`. On any seam failure, report via `Write-StderrLine` and return non-zero. Guard the entry point with the dot-source check `if ($MyInvocation.InvocationName -ne '.')`. Binary outcome: file exists, contains `Invoke-GitExe`, `v$` and `mcp-server-v$` tag derivation, and the dot-source guard; file under 500 lines.
- [x] [P3-T2] Create `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1` mirroring the production path. Cover: (a) `-ConfirmToken 'no'` returns 2 and invokes no `Invoke-GitExe`; (b) on `yes`, both tags are derived from the committed manifest versions and both pushed (two `git push` invocations via `Invoke-GitExe` with `v<ext-version>` and `mcp-server-v<mcp-version>`); (c) missing manifest is reported (not silently ignored); (d) tag-name derivation unit cases for both builders. Mock only `Invoke-GitExe` with a matching `-GitArgs` signature; never mock `git` directly. Binary outcome: `mcp__drm-copilot__run_poshqc_test` runs this file and all `It` blocks pass.

### Phase 4 — tasks.json Retarget and New publish-extension.yml Workflow

Batch: non-PowerShell config/workflow files (no PowerShell production-file budget consumed).

- [x] [P4-T1] Edit `.vscode/tasks.json`: retarget the task currently labeled "Publish: Marketplace VSIX (patch + tag)" to label "Release: Open Extension Version-Bump PR" with `detail` describing the extension-only release-PR opener (bump `extensions/drm-copilot/package.json` on a branch, open PR; no publish, no tag). Update its `input` `MarketplacePublishConfirm` `description` to reference opening a PR rather than publishing. Binary outcome: the task label and `detail` no longer contain "Marketplace VSIX (patch + tag)", "publish", or "git tag"; the task still invokes `scripts/dev-tools/Invoke-MarketplacePublish.ps1` with `-ConfirmToken`.
- [x] [P4-T2] Edit `.vscode/tasks.json`: retarget the task currently labeled "Publish: Full Release (bump both + Marketplace + npm tag)" to label "Release: Open Full Version-Bump PR" with `detail` describing the both-manifest release-PR opener (no publish, no tag push). Add a new task "Release: Push Release Tags (post-merge)" that invokes `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` with `-ConfirmToken ${input:ReleaseTagPushConfirm}`, and add a corresponding `inputs` entry `ReleaseTagPushConfirm` (pickString `no`/`yes`, default `no`, description referencing pushing `v*` and `mcp-server-v*` tags after the bump PR merges). Binary outcome: `.vscode/tasks.json` parses as valid JSON; the Full Release task `detail` no longer contains "Marketplace" or "npm tag"; the new tag-push task and its input exist.
- [x] [P4-T3] Create `.github/workflows/publish-extension.yml` mirroring `.github/workflows/publish-mcp-npm.yml`. Triggers: `push: tags: ['v*']` plus `workflow_dispatch:`. Job steps: `actions/checkout@v4` (no `ref` override, so a tag push checks out the tag commit); `actions/setup-node@v4` with `node-version: "20"`; install via `npm --prefix extensions/drm-copilot ci`; build via `npm --prefix extensions/drm-copilot run compile` (or the package's build script); package via `vsce package`; and a publish step running `vsce publish --pat ${{ secrets.VSCE_PAT }}` gated with `if: github.event_name == 'push'`. Ensure no `pwsh` step uses a deliberately-failing nested command (per `.claude/rules/ci-workflows.md`). Binary outcome: file exists; `Grep` confirms `on:` includes `tags:` `v*` and `workflow_dispatch`, the publish step has `if: github.event_name == 'push'`, and `vsce publish --pat ${{ secrets.VSCE_PAT }}` is present.

### Phase 5 — Workflow Validation (actionlint + green workflow_dispatch)

- [x] [P5-T1] Run `actionlint` on `.github/workflows/publish-extension.yml` (command: `actionlint .github/workflows/publish-extension.yml`) and write the result to `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/actionlint.publish-extension.2026-06-19T21-18.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Binary outcome: artifact exists, `EXIT_CODE: 0`, `Output Summary:` records zero findings. If non-zero, fix the workflow and re-run before marking complete.
- [ ] [P5-T2] Obtain a green `workflow_dispatch` run of `publish-extension.yml` against the branch head (the `modified-workflow-needs-green-run` policy applies). Command: `gh workflow run publish-extension.yml --ref <branch-head>` followed by `gh run watch <run-id>` (or `gh run view <run-id>`). Because the publish step is gated to `push`, the dispatch run exercises checkout/install/build/package without consuming a Marketplace version. Record `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/workflow-dispatch-green-run.publish-extension.2026-06-19T21-18.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, the workflow run URL, and `Output Summary:` (conclusion `success`, jobs/steps run, confirmation that the publish step was skipped). Binary outcome: artifact exists, records a `success` conclusion and the run URL. If the run is not green, fix and re-run before marking complete.

### Phase 6 — Final QA Loop and Coverage Comparison (PowerShell)

Run the PowerShell toolchain in order format -> analyze -> test. Restart from format if any step changes files or fails.

- [x] [P6-T1] Run `mcp__drm-copilot__run_poshqc_format` and write `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/poshqc-format.final.2026-06-19T21-18.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If files changed, re-run and restart the loop. Binary outcome: artifact exists with all four fields and a no-further-changes result recorded.
- [x] [P6-T2] Run `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/poshqc-analyze.final.2026-06-19T21-18.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (finding count by severity, must be zero errors/warnings). Binary outcome: artifact exists, `EXIT_CODE: 0`, zero findings recorded.
- [x] [P6-T3] Run `mcp__drm-copilot__run_poshqc_test` in coverage mode and write `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/poshqc-test.final.2026-06-19T21-18.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric post-change line coverage percent, branch coverage percent, and tests passed/failed. Binary outcome: artifact exists, all tests pass, line coverage >= 85% and branch coverage >= 75% recorded as numeric values.
- [x] [P6-T4] Write the coverage-comparison artifact `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/coverage-comparison.2026-06-19T21-18.md` that records: baseline line/branch coverage (from `evidence/baseline/poshqc-test.baseline.2026-06-19T21-18.md`), post-change line/branch coverage (from P6-T3), and changed-line coverage for the four changed/new scripts. The artifact must assert line >= 85%, branch >= 75%, and no regression on changed lines per `.claude/rules/general-unit-test.md`. Binary outcome: artifact exists with all three coverage figures as numeric values and an explicit no-regression-on-changed-lines determination. If any required coverage value is unavailable, the outcome is remediation-required, not PASS.
- [x] [P6-T5] Verify the Definition-of-Done absence invariants across the changed scripts and record `docs/features/active/separate-version-bump-from-publish-214/evidence/qa-gates/dod-absence-checks.2026-06-19T21-18.md`: `Grep` the four scripts to confirm no local task both bumps a tracked manifest and publishes or pushes a publish tag; confirm `vsce publish`/`npm version`/`git tag` are absent from `Publish-DrmCopilotExtension.ps1`; confirm both PR-opener scripts never publish or tag; confirm `Invoke-ReleaseTagPush.ps1` is the sole script that pushes `v*`/`mcp-server-v*`. Record each `Grep` command and its result. Binary outcome: artifact exists, every invariant marked satisfied with the supporting `Grep` output, or remediation-required with the failing check identified.

## Test Plan

- Unit (Pester): per-script tests in Phases 1-3 covering confirmation-token guard rejection of non-`yes`, both-manifest and single-manifest PR-opener bump + `gh pr create`, tag-push derivation/push of both tag names, removed publish/bump/tag side effects (absence assertions), dirty-tree block, and missing-manifest reporting. Mock only wrapper seams (`Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe`/`Invoke-PublishScript` where retained); never mock `git`/`gh`/`npm` directly.
- Workflow validation: `actionlint` clean (P5-T1) and a green `workflow_dispatch` run against branch head (P5-T2), satisfying `modified-workflow-needs-green-run`.
- Tooling: PoshQC format -> analyze -> test via MCP tools (Phase 6), restart-on-change loop.
- Coverage evidence:
  - Baseline: `evidence/baseline/poshqc-test.baseline.2026-06-19T21-18.md`
  - Post-change: `evidence/qa-gates/poshqc-test.final.2026-06-19T21-18.md`
  - Comparison: `evidence/qa-gates/coverage-comparison.2026-06-19T21-18.md`

## Rollback / Contingency

All changes are local PowerShell scripts, `.vscode/tasks.json`, and one new workflow file plus mirrored tests; revert is a single PR revert. No registry artifact is produced by the refactor itself. If the `workflow_dispatch` run cannot be made green, the workflow change is held back (the four scripts and `tasks.json` can still merge as the version-bump-PR half) and the workflow is re-validated in a follow-up.

## Open Questions / Notes

- `Invoke-MarketplacePublish.ps1` disposition resolved to "repurpose as extension-only release-PR opener" (see Strategy). If maintainers prefer retirement, that is a one-line change: delete the script, its test, and the `.vscode/tasks.json` task in P4-T1; the full-release opener then covers both manifests.
- `VSCE_PAT` provisioning and release-PR merge approval are one-time/recurring human-interaction requirements with runbooks already authored under `runbooks/`; they are recorded as `exception` items in orchestrator state and are out of scope for code execution in this plan.
