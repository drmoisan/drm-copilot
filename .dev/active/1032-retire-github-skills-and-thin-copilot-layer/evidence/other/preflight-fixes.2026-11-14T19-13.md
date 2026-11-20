# Preflight Fixes — Main Plan (2026-11-14 refresh)

Timestamp: 2026-11-14T19-13
Plan: plan.2026-10-30T18-39.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects returned separately; the fixes below are trivial and were applied in place)

## Fix 1 — [P1-T11] stale disposition of an asserted token

- Defect class: stale citation of an existing test's asserted value (validator-blind, changed-behavior test disposition).
- Finding: the task stated that the asserted token of `test_contract_premortem_mirror_parity_requires_brief_update_task` in `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` is `byte-identical copies` with no count. The `tokens` tuple joins two adjacent literals by implicit string concatenation, so the asserted token is `includes a task that updates the brief in the same change, in all six byte-identical copies`. Once S6 reads `in all four byte-identical copies`, the test fails and the task's own acceptance cannot pass.
- Change: the task now updates that asserted token to `in all four byte-identical copies` together with the docstring count. The intent of the task (S6 target in every copy, the module passing) is unchanged.

## Fix 2 — [P1-T7] symbol-to-file attribution

- Defect class: anchor location (symbols named without their files).
- Finding: the listed symbols are spread over four modules: `test_root_folders_include_published_github_hooks_in_scoped_order` is in `test_agentic_sync_artifacts.py`; `test_force_left_to_right_overrides_newer_right` is in `test_agentic_sync.py`; `_seed_scoped_source_files`, `test_push_down_copies_scoped_github_trees_to_empty_destination` and `test_push_down_overwrites_existing_destination_file` are in `test_push_down_copilot_customizations.py`; `test_push_down_reports_unmatched_script_references_without_rewrite` is in `test_push_down_copilot_customizations_rewrites.py`.
- Change: each symbol now names its module, and the `test_force_left_to_right_overrides_newer_right` update states that its root moves to a remaining `ROOT_FOLDERS` member, because `AgenticSyncer.sync_repos` iterates `ROOT_FOLDERS` and the test reads `summary.actions[0]`.

## Fix 3 — `## Size Justification` count

- Defect class: prose count.
- Finding: the justification stated twelve Pester files; `UPDATED-PESTER-SUITES` holds fourteen PowerShell test files (nine contract suites, the docs-authoring helper and its three consumers, and `ProcessReductionLedger.Tests.ps1`), and `UPDATED-PYTEST-MODULES` holds four conditional modules beyond the twelve.
- Change: the sentence now states twelve Python modules, four more when `RootConstants` is present, and fourteen PowerShell test files.

## Validation

- Command: repository Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` on the plan, run after the fixes.
- EXIT_CODE: 0
- Output Summary: `plan validation passed`.
