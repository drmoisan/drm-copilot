# TypeScript Declaration Move (Remediation Cycle 3)

Timestamp: 2026-10-16T07-23
Task: [P3-T1]
Command: poetry run python SCRATCH/stage/move_whitespace_class.py typescript
EXIT_CODE: 0
Output Summary: `TYPESCRIPT_DECLARATIONS: scratch=0 commands=1`. No `ANCHOR_NOT_FOUND:` line.

Effect: the TSDoc block, the `export const PLAN_WHITESPACE_CLASS` line, the blank line after it, and the `WHITESPACE_RUN_RE` line (formerly lines 67-79 of `plan-gate-scratch.ts`) were removed; the new TSDoc, the same declaration line verbatim, `PLAN_WHITESPACE_RUN_RE`, and `normalizePlanWhitespace` were inserted after `splitPlanLines` in `plan-gate-commands.ts` (declaration at line 288, function at line 302).

Grep tool counts on `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts` (output mode `count`):

| Pattern | Count |
| --- | --- |
| `^export const PLAN_WHITESPACE_CLASS = String\.raw` | 1 |
| `^export function normalizePlanWhitespace\(` | 1 |
| raw-character pattern from Conventions | 0 |
| line count `^` | 474 (444 before; at most 500) |
