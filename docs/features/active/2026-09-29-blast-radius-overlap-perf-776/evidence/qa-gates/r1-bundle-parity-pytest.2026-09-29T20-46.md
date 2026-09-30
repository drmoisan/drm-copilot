# Remediation Bundle Byte-Identity Test (P2-T14)

Timestamp: 2026-09-29T20-46
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"; git check-ignore -q .claude/state/current-session-id
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- KL-510: STATE-ONLY
- The node failed (1 failed). Assertion message, verbatim: `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
- The single path is .claude/state/current-session-id; `git check-ignore -q .claude/state/current-session-id` exited 0 (gitignored local state, known issue #510).
- No output line contains "Bundle content differs from repo for:" (grep count 0).
- The node was run twice with the same result; the second run's output was captured for the greps above.
- P2-T11 remains the direct identity proof for the three mirrors (all three pairs byte-identical).
- Result: PASS under acceptance case (b).
