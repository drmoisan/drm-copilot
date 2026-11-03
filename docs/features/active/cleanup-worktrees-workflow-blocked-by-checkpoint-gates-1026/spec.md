# cleanup-worktrees-workflow-blocked-by-checkpoint-gates (Spec)

- **Issue:** #1026
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-03T12-30
- **Status:** Draft
- **Version:** 0.2

## Context
- Summary of the bug and its impact (link to repro/playbook entry): the `cleanup-merged-worktrees` skill cannot complete its documented workflow from an agent session, because checkpoint-based enforcement hooks treat every cleanup write, commit, delegation, and PR creation as unauthorized feature implementation. A cleanup run writes none of the per-feature, epic, or parallel checkpoints by design (skill text, `## End-to-End Workflow`), so no gate recognizes it. Worktrees that hold uncommitted lessons cannot be preserved or removed from the agent. Reproduction records: `evidence/regression-testing/reproduction.2026-11-03T11-56.md` and `evidence/regression-testing/reproduction-pr-leg.2026-11-03T12-12.md` in this feature folder. Design input: `research/research.2026-11-03T12-06.md`.
- Observed environment(s): a main session on `main` whose checkout has no `artifacts/orchestration/orchestrator-state.json`, after a feature or parallel run closed and its checkpoint was archived. Windows host; the Linux CI hook-suite job runs the same hooks on a case-sensitive file system.
- Customer impact and severity (who is affected, how often, how bad): High (issue severity). Every operator running worktree cleanup is affected on every run that has content to preserve. The only workaround is running the steps outside the agent with the shell-escape prefix.
- First observed date and version(s) impacted: captured 2026-10-30; reproduced on current `main` on 2026-11-03 (extension and MCP server release 1.1.25).

## Repro & Evidence
- Steps to reproduce (with data/flags/inputs): from a session root without `artifacts/orchestration/orchestrator-state.json`, follow the skill workflow: write `artifacts/orchestration/cleanup-worktrees-manifest.json` (`tool: cleanup-merged-worktrees`, `schema_version: 1`); run `cleanup-worktrees.sh --preserve`; commit the consolidation branch `documentationandmemories`; delegate `Agent(pr-author)` with `branch: documentationandmemories`; let pr-author write its receipt and run `gh pr create`; run `--apply`; run a manifest-authorized `git worktree remove` for each `SAFE_TO_DELETE` worktree. The reproduction scripts call `Invoke-OrchestrationPreimplementationGateDecision` with an empty checkpoint and with a ready checkpoint, `Get-DocsOnlyDiffTextViolation`, and `Invoke-ModelRoutingReceiptDecision` with a resolved checkpoint path that does not exist.
- Expected vs actual behavior: expected, every step runs from the agent and a manifest-authorized `SAFE_TO_DELETE` removal is reachable. Actual (no checkpoint):

  | Operation | Decision on main | Hook file and function |
  |---|---|---|
  | Write of the manifest | deny, `PREIMPLEMENTATION_GATE_BLOCKED` | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `Test-ImplementationPath` (`.json` extension leg) |
  | Write of a scratch `.ps1` or `.py` outside every worktree | deny, `PREIMPLEMENTATION_GATE_BLOCKED` | same, `Test-ImplementationPath` |
  | `git add` of `docs/research/...` or `.claude/agent-memory/...` | deny | `Test-ImplementationCommand` with `Test-ExemptOrchestrationStagingCommand` (`enforce-orchestration-preimplementation-gate-helpers.ps1`) |
  | `git commit -F <file>` | deny | `Test-ImplementationCommand` (git staging leg) |
  | `Agent(pr-author)` with `branch: documentationandmemories` | deny, `MODEL_ROUTING_RECEIPT_BLOCKED` | `.claude/hooks/enforce-model-routing-receipt.ps1`, `Invoke-ModelRoutingReceiptDecision` via `Test-ModelRoutingReceiptPresent` |
  | Write of `<consolidation worktree>/artifacts/pr_body_<N>.receipt.json` | deny, `PREIMPLEMENTATION_GATE_BLOCKED` | preimplementation gate, `Test-ImplementationPath` (`.json` leg) |
  | `gh pr create` for a branch whose diff includes `.claude/agent-memory/` | deny, `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` | `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `Get-PrAuthorBypassReason`; docs-only exemption `Get-PrAuthorDocsOnlyExemption` rejects via `Get-DocsOnlyDiffTextViolation` (`DOCS_ONLY_EXEMPTION_NON_DOCS_PATH`) |
  | Skill step 4 | requires `--require-pr-creation-ready` validation of a checkpoint the run cannot have | `.claude/skills/cleanup-merged-worktrees/SKILL.md`, `## End-to-End Workflow` |

