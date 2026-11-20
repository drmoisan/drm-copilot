# Issue #984 Research: completion helpers missing from the Claude core pack manifest

- Issue: #984
- Branch: `bug/completion-helpers-missing-from-core-pack-manifest-984`
- Feature folder: `docs/features/active/2026-10-20-completion-helpers-missing-from-core-pack-manifest-984`
- Researcher scope: read-only analysis; no source, configuration, or test file was changed.
- Citation convention: files and symbols only; no line numbers and no commit identifiers.

## Summary of Findings

1. The `$PSScriptRoot` dependency closure of every manifested `.ps1`/`.psm1` file has exactly one gap on the Claude surface: `.claude/hooks/enforce-completion-helpers.ps1`, dot-sourced by `.claude/hooks/enforce-completion-consistency.ps1` (core). The Codex surface has no gap.
2. A second dependency class exists outside `$PSScriptRoot`: hook scripts named in the command text of a manifested file (`.claude/settings.json`, agent frontmatter `hooks:`). The Claude `core.json` ships `.claude/settings.json`, which registers five hook scripts that core does not carry: `validate-pr-author-output.ps1` (no manifest at all) and four language-pack hooks (`check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `check-powershell-test-purity.ps1`, `enforce-powershell-batch-budget.ps1`). A missing registered script does not block; it produces a non-blocking hook error on every matching tool call (Claude Code hook semantics, verified against the published hooks documentation).
3. `.claude/agents/pr-author.md` and `.claude/hooks/validate-pr-author-output.ps1` are real defects of the same family: `orchestrator.md` (core) delegates to `pr-author`, `.claude/settings.json` (core) grants `Agent(pr-author)` and registers `validate-pr-author-output.ps1`, `enforce-pr-author-skill.ps1` (core) routes `gh pr create` through the pr-author path, and `enforce-pr-author-command-allowlist.ps1` (core) is registered only by `pr-author.md`. The #279 audit recorded all three exceptions as an optional follow-up, not as a design decision. Both belong in core.
4. The Claude `core.json` is hand-maintained. The Codex `core.json` is hand-maintained except for agent-family entries, which `scripts/dev_tools/generate_codex_agent_variants.py` (`render_manifest`, `PACK_FAMILIES`) appends and `--check` compares byte-for-byte against `json.dumps(indent=2)` output.
5. The established repository pattern for "a dependency needed only for a governed path" is the named Handler exemption (H1, issue #565, `enforce-feature-folder-order.ps1`). Re-ordering the dependency decision behind the path filter would break structural check S6 in `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`; the Handler pattern does not.
6. Release notes live in `extensions/drm-copilot/CHANGELOG.md` (Keep a Changelog, `## [Unreleased]` with `### Changed`; no `### Fixed` subsection exists yet). The extension is at `1.1.21`, so 1.1.19 through 1.1.21 all ship the gap.

## 1. Current State and Pack Combination

### How packs combine (verified)

- `extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts`: `loadPackManifests` always adds `CORE_PACK_NAME` (`"core"`); `computePublishedPaths` unions the selected packs plus core, and returns `null` for an empty or absent selection, which publishes the full bundle tree. `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (`resolvePublishedPaths`) passes the set to the filtering filesystem (`claude-filesystem-adapter.ts`, `isPackIncluded`).
- `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` behaves the same (`computePublishedPaths`, `resolveManifestPackNames` maps public `csharp` to `csharp-<variant>`).
- Codex virtual resources: `codex-agents-customizations.ts` (`VIRTUAL_RESOURCE_PAIRS`, `RoutingConfigFileSystem`) always publishes `config/orchestration-routing.json`, `config/orchestration-handoff-registry.json`, `config/orchestration-handoff.schema.json`, `.codex/lib/codex-routing/CodexTopology.psm1`, and `.codex/lib/codex-routing/CodexDeployment.psm1`. `RoutingConfigFileSystem` is the outer adapter and lists virtual roots from the pair map without consulting the pack filter, so these five destinations are published under any selection. The Python port carries the same constant (`scripts/dev_tools/push_down_codex_and_agents_customizations.py`, `VIRTUAL_RESOURCE_PAIRS`).
- Consequence for the closure rule: a file in pack P may depend only on files in `core ∪ P` (plus the Codex virtual set). A full-tree publish has no gap.

### Q1. Full `$PSScriptRoot` dependency closure

Enumeration source: every `$PSScriptRoot` occurrence under `extensions/drm-copilot/resources/claude-customizations/.claude` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex`, each target resolved relative to the containing directory and checked against `core ∪ owning pack`.

Claude surface:

| Manifested source (pack) | Target | In closure set |
|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` (core) | `.claude/hooks/enforce-completion-helpers.ps1` | **No (gap)** |
| `.claude/hooks/enforce-completion-helpers.ps1` (would be core) | `config/orchestration-routing.json` (data read via `Join-Path $PSScriptRoot '../../config/orchestration-routing.json'`) | Yes (core) |
| `check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1` (python) | `hook-dependency-guard.ps1`, `../lib/hook-payload/HookPayload.psm1`, `enforce-batch-budget-route.ps1` | Yes (core) |
| `check-powershell-test-purity.ps1`, `enforce-powershell-batch-budget.ps1` (powershell) | same three | Yes (core) |
| All other core hooks | `hook-dependency-guard.ps1`, `HookPayload.psm1`, `feature-folder-resolution.ps1`, `hook-command-*.ps1`, `subagentstop-envelope.ps1`, `premortem-section.ps1`, the `*-helpers.ps1`/`*-resolution.ps1`/`*-modes.ps1`/`*-targets.ps1`/`*-epic-scope.ps1` siblings, `.claude/lib/{worktree-resolution,orchestrator-state,discovery-validation,cleanup-manifest,mermaid}/*` | Yes (core) |
| `.claude/lib/**` modules (core) | nested `Import-Module` targets in `blast-radius`, `mermaid`, `worktree-resolution`, `orchestrator-state`, `parallel-drift`, `project-file-merge`; nested `Join-Path` forms to `../codex-routing/CodexDeployment.psm1`, `../codex-routing/CodexTopology.psm1`, `../model-routing/ModelRouting.psm1`; `../blast-radius/*` from `parallel-drift` and `project-file-merge` | Yes (core) |

Every bundled `.claude/lib` PowerShell file is listed in core (checked file by file against the `core.json` `paths` array).

Codex surface: every target (`hook-dependency-guard.ps1`, `codex-pretooluse-file-mapping.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-completion-helpers.ps1`, `codex-authority-store.ps1`, `codex-agent-profile-attestation.ps1`, `codex-epic-child-launch-attestation.ps1`, the preimplementation-gate siblings including `-epic-resolution.ps1`, `hook-command-*.ps1`, `hook-docs-only-diff.ps1`, `enforce-epic-merge-gate-command.ps1`, `feature-folder-resolution.ps1`, `feature-review-coverage-thresholds.ps1`, `enforce-batch-budget-route.ps1`, `.codex/scripts/epic-child-*.ps1`, `.codex/scripts/codex-routing-cli-common.ps1`, `.codex/lib/codex-routing/*.psm1` (virtual), `config/orchestration-routing.json` (virtual)) is in Codex core or the virtual set. No gap.

Related observation outside the `$PSScriptRoot` closure: `.codex/scripts/post-codex-worktree-session.ps1` is bundled but listed in no Codex manifest. No hook or script depends on it; it is the default of the extension setting `postCodexScriptPath` in `extensions/drm-copilot/src/extension.ts`, which resolves it relative to the destination workspace. Neither completeness test enumerates `.codex/scripts/`, so the gap is invisible to CI. Report to the orchestrator as a related finding (decide in-item or file separately).

### Q2. The other two grandfathered exceptions

Verified dependency edges into the two files from manifested core files:

- `.claude/settings.json` (core): `permissions` lists `Agent(pr-author)` and `Skill(pr-author *)`; the `SubagentStop` group with matcher `pr-author` runs `.claude/hooks/validate-pr-author-output.ps1`.
- `.claude/agents/orchestrator.md` (core): the `Agent(...)` tool entry includes `pr-author`.
- `.claude/skills/pr-author/SKILL.md` (core): states that body-file and receipt writes stay in the pr-author agent scope.
- `.claude/hooks/enforce-pr-author-command-allowlist.ps1` (core): its synopsis states it is registered in the frontmatter of `.claude/agents/pr-author.md`; nothing else registers it.
- `.claude/agents/pr-author.md` frontmatter `hooks:` registers both `enforce-pr-author-command-allowlist.ps1` and `validate-pr-author-output.ps1`.

`validate-pr-author-output.ps1` depends only on `hook-dependency-guard.ps1` and `subagentstop-envelope.ps1` (both core), so adding it closes cleanly. History: `docs/features/completed/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/feature-audit.2026-07-03T01-15.md` lists the three files as an optional follow-up to register; `code-review.2026-07-03T01-15.md` flags the permanent exception set as a risk. No design rationale for exclusion was found. Recommendation: add both to Claude `core.json`.

Settings registration closure (Claude bundle `.claude/settings.json`, `PreToolUse`/`SubagentStop`/`SessionStart`): 31 unique hook scripts are registered; 26 are in core. The five not in core are listed in Summary item 2. Codex `.codex/config.toml` registrations are all in Codex core (the Codex core already carries the four language hooks, issue #697), which is the precedent for adding the same four to Claude core. Recommendation: add the four language hooks to Claude `core.json` (they are self-scoped by file extension and their dependencies are core), leaving the language manifests unchanged (a duplicate entry across manifests is harmless to the set union).

### Q3. Manifest generation

- Claude `core.json`: no generator references `resources/claude-customizations/pack-manifests`; it is hand-maintained. Per-library Pester tests pin subsets (for example `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`).
- Codex `core.json`: `scripts/dev_tools/generate_codex_agent_variants.py` `_synchronize` calls `render_manifest` for each entry of `PACK_FAMILIES` (`core.json` maps to `CORE_FAMILIES`). `render_manifest` appends any missing `.codex/agents/<family>.toml` and profile-variant paths to the existing `paths` list, preserves existing order, and re-serializes with `json.dumps(document, indent=2) + "\n"`. `--check` fails on any byte difference. Hook entries are hand-maintained, but a hand edit must match that serialization exactly. No Codex manifest change is recommended for this issue.

### Q4. Hooks that call `Get-HookDependencyFailureDecision`

Contract (`.claude/hooks/hook-dependency-guard.ps1`, byte-identical at four locations): every guarded load records through `Add-HookDependencyFailure`; the decision function's first two statements and the script tail return `Get-HookDependencyFailureDecision` when any failure is recorded. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` enforces S1 (bootstrap and the three tail statements directly after the dot-source early return), S2 (each direct edge in its own single-statement try recorded through `Add-HookDependencyFailure`, unless a Handler exemption applies), S3, S4, S5, and S6 (the decision function, chosen by `Get-HookDecisionFunctionName`, starts with the dependency decision). Exemptions come only from `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1` (`Get-HookImportFailureExemption`: Design D2, D3; Handler H1 to H6).

Path extraction: every Claude hook parses the envelope with `Resolve-ClaudeHookToolInput` and `Get-ClaudeHookToolInputString` from `.claude/lib/hook-payload/HookPayload.psm1`, and the tail reads stdin through `Read-ClaudeHookRawPayload` from the same module. `Test-IsCheckpointPath` is hook-local and pure, but the path it tests cannot be obtained without HookPayload.psm1. HookPayload.psm1 is therefore a scope dependency; `enforce-completion-helpers.ps1` is an evaluation-only dependency (its functions `Test-IsValidIssueNum`, `Test-IsValidFeatureFolder`, `Test-RouteRequiresPrGate`, `Get-EditReplaceAllFlag`, `Invoke-SingleOccurrenceEdit` are reached only after `Test-IsCheckpointPath` succeeds).

Claude hooks (33 call sites; matcher from `.claude/settings.json` or agent frontmatter):

| Hook | Matcher | Scope | Evaluation-only guarded dependency that denies out-of-scope calls today |
|---|---|---|---|
| `enforce-completion-consistency.ps1` | Write/Edit | path: canonical checkpoint | `enforce-completion-helpers.ps1` (**this bug**) |
| `enforce-checkpoint-monotonic.ps1` | Write/Edit | path: canonical checkpoint | none (HookPayload only) |
| `enforce-discovery-artifact-gate.ps1` | Write/Edit | path: `discovery/*` artifact types | `DiscoveryValidation.psm1` (same class) |
| `enforce-python-batch-budget.ps1` | Write/Edit | path: `*.py` | `enforce-batch-budget-route.ps1` (same class) |
| `enforce-powershell-batch-budget.ps1` | Write/Edit | path: `*.ps1/psm1/psd1` | `enforce-batch-budget-route.ps1` (same class) |
| `check-python-test-purity.ps1`, `check-powershell-test-purity.ps1` | Write/Edit | path: test files | none |
| `enforce-evidence-locations.ps1` | Write/Edit | path: forbidden evidence roots | none |
| `enforce-feature-folder-order.ps1` | Write/Edit | path: plan files | already handled (H1) |
| `enforce-mermaid-validation.ps1` | Write/Edit | path: Markdown/diagram files | already handled (D2, runtime import) |
| `enforce-orchestration-preimplementation-gate.ps1` | Bash, Write/Edit, Agent | implementation paths, commands, delegations | broad; treat as global |
| `validate-bash.ps1` | Bash | global | n/a |
| `enforce-promotion-mcp-only.ps1`, `enforce-pr-author-skill.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1` | Bash | command pattern | command scanning needs `hook-command-scanner.ps1`/`hook-command-invocation.ps1` (scope dependencies) |
| `enforce-prd-feature-before-planner.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-model-routing-receipt.ps1`, `enforce-epic-invocation-origin.ps1`, `enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1` | Agent | delegation pattern | partly handled (H3 to H6); blocks only Agent calls |
| `validate-*.ps1` (SubagentStop, 11 files) | per-agent matcher | agent-scoped by registration | n/a (blocks only that agent's stop) |

Codex hooks (19 files): payload transport and path mapping come from `.codex/hooks/codex-pretooluse-file-mapping.ps1` (`ConvertFrom-CodexPreToolUsePayload`, `ConvertTo-CodexFileEditInput`), a guarded dot-source; `.codex/hooks/enforce-completion-consistency.ps1` also takes `$script:GovernedCheckpointPath` from the dot-sourced `enforce-checkpoint-monotonic.ps1`. Both are scope dependencies. Only `enforce-completion-helpers.ps1` is evaluation-only there, and it is already manifested in Codex core.

Impact ranking: the Write/Edit hooks are the high-impact class, because one evaluation-only failure denies every file edit. After this fix and the closure test, every evaluation-only dependency in that class is manifested in core and guarded against regression. Converting `enforce-discovery-artifact-gate.ps1` and the two batch-budget hooks to the Handler pattern is defensible but optional; it costs two production PowerShell files per hook (repository copy plus bundle copy) against the direct-mode budget of three.

### Q5. Existing tests and where the new behaviour test fits

Claude: `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`, `.DefaultReader.Tests.ps1`, `.EditSemantics.Tests.ps1`, `.EditTarget.Tests.ps1`, `.FailClosed.Tests.ps1`, `.Payload.Tests.ps1`; the Codex hook is also tested from `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`. Codex: `tests/scripts/codex-hooks/enforce-completion-consistency-{default-reader,edit-semantics,edit-target,epic-scope,fail-closed}.Tests.ps1`.

Missing-dependency simulation without temporary files (verified in `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` B1 and `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` H1): `Mock Import-Module { }` plus `Mock Join-Path { throw 'simulated load failure: <leaf>' } -ParameterFilter { $ChildPath -eq '<leaf>' }`, then re-dot-source the hook inside the `It`, assert the handler variable names the leaf (`-Because 'E-CONSTRUCTION'`), call the decision function with an in-memory envelope, and reset the variable in `finally`. Process-level checks redirect `[Console]::In`/`[Console]::Error` (`Invoke-HookProcess`).

Effects of the recommended change on existing suites:

- B1 in `hook-dependency-failure.Claude.Tests.ps1` excludes edges whose leaf a Handler entry lists for that hook, so the helper edge leaves B1 once the H entry exists. Its remaining edges for this hook (HookPayload.psm1) keep denying.
- `hook-import-failure-exemptions.FailClosed.Tests.ps1` has 461 physical lines (Read output); a new Describe would pass the 500-line limit. The new proofs go in a new file, for example `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1`.
- `tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1` (G1 handler present, G2 no unlisted handler, G3 deny code present) runs over repository and mirror roots, so the bundle copy must carry the handler too.

### Q6. Mirror set

- `enforce-completion-consistency.ps1`: `.claude/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. The Claude and Codex copies differ by design; each repository copy must equal its bundle copy.
- `enforce-completion-helpers.ps1`: the same four locations.
- Pins: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (text equality, repository versus bundle) and the Codex twin `test_push_down_codex_and_agents_resource_contracts.py`; the guard and exemption Pester suites run over both roots; `hook-dependency-guard.ps1` is stated byte-identical at four locations (not changed by the recommendation).

### Q7. Release notes

`extensions/drm-copilot/CHANGELOG.md` is the only changelog. Format: Keep a Changelog 1.1.0; current `## [Unreleased]` carries `### Changed` bullets that name the issue in parentheses. `extensions/drm-copilot/PUBLISHING.md` stages the changelog with the version bump; `scripts/powershell/Publish-DrmCopilotExtension.ps1` warns when it is missing. Proposed entry: a new `### Fixed` subsection under `## [Unreleased]` stating that the core Claude pack now carries `.claude/hooks/enforce-completion-helpers.ps1` (and the other added files), that a repository that received 1.1.19, 1.1.20, or 1.1.21 must re-run the Claude push-down, and that `enforce-completion-consistency.ps1` no longer denies edits outside the checkpoint when the helper is absent.

### Q8. Dependency-closure test design: survey of forms in the bundles

| Form | Example source | Notes |
|---|---|---|
| F1 positional | `. (Join-Path $PSScriptRoot 'x.ps1')`, `Import-Module (Join-Path $PSScriptRoot '../lib/a/A.psm1')` | majority; inside or outside `try` |
| F2 named | `Join-Path -Path $PSScriptRoot -ChildPath 'A.psm1'` | `.claude/lib/**` modules |
| F3 backtick continuation | `Join-Path -Path $PSScriptRoot` followed by a backtick line continuation and `-ChildPath '../lib/...'` | `enforce-discovery-artifact-gate.ps1`, `validate-discovery-artifact-gate.ps1` |
| F4 nested | `Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '..') -ChildPath (Join-Path -Path 'codex-routing' -ChildPath 'CodexDeployment.psm1')` | `OrchestratorStateCodexModelReceipts.psm1`, `OrchestratorStateCodexTopologyReceipts.psm1`, `OrchestratorStateCompletion.psm1` |
| F5 parent | `Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/epic-child-launch-contract.ps1'` | two Codex hooks |
| F6 variable then import | `$script:MermaidModulePath = Join-Path ...` then `Import-Module $script:MermaidModulePath` | `enforce-mermaid-validation.ps1` |
| F7 data file | `Join-Path $PSScriptRoot '../../config/orchestration-routing.json'` | both helper copies |
| F8 dynamic | `Join-Path $ScriptRoot "../lib/codex-routing/$ModuleName"` | `.codex/scripts/codex-routing-cli-common.ps1` (`Get-CodexRoutingModuleCandidate`) |
| Non-dependency | `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`, `[string]$ScriptRoot = $PSScriptRoot` | repository-root computations |
| False-positive source | comment-based help such as `dot-sourced as: . (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')` | `hook-command-invocation.ps1`, `hook-command-scanner.ps1`, self-references in `hook-command-heredoc.ps1`, `feature-review-coverage-thresholds.ps1` |

## 2. Candidate Approaches

### A. Hook behaviour (AC3)

- **A1 (selected): named Handler exemption, the H1 pattern.** In `.claude/hooks/enforce-completion-consistency.ps1`, replace the guarded `Add-HookDependencyFailure` load of the helper with a scoped handler: initialize `$script:CompletionHelpersImportFailure = $null` and set it to `'enforce-completion-helpers.ps1'` in the catch of the single-statement try. In `Invoke-CompletionConsistencyDecision`, directly after the `Test-IsCheckpointPath` allow, add `if ($script:CompletionHelpersImportFailure) { return ConvertTo-CompletionDenyDecision -Reason "COMPLETION_CONSISTENCY_BLOCKED: the shared helpers '<leaf>' failed to load ...; the gate fails closed." }`. HookPayload.psm1 stays a guarded dependency (it is needed to read the path). Add a Handler entry (next free id, issue `#984`, surface `claude`, HandlerFile, ConsumerFile and DenyPathFile all `.claude/hooks/enforce-completion-consistency.ps1`, Variable `CompletionHelpersImportFailure`, DenyPathCondition `$script:CompletionHelpersImportFailure`, DenyCode `COMPLETION_CONSISTENCY_BLOCKED:`) to `Get-HookImportFailureExemption`. That function hard-codes `Leaf = @('feature-folder-resolution.ps1')` for every Handler row, so the tuple needs a leaf column (or the new row is emitted separately). Rationale: reuses an approved, tested exemption mechanism; S1, S2, S6, G1 to G3 stay satisfied without changing the guard or the structural checks; the change is two production PowerShell files.
- Rejected: **A2, move the path filter ahead of the dependency decision.** It violates S6 (and the S1 tail ordering), so the structural test and its exemption model would need a new rule kind.
- Rejected: **A3, add a `-Name` filter parameter to `Get-HookDependencyFailureDecision`.** It passes S1/S6 textually while weakening their intent, and changes the guard at four byte-identical locations (four production files, over the direct-mode budget).
- Codex copy: unchanged. Its helper is manifested, and its path mapping depends on two other guarded dot-sources, so the handler would only cover one of three dependencies; the file is already at 491 physical lines. Record the decision in the plan.

### B. Closure regression test (AC2)

- **B1 (selected): Python, `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`** (name indicative). Reads the real bundles and manifests from disk like the existing completeness tests; imports `CORE_PACK_NAME`/`compute_published_paths` from `scripts.dev_tools.push_down_claude_pack_selection` and `scripts.dev_tools.push_down_codex_pack_selection`, and `VIRTUAL_RESOURCE_PAIRS` from `scripts.dev_tools.push_down_codex_and_agents_customizations`, so pack combination and the virtual set come from the authoritative Python port rather than a restated constant. Rationale: sits beside the two completeness twins, runs on all four `quality-checks7` Python jobs, and can import the authoritative constants.
- Rejected: **B2, Pester reusing `HookDependencyGraph.Helpers.ps1`** (`Get-HookScriptEdge`, `Resolve-HookGraphStaticPath`). The AST resolver already handles F1 to F6 and ignores comments, but `Get-HookScriptEdge` collects only imports and dot-sources (misses F7), and pack combination plus the Codex virtual set would be restated in PowerShell with no authoritative source to import. It remains a valid fallback if the Python lexer proves brittle.
- Rejected: **B3, TypeScript.** It would duplicate the Python twin and parse PowerShell in TypeScript with no reuse.

## 3. Recommended Design

### Manifest changes (AC1, Q2)

Add to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: `.claude/hooks/enforce-completion-helpers.ps1`, `.claude/agents/pr-author.md`, `.claude/hooks/validate-pr-author-output.ps1`, and (recommended, orchestrator to confirm scope) `.claude/hooks/check-python-test-purity.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/check-powershell-test-purity.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`. No Codex manifest change.

Completeness tests: empty `PRE_EXISTING_UNRELATED_EXCEPTIONS` in `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` and `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (keep an empty set with a comment naming issue #984, following the Codex precedent `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS = frozenset()`), update both module docstrings, and replace the vacuous `test_documented_exceptions_remain_absent_from_every_manifest` with an assertion that the exception set is empty. The TS twin has no "remain absent" test.

### Closure test algorithm (B1)

1. For each surface (Claude bundle root `extensions/drm-copilot/resources/claude-customizations`; Codex bundle root `extensions/drm-copilot/resources/codex-and-agents-customizations`), load every `pack-manifests/*.json`.
2. For each manifest P, compute the effective set `E(P) = paths(core) ∪ paths(P)` (for Codex also the destinations of `VIRTUAL_RESOURCE_PAIRS`).
3. For each `.ps1`/`.psm1` path in `paths(P)`, read its bundle file. For Codex virtual destinations under `.codex/lib/`, read the resource path from the pair (`resources/lib/...`). For the `csharp-legacy` `source_prefix`, read from the prefixed source (it carries no PowerShell today).
4. Lex the text: remove `<# ... #>` block comments and `#` line comments outside single-quoted, double-quoted, and here-string literals. A lexer is required because the help-text forms in the table above are the observed false-positive source.
5. Extract dependency targets with explicit patterns for F1 to F7. Resolve each relative to the source file's directory with POSIX normalization (`posixpath.normpath` on the bundle-relative path; reject a result that escapes the bundle root), and require the resolved path to be in `E(P)`. Data targets (F7) are checked the same way.
6. Exhaustiveness guard: every remaining `$PSScriptRoot` occurrence must be matched by a dependency pattern or by a named non-dependency pattern (the repository-root `Split-Path` forms and `$ScriptRoot = $PSScriptRoot` parameter defaults); an unrecognized occurrence fails the test, so a new spelling cannot produce a silent false negative.
7. F8: one named dynamic entry for `Get-CodexRoutingModuleCandidate` whose expected candidates (`.codex/lib/codex-routing/CodexDeployment.psm1`, `.codex/lib/codex-routing/CodexTopology.psm1`) must be in `E(core)`.
8. Command-text closure: every `\.claude/hooks/[\w.-]+\.ps1` named in `.claude/settings.json` hook commands, and in the frontmatter `hooks:` of each manifested `.claude/agents/*.md`, must be in `E(P)` for the manifest that lists that file; the same for `\.codex/hooks/[\w.-]+\.ps1` in `.codex/config.toml`.
9. Self-tests with in-memory text (no files): one case per form F1 to F7 resolves to the expected target, a commented-out reference is ignored, an unrecognized `$PSScriptRoot` form fails the exhaustiveness guard, and a synthetic manifest missing a target reports it. A non-empty floor on the number of scanned sources keeps the real-bundle test from passing vacuously.

### Avoiding false positives

Comment stripping (step 4) removes the help-text forms; resolution relative to the source directory, not the bundle root, avoids misattributing `../lib` targets; the virtual set and `core ∪ P` model the real publish semantics; data and dynamic targets are explicit, named cases rather than heuristics.

## 4. Behavior Semantics (AC3)

- The helper fails to load, and the payload targets a path other than `artifacts/orchestration/orchestrator-state.json` (after `\` to `/` normalization, matched by `Test-IsCheckpointPath`): allow, exit 0.
- The helper fails to load, and the payload targets the checkpoint (Write or Edit, relative or absolute path): deny with a reason starting `COMPLETION_CONSISTENCY_BLOCKED:` that names `enforce-completion-helpers.ps1`, exit 0 with the JSON decision; `Resolve-EditedCheckpointContent` and every helper function are not called.
- HookPayload.psm1 fails to load: deny every call (unchanged; the path cannot be read).
- `hook-dependency-guard.ps1` fails to load: stderr reason and exit 2 (unchanged).
- Envelope anomaly: deny (unchanged). A missing `file_path`: allow (unchanged).
- Helper loaded: all existing behaviour unchanged.

## 5. Requirements Mapping

| Acceptance criterion (issue.md) | Change | Proof |
|---|---|---|
| AC1 core carries the helper; a fresh push-down places it | `core.json` entry | completeness tests with empty exceptions; closure test; a push-down unit test through the in-memory filesystem asserting the helper in the published set for `packs = {core}` (TS `claude-customizations.test.ts` or Python pack-selection twin) |
| AC2 completeness test fails when a manifested hook's dependency is missing | new closure test | self-test with a synthetic manifest that omits a target |
| AC3 helper removed: non-checkpoint allowed, checkpoint denied | Handler conversion plus exemption entry | new Pester file; structural, B1, and guard suites stay green |
| AC4 release notes | `CHANGELOG.md` `### Fixed` | review |

## Numeric Derivation Evidence

No numeric count is proposed for an approved `spec.md` acceptance criterion (the spec is a draft and its criteria are not numeric). The counts below support findings only; the recommended tests compute their sets from the tree and assert set membership, not a fixed count.

### Claim N1: Claude `$PSScriptRoot` closure gap set

- Complete Family: every dependency target (dot-source, `Import-Module`, data `Join-Path`) reached through `$PSScriptRoot` from a `.ps1`/`.psm1` file listed in any Claude pack manifest.
- Exhaustive Search Scope: all files under `extensions/drm-copilot/resources/claude-customizations/.claude`, all six `pack-manifests/*.json`.
- Inclusion Rules: the source is manifested; the target is resolved relative to the source directory; the target is absent from `core ∪ owning pack`.
- Exclusion Rules: comment text; repository-root `Split-Path` computations; targets of unmanifested sources.
- Primary Search Strategy or Query Expression: content search for `PSScriptRoot` across the bundle `.claude` tree (all occurrences, paginated to completion), each target resolved by hand and checked against the manifest `paths` arrays.
- Primary Member Set: {`.claude/hooks/enforce-completion-helpers.ps1`}
- Primary Count: 1
- Cross-check Search Strategy or Query Expression: list bundle `.claude/hooks/*`, `.claude/agents/*.md`, `.claude/lib/**` and diff against the union of manifest paths (unmanifested set: `.claude/agents/pr-author.md`, `.claude/hooks/enforce-completion-helpers.ps1`, `.claude/hooks/validate-pr-author-output.ps1`); then search each unmanifested file name across bundle `.ps1`/`.psm1` text for a `$PSScriptRoot`-based reference.
- Cross-check Member Set: {`.claude/hooks/enforce-completion-helpers.ps1`} (`validate-pr-author-output.ps1` is referenced only from `settings.json` and `pr-author.md`; `pr-author.md` is not a script target)
- Cross-check Count: 1
- Member-set Comparison: identical after normalization.

### Claim N2: Codex `$PSScriptRoot` closure gap set

- Complete Family: as N1 for the Codex surface, including the virtual destinations.
- Exhaustive Search Scope: all files under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex`, all six Codex manifests, `VIRTUAL_RESOURCE_PAIRS`.
- Inclusion Rules and Exclusion Rules: as N1; virtual destinations count as published.
- Primary Search Strategy or Query Expression: content search for `PSScriptRoot` across the Codex bundle tree, targets resolved and checked.
- Primary Member Set: {} (empty)
- Primary Count: 0
- Cross-check Search Strategy or Query Expression: bundle `.codex/hooks/*` and `.codex/scripts/*` listed and diffed against Codex `core.json`; the only unmanifested PowerShell file is `.codex/scripts/post-codex-worktree-session.ps1`, and a search for its name across Codex bundle scripts finds no reference.
- Cross-check Member Set: {} (empty)
- Cross-check Count: 0
- Member-set Comparison: identical.

### Claim N3: hook scripts registered by Claude core `settings.json` but absent from Claude core

- Complete Family: hook script paths named in `command` values of every hook event group in bundle `.claude/settings.json`.
- Exhaustive Search Scope: bundle `.claude/settings.json`; Claude `core.json`.
- Inclusion Rules: the registered path is not in `core.json`.
- Exclusion Rules: inline commands with no hook file.
- Primary Search Strategy or Query Expression: content search for `\.ps1` in bundle `settings.json`, de-duplicated (31 unique scripts), each checked against `core.json`.
- Primary Member Set: {`check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `check-powershell-test-purity.ps1`, `enforce-powershell-batch-budget.ps1`, `validate-pr-author-output.ps1`}
- Primary Count: 5
- Cross-check Search Strategy or Query Expression: the `$script:ReasonPrefix` table in `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, which B4 pins to the PreToolUse and SubagentStop registrations (30 entries, equal to 31 minus the SessionStart-only `persist-session-id.ps1`), checked against `core.json`.
- Cross-check Member Set: the same five names.
- Cross-check Count: 5
- Member-set Comparison: identical.

## 6. Testing Implications

- Python (pytest): the new closure test module with real-bundle assertions and in-memory self-tests; updated completeness tests. Line and branch coverage apply to production Python only; no production Python changes.
- TypeScript (Jest): updated completeness twin; optionally a published-set assertion in `extensions/drm-copilot/test/lib/push-down/claude-pack-selection.test.ts` or `claude-customizations.test.ts`. No production TypeScript changes, so no `coverageThreshold` entry.
- Pester: a new file for the handler proof (control allow for a non-checkpoint path with the helper loaded; allow for the same path with the helper failed; deny for a relative and an absolute checkpoint path with the helper failed, naming the leaf; helper functions not invoked on the deny path, proven by mocks; a process-level run through the `&` route showing exit 0 and an allow for a `.csproj` path with the helper dot-source failing). Changed-line coverage of `enforce-completion-consistency.ps1` comes from `artifacts/pester/powershell-coverage.xml`.
- Suites to re-run: `hook-dependency-guard-completeness.Tests.ps1`, `hook-import-failure-exemptions.Guard.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, all `enforce-completion-consistency*.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, both completeness tests, the Codex generator `--check`.

## Automation Feasibility

This work has no human-interaction steps. Every change is a file edit, every proof is an automated test run locally and in CI, and the downstream re-push instruction is delivered as a changelog entry. No manual validation, credential, or interactive approval is required by the change itself; merge authorization follows the repository's normal orchestration route.

## Items for the Orchestrator to Confirm (need `git` or `gh`)

1. The first release that shipped the fail-closed dependency guard in `enforce-completion-consistency.ps1` (issue #786) together with the helper gap, through `git log` on the bundle copy and the release tags. It sets the version range in the changelog (expected 1.1.19 to 1.1.21).
2. Whether the release workflow copies `## [Unreleased]` into a versioned section, through `git log -p` on `extensions/drm-copilot/CHANGELOG.md` and the release commits.
3. A tree-wide search of tests for literals that pin the Claude `core.json` contents or count (for example an expected path list) that adding eight entries would break; the research found none in `test_push_down_claude_pack_selection.py`, but the in-memory push-down suites were not read in full.
4. Scope decisions: the four language hooks in Claude core, `.codex/scripts/post-codex-worktree-session.ps1` in Codex core, and Handler conversion for `enforce-discovery-artifact-gate.ps1` and the two batch-budget hooks.
5. File housekeeping: an earlier copy of this artifact was written as `research/issue-984-research.md`, which does not follow the `<timestamp>-<short-name>-research.md` convention. Its content is identical; delete it. The timestamp in this file's name is an estimate, because the researcher has no clock access.

## Pre-Mortem

- Review checklists: a reviewer can flag the Handler conversion as weakening fail-closed behaviour; mitigation: the plan cites H1 (#565) as precedent, adds the exemption entry with a justification starting with its id, and proves fail-closed behaviour on the checkpoint path in the new Pester file.
- Coverage: the new deny branch in `enforce-completion-consistency.ps1` can be uncovered if the proof only calls the decision function in an un-instrumented way; mitigation: the proof calls `Invoke-CompletionConsistencyDecision` directly in-process, and the plan reads per-file line coverage from `artifacts/pester/powershell-coverage.xml`. No production Python or TypeScript changes, so no new thresholds.
- Mirror parity: the repository and bundle copies of `enforce-completion-consistency.ps1` must stay equal, and the guard suite checks both roots; mitigation: one task edits both and runs `test_push_down_claude_resource_contracts.py` and `hook-import-failure-exemptions.Guard.Tests.ps1`. This plan changes no fact stated in the execution-environment brief, so no brief update is needed; if the closure test becomes a pinned contract, the plan adds it to the brief's contract-test list in all six copies.
- File size: `enforce-completion-consistency.ps1` has about 488 physical lines and `hook-import-failure-exemptions.FailClosed.Tests.ps1` 461; mitigation: the handler uses a single-line try and a single-line deny, the executor records `wc -l` before and after, and the new proofs go in a new test file.
- Test isolation: re-dot-sourcing the hook in an `It` leaves `$script:CompletionHelpersImportFailure` and helper functions in scope for later tests; mitigation: reset the variable in `finally`, re-dot-source the clean hook in `AfterAll`, and run the seeded shuffled Pester runs with at least three seeds plus a reversed-order run of the new Python module.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` on a case-sensitive file system, and the Python test runs on four Python versions; mitigation: forward-slash paths through `Join-Path`, no drive letters, exact case in fixture paths, and a POSIX path library (`posixpath`) in the Python resolver.
- Evidence: fail-before evidence for AC2 and AC3 must exist before the fix; mitigation: run the new closure test and the new Pester file against the unfixed manifest and hook first and record both failing runs under `evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`; no artifact records an absolute path.
