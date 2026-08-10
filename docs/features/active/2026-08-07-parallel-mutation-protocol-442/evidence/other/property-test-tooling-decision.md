# Property-Test Tooling Decision — Confirmation ([P1-T6])

Timestamp: 2026-08-08T21-48

Command: `grep -c "hypothesis" pyproject.toml`
EXIT_CODE: 1 (grep reports no match)
Result: `0` matches.

Command: `grep -n 'name = "hypothesis"' poetry.lock`
EXIT_CODE: 1 (grep reports no match)
Result: no package entry.

Command: `poetry run python -c "import importlib.util; print('hypothesis installed:', importlib.util.find_spec('hypothesis') is not None)"`
EXIT_CODE: 0
Result: `hypothesis installed: False`

Command: `grep -n "^\[tool.poetry" pyproject.toml`
EXIT_CODE: 0
Result: `[tool.poetry]` (5), `[tool.poetry.dependencies]` (16),
`[tool.poetry.group.dev.dependencies]` (36), `[tool.poetry.scripts]` (47).

## `hypothesis` Presence Finding

**`hypothesis` is ABSENT.** Confirmed three independent ways:

1. It appears in NO dependency group of `pyproject.toml` — zero occurrences in the
   whole file, so it is absent from `[tool.poetry.dependencies]`, from
   `[tool.poetry.group.dev.dependencies]`, and from every other section. Those four
   sections are the complete set of `[tool.poetry*]` tables in the file.
2. `poetry.lock` contains no `name = "hypothesis"` package entry. The `hypothesis`
   substring does occur in the lock file, but only inside the `extras`/`test` extra
   metadata of unrelated third-party packages (pandas, scipy, pytest-family entries at
   lock lines 1954, 1975, 2046, 2067, 2618, 3341, 3421). Extra metadata of another
   package does not install the dependency and is not a declaration by this project.
3. The resolved environment reports `find_spec('hypothesis') is None`, so the module
   is not importable at run time.

This confirms the plan's reconciled finding. It has NOT since been added upstream.

## Selected Mechanism

**Seeded `random.Random(seed)` graph generation, with the seed printed on failure so
any failure is reproducible.** This mechanism is SELECTED, not conditional, and is
authorized by the determinism rules in `.claude/rules/general-unit-test.md`
("Seeded RNG — randomness must be supplied via a seedable interface; on test failure
the seed must be printed so the failure is reproducible"). [P2-T9] implements the
property tests on this mechanism and does not import `hypothesis`.

## No Dependency Is Added

**This plan adds no dependency under any circumstance.** `pyproject.toml` and
`poetry.lock` are not modified by any task in this plan. [P7-T10] Check F verifies this
from the branch diff (`git diff c939b5b8 -- pyproject.toml poetry.lock` must be empty).

## Branch-Status Classification

This task records a **branch SELECTION, not a divergence.** The Phase 1 stop rule is
therefore NOT triggered by it, and [P1-T8] confirms this task as
"selection recorded". Per the task text, even if `hypothesis` had since been added
upstream the selected mechanism would be unchanged, so this task can never block.

## Output Summary

`hypothesis` confirmed absent from `pyproject.toml` (0 occurrences), from `poetry.lock`
package entries, and from the resolved environment. Selected property-test mechanism:
seeded `random.Random(seed)` with the seed printed on failure. No dependency is added
by this plan. Status: selection recorded; not a divergence.