- Logs/screenshots/error snippets: `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.`; `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint.`; `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`.
- Frequency / determinism (always, intermittent, data-dependent): deterministic. With a ready checkpoint injected, the manifest Write and the agent-memory `git add` are allowed, so every denial depends only on checkpoint absence.
- Not reproduced (recorded for scope): `git push -u origin documentationandmemories` is allowed today; `--preserve` staging and `--apply` run their git calls inside the script, which no hook sees; the manifest-authorized removal branch already exists in `enforce-parallel-worktree-removal-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1` (issue 635, `CleanupWorktreeManifest.psm1`) and is blocked only because the manifest cannot be written.

## Scope & Non-Goals
- In scope:
  - Allow-side cleanup legs in the Claude preimplementation gate and its Codex twin: manifest Write, scratch Write under the temporary root, Write/Edit of allowlisted paths and the pr-author receipt inside the consolidation worktree, and `git add`/`git commit` in the consolidation worktree.
  - A cleanup exemption in the PR-author gate (`enforce-pr-author-skill`) that replaces the orchestrator-state preflight for consolidation PRs only.
  - A cleanup allow for `Agent(pr-author)` in `enforce-model-routing-receipt.ps1`.
  - Codex entry-tail forwarding of Write `content` so the Codex manifest leg can validate it.
  - Skill text in `.claude/skills/cleanup-merged-worktrees/SKILL.md` and the execution-environment brief, with all mirrors and pack manifests.
  - Pester suites, including one composed end-to-end suite over the hook decision functions.
- Out of scope / non-goals:
  - Codex twins of the PR-author gate, the checkpoint-backed model-routing gate, the manifest removal branch, and the cleanup skill. Codex has no PR-author gate, no checkpoint-backed model-routing receipt gate, no manifest branch in its epic worktree-removal gate, and no cleanup skill under `.agents/skills/` or `.github/skills/`. These are non-goals, not parity gaps. Only the preimplementation-gate legs are mirrored.
  - Any `run_id` binding between the manifest and the PR (decided; see Proposed Fix).
  - `jq` availability for `--preserve` on the operator host.
  - The `--preserve` regression for `modified` records (filed separately) and the target-worktree resolver family (#1009, #1010, #1011).
  - Any relaxation outside the cleanup context.
- Explicitly excluded systems, integrations, or datasets: no change to `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, the worktree resolver (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`, `.codex/hooks/hook-target-worktree.ps1`), the preimplementation `-helpers.ps1`, `-targets.ps1`, and `-epic-scope.ps1` files (Claude and Codex), `hook-docs-only-diff.ps1` (Claude and Codex), or the bash scripts under `.claude/skills/cleanup-merged-worktrees/scripts/`. No new Python, and no Python leg in any hook.

## Root Cause Analysis
- Current hypothesis or confirmed root cause: confirmed. The preimplementation gate, the PR-author preflight, the model-routing receipt gate, and the skill's own PR step all assume that every write, commit, delegation, or PR belongs to a feature orchestration with a per-feature checkpoint. A cleanup run is a sanctioned non-feature workflow whose integrity record is the manifest, and no gate reads the manifest except the removal gates.
- Signals/evidence supporting it: both reproduction records; the ready-checkpoint control in `reproduction.2026-11-03T11-56.md`; code reading in research Q3 and Q5 showing the removal gates and the receipt verifier (`Test-PrAuthorReceiptVerification`) do not require a checkpoint.
- Affected components/modules (paths, services, pipelines):
  - `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (`Invoke-OrchestrationPreimplementationGateDecision`, `Test-ImplementationPath`, `Test-ImplementationCommand`).
  - `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (`Get-PrAuthorBypassReason`) and `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (`Get-PrAuthorDocsOnlyExemption`).
  - `.claude/hooks/enforce-model-routing-receipt.ps1` (`Invoke-ModelRoutingReceiptDecision`).
  - `.codex/hooks/codex-pretooluse-file-mapping.ps1` (`ConvertTo-CodexFileEditInput`), whose mapping drops Write `content`.
  - `.claude/skills/cleanup-merged-worktrees/SKILL.md` and the execution-environment brief.

## Proposed Fix

### Design summary (what changes where):

Approach A of the research (allow-side legs at existing final deny points). Each new leg is evaluated only where current code would deny, and every existing deny path, ordering, and wording is preserved when the leg does not apply.

1. New shared pure file `hook-cleanup-context.ps1` at `.claude/hooks/` and `.codex/hooks/` and both bundles, byte-identical. Contents: the branch constant `documentationandmemories`; the manifest relative path `artifacts/orchestration/cleanup-worktrees-manifest.json`; `Test-CleanupManifestText -Raw [-UtcNow]`; `Test-CleanupConsolidationRelativePath` (allowlist); `Find-CleanupConsolidationRecord` (porcelain records to the consolidation record); `Test-CleanupScratchPath` (scratch rule, all roots supplied as inputs). Functions only, no I/O.
2. New sibling `enforce-orchestration-preimplementation-gate-cleanup.ps1` (Claude and Codex, byte-identical, plus bundles) exposing `Test-OrchestrationCleanupContextAllowed -FilePath -Content -Command`, composing the four legs over `Get-OrchestrationGateWorktreeList`, `Get-OrchestrationCommandTarget`, the helpers parser, an injectable temporary-root seam, and an injectable staged-index seam built on `Invoke-DocsOnlyGitExe`. Each gate file gains one guarded dot-source and one call immediately before its final `PREIMPLEMENTATION_GATE_BLOCKED` return. The Codex entry tail forwards Write `content` to the decision.
3. New sibling `.claude/hooks/enforce-pr-author-skill.cleanup.ps1`, dot-sourced from `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, defining a wrapper with the signature of `Get-PrAuthorDocsOnlyExemption` that evaluates the docs-only exemption first, unchanged, then the cleanup exemption (K1 to K6 below). `Get-PrAuthorBypassReason` calls the wrapper through a line-neutral edit. Receipt checks are unchanged and still run after the exemption.
4. `enforce-model-routing-receipt.ps1`: one cleanup allow for `subagent_type` `pr-author`, placed immediately before the final deny.
5. Skill text and execution-environment brief updates (decision 9 below).

