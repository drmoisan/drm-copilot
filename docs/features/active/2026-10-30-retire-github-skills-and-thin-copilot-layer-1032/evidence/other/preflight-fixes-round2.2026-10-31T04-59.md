# Preflight Fixes — Round 2 (issue #1032)

Timestamp: 2026-10-31T04-59

## Plan: docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/plan.2026-10-30T18-39.md

- Fix 1: [P1-T4] | stale or incomplete symbol citation | `test_root_folders_include_published_github_hooks_in_scoped_order` is defined in `tests/scripts/dev_tools/test_agentic_sync_artifacts.py`, not `test_agentic_sync.py`; the task text now names `in test_agentic_sync_artifacts.py` for that test. The test set and the acceptance condition are unchanged (that module is already in `CHANGED-PY` and in the P1-T4 acceptance list).
- Fix 2: [P2-T1] | asserted literal not quoted in task text | The acceptance asserts the token `byte-identical in four locations`; the task text now states that the rewritten `## Purpose and Maintenance` sentence contains that literal. The asserted value is unchanged.

## Plan: docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/plan-agents-branch-a.md

- No fixes.

## Plan: docs/features/active/2026-10-30-retire-github-skills-and-thin-copilot-layer-1032/plan-agents-branch-b.md

- Fix 1: [P2-T4] | evidence derivation left to the executor (validator-blind class) | The task now states the same mechanical derivation as Branch A P2-T4: `git diff --name-status` from the commit that added the self-review path recorded by P0-T2 (found by `git log` on that path) to `HEAD`, together with `git status --porcelain`. The assertion (no file outside `config/harness-parity-matrix.json` and `<FEATURE>/` changed since the main plan's self-review) is unchanged.
