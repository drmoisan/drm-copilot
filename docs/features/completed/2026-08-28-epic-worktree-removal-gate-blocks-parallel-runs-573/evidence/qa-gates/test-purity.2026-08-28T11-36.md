# Test-Purity Invariant (P5-T7)

Timestamp: 2026-08-28T11-36

Task: [P5-T7]
Issue: #573
Acceptance criterion discharged: AC-11
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. `git grep -F -n New-TemporaryFile -- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
2. `git grep -F -n GetTempPath -- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
3. `git grep -F -n Start-Process -- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`

EXIT_CODE: 1
ExpectedExitCode: 1

`git grep` exits 1 when it finds no match, so exit 1 is the passing outcome for all three searches and is declared as the expectation.

## Results

| # | Literal searched | Matches | Exit |
| --- | --- | --- | --- |
| 1 | `New-TemporaryFile` | 0 (no output) | 1 |
| 2 | `GetTempPath` | 0 (no output) | 1 |
| 3 | `Start-Process` | 0 (no output) | 1 |

All three searches report **zero matches**. Each produced no output line at all, and each exited 1.

`git grep` reads working-tree content for tracked files, so these results describe the suite as it stands after Phase 2's determinism additions, not a stale committed revision. That the mechanism observes working-tree content was verified independently during Phase 2, when the same command form found the newly added `Test-ParallelCheckpointAllowsWorktreeRemoval` token before it was committed.

## Every checkpoint fixture is a literal JSON string through a mocked read seam

The suite injects checkpoint content by exactly two mechanisms, and by no other:

- `Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { <literal JSON string or $null> }` for the epic checkpoint.
- `Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { <literal JSON string or $null> }` for the parallel-orchestrator checkpoint.

The four direct-predicate tests build their fixture with `'<literal JSON>' | ConvertFrom-Json` in the test body, which touches no filesystem at all.

The two epic read-seam tests and the two parallel read-seam tests are the only tests that exercise a real seam body, and both mock `Test-Path` and `Get-Content` under a `-ParameterFilter` keyed on the corresponding checkpoint script variable, so even those tests never open a file.

No test therefore creates a temporary file, spawns a child process, or reads a real checkpoint from disk. The suite's file docstring states this rule for future contributors, and the determinism obligation is additionally enforced at seven call sites by the parallel-seam `$null` mocks added in [P2-T4].

Output Summary: PASS (AC-11). All three fixed-string searches — `New-TemporaryFile`, `GetTempPath`, and `Start-Process` — report zero matches against `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` and each exits 1, matching `ExpectedExitCode: 1`. Every checkpoint fixture in the suite is a literal JSON string supplied through one of the two mocked read seams (or parsed in-test with `ConvertFrom-Json` for the direct-predicate cases), and the four read-seam tests mock `Test-Path` and `Get-Content` under a parameter filter, so no test creates a temporary file, spawns a child process, or reads a real checkpoint from disk.
