# fail-before

Timestamp: 2026-10-16T00-25
Command: poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py -v
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-afe528d4c18dba6f5\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-afe528d4c18dba6f5
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 66 items

tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[dot-access] PASSED [  1%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[single-quoted-bracket] PASSED [  3%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[double-quoted-bracket] PASSED [  4%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[spaced-lowercase-dot] PASSED [  6%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[third-line-of-three] PASSED [  7%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[spaced-bracket] PASSED [  9%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[lowercase-bracket] PASSED [ 10%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[vars-dot] PASSED [ 12%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_detects_reintroduced_reference[vars-bracket] PASSED [ 13%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[unrelated-secret] PASSED [ 15%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[longer-secret-name] PASSED [ 16%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[no-secrets-context] PASSED [ 18%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[empty] PASSED [ 19%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[vars-longer-name] PASSED [ 21%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_references_ignores_non_matching_text[prefixed-context-name] PASSED [ 22%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_detects_reference[other-secret-name] PASSED [ 24%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_detects_reference[lowercase-second-line] PASSED [ 25%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[oidc-permission] PASSED [ 27%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[longer-name] PASSED [ 28%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_node_auth_token_references_ignores_non_matching_text[empty] PASSED [ 30%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npmrc-echo-registry-scoped] PASSED [ 31%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npmrc-bare-key] PASSED [ 33%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-env-upper] PASSED [ 34%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-env-lower] PASSED [ 36%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-env-registry-scoped] PASSED [ 37%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-set-bare] PASSED [ 39%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_detects_config_key[npm-config-set-registry-scoped] PASSED [ 40%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[oidc-permission] PASSED [ 42%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[setup-node-registry-url] PASSED [ 43%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[always-auth] PASSED [ 45%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[node-auth-token-is-separate-family] PASSED [ 46%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[letter-prefixed-name] PASSED [ 48%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_auth_token_config_references_ignores_non_matching_text[empty] PASSED [ 50%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[yaml-env-key-other-secret] PASSED [ 51%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[yaml-flow-mapping] PASSED [ 53%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[quoted-key] PASSED [ 54%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[shell-export] PASSED [ 56%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[github-env-append] PASSED [ 57%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[powershell-env] PASSED [ 59%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[lowercase-key] PASSED [ 60%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[empty-assignment-end-of-line] PASSED [ 62%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[bash-append-secret-expression] FAILED [ 63%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[shell-export-append] FAILED [ 65%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[powershell-env-append] FAILED [ 66%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[secrets-dot-context] PASSED [ 68%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[env-context-read] PASSED [ 69%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[longer-name-key] PASSED [ 71%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[prefixed-name-key] PASSED [ 72%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[prose-comment] PASSED [ 74%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[empty] PASSED [ 75%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[equality-comparison] PASSED [ 77%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[shell-equality-test] PASSED [ 78%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[inequality-comparison] PASSED [ 80%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[longer-name-append] PASSED [ 81%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_ignores_non_matching_text[arithmetic-increment] PASSED [ 83%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[residual-single-equals-shell-test-reported] PASSED [ 84%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[residual-bash-regex-match-reported] PASSED [ 86%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[bash-append-reported] FAILED [ 87%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[accepted-double-equals-narrowing-not-reported] PASSED [ 89%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[accepted-append-double-equals-not-reported] PASSED [ 90%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_collect_offenders_names_each_matching_line PASSED [ 92%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_enumeration_is_non_vacuous PASSED [ 93%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-context] PASSED [ 95%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[node-auth-token] PASSED [ 96%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-auth-token-config] PASSED [ 98%]
tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_contain_no_npm_token_route[npm-token-assignment] PASSED [100%]

================================== FAILURES ===================================
_ test_find_npm_token_assignments_detects_assignment[bash-append-secret-expression] _

text = 'NPM_TOKEN+=${{ secrets.X }}', expected = [1]

    @pytest.mark.parametrize(
        ("text", "expected"),
        [
            pytest.param(
                "env:\n  NPM_TOKEN: ${{ secrets.PUBLISH }}",
                [2],
                id="yaml-env-key-other-secret",
            ),
            pytest.param("env: { NPM_TOKEN: x }", [1], id="yaml-flow-mapping"),
            pytest.param('"NPM_TOKEN": x', [1], id="quoted-key"),
            pytest.param("export NPM_TOKEN=x", [1], id="shell-export"),
            pytest.param(
                'echo "NPM_TOKEN=x" >> "$GITHUB_ENV"', [1], id="github-env-append"
            ),
            pytest.param("$env:NPM_TOKEN = 'x'", [1], id="powershell-env"),
            pytest.param("npm_token: x", [1], id="lowercase-key"),
            pytest.param("NPM_TOKEN=", [1], id="empty-assignment-end-of-line"),
            pytest.param("NPM_TOKEN+=${{ secrets.X }}", [1], id="bash-append-secret-expression"),
            pytest.param("export NPM_TOKEN+=x", [1], id="shell-export-append"),
            pytest.param("$env:NPM_TOKEN += 'x'", [1], id="powershell-env-append"),
        ],
    )
    def test_find_npm_token_assignments_detects_assignment(
        text: str, expected: list[int]
    ) -> None:
        """An ``NPM_TOKEN`` assignment is reported whichever secret feeds it."""
        # Arrange: the parametrized text and its expected line numbers.
    
        # Act
        result = find_npm_token_assignments(text)
    
        # Assert
>       assert result == expected, f"input {text!a} returned {result}, expected {expected}"
E       AssertionError: input 'NPM_TOKEN+=${{ secrets.X }}' returned [], expected [1]
E       assert [] == [1]
E         
E         Right contains one more item: 1
E         
E         Full diff:
E         + []
E         - [
E         -     1,
E         - ]

tests\scripts\dev_tools\test_workflow_npm_token_guard.py:239: AssertionError
___ test_find_npm_token_assignments_detects_assignment[shell-export-append] ___

text = 'export NPM_TOKEN+=x', expected = [1]

    @pytest.mark.parametrize(
        ("text", "expected"),
        [
            pytest.param(
                "env:\n  NPM_TOKEN: ${{ secrets.PUBLISH }}",
                [2],
                id="yaml-env-key-other-secret",
            ),
            pytest.param("env: { NPM_TOKEN: x }", [1], id="yaml-flow-mapping"),
            pytest.param('"NPM_TOKEN": x', [1], id="quoted-key"),
            pytest.param("export NPM_TOKEN=x", [1], id="shell-export"),
            pytest.param(
                'echo "NPM_TOKEN=x" >> "$GITHUB_ENV"', [1], id="github-env-append"
            ),
            pytest.param("$env:NPM_TOKEN = 'x'", [1], id="powershell-env"),
            pytest.param("npm_token: x", [1], id="lowercase-key"),
            pytest.param("NPM_TOKEN=", [1], id="empty-assignment-end-of-line"),
            pytest.param("NPM_TOKEN+=${{ secrets.X }}", [1], id="bash-append-secret-expression"),
            pytest.param("export NPM_TOKEN+=x", [1], id="shell-export-append"),
            pytest.param("$env:NPM_TOKEN += 'x'", [1], id="powershell-env-append"),
        ],
    )
    def test_find_npm_token_assignments_detects_assignment(
        text: str, expected: list[int]
    ) -> None:
        """An ``NPM_TOKEN`` assignment is reported whichever secret feeds it."""
        # Arrange: the parametrized text and its expected line numbers.
    
        # Act
        result = find_npm_token_assignments(text)
    
        # Assert
>       assert result == expected, f"input {text!a} returned {result}, expected {expected}"
E       AssertionError: input 'export NPM_TOKEN+=x' returned [], expected [1]
E       assert [] == [1]
E         
E         Right contains one more item: 1
E         
E         Full diff:
E         + []
E         - [
E         -     1,
E         - ]

tests\scripts\dev_tools\test_workflow_npm_token_guard.py:239: AssertionError
__ test_find_npm_token_assignments_detects_assignment[powershell-env-append] __

text = "$env:NPM_TOKEN += 'x'", expected = [1]

    @pytest.mark.parametrize(
        ("text", "expected"),
        [
            pytest.param(
                "env:\n  NPM_TOKEN: ${{ secrets.PUBLISH }}",
                [2],
                id="yaml-env-key-other-secret",
            ),
            pytest.param("env: { NPM_TOKEN: x }", [1], id="yaml-flow-mapping"),
            pytest.param('"NPM_TOKEN": x', [1], id="quoted-key"),
            pytest.param("export NPM_TOKEN=x", [1], id="shell-export"),
            pytest.param(
                'echo "NPM_TOKEN=x" >> "$GITHUB_ENV"', [1], id="github-env-append"
            ),
            pytest.param("$env:NPM_TOKEN = 'x'", [1], id="powershell-env"),
            pytest.param("npm_token: x", [1], id="lowercase-key"),
            pytest.param("NPM_TOKEN=", [1], id="empty-assignment-end-of-line"),
            pytest.param("NPM_TOKEN+=${{ secrets.X }}", [1], id="bash-append-secret-expression"),
            pytest.param("export NPM_TOKEN+=x", [1], id="shell-export-append"),
            pytest.param("$env:NPM_TOKEN += 'x'", [1], id="powershell-env-append"),
        ],
    )
    def test_find_npm_token_assignments_detects_assignment(
        text: str, expected: list[int]
    ) -> None:
        """An ``NPM_TOKEN`` assignment is reported whichever secret feeds it."""
        # Arrange: the parametrized text and its expected line numbers.
    
        # Act
        result = find_npm_token_assignments(text)
    
        # Assert
>       assert result == expected, f"input {text!a} returned {result}, expected {expected}"
E       AssertionError: input "$env:NPM_TOKEN += 'x'" returned [], expected [1]
E       assert [] == [1]
E         
E         Right contains one more item: 1
E         
E         Full diff:
E         + []
E         - [
E         -     1,
E         - ]

tests\scripts\dev_tools\test_workflow_npm_token_guard.py:239: AssertionError
_ test_find_npm_token_assignments_pins_documented_residuals[bash-append-reported] _

text = 'NPM_TOKEN+=x', expected = [1]

    @pytest.mark.parametrize(
        ("text", "expected"),
        [
            pytest.param(
                '[ $NPM_TOKEN = "" ]',
                [1],
                id="residual-single-equals-shell-test-reported",
            ),
            pytest.param(
                "[[ $NPM_TOKEN =~ ^npm_ ]]",
                [1],
                id="residual-bash-regex-match-reported",
            ),
            pytest.param("NPM_TOKEN+=x", [1], id="bash-append-reported"),
            pytest.param(
                "NPM_TOKEN==value",
                [],
                id="accepted-double-equals-narrowing-not-reported",
            ),
            pytest.param("NPM_TOKEN+==x", [], id="accepted-append-double-equals-not-reported"),
        ],
    )
    def test_find_npm_token_assignments_pins_documented_residuals(
        text: str, expected: list[int]
    ) -> None:
        """Pin the documented residual and narrowing behavior of the assignment finder.
    
        The #845 spec non-goal accepts three residuals of the textual
        ``NPM_TOKEN`` assignment rule: a single ``=`` shell test and a bash ``=~``
        regex match are reported, and a bash ``+=`` append is not. The #845
        backward-compatibility section accepts the ``==`` narrowing, so
        ``NPM_TOKEN==value`` is not reported. These rows characterize existing
        behavior so a change to either outcome is visible.
        """
        # Arrange: the parametrized text and its expected line numbers.
    
        # Act
        result = find_npm_token_assignments(text)
    
        # Assert
>       assert result == expected, f"input {text!a} returned {result}, expected {expected}"
E       AssertionError: input 'NPM_TOKEN+=x' returned [], expected [1]
E       assert [] == [1]
E         
E         Right contains one more item: 1
E         
E         Full diff:
E         + []
E         - [
E         -     1,
E         - ]

tests\scripts\dev_tools\test_workflow_npm_token_guard.py:309: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[bash-append-secret-expression]
FAILED tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[shell-export-append]
FAILED tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[powershell-env-append]
FAILED tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[bash-append-reported]
======================== 4 failed, 62 passed in 0.92s =========================
```
