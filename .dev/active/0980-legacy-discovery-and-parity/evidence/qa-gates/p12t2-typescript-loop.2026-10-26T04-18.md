# P12-T2 — Baseline result in the protected invocation partition: extension TypeScript loop

Timestamp: 2026-10-26T04-18
Command: npx prettier --write src/discovery-service-types.ts src/discovery-invocation.ts src/repo-automation-service-discovery-agent.ts test/discovery-invocation-test-support.ts test/discovery-invocation.test.ts test/repo-automation-service-discovery-agent.test.ts
EXIT_CODE: 0
Output Summary: First pass reformatted the two edited test files; the loop restarted and the second prettier pass reports every file "(unchanged)". ESLint over the same six files: exit 0, no output. `npx tsc -p ./ --noEmit`: exit 0. `npx tsc -p tsconfig.jest.json --noEmit`: exit 0. `node run-jest.cjs test/discovery-invocation test/repo-automation-service-discovery-agent test/discovery-routing test/discovery-finalization test/discovery-invocation-record test/discovery-public-workflow`: 8 suites, 229 tests passed. Coverage (`--coverage --coverageReporters=text --collectCoverageFrom` for the two changed modules over the invocation, service-discovery, finalization, invocation-record and capabilities suites): `discovery-invocation.ts` 99.33% lines / 96% branches; `repo-automation-service-discovery-agent.ts` 100% lines / 93.75% branches; both above the configured 90/75 entries in extensions/drm-copilot/jest.discovery-coverage.json. `discovery-service-types.ts` is type-only.

## Changed files (physical lines)

- `src/discovery-service-types.ts` (163): `DiscoveryRequestInputValue` admits `ReadonlyArray<Readonly<Record<string, unknown>>>` so `expected_outputs` rows travel in a `prepare-agent` request; type-only.
- `src/discovery-invocation.ts` (450): `BASELINE_RESULT_FILE = "baseline-result.json"`; `PrepareOptions.baseline` (the authoritative `prepare-agent` result); `validateBaseline` refuses `INVOCATION_REQUEST_INVALID` for a non-ok, foreign-operation, runtime-less or other-runtime result before any write; the exclusive file set is now five records, the fifth holding the baseline result document verbatim (`JSON.stringify(result, null, 2)` plus newline, the same serialization as the other four).
- `src/repo-automation-service-discovery-agent.ts` (237): `prepareDiscoveryAgentOperation` sends one `prepare-agent` request (structural mode, inputs `skill_id`, `selected_ids`, `paths`, `expected_outputs`, `execution_context`, `complexity`, optional `profile_path`) instead of `doctor`, takes the runtime identity from the result, and throws `DISCOVERY_PREPARE_BASELINE_FAILED` naming the exit code and finding codes for a non-ok, foreign or runtime-less result before any protected write.
- `test/discovery-invocation-test-support.ts` (237): `baselineResult()` fixture; `options()` supplies it by default so the refusal, record and finalization scenarios run unchanged.
- `test/discovery-invocation.test.ts` (226): five exclusively created files per skill, the baseline document byte-identical to the supplied result, four baseline refusals with zero writes; the partial-directory refusal is unchanged.
- `test/repo-automation-service-discovery-agent.test.ts` (326): Set N disposition applied: the doctor assertions become prepare-agent request-shape assertions (one runtime call, no doctor), three failed-result refusals with zero store writes, finding codes named in the refusal, the ceiling kept out of the Python inputs, the profile forwarded; finalize assertions unchanged.

## Acceptance

- A prepared partition holds exactly five exclusively created records including `baseline-result.json` (asserted per skill id on the in-memory store).
- A failing or malformed prepare-agent result creates no protected file and returns the typed refusal (`DISCOVERY_PREPARE_BASELINE_FAILED` at the service, `INVOCATION_REQUEST_INVALID` at the module).
