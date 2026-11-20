# Gate — coverage configuration untouched (AC21, second clause)

Timestamp: 2026-08-20T09-53

Task: [P7-T12]

Command: git diff 71aebdb9a1e4752b191b3c9d4e677b807ea6fdec -- pyproject.toml ; git diff --numstat 71aebdb9a1e4752b191b3c9d4e677b807ea6fdec -- pyproject.toml
EXIT_CODE: 0

## Result — the whole file is unchanged

Both commands produced NO output. Empty diff output and an absent numstat row together mean
`pyproject.toml` was not modified at all by this change, so zero lines changed in
`[tool.coverage.run]`, zero in `[tool.coverage.report]`, and zero anywhere else in the file.

## Current content of the two coverage sections, recorded for the audit trail

```toml
[tool.coverage.run]
source = ["src", "scripts/dev_tools"]
data_file = "artifacts/.coverage"
omit = [
    "tests/*",
    "*/tests/*",
    "*/__pycache__/*",
    "*/site-packages/*",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "if TYPE_CHECKING:",
    "@abstractmethod",
    "@abc.abstractmethod",
    "^\s*\.\.\.\s*$",
]
```

No `omit` or `exclude` entry was added for any production file. The `omit` list still names only test,
`__pycache__`, and site-packages paths, consistent with the Coverage Exclusion Policy in
`.claude/rules/general-unit-test.md`; `source = ["src", "scripts/dev_tools"]` keeps both changed
Python production files in the coverage denominator. The `exclude_lines` list is the pre-existing set
of line-level pragmas and carries no entry naming any file. The only other `exclude` key in the file
is at line 153 inside `[tool.pyright]`, which lists build and cache directories and is likewise
unchanged.

Output Summary: `pyproject.toml` is unmodified — empty diff output and no numstat row — so zero lines
changed in `[tool.coverage.run]` or `[tool.coverage.report]`. No `omit` or `exclude` entry was added
for any production file, and both changed Python production files remain in the coverage denominator.
