# Python-to-TypeScript Port — Authoritative Inventory and Feature Decomposition
**Issue #240 | Research Date: 2026-06-25**

---

## 1. Current State Analysis

### 1.1 Runtime Bridge Architecture

The VS Code extension bridges Python through `extensions/drm-copilot/src/command-runtime.ts`. The key pattern is:

1. `detectRuntime("python")` probes `python` then `py` on PATH.
2. `executeBundledScriptFromExtensionRoot()` resolves the script from the bundled extension resources directory, spawns the interpreter as a child process, and streams stdout/stderr.
3. MCP handlers in `src/mcp-handlers/*.ts` call methods on `RepoAutomationService` (defined in `src/repo-automation-service.ts`), which calls the private `executeScript()` method, which in turn calls `executeBundledScriptFromExtensionRoot()`.
4. Template wrapper scripts under `extensions/drm-copilot/resources/templates/*.py` add the bundled `resources/scripts/` directory to `sys.path` and delegate in-process to the matching `dev_tools.*` module.

After the port, the `"python"` branch of `detectRuntime()` and all `runtimeKind: "python"` invocations are eliminated. Each `RepoAutomationService` method switches to calling an in-process TypeScript function instead of spawning a child process.

### 1.2 Python File Count by Location

| Location | File count | Approx. LoC |
|---|---|---|
| `scripts/dev_tools/**` | 90 files | ~28,100 |
| `extensions/drm-copilot/resources/templates/*.py` | 13 files | ~1,155 |
| Python tests (`tests/**`) | ~131 files | ~39,750 |

---

## 2. Complete Python Module Inventory

### 2.1 Template Wrapper Files (entry points invoked at runtime)

These thirteen files live in `extensions/drm-copilot/resources/templates/` and are the direct targets spawned by the extension. Each is a thin bootstrap wrapper that adds `resources/scripts/` to `sys.path` and delegates to a `dev_tools` module.

| File | LoC | Purpose | Invoked by (service method) |
|---|---|---|---|
| `collect_commit_context.py` | 212 | Collects git staged/unstaged context for commit message generation; self-contained, no delegation | `collectCommitContext` |
| `collect_pr_context.py` | 75 | Wrapper; delegates to `dev_tools.pr_context.collector.main` | `collectPrContext` |
| `codex_native_converter.py` | 36 | Wrapper; delegates to `dev_tools.codex_native_converter.cli.main` | `runCodexNativeConverter` |
| `new_active_feature_folder.py` | 67 | Wrapper; delegates to `dev_tools.new_active_feature_folder.main`, injects `--template-root` | `newActiveFeatureFolder` |
| `new_potential_bug_entry.py` | 55 | Wrapper; delegates to `dev_tools.new_potential_bug_entry.main` | `newPotentialBugEntry` |
| `potential_to_issue.py` | 56 | Wrapper; delegates to `dev_tools.potential_to_issue.main` | `potentialToIssue` |
| `push_down_claude_customizations.py` | 234 | Full implementation; delegates to `push_down_claude_customizations` engine, parses `--packs/--csharp-variant/--memory-mode` | `pushDownClaudeCustomizations` |
| `push_down_codex_and_agents_customizations.py` | 96 | Wrapper; delegates to `dev_tools.push_down_codex_and_agents_customizations` | `pushDownCodexAndAgentsCustomizations` |
| `push_down_copilot_customizations.py` | 125 | Wrapper; delegates to `dev_tools.push_down_copilot_customizations.push_down_customizations` | `pushDownCopilotCustomizations` |
| `resolve_atomic_plan_prompt.py` | 76 | Wrapper; delegates to `dev_tools.resolve_file_prompt.main`, injects atomic-plan template path | `resolveAtomicPlanPrompt` |
| `resolve_hard_lock_prompt.py` | 66 | Wrapper; delegates to `dev_tools.resolve_hard_lock_prompt.main`, injects template root | `resolveExecuteHardLockPrompt` |
| `validate_orchestration_artifacts.py` | 56 | Wrapper; delegates to `dev_tools.validate_orchestration_artifacts.main` | `validateOrchestrationArtifacts` |
| `hello_python.py` | ~5 | Smoke-test placeholder; no production use | None |

### 2.2 Production `dev_tools` Modules — Cluster A: `pr_context`

The PR context cluster is the implementation behind `collect_pr_context.py` and `collect_commit_context.py`.

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `pr_context/collector.py` | 619 | Top-level orchestrator: builds git/gh clients, gathers diffs, feature docs, issue/PR details, verification evidence, writes summary+appendix files | `test_collect_pr_context.py`, `test_collect_pr_context_part2-4.py`, `test_pr_context_integration.py` |
| `pr_context/git.py` | 153 | `GitClient` + `SubprocessRunner`; typed git subprocess wrapper | `test_git.py` |
| `pr_context/github.py` | 549 | `GhClient`: `gh` CLI wrapper; entity classification, issue/PR/CI fetches, repo file fetch | `test_github.py`, `test_github_part2-3.py` |
| `pr_context/models.py` | 198 | Dataclass models: `CommandResult`, `IssueDetails`, `PullRequestDetails`, `PRContextResult`, helpers | (covered by collector tests) |
| `pr_context/render.py` | 342 | Build PR context text from git/gh data; select base, format diffs | `test_collect_pr_context.py` |
| `pr_context/render_feature_excerpts.py` | 256 | Render feature doc excerpts for PR context | `test_feature_docs.py` |
| `pr_context/render_pr_helpers.py` | 291 | Build autoclose section, issue-to-autoclose logic | (covered by collector tests) |
| `pr_context/summary_helpers.py` | 386 | Digest builders, bucket text, timestamp append, numstat parsing | (covered by collector tests) |
| `pr_context/feature_docs.py` | 349 | Discover feature docs, extract issue refs, read excerpts | `test_feature_docs.py` |
| `pr_context/verification_evidence.py` | 171 | Parse verification evidence YAML files | (covered by collector tests) |
| `pr_context/__init__.py` | 5 | Re-exports | — |
| `collect_commit_context.py` | 212 | Self-contained git context collector for commit messages | `test_collect_commit_context.py` |

**External dependencies**: `git` binary, `gh` CLI binary, filesystem, subprocess.

