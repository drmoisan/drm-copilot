# 2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt (Spec)

- **Issue:** #1182
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the only acceptance-criteria source; no `user-story.md`)
- **Research:** `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182/research/research.2026-11-14T10-43.md`

## Context

At Run Closing, the parallel-orchestrator cannot open the run-records pull request. Its `Agent(pr-author)` delegation is denied by `.claude/hooks/enforce-model-routing-receipt.ps1` with `MODEL_ROUTING_RECEIPT_BLOCKED`. The receipt check reads the per-feature orchestrator checkpoint beneath the resolved worktree. The coordinator root of a parallel run deliberately holds only `artifacts/orchestration/parallel-orchestrator-state.json` and no per-feature checkpoint (issue #673 hygiene), so the receipt can never be found. The `parallel-orchestrator` agent definition authorizes `Agent(pr-author)` for exactly this Run Closing records pull request, so the documented procedure cannot be completed.

Environment:
- OS/version: Windows 11 (local), Claude Code runtime; CI runs the hook suites on Linux.
- Python version: not applicable (no Python production change).
- Command/flags used: parallel-orchestrator Run Closing: `Agent(pr-author)` with the branch label `parallel/<slug>-plan`.
- Data source or fixture: run `harness-learnings-2026-11-09`, coordinator branch `parallel/harness-learnings-2026-11-09-plan` (head c295f89d1), closing state recorded as deferral LV3.

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Repro & Evidence

Steps to Reproduce:
1. Run a parallel run to completion, so that every non-withdrawn item is merged.
2. At Run Closing, delegate `Agent(pr-author)` from the parallel-orchestrator for the records pull request of the `parallel/<slug>-plan` branch.
3. Observe the denial: `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint`.

Expected:
The Run Closing records pull request is delegable when the parallel checkpoint records a valid pr-author routing receipt, and the pr-author agent can write its integrity receipt at the coordinator root.

Actual:
The delegation is denied, and the run ends with its records unmerged on the coordinator branch. The post-merge worktree cleanup report is also deferred, because it runs only after the records pull request merges.

Logs / Screenshots:
- Snippet: `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry for it is recorded in the orchestrator checkpoint. Perform Model Selection (record the complexity assessment and routing receipt) before delegating.`

Second block (found by research, not named in the issue; verified by code reading in this spec, to be demonstrated by a fail-before test): after the delegation, the pr-author agent's `Write` of `artifacts/pr_body_<N>.receipt.json` at the coordinator root is denied by `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`. `Test-ImplementationPath` classifies the path as implementation because it ends in `.json`; the coordinator root has no ready per-feature checkpoint; the cleanup leg (#1026) requires the consolidation context; the docs-estate leg (#1169) declines because `parallel-orchestrator-state.json` is one of its blocking checkpoint paths. The final deny is `PREIMPLEMENTATION_GATE_BLOCKED`. The `Write` of `artifacts/pr_body_<N>.md` is not affected: `.md` is not an implementation extension, so `Test-ImplementationPath` returns false and the gate allows it today.

## Scope & Non-Goals

- In scope:
  - A parallel records leg in the Claude model-routing receipt gate, for `Agent(pr-author)` only.
  - A parallel records leg in the Claude preimplementation gate, for the pr-author `Write` of `artifacts/pr_body_<N>.receipt.json` at the coordinator root only.
  - One shared pure-predicate helper used by both legs.
  - Documentation: the `parallel-orchestrate` skill Run Closing and `## Parallel-Level Checkpoint`, the `parallel-orchestrator` agent Run Closing, `.claude/rules/parallel-orchestration.md`, and every byte-identical copy of the execution-environment brief.
  - Bundle mirrors under `extensions/drm-copilot/resources/` and `pack-manifests/core.json` entries for every new or changed `.claude/`, `.agents/`, or `.github/` file.
  - Pester suites for the new legs and the shared helper, an end-to-end composition suite, and regression rows.
- Out of scope / non-goals:
  - The pr-author command gate (`.claude/hooks/enforce-pr-author-skill.ps1` and its siblings). Research finding 3: it already admits `gh pr create --head parallel/<slug>-plan --base main --body-file artifacts/pr_body_<N>.md` from the coordinator root through the docs-only exemption of issue #901 (`Get-PrAuthorDocsOnlyExemption`).
  - The merge gate (`.claude/hooks/enforce-epic-merge-gate.ps1` and its siblings, `hook-docs-only-diff.ps1`). Research finding 4: it already admits `gh pr merge <PR> --merge` for the records pull request through the docs-only branch of issue #927 (`Get-DocsOnlyMergeExemption`). Its parallel branch `Test-ParallelCheckpointAllowsMerge` must not be made to apply.
  - Every Codex hook and Codex surface under `.codex/` and its bundle mirror. Research finding 5: Codex has no parallel-orchestrator agent, no model-routing receipt gate twin, and no pr-author command gate twin. The Codex preimplementation gate is at its 500-line cap.
  - The byte-identical multi-surface files `enforce-orchestration-preimplementation-gate-docs.ps1` and `hook-docs-estate-context.ps1` (byte-identical across surfaces), `enforce-model-routing-receipt-docs.ps1`, and `hook-cleanup-context.ps1`.
  - `.claude/settings.json` and `.claude/hooks/pretooluse-dispatch.json` (the new logic is dot-sourced by already registered hooks).
  - Any Python production file, including the parallel and orchestrator-state validators. The parallel validators already tolerate unknown top-level keys.
  - Recording the records pull request number in `items[]` of the parallel checkpoint (doing so would make the merge gate's parallel target resolve and skip the docs-only branch).
- Explicitly excluded systems, integrations, or datasets: Copilot (`.github/`) and Codex (`.agents/`) runtime behaviour; only the execution-environment brief text changes there.

## Root Cause Analysis

`Invoke-ModelRoutingReceiptDecision` in `.claude/hooks/enforce-model-routing-receipt.ps1` evaluates, in order: epic scope (`Resolve-EpicScopeCheckpoint`, issue #663), item resolution (`Get-ModelRoutingTargetCheckpointResolution`), the per-feature receipt (`Get-ModelRoutingCheckpoint`, `Test-ModelRoutingReceiptPresent`), the cleanup leg (`Test-ModelRoutingCleanupDelegation`, issue #1026), the docs-estate leg (`Get-ModelRoutingDocsEstateDecision`, issue #1169), and the generic deny. For a prompt carrying `branch: parallel/<slug>-plan`, epic scope declines (no epic checkpoint records that branch); item resolution resolves the single live worktree with that branch checked out, which is the coordinator root; no per-feature checkpoint exists there, so `$checkpoint` is `$null`; the cleanup leg declines on the label; the docs-estate leg declines with an empty suffix (no docs profile). There is no leg that reads the parallel checkpoint, so the generic deny is returned. This was confirmed by reading the hook (lines 330-391 of the current file).

The preimplementation gate has the same structural gap for the receipt `Write`: its single-feature deny tail (`Invoke-OrchestrationPreimplementationGateDecision`, after `Test-OrchestrationReady` fails) has cleanup, bookkeeping, and docs-estate legs, and none of them covers a parallel coordinator root.

The skill and agent text also contribute: `### Run Closing` substep 3 instructs the delegation but never states where or how the pr-author routing receipt is recorded, whereas the epic skill records it in the epic checkpoint's `model_routing_receipts[]` (issue #663).

## Proposed Fix

### Design summary (what changes where):

Decisions taken in autonomous mode (owner directive OD-1), with rationale:

- D1. Parallel records leg in the model-routing gate (Claude only). Rationale: mirrors the receipt location of the epic precedent (#663) and the leg shape of the cleanup (#1026) and docs-estate (#1169) precedents; keeps a model-selection record instead of a label-only bypass (research approach B rejected); does not write a per-feature checkpoint at the coordinator root (research approach C rejected because it violates #673 hygiene and would disable the pr-author docs-only exemption).
- D2. Parallel records leg in the Claude preimplementation gate, scoped to `artifacts/pr_body_<digits>.receipt.json` only. Rationale: the body `.md` Write is already allowed; admitting only what is denied keeps the leg minimal.
- D3. One shared pure-predicate helper file used by both legs, plus one thin sibling per gate. Rationale: one implementation of the checkpoint predicates; neither existing hook grows past the 500-line guidance tier; the receipt validity check reuses the existing PowerShell port `Get-OrchestratorStateModelRoutingReceiptError` (`.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1`), which calls `Resolve-DelegationModel` in `.claude/lib/model-routing/ModelRouting.psm1`, so no model formula is re-implemented and no hook invokes Python.
- D4. No change to the pr-author command gate, the merge gate, or any Codex hook (see Non-Goals). Rationale: research verified both existing paths admit the records pull request; changing them adds risk without benefit.
- D5. Closing predicate equals parallel invariant 20 (every item whose `state` is not `withdrawn` has `merge_status` in `{merged, worktree_removed}`), which is also the Run Closing entry condition in the skill. The open-mode `close` mutation (invariant 21) is not required, because Run Closing's entry condition does not require it.
- D6. The new checkpoint keys `model_routing_receipts` and `complexity_assessments` are declared in `.claude/rules/parallel-orchestration.md` as optional, tolerated top-level keys of the parallel-orchestrator checkpoint. Rationale: the skill's `## Parallel-Level Checkpoint` forbids undeclared fields; the Python validator and the TypeScript core reject only `depends_on`, `integration_branch`, and `epic_merge_pr`, so no validator change is needed.

### Boundaries and invariants to preserve:

- Every decision that does not reach a new leg is byte-identical to today: allow/deny outcome and deny text. In particular: a resolved per-feature checkpoint, an epic integration-branch label, the cleanup label, a docs-estate root, a `NoTarget` or `Ambiguous` resolution, a gated agent other than `pr-author`, and any branch label that does not match the plan-branch pattern.
- The gate is presence-and-consistency only. It cannot read the `model` the delegation actually uses (the Agent tool input exposes no `model` field), so it checks that the recorded receipt is internally consistent, not that the delegation honours it.
- No literal `orchestrator-state.json` in any string expression of `.claude/hooks/enforce-model-routing-receipt.ps1` (pinned by `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, `It 'the in-scope hook files carry the checkpoint path literal in no string expression'`). The new files compose checkpoint paths only through `Get-WorktreeRunCheckpointPath -Kind parallel|item` (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`) and carry no such literal in a string expression either.
- Every new dot-source and module import uses the guarded pattern `try { ... } catch { Add-HookDependencyFailure -Name '<name>' -ErrorRecord $_ }` checked by `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`; imported modules write nothing to stdout.
- Hooks invoke no Python (`enforcement-hooks-no-python-invocation.Tests.ps1`).
- Both legs are policy-level controls, not security controls; same-session forgery of the checkpoint is possible, as for the epic receipt and the standalone-merge authorization. Each new file header states this.

### Dependencies or blocked work:

- No dependency on other open items. The fix reaches the session root only after it merges and the coordinator branch merges `origin/main` (hooks run from the session-root checkout); see `## Post-Merge Verification`.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

New (Claude only):
- `.claude/hooks/hook-parallel-records-context.ps1` - pure predicates shared by both legs.
- `.claude/hooks/enforce-model-routing-receipt-parallel.ps1` - `Get-ModelRoutingParallelRecordsDecision`.
- `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1` - `Get-OrchestrationParallelRecordsResult`.

Changed:
- `.claude/hooks/enforce-model-routing-receipt.ps1` - guarded imports of `WorktreeRunResolution.psm1` and `OrchestratorStateModelReceipts.psm1` where not already loaded, guarded dot-source of the new sibling, one call site, one `.DESCRIPTION` sentence.
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` - guarded dot-source of the new sibling and one deny-tail call.
- `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/rules/parallel-orchestration.md`.
- Every copy of the execution-environment brief that `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` holds byte-identical. The brief's own `## Purpose and Maintenance` names the copies; the planner enumerates them from that section and from the contract test, not from this spec (the research record's search scope was not repository-exhaustive, so this spec asserts no count).
- Bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/` for every new and changed `.claude/` file, and `pack-manifests/core.json` entries for each new hook file.

The change touches more than the direct-mode limit of production PowerShell files under `.claude/hooks/` plus their bundle copies, so it runs on the orchestrated large path (`enforce-powershell-batch-budget.ps1`).

#### Functions/classes/CLI commands impacted:

Shared helper `hook-parallel-records-context.ps1` (pure; reads no file, starts no process, reads no clock, never throws):
- `Get-ParallelRecordsSlug -BranchName <string>` returns the slug when the value fully matches `^parallel/(?<slug>[A-Za-z0-9][A-Za-z0-9._-]*)-plan$` (case-sensitive), else `$null`.
- `Get-ParallelRecordsCheckpointDecision -CheckpointText <string|null> -Slug <string>` returns `[pscustomobject]@{ Allowed = <bool>; SubCode = <string|null>; Detail = <string> }`, evaluating in order:
  1. Parse: text is non-blank and parses (`ConvertFrom-Json -NoEnumerate`) to a JSON object. Failure: `PARALLEL_RECORDS_CHECKPOINT_UNREADABLE`.
  2. Identity: `route_id` ceq `parallel` and `parallel_slug` ceq `<slug>`. Failure: `PARALLEL_RECORDS_SLUG_MISMATCH` (detail names which field differs and the recorded value).
  3. Closed: `items` is a non-empty list, and every element is an object whose `state` is `withdrawn` or whose `merge_status` is `merged` or `worktree_removed` (an absent `merge_status` reads as `not_started`). Failure: `PARALLEL_RECORDS_RUN_NOT_CLOSED` (detail names the first non-terminal `issue_num` and its `merge_status`).
  4. Receipt present: `model_routing_receipts` is present and holds at least one object whose `agent` ceq `pr-author`. Failure: `PARALLEL_RECORDS_RECEIPT_MISSING`.
  5. Receipt valid: `model_routing_receipts` is a list and at least one `pr-author` entry yields zero errors from `Get-OrchestratorStateModelRoutingReceiptError` applied to a one-element list holding that entry (band in `C1`..`C4`, `model` equals `Resolve-DelegationModel(agent, complexity_band, fable_policy)`, disabled-mode clamp). Failure: `PARALLEL_RECORDS_RECEIPT_INVALID` (detail carries the first error string).

Model-routing sibling `enforce-model-routing-receipt-parallel.ps1`:
- `Get-ModelRoutingParallelRecordsDecision -PromptText <string> -WorktreeRoot <string>` returns `[pscustomobject]@{ Allowed; DenySuffix }` and never throws (any exception answers `Allowed = $false` with an empty suffix). Conditions:
  - P1 label: the prompt has exactly one line matching `(?m)^branch:[ \t]*(\S+)[ \t]*$`, its value yields a slug from `Get-ParallelRecordsSlug`, and `Find-WorktreeResolutionBranchSignal -Text $PromptText` returns the same value. Failure: decline with an empty suffix.
  - P2 root: `WorktreeRoot` is non-blank. Failure: decline with an empty suffix.
  - P3: `Get-ParallelRecordsCheckpointDecision` on `Get-WorktreeRunCheckpointText -Path (Get-WorktreeRunCheckpointPath -Kind parallel -WorktreeRoot $WorktreeRoot)`. Allowed: allow. Otherwise suffix `' Parallel records leg not applied: <SubCode>: <Detail>'`; for `PARALLEL_RECORDS_RECEIPT_MISSING` the detail includes the remedy "record a pr-author entry in model_routing_receipts of the parallel checkpoint before delegating".
- `Invoke-ModelRoutingReceiptDecision`: inside the existing `$subagent -eq 'pr-author' -and $null -eq $checkpoint` region, after the cleanup leg and before the docs-estate leg, call the parallel leg with `$resolution.WorktreeRoot`. On `Allowed` return allow. Otherwise keep its suffix and continue to the docs-estate leg. Final deny text: the unchanged base text, then the parallel suffix, then the docs suffix.

Preimplementation sibling `enforce-orchestration-preimplementation-gate-parallel-records.ps1`:
- `Get-OrchestrationParallelRecordsResult -ToolInput <object> -FilePath <string>` returns `[pscustomobject]@{ Allowed; DenySuffix }` and never throws. Conditions:
  - Q1 shape: the tool input carries `content` and no `old_string` (a `Write` payload), and the path, with `\` normalized to `/`, is either exactly `artifacts/pr_body_<digits>.receipt.json` (case-sensitive) or an absolute path whose path relative to its enclosing registered worktree root (`Get-HookTargetWorktreeEnclosingRoot`, `Get-HookTargetWorktreeRelativePath`) is exactly that. Failure: decline with an empty suffix.
  - Q2 root R: the session root for a relative path; the enclosing registered root for an absolute path. Unresolvable: decline with an empty suffix.
  - Q3: no file exists at `Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot R`. Failure: decline with an empty suffix.
  - Q4: the HEAD branch of R, read through a mockable seam function (an existing seam such as `Get-EpicScopeWorktreeHeadBranch`, or a new wrapper in the sibling), yields a slug from `Get-ParallelRecordsSlug`. Failure: decline with an empty suffix.
  - Q5: `Get-ParallelRecordsCheckpointDecision` on the parallel checkpoint text beneath R. Allowed: allow. Otherwise suffix `' Parallel records leg not applied: <SubCode>: <Detail>'`.
- `Invoke-OrchestrationPreimplementationGateDecision`: after the docs-estate leg (line 429 today) and before the final deny, call the sibling; on `Allowed` return allow; append its suffix after `$docs.DenySuffix` in the final deny text.

#### Data flow and validation changes:

- New producer duty (documentation): before the Run Closing delegation, the parallel-orchestrator records in `artifacts/orchestration/parallel-orchestrator-state.json` one `complexity_assessments[]` entry for the records phase and one `model_routing_receipts[]` entry `{ agent: "pr-author", phase, complexity_band, fable_policy, table_model, clamped_from, model }` with `model` resolved by `Resolve-DelegationModel -Agent pr-author -Band <band> -FablePolicy <run fable_policy>`; it then delegates non-isolated with exactly one `branch: parallel/<slug>-plan` line, no canonical issue line, and `model` equal to the receipt's `model`.
- Consumers: only the new parallel records legs read the parallel checkpoint's `model_routing_receipts`. No validator reads the new keys.

#### Error handling and logging updates:

- New deny sub-codes, each appended after the existing deny token's base text and only once the label/path prefilter matched: `PARALLEL_RECORDS_CHECKPOINT_UNREADABLE`, `PARALLEL_RECORDS_SLUG_MISMATCH`, `PARALLEL_RECORDS_RUN_NOT_CLOSED`, `PARALLEL_RECORDS_RECEIPT_MISSING`, `PARALLEL_RECORDS_RECEIPT_INVALID`.
- Model-routing deny token is unchanged (`MODEL_ROUTING_RECEIPT_BLOCKED:`); preimplementation deny token is unchanged (`PREIMPLEMENTATION_GATE_BLOCKED:`).
- A dependency load failure of a new file fails closed through the existing `Get-HookDependencyFailureDecision` path of each gate.

#### Rollback/feature-flag considerations (if applicable):

- No flag. Rollback is a revert of the change; with the legs removed, behaviour returns to today's denials and Run Closing falls back to deferral LV3.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Inputs: the PreToolUse envelope (`tool_input.subagent_type`, `tool_input.prompt` for Agent; `tool_input.file_path`, `tool_input.content` for Write); the parallel checkpoint text beneath the resolved root.
- Outputs: the existing hook decision JSON (`hookSpecificOutput.permissionDecision` `allow` or `deny`, with `permissionDecisionReason` on deny).

#### Required configuration keys and defaults:

- None. `config/orchestration-routing.json` is read only through the existing pure constants of `ModelRouting.psm1`.

#### Backward-compatibility expectations:

- Every decision outside the new parallel records legs is unchanged (see Boundaries). A parallel checkpoint without the new keys validates exactly as before in the Python and TypeScript validators.

#### Performance constraints (latency/throughput/memory):

- The legs add at most one file read of the parallel checkpoint and, for the preimplementation leg, one HEAD-branch read, and only on a path that would otherwise deny. No new process start on any allow path that exists today.

## Assumptions, Constraints, Dependencies

- Assumptions: the coordinator root has `parallel/<slug>-plan` checked out and is the only live worktree with that branch (otherwise item resolution returns `Ambiguous` or `NoTarget` and denies unchanged); the records prompt carries no canonical issue line (with one, `Resolve-WorktreeItemTargetByBranch` can return `Ambiguous`).
- Constraints: Claude runtime only; no Python production change; no hook invokes Python; no existing changed hook exceeds 500 logical lines; Codex preimplementation gate untouched (500-line cap pinned by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`); tests run parallel only, one suite at a time, no local integration or golden suites; evidence is append-only with clock-read timestamps; no absolute paths in artifacts.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: new allow legs and new `PARALLEL_RECORDS_*` deny sub-codes on existing gates.
- Data or migration considerations: new optional tolerated keys on the parallel-orchestrator checkpoint (`model_routing_receipts`, `complexity_assessments`); no migration.
- Logging/telemetry updates: none beyond the deny text.
- Compatibility notes: Codex and Copilot runtimes unchanged; the execution-environment brief documents the Claude-only leg.

## Test Strategy

Seeded from issue (mapped to acceptance criteria below):

- Parallel-scope resolution with the receipt read from the parallel checkpoint: AC-1 to AC-8.
- pr-author preflight and records-PR merge path end to end: AC-15.
- Pester coverage for allow and deny, non-plan label, missing receipt, epic label unaffected: AC-2 to AC-14.
- Open the pending harness-learnings-2026-11-09 records PR through the fixed path: `## Post-Merge Verification`.

Details:
- Regression tests to add: `tests/scripts/claude-hooks/enforce-model-routing-receipt.ParallelRecords.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1`, `tests/scripts/claude-hooks/hook-parallel-records-context.Tests.ps1`, `tests/scripts/claude-hooks/parallel-records-workflow.EndToEnd.Tests.ps1`.
- Seams: mock `Resolve-ModelRoutingWorktreeTarget`, `Get-ModelRoutingCheckpoint`, `Get-WorktreeRunCheckpointText`, the HEAD-branch seam, and the enclosing-root and session-root seams; register the epic-state baseline mocks (`EpicStateIsolation.Baseline.Helpers.ps1`) so no suite reads the real session-root parallel checkpoint. A hook-scope call to an exported module function is mocked without `-ModuleName`; a call from inside a module needs `-ModuleName`.
- No temporary files; fixtures use forward-slash roots without drive letters and exact file-name case (CI runs on a case-sensitive file system); no test reads gitignored `artifacts/` state.
- Coverage: line coverage >= 85% per new or changed PowerShell file, read from `artifacts/pester/powershell-coverage.xml` of the single parallel gate run (Pester has no branch gate).
- Toolchain: PoshQC format, analyze, test (parallel runner) per `.claude/rules/powershell.md`; Python contract tests through one `pytest -n auto` run; Test Cadence per the `atomic-plan-contract` skill.
- Manual validation: the post-merge records PR (not an acceptance criterion of this PR).

## Acceptance Criteria

Model-routing gate, parallel records leg (`.claude/hooks/enforce-model-routing-receipt.ps1` with `.claude/hooks/enforce-model-routing-receipt-parallel.ps1`):

- [x] AC-1: `Invoke-ModelRoutingReceiptDecision` returns `permissionDecision` `allow` for `subagent_type` `pr-author` when all of these hold: the prompt has exactly one `branch:` line whose value is `parallel/<slug>-plan` and `Find-WorktreeResolutionBranchSignal` returns the same value; item resolution returns `SessionRoot` or `OtherWorktree` with a non-blank root; no per-feature checkpoint is read (`Get-ModelRoutingCheckpoint` returns `$null`); and the parallel checkpoint text beneath that root has `route_id` `parallel`, `parallel_slug` equal to `<slug>`, a non-empty `items` list in which every non-`withdrawn` item has `merge_status` `merged` or `worktree_removed`, and a `model_routing_receipts` entry with `agent` `pr-author` that yields zero errors from `Get-OrchestratorStateModelRoutingReceiptError`. Verified by an `It` row in `enforce-model-routing-receipt.ParallelRecords.Tests.ps1`.
- [x] AC-2: With the AC-1 setup except that `parallel_slug` differs from the label slug, or `route_id` is not `parallel`, the decision is `deny` and the reason starts with the unchanged base text `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to 'pr-author' before a model_routing_receipts entry` and contains ` Parallel records leg not applied: PARALLEL_RECORDS_SLUG_MISMATCH: `. One `It` row per field.
- [x] AC-3: With the AC-1 setup except that one non-`withdrawn` item has `merge_status` `pr_open`, or `ci_green`, or no `merge_status`, or `items` is an empty list, the decision is `deny` with sub-code `PARALLEL_RECORDS_RUN_NOT_CLOSED`. An item with `state` `withdrawn` and `merge_status` `not_started` does not cause this deny (row taken from the shape of run harness-learnings-2026-11-09).
- [x] AC-4: With the AC-1 setup except that `model_routing_receipts` is absent, or holds no entry whose `agent` is `pr-author`, the decision is `deny` with sub-code `PARALLEL_RECORDS_RECEIPT_MISSING`.
- [x] AC-5: With the AC-1 setup except that the only `pr-author` receipt has a `model` that differs from `Resolve-DelegationModel` for its `agent`, `complexity_band`, and `fable_policy`, or a `complexity_band` outside `C1`..`C4`, or `model_routing_receipts` is not a list, the decision is `deny` with sub-code `PARALLEL_RECORDS_RECEIPT_INVALID` and the detail carries the first error string from `Get-OrchestratorStateModelRoutingReceiptError`.
- [x] AC-6: With the AC-1 setup except that the parallel checkpoint text is `$null` (absent), blank, not valid JSON, or a JSON array, the decision is `deny` with sub-code `PARALLEL_RECORDS_CHECKPOINT_UNREADABLE`.
- [x] AC-7: Unchanged behaviour, each verified by an `It` row asserting the exact decision and the exact reason text produced today: (a) a per-feature checkpoint with a pr-author receipt beneath the resolved root decides through the per-feature path and the parallel checkpoint seam is not called (`Should -Invoke Get-WorktreeRunCheckpointText -Times 0`); (b) an epic integration-branch label decides through epic scope; (c) a non-parallel label such as `branch: feature/x` produces deny text byte-identical to today's with no parallel suffix; (d) `branch: parallel/<slug>` without the `-plan` suffix produces today's text with no parallel suffix; (e) a prompt with more than one `branch:` line produces today's text with no parallel suffix; (f) `subagent_type` `atomic-planner` with a valid plan label and a valid parallel checkpoint is denied with today's text and no suffix; (g) `NoTarget` and `Ambiguous` resolutions deny with the resolver code unchanged; (h) the cleanup label and a docs-estate decision keep their current outcome and the docs suffix stays last in the deny text.
- [x] AC-8: When the parallel leg seam throws, `Get-ModelRoutingParallelRecordsDecision` returns `Allowed` `$false` with an empty suffix and the gate returns today's deny text (never-throw row).

Preimplementation gate, parallel records leg (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` with `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1`):

- [x] AC-9: `Invoke-OrchestrationPreimplementationGateDecision` returns `allow` for a `Write` payload (`file_path` and `content`, no `old_string`) whose path is `artifacts/pr_body_<digits>.receipt.json`, relative or absolute beneath R, when no per-feature checkpoint exists beneath R, R's HEAD branch is `parallel/<slug>-plan`, and the parallel checkpoint beneath R satisfies the same identity, closed, and receipt conditions as AC-1. Verified by `It` rows for the relative and the absolute form in `enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1`.
- [x] AC-10: With the AC-9 setup and each failing checkpoint condition of AC-2 to AC-6, the decision is `deny`, the reason starts with today's `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require` text, and the matching ` Parallel records leg not applied: <SUB_CODE>: ` suffix appears after any cleanup, bookkeeping, and docs suffix. One `It` row per sub-code.
- [x] AC-11: Unchanged behaviour, each verified by an `It` row asserting today's decision and text with no parallel suffix: (a) an `Edit` payload (`old_string` present) of the receipt path; (b) a `Write` of any other implementation path beneath R, such as `artifacts/other.json` or `scripts/x.ps1`; (c) a `Write` whose path differs only in case, such as `artifacts/PR_BODY_5.receipt.json`; (d) R's HEAD branch is not a plan branch (for example `main` or `parallel/<slug>`); (e) a per-feature checkpoint exists beneath R; (f) a command payload such as `git add -- docs/features/parallel/<slug>/parallel-status.md`; (g) the `Write` of `artifacts/pr_body_<N>.md` is allowed today and remains allowed without reaching the new leg.
- [x] AC-12: When any seam used by the preimplementation leg throws, the leg returns `Allowed` `$false` with an empty suffix and the gate returns today's deny text (never-throw row).

Shared helper and structure:

- [x] AC-13: `.claude/hooks/hook-parallel-records-context.ps1` defines `Get-ParallelRecordsSlug` and `Get-ParallelRecordsCheckpointDecision` as specified in `#### Functions/classes/CLI commands impacted:`; both legs call them and neither leg re-implements the identity, closed, or receipt predicate (verified by `hook-parallel-records-context.Tests.ps1` rows for every sub-code, for slug extraction on `parallel/a-plan`, `parallel/a.b_c-plan`, `parallel/-plan`, `parallel/a`, `Parallel/a-plan`, and `feature/a-plan`, and by an AST test that each sibling leg file calls `Get-ParallelRecordsCheckpointDecision`). The helper reads no file, starts no process, and reads no clock.
- [x] AC-14: After the change, `.claude/hooks/enforce-model-routing-receipt.ps1` and `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` are each at most 500 logical lines, each new file is below 500 logical lines, `enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1` pass, and no new file contains the string `orchestrator-state.json` in a string expression. Each new file header states that the leg is a policy-level control, not a security control, and that same-session forgery of the checkpoint is possible.

End-to-end and non-goal verification:

- [ ] AC-15: `tests/scripts/claude-hooks/parallel-records-workflow.EndToEnd.Tests.ps1` composes, for one records pull request of a fixture run with mocked seams, the following decisions in sequence and asserts each is `allow`: `Agent(pr-author)` through the model-routing gate; the receipt `Write` through the preimplementation gate; `gh pr create --head parallel/<slug>-plan --base main --body-file artifacts/pr_body_<N>.md` through `.claude/hooks/enforce-pr-author-skill.ps1` (docs-only exemption of issue #901, branch diff limited to `docs/features/parallel/<slug>/`); and `gh pr merge <N> --merge` through `.claude/hooks/enforce-epic-merge-gate.ps1` (docs-only branch of issue #927, records PR number absent from `items[]`).
- [ ] AC-16: `git diff --name-only origin/main...HEAD` on the feature branch lists no path under `.codex/` or `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/`, none of `.claude/hooks/enforce-pr-author-skill*.ps1`, `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/hooks/enforce-epic-merge-gate*.ps1`, `.claude/hooks/hook-docs-only-diff.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1`, `.claude/hooks/hook-docs-estate-context.ps1`, `.claude/hooks/enforce-model-routing-receipt-docs.ps1`, `.claude/hooks/hook-cleanup-context.ps1`, `.claude/settings.json`, `.claude/hooks/pretooluse-dispatch.json`, or their bundle mirrors, and no `*.py` file outside `tests/`. The command output is recorded append-only in `evidence/qa-gates/non-goal-diff-check.<timestamp>.md` in the feature folder.
- [ ] AC-17: A parallel-orchestrator checkpoint fixture carrying `model_routing_receipts` and `complexity_assessments` validates with zero errors through `validate_parallel_orchestrator_state_text` (plain and `require_complete=True` for a closed fixture), verified by an added row in `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py`; no Python production file changes.

Fail-before evidence:

- [x] AC-18: Before either leg is implemented, the AC-1 allow row and the AC-9 allow row (relative form) are run against the unfixed hooks through the parallel test runner, and `evidence/regression-testing/fail-before.<timestamp>.md` in the feature folder records, with a clock-read timestamp and repo-relative paths only, that the AC-1 row received the generic `MODEL_ROUTING_RECEIPT_BLOCKED` deny and the AC-9 row received `PREIMPLEMENTATION_GATE_BLOCKED`. The file is never rewritten after it is written.

Documentation and mirrors:

- [ ] AC-19: `.claude/skills/parallel-orchestrate/SKILL.md` `### Run Closing` substep 3 states, before the delegation: refresh the PR context with `mcp__drm-copilot__collect_pr_context` at the coordinator root with base `main`; record one `complexity_assessments[]` entry and one pr-author `model_routing_receipts[]` entry (shape `{ agent, phase, complexity_band, fable_policy, table_model, clamped_from, model }`, `model` from `Resolve-DelegationModel -Agent pr-author`) in the parallel checkpoint; delegate non-isolated with exactly one `branch: parallel/<slug>-plan` line and no canonical issue line, passing `model` equal to the receipt's `model`; pr-author uses `gh pr create --head parallel/<slug>-plan --base main`; never record the records PR number in `items[]`. Substep 5 restates LV3 as a residual deferral for a delegation still denied, naming the `PARALLEL_RECORDS_*` sub-code. `## Parallel-Level Checkpoint` lists `model_routing_receipts[]` and `complexity_assessments[]` among the fields the coordinator writes. Every backticked `git add`/`git commit` span stays under `docs/features/`, and `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1` passes.
- [ ] AC-20: `.claude/agents/parallel-orchestrator.md` `### Run Closing` substeps 3 and 5 carry the same instructions in shortened form (receipt and assessment in the parallel checkpoint before the delegation; one `branch:` line, no canonical issue line; LV3 residual).
- [ ] AC-21: `.claude/rules/parallel-orchestration.md` declares `model_routing_receipts` and `complexity_assessments` as optional, tolerated top-level keys of the parallel-orchestrator checkpoint, read only by the Claude parallel records legs, not validated by the Python or TypeScript parallel validators, with the per-entry shape of `.claude/rules/orchestrator-state.md`; the enum table of `## Enum Ownership` is unchanged.
- [ ] AC-22: Every copy of the execution-environment brief that `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` holds byte-identical gains the same bullet "Parallel records legs (#1182)" in `## Hook Execution Context` beside the cleanup (#1026) and docs-estate (#1169) bullets, stating that on Claude the model-routing gate and the preimplementation gate admit the Run Closing records PR delegation and its receipt Write when the parallel checkpoint at the coordinator root records a valid pr-author receipt and every non-withdrawn item is merged, and that Codex has no equivalent leg; `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` passes.
- [ ] AC-23: Every new and changed `.claude/` file has an equal-text copy under `extensions/drm-copilot/resources/claude-customizations/`, each new hook file is listed in `pack-manifests/core.json`, and `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and `test_push_down_codex_and_agents_resource_contracts.py` pass in one `pytest -n auto` run.

Quality gates:

- [ ] AC-24: Line coverage is at least 85% for each of `.claude/hooks/hook-parallel-records-context.ps1`, `.claude/hooks/enforce-model-routing-receipt-parallel.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1`, `.claude/hooks/enforce-model-routing-receipt.ps1`, and `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, read from `artifacts/pester/powershell-coverage.xml` of the parallel gate run and recorded in `evidence/qa-gates/` of the feature folder.
- [ ] AC-25: The PowerShell toolchain (PoshQC format, analyze with zero findings, Pester through the parallel runner) passes in a single loop with no auto-fixed files, and CI on the PR head passes, including the Linux hook-suite job.

## Post-Merge Verification

This section is not an acceptance criterion of this pull request and does not gate its AC tracking. After this fix merges into `main`, the coordinator branch `parallel/harness-learnings-2026-11-09-plan` merges `origin/main` so that the session-root checkout runs the fixed hooks; after that merge, `git diff --name-only origin/main...HEAD` on that branch must still list only paths under `docs/features/parallel/harness-learnings-2026-11-09/`. The parallel-orchestrator (or the main session acting as coordinator) then records the pr-author complexity assessment and routing receipt in the session-root parallel checkpoint of run harness-learnings-2026-11-09, refreshes the PR context, delegates the records pull request through `Agent(pr-author)` with the single label `branch: parallel/harness-learnings-2026-11-09-plan` and no canonical issue line, and merges it with `gh pr merge <PR> --merge` once CI is green. Deferral LV3 recorded in that run's `completed_steps` is then resolved, and the deferred post-merge worktree cleanup report runs as Run Closing substep 4 describes.

## Risks & Mitigations

- Technical or operational risks:
  - A reviewer flags the new checkpoint keys as undeclared fields. Mitigation: AC-21 amends the rule in the same change.
  - Mirror drift between source and bundle copies, or a brief copy missed. Mitigation: AC-22 and AC-23 contract tests.
  - Test isolation: a suite reads the developer's real session-root parallel checkpoint and passes locally only. Mitigation: all reads go through mocked seams and the epic-state baseline mocks; no temporary files.
  - Linux-only CI failures from drive-letter fixtures or case differences. Mitigation: forward-slash fixtures without drive letters, exact case.
  - The receipt check is consistency-only; the delegation could still use a different model. Mitigation: documented limitation, same as every other path of this gate.
  - Same-session forgery of the parallel checkpoint. Mitigation: documented as a policy-level control, consistent with the epic receipt precedent.
- Mitigations and rollbacks: revert the change; Run Closing falls back to deferral LV3.

## Rollout & Follow-up

- Release/rollout steps: merge through the orchestrated large path; the push-down bundles carry the change to destinations on the next extension release.
- Post-fix monitoring or clean-up tasks: the records pull request of run harness-learnings-2026-11-09 per `## Post-Merge Verification`.
- Known limitations: the Python orchestrator-state validator does not read the parallel checkpoint's receipts; the leg checks receipt consistency, not the delegation's actual model; Codex has no parallel Run Closing and no equivalent leg.
- Links: issue #1182; precedents #663 (epic scope), #1026 (cleanup leg), #1169 (docs-estate leg), #901 (pr-author docs-only exemption), #927 (merge-gate docs-only branch), #673 (checkpoint hygiene).
