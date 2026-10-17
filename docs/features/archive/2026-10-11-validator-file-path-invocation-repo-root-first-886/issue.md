# 2026-10-11-validator-file-path-invocation-repo-root-first-886

- Work Mode: minor-audit
- Issue: #886
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/886

## Problem / Why

Running `python scripts/dev_tools/validate_orchestration_artifacts.py ...` by file path appends the worktree root to the end of `sys.path` (lines 16-17 of the script). In a shared Poetry environment, an editable-install `drm_copilot.pth` entry that resolves `scripts` to a different checkout is found first. The file-path form then runs this worktree's `main()` against the `scripts.dev_tools` validators of another checkout.

Expected behavior: both invocation forms (file path and `python -m scripts.dev_tools.validate_orchestration_artifacts`) import `scripts` from the worktree that contains the invoked file.

Severity: High. The validator can report results computed from the wrong checkout's code without any visible indication.

The operator has already corrected the shared `.pth` file. This item covers the code fix and its tests only.

## Implementation Intent

- Change the path bootstrap in `scripts/dev_tools/validate_orchestration_artifacts.py` (currently line 17) from an append to a slice-prepend, so the repository root occupies `sys.path` index 0 exactly once. The form must remain Ruff E402-clean without suppressions and must be a no-op under `python -m`, where the root is already first.
- Rewrite `test_file_path_bootstrap_appends_repo_root_once` in `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py`, which currently pins the append-last behavior, so that it pins prepend-first ordering.
- Add a regression test that simulates a foreign `scripts` package resolvable from a later `sys.path` entry, without temporary files, and proves the file-path form imports the local package.
- Record a search of `scripts/` confirming whether any other file-path entry script mutates `sys.path`. Research found only the validator; any additional hit must be fixed consistently.
- The validator file is 498 lines against the 500-line limit. The fix and any helper must fit within that limit or be extracted without exceeding it.

## Acceptance Criteria

- [x] AC-1: Invoking `scripts/dev_tools/validate_orchestration_artifacts.py` by file path inserts the repository root at `sys.path` index 0 (not appended), and the root appears in `sys.path` exactly once.
- [x] AC-2: Module-form invocation (`python -m scripts.dev_tools.validate_orchestration_artifacts`) leaves `sys.path` unchanged by the bootstrap.
- [x] AC-3: A regression test simulates a foreign `scripts` package resolvable from a later `sys.path` entry, uses no temporary files, and proves the file-path form imports the local `scripts` package; the test fails when run against the pre-fix code.
- [x] AC-4: The existing test `test_file_path_bootstrap_appends_repo_root_once` is replaced by a test that pins prepend-first ordering, and no test remains that asserts append-last behavior.
- [x] AC-5: A recorded search of `scripts/` (command or query and resulting file list stored in the evidence folder) confirms which file-path entry scripts mutate `sys.path`, and every such script other than the validator, if any, is fixed consistently with AC-1.
- [x] AC-6: No new Ruff suppression is introduced (no `# noqa: E402` and no new per-file-ignore), and every changed production and test file is at or under 500 lines.
- [x] AC-7: Black, Ruff, Pyright, and Pytest pass for the Python toolchain, and coverage for `scripts.dev_tools.validate_orchestration_artifacts` is at least 85% line and at least 75% branch, with no coverage regression on changed lines.

## Dependencies / Risks

- Dependencies: the corrected shared `drm_copilot.pth` (already applied by the operator) is a precondition for realistic reproduction but is not required by the tests, which simulate the foreign package in-process.
- Risk: the validator file is 498 lines against the 500-line limit; the fix must not push it over.
- Risk: tests must not create temporary files, so the foreign-package simulation must use in-memory mechanisms such as patched `sys.path`, `sys.modules`, or an import hook.
- Risk: any other file-path entry script with the same pattern would remain vulnerable; AC-5 addresses this through the recorded search.
- Out of scope (not an acceptance criterion): editing `.claude/rules/orchestrator-state.md` and its bundled mirror, whose line ~204 still says "appends". That wording is owned by item #898.

Operator-approved scope addition: the operator approved editing the single sentence at line 204 of `.claude/rules/orchestrator-state.md` and of its bundled copy `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`, changing `appends it to` to `inserts it first in` before `` `sys.path` ``. This supersedes the "Out of scope" bullet above for that sentence only. No acceptance criterion changes and none is added.

## Verification Steps

1. Run the rewritten ordering test and the new regression test; confirm both pass.
2. Revert the production change locally (or run the regression test against the pre-fix commit) and confirm the regression test fails.
3. Run `python -m scripts.dev_tools.validate_orchestration_artifacts` and the file-path form from the worktree, and confirm `sys.path[0]` is the worktree root in both and that `sys.path` is not altered by the bootstrap in the module form.
4. Search `scripts/` for `sys.path` mutations and store the query and result list in the evidence folder.
5. Run the full Python toolchain loop in order (Black, Ruff, Pyright, architecture tests, Pytest, contract checks, integration tests) until a single clean pass.
6. Confirm coverage thresholds for `scripts.dev_tools.validate_orchestration_artifacts` and confirm `wc -l` of changed files is at most 500.

## Evidence Checklist

- [ ] baseline
- [ ] targeted verification
- [ ] end-state
