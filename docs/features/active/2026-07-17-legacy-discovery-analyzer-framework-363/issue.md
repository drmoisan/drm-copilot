# legacy-discovery-analyzer-framework (Issue #363)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-analyzer-framework/ (Issue #363)

- Issue: #363
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/363
- Last Updated: 2026-07-17
- Work Mode: full-feature
- Epic: legacy-discovery-and-parity (child feature #9006, Wave 1, complexity C3)
- Integration branch: epic/legacy-discovery-and-parity-integration
- Depends on: legacy-discovery-config-contract (#360), legacy-discovery-schemas (#359)

## Problem / Why

The legacy-discovery-and-parity epic requires a reusable, domain-neutral way to read a
consumer repository's source and emit machine-readable discovery artifacts. Without a shared
analyzer framework, every stack-specific analyzer (the .NET/C# and VSTO/Office analyzers in
sibling feature #9014, and later skills in #9008) would re-implement the parse -> classify ->
map -> emit pipeline, artifact emission, and CLI wiring independently, reintroducing
duplication and inconsistent artifact shapes. This feature delivers the framework abstraction
plus the first concrete analyzer (repository/project inventory), establishing the contract that
downstream analyzers plug into.

## Proposed Behavior

Deliver a language-neutral analyzer framework and the repository/project inventory analyzer:

1. A base analyzer abstraction/pipeline (parse -> classify -> map -> emit) that a concrete
   analyzer plugs into, modeled on existing repo precedents
   (`scripts/dev_tools/codex_native_converter/` and the subagent-tree transcript parser).
2. A repository/project inventory analyzer (solution/project enumeration, file inventory) that
   reads a consumer repository at the external path declared by the domain profile
   (`legacy_source.root`, honoring `include`/`exclude` globs) via the config-contract loader
   (`scripts/dev_tools/discovery/domain_profile.py`).
3. Analyzer output emitted as artifacts conforming to the relevant discovery JSON schemas
   (feature #9002, `schemas/discovery/v1/`), with the exact schema mapping resolved in spec.
4. One or more `dev.discovery.*` Poetry console-script CLI entry points for the inventory
   analyzer, mapping to `scripts.dev_tools.discovery.<module>:main`.
5. An explicit, justified parsing-strategy specification decision (regex/plain-text is the
   expected choice; no Roslyn/AST/tree-sitter dependency exists in this repository today).

Domain-neutrality is an epic-wide invariant: the framework and inventory analyzer must contain
no TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior. This feature does NOT
implement the .NET/C# or VSTO/Office analyzers (feature #9014).

## Acceptance Criteria (early draft)

The authoritative acceptance criteria for this full-feature work live in `spec.md` and
`user-story.md`. Early-draft summary:

- [ ] A language-neutral analyzer base abstraction/pipeline (parse -> classify -> map -> emit)
      exists and is documented, with a concrete analyzer able to plug into it.
- [ ] The repository/project inventory analyzer enumerates solutions/projects and file
      inventory for a consumer repository located via the domain profile.
- [ ] Analyzer output conforms to the relevant discovery v1 JSON schema(s).
- [ ] A `dev.discovery.*` console-script CLI entry point runs the inventory analyzer.
- [ ] The parsing-strategy decision (regex/plain-text vs AST) is recorded and justified in
      `spec.md`.
- [ ] Framework and inventory production modules contain no domain-specific identifiers.
- [ ] Tests satisfy repository quality-tier policy (pytest, line >= 85%, branch >= 75%, test
      tree mirrors production tree, no temporary files).

## Constraints & Risks

- Domain-neutrality invariant (epic-wide): no domain-specific identifiers in the core
  framework.
- The analyzer reads a CONSUMER repository's source at an external path from the domain
  profile; this repository (drm-copilot) contains no C# source of its own.
- Upstream dependencies (config-contract loader #360, schemas #359) are prepared in parallel
  and are merged into the integration branch before this feature executes; design against
  their contracts (config-contract `spec.md` for the loader API; schemas `spec.md` for the
  `schemas/discovery/v1/` layout and the `schema_version` / `$schema` conventions).
- Parsing strategy: regex/plain-text consistent with repo precedent; a heavy AST dependency is
  out of scope and requires explicit approval.
- File-size limit: no production/test file exceeds 500 lines.

## Test Conditions to Consider

- [ ] Unit coverage: pipeline stage sequencing; inventory enumeration over a fixture repo tree
      (in-memory filesystem); include/exclude glob handling; artifact emission conforms to
      schema; CLI success and error exit codes.
- [ ] Integration scenarios: inventory analyzer end-to-end from a domain profile to a
      schema-conforming artifact.
- [ ] CLI/API examples: `dev.discovery.*` inventory command load-and-emit; non-zero exit on
      malformed profile or unreachable source root.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/legacy-discovery-analyzer-framework/` folder from the template
- [ ] Research, spec, user-story, atomic plan, preflight (preparation mode)
