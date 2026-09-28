# 500-Line Cap ([P9-T6])

Timestamp: 2026-09-26T22-33

Command: `wc -l extensions/drm-copilot/src/lib/executable-resolver.ts extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/collector-core.ts extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/test/lib/executable-resolver.test.ts extensions/drm-copilot/test/extension.collect-pr-context-gh-resolution.test.ts extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts extensions/drm-copilot/test/extension.integration.test.ts extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/collector.py tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py tests/scripts/dev_tools/test_pr_context_integration.py extensions/drm-copilot/src/lib/pr-context/autoclose.ts` (`autoclose.ts` appended because it is `<TS_BUILDER_FILE>`)

EXIT_CODE: 0

Output Summary (final count; delta vs [P0-T9]; budget):

| File | Final | [P0-T9] | Delta | Budget | OK |
|---|---|---|---|---|---|
| src/lib/executable-resolver.ts | 121 | new | create | <= 150 | yes |
| src/lib/pr-context/pr-context-service-call.ts | 185 | 174 | +11 | +16 | yes |
| src/lib/pr-context/render-pr-helpers.ts | 417 | 417 | 0 | 0 | yes |
| src/lib/pr-context/autoclose.ts | 304 | 298 | +6 | +8 (PARAM-ONLY) | yes |
| src/lib/pr-context/collector-core.ts | 396 | 396 | 0 | 0 (PRESENT) | yes |
| jest.config.cjs | 325 | 319 | +6 | +15 | yes |
| test/lib/executable-resolver.test.ts | 241 | new | create | <= 260 | yes |
| test/extension.collect-pr-context-gh-resolution.test.ts | 230 | new | create | <= 260 | yes |
| test/lib/pr-context/pr-context-service-call.test.ts | 356 | 286 | +70 | +84 | yes |
| test/lib/pr-context/pr-context-service-call-target.test.ts | 254 | 247 | +7 | +15 | yes |
| test/repo-automation-dispatch-pr-context-verification.test.ts | 196 | 187 | +9 | +13 | yes |
| test/extension.integration.test.ts | 491 | 481 | +10 | +14 | yes |
| test/lib/pr-context/render-pr-helpers.test.ts | 323 | 265 | +58 | +58 | yes |
| test/lib/pr-context/collector-core.test.ts | 476 | 419 | +57 | +63 | yes |
| scripts/dev_tools/pr_context/render_pr_helpers.py | 322 | 315 | +7 | +10 (PARAM-ONLY) | yes |
| scripts/dev_tools/pr_context/collector.py | 461 | 461 | 0 | 0 (PRESENT) | yes |
| tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py | 99 | new (ABSENT) | create | <= 120 | yes |
| tests/scripts/dev_tools/test_pr_context_integration.py | 347 | 336 | +11 | +14 | yes |

(TS paths are relative to `extensions/drm-copilot/`.) Every count is <= 500 and every delta is within its budget. Acceptance met.
