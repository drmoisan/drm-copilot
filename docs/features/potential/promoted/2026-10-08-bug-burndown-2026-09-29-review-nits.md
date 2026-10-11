# bug-burndown-2026-09-29-review-nits (Issue #846)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bug-burndown-2026-09-29-review-nits/ (Issue #846)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #846
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/846
- Last Updated: 2026-10-08
## Summary

The feature reviews for parallel run `bug-burndown-2026-09-29` recorded non-blocking Minor, Nit, and Info findings that were accepted at merge and not fixed. This entry collects the remaining items by originating issue so they can be closed in one pass. None of them changes runtime behavior on its own.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (review host); findings are platform-independent
- Python version: repository Poetry environment
- Command/flags used: code reading of the review artifacts; `wc -l` / `Get-Content | Measure-Object` line counts on main
- Data source or fixture: main at `fb413fce`; review artifacts under `docs/features/active/<item>/` (`code-review.*`, `policy-audit.*`, `feature-audit.*`)

## Steps to Reproduce

1. Open each cited review artifact at the line given below.
2. Open the cited production, test, or documentation file at the given location on main.
3. Confirm the finding still holds.

## Expected Behavior

Each accepted Minor or Nit finding is either fixed or explicitly closed, and the documentation and evidence for each item match the delivered state.

## Actual Behavior

**#734 (quality-tiers.yml), `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/code-review.2026-10-02T03-55.md`**
- CR-1 (line 34): `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry` at `tests/scripts/dev_tools/test_quality_tiers_contract.py:434` has no `-> None`. A shorter name would fit the annotation within 88 columns.
- CR-2 (line 35): `scripts/dev_tools/quality_tiers_contract.py` lines 124, 155, and 199 are uncovered (non-scalar mapping key, non-integer or `bool` `version`, missing `projects` key).
- CR-3 (line 36): `tests/scripts/dev_tools/test_quality_tiers_contract.py` is 495 lines against the 500-line limit (re-counted on main: 495).
- CR-4 (line 37): `scripts/dev_tools/check_quality_tiers.py:90-94` captures git stderr, but the QT009 `OSError` message reports only the exit code.

**#744 (completion-gate and tooling friction), `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/`**
- CR-1 (`code-review.2026-10-02T02-55.md:24`): `.claude/skills/acceptance-criteria-tracking/SKILL.md` (and the `.agents` and `.github` copies and mirrors), section `### When Orchestrators Enforce AC Tracking`: "Orchestrators do not directly check off AC items." has no cross-reference to the `### CI-Dependent Criteria` exception. Deferred to follow-up by the remediation plan.
- PA-2 (`policy-audit.2026-10-02T02-55.md:279`): `evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md` and `evidence/other/ac-status-summary-local.2026-09-30T03-18.md` carry no `Command:` / `EXIT_CODE:` rows.
- CR-5 (`code-review.2026-10-02T02-55.md:25`): `evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md:3` records `Timestamp: 2026-10-02T01-44`, later than the file's last write (01:43:48); the error is under one minute.

**#647 (test-tree typecheck), `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/code-review.2026-10-02T00-54.md:38`**
- CR-3: `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts` and `extensions/drm-copilot/test/subagent-tree-command.test.ts` are each exactly 500 lines (re-counted on main: 500 and 500). Both need a split before the next edit.

**#623 (promotion receipt destination), `docs/features/active/promotion-receipt-destination-unverified-623/code-review.2026-09-30T09-09.md`**
- Line 41: `test_file_system_protocol_members_declare_no_behavior` (`tests/scripts/dev_tools/test_potential_to_issue_filesystem.py:207-235`) exists only to cover the `->exit` arcs of one-line Protocol placeholder methods. The review recommends a repository-wide coverage configuration for one-line Protocol stubs.
- Line 42: plan P5-T3 (`plan.2026-09-29T19-06.md:228`) still says "exactly seven tests" (eight at HEAD), and the plan header at line 7 still reads "Draft (revision 1.2 ... pending ... preflight round 3)".
- Line 43: the Python `PromotionOutcome` docstring (`scripts/dev_tools/potential_to_issue.py:196-218`) and line 469 lack the exit-code-1 note and rationale comment that the TypeScript side has (`promotion.ts:88`, `:440-442`).

