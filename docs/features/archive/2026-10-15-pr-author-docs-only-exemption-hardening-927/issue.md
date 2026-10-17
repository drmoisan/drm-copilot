# pr-author-docs-only-exemption-hardening (Issue #927)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Issue: #927
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/927
- Lifecycle record: docs/features/potential/promoted/2026-10-15-pr-author-docs-only-exemption-hardening-901.md (present on ref origin/docs/followups-2026-10-15, not on main)
- Last Updated: 2026-10-15
- Work Mode: full-bug

> Work-mode note: the lifecycle record and the GitHub issue body carry `minor-audit`. This item runs under the parallel-orchestration preparation route, which requires a spec authored by prd-feature, and the change spans the hook, its bundled mirror, the hook test suites, and the #901 evidence record. The selected and persisted mode is therefore `full-bug` (spec.md is the acceptance-criteria source; user-story.md is absent by default).

## Summary

Follow-up to #901 (PR #924, merged at head e467c693 without the planned remediation cycle 3). The docs-only exemption in the pr-author hook can be retargeted by flag shapes it does not inspect (CR-1), depends on NUL preservation that no test exercises (CR-2), and the #901 evidence record has inaccurate timestamps and an unobserved exit code (PA-N3, PA-N2).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. CR-1: run `gh pr create --base main -dB other ...` (clustered shorthand containing B) or add `-R`/`--repo`. The exemption diffs against `main` while gh applies `other` or another repository.
2. CR-2: lines 64, 65, 68 and 70 of `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` are executed by no test (local coverage XML and CI agree).
3. PA-N3/PA-N2: inspect the cycle 2 evidence in `docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/`.

## Expected Behavior

The exemption denies when any single-dash shorthand cluster contains B or when -R/--repo is present; it fails closed when diff output is non-empty and does not end with NUL; evidence timestamps are read from the host clock and exit codes are only recorded when observed.

## Actual Behavior

- CR-1 (Medium): `Get-PrAuthorDocsOnlyBaseName` (lines 122-130) checks only tokens beginning with `-B`.
- CR-2 (Low): path separation (lines 64-70, 162) depends on PowerShell preserving NUL in captured native git stdout; untested.
- PA-N3: three files suffixed `2026-10-12T19-50` record `2026-10-13T00-00`; commits `ff1b7cbd4` and `70e58ca84` add rows stamped later than the commits. `p1-poshqc-direct-run.2026-10-12T19-50.md` records `EXIT_CODE: 0` for a run whose exit code was never observed (the `-rerun` file has the observed value).
- PA-N2: the `## Evidence Checklist` in #901 `issue.md` is unchecked.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

- CR-3 (diff uses local HEAD rather than the pushed branch) is recorded operator decision D5 and is out of scope here; it stays unchanged.
- These were classified as related to #901 under the operator's remediation-cycle policy, but #901 merged before cycle 3 ran.
- Every hook change applies to all mirrors where the hook exists: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. No `.codex/hooks` copy exists at main f6915d42.

## Proposed Fix / Validation Ideas

- Deny on any single-dash cluster containing B and on -R/--repo; add one test row each.
- Return DOCS_ONLY_EXEMPTION_DIFF_FAILED when diff output is non-empty and does not end with [char]0; add a test row covering lines 64-70.
- Correct the PA-N3 timestamp rows from the recorded epoch values and commit times (or annotate them as reconstructed); correct the unobserved EXIT_CODE row; check off or annotate the Evidence Checklist.