### 2.3 Production `dev_tools` Modules — Cluster B: `codex_native_converter`

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `codex_native_converter/cli.py` | 308 | Typer CLI: `review` and `apply` commands, dispatches to engine | `test_cli_review.py`, `test_cli_apply.py`, `test_cli_entrypoints.py` |
| `codex_native_converter/engine.py` | 499 | Orchestrates full pipeline: inventory → classify → map → rewrite → validate → report → (apply) | `test_end_to_end.py`, `test_reporting_topology_end_to_end.py` |
| `codex_native_converter/models.py` | 460 | Domain enums and dataclasses: `SourceKind`, `TargetRole`, `RunOptions`, `ValidationFinding` | (covered by other tests) |
| `codex_native_converter/models_intermediate.py` | 226 | Intermediate pipeline models: `PlannedEmission`, `SectionIntent`, `SemanticCue` | `test_intermediate_state.py` |
| `codex_native_converter/classifier.py` | 484 | Classify source artifacts into `SourceKind` | `test_classifier.py`, `test_section_classifier.py` |
| `codex_native_converter/inventory.py` | 217 | Discover source artifacts from source root | `test_inventory.py` |
| `codex_native_converter/mapping.py` | 234 | Plan target paths from classified sources | `test_mapping.py` |
| `codex_native_converter/parser.py` | 292 | Parse Markdown/YAML source into sections | `test_parser.py` |
| `codex_native_converter/rewrites.py` | 485 | Apply text rewrites to convert content | `test_rewrites.py` |
| `codex_native_converter/reporting.py` | 433 | Generate conversion reports | `test_reporting.py` |
| `codex_native_converter/validation.py` | 418 | Validate converted artifacts | `test_validation.py` |
| `codex_native_converter/section_intent.py` | 249 | Classify section intent/kind | `test_section_intent.py` |
| `codex_native_converter/pipeline.py` | 462 | Pipeline data structures and step orchestration | `test_prompt_decomposition_end_to_end.py` |
| `codex_native_converter/intermediate_state.py` | 271 | Serialize/deserialize intermediate pipeline state | `test_intermediate_state.py` |
| `codex_native_converter/_pipeline_traces.py` | 139 | Trace collection for pipeline debugging | (covered by end-to-end tests) |
| `codex_native_converter/_reporting_topology.py` | 175 | Reporting topology builder | `test_reporting_topology_end_to_end.py` |
| `codex_native_converter/__init__.py` | 24 | Re-exports | — |
| `codex_native_converter/__main__.py` | 23 | Module entry point (`python -m`) | — |

**External dependencies**: `typer` library, filesystem, subprocess (none beyond Python itself).

### 2.4 Production `dev_tools` Modules — Cluster C: `new_active_feature_folder`

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `new_active_feature_folder.py` | 79 | Public re-export facade | `test_new_active_feature_folder.py` |
| `new_active_feature_folder_flow.py` | 366 | CLI entrypoint and orchestration: `create_active_folder`, `main`, `parse_args` | `test_new_active_feature_folder_part2-4.py` |
| `new_active_feature_folder_docs.py` | 268 | Feature doc update logic, minor-audit mode detection | (covered by flow tests) |
| `new_active_feature_folder_io.py` | 305 | Filesystem I/O: template copy, slug building, issue fetching via `gh` | `test_new_active_feature_folder.py` |
| `new_active_feature_folder_markdown.py` | 252 | Markdown section manipulation helpers | `test_new_active_feature_folder_markdown_escape.py` |
| `new_active_feature_folder_models.py` | 136 | Models: `ActiveFolderResult`, `IssueMeta`, `FileSystem` protocol, `RealFileSystem` | `test_new_active_feature_folder_models_coverage.py` |

**External dependencies**: `gh` CLI (issue title fetch), filesystem, `code`/`code-insiders` (optional VS Code launch), subprocess.

### 2.5 Production `dev_tools` Modules — Cluster D: `new_potential_bug_entry`

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `new_potential_bug_entry.py` | 465 | Create bug entry from template, validate short name, open VS Code | `test_new_potential_bug_entry.py`, `tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py` |

**External dependencies**: filesystem, `git config` (author lookup), `code`/`code-insiders` (optional), subprocess.

### 2.6 Production `dev_tools` Modules — Cluster E: `potential_to_issue`

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `potential_to_issue.py` | 634 | Promote potential file to GitHub issue using `gh issue create`; creates labels, updates metadata | `test_potential_to_issue.py`, `test_potential_to_issue_missing_label_regression.py`, template tests |
| `potential_to_issue_content.py` | 212 | Parse/build issue body from potential file sections | `test_potential_to_issue_content.py` |

**External dependencies**: `gh` CLI (issue create, label create/list), filesystem, subprocess.

### 2.7 Production `dev_tools` Modules — Cluster F: `push_down_*` customizations

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `push_down_copilot_customizations.py` | 504 | Copy `.github` tree to destination workspace, rewrite references, emit summary JSON | `test_push_down_copilot_customizations.py` (via integration) |
| `push_down_copilot_customizations_filesystem.py` | 217 | `PushDownFileSystem` protocol + `RealPushDownFileSystem` adapter | (covered by push-down tests) |
| `push_down_copilot_customizations_rewrites.py` | 293 | Rewrite repo-specific command references in copied files | (covered by push-down tests) |
| `push_down_codex_and_agents_customizations.py` | 118 | Copy `.codex` and `.agents` trees; delegates engine from copilot module | (covered by parity tests) |
| `push_down_claude_customizations.py` | 403 | Copy `.claude` tree with pack selection, C# variant routing, memory scope filter | `test_push_down_claude_customizations.py`, `test_push_down_claude_pack_end_to_end.py`, `test_push_down_claude_memory_scope.py` |
| `push_down_claude_filesystem.py` | 472 | Filtering filesystem adapter for `.claude` push-down: memory scope detection, pack/variant routing | (covered by claude push-down tests) |
| `push_down_claude_pack_selection.py` | 401 | Pure pack-manifest loading, path computation, C# variant assertion | `test_push_down_claude_pack_end_to_end.py` |

**External dependencies**: filesystem only (no git/gh).

### 2.8 Production `dev_tools` Modules — Cluster G: `resolve_*` prompts

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `resolve_hard_lock_prompt.py` | 479 | Read template, substitute `${plan-path}`, write output file, optionally copy to clipboard | `test_resolve_hard_lock_prompt*.py`, template tests |
| `resolve_file_prompt.py` | 619 | Generic template resolver: substitute `${file}`, `${folderpath}`, `${name}`, `${spec}`, etc. | (covered by resolve_atomic_plan_prompt tests) |
| `resolve_execute_plan_prompt.py` | 586 | Interactive plan prompt resolver (GUI file picker via tkinter) | — |
| `prompt_mode_contract.py` | 157 | Work-mode normalization: `minor-audit`, `full-feature`, `full-bug` | `test_prompt_mode_contract.py` |

