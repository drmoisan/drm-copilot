# expect-fail-p1-t2

Timestamp: 2026-10-16T00-23
Command: poetry run pytest "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment" -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:

```text
........FFF                                                              [100%]
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
E         Use -v to get more diff

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
E         Use -v to get more diff

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
E         Use -v to get more diff

tests\scripts\dev_tools\test_workflow_npm_token_guard.py:239: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[bash-append-secret-expression]
FAILED tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[shell-export-append]
FAILED tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_detects_assignment[powershell-env-append]
3 failed, 8 passed in 0.19s
```
