# Research: #1016 Phase 1 (epic #1018 child 2) - development_docs_root resolver, folder-name parser, write-scope contract

- Issue: #1016
- Epic: #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 2
- Branch: `feature/dev-docs-root-resolver-phase1-1016`
- Mode: preparation, research only. No production file was changed.
- Settled design: `docs/features/potential/promoted/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production.md` (D-1 to D-22). Nothing here re-opens a decision. Where the text of a decision leaves an implementation choice open, this note records a recommendation and marks the point as an interpretation for the planner or as an owner question.

All findings were verified with Read, Grep and Glob against the branch tree. Facts that need `git show` or `gh` are marked **ORCHESTRATOR-CONFIRM**.

## 1. Where the key lives

### Survey of configuration that all three runtimes already read

| File | Python | PowerShell | TypeScript | Pushed down |
| --- | --- | --- | --- | --- |
| `config/orchestration-routing.json` | `scripts/dev_tools/_orchestrator_state_route_gates.py` `load_routing_matrix` (path fixed relative to the module, `ROUTING_MATRIX_PATH`) | read at runtime by `.codex/scripts/epic-child-launch-runtime.ps1`, `.codex/scripts/resume-epic-child.ps1`, `.codex/hooks/enforce-epic-child-worktree-binding.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`; the `.claude/lib` routing modules pin constants and do not read it | `src/lib/validate/orchestrator-state-routing.ts` `loadRoutingMatrix(fs, root)` (workspace-relative, `ROUTING_MATRIX_RELATIVE_PATH`) | Yes. Claude push-down merges it (`ROUTING_MERGE_RELATIVE_PATH`, `RoutingMergeFileSystem` in `src/lib/push-down/claude-routing-merge.ts`; Python twin `scripts/dev_tools/push_down_claude_routing_merge.py`). Codex push-down publishes it from `extensions/drm-copilot/resources/config/orchestration-routing.json` through `VIRTUAL_RESOURCE_PAIRS` (`src/lib/push-down/codex-agents-customizations.ts`), as a plain write (no merge code in that module). |
| `config/blast-radius.json` | `compute_blast_radius.py` | `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | `claude-blast-radius-derive*.ts` | Yes, but derived from the destination layout on every push (`BlastRadiusDeriveFileSystem`) and composed with a destination overlay; not suitable for a user-set key. |
| `config/ci-docs-only-paths.json` | no | `scripts/ci/CiChangeScope.psm1` | no | No (repo-only CI). |
| `config/poshqc-*.json`, `config/file-size-baseline.json`, `config/orchestration-handoff*.json` | partial | partial | partial | Handoff files only (Codex). Unrelated semantics. |

### Recommendation

Put the key in `config/orchestration-routing.json` as a flat top-level scalar:

```json
"development_docs_root": "docs/features"
```

Rationale:

- It is the only configuration file that the Python, PowerShell and TypeScript code already read and that both the Claude and the Codex push-downs already publish into destination repositories. No new publication plumbing, pack-manifest entry or bundle path is needed for the key itself.
- The Claude routing merge keeps a destination's existing top-level keys and appends missing source keys (merge loop over `Object.entries(destination)` then `Object.entries(source)` in `claude-routing-merge.ts`). A destination that later sets `.dev` keeps its value on the next Claude push-down. The merge handles scalar top-level values.
- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` asserts only byte identity between `config/orchestration-routing.json` and its bundled copy, so a new top-level key needs the same edit in all three copies: `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json`, `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`.

Risks to carry into the plan:

- The Codex push-down writes `config/orchestration-routing.json` without merging, so a destination that flipped the key loses the flip on a Codex push-down. Phase 1 keeps the default, so behavior is unaffected. Record this for child 4 (push-down consolidation), which owns destination-edit preservation.
- `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` and the `ModelRouting.psm1`/`CodexDeployment.psm1` help text say the file is not shipped to consumer repositories. That text is stale: `ROOT_FOLDERS = [".claude", "config"]` in `claude-customizations.ts` publishes it. The hooks that read the key therefore need the file to exist in destinations, which it does after a Claude or Codex push-down. A destination without the file must still work, so an absent file means the default.

Rejected alternative: a new dedicated `config/development-docs.json`. It separates the concern more cleanly, but it needs new entries in both push-downs, both pack manifests, a merge decorator to keep a destination flip, and new parity tests. It also adds a file that no runtime reads today.

### Resolution semantics (interpretation for the planner)

- Allowed values: exactly `docs/features` and `.dev` (closed set `KNOWN_DEVELOPMENT_DOCS_ROOTS`). Any other value, a blank value, a non-string, a backslash, a leading `/`, or a `..` segment is an explicit error (fail fast).
- Absent file, unreadable file or absent key: the default `docs/features`. Malformed JSON: an explicit error. Hooks surface the error through their existing fail-closed dependency pattern. Risk: a destination with a malformed routing file would start blocking hooks that previously ignored the file. Mitigation: the PowerShell resolver returns a typed failure and each hook reports a clear reason.
- Fallback (D-8; the `.dev`-then-`docs/features` order from the delegation brief): the configured root is preferred when its directory exists. When the configured root is `.dev`, `.dev` is absent and `docs/features` exists, the resolver returns `docs/features`. When the configured root is `docs/features` (the Phase 1 default), the resolver returns `docs/features` whether or not `.dev` exists, so "behavior identical" holds. When neither directory exists, the configured root is returned, so creators make the configured layout.
- **Owner question OQ-1**: whether an absent key should probe `.dev` first (literal reading of "resolve `.dev` when it exists") or use the default `docs/features` (reading of "default `docs/features` ... behavior identical"). The recommendation is the default, because D-8 describes a one-release fallback after the flip, and probing `.dev` in Phase 1 would change behavior in a destination that has a `.dev` folder for an unrelated purpose.
- Split between writers and matchers: code that creates or writes paths uses the resolved root. Code that recognizes paths in prompts, checkpoints, diffs or arguments (regexes, `StartsWith` prefixes) accepts the union of both known roots during the fallback release, independent of the configured value. Without this split, a checkpoint written under one root would be rejected after a flip.
- Area map (the `features` level is dropped under `.dev`, D-6):

| Area | Root `docs/features` | Root `.dev` |
| --- | --- | --- |
| active, completed, archive, potential, potential/promoted, epics, parallel, templates | `docs/features/<area>` | `.dev/<area>` |
| backlog | `docs/features/backlog.md` | `.dev/backlog.md` |
| one-off research | `docs/research` (not under the root) | `.dev/research` |
| discovery templates | `docs/discovery/templates` | `.dev/discovery/templates` |
| engineering | `docs/engineering` | `.dev/engineering` |

The resolver exposes areas by name (for example `developmentDocsPath(layout, "active")`) so no consumer concatenates `/active` onto a root. `research`, `discovery` and `engineering` are not children of `docs/features`, which is why the map is a table and not a suffix rule.

### Reading mechanism per runtime

