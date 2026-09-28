# Phase 0 — Ruff Configuration State Baseline (P0-T7)

Timestamp: 2026-08-24T13-53

Task: [P0-T7]
Issue: #515

Command: `git ls-files -- pyproject.toml tests/scripts/dev_tools/test_ruff_config_alignment.py`

EXIT_CODE: 0

## Verbatim command output

```text
pyproject.toml
```

## Tracked-state findings

- **`pyproject.toml` is tracked.** It is the sole path returned by the command, confirming it is a tracked file in this worktree's index and that the Phase 2 edit will register as a modification to an existing tracked file rather than as a new-file addition.
- **`tests/scripts/dev_tools/test_ruff_config_alignment.py` is NOT listed.** `git ls-files` returns only tracked paths, so its absence from the output confirms the module does not yet exist in the index. This is the required pre-state for P1-T1, which creates it, and it establishes that the module will appear in the P5-T1 union as an untracked addition rather than as a modification.

## Verbatim `[tool.ruff]` table, `pyproject.toml` lines 88-92

```toml
[tool.ruff]
line-length = 88
target-version = "py310"
fix = true
show-fixes = true
```

Line-by-line, at the exact line numbers the plan and spec cite:

| Line | Content | Disposition under this plan |
| --- | --- | --- |
| 88 | `[tool.ruff]` | unchanged (table header) |
| 89 | `line-length = 88` | unchanged |
| 90 | `target-version = "py310"` | unchanged |
| 91 | `fix = true` | **the fix-mode line; deleted by P2-T1** |
| 92 | `show-fixes = true` | **retained**, asserted by `test_ruff_config_retains_show_fixes` |

The fix-mode line is present at line 91 exactly as the spec's Context section states, and `show-fixes = true` is present at line 92. The observed state matches the spec's recorded state at commit `bee15c06` and is unchanged as of baseline commit `626743739843c0672d434de73fdd57a5a95cd8bb`.

Immediately following context, recorded so the single-line-deletion scope of P2-T1 is unambiguous: line 93 is blank and line 94 opens the separate `[tool.ruff.lint]` table. The deletion of line 91 therefore removes one key from `[tool.ruff]` and touches no other table. The rule selection at lines 94-104 and the per-file ignores at lines 106-112 are outside the edit.

Output Summary: **`pyproject.toml` is tracked; `tests/scripts/dev_tools/test_ruff_config_alignment.py` is not listed and therefore does not yet exist as a tracked file.** The `[tool.ruff]` table occupies lines 88-92 and reads exactly `[tool.ruff]` / `line-length = 88` / `target-version = "py310"` / `fix = true` / `show-fixes = true`, with the fix-mode line at line 91 and `show-fixes = true` at line 92, confirming the defect state the plan is written against.
