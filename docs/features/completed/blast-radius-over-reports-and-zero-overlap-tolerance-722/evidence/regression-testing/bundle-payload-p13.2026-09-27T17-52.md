# Bundled-payload Contract, Second B27 Node, Phase 13 (P13-T2)

Timestamp: 2026-09-27T17-52
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: KL-510 case (b). The node failed with the assertion message "Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a7614a4e8c3c79cff-ef7479b3.json". The path's first two components are .claude and state (the gitignored batch-budget hook state, issue #510), and no output line contains "Bundle content differs from repo for:". Because the test walks .claude files in sorted order and stops at its first failed assertion, and the state directory sorts after every other directory under .claude, every other .claude file (including the amended .claude/rules/parallel-orchestration.md) was present and identical in the bundle.

KL-510: STATE-ONLY

## Assertion message (verbatim)

```text
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a7614a4e8c3c79cff-ef7479b3.json
```

## Checks

- Result line: "FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" and "1 failed in 0.13s".
- Assertion message begins with the literal "Repo file missing from bundle:" followed by a path under .claude\state\.
- A count of the full output for the literal "Bundle content differs from repo for:" returned 0 lines.

The state file is written by the PowerShell batch-budget hook during execution (the P12-T6 batch) and is gitignored; CI has no such file.
