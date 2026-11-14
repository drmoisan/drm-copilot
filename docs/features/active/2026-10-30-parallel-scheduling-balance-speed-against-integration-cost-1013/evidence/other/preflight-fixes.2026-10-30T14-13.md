# Preflight Fixes — Issue #1013

Timestamp: 2026-10-30T14-13
Plan: docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/plan.2026-10-30T09-15.md
Signal: PREFLIGHT: REVISIONS REQUIRED (two substantive defects returned to the planner; listed at the end for traceability)

Every fix below edits task text only. No task was added, removed, reordered, or checked.

## Fixes Applied

1. [P0-T1] | literal formatting (blocked-return token) | The stop instruction for an absent #1006 observable now says to leave every task unchecked and to return the line `BLOCKED at [P0-T1]: #1006 not merged` with the uppercase `BLOCKED` token. Previously it said "STOP the run as blocked" in lowercase, which the executor SubagentStop hook does not read as a blocked claim. The gate condition is unchanged.
2. [P0-T3] | ambiguous anchor | "token-shape rejection paragraph" now names the paragraph under `### Read-by-mandate classification` that begins `The extractor additionally rejects`. The fix also excludes the `**Accepted residuals (fail-closed direction).**` paragraph under `### File-shape recognition (issue #797)`, which also states a token-shape count (currently three).
3. [P2-T3] | incomplete asserting-test disposition (validator-blind class) | The disposition list adds `test_after_edges_match_pins`, `test_after_tolerated_overlaps_match_pins`, `test_after_cohorts_match_pins`, and #1006's `test_blast_radius_generic_contracts.py`, all unchanged. Verified with a SCRATCH wrapper around `schedule_conflict_edges`: across the existing scheduling, historical-run, write-intent, drift, and regression-452 modules (66 calls, 8 with tolerated overlaps), no item exceeds its aggregate cap. The historical fixtures carry no `SheetN`/`ChartN` contract, so #1006's normalization filter does not change their tolerated sets.
4. [P4-T3] | incomplete asserting-test disposition | Adds #1006's `BlastRadiusGenericContract.Tests.ps1` as unchanged. Its scenario schedules one pair, and a single tolerated overlap never exceeds the cap.
5. [P4-T2] | unnamed asserting test for a new file | Names `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, which discovers every `.claude/lib/**/*.psm1` from disk. The fix states the three conventions that test asserts: the guard line after `Set-StrictMode`, the help-block convention sentence, and `-ErrorAction Stop` on column-0 imports.
6. [P4-T4] | unnamed asserting test for a new file | Same convention requirement as fix 5.
7. [P6-T1] | missing asserting-test disposition | Adds the existing tests that read the rule (`test_parallel_orchestration_rule_defines_p10`, the cache-doctrine rows of `test_epic_bounded_child_return_contract.py`, `test_claude_rules_frontmatter.py`), all unchanged.
8. [P6-T3] | missing asserting-test disposition | Adds `test_parallel_planner_surface_contracts.py`, `test_parallel_planner_agent_requires_routing_record`, and `test_claude_rules_frontmatter.py`, all unchanged, with the constraint that no `##` heading is added.
9. [P6-T4] | incomplete asserting-test disposition | Adds `test_delivered_runtime_files_carry_no_prescriptive_epic_literal`, unchanged. The skill is a delivered runtime file scanned for `PRESCRIPTIVE_EPIC_LITERALS`.
10. [P6-T5] | missing asserting-test disposition | Adds `test_agent_body_contains_exactly_the_nine_required_headings` (the agent's `##` set is pinned to nine), `test_delivered_runtime_files_carry_no_prescriptive_epic_literal`, `test_parallel_orchestrator_agent_names_admitted_item_source`, and the agent rows of `parallel-orchestrate-run-closing.Tests.ps1`, all unchanged.
11. [P8-T5] | file named by basename or count only | Names the three blast-radius modules and the four touched Pester files by their full repository-relative paths.
12. [P8-T11] | file named by basename only | Names the five Pester suites by their full repository-relative paths.

## Substantive Defects Returned (not fixed in place)

- [P4-T10] | task-ordering error (unsatisfiable acceptance) | `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` discovers every `.claude/lib/blast-radius/*.psm1` on disk. Its rows `lists every discovered library module in core.json paths` and `ships a bundled counterpart for every library module` fail at P4-T10, because P4-T2 and P4-T4 create the modules and they are bundled and manifested only at P7-T1 and P7-T2.
- [P8-T13] / `## Conventions` | scope boundary | The branch carries `docs/features/potential/promoted/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost.md` (staged now, committed with the feature folder). That path is neither in the declared write set nor under `FEATURE`, so the P8-T13 acceptance "zero out-of-scope paths" cannot be met.
