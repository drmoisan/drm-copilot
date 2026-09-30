# epic-child-prs-trigger-no-ci (Issue #658)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-child-prs-trigger-no-ci/ (Issue #658)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #658
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/658
- Last Updated: 2026-09-08
- Work Mode: minor-audit

## Summary

`.github/workflows/ci.yml` is gated on `pull_request: branches: [main, development]`, which filters the PR base ref. Every epic child PR targets `epic/<slug>-integration`, so `ci.yml` and the nine reusable workflows it calls never run for a child PR. A child that reports "CI green" from its checks tab has verified nothing; only the paths-gated `publish-extension.yml` attaches checks, and a child touching only bash, PowerShell, Python, or docs paths receives zero checks.

## Acceptance Criteria

- [ ] AC-1: `.github/workflows/ci.yml` `on.pull_request.branches` lists `main`, `development`, and `"epic/**"`, and `on.push.branches` remains exactly `[main, development]`. Verified by file content of `.github/workflows/ci.yml` and by AC-4.
- [ ] AC-2: `.github/workflows/README.md` documents the `ci.yml` `pull_request` trigger branches, names `epic/**`, and states that it is included so that epic child PRs targeting `epic/<slug>-integration` run the full CI gate. Verified by file content of `.github/workflows/README.md`.
- [ ] AC-3: `.claude/skills/orchestrate/SKILL.md` S9 CI gate text states that, for a PR whose base is an `epic/<slug>-integration` branch, an empty check list (including an empty `gh pr checks --required` result) is not accepted as green; the gate must observe at least one check from the `CI` workflow on the child head SHA and require every observed `CI` check to succeed. Verified by file content of `.claude/skills/orchestrate/SKILL.md`.
- [ ] AC-4: New Pester 5 test `tests/scripts/workflows/CiWorkflow.Tests.ps1` parses `.github/workflows/ci.yml` as text (following the `on:`-block isolation pattern in `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`, with no YAML module, process launch, or temporary file) and asserts that the `pull_request` branch list contains `main`, `development`, and `epic/**`. Verified by a recorded failing run against the pre-fix `ci.yml` and a recorded passing run against the fixed `ci.yml` (via `Invoke-PoshQCTest`), both stored under `evidence/`.
- [ ] AC-5: `actionlint` reports no findings for `.github/workflows/ci.yml`. Verified by running `scripts/dev-tools/run-actionlint.ps1` and recording its output under `evidence/qa-gates/`.
- [ ] AC-6: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` is byte-identical to `.claude/skills/orchestrate/SKILL.md`. Verified by a passing run of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (pytest).
- [ ] AC-7: The `modified-workflow-needs-green-run` rule is satisfied: a `CI` workflow run whose head SHA equals the fix branch head concluded `success`. Verified at PR time by recording the run id, head SHA, and conclusion (from `gh run view`) under `evidence/`.

Out of scope: `npm-audit-gate.yml`, the `ci.yml` `push` trigger, the `epic-orchestrate` skill, and behavior changes to `Invoke-CiGateParser.ps1`.

## Environment

- OS/version: GitHub Actions, repository `drmoisan/drm-copilot`.
- Python version: not applicable.
- Command/flags used: `gh pr checks <child-pr> --required`.
- Data source or fixture: child PRs #641, #642, #644, #650, #651, #652, #653, #654 of epic #655.

## Steps to Reproduce

1. Open a PR whose base is an `epic/<slug>-integration` branch.
2. Run `gh pr checks <pr> --required`.
3. Observe `no required checks reported` and, at most, the three `publish-extension.yml` checks when `extensions/drm-copilot/**` changed.

## Expected Behavior

A child PR into an integration branch runs the same quality gates as a PR into `main`, or the epic-orchestrate skill states the substitute verification (a `workflow_dispatch` of the relevant reusable workflow against the child head SHA, read from the run log) as the mandatory S9 evidence for epic children.

## Actual Behavior

No `ci.yml` run is triggered. During epic #655 every bash child had to be instructed to dispatch `_shell-coverage.yml` manually and poll it in-turn; the parent re-read each conclusion with `gh run view` rather than trusting a checks tab that carried nothing.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
$ gh pr checks 644 --required
no required checks reported on the 'bug/cleanup-worktrees-skips-detached-head-worktrees-630-r2' branch
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The S9 CI-green gate is satisfiable vacuously for every epic child; the integration-to-main PR is the first and only real run.

## Suspected Cause / Notes

- `ci.yml` trigger filter on the base branch; the reusable workflows are reachable only through `workflow_call` from `ci.yml`.
- Adding `epic/**` (and `parallel` integration patterns, if any) to the `pull_request.branches` list would make child PRs run the full gate.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: none (workflow trigger change); a docs-validation check on the workflow README.
- [x] Integration scenario to retest: open a docs-only PR into a throwaway `epic/test-integration` branch and confirm the eleven required checks attach.
- [x] Manual verification notes: `modified-workflow-needs-green-run` applies to the change itself.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
