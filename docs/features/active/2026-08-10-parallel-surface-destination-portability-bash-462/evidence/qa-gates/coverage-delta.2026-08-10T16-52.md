# Coverage Delta — Baseline vs Final, All Three Languages

Timestamp: 2026-08-10T16-52

Task: [P7-T11]
Command: (comparison of the recorded baseline and final artifacts; no new command executed)
EXIT_CODE: 0

Sources compared:

| Language | Baseline artifact | Final artifact |
| --- | --- | --- |
| Python | `evidence/baseline/python-baseline.2026-08-10T14-57.md` ([P0-T3]) | `evidence/qa-gates/final-python-test.2026-08-10T16-39.md` ([P7-T4]) |
| TypeScript | `evidence/baseline/typescript-baseline.2026-08-10T14-57.md` ([P0-T4]) | `evidence/qa-gates/final-ts-test.2026-08-10T16-45.md` ([P7-T9]) |
| Shell | `evidence/baseline/shell-baseline.2026-08-10T15-05.md` ([P0-T5]) | `evidence/qa-gates/final-shell-gate.2026-08-10T16-50.md` ([P7-T10]) |

## Output Summary

### Python

| Metric | Baseline | Final | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line coverage | 92.30% | 92.30% | 0.00 | >= 85% | PASS |
| Branch coverage | 89.46% | 89.48% | +0.02 | >= 75% | PASS |
| Tests passed | 3665 | 3774 | +109 | — | — |
| Statements | 14396 | 14396 | 0 | — | — |

Line coverage is flat because this feature added no Python production code; the Python side is
test-only (two parity suites). Branch coverage rose fractionally because one previously partial
branch in the shared corpus code path is now fully exercised.

### TypeScript

| Metric | Baseline | Final | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line coverage | 96.55% | 96.57% | +0.02 | >= 85% | PASS |
| Branch coverage | 89.86% | 89.90% | +0.04 | >= 75% | PASS |
| Function coverage | 90.09% | 90.15% | +0.06 | — | — |
| Tests passed | 2472 | 2495 | +23 | — | — |
| Statements | 42072 | 42412 | +340 | — | — |

Both gate metrics improved while 340 statements of production code were added
(`claude-routing-merge.ts` plus the entry-point wiring), so the new code is covered at a rate
above the existing average. Baseline and final used the same extension-scoped lane
(`npm --prefix extensions/drm-copilot run test:coverage`), so the two figures compare one
coverage universe.

### Shell

| Metric | Baseline | Final | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line coverage | 91.5% | 92.4% | +0.9 | >= 85% | PASS |
| bats tests | 102 | 245 | +143 | — | — |
| Branch coverage | not measurable | not measurable | — | no gate | n/a |

kcov reports line coverage only; `.claude/rules/shell.md` records that branch coverage is not
measurable for bash and that there is no bash branch-coverage gate. Both values are read from the
printed `Bash coverage (lines): NN.N%` log line, because the workflow has no coverage-threshold
gate and a low-coverage run would still conclude `success`.

The +143 bats tests are this feature's nine new suites plus one case added to the existing
discovery suite. The +0.9 point rise is notable given that the kcov include pattern was widened in
[P1-T2] to add `.claude/lib/bash` — 2,043 lines of new shell entered the denominator, and coverage
still improved, so the new library is covered above the pre-existing average.

## No Regression on Changed Lines

- **Python:** no production line changed, so no changed line can have regressed.
- **TypeScript:** the two changed/added production files are
  `src/lib/push-down/claude-customizations.ts` (constant plus decorator wiring) and
  `src/lib/push-down/claude-routing-merge.ts` (new). Both are exercised by the 15 cases in
  `test/lib/push-down/claude-config-carriage.test.ts`, which cover the merge rule's six
  behaviors, the absent-destination copy, the idempotency check, and the fail-fast path; overall
  line and branch coverage both rose.
- **Shell:** every new file under `.claude/lib/bash/` is inside the kcov include pattern and is
  exercised by the seven bats suites added in Phase 3 plus the two added in Phase 5; overall line
  coverage rose.

## Threshold Compliance Summary

All measured gates clear the uniform thresholds in `.claude/rules/quality-tiers.md`
(line >= 85%, branch >= 75%):

| Language | Line | Branch |
| --- | --- | --- |
| Python | 92.30% PASS | 89.48% PASS |
| TypeScript | 96.57% PASS | 89.90% PASS |
| Shell | 92.4% PASS | no gate (kcov cannot measure) |

No coverage-exclusion entry was added anywhere in this change, and no production path is excluded
from measurement.
