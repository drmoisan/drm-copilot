# Fail-Before / Pass-After — Ruff Configuration Alignment

Issue: #515
Module under test: `tests/scripts/dev_tools/test_ruff_config_alignment.py`
Discriminating test: `test_ruff_config_does_not_enable_fix_mode`

This artifact records both halves of the fail-before / pass-after pair in a single
file, as the spec's acceptance criterion 6 requires. The fail-before section is
written by [P1-T2]; the pass-after section is appended by [P3-T2].

---

## Fail-Before (P1-T2) — against the unmodified `pyproject.toml`

Timestamp: 2026-08-24T13-57

Task: [P1-T2] [expect-fail]

Command: `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py -v`

EXIT_CODE: 1

ExpectedExitCode: 1

Tree state at capture: `pyproject.toml` is unmodified. The `[tool.ruff]` table still
carries the fix-mode line at line 91, exactly as recorded in the P0-T7 baseline
artifact. The Phase 2 deletion has not been applied.

### Verbatim run output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
cachedir: .pytest_cache
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a046a08b20e685723
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 4 items

tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode FAILED [ 25%]
tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_retains_show_fixes PASSED [ 50%]
tests/scripts/dev_tools/test_ruff_config_alignment.py::test_no_standalone_ruff_config_at_repository_root PASSED [ 75%]
tests/scripts/dev_tools/test_ruff_config_alignment.py::test_quality_checks_workflow_still_runs_a_ruff_lint_step PASSED [100%]

================================== FAILURES ===================================
__________________ test_ruff_config_does_not_enable_fix_mode __________________

    def test_ruff_config_does_not_enable_fix_mode() -> None:
        """The ``[tool.ruff]`` table must not enable Ruff fix mode."""
        offending = [line for line in _tool_ruff_table_lines() if _FIX_ENABLED.match(line)]
>       assert offending == [], (
            "[tool.ruff] in pyproject.toml enables fix mode. The bare "
            "`poetry run ruff check` invocation then rewrites fixable violations "
            "in place and still exits 0, so the lint stage silently modifies the "
            f"working tree and reports success (issue #515). Offending: {offending}"
        )
E       AssertionError: [tool.ruff] in pyproject.toml enables fix mode. The bare `poetry run ruff check` invocation then rewrites fixable violations in place and still exits 0, so the lint stage silently modifies the working tree and reports success (issue #515). Offending: ['fix = true']
E       assert ['fix = true'] == []
E
E         Left contains one more item: 'fix = true'
E
E         Full diff:
E         - []
E         + [
E         +     'fix = true',
E         + ]

tests\scripts\dev_tools\test_ruff_config_alignment.py:70: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode
========================= 1 failed, 3 passed in 0.08s =========================
```

Output Summary: **1 failed, 3 passed** — exactly the outcome this task expects, so the
non-zero exit is the declared expectation and not a defect.

- **Failing test: `test_ruff_config_does_not_enable_fix_mode`.**
- Its assertion message, quoted verbatim:

  ```text
  AssertionError: [tool.ruff] in pyproject.toml enables fix mode. The bare `poetry run ruff check` invocation then rewrites fixable violations in place and still exits 0, so the lint stage silently modifies the working tree and reports success (issue #515). Offending: ['fix = true']
  assert ['fix = true'] == []
  ```

- The three tests that pass do so correctly against the pre-change tree, and their
  passing here is meaningful rather than incidental: `test_ruff_config_retains_show_fixes`
  confirms `show-fixes = true` is present *before* the edit, so its continued passing after
  the edit demonstrates retention rather than coincidence;
  `test_no_standalone_ruff_config_at_repository_root` and
  `test_quality_checks_workflow_still_runs_a_ruff_lint_step` assert invariants the Phase 2
  edit does not touch, so they are expected to pass in both halves of this pair.

The failure is attributable to the single configuration line this plan deletes: the
assertion message names the offending line as `'fix = true'`, which is `pyproject.toml:91`
as recorded in the P0-T7 baseline. This establishes that the test is discriminating — it
observes the defect state and reports it — rather than passing vacuously.

---

## Pass-After (P3-T2) — against the post-change `pyproject.toml`

Timestamp: 2026-08-24T14-04

Task: [P3-T2]

Pass-After Timestamp: 2026-08-24T14-04

Pass-After Command: `poetry run pytest tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode -v`

Pass-After EXIT_CODE: 0

Tree state at capture: `pyproject.toml` carries the Phase 2 deletion. The `[tool.ruff]`
table no longer has a fix-mode line; `line-length`, `target-version`, and
`show-fixes = true` are unchanged. `git diff --numstat -- pyproject.toml` reported
`0	1	pyproject.toml` at P2-T2, confirming the edit is a one-line deletion and nothing
else.

### Verbatim run output

```text
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a046a08b20e685723
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 1 item

tests/scripts/dev_tools/test_ruff_config_alignment.py::test_ruff_config_does_not_enable_fix_mode PASSED [100%]

============================== 1 passed in 0.05s ==============================
```

### Pass-after result

**Observed: 1 passed, 0 failed, 0 errors, exit code 0** for
`test_ruff_config_does_not_enable_fix_mode` — the same test that failed in the
fail-before section above.

## Pair verdict

| Half | Tree state | Command target | Result | Exit code |
| --- | --- | --- | --- | --- |
| Fail-before (P1-T2) | `fix = true` present at `pyproject.toml:91` | full module | 1 failed, 3 passed | 1 (expected 1) |
| Pass-after (P3-T2) | fix-mode line deleted | `::test_ruff_config_does_not_enable_fix_mode` | 1 passed, 0 failed, 0 errors | 0 |

The test module's own text is byte-identical between the two halves; the sole intervening
change is the single-line deletion in `pyproject.toml`. The transition from failing to
passing is therefore attributable to that deletion, which is what the fail-before /
pass-after pair exists to demonstrate. Spec acceptance criterion 6 is satisfied by this
single artifact, which carries both halves and declares the non-zero expectation on the
failing half.
