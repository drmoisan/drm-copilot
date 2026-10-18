# legacy-discovery-and-parity (Issue #980)

- Date captured: 2026-10-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-and-parity/ (Issue #980)

- Issue: #980
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/980
- Last Updated: 2026-10-18
- Work Mode: full-feature

## Problem / Why

Repositories modernizing existing applications need a repeatable way to discover observable behavior, inventory features and workflows, characterize runtime behavior, track implementation inspection, and define source-to-target parity. Undocumented, contradictory, inferred, and intentionally unspecified behavior must remain explicit rather than becoming invented target requirements.

Develop a reusable, domain-neutral `legacy-discovery-and-parity` capability in `drm-copilot`. The framework supplies workflow mechanics, schemas, agents, skills, validators, hooks, templates, analyzers, CLI commands, MCP tools, publishing support, and documentation. Structured artifacts are authoritative; Markdown reports are generated views where practical. Observed facts, inferred behavior, product decisions, target requirements, and implementation status remain separate.

The immediate consumers are `drmoisan/TaskMaster` as legacy source and `drmoisan/TMW` as modernization target. Their content belongs in their own repositories. They are a separately documented case study only; this feature neither inspects nor modifies those repositories.

## Proposed Behavior

Treat this as one large, cross-cutting feature. Follow the standard lifecycle: promote/create an active feature folder; perform repository and external research; author a detailed specification; produce an atomic implementation plan; delegate task-by-task implementation to appropriate specialists; run applicable language and repository quality gates; perform feature review; and produce complete evidence and handoff documentation. Persist orchestration state after every material phase and task transition. Do not implement in the orchestrator or modify canonical policy files outside established authoring and push-down mechanisms.

**1. Generic agent roles**

- Legacy Parity Analyst: systematically inspect a legacy repository, identify observable features/workflows, extract behavior without implementation proposals, classify verified/inferred/contradictory/unknown/intentionally unspecified behavior, maintain source/test/documentation/runtime traceability, and update contracts/coverage. It must neither make product decisions nor change production source.
- Runtime Characterization Analyst: define repeatable fixtures, preconditions, actions, observations, pre/post-state captures, runtime evidence, confidence, and environment dependencies. Support manual, semi-automated, and automated characterization without inventing unknown expected results.
- Requirements Reconciler: compare legacy contracts with target implementation records, maintain evidence-backed parity, classify missing/partial/conflicting/intentionally changed/retired behavior, and preserve observed-versus-approved behavior separation.
- Migration Coverage Reviewer: verify discovery completeness, component inspection/disposition, required-feature evidence/scenarios, and representation of unknown behavior in unresolved-behavior or product-decision records. Fail closed on incomplete required discovery.
- Apply repository model routing, tool allowlists, memory scope, hooks, output validation, and a SubagentStop validator to every new agent.

**2. Generic skills**

Provide `inventory-legacy-system`, `extract-feature-contract`, `characterize-runtime-behavior`, `reconcile-parity-matrix`, `review-discovery-coverage`, `adjudicate-unspecified-behavior`, `generate-acceptance-scenarios`, `initialize-discovery-workspace`, and `validate-discovery-artifacts`. Each declares explicit inputs, exact permitted output locations or configured roots, fail-closed missing-configuration behavior, deterministic artifacts where practical, and specialist routing. Publish through existing Claude Code, Codex, and GitHub Copilot mechanisms without domain assumptions.

**3. Repository-local configuration contract**

Define and justify a conventional profile path, provisionally `docs/migration/discovery/domain-profile.yaml`. Support system name/role (legacy source or modernization target), production/test/documentation/evidence roots, solution/project entry points, required platforms/modes, domain extensions, analyzer settings, excluded paths, output roots, source/target repository references, required feature dimensions, and completion gates. Read configuration rather than hard-code consumer paths. Supply schema, validation, initialization template, separate example, and documentation.

**4. Versioned machine-readable schemas**

Prefer JSON Schema unless research establishes a stronger repository convention. Domain extensions must preserve all core validation. Provide:

- Feature Contract: schema version, feature ID/name/group/summary, trigger, preconditions, inputs, state transitions, observable outputs, side effects, ordering/timing, cancellation/failure/offline behavior, mobile/alternate-client applicability, environment constraints, security/permissions, source/runtime evidence, confidence, unresolved questions, product-decision status, target relevance, and domain metadata.
- Coverage Ledger: repository revision, discovered components/types, paths/symbols, inspection status, disposition, linked contracts/tests, runtime-validation requirement, exclusions/rationale, responsible workflow/agent, and last-updated evidence.
- Runtime Characterization Scenario: scenario ID, feature links, environment, fixture, preconditions, action, observation plan, pre/post-state captures, expected result when known, result status, deviations, evidence, repeatability, confidence, and unresolved findings.
- Parity Matrix: source/target repositories and pinned revisions, feature ID, source contract, target implementation, overall/dimension-specific parity, offline/mobile status, evidence, intentional deviations, retirement decision, blockers, and validation status.
- Unspecified Behavior Record: behavior ID, feature link, question, evidence, competing interpretations, impact, status, decision owner, decision/rationale, approved target behavior, and acceptance-test implications.
- Product Decision Record: decision ID, linked features/unspecified behaviors, decision/rationale/alternatives, affected platforms, required migration behavior, approval metadata, and resulting acceptance criteria.
- Reusable Evidence Reference: type, repository/revision, path/symbol/line range, runtime artifact, timestamp, environment, checksum where applicable, author/agent, confidence, and notes.

**5. Deterministic validators**

Provide equivalents of `dev.discovery.validate-profile`, `validate-feature-contract`, `validate-coverage-ledger`, `validate-runtime-scenario`, `validate-parity-matrix`, `validate-decisions`, and `validate-all`. Detect malformed artifacts, unsupported versions, duplicate IDs, broken references, missing evidence, invalid statuses/confidence, unresolved behavior marked verified, parity without source contracts, required-parity features without acceptance scenarios, missing platform classifications, coverage without disposition, exclusion without rationale, conflicting decisions, and deterministically detectable stale revisions. Complete validation emits Markdown and JSON and exits nonzero on blocking failures.

**6. Configurable completion gates and hooks**

Prevent research agents from modifying production code. Require evidence for verified contracts, runtime evidence for passed runtime scenarios, and unspecified-behavior records for unknown/contradictory behavior. Require all in-scope component dispositions and acceptance scenarios for required features. Require online/offline/mobile classifications only for dimensions declared required by the profile. Gate implementation planning when configured discovery completion remains incomplete. Malformed configuration fails closed; each new agent has SubagentStop output validation.

**7. Initialization and templates**

Provide `dev.discovery.init` or a convention-aligned equivalent. Initialization is idempotent, supports dry-run, never silently overwrites content, reports created/skipped/conflicting files, and validates the resulting workspace. Production templates contain no domain-specific sample values. A proposed structure is:

```text
docs/migration/discovery/
  domain-profile.yaml
  scope.yaml
  coverage-ledger.json
  unspecified-behaviors.yaml
  product-decisions.yaml
  feature-contracts/
  characterization/
  evidence/
  reports/
```

Research may justify a different conventional structure. Keep documented synthetic fixtures separate from production templates.

**8. Generic static analyzers**

Implement at least repository/project inventory and one meaningful C#/.NET analyzer. Evaluate and implement where practical: tree/project inventory; .NET solutions/projects; C# types/symbols; event subscriptions; configuration/settings; file-system and registry access; COM interop; UI callbacks; test-to-production reference mapping; dependencies. Outputs are deterministic, machine-readable, source-referenced, read-only/dry-run capable, usable by coverage workflows, and explicit about detected facts versus inferred interpretations. Support local plugin/enrichment configuration.

Evaluate a reusable Office/VSTO analyzer that recognizes generic Ribbon XML/callbacks, interop references, `ThisAddIn`, COM events, item types, and MAPI access without product semantics. This is an optional analyzer evaluation, not permission to add Office-specific behavior to the core. Evaluate existing dependencies and simpler parsing before adding Roslyn or other heavy parsing dependencies.

**9. CLI, extension, and MCP integration**

Python is authoritative. Use a coherent convention-aligned namespace equivalent to `dev.discovery.init`, `inventory`, `new-contract`, `new-scenario`, `link-evidence`, `validate`, `coverage-report`, `parity-report`, and `generate-acceptance`. Expose individual validators and complete validation. VS Code and standalone MCP provide appropriate thin workspace-facing wrappers. Require validated workspace-relative paths, actionable errors, deterministic outputs, noninteractive agent invocation, and Python/wrapper tests.

**10. Cross-ecosystem publishing**

Use the existing canonical-source, generation, conversion, validation, and push-down architecture for agents, skills, rules, prompts, hooks, templates, and documentation. Publish to Claude Code, Codex, and GitHub Copilot. Do not manually maintain divergent implementations. Prove representation and absence of unsupported generated references with publishing/conversion tests.

**11. Acceptance-scenario generation**

Generate Gherkin-style Markdown or `.feature` specifications from confirmed contracts and product decisions. Preserve feature/scenario IDs, platform/mode/offline/mobile tags where applicable, evidence and decision traceability, and pending unresolved behavior. Distinguish legacy characterization, target acceptance, and implementation-specific automated tests. Generate test specifications rather than implementation-specific test code unless a later local implementation workflow explicitly requests it.

**12. Deterministic reports**

- Discovery Coverage: total, inspected, excluded, blocked, undispositioned components; feature-contract/runtime-characterization coverage; evidence completeness; unresolved behavior count.
- Parity: total/full/partial/missing/intentionally changed/retired features; online/offline/mobile verification; blockers; unresolved decisions.
- Discovery Completion: pass/fail, blocking findings, warnings, stale/conflicting references, incomplete artifacts, and next actions.
- Emit Markdown and JSON for each report.

**13. Documentation**

Document architecture, ownership boundaries, installation/push-down, initialization, profiles, artifact lifecycle, agent responsibilities, workflow examples, validators, hooks, schema extensions, evidence rules, and the source/target model. Provide architecture diagram, example consuming-repository structure, setup guide, status semantics, and maintainer guidance. Any TaskMaster/TMW example is clearly separated and noncanonical.

**14. Testing**

Cover schemas, valid/invalid fixtures, references, duplicate IDs, initialization idempotency/dry-run/conflicts, reports, analyzers, hooks, agent outputs, CLI, MCP, justified extension commands, conversion/push-down, path safety, malformed configuration, Windows, and applicable cross-platform behavior. Use synthetic fixtures; a deliberately added small licensed example requires explicit documentation. Follow repository isolation, coverage, file-size, and complete quality-gate requirements.

**15. Non-goals**

Do not implement consumer feature contracts, inspect/modify TaskMaster or TMW, encode Outlook product requirements, define consumer target architecture, build a full Outlook UI test framework, add domain-specific feature IDs, store migration evidence/catalogs authoritatively in this repository, duplicate orchestration logic, maintain divergent ecosystem implementations, or weaken fail-closed quality/security policies.

**Ownership and supported deployment shapes**

`drm-copilot` owns reusable agents, skills, standing rules, schemas, validators, hooks, templates, analyzers, initialization, commands, MCP/VS Code wrappers, publishing, and framework documentation. A legacy repository owns its profile/scope/contracts/coverage/runtime characterization/evidence/unspecified behavior/legacy architecture and local characterization tools. A target repository owns architecture decisions, implementation records, authoritative parity, acceptance/offline/mobile tests, implementation evidence, and target tools.

Support one repository containing source and target; separate source/target repositories; no runtime characterization capability; manual or automated runtime evidence; optional offline/mobile dimensions; and multiple target clients. Prefer thin composable modules, deterministic local analysis, no external-service requirement for validation/reports, and context loaded only on relevant workflow invocation.

**Required research before implementation**

Investigate using actual repository evidence and external primary sources:

1. Authoring/publishing of current agents, skills, hooks, schemas, CLI, MCP, and VS Code commands.
2. The canonical customization surface.
3. Conversion handling for agents, skills, rules, hooks, and templates.
4. Feature-folder and evidence-location conventions.
5. Hook context and configuration transport.
6. Existing JSON Schema infrastructure.
7. Existing YAML parsing/validation dependencies.
8. MCP creation/validation/reporting/analyzer invocation patterns.
9. Existing output validators.
10. Existing reusable skills to avoid duplication.
11. Atomic-planning/acceptance-tracking integration for discovered criteria.
12. Backward compatibility for repositories not using discovery.
13. Schema versioning and future artifact migration.
14. Determinism across Windows, Linux, and macOS.
15. Roslyn/compiler-backed C# analysis versus simpler parsing and existing dependencies.
16. Avoidance of unnecessary context injection for nonparticipants.

**Required specification decisions**

Decide final capability name; canonical locations; agent names/responsibilities; skill names/inputs; schema format/versioning; status/confidence enumerations; extensions; local configuration; evidence format; validation/hooks/analyzers architecture; CLI naming; MCP/VS Code exposure; publishing; backward compatibility; future schema migration; completion defaults; optional-dimension activation; scenario generation; discovery versus implementation acceptance-criteria check-off; and immutable source-revision references in target parity.

**Required deliverables**

1. Active feature documentation.
2. Repository and external research artifact.
3. Detailed specification.
4. Atomic implementation plan.
5. New/updated agents.
6. New/updated skills.
7. Versioned schemas.
8. Deterministic validators.
9. Configurable hooks.
10. Generic templates.
11. CLI tooling.
12. Generic analyzers.
13. MCP integration.
14. VS Code integration where justified.
15. Cross-ecosystem publication support.
16. Comprehensive tests.
17. User and maintainer documentation.
18. Discovery architecture diagram.
19. Example consuming-repository structure.
20. Final feature audit.
21. Completion report with acceptance-criteria status.
22. Follow-on handoff describing exact local TaskMaster and TMW work after publishing.

## Acceptance Criteria (early draft)

**Core framework**

- [ ] A reusable legacy discovery and parity framework exists in `drm-copilot`.
- [ ] Core content contains no TaskMaster- or TMW-specific behavior.
- [x] Configuration is loaded from a local domain profile.
- [ ] Repositories not using discovery remain unaffected.

**Agents and skills**

- [ ] All required generic agents are implemented and validated.
- [ ] All required generic skills are implemented and validated.
- [ ] Agents cannot write outside authorized paths.
- [ ] Every new agent has a SubagentStop output validator.
- [ ] Agent and skill assets are available across supported ecosystems.

**Schemas and artifacts**

- [x] All required schemas exist and are versioned.
- [x] Valid examples pass validation.
- [x] Invalid examples fail with actionable messages.
- [x] Cross-artifact references are validated.
- [x] Extensions cannot bypass core required fields.

**Initialization**

- [ ] A deterministic command initializes a consumer discovery workspace.
- [x] Initialization is idempotent.
- [x] Dry-run is supported.
- [x] Existing files are not silently overwritten.
- [x] The initialized workspace validates successfully.

**Validation and reporting**

- [ ] Individual artifact validators exist.
- [ ] A complete validation command exists.
- [ ] Blocking failures return nonzero exit codes.
- [ ] Markdown and JSON reports are generated.
- [x] Completion checks coverage, evidence, unresolved behavior, acceptance scenarios, and configured platform dimensions.

**Hooks**

- [ ] Verified claims require evidence.
- [ ] Unknown behavior requires an unresolved-behavior record.
- [ ] Passed runtime scenarios require runtime evidence.
- [ ] Completion fails for in-scope components without disposition.
- [ ] Required platform dimensions cannot remain unspecified.
- [ ] Implementation planning can be gated on discovery completion.

**Analyzers**

- [ ] A generic repository/project inventory analyzer exists.
- [ ] At least one meaningful C#/.NET analyzer exists.
- [ ] Output is deterministic and machine-readable.
- [ ] Findings include source references.
- [ ] Facts are distinguished from inference.
- [ ] Analyzer fixtures and tests exist.

**CLI, extension, and MCP**

- [ ] Python is the authoritative implementation layer.
- [ ] CLI commands are documented and tested.
- [ ] MCP exposes appropriate discovery functions.
- [ ] VS Code commands/wrappers are added where justified.
- [ ] Wrappers do not duplicate business logic.
- [ ] Workspace path safety is enforced.

**Cross-ecosystem publishing**

- [ ] Canonical assets publish correctly to Claude Code.
- [ ] Canonical assets publish correctly to Codex.
- [ ] Canonical assets publish correctly to GitHub Copilot.
- [ ] Publishing/conversion validation covers the assets.
- [ ] Generated outputs contain no unsupported references.

**Acceptance scenarios**

- [ ] Confirmed contracts generate linked acceptance scenarios.
- [ ] Platform-mode tags are supported.
- [ ] Offline/mobile tags are supported when configured.
- [ ] Unresolved behavior does not become a false expected result.
- [ ] Scenarios preserve contract and decision traceability.

**Documentation**

- [ ] Architecture and ownership boundaries are documented.
- [ ] A consumer setup guide exists.
- [ ] Schema/status semantics are documented.
- [ ] Extension-versus-local placement is documented.
- [ ] A source/target repository workflow is documented.
- [ ] TaskMaster/TMW appear only in a separated example/case study.

**Quality**

- [ ] Applicable Python quality gates pass.
- [ ] Applicable TypeScript quality gates pass.
- [ ] Applicable PowerShell quality gates pass.
- [ ] Applicable C# quality gates pass for any C# additions.
- [ ] All tests pass.
- [ ] Feature review reports no blocking defects.
- [ ] Evidence is stored in canonical feature evidence locations.
- [ ] Documentation and generated customization outputs are current.

## Constraints & Risks

- Existing authoring, generation, publishing, hook, and MCP conventions require research; proposed paths/names are requirements candidates rather than claims about existing implementations.
- Domain catalogs and runtime evidence remain consumer-owned. Do not inject them into standing instructions or core templates.
- Preserve separation of observed facts, inferences, approved decisions, target requirements, and implementation status. Unknown results remain pending.
- Optional offline/mobile/runtime requirements depend on the local profile. Missing/malformed required configuration fails closed without affecting nonparticipants.
- Pin source/target revisions and detect stale references when deterministic; do not claim validation can establish unknown external state.
- Evaluate heavy parsing/compiler dependencies before adoption and document analyzer confidence/limitations.
- Keep core validation/reporting local and independent of external services. Validate workspace-relative paths and authorized output roots across platforms.
- Do not modify canonical policy files except through established policy-authoring/push-down mechanisms. Preserve existing security and quality gates.
- Completion requires every blocking acceptance criterion, applicable repository gate, review, and evidence requirement to pass. The final report must identify limitations and unresolved follow-on work without claiming unverified completion.

## Test Conditions to Consider

- [ ] Schema and version validation: valid/invalid synthetic artifacts, required fields, invalid enums, protected core fields, and supported domain extensions.
- [ ] Cross-artifact validation: duplicate IDs, broken references, source contracts, revision pins/staleness, conflicting decisions, unresolved-versus-verified behavior, and missing evidence.
- [ ] Completion gates: undispositioned coverage, exclusion rationale, unknown/contradictory records, runtime pass evidence, required scenarios, configured dimensions, and planning prerequisites.
- [ ] Initialization: first run, repeat run, dry-run, conflicts, no overwrite, neutral templates, and successful initialized-structure validation.
- [ ] Analyzers: repository/.NET/C# synthetic fixtures, facts versus inference, source references, deterministic ordering, exclusions, plugins, and read-only operation.
- [ ] Reports: coverage/parity/completion structural assertions or intentional snapshots, counts, blockers, warnings, next actions, and consistent Markdown/JSON.
- [ ] Scenario generation: stable feature/scenario IDs, evidence/decision linkage, platform tags, conditional offline/mobile tags, and pending unresolved expectations.
- [ ] Agent and hook validation: authorized output roots, production mutation denial, per-agent SubagentStop, missing/malformed profile fail-closed behavior, and inactive-repository compatibility.
- [ ] CLI/API examples: noninteractive initialization/inventory/artifact creation/evidence linking/individual and complete validation/reporting/scenario generation, actionable errors, and nonzero blocking exits.
- [ ] Integration: thin MCP and VS Code wrappers, authoritative Python invocation, workspace path traversal/symlink safety, and cross-platform paths/line endings.
- [ ] Publishing: canonical-source conversion/push-down representation for Claude Code/Codex/Copilot, bundle parity, hook/templates coverage, and unsupported-reference rejection.
- [ ] Applicable complete language/repository quality loops, coverage and isolation checks, and final full feature review.

## Next Step

Specification handoff: [spec.md](spec.md) records the detailed decisions; [user-story.md](user-story.md) completes the user scenarios; [requirements-traceability.md](requirements-traceability.md) maps all 66 criteria and 22 deliverables. The [core research](research/2026-10-18T02-40-core-contracts-and-analyzers-research.md) and [runtime research](research/2026-10-18T02-40-runtime-publishing-research.md) are sufficient for atomic planning. These documents define implementation requirements and do not claim delivery or check off acceptance criteria.

- [ ] Promote to GitHub issue (feature request template).
- [ ] Create the active feature folder through the standard promotion lifecycle, using the returned issue number and canonical folder name.
- [ ] Complete all 16 research questions before specification/implementation decisions.
- [ ] Delegate detailed specification and user story, then atomic planning and validation-only preflight before task-by-task execution.
- [ ] Complete implementation, quality gates, acceptance-criteria check-off, feature review, evidence, and lifecycle completion validation.
- [ ] Deliver a concise final implementation summary with architectural decisions, added files/components, commands, supported ecosystems, quality results, limitations, compatibility impact, exact publishing/push-down steps, exact TaskMaster-local artifacts, exact TMW-local artifacts, and unresolved follow-on work.
