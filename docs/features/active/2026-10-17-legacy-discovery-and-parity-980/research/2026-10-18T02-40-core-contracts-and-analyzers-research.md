<!-- markdownlint-disable-file -->

# Task Research Notes: Legacy Discovery and Parity Core Contracts and Analyzers

## Research Executed

### File Analysis

- `.github/agents/task-researcher.agent.md`
  - The current canonical agent permits research only in the orchestrator-supplied tracked feature research root and requires this template and a seven-label Pre-Mortem.
- `.agents/skills/execution-environment/SKILL.md`, `.agents/skills/research-issue/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `AGENTS.md`, and the general code, general test, and Python skills.
  - Read before research authoring. No code, test, or checkpoint modification is authorized for this worker.
- `pyproject.toml`
  - Existing discovery commands already cover initialization, profile parsing, inventory, .NET and optional VSTO scanning, seven artifact validators, reports, and acceptance generation. PyYAML is a runtime dependency; jsonschema is an approved development dependency.
- `scripts/dev_tools/validate_discovery_artifacts.py`
  - The existing `all` command validates a single document against alternative artifact types; it does not validate a discovery workspace or cross-artifact references.
- `scripts/dev_tools/validate_discovery_schema_artifacts.py`
  - Validators currently load the schema named by the artifact itself. The artifact-type argument does not select or constrain the schema. Local scheme-less schema paths are rejected, while remote schema fetching is permitted.
- `scripts/dev_tools/discovery/domain_profile.py` and `domain_profile_models.py`
  - Strict version-1 YAML profile parsing exists. Its contract only contains source/target roots, technology-stack labels, and an artifact root/conventions; required roles, dimensions, gate configuration, evidence roots, and immutable repository pins are absent.
- `scripts/dev_tools/validate_discovery_profile.py`, `schema_loading.py`, and `validate_json.py`
  - The standalone discovery-profile validator still checks the obsolete `legacy_source_path` field. The generic schema loader supports HTTP/file locations; the generic JSON validator also has a reduced fallback when jsonschema is unavailable. Neither behavior is an acceptable completion authority for discovery.
- `scripts/dev_tools/discovery/init_models.py`, `init_flow.py`, `init_cli.py`, `io.py`, `rendering.py`, `coverage_report.py`, `parity_report.py`, and `completion_report.py`
  - Existing injected-I/O and pure-rendering seams are reusable. Initialization rejects nonempty directories unless forced, and force writes existing files. Reports expose only small JSON aggregates; parity reads the wrong collection name and completion unconditionally reports ready.
- `scripts/dev_tools/generate_acceptance_scenarios.py`
  - Stable identifier helpers and deterministic serialization exist, but expected input fields and schema paths differ from the committed artifact schemas. Product decisions, unresolved behavior, configured dimensions, and Gherkin output are not implemented.
- `scripts/dev_tools/discovery/analyzer/{models,inventory,pipeline,emitter,cli,stack_cli,dotnet_inventory,source_text,vsto_office,vsto_patterns}.py`
  - The parse/classify/map/emit pipeline and frozen records are reusable. The .NET analyzer performs lexical C# detection; the optional Office analyzer recognizes general framework constructs. Repository/project classification, path containment, read-only execution, and several requested analyzers remain incomplete.
- `schemas/discovery/v1/`, `examples/discovery/v1/`, `docs/discovery/templates/`, and `tests/schemas/discovery/`
  - Seven closed Draft 2020-12 artifact schemas, positive examples, negative fixtures, and conformance tests already exist. There is no profile, scope, inventory-snapshot, or generated-acceptance schema in this versioned directory.
- `tests/scripts/dev_tools/discovery/`, focused top-level discovery validator/generator tests, and `tests/conftest.py`
  - The `mem_fs_path` fixture provides an in-memory pathlib implementation. Several tests encode current placeholder behavior, so preserving those assertions unchanged would preserve defects. Real schema fixtures are available for integration-level contract tests without temporary files.
- `docs/engineering/legacy-discovery-and-parity/{README,domain-profile,artifacts-and-schemas}.md`, `poetry.lock`, and `quality-tiers.yml`
  - Existing documentation must be reconciled with actual execution. jsonschema is locked in the development group, while PyYAML is a main dependency. The current dev-tool tier rationale says these tools are not published by push-down; distributing discovery changes that premise.

### Code Search Results

- `dev.discovery` in `pyproject.toml`
  - Existing registered commands establish that this work is completion and hardening of a present capability, not a new parallel implementation.
- Discovery source, schema, template, test, and documentation paths
  - Located `scripts/dev_tools/discovery/`, `schemas/discovery/v1/`, `docs/discovery/templates/`, `docs/engineering/legacy-discovery-and-parity/`, and focused Python/Pester tests.
- `legacy_source_path`, `SCHEMA_VERSION`, `resolve_discovery_schema`, `entries`, and `readiness`
  - Confirmed profile-validator drift, generator version/path drift, parity `rows` versus report `entries`, and unconditional completion readiness in the functions named below.
- `Roslyn`, `tree-sitter`, `.csproj`, `.sln`, and `.slnx` in dependency manifests and the project inventory
  - No existing compiler-backed analysis dependency or nonfixture .NET project was found in the inspected implementation surface. The current scanner uses Python regular expressions and source masking.
- Product names and application-specific tokens in discovery schemas, templates, and analyzers
  - No TaskMaster/TMW product semantics were found in the inspected core files. Office/VSTO behavior is concentrated in optional analyzer modules, although eager imports and generic helper documentation currently expose that adapter to the common stack surface.
- `enforcement-hooks-no-python-invocation` and `mem_fs_path`
  - Existing tests constrain hook language and prohibit a naive Python call from enforcement hooks; filesystem tests already have an isolated alternative to temporary directories.

### External Research

- #fetch:https://json-schema.org/understanding-json-schema/reference/object
  - `additionalProperties` closes an object within its schema scope; composition requires deliberate treatment of evaluated properties. Keep core fields closed and extension payloads explicitly namespaced rather than allowing arbitrary top-level properties.
- #fetch:https://python-jsonschema.readthedocs.io/en/stable/referencing/
  - The supported referencing API accepts a preloaded immutable registry and does not retrieve remote resources by default. YAML input must use JSON-compatible values. This directly supports an offline, bundled discovery schema catalog.
- #githubRepo:"python-jsonschema/jsonschema referencing Registry"
  - Verified the corresponding primary documentation source at [docs/referencing.rst](https://github.com/python-jsonschema/jsonschema/blob/main/docs/referencing.rst); the modern registry replaces the deprecated resolver approach.
- #fetch:https://pyyaml.org/wiki/PyYAMLDocumentation
  - Safe loading avoids arbitrary Python object construction. It does not by itself establish the stricter JSON-compatible profile contract needed here.
- #githubRepo:"yaml/pyyaml construct_mapping SafeConstructor"
  - [constructor.py](https://github.com/yaml/pyyaml/blob/main/lib/yaml/constructor.py) assigns mapping keys during construction and supports YAML merge processing. A discovery-specific safe loader must explicitly reject duplicate keys and ambiguous merges rather than assume safe loading rejects them.
- #fetch:https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-items
  - Project items have Include/Exclude/Remove expressions, metadata, and conditions. XML detection can report declared facts; it cannot equate them with an evaluated build graph.
- #fetch:https://learn.microsoft.com/en-us/dotnet/core/project-sdk/overview
  - SDK projects include implicit imports and item globs. Inventory must label explicit declarations and implicit SDK conventions separately without executing project evaluation.
- #fetch:https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/get-started/syntax-analysis
  - Roslyn provides full-fidelity syntax trees, including incomplete source. It would improve syntax accuracy, but introduces a compiler dependency absent from this Python toolchain.
- #fetch:https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/work-with-workspace
  - Workspace models include solutions, projects, documents, references, and compilation options. Semantic resolution therefore needs more project/environment context than the current file scanner supplies.
- #githubRepo:"dotnet/roslyn Roslyn-Overview"
  - [Roslyn-Overview.md](https://github.com/dotnet/roslyn/blob/main/docs/wiki/Roslyn-Overview.md) corroborates the syntax/semantic/workspace distinction used in this recommendation.
- #fetch:https://learn.microsoft.com/en-us/visualstudio/vsto/ribbon-xml
  - Ribbon XML and callback signatures are reusable platform constructs. An optional adapter can inventory these declarations without defining application feature semantics.
- #fetch:https://cucumber.io/docs/gherkin/reference/
  - Gherkin supplies feature/scenario structure, ordered Given/When/Then steps, and tags. Execution depends on separately supplied step definitions; generated specifications alone do not prove automated acceptance.
- #fetch:https://docs.python.org/3.10/library/pathlib.html
  - Lexical path operations do not establish resolved containment. Resolve paths and inspect containment after symlink resolution; the cited version matches the repository's minimum Python runtime.
- #fetch:https://lxml.de/parsing.html
  - Parser controls include entity resolution, DTD loading, and network access. The already-approved lxml dependency can parse local project/configuration XML with those capabilities disabled.

### Project Conventions

- Standards referenced: `AGENTS.md`; `.agents/skills/general-code-change/SKILL.md`; `.agents/skills/general-unit-test/SKILL.md`; `.agents/skills/python/SKILL.md`; `.agents/skills/execution-environment/SKILL.md`.
- Instructions followed: research-only writes under this feature's `research/`; no consumer-repository inspection; no nested delegation; no code execution or test changes; recommendations will name existing tests affected by public-contract changes.
- Routing verified: actual SubagentStart attestation for this research worker records `task-researcher-c4`, `gpt-6-astra`, `max`, and `routing_valid: true`, matching the persisted phase receipt.
- Research started: 2026-10-18T02:40:52Z. Canonical issue number: 980.
- Research consolidated: 2026-10-18T02:53:24Z, read from the clock tool. All assigned questions have source-backed findings; the remaining choices are listed for specification authoring.
- Scope boundary: the runtime researcher owns exact customization authoring, publishing, hook registration, MCP, and VS Code integration. This artifact supplies their Python authority and resource-contract requirements; it does not repeat their publishing audit.
- No tests were executed by this research-only worker. Findings are source inspection, existing fixture/test analysis, and external primary-source research, not a claim that current tooling passes the requested acceptance criteria.

## Key Discoveries

### Project Structure

The reusable capability already exists in `scripts/dev_tools/discovery/`, adjacent discovery entry-point modules, `schemas/discovery/v1/`, and `docs/discovery/templates/`. The registered `dev.discovery.*` namespace should remain the public entry point. This is a completion and hardening feature with an explicit artifact-version transition, not a second discovery engine.

The strongest reusable seams are frozen profile/analyzer value objects, pure parsing and rendering, injected filesystem/clock dependencies, existing schema fixtures, and a pipeline separating parsing, classification, mapping, and emission. Repository-specific discovery data belongs in the consuming workspace; this repository should distribute only implementation, schemas, generic templates, and synthetic examples.

### Implementation Patterns

| Verified current behavior | Consequence for the requested feature |
| --- | --- |
| `validate_discovery_profile.validate_profile_text` checks `legacy_source_path`; `domain_profile.parse_domain_profile_text` expects `profile_version`, `legacy_source`, `target`, `technology_stack`, and `artifacts`. | Consolidate on one parser/schema contract. A profile accepted by one entry point must not be rejected or ignored by another. |
| `_validate_against_schema` accepts `artifact_type` but loads the artifact's arbitrary `$schema` instead. It does not pass a base path to the loader. | A weak schema can validate the wrong artifact kind; generated relative references fail through this path. Select schema by trusted expected kind and exact supported version. |
| `_validate_all_text` returns success after the first successful artifact validator. | This is single-document type probing, not complete-workspace validation. Replace the complete command's semantics explicitly and retain a clearly named compatibility path if needed. |
| The generic schema loader permits remote retrieval; generic JSON validation has a limited fallback without jsonschema. | Discovery must fail closed when its full validator or catalog is unavailable and must not retrieve schemas from untrusted artifact locations. Do not weaken unrelated generic tooling. |
| Initialization requires an existing parent and rejects nonempty directories unless `force`; forced initialization writes files with ordinary overwrite semantics. | Add a projected creation plan, dry-run, exclusive no-overwrite writes, skip/conflict reporting, and post-creation structural validation. Deprecate destructive force behavior. |
| Coverage/parity reports count `entries`; parity schemas define `rows`. Completion always sets `readiness` to `ready`. | Render reports from the validated graph, compute real counts, and derive readiness from findings rather than object presence. |
| Acceptance generation looks for `feature_ref`, `given`/`when`/`then`, and scenario collections; committed feature/runtime schemas use other fields. It resolves `schemas/vN` instead of `schemas/discovery/vN`. | Align generation to the authoritative contracts and product decisions. Do not preserve incompatible placeholder fields as a second format. |
| Inventory markers default to `*.solution`/`*.project`; traversal follows directory links through `is_dir`, and filtering happens after traversal. CLI roots are resolved from process working directory. | Add real project suffixes, workspace-relative path policy, early exclusions, containment/cycle checks, and explicit analyzer diagnostics. |
| Analyzer execution always emits records; timestamps come from a fresh injected clock, and some files are reread for hashes after parsing. | Offer read-only/dry-run execution, hash the bytes actually inspected, and distinguish stable content results from deliberately supplied capture metadata. |
| Most existing validators test schema loading through fakes; report tests assert placeholder behavior. | Add real-resource, end-to-end contract tests through public entry points; tests must reject the current false-success cases. |

### Complete Examples

This complete current v1 example is committed at `examples/discovery/v1/feature-contract.example.json` and is covered by `tests/schemas/discovery/test_v1_fixtures.py`. It shows why preserving v1 history is different from claiming the expanded v2 contract is already present. Its `approved` status does not separately encode observational confidence, product approval, and target verification.

```json
{
  "$schema": "../../../schemas/discovery/v1/feature-contract.schema.json",
  "acceptance_criteria": [
    {"id": "criterion-alpha-1", "statement": "The covered unit produces the recorded output for the primary input.", "verification": "automated"},
    {"id": "criterion-alpha-2", "statement": "The covered unit rejects an out-of-range input.", "verification": "characterization"}
  ],
  "description": "Contracted behavior of the primary covered unit observed during discovery.",
  "evidence_refs": ["evidence-alpha-001"],
  "id": "feature-alpha",
  "schema_version": "1.0.0",
  "source_refs": [{"line_end": 42, "line_start": 10, "path": "src/component-a/handler.ext", "symbol": "primary_handler"}],
  "status": "approved",
  "title": "Primary Covered Unit",
  "workflows": [{"id": "workflow-primary", "name": "Primary observation workflow", "steps": ["apply the recorded stimulus", "record the observed behavior"]}]
}
```

### API and Schema Documentation

The seven v1 schema documents use Draft 2020-12, internal `$defs` references, closed top-level fields, and a free-form `metadata` object. Their schema documents declare version `1.0.0`, but artifact `schema_version` accepts any `1.<minor>.<patch>` rather than an explicit supported-version set. `Draft202012Validator` is used without an explicit format checker in the discovery artifact adapter.

| Artifact | Existing v1 contract | Material missing requirements |
| --- | --- | --- |
| Feature contract | ID/title/description, lifecycle-like status, criteria, workflows, source/evidence references, dependencies | Behavioral dimensions, confidence, explicit uncertainty, decision status, target relevance, environment and permissions |
| Coverage ledger | ID/generated time/subject, entries with unit kind/status/feature/evidence links, summary | Repository pin, inspection versus disposition, excluded rationale, tests, runtime requirement, responsible actor |
| Runtime scenario | Single feature, stimulus, observed behavior, observation method, evidence; optional variations/determinism | Draft observation plan, pre/post captures, result state, repeatability, unresolved findings, multiple linked features |
| Parity matrix | Source/target labels, rows with feature/criterion, parity status, verification, evidence/decision references | Immutable repositories/revisions/contracts, implementation references, clients/modes/dimensions, blockers, explicit retirement approval |
| Unspecified behavior | Category, context, open/under-review/resolved, evidence, optional feature/decision link | Competing interpretations, owner, impact, approved target behavior, acceptance implications |
| Product decision | Decision/status/rationale, alternatives, linked features/behaviors, evidence, supersession | Approval metadata, affected platforms, required migration behavior, resulting acceptance criteria |
| Evidence reference | Kind/location/capture time/description; optional content hash/tool/metadata | Repository/revision, structured symbol/lines, environment, author/agent, confidence, runtime artifact distinctions |

Adding the required fields in place would break existing valid artifacts. Recommend a strict v2 family alongside frozen v1 schemas, with explicit readers/migration rather than silently changing v1 semantics. Add profile, scope, inventory snapshot, and structured acceptance specifications to the governed set; any enforcement receipt also needs a versioned contract. Core extensions should be namespaced payloads validated after core validation, never alternate schemas that replace required core fields.

### Configuration Examples

```yaml
# Existing parser-compatible v1 shape, using synthetic values.
profile_version: 1
legacy_source:
  root: src/legacy