**External dependencies**: filesystem, clipboard (`pyperclip` optional, falls back to `clip`/`pbcopy`/`xclip`), tkinter (optional, only `resolve_execute_plan_prompt.py`).

### 2.9 Production `dev_tools` Modules — Cluster H: `validate_*` artifacts

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `validate_orchestration_artifacts.py` | 246 | CLI dispatcher for plan/review/checkpoint/policy-audit validation | `test_validate_orchestration_artifacts.py`, template tests |
| `validate_orchestrator_state.py` | 505 | Checkpoint JSON validation: required keys, status values, receipt formats, remediation cycles | (covered by orchestration contract tests) |
| `validate_orchestration_review_artifacts.py` | 107 | Code-review and feature-audit heading validators | (covered by orchestration artifact tests) |
| `validate_policy_audit_artifact.py` | 472 | Policy-audit coverage table and checklist validators | (covered by orchestration artifact tests) |
| `validate_evidence_locations.py` | 109 | Scan repo tree for files at forbidden `artifacts/` evidence paths | `test_orchestration_guardrail_contracts.py` |
| `validate_json.py` | 278 | Generic JSON schema validation utility | `test_format_json.py` |
| `_orchestrator_state_human_interaction.py` | 127 | Human-interaction block validation sub-module | (covered by orchestrator state tests) |
| `_orchestrator_state_routing.py` | 216 | Routing contract validation sub-module | `test_orchestration_routing_config_parity.py` |

**External dependencies**: filesystem, JSON parsing (stdlib), regex (stdlib).

### 2.10 Production `dev_tools` Modules — Cluster I: Utility/shared

| File | LoC | Purpose | Python tests |
|---|---|---|---|
| `json_config.py` | 51 | JSON config load/save with round-trip formatting | `test_json_config.py` |
| `format_json.py` | 159 | Reformat JSON files in place | `test_format_json.py` |
| `markdown_label_formatter.py` | 140 | GitHub label markdown formatter | `test_markdown_label_formatter.py` |
| `agentic_sync.py` | 819 | Sync `.github` docs between two repos by mtime/content | `test_agentic_sync.py` |
| `tk_dialog_helpers.py` | 260 | Tkinter file-dialog utilities with HiDPI scaling | (via copy_research_to_issue tests) |

### 2.11 Production `dev_tools` Modules — Dev/internal tooling (NOT shipped to extension)

These modules are invoked only as repo-internal dev tooling. They are not bundled with the extension and are not invoked by any MCP handler or `RepoAutomationService` method.

| File | LoC | Purpose |
|---|---|---|
| `fix_all.py` | 628 | Parallel multi-branch fix-all workflow runner |
| `fix_all_branches.py` | 375 | Branch iteration and orchestration for fix_all |
| `fix_all_branches_extra.py` | 359 | Additional branch fix-all scenarios |
| `fix_all_runtime.py` | 183 | Process management for fix_all |
| `shell_qc.py` | 495 | Shell script formatting/linting/testing via shfmt/shellcheck/bats |
| `agentic_sync.py` | 819 | Two-repo `.github` document sync (also imported by push_down_copilot) |
| `copy_research_to_issue.py` | 318 | GUI file picker to copy research doc into active issue folder |
| `clean_devcontainer.py` | 183 | Docker container/volume cleanup for devcontainer reset |
| `plan_progress_report.py` | 396 | Markdown report of unchecked plan tasks across `docs/features/active/` |
| `atomic_executor/` (22 files) | ~5,400 | Copilot atomic task executor (spawns Copilot Chat sessions, QC runner, throttling) |

### 2.12 `atomic_executor` Sub-cluster Detail

| File | LoC | Purpose |
|---|---|---|
| `atomic_executor/cli.py` | 459 | Main CLI entry point |
| `atomic_executor/cli_copilot_runtime.py` | 439 | Copilot session runtime |
| `atomic_executor/cli_execute_one_task.py` | 308 | Execute a single atomic task |
| `atomic_executor/cli_preflight.py` | 413 | Preflight checks |
| `atomic_executor/cli_task_runtime.py` | 407 | Task runtime management |
| `atomic_executor/cli_workspace.py` | 312 | Workspace management |
| `atomic_executor/copilot_runner.py` | 38 | Thin Copilot process runner |
| `atomic_executor/copilot_throttling.py` | 340 | Rate/throttle control |
| `atomic_executor/feature_resolver.py` | 207 | Feature path resolution |
| `atomic_executor/plan_discovery.py` | 124 | Plan file discovery |
| `atomic_executor/plan_parser.py` | 669 | Plan Markdown parser |
| `atomic_executor/prompt_builder.py` | 434 | Build Copilot prompts |
| `atomic_executor/pytest_expectations.py` | 384 | Pytest result interpretation |
| `atomic_executor/qc_runner.py` | 571 | QC run orchestrator |
| `atomic_executor/qc_runner_expectations.py` | 184 | QC result expectations |
| `atomic_executor/qc_runner_loop.py` | 287 | QC retry loop |
| `atomic_executor/qc_runner_process.py` | 97 | QC subprocess management |
| `atomic_executor/qc_toolchain.py` | 78 | QC toolchain description |
| `atomic_executor/__init__.py` | 27 | Re-exports |

---

## 3. Extension/MCP Invocation Map

### 3.1 Scripts Invoked at Runtime by the Extension or MCP Server

The following `bundledRelativePath` values are set in `RepoAutomationService` methods and the methods they call. These are the scripts that **must** be ported to eliminate the Python dependency.

