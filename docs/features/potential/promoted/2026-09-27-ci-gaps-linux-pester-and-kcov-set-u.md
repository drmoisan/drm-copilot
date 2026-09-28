# ci-gaps-linux-pester-and-kcov-set-u (Issue #743)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-gaps-linux-pester-and-kcov-set-u/ (Issue #743)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #743
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/743
- Last Updated: 2026-09-27
## Summary

Two CI coverage gaps surfaced as plan and CI surprises. There is no Linux Pester job, and a bats pattern fails only under CI kcov tracing, with nothing to catch it earlier.

## Environment

- OS/version: GitHub runners (windows-latest for Pester; ubuntu for shell coverage)
- Python version: n/a
- Command/flags used: `.github/workflows/_poshqc.yml` (`runs-on: windows-latest`); `_shell-coverage.yml` (bats + kcov)
- Data source or fixture: #707 (AC-16 "Linux runner" wording), #706 (kcov failures)

## Steps to Reproduce

1. CI's only Pester job runs on windows-latest, so the Codex and Claude hook suites have never run on Linux. Planners keep writing "Linux runner" into Pester acceptance criteria (#707 AC-16, amended as D18).
2. A bats test that sources a `set -u` helper inside `bash -c` fails only under kcov tracing, because kcov reads an unset `BASH_SOURCE`. Local bats and preflight do not catch it (#706 FU-706-3).
3. Git for Windows grep 3.0 reads `\\` in a fixed-string pattern as one backslash, so some plan checks cannot pass locally (#706 FU-706-4).

## Expected Behavior

PowerShell suites that must be portable run on Linux as well, and known CI-only failure patterns are caught before CI.

## Actual Behavior

As above.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #707 D18; #706 FU-706-3 and FU-706-4; memory note kcov-bash-c-source-set-u.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

A Linux Pester leg would also catch Windows-only path assumptions in PowerShell tests (compare the `C:/workspace` class in memory note ci-gate-polling-and-linux-only-test-failures).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add an ubuntu matrix leg to `_poshqc.yml`, at least for the hook suites; add a shellcheck or custom lint rule, or a preflight check, for the kcov `set -u` + `bash -c` pattern; add planner guidance on the runner matrix and on the Git-for-Windows grep backslash quirk.
- [ ] Integration scenario to retest: the hook suites pass on both runners.
- [ ] Manual verification notes: expect some Windows-only test assumptions to surface on the first Linux run.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
