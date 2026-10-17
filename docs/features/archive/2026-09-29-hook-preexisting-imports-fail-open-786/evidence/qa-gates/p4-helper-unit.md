# Helper Unit Tests ([P4-T8])

Timestamp: 2026-10-09T23-21
Command: sh <SCRATCHPAD>/r.sh rscoped -Path tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1,tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1,tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 (R-SCOPED)
EXIT_CODE: 0
Output Summary: 66 passed, 0 failed, 0 failed blocks, 0 failed containers; the 12 Claude-copy helper tests (H1 to H12) and the 11 Codex-copy helper tests (H1 to H10, H12) pass; legacy-codex-hook-contracts.Tests.ps1 passes 43 of 43 with hook-dependency-guard.ps1 in $script:SharedModuleNames.

Runner output:

```text

Starting discovery in 3 files.
Discovery found 66 tests in 185ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 556ms (170ms|276ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 119ms (73ms|31ms)
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 13.42s (13.29s|93ms)
Tests completed in 14.1s
Tests Passed: 66, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
PassedCount: 66
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1 | result=Passed | passed=12 | failed=0
CONTAINER: tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1 | result=Passed | passed=11 | failed=0
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | result=Passed | passed=43 | failed=0
PASSED: H1: records a dependency failure by name
PASSED: H2: reports no failure before any record
PASSED: H3: reports a failure after a record
PASSED: H4: builds the reason from the prefix, the dependency name, and the first exception line
PASSED: H5: returns the PreToolUse deny decision in the hookSpecificOutput shape
PASSED: H6: returns a SubagentStop result carrying exit code 2 and the reason
PASSED: H7: returns null from the decision builder when nothing failed
PASSED: H8: keeps earlier records when the helper is dot-sourced again
PASSED: H9: writes nothing to any output stream when recording a failure
PASSED: H10: contains no Import-Module and no dot-source
PASSED: H11: is byte-identical across all four copies
PASSED: H12: stays within 500 lines
PASSED: H1: records a dependency failure by name
PASSED: H2: reports no failure before any record
PASSED: H3: reports a failure after a record
PASSED: H4: builds the reason from the prefix, the dependency name, and the first exception line
PASSED: H5: returns the PreToolUse deny decision in the hookSpecificOutput shape
PASSED: H6: returns a SubagentStop result carrying exit code 2 and the reason
PASSED: H7: returns null from the decision builder when nothing failed
PASSED: H8: keeps earlier records when the helper is dot-sourced again
PASSED: H9: writes nothing to any output stream when recording a failure
PASSED: H10: contains no Import-Module and no dot-source
PASSED: H12: stays within 500 lines
PASSED: parse-checks each root and bundled hook and keeps every file within 500 lines
PASSED: keeps the canonical hooks byte-identical to their bundled copies
PASSED: reads stdin in every hook entrypoint
PASSED: contains no legacy Claude environment-variable dependency in hooks or shared modules
PASSED: lists every shared hook module in the core pack manifest
PASSED: ignores poisoned Claude variables when safe Codex stdin payloads are supplied
PASSED: fails closed with exit 2 and stderr for malformed stdin on every hook
PASSED: emits the current PreToolUse deny envelope for shell and patch violations
PASSED: fails closed when the canonical checkpoint is deleted or becomes invalid JSON
PASSED: denies preimplementation and batch-budget violations through their pure decisions
PASSED: allows exempt checkpoint writes and preparation-mode delegations (issue #535)
PASSED: reconstructs update patches in memory and includes move destinations
PASSED: uses one SubagentStop continuation and stops repeated continuation loops
PASSED: classifies a feature documentation path as implementation path False
PASSED: classifies the orchestrator checkpoint as implementation path False
PASSED: classifies a production script as implementation path True
PASSED: classifies a plain text file as implementation path False
PASSED: classifies an empty command as implementation command False
PASSED: classifies an apply_patch add of a script as implementation command True
PASSED: classifies an apply_patch add of documentation as implementation command False
PASSED: classifies an apply_patch rename onto a script as implementation command True
PASSED: classifies a git commit as implementation command True
PASSED: classifies a pytest run as implementation command True
PASSED: classifies an unrelated command as implementation command False
PASSED: treats a null tool_input as no implementation delegation
PASSED: detects an implementation delegation inside a serialized tool_input
PASSED: treats an unrelated serialized tool_input as no delegation
PASSED: treats a null checkpoint payload as not ready
PASSED: treats a checkpoint missing lifecycle readiness as not ready
PASSED: treats a complete checkpoint as ready
PASSED: returns empty checkpoint content when the checkpoint file is absent
PASSED: returns the checkpoint file content when the checkpoint file is present
PASSED: allows when no mapped tool_input is supplied
PASSED: throws a hook-named error for malformed mapped tool_input JSON
PASSED: allows a documentation file path without consulting the checkpoint
PASSED: denies an implementation command when the checkpoint is not ready
PASSED: denies an implementation delegation when the checkpoint is not ready
PASSED: allows an implementation path when the checkpoint is ready
PASSED: reads the checkpoint from disk when no checkpoint text is supplied
PASSED: denies an apply_patch implementation through its own entrypoint
PASSED: denies a mapped Edit implementation through its own entrypoint
PASSED: allows a mapped Write of feature documentation through its own entrypoint
PASSED: fails closed with exit 2 when its entrypoint receives empty stdin
```
