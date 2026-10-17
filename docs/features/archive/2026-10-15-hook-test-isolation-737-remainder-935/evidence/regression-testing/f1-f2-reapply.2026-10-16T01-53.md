# F-1/F-2 Reapply (P2-T1, P2-T2)

Timestamp: 2026-10-16T01-53
Command: git diff 4e8d9f92d 4e8d9f92d~1 -- tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 > SCRATCH/935/issue-935/f1-f2-reapply.patch; git apply --check SCRATCH/935/issue-935/f1-f2-reapply.patch; git apply SCRATCH/935/issue-935/f1-f2-reapply.patch; git diff --stat 4e8d9f92d~1 -- <same four paths>
EXIT_CODE: 0

Output Summary:
- Patch generation: exit 0; patch is 416 lines (non-empty).
- Route taken: direct apply. `git apply --check` exit 0; `git apply` exit 0. The `--3way` and hand-transcription routes were not needed.
- `git diff --stat 4e8d9f92d~1 -- <four paths>`: exit 0, output EMPTY. P0-T5 recorded no drift, so the reapplied files are identical to the withheld state at `4e8d9f92d~1`. PASS.
