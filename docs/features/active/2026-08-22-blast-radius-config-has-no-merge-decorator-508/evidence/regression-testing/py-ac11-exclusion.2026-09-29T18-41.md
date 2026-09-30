# Python AC11 Exclusion Gate (P4-T4)

Timestamp: 2026-09-29T18-41
Command: poetry run pytest -rA tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py -k ac11
Command actually executed: the same command with `-p no:cacheprovider` appended, output filtered with `grep -E "PASSED|FAILED|passed|failed|deselected|^E  "` (exit code taken from pytest via PIPESTATUS).
EXIT_CODE: 0
Output Summary:
- `collected 2 items / 1 deselected / 1 selected`
- `PASSED tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py::test_ac11_source_side_overlay_is_not_published`
- `1 passed, 1 deselected in 0.08s`
- Pre-check: `poetry run python -c "import scripts.dev_tools.push_down_claude_customizations as m; from pathlib import Path; print(Path('config/blast-radius.local.json') in m.EXCLUDED_RELATIVE_PATHS)"` printed `True`.
- P1-T5 was Outcome A (AC11_FAIL_BEFORE: published from CONFIG_PUBLISH_ROOT); with SOURCE_ROOT_EQUALS_REPO_ROOT = yes, the exclusion resolved against repo_root matches the path the #507 config enumeration reports. No BLOCKED condition.
