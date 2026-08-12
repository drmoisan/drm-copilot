# Python/TypeScript Mutation and Drift Parity Receipt

- Plan task: `[P1-T8]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- Mutation corpus: `16` cases
- Drift corpus: `6` cases

## Python

- Command: `poetry run pytest -q tests/scripts/dev_tools -k 'parallel and (mutation or drift)'`
- Exit code: `0`
- Result: `629 passed, 3088 deselected`
- Runtime: `1.28 s`

The selected Python suite includes the authoritative fixture evaluators and
verifies deterministic normalized decisions, ordered reason codes, mutation
sequence handling, drift resolution, scheduling, and completion admission.

## TypeScript

- Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/parallel-mutation-parity.test.ts test/lib/validate/parallel-drift-parity.test.ts`
- Exit code: `0`
- Test suites: `2 passed, 2 total`
- Tests: `36 passed, 36 total`
- Runtime: `0.389 s`

The TypeScript tests load the same fixtures and compare normalized decisions
and reason-code order against the Python-authoritative expected values for all
`22` mutation and drift cases.

## MCP Completion Enforcement

The preceding `[P1-T7]` public-path verification compared direct TypeScript
findings with orchestration-artifact dispatch and rejected a false-accept
checkpoint containing both an invalid mutation and unresolved drift. Direct
dispatch passed `11/11`, the in-process service passed `4/4`, and the registered
MCP handler passed `5/5`; mutation findings preceded drift findings in the
returned order. No unresolved mutation or drift fixture passed completion
validation.
