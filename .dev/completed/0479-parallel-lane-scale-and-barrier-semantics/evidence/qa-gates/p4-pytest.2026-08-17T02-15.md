# Phase 4 Planner-Surface Gate (Issue #479, [P4-T4], AC35)

Timestamp: 2026-08-17T02-15

Command:
```
poetry run pytest tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py \
  tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py -q
git diff --name-only $(git merge-base origin/main HEAD) -- <the four D4 files>
git diff --name-only $(git merge-base origin/main HEAD) -- <the two planner-surface test modules>
poetry run pytest tests/scripts/dev_tools -q --deselect <the environmental test>
```

EXIT_CODE: 0 (all four)

## Output Summary

- Planner-surface contract suites: **`23 passed in 0.09s`**, with ZERO test-file edits
  (`git diff --name-only` over both modules returns nothing).
- Whole `tests/scripts/dev_tools` suite: `3796 passed, 5 skipped, 1 deselected`. The one
  deselected test is the Phase 0 pre-existing environmental
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts`; mirror byte-identity over
  all 161 tracked `.claude` files was verified independently with zero missing and zero
  differing.

## D4-attributable diff is Markdown-only

`git diff --name-only $(git merge-base origin/main HEAD)` restricted to the D4 surface returns
exactly four Markdown files and nothing else:

```
.claude/agents/parallel-planner.md
.claude/skills/parallel-plan/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
```

No validator, schema, library, hook, or test file is modified attributable to D4. AC35 is
satisfied.

## One in-phase correction, recorded

The first draft of `## Preparation Fan-Out` re-wrapped the line carrying the sentence

> Create each preparation worktree's branch from `origin/main`.

so that it spanned two source lines. `test_skill_branches_preparation_worktrees_from_origin_main`
pins that sentence with a plain `in skill_text` substring check and performs NO whitespace
collapsing (unlike the orchestrator surface's `assert_fragments`), so the wrap broke the pin.
The prose was re-wrapped to place the sentence on a single source line, verbatim and unchanged
in wording, and the suite was re-run to green. No test, assertion, or pin was modified.
