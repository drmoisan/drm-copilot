# Coverage Delta and Changed-Line Coverage (P6-T6)

Timestamp: 2026-10-09T03-58
Task: [P6-T6]
Working directory: worktree root
Command: git diff -U0 origin/main -- extensions/drm-copilot/src/lib/validate; then intersect added line numbers with `DA:<line>,<hits>` records in extensions/drm-copilot/coverage/lcov.info (from the P5-T6 run; `SF:` keys with `\` replaced by `/`, diff paths with the `extensions/drm-copilot/` prefix removed)
EXIT_CODE: 0

Baseline source: evidence/baseline/ts-jest-coverage.2026-10-09T03-02.md (P0-T9)
Post-change source: evidence/qa-gates/ts-jest-coverage.2026-10-09T03-47.md (P5-T6)

## Module coverage: baseline, post-change, delta

| Module | Lines baseline | Lines post | Lines delta | Branches baseline | Branches post | Branches delta | >= 85 / >= 75 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| src/lib/validate/orchestration-handoff-authority-service.ts | 98.97 (386/390) | 98.97 (386/390) | +0.00 | 90.14 (64/71) | 91.55 (65/71) | +1.41 | yes |
| src/lib/validate/orchestration-handoff-materializer.ts | 98.98 (483/488) | 98.99 (489/494) | +0.01 | 96.43 (81/84) | 97.73 (86/88) | +1.30 | yes |
| src/lib/validate/orchestration-handoff-materializer-production.ts | 100.00 (139/139) | 100.00 (138/138) | +0.00 | 97.50 (39/40) | 100.00 (39/39) | +2.50 | yes |
| src/lib/validate/orchestration-handoff-materializer-request.ts | 100.00 (122/122) | 100.00 (155/155) | +0.00 | 100.00 (26/26) | 100.00 (31/31) | +0.00 | yes |

Repository totals: Lines 97.16% -> 97.16%; Branches 91.66% -> 91.7%.

## Changed-line coverage (added lines with a DA record)

| Module | Added lines | With DA | Covered | Uncovered lines |
| --- | --- | --- | --- | --- |
| src/lib/validate/orchestration-handoff-authority-service.ts | 8 | 8 | 8/8 | none |
| src/lib/validate/orchestration-handoff-materializer.ts | 6 | 6 | 6/6 | none |
| src/lib/validate/orchestration-handoff-materializer-production.ts | 8 | 8 | 8/8 | none |
| src/lib/validate/orchestration-handoff-materializer-request.ts | 36 | 36 | 36/36 | none |
| Total | 58 | 58 | 58/58 | none |

DA hit counts for added lines (line:hits):

- authority-service: 24:1 25:1 26:1 27:1 153:2 154:2 155:2 156:2
- materializer: 71:1 200:2 293:3 294:3 295:3 296:3
- materializer-production: 6:1 12:1 13:1 14:1 15:1 34:2 37:2 40:2
- materializer-request: 8:1 21:1 22:1 23:1 28:1 29:1 30:1 49:32 50:32 51:32 56:1 57:1 58:1 59:1 60:1 61:1 62:1 63:1 64:1 65:1 66:1 67:1 68:7 69:7 70:7 71:7 72:7 73:7 74:7 75:7 76:7 77:7 78:7 79:7 80:1 115:61

Output Summary: Pass (AC-17). No module regressed in line or branch coverage; branch coverage rose in three modules. Every module is at or above 85% lines and 75% branches. Changed-line coverage is 58/58 added lines with a DA record covered (hit count > 0). No value is missing.