**#764 (feature-review skill validator citation), `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/code-review.2026-09-30T10-15.md`**
- Line 34: P1-T1 and P1-T2 acceptance commands (`plan.2026-09-30T05-00.md:39-40`, also line 66) use `git grep -nxF`; `git grep` has no `-x` switch and exits 129.
- Line 35: evidence filenames carry `2026-09-30T05-20` while their `Timestamp:` fields read 09-47 to 09-58.
- Line 36: `issue.md:5` `Status: Promoted -> docs/features/active/feature-review-skill-cites-nonexistent-validator/` names a folder that does not exist (no date prefix or issue suffix).

**#338 (IDE launcher audit gaps), `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/`**
- CR-1 (`code-review.2026-10-08T07-05.md:35`): AC-3 names `test/lib/new-active-feature-folder/io.test.ts`, but the tests are in `io-launcher.test.ts`; the AC-3 command does not run that file.
- Advisory A1 (`policy-audit.2026-10-08T07-05.md:101`, `:355`): the Python coverage artifact covers only the two changed modules; no whole-repository Python figure was produced.
- CR-3 (`code-review.2026-10-08T07-05.md:37`): the issue text refers to bundled mirror copies of the two Python modules; none exist at this commit. The issue text should be corrected.
- Residual risk (`feature-audit.2026-10-08T07-05.md:71`): live Windows observation of `code --reuse-window` window reuse was never performed; closed as `scope_change` under AC-5.

**#609 (bash lane assertion newline edges), `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/`**
- `code-review.2026-10-02T04-20.md:47` and `policy-audit.2026-10-02T04-20.md:277`: four point-in-time files still describe AC-6 and AC-14 as open: `evidence/other/ac-gaps.2026-09-29T18-45.md`, `evidence/other/ac-status-summary.2026-09-29T18-45.md`, `evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md`, and `evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md`. No superseding summary exists.

**#543 (epic planner ready gate), `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/code-review.2026-10-07T09-34.md:49`**
- CR-11: `evidence/other/python-batch-budget.2026-10-02T05-01.md` lines 3-4 give a header time of `2026-10-02T05-18`, about 4 minutes after commit `0c6abb95` (05:14:57) that first contained the row, so the "upper bound on the write time" claim on line 4 does not hold for that row.

**#527 (PoshQC coverage denominator), `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/code-review.2026-10-02T05-34.md:38`**
- The consumer-visible change (coverage roots moved to `config/poshqc-coverage.json`) is documented in `scripts/powershell/PoshQC/README.md` but has no `[Unreleased]` entry in `extensions/drm-copilot/CHANGELOG.md`. The entry was deferred.

**#510 (claude resource parity), `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/code-review.2026-10-07T15-30.md:37`**
- `spec.md` is stale: lines 45 and 61 cite `.gitignore` lines 21/67/68 (actual 23/69/70); acceptance criterion 11 (line 174) names a rc file under `evidence/coverage/` while the file is at the canonical `evidence/other/coveragerc-helper.ini`; and line 7 still reads `Status: Draft` with all 13 criteria checked.

**#723 (npm publish verify window), `docs/features/active/2026-09-27-npm-publish-verify-window-too-short-723/code-review.2026-10-01T22-30.md`**
- The optional refinement of using the publish step's own success as the primary signal (the error message currently asserts the "publish step succeeded" token as a fact) was left out of scope: `issue.md:60` ("Consider checking the publish step's own output as the primary success signal") and `research/research.2026-09-29T21-40.md:123` ("Possible future refinement (out of scope)"). Related non-blocking notes in the same review: N1 (line 28, the runbook does not give the `npm view` command) and N3 (line 30, the `(?m)^\s*exit 1\s*$` assertion would match any standalone `exit 1` in the step).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: line counts on main `fb413fce`: `test_quality_tiers_contract.py` 495; `orchestration-handoff-authority-service.test.ts` 500; `subagent-tree-command.test.ts` 500.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Maintainability and documentation accuracy. Three test files have zero to five lines of headroom under the 500-line limit, so the next edit to any of them must include a split.

## Suspected Cause / Notes

The items were accepted as non-blocking during review so the run could merge. Several of them (evidence timestamps not read from the clock, stale point-in-time evidence, plan text not updated after a deviation) recur across items and share a process cause rather than a code cause.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add the #734 CR-2 negative cases; split the three near-limit test files before further edits; decide the #623 Protocol-stub coverage approach repository-wide.
- [ ] Integration scenario to retest: re-run the #764 acceptance commands with a valid `git grep` form.
- [ ] Manual verification notes: correct the stale documentation (#510 spec, #764 issue.md Status, #623 plan, #338 AC-3 and issue text, #744 skill sentence); add superseding summaries rather than editing timestamped evidence (#609, #543, #744); add the #527 CHANGELOG entry.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
