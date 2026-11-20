# Preflight Clearance — Issue #632 (epic child C)

Timestamp: 2026-09-07T01-25
Command: mcp__drm-copilot__validate_orchestration_artifacts artifact_type=plan artifact_path=docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/plan.2026-09-06T23-05.md
EXIT_CODE: 0

PREFLIGHT: ALL CLEAR

CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Scope of this artifact

This records the terminal preflight clearance for the atomic plan of GitHub issue #632, epic
child C of the `cleanup-merged-worktrees-hardening` epic. Atomic execution has NOT begun. No
plan task was executed and no acceptance criterion was checked off.

- Plan path: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/plan.2026-09-06T23-05.md`
- Plan state at clearance: 662 lines, 9 phases, 81 tasks (P0x8, P1x11, P2x17, P3x7, P4x7, P5x13, P6x7, P7x8, P8x3)
- Acceptance-criteria source: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`, 38 unchecked items under `## Acceptance Criteria`
- Work mode: `full-bug` (`issue.md:12`)

## Gate results

The `EXIT_CODE: 0` above is the plan-artifact validator run against the final plan text. It
returned `ok: true` with no warnings, applying the structural contract and acceptance-gate
rules G1 through G9.

The validator was proven discriminating rather than vacuous before its pass was trusted: a
copy of the plan with `### Phase 0 ` rewritten to `### Phase Zero ` was validated and returned
`ok: false` with 9 errors. The mutated copy was deleted after the check.

The `PREFLIGHT: ALL CLEAR` signal above was returned by `Agent(atomic-executor)` under
`DIRECTIVE: PREFLIGHT VALIDATION ONLY` on round 4, which reported editing no file and finding
no blocking defect.

## Preflight round history

Four rounds were required against the two-round target in `.claude/skills/atomic-plan-contract/SKILL.md`.

| Round | Result | Blocking defects | Applied by |
| --- | --- | --- | --- |
| 1 | REVISIONS REQUIRED | 21 | `atomic-executor`, in place |
| 2 | REVISIONS REQUIRED | 6 (D1-D6) | reported only; applied afterwards by `atomic-planner` |
| 3 | REVISIONS REQUIRED | 2 (B1 applied in place; B2 raised) | `atomic-executor` (B1); `prd-feature` + `atomic-planner` (B2) |
| 4 | ALL CLEAR | 0 | not applicable |

Round 2 returned its deltas without applying them. The orchestrator detected this by
re-measuring the plan file, which was byte-unchanged from round 1 (same mtime, 634 lines, 80
tasks, no `P6-T7`, no `doc-literals` token), and routed the six deltas to `atomic-planner` for
application rather than treating the report as done.

## Defect B2 and the resulting spec amendment

Round 3 found that one acceptance criterion was unsatisfiable, and closing it required a change
to `spec.md` rather than to the plan alone. The orchestrator confirmed the mechanism
independently against the tree before authorising the amendment:

- The stub git logs every invocation to stderr: `printf 'stub-git: %s\n' "$*" >&2` in `tests/fixtures/cleanup_worktrees/stub-bin/git`.
- `classify_ancestry` issues `cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null 2>&1` at `scripts/bash/cleanup_worktrees_lib.sh:64`; the `2>&1` discards that log line.
- `cleanup_wt_git` (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:34-57`) is a plain exec wrapper, so the caller's redirection reaches the stub process.
- No `merge-base --is-ancestor` line can therefore appear in the argv log, and the criterion asserting one could never pass.

The replacement probe was verified before adoption: `classify_cherry_equivalent` issues
`out=$(cleanup_wt_git cherry main "$branch")` at `scripts/bash/cleanup_worktrees_lib.sh:131`,
capturing stdout only, so its `stub-git:` line survives; an all-`- <sha>` cherry output leaves
the residual array empty and prints `MERGED_EQUIVALENT` (`:159-161`); and `MERGED_EQUIVALENT` is
on the delete-eligible allowlist in `reverify_delete_eligible`
(`scripts/bash/cleanup_worktrees_actions_lib.sh:242`), so the fixture stays delete-eligible and
each re-verification emits an observable `cherry main feature-dirt` line.

The criterion now asserts the second `cherry main feature-dirt` occurrence. The acceptance-criteria
count is unchanged at 38. This is an observability substitution, not a weakening: the assertion
still pins that the re-verification happens after the clear and before the removal retry.

## Out of scope for this run

Atomic execution, PR authoring, and CI monitoring are deferred to `epic-orchestrator` per the
preparation route. The checkpoint records `next_step: "S5_atomic_execution"` with the
out-of-scope step statuses set to `not-applicable`.
