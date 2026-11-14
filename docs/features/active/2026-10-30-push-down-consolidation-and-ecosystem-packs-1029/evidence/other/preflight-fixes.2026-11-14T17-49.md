# Preflight Fixes - Issue #1029 (round 2)

Timestamp: 2026-11-14T17-49
Plan: docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/plan.2026-10-30T18-37.md
Validator: branch Python CLI `scripts.dev_tools.validate_orchestration_artifacts plan` run after the fixes; result recorded in the preflight return.

## Fixes

1. `## Existing Test Dispositions` X1 | missing asserting-test names (changed-behavior rule) | The describe `pushDownCustomizations (engine)` in `PDT/copilot-customizations-engine.test.ts` holds eight cases and the import retarget applies to all of them; the row named four. Added `writes the summary artifact at the deterministic path and returns it`, `copies file content into the destination via the injected filesystem`, `exposes the inlined copilot root-folder enumeration order` and `defaults sourceRoot and artifactRoot to repoRoot when omitted`. Disposition unchanged (import retargeted, assertions unchanged).
2. `## Existing Test Dispositions` rule R3 | helper route mismatch | `EXT/test/extension.push-down-claude-customizations.test.ts` backs its file system with the `node:fs` mock (`seedInProcessFileSystem`), so `seedSharedLayerManifest` (built over `buildInMemoryFileSystem`) cannot seed it. R3 now also allows seeding `shared.json` as one more file entry in that case. No assertion changed.
3. `## Planning Decisions` D9 | inaccurate claim (validator-blind asserting test) | "No test pins either map" was inaccurate: `EXT/test/discovery-coverage-contracts.test.ts` pins `jest.discovery-coverage.json` and its merge into `coverageThreshold`. D9 now names that test as unchanged, because the new map's keys are distinct from the discovery keys. No assertion changed.
