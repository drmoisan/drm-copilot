# Phase 0 policy and requirement baseline

Timestamp: 2026-10-18T03-48
Command: poetry run python SCRATCH/issue-980-policy-baseline.py
EXIT_CODE: 0
Output Summary: Read 27 policy/requirement/research/plan inputs; verified identical 66-criterion sections, seven DoD items, and twelve seeded conditions; inventoried 2068 tracked code/script files. No production or test modification precedes this baseline.

Task: P0-T1
Work Mode: full-feature
HEAD: 58e5001c5907d74ee24f205690d891b4352fda23
Plan SHA256 before execution: 30b38d8442bfcc81a64aa1a2e3460ed76ed256de8c0871fe935aea2a8da7c489
Preflight: Required MCP validator and branch-current plan validator passed.
Execution identity: atomic-executor-c4; actual external SubagentStart attestation confirms gpt-6-astra/max and routing/provenance/launch authority validity.

## Policy Order

Standing guidance precedes general code, general unit-test, then applicable Python, TypeScript and PowerShell policies. Shared execution, evidence and acceptance contracts govern the approved plan. Legacy split language policy paths are superseded by the consolidated language skills. No policy is changed.

## Files read

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.agents/skills/policy-compliance-order/SKILL.md`
- `.agents/skills/general-code-change/SKILL.md`
- `.github/instructions/general-code-change.instructions.md`
- `.agents/skills/general-unit-test/SKILL.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.agents/skills/python/SKILL.md`
- `.agents/skills/python-suppressions/SKILL.md`
- `.agents/skills/typescript/SKILL.md`
- `.agents/skills/typescript-suppressions/SKILL.md`
- `.agents/skills/powershell/SKILL.md`
- `.agents/skills/quality-tiers/SKILL.md`
- `.agents/skills/architecture-boundaries/SKILL.md`
- `.agents/skills/self-explanatory-code-commenting/SKILL.md`
- `.agents/skills/atomic-executor/SKILL.md`
- `.agents/skills/atomic-plan-contract/SKILL.md`
- `.agents/skills/acceptance-criteria-tracking/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/issue.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/spec.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/user-story.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/requirements-traceability.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/research/2026-10-18T02-40-core-contracts-and-analyzers-research.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/research/2026-10-18T02-40-runtime-publishing-research.md`

## Requirements inventory

- AC-01: A reusable legacy discovery and parity framework exists in `drm-copilot`.
- AC-02: Core content contains no TaskMaster- or TMW-specific behavior.
- AC-03: Configuration is loaded from a local domain profile.
- AC-04: Repositories not using discovery remain unaffected.
- AC-05: All required generic agents are implemented and validated.
- AC-06: All required generic skills are implemented and validated.
- AC-07: Agents cannot write outside authorized paths.
- AC-08: Every new agent has a SubagentStop output validator.
- AC-09: Agent and skill assets are available across supported ecosystems.
- AC-10: All required schemas exist and are versioned.
- AC-11: Valid examples pass validation.
- AC-12: Invalid examples fail with actionable messages.
- AC-13: Cross-artifact references are validated.
- AC-14: Extensions cannot bypass core required fields.
- AC-15: A deterministic command initializes a consumer discovery workspace.
- AC-16: Initialization is idempotent.
- AC-17: Dry-run is supported.
- AC-18: Existing files are not silently overwritten.
- AC-19: The initialized workspace validates successfully.
- AC-20: Individual artifact validators exist.
- AC-21: A complete validation command exists.
- AC-22: Blocking failures return nonzero exit codes.
- AC-23: Markdown and JSON reports are generated.
- AC-24: Completion checks coverage, evidence, unresolved behavior, acceptance scenarios, and configured platform dimensions.
- AC-25: Verified claims require evidence.
- AC-26: Unknown behavior requires an unresolved-behavior record.
- AC-27: Passed runtime scenarios require runtime evidence.
- AC-28: Completion fails for in-scope components without disposition.
- AC-29: Required platform dimensions cannot remain unspecified.
- AC-30: Implementation planning can be gated on discovery completion.
- AC-31: A generic repository/project inventory analyzer exists.
- AC-32: At least one meaningful C#/.NET analyzer exists.
- AC-33: Output is deterministic and machine-readable.
- AC-34: Findings include source references.
- AC-35: Facts are distinguished from inference.
- AC-36: Analyzer fixtures and tests exist.
- AC-37: Python is the authoritative implementation layer.
- AC-38: CLI commands are documented and tested.
- AC-39: MCP exposes appropriate discovery functions.
- AC-40: VS Code commands/wrappers are added where justified.
- AC-41: Wrappers do not duplicate business logic.
- AC-42: Workspace path safety is enforced.
- AC-43: Canonical assets publish correctly to Claude Code.
- AC-44: Canonical assets publish correctly to Codex.
- AC-45: Canonical assets publish correctly to GitHub Copilot.
- AC-46: Publishing/conversion validation covers the assets.
- AC-47: Generated outputs contain no unsupported references.
- AC-48: Confirmed contracts generate linked acceptance scenarios.
- AC-49: Platform-mode tags are supported.
- AC-50: Offline/mobile tags are supported when configured.
- AC-51: Unresolved behavior does not become a false expected result.
- AC-52: Scenarios preserve contract and decision traceability.
- AC-53: Architecture and ownership boundaries are documented.
- AC-54: A consumer setup guide exists.
- AC-55: Schema/status semantics are documented.
- AC-56: Extension-versus-local placement is documented.
- AC-57: A source/target repository workflow is documented.
- AC-58: TaskMaster/TMW appear only in a separated example/case study.
- AC-59: Applicable Python quality gates pass.
- AC-60: Applicable TypeScript quality gates pass.
- AC-61: Applicable PowerShell quality gates pass.
- AC-62: Applicable C# quality gates pass for any C# additions.
- AC-63: All tests pass.
- AC-64: Feature review reports no blocking defects.
- AC-65: Evidence is stored in canonical feature evidence locations.
- AC-66: Documentation and generated customization outputs are current.

### Definition of Done

- Acceptance criteria documented and mapped to tests or demos
- Behavior matches acceptance criteria in all documented environments
- Tests updated/added (unit/integration as applicable)
- Edge cases and error handling covered by tests
- Docs updated (README, docs/features/active/... links)
- Telemetry/logging added or updated (if applicable)
- Toolchain pass completed (format → lint → type-check → test)

### Seeded conditions

- Schema and version validation: valid/invalid synthetic artifacts, required fields, invalid enums, protected core fields, and supported domain extensions.
- Cross-artifact validation: duplicate IDs, broken references, source contracts, revision pins/staleness, conflicting decisions, unresolved-versus-verified behavior, and missing evidence.
- Completion gates: undispositioned coverage, exclusion rationale, unknown/contradictory records, runtime pass evidence, required scenarios, configured dimensions, and planning prerequisites.
- Initialization: first run, repeat run, dry-run, conflicts, no overwrite, neutral templates, and successful initialized-structure validation.
- Analyzers: repository/.NET/C# synthetic fixtures, facts versus inference, source references, deterministic ordering, exclusions, plugins, and read-only operation.
- Reports: coverage/parity/completion structural assertions or intentional snapshots, counts, blockers, warnings, next actions, and consistent Markdown/JSON.
- Scenario generation: stable feature/scenario IDs, evidence/decision linkage, platform tags, conditional offline/mobile tags, and pending unresolved expectations.
- Agent and hook validation: authorized output roots, production mutation denial, per-agent SubagentStop, missing/malformed profile fail-closed behavior, and inactive-repository compatibility.
- CLI/API examples: noninteractive initialization/inventory/artifact creation/evidence linking/individual and complete validation/reporting/scenario generation, actionable errors, and nonzero blocking exits.
- Integration: thin MCP and VS Code wrappers, authoritative Python invocation, workspace path traversal/symlink safety, and cross-platform paths/line endings.
- Publishing: canonical-source conversion/push-down representation for Claude Code/Codex/Copilot, bundle parity, hook/templates coverage, and unsupported-reference rejection.
- Applicable complete language/repository quality loops, coverage and isolation checks, and final full feature review.

## Existing implementation and physical lengths

Complete baseline inventory and file hashes: `initial-file-inventory.2026-10-18T03-48.json`. Bundle copies are identified separately. Existing discovery code remains at scripts/dev_tools/discovery with adjacent validator/generator adapters, schemas/discovery/v1, shared extension/MCP wrappers, native hooks and libraries. No dedicated discovery-runtime package exists yet.

| File | Physical lines |
| --- | ---: |
| .claude/hooks/enforce-discovery-artifact-gate.ps1 | 239 |
| .claude/hooks/validate-discovery-artifact-gate.ps1 | 255 |
| .claude/lib/discovery-validation/DiscoveryValidation.psm1 | 500 |
| extensions/drm-copilot/src/discovery-command-registration.ts | 364 |
| extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts | 214 |
| extensions/drm-copilot/src/mcp-handlers/discovery-handlers.ts | 69 |
| extensions/drm-copilot/src/mcp-tool-inputs-discovery.ts | 246 |
| extensions/drm-copilot/src/repo-automation-execute-discovery.ts | 454 |
| extensions/drm-copilot/test/extension.discovery-commands.test.ts | 282 |
| extensions/drm-copilot/test/mcp-server.discovery.test.ts | 303 |
| extensions/drm-copilot/test/mcp-tool-inputs-discovery.test.ts | 296 |
| extensions/drm-copilot/test/mcp-tools.discovery.test.ts | 288 |
| extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts | 438 |
| extensions/drm-copilot/test/repo-automation-service.discovery.test.ts | 155 |
| scripts/dev_tools/atomic_executor/plan_discovery.py | 124 |
| scripts/dev_tools/discovery/__init__.py | 37 |
| scripts/dev_tools/discovery/analyzer/__init__.py | 53 |
| scripts/dev_tools/discovery/analyzer/__main__.py | 12 |
| scripts/dev_tools/discovery/analyzer/cli.py | 163 |
| scripts/dev_tools/discovery/analyzer/dotnet_inventory.py | 457 |
| scripts/dev_tools/discovery/analyzer/emitter.py | 80 |
| scripts/dev_tools/discovery/analyzer/inventory.py | 231 |
| scripts/dev_tools/discovery/analyzer/models.py | 174 |
| scripts/dev_tools/discovery/analyzer/pipeline.py | 150 |
| scripts/dev_tools/discovery/analyzer/source_text.py | 476 |
| scripts/dev_tools/discovery/analyzer/stack_cli.py | 214 |
| scripts/dev_tools/discovery/analyzer/vsto_office.py | 451 |
| scripts/dev_tools/discovery/analyzer/vsto_patterns.py | 87 |
| scripts/dev_tools/discovery/completion_report.py | 269 |
| scripts/dev_tools/discovery/coverage_report.py | 207 |
| scripts/dev_tools/discovery/domain_profile.py | 408 |
| scripts/dev_tools/discovery/domain_profile_models.py | 152 |
| scripts/dev_tools/discovery/init_cli.py | 66 |
| scripts/dev_tools/discovery/init_flow.py | 91 |
| scripts/dev_tools/discovery/init_models.py | 81 |
| scripts/dev_tools/discovery/io.py | 156 |
| scripts/dev_tools/discovery/parity_report.py | 208 |
| scripts/dev_tools/discovery/profile_cli.py | 154 |
| scripts/dev_tools/discovery/rendering.py | 101 |
| scripts/dev_tools/validate_discovery_artifacts.py | 258 |
| scripts/dev_tools/validate_discovery_profile.py | 118 |
| scripts/dev_tools/validate_discovery_schema_artifacts.py | 189 |
| scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1 | 138 |
| tests/schemas/discovery/test_v1_fixtures.py | 114 |
| tests/schemas/discovery/test_v1_schema_documents.py | 244 |
| tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 | 381 |
| tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | 229 |
| tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | 89 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 368 |
| tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1 | 67 |
| tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | 420 |
| tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | 89 |
| tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1 | 75 |
| tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 | 476 |
| tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 | 163 |
| tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 | 485 |
| tests/scripts/dev_tools/atomic_executor/test_plan_discovery.py | 114 |
| tests/scripts/dev_tools/discovery/__init__.py | 0 |
| tests/scripts/dev_tools/discovery/analyzer/__init__.py | 0 |
| tests/scripts/dev_tools/discovery/analyzer/test_cli.py | 201 |
| tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py | 91 |
| tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py | 410 |
| tests/scripts/dev_tools/discovery/analyzer/test_emitter.py | 205 |
| tests/scripts/dev_tools/discovery/analyzer/test_inventory.py | 226 |
| tests/scripts/dev_tools/discovery/analyzer/test_inventory_e2e.py | 119 |
| tests/scripts/dev_tools/discovery/analyzer/test_models.py | 144 |
| tests/scripts/dev_tools/discovery/analyzer/test_pipeline.py | 143 |
| tests/scripts/dev_tools/discovery/analyzer/test_source_text.py | 325 |
| tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py | 212 |
| tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py | 129 |
| tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py | 474 |
| tests/scripts/dev_tools/discovery/test_completion_report.py | 200 |
| tests/scripts/dev_tools/discovery/test_coverage_report.py | 175 |
| tests/scripts/dev_tools/discovery/test_domain_neutrality.py | 76 |
| tests/scripts/dev_tools/discovery/test_domain_profile.py | 452 |
| tests/scripts/dev_tools/discovery/test_init_cli.py | 129 |
| tests/scripts/dev_tools/discovery/test_init_flow.py | 275 |
| tests/scripts/dev_tools/discovery/test_init_models.py | 94 |
| tests/scripts/dev_tools/discovery/test_io.py | 88 |
| tests/scripts/dev_tools/discovery/test_package_exports.py | 47 |
| tests/scripts/dev_tools/discovery/test_parity_report.py | 175 |
| tests/scripts/dev_tools/discovery/test_profile_cli.py | 180 |
| tests/scripts/dev_tools/discovery/test_rendering.py | 86 |
| tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py | 120 |
| tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py | 415 |
| tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py | 195 |
| tests/scripts/dev_tools/test_validate_discovery_profile.py | 38 |
| tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py | 142 |
| tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py | 63 |

## Baseline concerns and applicability

No C# production addition is planned. C# text under analyzer fixtures is input data, not a new runtime requiring C# build gates. If implementation adds compiled C#, its gates become applicable.

Full language baseline executions are pending P0-T2 through P0-T4. No formatter, linter, type checker, test or coverage success is asserted by this input inventory. Existing defects documented in research remain unverified implementation gaps, not new failures introduced by this feature.

Tracked code/script files above 500 physical lines before implementation: 27. Raw fixture exceptions remain separately identifiable in the JSON inventory; any changed nonexempt file must meet the approved cap.
- `extensions/drm-copilot/test/extension.workflow-commands.test.ts`: 800 lines.
- `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts`: 508 lines.
- `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-structures.test.ts`: 514 lines.
- `scripts/dev_tools/agentic_sync.py`: 819 lines.
- `scripts/dev_tools/atomic_executor/plan_parser.py`: 669 lines.
- `scripts/dev_tools/atomic_executor/qc_runner.py`: 571 lines.
- `scripts/dev_tools/fix_all.py`: 628 lines.
- `scripts/dev_tools/pr_context/github.py`: 549 lines.
- `scripts/dev_tools/push_down_copilot_customizations.py`: 504 lines.
- `scripts/dev_tools/resolve_execute_plan_prompt.py`: 586 lines.
- `scripts/dev_tools/resolve_file_prompt.py`: 619 lines.
- `tests/conftest.py`: 660 lines.
- `tests/scripts/dev-tools/run-actionlint.Tests.ps1`: 523 lines.
- `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`: 512 lines.
- `tests/scripts/dev-tools/tree.Tests.ps1`: 501 lines.
- `tests/scripts/dev_tools/atomic_executor/test_plan_parser.py`: 675 lines.
- `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py`: 695 lines.
- `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`: 665 lines.
- `tests/scripts/dev_tools/test_agentic_sync.py`: 586 lines.
- `tests/scripts/dev_tools/test_atomic_executor_cli.py`: 790 lines.
- `tests/scripts/dev_tools/test_collect_commit_context.py`: 622 lines.
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`: 533 lines.
- `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py`: 537 lines.
- `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`: 650 lines.
- `tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py`: 550 lines.
- `tests/scripts/dev_tools/test_resolve_file_prompt.py`: 553 lines.
- `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`: 766 lines.
