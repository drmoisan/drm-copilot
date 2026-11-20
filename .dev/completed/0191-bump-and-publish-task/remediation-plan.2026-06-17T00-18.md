# Remediation Plan: bump-and-publish-task (Issue #191)

- Entry Timestamp: 2026-06-17T00-18
- Feature Folder: `docs/features/active/2026-06-16-bump-and-publish-task-191`
- Work Mode: minor-audit
- Base Branch: `main`
- Plan Contract: `.claude/skills/atomic-plan-contract/SKILL.md`
- Requirements Source: `docs/features/active/2026-06-16-bump-and-publish-task-191/issue.md` (`## Acceptance Criteria`, six criteria, all checked; not altered by this plan)
- Remediation Inputs: `docs/features/active/2026-06-16-bump-and-publish-task-191/remediation-inputs.2026-06-17T00-18.md`

## Scope

Two findings from the feature-review cycle. Both are policy/evidence gaps; all six acceptance criteria pass at the code level and are not modified.

- F1 (BLOCKING): satisfy `modified-workflow-needs-green-run` for `.github/workflows/publish-mcp-npm.yml` by adding a verification-only `workflow_dispatch` path that exercises the changed steps without publishing.
- F2 (PARTIAL): record an explicit, policy-sanctioned branch-coverage tooling-limitation exception in `evidence/qa-gates/coverage-delta.md`.

Languages in scope: GitHub Actions (workflow YAML, validated by actionlint) and PowerShell (evidence documentation only; no PowerShell production or test code change).

## Constraints (Do-Not-Do)

- Do not narrow scope; scope is the full branch diff vs `main`.
- Do not weaken or modify any policy document under `.claude/rules/` or `.github/instructions/`.
- Do not lower coverage thresholds in `quality-tiers.md` or `general-unit-test.md`.
- Do not remove or disable the `modified-workflow-needs-green-run` rule or its validator.
- Do not mock raw `git`/`npm`; preserve wrapper seams. Do not introduce temp files or a permanent dot-source coverage harness.
- Do not push the `mcp-server-v*` release tag or publish any artifact during verification.
- All evidence under `<FEATURE>/evidence/<kind>/` only.
- Do not alter the six acceptance criteria or their checked state in `issue.md`.

## Evidence Location Invariant

All evidence artifacts in this plan resolve to `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/<kind>/`, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No non-canonical `artifacts/...` evidence path is used.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the required order from `.claude/skills/policy-compliance-order/SKILL.md` (`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/ci-workflows.md`, `.claude/rules/quality-tiers.md`) and record the read in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/remediation-baseline/phase0-instructions-read.md`. Acceptance: artifact exists and contains `Timestamp:`, `Policy Order:`, and an explicit list of every file read in order.

- [x] [P0-T2] Capture the pre-change content state of `.github/workflows/publish-mcp-npm.yml` (current `on:` triggers, the `publish` job `permissions` block, and the `Publish to npm` step) into `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/remediation-baseline/workflow-prechange.md`. Acceptance: artifact exists and contains `Timestamp:`, `Command:` (the read command or `git show HEAD:.github/workflows/publish-mcp-npm.yml`), `EXIT_CODE:`, and an `Output Summary:` recording that `on:` is `push: tags: mcp-server-v*` only and that no `workflow_dispatch` trigger is present.

- [x] [P0-T3] Capture the baseline actionlint result for the workflow by running `actionlint .github/workflows/publish-mcp-npm.yml` and record it in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/remediation-baseline/actionlint.md`. Acceptance: artifact exists with `Timestamp:`, `Command: actionlint .github/workflows/publish-mcp-npm.yml`, `EXIT_CODE:`, and `Output Summary:` recording the finding count for the pre-change workflow.

---

### Phase 1 — Remediation (F1 workflow dispatch path; F2 coverage-exception evidence)

- [x] [P1-T1] In `.github/workflows/publish-mcp-npm.yml`, add a `workflow_dispatch:` trigger to the `on:` block while preserving the existing `push: tags: - "mcp-server-v*"` trigger. Acceptance: the `on:` block contains both `workflow_dispatch:` and the unchanged `push.tags` entry `mcp-server-v*`; no other trigger is added or removed.

- [x] [P1-T2] In `.github/workflows/publish-mcp-npm.yml`, guard the `Publish to npm` step (currently `run: npm publish --provenance --access public`, `working-directory: packages/mcp-server`) by adding `if: github.event_name == 'push'` to that step only. Acceptance: the `Publish to npm` step carries `if: github.event_name == 'push'`; the step's `run:` value remains exactly `npm publish --provenance --access public`; its `working-directory` and `env.NODE_AUTH_TOKEN` are unchanged; no other step in the workflow receives an `if:` condition.

- [x] [P1-T3] Confirm the provenance and permission elements are intact in `.github/workflows/publish-mcp-npm.yml`: the `publish` job retains `permissions:` with `id-token: write` and `contents: read`, and the publish step retains `--provenance --access public`. Acceptance: a read of the workflow confirms both elements present and unchanged from their pre-change values recorded in P0-T2.

