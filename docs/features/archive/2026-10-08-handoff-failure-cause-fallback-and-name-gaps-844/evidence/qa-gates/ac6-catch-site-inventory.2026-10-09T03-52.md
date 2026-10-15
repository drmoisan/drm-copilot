# AC-6 Catch-Site Inventory (P6-T1)

Timestamp: 2026-10-09T03-52
Task: [P6-T1]
Command: Grep tool over extensions/drm-copilot/src/lib/validate/orchestration-handoff-{authority-service,materializer,materializer-production,materializer-request}.ts with line numbers: primary pattern `catch \(`; cross-check pattern `\bcatch\b`; cause-source pattern `failureCause|describeHandoffFailureCause|describeEnvelopeParseFailure`
EXIT_CODE: 0

SearchScope: the four in-scope production modules listed above
SearchPatterns: `catch \(` (primary); `\bcatch\b` (cross-check)
SearchResult: both strategies returned the same 16 file:line members.

| Module | Primary `catch \(` | Cross-check `\bcatch\b` |
| --- | --- | --- |
| orchestration-handoff-authority-service.ts | 142, 152, 177 (3) | 142, 152, 177 (3) |
| orchestration-handoff-materializer.ts | 168, 183, 284, 315, 369, 379, 403, 413, 445, 457, 490 (11) | identical (11) |
| orchestration-handoff-materializer-production.ts | 33, 49 (2) | 33, 49 (2) |
| orchestration-handoff-materializer-request.ts | none (0) | none (0) |
| Total | 16 | 16 |

## Per-site classification

| # | Site | Stage | Classification | failureCause source |
| --- | --- | --- | --- | --- |
| 1 | authority-service.ts:142 | envelope-read | returns a blocked result | line 144 `describeHandoffFailureCause("envelope-read", error)` |
| 2 | authority-service.ts:152 | envelope-parse | returns a blocked result | line 153 `describeEnvelopeParseFailure(error)`, line 155 `failureCause: failure.failureCause` |
| 3 | authority-service.ts:177 | plan-read | feeds a blocked result | line 178 `describeHandoffFailureCause("plan-read", error)`; consumer lines 338-341 forward `planObservation.failureCause` |
| 4 | materializer.ts:168 | checkpoint-read | returns a blocked result | line 170 |
| 5 | materializer.ts:183 | envelope-decode | returns a blocked result | line 185 |
| 6 | materializer.ts:284 | destination-projection | returns a blocked result | line 293 `describeHandoffFailureCause("destination-projection", error)` (new; both failure-code arms of the ternary carry it) |
| 7 | materializer.ts:315 | git-status | returns a blocked result | line 319 |
| 8 | materializer.ts:369 | archive-write | feeds a blocked result | line 370 `writeCause`; used at line 384 (readback-failure arm) and line 392 (hash-mismatch arm) |
| 9 | materializer.ts:379 | archive-readback | returns a blocked result | line 384 |
| 10 | materializer.ts:403 | candidate-write | feeds a blocked result | line 404 `writeCause`; used at line 418 and line 426 |
| 11 | materializer.ts:413 | candidate-readback | returns a blocked result | line 418 |
| 12 | materializer.ts:445 | candidate-validate | returns a blocked result (via `discardedCandidateResult`) | line 449; consumer line 478 |
| 13 | materializer.ts:457 | candidate-replace | returns a blocked result (via `discardedCandidateResult`) | line 461; consumer line 478 |
| 14 | materializer.ts:490 | candidate-cleanup | feeds a blocked result | line 491; appended by consumer line 478 |
| 15 | materializer-production.ts:33 | envelope-parse (production `validateEnvelope`) | feeds a blocked result | line 34 `describeEnvelopeParseFailure(error)`, line 40 `failureCause: failure.failureCause`; forwarded by materializer.ts line 200 `failureCause: validation.failureCause` |
| 16 | materializer-production.ts:49 | destination-projection JSON.parse (`validateDestinationProjection`) | returns a message array | line 51 embeds `describeHandoffFailureCause("destination-projection", error)` in the message; the consumer at materializer.ts line 307 attaches `destination-projection: invalid` (and the candidate-validate consumer at line 449 attaches `candidate-validate: HANDOFF_CANDIDATE_MISMATCH`) |

## Result

- Sites that return or feed a blocked result: 15 (sites 1-15). Each supplies a `failureCause` on every arm that produces a blocked result, including the authority envelope-parse site (`describeEnvelopeParseFailure`), the production `validateEnvelope` site (`failureCause: failure.failureCause`, forwarded by `failureCause: validation.failureCause`), and the materializer projection site (`destination-projection`).
- Sites that return a message array: 1 (site 16), whose consumer attaches `destination-projection: invalid`.
- Blocked-result sites lacking a cause: 0.

Output Summary: Pass (AC-6). Both search strategies return 16 identical sites (authority-service 3, materializer 11, materializer-production 2, materializer-request 0). All 15 blocked-result sites carry a failureCause; the remaining site returns a message array whose consumer attaches `destination-projection: invalid`. Count of blocked-result sites lacking a cause: 0.
