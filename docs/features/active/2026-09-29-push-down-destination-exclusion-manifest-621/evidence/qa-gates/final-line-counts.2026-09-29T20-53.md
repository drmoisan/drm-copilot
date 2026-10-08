# Final line counts — [P9-T4] (AC-25, US-22)

Timestamp: 2026-09-29T20-53
Command: for f in <25 files below>; do awk 'END{print NR}' "$f"; done
EXIT_CODE: 0
Output Summary: 25 files counted; maximum non-documentation count is 499 (`scripts/dev_tools/push_down_claude_customizations.py`); every count is at or below 500. PASS.

Substitution: the plan's `(Get-Content -LiteralPath <path>).Count` runs under `pwsh`, which the worktree isolation guard refuses. `awk 'END{print NR}'` is used instead; like `Get-Content`, it counts a final line that lacks a trailing newline.

File set: the section 3 inventory, confirmed equal to `git diff 9438bdf5253e10903e2e74eab5cf51df988e0466 --name-status` outside the feature folder (14 `A`, 11 `M`).

| Lines | File | Kind |
|---|---|---|
| 441 | README.md | documentation (exempt) |
| 356 | extensions/drm-copilot/jest.config.cjs | configuration |
| 496 | extensions/drm-copilot/src/lib/push-down/claude-customizations.ts | production (modified) |
| 337 | extensions/drm-copilot/src/lib/push-down/claude-exclusion-filter.ts | production (new) |
| 343 | extensions/drm-copilot/src/lib/push-down/claude-exclusion-manifest.ts | production (new) |
| 448 | extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts | production (modified) |
| 214 | extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts | production (modified) |
| 420 | extensions/drm-copilot/src/repo-automation-command-registration-admin.ts | production (modified) |
| 391 | extensions/drm-copilot/test/lib/push-down/claude-exclusion-filter.test.ts | test (new) |
| 492 | extensions/drm-copilot/test/lib/push-down/claude-exclusion-manifest.test.ts | test (new) |
| 193 | extensions/drm-copilot/test/lib/push-down/claude-exclusion-parity.test.ts | test (new) |
| 290 | extensions/drm-copilot/test/lib/push-down/push-down-service-call.test.ts | test (modified) |
| 96 | extensions/drm-copilot/test/lib/push-down/seeded-random.test-helpers.ts | test helper (new) |
| 258 | extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts | test (modified) |
| 299 | extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts | test (modified) |
| 166 | pyproject.toml | configuration |
| 499 | scripts/dev_tools/push_down_claude_customizations.py | production (modified) |
| 346 | scripts/dev_tools/push_down_claude_exclusion_filter.py | production (new) |
| 343 | scripts/dev_tools/push_down_exclusion_manifest.py | production (new) |
| 109 | tests/fixtures/push_down_exclusions/manifest-corpus.json | fixture (new) |
| 113 | tests/fixtures/push_down_exclusions/matcher-corpus.json | fixture (new) |
| 233 | tests/fixtures/push_down_exclusions/plan-corpus.json | fixture (new) |
| 398 | tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py | test (new) |
| 181 | tests/scripts/dev_tools/test_push_down_claude_exclusion_parity.py | test (new) |
| 358 | tests/scripts/dev_tools/test_push_down_exclusion_manifest.py | test (new) |
