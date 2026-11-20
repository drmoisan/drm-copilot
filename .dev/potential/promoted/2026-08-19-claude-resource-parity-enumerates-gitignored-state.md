# claude-resource-parity-enumerates-gitignored-state (Issue #510)

- Date captured: 2026-08-19
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/claude-resource-parity-enumerates-gitignored-state/ (Issue #510)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: full-bug

- Issue: #510
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/510
- Last Updated: 2026-08-23
## Summary

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates the repository `.claude/**` tree with `Path.rglob("*")` and does not read `.gitignore`. Gitignored, session-scoped state files under `.claude/state/` are therefore enumerated and reported as missing from the bundle, failing the suite for a reason unrelated to the mirrors it exists to verify.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- Data source or fixture: `.claude/state/` runtime artifacts written by the batch-budget hooks

## Steps to Reproduce

1. In a clean worktree, confirm the suite passes.
2. Cause the batch-budget hook to create its state file, by writing a PowerShell file through the Write or Edit tool, or by writing enough Python files to trip the Python budget. Confirm the file exists with `ls .claude/state/`.
3. Re-run the suite. It now fails, naming the state file as missing from the bundle.
4. Delete the state file and re-run. It passes again.

## Expected Behavior

The walk considers only files that are actually part of the distributed payload. Session-local and machine-local runtime state, which is gitignored and never distributable, is excluded exactly as `.claude/settings.local.json` and `.claude/agent-memory/**` already are.

## Actual Behavior

The suite fails with a message naming a file that is correctly absent from the bundle:

```text
AssertionError: Repo file missing from bundle: .claude/state/python-batch-budget.default.json
```

The walk excludes only `.claude/settings.local.json` and `.claude/agent-memory/**`. `.claude/state/` is gitignored at `.gitignore` line 68 but is not excluded from the walk.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet, observed 2026-08-22 during issue #500 orchestration:

  ```text
  E  AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
  tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
  ```

  Deleting the gitignored artifact and re-running returned `10 passed`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. A green suite fails spuriously once any hook-triggering write occurs in a session. The message names a file that is correctly absent from the bundle, which misdirects diagnosis toward the mirror work actually under test. Because the remedy looks like deleting a file, the natural response is a per-plan workaround rather than a repository fix, so the defect recurs for every future feature that trips a budget hook. The state file is session-scoped runtime state and is gitignored; it is never distributable, so including it in a distribution-parity assertion is incorrect on its own terms.

CI is unaffected: no workflow under `.github/workflows` invokes the Claude PreToolUse hooks, so the artifact is never created on a runner. This is a local-workstation failure only.

## Suspected Cause / Notes

The walk was written with two explicit exclusions and no general rule, so each new gitignored runtime path under `.claude/` reintroduces the failure.

The trigger has widened since this entry was first written. It originally reproduced only through `.claude/hooks/enforce-powershell-batch-budget.ps1`, which creates `.claude/state/powershell-batch-budget.<session_id>.json` on the first PowerShell write of a session. Issue #501 added an entry-point seam to the Python batch-budget hook, which now creates `.claude/state/python-batch-budget.default.json` as well, so a session that writes only Python files reproduces it too.

## Proposed Fix / Validation Ideas

- [ ] Exclude `.claude/state/**` from the walk, exactly as `.claude/agent-memory/**` is already excluded. The two are the same category of local runtime state.
- [ ] A broader alternative is to have the walk honor `.gitignore`, which generalizes to any future gitignored runtime path under `.claude/`. That is more durable but widens the suite's behavior and should first be evaluated for whether it could mask a genuinely missing tracked file.
- [ ] The suite must still fail when a genuinely tracked, distributable `.claude` file is missing from the bundle, so the exclusion does not weaken the assertion it protects.
- [ ] The exclusion must cover nested paths under `.claude/state/`, not only direct children.
- [ ] `.claude/settings.local.json` and `.claude/agent-memory/**` must remain excluded.
- [ ] Check whether the TypeScript and Python pack-manifest completeness suites share the same unfiltered-walk exposure.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
