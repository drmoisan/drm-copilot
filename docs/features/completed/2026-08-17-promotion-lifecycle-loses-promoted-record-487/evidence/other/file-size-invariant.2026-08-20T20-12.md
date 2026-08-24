# File-Size Invariant [P6-T4]

Timestamp: 2026-08-20T20-12

Command: `wc -l <each modified or created production and test file>`

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2b9a9c0d25db8e3b`

EXIT_CODE: 0

Limit: **500 lines** per `.claude/rules/general-code-change.md` ("No production code, test code, or reusable script file may exceed 500 lines").

## Production Files

```
  492 extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts
  164 extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts
  206 extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts
  416 scripts/dev_tools/new_active_feature_folder_flow.py
```

| File | Lines | At or below 500 |
| --- | --- | --- |
| `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` | **492** | **Yes** |
| `extensions/drm-copilot/src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts` | 164 | Yes |
| `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 206 | Yes |
| `scripts/dev_tools/new_active_feature_folder_flow.py` | 416 | Yes |

### Explicit confirmation for `flow.ts` (INV-5, AC-10)

`extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts` is **492 lines**, which is at or below the 500-line limit. Pre-change it was 444 (P0-T9); the change added 48 lines, leaving 8 lines of headroom. Because the count fits, the P2-T1 fallback of relocating the disposition helper into `io.ts` was not required, and `io.ts` remains unmodified at 396 lines.

## Test Files

```
  500 extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts
  165 extensions/drm-copilot/test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts
  260 extensions/drm-copilot/test/lib/promotion-lifecycle-sequence.test.ts
  310 extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts
  327 extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts
  533 tests/scripts/dev_tools/test_new_active_feature_folder.py
  472 tests/scripts/dev_tools/test_new_active_feature_folder_part4.py
  122 tests/scripts/dev_tools/test_new_active_feature_folder_part5.py
```

| File | Lines | At or below 500 | Note |
| --- | --- | --- | --- |
| `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts` | **500** | **Yes** (exactly at the limit) | Was 499; P1-T3 added exactly one assertion line, as the task required. This is why P1-T1 created a sibling file instead of appending. |
| `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts` | 165 | Yes | New file (P1-T1, P1-T2, P1-T4) |
| `extensions/drm-copilot/test/lib/promotion-lifecycle-sequence.test.ts` | 260 | Yes | New file (P1-T5) |
| `extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` | 310 | Yes | Was 184; P1-T6 added the blocked-path fake and three cases |
| `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | 327 | Yes | Was 237; P1-T7 added the blocked-path fake and two cases |
| `tests/scripts/dev_tools/test_new_active_feature_folder.py` | 533 | **No — pre-existing over-limit condition, not increased** (see below) | |
| `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py` | 472 | Yes | Unchanged count; P1-T9 edited one line in place |
| `tests/scripts/dev_tools/test_new_active_feature_folder_part5.py` | 122 | Yes | New file (P4-T5, P4-T6) |

## Pre-Existing Over-Limit File

`tests/scripts/dev_tools/test_new_active_feature_folder.py`:

| Measure | Value |
| --- | --- |
| Pre-change (at merge base `cd4b887f4e56606a7aca4bd02e093829b33bf8db`) | **533** |
| Post-change | **533** |
| Delta | **0** |

The count **was not increased by P1-T8**. That task changed two lines in place — inverting `assert potential_path not in fs.files` to `assert potential_path in fs.files`, and renaming the test function — with no net line addition. The over-limit condition is pre-existing and is analogous to `scripts/dev_tools/potential_to_issue.py` (639 lines, also unmodified by this change and separately tracked). Remediating it is outside this bug's scope; the plan's requirement is that the count not be increased, which is satisfied.

This is also why P4-T5 created `test_new_active_feature_folder_part5.py` rather than appending the two new pytest cases to the already-oversized base module. The `_partN` split is the convention already in use in this directory (`_part2` 537, `_part3` 468, `_part4` 472).

## Verdict

Every modified or created production and test file is at or below 500 lines, with the single exception of `tests/scripts/dev_tools/test_new_active_feature_folder.py`, whose 533-line count is pre-existing and unchanged by this work. INV-5 and AC-10 are satisfied.
