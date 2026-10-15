# Research: /parallel-add preparation children are not told to record issue_adoption (Issue #885)

Timestamp: 2026-10-11T08-05

## Scope and tool limits

- Read-only research. Tools available were Read, Grep, Glob, Write. Bash and PowerShell were unavailable, so `git hash-object`, `git log`, and `poetry run pytest` were NOT run. Byte-identity and test pass state are therefore not hash-verified or executed here; see items 3 and 5 for the substitute evidence.
- All line numbers are against the current tree of this worktree.

## Sources consulted

- `.claude/skills/parallel-add/SKILL.md`
- `.claude/skills/parallel-plan/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`
- `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py`
- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py`
- `package.json` and `extensions/drm-copilot/package.json` (prettier scripts)
- #849 feature folder evidence: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/diff-scope.2026-10-09T01-33.md`, `.../evidence/other/follow-up-parallel-add.2026-10-09T01-33.md`, `.../evidence/other/mirror-identity.2026-10-09T01-33.md`

## Finding 1. Existing issue-adoption text

parallel-plan `.claude/skills/parallel-plan/SKILL.md`:

- Line 45-49 (Item Intake bullet): "**Issue adoption.** Issue-number items are adopted, not promoted. The item's GitHub issue already exists, so its preparation child verifies the issue read-only and records a top-level `issue_adoption` object in its checkpoint instead of calling `potential_to_issue` or the promotion-entry tool. The delegation prompt carries that instruction as the issue-adoption line under `## Preparation Fan-Out`."
- Line 109-110 (conditioning, sentence in `## Preparation Fan-Out`): "Each delegation prompt includes this literal kickoff line, followed by the model-budget marker line and, for an issue-number item only, the issue-adoption line:"
- Line 112 kickoff line, line 114 model-budget line, then line 116, the verbatim adoption line (a blockquote line):

> `Issue adoption: this item's GitHub issue already exists. Verify it read-only (gh issue view), do not call potential_to_issue or the promotion-entry tool, and record a top-level issue_adoption object in the checkpoint per .claude/rules/orchestrator-state.md with origin filed_before_orchestration (or transferred when the issue was transferred), waiving potential_to_issue and the promotion-entry tool for the checkpoint's promotion-type. When a lifecycle record for the item exists under docs/features/potential/promoted/, cite it as potential_record.`

- Line 138-143 (conditioning paragraph): "The issue-adoption line is emitted only for an issue-number item, after the model-budget marker line, and is omitted for a potential-entry item, whose child promotes it. The line carries no mode marker, no digits, and no active feature-folder path, so hook target resolution and mode classification are unchanged. The preparation checkpoint does not carry over to execution, so the execution child records its own adoption (see `.claude/skills/parallel-orchestrate/SKILL.md`, kickoff element 4)."
- Line 151-154: the planner collects the `issue_adoption` record from the child checkpoint for issue-number items.

parallel-orchestrate `.claude/skills/parallel-orchestrate/SKILL.md`, kickoff element 4, lines 255-266. The adoption sentence is lines 259-266: "The execution child starts a new checkpoint in its own worktree, and the preparation checkpoint does not carry over, so the prompt also instructs the child to verify the item's GitHub issue read-only (gh issue view), not to call `potential_to_issue` or the promotion-entry tool, and to record its own top-level `issue_adoption` object per `.claude/rules/orchestrator-state.md`, with origin `filed_before_orchestration` unless the issue was transferred, waiving `potential_to_issue` and the promotion-entry tool for the checkpoint's promotion-type. When a lifecycle record for the item exists under `docs/features/potential/promoted/`, the child cites it as `potential_record`."

Conditioning summary: parallel-plan emits the line for issue-number items only and omits it for potential-entry items (which promote through the child). The parallel-orchestrate element applies to every item because every item has an issue by execution time.

## Finding 2. parallel-add step 2 and surrounding passages

`.claude/skills/parallel-add/SKILL.md` (189 lines). Step 2 is lines 53-64, verbatim:

