# ci-green-gate-ignores-non-required-check-failures (Issue #899)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-green-gate-ignores-non-required-check-failures/ (Issue #899)
- Origin: parallel run bug-burndown-2026-10-08 (PRs #859-#862); process defect observed by the coordinator

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #899
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/899
- Last Updated: 2026-10-11
## Summary

Child orchestrators report "CI green" when only the branch's required checks pass. The orchestrate skill's S9 CI Green Gate queries `gh pr checks --required` for non-epic PRs, so failing non-required checks (in this run, both `NPM Audit Gate` jobs) do not prevent a "green" report. The parallel orchestrator accepts the child's report without re-reading all checks. The operator had to intervene mid-run to require a positive assertion over every check.

## Environment

- OS/version: GitHub Actions; repository ruleset for `main` with 11 required contexts (`gh api repos/drmoisan/drm-copilot/rules/branches/main`); `NPM Audit Gate / *` is not required
- Python version: n/a
- Command/flags used: `gh pr checks --required --json bucket,name,state,link,workflow` (orchestrate S9.2)
- Data source or fixture: `artifacts/orchestration/parallel-orchestrator-state.json` in the run worktree `2026-10-08T08-00-parallel-bug-burndown`

## Steps to Reproduce

1. Open a non-epic PR where all required checks pass and a non-required check fails.
2. Let a child orchestrator reach S9 and evaluate the CI Green Gate.
3. Observe the child's DONE report and the parent's acceptance.

## Expected Behavior

"CI green" means every check on the PR head passed or was skipped, or the report explicitly states "required checks green; N non-required checks failing" so the coordinator can decide. A parent orchestrator does not merge on a report that hides failing checks.

## Actual Behavior

- `.claude/skills/orchestrate/SKILL.md:292` (S9.2) invokes `gh pr checks --required ...`; line 296 returns `success` "when every queried check passed or was skipped". Only epic children query without `--required` (line 294).
- `.claude/skills/parallel-orchestrate/SKILL.md:373-380` accepts child DONE as "checks are green" and re-reads `gh pr checks` only "when the check conclusion must be re-read".
- In this run, PR #862 (#798) at head `8f90c41c` was recorded as "child reported green; gh shows 2 audit failures": `NPM Audit Gate / npm audit (.)` and `(extensions/drm-copilot)` both `failure` at 2026-10-09T08:28Z. PRs #859, #860 and #861 had the same two failures at their heads (state-file lines 19, 23, 25, 26).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/qa-gates/ci-run-37900002916.2026-10-09T07-51.md:6`: "All 11 required checks passed. The overall run conclusion is `failure` only because of the two non-required NPM Audit Gate jobs."
- Snippet: parallel-orchestrator-state.json line 27 (2026-10-09T08:45Z), operator correction: "do not merge items past failing audit jobs ... re-check ALL checks positively". Later entries read `ci_green_all_20_checks_positive_assertion`.
- Note: these PRs show all checks passing today because they were re-run after the handlebars audit fix (#864, PR #865); the failures are visible only on the earlier head SHAs.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. A PR can be merged with failing security-audit checks while the orchestration records it as green. Merges were stopped only by operator intervention.

## Suspected Cause / Notes

- The gate was designed around branch protection; the word "green" in reports does not distinguish required-only from all checks.
- `.agents/skills/orchestrate/SKILL.md` (Codex) uses "required GitHub checks" wording as well.

## Proposed Fix / Validation Ideas

- [ ] Change S9 to evaluate all checks on the head SHA (or report required and non-required results separately and treat any failure as not-green unless the coordinator waives it in the checkpoint).
- [ ] Require the parallel and epic orchestrators to re-read all checks on the head SHA before merging, rather than accepting a child's "green".
- [ ] Unit coverage areas: `Invoke-CiGateParser` cases with a failing non-required check.
- [ ] Integration scenario to retest: a PR with a failing non-required job is reported not-green by the child and not merged by the parent.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch