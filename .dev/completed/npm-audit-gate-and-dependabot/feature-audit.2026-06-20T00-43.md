# Feature Audit: npm-audit-gate-and-dependabot

- Feature: npm-audit-gate-and-dependabot (no associated GitHub issue number)
- Date: 2026-06-20T00-43
- Work Mode: minor-audit
- Reviewer: feature-review agent

## Scope and Baseline

- Base branch: main
- Merge-base SHA: b70045e02d0d3b6290e9ed9799d0dec5ed09425b
- Feature head SHA: 948b03ee31e8375a7a20ee328ca4949b06afdfb2
- Range: b70045e02d0d3b6290e9ed9799d0dec5ed09425b..948b03ee31e8375a7a20ee328ca4949b06afdfb2

This audit evaluates the feature branch against its baseline (main at the merge-base). Work Mode is `minor-audit`, so the authoritative acceptance-criteria source is the explicit `## Acceptance Criteria` section in `docs/features/active/npm-audit-gate-and-dependabot/issue.md`. No GitHub issue number is associated with this feature; cross-references use the feature folder name.

Changed files (five total):
- .github/workflows/_npm-audit-gate.yml (+54/-0)
- .github/workflows/npm-audit-gate.yml (+21/-0)
- .github/dependabot.yml (+67/-0)
- docs/features/active/npm-audit-gate-and-dependabot/issue.md (+71/-0)
- docs/features/active/npm-audit-gate-and-dependabot/plan.2026-06-19T20-37.md (+53/-0)

No production source files changed.

## Acceptance Criteria Inventory

Source: `docs/features/active/npm-audit-gate-and-dependabot/issue.md`, `## Acceptance Criteria` section. Seven criteria:

- AC-1: `_npm-audit-gate.yml` declares both `workflow_call` and `workflow_dispatch` and audits all three manifests via matrix.
- AC-2: `npm-audit-gate.yml` triggers on `schedule`, path-filtered `pull_request`, and `workflow_dispatch`, and calls the reusable workflow.
- AC-3: The gate runs `npm ci` (lockfile sync check) before `npm audit` for each manifest.
- AC-4: `.github/dependabot.yml` configures weekly grouped npm updates for `/`, `/extensions/drm-copilot`, `/packages/mcp-server`, and github-actions.
- AC-5: All workflow YAML passes `actionlint` and parses as valid YAML.
- AC-6: The gate passes against the current (remediated) lockfiles: `npm audit --audit-level=moderate` exits 0 for all three manifests.
- AC-7: A green run of the new gate is observed on the PR (satisfies `modified-workflow-needs-green-run`).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | `_npm-audit-gate.yml` lines 4 and 13 declare `workflow_call` and `workflow_dispatch`. Lines 27-34 declare `strategy.matrix.manifest` with three entries: `.`, `extensions/drm-copilot`, `packages/mcp-server`. |
| AC-2 | PASS | `npm-audit-gate.yml` declares `schedule` (cron `0 7 * * 1`, lines 4-7), path-filtered `pull_request` (lines 8-14), and `workflow_dispatch` (line 15). Job uses `./.github/workflows/_npm-audit-gate.yml` (line 19). |
| AC-3 | PASS | `_npm-audit-gate.yml` step "Install from lockfile (verifies lockfile/manifest sync)" runs `npm ci` (lines 46-48) before the "Audit dependencies" step (lines 50-54), per matrix manifest. |
| AC-4 | PASS | `dependabot.yml` configures four `updates` entries: npm for `/`, `/extensions/drm-copilot`, `/packages/mcp-server`, and github-actions for `/`. Each is weekly (Monday 07:00 UTC) with a catch-all `groups` block and `open-pull-requests-limit: 5`. |
| AC-5 | PASS | Independently confirmed: `actionlint` on both workflows exits 0; `python -c "import yaml; ..."` parses all three files. |
| AC-6 | PASS | Independently confirmed: `npm audit --audit-level=moderate` exits 0 in `.`, `extensions/drm-copilot`, and `packages/mcp-server`. |
| AC-7 | FAIL | No green workflow run against the branch head (SHA 948b03ee31e8375a7a20ee328ca4949b06afdfb2) is currently observable. `gh run list --workflow=npm-audit-gate.yml` returns HTTP 404 (workflow not yet on default branch); no PR exists yet. This is the same condition as the policy audit's Blocking `modified-workflow-needs-green-run` finding. Expected to clear via the PR's own CI, verified by the orchestrator's S9 CI-green gate prior to merge. |

## Summary

Six of seven acceptance criteria PASS with independently confirmed evidence. AC-7 (green run observed on the PR) is FAIL at review time because the green run is produced by the introducing PR's own CI, which has not run yet. This is the intended sequence for a CI gate that must land before it can run in PR context, and it corresponds to the single Blocking policy finding (`modified-workflow-needs-green-run`).

The implementation matches the stated intent: a reusable matrix-based npm audit gate, a thin caller wiring schedule/PR/dispatch triggers, and Dependabot configuration for three npm directories plus github-actions. No code-quality blockers were found.

Overall feature verdict: PARTIAL — 6/7 AC PASS, AC-7 pending the PR green run. Not ready to merge until the green-run evidence is produced and verified by S9.

### Acceptance Criteria Status
- Source: docs/features/active/npm-audit-gate-and-dependabot/issue.md
- Total AC items: 7
- Checked off (delivered): 6
- Remaining (unchecked): 1
- Items remaining: AC-7 "A green run of the new gate is observed on the PR (satisfies `modified-workflow-needs-green-run`)"

## Acceptance Criteria Check-off

AC-1 through AC-6 are evaluated PASS and were already marked `[x]` in `issue.md` by the executor; their checked state is confirmed consistent with the verified evidence. AC-7 is FAIL and correctly remains `[ ]`. No check-off changes were made to `issue.md`: the six passing items were already checked, and the one failing item must remain unchecked per the check-off protocol (evidence before check-off; leave unmet items unchecked). The related Evidence Checklist item "end-state — green `npm Audit Gate` run observed on the PR" also correctly remains `[ ]`.
