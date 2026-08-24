Timestamp: 2026-08-23T02-59 (UTC)
Command: $pesterConfig = New-PesterConfiguration; $pesterConfig.Run.Path = 'tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1'; $pesterConfig.Run.PassThru = $true; $pesterConfig.Filter.FullName = '*requires every Class 2 and Class 3 key to be indexed by name in its registered consumer file*'; $result = Invoke-Pester -Configuration $pesterConfig
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Passed=0 Failed=1. Failure message: "Expected $null or empty, but got 'invented_key -> BlastRadius.TruthTable.Tests.ps1'." This is the demonstration perturbation: 'invented_key' = 'BlastRadius.TruthTable.Tests.ps1' was added to $script:ClassTwoKeyConsumerFile in BlastRadius.KeyPartition.Tests.ps1, alongside the same JSON-config and Python-registry perturbations described in the paired Python fail-before artifact. This is the state the pre-fix registry passed on silently in all three languages (reviewer-perturbation-battery.2026-08-22T17-20.md Group D2); it is not the current, unperturbed state.

git diff --stat confirming all four files changed:
 config/blast-radius.json                           |  1 +
 .../claude-customizations/config/blast-radius.json |  1 +
 .../BlastRadius.KeyPartition.Tests.ps1             | 57 ++++++++++++++--
 .../dev_tools/blast_radius_parity_test_support.py  | 77 +++++++++++++++++++---
 4 files changed, 123 insertions(+), 13 deletions(-)
