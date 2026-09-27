# Bug: collector-core-no-whichgh-branch-untested

- Issue: #714
- Type: bug
- Work Mode: full-bug
- Source: GitHub issue #714 (label: bug). The issue body carried `- Work Mode: minor-audit`; the orchestration kickoff for parallel run `followups-2026-09-27` selected `full-bug`, which is the persisted mode.

## Summary
After issue #588 (PR #704), no test calls `collectPrContext` without a `whichGh` resolver. The `whichGh === undefined` arm in `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` (the `GhClient` construction inside `collectPrContext`) is no longer exercised, and branch coverage of that file fell from 91.22% to 89.28% with no diff to the file.

## Environment
- OS/version: any
- Python version: n/a (TypeScript, Jest)
- Command/flags used: Jest with coverage for `extensions/drm-copilot`
- Data source or fixture: `collector-core.test.ts`

## Steps to Reproduce
1. Run Jest with coverage on `extensions/drm-copilot`.
2. Inspect `collector-core.ts`: `BRDA:135,2,0,0` is uncovered.

## Expected Behavior
Both arms of `...(whichGh === undefined ? {} : { whichGh })` are covered.

## Actual Behavior
The service-call tests that used to omit `whichGh` now inject it, so the default-resolver arm has no test.

## Logs / Screenshots
- Snippet: #588 `code-review.2026-09-26T21-37.md` CR-1; `evidence/qa-gates/ts-coverage-delta.2026-09-25T22-06.md`.

## Impact / Severity
- Low

## Acceptance Criteria
- [ ] A Jest test calls `collectPrContext` with no `whichGh` option, so the `whichGh === undefined` arm of the `GhClient` construction in `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` is executed.
- [ ] Both arms of the `whichGh === undefined ? {} : { whichGh }` conditional are reported covered in the Jest coverage output for `collector-core.ts`.
- [ ] Branch coverage of `collector-core.ts` is restored to at least the pre-#588 value of 91.22%, and line coverage does not regress.
- [ ] The new test is deterministic: it spawns no real `gh` process, touches no real filesystem, and does not depend on the host PATH, on origin/main, or on gitignored state.
- [ ] The full TypeScript toolchain (format, lint, type-check, test with coverage) passes.

## Source
From: docs/features/potential/2026-09-26-collector-core-no-whichgh-branch-untested.md (lifecycle record held on another branch; not present on this branch).
