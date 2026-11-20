# Stale-Reference Classification ([P2-T6])

Timestamp: 2026-11-19T12-00
Plan: plan.2026-10-30T18-39.md
Command: git grep -c -F -e RETIRED-PATH -- . ':(exclude)docs/features/' (RETIRED-PATH passed literally), each hit classified with a STALE-REFERENCE-CLASSES class
EXIT_CODE: 0
Output Summary: 61 files (510 occurrences) hold RETIRED-PATH outside docs/features/ (Phase 0: 121 files, 762 occurrences); unclassified: 0; class example used: 0; files of COPILOT-AGENT-FILES with a hit: 0.

| File | Count | Class and reason |
| --- | --- | --- |
| `.claude/skills/translate-copilot-to-claude/SKILL.md` | 4 | generic-input | generic Copilot-to-Claude conversion input format |
| `config/harness-parity-matrix.json` | 45 | historical | source_path of the dropped copilot:skill and copilot:skill-frontmatter-field matrix entries, which record the retired source each entry described |
| `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` | 7 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0002-concurrent-review.md` | 2 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0003-light-remediation.md` | 8 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0004-smaller-plans.md` | 3 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0005-policy-read-removal.md` | 3 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0006-test-suite-baseline-restored.md` | 8 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0008-g13-guideline-cutoff.md` | 2 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0009-less-evidence.md` | 4 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0011-task-check-cadence.md` | 5 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/0012-local-lane-exclusion.md` | 4 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch` | 1 | ledger-record | process-reduction entry or stored patch text that the chain test reads (Files Changed bullets, revert-step prose, and the #1032 retirement notes) |
| `docs/research/20260309-push-down-copilot-customizations-implementation-research.md` | 2 | historical | dated research record |
| `docs/research/20260314-bundle-hard-lock-resolver-into-extension-implementation-research.md` | 1 | historical | dated research record |
| `docs/research/20260314-csharp-orchestrator-small-path-lifecycle-research.md` | 17 | historical | dated research record |
| `docs/research/20260411-claude-code-architecture-implementation-research.md` | 4 | historical | dated research record |
| `docs/research/20260412-claude-code-github-skills-agents-migration-research.md` | 29 | historical | dated research record |
| `docs/research/20260412-codex-github-skills-agents-migration-implementation-research.md` | 5 | historical | dated research record |
| `docs/research/20260417-github-bundled-customization-divergence-audit-research.md` | 5 | historical | dated research record |
| `docs/research/20260417-github-instructions-not-migrated-to-claude-151-research.md` | 2 | historical | dated research record |
| `docs/research/20260429-harden-feature-promotion-lifecycle-mcp-only-implementation-research.md` | 1 | historical | dated research record |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/translate-copilot-to-claude/SKILL.md` | 4 | generic-input | generic Copilot-to-Claude conversion input format |
| `extensions/drm-copilot/src/lib/codex-native-converter/classifier.ts` | 2 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/classifier.test.ts` | 4 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/cli.test.ts` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/codex-native-converter-service-call.test.ts` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/engine-pipeline.test.ts` | 2 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/engine.test.ts` | 2 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/inventory.test.ts` | 2 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/mapping.test.ts` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/pipeline.test.ts` | 17 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/lib/codex-native-converter/rewrites.test.ts` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `extensions/drm-copilot/test/repo-automation-service.codex-native-converter.test.ts` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `scripts/dev_tools/codex_native_converter/README.md` | 2 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `scripts/dev_tools/codex_native_converter/classifier.py` | 2 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `scripts/dev_tools/codex_native_converter/inventory.py` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `scripts/dev_tools/codex_native_converter/rewrites.py` | 2 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `scripts/harness-generation/sources/skills/translate-copilot-to-claude.substitutions.json` | 4 | generic-input | generic Copilot-to-Claude conversion input format |
| `scripts/harness/HarnessInventory.psm1` | 3 | generic-input | child 1 inventory scanner that enumerates the Copilot skill root of any repository layout; it finds no file here after the retirement |
| `testResults.xml` | 1 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json` | 3 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `tests/fixtures/codex_native_converter/github_copilot/.github/agents/beast-topology.agent.md` | 1 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `tests/scripts/claude-hooks/enforce-docs-role-write-scope.Tests.ps1` | 1 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` | 1 | ledger-mapping-rule | in-memory case of the generic skill-copy mapping rule of Get-ProcessReductionMappedSource |
| `tests/scripts/dev_tools/codex_native_converter/test_classifier.py` | 2 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `tests/scripts/dev_tools/codex_native_converter/test_inventory.py` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `tests/scripts/dev_tools/codex_native_converter/test_mapping.py` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `tests/scripts/dev_tools/codex_native_converter/test_rewrites.py` | 1 | generic-input | generic Copilot-to-Codex input-format handling of the Codex native converter |
| `tests/scripts/harness/HarnessInventory.Tests.ps1` | 2 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` | 2 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `virtual/apply-artifacts-debug/conversion-report.md` | 4 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `virtual/apply-artifacts-debug/mapping-catalog.json` | 1 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `virtual/debug-artifacts-2/conversion-report.md` | 74 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `virtual/debug-artifacts-2/mapping-catalog.json` | 17 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `virtual/debug-artifacts-3/conversion-report.md` | 74 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `virtual/debug-artifacts-3/mapping-catalog.json` | 17 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `virtual/debug-artifacts/conversion-report.md` | 74 | fixture | historical test fixture, in-memory test input, or recorded tool output |
| `virtual/debug-artifacts/mapping-catalog.json` | 17 | fixture | historical test fixture, in-memory test input, or recorded tool output |
