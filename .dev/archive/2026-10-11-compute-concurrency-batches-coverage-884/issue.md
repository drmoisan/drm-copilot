# compute-concurrency-batches-coverage (Issue #884)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Active (bash half of Issue #884)
- Issue: #884
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/884
- Lifecycle record: `docs/features/potential/promoted/2026-10-11-untouched-files-coverage-below-floor.md` (on branch `origin/docs/followups-2026-10-11`; not copied into this branch)
- Last Updated: 2026-10-11
- Work Mode: minor-audit

## Summary

Issue #884 reports two production files below the repository's uniform 85% line-coverage floor. This feature folder addresses only the bash file: `.claude/lib/bash/compute-concurrency-batches.sh` at 81.82% line coverage (kcov, CI run 38057811190). The repository-wide kcov aggregate remains above 85%, so no gate fails, but the file individually falls short of `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`.

## Environment

- OS/version: GitHub Actions CI (ubuntu runner for the kcov job)
- Command/flags used: CI kcov coverage job; run 38057811190, as cited in policy-audit finding PA-7 of issue #824
- Data source or fixture: main at 2ef8d361; `.claude/lib/bash/compute-concurrency-batches.sh` (122 lines)

## Steps to Reproduce

1. Open CI run 38057811190 and read the kcov per-file report for `.claude/lib/bash/compute-concurrency-batches.sh`.
2. Compare the per-file line-coverage figure with the 85% floor in `.claude/rules/quality-tiers.md`.

## Expected Behavior

`.claude/lib/bash/compute-concurrency-batches.sh` has at least 85% line coverage in the CI kcov report, per `.claude/rules/general-unit-test.md` and `.claude/rules/quality-tiers.md` (uniform across T1-T4; bash is exempt only from the branch threshold).

## Actual Behavior

`.claude/lib/bash/compute-concurrency-batches.sh`: 81.82% line coverage (kcov, CI 38057811190). No kcov evidence file was committed, so the uncovered lines must be derived from the CI kcov report or from the bats suites that invoke the script.

## Acceptance Criteria

- [x] AC-1: The CI kcov report for the PR head reports `.claude/lib/bash/compute-concurrency-batches.sh` at or above 85% line coverage.
- [x] AC-2: New bats test cases exercise the previously uncovered lines of `.claude/lib/bash/compute-concurrency-batches.sh`, live under `tests/shell/`, and pass in the PR's CI bats job.
- [x] AC-3: The observable behavior of `.claude/lib/bash/compute-concurrency-batches.sh` (stdout, stderr, and exit codes 0, 1, and 2) is unchanged; if a refactor is needed to make a line testable, the existing bats suites that invoke the script still pass unchanged in CI.
- [x] AC-4: `.codex/hooks/validate-feature-review-coverage.ps1` and its tests are not modified, and the eventual PR references #884 without a closing keyword, so the issue stays open for the PowerShell half.

Scope note (orchestrator, 2026-10-11): Issue #884 covers two files. This item, prepared in parallel run `bug-burndown-2026-10-11`, covers only the bash half. The PowerShell half (`.codex/hooks/validate-feature-review-coverage.ps1`, 7.30% line coverage) is out of scope and remains tracked by #884; the PR for this item must reference #884 without closing it. The acceptance criteria above were authored by the orchestrator from the Expected Behavior and Proposed Fix sections because the lifecycle record carried no explicit `## Acceptance Criteria` section. Verification follows operator Option A: bats and kcov results are taken from the PR's CI run; no local bats, kcov, sh, bash, or pwsh wrapper invocation is part of the plan.

## Logs / Screenshots

- Snippet: `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/policy-audit.2026-10-10T14-25.md:297` (PA-7): "Files below 85% line coverage that this branch does not change: `.claude/lib/bash/compute-concurrency-batches.sh` 81.82% (kcov, CI 38057811190) ..." Disposition: "Out of scope; candidates for separate follow-up."

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. The aggregate gate passes, so the per-file gap is not visible in CI.

## Suspected Cause / Notes

- The coverage gates are aggregate, not per-file, so an individual file can fall below the floor without a failure.
- Open issue #743 (Linux Pester job and kcov `set -u`) is related to the coverage toolchain but does not name this file.

## Evidence Checklist

- [x] baseline
- [x] targeted verification
- [x] end-state
