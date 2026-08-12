# TypeScript Mutation Parity Fail-Before

Timestamp: `2026-08-10T23-53-04:00`

Status: `EXPECTED FAILURE`

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-mutation-parity.test.ts`

EXIT_CODE: `1`

Output Summary: The fail-before suite produced only the seven expected missing TypeScript mutation-invariant failures while `17/24` tests passed; the corrected shared fixture retained `18` green Python cases and no unrelated TypeScript validation error.

Test suites: `1 failed / 1 total`

Tests: `17 passed / 24 total`; `7 failed / 24 total`

## Expected mutation-only failures

The authoritative rerun returned no existing TypeScript checkpoint error for each of these seven Python-authoritative mutation decisions:

1. `missing-required-record-field` — `MUTATION_RECORD_INCOMPLETE`
2. `recompute-sequence-gap` — `MUTATION_SEQUENCE_GAP`
3. `duplicate-recompute-sequence` — `MUTATION_SEQUENCE_DUPLICATE`
4. `open-mode-mutation-after-close` — `MUTATION_AFTER_OPEN_CLOSE`
5. `close-rejected-while-item-in-flight` — `MUTATION_CLOSE_IN_FLIGHT`
6. `merged-item-removal-rejected` — `MUTATION_REMOVE_MERGED`
7. `in-flight-removal-moves-pinned-generation` — `MUTATION_PIN_GENERATION_CHANGED`

Every failing assertion received an empty TypeScript error list and expected one mutation-specific error substring. The remaining 17 assertions passed, including corpus shape, stable reason codes, exact detach/abandon confirmation tuples, all accepted decisions, and the in-flight disposition rule already present in `parallel-state-records.ts`. The non-zero exit is therefore caused only by absent TypeScript mutation invariants.

## Fixture correction before authoritative rerun

The first invocation also showed the existing cohort-membership error on three rejected scenario documents because their current-generation cohort overrides omitted the still-pinned item. The shared fixture was corrected to retain item `444` in those current-generation cohorts. The Python fixture suite then remained green (`18 passed`), Prettier remained clean, and the exact Jest command was rerun. The results above are from that corrected authoritative rerun; it contains no unrelated TypeScript validation error.

## P1-T1 fixture verification

- Shared corpus: `tests/fixtures/parallel-orchestration/mutation-parity.json`
- Python loader/authority suite: `tests/scripts/dev_tools/test_parallel_mutation_parity.py`
- TypeScript parity suite: `extensions/drm-copilot/test/lib/validate/parallel-mutation-parity.test.ts`
- Corpus cases: `16`
- Behavior classes: `8`
- Expected decisions: `7 accept`, `9 reject`
- Python result after final fixture correction: `18 passed`
- `.claude/` changed paths: `0`
