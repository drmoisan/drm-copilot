# New-Module Toolchain Precheck (P1-T3)

Timestamp: 2026-08-24T14-00

Task: [P1-T3]
Issue: #515
Module under check: `tests/scripts/dev_tools/test_ruff_config_alignment.py`

Purpose: confirm the module authored by P1-T1 is clean under the read-only Python
toolchain before Phase 2 lands, so that a format, lint, or type defect in the new
module cannot force a Phase 4 loop restart.

Commands, in the order run:

1. `poetry run black --check tests/scripts/dev_tools/test_ruff_config_alignment.py`
2. `poetry run ruff check --no-fix tests/scripts/dev_tools/test_ruff_config_alignment.py`
3. `poetry run pyright tests/scripts/dev_tools/test_ruff_config_alignment.py`

EXIT_CODE (1, black): 0
EXIT_CODE (2, ruff): 0
EXIT_CODE (3, pyright): 0

## Verbatim outputs

Black:

```text
All done! ✨ 🍰 ✨
1 file would be left unchanged.
```

Ruff:

```text
All checks passed!
```

Pyright:

```text
venv .venv subdirectory not found in venv path c:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a046a08b20e685723.
0 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.411).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```

The two pyright advisory lines are the same environment and self-update notices recorded
and dispositioned in the P0-T5 baseline artifact. Neither is a finding and neither affects
the exit code.

## Why the read-only lint form was used

At this point in the plan the Phase 2 deletion has not yet been applied, so `[tool.ruff]`
still enables fix mode and the bare `poetry run ruff check` form is a write-mode
invocation. Running the bare form here would have rewritten the module P1-T1 had just
authored, which is exactly the defect under repair. The explicit `--no-fix` form was used
so the check observed the module without altering it. The linter's explicit fix flag was
not passed.

## Recorded intermediate state: one manual formatting correction

The module as first written was not Black-clean. The first `black --check` run exited 1
with `1 file would be reformatted`. The required change was obtained read-only via
`poetry run black --diff` and applied by hand; it was a single logical-line join inside
`test_quality_checks_workflow_still_runs_a_ruff_lint_step`, joining a two-line `if`
clause of a list comprehension into one line:

```text
-        if _RUFF_LINT_INVOCATION.search(stripped)
-        and not _YAML_NAME_KEY.match(stripped)
+        if _RUFF_LINT_INVOCATION.search(stripped) and not _YAML_NAME_KEY.match(stripped)
```

The correction is whitespace-only and changes no assertion, no test name, and no
control flow. It was applied by hand rather than by invoking the write-mode formatter,
because this plan prohibits running the bare `poetry run black .` form and because the
edit is confined to a file already inside the scope lock. The three exit codes recorded
above are from the runs taken after that correction.

Post-correction re-verification of the P1-T1 acceptance condition, confirming the
formatting edit did not disturb collection:

```text
tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode
tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_retains_show_fixes
tests/scripts/dev_tools/test_ruff_config_alignment.py::test_no_standalone_ruff_config_at_repository_root
tests/scripts/dev_tools/test_ruff_config_alignment.py::test_quality_checks_workflow_still_runs_a_ruff_lint_step

4 tests collected in 0.03s
```

The correction sits below the assertion at line 70 that the P1-T2 fail-before artifact
quotes, so that artifact's recorded traceback location remains accurate.

Output Summary: **All three read-only checks exit 0 and none of the three reported a
finding.** Black reports the module would be left unchanged (0 would be reformatted),
Ruff reports `All checks passed!` (0 findings), and Pyright reports 0 errors, 0 warnings,
and 0 informations. The module is clean under formatting, linting, and type checking
before Phase 2 begins, so no defect in it can force a Phase 4 loop restart.
