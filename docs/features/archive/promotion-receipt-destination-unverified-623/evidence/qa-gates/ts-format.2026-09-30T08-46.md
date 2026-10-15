# TypeScript Format Gate (#623)

Timestamp: 2026-09-30T08-46
Command: git hash-object -- <six TypeScript/CJS blast-radius files>; npm --prefix extensions/drm-copilot run format; git hash-object -- <same six files>
EXIT_CODE: 0
Output Summary: Formatter exit 0. 472 per-file lines printed, all ending with `(unchanged)`. REWRITTEN_COUNT: 0. All six before/after hash pairs are identical. git status --porcelain printed nothing after the run.

REWRITTEN_COUNT: 0

## Files hashed (blast-radius rows 1, 4, 5, 6, 7, 10; row 10 included because P6-T2 recorded DECISION: ADDED)

| Path | Before | After |
| --- | --- | --- |
| extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts | 0f96b29225844031e2015cd3343766c3d071108f | 0f96b29225844031e2015cd3343766c3d071108f |
| extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts | 3f6eb2d4fb2ef3e22ec18458b0a8eab142455dab | 3f6eb2d4fb2ef3e22ec18458b0a8eab142455dab |
| extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts | 09cf222f575ae0280581250c1e6ed7f41cb68c25 | 09cf222f575ae0280581250c1e6ed7f41cb68c25 |
| extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts | 77d2a8aa2984b726fe6fe60524b538efaeb841fc | 77d2a8aa2984b726fe6fe60524b538efaeb841fc |
| extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts | 6b3da152409625203eb3d770a9be8eb47d65788e | 6b3da152409625203eb3d770a9be8eb47d65788e |
| extensions/drm-copilot/jest.config.cjs | abaf6058669d2d10af8af3c48fb4218f4503a08e | abaf6058669d2d10af8af3c48fb4218f4503a08e |

## Formatter lines for the blast-radius files (verbatim, ANSI colour codes removed)

```
src/lib/potential-to-issue/promotion.ts 12ms (unchanged)
test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts 2ms (unchanged)
test/lib/potential-to-issue/potential-to-issue-service-call.test.ts 5ms (unchanged)
test/lib/potential-to-issue/promotion-test-support.ts 4ms (unchanged)
test/lib/potential-to-issue/promotion.move-verification.test.ts 2ms (unchanged)
jest.config.cjs 5ms (unchanged)
```

Count method: the output was captured to a scratch file outside the repository; every line other than the two npm script-header lines is a per-file line (472), and `grep -c "(unchanged)"` on the capture printed 472.
