# Changed Python Files Scope (issue #527)

Timestamp: 2026-10-02T05-33
Command: git diff --name-only origin/main...HEAD -- '*.py'; git status --porcelain -- '*.py' (run from <ROOT>)
EXIT_CODE: 0 (both commands)
Output Summary: The committed diff against origin/main lists exactly one Python file, a test module. The porcelain status for Python files is empty. No Python production file changed on the branch.

## git diff --name-only origin/main...HEAD -- '*.py'

```
tests/scripts/dev_tools/test_poshqc_bundled_parity.py
```

## git status --porcelain -- '*.py'

```
(no output)
```
