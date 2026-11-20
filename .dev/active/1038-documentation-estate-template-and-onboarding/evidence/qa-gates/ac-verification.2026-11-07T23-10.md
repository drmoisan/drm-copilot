# Acceptance-criteria verification, cycle 1 ([P4-T11])

Timestamp: 2026-11-07T23-10
Command: read <FEATURE>/spec.md `## Acceptance Criteria` and <FEATURE>/user-story.md after the [P1-T1] to [P1-T3] commits; read the SAC-12 test result from evidence/regression-testing/pester-coverage.2026-11-07T23-06.md and artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: SAC-12 is met and checked in spec.md; SAC-24 stays unchecked as pending-CI for the orchestrator at S9. spec.md: 25 criteria, 24 checked, 1 unchecked. user-story.md: 11 criteria, 11 checked.

## SAC-12 - met

Criterion (spec.md, `## Acceptance Criteria`): `consumer-onboarding.md` states that the optional python pack, with Python 3.11 or later, enables the native Python analyzer (D3), the scanner fallback recording `analysis_method: scanner`, the `-AnalysisMethod` choices, and the inert helper of a push-down without a pack selection; the documentation contract suite asserts the python pack statement.

Citations:

- Page: `docs/engineering/documentation-estate/consumer-onboarding.md` `## Optional Python Pack` states Python 3.11 or later as the floor that the native helper enforces, the four analyzers, the scanner fallback with `analysis_method: scanner`, the `-AnalysisMethod` choices and the inert helper.
- Test: `documentation-estate onboarding pages.states that the optional python pack enables the native Python analyzer` in `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1`, status Passed in the gate run recorded in evidence/regression-testing/pester-coverage.2026-11-07T23-06.md (DocumentationEstateOnboarding.Tests.ps1: 13 passed, 0 failed).
- Floor text: evidence/other/python-floor-erratum.2026-11-07T22-45.md (the criterion and the spec now state 3.11; `3.10` remains only in the erratum entry).

Check-off: `- [ ]` changed to `- [x]` for SAC-12 in spec.md; criterion text unchanged.

## SAC-24 - pending-CI

The criterion requires the three new suites to pass in the CI job `poshqc / PowerShell QC` on the pull-request head (its run-evidence and coverage parts are recorded under `evidence/`, with the owner decision of 2026-11-07 substituting one parallel gate run for the shuffled and single-process runs). Its CI part cannot be verified before the pull request runs, so it stays `- [ ]`; the orchestrator checks it at S9.

## Acceptance Criteria Status

- Source: docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md and docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/user-story.md (Work Mode: full-feature)
- Total AC items: 36 (spec.md 25, user-story.md 11)
- Checked off (delivered): 35
- Remaining (unchecked): 1
- Items remaining: SAC-24 (the new suites pass in the CI job `poshqc / PowerShell QC`; pending-CI, orchestrator S9)
