# execution-env-test-worktree-filter (Bug)

- Date captured: 2026-11-06
- Author: Dan Moisan
- Status: Active
- Issue: #1019 (adopted from epic decomposition; no separate issue is filed)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Work Mode: minor-audit

## Summary

`test_execution_environment_fact_is_unchanged_across_copies` in `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` evaluates its exclusion set against absolute path parts. Any checkout located under a directory named `worktrees` therefore discards all six copies of the execution-environment brief, and the test fails with 0 found.

## Environment

- OS/version: Windows 11 Pro, agent-isolated worktree under `.claude/worktrees/`
- Python version: 3.13 (Poetry environment)
- Command/flags used: Pytest on the named test node
- Data source or fixture: the committed copies of `execution-environment/SKILL.md`

## Steps to Reproduce

1. Check out the repository under any directory named `worktrees`.
2. Run the test node `test_execution_environment_fact_is_unchanged_across_copies`.
3. Observe the count assertion.

## Expected Behavior

The test finds the six committed copies regardless of where the checkout is located, and excludes only paths inside the repository that lie under `node_modules`, `.git`, `packages`, or `worktrees`.

## Actual Behavior

`AssertionError: []` with `assert 0 == 6`, because an ancestor of the repository root named `worktrees` matches the exclusion set.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `evidence/regression-testing/fail-before.<timestamp>.md`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The generator expression tests `set(path.parts)`, and `path` is absolute because it comes from `REPO_ROOT.rglob`.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: the named test, run from a worktree and against an exclusion that still applies to a nested agent worktree.
- [ ] Integration scenario to retest: not applicable.
- [ ] Manual verification notes: not applicable.

## Acceptance Criteria

- [ ] AC1: The exclusion in `test_execution_environment_fact_is_unchanged_across_copies` is evaluated against `path.relative_to(REPO_ROOT).parts`, and no other production or test logic changes.
- [ ] AC2: The assertion and the expected count of 6 are unchanged, and the excluded directory names are unchanged, so a nested agent worktree under the repository root stays excluded.
- [ ] AC3: The test fails before the fix and passes after it when run from a checkout located under a directory named `worktrees`.
- [ ] AC4: Black, Ruff, Pyright, and Pytest pass on the changed file.

## Next Step

- [x] Move to active fix folder / branch
