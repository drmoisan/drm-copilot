# #845 Node-Id Comparison (P4-T14)

Timestamp: 2026-10-13T11-26
Command: poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py --collect-only -q > artifacts/scratch-903/npm-guard-collect-after-903.txt; git diff --no-index artifacts/scratch-903/npm-guard-collect-before-903.txt artifacts/scratch-903/npm-guard-collect-after-903.txt
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Collect-only exit 0 (60 tests collected). The `git diff --no-index` exits 1 because the files differ. The only removed line is the summary line (`56 tests collected`); the added lines are the new summary line (`60 tests collected`) and exactly the four `test_find_npm_token_assignments_pins_documented_residuals` ids. Every pre-split node id is present after the split.

## Diff text

```
diff --git a/artifacts/scratch-903/npm-guard-collect-before-903.txt b/artifacts/scratch-903/npm-guard-collect-after-903.txt
index db8fce2e8..61d8a3d6d 100644
--- a/artifacts/scratch-903/npm-guard-collect-before-903.txt
+++ b/artifacts/scratch-903/npm-guard-collect-after-903.txt
@@ -48,6 +48,10 @@ tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_as
 tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison]
 tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test]
 tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[inequality-comparison]
+tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[residual-single-equals-shell-test-reported]
+tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[residual-bash-regex-match-reported]
+tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[residual-bash-append-not-reported]
+tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[accepted-double-equals-narrowing-not-reported]
 tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_collect_offenders_names_each_matching_line
 tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_enumeration_is_non_vacuous
 tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-context]
@@ -55,4 +59,4 @@ tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files
 tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-auth-token-config]
 tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment]
 
-56 tests collected in 0.05s
+60 tests collected in 0.06s
```

Git also printed two `CRLF will be replaced by LF` warnings for the git-ignored scratch files; they do not affect the comparison.

## Classification

- Removed (`-`) lines: `56 tests collected in 0.05s` (summary line only).
- Added (`+`) lines: `60 tests collected in 0.06s` (summary line) and the four ids `[residual-single-equals-shell-test-reported]`, `[residual-bash-regex-match-reported]`, `[residual-bash-append-not-reported]`, `[accepted-double-equals-narrowing-not-reported]`.
- Collected count after the split: 60.
