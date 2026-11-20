# Post-Fix — Python `new_active_feature_folder` Cluster (Pytest) [P4-T8]

Timestamp: 2026-08-20T19-52

Command: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py tests/scripts/dev_tools/test_new_active_feature_folder_part2.py tests/scripts/dev_tools/test_new_active_feature_folder_part3.py tests/scripts/dev_tools/test_new_active_feature_folder_part4.py tests/scripts/dev_tools/test_new_active_feature_folder_part5.py --no-cov`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

EXIT_CODE: 0

The exit code was captured directly from the command process with no pipe.

## Result Header

```
tests\scripts\dev_tools\test_new_active_feature_folder_part4.py ........ [ 93%]
..                                                                       [ 96%]
tests\scripts\dev_tools\test_new_active_feature_folder_part5.py ..       [100%]

============================= 59 passed in 0.28s ==============================
```

## Output Summary

**59 passed, 0 failed.** The Phase 4 Python mirror is verified.

### The inverted assertions from P1-T8 and P1-T9 now pass

| Task | File | Test | Before | After |
| --- | --- | --- | --- | --- |
| P1-T8 | `tests/scripts/dev_tools/test_new_active_feature_folder.py` | `test_create_feature_folder_retains_promoted_potential_and_updates_files` (renamed from `test_create_feature_folder_moves_potential_and_updates_files`) | FAIL on `assert potential_path in fs.files` | **PASS** |
| P1-T9 | `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py` | `test_create_active_folder_auto_resolve_feature_name_from_promoted_active_file` | FAIL on `assert active_file in fs.files` | **PASS** |

Both sources are seeded under `docs/features/potential/promoted/`, so both now take the copy branch and the promoted record is retained.

### The unpromoted-seeded suites in `_part2.py` and `_part3.py` are unaffected

Both files pass unmodified — neither was edited by this change and neither reports a failure. Their potential files are seeded directly under `docs/features/potential/`, so they continue to take the move branch, which is unchanged behavior. This is the practical demonstration of INV-2: the fix narrows what is retained to promoted sources only and does not alter the move path.

### New coverage added by P4-T5 and P4-T6

`tests/scripts/dev_tools/test_new_active_feature_folder_part5.py` contributes both arms of the new branch, and both pass:

| Task | Test | Asserts |
| --- | --- | --- |
| P4-T5 | `test_create_feature_folder_moves_unpromoted_potential` | Source under `docs/features/potential/` IS removed after the call, `issue.md` is written, and stdout carries `Moved potential file to <path>`. Preserves move-branch coverage after the P1-T8 inversion (INV-2). |
| P4-T6 | `test_create_feature_folder_copies_promoted_potential` | Source under `docs/features/potential/promoted/` is retained with byte-unchanged content, `issue.md` is written, and stdout carries `Copied potential file to <path>`. |

The emitted-line wording is therefore covered in both arms on the Python side, byte-matching the TypeScript wording chosen in P2-T4.

## Scope Verification (P4-T7)

- `scripts/dev_tools/potential_to_issue.py` is **unmodified**: `git diff --stat` on that path returns no output. Its line count is 639, unchanged; that over-limit condition is pre-existing and separately tracked, and this change neither touches nor worsens it.
- `scripts/dev_tools/new_active_feature_folder_io.py` is **unmodified**: `git diff --stat` on that path returns no output. `find_potential_file` (`:35-55`) retains its two-directory scan order (`potential` then `potential/promoted`), its `_`-to-`-` normalization, its `.md` suffix filter, its `EXCLUDED_POTENTIAL_NAMES` exclusion set, and its name-descending tie-break (`sorted(..., key=name, reverse=True)[0]`). This is the Python side of INV-1.
