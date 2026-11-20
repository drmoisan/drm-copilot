# PowerShell Coverage Comparison ([P2-T8])

Timestamp: 2026-10-08T02-30 (UTC)
BaselineArtifact: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/baseline/baseline-poshqc-test.2026-10-07T21-58.md
FinalArtifact: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/qa-gates/final-poshqc-test.2026-10-08T02-30.md
BaselineCoverage: 84.32
FinalCoverage: 84.32
ScanFolder: tests/scripts/workflows
ScopeNote: under DEV-CI-BASELINE both values are full-repository CI headlines (`Covered 84.32% / 0%. 21,894 analyzed Commands in 174 Files.` in CI run 37645267440 and in CI run 37717224700), not a tests/scripts/workflows-only run.
ChangedProductionPowerShellFiles: none (the only PowerShell file written is the test suite tests/scripts/workflows/CiWorkflow.Tests.ps1, which is outside the CodeCoverage.Path allow-list in scripts/powershell/PoshQC/settings/pester.runsettings.psd1)
NewOrChangedCodeCoverage: not applicable - no production PowerShell line changed
Verdict: PASS
VerdictBasis: FinalCoverage 84.32 >= BaselineCoverage 84.32, and [P2-T3] met its acceptance condition (FinalPassed 6521 = 6519 + 2, FinalFailed 0 = 0, no `[-]` line for CiWorkflow.Tests.ps1).
