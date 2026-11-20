# [P4-T5] Native registry rows and the three committed-registry suites

Timestamp: 2026-11-04T16-40
Command: sh SCRATCH/issue-1031-gate.sh issue-1031-p4t5.out tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1,tests/scripts/claude-lib/docs/DocsAnalyzerConfigFiles.Tests.ps1,tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1 -NoCoverage (branch-current Invoke-PoshQCTest, all three suites in one process)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml tests=58 failures=0 errors=0 (DocsAnalyzerRegistry.Tests.ps1 31, DocsAnalyzerConfigFiles.Tests.ps1 16, DocsInventorySnapshot.Tests.ps1 11). Passing cases include:
- Committed provider tables (membership only).holds exactly one native row for each of the four Python identifiers, with the scanner row ElementKinds (issue #1031) (new)
- Invoke-DocsAnalyzerConfigFiles.registration.registers the five 1022 scanner rows in the committed registry and Test-DocsAnalyzerRegistration returns no finding (filter now Id and AnalysisMethod -ceq 'scanner')
- New-DocsInventorySnapshot over both corpora.validates against surface-inventory-snapshot through Test-DocsArtifactText with no finding and carries the header fields
- New-DocsInventorySnapshot over both corpora.property: New-DocsInventorySnapshot is byte-identical under permuted inputs and analyzer outputs

Command: git diff --numstat MERGE_BASE -- .claude/lib/docs/DocsAnalyzerRegistry.psm1
EXIT_CODE: 0
Output Summary: 4	0	.claude/lib/docs/DocsAnalyzerRegistry.psm1 (4 added, 0 deleted; the four native rows python-architecture, python-cli, python-http, python-public-api directly under the 1031 anchor).
