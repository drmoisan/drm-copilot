# P6-T25 Commit-Steward TypeScript Fail-Before

Timestamp: `2026-08-10T20-25`

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts test/lib/push-down/codex-pack-selection.test.ts`

EXIT_CODE: `1`

Output Summary: `3 failed, 62 passed, 65 total; 3 suites failed in 0.582s`. The model-routing and topology cases fail only because `commit-steward` is not in the TypeScript generated-family authority. The real core-manifest case fails only because all six required `commit-steward` base/generated paths are absent. No unrelated test failed.

## Static Gates

- Prettier check over the three owners: exit `0`.
- ESLint over the three owners: exit `0`.
- `npm --prefix extensions/drm-copilot run typecheck`: exit `0`.
- `git diff --check -- <three owners>`: exit `0`.

## Exact Expected Authority Tuple

- `logical_agent=commit-steward`
- `deployment_agent=commit-steward-c4`
- `model=gpt-5.6-sol`
- `model_reasoning_effort=max`
- `c3_overlay_applied=false`
- `orchestration_complexity_ceiling=C4`

## Owner Boundaries

- `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts`: `458` lines.
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-topology.test.ts`: `317` lines.
- `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts`: `301` lines.
- Production/manifest/dependency/suppression/`.claude/` writes: `0`.
- Temporary filesystem artifacts: `0`.

Result: `PASS (expected failure cleanly attributed)`.
