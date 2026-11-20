# Preflight Fixes — Issue #1013

Timestamp: 2026-10-31T14-51
Plan: docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/plan.2026-10-30T09-15.md (v0.7)
Directive: PREFLIGHT VALIDATION ONLY (single-pass preflight; task text edited only; no task added, removed, reordered, or checked)

## Fixes

1. [P7-T2] | validator-blind class: existing test outside the named exclusion list | The exclusion list for the added `## Issue Combination` text named six fragments, while `test_skill_contains_no_pinned_word_and_no_forbidden_fragments` in `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` (named by the task as unchanged) rejects eleven, including `integration branch is created`, which combination prose could plausibly contain. The task text now also names the remaining fragments of that test's `forbidden` tuple. The disposition (unchanged) and the assertion are the same.
2. [P7-T4] | validator-blind class: literal-format constraint narrower than the asserting test | The element 3 continuation constraint said only "no line starting `6. `". `_element_four_text` in `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` (used by `test_parallel_orchestrate_element_four_carries_issue_adoption` and `test_added_skill_text_does_not_match_hook_issue_number_pattern`, both named unchanged) requires exactly one line starting `4. ` and one starting `5. `. The constraint now states that no added line starts with a digit followed by `. `.
3. [P7-T4] | validator-blind class: existing asserting tests not named | `test_seam_status_template_realises_header_fields_prescribed_by_skill` and `test_seam_status_template_realises_cohort_columns_prescribed_by_skill` in `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` parse the `## Documentation Maintenance Boundaries` section that P7-T4 edits. Both are added to the unchanged list with the reason (the added text adds no second `Header block fields:` sentence and no `cohorts[] {` projection).
4. [P2-T7] | validator-blind class: existing tests that consume an edited fixture not named | `SOURCE_BLAST_RADIUS` is also consumed by `demotes quality-tiers.yml with tolerance 5000 on push (issue #1006 AC-04)` in `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts` and by the remaining seeding rows of `claude-config-carriage.test.ts`. Both are added as unchanged with the reason (none asserts a `weights` value).
5. [P4-T3] | validator-blind class: existing tests that consume an edited fixture not named | The same two consumers are added as unchanged for the `combination_threshold_percent` edit (none asserts that member).

## Checks Performed Without a Fix

- Weight-map set: a search for `possible_overlap` outside `docs/` returns exactly the 27 files listed in `## Conventions`.
- P0-T1 observables present at `HEAD`: `def is_generic_contract_token`, `SHARED_SURFACES_DEMOTE_KEY`, and `quality-tiers.yml` in `conflict_tolerance.append_only_paths` and not in `shared_surfaces` of `config/blast-radius.json`.
- Every test name cited for #1002 (`test_parallel_planner_no_scratch_worktree_contracts.py`), #1011 (`pr-author-coordinator-topology-contract.Tests.ps1` CT-01 to CT-07), #1012 (`test_parallel_mutation_rejection_signal_contracts.py`), and #1006 (`test_blast_radius_generic_contracts.py`, `BlastRadiusGenericContract.Tests.ps1`) exists under the cited name.
- Facade export count in `.claude/lib/blast-radius/BlastRadius.psm1` and the row `'exports no function beyond the spec-fixed names'` both read 14.
- `core.json` blast-radius block ends with `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1`.
- All scheduling, write-intent, and parallel-drift fixtures in the Weight-map set carry empty `contracts`, so their pinned costs are unchanged; `CodeCoverage.Path` appears only in `followups-2026-09-27.json`.
- `scripts/dev_tools/parallel_manifest_contract.py` rejects only the prohibited keys `depends_on` and `integration_branch`, so `combined_issue_nums` on a manifest item is tolerated.
- Plan validator: installed MCP validator and branch-current CLI both pass.
