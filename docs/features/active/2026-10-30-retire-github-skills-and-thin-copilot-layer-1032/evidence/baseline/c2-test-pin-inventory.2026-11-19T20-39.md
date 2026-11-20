# C2 Test-Pin and Stale-Reference Inventory ([P0-T3])

Timestamp: 2026-11-19T20-39
Plan: remediation-plan.2026-11-19T19-58.md
Command: Grep (working tree, merge in progress) over `tests/**` and `extensions/drm-copilot/test/**` for (1) RETIRED-PATH written whole, (2) a retired-tree path built from parts (template literal `.github/${...}`, a `'.github', 'skills'` join or list, `'.github' +` concatenation, `Join-Path ... .github ... skills`, `Path('.github') / 'skills'`), (3) `execution-environment/SKILL.md` in a copy list, (4) six-copy counts (`six copies`, `six tracked copies`, `in six locations`, `toHaveLength(6)`, `Should -Be 6`, `HaveCount 6`), (5) `skills/push-down-integration` copy-set pins; Grep of the saved INCOMING-DELTA for added test files; Grep of `config/harness-parity-matrix.json`; git diff <IMB> origin/epic/shared-agent-harness-layer-integration -- config/harness-parity-matrix.json and the modified incoming tests
EXIT_CODE: 0
Output Summary: three tests carry an `update` disposition (push-down-integration-skill.test.ts, push-down-ci-contract.test.ts, PoshQC.VendoredCoverage.RepoGate.Tests.ps1); every other match predates the merge and passes at the pre-merge head (unchanged, unaffected); the parity-matrix row copilot:skill:push-down-integration is `dropped`; 5 non-test INCOMING-DELTA hit files are all classified, with 0 unclassified; no INCOMING-DELTA hit lies in a COPILOT-AGENT-FILES file.

## Tests with disposition `update`

| Test file | Asserting test | Current pin | Disposition and reason |
| --- | --- | --- | --- |
| `extensions/drm-copilot/test/packaging/push-down-integration-skill.test.ts` | `S51 positive: the six copies are byte-identical`; `S51 negative: a copy that differs by one byte is detected` | `COPIES` = `.agents/${SKILL}`, `.claude/${SKILL}`, `.github/${SKILL}`, `${RESOURCES}/codex-and-agents-customizations/.agents/${SKILL}`, `${RESOURCES}/claude-customizations/.claude/${SKILL}`, `${RESOURCES}/customizations/.github/${SKILL}` (six; the third and sixth are built from parts under RETIRED-SKILL-TREES); module comment "The six tracked copies"; negative case mutates `texts[5]` | `update`: reduce `COPIES` to the four remaining copies (`.agents`, `.claude` and their two bundle copies), rename both S51 titles from six copies to four (and the module comment), and move the mutated entry to `texts[3]`; the two retired copies are deleted by P1-T1, so the six-entry list would throw on read |
| `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` | `every brief copy names the CI data file after the refresh rule` | local `copies` list of six `execution-environment/SKILL.md` paths, including both RETIRED-BRIEF-COPIES written whole | `update`: drop the two retired entries so the list names the four REMAINING-BRIEF-COPIES; the retired copies are deleted by P1-T1 |
| `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1` | data-driven cases over `$script:BriefCopies` (`BeforeDiscovery`) | six `execution-environment/SKILL.md` paths, including both RETIRED-BRIEF-COPIES written whole | `update`: drop the two retired entries so the list names the four REMAINING-BRIEF-COPIES; the retired copies are deleted by P1-T1 |

## Tests with disposition `unchanged (unaffected)`

