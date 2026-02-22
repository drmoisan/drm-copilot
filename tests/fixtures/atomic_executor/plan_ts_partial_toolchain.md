# Test Plan with Partial TypeScript Toolchain Phase

## Phase 0 — Context
- [ ] [P0-T1] Read some context

## Phase 3 — Unit Test Pass (not a toolchain loop)
- [ ] [P3-T1] Run `npm run test:unit` for TypeScript unit tests

## Phase 5 — QA Toolchain Loop
- [ ] [P5-T1] Run `npm run format` and restart the loop if files change.
- [ ] [P5-T2] Run `npm run lint` and restart the loop if it fails.
- [ ] [P5-T3] Run `npm run typecheck` and restart the loop if it fails.
- [ ] [P5-T4] Run `npm run test:unit` and restart the loop if it fails.
