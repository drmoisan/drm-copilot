# File Size and Raw-Character Baseline (Remediation Cycle 3)

Timestamp: 2026-10-16T06-21
Task: [P0-T15]

Method: Grep tool, pattern `^`, output mode `count`, per file (line count); Grep tool, output mode `count`, with the Conventions raw-character pattern `[\x0b\x0c\x1c-\x1f\x{85}\x{a0}\x{1680}\x{2000}-\x{200a}\x{2028}\x{2029}\x{202f}\x{205f}\x{3000}\x{feff}]` (raw-character count). The raw-character searches used the same paths and globs as the `^` searches, which matched all ten files, so a zero count is not an unmatched-glob artifact.

| File | Line count | Planning-time value | Raw-character count |
| --- | --- | --- | --- |
| `scripts/dev_tools/plan_gate_commands.py` | 403 | 403 | 0 |
| `scripts/dev_tools/plan_gate_scratch.py` | 217 | 217 | 0 |
| `scripts/dev_tools/plan_gate_discrimination.py` | 398 | 398 | 0 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` | 444 | 444 | 0 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts` | 226 | 226 | 0 |
| `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts` | 437 | 437 | 0 |
| `tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py` | 150 | 150 | 0 |
| `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py` | 387 | 387 | 0 |
| `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` | 189 | 189 | 0 |
| `extensions/drm-copilot/test/lib/validate/plan-gate-discrimination-literals.test.ts` | 314 | 314 | 0 |

Every line count equals the planning-time value; every raw-character count is 0.
