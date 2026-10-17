# Final new-file registration — [P9-T5] (AC-24 companion to [P0-T5])

## Command 1 (literal plan command)

Timestamp: 2026-09-29T20-54
Command: git status --porcelain -- tests/fixtures/push_down_exclusions scripts/dev_tools/push_down_exclusion_manifest.py scripts/dev_tools/push_down_claude_exclusion_filter.py extensions/drm-copilot/src/lib/push-down/claude-exclusion-manifest.ts extensions/drm-copilot/src/lib/push-down/claude-exclusion-filter.ts tests/scripts/dev_tools/test_push_down_exclusion_manifest.py tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py tests/scripts/dev_tools/test_push_down_claude_exclusion_parity.py extensions/drm-copilot/test/lib/push-down/claude-exclusion-manifest.test.ts extensions/drm-copilot/test/lib/push-down/claude-exclusion-filter.test.ts extensions/drm-copilot/test/lib/push-down/claude-exclusion-parity.test.ts extensions/drm-copilot/test/lib/push-down/seeded-random.test-helpers.ts
EXIT_CODE: 0
Output Summary: empty output. The `??` status the task expects cannot appear in this run: plan rule 4 ("No commits inside this plan") was superseded by the caller's run instruction to commit and push at the end of every phase, so all fourteen files were committed in Phases 2 to 7 and are tracked and clean. This is a deviation caused by the commit override, recorded here and reported to the caller.

## Command 2 (committed-state equivalent, pinned Phase 0 anchor)

Timestamp: 2026-09-29T20-54
Command: git diff 9438bdf5253e10903e2e74eab5cf51df988e0466 --name-status --diff-filter=A -- . ":(exclude)docs"
EXIT_CODE: 0
Output Summary: exactly fourteen added files, each with status `A`, and no other added file outside `docs/`:
- fixtures (3): tests/fixtures/push_down_exclusions/manifest-corpus.json, matcher-corpus.json, plan-corpus.json
- new production (4): scripts/dev_tools/push_down_exclusion_manifest.py, scripts/dev_tools/push_down_claude_exclusion_filter.py, extensions/drm-copilot/src/lib/push-down/claude-exclusion-manifest.ts, extensions/drm-copilot/src/lib/push-down/claude-exclusion-filter.ts
- new tests (7): tests/scripts/dev_tools/test_push_down_exclusion_manifest.py, test_push_down_claude_exclusion_filter.py, test_push_down_claude_exclusion_parity.py, extensions/drm-copilot/test/lib/push-down/claude-exclusion-manifest.test.ts, claude-exclusion-filter.test.ts, claude-exclusion-parity.test.ts, seeded-random.test-helpers.ts

The anchor SHA is the [P0-T2] value (see ANCHOR_DRIFT note in `final-scope-guard.2026-09-29T20-50.md`). Result: the registered new-file set equals the planned set of three fixtures, four production files, and seven test files. PASS on the committed-state equivalent.
