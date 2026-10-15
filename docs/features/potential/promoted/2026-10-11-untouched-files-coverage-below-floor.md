# untouched-files-coverage-below-floor (Issue #884)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/untouched-files-coverage-below-floor/ (Issue #884)
- Origin: issue #824 follow-ups (PR #879), policy-audit finding PA-7; parallel run bug-burndown-2026-10-08

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #884
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/884
- Last Updated: 2026-10-11
## Summary

Two production files that no recent change touched are below the repository's uniform 85% line-coverage floor: `.claude/lib/bash/compute-concurrency-batches.sh` at 81.82% (kcov) and `.codex/hooks/validate-feature-review-coverage.ps1` at 7.30% (Pester, 10 of 137 lines). The repository-wide aggregates remain above 85%, so no gate fails, but both files individually violate `.claude/rules/quality-tiers.md` and no open issue tracks them.

## Environment

- OS/version: GitHub Actions CI (ubuntu runner for kcov; Pester job)
- Python version: n/a (bash and PowerShell)
- Command/flags used: CI coverage jobs; kcov run 38057811190 and Pester run 38022356096, as cited in PA-7
- Data source or fixture: main at 2ef8d361; `.claude/lib/bash/compute-concurrency-batches.sh` (122 lines), `.codex/hooks/validate-feature-review-coverage.ps1` (304 lines)

## Steps to Reproduce

1. Open CI run 38057811190 and read the kcov per-file report for `.claude/lib/bash/compute-concurrency-batches.sh`.
2. Open CI run 38022356096 and read the Pester per-file coverage for `.codex/hooks/validate-feature-review-coverage.ps1`.
3. Compare each per-file line-coverage figure with the 85% floor in `.claude/rules/quality-tiers.md`.

## Expected Behavior

Every production file has at least 85% line coverage, per `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` (uniform across T1-T4; PowerShell and bash are exempt only from the branch threshold).

## Actual Behavior

- `.claude/lib/bash/compute-concurrency-batches.sh`: 81.82% line coverage (kcov, CI 38057811190).
- `.codex/hooks/validate-feature-review-coverage.ps1`: 7.30% line coverage, 10/137 lines (Pester, CI 38022356096).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/policy-audit.2026-10-10T14-25.md:297` (PA-7): "Files below 85% line coverage that this branch does not change: `.claude/lib/bash/compute-concurrency-batches.sh` 81.82% (kcov, CI 38057811190) and `.codex/hooks/validate-feature-review-coverage.ps1` 7.30% (Pester, CI 38022356096). Repo-wide figures remain above 85%." Disposition: "Out of scope; candidates for separate follow-up."
- Snippet: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/issue.md:54` lists "`.codex/hooks/validate-feature-review-coverage.ps1` 10/137 (7.30%)". `spec.md:55` of that folder kept `.codex/**` out of scope and `spec.md:210` says the remaining sub-85% files are "tracked separately"; no tracking issue was found.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. The aggregate gates pass, so the gap is invisible to CI. The Codex hook is a completion gate for feature reviews and is almost entirely untested, so a regression in it would not be detected.

## Suspected Cause / Notes

- The coverage gates are aggregate, not per-file, so individual files can fall below the floor without a failure.
- `.codex/hooks/validate-feature-review-coverage.ps1` is a Codex-surface counterpart of `.claude/hooks/validate-feature-review-coverage.ps1`; the Claude copy has its own Pester suites (for example `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`) but the Codex copy does not have equivalent coverage.
- The 81.82% figure is recorded only in PA-7; no kcov evidence file was committed, so the uncovered lines must be re-read from CI run 38057811190.
- Open issues #527 (PoshQC denominator reproducibility) and #743 (Linux Pester job and kcov `set -u`) are related to the coverage toolchain but do not name either file.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add bats cases for the uncovered branches of `compute-concurrency-batches.sh`; add Pester tests for the parse, threshold and block paths of `.codex/hooks/validate-feature-review-coverage.ps1` (or extract its logic into a tested module shared with the Claude copy).
- [ ] Integration scenario to retest: CI kcov and Pester jobs report both files at or above 85% line coverage.
- [ ] Manual verification notes: consider a per-file floor check so a file below 85% fails CI even when the aggregate passes.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch