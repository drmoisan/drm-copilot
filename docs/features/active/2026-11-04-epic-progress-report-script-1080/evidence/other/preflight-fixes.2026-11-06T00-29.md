# Preflight Fixes - Remediation Plan Cycle 2 (Issue 1080)

Timestamp: 2026-11-06T00-29
Plan: docs/features/active/2026-11-04-epic-progress-report-script-1080/remediation-plan.2026-11-06T00-11.md
Signal: PREFLIGHT: ALL CLEAR
Validator: installed MCP plan validator passed; branch-current Python CLI (`plan` subcommand) passed with exit 0.

## Fixes

1. `## Existing Tests That Assert Changed Behavior` (search sentence) | citation correction | The sentence stated that the search matched only the four change-set files. The search also matches unrelated files: `| Issue |` matches the three `make-skill-template` skill mirrors under `extensions/drm-copilot/resources/`, and `issue_num` matches bundled agent and hook files. The sentence now states that every parser caller and kickoff fixture is in the four change-set files and names the unrelated matches. The disposition list is unchanged.
2. `[P2-T8]` | literal clarification | The acceptance read "`git diff MB -- issue.md` shows no change to `## Acceptance Criteria` in this cycle". The MB diff also carries the AC check-offs of the original delivery, so the task now names the cycle-2 start (the parent of the P0-T1 commit) as the reference for "this cycle" and requires that diff to be empty. The asserted property (no AC change in cycle 2) is unchanged.

## Checks Without Defect

- Kickoff corpus probe (read-only, before execution): 9 kickoff files, each opening its feature table with the `issue_num` header followed by a separator and a contiguous row block. 71 numeric-first rows in total, 9 with an empty plan cell (3 each in `cleanup-merged-worktrees-hardening`, `orchestrator-state-contract-correctness`, and `worktree-scoped-state-resolution`, all from the `| wave | features | width |` table). The P0-T6 and P1-T4 expectations are consistent with this (expected after-sweep rows 62).
- Mutant A and mutant B expectations in P1-T3 were traced against the designed tests: mutant A fails exactly the two table tests; mutant B fails exactly the overflow test.
- No other caller of `ConvertFrom-EpicProgressKickoffRow` exists outside the change set; the script suite fixture `$script:kickoffWithMarker` carries the `| Issue |` header.
