# Coverage delta ([P2-T5], remediation cycle 1)

Timestamp: 2026-11-14T01-19
Command: `git -C <worktree> diff -U0 <CycleStartHead> -- <the two validators>` for the changed hunks; a SCRATCH reader over SCRATCH/issue-1161-pytest-final.json (`executed_lines`, `missing_lines`, `missing_branches`); an `awk` read of the `DA` and `BRDA` records in SCRATCH/issue-1161-jest-final.lcov
EXIT_CODE: 0
Output Summary: Every changed executable line is covered in both runtimes, and no per-file or repo-wide figure drops. Python validator: line 100.00% to 100.00%, branch 99.21% to 99.21%. TypeScript module: lines 100.00% to 100.00%, branches 100.00% to 100.00%. Repo-wide pytest line 97.13% to 97.13% and branch 94.42% to 94.42%; repo-wide Jest lines 97.17% to 97.17% and branches 93.94% to 93.94%.

Sources: baseline `evidence/remediation-baseline/pytest-gate.2026-11-14T00-58.md` and `evidence/remediation-baseline/jest-gate.2026-11-14T00-59.md`; final `evidence/qa-gates/pytest-gate.2026-11-14T01-17.md` and `evidence/qa-gates/jest-gate.2026-11-14T01-18.md`.

## Per-file figures

| File | Baseline line | Final line | Baseline branch | Final branch | Changed-line coverage |
|---|---|---|---|---|---|
| `scripts/dev_tools/validate_epic_planner_state.py` | 100.00% (239/239) | 100.00% (240/240) | 99.21% (125/126) | 99.21% (125/126) | 2 of 2 changed statements executed |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts` | 100.00% (172/172) | 100.00% (179/179) | 100.00% (44/44) | 100.00% (44/44) | 2 of 2 changed lines hit |

## Changed executable lines

- Python: the `_RECORDED_AT_BLANK_CHARS` assignment (executed) and the `recorded.strip(_RECORDED_AT_BLANK_CHARS)` condition in `_validate_planner_worktrees` (executed). The only missing arc in the file (176 to 180) is the pre-existing `feature_folder` guard in the dependency-and-wave helper, not a changed line. The other changed lines are comments and docstring text, which are not statements.
- TypeScript: the `RECORDED_AT_BLANK` declaration (hit count 1) and the `!RECORDED_AT_BLANK.test(recordedAt)` operand in `validateEntryFields` (hit count 35); the module reports no `BRDA` record with a zero count. The TSDoc lines are comments.

## Repo-wide figures

| Gate | Baseline line | Final line | Baseline branch | Final branch |
|---|---|---|---|---|
| pytest | 97.13% (34573/35594) | 97.13% (34574/35595) | 94.42% (12784/13540) | 94.42% (12785/13540) |
| Jest (`extensions/drm-copilot`) | 97.17% (64207/66073) | 97.17% (64214/66080) | 93.94% (9845/10479) | 93.94% (9845/10479) |
