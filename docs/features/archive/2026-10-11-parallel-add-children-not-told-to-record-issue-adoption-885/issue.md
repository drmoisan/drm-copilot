# parallel-add-children-not-told-to-record-issue-adoption (Issue #885)

- Work Mode: minor-audit
- Issue: #885
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/885
- Promotion type: bug
- Lifecycle record: `docs/features/potential/promoted/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption.md` (on branch `origin/docs/followups-2026-10-11`; not copied into this branch)
- Research: `research/research.2026-10-11T08-05.md`

## Problem / Why

`/parallel-add` preparation children admitted for an existing GitHub issue are not instructed to record a top-level `issue_adoption` object. Issue #849 added that instruction to `/parallel-plan` and `/parallel-orchestrate` but left `.claude/skills/parallel-add/SKILL.md` unchanged, so an item admitted through `/parallel-add` can still fail completion on the missing `potential_to_issue` and promotion-entry receipts that #849 fixed for planned items. Severity: Medium. Items admitted mid-run for existing issues can fail completion and require manual checkpoint repair. Planned items are not affected.

## Implementation Intent

Add the `/parallel-plan` `## Preparation Fan-Out` issue-adoption line (`.claude/skills/parallel-plan/SKILL.md:116`) to `/parallel-add` step 2 (`2. **Prepare the item.**`, lines 53-64) for issue-number items only, mirror the edit byte-for-byte into the bundled copy under `extensions/drm-copilot/resources/claude-customizations/`, and extend `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` to pin the text. No `.agents/`, `.codex/`, or `.github/` counterpart of `parallel-add` exists. The edit stays inside step 2; steps 3 through 6 (conflict edges, decision, recolor, `build_add_entry`) are being edited concurrently by issue #890 and must not change.

## Acceptance Criteria

- [x] AC-1: `.claude/skills/parallel-add/SKILL.md` step 2 instructs the preparation child for an issue-number item to verify the issue read-only, not call `potential_to_issue` or the promotion-entry tool, and record a top-level `issue_adoption` object, using text equal (after whitespace collapse) to the `/parallel-plan` issue-adoption line.
- [x] AC-2: The added step-2 text states that the issue-adoption line applies to issue-number items only and is omitted for potential-entry items, whose child promotes them.
- [x] AC-3: The added step-2 text contains no mode marker, no text matching the hook issue-number pattern, and no `docs/features/active/` path.
- [x] AC-4: Only step 2 of `.claude/skills/parallel-add/SKILL.md` changes; the `2. **Prepare the item.**` and `3. **Compute conflict edges` markers and all text from step 3 onward are unchanged.
- [x] AC-5: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` is byte-identical to `.claude/skills/parallel-add/SKILL.md`.
- [x] AC-6: `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` gains contract tests for the parallel-add step-2 text (presence, equality with the parallel-plan line, issue-number-only conditioning, no mode marker, hook-pattern and active-path exclusion) that fail before the skill edit and pass after it.
- [x] AC-7: The issue-adoption contract tests, the complexity-routing contract tests, the planner-surface contract tests, and the bundle-parity test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` pass, and the Python toolchain (Black, Ruff, Pyright) is clean for the edited test file.
- [x] AC-8: No file under `.claude/rules/` or `.github/instructions/` is modified.

## Dependencies / Risks

- Concurrent issue #890 edits `parallel-add` steps 3 through 6. Keeping the hunk inside lines 53-64 (blank line 65 separates the steps) keeps the textual merge-conflict risk low.
- Existing tests slice step 2 between `2. **Prepare the item.**` and `3. **Compute conflict edges`; those markers must not change.

## Verification Steps

- `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- `git hash-object` of both `parallel-add/SKILL.md` copies returns the same value.
- `git diff origin/main --stat` lists no path under `.claude/rules/` or `.github/instructions/`.

## Evidence Checklist

- [ ] baseline
- [ ] targeted verification
- [ ] end-state