| MCP tool name | Service method | Template wrapper | Core module(s) |
|---|---|---|---|
| `collect_commit_context` | `collectCommitContext` | `resources/templates/collect_commit_context.py` | (self-contained) |
| `collect_pr_context` | `collectPrContext` | `resources/templates/collect_pr_context.py` | `pr_context/collector.py` + cluster A |
| `run_codex_native_converter` | `runCodexNativeConverter` | `resources/templates/codex_native_converter.py` | `codex_native_converter/` cluster B |
| `push_down_copilot_customizations` | `pushDownCopilotCustomizations` | `resources/templates/push_down_copilot_customizations.py` | `push_down_copilot_customizations.py` + cluster F |
| `push_down_codex_and_agents_customizations` | `pushDownCodexAndAgentsCustomizations` | `resources/templates/push_down_codex_and_agents_customizations.py` | `push_down_codex_and_agents_customizations.py` + cluster F |
| `push_down_claude_customizations` | `pushDownClaudeCustomizations` | `resources/templates/push_down_claude_customizations.py` | `push_down_claude_customizations.py` + cluster F |
| `new_potential_bug_entry` | `newPotentialBugEntry` | `resources/templates/new_potential_bug_entry.py` | `new_potential_bug_entry.py` (cluster D) |
| `potential_to_issue` | `potentialToIssue` | `resources/templates/potential_to_issue.py` | `potential_to_issue.py` + `potential_to_issue_content.py` (cluster E) |
| `new_active_feature_folder` | `newActiveFeatureFolder` | `resources/templates/new_active_feature_folder.py` | `new_active_feature_folder*.py` cluster C |
| `resolve_execute_hard_lock_prompt` | `resolveExecuteHardLockPrompt` | `resources/templates/resolve_hard_lock_prompt.py` | `resolve_hard_lock_prompt.py` + `resolve_file_prompt.py` (cluster G) |
| `resolve_atomic_plan_prompt` | `resolveAtomicPlanPrompt` | `resources/templates/resolve_atomic_plan_prompt.py` | `resolve_file_prompt.py` (cluster G) |
| `validate_orchestration_artifacts` | `validateOrchestrationArtifacts` | `resources/templates/validate_orchestration_artifacts.py` | `validate_orchestration_artifacts.py` + cluster H |

**Not Python**: `newPotentialEntry`, `linkParentChild`, and all `runPoshQC*` methods use `runtimeKind: "powershell"` and are out of scope for this epic.

**Not script-invoked**: `resolvePolicyAuditTemplateAsset` uses file copy only (`policy-audit-template-assets.ts`); no Python subprocess.

### 3.2 Scripts NOT Invoked by Extension or MCP (dev-internal only)

The following Python modules are repo-internal dev tooling and are **not** bundled or invoked by the extension or MCP server:

- `fix_all.py`, `fix_all_branches.py`, `fix_all_branches_extra.py`, `fix_all_runtime.py`
- `shell_qc.py`
- `agentic_sync.py` (partially — imported by `push_down_copilot_customizations.py` for `ROOT_FOLDERS` constant only; the sync logic itself is not invoked)
- `copy_research_to_issue.py`
- `clean_devcontainer.py`
- `plan_progress_report.py`
- `atomic_executor/` (entire cluster)
- `format_json.py`, `validate_json.py` (repo dev tools, not MCP-exposed)
- `validate_evidence_locations.py` (repo dev tool; CI hook only)
- `tk_dialog_helpers.py` (GUI support for dev tools only)
- `resolve_execute_plan_prompt.py` (uses tkinter; not exposed via MCP)
- `markdown_label_formatter.py`, `json_config.py`

**Scoping recommendation**: The epic title states "port ALL Python command scripts used by the VS Code extension and the standalone MCP server." Accordingly:

- **In scope for the port**: The 12 runtime-invoked commands listed in Section 3.1, and all `dev_tools` modules those commands depend on (clusters A, B, C, D, E, F, G, H, and the shared utilities those clusters import).
- **Out of scope**: `fix_all*`, `shell_qc`, `copy_research_to_issue`, `clean_devcontainer`, `plan_progress_report`, `atomic_executor/**` — these are developer workflow tools that run on developer machines only. They do not need a port to remove the Python runtime dependency from the published extension and MCP server.
- `agentic_sync.ROOT_FOLDERS` constant (imported by `push_down_copilot_customizations.py`): only this constant needs to be replicated in the TS port of that module; the full sync logic is out of scope.

---

## 4. Existing TypeScript Bridge (Current MCP Architecture)

### 4.1 Handler → Service → subprocess chain

```
MCP tool call
  → mcp-handlers/<name>-handlers.ts     (input validation)
  → repo-automation-service.ts           (DefaultRepoAutomationService)
  → executeBundledScriptFromExtensionRoot()  (command-runtime.ts)
  → cp.spawn(python, [scriptPath, ...args])
  → template wrapper .py
  → dev_tools module
```

### 4.2 Post-port target chain

```
MCP tool call
  → mcp-handlers/<name>-handlers.ts     (unchanged input validation)
  → repo-automation-service.ts           (DefaultRepoAutomationService)
  → in-process TS function call          (no subprocess)
  → TS module implementing dev_tools logic
```

The `RepoAutomationService` interface (`repo-automation-service.ts`) remains unchanged. Only the `DefaultRepoAutomationService` implementation of each method changes: the `executeScript()` call is replaced by a direct function call to the TS equivalent. The MCP handlers, tool definitions, and input schemas are unaffected.

### 4.3 Removal targets in command-runtime.ts

After all Python commands are ported:
- The `"python"` branch of `detectRuntime()` can be removed.
- `executeBundledScriptFromExtensionRoot()` can remain for PowerShell commands; the Python probing logic inside it is no longer needed.
- Template wrapper `.py` files in `resources/templates/` are removed (no longer bundled).
- The bundled `resources/scripts/dev_tools/` copy is removed from the extension package.

---

## 5. Module Cluster Summary with Dependencies

### Cluster A — `pr_context` (collect_pr_context + collect_commit_context)
- **Files**: 11 files in `pr_context/` + `collect_commit_context.py`
- **Total LoC**: ~3,273
- **Inter-cluster deps**: None
- **External deps**: `git` binary, `gh` CLI binary, filesystem, subprocess, `base64` (stdlib), `json` (stdlib)
- **Complexity**: Highest; `collector.py` (619 LoC) orchestrates git + gh + feature doc discovery + verification evidence + CI status; `github.py` (549 LoC) wraps many `gh api` calls

### Cluster B — `codex_native_converter`
- **Files**: 18 files
- **Total LoC**: ~4,678
- **Inter-cluster deps**: None
- **External deps**: `typer` library (for CLI), filesystem; the conversion pipeline is pure logic
- **Complexity**: High; the engine is a multi-stage pipeline with many model types; `typer` must be replaced with a plain TS argument parser

### Cluster C — `new_active_feature_folder`
- **Files**: 6 files
- **Total LoC**: ~1,406
- **Inter-cluster deps**: `prompt_mode_contract.py` (cluster G shared utility), `gh` CLI (issue fetch)
- **External deps**: `gh` CLI, filesystem, `code`/`code-insiders` (optional VS Code launch), subprocess

### Cluster D — `new_potential_bug_entry`
- **Files**: 1 file
- **Total LoC**: 465
- **Inter-cluster deps**: None
- **External deps**: `git config`, filesystem, `code`/`code-insiders` (optional), subprocess

