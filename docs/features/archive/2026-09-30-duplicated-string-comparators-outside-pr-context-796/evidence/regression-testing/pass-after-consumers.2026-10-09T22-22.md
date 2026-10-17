# Pass-after: six consumer regression tests (P3-T31)

Timestamp: 2026-10-09T22-22
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/codex-native-converter/inventory.test.ts test/lib/push-down/blast-radius-derive-manifests.test.ts test/lib/push-down/copilot-customizations-engine.test.ts test/lib/subagent-tree/tree-assembler.test.ts test/lib/subagent-tree/quick-pick-labels.test.ts test/lib/pr-context/collector-output-ordering.test.ts -t "issue #796"
EXIT_CODE: 0
Output Summary:
- Test Suites: 6 passed, 6 total
- Tests:       53 skipped, 6 passed, 59 total  (no failed count)
- Passing titles and fail-before counterparts (under FEATURE/evidence/regression-testing/):
  1. P1-T1 "issue #796 sorts a supplementary-character path after a U+E000 path by code point" - fail-before-inventory.2026-10-09T21-24.md
  2. P1-T3 "issue #796 sorts a supplementary-character module path after a U+E000 module path" - fail-before-derive-manifests.2026-10-09T21-26.md
  3. P1-T5 "issue #796 emits a U+E000 key before a supplementary-character key" - fail-before-copilot-engine.2026-10-09T21-31.md
  4. P1-T7 "issue #796 orders orphans with a U+E000 agentId before a supplementary-character agentId" - fail-before-tree-assembler.2026-10-09T21-35.md
  5. P1-T9 "issue #796 breaks an equal-timestamp tie with a U+E000 path before a supplementary-character path" - fail-before-quick-pick-labels.2026-10-09T21-37.md
  6. P1-T11 "issue #796 renders a U+E000 evidence source before a supplementary-character evidence source" - fail-before-collector-output.2026-10-09T21-40.md
