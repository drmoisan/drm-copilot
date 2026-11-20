# Research: legacy-discovery-documentation (#371)

- Date: 2026-07-17T15-33
- Feature: `docs/features/active/2026-07-17-legacy-discovery-documentation-371/`
- Epic: `legacy-discovery-and-parity` (`docs/features/epics/legacy-discovery-and-parity/epic.md`)
- Deliverable under research: capability-level, end-to-end Markdown documentation only (no production code).
- Authoritative capability scope: `docs/features/epics/legacy-discovery-and-parity/objective-source.md` (sections cited below by heading and scope-item number).

## 1. Existing documentation conventions and placement

### Observed structure of `docs/`

- `docs/engineering/` — durable engineering documentation, flat (no subdirectories, no README index). Contents: `Bugfix Playbook.md`, `Feature Playbook.md`, `claude-code-architecture.md`, `npm-token-rotation.runbook.md`. `claude-code-architecture.md` is the closest precedent for capability-level documentation: a single multi-section document describing an entire capability (four-layer architecture, equivalence tables, sync strategy, validation walkthrough), with numbered `## N.` sections and relative-path references in backticks (`docs/engineering/claude-code-architecture.md:1-60`).
- `docs/features/` — lifecycle planning tree (`potential/`, `active/`, `completed/`, `epics/`, `templates/`, `research/`). `README.md:22` documents this tree as "feature, backlog, and planning documents". Per `docs/features/templates/README.md:11`, shipped feature folders move to archive; this tree is not a durable home for capability documentation.
- `docs/research/` — one-off research notes, `<date>-<slug>-research.md` naming (25 files observed).
- There is no `docs/README.md`, no `docs/engineering/README.md`, and no top-level `docs/*.md` file on this branch (verified by glob: `docs/*.md` returns nothing). Note: `.claude/rules/quality-tiers.md` references `docs/ci.research.md`, which does not exist on this branch — an existing stale reference, not a convention.

### Naming and cross-linking conventions

- Recent `docs/engineering/` files use kebab-case (`claude-code-architecture.md`, `npm-token-rotation.runbook.md`); older files use spaces (`Feature Playbook.md`). New files should use kebab-case.
- Cross-linking style is relative Markdown links (`README.md:14-23`) or backticked repo-relative paths in prose (`docs/engineering/claude-code-architecture.md:5`, `:32`).

### Recommended placement

`docs/engineering/legacy-discovery-and-parity/` — a subdirectory named after the epic slug, containing a `README.md` index plus one page per capability area. Justification:

- `docs/engineering/` is the only durable documentation home; `docs/features/` is lifecycle-scoped and archived after shipping.
- The documentation set spans five distinct areas (workflow, domain-profile authoring, artifact/schema lifecycle, CLI/MCP/VS Code surfaces, consumer onboarding). A README-indexed directory keeps each page focused and gives the later per-feature reference docs (delivered by functional features) stable per-topic link targets. README-indexed directories are established repo practice (`docs/features/templates/README.md`, `scripts/dev_tools/codex_native_converter/README.md`).
- Markdown documentation files are exempt from the 500-line limit (`.claude/rules/general-code-change.md`, File Size Limit), so page size is a readability concern only.

Proposed file set (names indicative, kebab-case):

| File | Covers (issue.md Proposed Behavior item) |
|---|---|
| `README.md` | Index; capability overview; domain-neutrality invariant (item 1) |
| `workflow.md` | End-to-end discovery/parity workflow and artifacts produced (item 1) |
| `domain-profile.md` | Authoring the domain-profile configuration contract (item 2) |
| `artifacts-and-schemas.md` | Seven schemas, versioning convention, validation, completion gates (item 3) |
| `running-the-workflow.md` | CLI `dev.discovery.*`, MCP tools, VS Code commands in lockstep (item 4) |
| `consumer-onboarding.md` | Push-down delivery to consumers; TaskMaster/TMW as examples only (item 5) |

### Rejected alternatives (brief)

- Single file `docs/engineering/legacy-discovery-and-parity.md` (the `claude-code-architecture.md` precedent): simpler, but one file covering five audiences/areas would be very long and gives downstream per-feature docs only anchor-level link targets. Viable fallback if the authored content turns out small.
- `docs/features/epics/legacy-discovery-and-parity/`: rejected; that directory is the epic's planning home (manifest + objective), not durable capability documentation, and the features tree has archive semantics.

## 2. Docs-lint convention

No docs structural/link-check tooling exists in this repository.

- Searched repo-wide for `markdownlint`, `remark`, `linkcheck`, `link-check`, `mdlint` (case-insensitive): matches are incidental strings in research notes, bundled customization mirrors, and extension source; no lint tool, config, or CI step.
- `scripts/dev_tools/` contains `markdown_label_formatter.py` (exposed as `dev.format-markdown`, `pyproject.toml:61`), which formats bold-label spacing; it is not a link or section checker.
- `tests/` contains no generic docs structural test. What does exist is a pattern of targeted Python "contract tests" that assert specific text in specific Markdown files (for example `tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py:72` asserts a template README documents a required section; `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` asserts bundled Markdown mirrors byte-identically).

Consequence for the documentation plan: per `issue.md` ("Tests where applicable: link/section structural checks if the repository has a docs-lint convention; otherwise none"), no tests are required. Optionally, one small pytest contract test asserting the doc set exists with its required top-level sections would be consistent with the existing contract-test precedent, but it is not mandated by any repository convention.

## 3. Upstream child feature presence on this branch

Verified by glob over `docs/features/active/` and `docs/features/completed/` (spec.md enumeration). On the current branch (`drm-copilot-wt-2026-07-17T10-10`):

- **Present:** only `docs/features/active/2026-07-17-legacy-discovery-documentation-371/` (this feature: `issue.md`, `spec.md` [template, unfilled], `user-story.md`, `plan.2026-07-17T15-28.md` [template, unfilled]).
- **Absent (all 13 upstream children):** no `docs/features/active/2026-07-17-legacy-discovery-*` folder exists for #9001–#9012 or #9014, and none appears in `docs/features/completed/`. Each child keeps its own branch/worktree (`epic.md:168-169`), so absence here means the documentation must be authored against planned scope from `objective-source.md`.

Planned scope per absent child — all entries below are planned scope (upstream not present on branch), cited by `objective-source.md` Scope item:

| Child | Placeholder | Planned scope (objective-source.md) |
|---|---|---|
| config-contract | #9001 | Scope 3: repository-local domain-profile config declaring legacy source location, target location, technology stack, artifact conventions; parser decision (PyYAML vs frontmatter regex) |
| schemas | #9002 | Scope 4: seven versioned JSON schemas plus an explicit schema-versioning convention (none exists today) |
| validators | #9003 | Scope 5: deterministic validators for the config and each schema, canonical `validate_<artifact>_text(text) -> list[str]` + argparse subparser CLI |
| hooks | #9004 | Scope 6: PowerShell PreToolUse/SubagentStop hooks enforcing discovery-artifact completion gates by invoking the validators |
| init-templates | #9005 | Scope 7: initialization command and artifact templates scaffolding a consumer's discovery workspace, instantiating each schema |
| analyzer-framework | #9006 | Scope 8 (language-neutral part): repository/project inventory (solution/project enumeration, file inventory) reading consumer source at the domain-profile path |
| agent-roles | #9007 | Scope 1: four domain-neutral personas — Legacy Parity Analyst, Runtime Characterization Analyst, Requirements Reconciler, Migration Coverage Reviewer |
| skills | #9008 | Scope 2: domain-neutral workflow-mechanics skills sequencing discovery/parity, invoking analyzers, producing machine-readable artifacts |
| acceptance-scenarios | #9009 | Scope 11: executable acceptance scenarios generated from feature contracts and parity/characterization evidence |
| reports | #9010 | Scope 12: coverage, parity, and completion reports rendered deterministically from the machine-readable artifacts |
| mcp-vscode | #9011 | Scope 9: MCP tool and VS Code command exposure of the `dev.discovery.*` CLI commands (CLI before MCP before VS Code) |
| publishing | #9012 | Scope 10: mirror all new customization assets into `resources/` subtrees, Codex converter registration if required, push-down pack-manifest selection |
| dotnet-vsto-analyzers | #9014 | Scope 8 (stack-specific part): .NET/C# inventory (namespace/type enumeration, event-subscription detection) and VSTO/Office analyzer (Ribbon-XML, COM-interop detection) |

Documentation implication: every capability claim in the doc set must currently be authored against planned scope and marked or phrased accordingly; where a child ships before documentation authoring completes, the delivered spec supersedes (`issue.md`, Constraints & Risks).

## 4. Domain-profile configuration contract (#9001)

Planned scope (upstream not present on branch); `objective-source.md` Scope 3 and Required Operating Mode:

- A consumer repository authors a repository-local domain profile declaring: legacy source location, target location, technology stack, and artifact conventions (`objective-source.md:65-68`). All domain specificity is supplied at runtime via this profile; the framework hardcodes none of it (`objective-source.md:44-47`).
- Analyzers read consumer-repository source at an external path the profile points at; this repository contains no C# source (`objective-source.md:133-136`).

Open parser decision (Required Research Questions, `objective-source.md:140-141`), verified current state:

- PyYAML is declared at `pyproject.toml:19` (`PyYAML = ">=6.0"`) but unused: no `import yaml`/`from yaml` anywhere under `scripts/` (verified by grep).
- The hand-rolled frontmatter-regex convention is established in `scripts/dev_tools/` (10 files match `frontmatter`, including `resolve_file_prompt.py`, `resolve_execute_plan_prompt.py`, `codex_native_converter/parser.py`, `push_down_claude_customizations.py`).

Documentation consequence: the "authoring your domain profile" page must document the contract fields and authoring guidance, but the parser choice is a #9001 specification decision. The documentation should reference the decided format once #9001 lands and must not restate parser internals (per-feature reference docs belong to #9001).

## 5. Artifact/schema lifecycle (#9002, #9003, #9004)

### Seven schemas and versioning (planned scope, upstream not present on branch)

`objective-source.md` Scope 4: Feature Contract, Coverage Ledger, Runtime Characterization Scenario, Parity Matrix, Unspecified Behavior Record, Product Decision Record, Evidence Reference — seven versioned JSON schemas with an explicit versioning convention. Verified: no `schemas/` directory exists anywhere in the repo today; the versioning convention (directory layout `schemas/vN/`, version field, `$schema` self-reference — `objective-source.md:142-143`) is greenfield and owned by #9002.

### Existing `$schema`/governed-glob machinery (verified)

`scripts/dev_tools/validate_json.py`:

- Every governed JSON instance must declare a `$schema` string; missing `$schema` fails validation (`validate_json.py:197-200`).
- Schema resolution (`_load_schema`, `validate_json.py:130-164`) supports scheme-less relative paths resolved against the instance file's directory, `file://` paths, and cached `http(s)` fetches (cache under `.cache/schemas`). Relative self-reference is therefore already supported — relevant to the `schemas/vN/` + `$schema` self-reference decision.
- Governed globs come from `scripts/dev_tools/json_config.py:12-16`: `scripts/**/*.json`, `docs/**/*.json`, `examples/**/*.json` (excludes at `:19-29`). Discovery artifacts placed under these globs are validated by `dev.validate-json` (`pyproject.toml:69`) with no new loading code, matching the epic shared design (`epic.md:107-110`).
- Validation uses `jsonschema` Draft 2020-12 when available, with a minimal fallback validator otherwise (`validate_json.py:19-23`, `:204-221`).

### Canonical validator pattern (verified)

`scripts/dev_tools/validate_orchestration_artifacts.py` is the reference implementation the epic names (`epic.md:111-113`):

- Pure text validators with signature `validate_<artifact>_text(text) -> list[str]` returning error strings (e.g. `validate_plan_text`, `validate_orchestration_artifacts.py:62`); artifact-specific validators live in their own modules and are imported (`:16-31`).
- A single argparse CLI with one subparser per artifact type (`build_parser`, `:144-200`; `subparsers.add_parser(...)` at `:168-180`), plus opt-in strictness flags (`--require-complete`, `--require-pr-creation-ready`, `--require-model-routing`).

