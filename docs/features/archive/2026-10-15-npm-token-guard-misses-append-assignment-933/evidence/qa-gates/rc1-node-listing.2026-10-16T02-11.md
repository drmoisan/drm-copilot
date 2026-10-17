# rc1 Node Listing (P2-T10)

Timestamp: 2026-10-16T02-11
Command: poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -v
EXIT_CODE: 0
Output Summary: ============================= 70 passed in 0.15s ==============================

Named nodes (F1, F2, prior AC regression rows): all 15 are listed PASSED below. 70 passed against 66 baseline nodes (P0-T12) establishes that every pre-existing row still passes. Progress-percentage suffixes are removed from the node lines.

Node lines:

```text
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
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[empty-assignment-end-of-line] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[bash-append-secret-expression] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[shell-export-append] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[powershell-env-append] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[dot-prefixed-append-reported] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[hyphen-prefixed-append-reported] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[arithmetic-compound-append] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[secrets-dot-context] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[env-context-read] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[longer-name-key] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[prefixed-name-key] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[prose-comment] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[empty] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[inequality-comparison] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[longer-name-append] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[arithmetic-increment] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[double-plus-equals-not-reported] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[residual-single-equals-shell-test-reported] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[residual-bash-regex-match-reported] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[bash-append-reported] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[accepted-double-equals-narrowing-not-reported] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[accepted-append-double-equals-not-reported] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_collect_offenders_names_each_matching_line PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_enumeration_is_non_vacuous PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-context] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[node-auth-token] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-auth-token-config] PASSED
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment] PASSED
============================= 70 passed in 0.15s ==============================
```
