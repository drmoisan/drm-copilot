# Phase 1 — Coverage Exclusion Check

Timestamp: 2026-08-08T11-05
Task: [P1-T11]

Command: `git diff -- pyproject.toml .coveragerc setup.cfg tox.ini` then
`grep -n "omit|exclude_lines|\[tool.coverage" -A 6 pyproject.toml`

EXIT_CODE: 0

## Result

`git diff` over the coverage configuration files produces NO output: none of them is modified by
this change set. `.coveragerc`, `setup.cfg`, and `tox.ini` do not exist in this repository, so
`pyproject.toml` is the sole coverage configuration.

Current `[tool.coverage.run]` block, unmodified:

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
```

No `omit` entry names any `scripts/dev_tools/` path. The four existing entries are the permitted
non-production categories (test files and build/environment directories) allowed by
`.claude/rules/general-unit-test.md`.

Positive confirmation that the new module is in the denominator: the P1-T9 pytest run reports
`scripts\dev_tools\_blast_radius_glob.py 54 1 28 1 98%` as its own row in the coverage table.
A file excluded from measurement would produce no row.

Output Summary: No `omit` or `exclude` entry naming any `scripts/dev_tools/` path was added, and
no coverage configuration file was modified. `scripts/dev_tools/_blast_radius_glob.py` is a
production module measured in the coverage denominator at 98% with one uncovered statement, which
is the statement it inherited with the relocated `_entries_overlap` body.