### Cluster E — `potential_to_issue`
- **Files**: 2 files
- **Total LoC**: 846
- **Inter-cluster deps**: `prompt_mode_contract.py` (cluster G shared utility)
- **External deps**: `gh` CLI (issue create, label operations), filesystem, subprocess

### Cluster F — `push_down_*`
- **Files**: 7 files
- **Total LoC**: ~2,408
- **Inter-cluster deps**: `agentic_sync.ROOT_FOLDERS` constant (can be inlined in TS)
- **External deps**: Filesystem only; JSON parsing (stdlib); YAML frontmatter parsing (regex-based, no yaml library)

### Cluster G — `resolve_*` prompts
- **Files**: 4 files
- **Total LoC**: ~1,841
- **Inter-cluster deps**: None
- **External deps**: Filesystem, clipboard (optional; `clip` on Windows, `pbcopy` macOS, `xclip`/`wl-copy` Linux)

### Cluster H — `validate_*` artifacts
- **Files**: 8 files
- **Total LoC**: ~2,060
- **Inter-cluster deps**: None
- **External deps**: Filesystem, JSON parsing (stdlib), regex (stdlib)

### Cluster I — Shared utility (in-scope portion)
- **Files**: `prompt_mode_contract.py` (157 LoC), `json_config.py` (51), `markdown_label_formatter.py` (140)
- **Total LoC**: 348
- **External deps**: Filesystem, regex

---

## 6. Hard-to-Port Behaviors and Recommended Approaches

### 6.1 `tkinter` GUI dialogs (`tk_dialog_helpers.py`, `resolve_execute_plan_prompt.py`)

**Situation**: `resolve_execute_plan_prompt.py` opens a native OS file picker via `tkinter.filedialog.askopenfilename`. This module is NOT exposed via any MCP handler or `RepoAutomationService` method. It is a developer-interactive script only.

**Recommendation**: Exclude from the port. `resolve_execute_plan_prompt.py` and `tk_dialog_helpers.py` serve the developer experience on developer machines where Python is present. The MCP/extension-facing equivalent is `resolve_hard_lock_prompt.py` (which takes `--target` as a CLI argument and is in scope). No tkinter dependency exists in the in-scope MCP commands.

### 6.2 Subprocess orchestration (`gh` CLI, `git`)

**Situation**: Multiple clusters spawn `git` and `gh` subprocesses. The TS extension already uses `cp.spawn` for PowerShell commands. Node.js `child_process` provides identical capabilities.

**Recommendation**: Port `SubprocessRunner`/`CommandRunner` as a TypeScript interface + class. Use `node:child_process` `spawnSync` or `execFile` with `encoding: 'utf8'` and `errors: 'replace'` to match Python's `encoding="utf-8", errors="replace"` behavior. Each cluster's git/gh calls map directly to Node.js subprocess calls with the same arguments.

### 6.3 Encoding and Unicode handling

**Situation**: Python uses `encoding="utf-8", errors="replace"` for subprocess stdout, which replaces invalid bytes with U+FFFD. Node.js `child_process` with `encoding: 'utf8'` does not apply replacement characters; it may throw on invalid sequences if using `'utf8'` string mode.

**Recommendation**: Capture subprocess output as `Buffer` (binary) and decode with `buffer.toString('utf8')`. For Windows code page compatibility, use `buffer.toString('utf8')` which replaces lone surrogates rather than throwing. This matches the Python behavior. Document this explicitly in the TS implementation.

### 6.4 `typer` library (`codex_native_converter/cli.py`)

**Situation**: The converter CLI uses Typer for argument parsing and command dispatch. Typer is a Python-only library.

**Recommendation**: Replace with a plain TypeScript argument parser. The converter CLI has two commands (`review`, `apply`) with well-defined option sets. Use a small hand-written parser consistent with the existing TS extension pattern (no external CLI framework dependency). Alternatively, the CLI layer is thin; the port can expose the engine as a TypeScript function and have the `RepoAutomationService` call it directly, bypassing the CLI layer entirely.

### 6.5 `pyperclip` clipboard integration (`resolve_hard_lock_prompt.py`, `resolve_file_prompt.py`)

**Situation**: The `resolve_hard_lock_prompt` and `resolve_file_prompt` commands attempt to copy the resolved prompt to clipboard using `pyperclip` with fallback to OS clipboard commands (`clip`, `pbcopy`, `xclip`, `wl-copy`). The MCP invocation path sets `--quiet` and writes to `artifacts/hard_lock_prompt.txt`, bypassing the clipboard entirely.

**Recommendation**: In the TS port, the `resolveExecuteHardLockPrompt` and `resolveAtomicPlanPrompt` service methods pass `quiet: true`, so no clipboard interaction is needed. Implement clipboard support as an optional feature that falls back gracefully when no clipboard mechanism is available, using Node.js subprocess calls to `clip`/`pbcopy`/`xclip` as the Python code does.

### 6.6 `push_down` YAML frontmatter memory-scope reading (`push_down_claude_filesystem.py`)

**Situation**: The Claude push-down reads YAML frontmatter from agent-memory files to determine `metadata.scope`. It does this with a regex-based parser, not a full YAML library, so no YAML dependency is introduced.

**Recommendation**: Port the regex-based frontmatter parser directly to TypeScript. The same approach works with Node.js regex APIs. No `js-yaml` or similar dependency is required.

### 6.7 `agentic_sync.ROOT_FOLDERS` constant

**Situation**: `push_down_copilot_customizations.py` imports `ROOT_FOLDERS` from `agentic_sync.py`, which is the tuple `(Path(".github/agents"), Path(".github/instructions"), Path(".github/prompts"), Path(".github/skills"))`.

**Recommendation**: Inline this constant in the TS port of `push-down-copilot-customizations.ts` as a typed tuple. No need to port the rest of `agentic_sync.py`.

---

## 7. Feature Decomposition (Ordered, Independently Shippable)

### 7.1 Dependency Graph

```
F1 (shared utilities)
  └─► F2 (validate_* cluster)
  └─► F3 (push_down cluster)
  └─► F4 (collect_commit_context)
  └─► F5 (resolve_* prompts)
  └─► F6 (new_potential_bug_entry)
  └─► F7 (potential_to_issue) [depends on F1]
  └─► F8 (new_active_feature_folder) [depends on F1, F7 shared]
F2, F3, F4, F5, F6, F7, F8 are independent of each other
F9 (pr_context) [depends on F1 git/gh utilities]
F10 (codex_native_converter) [depends on F1 for subprocess wrapper]
F11 (command-runtime.ts cleanup) [depends on F2–F10 all done]
```

