# TypeScript Containment Focused Regression

- Timestamp: `2026-09-02T23:16:42.4288148-04:00`
- Working directory: `extensions/drm-copilot`
- Command: `npm run test:unit -- --runInBand test/lib/validate/orchestration-handoff-path-boundary.test.ts test/lib/validate/orchestration-handoff-authority-service.test.ts test/lib/validate/orchestration-handoff-contract.test.ts test/repo-automation-orchestration-validation.test.ts test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts test/lib/validate/orchestration-handoff-materializer-production.test.ts test/lib/validate/orchestration-handoff-materializer.test.ts test/mcp-server.test.ts`
- Exit code: `0`
- Test suites: `8 passed, 8 total`
- Tests: `98 passed, 98 total`
- Snapshots: `0 total`

## Acceptance verification

- All collected authority and materializer suites passed.
- `orchestration-handoff-authority-service.test.ts` covers canonical envelope and plan escapes before the applicable file reads.
- `orchestration-handoff-materializer-path-boundary.test.ts` covers source, envelope, archive, destination, and candidate escapes before relevant reads or mutations, plus ordinary in-workspace materialization.
- `orchestration-handoff-contract.test.ts` verifies the shared Python failure-precedence registry and the ordering of contract, authority, and dirty-worktree checks.
- The focused result therefore verifies FR-614-001 failure precedence and ordinary behavior remained unchanged.
