# Preflight Fixes — Issue #1013 (second preflight)

Timestamp: 2026-10-30T14-28
Plan: docs/features/active/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost-1013/plan.2026-10-30T09-15.md (version 0.3)
Signal: PREFLIGHT: ALL CLEAR
Prior record: evidence/other/preflight-fixes.2026-10-30T14-13.md

Every fix below edits task text only. No task was added, removed, reordered, or checked. After the fixes, the plan passes the installed MCP validator and the branch-current Python CLI (`validate_orchestration_artifacts plan`, exit 0).

## Round-1 Defects Verified

- [P4-T10] / [P7-T3]: P4-T10 now exempts only the two rows `lists every discovered library module in core.json paths` and `ships a bundled counterpart for every library module` of `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`. P7-T3 requires that suite to report zero failures, read from the JUnit file. The test discovers `.claude/lib/blast-radius/*.psm1` from disk, and no task between P4-T2 and P7-T2 runs that suite. Resolved.
- `## Conventions` / [P8-T13]: the promoted lifecycle record `docs/features/potential/promoted/2026-10-30-parallel-scheduling-balance-speed-against-integration-cost.md` (staged on the branch) is now in the declared write set, and P8-T13 accepts it. Open Questions records the AC-22 reading. Resolved.

## Fixes Applied

1. [P3-T5] | stale symbol (anchor) | Replaced `merge_blast_radius_overlay` with `compose_blast_radius_overlay` and a `None` overlay. `merge_blast_radius_overlay(destination_text: str, source_text, path)` in `scripts/dev_tools/push_down_claude_destination_writes.py` requires overlay text, and the writer calls it only when the overlay file exists. `compose_blast_radius_overlay(base_text, overlay_text: str | None, overlay_path)` returns the base unchanged for `None`, which matches P3-T6's `composeBlastRadiusOverlay` with a null overlay. The fix also states that the observation sequence passed to `derive_destination_module_map` is empty. The asserted values (100 and 400) are unchanged.
2. [P1-T4] | literal clarification (validator-blind) | Adds the in-test import requirement already stated for P1-T3. The P1-T7 acceptance requires collection to succeed for this module before implementation.
3. [P1-T5] | literal clarification (validator-blind) | Same as fix 2.
4. [P1-T6] | literal clarification (validator-blind) | Same as fix 2, for `COMBINATION_THRESHOLD_DEFAULT`.
5. [P6-T2] | incomplete asserting-test disposition | Adds three modules, all unchanged:
   - `test_parallel_planner_surface_contracts_landed.py`, which scans the whole skill. The added text must carry no `pinned` token in any letter case, no two-argument `conflicts(a, b)` form, and no `python -m` invocation of either library.
   - `test_parallel_kickoff_template_seam.py`, which reads only the first fenced `markdown` block after `## Kickoff Artifact`. That block follows the new section.
   - `test_skill_bundle_contract_repo.py`.
6. [P6-T4] | incomplete asserting-test disposition | Adds three tests that read the edited sections, all unchanged:
   - `test_completion_gate_documentation_contracts.py`, with the merge-queue fragment pins from `merge_queue_documentation_expectations.py`.
   - `test_merge_on_green_always_rereads_every_check` in `test_ci_gate_all_checks_contracts.py`. The added text must carry neither `MERGE_ON_GREEN_SUPERSEDED` phrase.
   - The marker-binding Context of `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`. Element 1's marker line must stay the first line in the kickoff section that names `parallel_checkpoint_path`.
7. [P6-T9] | missing asserting-test disposition | Adds the template rows of `test_parallel_orchestrator_surface_contracts.py` (banner, header fields, cohort header row, projection binding), all unchanged.

## Checks Without Findings

- All 54 Complete File List entries have a writing task. AC-01 to AC-25 and US-01 to US-17 each map to at least one task.
- Every existing file, symbol, heading, and test name cited for the current tree was confirmed present. Citations to #1006 symbols (`is_generic_contract_token`, `SHARED_SURFACES_DEMOTE_KEY`, `test_blast_radius_generic_contracts.py`, `BlastRadiusGenericContract.Tests.ps1`) were checked against the #1006 spec on `origin/bug/parallel-scheduling-false-hard-edges-1006`. That branch does not yet carry the implementation.
- The Python, TypeScript, and bash validators reject only listed prohibited keys and check required keys. `combined_issue_nums` and `combinations` are therefore accepted without a validator edit.
- `config/poshqc-coverage.json` lists `.claude/lib` as a root, so the two new modules are measured by P8-T6. The overlay corpus parity tests assert at least 6 files, so P3-T4's new file passes.
- Current line counts of the edited files are at most 495. No `observed_resolution` token exists in the AC-07 scan population. No parallel file has a `.codex`, `.agents`, or `.github` mirror.