### 7.2 Feature List

---

#### F1 — `ts-shared-subprocess-and-utility-layer`

**Purpose**: Establish the shared TypeScript infrastructure all other features depend on.

**Python files ported**:
- `prompt_mode_contract.py` (157 LoC)
- `json_config.py` (51 LoC)
- `markdown_label_formatter.py` (140 LoC)
- Subprocess runner abstraction (extracted from `pr_context/git.py` pattern)

**TS target paths**:
- `extensions/drm-copilot/src/lib/prompt-mode-contract.ts`
- `extensions/drm-copilot/src/lib/json-config.ts`
- `extensions/drm-copilot/src/lib/markdown-label-formatter.ts`
- `extensions/drm-copilot/src/lib/subprocess-runner.ts`

**Tests to port**:
- `tests/scripts/dev_tools/test_prompt_mode_contract.py` → `extensions/drm-copilot/test/lib/prompt-mode-contract.test.ts`
- `tests/scripts/dev_tools/test_json_config.py` → `extensions/drm-copilot/test/lib/json-config.test.ts`
- `tests/scripts/dev_tools/test_markdown_label_formatter.py` → `extensions/drm-copilot/test/lib/markdown-label-formatter.test.ts`

**Prerequisites**: None. First feature.

**LoC estimate**: ~500 LoC new TS production + ~400 LoC tests. Fits within 500-line file limit per file.

---

#### F2 — `ts-validate-orchestration-artifacts`

**Purpose**: Port the full `validate_orchestration_artifacts` command cluster to TypeScript.

**Python files ported**:
- `validate_orchestration_artifacts.py` (246 LoC)
- `validate_orchestrator_state.py` (505 LoC)
- `validate_orchestration_review_artifacts.py` (107 LoC)
- `validate_policy_audit_artifact.py` (472 LoC)
- `_orchestrator_state_human_interaction.py` (127 LoC)
- `_orchestrator_state_routing.py` (216 LoC)
- `validate_evidence_locations.py` (109 LoC)
- `validate_json.py` (278 LoC)

**TS target paths**:
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` (entry point / dispatcher)
- `extensions/drm-copilot/src/lib/validate/orchestrator-state.ts`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-human-interaction.ts`
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`
- `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts`
- `extensions/drm-copilot/src/lib/validate/review-artifacts.ts`
- `extensions/drm-copilot/src/lib/validate/evidence-locations.ts`
- `extensions/drm-copilot/src/lib/validate/json-validator.ts`

**Update**:
- `repo-automation-service.ts` `validateOrchestrationArtifacts()`: replace `executeScript()` call with direct TS call

**Tests to port**:
- `tests/extensions/drm_copilot/resources/templates/test_validate_orchestration_artifacts.py`
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`
→ `extensions/drm-copilot/test/lib/validate/*.test.ts`

**Prerequisites**: F1.

**Note**: `validate_orchestrator_state.py` (505 LoC) exceeds the 500-line file limit; split into `orchestrator-state-core.ts` + `orchestrator-state-remediation.ts` in the TS port.

---

#### F3 — `ts-push-down-customizations`

**Purpose**: Port all three push-down command variants to TypeScript.

**Python files ported**:
- `push_down_copilot_customizations.py` (504 LoC)
- `push_down_copilot_customizations_filesystem.py` (217 LoC)
- `push_down_copilot_customizations_rewrites.py` (293 LoC)
- `push_down_codex_and_agents_customizations.py` (118 LoC)
- `push_down_claude_customizations.py` (403 LoC)
- `push_down_claude_filesystem.py` (472 LoC)
- `push_down_claude_pack_selection.py` (401 LoC)

**TS target paths**:
- `extensions/drm-copilot/src/lib/push-down/copilot-customizations.ts`
- `extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts`
- `extensions/drm-copilot/src/lib/push-down/reference-rewrites.ts`
- `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`
- `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`
- `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`
- `extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts`

**Update**:
- `repo-automation-service.ts` `pushDownCopilotCustomizations()`, `pushDownCodexAndAgentsCustomizations()`, `pushDownClaudeCustomizations()`: replace `executeScript()` with direct TS calls
- `repo-automation-service-push-down.ts`: remove Python arg-building code

**Tests to port**:
- `tests/scripts/dev_tools/test_push_down_claude_customizations.py`
- `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py`
- `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py`
- `tests/scripts/dev_tools/test_push_down_claude_bundled_parity.py`
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (cross-reference)
→ `extensions/drm-copilot/test/lib/push-down/*.test.ts`

**Prerequisites**: F1. `push_down_copilot_customizations.py` (504 LoC) exceeds the 500-line limit; split into `copilot-customizations-engine.ts` + `copilot-customizations-cli.ts`.

---

#### F4 — `ts-collect-commit-context`

**Purpose**: Port `collect_commit_context.py` to TypeScript; it is self-contained.

**Python files ported**:
- `extensions/drm-copilot/resources/templates/collect_commit_context.py` (212 LoC) — self-contained, all logic inline

**TS target paths**:
- `extensions/drm-copilot/src/lib/collect-commit-context.ts`

**Update**:
- `repo-automation-service.ts` `collectCommitContext()`: replace `executeScript()` with direct TS call

**Tests to port**:
- `tests/scripts/dev_tools/test_collect_commit_context.py`
→ `extensions/drm-copilot/test/lib/collect-commit-context.test.ts`

**Prerequisites**: F1 (subprocess runner).

---

#### F5 — `ts-resolve-prompts`

**Purpose**: Port the hard-lock and file-prompt resolvers to TypeScript.

**Python files ported**:
- `resolve_hard_lock_prompt.py` (479 LoC)
- `resolve_file_prompt.py` (619 LoC) — note: exceeds 500 LoC, requires split
- `prompt_mode_contract.py` — already in F1

**TS target paths**:
- `extensions/drm-copilot/src/lib/resolve/hard-lock-prompt.ts`
- `extensions/drm-copilot/src/lib/resolve/file-prompt-core.ts`
- `extensions/drm-copilot/src/lib/resolve/file-prompt-variables.ts`

**Update**:
- `repo-automation-service.ts` `resolveExecuteHardLockPrompt()`, `resolveAtomicPlanPrompt()`: replace `executeScript()` with direct TS calls
- `repo-automation-service-workflows.ts`: remove Python arg builders for these commands

