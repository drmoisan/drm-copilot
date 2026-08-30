# [P3-T6] Python batch-budget hook — pass-after evidence

Timestamp: 2026-08-29T16-05

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -ScanFolders 'tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1'"`

EXIT_CODE: 0

Output Summary: The Form A run exited 0 and Pester replayed `Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. The Form B extraction of `artifacts/pester/pester-junit.xml` reported `root=Pester tests=32 failures=0`. All ten `It` titles added by [P3-T2] are present among the `testcase` names with no `failure` child, alongside the 22 pre-existing tests of the same suite, which remain green.

## Form A console output (verbatim)

```

Starting discovery in 1 files.
Discovery found 32 tests in 157ms.
Starting code coverage.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 963ms (503ms|322ms)
Tests completed in 974ms
Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 2.6% / 0%. 10,697 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5\artifacts\pester\powershell-coverage.koverage.xml
```

Replayed summary line, quoted verbatim:

```
Tests Passed: 32, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

The five counts it carries: Passed 32, Failed 0, Skipped 0, Inconclusive 0, NotRun 0.

## Form B extraction

Command: `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`

EXIT_CODE: 0

Output:

```
root=Pester tests=32 failures=0
```

The `failures` count is 0 and no `testcase` carries a `failure` child.

## The ten [P3-T2] titles present among the testcase names

Enumerated from the full `//testcase` name listing of the same result file:

1. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from CLAUDE_SESSION_ID when the environment supplies it`
2. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes the state-file name from the session-id state file when the environment is empty`
3. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes a worktree-derived state-file name when both sources are empty`
4. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.composes pairwise different state-file names across the three session sources`
5. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.sanitizes a hostile session id into the state-file name pattern`
6. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records a relative candidate path`
7. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records an absolute candidate path under the resolved root`
8. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.discards an absolute candidate path outside the resolved root`
9. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.records an in-root absolute path that differs from the root only in letter case`
10. `enforce-python-batch-budget.ps1.session identity, containment, and rehydrate filter.admits three in-root production files when the persisted state already holds an out-of-root entry`

## Pre-existing tests of the same suite

The 22 pre-existing tests are present and green:

```
enforce-python-batch-budget.ps1.allows a new production file under the production cap and records it
enforce-python-batch-budget.ps1.allows a new test file under the test cap and records it
enforce-python-batch-budget.ps1.allows repeated file edits without consuming another slot
enforce-python-batch-budget.ps1.denies a new production file when the production cap is full
enforce-python-batch-budget.ps1.denies a new test file when the test cap is full
enforce-python-batch-budget.ps1.serializes the deny decision into the PreToolUse hookSpecificOutput envelope
enforce-python-batch-budget.ps1.ignores non-Python file paths
enforce-python-batch-budget.ps1.uses loaded state when evaluating session budget
enforce-python-batch-budget.ps1.denies malformed tool-input JSON with a diagnostic before touching state
enforce-python-batch-budget.ps1.denies an empty payload as an envelope anomaly (fail closed)
enforce-python-batch-budget.ps1.denies the legacy flat root shape as a missing-tool_input anomaly
enforce-python-batch-budget.ps1.allows a well-formed tool_input carrying no file_path (scope filter)
enforce-python-batch-budget.ps1.allows valid non-Python tool input without touching state
enforce-python-batch-budget.ps1.writes state for valid Python tool input through injected state operations
enforce-python-batch-budget.ps1.loads existing state through injected state operations
enforce-python-batch-budget.ps1.continues when injected state read and write operations fail
enforce-python-batch-budget.ps1.denies a nested envelope naming a Python file once the production cap is full (AC-7)
enforce-python-batch-budget.ps1.reads the payload through the shared reader at the entry point
enforce-python-batch-budget.ps1.entry-point dispatch.returns exit code 0 and emits nothing for an allowed non-Python path (deny-only convention)
enforce-python-batch-budget.ps1.entry-point dispatch.returns exit code 0 and emits a deny decision with no state property for an empty payload
enforce-python-batch-budget.ps1.entry-point dispatch.returns exit code 0 and emits a deny decision when ToolInputRaw is omitted and the ReadPayload seam is empty
enforce-python-batch-budget.ps1.entry-point dispatch.returns exit code 0 for malformed JSON with non-default session and cap environment variables set
```

## Mirror parity at the close of Phase 3

Command: `git hash-object .claude/hooks/enforce-python-batch-budget.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 0

```
db025b9d50826c8ade88d38dd9a651afcaef66d4
db025b9d50826c8ade88d38dd9a651afcaef66d4
```

The two object ids are equal, and both differ from the [P0-T8] baseline id `07a265fa22c088c47261a559e6f89991649b2c1f`, which confirms the pair was edited rather than left untouched.
