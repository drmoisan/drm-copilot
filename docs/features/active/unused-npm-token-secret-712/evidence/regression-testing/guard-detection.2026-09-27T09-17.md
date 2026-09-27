# Guard Detection Run (P2-T1)

Timestamp: 2026-09-27T09-17
Command: poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -v
EXIT_CODE: 0
Output Summary:
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[dot-access] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[single-quoted-bracket] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[double-quoted-bracket] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[spaced-lowercase-dot] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[third-line-of-three] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[unrelated-secret] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[longer-secret-name] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[no-secrets-context] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[empty] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_detects_reference[other-secret-name] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_detects_reference[lowercase-second-line] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[oidc-permission] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[longer-name] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[empty] PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_enumeration_is_non_vacuous PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_reference_no_npm_token_secret PASSED
- tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_reference_no_node_auth_token PASSED
- Result line: `============================= 17 passed in 0.07s ==============================`

Interpretation: the five parametrized positive cases of `test_find_npm_token_references_detects_reintroduced_reference` and the two of `test_find_node_auth_token_references_detects_reference` show that the helpers used by the tree scan return non-empty results for each reintroduced reference shape. The two tree-scan tests pass on the current tree.
