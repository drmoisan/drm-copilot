# P13-T2 extension TypeScript test gate with coverage

Timestamp: 2026-10-29T00-40
Task: [P13-T2] Repeat both TypeScript quality loops and builds.
Command: node run-jest.cjs --coverage --runInBand --coverageDirectory=SCRATCH/issue-980-p13t2-jest-ext --coverageReporters=json-summary --coverageReporters=json --coverageReporters=text-summary --json --outputFile=SCRATCH/issue-980-p13t2-jest-ext-results.json (in extensions/drm-copilot, so the extension configuration and its per-file `coverageThreshold` map apply)
EXIT_CODE: 1 (pass 1), 0 (pass 2)
Output Summary: Pass 2: 316 suites passed, 5107 tests passed, 0 failed. Coverage over src: statements and lines 97.12% (60437/62225), branches 93.58% (9190/9820), functions 91.82% (1820/1982). Every per-file threshold in the map passed, including the Phase 12 entries P12-T3 and P12-T4 added to `jest.discovery-coverage.json`, because Jest exits non-zero on any breach. P11-T3 recorded 312 suites, 4996 tests, 97.15% lines and 93.53% branches.

## Loop record

Pass 1 (5103 passed, 2 failed) failed two existing tests whose assertions had been superseded by intended Phase 12 behavior changes and had not been updated with them:

- `test/mcp-discovery-authority-tool-definitions.test.ts` "finalize_discovery_agent requires exactly [...]" expected `request_id` in the required list. The P12-T12 installed-host repair made `request_id` optional (it is derived from the consumed host authorization reference). Update: the expected required list is `["workspace_root", "invocation_ref"]`, and a new test asserts that `request_id` is still declared as an optional string property.
- `test/discovery-artifact-commands.test.ts` "createDiscoveryArtifact direct invocation drafts a feature contract under a grant" sent an `invocation_ref` from a process with no trusted agent identity. Since P12-T3 (`invocationOptions` in `src/repo-automation-service-discovery-identity.ts`), such a request is refused with `DISCOVERY_AGENT_IDENTITY_REQUIRED` and launches no runtime; the suite was outside the P12-T3 Set N update. Update: the positive case now supplies the trusted identity through the `DRM_DISCOVERY_*` environment keys that `createNodeDiscoveryAuthorityProvider` reads. It saves and restores every key, following the precedent in `test/repo-automation-service-discovery.test.ts`. It keeps every original request assertion and additionally asserts `--principal host` with the author, session, host and role arguments. A new case asserts that the same request without an identity rejects with `DISCOVERY_AGENT_IDENTITY_REQUIRED` and spawns no process.

No assertion was weakened, and the two refusal behaviors are now asserted where they were previously untested in these suites. The loop restarted from formatting in both projects.
Result: PASS
