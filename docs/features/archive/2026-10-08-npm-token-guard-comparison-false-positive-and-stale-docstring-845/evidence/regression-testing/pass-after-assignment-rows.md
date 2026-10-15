# Pass-After Assignment Rows

Timestamp: 2026-10-09T20-45
Command: poetry run pytest "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment" "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text" -v
EXIT_CODE: 0
Output Summary: 17 passed in 0.08s. [equality-comparison], [shell-equality-test], [inequality-comparison] (ignores_non_matching_text) and [empty-assignment-end-of-line] (detects_assignment) are each PASSED.

Node lines (prefix tests/scripts/dev_tools/test_workflow_npm_token_guard.py::):

```text
test_find_npm_token_assignments_detects_assignment[yaml-env-key-other-secret] PASSED
test_find_npm_token_assignments_detects_assignment[yaml-flow-mapping] PASSED
test_find_npm_token_assignments_detects_assignment[quoted-key] PASSED
test_find_npm_token_assignments_detects_assignment[shell-export] PASSED
test_find_npm_token_assignments_detects_assignment[github-env-append] PASSED
test_find_npm_token_assignments_detects_assignment[powershell-env] PASSED
test_find_npm_token_assignments_detects_assignment[lowercase-key] PASSED
test_find_npm_token_assignments_detects_assignment[empty-assignment-end-of-line] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[secrets-dot-context] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[env-context-read] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[longer-name-key] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[prefixed-name-key] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[prose-comment] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[empty] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test] PASSED
test_find_npm_token_assignments_ignores_non_matching_text[inequality-comparison] PASSED
```

Final result line:

```text
============================== 17 passed in 0.08s ==============================
```
