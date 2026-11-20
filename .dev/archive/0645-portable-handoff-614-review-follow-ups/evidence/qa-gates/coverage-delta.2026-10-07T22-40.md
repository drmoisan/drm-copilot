# Coverage Delta (P8-T11)

Timestamp: 2026-10-07T22-40
Task: [P8-T11]
Command: compare P0-T9 vs P7-T5 (Python), P0-T18 vs P7-T16 (PowerShell), P0-T15 vs P7-T11 (TypeScript); TypeScript changed-line coverage by intersecting the added line numbers from `git diff -U0 08ee030d9584bf15882fbb3654c8e38f34c7c359 -- extensions/drm-copilot/src` with the `DA:<line>,<hits>` records of `extensions/drm-copilot/coverage/lcov.info` (the P7-T11 report; the source hashes are unchanged since P7-T1 per P7-T17)
EXIT_CODE: 0
Output Summary: every value is present and every comparison is non-decreasing. Python line 93.67 -> 93.67 (16444 -> 16445 covered), branch 87.09 -> 87.09. PowerShell 96.38 -> 96.41. All 14 TypeScript modules at or above 85/75; the five R18 modules at or above baseline. TypeScript changed-line coverage 179/179 = 100.00%.

## (a) Python

| Metric | P0-T9 | P7-T5 | Result |
|---|---|---|---|
| Line % | 93.67 (16444/17556) | 93.67 (16445/17556) | non-decreasing |
| Branch % | 87.09 (5520/6338) | 87.09 (5520/6338) | non-decreasing |

Changed-production-line coverage: N/A: no production Python file changed (verified by P8-T6).

## (b) PowerShell

| Metric | P0-T18 | P7-T16 | Result |
|---|---|---|---|
| Report line % | 96.38 (11455/11885) | 96.41 (11458/11885) | non-decreasing |

Changed-production-line coverage: N/A: hook unchanged (verified by P8-T2).

## (c) TypeScript per-module (P0-T15 -> P7-T11)

| Module | Line % before | Line % after | Branch % before | Branch % after | R18 module | Result |
|---|---|---|---|---|---|---|
| `orchestration-handoff-authority-service.ts` | 98.41 | 98.97 | 88.41 | 90.14 | yes | >= baseline, >= 85/75 |
| `orchestration-handoff-checkout-context.ts` | 100.00 | 100.00 | 100.00 | 100.00 | no | >= 85/75 |
| `orchestration-handoff-contract-support.ts` | 100.00 | 100.00 | 100.00 | 100.00 | no | >= 85/75 |
| `orchestration-handoff-contract.ts` | 98.79 | 98.79 | 90.79 | 90.79 | no | >= 85/75 |
| `orchestration-handoff-materializer-production.ts` | 100.00 | 100.00 | 97.30 | 97.50 | yes | >= baseline, >= 85/75 |
| `orchestration-handoff-materializer-request.ts` | 100.00 | 100.00 | 100.00 | 100.00 | yes | >= baseline, >= 85/75 |
| `orchestration-handoff-materializer-support.ts` | 100.00 | 100.00 | 90.00 | 95.24 | no | >= 85/75 |
| `orchestration-handoff-materializer.ts` | 98.42 | 98.98 | 94.87 | 96.43 | yes | >= baseline, >= 85/75 |
| `orchestration-handoff-path-boundary.ts` | 97.56 | 98.64 | 81.13 | 84.75 | yes | >= baseline, >= 85/75 |
| `orchestration-handoff-provider-adapters.ts` | 99.27 | 99.27 | 95.65 | 95.65 | no | >= 85/75 |
| `orchestration-handoff-validation.ts` | 99.19 | 99.19 | 92.59 | 92.59 | no | >= 85/75 |
| `semantic-mcp-identity.ts` | 100.00 | 100.00 | 100.00 | 100.00 | no | >= 85/75 |
| `mcp-handlers/orchestration-handoff-handlers.ts` | 100.00 | 100.00 | 100.00 | 100.00 | no | >= 85/75 |
| `mcp-repo-automation-tool-definitions-handoff.ts` | 100.00 | 100.00 | no branch construct | no branch construct | no | >= 85 line |

## (d) TypeScript changed-line coverage

No new production file under `extensions/drm-copilot/src/` (P6-T2), so the diff is complete. lcov `SF:` paths matched with `\` replaced by `/` and the `extensions/drm-copilot/` prefix removed from the diff path; each file matched exactly one record.

| File | Added lines | Instrumented | Covered | Uncovered |
|---|---|---|---|---|
| `src/lib/validate/orchestration-handoff-authority-service.ts` | 24 | 24 | 24 | none |
| `src/lib/validate/orchestration-handoff-materializer-production.ts` | 5 | 5 | 5 | none |
| `src/lib/validate/orchestration-handoff-materializer-request.ts` | 38 | 38 | 38 | none |
| `src/lib/validate/orchestration-handoff-materializer.ts` | 73 | 73 | 73 | none |
| `src/lib/validate/orchestration-handoff-path-boundary.ts` | 30 | 30 | 30 | none |
| `src/mcp-handlers/orchestration-handoff-handlers.ts` | 6 | 6 | 6 | none |
| `src/mcp-repo-automation-tool-definitions-handoff.ts` | 2 | 2 | 2 | none |
| `src/mcp-tools.ts` | 1 | 1 | 1 | none |
| Total | 179 | 179 | 179 | 100.00% (>= 85%) |

Result: PASS