```
2. **Prepare the item.** Run preparation through a preparation-mode child `Agent(orchestrator)`
   run, reusing the existing `route_id: preparation` contract UNCHANGED: promotion, research,
   `spec.md`, `user-story.md`, the atomic plan, and preflight clearance. Do not fork a variant
   contract for parallel admission. Preparation yields the item's DECLARED blast radius, and only
   the planner-computed declared radius is authoritative for scheduling. The item's lifecycle
   advances `proposed` -> `admitted` -> `prepared` during this step, recorded as item-state updates in
   `items[]` with the checkpoint's lifecycle timestamps. After the admitted item's preflight
   clearance, perform the `parallel-plan` skill's `## Complexity Assessment` procedure for it, and
   record the resulting `complexity_band` on the admitted orchestrator-checkpoint item so step 3's
   edge derivation and the parent's model routing read the same band.
   The admitted item records `complexity_band` and no `model_routing_receipt`; the parent resolves
   the item's model from that band at spawn time per `parallel-orchestrate` `## Model Selection`.
```

Line 65 is blank. Step 1 is lines 50-51; step 3 begins line 66.

The step never describes the delegation prompt contents at all (no kickoff line, no marker line, no adoption line). The fix therefore adds new prompt-composition text rather than editing an existing line.

Passages #890 is porting from Python engine-call text to bash (not editable by #885):

- Step 3, lines 66-97. Python references at lines 82-84 (`schedule_conflict_edges`, `conflicts`, `scripts/dev_tools/compute_blast_radius.py`, `_blast_radius_scheduling.py`, `_blast_radius_conflicts.py`) are parity-reference text and may also be touched.
- Step 4 (decision), lines 99-131: `decide_admission(...)` and `recolor_unstarted(...)` from `scripts/dev_tools/parallel_mutation_protocol.py` at lines 99-109.
- Step 5 (recolor application), lines 133-147, including `scripts/dev_tools/_parallel_state_structures.py:282-305` at lines 146-147.
- Step 6 (`build_add_entry`), lines 149-160, with `scripts/dev_tools/parallel_mutation_protocol.py` named at line 150.
- Step 7 (lines 162-165) and Constraints are unlikely to change but are outside step 2.

Merge-conflict risk: low if the edit is confined to lines 53-64. The nearest #890 text is step 3 at line 66; the blank line 65 separates the hunks. Insert the new text inside step 2 (preferably after line 64 as an additional indented paragraph, or earlier within step 2), and do not touch lines 65-66. The issue #890 folder was not found in this tree, so its exact hunks are unverified. The #849 follow-up note says `parallel-add/SKILL.md` was excluded from #849 because of overlap with #843; #843 status was not verified (step 3 already shows the PowerShell port text at lines 66-97, which suggests it landed).

Constraints from existing tests that the edit must preserve (see Finding 4): the literal markers `2. **Prepare the item.**` and `3. **Compute conflict edges` must stay unchanged, and step 2 must still contain every token in `STEP_TWO_TOKENS` plus `## Complexity Assessment` and `complexity_band`.

## Finding 3. Copies and mirrors

Located by Glob (`**/parallel-add/**`) and Grep for `parallel-add` outside `docs/`:

