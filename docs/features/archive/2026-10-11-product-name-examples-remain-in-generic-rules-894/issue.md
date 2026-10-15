# 2026-10-11-product-name-examples-remain-in-generic-rules

- Work Mode: minor-audit
- Issue: #894
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/894
- Branch: bug/product-name-examples-remain-in-generic-rules-894
- Lifecycle record: docs/features/potential/promoted/2026-10-11-product-name-examples-remain-in-generic-rules.md at ref origin/docs/followups-2026-10-11 (unmerged branch; cited by ref, not copied)
- Also resolves: #797 code-review CR-2 note (collected in #903; #903 itself is closed by a different item)

## Problem / Why

PR #879 neutralized repository-specific product names in the rule surfaces pushed into consumer repositories, but left four exceptions that are still pushed:

- `src/TaskMaster.Domain` in `.claude/rules/parallel-orchestration.md` (line 411) and its bundled mirror.
- `No-COM` in `.claude/rules/typescript.md` (line 57) and `.claude/rules/csharp.md` (lines 5 and 10), and their bundled mirrors.

The guard test `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` exempts six whole files through `PRE_EXISTING_NAME_EXCEPTIONS`. A new product-name occurrence in any exempted file is therefore not detected (#824 code-review finding CR-5).

The `typescript.md` sentence that points to `.claude/rules/architecture-boundaries.md` still refers to the former "No-COM Architecture Rules" heading, which was renamed to "Host-Neutral Architecture Rules (enforceable assertions)". The reference no longer matches the current heading.

The #797 code review (CR-2) found that item 7 of "Known false negatives" in `parallel-orchestration.md` sits under the lead-in "Write-intent extraction can drop a genuine write in these cases". Item 7 describes a drop made by the file-shape classifier before write-intent extraction runs, so the lead-in does not describe it.

Expected outcome: pushed rule surfaces contain no repository-specific product names, and the guard test fails on any new occurrence, including in files that previously held exceptions.

## Implementation Intent

1. Edit the three source rule files and apply identical edits to the three bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/` (six files in total):
   - `parallel-orchestration.md` line 411: replace `src/TaskMaster.Domain` with the placeholder form `src/<Product>.Domain`, which matches the convention at `.claude/rules/architecture-boundaries.md:40`.
   - `typescript.md` line 57: replace "the No-COM architecture assertions" with "the host-neutral architecture assertions". This also corrects the cross-reference so it matches the current heading text in `architecture-boundaries.md`.
   - `csharp.md` line 5 (frontmatter `description`): remove "No-COM, " so it reads "(xUnit)". Leave `paths:` untouched.
   - `csharp.md` line 10: replace "the No-COM .NET foundation" with "a host-neutral .NET foundation".
2. In `parallel-orchestration.md` "Known false negatives", move item 7 out of the numbered write-intent list into its own sentence after item 6 and before "Three mitigations bound these cases:". The sentence states that the file-shape classifier, which runs before write-intent extraction, drops a genuine file cited only as a separator-free bare file name (issue #797), and that the planner cites the repository-relative path or appends it to the declared radius. Item 6 then ends the list and keeps its terminal period. Apply the same change to the mirror.
3. Rewrite the guard in `test_push_down_issue_824_follow_ups.py`:
   - Replace `PRE_EXISTING_NAME_EXCEPTIONS` and its comments with `PINNED_NAME_OCCURRENCES: dict[str, int]`, mapping path to the exact expected total of `CONSUMING_NAMES` occurrences. After the rule edits all six counts are zero, so the map is empty and any future exception must be a visible, counted entry.
   - Add pure helpers `count_name_occurrences(text)` and `pinned_count_mismatches(observed, pinned)`. The latter reports every scanned path whose observed count differs from `pinned.get(path, 0)`, covering both new and removed occurrences.
   - Replace `test_pushed_rule_and_skill_files_name_no_consuming_product` with a real-tree test that compares observed counts to the pinned map.
   - Replace `test_name_exceptions_still_name_a_consuming_product` with a staleness test requiring every pinned key to be a pushed file with a pinned value greater than zero.
   - Add in-memory negative tests (no temporary files): a new occurrence in an unpinned file, a new occurrence in a pinned file, a removed occurrence in a pinned file, count helper cases, and an equal-maps case.
   - Update the module docstring that mentions `PRE_EXISTING_NAME_EXCEPTIONS`.
4. Write the pinned-count tests first and confirm they fail against the unedited rule files, then make the rule edits (fail-before, pass-after).

## Acceptance Criteria

- [x] `src/TaskMaster.Domain` no longer appears in `.claude/rules/parallel-orchestration.md` or its bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/`; the example is replaced with neutral wording (the placeholder form `src/<Product>.Domain` already used in `architecture-boundaries.md`).
- [x] `No-COM` no longer appears anywhere (including the `csharp.md` frontmatter `description`) in `.claude/rules/typescript.md` or `.claude/rules/csharp.md`, or in their bundled mirrors; the replacement wording is neutral.
- [x] The cross-reference in `.claude/rules/typescript.md` to `.claude/rules/architecture-boundaries.md` names the current heading text ("Host-Neutral Architecture Rules" wording) rather than the former "No-COM" heading.
- [x] (#797 CR-2) In `parallel-orchestration.md` "Known false negatives", the separator-free bare-file-name case (former item 7) sits under a lead-in that correctly attributes it to the file-shape classifier rather than write-intent extraction, in the source rule file and in its bundled mirror.
- [x] Each of the three bundled mirrors (`parallel-orchestration.md`, `typescript.md`, `csharp.md`) is byte-identical to its source rule file, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [x] In `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, `PRE_EXISTING_NAME_EXCEPTIONS` is replaced by pinned per-file occurrence counts that require an exact match, with the stale six-file exemptions removed; new in-memory negative tests show the guard fails on a new occurrence in an unpinned file and on a new occurrence in a pinned file; and the staleness check on pinned entries still exists.
- [x] The changed Python test file is clean under black, ruff, pyright, and pytest; the guard test and the bundle parity test pass; no changed file exceeds 500 lines.

## Dependencies / Risks

- Dependency: the rule edits and the guard rewrite must land together. With the exemptions removed and tokens still present, the real-tree guard test fails on all six files.
- Risk: source and mirror edits diverging. Mitigation: apply each edit to both files identically and run the bundle parity test. The mirror is edited directly; push-down regeneration is not used.
- Risk: the `csharp.md` frontmatter edit affecting rule loading. Mitigation: change the `description` wording only, leave `paths:` untouched, and re-run `test_claude_rules_frontmatter.py`.
- Risk: other tests read `parallel-orchestration.md` and `typescript.md`. Research found none pinning the changed passages (the "Accepted residuals" paragraph, the "Known false negatives" lead-in, or item 7); they are re-run as a regression set.
- Risk: the `<Product>` placeholder contains angle brackets. The rule file is not a plan and is not harvested by the classifier, so no runtime effect is expected.
- Pre-change baseline pytest results were not collected during research and must be captured by the implementer before editing.
- No `.github/instructions/` or other Copilot-surface copy of these three rules exists (research found none).

## Verification Steps

1. Capture a baseline before editing: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q`, recording the result under the feature `evidence/` folder.
2. After the guard rewrite and before the rule edits, run the same command and confirm the real-tree guard test fails (fail-before).
3. After the rule edits, search the three source rule files and the three mirrors for `TaskMaster` and `No-COM` and confirm zero matches.
4. Run `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py -q` and confirm it passes, including the new negative tests.
5. Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` and confirm the bundle parity test passes.
6. Run `poetry run pytest tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q`.
7. Run `poetry run pytest tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py -q`.
8. Run black, ruff, and pyright on `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`, repeating the loop until a single pass is clean, and confirm the file remains under 500 lines.
9. Read the revised "Known false negatives" passage in the source and mirror to confirm the lead-in and item 6 punctuation are correct.

## Operator Approval

The operator approved, for this item only, editing `.claude/rules/parallel-orchestration.md`, `.claude/rules/typescript.md`, `.claude/rules/csharp.md`, and their bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/`. No other policy file under `.claude/rules/` or `.github/instructions/` may be edited. A parallel Copilot-surface copy under `.github/instructions/` would be reported as a follow-up rather than edited; research found no such copy.

## Out of Scope

- The classifier test data `src/TaskMaster.Domain` in `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py:308` and in `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1:261`. The guard does not scan it, and it is not changed.
- Historical #824 and #797 artifacts are not edited.
- No CHANGELOG entry is added.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
