# Phase 3 — Gap 1 Python Pass-After (full toolchain)

Timestamp: 2026-08-08T11-40
Task: [P3-T12]

Command: `poetry run black .` then `poetry run ruff check .` then `poetry run pyright` then
`poetry run pytest tests/scripts/dev_tools/ --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0, 0, 0, 0

## Stage results

| Stage | Command | EXIT_CODE | Result |
| --- | --- | ---: | --- |
| 1 Format | `poetry run black .` | 0 | `361 files left unchanged` (0 reformatted) |
| 2 Lint | `poetry run ruff check .` | 0 | `All checks passed!` — 0 findings |
| 3 Type-check | `poetry run pyright` | 0 | `0 errors, 0 warnings, 0 informations` |
| 4 Test | `poetry run pytest tests/scripts/dev_tools/ --cov --cov-branch --cov-report=term-missing` | 0 | `2763 passed` |

## Toolchain loop history

One restart was required. On the first pass, stage 1 reformatted
`tests/scripts/dev_tools/test_blast_radius_config.py` (the [P3-T11] config-shape assertion). Per
the mandatory loop rule the loop restarted from stage 1; the second pass reformatted nothing and
all four stages then completed cleanly in a single pass, which is the result in the table above.
No suppression (`# noqa` or `# type: ignore`) was added at any point.

## The [P3-T1] fail-before tests now pass

```
test_classify_path_token_accepts_a_configured_separator_free_root_surface[package-lock.json] PASSED
test_classify_path_token_accepts_a_configured_separator_free_root_surface[poetry.lock] PASSED
test_classify_path_token_accepts_a_configured_separator_free_root_surface[quality-tiers.yml] PASSED
test_classify_path_token_rejects_a_bare_identifier_against_root_surfaces PASSED
test_classify_path_token_root_surface_membership_is_ordinal PASSED
test_classify_path_token_without_root_surfaces_still_rejects_a_root_surface PASSED
6 passed, 79 deselected
```

All three cases that failed at [P3-T1] with
`TypeError: classify_path_token() got an unexpected keyword argument 'root_surfaces'` now pass.

## V1/V2 self-consistency preserved without modifying those tests

`test_a_derived_radius_passes_v1_against_its_own_plan` and
`test_a_derived_radius_passes_v2_against_its_own_plan` pass for every entry of the `PLANS` table,
including the new row added by [P3-T10]:

```
test_a_derived_radius_passes_v1_against_its_own_plan[- [ ] [P1-T1] Touch `poetry.lock` and `scripts/dev_tools/alpha.py`.] PASSED
test_a_derived_radius_passes_v2_against_its_own_plan[- [ ] [P1-T1] Touch `poetry.lock` and `scripts/dev_tools/alpha.py`.] PASSED
12 passed, 42 deselected
```

Neither test body was modified. The `PLANS` table gained one entry and the existing parametrized
suites picked it up automatically, so the guard now genuinely exercises the Gap 1 path. This is
the direct evidence for the spec's `## Risks & Mitigations` item 4 (V1/V2 self-consistency
regression), the single most important regression risk of Gap 1.

## Coverage for the in-scope modules

| File | Cover | Statements | Branches |
| --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 100% | 93 | 42 |
| `scripts/dev_tools/_blast_radius_validation.py` | 100% | 118 | 46 |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 100% | 58 | 22 |
| `scripts/dev_tools/_blast_radius_glob.py` | 98% | 54 (1 miss, line 222) | 28 |
| `scripts/dev_tools/compute_blast_radius.py` | 100% | 60 | 8 |

Every Gap 1 line added in Phase 3 is covered: the two modules that gained the `root_surfaces`
plumbing (`_blast_radius_extraction.py`, `_blast_radius_validation.py`) and the module that gained
the call-site wiring (`compute_blast_radius.py`) are all at 100%.

Output Summary: All four commands exit 0. Black reformatted 0 files on the clean pass, Ruff
reported 0 findings, Pyright reported 0 errors, and pytest reported 2763 passed / 0 failed over
`tests/scripts/dev_tools/`. The three [P3-T1] tests now pass, and
`test_a_derived_radius_passes_v1_against_its_own_plan` and its V2 counterpart pass for all six
`PLANS` entries including the new separator-free-surface plan, without either test body being
modified.
