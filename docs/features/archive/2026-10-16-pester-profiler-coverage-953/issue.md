# pester-profiler-coverage (Issue #953)

- Date captured: 2026-10-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pester-profiler-coverage/ (Issue #953)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #953
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/953
- Last Updated: 2026-10-16
- Work Mode: full-bug

## Summary

The Windows `poshqc / PowerShell QC` job sets the length of every CI run. In run 38846579572 it took 18.6 minutes, 15.5 of them in the `Invoke-PoshQCTest` step: about 5,300 Pester tests with breakpoint-based code coverage. Every other job finishes within about 6 minutes. Switching to profiler-based coverage (`CodeCoverage.UseBreakpoints = $false`, Pester 5.4 or later) should shorten that step substantially.

## Environment

- OS/version: GitHub Actions windows-latest; local Windows 11
- Python version: n/a
- Command/flags used: `Invoke-PoshQCTest -Root <workspace>` in `.github/workflows/_poshqc.yml`
- Data source or fixture: full repository Pester suite

## Steps to Reproduce

1. Open any PR against `main`.
2. Inspect the step timings of the `poshqc / PowerShell QC` job.
3. Observe that `Test PowerShell` takes about 15.5 minutes, while every other job finishes within about 6 minutes.

## Expected Behavior

The Windows Pester step finishes in a time comparable to the other CI jobs, with no reduction in coverage enforcement.

## Actual Behavior

The step takes about 15.5 minutes, so every CI run takes 14–19 minutes.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: run 38846579572 step timings: Analyze PowerShell 2.1m, Test PowerShell 15.5m.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- Pester coverage uses breakpoint mode, which is markedly slower than profiler mode.
- The Pester version is pinned at 5.6.1 locally in `PoshQC.psm1` but runs as 5.9.0 in CI. Reconcile both to one supported minimum.
- Profiler mode counts lines differently, so per-file coverage figures may shift. Thresholds must still pass. Do not exclude any production file and do not lower any threshold. Document every baseline change.
- Leave the `ci.yml` triggers alone, because a sibling merge-queue item edits them.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: the PoshQC module configuration tests, and any test that pins the Pester configuration.
- [x] Integration scenario to retest: full suite under profiler mode with the coverage thresholds evaluated.
- [x] Manual verification notes: record the CI step and job times before and after. If the step is still above about 8 minutes, shard it across a matrix and merge the coverage reports.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
