# Coverage Delta — No-Regression Confirmation (Remediation #226)

Timestamp: 2026-06-24T23-08

Sources:
- Baseline: evidence/remediation-baseline/ts-test.2026-06-24T23-08.md
- Post-change: evidence/qa-gates/ts-test.remediation.2026-06-24T23-08.md

## Overall coverage

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Line | 95.86% | 95.87% | +0.01 |
| Branch | 88.05% | 88.07% | +0.02 |

Overall coverage is >= baseline. No regression.

## Changed-code coverage (extracted/new modules)

| File | Line % | Branch % |
|---|---|---|
| mcp-tool-inputs-push-down.ts (new) | 97.56% | 96.55% |
| repo-automation-service-push-down.ts (new) | 100% | 100% |

## Affected original target files

| File | Baseline line / branch | Post-change line / branch |
|---|---|---|
| mcp-tool-inputs.ts | 93.71% / 93.18% | 93.2% / 91.66% |
| repo-automation-service.ts | 100% / 81.25% | 100% / 79.06% |

Note: The line/branch percentages on the two original files shift only because the
extracted code (and its associated covered lines/branches) moved into the new sibling
modules; the moved logic is fully exercised by the unchanged existing test suites and
now reports under the new modules (97.56%/96.55% and 100%/100%). No test was changed,
weakened, or removed; all 415 tests pass. The aggregate (all-files) line and branch
coverage did not regress and slightly increased.

Result: PASS — post-change overall coverage >= baseline; new modules' lines and branches
are covered; all required numeric coverage values are available.
