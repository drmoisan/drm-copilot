# P6-T5 No-Python codex scan-root fail-before

Timestamp: 2026-10-09T05-33
Command: Route C: CR-PESTER-LIST over tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 with patterns [AC-15 *] and CR-LINES via pwsh -NoProfile -File
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Result=Failed
SUITE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Passed=30 | Failed=2 | Skipped=0 | NotRun=0 | ProbeRows=0
NAMED: AC-15 * | Passed=3 | Failed=2 | Total=5
FAILED: enforcement hooks must not invoke Python.scan roots (issue #707).AC-15 codex hooks path is under a scan root :: Expected $true, because the Codex hooks directory is a scan root, but got $false.
FAILED: enforcement hooks must not invoke Python.scan roots (issue #707).AC-15 enumeration includes at least one codex hooks file :: Expected the actual value to be greater than 0, because the Codex hooks directory is enumerated, but got 0.
TOTAL: Passed=30 | Failed=2 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 1
LINES: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 488
LINES-OVER-500: 0
N6B-CREATED: False
