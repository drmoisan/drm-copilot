# Preflight Clearance — Issue #637 (epic child F, gap 5)

Timestamp: 2026-09-07T10-36

Command: Agent(atomic-executor) at model opus under `DIRECTIVE: PREFLIGHT VALIDATION ONLY` against `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/plan.2026-09-07T01-26.md`, three rounds; plus `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "plan"` run by the orchestrator after each revision round.

EXIT_CODE: 0

ExpectedExitCode: 0

Output Summary: PREFLIGHT: ALL CLEAR / CONVERGENCE: NO FURTHER ROUNDS EXPECTED on round 3. Three preflight rounds were required; rounds 1 and 2 each enumerated real defects, so the rounds beyond the two-round target were earned rather than spent rediscovering the same finding. Round 1 returned 16 defects (4 blocking), round 2 returned 5 further defects (1 blocking) and confirmed all 16 round-1 closures against the tree, round 3 confirmed all 5 round-2 closures and found no sibling invalidation. The plan validator gate returned ok with no warnings after each revision, so acceptance-gate rules G1 through G9 are clear. Final plan shape: 11 phases, 104 tasks, none pre-checked; all 43 spec criteria AC-01 through AC-43 present, unchecked, and each claimed by exactly one `Satisfies` task.

## Rounds

| Round | Signal | Convergence | Defects |
|---|---|---|---|
| 1 | `PREFLIGHT: REVISIONS REQUIRED` | `NO FURTHER ROUNDS EXPECTED` | 16 (4 blocking, 5 medium, 7 low) |
| 2 | `PREFLIGHT: REVISIONS REQUIRED` | `NO FURTHER ROUNDS EXPECTED` | 5 (1 blocking) |
| 3 | `PREFLIGHT: ALL CLEAR` | `NO FURTHER ROUNDS EXPECTED` | 0 blocking; 2 non-blocking carried into execution |

## Blocking defects closed

Round 1:

1. **Worktree-path hardcoding.** The plan hardcoded a different agent worktree in roughly 40 command spans. The reviewer reproduced the harness isolation guard refusing those `git -C` spans. The orchestrator declined the reviewer's proposed fix of substituting the review worktree's root, because this is preparation mode and atomic execution runs later in a fresh worktree whose path is not knowable at planning time; substituting either concrete root would fail identically at execution. The plan was re-authored worktree-agnostic instead: bare `git` spans resolving through cwd, a runtime-resolved WSL root recorded in `[P0-T2]`, and a tree-contents workspace check replacing the hardcoded branch-name assertion.
2. **Phase-ordering defect.** `[P3-T9]` gated a test whose driver function `run_preserve` was not created until `[P4-T5]`. Re-authored to drive `preserve_resolve_jq`, created in the same phase.
3. **Exit-127 assertion that could not fail.** The AC-05 test asserted status 127, which bash also returns for "command not found", so a failed source or a misspelled function name would pass it without the logic under test running. Now asserts 127 together with the diagnostic token `no jq binary resolved`, which bash does not print.
4. **Unsatisfiable `-f` search.** `[P4-T3]` asserted that neither `-f` nor `--force` appears on any git invocation in a file that necessarily contains `[[ -f "$path" ]]`. Rescoped to `cleanup_wt_git`-bearing lines.

Round 2:

5. **Unsatisfiable byte-identity gate.** `[P10-T2]` compared two unscoped `git status --porcelain` captures for byte-identity, but `[P9-T3]` runs `git add -A` first, which indexes the evidence tree; git then stops collapsing `evidence/qa-gates/` as an untracked directory and lists new files individually, so `[P10-T1]`'s own artifact — written between the two captures — appears in the second listing and not the first. The gate would have failed on every run irrespective of the formatter. Both captures are now scoped to `scripts tools .claude/lib/bash`, the three roots `discover_shell_scripts` walks at `scripts/bash/shell_qc_lib.sh` line 85, which are the only paths `shfmt -w` can rewrite. Verified in-tree: `git status --porcelain -- scripts tools .claude/lib/bash` exits 0 with empty output, and the evidence tree falls outside all three roots.

This defect class is covered by no validator rule. `.claude/rules/plan-acceptance-gates.md` records task-ordering satisfiability as author judgment rather than an automated check.

## Cross-agent corrections recorded

Two instances where a delegate rejected an instruction on evidence rather than following it. Both were verified independently by the orchestrator.

- **Round 1 defect 15 premise was incomplete.** The reviewer stated the degraded coverage outcome is an empty percent value. The planner re-derived `scripts/bash/shell_qc_lib.sh` and found the guard at line 286 returns 0 *without printing*, so the dominant degraded outcome is no headline at all. The authored branch covers both. The round-2 reviewer re-derived the same lines and withdrew its own premise.
- **Round 2 delta named a function that does not exist.** The reviewer's D1 delta cited `collect_shell_files`. The planner refused to write it and substituted the real identifier. Orchestrator verification: `scripts/bash/shell_qc_lib.sh` line 75 defines `discover_shell_scripts`, call sites at lines 172 and 211; `collect_shell_files` returns zero matches in that file; the revised plan carries the correct name twice and the incorrect name zero times. The line number and the three roots in the delta were correct.

## Non-blocking observations carried into execution

Neither prevents a task from executing or a gate from being recorded. A fourth planning round for two acceptance-wording tweaks would cost more than handling them in flight.

1. `[P1-T1]`'s acceptance "the file contains an `add)` case arm" is already true: `tests/fixtures/cleanup_worktrees/stub-bin/git` line 103 is `add) respond "worktree-add" ;;`, nested inside the `worktree)` arm. The condition cannot fail as written. It is backstopped by `[P1-T9]` (AC-32), which drives the new top-level `add` case and does fail if that arm is missing. The executor verifies a top-level `add)` arm distinct from the nested one.
2. `[P4-T5]` asserts the token `MISSING`, a substring of `MISSING-WORKTREE` in the same acceptance clause, so the manifest-missing precondition has no discriminating check and no dedicated test. The executor asserts a discriminating literal such as `preserve-manifest` when verifying that clause.

## Execution risk recorded

The plan's bash toolchain route is refused inside an agent-isolated worktree. The round-3 reviewer probed the pwsh-wrapped WSL form and the harness worktree-isolation guard denied it before execution. This confirms the plan's own citation rather than contradicting it, and `[P0-T2]` is the correct fail-closed handling: on refusal it records `ROUTE REFUSED` with `EXIT_CODE: 1` and `ExpectedExitCode: 1`, stays unchecked, and the plan halts before any gate is recorded. Roughly 30 targeted `bats` gates have no CI fallback by design, because the coverage workflow emits no per-test TAP output. The execution worktree must be one where the WSL route is permitted, or execution cannot proceed past Phase 0.

## Verification performed by the orchestrator

- Plan validator gate after each revision round: `ok: true`, no warnings.
- Post-revision shape: 11 phases, 104 tasks; zero occurrences of `agent-a1dc`, `agent-a466`, or `DanMoisan`; the 3 surviving `git -C` occurrences at plan lines 572, 587, 606 are all `cleanup_wt_git -C` descriptions of the preserve library's runtime behavior, not executor invocations.
- Walker identifier re-derived directly against `scripts/bash/shell_qc_lib.sh`.
- Checkpoint validated with `--require-model-routing` at exit 0 after every phase transition. Gate discrimination confirmed on the same file: a prior revision carrying `step5_status: in-progress` returned exit 1, so the passing result is not vacuous.
