# 2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser — Spec

- **Issue:** #1035 (Phase 1 of #1016; references #1016 and does not close it — no Closes, Fixes or Resolves line for #1016)
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 2
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-feature (acceptance criteria in this file and in `user-story.md`)
- **Branch:** `feature/dev-docs-root-resolver-phase1-1035`
- **Research:** `research/research.2026-10-30T21-15.md` (inventory and proposed contracts)
- **Settled decisions:** `docs/features/potential/promoted/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production.md` (D-1 to D-22). This spec does not re-open any decision.

## Overview

`docs/features/` holds potential entries, active and completed features, an archive, epics, parallel orchestrations, templates and research. It is development-process material in the folder that conventionally holds production documentation, and the same layout is pushed to every destination repository that uses this toolset.

Goal of issue #1016: separate development documentation from production documentation. Development records move to a new top-level `.dev/` root, and `docs/` is reserved for production documentation. The lifecycle semantics (potential, active, completed, archive) do not change.

This spec records the full #1016 design (target layout, three phases, D-1 to D-22). Child 2 of epic #1018 is tracked by issue #1035 and delivers **Phase 1 only**. Phases 2 and 3 are delivered by epic child 7, which adopts #1016 (owner decision E1), so #1016 closes only when the move to `.dev` completes; child 7 cites this spec. The acceptance criteria in this spec cover Phase 1 only.

## Scope Boundary

| Item | Phase | Delivered by | In scope for this child |
| --- | --- | --- | --- |
| `development_docs_root` key, default `docs/features`, behavior identical | 1 | child 2 (#1035) | Yes |
| Resolvers in Python, PowerShell and TypeScript; area map; writer/matcher split; `.dev` fallback logic | 1 | child 2 | Yes |
| Routing every production consumer through the resolver | 1 | child 2 | Yes |
| CI docs-only scope for `.dev/` (D-12); JSON governance glob (D-14); dot-folder handling (D-13) | 1 | child 2 | Yes |
| D-16 write-scope literal contract and checker | 1 | child 2 | Yes |
| Feature-folder name parser in three runtimes (D-18, D-19); new folders named `<NNNN>-<feature>` | 1 | child 2 | Yes |
| Mirrored, bundled, pack-manifest and Codex counterparts; frozen-surface hash re-baseline | 1 | child 2 | Yes |
| TypeScript migration command as an MCP tool with an `npx` entry point (D-9, D-17) | 2 | child 7 | **No (out of scope)** |
| The move of this repository to `.dev` and the `docs/README.md` boundary note (D-1 to D-6, D-10) | 3 | child 7 | **No (out of scope)** |
| Rename of existing feature folders, non-matching-folder report and owner stop (D-20, D-21, D-22) | 3 | child 7 | **No (out of scope)** |
| Flip of the default to `.dev` and removal of the fallback after one release (D-8) | 3 / later | child 7 | **No (out of scope)** |
| Historical-fixture handling at the flip (D-15) | 3 | child 7 | **No (out of scope)** |
| Moving `docs/discovery/templates` resources (`build_discovery_runtime.py` `RESOURCE_ROOTS`) | 3 | child 7 | **No (out of scope)** |

## Behavior

### Target layout (full design; reached in Phase 3)

The `features` level is dropped (D-6).

```
.dev/
  potential/  active/  completed/  archive/
  epics/  parallel/
  templates/          (was docs/features/templates and docs/discovery templates)
  research/           (was docs/research and docs/features/research; issue-linked research stays in its feature folder)
  engineering/        (was docs/engineering)
  discovery/          (was docs/discovery)
  backlog.md
docs/
  README.md           (states that docs/ holds production documentation only)
```

### Phase 1: resolver and configured root (this child)

- One configured key, `development_docs_root`, with the default `docs/features`. With the default, behavior is identical to today.
- A resolver in each runtime reads the key. Writers obtain paths from the resolver; matchers accept both known roots during the fallback release.
- `.dev/` is added to the CI docs-only scope with today's classification preserved, and `.dev/**/*.json` is added to JSON governance.
- Dot-folder handling is made explicit for the in-house glob consumers, each with a test that finds a file under `.dev`.
- Agent and hook write scopes carry checked literals for both roots, driven by one TypeScript rule table.
- A feature-folder name parser in each runtime accepts both the old date-first format and the new `<NNNN>-<feature>` format, and the folder-creation tool names new folders from the issue number.
- Mirrored, bundled, pack-manifest and Codex counterparts are updated.

### Phase 2: migration command (child 7; out of scope here)

- A TypeScript command, exposed as an MCP tool in `@danmoisan/drm-copilot-mcp` with a thin `npx` entry point, so agents and destination repositories without the extension can run it (D-9, D-17).
- It moves `docs/features`, `docs/engineering`, `docs/research` and `docs/discovery` into `.dev` with `git mv`, rewrites in-repository path references and links, creates the `docs/README.md` boundary note, and is safe to re-run.

### Phase 3: move this repository and flip the default (child 7; out of scope here)

- Run the migration on this repository as one mechanical commit, flip `development_docs_root` to `.dev`, and update tests and prose.
- Rename existing feature folders in `active`, `completed` and `archive` to `<NNNN>-<feature>` in the same move, report non-matching folders and issue-number collisions, and stop for an owner decision on each (D-20, D-21). Potential records, epics, parallel runs and research keep their names (D-22).
- Historical JSON fixtures that record past runs stay frozen with their `docs/features` paths and are read through the fallback (D-15).
- After one release, remove the fallback (D-8); `KNOWN_DEVELOPMENT_DOCS_ROOTS` then shrinks to `.dev`.

## Inputs / Outputs

### Configuration key

- File: `config/orchestration-routing.json`, as a flat top-level scalar:

  ```json
  "development_docs_root": "docs/features"
  ```

- Copies that must stay byte-identical: `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json`, `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` (pinned by `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`).
- Rationale: this is the only configuration file that the Python, PowerShell and TypeScript code already read and that both the Claude and Codex push-downs already publish. The Claude routing merge keeps a destination's existing top-level keys, so a destination value survives a Claude push-down.
- Known limitation, recorded for epic child 4: the Codex push-down writes this file without merging, so a destination that later sets `.dev` loses the value on a Codex push-down. Phase 1 keeps the default, so behavior is unaffected.

### Closed value set

`KNOWN_DEVELOPMENT_DOCS_ROOTS = ("docs/features", ".dev")`. `DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features"`. `DEVELOPMENT_DOCS_ROOT_KEY = "development_docs_root"`.

### Resolution semantics (adopted orchestrator interpretation)

The following rules are the adopted orchestrator interpretation of D-7 and D-8. OQ-1 records the point awaiting owner confirmation.

| Case | Condition | Result |
| --- | --- | --- |
| R-1 | `config/orchestration-routing.json` absent or unreadable | `docs/features` |
| R-2 | File present, key absent | `docs/features` (no `.dev` probe; OQ-1) |
| R-3 | File present, JSON malformed | explicit error |
| R-4 | Value outside the closed set (any other string, blank, non-string, backslash, leading `/`, `..` segment) | explicit error |
| R-5 | Value `docs/features` | `docs/features`, whether or not `.dev` exists |
| R-6 | Value `.dev`, `.dev` exists | `.dev` |
| R-7 | Value `.dev`, `.dev` absent, `docs/features` exists | `docs/features` (one-release fallback, D-8) |
| R-8 | Value `.dev`, neither directory exists | `.dev` (creators make the configured layout) |

Errors are fail-fast. Hooks surface a resolver error through their existing fail-closed dependency pattern with a clear reason; the PowerShell resolver returns a typed failure for that purpose.

### Area map (resolution by name, D-6)

Consumers request an area by name; no consumer concatenates `/active` onto a root. `research`, `discovery` and `engineering` are not children of `docs/features`, so the map is a table, not a suffix rule.

| Area name | Root `docs/features` | Root `.dev` |
| --- | --- | --- |
| `active`, `completed`, `archive`, `potential`, `potential/promoted`, `epics`, `parallel`, `templates` | `docs/features/<area>` | `.dev/<area>` |
| `backlog` | `docs/features/backlog.md` | `.dev/backlog.md` |
| `research` (one-off) | `docs/research` | `.dev/research` |
| `discovery-templates` | `docs/discovery/templates` | `.dev/discovery/templates` |
| `engineering` | `docs/engineering` | `.dev/engineering` |

An unknown area name is an explicit error.

### Writer/matcher split

- Writers (code that creates or writes paths, or builds a path to read) use the resolved root through the area map.
- Matchers (regexes and prefix tests that recognize paths in prompts, checkpoints, diffs and arguments) accept the union of both known roots for the area during the fallback release, independent of the configured value. Without the split, a checkpoint written under one root would be rejected after the flip.

### Outputs

- No new artifacts at runtime. Folder-creation output changes from `<slug>-<issue>` to `<NNNN>-<feature>` when an issue number is supplied.
- The `potential_to_issue` status line names the folder that will actually be created: `Promoted -> <resolved active area>/<NNNN>-<feature>/`.

### Versioning and compatibility

- Default behavior is unchanged. Destination repositories without the key, or without the file, resolve `docs/features`.
- Existing date-first folder names keep parsing until child 7 migrates them.
- Extension and MCP package version bumps are assumed to happen at epic fan-in, not in this child (owner question OQ-5).

## API / CLI Surface

### TypeScript (`extensions/drm-copilot/src/lib/development-docs/`; no module imports `vscode`)

`root.ts`:

```ts
export const DEVELOPMENT_DOCS_ROOT_KEY = "development_docs_root";
export const DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features";
export const KNOWN_DEVELOPMENT_DOCS_ROOTS: ReadonlyArray<DevelopmentDocsRoot>; // ["docs/features", ".dev"]
export type DevelopmentDocsRoot = "docs/features" | ".dev";
export type DevelopmentDocsArea =
  | "active" | "completed" | "archive" | "potential" | "potential/promoted"
  | "epics" | "parallel" | "templates" | "backlog" | "research"
  | "discovery-templates" | "engineering";
export function resolveDevelopmentDocsRoot(fs: FileSystem, workspaceRoot: string): DevelopmentDocsRoot;
export function developmentDocsPath(root: DevelopmentDocsRoot, area: DevelopmentDocsArea): string;
export function knownRootPrefixes(area: DevelopmentDocsArea): ReadonlyArray<string>;
```

`feature-folder-name.ts`:

```ts
export type FeatureFolderName =
  | { format: "date-first"; date: string; feature: string; issueNumber: number | null }
  | { format: "issue-first"; issueNumber: number; feature: string }
  | { format: "other"; feature: string; issueNumber: number | null };
export function parseFeatureFolderName(name: string): FeatureFolderName;
export function formatFeatureFolderName(issueNumber: number, feature: string): string;
export function stripDateFirstPrefix(stem: string): string;
```

`write-scopes.ts`: the D-16 contract (see "Write-scope literal contract (D-16)").

The resolver reads `config/orchestration-routing.json` through the injected `FileSystem` (`src/lib/file-system.ts`), as `loadRoutingMatrix` does.

### Python (extend `scripts/dev_tools/json_config.py` in place)

```python
DEVELOPMENT_DOCS_ROOT_KEY = "development_docs_root"
DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features"
KNOWN_DEVELOPMENT_DOCS_ROOTS = ("docs/features", ".dev")

def resolve_development_docs_root(workspace: Path, *, read_text=None, is_dir=None) -> str: ...
def development_docs_path(workspace: Path, area: str, *, root: str | None = None) -> Path: ...
def known_root_prefixes(area: str) -> tuple[str, ...]: ...
def parse_feature_folder_name(name: str) -> FeatureFolderName: ...
def format_feature_folder_name(issue_number: int, feature: str) -> str: ...
```

The resolver takes the workspace root as an argument (not a module-relative path) because consumers such as `new_active_feature_folder_flow.py` operate on a `--workspace`. No new Python file, script, tool or entry point is added.

### PowerShell (new `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`)

- `Resolve-DevelopmentDocsRoot -WorkspaceRoot <path> [-ReadText <scriptblock>] [-TestDirectory <scriptblock>]` (I/O only through injected script blocks)
- `Get-DevelopmentDocsPath -Root <root> -Area <area>`
- `Get-DevelopmentDocsKnownRootPrefix -Area <area>` and `Get-DevelopmentDocsKnownRootPattern -Area <area>` (regex-escaped union, both separators)
- `ConvertFrom-FeatureFolderName -Name <name>` and `ConvertTo-FeatureFolderName -IssueNumber <n> -Feature <feature>`

The module follows the `.claude/lib` convention enforced by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`. Copies: `.claude/lib/development-docs/`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/development-docs/`, and the Codex source copy `extensions/drm-copilot/resources/lib/development-docs/`, published to `.codex/lib/development-docs/` by a new `VIRTUAL_RESOURCE_DIRECTORIES` entry in `src/lib/push-down/codex-agents-customizations.ts` and its existing Python twin `scripts/dev_tools/push_down_codex_and_agents_customizations.py`. Codex hooks import the published path first and the self-hosted `.claude/lib` path second. Hooks that import the module use the guarded import pattern. Hooks pass the root resolved by `Resolve-HookTargetWorktree` where they already have it, otherwise the session root. `feature-folder-resolution.ps1` stays pure; callers pass the known-root pattern into it.

The bundled standalone `new-potential-entry.ps1` (`scripts/dev-tools/` and `extensions/drm-copilot/resources/templates/`) gains a `-DevelopmentDocsRoot` parameter with the default `docs/features`; `RepoAutomationService.newPotentialEntry` passes the resolved root. `scripts/dev-tools/link-feature-docs.ps1` gains the same parameter.

### Feature-folder name rules (D-18, D-19)

| Case | Input | Result |
| --- | --- | --- |
| F-1 | `2026-10-30-foo-bar-1016` | date-first, date `2026-10-30`, feature `foo-bar`, issue 1016 |
| F-2 | `2026-10-30-foo-bar` | date-first, feature `foo-bar`, issue null (never issue 2026) |
| F-3 | `1016-foo-bar` | issue-first, issue 1016, feature `foo-bar` |
| F-4 | `0042-foo-bar` | issue-first, issue 42, feature `foo-bar` |
| F-5 | `subagentstop-envelope-core-897` | other, feature `subagentstop-envelope-core`, issue 897 |
| F-6 | `notes-feature` | other, feature `notes-feature`, issue null |

Formatter: `String(issueNumber).padStart(4, "0") + "-" + feature`, where `feature` is the potential stem with `stripDateFirstPrefix` applied and a trailing `-<issue>` removed.

| Case | Input | Result |
| --- | --- | --- |
| N-1 | (1016, `move-development-docs`) | `1016-move-development-docs` |
| N-2 | (42, `notes`) | `0042-notes` |
| N-3 | issue 0, negative, or non-integer | explicit error |
| N-4 | issue above 9999 | explicit error (D-18 fixes four digits; five digits would misparse under D-19) |
| N-5 | empty feature, feature failing the existing name pattern, or feature beginning with `\d{2}-\d{2}-` | explicit error |

Versioned subfolders (`v2`) are handled before parsing, as `file-prompt-variables.ts` does today.

### Folder creation

Path: MCP `new_active_feature_folder` -> `RepoAutomationService.newActiveFeatureFolder` -> `newActiveFeatureFolderServiceCall` -> `createActiveFolder` -> `buildFolderSlug`; the Python CLI `dev.new-active-feature` (`new_active_feature_folder_flow.py`, `new_active_feature_folder_io.py` `build_folder_slug`) follows the same rule.

- Issue number supplied: the folder is `<resolved active area>/<NNNN>-<feature>`.
- No issue number (blank, or `auto` with no `Issue:` line): the current slug is kept, without an issue prefix (OQ-4).
- Epic folders keep `<epics area>/<slug>` with no date or issue (D-22).

## Write-scope literal contract (D-16)

Epic child 3's agent generator consumes this contract. The contract is stated here precisely.

### Single source

`extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` is the only source of write-scope rules. No other file defines which development-docs literals an agent, the settings file or a hook argument must carry.

### Types and exports

```ts
export type WriteScopeArea =
  | "root"              // docs/features/**        | .dev/**
  | "active"            // docs/features/active/** | .dev/active/**
  | "potential"         // docs/features/potential/** | .dev/potential/**
  | "epics"             // docs/features/epics/**  | .dev/epics/**
  | "parallel"          // docs/features/parallel/** | .dev/parallel/**
  | "feature-research"  // docs/features/**/research/** | .dev/**/research/**
  | "one-off-research"  // docs/research/**        | .dev/research/**
  | "docs-broad";       // docs/**                 | .dev/**

export interface WriteScopeRule {
  readonly agent: string;           // logical agent name, e.g. "prd-feature"
  readonly tool: "Write" | "Edit";
  readonly area: WriteScopeArea;
  readonly leadingSlash: boolean;   // preserves the agent's existing spelling
}

export interface SettingsAllowRule {
  readonly tool: "Edit";
  readonly area: WriteScopeArea;
}

export interface RequiredArtifactRule {
  readonly agent: string;           // agent whose hook command carries -RequiredArtifact
  readonly token: string;           // e.g. "spec-path"
  readonly area: WriteScopeArea;    // e.g. "active"
  readonly suffixPattern: string;   // regex after the area, e.g. ".+/spec\\.md$"
}

export const WRITE_SCOPE_RULES: ReadonlyArray<WriteScopeRule>;
export const SETTINGS_ALLOW_RULES: ReadonlyArray<SettingsAllowRule>;
export const REQUIRED_ARTIFACT_RULES: ReadonlyArray<RequiredArtifactRule>;

// Input: one rule and a root list. Output: the exact literal strings, one per root, in root order.
// expandWriteScopeLiterals({agent:"prd-feature", tool:"Write", area:"active", leadingSlash:true},
//                          KNOWN_DEVELOPMENT_DOCS_ROOTS)
//   -> ["Write(/docs/features/active/**)", "Write(/.dev/active/**)"]
export function expandWriteScopeLiterals(
  rule: WriteScopeRule | SettingsAllowRule,
  roots: ReadonlyArray<DevelopmentDocsRoot>,
): string[];

// Input: one required-artifact rule and a root list. Output: one regex literal accepting every root.
// e.g. "^(?:docs/features|\\.dev)/active/.+/spec\\.md$"
export function expandRequiredArtifactPattern(
  rule: RequiredArtifactRule,
  roots: ReadonlyArray<DevelopmentDocsRoot>,
): string;
```

`SettingsAllowRule` carries no `leadingSlash`; settings literals have no leading slash. The `docs-broad` area keeps `docs/**` as its `docs/features` form because the existing atomic-planner and settings scopes name `docs/**`.

### Rule table (Phase 1 content)

| Surface | Tool | Area | Leading slash | Literals required during the fallback release |
| --- | --- | --- | --- | --- |
| `atomic-planner` | Edit, Write | docs-broad | no | `Edit(docs/**)`, `Edit(.dev/**)`, `Write(docs/**)`, `Write(.dev/**)` |
| `task-researcher` | Write | feature-research | yes | `Write(/docs/features/**/research/**)`, `Write(/.dev/**/research/**)` |
| `task-researcher` | Write | one-off-research | yes | `Write(/docs/research/**)`, `Write(/.dev/research/**)` |
| `prd-feature` | Write | active | yes | `Write(/docs/features/active/**)`, `Write(/.dev/active/**)` |
| `feature-review` | Write | active | yes | `Write(/docs/features/active/**)`, `Write(/.dev/active/**)` |
| `status-updater` | Write | root | yes | `Write(/docs/features/**)`, `Write(/.dev/**)` |
| `epic-review` | Write | root | yes | `Write(/docs/features/**)`, `Write(/.dev/**)` |
| `epic-planner` | Write, Edit | epics | no | `Write(docs/features/epics/**)`, `Write(.dev/epics/**)`, `Edit(docs/features/epics/**)`, `Edit(.dev/epics/**)` |
| `epic-planner` | Write | potential | no | `Write(docs/features/potential/**)`, `Write(.dev/potential/**)` |
| `epic-orchestrator` | Write, Edit | epics | no | as `epic-planner` epics |
| `parallel-orchestrator` | Write, Edit | parallel | no | `Write(docs/features/parallel/**)`, `Write(.dev/parallel/**)`, `Edit(docs/features/parallel/**)`, `Edit(.dev/parallel/**)` |
| `parallel-planner` | Write, Edit | parallel | no | as `parallel-orchestrator` |
| `.claude/settings.json` `permissions.allow` | Edit | docs-broad | n/a | `Edit(docs/**)`, `Edit(.dev/**)` |
| `prd-feature` hook `-RequiredArtifact` | n/a | active | n/a | token `spec-path`, pattern `^(?:docs/features|\.dev)/active/.+/spec\.md$` |
| `epic-review` hook `-RequiredArtifact` | n/a | epics | n/a | token `epic-audit-path`, pattern `^(?:docs/features|\.dev)/epics/.+/epic-audit\.\d{4}-\d{2}-\d{2}T\d{2}-\d{2}\.md$` |

Each agent keeps its existing spelling (with or without a leading `/`), so Phase 1 changes no matching behavior; normalization is left to child 3. The literals appear in `.claude/agents/<agent>.md` frontmatter `tools:` and as text in the base Codex agent files `.codex/agents/<agent>.toml` that carry them today (atomic-planner, prd-feature, feature-review, status-updater, epic-review); the Codex variants and bundle copies are regenerated by `scripts/dev_tools/generate_codex_agent_variants.py`.

### Literal-set rule

During the fallback release, every surface in the rule table contains `expandWriteScopeLiterals(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS)` for each of its rules, so both the `docs/features` form and the `.dev` form are present, with the `.dev` form mapping areas per D-6. After child 7 removes the fallback, `KNOWN_DEVELOPMENT_DOCS_ROOTS` shrinks to `.dev` and the checker then requires only the `.dev` literals.

### Checker test (three directions)

TypeScript Jest suite under `extensions/drm-copilot/test/lib/development-docs/` (for example `write-scopes.contract.test.ts`), reading repository files through an injected reader with forward-slash relative paths:

1. **Forward coverage.** For each rule, every expanded literal is present in the agent's `.claude/agents/<agent>.md` frontmatter `tools:` entries and, where the agent has a base Codex file, in `.codex/agents/<agent>.toml`; every `SETTINGS_ALLOW_RULES` literal is present in `.claude/settings.json` `permissions.allow`; every `REQUIRED_ARTIFACT_RULES` pattern is present in the agent's hook `command:` line.
2. **Reverse coverage.** Every `Write(`/`Edit(` entry in `.claude/agents/*.md`, `.codex/agents/*.toml` and `.claude/settings.json` that names `docs/features`, `docs/research`, `docs/**` or `.dev` is produced by a rule; an entry not produced by a rule fails the test.
3. **Root coverage.** For each rule, a sample path under each known root (for example `docs/features/active/x/spec.md` and `.dev/active/x/spec.md`) is matched by at least one expanded literal using the same glob compiler as `compileGlob`, and each required-artifact pattern accepts sample paths under both roots.

### Enforcement statement

Claude Code path-limited tool entries in agent frontmatter (for example `Write(/docs/features/active/**)`) and permission rules are declarative and cannot read configuration. The literals are therefore checked by the test above, not enforced by the runtime from the configured key. Whether a given path-limited entry restricts writes at runtime is runtime behavior outside this repository; this child neither relies on nor changes it.

### Interface for epic child 3

Child 3's agent generator imports `WRITE_SCOPE_RULES`, `SETTINGS_ALLOW_RULES`, `REQUIRED_ARTIFACT_RULES`, `expandWriteScopeLiterals`, `expandRequiredArtifactPattern` and `KNOWN_DEVELOPMENT_DOCS_ROOTS`, emits the literals, and uses the three-direction checker as its `--check` assertion for write scopes.

## Data & State

- New configuration state: one top-level key in `config/orchestration-routing.json` and its two bundle copies.
- Invariants: the resolved root is always a member of `KNOWN_DEVELOPMENT_DOCS_ROOTS`; matchers accept every member of `KNOWN_DEVELOPMENT_DOCS_ROOTS`; every write-scope literal is produced by a rule.
- No persistence or caching beyond reading the configuration file on each resolution.
- No migration or backfill in this child. Existing folders, fixtures and records keep their names and paths.

## Production Consumers (routing scope)

The authoritative per-file inventory is section 2 of `research/research.2026-10-30T21-15.md`. Disposition rules:

- **Route** (writers: path constants and joins) obtain the path from the resolver through the area map.
- **Route (union)** (matchers: regexes and prefix tests) accept the known-root union.
- **Msg** (user-facing messages) build path text from the resolver.
- **Stay** (prose, comments, spec citations, historical examples, frozen JSON fixtures) are unchanged.

Specific dispositions recorded from research:

- `pr_context/collector.py` and `lib/pr-context/collector-core.ts` docs bucket: add `.dev/`.
- `hook-docs-only-diff.ps1` `Get-DocsOnlyDiffTextViolation`: add `.dev/` as a whole, mirroring its current classification, in which `docs/` is exempt as a whole (including `docs/engineering` and `docs/discovery`). Recorded under OQ-3.
- `extension-command-helpers.ts` `ACTIVE_FEATURE_DOCS_DIRECTORY` and `POTENTIAL_DOCS_DIRECTORY` are replaced with resolver calls.
- `build_discovery_runtime.py` `RESOURCE_ROOTS` stays (out of scope; discovery moves in Phase 3).
- The Claude/Codex twin `feature-folder-resolution.ps1` keeps byte identity and stays pure.

## CI Docs-Only Scope (D-12)

`config/ci-docs-only-paths.json` (matched by ordinal prefix in `scripts/ci/CiChangeScope.psm1`):

- Add include prefix `.dev/`.
- Add exclude prefixes `.dev/templates/` and `.dev/potential/template.md` (mirroring today's `docs/features/templates/` and `docs/features/potential/template.md` exclusions).
- Add exclude prefixes `.dev/engineering/` and `.dev/discovery/`, because `docs/engineering/` and `docs/discovery/` are not docs-only today (OQ-3).
- Existing `docs/` include and exclude prefixes are unchanged.

The execution-environment brief section `## CI Shape and Required Checks` (all byte-identical copies) and `.github/workflows/README.md` are updated in the same change, as the brief's maintenance rule requires. The allowlist file is not itself docs-only, so this change runs full CI.

## JSON Governance (D-14)

`GOVERNED_GLOBS` in `scripts/dev_tools/json_config.py` and `extensions/drm-copilot/src/lib/json-config.ts` gain `.dev/**/*.json`; `docs/**/*.json` stays.

## Dot-Folder Handling (D-13)

Research findings, stated as found:

- No production code imports a third-party glob library (`fast-glob`, `glob`, `minimatch`, `globby`, `picomatch`, `micromatch`, `tinyglobby`) or calls `vscode.workspace.findFiles`, and no production code invokes ripgrep (`rg` appears only as a token in command parsers).
- The TypeScript glob is the in-house `RealFileSystem.glob` with `compileGlob` in `src/lib/file-system.ts`, which already matches dot-prefixed names.
- `isExcludedDirectoryName` in `src/lib/push-down/claude-blast-radius-derive-manifests.ts` prunes dot directories and `docs` on purpose; `.dev` is a location bucket like `docs`, so the exclusion stays.
- Python `Path.glob` and PowerShell `Get-ChildItem -Recurse` include dot folders by default.

D-13 therefore applies to the in-house `RealFileSystem.glob` consumers and to the blast-radius derive exclusion: the include-dot behavior of `compileGlob`/`RealFileSystem.glob` becomes explicit (a named, documented constant or comment), and each consumer receives a test that finds a file under `.dev`:

- `src/lib/json-config.ts` `iterGovernedFiles`
- `src/lib/validate/json-validator.ts`
- `src/lib/validate/evidence-locations.ts`
- `src/lib/pr-context/verification-evidence.ts`
- `src/lib/pr-context/feature-docs-parsers.ts`
- `isExcludedDirectoryName(".dev")` returns `true` (the exclusion is deliberate)

All such tests use in-memory fakes; no temporary files are created.

## Constraints & Risks

- Scale (full design): about 896 files outside `docs/` mention `docs/features`; Phase 1 changes production consumers only, about 40 PowerShell, 28 Python and 25 TypeScript production files plus new modules (planning estimates, not acceptance criteria). The Python and PowerShell batch budgets require the `large` route.
- Malformed routing file risk: a destination with a malformed `config/orchestration-routing.json` would start blocking hooks that previously ignored the file. Mitigation: typed failure and a clear reason per hook.
- Codex push-down overwrite of a destination key value (recorded for child 4).
- Stale help text in `OrchestratorStateRoutingMatrix.psm1`, `ModelRouting.psm1` and `CodexDeployment.psm1` stating the routing file is not shipped; the file is published by both push-downs. An absent file must still resolve the default.
- File size: `flow.ts`, `feature-folder-resolution.ps1` and larger hooks approach the 700 and 800 line tiers; new logic goes into the new modules.
- Linux CI: case-sensitive paths, forward slashes, no drive-letter fixtures in the write-scope checker.
- Test isolation: resolver tests must not read the real configuration file or depend on whether `.dev` exists; readers and directory probes are injected in all three runtimes.
- Enforcement hooks do not invoke Python.

## Language Choices (cost and risk)

| Component | Language | Cost | Risk |
| --- | --- | --- | --- |
| New resolver, parser and write-scope modules | TypeScript | Jest `coverageThreshold` entry per new file; no `vscode` import because `packages/mcp-server` bundles the source with `vscode` shimmed to `{}` | A `vscode` import would fail at runtime on the MCP path |
| Write-scope checker | TypeScript | Reads files outside the extension directory through an injected reader | Path joins must be forward-slash and drive-letter free for Linux CI. Rejected: Pester or Python checker, which would duplicate the rule table child 3 needs |
| PowerShell resolver | PowerShell module | Bundle copy, Codex source copy, push-down publication entry, pack manifests | Hooks gain an import dependency; guarded import pattern required |
| Python resolver | Python, by extending `scripts/dev_tools/json_config.py` in place | Module docstring widens from JSON governance to repository layout configuration | Existing Python consumers read the key, so a Python resolver is required. No new Python scripts, tools, generators, checkers or entry points (epic language directive). `json_config` imports nothing from `scripts.dev_tools`, so no import cycle |
| Enforcement hooks | PowerShell | none | Hooks do not invoke Python |

## Execution Precondition

Execution starts only after the parallel run `bugs-1001-1002-1003-1006` has merged to `main`. The plan names each file below, and its Phase 0 gate re-checks each against current `origin/main` and stops for re-planning when a named file, symbol or heading has moved. Overlapping files (research section 9):

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.claude/lib/blast-radius/BlastRadius.psm1`, `BlastRadiusTokenShape.psm1`, `BlastRadiusWriteIntent.psm1` and their bundle copies
- `scripts/dev_tools/compute_blast_radius.py`, `_blast_radius_token_shapes.py`, `_blast_radius_write_intent.py`
- `.claude/agents/epic-orchestrator.md`, `parallel-orchestrator.md`, `parallel-planner.md` and the bundle copies of the latter two
- `.claude/settings.json`
- the execution-environment brief, all copies
- `extensions/drm-copilot/jest.config.cjs`, `package.json`, `CHANGELOG.md`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- tests: `test_parallel_planner_surface_contracts.py`, `test_execution_environment_brief_contracts.py`, `test_push_down_*_resource_contracts.py`, `test_push_down_*_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `claude-architecture-doc.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `ClaudeLibModuleConvention.Tests.ps1`, `parallel_orchestrator_surface_test_support.py`
- read but not edited: `scripts/dev_tools/generate_codex_agent_variants.py`, `config/poshqc-coverage.json`, `config/file-size-baseline.json`

The blast-radius files carry the heaviest overlap and belong in a late plan phase after a second conflict re-check.

## Implementation Strategy

- Key and resolvers: routing-config key in all copies; TypeScript `root.ts`; Python additions to `json_config.py`; PowerShell `DevelopmentDocsRoot.psm1` with bundle and Codex source copies; Codex `VIRTUAL_RESOURCE_DIRECTORIES` entries (TypeScript and the existing Python twin); pack manifests; Jest coverage entries.
- Parsers and folder creation: parser and formatter in three runtimes; `buildFolderSlug`/`build_folder_slug`, `createActiveFolder`, the potential-to-issue status line; replace the existing parsers (`resolveNameFromFeatureFoldername`, the two Python `_resolve_name_from_feature_foldername` copies, `_TRAILING_ISSUE_IN_FEATURE_DIR_PATTERN` in `plan_progress_report.py`).
- Consumers: TypeScript, Python and PowerShell consumers per the research inventory; bundle copies.
- Write-scope contract: `write-scopes.ts`, checker test, agent frontmatter and Codex base literals, generator run and `--check`, `.claude/settings.json`, `PINNED_FROZEN_SURFACE_HASHES` re-baseline with a dated comment for each changed pinned agent file.
- CI docs-only allowlist, brief copies and workflow README.
- Blast-radius consumers last, after a second conflict re-check.
- Dependencies: none added.
- Logging: resolver errors carry the configuration path, the key and the offending value.
- Rollout: default unchanged; the flip is child 7.

## Owner Questions (recorded interpretations awaiting confirmation)

- **OQ-1.** An absent key resolves the default `docs/features` and does not probe `.dev` first (R-2). Reason: D-8 describes a one-release fallback after the flip, and probing `.dev` in Phase 1 would change behavior in a destination that has a `.dev` folder for an unrelated purpose.
- **OQ-3.** `.dev/engineering/` and `.dev/discovery/` are excluded from the CI docs-only scope, preserving today's classification of `docs/engineering/` and `docs/discovery/`. In `hook-docs-only-diff.ps1`, `.dev/` is added as a whole because that hook exempts `docs/` as a whole today.
- **OQ-4.** When the folder-creation tool has no issue number, it keeps the current slug (no issue prefix) rather than failing.
- **OQ-5.** Extension and MCP package version bumps (`extensions/drm-copilot/package.json`, `CHANGELOG.md`) happen at epic fan-in, not in this child.
- OQ-2 (new Python library module versus extending `json_config.py`) is settled by the delegation for this child: extend `json_config.py` in place.

## Acceptance Criteria

### Configuration key and resolvers

- [ ] `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` each contain the flat top-level entry `"development_docs_root": "docs/features"`, and `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` passes.
- [ ] The TypeScript resolver suite `extensions/drm-copilot/test/lib/development-docs/root.test.ts` covers resolution cases R-1 to R-8 from this spec using the in-memory `FileSystem` fake, and passes.
- [ ] Python tests for `resolve_development_docs_root` in `scripts/dev_tools/json_config.py` cover cases R-1 to R-8 with injected readers and directory probes, and pass.
- [ ] The Pester suite `tests/scripts/claude-lib/development-docs/DevelopmentDocsRoot.Tests.ps1` covers cases R-1 to R-8 for `Resolve-DevelopmentDocsRoot` with injected script blocks, and passes.
- [ ] In each runtime, the area-path function returns the area-map value for every listed area under both `docs/features` and `.dev`, and an unknown area name raises an explicit error; each case is asserted by a unit test.
- [ ] In each runtime, the known-root prefix function returns both the `docs/features` form and the `.dev` form for each area, and the PowerShell pattern function matches sample paths with forward and back slashes under both roots; each case is asserted by a unit test.
- [ ] No module under `extensions/drm-copilot/src/lib/development-docs/` imports `vscode`, asserted by a test or a dependency-cruiser rule that fails on such an import.
- [ ] The resolver and parser in Python are added to `scripts/dev_tools/json_config.py`; the change adds no new Python file under `scripts/`, no new `pyproject.toml` script entry, and no Python invocation in any enforcement hook (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes).

### Consumer routing and behavior

- [ ] With the default key, the full Python, PowerShell and TypeScript test suites pass, and the only changed expectations in existing tests are the folder-naming and status-line expectations for supplied issue numbers.
- [ ] A recorded repository search over the production roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts` and `extensions/drm-copilot/src` for `docs/features` and its separator-variant regex forms returns only the resolver constant definitions and entries on a recorded allowlist of Stay rows from the research inventory; the search command, output and allowlist are stored under the feature folder's `evidence/` directory.
- [ ] TypeScript tests show that, with the routing configuration set to `.dev` and a `.dev` directory present in the in-memory fake, `createActiveFolder`, the new potential bug entry flow and the potential-to-issue promotion write under `.dev/<area>`, and with `.dev` absent they write under `docs/features/<area>`.
- [ ] Matcher tests in each runtime show that the feature-folder record validators (`orchestrator-state-feature-folder-record.ts`, `_orchestrator_state_feature_folder_record.py`, `OrchestratorStateFeatureFolderRecord.psm1`) accept both `docs/features/active/<folder>` and `.dev/active/<folder>` independent of the configured value.
- [ ] Pester tests for `enforce-orchestration-preimplementation-gate.ps1` (Claude and Codex) and `validate-task-researcher-output.ps1` show that paths under `.dev/active/`, `.dev/epics/` and `.dev/research/` are recognized alongside their `docs/features` and `docs/research` forms.
- [ ] `new-potential-entry.ps1` in `scripts/dev-tools/` and in `extensions/drm-copilot/resources/templates/` accepts `-DevelopmentDocsRoot` with the default `docs/features`, the two copies have equal text, and a test shows `RepoAutomationService.newPotentialEntry` passes the resolved root.
- [ ] A resolver error (malformed routing JSON or an out-of-set value) causes a hook that reads the key to fail closed with a reason naming the configuration file and key, asserted by a Pester test.

### CI docs-only scope and JSON governance

- [ ] `config/ci-docs-only-paths.json` includes `.dev/` and excludes `.dev/templates/`, `.dev/potential/template.md`, `.dev/engineering/` and `.dev/discovery/`, with existing `docs/` entries unchanged; `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` asserts that `.dev/active/x/spec.md` is docs-only and that `.dev/templates/x.md`, `.dev/potential/template.md`, `.dev/engineering/x.md` and `.dev/discovery/x.md` are not, and passes.
- [ ] `tests/scripts/ci/CiChangeScope.Tests.ps1`, `Invoke-CiChangeScope.Tests.ps1`, `Invoke-CiChangeScopeMergeBase.Tests.ps1` and `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` pass.
- [ ] A Pester test shows `Get-DocsOnlyDiffTextViolation` in `hook-docs-only-diff.ps1` treats a `.dev/` path as docs-only.
- [ ] The execution-environment brief section `## CI Shape and Required Checks` and `.github/workflows/README.md` list the `.dev/` docs-only prefix and its exclusions, and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` passes.
- [ ] `GOVERNED_GLOBS` in `scripts/dev_tools/json_config.py` and in `extensions/drm-copilot/src/lib/json-config.ts` contains both `.dev/**/*.json` and `docs/**/*.json`; a Python test using the `mem_fs_path` fixture and a Jest test using the in-memory fake each show that governed-file discovery returns a JSON file under `.dev/`.

### Dot-folder handling

- [ ] The include-dot behavior of `compileGlob`/`RealFileSystem.glob` in `src/lib/file-system.ts` is stated by a named constant or documented comment, and a test shows the matching seam matches `.dev/active/x/spec.md` for the patterns `**` and `**/*.md`.
- [ ] Each of `iterGovernedFiles` (`json-config.ts`), `json-validator.ts`, `evidence-locations.ts`, `verification-evidence.ts` and `feature-docs-parsers.ts` has a Jest test, using in-memory fakes, that finds a file under `.dev`.
- [ ] A Jest test asserts `isExcludedDirectoryName(".dev")` returns `true`.

### Feature-folder name parser and folder creation

- [ ] `extensions/drm-copilot/test/lib/development-docs/feature-folder-name.test.ts` asserts parser cases F-1 to F-6 and formatter cases N-1 to N-5 from this spec, and passes.
- [ ] Python tests for `parse_feature_folder_name` and `format_feature_folder_name` and Pester tests for `ConvertFrom-FeatureFolderName` and `ConvertTo-FeatureFolderName` assert the same cases F-1 to F-6 and N-1 to N-5, and pass.
- [ ] `resolveNameFromFeatureFoldername` (`file-prompt-variables.ts`), `_resolve_name_from_feature_foldername` in `resolve_execute_plan_prompt.py` and in `resolve_file_prompt.py`, and the trailing-issue extraction in `plan_progress_report.py` delegate to the shared parser, and their test suites include an issue-first folder-name case that passes.
- [ ] Folder-creation tests in TypeScript (`io.test.ts`, `flow.test.ts`, `new-active-feature-folder-service-call.test.ts`) and Python (`test_new_active_feature_folder.py`) show that issue 1016 with potential stem `2026-10-30-foo` creates `<active area>/1016-foo`, issue 42 creates `<active area>/0042-<feature>`, and a request without an issue number keeps the current slug.
- [ ] Epic folder creation still produces `<epics area>/<slug>` with no date or issue prefix, asserted by an existing or new test.
- [ ] Potential-to-issue status-line tests in TypeScript (`content.test.ts`, `promotion.test.ts`) and Python (`test_potential_to_issue_content.py`, `test_potential_to_issue.py`) assert `Promoted -> docs/features/active/<NNNN>-<feature>/` under the default root.

### Write-scope literal contract (D-16)

- [ ] `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts` exports `WriteScopeArea`, `WriteScopeRule`, `SettingsAllowRule`, `RequiredArtifactRule`, `WRITE_SCOPE_RULES`, `SETTINGS_ALLOW_RULES`, `REQUIRED_ARTIFACT_RULES`, `expandWriteScopeLiterals` and `expandRequiredArtifactPattern` with the signatures in this spec, and unit tests assert the rule-table rows and example outputs in this spec.
- [ ] The checker suite under `extensions/drm-copilot/test/lib/development-docs/` passes all three directions: forward coverage (every contracted literal present in each `.claude/agents/*.md`, each base `.codex/agents/*.toml` and `.claude/settings.json`), reverse coverage (every `docs/features`, `docs/research`, `docs/**` or `.dev` scope found in those files is produced by a rule), and root coverage (sample paths under both roots match the expanded literals and required-artifact patterns).
- [ ] Each agent file and `.claude/settings.json` in the rule table carries both the `docs/features` form and the `.dev` form of its literals with its existing leading-slash spelling, and the `prd-feature` and `epic-review` `-RequiredArtifact` patterns accept paths under both roots.
- [ ] `scripts/dev_tools/generate_codex_agent_variants.py --check` reports no drift after the base Codex agent files are edited, and `test_codex_agent_wrapper_contracts.py` passes.
- [ ] `PINNED_FROZEN_SURFACE_HASHES` is re-baselined with a dated comment for each pinned agent file whose content changes, and the parallel-orchestrator surface tests and `test_parallel_planner_surface_contracts.py` pass.

### Mirrors, manifests and Codex counterparts

- [ ] `DevelopmentDocsRoot.psm1` exists with equal text at `.claude/lib/development-docs/`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/development-docs/` and `extensions/drm-copilot/resources/lib/development-docs/`, and `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` passes.
- [ ] The Codex `VIRTUAL_RESOURCE_DIRECTORIES` entry publishing `.codex/lib/development-docs/` exists in `codex-agents-customizations.ts` and in `push_down_codex_and_agents_customizations.py`, and `test_push_down_codex_and_agents_virtual_paths.py` passes.
- [ ] `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` list the new module, and `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [ ] Every edited file under `.claude/` and `.codex/` has equal text in its bundle copy, and `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_claude_rules_frontmatter.py`, `test_push_down_issue_824_follow_ups.py`, `test_typescript_toolchain_instruction_contracts.py`, `claude-architecture-doc.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` pass.

### Scope boundary, quality and evidence

- [ ] After this child, the repository contains no `.dev/` directory, `development_docs_root` is `docs/features`, no existing feature folder is renamed, and no migration command is added.
- [ ] Each new TypeScript production file under `src/lib/development-docs/` has its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` with `lines: 85` and `branches: 75`, and coverage evidence for changed code meets 85% line coverage in every language and 75% branch coverage for Python and TypeScript, recorded under the feature folder's `evidence/coverage/`.
- [ ] The seven-stage toolchain passes in a single pass for Python, PowerShell and TypeScript, and no changed production file exceeds 800 lines.
- [ ] A Phase 0 evidence artifact under the feature folder's `evidence/baseline/` records that the parallel run `bugs-1001-1002-1003-1006` has merged and that each file in "Execution Precondition" was re-checked against `origin/main` before any edit.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [x] Unit coverage areas: resolver in each runtime with the key set to each root; fallback order; migration command including idempotence and link rewriting; dot-folder discovery; write-scope coverage; docs-only scope. (Migration command items belong to child 7.)
- [x] Integration scenarios: a full toolchain run with the key at `docs/features` and at `.dev`; a migration of a fixture repo and a second no-op run; a destination without the key. (Migration and the full `.dev` toolchain run belong to child 7.)
- [ ] CLI/API examples
