# No coverage exclusion added for the new leaf module ([P11-T19])

Timestamp: 2026-08-08T13-05

Command:
```
git diff --name-only pyproject.toml
ls .coveragerc
grep -n "omit\|\[tool.coverage" pyproject.toml
```

EXIT_CODE: 0

## Output Summary

NO coverage exclusion entry was added for
`scripts/dev_tools/_blast_radius_thresholds.py`, or for any other
`scripts/dev_tools/` path, in any coverage configuration.

### Configuration files inspected

| File | State |
| --- | --- |
| `pyproject.toml` | Present. `git diff --name-only pyproject.toml` produces NO output and exits 0, so the file is unmodified by this plan. |
| `.coveragerc` | Does not exist in the repository (`ls: cannot access '.coveragerc': No such file or directory`). |
| `setup.cfg`, `tox.ini` | Do not exist in the repository. |

### The committed `omit` list, unchanged

`pyproject.toml` lines 115-124:

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

All four `omit` entries are non-production paths permitted by
`.claude/rules/general-unit-test.md` (test files, bytecode caches, and installed
packages). NO entry names any `scripts/dev_tools/` path. `scripts/dev_tools` is
in fact a coverage `source` root, so the new module is automatically inside the
measurement denominator rather than outside it — confirmed empirically by the
[P11-T16] run, which reports
`scripts\dev_tools\_blast_radius_thresholds.py  10  0  4  0  100%` as a measured
row.

### `exclude_lines`

The `[tool.coverage.report] exclude_lines` list is likewise unmodified. It
contains only line-level idiom patterns (`pragma: no cover`, `def __repr__`,
`raise AssertionError`, `raise NotImplementedError`, `if __name__ ==
.__main__.:`, `if TYPE_CHECKING:`, `@abstractmethod`, `@abc.abstractmethod`, and
a bare-ellipsis pattern). No path-shaped entry was added, and no entry was added
by this relief.
