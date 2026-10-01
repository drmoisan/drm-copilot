# TypeScript Module Size and Split Decision (P4-T4)

Timestamp: 2026-10-01T22-08
Task: P4-T4
Command: (from extensions/drm-copilot) npx prettier --write src/lib/validate/orchestrator-state-remediation.ts; git status --porcelain -- extensions/drm-copilot/src; wc -l src/lib/validate/orchestrator-state-remediation.ts
EXIT_CODE: 0

## Pass 1 (before the split)

```
src/lib/validate/orchestrator-state-remediation.ts 75ms
```

Prettier rewrote the file (no `(unchanged)` marker). A second `npx prettier --write` printed `src/lib/validate/orchestrator-state-remediation.ts 57ms (unchanged)`.

```
455 src/lib/validate/orchestrator-state-remediation.ts
```

455 is above 450, so the split branch of P4-T4 applies.

## Split applied

- Moved the review-outcome checks (R8a, R8b, R9a-R9d, R10 as `validateReviewOutcome` and the exported `validateReviewOutcomes`), `deriveReviewVerdict`, and the vocabulary it needs (`REVIEW_OUTCOMES_KEY`, `type ReviewVerdict`, `REVIEW_VERDICTS`, `REMEDIABILITY_CLASSES`, `NON_REMEDIABLE_CLASSES`, `HALT_CLASSES`, and the file-local `str()`-semantics renderer) into `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation-accounting.ts`.
- `orchestrator-state-remediation.ts` re-exports `HALT_CLASSES`, `NON_REMEDIABLE_CLASSES`, `REMEDIABILITY_CLASSES`, `REVIEW_OUTCOMES_KEY`, `REVIEW_VERDICTS`, `deriveReviewVerdict`, and `type ReviewVerdict`, and keeps the per-cycle checks, the accounting checks (R5, R6, R7a, R7b, R11), `COMPLETED_ATTEMPTS_KEY`, `CANDIDATE_APPLIED_KEY`, `OPENED_BY_REVIEW_KEY`, and `validateRemediationLoop`.
- `extensions/drm-copilot/jest.config.cjs` gained the key `"./src/lib/validate/orchestrator-state-remediation-accounting.ts"` (`lines: 85`, `branches: 75`) directly after the P4-T3 key, with a one-line issue #484 comment.

## Pass 2 (after the split)

Command: (from extensions/drm-copilot) npx prettier --write src/lib/validate/orchestrator-state-remediation.ts src/lib/validate/orchestrator-state-remediation-accounting.ts jest.config.cjs (run twice); git status --porcelain -- extensions/drm-copilot/src extensions/drm-copilot/jest.config.cjs; wc -l on both modules

```
src/lib/validate/orchestrator-state-remediation.ts 49ms (unchanged)
src/lib/validate/orchestrator-state-remediation-accounting.ts 11ms (unchanged)
jest.config.cjs 22ms (unchanged)
 M extensions/drm-copilot/jest.config.cjs
 M extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts
?? extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation-accounting.ts
  283 src/lib/validate/orchestrator-state-remediation.ts
  221 src/lib/validate/orchestrator-state-remediation-accounting.ts
```

(the first pass-2 prettier run rewrote both modules; the second printed `(unchanged)` for all three files, shown above)

Output Summary: The pre-split module measured 455 lines after formatting (above 450). After the split both counts are at or below 450: `orchestrator-state-remediation.ts` 283, `orchestrator-state-remediation-accounting.ts` 221. Supporting checks on the final text: `npx eslint` on both modules exit 0 with no output; `npm run typecheck` exit 0 with no `error TS` line.

Split: applied