**Tests to port**:
- `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt*.py`
- `tests/extensions/drm_copilot/resources/templates/test_resolve_atomic_plan_prompt*.py`
→ `extensions/drm-copilot/test/lib/resolve/*.test.ts`

**Prerequisites**: F1.

**Note**: `resolve_file_prompt.py` is 619 LoC; must be split into at least two TS files (core resolver + variable substitution logic).

---

#### F6 — `ts-new-potential-bug-entry`

**Purpose**: Port `new_potential_bug_entry.py` to TypeScript.

**Python files ported**:
- `new_potential_bug_entry.py` (465 LoC)

**TS target paths**:
- `extensions/drm-copilot/src/lib/new-potential-bug-entry.ts`

**Update**:
- `repo-automation-service.ts` `newPotentialBugEntry()`: replace `executeScript()` with direct TS call

**Tests to port**:
- `tests/scripts/dev_tools/test_new_potential_bug_entry.py`
- `tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py`
→ `extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts`

**Prerequisites**: F1.

---

#### F7 — `ts-potential-to-issue`

**Purpose**: Port the potential-to-issue promotion command to TypeScript.

**Python files ported**:
- `potential_to_issue.py` (634 LoC) — exceeds 500 LoC; split required
- `potential_to_issue_content.py` (212 LoC)

**TS target paths**:
- `extensions/drm-copilot/src/lib/potential-to-issue/content.ts`
- `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` (core workflow)
- `extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts` (gh label/issue ops)

**Update**:
- `repo-automation-service.ts` `potentialToIssue()`: replace `executeScript()` with direct TS call

**Tests to port**:
- `tests/scripts/dev_tools/test_potential_to_issue.py`
- `tests/scripts/dev_tools/test_potential_to_issue_content.py`
- `tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py`
- `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue*.py`
→ `extensions/drm-copilot/test/lib/potential-to-issue/*.test.ts`

**Prerequisites**: F1. `potential_to_issue.py` is 634 LoC; split into at least two files.

---

#### F8 — `ts-new-active-feature-folder`

**Purpose**: Port the active feature folder creation command to TypeScript.

**Python files ported**:
- `new_active_feature_folder_models.py` (136 LoC)
- `new_active_feature_folder_markdown.py` (252 LoC)
- `new_active_feature_folder_io.py` (305 LoC)
- `new_active_feature_folder_docs.py` (268 LoC)
- `new_active_feature_folder_flow.py` (366 LoC)
- `new_active_feature_folder.py` (79 LoC — facade)

**TS target paths**:
- `extensions/drm-copilot/src/lib/new-active-feature-folder/models.ts`
- `extensions/drm-copilot/src/lib/new-active-feature-folder/markdown.ts`
- `extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts`
- `extensions/drm-copilot/src/lib/new-active-feature-folder/docs.ts`
- `extensions/drm-copilot/src/lib/new-active-feature-folder/flow.ts`
- `extensions/drm-copilot/src/lib/new-active-feature-folder/index.ts`

**Update**:
- `repo-automation-service.ts` `newActiveFeatureFolder()`: replace `executeScript()` with direct TS call

**Tests to port**:
- `tests/scripts/dev_tools/test_new_active_feature_folder*.py` (7 files)
- `tests/extensions/drm_copilot/resources/templates/test_new_active_feature_folder.py`
→ `extensions/drm-copilot/test/lib/new-active-feature-folder/*.test.ts`

**Prerequisites**: F1.

---

#### F9 — `ts-pr-context`

**Purpose**: Port the full PR context collection cluster to TypeScript. This is the largest and most complex single feature.

**Python files ported**:
- `pr_context/models.py` (198 LoC)
- `pr_context/git.py` (153 LoC)
- `pr_context/github.py` (549 LoC) — exceeds 500 LoC; split required
- `pr_context/feature_docs.py` (349 LoC)
- `pr_context/render.py` (342 LoC)
- `pr_context/render_feature_excerpts.py` (256 LoC)
- `pr_context/render_pr_helpers.py` (291 LoC)
- `pr_context/summary_helpers.py` (386 LoC)
- `pr_context/verification_evidence.py` (171 LoC)
- `pr_context/collector.py` (619 LoC) — exceeds 500 LoC; split required

