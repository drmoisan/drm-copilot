# Gate-5 Pin Run ([P4-T5])

Timestamp: 2026-09-27T07-13
Command: git diff --name-only daae7f796ebbd87e2170df3c86a9901ce11a4b68 -- .codex/hooks/enforce-completion-consistency.ps1 .codex/hooks/enforce-completion-helpers.ps1; git status --porcelain -- .codex/hooks/enforce-completion-consistency.ps1 .codex/hooks/enforce-completion-helpers.ps1; sh <SCRATCHPAD>/x707p2-rscoped.sh tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 (R-SCOPED body of plan section 5, launched by route sh with working directory <WORKSPACE_ROOT>)
EXIT_CODE: 0
Output Summary: Both git observations printed nothing, so the two gate-5 production files are unchanged against BASE_SHA and in the working tree. R-SCOPED over Suite C: PassedCount 6, FailedCount 0, FailedBlocksCount 0, FailedContainersCount 0; all six C1 to C6 names on PASSED lines. The pin passes on unchanged production files, as spec decision D12 states.

BASE_SHA: daae7f796ebbd87e2170df3c86a9901ce11a4b68 (from evidence/baseline/p0-base-ref.md)

## Output 1: git diff --name-only (exit 0)

```
(empty)
```

## Output 2: git status --porcelain (exit 0)

```
(empty)
```

## Output 3: runner output (ANSI colour codes removed; host root replaced by `<WORKSPACE_ROOT>`)

```
RUN_START=2026-09-27T07-13

Starting discovery in 1 files.
Discovery found 6 tests in 117ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1
 519ms (162ms|257ms)
Tests completed in 529ms
Tests Passed: 6, 
Failed: 0, 
Skipped: 0, 
Inconclusive: 0, 

NotRun: 0
PassedCount: 6
FailedCount: 0
FailedBlocksCount: 0
FailedContainersCount: 0
CONTAINER: tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | passed=6 | failed=0
PASSED: does not intercept a completion-asserting Write to the epic checkpoint
PASSED: does not intercept a completion-asserting Edit to the epic checkpoint
PASSED: does not intercept an apply_patch Add of the epic checkpoint
PASSED: emits no mapped record for an apply_patch Update of the epic checkpoint
PASSED: still denies a completion-asserting per-feature checkpoint whose feature-folder is under docs/features/epics/
PASSED: still denies a completion-asserting per-feature checkpoint that lacks ci_gate
EXIT_CODE=0
```
