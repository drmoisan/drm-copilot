# Preflight Fixes — Issue #1021

Timestamp: 2026-10-30T20-49
Plan: docs/features/active/2026-10-30-docs-page-quality-checker-1021/plan.2026-10-30T16-13.md
Signal: PREFLIGHT: ALL CLEAR
Validator: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` exited 0 before and after the fixes, with no gate warnings.

All fixes edit task text only. No task was added, removed, reordered, or checked.

## Fixes

1. [P8-T14] | unsatisfiable scope allow-list (validator-blind; scope anchor) | The merge base of `origin/main` and `HEAD` lies before the epic manifest commit, which is on `epic/documentation-estate-tooling-integration` and not on `origin/main`. `git diff --name-only origin/main...HEAD` therefore lists `docs/features/epics/documentation-estate-tooling/epic.md`, which the allow-list omitted, so the check would fail on any execution. The parent epic manifest is now allowed by its exact path as a file inherited from the branch base. The assertion still means that the change set holds only this feature's inventory and lifecycle files. The other file from that commit is under `docs/features/potential/promoted/` and was already allowed.
2. [P6-T1] | acceptance wording contradicted by [P3-T3] | The acceptance said `cli.py` is the only module that touches the file system. [P3-T3] reads the packaged schema through `importlib.resources` in `front_matter.load_page_schema`. That read is now named as the one exception.
3. [P6-T2] | test-isolation clarification | `mem_fs_path` patches `Path.read_bytes`. A real-reader test that reached `run_check` would intercept the packaged-schema read, and whether it then passed would depend on test order through the `lru_cache`. The test now calls `read_markdown_tree` and `make_path_exists` directly.
4. [P8-T5] | undefined branch figure | A module with zero branches (for example `__init__.py`) has `num_branches` 0, so a branch percentage cannot be computed. Such a file now records `N/A (0 branches)` and is judged on line coverage only. The package-level threshold is unchanged.
5. [P0-T2] | ambiguous checkpoint location | The task said "item worktree checkpoint". It now names the checkpoint of the worktree that `Resolve-HookTargetWorktree` resolves for the written production files, and it states that an isolated subagent worktree has no checkpoint and is capped, as the execution-environment brief's `## Batch Budget` says.
6. [P2-T3] | misquoted heading anchor | The anchor is corrected to the exact `spec.md` heading ``### `CheckConfig` (frozen dataclass in `config.py`)``.
7. Open Questions / Notes | misquoted heading anchor | The anchor is corrected to the exact `spec.md` heading ``### Tests (under `tests/docs_page_check/`)``.