target:
  root: src/target
technology_stack:
  legacy: [csharp]
artifacts:
  root: docs/migration/discovery
```

The current shipped profile template substitutes placeholder strings in this shape. It is not the requested role-aware domain profile. A v2 profile should locate production/test/project/documentation/evidence roots, explicit excluded paths with rationale, output roots per artifact kind, analyzer settings, repository relationships and immutable revisions, required clients/platform modes/dimensions, namespaced extensions, and completion-gate policy. All local paths should be workspace-relative and resolve through one path authority. Recommend `docs/migration/discovery/domain-profile.yaml` as the default, with an explicit configured locator for alternative roots; ambiguous multiple profiles must fail rather than select by discovery order.

### Technical Requirements

The assigned research questions resolve as follows. Recommendations in this table are design proposals for the specification author, not descriptions of existing behavior.

| Required research question | Verified answer and resulting recommendation |
| --- | --- |
| 6. Existing JSON Schema infrastructure | Seven discovery schemas and `validate_json`, `schema_loading`, and discovery adapters exist. Reuse Draft 2020-12 and fixture infrastructure, but replace artifact-directed schema selection with a trusted discovery catalog and a full semantic layer. |
| 7. YAML/dependencies | PyYAML is an approved main dependency (`>=6.0`, locked 6.0.3); jsonschema is approved only in the dev group (`^4.25.1`, locked 4.26.0), with referencing locked 0.37.0. Python minimum is 3.10. Publication must include the full validator as a runtime dependency; an optional fallback is insufficient. lxml is already approved for XML. |
| 8. Host service compatibility | Existing Python entry points accept paths and return exit codes; frozen values and injectable I/O support a shared service. Runtime research verifies wrapper distribution and hook transport. The Python API should return structured findings/artifact plans rather than require hosts to parse stdout. |
| 10. Reuse existing skills | Reuse research, feature promotion, evidence/timestamp, atomic planning/execution, acceptance-criteria tracking, review, and publishing mechanisms. Discovery adds artifact-focused operations and a planning prerequisite, not another scheduler or acceptance check-off protocol. |
| 11. Planning/criteria | Existing acceptance tracking updates requirement source checkboxes using implementation evidence. Generated discovery scenarios must remain specifications with stable references; generating or observing a source scenario cannot mark a target implementation criterion complete. A configured discovery gate should precede existing planning. |
| 12. Backward compatibility | Preserve command namespace and v1 readers/fixtures, but explicitly version incompatible schemas/profile and document corrected false-success behavior. Repositories without discovery activation remain unaffected. Explicit discovery commands without a valid profile fail; activated profile deletion or malformation must not silently disable enforcement. |
| 13. Version/migration | Add exact supported `2.0.0` artifact schemas and `profile_version: 2`; do not accept unknown minor versions by regex alone. Provide an explicit, dry-run, no-overwrite migration that retains original hashes and records unknown fields as pending. Never fabricate revisions, approvals, evidence, or expected results to complete migration. v1 structure validity does not establish v2 completion. |
| 14. Cross-platform determinism | Normalize relative output names to POSIX separators, sort paths/keys/findings, use stable content-derived IDs and fixed newline/encoding rules, and inject capture metadata. Resolve containment including directory links, reject platform-specific unsafe paths, detect case collisions, exclude output roots from input traversal, and report unreadable or unsupported sources. |
| 15. Compiler-backed analysis | Existing code is Python lexical analysis; no Roslyn or tree-sitter dependency was found. Reuse the scanner and secure XML parsing for declared facts. Roslyn can improve syntax/semantic precision but requires an additional runtime/package and project-loading context; leave it as an optional future adapter rather than a mandatory dependency. |
| 16. Context injection interaction | Only invoked discovery skills/agents should load profiles, inventories, and selected artifacts. Large catalogs and optional technology adapters do not belong in standing instructions. Runtime publishing research owns the exact routing surfaces. |

The requested analyzers were evaluated individually:

| Analyzer | Current evidence | Recommended scope and confidence boundary |
| --- | --- | --- |
| Repository tree/projects | `inventory.py` walks files, filters globs, hashes content; default project markers are incomplete. | Implement real generic manifest recognition, selected-root inventory, exclusions, diagnostics, and stable source references. File existence/path/hash are detected facts. |
| .NET solutions/projects | The current `dotnet_inventory.py` scans C# rather than solution/project XML. | Add `.sln`, `.slnx`, project, props/targets, project/package references and declared target-framework inventory. Preserve conditions and unresolved expressions; do not execute MSBuild/imported tasks or claim a fully evaluated graph. |
| C# types/symbols | Existing lexical detection covers namespaces, class/struct/interface/enum/record/delegate/event patterns. `source_text.py` masks comments/strings. | Reuse and test this bounded scanner; retain line/symbol references and parser diagnostics. Do not claim binding, overload resolution, preprocessing semantics, or complete syntax coverage. |
| Event subscriptions | Existing `+=`/`-=` recognition is heuristic; arithmetic assignments can match. | Label candidate subscriptions as inferred unless syntax context establishes the fact. Do not infer the event's product behavior. |
| Configuration/settings | No dedicated implementation was found in inspected analyzer modules. | Extract structured JSON/XML keys and recognized settings declarations, retaining source references. Avoid secret values; preserve conditional or unresolved declarations. |
| Filesystem access | No dedicated implementation was found. | Detect known generic I/O API call patterns; a text match is a candidate access, not proof of runtime execution or the actual resolved path. |
| Registry access | No dedicated implementation was found. | Detect generic registry API constructs with source references and platform applicability. No product-specific registry key catalog. |
| COM interop | `vsto_patterns.py`/`vsto_office.py` detect generic attributes, marshal APIs, ProgID activation and project COM references. | Extract reusable COM detection so consumers do not need the Office adapter for generic interop inventory. |
| UI callbacks | Office scanner finds Ribbon-related constructs; no general callback relationship inventory was found. | Add declared XAML/XML callback relationships where syntax is deterministic; unresolved code-behind associations remain inferred. Office Ribbon callback extraction belongs in its optional adapter. |
| Test/component mapping | No dedicated mapping implementation was found. | Use declared test-project references and lexical type references as links. Such links are inferred relevance, never proof of test execution or behavioral coverage. |
| Dependencies | No complete dependency inventory was found. | Read declared project/package/lockfile references locally and report origin/conditions. Do not restore packages or evaluate arbitrary build code. |
| Optional Office/VSTO | Existing adapter recognizes general Ribbon namespaces, Office interop references, COM declarations and selected APIs; XML handling has line-pattern limitations. | Retain only as a lazily loaded, explicitly enabled platform adapter. Evaluate XML callback extraction and generic lifecycle constructs without application-specific requirements or feature IDs. Broader application APIs remain extension work, not required core knowledge. |

No new parsing dependency is justified by these baseline requirements. XML parsing must disable external entities, DTD loading, and network access. A programmatically registered analyzer protocol and validated local result imports can support extensions without importing arbitrary modules or executing commands named in a profile. Extension findings must use the same provenance, uncertainty, and path validation contract.

**Mandatory unachievable objective callout**:
- No requested framework objective was proven unachievable. **Complete semantic C# binding, evaluated MSBuild behavior, runtime parity, and natural-language decision agreement cannot be established by the proposed read-only lexical/XML analyzers alone.** Those claims need compiler/runtime evidence or explicit human adjudication. Analyzer limits must remain visible in reports and cannot be converted into a completion claim.

## Recommended Approach

Extend the existing Python capability into a profile-driven, offline artifact graph. Keep parsing/schema validation, graph invariants, I/O, analysis, rendering, and host adapters separate. Use a common service result containing success, stable coded findings, proposed/written artifact paths, and report data; retain small CLI adapters and the existing command namespace. Hosts must call this authority rather than reimplement its rules.

As a proposed interface boundary, a pure `validate_snapshot(snapshot, *, mode)` operation can serve structural, discovery-completion, parity, and planning checks, while an injected-I/O service loads the profile/resources, creates the snapshot, and performs explicitly requested writes. Keep per-artifact validators as adapters to the same catalog/rules. The public surface should cover the existing operations plus contract/scenario creation, evidence linking, aggregate decision validation, and migration; exact argument names belong in the specification.

The following recommendations require explicit specification decisions:

1. **Separate validation levels.** Structural validation checks parsing, exact versions, expected artifact kinds, profile/path validity, identifier uniqueness, existing references, and the consistency of claims already made. A newly initialized empty workspace can pass this level. Discovery completion additionally requires confirmed scope, a complete inventory-to-ledger mapping, dispositions, required features/evidence/scenarios, and configured runtime requirements. An empty or uninventoried workspace must fail completion. Parity completion checks each required feature/client/mode and its target evidence or approved change/retirement. Planning invokes the configured prerequisite through the existing lifecycle.
2. **Make evidence immutable where claims require it.** Reference source contracts by repository identity, full immutable revision, feature ID, artifact path, and content hash. Evidence needs source/runtime distinctions, optional symbol and one-based inclusive line range, capture metadata, environment, author/agent, confidence, and checksum where applicable. Pin source and target independently, even inside one repository. For separate repositories, validate locally imported source snapshots against a manifest of identities/revisions/hashes; do not authorize arbitrary sibling-repository writes. Include explicit client identifiers for multiple targets.
3. **Use separate state fields.** Observed behavior should distinguish verified, inferred, unknown, contradictory, and intentionally unspecified. Confidence can independently be high/medium/low/unknown. Feature lifecycle and product-decision approval must remain distinct. Inspection state differs from coverage disposition; runtime result differs from repeatability; parity state differs from dimension applicability and verification. Required dimensions cannot be satisfied by an unspecified state. Offline/mobile requirements activate only when declared by the local profile.
4. **Enforce cross-artifact claims.** Verified behavior requires appropriate evidence and no unresolved contradiction; unknown/contradictory behavior requires a linked unresolved record. Passed runtime scenarios need runtime evidence. Required-parity features need acceptance specifications. Exclusions need rationale. Changed/retired target behavior requires approved decisions. Add explicit decision scopes/keys and supersession links so overlapping approved decisions can be detected deterministically; semantic contradictions in prose remain analyst findings.
5. **Use trusted schema ownership.** Expected artifact kind comes from the operation and configured artifact root, not the artifact's `$schema`. Resolve known schema IDs from packaged resources with no network. Reject mismatched kind/version and invalid formats. Existing relative v1 schema aliases can map to the known v1 catalog through a compatibility reader. Namespaced extension schemas may validate their own payload but cannot replace core requirements or relax gates.
6. **Unify safe input and path handling.** Parse JSON and safe YAML into a JSON-compatible value model, rejecting duplicate keys, ambiguous merges, nonfinite values, unsupported YAML types, and excessive resource use. Normalize workspace-relative paths, reject traversal, absolute/drive-relative/UNC/device paths and unsafe names, then verify resolved containment and protected-root separation. Do not rely on lexical prefix comparison. Validate outputs before writing and use no-overwrite creation semantics.
7. **Initialize honest draft artifacts.** Create profile/scope, empty ledger and decision/unresolved collections, and configured directories for contracts, characterization, evidence, inventory, acceptance, reports, and imported source snapshots. Target roles may also initialize a parity collection. Require caller-supplied system/repository context or an explicitly modeled incomplete draft state; do not ship fake evidence, timestamps, approved decisions, or synthetic feature claims in production templates. Plan all operations first, report created/skipped/conflicting files, and validate the projected structure during dry-run. An existing valid file is preserved; incompatible content is reported as a conflict.
8. **Generate specifications from confirmed requirements.** Produce structured acceptance records first and render Gherkin-style Markdown or `.feature` views. Stable IDs link feature/criterion/client/mode and approved decisions; preserve evidence references and separate source characterization from target acceptance. Emit online/offline/mobile tags only according to configured applicability. Unresolved expectations remain explicit pending records with no fabricated `Then`. A pending tag alone must not be treated as an execution skip; only ready scenarios should be emitted as executable cases unless the consuming runner explicitly supports pending semantics. Do not generate implementation-specific test code or check off implementation criteria.
9. **Derive deterministic reports.** Coverage, parity, and completion JSON/Markdown must come from the same validated model, with stable ordering and all requested counts, blockers, warnings, stale/conflicting references, and next actions. Recompute counts instead of trusting authored summary totals. Unconfigured dimensions report not applicable, not failure or implicit success. A remote revision's freshness is unknown unless local immutable evidence permits a deterministic comparison.
10. **Keep enforcement authority outside editable reports.** The no-Python-hook constraint requires a runtime-owned bridge rather than copied PowerShell business logic. A candidate validation receipt must bind the raw profile hash, complete input file set and hashes, source/target pins, gate kind, tool/schema/policy versions, and authority identity. Missing, stale, modified, added, or deleted inputs invalidate it. Store authority outside analyst-writable roots; a report claiming success is not authority. Runtime research must finalize receipt transport, proposed-content validation, activation persistence, and publication packaging before implementation.

#### Rejected alternatives

- **Build a new discovery engine or namespace.** This avoids compatibility work initially but duplicates existing commands, models, fixtures, and publishing surfaces. Extending the current modules has less long-term divergence.
- **Expand v1 schemas in place.** Required new fields would invalidate existing consumers, while optional-only additions would not establish the requested fail-closed contract. Use v2 with explicit migration.
- **Trust each artifact's schema or use generic validator fallback.** This permits weaker validation and nonlocal schema access. A fixed expected-kind catalog is necessary for evidence-backed gates.
- **Require Roslyn/MSBuild for every inventory.** Compiler-backed analysis is useful for semantic questions, but adds unapproved dependencies and environment-sensitive loading to an otherwise local Python workflow. Keep it optional.
- **Encode discovery rules independently in each host/hook.** This would reproduce the drift already observed between profile parsers and validators. Prefer a single Python authority with a narrowly specified runtime bridge.

## Implementation Guidance

- **Objectives**: complete the existing capability, close false-success paths, and keep repository observations, product approvals, target requirements, and implementation verification separate.
- **Key Tasks**: specification and atomic planning should use the candidate boundaries and test mapping below. This research does not prescribe task IDs or modify the orchestration plan.
- **Dependencies**: retain approved PyYAML, jsonschema/referencing, and lxml. Moving the full validator into the published runtime and delivering schemas/templates are required integration changes, not justification for a new parser dependency. Review the dev-tool quality-tier rationale when publication expands its consumers.
- **Success Criteria**: a real initialized workspace passes structure validation; the same workspace fails completion until inventory/scope/coverage/evidence/scenarios satisfy its profile; all entry points agree; invalid claims return stable blocking findings and a nonzero CLI exit status; no network is needed for validation/reporting.

Candidate changes grounded in existing files:

| Responsibility | Existing implementation to extend or adapt | Recommended boundary |
| --- | --- | --- |
| Profiles and version compatibility | `discovery/domain_profile.py`, `domain_profile_models.py`, `profile_cli.py`, `validate_discovery_profile.py` | One parser/catalog per explicit supported version with typed results; retain v1 read compatibility. |
| Schemas and graph validation | `validate_discovery_schema_artifacts.py`, `validate_discovery_artifacts.py`, `schema_loading.py`, `schemas/discovery/v1/` | New `schemas/discovery/v2/`; separate catalog, parsed snapshot, reference/claim rules, completion policy, and findings models. Avoid broad changes to generic schema loading. |
| Initialization/migration | `discovery/init_flow.py`, `init_models.py`, `init_cli.py`, `docs/discovery/templates/` | Separate creation planning from exclusive writes and structural validation; add explicit version migration. |
| Reports/acceptance | `discovery/*_report.py`, `rendering.py`, `io.py`, `generate_acceptance_scenarios.py` | Pure report models/renderers and typed acceptance transform, with thin entry points and shared safe I/O. |
| Analyzer framework | `discovery/analyzer/{models,pipeline,inventory,emitter,cli,stack_cli}.py` | Read-only execution option, immutable source snapshots, validated profile paths, stable diagnostics, declared adapter registry. |
| Language/platform detectors | `dotnet_inventory.py`, `source_text.py`, `vsto_office.py`, `vsto_patterns.py` | Small project/XML, generic I/O/COM/configuration, and test-reference modules; keep Office optional and isolated. |
| Public surface/resources | `pyproject.toml`, existing discovery docs/examples/fixtures | Retain namespace/aliases, add missing operations and runtime resource packaging in coordination with runtime research. |

`source_text.py` has 476 lines, `dotnet_inventory.py` 457, `vsto_office.py` 451, and `domain_profile.py` 408 in the inspected revision. They cannot absorb broad new responsibilities under the 500-line limit; split focused modules during implementation. Proposed module names are intentionally left to specification/atomic planning.

Required tests and existing affected files:

| Test area | Existing files or fixture roots | Required additions/corrections |
| --- | --- | --- |
| Schema/profile versions | `tests/schemas/discovery/test_v1_schema_documents.py`, `test_v1_fixtures.py`; `examples/discovery/v1/`; `tests/fixtures/discovery_schemas/v1/` | Preserve v1 historical fixtures; add real v2 positive/negative cases, exact unsupported-version rejection, domain extensions, formats, and expected-kind ownership. |
| Validator entry points | `tests/scripts/dev_tools/test_validate_discovery_profile.py`, `test_validate_discovery_schema_artifacts.py`, `test_validate_discovery_schema_artifacts_more.py`, `test_validate_discovery_artifacts_dispatch.py` | Replace placeholder-profile expectations; reject weak/remote/wrong-kind schemas, duplicate IDs, broken references, missing evidence, false verified/pass states, missing scenarios/modes, stale pins, conflicting decisions, and malformed activation. |
| Initialization/path safety | `tests/scripts/dev_tools/discovery/test_init_flow.py`, `test_init_cli.py`, `test_init_models.py`, `test_domain_profile.py`, `test_profile_cli.py`, `test_io.py` | First/repeated run, dry-run no writes, preserve files, collisions/races, invalid existing profile, structure-versus-completion, traversal/drive/UNC/case/symlink containment, source/output overlap. |
| Reports and generation | `tests/scripts/dev_tools/discovery/test_coverage_report.py`, `test_parity_report.py`, `test_completion_report.py`, `test_rendering.py`; `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` | Correct parity collection/counts, incomplete empty workspace failure, both formats, deterministic output, ready/pending separation, decisions and client/mode tags, stable traceability. |
| Analyzers | `tests/scripts/dev_tools/discovery/analyzer/` inventory/pipeline/CLI/stack/E2E/.NET/source-text/Office tests | Real manifest fixtures, masks and false positives, XML conditions/entities, source digest consistency, read-only operation, excluded/output roots, ordering, platform paths, generic COM, inferred test mappings, explicit optional adapters. |
| Neutrality and resources | Discovery package/export/neutrality tests and analyzer neutrality tests | No application/product knowledge in core; optional Office adapter stays explicit; packaged schemas/templates available outside the source checkout. |
| Integration with hosts | Runtime research owns exact Pester/TypeScript/conversion tests. | Exercise the authoritative service with no-Python hooks, stale/missing receipts, proposed writes, profile opt-in/opt-out, wrappers, and deployed resource lookup. |

Add a fully in-memory public-path sequence covering initialization, real schema validation, inventory/ledger integration, report generation, acceptance generation, and completion. This catches the current seams hidden by per-module mocks. Use existing `mem_fs_path` or explicit fake readers/writers; no temporary files. Negative tests must cover resource limits, duplicate YAML/JSON keys, unsupported types, deterministic diagnostic ordering, and incomplete plugin results. Final execution must run the prescribed language/repository gates and retain canonical feature evidence; this research did not run them.

Remaining specification decisions are integration details, not unanswered research questions: the exact authority-owned receipt transport; how activated custom profile roots remain enforceable after deletion; deployment/bootstrap of the authoritative Python package and resources; final field names/enumerations and schema IDs; and which optional analyzer adapters ship in the first release. Runtime research supplies the publishing/hook constraints. The specification should choose these explicitly before execution.

## Pre-Mortem

- Review checklists: review may reject superficially present commands that do not satisfy workspace-wide invariants; the plan must map every requirement to exercised behavior.
- Coverage: new graph and path validation branches may miss negative cases; plan pure-function and injected-I/O tests with existing coverage gates.
- Mirror parity: generated and bundled discovery resources can drift; runtime research owns authoritative publication-path and mirror-test mapping.
- File size: existing modules near 500 lines cannot absorb a new validation engine; split by parsing, schema selection, graph rules, I/O, and rendering.
- Test isolation: new initializer/analyzer tests could create temporary files; inject in-memory readers, enumerators, and writers.
- CI-only behavior: path handling can differ across Windows and POSIX hosts; test drive, UNC, traversal, casing, and symlink semantics explicitly.
- Evidence: raw discovery claims can appear verified without immutable evidence; schema and semantic validators must enforce evidence and revision requirements separately from report rendering.