- TypeScript: `resolveDevelopmentDocsRoot(fs: FileSystem, workspaceRoot: string)` reads `config/orchestration-routing.json` through the injected `FileSystem` (`src/lib/file-system.ts`), like `loadRoutingMatrix`. Tests use the in-memory fakes.
- Python: `resolve_development_docs_root(workspace: Path, *, read_text=...)` with an injectable reader. It must take the workspace root, not `Path(__file__).parents[2]` as `_orchestrator_state_route_gates.ROUTING_MATRIX_PATH` does, because consumers such as `new_active_feature_folder_flow.py` operate on a `--workspace`.
- PowerShell: `Resolve-DevelopmentDocsRoot -WorkspaceRoot <path> [-ReadText <scriptblock>]` with `ConvertFrom-Json`. Hooks pass the root resolved by `Resolve-HookTargetWorktree` (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`) where they already have it, otherwise the session root.
- Bundled standalone PowerShell scripts (`resources/templates/new-potential-entry.ps1`) do not read the config. The TypeScript service resolves the root and passes it as a new `-DevelopmentDocsRoot` argument (`RepoAutomationService.newPotentialEntry` in `src/repo-automation-service.ts`), with the default `docs/features` when the argument is absent.

### Package boundary

- All TypeScript lives in `extensions/drm-copilot/src`. `packages/mcp-server` (`@danmoisan/drm-copilot-mcp`) has no source of its own: `packages/mcp-server/esbuild-mcp-server.cjs` bundles `extensions/drm-copilot/src/mcp-server.ts` and shims `vscode` to `{}`. The resolver, parser and write-scope modules must not import `vscode`, or the MCP path will fail at runtime when a `vscode` API is called.
- Publishing the MCP package version is outside this child. **ORCHESTRATOR-CONFIRM** whether the extension and MCP versions are bumped by this child or at epic fan-in (`extensions/drm-copilot/package.json` and `CHANGELOG.md` are both in the conflict list).

## 2. Inventory of production consumers

Kind codes: **C** path constant or join, **P** prefix test, **R** regex, **S** permission or write scope, **M** user-facing message, **X** prose or comment. Disposition: **Route** = Phase 1 routes it through the resolver (writers) or the known-root union (matchers); **Msg** = message text built from the resolver; **Stay** = prose, comment, or historical example that stays. `[CONFLICT]` = listed in the parallel-run blast radius (section 9).

### PowerShell - `.claude/hooks`

| File | Symbol / site | Kind | Disposition |
| --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.ps1` [CONFLICT] | `-cmatch '(^|/)docs/features/active/'`; `$featureFolder.StartsWith('docs/features/active/')` | R, P | Route (union) |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | exempt prefix list (`docs/features/epics/`, `parallel/`, `active/`, `potential/`) | P | Route (union) |
| `enforce-orchestration-preimplementation-gate-modes.ps1` | `-notmatch '(^|/)docs/features/epics/'` | R | Route (union) |
| `enforce-completion-helpers.ps1` | `$prefix = 'docs/features/active/'` | P | Route (union; existence check against resolved root) |
| `enforce-completion-consistency.ps1` | feature-folder message | M | Msg |
| `enforce-parallel-drift-gate.ps1` | `$script:ActiveFeatureRoot = 'docs/features/active'` | C | Route |
| `enforce-prd-feature-before-planner-helpers.ps1` | `IndexOf('docs/features/active/')`; token regex `docs[\\/]+features[\\/]+active` | P, R | Route (union) |
| `enforce-parallel-cohort-barrier.ps1` | block reason text | M | Msg |
| `enforce-feature-folder-order.ps1` | `'(^|/)docs/features/(active|archive)/[^/]+/plan...'` | R | Route (union) |
| `feature-folder-resolution.ps1` (byte-identical Codex twin) | `Find-FeatureFolderCandidate` regex; `ConvertTo-FeatureFolderBasename` prefix strip | R | Route (union); keep the file pure by passing the root set as a parameter |
| `validate-executor-output.ps1` | `StartsWith('docs/features/')` for `preflight-fix-record` | P | Route (union) |
| `validate-feature-review-coverage-rules.ps1` | `^docs/features/active/(?<Folder>...)` patterns | R | Route (union) |
| `validate-feature-review-coverage.ps1` | messages | M | Msg |
| `validate-task-researcher-output.ps1` | `Test-IsUnderResearchRoot` prefixes `docs/features/`, `docs/research/`; Pre-Mortem applicability `StartsWith('docs/features/')`; messages | P, M | Route (union of both roots and both research roots) |
| `hook-docs-only-diff.ps1` | `Get-DocsOnlyDiffTextViolation` `StartsWith('docs/')` (pr-author and merge docs-only exemptions) | P | Route: add `.dev/` so the exemption matches the CI docs-only scope (D-12 intent). Interpretation; see OQ-3. |
| `enforce-evidence-locations.ps1`, `enforce-epic-wave-barrier.ps1`, `hook-command-*.ps1`, `subagentstop-envelope.ps1`, `validate-required-artifact-output.ps1` | help text, spec citations | X | Stay |

### PowerShell - `.claude/lib`

| File | Symbol | Kind | Disposition |
| --- | --- | --- | --- |
| `worktree-resolution/WorktreeTargetResolution.psm1` | `$script:FeatureFolderPattern` | R | Route (union) |
| `worktree-resolution/EpicScopeReadiness.psm1` | `$script:EpicManifestPattern` | R | Route (union) |
| `blast-radius/BlastRadius.psm1` [CONFLICT] | `$script:FeatureFolderRoot`, `$script:FeatureFolderPrefix` | C, P | Route |
| `blast-radius/BlastRadiusTokenShape.psm1` [CONFLICT] | `$script:FeatureCorpusPrefix` | P | Route (union) |
| `blast-radius/BlastRadiusWriteIntent.psm1` [CONFLICT] | `StartsWith('docs/features/')` | P | Route (union) |
| `orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` | `$script:LifecyclePrefixes` | P | Route (union) |
| `orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1` | `$script:FEATURE_FOLDER_PATH_PATTERN`, `$script:ERROR_PATH_FORMAT` | R, M | Route (union) |
| `orchestrator-state/OrchestratorStateIssueAdoption.psm1` | `$script:POTENTIAL_RECORD_PREFIX` | P | Route (union) |
| `orchestrator-state/OrchestratorStateCheckpointValue.psm1`, `bash/report-lane-assertion.sh` | comments, usage text | X | Stay |

### PowerShell - `.codex/hooks` and `.codex/scripts`

| File | Symbol | Kind | Disposition |
| --- | --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` [CONFLICT] | as Claude twin | R, P | Route (union) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` [CONFLICT] | `$script:EpicScopeManifestPattern` | R | Route (union) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `-modes.ps1` | as Claude twins | P, R | Route (union) |
| `.codex/hooks/enforce-completion-helpers.ps1`, `enforce-completion-consistency.ps1` | as Claude twins | P, M | Route / Msg |
| `.codex/hooks/feature-folder-resolution.ps1` | twin | R | Route (keep byte identity with Claude) |
| `.codex/hooks/enforce-epic-planning-only.ps1` | `'(^|/)docs/features/(?:active|potential)/'` | R | Route (union) |
| `.codex/hooks/authorize-root-epic-invocation.ps1` | epic reference regex; `$kickoffPath = "docs/features/epics/$slug/epic-kickoff.md"` | R, C | Route |
| `.codex/hooks/record-subagent-routing-attestation.ps1` | kickoff path comparison | C | Route |
| `.codex/hooks/validate-feature-review-coverage.ps1` | `Join-Path $RepoRoot 'docs/features/active'` | C | Route |
| `.codex/scripts/epic-child-launch-runtime.ps1` | `-Path 'docs/features/active'` | C | Route |
| `.codex/scripts/epic-child-launch-contract.ps1` | `'^docs/features/active/[^/<>]+$'`, message | R, M | Route (union) |

### PowerShell - `scripts/`

| File | Kind | Disposition |
| --- | --- | --- |
| `scripts/dev-tools/new-potential-entry.ps1` and bundled `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` (potential target, `template.md`, `backlog.md`) | C | Route via a new `-DevelopmentDocsRoot` parameter (default `docs/features`) |
| `scripts/dev-tools/link-feature-docs.ps1` (generated Markdown links) | C | Route via a parameter (default) |
| `scripts/ci/Invoke-CiChangeScope.ps1`, `scripts/ci/CiChangeScope.psm1` | config-driven | No code change; config change only (section 7) |

### Python - `scripts/dev_tools`

| File | Symbol | Kind | Disposition |
| --- | --- | --- | --- |
| `new_active_feature_folder_flow.py` | promoted root, templates dir, epics and active target dirs, argparse help | C, M | Route; folder naming (section 6) |
| `new_active_feature_folder_io.py` | potential search dirs; `build_folder_slug` | C | Route; naming |
| `new_potential_bug_entry.py` | potential target dir, template | C | Route |
| `potential_to_issue.py` | promoted dir | C | Route |
| `potential_to_issue_content.py` | `Promoted -> docs/features/active/...` status line | M | Msg (resolver root plus new name) |
| `copy_research_to_issue.py` | `ACTIVE_ISSUE_START_DIR` | C | Route |
| `atomic_executor/cli.py`, `atomic_executor/prompt_builder.py` | active dir joins | C | Route |
| `atomic_executor/cli_workspace.py`, `atomic_executor/feature_resolver.py` | help text; `_normalize_branch_suffix` | M | Msg |
| `plan_progress_report.py` | `--active-root` default; `_TRAILING_ISSUE_IN_FEATURE_DIR_PATTERN` | C, R | Route; parser (section 6) |
| `pr_context/feature_docs.py`, `pr_context/render_feature_excerpts.py` | `parts[0] == "docs" and parts[1] == "features"`; base and promoted dirs | P, C | Route (union for matching, resolver for reading) |
| `pr_context/verification_evidence.py` | feature root join | C | Route |
| `pr_context/summary_helpers.py` | `startswith("docs/features/")` | P | Route (union) |
| `pr_context/collector.py` | docs bucket `startswith("docs/")` | P | Route: add `.dev/` |
| `epic_planner_readiness.py` | `feature_folder` prefix checks; manifest and kickoff paths | P, C | Route |
| `epic_kickoff_contract.py`, `parallel_kickoff_contract.py` | `MANIFEST_RE` | R | Route (union) |
| `_orchestrator_state_issue_adoption.py` | `POTENTIAL_RECORD_PREFIX` | P | Route (union) |
| `_orchestrator_state_feature_folder_record.py` | folder pattern, message | R, M | Route (union) |
| `_epic_orchestrator_state_resolution.py`, `_parallel_orchestrator_state_cohort_barrier.py` | lifecycle prefix tuples | P | Route (union) |
| `compute_blast_radius.py` [CONFLICT] | `FEATURE_FOLDER_ROOT`, `FEATURE_FOLDER_PREFIX` | C, P | Route |
| `_blast_radius_token_shapes.py` [CONFLICT] | `FEATURE_CORPUS_PREFIX` | P | Route (union) |
| `_blast_radius_write_intent.py` [CONFLICT] | `_FEATURE_FOLDER_PREFIX` | P | Route (union) |
| `resolve_execute_plan_prompt.py`, `resolve_file_prompt.py` | `_resolve_name_from_feature_foldername` | parser | Route to the shared parser (section 6) |
| `validate_evidence_locations.py` | remediation hint | M | Msg |
| `json_config.py` | `GOVERNED_GLOBS` | glob | Add `.dev/**/*.json` (D-14) |
| `build_discovery_runtime.py` | `RESOURCE_ROOTS` includes `docs/discovery/templates` | C | Out of Phase 1 scope (discovery moves in Phase 3); list for child 7 |
| `plan_gate_observability.py`, `plan_gate_discrimination.py`, `schema_loading.py`, `parallel_manifest_contract.py`, `parallel_lane_assertion.py` | spec citations, help | X | Stay |
| `scripts/dev_tools/pr_context/render.py,cover` | a tracked coverage-annotate file that holds old source | X | Stay. **ORCHESTRATOR-CONFIRM** whether it is tracked (`git ls-files`); if tracked, it is unrelated debris to report, not edit. |

### TypeScript - `extensions/drm-copilot/src`

| File | Symbol | Kind | Disposition |
| --- | --- | --- | --- |
| `extension-command-helpers.ts` | `ACTIVE_FEATURE_DOCS_DIRECTORY`, `POTENTIAL_DOCS_DIRECTORY` (used in the same file only; no test imports them), message | C, M | Route. Replace with resolver calls; keep the exported names as defaults or remove them, since no other module imports them |
| `lib/new-active-feature-folder/flow.ts` | `createActiveFolder` promoted root, templates, epics and active targets | C, M | Route; naming (section 6) |
| `lib/new-active-feature-folder/io.ts` | `findPotentialFile` dirs; `buildFolderSlug` | C | Route; naming |
| `lib/new-potential-bug-entry.ts` | `nodePath.posix.join(..., "docs", "features", "potential")`, templates join | C | Route |
| `lib/potential-to-issue/promotion.ts` | promoted dir | C | Route |
| `lib/potential-to-issue/content.ts` | status line | M | Msg (resolver root plus new name) |
| `lib/pr-context/feature-docs.ts`, `render-feature-excerpts.ts` | `parts[0] === "docs" && parts[1] === "features"`; base and promoted dirs | P, C | Route |
| `lib/pr-context/verification-evidence.ts` | `featureRoot` | C | Route |
| `lib/pr-context/summary-helpers.ts` | `isScopingDoc` | P | Route (union) |
| `lib/pr-context/collector-core.ts` | docs bucket `startsWith("docs/")` | P | Route: add `.dev/` |
| `lib/validate/epic-orchestrator-state-resolution.ts`, `parallel-orchestrator-state-cohort-barrier.ts` | lifecycle prefix arrays | P | Route (union) |
| `lib/validate/epic-planner-readiness-integrity.ts` | folder prefixes, manifest and kickoff paths | P, C | Route |
| `lib/validate/epic-kickoff-artifact.ts`, `parallel-kickoff-artifact.ts` | `MANIFEST_RE` | R | Route (union) |
| `lib/validate/orchestrator-state-feature-folder-record.ts` | path regex, message | R, M | Route (union) |
| `lib/validate/orchestrator-state-issue-adoption.ts` | `POTENTIAL_RECORD_PREFIX`, message | P, M | Route (union) |
| `lib/validate/evidence-locations.ts` | hint | M | Msg |
| `lib/resolve/file-prompt-variables.ts` (`file-prompt-core.ts` caller) | `resolveNameFromFeatureFoldername` | parser | Route to the shared parser |
| `lib/json-config.ts` | `GOVERNED_GLOBS` | glob | Add `.dev/**/*.json` |
| `lib/validate/plan-gate-observability.ts`, `plan-gate-discrimination.ts` | doc comments citing evidence paths | X | Stay |

No TypeScript source exists under `packages/mcp-server`. Agent and settings write scopes are covered in section 5.

## 3. Hosts for the resolver per runtime

### Python (no new Python file; extend in place)

Recommended host: `scripts/dev_tools/json_config.py` (52 lines, pure, no imports beyond `pathlib`). It already owns repository JSON configuration discovery and is edited anyway for D-14. Add:

- `DEVELOPMENT_DOCS_ROOT_KEY = "development_docs_root"`, `DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features"`, `KNOWN_DEVELOPMENT_DOCS_ROOTS = ("docs/features", ".dev")`
- `resolve_development_docs_root(workspace, *, read_text=None, is_dir=None) -> str`
- `development_docs_path(workspace, area, *, root=None) -> Path` using the area map
- `known_root_prefixes(area) -> tuple[str, ...]` for matchers
- `parse_feature_folder_name(name)` and `format_feature_folder_name(issue_number, feature)` (section 6)

Cost and risk: low code cost. The module docstring widens from JSON governance to repository layout configuration, and all Python consumers gain an import of `json_config`; there is no cycle risk because `json_config` imports nothing from `scripts.dev_tools`. Rejected: `_orchestrator_state_route_gates.py` (fixed tool-repo path, validator domain, cycle risk) and `new_active_feature_folder_models.py` (too narrow for the pr_context and validator consumers).

**Owner question OQ-2**: a new importable library module (for example `scripts/dev_tools/development_docs_root.py`, no `main`, no entry point) would be cleaner than widening `json_config.py`. The directive forbids new scripts, tools, generators, checkers and CLI entry points; whether a library module counts is not stated. The recommendation is `json_config.py` unless the owner allows a library module.

Python batch budget: about 28 production Python files change (section 10). The fourth file is denied in direct mode (`PYTHON_LARGE_PATH_REQUIRED`), so execution needs the `large` route checkpoint in the item worktree, or several sessions.

### PowerShell (a new module is allowed)

Recommended: a new module `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` following the `.claude/lib` convention enforced by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`: `Set-StrictMode -Version Latest` followed by `$ErrorActionPreference = 'Stop'`, the convention sentence `imports its siblings with -ErrorAction Stop` in the help block, and 800 lines or fewer. Functions:

- `Resolve-DevelopmentDocsRoot -WorkspaceRoot [-ReadText] [-TestDirectory]` (only I/O through injected script blocks)
- `Get-DevelopmentDocsPath -Root -Area`
- `Get-DevelopmentDocsKnownRootPrefix -Area` and `Get-DevelopmentDocsKnownRootPattern -Area` (union for matchers, regex-escaped, both separators)
- `ConvertFrom-FeatureFolderName`, `ConvertTo-FeatureFolderName` (section 6)

Codex publication follows the existing discovery-validation pattern: a single source copy under `extensions/drm-copilot/resources/lib/development-docs/`, published to `.codex/lib/development-docs/` by a new `VIRTUAL_RESOURCE_DIRECTORIES` entry in `src/lib/push-down/codex-agents-customizations.ts` and its Python twin in `scripts/dev_tools/push_down_codex_and_agents_customizations.py` (existing Python, extended in place). Codex hooks import the published path first and the self-hosted `../../.claude/lib/...` path second (pattern in `.codex/hooks/enforce-discovery-planning-gate.ps1`). The Claude bundle copy goes under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/development-docs/`.

Do not host the resolver in `HookTargetWorktree.psm1` or `WorktreeResolution.psm1`: both are in the conflict list. `feature-folder-resolution.ps1` stays pure; callers pass the known-root pattern into it.

The PoshQC coverage population needs no edit: `config/poshqc-coverage.json` lists roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`), so the new module is measured automatically.

PowerShell batch budget: about 40 production files plus their bundle mirrors (mirrors count). Use the `large` route.

### TypeScript

New modules (none may import `vscode`):

- `extensions/drm-copilot/src/lib/development-docs/root.ts`: `DEVELOPMENT_DOCS_ROOT_KEY`, `DEFAULT_DEVELOPMENT_DOCS_ROOT`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`, `resolveDevelopmentDocsRoot(fs, workspaceRoot)`, `developmentDocsPath(root, area)`, `knownRootPrefixes(area)`
- `extensions/drm-copilot/src/lib/development-docs/feature-folder-name.ts`: parser and formatter
- `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts`: the D-16 contract (section 5)

Each new production file needs its own entry in the `coverageThreshold` map of `extensions/drm-copilot/jest.config.cjs` (`lines: 85, branches: 75`, keyed `"./src/lib/development-docs/<file>.ts"`). The map has per-file entries only and no `global` key, and it already merges one external JSON (`jest.discovery-coverage.json`). `jest.config.cjs` is in the conflict list, so the plan's Phase 0 gate re-reads it before the edit.

## 4. Node-glob and ripgrep consumers

Verified findings:

- No production code imports `fast-glob`, `glob`, `minimatch`, `globby`, `picomatch`, `micromatch` or `tinyglobby`, and no code calls `vscode.workspace.findFiles` (repository-wide search excluding `node_modules`). The only matches are in historical feature documents.
- No production code invokes ripgrep. `rg` appears only as a token in command parsers (`GREP_EXECUTABLES` in `src/lib/validate/plan-gate-commands.ts` and `scripts/dev_tools/plan_gate_commands.py`; the sink list in `.claude/hooks/hook-command-payload.ps1` and its Codex twin) and as a package in `.codex/codex-web-setup.sh`.
- The TypeScript glob is the in-house `RealFileSystem.glob` with `compileGlob` in `src/lib/file-system.ts`. It walks with `readdirSync` and does not skip dot entries: `*` compiles to `[^/]*` and `**` to `(?:.*/)?` or `.*`, both of which match names that begin with a dot. It has no `dot` option because no dot filter exists.

Consumers of `FileSystem.glob` and their dot behavior:

| Consumer | Call | Dot handling today |
| --- | --- | --- |
| `src/lib/json-config.ts` `iterGovernedFiles` | `fs.glob(root, pattern)` | includes dot paths |
| `src/lib/validate/json-validator.ts` | `fs.glob(normalized, "**/*.json")` | includes |
| `src/lib/validate/evidence-locations.ts` | `fs.glob(normalizedRoot, "**")` | includes |
| `src/lib/pr-context/verification-evidence.ts` | `fs.glob(featureRoot, pattern)` | includes |
| `src/lib/pr-context/feature-docs-parsers.ts` | `fs.glob(directory, pattern)`, `fs.glob(featureDir, "feature-audit.*.md")` | includes |

Other directory walkers that use `readdirSync` without a dot filter: `src/lib/new-active-feature-folder/models.ts`, `src/lib/push-down/filesystem-adapter.ts`. One walker excludes dot directories on purpose: `isExcludedDirectoryName` in `src/lib/push-down/claude-blast-radius-derive-manifests.ts` prunes every dot name and `docs`, because location buckets must not become blast-radius modules. `.dev` is a location bucket like `docs`, so the exclusion is correct and stays.

The agent tools: the Claude Code Grep and Glob tools returned `.claude/`, `.codex/` and `.agents/` paths in this session (for example Glob `**/execution-environment/SKILL.md` from the repository root returned the `.agents`, `.claude` and `.github` copies), so they include dot folders. Their exact defaults are runtime behavior, not repository code.

D-13 in this repository therefore means: make the include-dot behavior explicit (a documented, named constant or comment in `compileGlob`/`RealFileSystem.glob` stating that dot entries are matched), and add a test per consumer that finds a file under `.dev`. Recommended tests: one `RealFileSystem.glob` contract test (finds `.dev/active/x/spec.md`), one test per consumer listed above with a `.dev` file in the fake, and one test that `isExcludedDirectoryName(".dev")` is `true`. All tests use the in-memory fakes; no temporary directories. The real-disk walker contract test must not write files; if the existing `file-system` tests cover `RealFileSystem.glob` only through fakes, assert `compileGlob` behavior through the exported matching seam instead (planner to confirm the seam). Python `Path.glob` and PowerShell `Get-ChildItem -Recurse` include dot folders by default; add one Python test that `iter_governed_files` finds `.dev/x.json` (in-memory is not possible for `Path.glob`; the existing `tests/scripts/dev_tools/test_json_config.py` pattern must be checked for its fixture approach, because temporary files are prohibited).

## 5. Write scopes and the D-16 contract

### Current scopes naming `docs/**` or `docs/features/**`

Claude agent frontmatter `tools:` entries:

| Agent | Entries |
| --- | --- |
| `.claude/agents/atomic-planner.md` | `Edit(docs/**)`, `Write(docs/**)` |
| `.claude/agents/task-researcher.md` | `Write(/docs/features/**/research/**)`, `Write(/docs/research/**)` |
| `.claude/agents/prd-feature.md` | `Write(/docs/features/active/**)`; hook arg `-RequiredArtifact 'spec-path|^docs/features/active/.+/spec\.md$|...'` |
| `.claude/agents/feature-review.md` | `Write(/docs/features/active/**)` |
| `.claude/agents/status-updater.md` | `Write(/docs/features/**)` |
| `.claude/agents/epic-review.md` | `Write(/docs/features/**)`; hook arg `-RequiredArtifact 'epic-audit-path|^docs/features/epics/.+/epic-audit\...'` |
| `.claude/agents/epic-planner.md` | `Write(docs/features/epics/**)`, `Edit(docs/features/epics/**)`, `Write(docs/features/potential/**)` |
| `.claude/agents/epic-orchestrator.md` [CONFLICT] | `Write(docs/features/epics/**)`, `Edit(docs/features/epics/**)` |
| `.claude/agents/parallel-orchestrator.md` [CONFLICT] | `Write(docs/features/parallel/**)`, `Edit(docs/features/parallel/**)` |
| `.claude/agents/parallel-planner.md` [CONFLICT] | `Write(docs/features/parallel/**)`, `Edit(docs/features/parallel/**)` |

Settings: `.claude/settings.json` [CONFLICT] `permissions.allow` has `Edit(docs/**)`.

Codex: the base files `.codex/agents/atomic-planner.toml`, `prd-feature.toml`, `feature-review.toml`, `status-updater.toml`, `epic-review.toml` carry the same `Write(...)`/`Edit(...)` lines as text inside their instructions; the `-c1` to `-c4` and `-c3-elevated` variants and the bundle copies are generated by `scripts/dev_tools/generate_codex_agent_variants.py`. `.codex/config.toml` names no `docs/` scope.

Copilot: `.github/agents/*.agent.md` mention `docs/features` in prose only; they carry no write-scope literals. Stay (child 6 retires or regenerates them).

Hooks: `.claude/hooks/enforce-evidence-locations.ps1` is a denylist of `artifacts/` paths and has no `docs` scope; the path rules that act as hook write scopes are the matchers in section 2 (`validate-task-researcher-output.ps1`, `validate-feature-review-coverage-rules.ps1`, `validate-executor-output.ps1`, `enforce-feature-folder-order.ps1`) and the two `-RequiredArtifact` regex literals in agent frontmatter. The matchers read the resolver union; the two regex literals are in the contract.

Finding to record: the execution-environment brief states that a `(pattern)` suffix on a `tools:` entry admits the bare tool, and the user's project memory records an observation that `Write(path)` rules are inert and that a leading `/` matches nothing (**ORCHESTRATOR-CONFIRM** against current Claude Code documentation before the plan relies on it). If so, the scopes do not restrict writes today and the "fails mid-run" risk in the spec is lower than stated. D-16 still applies; the contract keeps each agent's existing spelling (with or without a leading `/`) so Phase 1 changes no matching behavior, and normalization is left to child 3.

### Proposed contract

Single source: `extensions/drm-copilot/src/lib/development-docs/write-scopes.ts`.

```ts
export type WriteScopeArea =
  | "root" | "active" | "potential" | "epics" | "parallel"
  | "feature-research" | "one-off-research";

export interface WriteScopeRule {
  readonly agent: string;            // logical agent name, e.g. "prd-feature"
  readonly tool: "Write" | "Edit";
  readonly area: WriteScopeArea;
  readonly leadingSlash: boolean;    // preserves the existing spelling
}

export const WRITE_SCOPE_RULES: ReadonlyArray<WriteScopeRule>;
export const SETTINGS_ALLOW_RULES: ReadonlyArray<{ tool: "Edit"; area: WriteScopeArea }>;
export const REQUIRED_ARTIFACT_RULES: ReadonlyArray<{ agent: string; token: string; area: WriteScopeArea; suffixPattern: string }>;

// Exact literals, e.g. "Write(/docs/features/active/**)" and "Write(/.dev/active/**)".
export function expandWriteScopeLiterals(rule: WriteScopeRule, roots: ReadonlyArray<string>): string[];
// Regex literal accepting every root, e.g. "^(?:docs/features|\\.dev)/active/.+/spec\\.md$".
export function expandRequiredArtifactPattern(rule: ..., roots: ReadonlyArray<string>): string;
```

Area-to-glob map per root:

| Area | `docs/features` | `.dev` |
| --- | --- | --- |
| root | `docs/features/**` | `.dev/**` |
| active, potential, epics, parallel | `docs/features/<area>/**` | `.dev/<area>/**` |
| feature-research | `docs/features/**/research/**` | `.dev/**/research/**` |
| one-off-research | `docs/research/**` | `.dev/research/**` |
| atomic-planner broad scope | keeps `docs/**` | adds `.dev/**` |

Literal set rule: during the fallback release, every agent's `tools:` list contains `expandWriteScopeLiterals(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS)` for each of its rules, so both `docs/features` and `.dev` forms are present. After child 7 removes the fallback, `KNOWN_DEVELOPMENT_DOCS_ROOTS` shrinks and the checker then requires only the `.dev` literals.

Checker test (TypeScript, Jest, under `extensions/drm-copilot/test/lib/development-docs/`):

1. Forward coverage: for each rule, read the agent file (`.claude/agents/<agent>.md` frontmatter and `.codex/agents/<agent>.toml` base text) through an injected reader, and assert each expanded literal is present in the `tools:` entries. Same for `SETTINGS_ALLOW_RULES` against `.claude/settings.json` and for `REQUIRED_ARTIFACT_RULES` against the hook `command:` lines.
2. Reverse coverage: scan every `.claude/agents/*.md` and `.codex/agents/*.toml` for `Write(`/`Edit(` entries that name `docs/features`, `docs/research`, `docs/**` or `.dev`, and fail when an entry is not produced by a rule. This catches a new scope added without a contract rule.
3. Root coverage: for each rule, assert that a sample path under each known root (for example `docs/features/active/x/spec.md` and `.dev/active/x/spec.md`) is matched by at least one expanded literal, using the same glob compiler as `compileGlob`, and that each `-RequiredArtifact` regex accepts sample paths under both roots.

Reading real repository files in a test is not a temporary-file write; the reader is injected and production code does not read agent files. Bundle mirrors are covered by the existing contract tests (section 8).

Interface for child 3's agent generator: import `WRITE_SCOPE_RULES`, `expandWriteScopeLiterals` and `KNOWN_DEVELOPMENT_DOCS_ROOTS` and emit the literals; the Phase 1 checker then becomes the generator's `--check` assertion for write scopes.

Language choice: TypeScript. Cost: Jest coverage entries and reading files from outside the extension directory (`../../.claude/agents`). Risk: path joins must use forward slashes and no drive letters (Linux CI). Rejected: a Pester checker (child 3's generator is TypeScript and would duplicate the rule table) and a Python checker (language directive).

## 6. Feature-folder name parsing and folder creation

### Parsing sites found

| Runtime | Site | Current behavior |
| --- | --- | --- |
| TypeScript | `resolveNameFromFeatureFoldername` in `src/lib/resolve/file-prompt-variables.ts` (used by `file-prompt-core.ts`) | splits on `-`; date-first plus trailing all-digit issue gives the middle name; otherwise the whole name |
| Python | `_resolve_name_from_feature_foldername` in `scripts/dev_tools/resolve_execute_plan_prompt.py` and in `scripts/dev_tools/resolve_file_prompt.py` (two copies) | same rule |
| Python | `_TRAILING_ISSUE_IN_FEATURE_DIR_PATTERN = r"-(?P<num>\d+)$"` in `scripts/dev_tools/plan_progress_report.py` | trailing issue suffix |
| Python | `_normalize_branch_suffix` in `scripts/dev_tools/atomic_executor/feature_resolver.py` | strips trailing digits from a branch name for fuzzy match against folder names |
| PowerShell | `feature-folder-resolution.ps1` (Claude and Codex) | takes the basename structurally; matches records by `issue_num` or folder basename; does not parse the name format |
| PowerShell | `WorktreeItemResolution.psm1` `$script:IssueNumberPattern` | parses an issue selector, not a folder |

No PowerShell code parses the date-first format today. The new PowerShell parser is still required by D-19 for parity and for child 7.

### Folder creation path

MCP `new_active_feature_folder` -> `mcp-tools.ts` -> `mcp-handlers/feature-entry-handlers.ts` -> `RepoAutomationService.newActiveFeatureFolder` (`src/repo-automation-service.ts`) -> `newActiveFeatureFolderServiceCall` (`src/lib/new-active-feature-folder/new-active-feature-folder-service-call.ts`) -> `createActiveFolder` (`src/lib/new-active-feature-folder/flow.ts`) -> `buildFolderSlug` (`src/lib/new-active-feature-folder/io.ts`).

Current naming: the slug is the potential file stem when a potential file is found (date-first `YYYY-MM-DD-<name>`), otherwise the feature name with `_` replaced by `-`; then `-<issue>` is appended unless the slug already ends with the issue digits. Result for this item: `2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016`. Epics use `docs/features/epics/<slug>` without date or issue. The Python CLI `dev.new-active-feature` (`pyproject.toml`, `scripts/dev_tools/new_active_feature_folder.py`, `_flow.py`, `_io.py` `build_folder_slug`) has the same rule.

### Recommended API

TypeScript (`feature-folder-name.ts`), mirrored in Python (`json_config.py` or OQ-2 module) and PowerShell (`DevelopmentDocsRoot.psm1`):

```ts
export type FeatureFolderName =
  | { format: "date-first"; date: string; feature: string; issueNumber: number | null }
  | { format: "issue-first"; issueNumber: number; feature: string }
  | { format: "other"; feature: string; issueNumber: number | null };

export function parseFeatureFolderName(name: string): FeatureFolderName;
export function formatFeatureFolderName(issueNumber: number, feature: string): string;
export function stripDateFirstPrefix(stem: string): string;
```

Rules (D-18, D-19):

1. `^\d{4}-\d{2}-\d{2}-` matches: date-first. `feature` is the remainder; when the remainder ends with `-\d+`, that is `issueNumber` and is removed from `feature` (compatible with the existing middle-segment rule).
2. Otherwise `^\d{4}-` matches: issue-first. `issueNumber` is the integer value of the four digits; `feature` is the remainder.
3. Otherwise: other. A trailing `-\d+` is reported as `issueNumber` so `plan_progress_report.py` keeps working for undated folders such as `subagentstop-envelope-core-897`.

Formatter: `String(issueNumber).padStart(4, "0") + "-" + feature`, where `feature` is the potential stem with `stripDateFirstPrefix` applied and any trailing `-<issue>` removed. Fail fast on: a non-integer or non-positive issue number; an issue number above 9999 (D-18 fixes four digits, and D-19 would misread five digits); a feature that is empty, fails the existing `NAME_PATTERN`, or begins with `\d{2}-\d{2}-` (it would make `NNNN-MM-DD-...` parse as date-first).

Edge cases: issue 1016 gives `1016-move-development-docs-to-dev-root-and-reserve-docs-for-production`; issue 42 gives `0042-<feature>`. Name `2026-10-30-foo` is always date-first, never issue 2026. Versioned subfolders (`v2`) are handled before parsing, as `file-prompt-variables.ts` already does.

**Owner question OQ-4**: when `new_active_feature_folder` has no issue number (blank or `auto` with no `Issue:` line), the recommendation is to keep the current slug (no issue prefix) rather than fail, because the VS Code command path allows it; D-18 names folders from the issue number only when one exists.

`potential_to_issue` status line: build it with the resolver root and `formatFeatureFolderName` so the promoted record names the folder that will be created. Today it names a path that never exists (`docs/features/active/<name>/`).

### Existing tests that assert current folder names or parser output

- `tests/scripts/dev_tools/test_new_active_feature_folder.py` `test_build_folder_slug_uses_potential_and_issue_number` (`2025-12-23-json-quality-63`); `test_build_folder_slug_raises_on_invalid_slug` (unchanged)
- `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts` `describe("buildFolderSlug")` (`notes-240`, `notes-feature`)
- `extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts` (`docs/features/active/notes-feature-240` and issue-less `notes-feature`, `notes`)
- `extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts` (`notes-feature-240`)
- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`, `extension.new-active-feature-folder-inprocess.test.ts` (path fixtures; preflight must check each)
- `tests/scripts/dev_tools/test_resolve_execute_plan_prompt.py`, `extensions/drm-copilot/test/lib/resolve/file-prompt-variables.test.ts` (parser output)
- `tests/scripts/dev_tools/test_potential_to_issue.py`, `test_potential_to_issue_content.py`, `extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts`, `content.test.ts` (`Promoted -> docs/features/active/...` status line)
- plan_progress_report tests: **planner to locate** (search `plan_progress_report` under `tests/`).

Tests with issue-number inputs change expected output from `<name>-240` to `0240-<name>`; issue-less cases stay (OQ-4).

## 7. CI docs-only scope and JSON governance

`config/ci-docs-only-paths.json`: `version: 1`, `include_prefixes` (seven `docs/...` prefixes), `exclude_prefixes` (`docs/features/potential/template.md`, `docs/features/templates/`), `extensions` (`.md .txt .log .json .xml`). It is parsed by `ConvertFrom-CiDocsOnlyPathConfig` and applied by `Test-CiDocsOnlyPath` in `scripts/ci/CiChangeScope.psm1`, called from `scripts/ci/Invoke-CiChangeScope.ps1` (`Read-CiChangeScopeConfigText`). Matching is an ordinal prefix test, so the config holds prefixes, not globs. `Test-CiDocsOnlyPath` rejects only `..` segments, a leading `/` and backslashes, so `.dev/` paths are accepted structurally.

Proposed change (D-12, "as `docs/features` does today"): add include prefix `.dev/` and exclude prefixes `.dev/templates/` and `.dev/potential/template.md`, so templates stay code-relevant as they are today.

**Owner question OQ-3**: `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` asserts that `docs/engineering/` and `docs/discovery/` are not docs-only. A `.dev/` prefix makes `.dev/engineering/` and `.dev/discovery/` docs-only. Either add `.dev/engineering/` and `.dev/discovery/` (and possibly `.dev/discovery/templates/`) as exclude prefixes to keep today's classification, or accept the broader `.dev/**` literally. Recommendation: exclude them, to preserve current behavior. The same question applies to the `.dev/` addition in `hook-docs-only-diff.ps1`.

Tests that change: `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1` ('starts every include prefix with docs/'; the exact include list 'configures exactly the D3 include prefixes'; new rows for `.dev/` and the new exclusions). Tests to re-run: `tests/scripts/ci/CiChangeScope.Tests.ps1`, `Invoke-CiChangeScope.Tests.ps1`, `Invoke-CiChangeScopeMergeBase.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`. Documentation that states the allowlist: `.github/workflows/README.md` and the execution-environment brief `## CI Shape and Required Checks` (six byte-identical copies, all in the conflict list; `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` pins them). The brief's maintenance rule requires the brief update in the same change.

The allowlist file itself is not allowlisted, so this change runs full CI, as required.

JSON governance: `GOVERNED_GLOBS` in `scripts/dev_tools/json_config.py` and `extensions/drm-copilot/src/lib/json-config.ts` both list `scripts/**/*.json`, `docs/**/*.json`, `examples/**/*.json`. Add `.dev/**/*.json` to both, keeping `docs/**/*.json`. Consumers: `scripts/dev_tools/validate_json.py`, `format_json.py`, `src/lib/validate/json-validator.ts`. Existing tests (`tests/scripts/dev_tools/test_json_config.py`, `extensions/drm-copilot/test/lib/json-config.test.ts`) assert membership, not equality, so they keep passing; add one `.dev` membership row and one discovery row per runtime.

## 8. Mirrors, manifests, generators and contract tests

Every edited file under `.claude/` and `.codex/` has a bundle copy that must have equal text:

- `.claude/**` -> `extensions/drm-copilot/resources/claude-customizations/.claude/**`
- `.codex/**`, `.agents/**` -> `extensions/drm-copilot/resources/codex-and-agents-customizations/...`
- `.github/skills/**` -> `extensions/drm-copilot/resources/customizations/.github/skills/**`
- `config/orchestration-routing.json` -> `resources/config/` and `resources/claude-customizations/config/`
- `scripts/dev-tools/new-potential-entry.ps1` -> `resources/templates/new-potential-entry.ps1` (**planner to confirm** whether a parity test pins this pair)
- New PowerShell module -> `.claude/lib/development-docs/`, `resources/claude-customizations/.claude/lib/development-docs/`, `resources/lib/development-docs/`

Pack manifests: `resources/claude-customizations/pack-manifests/core.json` and `resources/codex-and-agents-customizations/pack-manifests/core.json` (both in the conflict list) need the new module files. The Codex `core.json` is generated by the Codex generator; the Claude one is hand-edited (**planner to confirm** from `test_push_down_claude_pack_manifest_completeness.py`).

Codex generator: after editing base `.codex/agents/*.toml`, run `scripts/dev_tools/generate_codex_agent_variants.py` to regenerate variants and bundle copies, then run it with `--check`. The generator file itself is in the conflict list but is not edited.

Contract tests to pass (from the execution-environment brief): `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (each hook that imports the new module makes it a dependency that must be in core), the generator `--check`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_claude_rules_frontmatter.py`, `parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES` pins `.claude/agents/epic-orchestrator.md`; adding `.dev` scopes changes its hash, so the pin must be re-baselined with a dated comment, as earlier issues did), `test_push_down_issue_824_follow_ups.py`, `test_typescript_toolchain_instruction_contracts.py`, `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (new imports in hooks must use the guarded pattern). Also: `test_orchestration_routing_config_parity.py`, `test_push_down_codex_and_agents_virtual_paths.py`, `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, and the literal-containment tests `test_parallel_planner_surface_contracts.py`, `test_completion_gate_documentation_contracts.py`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` (containment only, so additive `.dev` literals pass).

## 9. Conflict check against the parallel run `bugs-1001-1002-1003-1006`

Candidate files of this child that appear in `research/parallel-run-blast-radius-bugs-1001-1002-1003-1006.txt`. The plan names each, and its Phase 0 gate re-checks each against `origin/main` after that run merges:

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.claude/lib/blast-radius/BlastRadius.psm1`, `BlastRadiusTokenShape.psm1`, `BlastRadiusWriteIntent.psm1` (and their bundle copies)
- `scripts/dev_tools/compute_blast_radius.py`, `_blast_radius_token_shapes.py`, `_blast_radius_write_intent.py`
- `.claude/agents/epic-orchestrator.md`, `parallel-orchestrator.md`, `parallel-planner.md` (and bundle copies of the latter two)
- `.claude/settings.json`
- the execution-environment brief, all six copies
- `extensions/drm-copilot/jest.config.cjs`, `package.json`, `CHANGELOG.md`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `resources/codex-and-agents-customizations/pack-manifests/core.json`
- tests: `test_parallel_planner_surface_contracts.py`, `test_execution_environment_brief_contracts.py`, `test_push_down_*_resource_contracts.py`, `test_push_down_*_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `claude-architecture-doc.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `ClaudeLibModuleConvention.Tests.ps1`, `parallel_orchestrator_surface_test_support.py` (consumer of the hash pins)
- read but not edited: `scripts/dev_tools/generate_codex_agent_variants.py`, `config/poshqc-coverage.json`, `config/file-size-baseline.json`

The blast-radius files carry the heaviest overlap. Recommendation: put them in a late phase of this plan, after a fresh Phase 0 re-check, so a moved symbol stops only that phase.

## 10. Size estimate and phase breakdown

Planning estimates (not acceptance criteria): about 40 PowerShell production files (Claude hooks and lib about 24, Codex hooks and scripts about 13, `scripts/` 2, plus the new module), each with a bundle copy; about 28 Python production files; about 25 TypeScript production files plus 3 new modules; 4 agent files in `.claude/agents`, 5 Codex base tomls and their generated variants, `.claude/settings.json`, three routing-config copies, `config/ci-docs-only-paths.json`, two pack manifests. Tests: new suites for the three resolvers, the three parsers, the write-scope checker, the dot-folder consumer tests, plus updates to about 15 existing suites listed in sections 6 to 8. Several files near size tiers need checking at plan time (for example `flow.ts`, `feature-folder-resolution.ps1`); new logic goes into the new modules.

Suggested phases:

0. Phase 0 gate: re-check every conflict-listed file, symbol and heading against `origin/main` (merge base); record baselines per language under `evidence/baseline/`.
1. Key and resolvers: routing-config key (three copies), TypeScript `root.ts`, Python `json_config.py` additions, PowerShell `DevelopmentDocsRoot.psm1` with bundle and `resources/lib` copies, Codex `VIRTUAL_RESOURCE_DIRECTORIES` entries (TypeScript and Python), pack manifests, coverage entries, unit tests.
2. Parsers and folder creation: parser and formatter in three runtimes; `buildFolderSlug`/`build_folder_slug`, `createActiveFolder`, potential-to-issue status line; replace the three existing parsers; update the tests listed in section 6.
3. TypeScript consumers: section 2 TypeScript table, `extension-command-helpers.ts`, `new-potential-entry` argument wiring, pr-context buckets, D-13 dot-folder tests, JSON governance glob.
4. Python consumers (non-blast-radius) and JSON governance glob.
5. PowerShell hooks and lib consumers (Claude and Codex, non-blast-radius), `new-potential-entry.ps1`, `link-feature-docs.ps1`, `hook-docs-only-diff.ps1`, bundle copies.
6. Write-scope contract: `write-scopes.ts`, checker test, agent frontmatter and Codex base toml literals, generator run and `--check`, `.claude/settings.json`, hash re-baseline.
7. CI docs-only allowlist and its tests; execution-environment brief (six copies) and `.github/workflows/README.md`.
8. Blast-radius consumers (PowerShell and Python), after a second conflict re-check.
9. Full toolchain in all languages, isolation checks, mirror and contract tests, coverage comparison.

## Rejected alternatives (brief)

- Dedicated `config/development-docs.json` for the key: more plumbing, no current reader (section 1).
- Host the PowerShell resolver in `feature-folder-resolution.ps1`: that file is pure by contract and does no I/O.
- A Pester or Python write-scope checker: duplicates the rule table that child 3's TypeScript generator needs.

## Owner Questions

- OQ-1: absent key in Phase 1 - default `docs/features` (recommended) or probe `.dev` first.
- OQ-2: whether a new Python library module (no entry point) is allowed instead of widening `json_config.py`.
- OQ-3: whether `.dev/engineering/` and `.dev/discovery/` are excluded from the CI docs-only scope and from the `hook-docs-only-diff.ps1` exemption, to preserve today's classification.
- OQ-4: folder naming when no issue number is available (keep the current slug, recommended).

## Numeric Derivation Evidence

No numeric count, enumeration or population is proposed for a `spec.md` acceptance criterion. The counts in section 10 are planning estimates from the inventory and are not acceptance criteria.

## Automation Feasibility

No third-party UI is involved. All work is file edits plus toolchain runs (Jest, Pytest, Pester through `sh`-launched PowerShell 7, the Codex generator). Facts that need `git show`, `git ls-files` or `gh` are marked ORCHESTRATOR-CONFIRM. Live hook behavior on the branch is proven by Pester suites, not by isolated subagents, because isolated subagents run `main`'s hooks.

## Pre-Mortem

- Review checklists: a reviewer finds a consumer still hard-coding `docs/features` (AC: "no consumer hard-codes the old path"). Mitigation: the plan includes a final repository search over production roots with an allowlist of the Stay rows in section 2, recorded as evidence.
- Coverage: new TypeScript modules without a `coverageThreshold` entry are ungated, and the Python resolver in `json_config.py` needs `--cov=scripts.dev_tools.json_config` with branch figures from the JSON report. Mitigation: one coverage entry per new TypeScript file and per-module Python and Pester coverage evidence.
- Mirror parity: about 40 PowerShell files and 4 agent files have bundle copies; the Codex variants are generated; the brief has six copies; the routing config has three. Mitigation: a mirror step per phase, then all section 8 contract tests and the generator `--check`, plus the `epic-orchestrator.md` hash re-baseline.
- File size: `flow.ts`, `feature-folder-resolution.ps1` and the larger hooks may approach the 700 and 800 line tiers. Mitigation: logic lives in the new modules; each call site changes by a few lines; the plan checks physical line counts with `@(Get-Content).Count` before editing.
- Test isolation: resolver tests could read the real `config/orchestration-routing.json` or depend on whether `.dev` exists. Mitigation: injected readers and directory probes in all three runtimes; seeded shuffled Jest, reversed Python order and three-seed Pester runs recorded under `evidence/regression-testing/`.
- CI-only behavior: the Linux hook-suite job is case-sensitive and the write-scope checker reads files by relative path. Mitigation: `Join-Path` and forward slashes, no drive-letter fixtures, no test that diffs against `origin/main`; `.dev` fixtures held in memory, because the `eol=lf` and checkout rules do not affect them.
- Evidence: Phase 0 must record the conflict re-check and baselines before any edit, and the run must use the `large` route because the batch budget is exceeded in every language. Mitigation: a Phase 0 task writes `evidence/baseline/` artifacts with Timestamp, Command, EXIT_CODE and Output Summary, and the orchestrator checkpoint selects `large` in the item worktree.
