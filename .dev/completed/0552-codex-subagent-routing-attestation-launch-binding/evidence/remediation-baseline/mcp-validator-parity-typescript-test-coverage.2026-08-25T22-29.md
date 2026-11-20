Timestamp: 2026-08-25T22-29
Command: `npm run test:coverage -- test/lib/validate/codex-deployment.test.ts test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestration-artifacts.test.ts` from `extensions/drm-copilot`
EXIT_CODE: 1
Output Summary: Baseline command completed with 194 passing suites and 1 failing suite; 2657 tests passed and 1 failed, with 0 skipped. Reported line coverage was 96.66% (43084/44571). The failure is pre-existing root/bundle carriage drift in `test/lib/push-down/claude-config-carriage.test.ts`; after test execution, the coverage reporter also failed to resolve the first positional test argument as a module. No production, test, package, or bundled-customization path was modified by this baseline command.

Jest counts:
- Test suites: 194 passed, 1 failed, 195 total.
- Tests: 2657 passed, 1 failed, 2658 total.
- Skipped: 0.

Coverage summary:
- Lines: 96.66% (43084/44571).
- Statements: 96.66% (43084/44571).
- Branches: 90.05% (6128/6805).
- Functions: 89.67% (1260/1405).

Diagnostics:
- `issue #462 AC6: the Claude push-down publishes the config tree` failed because the bundled routing source was not byte-identical to the repository-root file.
- `istanbul-reports` could not resolve `test/lib/validate/codex-deployment.test.ts` while writing coverage reports.

Source-level note: this is pre-change source-level baseline behavior. The planned source revision has not yet modified its permitted files.
