# Task Check P1-T7

Timestamp: 2026-11-19T08-55
Plan: plan.2026-10-30T18-39.md
Condition: P0-T5 recorded `RootConstants` present for both constants, so the edits apply.
Changed files: `extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts` (`COPILOT_ROOT_FOLDERS` drops the skill root); `extensions/drm-copilot/test/lib/push-down/copilot-customizations-engine.test.ts` (`exposes the inlined copilot root-folder enumeration order`; `classifies created vs overwritten and enumerates in root then path order` and `accumulates rewrite counters and first-seen unmatched references` seeds moved to `.github/instructions/`); `scripts/dev_tools/agentic_sync.py` (`ROOT_FOLDERS` drops the skill root; module docstring); `tests/scripts/dev_tools/test_agentic_sync_artifacts.py` (`test_root_folders_include_published_github_hooks_in_scoped_order`); `tests/scripts/dev_tools/test_agentic_sync.py` (`test_force_left_to_right_overrides_newer_right` root moved to `.github/prompts`, a remaining `ROOT_FOLDERS` member); `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` (`_seed_scoped_source_files` drops the skill seed; `test_push_down_copies_scoped_github_trees_to_empty_destination` `created_count` 4 and drops the skill assertion); `tests/scripts/dev_tools/test_push_down_copilot_customizations_rewrites.py` (fixture of `test_push_down_reports_unmatched_script_references_without_rewrite` moved to `.github/instructions/example.instructions.md`). Unchanged as unaffected: `test_push_down_overwrites_existing_destination_file`, `test_agentic_sync_branches.py`, `test_agentic_sync_filesystem.py`.
Selection rule: mirrored tests of the changed production files plus every test that imports `agentic_sync` or the Python push-down module (`test_agentic_sync*.py`, `test_push_down_copilot_customizations*.py`), and the engine Jest suite.

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `env -u VIRTUAL_ENV poetry run black --check` (5 Python files) | 0 | 5 files would be left unchanged |
| `env -u VIRTUAL_ENV poetry run ruff check` (5 Python files) | 0 | All checks passed (after wrapping one docstring line that the first run reported as E501) |
| `env -u VIRTUAL_ENV poetry run pyright` (5 Python files) | 0 | 0 errors, 0 warnings |
| `npx prettier --check` (engine and its test; SCRATCH/issue-1032-tsstatic.sh) | 0 | All matched files use Prettier code style |
| `npx eslint` (engine and its test) | 0 | no diagnostics |
| `npm run typecheck` (extensions/drm-copilot) | 0 | no diagnostics |
| `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <7 modules> -q -p no:cacheprovider` | 0 | 53 passed (three earlier attempts exited 75, queue timeout: another worktree held the machine lock) |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down/copilot-customizations-engine.test.ts` | 0 | 1 suite, 12 tests passed |
| Grep for RETIRED-PATH over the edited production and test files | 0 | 0 matches |