Decisions recorded as decided (not open questions):

- D1 No `run_id` binding. No PR-side carrier for a run identifier exists. The cleanup PR readiness check requires a fresh valid manifest (`tool` `cleanup-merged-worktrees`, `schema_version` 1, `generated_at` parseable, not in the future, within 24 hours, non-empty `run_id`), a head branch exactly `documentationandmemories` supplied through an explicit `--head`, exactly one `--base main`, and a branch diff limited to the allowlist.
- D2 Allowlist: exactly the repository-relative prefixes `docs/` and `.claude/agent-memory/`, compared ordinal and case-sensitive. `**/*.md` elsewhere is not admitted. Operands must match the plain character set `A-Z a-z 0-9 . _ / -`, be relative, and carry no `..` segment. In the Write/Edit leg inside the consolidation worktree only, `artifacts/pr_body_<digits>.receipt.json` is also admitted; it never enters the staging allowlist.
- D3 Scratch rule: a Write or Edit to an absolute local path outside every registered worktree, outside the session root, and under the operating-system temporary root is allowed for every session. Measured fact: `[System.IO.Path]::GetTempPath()` returns the long-name spelling, while the session scratchpad path handed to the Write tool uses the 8.3 short-name spelling. The rule must accept both spellings of the temporary root. The planner chooses the mechanism behind an injectable seam.
- D4 Manifest Write is allowed only at the session-root spelling of `artifacts/orchestration/cleanup-worktrees-manifest.json` and only when the Write content validates (`tool` and `schema_version`). Edit of the manifest, and Codex `apply_patch` Update, Delete, or Move of it, stays denied without a checkpoint.
- D5 Consolidation worktree identity is the porcelain branch exactly `documentationandmemories` (never the path, which `CLEANUP_WT_CONSOLIDATION_PATH` can override), reached through `git -C <consolidation root>`. `git add` accepts only allowlisted operands. `git commit` accepts only `-m`, `--message`, `-F`, `--file`, `--trailer` and zero pathspecs, and the staged index, read through a bounded git seam, must be non-empty and entirely allowlisted.
- D6 The PR leg covers three gates: `enforce-pr-author-skill` (new cleanup exemption after the docs-only exemption, receipt checks unchanged), `enforce-model-routing-receipt` (allow `Agent(pr-author)` carrying `branch: documentationandmemories` when the resolved worktree has no checkpoint and a fresh valid manifest exists), and the preimplementation gate (the receipt Write in D2).
- D7 Codex mirrors only the preimplementation-gate legs. The Codex entry tail must forward Write `content` for the manifest leg.
- D8 No change to the excluded files listed under Scope; the removal step already works once the manifest exists. `jq` availability for `--preserve` is out of scope.
- D9 Skill text: `.claude/skills/cleanup-merged-worktrees/SKILL.md` `## End-to-End Workflow` steps 3 and 4 and `## Sanctioned Removal Manifest` name the cleanup context and remove the per-feature `--require-pr-creation-ready` requirement for consolidation PRs. `mcp__drm-copilot__collect_pr_context` runs with `workspace_root` set to the consolidation worktree, so `artifacts/pr_context.summary.txt` exists beneath it. The execution-environment brief changes in all of its byte-identical copies.
- D10 PowerShell only for hooks and libraries. New logic goes in new sibling files because several files are at pinned 500-line caps (research Q7).
- D11 No relaxation outside the cleanup context: feature work without a checkpoint is denied exactly as today, with unchanged deny wording.

