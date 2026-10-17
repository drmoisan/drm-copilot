# expect-fail-p1-t3

Timestamp: 2026-10-16T00-23
Command: poetry run pytest "tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals" -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:

```text
..F.                                                                     [100%]
================================== FAILURES ===================================
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
E         Use -v to get more diff

tests\scripts\dev_tools\test_workflow_npm_token_guard.py:306: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_find_npm_token_assignments_pins_documented_residuals[bash-append-reported]
1 failed, 3 passed in 0.25s
```

GrepCommand: grep -c -F "residual-bash-append-not-reported" tests/scripts/dev_tools/test_workflow_npm_token_guard.py
GrepOutput: 0
GrepExitCode: 1
