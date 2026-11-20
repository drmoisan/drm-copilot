# Preflight Fixes (Issue #1096)

Timestamp: 2026-11-07T07-54
Plan: docs/features/active/2026-11-06-pester-static-leak-scan-1096/plan.2026-11-07T02-06.md

Every fix edits task text or plan preamble. No task was added, removed, or reordered, and no box was checked.

## Fixes

1. `## Execution Rules`, `Commit and push`. Defect class: unsatisfiable condition whose correction keeps the assertion. The rule staged no plan file, so an earlier checkbox left the worktree dirty and the P4-T2 condition that `git status --porcelain` is empty could not hold. The rule now stages the plan file with its checkbox, and excludes it from the P4-T2 commit and from a P5-T2 fence-correction commit, as the #1094 plan did for its reduction commit.
2. `## Execution Rules`, `Poetry`. Defect class: missing environment fact. The rule now states that `poetry run` from the item worktree uses the main checkout's environment through the inherited `VIRTUAL_ENV` and creates no `.venv`. This was observed with a one-line `sys.prefix` probe; no `.venv` appeared in the worktree afterward.
3. [P0-T2] and [P6-T1]. Defect class: validator-blind unsatisfiable condition. `Get-PoshQCFileList` returns `.psd1` files, while `Invoke-PoshQCAnalyze` analyzes `.ps1` and `.psm1` only, so a direct run over the whole list measures files CI never analyzes. Both tasks now name that filter. The zero-findings assertion is unchanged.
4. [P1-T2]. Defect class: unstated route. The spec signature has no folder seam, so the two default-folder `LI-` cases cannot use a parameter. The task now names `Mock` inside `InModuleScope PoshQC`, because `Mock -ModuleName` from test code is not honored in a PoshQC-hosted run.
5. [P3-T2]. Defect class: stale citation. `scripts/dev-tools/Enter-DrmCopilotShell.ps1` calls `Start-DrmCopilotPromptSession` and neither seam function. The sentence now states that the file is unchanged.
6. [P4-T2], `## Prior Text` bullet. Defect class: citation correction. `docs/engineering/process-reductions/README.md` states that a byte-identical mirror takes no block. The bullet now excepts the brief copies.
7. [P4-T2], `## Revert Steps` bullet. Defect class: citation correction. P5-T1 adds a `## Test Runtime` entry to `test_brief_passages_state_parallel_gate_facts`, and that entry pins wording of the reduction. Step 5 now names it, so a revert does not leave that test failing.
8. [P6-T1]. Defect class: literal formatting. A case-insensitive search for `Formatted:` also matches `Already formatted:`. The task now states a case-sensitive count from the line start.
9. `## Pre-Mortem`, `CI-only behavior`. Defect class: citation correction. Six production Python files change, so the large-route statement now names the Python budget and `PYTHON_LARGE_PATH_REQUIRED` as well.