### Boundaries and invariants to preserve:

- Ordering: in the preimplementation gate, the epic-scope decision, the delegation-mode branch, and the unresolved-target and ambiguous-resolution denies of `Read-OrchestrationGateCheckpoint` all precede the cleanup leg unchanged; the leg runs after `Test-OrchestrationReady` fails and immediately before the final deny. In the PR-author gate, the cleanup exemption runs after `Invoke-OrchestratorStatePreflight` errors and after the docs-only exemption fails. In the model-routing gate, the cleanup allow runs immediately before the final deny.
- Pure prefilters run before any process: the manifest leg compares the path literal and validates content with no listing; the consolidation Write/Edit leg first requires a `/docs/`, `/.claude/agent-memory/`, or `/artifacts/pr_body_<digits>.receipt.json` tail; the command leg first requires every segment to be `git add` or `git commit` with a `-C` value. The listing seam is called only after a prefilter passes, and the staged-index seam only after the branch matches.
- Fail closed on: listing failure or empty listing; ambiguous resolution; any unresolved `Get-OrchestrationCommandTarget` result; `Test-OrchestrationCommandTextUnresolvable` true; any chained segment that is not itself a recognized cleanup staging invocation (issue #539 all-segments rule); a segment without `-C` unless the session root itself is the consolidation worktree; a matching record that is prunable, detached, or the main worktree stanza.
- Deny wording: unchanged `PREIMPLEMENTATION_GATE_BLOCKED`, `MODEL_ROUTING_RECEIPT_BLOCKED`, and `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` text when the cleanup leg does not apply. A cleanup-specific sub-code may be appended only when the target is the consolidation worktree.
- Byte-identity: the helpers and targets files stay byte-untouched; `hook-cleanup-context.ps1` and the gate-cleanup sibling are byte-identical across their copies.
- The docs-only exemption (issue 901) behavior is unchanged; `Get-DocsOnlyPathViolation` is not widened, so the epic merge gate on both runtimes is unaffected.

### Dependencies or blocked work:

- Isolated subagents execute `main`'s hook copies (execution-environment brief, Hook Execution Context), so the live workflow cannot be exercised until this change merges. The live post-merge run is a manual validation, not CI.
- The pr-author skill already requires non-isolated delegation and an absolute body path in the coordinator-session topology (`.claude/skills/pr-author/SKILL.md`, Coordinator-Session Topology); the PR leg relies on it.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:

- New: `.claude/hooks/hook-cleanup-context.ps1`, `.codex/hooks/hook-cleanup-context.ps1`, and bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.
- New: `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`, and bundle copies.
- New: `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` and bundle copy.
- Changed: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (guarded dot-source and one call; Codex entry tail forwards Write `content`), with bundle copies.
- Changed: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` (guarded dot-source of the new sibling) and `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (line-neutral call replacement in `Get-PrAuthorBypassReason`), with bundle copies.
- Changed: `.claude/hooks/enforce-model-routing-receipt.ps1`, with bundle copy.
- Changed: `.claude/skills/cleanup-merged-worktrees/SKILL.md`, with bundle copy.
- Changed: the execution-environment brief in every copy: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the bundle copies under `claude-customizations/.claude/skills/`, `codex-and-agents-customizations/.agents/skills/`, and `customizations/.github/skills/`.
- Changed: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (new `.claude` files, by hand); `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (new Codex files, through `scripts/dev_tools/generate_codex_agent_variants.py`).
- Changed if required: `config/poshqc-coverage.json` so the new production files are in the coverage population; the shared baseline test helper (`EpicStateIsolation.Baseline.Helpers.ps1`) to register the new seams; `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` only in its `SharedModuleNames` list.

#### Functions/classes/CLI commands impacted:

- New pure functions: `Test-CleanupManifestText`, `Test-CleanupConsolidationRelativePath`, `Find-CleanupConsolidationRecord`, `Test-CleanupScratchPath`.
- New composing function: `Test-OrchestrationCleanupContextAllowed`; new seams for the temporary root (proposed `Get-OrchestrationGateTemporaryRoot`) and the staged index.
- New PR-author wrapper (name chosen by the planner) and cleanup exemption checks K1 to K6:
  - K1 structural `gh pr create` (an edit is not exempt).
  - K2 no checkpoint at the resolved path (`Test-PrAuthorDocsOnlyCheckpointPresence`).
  - K3 explicit `--head` ordinal-equal to `documentationandmemories`; the current-branch fallback (`Resolve-PrAuthorCurrentBranchTarget`) is not used.
  - K4 exactly one explicit `--base`, equal to `main`, with no base or repository override (`Get-PrAuthorDocsOnlyBaseName`).
  - K5 fresh, valid manifest at the session root, read through `Get-CleanupWorktreeManifestContent`.
  - K6 `refs/remotes/origin/main` resolves and `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <commit>...HEAD` in the resolved root exits 0, is NUL-terminated, lists at least one path, and every path is allowlisted; git runs only through `Invoke-PrAuthorDocsOnlyGitExe` and names are split with `ConvertFrom-DocsOnlyNameList`.
- Changed: `Invoke-OrchestrationPreimplementationGateDecision` (both runtimes), `Get-PrAuthorBypassReason`, `Invoke-ModelRoutingReceiptDecision`, the Codex entry tail mapping of Write records.
- Unchanged and relied on: `Test-PrAuthorReceiptVerification`, `Test-CleanupWorktreeManifestAuthorizesRemoval`, `Get-ParallelWorktreeRemovalTargetDenial`, `Get-EpicWorktreeRemovalTargetDenial`, `Resolve-HookTargetWorktree`, `ConvertFrom-HookTargetWorktreePorcelain`, `Get-HookTargetWorktreeEnclosingRoot`.

#### Data flow and validation changes:

- Manifest Write: path equals the session-root spelling of the manifest relative path; `content` parses as a JSON object with `tool` ordinal-equal to `cleanup-merged-worktrees` and integer `schema_version` 1. Any other content, an Edit, or a Codex patch other than a single `*** Add File:` marker naming the manifest (content taken from its `+` lines) is not admitted.
- Scratch Write/Edit: absolute local path (no match for `$script:OrchestrationTargetNonLocalPattern`, no `.` or `..` segment); listing succeeded with at least one record; `Get-HookTargetWorktreeEnclosingRoot` returns `$null` over all records including prunable ones; not under the session root; under the temporary root in either its long-name or 8.3 short-name spelling, compared after normalization with OrdinalIgnoreCase.
- Consolidation Write/Edit: the enclosing registered worktree is the consolidation record (D5) and the relative path is allowlisted (D2), or is `artifacts/pr_body_<digits>.receipt.json`.
- Consolidation `git add`: every segment is `git -C <consolidation root> add`, no option other than `--`, at least one operand, every operand allowlisted.
- Consolidation `git commit`: every segment is `git -C <consolidation root> commit` with only the D5 options and zero pathspecs; staged index read as `git -C <root> diff --cached --name-only -z --no-renames --no-color --no-ext-diff --no-relative` through `Invoke-DocsOnlyGitExe`; empty, non-NUL-terminated, failed, or any non-allowlisted path denies. This is required because `--preserve` stages files through script-internal git calls no hook observes.
- Model-routing allow: `subagent_type` is `pr-author`; prompt `branch:` label ordinal-equal to `documentationandmemories`; checkpoint `$null` at the resolved worktree; K5 holds.

#### Error handling and logging updates:

- No new deny text outside the cleanup context. Within it, a sub-code naming the first failed condition is appended to the existing reason so the operator can see why the cleanup leg did not apply (for example the K-check sub-codes appended to `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`).
- All git seams are bounded and never throw; a seam failure is a deny.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the change set; because each leg is additive and allow-side only, reverting restores the current deny behavior exactly.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Hook payloads are unchanged in shape. Claude Write `tool_input` carries `file_path` and `content`; Edit carries `file_path`, `old_string`, `new_string`. Codex Write records gain forwarded `content` in the decision input.
- Manifest schema is the existing `## Sanctioned Removal Manifest` schema; no field is added.
- Receipt schema (`skill`, `pr_body_path`, `number`, `sha256`, `context_summary_path`, `created_at`) is unchanged.

#### Required configuration keys and defaults:

- Branch constant `documentationandmemories`, restated in `hook-cleanup-context.ps1` and pinned by test equal to `CLEANUP_WT_CONSOLIDATION_BRANCH` in `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh`.
- Manifest tool, schema version, and 24-hour freshness bound restated in `hook-cleanup-context.ps1` and pinned by test equal to `$script:ExpectedManifestTool`, `$script:ExpectedManifestSchemaVersion`, and `$script:ManifestFreshnessBound` in `CleanupWorktreeManifest.psm1`.
- Temporary root default from `[System.IO.Path]::GetTempPath()` plus its 8.3 short-name spelling, supplied through an injectable seam.

#### Backward-compatibility expectations:

- Every existing Pester suite for the preimplementation, PR-author, model-routing, manifest, removal, resolver, and docs-only components passes without edits to expected strings, and does not start a real `git` process through the new legs.
- Feature work without a checkpoint is denied exactly as today.

#### Performance constraints (latency/throughput/memory):

- No process is started by a new leg unless its pure prefilter passes. The cleanup command leg starts at most the existing listing process plus one bounded staged-index git process; the PR leg uses the existing bounded docs-only git seam.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the cleanup skill runs from the main checkout, so the session root holds the manifest; the consolidation worktree is registered on branch `documentationandmemories`; pr-author is delegated non-isolated with an absolute body path.
- Constraints (budget, performance, compatibility): file-size caps pinned by tests: `enforce-pr-author-skill-helpers.ps1` by `session-root-reads-850.Constraints.Tests.ps1` (edit must be line-neutral), the Codex gate by `legacy-codex-hook-contracts.Tests.ps1`; repository hard block above 800 lines. Existing suites near 500 lines (`enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, the Codex `-epic-scope.Tests.ps1`) are not extended. Linux CI runs the hook suites case-sensitively: fixtures use forward slashes and POSIX roots, the temporary root comes from its seam, and no test reads gitignored `artifacts/` state or `origin/main`. No temporary files in tests.
- External dependencies (services, libraries, releases): Pester 5, PoshQC coverage through `config/poshqc-coverage.json`; no new dependency.

## Data / API / Config Impact
- User-facing or API changes: the cleanup skill workflow becomes executable from the agent; hook decisions change only inside the cleanup context and for scratch writes under the temporary root.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): cleanup-specific deny sub-codes inside the cleanup context only.
- Compatibility notes (CLI flags, config schemas, versioning): new hook files enter both pack manifests; push-down consumers receive them through the bundle. In this repository `.claude/agent-memory/` is gitignored and `git ls-files -- .claude/agent-memory` lists no file, so that prefix admits only tracked files; it is retained for consumer repositories.

## Test Strategy
- Regression tests to add or update (all Pester; new files under the mirrored `tests/` tree):
  - `tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1`: pure functions, every fail-closed branch.
  - `tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1`: byte-identity of every copy of `hook-cleanup-context.ps1` and of `enforce-orchestration-preimplementation-gate-cleanup.ps1`, and literal pinning against `CleanupWorktreeManifest.psm1` and `cleanup_worktrees_actions_lib.sh`.
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1`: Claude gate legs.
  - `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1`: Codex gate legs, including `apply_patch` and the entry-tail `content` forwarding.
  - `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1`: K1 to K6 and the wrapper ordering.
  - `tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1`: pr-author cleanup allow.
  - `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`: composed suite, one `Context` per workflow step, each loading only the hook under test, with no checkpoint and every checkpoint seam returning nothing.
  - `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1`: skill and brief text assertions.
- Unit tests (Pester) for the fixed behavior and boundaries: each allow leg paired with the same command or path against a non-consolidation worktree, against the session root, and with no ready checkpoint, asserting the unchanged deny text.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): wrong `tool`; non-integer or wrong `schema_version`; manifest at a non-session-root spelling; manifest Edit; Codex Update/Delete/Move patch; `generated_at` unparseable, in the future, or older than 24 hours; empty `run_id`; `**/*.md` outside the allowlist (for example `CLAUDE.md`, `.claude/rules/*.md`); case variants of the prefixes and branch; `..` segments and characters outside the operand set; `git add -A`, `-f`, missing `-C`, `-C` with a backslash; commit with `-a`, `--amend`, `--pathspec-from-file`, or a pathspec; empty, failed, or non-NUL-terminated staged index; chained segments with a non-cleanup segment; prunable, detached, or main-stanza consolidation record; listing failure; scratch path in either temporary-root spelling, inside a registered worktree spelled in 8.3 form, inside the session root, UNC or drive-relative; `--head` absent, a different branch, or current-branch fallback only; `--base` repeated, absent, or not `main`; diff empty or containing a non-allowlisted path.
- Error handling and logging verification: assert exact existing deny strings outside the cleanup context and the appended sub-code inside it.
- Coverage impact and targets for changed lines/modules: line coverage at or above 85% for each new PowerShell production file, read per file from `artifacts/pester/powershell-coverage.xml` (PoshQC MCP results carry no output). No branch-coverage gate applies to PowerShell. Changed lines in existing files must not reduce coverage.
- Isolation: mock `Get-OrchestrationGateWorktreeList`, the temporary-root seam, and the staged-index seam in every new suite and register them in the shared baseline helper; run seeded shuffled, single-process, and concurrent-shard Pester checks.
- Toolchain commands to run (format → lint → type-check → test): `Invoke-Formatter` and PSScriptAnalyzer through PoshQC; no type-check stage for PowerShell; Pester through `Invoke-PoshQCTest`; push-down contract tests (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_execution_environment_brief_contracts.py`); `scripts/dev_tools/generate_codex_agent_variants.py --check`; `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`; `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
- Manual validation steps (if required): after merge, run the full cleanup workflow live from a main session with no `orchestrator-state.json` (report, manifest, preserve, commit, push, pr-author delegation, receipt write, PR create, apply, manifest-authorized removal) with no shell-escape steps, and record the result as a separate manual validation artifact under `evidence/`. This live run is a manual validation, not CI, because isolated subagents execute `main`'s hook copies.

## Acceptance Criteria

Numeric counts of copies or members are intentionally not asserted below: the research record states that no numeric derivation was performed, so copy sets are referenced through the tests that enumerate them.

- [x] `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` passes a test named `allows a Write of the session-root cleanup manifest with valid tool and schema_version and no checkpoint`, and tests named `denies a manifest Write whose tool is not cleanup-merged-worktrees`, `denies a manifest Write whose schema_version is not 1`, `denies a manifest Write at a path other than the session-root spelling`, and `denies an Edit of the cleanup manifest without a checkpoint`, each asserting the unchanged `PREIMPLEMENTATION_GATE_BLOCKED` text.
- [x] The same suite passes tests named `allows git -C <consolidation root> add of docs/ and .claude/agent-memory/ operands` and `denies git add in the consolidation worktree when any operand is outside the allowlist`, covering a `scripts/` operand, a root-level `.md` operand, `-A`, `-f`, and a missing `-C`.
- [x] The same suite passes tests named `allows git -C <consolidation root> commit -F when the staged index is non-empty and entirely allowlisted`, `denies the commit when the staged index holds a non-allowlisted path`, `denies the commit when the staged index is empty or the staged-index seam fails`, and `denies the commit with -a, --amend, --pathspec-from-file, or a pathspec operand`.
- [x] The same suite passes a test named `identifies the consolidation worktree by porcelain branch documentationandmemories and not by path`, with deny cases for a prunable, detached, or main-stanza record and for a consolidation path whose branch differs.
- [x] The same suite passes tests named `allows a Write under the temporary root in its long-name spelling outside every worktree and the session root`, `allows a Write under the temporary root in its 8.3 short-name spelling`, and `denies a scratch-named Write inside a registered worktree, inside the session root, or at a non-local path`, with the temporary root supplied through its injectable seam.
- [x] The same suite passes tests named `allows the pr-author receipt Write of artifacts/pr_body_<digits>.receipt.json beneath the consolidation worktree` and `denies the same receipt path beneath a non-consolidation worktree`.
- [x] `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` passes a test named `allows gh pr create --head documentationandmemories --base main with no checkpoint, a fresh valid manifest, and an allowlisted diff`, and tests named for each failed condition K1 to K6 (edit instead of create, checkpoint present, absent or different `--head`, repeated or non-`main` `--base`, missing or stale or future or invalid manifest or empty `run_id`, empty or non-allowlisted diff), each returning `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` with its sub-code.
- [x] The same suite passes tests named `still requires the orchestrator preflight for a non-consolidation PR with no checkpoint`, `evaluates the docs-only exemption before the cleanup exemption with unchanged results`, and `runs the receipt checks unchanged after the cleanup exemption`.
- [x] `tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1` passes a test named `allows Agent(pr-author) with branch: documentationandmemories when the resolved worktree has no checkpoint and a fresh valid manifest exists`, and tests named `denies the delegation when the manifest is absent or invalid`, `denies a non-pr-author subagent under the same conditions`, and `denies a different branch label`, each asserting the unchanged `MODEL_ROUTING_RECEIPT_BLOCKED` text.
- [x] `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` passes the Codex equivalents of the manifest, scratch, consolidation Write/Edit, receipt, `git add`, and `git commit` cases, plus tests named `allows an apply_patch Add File of the manifest with valid content`, `denies an apply_patch Update, Delete, or Move of the manifest`, and `forwards Write content from the Codex entry tail to the decision`.
- [ ] `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` and `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1` pass unchanged, and the end-to-end suite asserts that a manifest-authorized `git worktree remove <SAFE_TO_DELETE path>` is allowed by `enforce-parallel-worktree-removal-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1` with no checkpoint.
- [ ] `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` passes, composing over one in-memory scenario with no `orchestrator-state.json` a `Context` for each step: report, manifest Write, `--preserve`, `git commit`, `git push`, `Agent(pr-author)` delegation, receipt Write, `gh pr create`, `--apply`, and manifest-authorized removal, each allowed by every hook registered for that tool call.
- [ ] Each new cleanup suite includes, for every allow case, the same command or path against a non-consolidation worktree and against the session root with no ready checkpoint, asserting the deny text that the gate returns today; and the existing preimplementation, PR-author, model-routing, manifest, removal, resolver, and docs-only Pester suites pass without changes to their expected strings.
- [x] `tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1` passes, covering every fail-closed branch of `Test-CleanupManifestText`, `Test-CleanupConsolidationRelativePath`, `Find-CleanupConsolidationRecord`, and `Test-CleanupScratchPath`, including case-sensitivity of the allowlist prefixes and rejection of `**/*.md` paths outside `docs/` and `.claude/agent-memory/`.
- [ ] `tests/scripts/claude-hooks/hook-cleanup-context.Parity.Tests.ps1` passes, asserting byte-identity of every repository and bundle copy of `hook-cleanup-context.ps1` and of `enforce-orchestration-preimplementation-gate-cleanup.ps1`, and equality of the restated literals with the `CleanupWorktreeManifest.psm1` constants and `CLEANUP_WT_CONSOLIDATION_BRANCH`.
- [ ] `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` passes, asserting that `.claude/skills/cleanup-merged-worktrees/SKILL.md` `## End-to-End Workflow` steps 3 and 4 and `## Sanctioned Removal Manifest` name the cleanup context, the session-root manifest location, `git -C <consolidation root>` staging with `git commit -F`, explicit `--head documentationandmemories --base main`, `collect_pr_context` with `workspace_root` set to the consolidation worktree, and the unsupported manifest Edit, and no longer require `--require-pr-creation-ready` for consolidation PRs; and that the execution-environment brief states the cleanup legs and the scratch rule.
- [ ] `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` passes, confirming every copy of the execution-environment brief remains byte-identical after the change.
- [ ] The push-down contract tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`), `scripts/dev_tools/generate_codex_agent_variants.py --check`, the preimplementation helpers and targets Parity suites, `legacy-codex-hook-contracts.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1` pass.
- [ ] Each new PowerShell production file reports line coverage at or above 85% in `artifacts/pester/powershell-coverage.xml`, and no changed line in an existing production file reduces coverage.
- [ ] `session-root-reads-850.Constraints.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` pass with their line caps unchanged, and no changed or new file exceeds the repository file-size hard block.
- [ ] No new Python file is added and no hook invokes Python; all new hook and library logic is PowerShell.

## Risks & Mitigations
- Technical or operational risks:
  - A leg allows outside the cleanup context (for example a commit in a feature worktree with no checkpoint).
  - Unmocked listing or staged-index seams start a real `git` process in existing suites, producing machine-dependent results.
  - Mirror or pack-manifest drift between repository and bundle copies.
  - Linux-only failures from Windows-shaped fixtures.
  - Scratch rule exempting a worktree file spelled in 8.3 short-name form.
- Mitigations and rollbacks: paired deny tests for every allow case; pure prefilters before any process and seam registration in the shared baseline helper; parity suites and push-down contract tests; POSIX fixtures with seam-supplied roots; the scratch rule requires both no enclosing registered worktree and a temporary-root prefix. Rollback is a revert; legs are additive.

## Rollout & Follow-up
- Release/rollout steps: merge; rebuild and reinstall the extension so push-down serves the updated bundle; run the live manual validation described under Test Strategy and record it under `evidence/`.
- Post-fix monitoring or clean-up tasks: confirm on the first live cleanup run that `artifacts/pr_context.summary.txt` is produced beneath the consolidation worktree when `collect_pr_context` receives that `workspace_root`; confirm `--preserve` behavior on the operator host separately from this change (`jq` is out of scope).
- Links: issue #1026; research `research/research.2026-11-03T12-06.md`; reproductions `evidence/regression-testing/reproduction.2026-11-03T11-56.md` and `evidence/regression-testing/reproduction-pr-leg.2026-11-03T12-12.md`; related #1009, #1010, #1011, and the separately filed `--preserve` `modified`-record defect.
