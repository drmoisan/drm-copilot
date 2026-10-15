# validator-file-path-invocation-imports-foreign-scripts-package (Issue #886)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/validator-file-path-invocation-imports-foreign-scripts-package/ (Issue #886)
- Origin: issue #798 (PR #862), code-review finding CR-2 and plan item PD8; parallel run bug-burndown-2026-10-08

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #886
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/886
- Last Updated: 2026-10-11
## Summary

Running `python scripts/dev_tools/validate_orchestration_artifacts.py ...` by file path appends the worktree root to the end of `sys.path`. In the shared Poetry environment an editable-install `.pth` already resolves the `scripts` package to a different checkout, so the file-path form runs this worktree's `main()` against another checkout's `scripts.dev_tools.*` validators. The shared environment's `drm_copilot.pth` currently points at an agent worktree for #824, so every worktree that uses the shared environment is exposed.

## Environment

- OS/version: Windows 11 Pro
- Python version: Poetry environment `C:\Users\DanMoisan\repos\drm-copilot\.venv` (reported by `poetry env info -p` from a secondary worktree; shared across worktrees)
- Command/flags used: `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py <validator> <path>` (no `-S`)
- Data source or fixture: main at 2ef8d361; `.venv\Lib\site-packages\drm_copilot.pth`

## Steps to Reproduce

1. From any secondary worktree, run `poetry env info -p` and confirm the shared `.venv` path.
2. Read `<venv>\Lib\site-packages\drm_copilot.pth`.
3. Run the validator by file path and print `scripts.__file__` from inside it (or repeat the `ORIGIN_CLASS` probe recorded in #798's `evidence/baseline/scripts-package-origin.2026-10-09T02-59.md`).

## Expected Behavior

Both invocation forms (`python -m scripts.dev_tools.validate_orchestration_artifacts` and the file-path form) import the `scripts` package from the worktree that contains the invoked file, as `.claude/rules/orchestrator-state.md:204` states: "Both forms reach the same `main()`, so their flags, output lines, and exit codes are identical".

## Actual Behavior

- `drm_copilot.pth` contains exactly `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad37294aa9395bddb`. `drm_copilot-0.1.1.dist-info/direct_url.json` records an editable install from the same path. That worktree is on branch `c1a-824-resume` (HEAD `d42af91c9`), an agent worktree for #824. The `.pth` was last modified 2026-10-08 22:04 -0400.
- `scripts/dev_tools/validate_orchestration_artifacts.py:16-17`:
  `# File-path invocation has no package context; make the repo root importable.`
  `sys.path += [str(Path(__file__).resolve().parents[2])] if not __package__ else []`
  Because the root is appended after site-packages, the `.pth` entry wins and `from scripts.dev_tools...` (line 19 onward) imports the foreign checkout's modules.
- #798's probe returned `ORIGIN_CLASS FOREIGN`.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/code-review.2026-10-09T03-29.md:31` (CR-2, Medium): "In the shared Poetry environment, an editable-install `.pth` entry resolves `scripts` to another worktree, so `python scripts/dev_tools/validate_orchestration_artifacts.py ...` (without `-S`) runs this worktree's `main()` against another checkout's `scripts.dev_tools.*` validators." `code-review.2026-10-09T04-08.md:25` and both feature audits (lines 78 and 80) record that "the PD8 follow-up has not been filed".

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. Orchestration completion gates run this validator. A validator imported from a stale or divergent agent worktree can pass or fail a checkpoint according to rules that are not the ones on the current branch, and nothing reports the mismatch. A wrong result has not been observed directly; the import origin has been.

## Suspected Cause / Notes

- Two contributing causes: (1) the validator appends rather than prepends its root; (2) an agent ran `poetry install` (editable) from inside a temporary agent worktree, repointing the shared environment's `drm_copilot.pth` at that worktree. The second also affects `python -m scripts...` invocations from the main checkout, because `scripts` then resolves to the agent worktree.
- The test fixture `isolated_import_state` in `tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py` strips foreign `scripts` entries from `sys.path` (CR-5), so the tests never exercise this environment.
- Who ran the editable install is inferred from timing (the `.pth` at 22:04, #824 commits in that worktree at 22:19) and is not confirmed.

## Proposed Fix / Validation Ideas

- [ ] Prepend the root in the file-path bootstrap (with an approved E402 per-file ignore), or use per-worktree virtual environments, as plan PD8 proposed.
- [ ] Prevent agents from running `poetry install` against the shared environment from a secondary worktree, or detect a `drm_copilot.pth` that points outside the main checkout and fail fast.
- [ ] Restore `drm_copilot.pth` to the main checkout (operator action).
- [ ] Unit coverage areas: a test that places a foreign `scripts` package earlier on `sys.path` and asserts the file-path form still imports the local one.
- [ ] Manual verification notes: optionally add the precedence caveat to `.claude/rules/orchestrator-state.md` (policy file; operator approval required).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch