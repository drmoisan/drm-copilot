# Feature Audit: Push-Down Root Folders Divergence (#507)

- Branch: `bug/push-down-root-folders-divergence-exec-507`
- Head commit: `977a1011`
- Audit timestamp: 2026-09-29T18-12
- Issue: #507 (also covers #764 part 2); parent epic #770 (`push-down-payload-correctness`, wave 0)

## Scope and Baseline

- Baseline: `origin/epic/push-down-payload-correctness-integration`. This branch is an epic child whose PR targets the integration branch, not `main`. All diffs use `git diff origin/epic/push-down-payload-correctness-integration...HEAD`.
- Diff size: 63 files, 4487 insertions, 103 deletions. Code delta: 6 Python production files (5 new, 1 modified), 10 Python test files (9 new, 1 modified), 1 JSON fixture, 1 Jest test file, `README.md`. The remainder is feature-folder evidence, plan checkboxes, and `spec.md` AC checkboxes (the `spec.md` diff is 24 checkbox lines only).
- Work mode: `full-bug`, read from `issue.md` line 13 (`- Work Mode: full-bug`) and confirmed by `spec.md` line 9. AC source: `spec.md` `## Acceptance Criteria` only.
- Baseline behavior: `scripts/dev_tools/push_down_claude_customizations.py` declared `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"),)`, while TypeScript declared `[".claude", "config"]`. The Python path published no `config/` tree and had no destination-side merge or derivation decorators.
- Post-change behavior: Python declares `(Path(".claude"), Path("config"))`, reads `config/` from `extensions/drm-copilot/resources/claude-customizations/config/` (two files), merges `config/orchestration-routing.json`, and derives `config/blast-radius.json` from a depth-3 destination scan.
- Reviewer verification: all code was read; Black, Ruff, Pyright, the scoped and full pytest runs, Prettier, ESLint, and Jest were re-run by the reviewer (see `policy-audit.2026-09-29T18-12.md`).

## Acceptance Criteria Inventory

- Source: `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md`, section `## Acceptance Criteria` (lines 238-264).
- Format: markdown checkboxes, AC1 through AC25.
- Total AC items: 25.
- Checked on entry to review: 24 (AC1-AC24, checked by the executor in P10-T2).
- Unchecked on entry to review: 1 (AC25).
- The `## Test Strategy` checklist items in `spec.md` (lines 222-226) are strategy notes, not acceptance criteria, and are not tracked here.

## Acceptance Criteria Evaluation

