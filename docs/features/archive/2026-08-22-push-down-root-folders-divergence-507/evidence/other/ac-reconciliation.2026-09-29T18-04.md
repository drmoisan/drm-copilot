# Acceptance Criteria Reconciliation (P10-T1)

Timestamp: 2026-09-29T18-04
AC source: docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md (Work Mode: full-bug)
Evidence root: docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/

Output Summary:
- 25 AC rows. AC1 through AC24 each name at least one existing passing artifact. AC25 is deferred to PR time.

| AC | Verifying tasks | Evidence artifacts | Status |
|---|---|---|---|
| AC1 | P1-T1, P1-T4, P5-T1, P5-T7 | regression-testing/ac1-root-folders-fail-before.2026-09-29T17-28.md; regression-testing/ac1-root-folders-pass-after.2026-09-29T17-54.md | PASS |
| AC2 | P1-T3, P1-T5, P5-T8 | regression-testing/parity-fail-before.2026-09-29T17-28.md; regression-testing/parity-pass-after.2026-09-29T17-54.md | PASS |
| AC3 | P1-T3, P4-T2, P3-T2, P5-T8 | regression-testing/parity-pass-after.2026-09-29T17-54.md | PASS |
| AC4 | P1-T3, P1-T5, P5-T8 | regression-testing/parity-fail-before.2026-09-29T17-28.md (6 synthetic/zero-declaration tests pass); regression-testing/parity-pass-after.2026-09-29T17-54.md | PASS |
| AC5 | P5-T5, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_config_carriage_publishes_exactly_two_bundle_config_files) | PASS |
| AC6 | P5-T5, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_summary_lists_claude_files_before_config_files, test_published_blast_radius_is_derived_for_injected_layout) | PASS |
| AC7 | P2-T2, P4-T5, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_push_down_claude_routing_merge.py nodes) | PASS |
| AC8 | P2-T2, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (error tests in test_push_down_claude_routing_merge.py) | PASS |
| AC9 | P4-T4, P5-T5, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_destination_merge_leaves_bytes_unchanged_on_routing_merge_error, test_routing_merge_error_aborts_with_destination_bytes_unchanged) | PASS |
| AC10 | P2-T2, P5-T5, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_second_push_produces_byte_identical_routing_file) | PASS |
| AC11 | P3-T3, P3-T4, P3-T5, P4-T3, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_push_down_claude_blast_radius_derive*.py nodes) | PASS |
| AC12 | P4-T2, P4-T4, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_merged_relative_paths_initial_registry_is_routing_only) | PASS |
| AC13 | P4-T4, P5-T6, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_build_stack_layer_order_derive_over_merge_over_inner, test_build_stack_caller_merges_replace_default_registry, test_push_down_customizations_obtains_decorators_only_through_stack) | PASS |
| AC14 | P4-T4, P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_bundle_config_* nodes) | PASS |
| AC15 | P4-T2, P4-T4, P7-T4 | other/extension-seam-docstring.2026-09-29T17-58.md | PASS |
| AC16 | P1-T2, P1-T3, P5-T8, P6-T1 | regression-testing/parity-pass-after.2026-09-29T17-54.md; regression-testing/jest-routing-merge-parity.2026-09-29T17-57.md | PASS |
| AC17 | P5-T10 | regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md | PASS |
| AC18 | P7-T1 | other/scope-boundary.2026-09-29T17-58.md | PASS |
| AC19 | P7-T2 | other/no-temp-files.2026-09-29T17-58.md | PASS |
| AC20 | P7-T3 | other/line-counts.2026-09-29T17-58.md | PASS |
| AC21 | P0-T15, P8-T5, P8-T6 | baseline/python-coverage-baseline.2026-09-29T17-28.md; qa-gates/python-coverage.pass-1.2026-09-29T17-59.md; qa-gates/python-coverage-delta.2026-09-29T17-59.md | PASS |
| AC22 | P8-T1..P8-T7, P9-T1..P9-T6 | qa-gates/python-loop-clean-pass.2026-09-29T17-59.md; qa-gates/ts-loop-clean-pass.2026-09-29T18-02.md (test-code tsc passes under the plan's baseline-equality clause: 353 pre-existing errors in 71 files, none in the new file) | PASS |
| AC23 | P5-T3, P5-T4, P5-T5, P5-T9, P7-T5 | other/cli-help-stale-text-absent.2026-09-29T17-54.md; other/ac23-config-mentions.2026-09-29T17-58.md; regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md (test_module_docstring_and_cli_help_name_config_payload, test_readme_claude_row_lists_config_payload) | PASS |
| AC24 | P7-T6 | other/ac24-follow-up-candidates.2026-09-29T17-58.md | PASS |
| AC25 | (PR authoring) | DEFERRED-TO-PR-TIME: verified by the epic orchestration session when it authors the PR description | DEFERRED |

Recorded deviations:
- Branch: executed on `bug/push-down-root-folders-divergence-exec-507` as directed by the epic orchestrator (plan names `bug/push-down-root-folders-divergence-507`); see baseline/git-anchor.2026-09-29T17-28.md.
- Delegation: the plan delegates edits to `python-typed-engineer` and `typescript-engineer`; this session had no delegation tool, so atomic-executor performed the edits directly within each phase's batch.
- P4-T2(h): the #621 sentence is wrapped across two docstring lines (107 characters exceeds Ruff E501's 88 columns); the docstring test asserts all three sentences after whitespace normalization.
- P4-T4: `_DelegatingFileSystem` exposes a read-only `inner` property so the layer-order test inspects the stack without private-attribute access (strict Pyright).
- P5-T2: the write stack is bound to a local `write_stack` before being passed to `BundleConfigFileSystem`; the composition is the one the task specifies.
- Commit cadence: the caller required a commit and push at every phase boundary, so P10-T3 commits only the Phase 10 remainder, and the push it prohibits is performed under the caller's cadence rule.
- Batch-budget hook: the gitignored `.claude/state/python-batch-budget.*.json` file was deleted at each phase boundary (the hook's documented reset) and before each full-suite run, because the resource-contract test enumerates it as an unmirrored `.claude` file (local-only, issue #510 class).
