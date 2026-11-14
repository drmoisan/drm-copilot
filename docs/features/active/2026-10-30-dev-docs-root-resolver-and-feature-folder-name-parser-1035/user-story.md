# `2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production` — User Story

- Issue: #1035 (epic #1018, child 2: Phase 1 of #1016 only; references #1016 and does not close it)
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-10-30
- Spec: `spec.md` in this folder (full #1016 design; Phases 2 and 3 are delivered by epic child 7)

## Story Statement

- As the maintainer of this repository, I want every hook, validator, MCP tool and script to read the development-docs root from one configured key through a resolver in each runtime, so that the later move to `.dev` (epic child 7) is a configuration change plus a mechanical move rather than an edit of every consumer.
- As a maintainer of a destination repository that receives this toolset through push-down, I want the new key to default to `docs/features` and an absent key or file to resolve the same default, so that my repository behaves exactly as before until I choose to migrate.
- As the author of the epic child 3 agent generator, I want one TypeScript rule table and expansion function for agent and hook write-scope literals, with a checker test, so that the generator emits the same literals for each known root and its `--check` mode can reuse the checker.

## Problem / Why

`docs/features/` holds potential entries, active and completed features, an archive, epics, parallel orchestrations, templates and research. It is development-process material in the folder that conventionally holds production documentation, and the same layout is pushed to every destination repository. Issue #1016 separates development documentation (new `.dev/` root) from production documentation (`docs/`).

Today no shared constant exists: TypeScript has `ACTIVE_FEATURE_DOCS_DIRECTORY` and `POTENTIAL_DOCS_DIRECTORY` plus many inlined literals, and Python and PowerShell have per-module constants. Phase 1 introduces the configured key and resolvers with the default unchanged, so later epic children use the resolver and the move in child 7 does not require editing each consumer again.

## Personas & Scenarios

- Persona: Repository maintainer (this repository)
  - Maintains hooks, validators, MCP tools and scripts across Python, PowerShell and TypeScript.
  - Cares about no behavior change in Phase 1, full toolchain passes, and mirror and contract parity.
  - Constraints: no new Python scripts or entry points; enforcement hooks do not invoke Python; execution waits for the parallel run `bugs-1001-1002-1003-1006` to merge.
  - Goal: a single key and resolver per runtime so that no consumer hard-codes `docs/features`.
- Persona: Destination-repository maintainer
  - Receives `.claude/`, `.codex/` and `config/` through the Claude and Codex push-downs.
  - Cares about not having existing workflows broken by an upgrade.
  - Constraints: may not have the routing configuration file, or may have an older copy without the key.
  - Goal: unchanged behavior with the default, and new feature folders named `<NNNN>-<feature>` when an issue number is supplied.
- Persona: Epic child 3 generator author
  - Writes the TypeScript agent generator that emits `.claude/agents/*.md` and `.codex/agents/*.toml`.
  - Cares about a precise, importable contract for write-scope literals.
  - Constraints: Claude Code permission rules and path-limited tool entries cannot read configuration, so literals must be emitted and checked.
  - Goal: import `WRITE_SCOPE_RULES` and `expandWriteScopeLiterals`, emit literals for each known root, and reuse the checker as `--check`.

- Scenario: Maintainer adds a new consumer
  - Trigger: a new hook needs the active-features folder.
  - Steps: the maintainer imports the PowerShell resolver module, calls `Resolve-DevelopmentDocsRoot` and `Get-DevelopmentDocsPath -Area active` for writes, and `Get-DevelopmentDocsKnownRootPattern -Area active` for path matching.
  - Outcome: the hook works under `docs/features` today and under `.dev` after child 7, without further edits.
- Scenario: Destination repository without the key
  - Trigger: the destination maintainer upgrades the extension; the destination's `config/orchestration-routing.json` predates the key, or the file is absent.
  - Steps: hooks and MCP tools resolve the root.
  - Outcome: the resolver returns `docs/features`; behavior is unchanged. A malformed file produces a clear fail-closed reason naming the file and key.
- Scenario: Creating a feature folder from an issue
  - Trigger: `new_active_feature_folder` runs for issue 1016 with a date-first potential record.
  - Steps: the tool strips the date prefix and formats the name from the issue number.
  - Outcome: the folder is `docs/features/active/1016-<feature>`; issue 42 would produce `0042-<feature>`; a request without an issue number keeps the current slug.
- Scenario: Generator author consumes the write-scope contract
  - Trigger: child 3 replaces hand-written agent frontmatter with generated output.
  - Steps: the generator imports the rule table and emits `expandWriteScopeLiterals(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS)` for each rule; the three-direction checker runs as the generator's `--check` assertion.
  - Outcome: every agent carries both the `docs/features` and `.dev` literals during the fallback release, and any scope not produced by a rule fails the check.

## Acceptance Criteria

### Repository maintainer

- [ ] `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` each contain `"development_docs_root": "docs/features"` as a flat top-level entry, and `test_orchestration_routing_config_parity.py` passes.
- [ ] Resolver unit tests in TypeScript (`root.test.ts`), Python (tests for `resolve_development_docs_root` in `json_config.py`) and PowerShell (`DevelopmentDocsRoot.Tests.ps1`) each cover resolution cases R-1 to R-8 in `spec.md` and pass.
- [ ] The Python resolver and parser are added to `scripts/dev_tools/json_config.py` with no new Python file under `scripts/`, no new `pyproject.toml` script entry, and no Python invocation in any enforcement hook.
- [ ] With the default key, the full Python, PowerShell and TypeScript test suites pass, and the only changed expectations in existing tests are the folder-naming and status-line expectations for supplied issue numbers.
- [ ] A recorded repository search over the production roots for `docs/features` returns only the resolver constant definitions and the recorded allowlist of Stay rows, stored under the feature folder's `evidence/` directory.
- [ ] Matcher tests in each runtime show that the feature-folder record validators accept both `docs/features/active/<folder>` and `.dev/active/<folder>` independent of the configured value.
- [ ] `config/ci-docs-only-paths.json` includes `.dev/` and excludes `.dev/templates/`, `.dev/potential/template.md`, `.dev/engineering/` and `.dev/discovery/`, and `CiDocsOnlyPathsConfig.Tests.ps1` asserts that classification and passes.
- [ ] `GOVERNED_GLOBS` in Python and TypeScript contains `.dev/**/*.json` and `docs/**/*.json`, and a test in each runtime finds a JSON file under `.dev/` using in-memory fixtures.
- [ ] Each in-house `RealFileSystem.glob` consumer named in `spec.md` (`iterGovernedFiles`, `json-validator.ts`, `evidence-locations.ts`, `verification-evidence.ts`, `feature-docs-parsers.ts`) has a test that finds a file under `.dev`, the include-dot behavior of `compileGlob` is documented with a test, and `isExcludedDirectoryName(".dev")` is asserted `true`.
- [ ] The new PowerShell module exists with equal text in its Claude, Claude-bundle and Codex source locations; the Codex publication entry exists in TypeScript and the existing Python push-down twin; the Claude and Codex `pack-manifests/core.json` files list it; and the resource-contract, pack-manifest completeness, dependency-closure, `ClaudeLibModuleConvention.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` suites pass.
- [ ] The seven-stage toolchain passes in a single pass for Python, PowerShell and TypeScript; coverage of changed code meets 85% line coverage in every language and 75% branch coverage for Python and TypeScript; no changed production file exceeds 800 lines.
- [ ] A Phase 0 evidence artifact under `evidence/baseline/` records that the parallel run `bugs-1001-1002-1003-1006` has merged and that each overlapping file listed in `spec.md` was re-checked against `origin/main` before any edit.

### Destination-repository maintainer

- [ ] With the routing file absent, or present without the key, every resolver returns `docs/features` (cases R-1 and R-2), asserted in TypeScript, Python and PowerShell.
- [ ] A malformed routing file or an out-of-set value produces an explicit error, and a hook that reads the key fails closed with a reason naming the configuration file and key, asserted by a Pester test.
- [ ] Folder-creation tests in TypeScript and Python show that issue 1016 with potential stem `2026-10-30-foo` creates `<active area>/1016-foo`, issue 42 creates `<active area>/0042-<feature>`, and a request without an issue number keeps the current slug.
- [ ] Parser tests in TypeScript, Python and PowerShell assert cases F-1 to F-6 and N-1 to N-5 in `spec.md`, so existing date-first folders keep parsing alongside the new `<NNNN>-<feature>` format.
- [ ] After this child, the repository contains no `.dev/` directory, `development_docs_root` is `docs/features`, no existing feature folder is renamed, and no migration command is added.

### Epic child 3 generator author

- [ ] `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` exports `WriteScopeArea`, `WriteScopeRule`, `SettingsAllowRule`, `RequiredArtifactRule`, `WRITE_SCOPE_RULES`, `SETTINGS_ALLOW_RULES`, `REQUIRED_ARTIFACT_RULES`, `expandWriteScopeLiterals` and `expandRequiredArtifactPattern` with the signatures in `spec.md`, and imports no `vscode` module.
- [ ] The write-scope checker suite passes forward coverage, reverse coverage and root coverage against `.claude/agents/*.md`, the base `.codex/agents/*.toml` files and `.claude/settings.json`.
- [ ] Each surface in the `spec.md` rule table carries both the `docs/features` and `.dev` forms of its literals with its existing leading-slash spelling, and the `prd-feature` and `epic-review` `-RequiredArtifact` patterns accept paths under both roots.
- [ ] `generate_codex_agent_variants.py --check` reports no drift, and `PINNED_FROZEN_SURFACE_HASHES` is re-baselined with a dated comment for each pinned agent file whose content changes, with the parallel-orchestrator surface tests passing.

## Non-Goals

- The TypeScript migration command, the move of this repository to `.dev`, the `docs/README.md` boundary note, the rename of existing feature folders, the default flip, removal of the fallback, and historical-fixture handling at the flip. These are delivered by epic child 7 under its own child issue.
- Normalizing write-scope spelling (leading slash) across agents; left to epic child 3.
- Preserving a destination's key value across a Codex push-down; recorded for epic child 4.
- Moving `docs/discovery/templates` resources referenced by `build_discovery_runtime.py`.
- Extension and MCP package version bumps (assumed at epic fan-in; OQ-5 in `spec.md`).
- Re-opening any decision D-1 to D-22.
