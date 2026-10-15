# P3-T3 Codex epic-scope-targets suite structure run (issue #738)

Timestamp: 2026-10-09T04-00
Task: [P3-T3]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 1 files)
EXIT_CODE: 1
ExpectedExitCode: 1

## Output

```text
FILES: 1
RUN_FILE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1
PassedCount: 4
FailedCount: 9
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a second segment that targets a different not-ready worktree
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a relative -C selector in epic scope
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies an unresolvable -C selector in epic scope
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a directory-changing segment in epic scope
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a wrapper-led git segment in epic scope
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies a target outside the epic scope of the session root
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch absolute file marker into a not-ready epic worktree
FAILED: Codex preimplementation gate epic-scope targets (issue #738).evaluates every value of a repeated -C selector
FAILED: Codex preimplementation gate epic-scope targets (issue #738).denies an ambiguous epic target
PASSED: Codex preimplementation gate epic-scope targets (issue #738).allows when every target is epic scope and ready
PASSED: Codex preimplementation gate epic-scope targets (issue #738).keeps the single-feature decision for a relative -C selector outside epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).keeps the single-feature decision for a directory change outside epic scope
PASSED: Codex preimplementation gate epic-scope targets (issue #738).resolves a segment without -C to the session root
```

Output Summary: PassedCount 4, FailedCount 9, FailedBlocksCount 0, FailedContainersCount 0; 9 FAILED: lines listed above.