**TS target paths**:
- `extensions/drm-copilot/src/lib/pr-context/models.ts`
- `extensions/drm-copilot/src/lib/pr-context/git-client.ts`
- `extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts`
- `extensions/drm-copilot/src/lib/pr-context/gh-client-details.ts`
- `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts`
- `extensions/drm-copilot/src/lib/pr-context/render.ts`
- `extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts`
- `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts`
- `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts`
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`
- `extensions/drm-copilot/src/lib/pr-context/collector-core.ts`
- `extensions/drm-copilot/src/lib/pr-context/collector-output.ts`

**Update**:
- `repo-automation-service.ts` `collectPrContext()`: replace `executeScript()` with direct TS call

**Tests to port**:
- `tests/scripts/dev_tools/test_collect_pr_context*.py` (4 files)
- `tests/scripts/dev_tools/test_feature_docs.py`
- `tests/scripts/dev_tools/test_git.py`
- `tests/scripts/dev_tools/test_github*.py` (3 files)
- `tests/scripts/dev_tools/test_pr_context_integration.py`
→ `extensions/drm-copilot/test/lib/pr-context/*.test.ts`

**Prerequisites**: F1.

**Note**: `github.py` (549 LoC) and `collector.py` (619 LoC) must each be split into at least two TS files.

---

#### F10 — `ts-codex-native-converter`

**Purpose**: Port the codex-native converter pipeline to TypeScript.

**Python files ported**:
- `codex_native_converter/models.py` (460 LoC)
- `codex_native_converter/models_intermediate.py` (226 LoC)
- `codex_native_converter/inventory.py` (217 LoC)
- `codex_native_converter/classifier.py` (484 LoC)
- `codex_native_converter/section_intent.py` (249 LoC)
- `codex_native_converter/parser.py` (292 LoC)
- `codex_native_converter/mapping.py` (234 LoC)
- `codex_native_converter/rewrites.py` (485 LoC)
- `codex_native_converter/validation.py` (418 LoC)
- `codex_native_converter/pipeline.py` (462 LoC)
- `codex_native_converter/intermediate_state.py` (271 LoC)
- `codex_native_converter/reporting.py` (433 LoC)
- `codex_native_converter/_pipeline_traces.py` (139 LoC)
- `codex_native_converter/_reporting_topology.py` (175 LoC)
- `codex_native_converter/engine.py` (499 LoC)
- `codex_native_converter/cli.py` (308 LoC) — CLI layer replaced by direct function call from service

**TS target paths** (mirroring the 500-line limit):
- `extensions/drm-copilot/src/lib/codex-native-converter/models.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/models-intermediate.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/classifier.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/section-intent.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/parser.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/mapping.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/rewrites.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/validation.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/pipeline.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/intermediate-state.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/reporting.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-traces.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/reporting-topology.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/engine.ts`
- `extensions/drm-copilot/src/lib/codex-native-converter/index.ts`

**Update**:
- `repo-automation-service.ts` `runCodexNativeConverter()`: replace `executeScript()` with direct TS call
- `repo-automation-service-workflows.ts`: update `buildRunCodexNativeConverterOptions` to build TS function call args

**Tests to port**:
- All 16 files in `tests/scripts/dev_tools/codex_native_converter/`
→ `extensions/drm-copilot/test/lib/codex-native-converter/*.test.ts`

**Prerequisites**: F1.

---

#### F11 — `ts-command-runtime-cleanup`

**Purpose**: Remove the Python bridge from `command-runtime.ts` and clean up bundled resources.

**Changes**:
- Remove `"python"` branch from `detectRuntime()` in `command-runtime.ts`
- Remove `resources/templates/*.py` from the extension bundle
- Remove `resources/scripts/dev_tools/` from the extension bundle (`package.json`, `.vscodeignore`)
- Remove `runtimeKind: "python"` from all `ScriptExecutionOptions` usages (they all become direct TS calls after F2–F10)
- Update `packages/mcp-server/` `prepack` script accordingly
- Update integration tests that verify Python is no longer needed

**Prerequisites**: F2, F3, F4, F5, F6, F7, F8, F9, F10 all complete.

---

## 8. Recommended Execution Order

The recommended order balances: delivering value early, establishing shared infrastructure first, and isolating complex features.

```
F1  → shared utilities (prerequisite for all)
F2  → validate_orchestration_artifacts (pure logic, no git/gh, quickest win)
F4  → collect_commit_context (self-contained, 212 LoC, quick win)
F5  → resolve_* prompts (file I/O only, no git/gh)
F6  → new_potential_bug_entry (single file, manageable)
F3  → push_down_* customizations (pure filesystem, complex but no subprocess)
F7  → potential_to_issue (gh CLI, moderate complexity)
F8  → new_active_feature_folder (gh CLI + filesystem, moderate complexity)
F9  → pr_context (most complex; git + gh + feature doc discovery)
F10 → codex_native_converter (pure pipeline logic, complex but isolated)
F11 → command-runtime cleanup (cleanup; all prior features complete)
```

**Rationale**:
- F1 unblocks all other features. It is small and has zero risk.
- F2 and F4 are pure-logic ports (no external processes) and serve as confidence builders.
- F5 is small and validates the template-resolver pattern early.
- F3 (push-down) is filesystem-only and its TS structure is well-scoped.
- F7 and F8 share `gh` CLI patterns; doing F7 before F8 lets F8 reuse the `gh` helper patterns established in F7.
- F9 is the largest feature and is saved until the team has established patterns from smaller features.
- F10 is a pure-logic pipeline that can proceed in parallel with F9 once F1 is done; it is placed after F9 only for sequencing simplicity.
- F11 is a cleanup feature that confirms the port is complete.

---

## 9. Testing Implications

### 9.1 Test Location Policy

Per repository policy (`.claude/rules/general-unit-test.md`), all TS test files go under `extensions/drm-copilot/test/` mirroring the production source structure:
- Production: `extensions/drm-copilot/src/lib/pr-context/git-client.ts`
- Test: `extensions/drm-copilot/test/lib/pr-context/git-client.test.ts`

### 9.2 Mocking Strategy

- `git` and `gh` subprocess calls: mock at the `subprocess-runner.ts` boundary using `vi.spyOn`. All git/gh clients accept an injected runner (matching the Python `CommandRunner` protocol pattern).
- Filesystem reads/writes: use in-memory maps passed via a `FileSystem` interface (matching the Python `FileSystem` Protocol pattern).
- No real subprocesses, no real filesystem temp files in unit tests (per policy).

### 9.3 Coverage Requirements

Line coverage >= 85%, branch coverage >= 75% (uniform across all tiers, per `.claude/rules/quality-tiers.md`). The Python tests across the 12 in-scope commands total ~39,750 LoC and cover substantial edge cases. All distinct behavioral scenarios from the Python tests must be ported.

### 9.4 Property-Based Tests

The `pr_context`, `codex_native_converter`, and `validate_*` clusters contain pure functions that qualify for property-based testing. Per quality tier policy (T1/T2 modules require >= 1 property test per pure function), at minimum one `fast-check` property test should be added per pure function in clusters B and H.

---

## 10. Automation Feasibility

The entire conversion is fully automatable with no human interaction required. All operations involved are:

- Reading Python source files from the local repository.
- Writing TypeScript source files to the same repository.
- Running the TypeScript toolchain (`npm run format`, `npm run lint`, `npm run typecheck`, `npm run test`).
- Running the Python toolchain to verify behavior parity (`poetry run pytest`).
- Git operations (`git add`, `git commit`).
- GitHub operations via `gh pr create` for PR submission.

No third-party UI interaction, no external service authentication beyond what already exists in the dev environment, and no manual approval gates are required within any individual feature PR.

The only human decision point is the epic-level scoping review at the start (the decision in Section 3.2 above, which is resolved by this document).

**AUTOMATION_FEASIBILITY: FULLY_AUTOMATABLE. No third-party UI interaction required.**

---

## 11. Rejected Alternatives

**Alternative: keep Python as a bundled runtime (ship a minimal Python distribution with the extension)**: Rejected because it increases the extension bundle size by approximately 50–200 MB, complicates cross-platform packaging, and does not eliminate the runtime dependency — it only embeds it. The objective is to eliminate Python as a dependency entirely.

**Alternative: port only the template wrappers and keep `dev_tools` in Python**: Rejected because the template wrappers are thin adapters that immediately delegate to `dev_tools` modules; porting the wrappers without porting `dev_tools` would still require bundling the full Python `dev_tools` package and a Python interpreter.

**Alternative: use WASM-compiled Python (e.g., Pyodide)**: Rejected because Pyodide is not supported in VS Code extension hosts or Node.js MCP server contexts without significant shim infrastructure. The existing Python code does not use the scientific Python stack; there is no benefit to WASM Python over native TypeScript.
