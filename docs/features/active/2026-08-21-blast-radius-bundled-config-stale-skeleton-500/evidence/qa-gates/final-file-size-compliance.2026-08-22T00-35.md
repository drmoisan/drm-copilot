# Final file-size compliance (Issue #500)

Timestamp: 2026-08-22T00:35:00Z
Issue: #500
Task: [P8-T13]

Command:

```
wc -l <every code and test file this plan touched>
git status --porcelain -- tests/scripts/dev_tools/test_blast_radius_config.py
```

(working directory: worktree root)

EXIT_CODE: 0

Output Summary: every count is at or under the 500-line ceiling in
`.claude/rules/general-code-change.md`.

| File | Lines | Headroom | Baseline (P0-T4) | Delta |
| --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | 468 | 32 | 452 | +16 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | 482 | 18 | 478 | +4 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 472 | 28 | 476 | -4 |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | 434 | 66 | 401 | +33 |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 224 | 276 | 198 | +26 |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | 387 | 113 | new file | +387 |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | 172 | 328 | new file | +172 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 353 | 147 | 269 | +84 |

The tightest file is `blast-radius-derive-core.test.ts` at 482 with 18 lines of headroom.

## `test_blast_radius_config.py` is unmodified at 499 lines

`git status --porcelain -- tests/scripts/dev_tools/test_blast_radius_config.py` returned **no
output**, which confirms the file is unmodified. It measures **499** lines, unchanged from the
Phase 0 baseline, leaving 1 line of headroom.

That file could not receive the three-class key-partition gate: one added line would breach the
ceiling. The gate therefore landed in the sibling module
`tests/scripts/dev_tools/test_blast_radius_config_parity.py` per plan constraint C2, with its
constants and accessors in `tests/scripts/dev_tools/blast_radius_parity_test_support.py` per the
[P6-T13] split. The shared helpers `load_config_file`, `load_module_globs`, `COMMITTED_CONFIGS`,
`CONFIG_PATH`, `BUNDLED_CONFIG_PATH`, and `BUNDLED_CONFIG_LABEL` are imported from the 499-line
module rather than duplicated, so no logic is copied.

## Files outside the ceiling

`.claude/rules/parallel-orchestration.md` and its bundled mirror measure 34831 bytes each. Both are
Markdown documentation, which `.claude/rules/general-code-change.md` explicitly exempts from the
500-line limit.

`extensions/drm-copilot/test/repo-automation-dispatch.test.ts` was deliberately not touched. Its six
occurrences of `"C:/workspace/tests/claude-runtime"` are filesystem-path fixtures rather than the
module name, so a blanket rename would have corrupted them.
