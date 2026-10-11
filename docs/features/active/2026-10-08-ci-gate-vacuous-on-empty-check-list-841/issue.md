# ci-gate-vacuous-on-empty-check-list (Issue #841)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-gate-vacuous-on-empty-check-list/ (Issue #841)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #841
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/841
- Last Updated: 2026-10-08
- Work Mode: full-bug

## Summary

The S9 CI gate can conclude `success` on an empty check list. `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` maps an empty or null check set to `success`, so the epic-child rule added by #658 (PR #837, merge `6dac65b0`), which requires at least one `CI` check, is enforced only by skill prose. Two related rule-text gaps were recorded by the same review: the S9 step 3 wording still says "required checks" (CR-4), and the `modified-workflow-needs-green-run` rule requires a green run on the exact branch head, which committed evidence can never meet (PA-N9).

## Environment

- OS/version: Windows 11 Pro; any host that runs the S9 gate
- Python version: n/a (PowerShell parser and skill text)
- Command/flags used: `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson '[]' -HeadSha <sha>`; `gh pr checks --json bucket,name,state,link,workflow`
- Data source or fixture: #658 review artifacts on main fb413fce: `docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/code-review.2026-10-08T03-15.md` (CR-1, CR-4), `policy-audit.2026-10-08T03-15.md` (N-1, PA-N9), `remediation-inputs.2026-10-08T03-15.md` lines 23, 25, 27

## Steps to Reproduce

1. CR-1: run `Invoke-CiGateParser.ps1` with `-ChecksJson '[]'` (the result `gh pr checks --required` returns for a PR into an `epic/<slug>-integration` branch, which has no required-status-check protection). Observe `ci_gate.conclusion: success`. The existing test `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1:91` ("returns success for an empty required-check array (vacuous satisfaction)") pins this behavior.
2. CR-4: read `.claude/skills/orchestrate/SKILL.md` lines 289-293. Step 2's epic-child paragraph (line 291) runs the query without `--required`, while step 3 (line 293) still defines the conclusion in terms of "required checks".
3. PA-N9: read `.claude/skills/feature-review-workflow/SKILL.md` lines 70-75. Commit an evidence file that records a green run, then re-run the policy audit on the new head.

## Expected Behavior

- CR-1: for an epic child, the parser (or an opt-in parameter passed by S9 when `epic_mode` is true) refuses `success` unless at least one check with `workflow == CI` is observed and every observed `CI` check passed, matching the rule at `orchestrate/SKILL.md:291`.
- CR-4: step 3 describes the conclusion over the checks actually queried, and the rule states whether failing non-`CI` checks on an epic child are ignored or must pass.
- PA-N9: the rule text defines a satisfiable condition for committed evidence, for example the three conditions of the orchestrator ruling applied in the #658 review.

## Actual Behavior

- CR-1: `Invoke-CiGateParser.ps1` lines 22-23 (help text) and 130-133 (`if ($null -eq $Checks -or $Checks.Count -eq 0) { return 'success' }`) return `success` for an empty set. The epic-child requirement at `orchestrate/SKILL.md:291` ("An empty check list ... is not accepted as green") has no mechanical enforcement. Verified by reading the file on main fb413fce (330 lines).
- CR-4: `orchestrate/SKILL.md:293` reads "derives `ci_gate.conclusion` as `success` when all required checks pass, `failure` when any required check failed, and `pending` when any required check is still in progress", and line 307 describes `head_sha` as "the PR head SHA that the required checks were observed against". The treatment of non-`CI` checks on an epic child is unstated. The same text is in the bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md:289-307`.
- PA-N9: `feature-review-workflow/SKILL.md:73` defines a qualifying run as one "whose head SHA matches the current branch head". An in-repo evidence artifact cannot name the SHA of the commit that contains it, so the condition fails as soon as the evidence is committed. The #658 review cleared its Blocker B-1/CR-2 only through a per-run orchestrator ruling (`policy-audit.2026-10-08T03-15.md:372-382`); the rule text does not contain that ruling.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `code-review.2026-10-08T03-15.md:28`: "The S9 epic-child rule is still enforced only by prose. `Invoke-CiGateParser.ps1` returns `success` for an empty check set (CR-1, Non-blocking, out of scope)." `policy-audit.2026-10-08T03-15.md:395`: "PA-N9 ... the `modified-workflow-needs-green-run` rule text is SHA-exact and cannot be met by committed in-repo evidence once any later commit lands."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

An orchestrator that runs S9 mechanically on an epic child with zero checks records `ci_gate.conclusion: success`, which is the vacuous-green defect class #658 targeted. PA-N9 makes the review rule depend on a per-run ruling each time a workflow-modifying branch commits its evidence.

## Suspected Cause / Notes

- #658 declared parser changes out of scope (`issue.md` line 28 of the #658 folder), so the epic-child rule was added as prose only.
- The empty-set-is-success mapping was a deliberate design choice for `--required` queries on protected branches; it is not wrong for that case, which is why an opt-in guard is preferable to changing the default.
- Orchestrator ruling text applied in the #658 review (`policy-audit.2026-10-08T03-15.md:374`): AC-7 passes when the recorded run covers the latest head containing any non-feature-folder change, every later commit touches only feature-folder paths, and the S9 gate obligation is stated.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add an opt-in parameter to `Invoke-CiGateParser.ps1` (for example `-RequireWorkflow CI`) that returns `failure` or `pending` when no check of that workflow is present; Pester cases for empty set, non-`CI`-only set, and mixed set with a failing `CI` check. Keep the existing vacuous-success test for the default path.
- [ ] Integration scenario to retest: S9 on a PR into an `epic/<slug>-integration` branch passes `-RequireWorkflow CI` when `epic_mode` is true; update `orchestrate/SKILL.md` step 3 wording (CR-4) and its bundle mirror together.
- [ ] Manual verification notes: codify the three ruling conditions in `feature-review-workflow/SKILL.md` lines 70-75 (PA-N9) and confirm the bundle-parity test still passes.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
