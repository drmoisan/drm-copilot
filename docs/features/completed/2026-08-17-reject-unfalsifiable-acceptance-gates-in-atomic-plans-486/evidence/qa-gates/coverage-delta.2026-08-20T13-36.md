# Coverage Delta — Baseline versus Post-Change

Timestamp: 2026-08-20T13-36
Task: [P12-T10]
Issue: #486

Comparison points:

- Python baseline: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/python-test.2026-08-20T11-29.md`
- Python post-change: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/python-test.2026-08-20T13-21.md`
- TypeScript baseline: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/baseline/typescript-test.2026-08-20T11-35.md`
- TypeScript post-change: `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/typescript-test.2026-08-20T13-32.md`

Command: `poetry run pytest -q --cov=scripts.dev_tools.plan_gate_commands --cov=scripts.dev_tools.plan_gate_discrimination --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing` and `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary`

EXIT_CODE: 0

Output Summary: nine of the ten measured production modules pass the no-regression rule; one module, `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts`, regresses on both line and branch coverage and is recorded as FAIL. See the remediation-required section below.

## Python

| Module | Baseline line % | Post line % | Line delta | Baseline branch % | Post branch % | Branch delta | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | 93.70 | 96.62 | +2.92 | 84.62 | 91.07 | +6.45 | PASS |
| `scripts/dev_tools/plan_gate_commands.py` | not present | 100.00 | n/a (new module) | not present | 100.00 | n/a (new module) | PASS (absolute) |
| `scripts/dev_tools/plan_gate_discrimination.py` | not present | 98.21 | n/a (new module) | not present | 90.54 | n/a (new module) | PASS (absolute) |

Suite counts: baseline 3850 passed / 5 skipped; post-change 3998 passed / 5 skipped. The five skips are the same pre-existing parity-fixture skips in both runs.

## TypeScript

| Module | Baseline line % | Post line % | Line delta | Baseline branch % | Post branch % | Branch delta | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `src/lib/validate/orchestration-artifacts.ts` | 100 | 100 | 0.00 | 98.50 | 98.68 | +0.18 | PASS |
| `src/lib/validate/validate-orchestration-service-call.ts` | 100 | 98.50 | -1.50 | 84.61 | 81.25 | -3.36 | FAIL — regression |
| `src/mcp-tools.ts` | 92.45 | 92.50 | +0.05 | 82.14 | 82.75 | +0.61 | PASS |
| `src/lib/validate/plan-gate-commands.ts` | not present | 96.24 | n/a (new module) | not present | 84.93 | n/a (new module) | PASS (absolute) |
| `src/lib/validate/plan-gate-discrimination.ts` | not present | 100 | n/a (new module) | not present | 97.91 | n/a (new module) | PASS (absolute) |
| `src/lib/validate/plan-gate-rules.ts` | not present | 97.71 | n/a (new module) | not present | 89.39 | n/a (new module) | PASS (absolute) |
| `src/repo-automation-service-contract.ts` | 0 | 0 | 0.00 | 0 | 0 | 0.00 | PASS — type-only module |

Repository-wide: baseline Statements 96.61% (41750/43212), Branches 89.96% (5902/6560); post-change Statements 96.64% (42898/44387), Branches 89.97% (6083/6761). Deltas +0.03 and +0.01. Suite counts: baseline 185 suites / 2558 tests; post-change 193 suites / 2621 tests.

`src/repo-automation-service-contract.ts` is an interface-and-type-only module: it declares zero functions, constants, or classes across its 176 lines, and its branch diff is the single added optional field `readonly warnings?: ReadonlyArray<string>`. The reporter records it as 0/0/0/0 with lines 1-176 uncovered both before and after the change, which is the legitimate type-only case described in `.claude/rules/general-unit-test.md`. Its delta is therefore 0.00 and the module is not a regression. The Phase 0 baseline artifact did not tabulate a row for it because P12-T9 does not name it; the 0-versus-0 comparison is derived from the type-only property of the file, which the one-line interface addition did not change.

## Absolute Threshold Check

Every measured module with executable code satisfies the uniform thresholds in `.claude/rules/quality-tiers.md`, line >= 85 and branch >= 75. The lowest line figure is 92.50 (`src/mcp-tools.ts`) and the lowest branch figure is 81.25 (`src/lib/validate/validate-orchestration-service-call.ts`).

## Remediation Required — no-regression rule

`extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts` regresses against the Phase 0 baseline on both axes: line coverage falls from 100 to 98.50 (delta -1.50) and branch coverage falls from 84.61 to 81.25 (delta -3.36). The module still clears both absolute thresholds, so no jest per-file threshold fired and the suite exited 0; the regression is visible only in this delta comparison.

Cause: the uncovered post-change lines are 117-118, which are the `warnings` receiver and its `.map((warning) => ...)` callback inside the `warningBlock` construction; the trailing `.join` continuation sits on line 119. That block is reached only when `errors.length > 0` **and** `warnings.length > 0` on the same call — a validation failure that also carries at least one plan-gate warning. The three tests added by `[P9-T10]` cover the warning-with-no-error path, the warning-surfacing path, and the no-warning path, but no test exercises a blocking error and a warning together, so the warning-block concatenation branch of the new code is unexercised. The uncovered lines are lines this branch added, so this is a regression on changed lines under the uniform gate `No regression on changed lines` in `.claude/rules/quality-tiers.md`, not merely a whole-module dilution.

Remediation, recorded and NOT performed here because no task in this plan assigns it: add a test to `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts` that drives a runner returning at least one error and at least one warning, and assert the thrown message ends with the `PLAN GATE WARNING: `-prefixed warning block appended after the error list. That single test covers lines 117-118 and restores line coverage to 100 and branch coverage to at or above the 84.61 baseline. This is reported as remediation-required rather than as a pass.
