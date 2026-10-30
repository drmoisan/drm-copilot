# `2026-10-17-legacy-discovery-and-parity` — User Story

- Issue: #980
- Owner: drmoisan
- Status: Remediation cycle 2 implemented on `feature/legacy-discovery-and-parity-980`: the capability probe proves sentinel consumption from the exclusive `.consumed` latch the sentinel tool writes beside the observation record, which is never rewritten (Phase 17, closing Blocker R5 of the 2026-10-30T10-19 review; the root-grant Minor and the shell-observation Nit are deferred to follow-up issues #1007 and #1008 by user decision); Phase 18 re-runs the gates for the touched languages; 65 of 66 criteria checked; independent re-review (AC-64) and exact-head CI pending (see `completion-report.md`)
- Last Updated: 2026-10-30T12-13

## Story Statement

- As a legacy-system maintainer, I want reusable agents and deterministic tools to inventory components, document observed behavior, characterize runtime results, and expose uncertainty, so that migration requirements remain traceable to evidence.
- As a modernization owner, I want pinned source contracts, explicit product decisions, client-specific parity, and linked acceptance specifications, so that implementation planning and completion depend on verified requirements rather than inferred legacy behavior.

## Problem / Why

Repositories modernizing existing applications need a repeatable way to discover observable behavior, inventory features and workflows, characterize runtime behavior, track implementation inspection, and define source-to-target parity. Undocumented, contradictory, inferred, and intentionally unspecified behavior must remain explicit rather than becoming invented target requirements.

Develop a reusable, domain-neutral `legacy-discovery-and-parity` capability in `drm-copilot`. The framework supplies workflow mechanics, schemas, agents, skills, validators, hooks, templates, analyzers, CLI commands, MCP tools, publishing support, and documentation. Structured artifacts are authoritative; Markdown reports are generated views where practical. Observed facts, inferred behavior, product decisions, target requirements, and implementation status remain separate.

Source observations, target decisions, and verification records belong to the consuming repositories. The framework provides reusable mechanics and enforcement; the separated case study in [spec.md](spec.md#separated-consumer-case-study-and-publication-handoff) identifies future consumers without inspecting them or supplying their feature catalogs.


## Personas & Scenarios

| Persona | Motivation, constraints, and expected outcome |
| --- | --- |
| Legacy maintainer | Needs a complete component/workflow inventory despite incomplete documentation; may have only manual runtime access; requires evidence-backed facts, explicit unknowns, and no production-code changes by research agents. |
| Runtime investigator | Must reproduce behavior across declared environments and compare pre/post state; cannot assert an expected result before observing it; needs repeatable scenarios and attributable runtime evidence. |
| Product/decision owner | Must resolve contradictions or intentionally unspecified behavior; needs competing interpretations, impact, approval provenance, and target acceptance implications separated from legacy observations. |
| Target implementer | Works from an immutable source revision, possibly in another repository and for several clients; needs approved requirements, implementation references, parity gaps, and ready/pending specifications. |
| Migration reviewer | Must detect uninspected, excluded-without-rationale, unresolved, or unverified required behavior; needs deterministic reports and gates that cannot be satisfied by editable success JSON. |
| Framework maintainer | Publishes one canonical capability to three coding-agent ecosystems; needs installed-runtime/resource verification, native role restrictions, thin wrappers, and unchanged behavior for nonparticipating repositories. |

1. **Initialize and inventory.** A maintainer installs the published runtime and native assets, supplies the local identity/role/roots, and previews initialization. Dry-run changes nothing; normal initialization preserves existing valid files and reports conflicts. The initialized draft passes structural validation but fails completion until scope, inventory, dispositions, and evidence are supplied. Inventory reports source references and inferred links without marking components inspected merely because they were detected.
2. **Extract a feature with uncertainty.** A maintainer invokes `extract-feature-contract` for selected components. The root obtains existing provider/model routing and a protected discovery invocation without promoting a new feature. The analyst reads source/tests/docs through restricted read tools, writes only controlled artifact outputs, records verified and inferred observations separately, and creates unresolved records for unknown/contradictory dimensions. Attempts to run a shell or modify source/configuration/authority are denied; valid incremental output may finish while other discovery work remains incomplete.
3. **Characterize runtime behavior.** An investigator supplies an environment, fixture, actions, and observation plan. A first run with an unknown expected result records `observed` and evidence, never `passed`. Later comparison against a known expectation requires runtime evidence and pre/post captures. A repository without runtime capability can retain not-run/blocked scenarios; it cannot satisfy a configured runtime-required feature by inventing a result.
4. **Adjudicate and reconcile.** A decision owner reviews competing interpretations and explicitly approves target behavior with rationale and approval evidence. The reconciler preserves the observed source contract, imports a pinned/hash-verified source snapshot into the target, and records parity per feature/client/mode. Missing implementation, conflicting approved decisions, changed source bytes, or unmatched source pins remain blocking findings. A later documentation-only source commit does not invalidate an intentional historical source pin.
5. **Generate specifications and plan.** Confirmed requirements produce stable linked acceptance records, platform/mode tags, and ready Gherkin scenarios. Unresolved behavior remains pending without a fabricated expected result; offline/mobile tags appear only when configured. Generating specifications does not check off implementation criteria. A configured planning gate requires the current protected discovery/parity receipt before the existing atomic-planning lifecycle proceeds.
6. **Review, recover, and publish.** The reviewer produces coverage/parity/completion JSON and Markdown with explicit failures and next actions. Added/deleted artifacts, modified evidence, malformed configuration, deleted activation/profile files, forged reports, and stale or replayed grants invalidate authority. Unsupported or disabled native enforcement prevents controlled-agent launch. Nonparticipating repositories keep their current workflows, and the maintainer verifies all three generated bundles plus the independently installed Python runtime before publication.

The authoritative full-feature acceptance sources are this file and [spec.md](spec.md). [requirements-traceability.md](requirements-traceability.md) maps the 66 requested criteria, 22 deliverables, 15 functional areas, and 16 research questions to implementation and verification responsibility. All checkboxes remain unchecked during specification authoring.


## Acceptance Criteria

### Core framework
- [x] A reusable legacy discovery and parity framework exists in `drm-copilot`.
- [x] Core content contains no TaskMaster- or TMW-specific behavior.
- [x] Configuration is loaded from a local domain profile.
- [x] Repositories not using discovery remain unaffected.
### Agents and skills
- [x] All required generic agents are implemented and validated.
- [x] All required generic skills are implemented and validated.
- [x] Agents cannot write outside authorized paths.
- [x] Every new agent has a SubagentStop output validator.
- [x] Agent and skill assets are available across supported ecosystems.
### Schemas and artifacts
- [x] All required schemas exist and are versioned.
- [x] Valid examples pass validation.
- [x] Invalid examples fail with actionable messages.
- [x] Cross-artifact references are validated.
- [x] Extensions cannot bypass core required fields.
### Initialization
- [x] A deterministic command initializes a consumer discovery workspace.
- [x] Initialization is idempotent.
- [x] Dry-run is supported.
- [x] Existing files are not silently overwritten.
- [x] The initialized workspace validates successfully.
### Validation and reporting
- [x] Individual artifact validators exist.
- [x] A complete validation command exists.
- [x] Blocking failures return nonzero exit codes.
- [x] Markdown and JSON reports are generated.
- [x] Completion checks coverage, evidence, unresolved behavior, acceptance scenarios, and configured platform dimensions.
### Hooks
- [x] Verified claims require evidence.
- [x] Unknown behavior requires an unresolved-behavior record.
- [x] Passed runtime scenarios require runtime evidence.
- [x] Completion fails for in-scope components without disposition.
- [x] Required platform dimensions cannot remain unspecified.
- [x] Implementation planning can be gated on discovery completion.
### Analyzers
- [x] A generic repository/project inventory analyzer exists.
- [x] At least one meaningful C#/.NET analyzer exists.
- [x] Output is deterministic and machine-readable.
- [x] Findings include source references.
- [x] Facts are distinguished from inference.
- [x] Analyzer fixtures and tests exist.
### CLI, extension, and MCP
- [x] Python is the authoritative implementation layer.
- [x] CLI commands are documented and tested.
- [x] MCP exposes appropriate discovery functions.
- [x] VS Code commands/wrappers are added where justified.
- [x] Wrappers do not duplicate business logic.
- [x] Workspace path safety is enforced.
### Cross-ecosystem publishing
- [x] Canonical assets publish correctly to Claude Code.
- [x] Canonical assets publish correctly to Codex.
- [x] Canonical assets publish correctly to GitHub Copilot.
- [x] Publishing/conversion validation covers the assets.
- [x] Generated outputs contain no unsupported references.
### Acceptance scenarios
- [x] Confirmed contracts generate linked acceptance scenarios.
- [x] Platform-mode tags are supported.
- [x] Offline/mobile tags are supported when configured.
- [x] Unresolved behavior does not become a false expected result.
- [x] Scenarios preserve contract and decision traceability.
### Documentation
- [x] Architecture and ownership boundaries are documented.
- [x] A consumer setup guide exists.
- [x] Schema/status semantics are documented.
- [x] Extension-versus-local placement is documented.
- [x] A source/target repository workflow is documented.
- [x] TaskMaster/TMW appear only in a separated example/case study.
### Quality
- [x] Applicable Python quality gates pass.
- [x] Applicable TypeScript quality gates pass.
- [x] Applicable PowerShell quality gates pass.
- [x] Applicable C# quality gates pass for any C# additions.
- [x] All tests pass.
- [ ] Feature review reports no blocking defects.
- [x] Evidence is stored in canonical feature evidence locations.
- [x] Documentation and generated customization outputs are current.


## Non-Goals

Do not inspect or modify consuming repositories, implement their feature contracts, assign domain-specific feature IDs, decide their target architecture, encode application-specific requirements, create a full application UI-testing framework, or store their catalogs/evidence in this repository. Do not duplicate the existing orchestration engine, maintain divergent ecosystem implementations, or weaken security/quality gates.

This release generates test specifications rather than implementation-specific automated test code. Static analyzers do not prove semantic C# binding, evaluated MSBuild behavior, runtime execution, natural-language agreement, or actual test coverage. Compiler-backed analysis and local characterization automation remain optional consumer/future-adapter work. No core behavior depends on Office/VSTO or other application-specific semantics; an existing platform analyzer remains an explicitly selected isolated adapter.
