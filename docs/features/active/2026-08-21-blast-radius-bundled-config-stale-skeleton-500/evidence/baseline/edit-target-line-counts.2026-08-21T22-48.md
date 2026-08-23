# Baseline line counts for every file this plan edits (Issue #500)

Timestamp: 2026-08-21T22:48:53Z
Issue: #500
Task: [P0-T4]

Command:
```
wc -l <each path below>
```

EXIT_CODE: 0

Output Summary: measured counts and headroom against the 500-line ceiling in
`.claude/rules/general-code-change.md`.

| File | Lines | Headroom to 500 |
| --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | 452 | 48 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | 478 | 22 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 476 | 24 |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | 401 | 99 |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | 198 | 302 |
| `tests/scripts/dev_tools/test_blast_radius_config.py` | 499 | 1 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 269 | 231 |

Every count matches the figure recorded in plan constraint C2. `test_blast_radius_config.py` at 499
of a permitted 500 lines confirms that the three-class key-partition gate cannot land in that file;
per C2 it lands in the new sibling module `tests/scripts/dev_tools/test_blast_radius_config_parity.py`.
