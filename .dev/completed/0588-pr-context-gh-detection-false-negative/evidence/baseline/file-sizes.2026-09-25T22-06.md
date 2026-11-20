# Baseline File Sizes ([P0-T9])

Timestamp: 2026-09-26T21-13

Command: `wc -l extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/test/extension.collect-pr-context.test.ts extensions/drm-copilot/test/extension.integration.test.ts extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/collector.py scripts/dev_tools/pr_context/github.py tests/scripts/dev_tools/test_pr_context_integration.py extensions/drm-copilot/src/lib/pr-context/autoclose.ts` (repository root; `autoclose.ts` appended because `TS_BUILDER_FILE` is that file; `PY_BUILDER_FILE` is `render_pr_helpers.py` and `PY_UNIT_TEST_FILE` is `ABSENT`, so nothing else is appended)

EXIT_CODE: 0

Output Summary: worktree equals the `<sync-sha>` tree for every listed path ([P0-T1] limited branch differences to the feature folder). States applied: TS_BUILDER_STATE PARAM-ONLY, PY_BUILDER_STATE PARAM-ONLY, TS_CALLSITE PRESENT, PY_CALLSITE PRESENT.

| File | Count | Delta budget (resolved) | Projected max |
|---|---|---|---|
| extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts | 174 | +16 | 190 |
| extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts | 417 | 0 (not the TS builder file) | 417 |
| extensions/drm-copilot/src/lib/pr-context/autoclose.ts | 298 | +8 (PARAM-ONLY) | 306 |
| extensions/drm-copilot/src/lib/pr-context/collector-core.ts | 396 | 0 (TS_CALLSITE PRESENT) | 396 |
| extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts | 437 | not in write set | 437 |
| extensions/drm-copilot/jest.config.cjs | 319 | +15 | 334 |
| extensions/drm-copilot/test/extension.collect-pr-context.test.ts | 499 | not in write set | 499 |
| extensions/drm-copilot/test/extension.integration.test.ts | 481 | +14 | 495 |
| extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts | 187 | +13 | 200 |
| extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts | 286 | +84 | 370 |
| extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts | 247 | +15 | 262 |
| extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts | 265 | +58 | 323 |
| extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts | 419 | +63 | 482 |
| scripts/dev_tools/pr_context/render_pr_helpers.py | 315 | +10 (PARAM-ONLY) | 325 |
| scripts/dev_tools/pr_context/collector.py | 461 | 0 (PY_CALLSITE PRESENT) | 461 |
| scripts/dev_tools/pr_context/github.py | 549 | not in write set (pre-existing over cap) | 549 |
| tests/scripts/dev_tools/test_pr_context_integration.py | 336 | +14 | 350 |
| extensions/drm-copilot/src/lib/executable-resolver.ts (new) | 0 | create <= 150 | 150 |
| extensions/drm-copilot/test/lib/executable-resolver.test.ts (new) | 0 | create <= 260 | 260 |
| extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts (new) | 0 | create <= 260 | 260 |
| tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py (new, PY_UNIT_TEST_FILE ABSENT) | 0 | create <= 120 | 120 |

Every projected maximum for a write-set file is <= 500. Acceptance met.
