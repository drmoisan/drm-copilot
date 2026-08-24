# Expect-Fail — Python (bug, minor-audit) regression (Issue #401)

Timestamp: 2026-07-22T15-53

Command: poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -k test_promote_potential_bug_minor_audit_uses_bug_body (from repo/worktree root)

EXIT_CODE: 1

Output Summary:
- Failing test (expected): test_promote_potential_bug_minor_audit_uses_bug_body.
- Result: 1 failed, 28 deselected.
- Failure detail: against the unfixed Python code the (bug, minor-audit) cell routes to build_minor_audit_body, producing "## Problem / Why", "## Implementation Intent", etc. with "(not provided in potential file)" placeholders. The assertion `"## Summary\nsummary details" in body` failed. This is the expected fail-before state for AC-3; the Phase 2 Python branch reorder makes it pass.
