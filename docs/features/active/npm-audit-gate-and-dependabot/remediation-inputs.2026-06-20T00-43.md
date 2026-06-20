# Remediation Inputs: npm-audit-gate-and-dependabot

- Feature: npm-audit-gate-and-dependabot (no associated GitHub issue number)
- Cycle entry timestamp: 2026-06-20T00-43
- Base branch: main
- Merge-base SHA: b70045e02d0d3b6290e9ed9799d0dec5ed09425b
- Feature head SHA: 948b03ee31e8375a7a20ee328ca4949b06afdfb2

## Source Audit Artifacts

These findings originate from the review artifacts produced in this cycle:

- docs/features/active/npm-audit-gate-and-dependabot/policy-audit.2026-06-20T00-43.md (Section 8.1, Section 10)
- docs/features/active/npm-audit-gate-and-dependabot/feature-audit.2026-06-20T00-43.md (AC-7)
- docs/features/active/npm-audit-gate-and-dependabot/code-review.2026-06-20T00-43.md (no code-quality blockers)

## Blocking Findings

### BF-1: modified-workflow-needs-green-run (Blocking)

- Rule: `modified-workflow-needs-green-run` (`.claude/skills/feature-review-workflow/SKILL.md`).
- Trigger: the branch diff modifies `.github/workflows/_npm-audit-gate.yml` and `.github/workflows/npm-audit-gate.yml`, both matching `.github/workflows/**`.
- Condition: no green workflow run against the branch head (SHA 948b03ee31e8375a7a20ee328ca4949b06afdfb2) is currently observable. `gh run list --workflow=npm-audit-gate.yml` returns HTTP 404 (workflow not yet on the default branch); no PR exists for the branch yet; no prior remediation-inputs records a qualifying green run.
- Corresponding acceptance criterion: issue.md AC-7 ("A green run of the new gate is observed on the PR") — currently FAIL.
- Note: the supporting validator `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1` is not present on disk in this worktree; the rule's trigger-path and evidence-presence logic was applied textually.

## Fix List

This Blocking finding does not require any source or configuration change. The workflow and Dependabot files are already correct and verified (actionlint exit 0, YAML parse OK, npm audit exit 0 on all three manifests). The remediation is to produce and verify the green-run evidence.

- FIX-1: Open the pull request for branch `chore/npm-audit-gate` against `main`.
  - Expected behavior: the caller `npm-audit-gate.yml` has a `pull_request` path filter (`branches: [main, development]`) that includes `.github/workflows/npm-audit-gate.yml` and `.github/workflows/_npm-audit-gate.yml`. Because the PR's diff touches both gate workflow files, the PR self-triggers the `npm Audit Gate` workflow against the branch head.
  - Files involved: no edits. The trigger is already wired at `.github/workflows/npm-audit-gate.yml` lines 8-14.
  - Verification command: `gh pr checks <pr-number>` shows the `npm Audit Gate` checks; `gh run list --workflow=npm-audit-gate.yml --branch chore/npm-audit-gate` shows a run whose head SHA matches the branch head and whose conclusion is `success`.

- FIX-2 (alternative, if PR-context run is not yet available): Trigger a `workflow_dispatch` run of `npm Audit Gate` against the branch head once the workflow exists on a ref that exposes dispatch.
  - Expected behavior: a green `workflow_dispatch` run against the branch head satisfies the rule, per the explicit mitigation in `.claude/skills/feature-review-workflow/SKILL.md` for the chicken-and-egg case where a feature must land its CI gate before the gate can run in PR context.
  - Verification command: `gh run list --workflow=npm-audit-gate.yml` shows a `workflow_dispatch` run with head SHA 948b03ee31e8375a7a20ee328ca4949b06afdfb2 and conclusion `success`.

- FIX-3: After the green run is observed, record the evidence and check off AC-7.
  - Expected behavior: the green-run URL and head SHA are recorded (in remediation inputs for the next cycle, or in the feature evidence folder), then issue.md AC-7 and the Evidence Checklist "end-state" item are changed from `[ ]` to `[x]`.
  - Files involved: docs/features/active/npm-audit-gate-and-dependabot/issue.md (lines 41 and 65).
  - Verification command: `grep -nE '^- \[x\].*green run' docs/features/active/npm-audit-gate-and-dependabot/issue.md`.

## Verification Summary (for the reaudit cycle)

The exit gate clears when:
- A workflow run for `npm Audit Gate` exists whose head SHA equals 948b03ee31e8375a7a20ee328ca4949b06afdfb2 (or the then-current branch head) and whose conclusion is `success`, AND
- That green-run evidence is recorded and AC-7 is checked off.

This Blocking finding is independently re-verified by the orchestrator's S9 CI-green gate prior to merge.

## Do Not Do

- Do not edit `_npm-audit-gate.yml`, `npm-audit-gate.yml`, or `dependabot.yml` to make the green-run requirement pass; the files are already correct and verified. The remediation is producing the run, not changing the gate.
- Do not weaken the gate (for example, lowering `audit-level` below `moderate` or adding `continue-on-error`) to force a green result.
- Do not check off AC-7 before a real green run against the branch head is observed; evidence must precede check-off.
- Do not narrow scope or mark any other policy category as out of scope.
- Do not introduce new dependencies or modify production source files; this feature adds CI infrastructure only.
- Do not fabricate a GitHub issue number; use the feature folder name `npm-audit-gate-and-dependabot` for cross-references.
