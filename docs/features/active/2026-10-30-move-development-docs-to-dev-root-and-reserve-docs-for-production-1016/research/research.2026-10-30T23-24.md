# Research: #1016 Phases 2 and 3 (epic #1018 child 7) - migration command, move to `.dev`, feature-folder rename, default flip

- Issue: #1016 (adopted by child 7, owner decision E1)
- Epic: #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 7, wave 4
- Branch: `feature/dev-docs-root-migration-phases-2-3-1016`
- Mode: preparation, research only. No production file was changed.
- Settled inputs (cited, not re-derived): `docs/features/potential/promoted/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production.md` (D-1 to D-22); child 2 (#1035) `spec.md`, `research/research.2026-10-30T21-15.md` and `plan.2026-10-30T17-11.md` under `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/` (key `development_docs_root`, resolvers, area map, writer/matcher split, R-1 to R-8, parser F-1 to F-6, formatter N-1 to N-5, D-16 write-scope contract). Child 2 is not implemented on this branch; this note consumes its contracts as specified.
- Method: Read, Grep and Glob against the branch tree. Facts that need `git`, `git ls-files`, `git show` or `gh` are marked **ORCHESTRATOR-CONFIRM**. No line numbers or commit identifiers are cited.
- Filename stamp: the task-researcher has no clock tool; the stamp in this filename was not read from the host clock. **ORCHESTRATOR-CONFIRM** and rename if the convention must hold strictly.

## 1. MCP server package anatomy and the files a new tool touches

### Verified anatomy

- `packages/mcp-server` has no TypeScript source. `packages/mcp-server/esbuild-mcp-server.cjs` bundles `../../extensions/drm-copilot/src/mcp-server.ts` into `out/mcp-server.js` (CommonJS, `node18`, banner `#!/usr/bin/env node`) and shims `vscode` to `{}`. The extension has its own `extensions/drm-copilot/esbuild-mcp-server.cjs` with entry `src/mcp-server.ts`.
- `packages/mcp-server/prepack.cjs` copies `extensions/drm-copilot/resources` into the package, excluding `.py` files and the resources-root `scripts/` subtree.
- `packages/mcp-server/package.json`: name `@danmoisan/drm-copilot-mcp`, version `1.1.23`, one `bin` entry `"drm-copilot-mcp": "out/mcp-server.js"`, `files: ["out/mcp-server.js", "resources"]`, scripts `build` and `prepack`. A `bin` entry for `npx` exists today, and it is the MCP stdio server.
- `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` asserts with `toEqual` that `files` is exactly `["out/mcp-server.js", "resources"]` and `bin` is exactly `{ "drm-copilot-mcp": "out/mcp-server.js" }`, and that both esbuild configs keep their entry point and the `vscode` shim. `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` tests `prepack.cjs`. `packages/mcp-server` has no test runner and no coverage configuration.
- `.github/workflows/publish-mcp-npm.yml` runs `npm --prefix packages/mcp-server ci`, `run prepack`, `run build` and publishes; `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` pins it.
- Server: `createRepoAutomationMcpServer` in `extensions/drm-copilot/src/mcp-server.ts` registers `ListToolsRequestSchema` (returns `listRepoAutomationTools()`) and `CallToolRequestSchema` (checks `isRepoAutomationToolName`, builds a service with `createRepoAutomationService`, calls `dispatchRepoAutomationTool`). `main()` runs when `require.main === module`.
- Registration chain for one tool:
  1. Name: `REPO_AUTOMATION_TOOLS` in `src/repo-automation-tool-names.ts` (ordered `as const` tuple; type `RepoAutomationToolName`).
  2. Schema: `REPO_AUTOMATION_TOOL_DEFINITIONS` in `src/mcp-repo-automation-tool-definitions.ts` (spreads `POSHQC_TOOL_DEFINITIONS`, `HANDOFF_TOOL_DEFINITIONS`, `DISCOVERY_TOOL_DEFINITIONS` from sibling modules). A second list, `toolDefinitions` in `src/mcp-tool-definitions.ts`, is the extension surface; `mcp-repo-automation-tool-definitions.test.ts` asserts the definition names equal `REPO_AUTOMATION_TOOLS` in order and that shared names have the same properties and `required` arrays on both lists.
  3. Input resolution: `src/mcp-tool-inputs.ts` and per-family modules (`mcp-tool-inputs-subagent-tree.ts`, `mcp-tool-inputs-push-down.ts`, `mcp-tool-inputs-discovery*.ts`, `mcp-tool-inputs-potential-to-issue.ts`).
  4. Handler: `src/mcp-handlers/*.ts` (for example `feature-entry-handlers.ts` `handleNewActiveFeatureFolder` resolves input and calls the service).
  5. Dispatch: the `switch (toolName)` in `dispatchRepoAutomationTool` (`src/mcp-tools.ts`); errors become `ok: false` results through `toFailureToolResult`.
  6. Service: `RepoAutomationService` interface in `src/repo-automation-service-contract.ts`; implementation `DefaultRepoAutomationService` in `src/repo-automation-service.ts` (451 lines) delegates to `src/lib/**/...-service-call.ts` helpers (for example `newActiveFeatureFolderServiceCall`). The service holds an injected `FileSystem` (`src/lib/file-system.ts`) and `CommandRunner` (`src/lib/subprocess-runner.ts`).
- Precedent: `migrate_discovery_artifacts` is an existing migration-style tool (name list, `mcp-discovery-authority-tool-definitions.ts`, `mcp-tool-inputs-discovery-authority.ts`, `mcp-handlers/discovery-handlers.ts` `handleMigrateDiscoveryArtifacts`, `repo-automation-service-discovery.ts` `migrateDiscoveryArtifacts`, extension command `drmCopilotExtension.migrateDiscoveryArtifacts`).
- MCP tools run the installed package: `.mcp.json` launches `npx -y @danmoisan/drm-copilot-mcp` (unpinned) and `.codex/config.toml` pins `@danmoisan/drm-copilot-mcp@1.1.23`. A tool added on a branch is not reachable through `mcp__drm-copilot__*` until a release is published and installed (execution-environment brief, `## MCP Surfaces Run the Installed Extension`).

### Recommended shape for `migrate_development_docs`

TypeScript only (D-9, D-17; epic language rule: MCP command). No module imports `vscode`.

| File | Change | Classification |
| --- | --- | --- |
| `extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts` (new) | ordered subtree map (section 5) and `mapLegacyPath` | TS, MCP tool core |
| `.../development-docs-migration/folder-rename-plan.ts` (new) | rename derivation using child 2 `parseFeatureFolderName`/`formatFeatureFolderName` (section 6) | TS, MCP tool core |
| `.../development-docs-migration/reference-rewrite.ts` (new) | prefix rewrite and relative-link recomputation (section 4) | TS, MCP tool core |
| `.../development-docs-migration/migration-git.ts` (new) | injectable git seam (section 2) | TS, MCP tool core |
| `.../development-docs-migration/migration-plan.ts` (new) | pure planner: tracked paths + decisions -> plan | TS, MCP tool core |
| `.../development-docs-migration/migration-apply.ts` (new) | applies a plan through the seams; idempotent | TS, MCP tool core |
| `.../development-docs-migration/migration-report.ts` (new) | dry-run report (Markdown and JSON) | TS, MCP tool core |
| `.../development-docs-migration/migrate-development-docs-service-call.ts` (new) | service-call wrapper | TS, MCP tool |
| `src/mcp-development-docs-tool-definitions.ts` (new) | `DEVELOPMENT_DOCS_TOOL_DEFINITIONS`, spread into both definition lists | TS, MCP tool |
| `src/mcp-tool-inputs-development-docs.ts` (new) | input validation | TS, MCP tool |
| `src/mcp-handlers/development-docs-migration-handler.ts` (new) | handler | TS, MCP tool |
| `src/migrate-development-docs-cli.ts` (new) | argv parsing for the `npx` subcommand | TS, MCP package entry |
| `src/repo-automation-tool-names.ts` | add `"migrate_development_docs"` | TS |
| `src/mcp-repo-automation-tool-definitions.ts`, `src/mcp-tool-definitions.ts` | spread the new definitions | TS |
| `src/mcp-tools.ts` (461 lines) | one `case` | TS |
| `src/repo-automation-service-contract.ts`, `src/repo-automation-service.ts` | `migrateDevelopmentDocs` method | TS |
| `src/mcp-server.ts` | `main()` dispatches to the CLI module when `process.argv[2] === "migrate-development-docs"`, otherwise starts the stdio server | TS, MCP package entry |
| `extensions/drm-copilot/jest.config.cjs` | one `coverageThreshold` entry per new production file (section 3) | config |
| `extensions/drm-copilot/package.json`, `CHANGELOG.md`, `packages/mcp-server/package.json` | version bump and changelog entry (timing: owner question OQ-7) | release |
| `packages/mcp-server/README.md`, `extensions/drm-copilot/README.md` | document the tool and the `npx` form | docs |

Tool input (proposal): `workspace_root` (required), `mode` (`"dry-run"` or `"apply"`, required), `rename_decisions_path` (optional; required by `apply` when the dry run reports any non-matching folder or multi-folder issue), `report_directory` (optional). Output: `RepoAutomationExecutionResult` with `artifacts` naming the report files and `summary` with counts.

`npx` entry recommendation: a subcommand on the existing bin, `npx -y @danmoisan/drm-copilot-mcp migrate-development-docs --workspace <path> --mode dry-run|apply [--decisions <path>]`. It keeps `bin` and `files` unchanged, so `discovery-resources.test.ts` keeps passing, and it keeps one bundle. Rejected: a second `bin` entry with a second esbuild entry point; it changes the pinned `bin`/`files` assertions and both esbuild configs, and with two bins `npx <package>` needs the `-p <package> <bin>` form.

### Tests and enumerations that a new tool name touches

Search: `new_active_feature_folder` and `migrate_discovery_artifacts` across `tests/`, `extensions/drm-copilot/test/`, `.claude/`, `.codex/`, `.agents/`, `.github/`, `config/`. Exhaustive enumerations of tool names found:

- `extensions/drm-copilot/test/mcp-server.test.ts` "registers the semantic repo automation tools": `toEqual` on the full ordered list. Must add the name.
- `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts`: definitions equal `REPO_AUTOMATION_TOOLS`; base/repo schema parity for shared names. Satisfied automatically when both lists spread the same module.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` `EXPECTED_DRM_COPILOT_TOOLS` pins `.codex/config.toml` `enabled_tools` (an explicit allowlist that already omits the discovery tools). Unchanged unless the tool is enabled for Codex (OQ-8); then `.codex/config.toml`, its bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, and the tuple change together.
- `.claude/settings.json` `permissions.allow` lists individual `mcp__drm-copilot__*` tools (and its bundle copy). Adding the migration tool there auto-approves a repository-wide move; leaving it out keeps a prompt (OQ-8).
- Full `RepoAutomationService` fakes: 13 test files reference `migrateDiscoveryArtifacts`, including the shared fake `extensions/drm-copilot/test/mcp-server-test-service.ts` and `mcp-tools.*.test.ts`, `mcp-server-*.test.ts`, `extension.discovery-commands.test.ts`, `repo-automation-service-discovery.test.ts`. A required interface method breaks type-checking of every full fake; an optional method (`migrateDevelopmentDocs?`, as `resolveOrchestrationTopology?` is) avoids that. Preflight must check each file.
- Name-specific mentions in hooks and skills (`enforce-promotion-mcp-only.ps1`, `enforce-epic-planning-only.ps1`, `DiscoveryToolRouting.psm1`, `feature-promotion-lifecycle` skills) are behavior lists for other tools, not enumerations of all tools; no change.
- Extension command: not required by D-17. `extensions/drm-copilot/package.json` `contributes.commands` and `src/repo-automation-command-registration-*.ts` would change only if one is added (OQ-9).

## 2. How TypeScript runs git, and the proposed seam

Verified:

- `src/lib/subprocess-runner.ts`: `CommandRunner.run(args, { cwd, allowError })` returning `{ stdout, stderr, code }`; `SubprocessRunner` uses `spawnSync` with `shell: false` and passes no `maxBuffer`. `src/lib/collect-commit-context.ts` `runGit(runner, cwd, args, allowError)` is the in-process pattern, faked in tests (`test/lib/collect-commit-context.test-helpers.ts`).
- `src/remove-worktrees-runner.ts` defines an async `GitRunner` (`run(args, cwd): Promise<GitRunResult>`) that resolves on non-zero exit; `createGitRunner()` uses `spawn`.
- Node documents `maxBuffer` default `1024 * 1024` for `spawnSync`; when exceeded the child is terminated and output truncated (nodejs.org `child_process` docs, read through WebFetch). Inferred: `git ls-files` over about 28k paths exceeds 1 MiB, so `SubprocessRunner` would report a non-zero code and throw.

Proposal (`migration-git.ts`):

```ts
export interface MigrationGit {
  listTrackedFiles(pathspecs: ReadonlyArray<string>): ReadonlyArray<string>; // git ls-files -z -- <pathspecs>
  move(from: string, to: string): void;                                       // git mv -- <from> <to>
  isInsideWorkTree(): boolean;                                                // git rev-parse --is-inside-work-tree
}
export function createMigrationGit(runner: CommandRunner, cwd: string): MigrationGit;
```

- Built over the existing `CommandRunner`, so tests inject a fake runner that records argv and returns canned stdout; no temporary files or repositories.
- `listTrackedFiles` uses `-z` and splits on NUL, so paths with spaces (`docs/engineering/Bugfix Playbook.md`) survive.
- Buffer limit: add an optional `maxBuffer` to `CommandRunOptions` and pass it in `SubprocessRunner` (additive; `subprocess-runner.ts` is shared, so its tests and coverage entry are re-run), or list per subtree pathspec and fall back to the `FileSystem` walk. The first is simpler.
- Moves are planned per directory (`git mv docs/features/active .dev/active`, a handful of calls) plus one call per renamed feature folder, not per file.
- `git mv` into an existing directory nests the source inside it (`.dev/active/active`). The planner must refuse when the target exists and is non-empty, or move entry by entry. Inferred from `git mv` semantics; covered by a fake-runner test of the planner decision, not of git.
- Whether `git mv` creates missing leading directories of the destination is not verified here; the applier calls `FileSystem.ensureDir` on the destination parent first.

## 3. Jest coverage configuration

- `extensions/drm-copilot/jest.config.cjs` (535 lines): `collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"]`; `coverageThreshold` is a per-file map with no `global` key, merging `jest.discovery-coverage.json` first. A new production file is gated only by its own entry `"./src/<path>.ts": { lines: 85, branches: 75 }`. Type-only files (for example `repo-automation-service-contract.ts`) are deliberately left without an entry, with a comment.
- Each new file in the section 1 table needs an entry (about 12 entries, about 48 lines; the file stays under the 700-line advisory tier). Alternative with precedent: a sibling JSON map (as `jest.discovery-coverage.json`) merged at the top.
- `packages/mcp-server` has no Jest or coverage configuration; its scripts are tested from `extensions/drm-copilot/test/packaging/`.
- `jest.config.cjs` is in the parallel-run blast radius (section 11).

## 4. Reference inventory and rewrite rules

### Counts per top-level area (snapshot; re-derive at execution)

Pattern P (ripgrep, case-sensitive): `docs[/\\]+(features|engineering|research|discovery)\b`. Counts are occurrences / files, taken before child 2 routes production consumers through the resolver.

| Area | Occurrences / files | Character |
| --- | --- | --- |
| `.claude/` (agents, hooks, lib, rules, skills) | 268 / 62 | prose, matchers, write scopes; rules: `plan-acceptance-gates.md` 11, `parallel-orchestration.md` 5, `orchestrator-state.md` 4 |
| `.codex/` | 72 / 32 | hooks, scripts, agent tomls (base and generated variants) |
| `.agents/` | 33 / 15 | shared skills prose |
| `.github/` | 45 / 19 | agents, prompts, three skills, `workflows/README.md`; `.github/instructions/` and `.github/copilot-instructions.md`: 0 |
| `extensions/drm-copilot/src` | 50 / 19 | production code (child 2 routes these) |
| `extensions/drm-copilot/test` | 471 / 96 | test literals; no JSON fixture under this tree matches |
| `extensions/drm-copilot/resources` | 428 / 136 | bundle mirrors: `claude-customizations` 269 / 63, `codex-and-agents-customizations` 106 / 48, `customizations` 44 / 18, remaining 9 occurrences in `templates/` and `feature-templates/` |
| `scripts/` | 63 / 30 | Python and PowerShell (child 2 routes production consumers); includes `scripts/dev_tools/pr_context/render.py,cover` |
| `tests/` | 3017 / 500 | of which `tests/fixtures` 1225 / 259; JSON files with literal `docs/features`: 1069 / 245 (the D-15 population) |
| `config/` | 9 / 1 | `ci-docs-only-paths.json` |
| Root and other | 27 / 11 | `AGENTS.md` 1, `README.md` 2, `pyproject.toml` 1 (comment), `.vscode/tasks.json` 4, `testResults.xml` 1, `packages/discovery-runtime/**` 18 in 6 files |
| Inside `docs/` (the moved trees) | 88,082 / 8,604 | self-references in records, plans, evidence `Command:` lines, manifests |

`extensions/drm-copilot/CHANGELOG.md` and `README.md` have 0 matches (the extensions total equals src + test + resources). **ORCHESTRATOR-CONFIRM** with `git ls-files` whether `testResults.xml` and `scripts/dev_tools/pr_context/render.py,cover` are tracked; neither is in `.gitignore`.

### Categories outside the moved trees

1. Production consumers (code constants, matchers, messages): owned by child 2's resolver routing; after child 2 the only remaining literals are its recorded Stay rows. No mechanical rewrite in child 7.
2. Test literals (TypeScript, Python, Pester): human updates where a test reads a real repository file under a moved tree or asserts the default. Real-file readers found: `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py` `STATUS_TEMPLATE_RELATIVE` (`docs/features/templates/parallel/parallel-status.md`); `test_execution_environment_brief_contracts.py` and `test_discovery_documentation_contracts.py` (read `docs/engineering/claude-code-architecture.md`); `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`; `test_single_pass_preflight_contracts.py`, `test_minor_audit_acceptance_criteria_contracts.py`, `tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1`, `extension.integration.test.ts`, `test_new_potential_bug_entry.py` (templates). Literal-only test inputs that are matched through the union matchers can stay during the fallback release.
3. Frozen JSON fixtures (D-15): 245 files under `tests/fixtures`; not rewritten.
4. Agent, skill, rule and prompt prose plus bundle mirrors (section 9).
5. Config and packaging: `config/ci-docs-only-paths.json` (section 7); `config/blast-radius.json` `path_roots` lists `docs` but not `.dev` (bundle copy under `resources/claude-customizations/config/`; carried by push-down as a bundled key) - not in child 2's spec; at the flip, `.dev` path tokens would not be recognized as paths by blast-radius extraction (inferred from `path_roots` semantics); `packages/discovery-runtime` (`resource-manifest.json`, `_resources/manifest.json`, `_build_manifest.json`, `build_identity.py`, `init_projection.py` `TEMPLATE_ROOT = "docs/discovery/templates/v2"`, README) and `scripts/dev_tools/build_discovery_runtime.py` `RESOURCE_ROOTS`: the packaged resource key equals the repository source path, so moving `docs/discovery` changes a published Python package's resource layout and build identity (existing Python; extend in place only; OQ-4).
6. Root docs and editor config: `README.md`, `AGENTS.md`, `.vscode/tasks.json`, `pyproject.toml` comment.
7. FileSizePolicy: `Get-FileSizeExcludedSegment` in `.claude/lib/file-size-policy/FileSizePolicy.psm1` excludes the segment `docs`; `.dev` is not excluded. No file with a covered extension (`.py .ps1 .psm1 .ts .tsx .js .cjs .mjs .cs .sh .bats`) exists under `docs/` today (Grep over `docs/` with that extension glob returned none), so the move does not trip `FileSizePolicy.RepoGate.Tests.ps1`, but after the flip a covered file written under `.dev/` is gated where it was exempt under `docs/` (OQ-10).

### Links inside the moved trees

- Relative links that leave the moved tree: 225 occurrences in 48 files match `\]\((\.\./){3,}(?:\.github|\.claude|\.codex|\.agents|scripts|extensions|tests|config|README|CLAUDE|AGENTS|packages)`. Typical: `](../../../../.github/instructions/general-code-change.instructions.md)` in `plan.*.md`; depth 5 in `audit-*/` and `v1/` subfolders. Under `.dev/active/<x>/` the depth drops by one (`docs/features/` is two segments, `.dev/` is one). Research and engineering files drop from two to one segment too (`docs/research/` to `.dev/research/`).
- The template `docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md` and its bundle copy `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md` carry `../../../../.github/...`, calibrated for `docs/features/active/<x>/plan.md`. Every new plan created after the flip from an unchanged template has a broken link. The bundled template is outside the moved tree and must change to three levels in the flip change; destinations still on `docs/features` would then get a broken link until they migrate (OQ-11).
- `refactor` templates and `docs/features/completed/repo-housekeeping-audit/plan.*.md` link `../../code-change.instructions.md` and `../../unit-test-policy.md`; those targets do not exist today (verified: `docs/*.md` matches nothing). Report only.
- Cross-subtree relative links: none found for `\]\((\.\./)+(research|engineering|discovery|features)/` (0) and for links into a dated sibling folder `\]\((\.\./)+\d{4}-\d{2}-\d{2}-` (0); one link into another lifecycle area in `docs/features/completed/2026-09-25-codex-pushdown-self-sufficiency-697/spec.md`.
- Repository-root-relative Markdown links `](docs/features/...)`: 14 occurrences in 10 files, mostly test inputs and `scripts/dev-tools/link-feature-docs.ps1`.
- Rewrite rule for links: for each moved Markdown file, resolve every relative link against the old location; if the target is outside the moved set or moved under a different mapping, recompute it relative to the new location; otherwise leave it. This one rule covers all depths, including `audit-*/` and `v1/` subfolders. Links to targets that do not exist are left unchanged and reported.

### Prefix rewrite rule

Longest prefix first: `docs/features/research/` -> `.dev/research/`; `docs/features/templates/` -> `.dev/templates/`; `docs/features/<area>/` -> `.dev/<area>/`; `docs/features/backlog.md` -> `.dev/backlog.md`; `docs/features/` -> `.dev/`; `docs/research/` -> `.dev/research/`; `docs/engineering/` -> `.dev/engineering/`; `docs/discovery/` -> per OQ-1. Renamed folder basenames are rewritten after the prefix rule, from the approved map. Idempotence follows because no output contains an input prefix.

### References that must not be rewritten

- The 245 historical JSON fixtures (D-15) and the historical-run fixtures under `tests/fixtures/blast_radius/historical-runs/`.
- `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pins `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`; both contain the pattern (8 and 6 occurrences). These are re-baselined with a dated comment when their text changes, not frozen. The same module's `KICKOFF_IDENTITY_FRAGMENTS` pins the literal fragment ``written literally as `docs/features/active/<basename>` ``; a prose rewrite of the pinned surface must update that fragment in the same change.
- Text that records the old-to-new mapping itself: the promoted record, this feature's spec, user story, research and plan, and child 2's spec, research and plan. A blind prefix rewrite turns `docs/features/templates -> .dev/templates` into `.dev/templates -> .dev/templates`. The tool needs an exclusion list, and the dry run reports every file it would rewrite.
- Git history and CHANGELOG history (0 occurrences in the CHANGELOG today).
- Policy files: `.github/instructions/**` and `.github/copilot-instructions.md` contain no occurrence. `.claude/rules/plan-acceptance-gates.md`, `parallel-orchestration.md` and `orchestrator-state.md` (and their bundle copies) do. `CLAUDE.md` names the `.github/` files as the canonical, unmodifiable policy; whether the `.claude/rules` mirrors may be edited by the flip is OQ-5. `AGENTS.md` (1 occurrence) becomes the instruction source under child 3.
- Whether historical records inside the moved trees (8,604 files, evidence `Command:` lines, completed plans, parallel manifests that cite `docs/features/active/<folder>` for folders now in `completed/`) are rewritten at all is OQ-2.

## 5. Mapping table

| Old prefix | New prefix | Notes (verified contents) |
| --- | --- | --- |
| `docs/features/potential/` (including `promoted/`, `template.md`, `README.md`) | `.dev/potential/` | names kept (D-22) |
| `docs/features/active/` | `.dev/active/` | folder rename (D-20) |
| `docs/features/completed/` | `.dev/completed/` | folder rename |
| `docs/features/archive/` | `.dev/archive/` | folder rename |
| `docs/features/epics/` | `.dev/epics/` | names kept |
| `docs/features/parallel/` | `.dev/parallel/` | names kept |
| `docs/features/templates/` | `.dev/templates/` | `README.md`, `bug/`, `epic/`, `feature/`, `parallel/`, `policy_audit/`, `refactor/` |
| `docs/features/research/` | `.dev/research/` | one file, `claude-ecosystem.md` |
| `docs/features/backlog.md` | `.dev/backlog.md` | |
| `docs/research/` | `.dev/research/` | 30 flat files |
| `docs/engineering/` | `.dev/engineering/` | 5 root files plus `legacy-discovery-and-parity/` (with `examples/`) |
| `docs/discovery/` | conflict, OQ-1 | contains only `templates/` (`artifacts/`, `domain-profile/`, `v2/`) |

Collisions checked: `docs/features/research/claude-ecosystem.md` does not share a name with any of the 30 files in `docs/research/`; the discovery template subfolders (`artifacts`, `domain-profile`, `v2`) share no name with the feature template entries, so a merge into `.dev/templates/` has no name collision.

Conflict to report (not decide): the record's layout comment says `templates/ (was docs/features/templates and docs/discovery templates)` and also lists `discovery/ (was docs/discovery)`; child 2's area map sets `discovery-templates` to `.dev/discovery/templates`. Because `docs/discovery` contains only templates, the two readings give different targets.

Other entries: Glob over `docs/*/*` returned files only under `docs/engineering/`, `docs/research/` and `docs/features/backlog.md`; `docs/*.md` matched nothing; Glob probes for top-level `docs/` directories outside the `d*`, `e*`, `f*`, `r*` families matched nothing; `docs/features/` has no entry outside the nine listed. No unmapped entry was found. `docs/` is empty after the move except the new `docs/README.md` (D-10).

## 6. Feature-folder rename derivation

### Mechanical rule (consumes child 2 F-1 to F-6 and N-1 to N-5)

For each direct child folder `<area>/<name>` of `active`, `completed` and `archive`:

1. `parseFeatureFolderName(name)`.
2. `date-first` with `issueNumber` (F-1): candidate `formatFeatureFolderName(issueNumber, feature)`.
3. `issue-first` (F-3, F-4): already migrated; no rename (idempotence).
4. `other` with `issueNumber` (F-5): candidate `formatFeatureFolderName(issueNumber, feature)`, but reported as non-matching and held for the owner (D-21).
5. `date-first` without issue (F-2) or `other` without issue (F-6): no recoverable number; keep the name (D-21), reported.
6. Any issue number that yields several candidates: reported; no rename for that number until decided.
7. A formatter error (N-3 to N-5; for example a feature that begins with `\d{2}-\d{2}-`) is reported, not thrown, in dry-run mode.
8. Target collisions are checked case-insensitively (Windows file system) across all three areas; a collision is reported.

Versioned subfolders (`v1/`, `v2/`) and nested layouts (`audit-*/`, `evidence/**`) move with their parent and are not renamed; only the top-level folder name changes.

### Snapshot counts (re-derive with `git ls-files` at execution)

Primary strategy: Grep for depth-one `issue.md` in each area. Cross-check strategy: regex classification of the folder segment of depth-one `issue.md`, `spec.md`, `README.md` and `user-story.md` paths.

| Measure | Value | Basis |
| --- | --- | --- |
| Folders with a depth-one `issue.md` | 335 (active 14, completed 182, archive 139) | primary; the record states 339, so about 4 folders lack `issue.md` |
| Active folders | 14, all date-first with a trailing issue | both strategies |
| Not date-first-with-trailing-issue | 36 (completed 24, archive 12) | cross-check; equals D-21's 36 |
| of which `other` with trailing issue (F-5) | 29 (completed 18, archive 11) | for example `subagentstop-envelope-core-897`, `codex-gates-4-5-lack-epic-scope-707` |
| of which no recoverable number | 7: `completed/subagent-tree-command`, `completed/repo-housekeeping-audit`, `completed/portable-orchestrator-state-preflight`, `completed/npm-dependency-vulnerability-remediation`, `completed/npm-audit-gate-and-dependabot`, `completed/2026-04-26-worktree-naming-bug` (F-2), `archive/epic-852-main-sync` (digits not trailing) | cross-check |
| Issue numbers with several folders (partial probe) | 543 (four archive folders: three date-first plus `epic-planner-receipt-checks-key-gate-543`), 824, 884, 903 | probe of the 29 F-5 numbers plus the 14 active numbers only; the complete set is derived by the dry run |
| Versioned folders | `archive/2026-03-09-push-down-copilot-customizations-84`, `completed/2026-04-26-codex-native-converter-164`, `completed/2026-04-11-claude-code-architecture-136`, `completed/2026-08-07-blast-radius-under-reporting-gaps-452` | `v\d+/spec.md` |

Edge case found: `archive/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824` parses to issue 824 (trailing), not 823, and collides with `archive/promotion-hook-raw-containment-false-positive-deny-824`.

### References to individual feature-folder paths outside the folder

- Epic manifests: `feature_folder:` appears in 22 manifest files (166 occurrences counting templates); epics use basename hints (`2026-09-13-target-worktree-resolution-module-669`, `subagentstop-envelope-core-897`). The in-flight epic `docs/features/epics/shared-agent-harness-layer/epic.md` names `2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`, which the rename changes; that manifest must be rewritten in the same change because the epic is still open while child 7 runs.
- Parallel manifests: full paths such as `"docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990"`, many pointing at `active/` for folders now under `completed/` or `archive/` (already stale today). Rewrite or freeze is OQ-2.
- Plans, specs and evidence citing other folders: inside the 88,082 in-tree occurrences; OQ-2.
- Gitignored checkpoints (`artifacts/orchestration/*.json`) record feature-folder paths, including this feature's own folder, which the move renames to `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`. A tracked-file migration does not rewrite them; the orchestrator updates the checkpoint in the same step (section 8).
- Test fixtures naming dated folders: frozen (D-15), read through child 2's union matchers.

## 7. Default flip

What child 2 leaves (from its spec): `"development_docs_root": "docs/features"` in `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` (byte-identical, `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`); `DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features"` in three runtimes; R-1/R-2 resolve the default when the file or key is absent.

| Place | Change at the flip |
| --- | --- |
| Three routing-config copies | value `.dev` in all three (the parity test forbids flipping only the repository copy) |
| `DEFAULT_DEVELOPMENT_DOCS_ROOT` and the R-1/R-2 tests in `root.test.ts`, the Python `json_config` tests, `DevelopmentDocsRoot.Tests.ps1` | unchanged unless the owner decides that an absent key now means `.dev` (OQ-3) |
| Folder-creation and promotion tests with the default root (`flow.test.ts`, `io.test.ts`, `content.test.ts`, `promotion.test.ts`, `test_potential_to_issue*.py`) | expected `.dev/<area>` when the repository config is read; tests that inject their own config are unaffected |
| `config/ci-docs-only-paths.json` and `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, `CiChangeScope.Tests.ps1`, `Invoke-CiChangeScope*.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` | `.dev/` entries exist after child 2; `docs/` entries stay for the fallback release (a pull request that still touches `docs/features/` paths, including the move itself, is classified correctly) |
| `.github/workflows/README.md` (`## Change-Scope Decision (Issue #962)`) and the execution-environment brief `## CI Shape and Required Checks` (six copies) | text unchanged at the flip if the allowlist is unchanged; changed later at fallback removal |
| `config/blast-radius.json` `path_roots` and bundle copy | add `.dev` (section 4, category 5) |
| Feature plan templates | link depth (section 4) |

Fallback behavior for unmigrated destinations (R-7): a Claude push-down merges `config/orchestration-routing.json` and appends missing source keys, so a destination without the key receives `.dev`; a Codex push-down overwrites the file. In both cases a destination that has `docs/features` and no `.dev` resolves `docs/features` (R-7), so its writers keep writing there; matchers accept both roots. A destination that set `docs/features` explicitly keeps it on a Claude push-down (R-5) and, after a Codex overwrite, still resolves `docs/features` through R-7. A destination with both trees resolves `.dev` (R-6); records left in `docs/features` remain matchable but are not written. A destination with neither resolves `.dev` (R-8).

Fallback removal (D-8) and D-15 interact: frozen fixtures that carry `docs/features` paths pass only while matchers accept the `docs/features` root. Whether child 7 removes the fallback is OQ-6.

## 8. Scale and feasibility of one mechanical commit

| Risk | Finding | Basis |
| --- | --- | --- |
| Write/Edit hooks (file size, evidence locations, batch budgets, preimplementation gate, feature-folder order, completion consistency, mermaid) | registered with matcher `Write|Edit` in `.claude/settings.json`; files moved by `git mv` or written by the tool process are not seen | verified (matchers; brief `## Batch Budget`) |
| Bash hooks | `validate-bash.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, PR and merge gates see only command text; `npx ...` and `sh <file>.sh` pass the isolation guard per the brief; the commit command is subject to the preimplementation gate, which needs a checkpoint at the execution phase | verified for registration; gate behavior on staging and commit is from project memory, ORCHESTRATOR-CONFIRM |
| MCP route | the tool's internal `git mv` runs in the server process; only the MCP call passes hooks (`enforce-discovery-artifact-gate.ps1` matcher `mcp__.*`) | verified registration; inferred effect |
| Branch tool not installed | MCP runs the installed package, so the branch tool is reachable only through a branch build (`npm --prefix packages/mcp-server run build`, then `node packages/mcp-server/out/mcp-server.js migrate-development-docs ...` launched from a `sh` script) or after a release | verified (brief); OQ-7 |
| Batch budget for prose edits | the post-decision plan edits many `.claude`, `.codex` and bundle files with Edit; Markdown does not count, but any PowerShell or Python edit does; use the `large` route | verified (brief) |
| CI change scope | the move diff runs with rename detection off, so both old and new paths are classified; the commit also changes code, tests and `.dev/templates/` (excluded after child 2), so the run is full | verified (brief, `CiChangeScope.psm1` config) |
| CI cost of about 57k changed paths | `Invoke-CiChangeScope.ps1` classifies each path by prefix; expected to complete | inferred |
| Linux case sensitivity | `.dev` and all folder names are lower case; the hook suite runs on Linux; test fixtures must use forward slashes and exact case | verified names; brief |
| Windows path length | every path shortens: `docs/features/` (14 characters) becomes `.dev/` (5), and `2026-10-30-<feature>-1016` becomes `1016-<feature>` (11 fewer characters) | verified by arithmetic |
| Rename detection | exact renames are detected cheaply; inexact renames are limited by `diff.renameLimit` (default not stated in git-scm `diff-config` text read through WebFetch). Rewriting text inside 8,604 moved files in the same commit makes those renames inexact, which risks delete-plus-add output and weaker `git log --follow` | inferred; OQ-12 |
| Untracked files under `docs/features` | `git mv` of a directory renames it on disk, so untracked files move too, while only tracked files are re-indexed | inferred; the dry run lists untracked files |
| Self-move | this feature's own folder, plan and evidence move and rename during its own execution; the plan path, `<FEATURE>` and checkpoint paths change mid-run | verified (folder location) |
| File size | no covered extension under `docs/` today; `.dev` is not an excluded segment | verified; OQ-10 |
| `spawnSync` buffer | 1 MiB default; `git ls-files` output for the tree is larger | verified (Node docs) and inferred size |

## 9. Prose and mirrored copies

- Prose occurrences by area are in section 4. After child 2 the production consumers are routed; the remainder is prose, examples, write-scope literals and test text.
- Mirrors that change in lockstep: every edited `.claude/**` file and its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/**`; `.codex/**` and `.agents/**` with copies under `resources/codex-and-agents-customizations/`; `.github/skills/**` with `resources/customizations/.github/skills/**`; Codex agent variants regenerated by `scripts/dev_tools/generate_codex_agent_variants.py` (run with `--check`); the execution-environment brief in six byte-identical copies; three routing-config copies; the feature templates in `docs/features/templates/` (moving) and `resources/feature-templates/` (not moving).
- After epic children 3 to 6 merge, several of these become generated or retired: child 3 generates `.claude/skills` from `.agents/skills`, rules from one source, and agents from one definition; child 6 retires `.github/skills` and possibly `.github/agents`. Child 7 must edit the sources and run the generators rather than edit generated outputs; the exact source set is known only after those children merge (Phase 0 gate).
- Contract tests to run: those listed in the brief `## Contract Tests That Pin Mirrored Files` (resource contracts, pack-manifest completeness and dependency closure, Codex generator `--check`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_claude_rules_frontmatter.py`, `parallel_orchestrator_surface_expectations.py`, `test_quality_checks_workflow_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_typescript_toolchain_instruction_contracts.py`, `claude-architecture-doc.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`), plus `test_execution_environment_brief_contracts.py`, `test_orchestration_routing_config_parity.py`, child 2's write-scope checker, and the literal-containment tests with `docs/features` fragments (12 `test_*contract*.py` files, 49 occurrences, including `test_parallel_planner_surface_contracts.py`, `test_parallel_kickoff_contract.py`, `test_epic_kickoff_contract.py`).
- The brief itself mentions the pattern once (the CI allowlist paragraph). Its maintenance rule requires a same-change update in all copies only when a stated fact changes (section 7).

## 10. Split into two plans and the decision artifact

### Pre-decision plan (Phase 2: tool, tests, dry run; no move)

- Phase 0 gate: child 2 merged; record the child 2 contracts actually exported (`parseFeatureFolderName`, `formatFeatureFolderName`, `developmentDocsPath`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`) and stop for re-planning if a signature differs.
- Implement the section 1 modules with unit tests: subtree map, rename derivation (F-1 to F-6 inputs and N-3 to N-5 error reporting), prefix rewrite, relative-link recomputation at depths 3, 4 and 5, collision detection (case-insensitive), exclusion list, nested-target refusal, idempotence (apply twice on an in-memory fixture repository; the second plan is empty and writes nothing), README creation once.
- MCP registration, CLI subcommand, Jest entries, enumerated-name test updates (section 1).
- Run the dry run against this repository from a branch build; write `evidence/other/dev-docs-migration-dry-run.<UTC>.md` and `.json` under this feature folder: renames, non-matching folders, multi-folder issues, formatter errors, collisions, files to rewrite with occurrence counts, excluded files, broken links, untracked files.
- Stop for the owner.

### Owner decision artifact

`<FEATURE>/evidence/other/folder-rename-decisions.<UTC>.json`, written by the orchestrator from the owner's answers:

```json
{
  "version": 1,
  "dry_run_report": "dev-docs-migration-dry-run.<UTC>.json",
  "source_digest": "<sha256 of the sorted list of candidate folder paths in the dry run>",
  "decisions": [
    { "source": "docs/features/archive/epic-planner-receipt-checks-key-gate-543", "action": "rename", "target": "0543-epic-planner-receipt-checks-key-gate-b" },
    { "source": "docs/features/completed/subagent-tree-command", "action": "keep" }
  ]
}
```

The tool reads it through `rename_decisions_path`, refuses `apply` when any reported folder lacks a decision, when a target collides, or when `source_digest` differs from a fresh dry run (the tree changed after approval), and applies only listed actions for reported folders; unreported F-1 folders follow the mechanical rule. The file moves with the feature folder, so the path is passed explicitly.

### Post-decision plan (Phase 3: move, flip, updates)

- Phase 0 gate: children 3 to 6 and the parallel run `bugs-1001-1002-1003-1006` merged; no open pull request touches `docs/features/**` or the files in section 11 (ORCHESTRATOR-CONFIRM with `gh`); fresh dry run digest equals the decision file digest.
- Apply with the decision file: one mechanical commit of moves and renames (and, per OQ-12, rewrites in the same or a following commit). Update the orchestrator checkpoint paths for this feature in the same step.
- Flip the three routing-config copies; `config/blast-radius.json` `path_roots`; plan-template link depth (both copies); epic manifest `feature_folder` for child 2; `docs/README.md`; discovery runtime packaging (OQ-4); `.vscode/tasks.json`, `README.md`, `AGENTS.md` and the `pyproject.toml` comment; prose in sources with generators re-run; `PINNED_FROZEN_SURFACE_HASHES` and `KICKOFF_IDENTITY_FRAGMENTS`; tests that read moved files.
- Full toolchain with the key at `.dev`, isolation checks, mirror and contract tests.

## 11. Overlap for the Phase 0 re-check

Against `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/research/parallel-run-blast-radius-bugs-1001-1002-1003-1006.txt`, files child 7 is expected to edit that the parallel run also lists:

- `.claude/agents/epic-orchestrator.md`, `parallel-orchestrator.md`, `parallel-planner.md` and bundle copies; `.claude/rules/orchestrator-state.md`, `parallel-orchestration.md` and bundle copies; `.claude/skills/epic-orchestrate/SKILL.md`, `orchestrate`, `parallel-add`, `parallel-orchestrate`, `parallel-plan`, `parallel-run` skills and bundle copies; `.claude/settings.json` and bundle copy (only if the tool is allow-listed).
- The execution-environment brief, all copies; `.codex/config.toml` (only if the tool is enabled for Codex).
- `docs/features/templates/parallel/parallel-status.md` and the three `policy_audit` templates (moved).
- `config/blast-radius.json` and `resources/claude-customizations/config/blast-radius.json`; `config/file-size-baseline.json` (read).
- `extensions/drm-copilot/jest.config.cjs`, `package.json`, `CHANGELOG.md`, `README.md`.
- Pack manifests `resources/claude-customizations/pack-manifests/core.json`, `resources/codex-and-agents-customizations/pack-manifests/core.json` (only if a manifested file is added).
- Tests: `parallel_orchestrator_surface_test_support.py`, `test_parallel_planner_surface_contracts.py`, `test_execution_environment_brief_contracts.py`, the push-down contract tests, `claude-architecture-doc.Tests.ps1`.
- Every `docs/features/active/2026-10-30-*` folder of that run (1001, 1002, 1003, 1006, 1009, 1010, 1011, 1012, 1013) and the four promoted potential records it lists: the move renames them. On this branch only the 1009 folder is present under `active/`; ORCHESTRATOR-CONFIRM their location on `origin/main` at execution.

Epic children 3 to 6 have no active folder on this branch (only the 1016 and 1035 folders exist for the epic), so their file sets are known only by scope: child 3 (agent, skill, rule and MCP-config generators; `.claude/agents`, `.codex/agents`, `.claude/skills`, `.claude/rules`, `.mcp.json`, `.codex/config.toml` `[mcp_servers]`, `AGENTS.md`, `CLAUDE.md`), child 4 (push-down pipeline, pack manifests, MCP push-down tools in `mcp-tools.ts` and tool definitions), child 5 (hooks), child 6 (`.github/skills`, `.github/agents`, `.vscode/settings.json`). Child 7 overlaps all of them on prose and on `mcp-tools.ts`, the tool-definition modules and `mcp-server.test.ts`. The Phase 0 gate re-reads each named file, symbol and heading after they merge.

## Candidate approaches

- Selected: one TypeScript tool with a pure planner (tracked paths, decisions, exclusion list -> plan), an applier over injected `MigrationGit` and `FileSystem` seams, a dry-run report, and an owner decision file consumed by `apply`; `npx` through a subcommand on the existing bin.
- Rejected: per-file `git mv` (about 28k process launches); a PowerShell or bash migration script (violates D-9/D-17 and the language rule for MCP commands); in-place text rewrite of every tracked file without an exclusion list (corrupts mapping records and frozen fixtures); a second `bin` entry (section 1).

## Language classification

| Artifact | Runs where | Language |
| --- | --- | --- |
| Migration core, MCP handler, definitions, inputs, CLI subcommand | MCP package | TypeScript |
| Jest tests | repository | TypeScript |
| `subprocess-runner.ts` `maxBuffer` option | MCP package and extension | TypeScript (existing file) |
| Prose, templates, `docs/README.md` | repository and pushed-down bundles | Markdown |
| Routing config, `ci-docs-only-paths.json`, `blast-radius.json`, decision file | repository and bundles | JSON |
| Discovery runtime packaging path changes | `packages/discovery-runtime`, `build_discovery_runtime.py` | existing Python, extend in place only; OQ-4 |
| FileSizePolicy excluded segment (if chosen) | pushed-down lib and hooks | existing PowerShell; OQ-10 |
| Test updates in Pytest and Pester | repository | existing files only; no new Python file |

No new Python file, PowerShell hook or bash script is proposed.

## Testing implications

- Jest with in-memory `FileSystem` fakes and a fake `CommandRunner`; no temporary directories, no real git. One in-memory fixture repository covers move, rename, rewrite and README creation, then a second `apply` yields an empty plan.
- Property-style tests for `reference-rewrite.ts` (idempotence; no output contains an input prefix) are recommended; the tier gate applies only if `quality-tiers.yml` classifies the module.
- Seeded shuffled Jest runs recorded under `evidence/regression-testing/`.
- Phase 3 is verified by the full toolchain with the key at `.dev` and by the contract tests in section 9.

## Numeric Derivation Evidence

No numeric count, enumeration or population is proposed for a `spec.md` acceptance criterion. All counts in this note are labeled snapshots for planning; the dry run re-derives them at execution.

## Pre-Mortem

- Review checklists: a reviewer finds a stale `docs/features` literal in a production consumer or a broken relative link after the move. Mitigation: the dry-run report lists every remaining occurrence and every unresolved link; the post-decision plan records a final search over production roots against child 2's Stay allowlist and a link check over moved Markdown, stored under `evidence/`.
- Coverage: new migration modules lack `coverageThreshold` entries, or blanket mocks inflate coverage. Mitigation: one entry per new production file; seams are fakes that exercise real planner and rewrite logic; coverage evidence per file.
- Mirror parity: prose edits reach generated outputs instead of child 3's sources, or one of the six brief copies, three routing copies or two template copies is missed. Mitigation: edit sources, run generators and `--check`, run every section 9 contract test, re-baseline `PINNED_FROZEN_SURFACE_HASHES` and `KICKOFF_IDENTITY_FRAGMENTS`, and name the brief-update task when a stated fact changes.
- File size: `mcp-tools.ts` (461), `mcp-tool-definitions.ts` (462), `repo-automation-service.ts` (451) and `jest.config.cjs` (535) grow. Mitigation: definitions in a new module spread into both lists; one `case` and one method each; consider a sibling JSON coverage map; check `.dev` against `Get-FileSizeExcludedSegment` (OQ-10).
- Test isolation: tests read the real routing config or depend on whether `.dev` exists; tests that read moved repository files break after the move. Mitigation: injected config and directory probes; update each real-file reader listed in section 4 in the move change; seeded shuffles.
- CI-only behavior: Linux case sensitivity and path separators in the rewrite and collision logic; a Windows-only test of rename collisions passes locally and fails on Linux. Mitigation: forward-slash, case-explicit fixtures; case-insensitive collision detection tested with explicit inputs; no test diffs against `origin/main`.
- Evidence: the feature folder renames itself during execution, so evidence paths, the plan path and the checkpoint change mid-run, and the decision file can go stale. Mitigation: the decision file carries `source_digest`; the plan records the post-move `<FEATURE>` path, updates the checkpoint in the same step, and writes later evidence only under the new path.

## ORCHESTRATOR-CONFIRM

- Whether `testResults.xml` and `scripts/dev_tools/pr_context/render.py,cover` are tracked.
- Exact folder total (record: 339; depth-one `issue.md`: 335) and the full multi-folder issue set, from `git ls-files`.
- Locations of the parallel run's `2026-10-30-*` folders on `origin/main`, and that no open pull request touches `docs/features/**` before Phase 3.
- Preimplementation-gate behavior for `git add`/`git commit` during the move, and the release that makes `migrate_development_docs` installable.
- `diff.renameLimit` default and exact-rename handling in the installed git.

## Owner Questions

- OQ-1: Where does `docs/discovery/templates` go: `.dev/templates/` (record layout comment), `.dev/discovery/templates/` (record `discovery/` line and child 2's area map), or another target?
- OQ-2: Should references inside the moved historical records (completed and archive plans, evidence `Command:` lines, parallel manifests that cite `active/` for completed folders) be rewritten, or left as written?
- OQ-3: At the flip, does an absent key or file in a destination resolve `docs/features` (R-1/R-2 unchanged) or `.dev`?
- OQ-4: Should the discovery runtime package keep its internal resource key `docs/discovery/templates/v2` while its repository source moves, or change the key (existing Python, published package)?
- OQ-5: May the flip edit `.claude/rules/plan-acceptance-gates.md`, `parallel-orchestration.md` and `orchestrator-state.md` and their bundle copies, which mention `docs/features`?
- OQ-6: Does child 7 remove the one-release fallback (D-8), given that D-15 fixtures pass only while matchers accept `docs/features`?
- OQ-7: Is Phase 3 run from a published release of `@danmoisan/drm-copilot-mcp` (a release between the two plans) or from a branch build, and when are the extension and MCP versions bumped?
- OQ-8: Should `migrate_development_docs` be added to `.claude/settings.json` `permissions.allow` and to `.codex/config.toml` `enabled_tools`?
- OQ-9: Is a VS Code extension command for the migration wanted in addition to the MCP tool and `npx` entry?
- OQ-10: Should `.dev` be added to the FileSizePolicy excluded segments to match today's `docs` exemption?
- OQ-11: The bundled plan template's link depth must change for `.dev/active/<x>/`; is a broken link acceptable for destinations still on `docs/features` during the fallback release?
- OQ-12: Must moves and text rewrites be one commit (the record's "one mechanical commit"), or may the pure renames be committed first so that every rename is exact?
- OQ-13: For each non-matching folder and each multi-folder issue in the dry-run report, which action applies (rename with which target, or keep)?
