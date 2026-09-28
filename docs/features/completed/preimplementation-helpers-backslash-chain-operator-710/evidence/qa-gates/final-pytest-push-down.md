# Final QC: Push-Down Contract Suite (Issue #710)

Timestamp: 2026-09-27T02-46
Command: git status --porcelain --ignored -- .claude/state; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q; git check-ignore -- .claude/state/powershell-batch-budget.worktree-agent-ad892ea660b9a7fe9-3f02e695.json
EXIT_CODE: 1
Output Summary: Pass 2. 1 failed, 13 passed. The only failed node is the #510 test (test_bundled_claude_payload_contains_all_repo_runtime_contracts); its single `AssertionError: ` line names the gitignored hook-state path .claude/state/powershell-batch-budget.worktree-agent-ad892ea660b9a7fe9-3f02e695.json, which git check-ignore confirms is ignored (exit 0) and which the [P0-T10] status output did not list. R-PYTEST branch B conditions (a), (b), and (c) all hold. KNOWN_ISSUE_510: branch-B. [P5-T7] acceptance is met.

Pass: 2

## Status Output (`git status --porcelain --ignored -- .claude/state`)

```text
!! .claude/state/
```

## Summary Line

```text
1 failed, 13 passed in 0.15s
```

## Failed or Errored Node IDs

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

## R-PYTEST Output Lines Containing `AssertionError: `

Quoted verbatim (the line contains no absolute path, drive letter, user-profile path, or account name, so no rule 2 substitution was needed):

```text
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-ad892ea660b9a7fe9-3f02e695.json
```

Line count containing `AssertionError: `: 1. Lines containing `AssertionError: Bundle content differs from repo for: `: 0. The output line `tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:137: AssertionError` does not contain `AssertionError: ` and is not a failure-message line.

## Named Paths (normalized)

- `.claude/state/powershell-batch-budget.worktree-agent-ad892ea660b9a7fe9-3f02e695.json`

## Check-Ignore

```text
CHECK_IGNORE: .claude/state/powershell-batch-budget.worktree-agent-ad892ea660b9a7fe9-3f02e695.json exit=0
```

## P0_T10_STATUS:

The [P0-T10] status output recorded in `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/baseline/p0-pytest-push-down.md`:

```text
(empty)
```

The recorded `(empty)` line is the placeholder for an empty status output and is not a status line, so no [P0-T10] status line has a path field equal to the named path or to a directory that the path begins with.

## Branch Evaluation

- (a) The #510 test is the only failed or errored node: holds (1 failed, 13 passed).
- (b) At least one `AssertionError: ` line contains `AssertionError: Repo file missing from bundle: `, none contains `AssertionError: Bundle content differs from repo for: `, and the normalized path after the token begins with `.claude/state/`: holds.
- (c) `git check-ignore` exits 0 for the path, and the [P0-T10] status output contains no matching path line: holds.

KNOWN_ISSUE_510: branch-B

No file under `.claude/state/` was deleted, moved, renamed, or edited.
