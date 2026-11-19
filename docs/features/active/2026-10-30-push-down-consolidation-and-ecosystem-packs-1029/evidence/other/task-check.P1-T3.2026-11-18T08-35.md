# Task Check P1-T3

Timestamp: 2026-11-18T08-35
Command: npx prettier --write/--check <changed files>; npx eslint <changed .ts files>; npx tsc -p ./ --noEmit; npx tsc -p tsconfig.jest.json --noEmit; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down
EXIT_CODE: 0
Output Summary: Static checks exit 0. Jest selection: 603 passed, including `skips a write whose LF-normalized text is unchanged` with a CRLF-identical target.

## Changed files

- `extensions/drm-copilot/src/lib/push-down/push-down-write-if-changed.ts`
- `extensions/drm-copilot/test/lib/push-down/push-down-write-if-changed.test.ts`
- `extensions/drm-copilot/jest.push-down-coverage.json`

## Test selection

- Selection: test/lib/push-down
- Rule: mirrored test of the new module plus tests that import it

## Commands

| Command | Exit code |
| --- | --- |
| `npx prettier --write/--check <changed files>` | 0 |
| `npx eslint <changed .ts files>` | 0 |
| `npx tsc -p ./ --noEmit; npx tsc -p tsconfig.jest.json --noEmit` | 0 |
| `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down` | 0 |
