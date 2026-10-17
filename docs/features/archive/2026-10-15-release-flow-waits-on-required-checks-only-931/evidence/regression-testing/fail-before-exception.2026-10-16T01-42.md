# Fail-Before Exception Dossier: Pester Additions (Issue #931)

Timestamp: 2026-10-16T01-42
Command: none (exception dossier)
EXIT_CODE: 0
Output Summary: No failing-before Pester run was captured for the new release-flow tests. Alternative proof: the baseline absence artifact shows the tests and helpers did not exist before the edit. This dossier is supplementary; no acceptance criterion in issue.md requires fail-before evidence for the Pester additions.

WhyFailingRunImpossible: The plan order places the script edit (P1-T4 to P1-T10) before the Pester additions (P1-T15 to P1-T22), so the new tests never ran against the unedited script. The PoshQC MCP tools return only a status summary, so per-test outcomes are available only from the CI artifact. No acceptance criterion in `issue.md` requires fail-before evidence for the Pester additions, so this dossier is supplementary.

## Alternative proof (absence of test before the edit)

Source: `evidence/baseline/new-test-absence.2026-10-16T01-23.md` (the greatest `new-test-absence.*.md`, written by P0-T23 before any Phase 1 edit).

- `polls gh pr checks without the required flag` in `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`: count 0
- `times out when completion polls keep failing` in `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`: count 0
- `function Get-CheckSetVerdict` in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: count 0
- `function ConvertFrom-CheckPollOutput` in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: count 0
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1`: does not exist (Glob returned no file)

Supplementary observation: the first post-edit scoped Pester run (P1-T24, run 1) failed one new test, `reports failure for a scalar element`. That failure exposed a real defect in the new parse helper, which was then fixed. It shows that the new tests detect a behavior defect. See `evidence/regression-testing/pester-after-edit.2026-10-16T01-42.md`.
