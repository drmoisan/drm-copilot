# QA gate: AC-5 consumer regression tests (P4-T11, pass 2)

Timestamp: 2026-10-09T23-22
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/codex-native-converter/inventory.test.ts test/lib/push-down/blast-radius-derive-manifests.test.ts test/lib/push-down/copilot-customizations-engine.test.ts test/lib/subagent-tree/tree-assembler.test.ts test/lib/subagent-tree/quick-pick-labels.test.ts test/lib/pr-context/collector-output-ordering.test.ts -t "issue #796"
EXIT_CODE: 0
Output Summary:
- Test Suites: 6 passed, 6 total
- Tests:       53 skipped, 6 passed, 59 total  (no failed count)
- Fail-before artifacts (FEATURE/evidence/regression-testing/), each confirmed to exist and to record `EXIT_CODE: 1` with `ExpectedExitCode: 1`:
  - fail-before-inventory.2026-10-09T21-24.md (codex-native-converter, normalizeSelectedPaths)
  - fail-before-derive-manifests.2026-10-09T21-26.md (push-down, classifyProjectDirectories)
  - fail-before-copilot-engine.2026-10-09T21-31.md (push-down, stringifySorted)
  - fail-before-tree-assembler.2026-10-09T21-35.md (subagent-tree, compareByAgentId)
  - fail-before-quick-pick-labels.2026-10-09T21-37.md (subagent-tree, compareCandidates path tiebreak)
  - fail-before-collector-output.2026-10-09T21-40.md (pr-context, renderVerificationEvidenceSection)
- Result: PASS.
