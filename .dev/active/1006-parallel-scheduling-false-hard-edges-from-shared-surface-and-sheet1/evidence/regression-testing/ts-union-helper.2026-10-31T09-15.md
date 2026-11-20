# TypeScript Union Helper Regression (Remediation Cycle 1, Issue #1006, RC1-UNION)

Timestamp: 2026-10-31T09-15
Command: node run-jest.cjs test/lib/push-down/claude-blast-radius-overlay.test.ts test/lib/push-down/claude-blast-radius-overlay-parity.test.ts test/lib/push-down/claude-blast-radius-overlay-demote.test.ts --coverage=false --json --outputFile=SCRATCH/issue-1006-tstests.json (in extensions/drm-copilot, via SCRATCH/issue-1006-tstests.sh)
EXIT_CODE: 0
Output Summary: Test Suites 3 passed of 3; Tests 71 passed of 71; 0 failures. Every test named in P1-T1 and P1-T2 passed. git diff --name-only HEAD and git status --porcelain list only the two production files; no TS_TESTS file is changed.

## Change under test

- `unionStrings` is now defined and exported once, in `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts`; `applySharedSurfaceDemotion` calls it for the append-only target list.
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` no longer defines `unionStrings` and imports it from `./claude-blast-radius-overlay-demote`.

## Named tests (status from the Jest JSON result)

claude-blast-radius-overlay-demote.test.ts:
- passed | moves the entry and keeps the remaining order
- passed | treats an already append-only entry as a no-op
- passed | yields identical output when a composed result is composed again
- passed | does not mutate the composed input
- passed | demotes quality-tiers.yml with tolerance 5000 on push (issue #1006 AC-04)

claude-blast-radius-overlay.test.ts:
- passed | issue #508 AC02 additive keys (10 of 10 tests in the block)
- passed | issue #508 AC04 nested and scalar keys > merges conflict_tolerance recursively (and the 2 sibling tests in the block)
- passed | issue #508 AC18 properties > idempotence: composing twice equals composing once
- passed | issue #508 AC18 properties > superset: every base list entry survives
- passed | issue #508 AC18 properties > overlay inclusion: every overlay list entry and module appears

claude-blast-radius-overlay-parity.test.ts, `composes %s to its expected text` (all 9 corpus rows passed), including:
- passed | composes shared-surfaces-demote.json to its expected text
- passed | composes shared-surfaces-demote-already-append-only.json to its expected text
- passed | composes shared-surfaces-demote-unknown-entry.json to its expected text

## Tree check

`git diff --name-only HEAD`:
```
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts
extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts
```
`git status --porcelain`:
```
 M extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts
 M extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts
```
No TS_TESTS file appears in either listing.
