# TypeScript Materializer Containment Regression

Timestamp: 2026-09-02T21-43-04:00
Command: `npm run test:unit -- --runInBand test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts test/lib/validate/orchestration-handoff-materializer-production.test.ts test/lib/validate/orchestration-handoff-materializer.test.ts test/mcp-server.test.ts`
Working Directory: `extensions/drm-copilot`
EXIT_CODE: 0

Output Summary: 4/4 test suites passed, 54/54 tests passed, and 0 snapshots were present. Canonical escapes for source, envelope, archive, destination checkpoint, and candidate paths were rejected before relevant reads or mutations, with the original source retained. Existing dry-run, archive immutability, candidate validation and cleanup, atomic checkpoint replacement, and MCP result-shaping tests remained passing. The scheduler-neutral transition request and projection behavior remained unchanged for ordinary, parallel-child, and epic-child inputs; the broader ownership matrix is retained for the Phase 2 integration-and-parity gate.