- [x] [P1-T4] Re-lint the amended workflow by running `actionlint .github/workflows/publish-mcp-npm.yml` and record the result in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/actionlint.md` (overwrite the existing file). Acceptance: artifact contains `Timestamp:`, `Command: actionlint .github/workflows/publish-mcp-npm.yml`, `EXIT_CODE: 0`, and an `Output Summary:` confirming zero findings for the workflow now containing the `workflow_dispatch` trigger and the `if: github.event_name == 'push'` guard.

- [x] [P1-T5] Update `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/coverage-delta.md` to record the F2 branch-coverage tooling-limitation exception. The update must state: (a) the repo's mandated PowerShell coverage tool (Pester via PoshQC, CoverageGutters XML format) emits no `type="BRANCH"` counter, a repo-wide condition that affects the baseline equally (baseline emits no branch counter either), so there is no branch-coverage regression; (b) new-code line coverage is 88.0%, which exceeds the >= 85% threshold; (c) for this repository's PowerShell toolchain, line coverage plus per-branch enumeration is the accepted standard because the tool does not emit branch metrics. Acceptance: the file contains these three statements and retains the prior numeric coverage values (baseline LINE 96.83%, new-code LINE 88.0%).

- [x] [P1-T6] In `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/coverage-delta.md`, include the per-branch enumeration of the decision points in `scripts/dev-tools/Invoke-FullRelease.ps1`, mapping each branch to the Pester test that exercises it: the `-cne 'yes'` guard (covered by `ConfirmToken 'no'`, `'YES'`, `'Yes'` cases returning 2), missing publish script (`Test-Path` false returns 1), npm-bump failure (`$bumpExit -ne 0`), publish failure (`$publishExit -ne 0`), tag-create failure (`$tagCreateExit -ne 0`), tag-push failure (`$tagPushExit -ne 0`), the success path (returns 0), and both `throw` branches of `Get-NpmVersion` (missing manifest, empty version). Acceptance: each enumerated decision point in `Invoke-FullReleaseGuarded` and `Get-NpmVersion` is listed with its covering test from `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` or the targeted coverage harness; the enumeration asserts that all decision branches are exercised.

- [x] [P1-T7] Confirm no policy document was modified during remediation: `quality-tiers.md`, `general-unit-test.md`, any file under `.claude/rules/`, and any file under `.github/instructions/` are unchanged. Record the confirmation in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/policy-untouched.md`. Acceptance: artifact contains `Timestamp:`, `Command: git status --porcelain .claude/rules .github/instructions quality-tiers.yml`, `EXIT_CODE:`, and an `Output Summary:` confirming no policy file appears in the change set and no threshold was lowered.

- [x] [P1-T8] Create the green-run placeholder evidence file `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/workflow-green-run.md`. The file must state that the actual green `workflow_dispatch` run against branch head (push branch, `gh workflow run`, poll, record run URL/head SHA/conclusion) is performed by the orchestrator, not the executor, because the executor has no `gh` access, and must reserve labeled placeholder fields for the orchestrator to populate: `Workflow:`, `Head SHA:`, `Run URL:`, and `Conclusion: success`. Acceptance: artifact exists, contains `Timestamp:`, the orchestrator-responsibility note, and the four labeled placeholder fields; the executor does not push the branch, invoke `gh`, or publish any artifact.

---

### Phase 2 — Final QC

- [x] [P2-T1] Run formatting via PoshQC and record the result in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/poshqc-format.md` (overwrite). Command: `mcp__drm-copilot__run_poshqc_format`. Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` confirming no PowerShell file required reformatting (no PowerShell production code changed in this remediation; formatting is verified to remain clean). If formatting changes any file, restart the loop from P2-T1.

- [x] [P2-T2] Run linting via PoshQC and record the result in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/poshqc-analyze.md` (overwrite). Command: `mcp__drm-copilot__run_poshqc_analyze`. Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` confirming zero PSScriptAnalyzer findings. If linting fails or changes files, restart the loop from P2-T1.

- [x] [P2-T3] Run the Pester suite with coverage via PoshQC and record the result in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/poshqc-test.md` (overwrite). Command: `mcp__drm-copilot__run_poshqc_test`. Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and an `Output Summary:` recording numeric coverage (repo-wide pinned-scope LINE coverage value and pass/fail counts). The recorded LINE coverage must remain at or above the baseline value (96.83%) captured in `evidence/baseline/poshqc-test.md`. If tests fail or change files, restart the loop from P2-T1.

- [x] [P2-T4] Re-run `actionlint .github/workflows/publish-mcp-npm.yml` as the final GitHub Actions QC gate and confirm it matches the P1-T4 evidence (overwrite `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/actionlint.md` if the value changed). Acceptance: `EXIT_CODE: 0` with zero findings for the amended workflow; the evidence file is consistent with the workflow on disk.

- [x] [P2-T5] Verify the final coverage-delta threshold conclusion in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/coverage-delta.md`: baseline LINE 96.83%, post-change repo-wide LINE unchanged, new-code LINE 88.0% (>= 85% PASS), branch metric not emitted by tooling with the sanctioned tooling-limitation exception and per-branch enumeration recorded. Acceptance: the file's Outcome section states PASS with the branch-coverage exception explicitly documented and no threshold lowered.

- [x] [P2-T6] Confirm the two findings are resolved at executor scope and the green-run placeholder is in place for orchestrator population. Record the end-state summary in `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/qa-gates/remediation-end-state.md`. Acceptance: artifact contains `Timestamp:`, a per-finding status line (F1: workflow dispatch path added, actionlint EXIT 0, green-run placeholder created for orchestrator; F2: coverage exception recorded with branch enumeration), and confirmation that no release tag was pushed and no artifact was published during remediation.
