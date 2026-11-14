# Preflight Fixes

Timestamp: 2026-11-09T22-19
Plan: docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/plan.2026-11-09T16-33.md

Trivial defects fixed in place in task text and preamble. No task was added, removed, or reordered, and no checkbox was changed.

1. `## Terms and Standing Rules` | glob token in plan prose | `issue-1161-*` replaced by "scratch file names start with `issue-1161-`".
2. `[P0-T4]` | unobservable success-case output | Jest `coverageReporters` is `lcov` plus `text-summary`, and `text-summary` prints totals only; the per-file source is now named as `extensions/drm-copilot/coverage/lcov.info`.
3. `[P1-T1]` | boundary coverage made explicit | Added a `Content:` line that names one entry per boundary of each rejecting file (branch sub-rules, a three-entry duplicate, empty and dot-segment `path`, case variants for `preparation_status` and `purpose`). The asserted error strings are unchanged.
4. `[P1-T3]` | non-concrete path | "the readiness suites in `extensions/drm-copilot/test/lib/validate/`" replaced by the three named readiness test files.
5. `[P2-T1]` | boundary coverage made explicit | Named the three U1 variants, a case-variant status and purpose row, and an absent or empty `integration_branch` row. The codes and order are unchanged.
6. `[P2-T3]` | missing mechanical dependency | Added a guarded dot-source of `.codex/hooks/hook-target-worktree.ps1`, which defines `ConvertFrom-HookTargetWorktreePorcelain` and which the Codex gate does not load today.
7. `[P2-T5]` | unsatisfiable fail-before scope wording | The adapter-level allow rows of P2-T2 and P2-T3 pass before the gate edit; the list is now limited to the gate-level allow rows (P2-T3 rows through `Invoke-CodexWorktreeRemovalDecision`, and both P2-T4 suites). The acceptance condition is unchanged.
8. `[P4-T4]` | non-concrete reference | "every push-down contract test of research section 6" replaced by the named pytest files from AC-30 and the `PINNED_FROZEN_SURFACE_HASHES` rows of `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
9. `[P4-T5]` | unobservable success-case output | Per-file Jest figures now named as read from `extensions/drm-copilot/coverage/lcov.info`.
10. `## Existing Test Dispositions` | non-concrete paths and missing unchanged-disposition entries | Abbreviated suite names expanded to full repository-relative paths. Added, all unchanged: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1`, `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py`, `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py`. "the parallel-rule readers under `tests/scripts/dev_tools/`" replaced by a statement that names the two edited documents and the two edited regions.

Validation after the fixes: the Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` and the MCP `validate_orchestration_artifacts` (`artifact_type: plan`) were both re-run on the plan.
