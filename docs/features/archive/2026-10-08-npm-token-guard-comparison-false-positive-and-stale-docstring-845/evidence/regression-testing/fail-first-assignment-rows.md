# Fail-First Assignment Rows [expect-fail]

Timestamp: 2026-10-09T20-40
Command: poetry run pytest "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment" "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text" -v
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 2 failed, 15 passed in 0.14s. FAILED: ignores_non_matching_text[equality-comparison] and ignores_non_matching_text[shell-equality-test] (each returned [1], expected []). PASSED: [inequality-comparison] and detects_assignment[empty-assignment-end-of-line]. Pattern not yet changed (fail-first state).

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
test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison] FAILED
test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test] FAILED
test_find_npm_token_assignments_ignores_non_matching_text[inequality-comparison] PASSED
```

Failure messages:

```text
AssertionError: input "if: ${{ env.NPM_TOKEN == '' }}" returned [1], expected []
AssertionError: input '[[ $NPM_TOKEN == "" ]]' returned [1], expected []
```

Final result line:

```text
======================== 2 failed, 15 passed in 0.14s =========================
```

Collection checks for P1-T1 and P1-T2 (exit 0 each): `test_find_npm_token_assignments_ignores_non_matching_text` reports 9 tests collected; `test_find_npm_token_assignments_detects_assignment` reports 8 tests collected.