### Hook enforcement (verified conventions; discovery hooks are planned scope)

- `.claude/hooks/` holds the canonical PowerShell hooks (28 scripts), including completion gates such as `validate-orchestrator-output.ps1` and PreToolUse deterrents such as `enforce-model-routing-receipt.ps1` and `enforce-evidence-locations.ps1`.
- Conventions the #9004 hooks must follow (epic shared design, `epic.md:114-116`): `$env:CLAUDE_TOOL_INPUT` / `$env:CLAUDE_HOOK_INPUT` input, JSON stdout decision payloads, dot-source guard, registration in `.claude/settings.json`.
- Documentation consequence: the artifact-lifecycle page should describe the lifecycle as: template instantiation (#9005) -> agent/skill population (#9007/#9008) -> validator checks (#9003, runnable via CLI) -> completion-gate hooks (#9004) blocking progression until validators pass — citing, not duplicating, each feature's own reference docs.

## 6. CLI / MCP / VS Code surfaces (#9011)

### CLI namespace pattern (verified precedent; `dev.discovery.*` is planned)

- Poetry console scripts live in `[tool.poetry.scripts]` (`pyproject.toml:47-69`). The `dev.*` alias namespace is established (`dev.validate-json`, `dev.format-json`, `dev.pr-context`, etc.); each command is one script line mapping to a `scripts.dev_tools.<module>:main` entrypoint. No `dev.discovery.*` entry exists yet; per `epic.md:87-89`, each functional feature ships its own `dev.discovery.*` command (module + one `pyproject.toml` line), and #9011 wraps them.
- User invocation pattern to document: `poetry run dev.discovery.<command> ...` (matching how existing `dev.*` commands run).

### MCP wrapping pattern (verified)

The MCP server source lives in the extension and is republished as a standalone npm package:

- Tool-name registry: `extensions/drm-copilot/src/repo-automation-tool-names.ts` (const array of tool names; e.g. `push_down_claude_customizations`, `validate_orchestration_artifacts`).
- Tool definitions: `extensions/drm-copilot/src/mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts`; dispatch in `mcp-tools.ts`; service-call bodies under `extensions/drm-copilot/src/lib/` (e.g. `lib/push-down/push-down-service-call.ts`).
- Lockstep requirement for new tools (epic shared design, `epic.md:117-119`): tool-names, tool-definitions, dispatch switch, handler, service call all updated together.
- Standalone npm package: `packages/mcp-server/` bundles `extensions/drm-copilot/src/mcp-server.ts` via esbuild (`packages/mcp-server/esbuild-mcp-server.cjs:29`), published for `npx`/global use (`README.md:9`).

### VS Code command pattern (verified)

Extension commands are contributed in `extensions/drm-copilot/package.json` (e.g. `drmCopilotExtension.pushDownClaudeCustomizations` at `package.json:109`) and call the same in-process service the MCP tools call.

Documentation consequence: the "running the workflow" page documents three lockstep invocation surfaces per command — `poetry run dev.discovery.<x>`, MCP tool `<x>` (extension-hosted or `npx` package), VS Code command palette entry — in the order CLI before MCP before VS Code (`objective-source.md:101-104`). Concrete discovery command names are planned scope until the owning features land.

## 7. Push-down / consumer onboarding (#9012)

Verified current machinery (the discovery assets themselves are planned scope):

- Three push-down variants exist as Python CLIs — `scripts/dev_tools/push_down_copilot_customizations.py`, `push_down_codex_and_agents_customizations.py`, `push_down_claude_customizations.py` — and as MCP tools `push_down_copilot_customizations`, `push_down_codex_and_agents_customizations`, `push_down_claude_customizations` (`repo-automation-tool-names.ts:5-7`) and VS Code commands (`extensions/drm-copilot/package.json:101-109`).
- Source of published assets: bundled mirror subtrees under `extensions/drm-copilot/resources/` — `customizations/` (`.github` surface), `claude-customizations/` (`.claude` surface), `codex-and-agents-customizations/` (`AGENTS.md` + `.agents`). Contract tests enforce the mirror: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` requires the bundled `.claude` payload to be byte-identical to the repo `.claude/` tree (agent-memory exempted) and to contain required anchor files.
- Claude push-down is pack-based: manifests at `extensions/drm-copilot/resources/claude-customizations/pack-manifests/` — `core.json`, `python.json`, `typescript.json`, `powershell.json`, `csharp-modern.json`, `csharp-legacy.json`. `core` is always included; the two C# packs are mutually exclusive (`scripts/dev_tools/push_down_claude_pack_selection.py:15-33`, `:394-399`).
- Open decision owned by #9012 (`objective-source.md:148`): whether discovery assets ride in `core` (always pushed) or a new language-neutral pack.
- Codex converter registration: `scripts/dev_tools/codex_native_converter/mapping.py` and `classifier.py` exist; whether new asset categories need registration there is a #9012 research question (`objective-source.md:145-147`).

Documentation consequence: the consumer-onboarding page describes the generic flow — consumer runs the push-down tool (CLI, MCP, or VS Code command) against its workspace and receives the discovery agents, skills, hooks, schemas, and templates from the bundled mirrors — with TaskMaster (legacy source provider) and TMW (modern target provider) used strictly as worked examples (`objective-source.md:32-37`), never as framework behavior.

## 8. Reports and acceptance scenarios (#9010, #9009)

Planned scope (upstream not present on branch):

- Reports (`objective-source.md` Scope 12): coverage report, parity report, and completion report, rendered deterministically from the machine-readable artifacts (coverage ledger, parity matrix, etc.). Determinism is an epic NFR (`epic.md:17`).
- Acceptance scenarios (`objective-source.md` Scope 11): executable acceptance scenarios generated from feature contracts and parity/characterization evidence.

Documentation consequence: the workflow page's "outputs" section presents these as the end-to-end terminal artifacts: discovery artifacts -> validated -> reports rendered + acceptance scenarios generated. Report formats and generator command names are deferred to the owning features' reference docs.

## Recommended approach (summary)

Author a README-indexed capability documentation directory at `docs/engineering/legacy-discovery-and-parity/` with five topic pages (workflow, domain-profile authoring, artifacts-and-schemas, running-the-workflow, consumer-onboarding), kebab-case filenames, relative-path cross-links, and the domain-neutrality invariant stated in the index. All upstream capability behavior is documented against `objective-source.md` planned scope with explicit deferral to each functional feature's reference docs (no duplication), updated to delivered specs where children land first. TaskMaster/TMW appear only in the onboarding page as examples.

### Behavior semantics / success conditions

- Success: a consumer repository engineer can, from this doc set alone plus the per-feature reference docs it links to, (a) author a domain profile, (b) initialize the discovery workspace, (c) run the workflow on any of the three surfaces, (d) understand the seven artifacts and their gates, and (e) receive the capability via push-down. This mirrors the capability-level acceptance criterion "Documentation enables a consumer repository to author a domain profile and run the workflow" (`objective-source.md:161`).
- Failure conditions: domain-specific behavior presented as framework behavior; duplication of per-feature reference content; links to paths that do not exist and are not marked as planned.
- Naming constraint: no collision with the `code-modernization` plugin's `/modernize-*` commands or agent names (`objective-source.md:163-169`); the doc set must not introduce or imply such names.

### Testing implications

- No docs-lint convention exists (section 2), so no tests are required for this feature per `issue.md` scope.
- Optional, consistent with repo precedent: one pytest contract test under `tests/docs/` (mirroring layout policy) asserting the documentation files exist and contain their required top-level sections, in the style of `test_minor_audit_acceptance_criteria_contracts.py`. Recommend deferring this decision to planning; it is not repository-mandated.
- Markdown files are exempt from the 500-line limit (`.claude/rules/general-code-change.md`).

### Risks

- Wave-4 timing: this feature depends on #9008, #9011, #9012, none present on this branch. If documentation is authored before those children merge to the integration branch, every command name, schema path, and pack decision documented is provisional; the plan should include a final reconciliation pass against the integration branch before PR.
- Stale-reference precedent (`docs/ci.research.md` referenced but absent) shows unlinked-path drift is a real failure mode here; the doc set should prefer linking to files that exist at authoring time and marking the rest as planned.
