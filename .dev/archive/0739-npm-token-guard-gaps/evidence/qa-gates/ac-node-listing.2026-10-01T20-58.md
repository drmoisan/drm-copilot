# AC node listing (P2-T10)

Timestamp: 2026-10-01T20-58
Command: poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -v
EXIT_CODE: 0
CombinedStateBase: origin/main 12fd3c26 (includes #723 / PR #813) merged at 8c2a7c85
Output Summary: `============================= 52 passed in 0.10s ==============================`; 52 PASSED node lines, 0 FAILED or ERROR lines. Every node ID that P2-T10 names (the nine context-positive, six context-negative, seven `_authToken`-positive, six `_authToken`-negative, seven assignment-positive, and six assignment-negative parametrized IDs, `test_collect_offenders_names_each_matching_line`, `test_github_yaml_enumeration_is_non_vacuous`, and the four `test_github_yaml_files_contain_no_npm_token_route` IDs) appears below with `PASSED`.

## Node listing

    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[dot-access] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[single-quoted-bracket] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[double-quoted-bracket] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[spaced-lowercase-dot] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[third-line-of-three] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[spaced-bracket] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[lowercase-bracket] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[vars-dot] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[vars-bracket] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[unrelated-secret] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[longer-secret-name] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[no-secrets-context] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[empty] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[vars-longer-name] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[prefixed-context-name] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_detects_reference[other-secret-name] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_detects_reference[lowercase-second-line] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[oidc-permission] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[longer-name] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[empty] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npmrc-echo-registry-scoped] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npmrc-bare-key] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-env-upper] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-env-lower] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-env-registry-scoped] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-set-bare] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-set-registry-scoped] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[oidc-permission] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[setup-node-registry-url] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[always-auth] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[node-auth-token-is-separate-family] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[letter-prefixed-name] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[empty] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[yaml-env-key-other-secret] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[yaml-flow-mapping] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[quoted-key] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[shell-export] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[github-env-append] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[powershell-env] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[lowercase-key] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[secrets-dot-context] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[env-context-read] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[longer-name-key] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[prefixed-name-key] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[prose-comment] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[empty] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_collect_offenders_names_each_matching_line PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_enumeration_is_non_vacuous PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-context] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[node-auth-token] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-auth-token-config] PASSED
    tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment] PASSED
    ============================= 52 passed in 0.10s ==============================
