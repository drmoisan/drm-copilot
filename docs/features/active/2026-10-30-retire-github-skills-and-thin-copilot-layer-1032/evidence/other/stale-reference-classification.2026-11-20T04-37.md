# Stale-Reference Classification, Cycle-2 Merge Head ([P1-T6])

Plan: remediation-plan.2026-11-19T19-58.md
Timestamp: 2026-11-20T04-37
Command: git grep -c -F -e RETIRED-PATH -- . ':(exclude)docs/features/' (RETIRED-PATH passed literally) on the merge head; each hit classified with a STALE-REFERENCE-CLASSES class; INCOMING-DELTA membership from the P0-T1 listing (SCRATCH/issue-1032-c2-incoming-delta.txt, 361 paths); git ls-files under both RETIRED-SKILL-TREES trees
EXIT_CODE: 0
Output Summary: 61 files (511 occurrences) hold RETIRED-PATH outside docs/features/; the file list equals the cycle-1 post-fix classification `stale-reference-classification.2026-11-19T13-50.md`, and the only count change is `config/harness-parity-matrix.json` 45 to 46 (the incoming #1051 row `copilot:skill:push-down-integration`, disposition `dropped`, whose `source_path` names the retired Copilot copy). Unclassified: 0; class example used: 0; files of COPILOT-AGENT-FILES with a hit: 0 (the one `.github/agents` hit is the converter input fixture under `tests/fixtures/`, not a COPILOT-AGENT-FILES member).

INCOMING-DELTA hits: 1 (`config/harness-parity-matrix.json`, status M in INCOMING-DELTA)
RetiredTreeFiles: 0
Unclassified: 0
COPILOT-AGENT-FILES hits: 0

| File | Count | In INCOMING-DELTA | Class and reason |
| --- | --- | --- | --- |
| `.claude/skills/translate-copilot-to-claude/SKILL.md` | 4 | no | generic-input: generic Copilot-to-Claude conversion input format |
| `config/harness-parity-matrix.json` | 46 | yes | historical: source_path of the dropped copilot skill matrix entries, which record the retired source each entry described |
| `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` | 7 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0002-concurrent-review.md` | 2 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0003-light-remediation.md` | 8 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0004-smaller-plans.md` | 3 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0005-policy-read-removal.md` | 3 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0006-test-suite-baseline-restored.md` | 8 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0008-g13-guideline-cutoff.md` | 2 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0009-less-evidence.md` | 4 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0011-task-check-cadence.md` | 5 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/0012-local-lane-exclusion.md` | 4 | no | ledger-record: entry text the chain test reads |
| `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch` | 1 | no | ledger-record: stored patch text the chain test reads |
| `docs/research/20260309-push-down-copilot-customizations-implementation-research.md` | 2 | no | historical: dated research record |
| `docs/research/20260314-bundle-hard-lock-resolver-into-extension-implementation-research.md` | 1 | no | historical: dated research record |
| `docs/research/20260314-csharp-orchestrator-small-path-lifecycle-research.md` | 17 | no | historical: dated research record |
| `docs/research/20260411-claude-code-architecture-implementation-research.md` | 4 | no | historical: dated research record |
| `docs/research/20260412-claude-code-github-skills-agents-migration-research.md` | 29 | no | historical: dated research record |
| `docs/research/20260412-codex-github-skills-agents-migration-implementation-research.md` | 5 | no | historical: dated research record |
| `docs/research/20260417-github-bundled-customization-divergence-audit-research.md` | 5 | no | historical: dated research record |
| `docs/research/20260417-github-instructions-not-migrated-to-claude-151-research.md` | 2 | no | historical: dated research record |
| `docs/research/20260429-harden-feature-promotion-lifecycle-mcp-only-implementation-research.md` | 1 | no | historical: dated research record |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/translate-copilot-to-claude/SKILL.md` | 4 | no | generic-input: generic Copilot-to-Claude conversion input format |
| `extensions/drm-copilot/src/lib/codex-native-converter/classifier.ts` | 2 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts` | 1 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/classifier.test.ts` | 4 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/cli.test.ts` | 1 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/codex-native-converter-service-call.test.ts` | 1 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/engine.test.ts` | 2 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/engine-pipeline.test.ts` | 2 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/inventory.test.ts` | 2 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/mapping.test.ts` | 1 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/models.test.ts` | 1 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/pipeline.test.ts` | 17 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/lib/codex-native-converter/rewrites.test.ts` | 1 | no | generic-input: Codex native converter input-format handling |
| `extensions/drm-copilot/test/repo-automation-service.codex-native-converter.test.ts` | 1 | no | generic-input: Codex native converter input-format handling |
| `scripts/dev_tools/codex_native_converter/classifier.py` | 2 | no | generic-input: Codex native converter input-format handling |
| `scripts/dev_tools/codex_native_converter/inventory.py` | 1 | no | generic-input: Codex native converter input-format handling |
| `scripts/dev_tools/codex_native_converter/README.md` | 2 | no | generic-input: Codex native converter input-format handling |
| `scripts/dev_tools/codex_native_converter/rewrites.py` | 2 | no | generic-input: Codex native converter input-format handling |
| `scripts/harness/HarnessInventory.psm1` | 3 | no | generic-input: child 1 inventory scanner that enumerates the Copilot skill root of any repository layout |
| `scripts/harness-generation/sources/skills/translate-copilot-to-claude.substitutions.json` | 4 | no | generic-input: generic Copilot-to-Claude conversion input format |
| `testResults.xml` | 1 | no | fixture: recorded tool output |
| `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json` | 3 | no | fixture: historical test fixture |
| `tests/fixtures/codex_native_converter/github_copilot/.github/agents/beast-topology.agent.md` | 1 | no | fixture: converter input fixture (not a COPILOT-AGENT-FILES member; it is under `tests/fixtures/`) |
| `tests/scripts/claude-hooks/enforce-docs-role-write-scope.Tests.ps1` | 1 | no | fixture: in-memory test input |
| `tests/scripts/dev_tools/codex_native_converter/test_classifier.py` | 2 | no | generic-input: Codex native converter input-format handling |
| `tests/scripts/dev_tools/codex_native_converter/test_inventory.py` | 1 | no | generic-input: Codex native converter input-format handling |
| `tests/scripts/dev_tools/codex_native_converter/test_mapping.py` | 1 | no | generic-input: Codex native converter input-format handling |
| `tests/scripts/dev_tools/codex_native_converter/test_rewrites.py` | 1 | no | generic-input: Codex native converter input-format handling |
| `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` | 1 | no | ledger-mapping-rule: in-memory case of the generic skill-copy mapping rule of Get-ProcessReductionMappedSource |
| `tests/scripts/harness/HarnessInventory.Tests.ps1` | 2 | no | fixture: in-memory test input |
| `tests/scripts/harness/HarnessParityMatrix.Tests.ps1` | 2 | no | fixture: in-memory test input |
| `virtual/apply-artifacts-debug/conversion-report.md` | 4 | no | fixture: recorded tool output |
| `virtual/apply-artifacts-debug/mapping-catalog.json` | 1 | no | fixture: recorded tool output |
| `virtual/debug-artifacts/conversion-report.md` | 74 | no | fixture: recorded tool output |
| `virtual/debug-artifacts/mapping-catalog.json` | 17 | no | fixture: recorded tool output |
| `virtual/debug-artifacts-2/conversion-report.md` | 74 | no | fixture: recorded tool output |
| `virtual/debug-artifacts-2/mapping-catalog.json` | 17 | no | fixture: recorded tool output |
| `virtual/debug-artifacts-3/conversion-report.md` | 74 | no | fixture: recorded tool output |
| `virtual/debug-artifacts-3/mapping-catalog.json` | 17 | no | fixture: recorded tool output |