- `.claude/skills/parallel-add/SKILL.md` (source).
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` (bundled mirror). Read lines 48-64: step 2 text matches the source line for line, and it contains no issue-adoption text. It needs the identical edit.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:122` lists `.claude/skills/parallel-add/SKILL.md`. The manifest lists paths only (no hash); no manifest change is needed.
- No `.agents/`, `.codex/`, or `.github/` counterpart of parallel-add exists. Matches for `parallel-plan/SKILL.md` and `parallel-add` exist only under `.claude/` and the `claude-customizations` bundle; the `codex-and-agents-customizations` bundle holds no parallel-* skill.
- Hash comparison with `git hash-object` was NOT performed (no shell). Substitute evidence: the repo test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` asserts text equality of every distributable `.claude/**` file against the bundle, and the #849 mirror-identity artifact verified six other pairs only (parallel-add was not among them). The step-2 text matching above is a partial, visual check, not a hash.
- #849 touched (from `diff-scope.2026-10-09T01-33.md`, lines 38-42 and 102-107): 6 `.claude/` sources (`lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`, `rules/orchestrator-state.md`, skills `feature-promotion-lifecycle`, `orchestrate`, `parallel-orchestrate`, `parallel-plan`) and the 6 bundled mirrors of the same files, plus the TypeScript validator, the Python validator, fixtures, and tests. It touched NO `.codex/`, `.agents/`, or `.github/` file. The same two-surface pattern (source plus bundled mirror) therefore applies to #885. (git log was not run; this list is taken from the committed #849 gate artifact.)

## Finding 4. Existing contract test and parity tests

`tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` (268 lines):

- Imports `collapse_whitespace`, `extract_section`, `read_repo_text` from `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py`. Paths are repo-relative `Path` constants resolved by `read_repo_text` (`REPO_ROOT / relative_path`, support module line 73-89). Nothing is read at collection time.
- Constants: `PARALLEL_PLAN_SKILL`, `PARALLEL_ORCHESTRATE_SKILL`, `ORCHESTRATE_SKILL`, `LIFECYCLE_SKILL`, `ORCHESTRATOR_STATE_RULE`; `ADOPTION_LINE_PREFIX = "> \`Issue adoption:"`; `MODE_MARKERS`; `HOOK_ISSUE_NUMBER_PATTERN` (`issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?(\d+)`, lines 70-72).
- Helpers: `_fan_out_section`, `_adoption_line` (requires exactly one line starting with the prefix in `## Preparation Fan-Out`), `_element_four_text`. Registry `ADDED_TEXT_SOURCES` (line 134-137) maps source ids to text callables.
- Test node IDs (all prefixed `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::`):
  - `test_parallel_plan_item_intake_declares_issue_number_items_adopted`
  - `test_parallel_plan_fan_out_carries_issue_adoption_prompt_line`
  - `test_parallel_plan_issue_adoption_line_carries_no_mode_marker`
  - `test_parallel_plan_kickoff_line_is_unchanged`
  - `test_parallel_orchestrate_element_four_carries_issue_adoption`
  - `test_parallel_orchestrate_kickoff_keeps_five_elements`
  - `test_added_skill_text_does_not_match_hook_issue_number_pattern[parallel-plan-adoption-line]`
  - `test_added_skill_text_does_not_match_hook_issue_number_pattern[parallel-orchestrate-element-four]`
  - `test_rule_doc_states_origin_conditional_potential_record`
  - `test_skill_states_origin_conditional_potential_record[feature-promotion-lifecycle]`
  - `test_skill_states_origin_conditional_potential_record[orchestrate]`
- How a new assertion fits: add `PARALLEL_ADD_SKILL = Path(".claude/skills/parallel-add/SKILL.md")` and a helper `_parallel_add_step_two_text()` that extracts the `## Procedure` section, then the lines from the one starting `2. ` to the one starting `3. ` (same boundary technique as `_element_four_text`). Register it in `ADDED_TEXT_SOURCES` as `parallel-add-step-two`, which automatically extends the parametrized hook-pattern and `docs/features/active/` no-path test to the new text (note the existing parameter ids sort alphabetically). Add new tests: (a) step 2 collapsed text contains `issue_adoption`, `potential_to_issue`, and the line's key phrases; (b) the adoption sentence in step 2 equals the parallel-plan line text (strip the leading `> \`` and trailing `` ` `` from `_adoption_line()` and compare after `collapse_whitespace`) so the two copies cannot drift; (c) it states that the line is for issue-number items only and omitted for potential-entry items; (d) it carries no mode marker. Do not use a `> \`Issue adoption:` blockquote in parallel-add if `_adoption_line` ever scans it; it scans only `parallel-plan`, so a blockquote there is also safe. A bundled-copy assertion is not needed in this test because the full-tree parity test below covers byte equality.
- Constraint: the added step-2 text must not match `HOOK_ISSUE_NUMBER_PATTERN` and must not contain `docs/features/active/`. The parallel-plan line text meets both (it contains `docs/features/potential/promoted/`, which is permitted).

Other tests pinning parallel-add step 2 (must stay green):

- `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_add_requires_complexity_assessment` (lines 156-172) and `::test_parallel_add_step_two_defers_model_to_parallel_orchestrate` (lines 251-264). Both slice the text with `between(text, "2. **Prepare the item.**", "3. **Compute conflict edges")` and assert tokens inside step 2 (`## Complexity Assessment`, `complexity_band`, `STEP_TWO_TOKENS`).
- `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_parallel_intake_requires_consolidation_before_execution` (lines 156-162): asserts `pending or not-started` and `execution has started` in parallel-add (Prerequisites, line 24; unaffected).

Parity tests that fail if source and bundle diverge:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 89-110). It enumerates every distributable `.claude/**` file and asserts both presence in the bundle and `read_text` equality. This is the failing test if only one copy is edited.
- Manifest tests are unaffected by a content-only change: `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest` and `test_skill_bundle_contract_repo.py::test_every_skill_folder_file_is_carried_by_skill_packs` depend on path membership (already satisfied by `core.json:122`), not on content. Pack manifests are excluded from the parity scope (`test_pack_manifests_are_outside_the_parity_scope`).
- No sha256 or hash manifest covers skill files: Grep of the push-down tests for `sha256|hashlib|read_bytes|filecmp` found only byte comparisons in `test_push_down_claude_resource_contracts.py` lines 122 and 134-136 (planner-review and handoff files, not parallel-add). The bundle is a manually mirrored copy, so no generated manifest or hash update is required.

## Finding 5. Commands, formatting, size limits

Commands (not executed here; no shell was available; pass state on the current tree is unknown):

```
poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py -q
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q
poetry run pytest tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py -q
```

- Prettier: root `package.json` lines 33-34 and `extensions/drm-copilot/package.json` line 207 limit prettier to `ts/tsx/js/mjs/cjs/json` globs; no Markdown glob. SKILL.md files are not format-checked by prettier. The Python test edit is subject to Black, Ruff, and Pyright (project Python toolchain).
- Line limit: the 500-line limit in `.claude/rules/general-code-change.md` exempts Markdown documentation. A repository grep of `tests/` for a SKILL.md line-count limit found none. `parallel-add/SKILL.md` is 189 lines. The Python test is 268 lines; adding about 60-80 lines keeps it below 500.

## Recommendations

Selected approach: embed the issue-adoption instruction as an issue-number-only sentence inside step 2, reproducing the parallel-plan line text verbatim, and pin the equality with a contract test. Rejected alternatives: (a) a pointer-only sentence ("send the parallel-plan issue-adoption line"), rejected because the issue asks for the same line and a pointer leaves the delegation text unspecified for the forked agent; (b) editing the `route_id: preparation` contract in the orchestrate skill, rejected because step 2 requires that contract UNCHANGED.

Suggested step-2 text shape (added after line 64, inside the list item, indented 3 spaces): state that the delegation prompt for an issue-number item carries the issue-adoption line used by `/parallel-plan` (`## Preparation Fan-Out`), quote it, and state it is omitted for a potential-entry item, whose child promotes it. Keep digits, `Epic mode: true`, `Parallel mode: true`, `Preparation mode: true`, and `docs/features/active/` out of the added text.

Recommended acceptance criteria for issue.md (minor-audit):

- [ ] `.claude/skills/parallel-add/SKILL.md` step 2 instructs the preparation child for an issue-number item to verify the issue read-only, not call `potential_to_issue` or the promotion-entry tool, and record a top-level `issue_adoption` object, using text equal to the `/parallel-plan` issue-adoption line.
- [ ] The added text states it applies to issue-number items only and is omitted for potential-entry items.
- [ ] The added text contains no mode marker, no hook issue-number shape, and no `docs/features/active/` path.
- [ ] Lines outside step 2 (lines 53-64 in the current tree) are unchanged, preserving the `2. **Prepare the item.**` and `3. **Compute conflict edges` markers.
- [ ] `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` is byte-identical to the source file.
- [ ] `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` gains a failing-first contract covering the parallel-add step 2 text (presence, equality with the parallel-plan line, issue-number-only conditioning, no mode marker, hook-pattern and active-path exclusion).
- [ ] The existing contract, complexity-routing, planner-surface, and bundle-parity tests listed above pass.
- [ ] No file under `.claude/rules/` or `.github/instructions/` is modified.

Minimal set of files to write:

1. `.claude/skills/parallel-add/SKILL.md`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
3. `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`

(plus the feature folder documents for #885: `issue.md`, `spec.md` if required by the tier, the plan, and evidence). No `.agents/`, `.codex/`, `.github/`, `core.json`, or hash manifest change is required.
