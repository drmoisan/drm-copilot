# Baseline Coverage Scope

Timestamp: 2026-10-09T20-30
Command: grep -n -F "source = " pyproject.toml ; grep -n -F "tests/*" pyproject.toml
EXIT_CODE: 0
Output Summary: pyproject.toml line 120 sets source = ["src", "scripts/dev_tools"]; line 123 lists "tests/*" under omit.

Outputs, verbatim:

1. `grep -n -F "source = " pyproject.toml`

```text
120:source = ["src", "scripts/dev_tools"]
```

2. `grep -n -F "tests/*" pyproject.toml`

```text
106:"tests/**/*" = ["S101"]
123:    "tests/*",
124:    "*/tests/*",
```

CoverageApplicability: not applicable - tests/* is omitted from coverage measurement and the only changed Python file is tests/scripts/dev_tools/test_workflow_npm_token_guard.py; no coverage percentage is asserted (spec D3)