| AC | Criterion (abridged) | Verdict | Evidence |
|---|---|---|---|
| AC1 | `ROOT_FOLDERS == (Path(".claude"), Path("config"))`, verified by the updated assertion near line 80 | PASS | `push_down_claude_customizations.py:115` is the single line `ROOT_FOLDERS: tuple[Path, ...] = (Path(".claude"), Path("config"))`; `test_push_down_claude_customizations.py:80` asserts it; passes in the reviewer's 194-test run. Fail-before evidence: `evidence/regression-testing/ac1-root-folders-fail-before.2026-09-29T17-28.md`. |
| AC2 | Parity test asserts ordered equality of TS and Python `ROOT_FOLDERS`, failure message names both files | PASS | `test_root_folders_match_typescript_in_order` (parity test line 257) uses comment-stripped TS extraction and `ast` Python extraction and passes both file labels to `_assert_same`. |
| AC3 | Set equality of merged paths and derived paths; each set has exactly one member | PASS | `test_merged_relative_paths_match_typescript` and `test_derived_relative_paths_match_typescript` assert set equality and `len(...) == 1` on both sides. |
| AC4 | Synthetic divergence tests and zero-declaration tests fail rather than pass vacuously | PASS | `test_typescript_root_folder_extraction_detects_divergence`, `test_python_root_folder_extraction_detects_divergence`, `test_set_comparison_fails_on_divergent_merged_paths`, `test_typescript_extraction_rejects_zero_declarations`, `test_python_extraction_rejects_zero_declarations`. |
| AC5 | In-memory push with five repo-root config files and two bundle files yields exactly the two bundle files | PASS | `test_config_carriage_publishes_exactly_two_bundle_config_files`; `_seed` places three repo-only files plus repo `blast-radius.json` and `orchestration-routing.json` under the source `config/` and two files under the bundle `config/`. |
| AC6 | Summary lists `.claude` before `config`; published blast-radius equals the derived document | PASS | `test_summary_lists_claude_files_before_config_files` asserts root order `[".claude", ".claude", "config", "config"]`; `test_published_blast_radius_is_derived_for_injected_layout` asserts the derived `modules` map and that the bytes differ from both the repo and bundle documents. |
| AC7 | Routing-merge unit coverage of all listed semantics | PASS | `test_push_down_claude_routing_merge.py`: destination-absent, destination-order preservation, `parallel` replacement, source-only routes and top-level keys appended, non-object destination `routes`, appended non-object source `routes` becoming `{}`. |
| AC8 | `RoutingMergeError` is a `ValueError` with `.path` and the TS message for invalid JSON, `NaN`/`Infinity`, non-object roots on either side | PASS | `test_merge_raises_for_invalid_destination_json`, `..._invalid_source_json`, `..._non_finite_constants` (parametrized by constant and side), `..._non_object_destination_root`, `..._non_object_source_root`, `test_routing_merge_error_is_value_error_with_path_and_message`. |
| AC9 | Destination routing bytes unchanged after `RoutingMergeError` | PASS | `test_routing_merge_error_aborts_with_destination_bytes_unchanged` (carriage) and the corrupt-destination case in `test_push_down_claude_destination_writes.py` (asserts `"{corrupt"` preserved). |
| AC10 | Two pushes produce byte-identical routing output | PASS | `test_second_push_produces_byte_identical_routing_file`. |
| AC11 | Derivation tests mirror the TS core suite with an injected lister and no filesystem access | PASS | `test_push_down_claude_blast_radius_derive_core.py` (ancestor pruning, top-level fallback, `config` payload module collision, fixed key order, determinism, non-mutation) and `..._core_guard.py` (`BlastRadiusGuardError` for `**`, `docs/**`, `tests/**`). |
| AC12 | `MERGED_RELATIVE_PATHS` is a module-level literal equal to `{"config/orchestration-routing.json": merge_routing_documents}`, verified by a test | PASS | `push_down_claude_destination_writes.py:86-88`; `test_push_down_claude_destination_writes.py` parses the module with `ast` (line 80) to verify the literal. |
| AC13 | Stack order derive over merge over inner; caller `merges` replaces default; entry point uses only the stack | PASS | `test_build_stack_layer_order_derive_over_merge_over_inner`, `test_build_stack_caller_merges_replace_default_registry`, `test_push_down_customizations_obtains_decorators_only_through_stack`. |
| AC14 | `BundleConfigFileSystem` redirects `list_files`, `is_file`, `read_text`; passes other paths through; identity when roots match | PASS | `test_bundle_config_lists_bundle_files_under_source_config_root`, `test_bundle_config_redirects_is_file_and_read_text`, `test_bundle_config_passes_through_non_config_paths`, `test_bundle_config_is_identity_when_roots_match`, `test_bundle_config_lists_nothing_when_bundle_config_absent`. |
| AC15 | Spec and module docstring state the #508 and #621 seam extensions; `rg -n "#508|#621"` matches | PASS | `spec.md` Extension seams section (lines 156-160); `push_down_claude_destination_writes.py` lines 24-27; `rg` matches lines 24 and 25. The #621 sentence wraps across lines 25-26 (non-blocking, see code review). `test_module_docstring_names_downstream_seams` asserts the full sentences after whitespace normalization. |
| AC16 | Shared fixture exists; pytest and Jest both assert byte-identical merge output | PASS | `tests/fixtures/push_down/routing-merge-parity.json` (nine cases); `test_routing_merge_fixture_parity` passes; reviewer-run `npx jest test/lib/push-down/claude-routing-merge-parity.test.ts`: 9 passed. |
| AC17 | Pre-existing Python push-down tests pass with no change other than AC1 | PASS | Reviewer run `pytest tests/scripts/dev_tools -k push_down_claude`: 194 passed. The only modified pre-existing test file is `test_push_down_claude_customizations.py`, with the single AC1 line changed. |
| AC18 | No production path under `extensions/drm-copilot/src/` and none of the listed protected files in the diff | PASS | `git diff --name-status` shows only `extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts` under `extensions/`; `skill_bundle_contract.py`, `push_down_copilot_customizations.py`, `push_down_claude_filesystem.py`, `test_push_down_claude_resource_contracts.py`, and `enforce-powershell-batch-budget.ps1` and its tests are absent. |
| AC19 | No temp files in new or changed tests | PASS | `rg "tmp_path|tempfile|TemporaryDirectory|mkdtemp"` over `tests/scripts/dev_tools/test_push_down_claude_*.py`: no matches. |
| AC20 | Every new or changed production and test file under 500 lines | PASS | Maximum 444 lines (`push_down_claude_customizations.py`); maximum test 438 lines (`test_push_down_claude_parity.py`). |
| AC21 | Each new module >= 85% line and >= 75% branch; no regression on changed lines of the modified module; evidence under `evidence/qa-gates/` | PASS | New modules: minimum 98.84% line and 91.67% branch; modified module 92.75% line (baseline 92.42%), 75.00% branch (unchanged), no changed line uncovered. `evidence/qa-gates/python-coverage.pass-1.2026-09-29T17-59.md`, `python-coverage-delta.2026-09-29T17-59.md`; reproduced by the reviewer. |
| AC22 | Full toolchain passes in a single pass; evidence under `evidence/qa-gates/` | PASS | `python-loop-clean-pass.2026-09-29T17-59.md` and `ts-loop-clean-pass.2026-09-29T18-02.md` (pass 1 each); reviewer re-run of Black, Ruff, Pyright, full pytest (5472 passed, 6 skipped), Prettier, ESLint, and Jest all clean. `tsc -p tsconfig.jest.json` retains the baseline 71-file pre-existing error set and excludes the new file, per the plan's baseline-exception acceptance. |
| AC23 | README and module docstrings/CLI help describe `config/` | PASS | `README.md:251` row reads `Claude Code (.claude, config/, CLAUDE.md)`; module docstring line 1, function docstring, and `--destination` help mention `config`. `test_module_docstring_and_cli_help_name_config_payload` and `test_readme_claude_row_lists_config_payload` pass. |
| AC24 | Rollout & Follow-up records two follow-up candidates with problem statement and evidence | PASS | `spec.md` lines 279-280 record (a) the `.gitignore` managed-block merge and (b) gitignored `.claude` subtree publishing, each with an evidence citation. Filing is assigned to the epic orchestration session. |
| AC25 | PR description references #507 and #764 part 2 and states #764 part 1 is out of scope | PENDING-PR | Not evaluable before the PR exists. Deferred per `evidence/other/ac-reconciliation.2026-09-29T18-04.md` (`DEFERRED-TO-PR-TIME`). The commit body of `977a1011` already states "Covers #764 part 2; #764 part 1 is out of scope." Non-blocking. |

