# P5 group slot EG-18

Timestamp: 2026-10-09T05-09
Command: Route C: CR-PESTER-LIST over the EG-18 suites; CR-COMPARE against the P0-T12 artifact (E2 and E4 by design); CR-PESTER-LIST over N2 with the AC-4 and AC-6 patterns of the group; CR-LINES, via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
GROUP: EG-18
GROUP-SUITES: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1, tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1, tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1, tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
EDIT-NOTES:
EDITED tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 :: form=direct probe=no, guard findings=0, FORMAT-CLEAN; EP-6 adaptation: Get-ChangedLanguageSet, Get-JacocoRepoCoverage and Get-LcovRepoCoverage are pure helpers over the baseline-mocked Get-ArtifactFileContent, so their real bodies are stashed before the baseline null Mocks and restored by a Describe-level Mock; no existing line changed
EDITED tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 :: form=direct probe=yes(Claude) orig=223 lines=235 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1
   NOTE: 2 Import-Module -Force command(s) present at lines 36,37
EDITED tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 :: form=direct probe=yes(Claude), guard findings=0, FORMAT-CLEAN; EP-6 adaptation: the Get-CheckpointFileContent Context exercises the real file seam, so the real function is stashed before the baseline null Mock and restored by a Context-level Mock; no existing line changed
EDITED tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 :: form=direct probe=yes(Claude) orig=237 lines=249 findings=0 probefindings=0 FORMAT-CLEAN: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1
RUN-1 (group CR-PESTER-LIST)
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | Passed=13 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | Passed=26 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
SUITE: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | Passed=13 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=1
TOTAL: Passed=56 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
RUN-2 (CR-COMPARE; only the group COMPARE lines count)
COMPARE: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | result=EQUAL
COMPARE-EXIT_CODE: 1
RUN-3 (N2 AC-4 and AC-6 patterns for the group)
NAMED: AC-4 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 * | Passed=0 | Failed=0 | Total=0
NAMED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-4 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
NAMED: AC-6 tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 * | Passed=1 | Failed=0 | Total=1
N2-EXIT_CODE: 1
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | 135
LINES: tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | 235
LINES: tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | 454
LINES: tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | 249
LINES-OVER-500: 0
