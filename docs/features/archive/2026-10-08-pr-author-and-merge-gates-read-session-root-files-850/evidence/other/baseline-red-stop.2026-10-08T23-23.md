# Stop record: BASELINE-RED-IN-EDITED-SUITE at P0-T17

Timestamp: 2026-10-08T23-23
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path <SET-PRA, 13 suites, Appendix G> (run twice: 23-20 and 23-21)
EXIT_CODE: 0
Output Summary: SET-PRA TotalCount=247 PassedCount=246 FailedCount=1 on both runs; no FAILED-CONTAINER line. The single failure is in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, a member of Appendix F group BASELINE-GREEN (EDITED-TESTS), so the P0-T17 stop condition `BASELINE-RED-IN-EDITED-SUITE` fired. Execution stopped at P0-T17; P0-T17 is left unchecked.

StopCode: BASELINE-RED-IN-EDITED-SUITE
Task: P0-T17
Plan: plan.2026-10-08T13-54.md (revision 3)
Last completed task: P0-T16

## Failing row

- `FAILED: enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- `FAILED-FILE: tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Assertion (suite line 154): expected `allow`, observed `deny`. The sibling row for `gh pr edit` in the same Context passes.

Evidence: `evidence/baseline/pester-set-pra.2026-10-08T23-20.md`, `evidence/baseline/pester-set-pra.2026-10-08T23-21.md` (paths relative to FEATURE).

## Diagnosis (read-only probe)

`evidence/other/baseline-red-probe.2026-10-08T23-22.md` evaluates the row's command with the same six seams replaced as the row mocks them. The deny reason is:

`EPIC_BASE_BRANCH_MISMATCH: gh pr create must pass --base epic/enforcement-hook-precision-integration (epic_context.integration_branch) under epic_mode; the command does not carry a matching --base argument.`

The epic base-branch check (`enforce-pr-author-skill.epic-base-branch.ps1`, PRAE) applies only to `gh pr create` and reads the session-root checkpoint `artifacts/orchestration/orchestrator-state.json`. In this worktree that checkpoint records `"epic_mode": true` and `"integration_branch": "epic/enforcement-hook-precision-integration"` (lines 5 and 8). The checkpoint is the one P0-T7 requires (route `large`) and is protected by LH-5. The row does not mock the epic base-branch seam, so its outcome depends on local checkpoint state. The failure is therefore attributable to the local epic-mode checkpoint, not to a code change (no production or test file has been changed by this run). This attribution is an inference from the probe; it was not verified by running the suite without the checkpoint, because LH-5 prohibits moving it.

## Plan delta proposed for the planner (not applied)

One of the following, at the planner's choice:

1. Add a single Arrange line to the `allowed commands` Context `BeforeEach` of `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` that mocks the epic base-branch seam to a non-epic result (the planner to name the exact PRAE seam function after reading PRAE), add the suite edit as a new Appendix C entry, and run it before P0-T17 so the baseline is green; or
2. Amend the P0-T17 stop rule with an explicit exception: a `FAILED:` line whose deny reason is `EPIC_BASE_BRANCH_MISMATCH` and whose row issues `gh pr create` without `--base` is recorded as an environmental baseline failure (local epic-mode checkpoint) and does not stop the plan; later SET-PRA and CG-PRA assertions already accept members of the baseline failure set.

Other SET-PRA, SET-MRG, SET-REM, and SET-LIB rows may be affected by the same checkpoint; P0-T18 through P0-T20 have not run, so this is unknown.

## State at stop

- P0-T12 through P0-T16 completed and checked in the plan; evidence: `evidence/other/c1a-reverification.2026-10-08T23-17.md`, `evidence/baseline/line-counts-tests.2026-10-08T23-19.md`, `evidence/baseline/mirror-hashes.2026-10-08T23-19.md`, `evidence/baseline/powershell-format.2026-10-08T23-19.md`, `evidence/baseline/powershell-analyze.2026-10-08T23-20.md`.
- No production, test, mirror, or spec file was changed.
- SCRATCH in this session is the scratchpad subdirectory `x850`; A1-A17 were re-created verbatim from Appendix H.