## Executor Deviations

| Deviation | Classification | Rationale |
|---|---|---|
| P10-T3 unchecked; its acceptance demanded a `Claude-Session:` trailer | Non-blocking | Commit `977a1011` exists with the planned subject and change set and was pushed. Session attribution guidance governs trailers. No AC depends on the trailer. |
| Direct edits instead of `python-typed-engineer` / `typescript-engineer` delegation | Non-blocking | Provenance deviation only; the reviewer independently re-verified every toolchain stage. |
| #621 docstring sentence wraps across two lines | Non-blocking | AC15's `rg` check matches; the docstring test normalizes whitespace. |
| Read-only `inner` property on the write decorators | Non-blocking | Additive, read-only; supports the AC13 layer-order assertion. |

## Summary

24 of 25 acceptance criteria are PASS with direct test or command evidence re-verified by the reviewer. AC25 is PENDING-PR and is satisfied at PR authoring time. No AC is PARTIAL, FAIL, or UNVERIFIED. The executor deviations are all non-blocking. Blocking findings in this artifact: 0.

## Acceptance Criteria Check-off

- Newly checked off by this review: none. AC1-AC24 were already `[x]` in `spec.md` on entry, and each was independently re-evaluated as PASS above, so their checked state is confirmed.
- Left unchecked: AC25 (PENDING-PR). The PR author must include #507, #764 part 2, and the statement that #764 part 1 is out of scope, after which AC25 can be checked off.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md`
- Total AC items: 25
- Checked off (delivered): 24
- Remaining (unchecked): 1
- Items remaining: AC25 - The PR description references #507 and #764 (part 2) and states that #764 part 1 is out of scope.