- RETIRED-PATH written whole, pre-existing on the branch and classified in earlier cycles (`fixture` or `generic-input`), each passing at the pre-merge head: the codex-native-converter suites (`classifier.test.ts`, `cli.test.ts`, `codex-native-converter-service-call.test.ts`, `engine-pipeline.test.ts`, `engine.test.ts`, `inventory.test.ts`, `mapping.test.ts`, `models.test.ts`, `pipeline.test.ts`, `rewrites.test.ts`, `repo-automation-service.codex-native-converter.test.ts`, and `tests/scripts/dev_tools/codex_native_converter/test_classifier.py`, `test_inventory.py`, `test_mapping.py`, `test_rewrites.py`), the fixtures `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json` and `tests/fixtures/codex_native_converter/github_copilot/.github/agents/beast-topology.agent.md`, `tests/scripts/claude-hooks/enforce-docs-role-write-scope.Tests.ps1`, `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`, `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.Tests.ps1`.
- Parts-built retired path: `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` (`$script:RetiredPath` built at runtime; GUARD-SUITE by design). `extensions/drm-copilot/test/lib/push-down/claude-customizations.test.ts` matched the template pattern through `LEGACY_BASE` (`.claude-variants/csharp-legacy`), not a retired tree.
- `execution-environment/SKILL.md` in a copy list, already reduced to the four remaining copies on this branch and passing at the pre-merge head: `cleanup-merged-worktrees.SkillText.Tests.ps1`, `enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1`, `enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1`, `hook-release-allowance-context.Parity.Tests.ps1`, `NestingDepthContract.Tests.ps1`, `copilot-layer-retirement.Tests.ps1`, `docs-authoring-roles.WorkflowText.Tests.ps1`, `documentation-workflow.CommitStage.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `regeneration-path-skill-contract.Tests.ps1`, `test-cadence-wording.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1`, `test_bash_command_shape_surfaces.py`, `test_discovery_documentation_contracts.py`, `test_execution_environment_brief_contracts.py`.
- Six-copy counts: every `toHaveLength(6)`, `Should -Be 6` and `HaveCount 6` match outside `push-down-integration-skill.test.ts` counts an unrelated quantity (causes, registrations, docs-ledger totals, token columns), not brief or contract copies.
- Modified incoming tests read and found unaffected: `push-down-harness.real-bundle.test.ts` (integration-item ids only), `test_push_down_codex_and_agents_resource_contracts.py` (tool tuple), `test_poshqc_bundled_parity.py` (PoshQC module list), `push-down-integration-brief.test.ts` (reads only the bundled Claude brief) and `push-down-integration-exposure.test.ts` (reads only the Codex bundle). `tests/fixtures/push-down-manifest-hash/corpus.json`, `push-down-hash-parity.test.ts` and `push-down-apply-hash-invariant.test.ts` name no Copilot bundle path.

COPY-SET-PINS (any skill with an IncomingRetiredAdds copy): `push-down-integration` is the only such skill; its only copy-set pin is `push-down-integration-skill.test.ts` (above, `update`).

## Parity-matrix rows for IncomingRetiredAdds skills

| Row id | source_path | Disposition |
| --- | --- | --- |
| `copilot:skill:push-down-integration` | `.github/skills/push-down-integration/SKILL.md` | `dropped` (expected) |
| `claude:skill:push-down-integration` | `.claude/skills/push-down-integration/SKILL.md` | `generated` (kept copy) |
| `codex:skill:push-down-integration` | `.agents/skills/push-down-integration/SKILL.md` | `shared` (kept copy) |

## Non-test INCOMING-DELTA hits for RETIRED-PATH

| File | Hit | Class or resolution |
| --- | --- | --- |
| `config/harness-parity-matrix.json` | `source_path` of the dropped row `copilot:skill:push-down-integration` (file total 46, was 45) | `historical` (records the retired source the dropped entry described; same class as the earlier dropped rows) |
| `extensions/drm-copilot/resources/customizations/pack-manifests/core.json` | incoming entry `.github/skills/push-down-integration/SKILL.md` | removed by the P1-T2 resolution (not a remaining hit) |
| `.github/skills/execution-environment/SKILL.md` | retired brief copy | deleted by P1-T1 (not a remaining hit) |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | retired brief copy | deleted by P1-T1 (not a remaining hit) |
| IncomingRetiredAdds (`.github/skills/push-down-integration/SKILL.md` and its Copilot bundle copy) | path under RETIRED-SKILL-TREES; no RETIRED-PATH text in the content | deleted by P1-T1 (not a remaining hit) |

Unclassified: 0. No INCOMING-DELTA file lies under `.github/agents/` or the Copilot agent bundle, so no COPILOT-AGENT-FILES hit exists.

## New incoming test files (manifests, CI workflows, integration skill)

#1049 (vendored coverage): `tests/scripts/powershell/PoshQC/PoshQC.TestingVendoredReport.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1`, `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.Tests.ps1`.

#1050 (CI workflows): `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1`, `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` (with `push-down-ci-contract.test-helpers.ts`), `push-down-ci-layer.test.ts`, `push-down-ci-workflows.test.ts`, `push-down-harness.ci-workflows.test.ts`, `extensions/drm-copilot/test/mcp-tool-inputs.push-down-ci-workflows.test.ts`, `push-down-apply-hash-invariant.test.ts`, `push-down-hash-parity.test.ts` (fixture `tests/fixtures/push-down-manifest-hash/corpus.json`).

#1051 (integration tools and skill): under `extensions/drm-copilot/test/lib/push-down-integration/`: `integration-detect.test.ts`, `integration-ecosystems.test.ts`, `integration-end-to-end.test.ts`, `integration-items.test.ts`, `integration-validate-artifacts.test.ts`, `integration-validate.test.ts`, `workflow-yaml-reader-templates.test.ts`, `workflow-yaml-reader.test.ts` (helper `integration-test-helpers.ts`); `extensions/drm-copilot/test/lib/push-down/push-down-integration-needed.test.ts`; `extensions/drm-copilot/test/mcp-handlers/push-down-integration-handlers.test.ts`; `extensions/drm-copilot/test/mcp-push-down-integration-tool-definitions.test.ts`; `extensions/drm-copilot/test/mcp-server.push-down-integration-tools.test.ts`; `extensions/drm-copilot/test/mcp-tool-inputs-push-down-integration-tools.test.ts`; `extensions/drm-copilot/test/packaging/push-down-integration-brief.test.ts`, `push-down-integration-exposure.test.ts`, `push-down-integration-skill.test.ts`; `extensions/drm-copilot/test/push-down-integration-no-model-call.test.ts`; `extensions/drm-copilot/test/repo-automation-service-push-down-integration-tools.test.ts`.

Incoming Pester tests for the P1-T7 Pester acceptance: `Set-CiRequiredChecks.Tests.ps1`, `PoshQC.TestingVendoredReport.Tests.ps1`, `PoshQC.VendoredCoverage.RepoGate.Tests.ps1`, `PoshQC.VendoredCoverage.Tests.ps1`, and the modified `PoshQC.CoverageConfig.Tests.ps1`.
