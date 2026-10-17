# Rule-Doc and Mirror Tests (P6-T4)

Timestamp: 2026-09-29T19-15
Command: poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Result line: `1 failed, 21 passed in 0.37s`.
- Sole failure: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  with message `AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.worktree-agent-a99d2af8cad4116b3-bcaad275.json`.
- The message names a `.claude/state/` path (a gitignored hook state file), which is the known environment condition of issue #510.
  This is the single admissible failure named in the P6-T4 acceptance; P6-T3 hash equality
  (both files 8eddadf58694694ccf3bce05ebee172039ddc68e, see rule-doc-parity.2026-09-29T19-15.md) is the recorded parity proof.
- All tests in test_claude_rules_frontmatter.py passed.
- Acceptance: PASS (admissible issue #510 branch).
