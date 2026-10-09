# P10-T9 Auxiliary suites after the change

Timestamp: 2026-10-09T06-17
Command: Route C: CR-PESTER-LIST over LIST-AUX, then CR-COMPARE against the P0-T13 artifact (E3 by design) via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | Passed=28 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | Passed=5 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
SUITE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Passed=32 | Failed=0 | Skipped=0 | NotRun=0 | ProbeRows=0
TOTAL: Passed=65 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
RUN-EXIT_CODE_COMPUTED: 0
BEFORE-ARTIFACT: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/pester-aux-baseline.2026-10-09T02-32.md
COMPARE: tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | result=EQUAL
COMPARE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | result=BY-DESIGN-OK
COMPARE-DIFFERENT-COUNT: 0
COMPARE-EXIT_CODE: 0
EXIT_CODE_COMPUTED: 0
