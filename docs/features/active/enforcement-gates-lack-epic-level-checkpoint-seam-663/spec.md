# enforcement-gates-lack-epic-level-checkpoint-seam (Spec)

- **Issue:** #663
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25T09-10
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance-criteria source is this file only; no `user-story.md` is produced)
- **Research:** `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/research/research.2026-09-25T08-35.md`
- **Consolidates:** #657 (gate 6), #662 (gate 3), #664 (gate 4)

## Context

- **Summary.** Several PowerShell PreToolUse enforcement gates assume that every orchestration run is governed by the per-feature checkpoint `artifacts/orchestration/orchestrator-state.json`, whose `feature-folder` is under `docs/features/active/` and which carries an `issue-num`. An epic run keeps its state in `artifacts/orchestration/epic-orchestrator-state.json`, its home folder is `docs/features/epics/<slug>/`, and epic planning does not create an epic-level GitHub issue. The gates therefore fail closed on the epic's own operations: opening the integration-to-`main` PR, delegating to `pr-author`, staging main-sync merge conflict resolutions, and committing the epic status projection.
- **Observed environment.** Windows 11 Pro 10.0.26200, Claude Code runtime, PowerShell 7; Python 3.13 via Poetry for validators (validators are not invoked from hooks).
- **Customer impact and severity.** Blocker. Every epic stalls at its final PR unless the main session intervenes. Epic #655 required a hand-promoted epic issue, a per-feature checkpoint that described the integration-PR run with `epic_mode: false`, and commits issued through the PowerShell tool to bypass the Bash-side staging exemption.
- **First observed.** Epic #655, 2026-09-07 to 2026-09-09. Current-tree state re-verified by research on 2026-09-25 against `origin/main` `26d57cb3`.

## Repro & Evidence

- **Steps to reproduce.**
  1. Run an epic to the end of its final wave.
  2. From the epic coordinator (main session or `epic-orchestrator`), attempt: `Agent(pr-author)` for the integration PR; `gh pr create --head epic/<slug>-integration --base main --body-file artifacts/pr_body_<N>.md`; `git merge origin/main` on the integration branch followed by `git add <resolved production path>`; `git add docs/features/epics/<slug>/epic-status.md && git commit -m "..."` with a message carrying the mandated `Co-Authored-By: ... <noreply@anthropic.com>` trailer.
  3. Observe the denials listed below.
- **Expected.** Each epic-level operation is evaluated against `epic-orchestrator-state.json` and allowed when the epic evidence is present; the same operation denies when the epic evidence is absent; standalone, parallel, and epic-child runs are unchanged.
- **Actual (current tree, per research).**
  - Gate 1: `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` or a `NoTarget` denial, because only a per-feature checkpoint is ever read, and the #673 hygiene rule (`.claude/skills/epic-orchestrate/SKILL.md` checkpoint-hygiene paragraph) forbids the coordinator from holding one.
  - Gate 2: latent. Check 6 is reached only after gate 1 passes; the epic checkpoint has no `epic_mode` key, so check 6 would no-op instead of asserting `--base main`.
  - Gate 3: `MODEL_ROUTING_RECEIPT_BLOCKED`, because receipts are read only from a per-feature checkpoint.
  - Gate 4: `PREIMPLEMENTATION_GATE_BLOCKED` on the command and path legs, which are pinned to single-feature mode and a cwd-relative per-feature checkpoint whose `feature-folder` must start with `docs/features/active/`.
  - Gate 4b: the Bash-side staging exemption rejects any command line containing `<` or `>`, including inside a quoted `-m` value, so the `Co-Authored-By` trailer causes a false denial.
  - Gate 5: `COMPLETION_CONSISTENCY_BLOCKED` when a per-feature-shaped checkpoint carries `docs/features/epics/<slug>`. Under the design below no such checkpoint is written, and writes to `epic-orchestrator-state.json` are not intercepted.
- **Logs.** See `issue.md` "Logs / Screenshots".
- **Frequency.** Deterministic for every epic.

## Scope & Non-Goals

- **In scope.**
  - A shared epic-scope resolver (PowerShell lib module) consumed by gates 1, 2, 3, and 4.
  - Gate 1 (pr-author PR-creation preflight): epic-scope PR-creation readiness evaluated on the epic checkpoint.
  - Gate 2 (epic base-branch check 6): epic-scope rule requiring `--base main`.
  - Gate 3 (model-routing receipt): epic-scope receipt lookup in the epic checkpoint's `model_routing_receipts[]`.
  - Gate 4 (preimplementation gate, command and path legs): epic-scope readiness, with production-path staging allowed only while a merge is in progress (D2).
  - Gate 4b (staging exemption): `<` and `>` treated as literal inside quoted spans, applied identically to the four byte-identical helper copies (D1, D4).
  - Gate 5: no production change; a pinning test (D3).
  - Contract text: `epic-planner` promotes an epic-level issue and records `epic_issue_num`; `epic-orchestrate` states the integration-PR checkpoint shape and the receipt location; `epic-orchestrator` lists the added epic-checkpoint fields.
  - Push-down mirrors, pack-manifest membership, Pester coverage allow-list entries, and manifest-test registration for every new or changed `.claude/**` file.
- **Out of scope / non-goals.**
  - Gate 6 (`enforce-parallel-worktree-removal-gate.ps1`) code. It was fixed by #688 (PR #689); this change only asserts non-regression.
  - Codex gate-4 and gate-5 epic-scope fixes (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`). Deferred to a follow-up issue (D1). The only `.codex` change is the byte-identical helpers copy.
  - Any Python leg in an enforcement hook (D5). Python validators may gain additive-field tests; no hook calls Python.
  - Modelling backslash-escaped quotes in the staging-exemption parser; the `'\''` idiom stays denied (D4).
  - Widening `Test-OrchestrationReady` or `Test-IsValidFeatureFolder` to accept `docs/features/epics/` (rejected Approach B).
  - The adjacent completion-consistency defect where an Edit resolves on-disk content from the literal relative checkpoint path rather than `file_path`. Recorded as a follow-up candidate only.
  - Two-child epic packaging. Delivery is one standalone PR to `main`.
- **Explicitly excluded systems.** Live GitHub and a live epic are not used in automated tests; the #655 end-to-end rerun is a manual verification step.

## Root Cause Analysis

- **Confirmed root cause.** Checkpoint resolution in the gates has exactly one family: `<root>/artifacts/orchestration/orchestrator-state.json` (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`), combined with a hard-coded `docs/features/active/` prefix rule. No gate decides whether a call is an epic-level operation, and no gate reads `epic-orchestrator-state.json` on the PR, receipt, command, or path legs. #554 added epic-mode resolution only to the preimplementation gate's delegation leg; #673 changed which worktree is read but not which checkpoint family.
- **Contributing contract gaps.** `epic-plan` / `epic-planner` promote child issues only and never record `epic_issue_num`; `epic-planner` lacks `mcp__drm-copilot__potential_to_issue`. `epic-orchestrate` records only the post-PR `epic_merge_pr` result and names no pre-PR readiness shape or receipt location for the epic's own `pr-author` delegation.
- **Staging exemption (4b).** `$script:UnresolvableCommandCharacters` (`'$'`, backtick, `'>'`, `'<'`) is tested against the whole command text before quote parsing in `Test-ExemptOrchestrationStagingCommand`, so literal angle brackets inside a quoted commit message are treated as redirections.
- **Signals.** Research sections 1 (per-gate `file:line` citations) and the orchestrator's git-log verification: since 2026-09-08 the gate files changed only in `1329b43e` (#673), `4ea6e15e` (#688), `685bcbf5`, and `03f4f305` (staging exemption / worktree selector). None adds an epic-level checkpoint seam to gates 1-4.
- **Affected components.** See "Files/modules to change".

## Resolved Design Decisions

- **D1 — Codex scope.** Codex gate-4 and gate-5 epic-scope fixes are deferred to a follow-up issue. Exception: the four byte-identical copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` change together, because the parity test requires SHA-256 identity.
- **D2 — Gate-4 command-leg narrowing.** In epic scope, staging a non-bookkeeping (production) operand is allowed only while a merge is in progress in the effective worktree (a `MERGE_HEAD` file exists in that worktree's git directory, read through a mockable seam). Bookkeeping operands continue to use the existing exemption.
- **D3 — Gate 5.** No production code change. Current behavior is pinned by a test: a completion-asserting Write or Edit to `artifacts/orchestration/epic-orchestrator-state.json` is not intercepted, and a per-feature checkpoint carrying `docs/features/epics/<slug>` is still denied.
- **D4 — Apostrophes and quoting.** The single-quoted `'\''` apostrophe idiom stays denied. Double-quoted commit messages containing angle brackets and apostrophes are accepted.
- **D5 — Epic readiness authority.** The epic readiness predicates are PowerShell-only and declared PowerShell-authoritative in their module header. Enforcement hooks do not call Python.
- **Delivery.** One large feature, delivered as a standalone PR to `main`, using the shared-resolver design (Approach A) and batches that respect the 500-line file limit and the PowerShell cap of three production and three test files per batch.

## Proposed Fix

### Design summary (what changes where):

A new lib module (working name `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`; the plan may choose a sibling folder) decides whether a call is an epic-level operation and, if so, returns the absolute path of the governing `epic-orchestrator-state.json`:

1. Locate the session worktree root (`Find-WorktreeResolutionRoot`) and read `<root>/artifacts/orchestration/epic-orchestrator-state.json` through a mockable seam.
2. The call is epic scope when that checkpoint parses, has `route_id == "epic"`, and its `integration_branch` equals (a) the call's branch signal (`--head`, `--branch`, or a `branch:` delegation label, via `Find-WorktreeResolutionBranchSignal`), or (b) for a command or path leg with no branch signal, the HEAD branch of the effective worktree (the `-C <value>` selector when present, otherwise the session root).
3. Otherwise the existing per-feature resolution runs unchanged.

Gate wiring:

- **Gate 1.** In epic scope, `Get-PrAuthorBypassReason` evaluates an epic PR-creation readiness predicate on the epic checkpoint instead of `Invoke-OrchestratorStatePreflight`: `route_id == "epic"`, `integration_branch` equals `--head`, `features` non-empty, and every `features[].merge_status` in `{merged, worktree_removed}`.
- **Gate 2.** Check 6 receives the same scope result as gate 1 (single resolution). In epic scope, `--base` must equal `main`; any other value denies. Per-feature `epic_mode` behavior is unchanged.
- **Gate 3.** In epic scope, `Test-ModelRoutingReceiptPresent` scans the epic checkpoint's `model_routing_receipts[]` for a `pr-author` receipt.
- **Gate 4.** In epic scope, the command and path legs evaluate the epic-shape conjuncts of `Get-EpicOrchestrationReadinessFailure` (`route_id`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, `features`) without the delegation-specific target-record conjuncts, plus the D2 merge-in-progress rule for production operands. Code moves to a new sibling file to keep `enforce-orchestration-preimplementation-gate.ps1` under 500 lines.
- **Gate 4b.** `<` and `>` are unresolvable only outside quoted spans. `$` and backtick remain unresolvable anywhere. The all-segments rule and pathspec requirement are unchanged.
- **Gate 5, gate 6.** No code change.

### Boundaries and invariants to preserve:

- Epic scope is decided only from the session root's epic checkpoint plus a branch or HEAD match. No checkpoint path is ever read from prompt or command text (the #554 posture).
- Checkpoint paths are composed as absolute paths from a resolved root (the #673 invariant). No hook reads a process-directory-relative checkpoint on the new epic path.
- Fail-closed: an absent, unparseable, or non-`epic` epic checkpoint yields "not epic scope"; the per-feature path then runs unchanged, including its denials.
- Standalone, parallel, and epic-child runs keep identical decisions and reason text. Existing suites pass without modification except where a test is deliberately extended.
- An epic-scope denial names the epic checkpoint and the failed conjunct, following `Get-OrchestrationModeDenyReason`.
- The coordinator root never holds a per-feature checkpoint (the #673 hygiene rule remains intact; the design does not require one).
- The four helper copies stay SHA-256 identical; every `.claude/**` file stays text-identical to its push-down mirror.
- No production or test file exceeds 500 lines. `WorktreeResolution.psm1` (500 lines) and `OrchestratorState.psm1` (499 lines) are not modified.
- No enforcement hook invokes Python.
- Tests use mocked read seams only: no temporary files, no live git state, no absolute host roots such as `C:/workspace`.

### Dependencies or blocked work:

- Builds on #554, #573, #673 (PR #695), #687 (PR #691), and #688 (PR #689), all merged.
- No external dependency. No new third-party package.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production (Claude surface):

- New: `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (resolver and read seams).
- New (optional, if the resolver would exceed about 400 lines): a pure epic readiness predicate module in the same folder.
- New: a sibling of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` that receives relocated per-mode read seams and the epic command/path-leg wiring.
- Modified: `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (gate 1).
- Modified: `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` (gate 2).
- Modified: `.claude/hooks/enforce-model-routing-receipt.ps1` (gate 3).
- Modified: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (gate 4).
- Modified: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (gate 4b), plus its byte-identical copies at `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.

Configuration and manifests:

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`CodeCoverage.Path` entries for new modules and the new hook sibling).
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (pack membership for new `.claude/**` files).
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` `ExpectedPaths` (new module registration).

Contract documents:

- `.claude/skills/epic-plan/SKILL.md` (epic-level issue promotion step; `epic_issue_num`).
- `.claude/agents/epic-planner.md` (frontmatter gains `mcp__drm-copilot__potential_to_issue` and a write scope sufficient to author the potential entry, or the procedure names another author; checkpoint field list gains `epic_issue_num`).
- `.claude/skills/epic-orchestrate/SKILL.md` (integration-PR checkpoint shape, receipt location, statement that the integration PR is gated against the epic checkpoint).
- `.claude/agents/epic-orchestrator.md` (epic checkpoint field list gains `epic_issue_num` and `model_routing_receipts`).

Mirrors: every modified or new `.claude/**` file above at `extensions/drm-copilot/resources/claude-customizations/.claude/**`, copied byte-for-byte after each batch rather than written with Write/Edit.

Tests (new or extended):

- New: `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`.
- New: `tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1`.
- Extended: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`.
- New: `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1`.
- New: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`.
- Extended: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`.
- Extended: `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` (D3 pinning rows).
- Extended: `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` (contract rows).
- Extended: `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` (additive-field acceptance).
- Regression only (unmodified): `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`, `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.

#### Functions/classes/CLI commands impacted:

- New exported resolver function (working name `Resolve-EpicScopeCheckpoint`) returning `{ IsEpicScope, CheckpointPath, Checkpoint, Reason }`, plus mockable seams for the epic checkpoint read, the HEAD-branch read, and the `MERGE_HEAD` probe.
- New pure predicates (working names `Get-EpicPrCreationReadinessFailure`, `Get-EpicCommandLegReadinessFailure`).
- `Get-PrAuthorBypassReason`, `Get-PrAuthorTargetCheckpointResolution`, `Test-PrAuthorReceiptVerification` check 6, `Test-EpicBaseBranchOverride`.
- `Get-ModelRoutingTargetCheckpointResolution`, `Invoke-ModelRoutingReceiptDecision`.
- `Invoke-OrchestrationPreimplementationGateDecision` (command and path legs).
- `Test-ExemptOrchestrationStagingCommand`, and the quote-aware character check it uses.

#### Data flow and validation changes:

- Epic checkpoint gains two additive fields: `epic_issue_num` (integer, recorded by `epic-planner` after promotion) and `model_routing_receipts[]` (same element shape as the per-feature array). `validate_epic_orchestrator_state.py` must accept both without change to its required-key sets; this is confirmed by a test rather than assumed.
- Gate 1 epic readiness reads `route_id`, `integration_branch`, and `features[].merge_status`.

#### Error handling and logging updates:

- Epic-scope denials reuse the existing reason codes (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED`, `EPIC_BASE_BRANCH_MISMATCH`, `MODEL_ROUTING_RECEIPT_BLOCKED`, `PREIMPLEMENTATION_GATE_BLOCKED`) and add the epic checkpoint path and the failed conjunct to the reason text.
- Unparseable epic checkpoint content is treated as "not epic scope" and never throws out of the hook.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the PR; the resolver is only consulted when an epic checkpoint with a matching `integration_branch` exists, so removal restores current behavior.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Hook inputs are unchanged PreToolUse JSON envelopes. Hook outputs are unchanged allow/deny decisions with reason text.
- Integration-PR checkpoint shape (stated in `epic-orchestrate/SKILL.md`): `epic-orchestrator-state.json` with `route_id: "epic"`, `integration_branch`, `epic_issue_num`, `features[]` all `merged` or `worktree_removed`, and a `model_routing_receipts[]` entry for `pr-author` recorded before the `Agent(pr-author)` delegation. No per-feature checkpoint is written for the integration PR.

#### Required configuration keys and defaults:

- None added to `.claude/settings.json`. Pester coverage allow-list entries only.

#### Backward-compatibility expectations:

- Per-feature checkpoint schema and every existing gate decision for non-epic runs are unchanged.
- Epic checkpoint changes are additive.

#### Performance constraints (latency/throughput/memory):

- One additional small JSON read per gate invocation when the session root holds an epic checkpoint; no network or process spawn added beyond the existing git HEAD resolution already used by worktree resolution.

## Assumptions, Constraints, Dependencies

- **Assumptions.** The epic coordinator runs in a worktree whose root holds `epic-orchestrator-state.json`. The integration PR uses `--head <integration_branch>`.
- **Constraints.** 500-line file limit; PowerShell batch cap of three production and three test files; mirrors copied byte-for-byte; the agent-worktree isolation guard denies commands containing `bash`, `pwsh`, or `wsl`; the PoshQC MCP result carries no test output, so pass counts must not be asserted from it.
- **External dependencies.** None.

## Data / API / Config Impact

- **User-facing changes.** Epic coordinators can open the integration PR, delegate to `pr-author`, stage main-sync merge resolutions, and commit the epic status projection without tool detours.
- **Data.** Additive epic checkpoint fields `epic_issue_num` and `model_routing_receipts`.
- **Logging.** Denial reasons name the epic checkpoint and failed conjunct in epic scope.
- **Compatibility.** No CLI flag or settings change.

## Test Strategy

- **Regression tests.** Each residual gate gets allow (epic evidence present), deny (epic evidence absent or mismatched), and standalone-unchanged cases, listed in the acceptance criteria.
- **Unit tests (Pester).** Hermetic: mock the epic checkpoint read, HEAD-branch read, and `MERGE_HEAD` probe; reuse `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1`.
- **Edge cases.** Absent, unparseable, and non-`epic` epic checkpoints; `integration_branch` mismatch; empty `features`; a feature with non-terminal `merge_status`; `-C` selector versus session root; `>`/`<` outside quotes; `$(`, `$VAR`, and backtick inside a double-quoted message; the `'\''` idiom.
- **Error handling.** Assert reason text contains the epic checkpoint name and the failed conjunct.
- **Coverage.** Line coverage >= 85% for each new and changed PowerShell file; no regression on changed lines. PowerShell has no branch-coverage gate.
- **Toolchain.** `run_poshqc_format` -> `run_poshqc_analyze` -> `run_poshqc_test` (repo `pester.runsettings.psd1`); `poetry run pytest` for the Python contract tests; the extension jest suite for pack-manifest completeness.
- **Manual validation.** Rerun the #655 sequence from its recorded provenance block on a live epic and confirm zero denials.

## Acceptance Criteria

Resolver

- [x] `EpicScopeResolution.Tests.ps1` passes with cases proving: epic scope when the branch signal equals the epic checkpoint's `integration_branch`; epic scope for a command leg whose `-C` selector worktree HEAD, or session-root HEAD when no selector is present, equals `integration_branch`; not epic scope when the epic checkpoint is absent, unparseable, has `route_id` other than `epic`, or the branch does not match; the returned checkpoint path is absolute and is never taken from command or prompt text.

Gate 1 — pr-author PR-creation preflight

- [x] `enforce-pr-author-skill.EpicScope.Tests.ps1` allow case: `gh pr create --head <integration_branch> --base main` is allowed when the epic checkpoint has `route_id: epic`, a matching `integration_branch`, and every `features[].merge_status` in `{merged, worktree_removed}`, with no per-feature checkpoint present.
- [x] `enforce-pr-author-skill.EpicScope.Tests.ps1` deny cases: the same command is denied when a feature has a non-terminal `merge_status`, when `features` is empty, and when the epic checkpoint is absent; each epic-scope denial reason names the epic checkpoint and the failed conjunct.
- [ ] `enforce-pr-author-skill.EpicScope.Tests.ps1` standalone case: a per-feature PR (`--head` not equal to any epic `integration_branch`) yields the same decision and reason text as before the change, and all existing `enforce-pr-author-skill*.Tests.ps1` suites pass unmodified.

Gate 2 — epic base-branch check 6

- [x] `enforce-pr-author-skill.epic-base-branch.Tests.ps1` epic-scope cases: `--base main` is allowed and any other `--base` value is denied with `EPIC_BASE_BRANCH_MISMATCH`, using the scope result gate 1 resolved (a single resolution per call).
- [ ] The existing per-feature `epic_mode: true` / `epic_mode: false` rows in `enforce-pr-author-skill.epic-base-branch.Tests.ps1` and `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` pass without modification.

Gate 3 — model-routing receipt

- [x] `enforce-model-routing-receipt.EpicScope.Tests.ps1` allow case: `Agent(pr-author)` with a `branch:` label equal to `integration_branch` is allowed when the epic checkpoint's `model_routing_receipts[]` contains a `pr-author` receipt.
- [x] `enforce-model-routing-receipt.EpicScope.Tests.ps1` deny case: the same delegation is denied with `MODEL_ROUTING_RECEIPT_BLOCKED` when the epic checkpoint has no `pr-author` receipt.
- [ ] `enforce-model-routing-receipt.EpicScope.Tests.ps1` standalone case: a per-feature delegation resolves the per-feature checkpoint with unchanged decision and reason text, and the existing `enforce-model-routing-receipt*.Tests.ps1` suites pass unmodified.

Gate 4 — preimplementation gate, command and path legs

- [x] `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` allow case: in epic scope with a ready epic checkpoint and a mocked `MERGE_HEAD` present, `git add <production path>` is allowed.
- [x] `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` deny cases: in epic scope, `git add <production path>` is denied with `PREIMPLEMENTATION_GATE_BLOCKED` when no merge is in progress (D2), and when an epic-shape conjunct (`route_id`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, or `features`) is missing; the reason names the epic checkpoint and the failed conjunct.
- [x] `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` path-leg case: an Edit or Write to a production path in epic scope follows the same readiness decision as the command leg.
- [ ] `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` standalone case: with no epic checkpoint, the command and path legs return the single-feature decision and reason text unchanged, and the existing `enforce-orchestration-preimplementation-gate*.Tests.ps1` suites pass unmodified (including the delegation-leg mode-resolution suite from #554).

Gate 4b — staging exemption

- [x] `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` passes new rows proving: `git add <exempt path> && git commit -m "<message with Co-Authored-By: Name <noreply@anthropic.com> and an apostrophe such as it's>"` is exempt; a single-quoted `-m` value containing `<` and `>` is exempt; the `'\''` apostrophe idiom is denied (D4); `$(`, `$VAR`, and backtick inside a double-quoted message are denied; and the existing unquoted `>` and `<` redirection rows still deny.
- [x] `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` carries the same new rows and passes against the `.codex/hooks` helpers copy.
- [x] `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` passes, proving all four copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` (`.claude/hooks`, `.codex/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`) are SHA-256 identical after the change, and `legacy-codex-hook-contracts.Tests.ps1` passes.

Gate 5 — completion-consistency (no code change, D3)

- [ ] `enforce-completion-consistency.Tests.ps1` pinning rows pass: a completion-asserting Write or Edit to `artifacts/orchestration/epic-orchestrator-state.json` is not intercepted, and a per-feature `orchestrator-state.json` whose `feature-folder` is `docs/features/epics/<slug>` is still denied with `COMPLETION_CONSISTENCY_BLOCKED`; `git diff origin/main -- .claude/hooks/enforce-completion-consistency.ps1 .claude/hooks/enforce-completion-helpers.ps1` is empty.

Gate 6 — non-regression

- [ ] `enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1`, `enforce-parallel-worktree-removal-gate.Tests.ps1`, and `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` pass unmodified, and `git diff origin/main -- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1` is empty.

Contracts — skills and agents

- [x] `.claude/skills/epic-plan/SKILL.md` and `.claude/agents/epic-planner.md` state that `epic-planner` promotes an epic-level issue at planning time through `mcp__drm-copilot__potential_to_issue` with `promotion_type: epic` and records the resulting number as `epic_issue_num` in the epic checkpoint; `epic-planner.md` frontmatter lists `mcp__drm-copilot__potential_to_issue`. Verified by new rows in `checkpoint-hygiene-skill-contract.Tests.ps1`.
- [ ] `.claude/skills/epic-orchestrate/SKILL.md` states the integration-PR checkpoint shape (`route_id: epic`, `integration_branch`, `epic_issue_num`, all `features[]` merged or `worktree_removed`), that the integration PR and its `Agent(pr-author)` delegation are gated against `epic-orchestrator-state.json`, and that the `pr-author` receipt is recorded in that file's `model_routing_receipts[]`; `.claude/agents/epic-orchestrator.md` lists `epic_issue_num` and `model_routing_receipts` in its epic checkpoint field list. Verified by new rows in `checkpoint-hygiene-skill-contract.Tests.ps1`; the existing #673 hygiene rows pass unmodified.
- [ ] `test_validate_epic_orchestrator_state.py` passes a new case proving `validate_epic_orchestrator_state` accepts an epic checkpoint carrying `epic_issue_num` and `model_routing_receipts`, and `test_parallel_planner_surface_contracts.py` passes unmodified.

Mirrors, manifests, and policy

- [ ] Every new or modified `.claude/**` file is text-identical to its mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/**`, verified by `test_push_down_claude_resource_contracts.py` passing; new `.claude/**` files are listed in `pack-manifests/core.json`, verified by `test_push_down_claude_pack_manifest_completeness.py` and `claude-pack-manifest-completeness.test.ts` passing; `WorktreeResolution.Manifest.Tests.ps1` passes with the new module(s) registered in `ExpectedPaths` and SHA-256 identical to the bundle copy.
- [ ] `enforcement-hooks-no-python-invocation.Tests.ps1` passes, and the new resolver and predicate module headers declare the epic readiness predicates PowerShell-authoritative (D5).
- [ ] No new or modified production or test file exceeds 500 lines, and `.claude/lib/worktree-resolution/WorktreeResolution.psm1` and `.claude/lib/orchestrator-state/OrchestratorState.psm1` show an empty `git diff origin/main`.
- [ ] Full PowerShell toolchain passes in one pass (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test` with the repository `pester.runsettings.psd1`), and each new or changed PowerShell production file reports line coverage >= 85% in the coverage evidence recorded under the feature folder's `evidence/coverage/`.

## Risks & Mitigations

- **Risk: epic scope over-matches.** A standalone run in a worktree that also holds an epic checkpoint could be treated as epic scope. Mitigation: scope requires both `route_id == epic` and an exact `integration_branch` match; standalone-unchanged cases per gate.
- **Risk: D2 opens production staging on the integration branch.** Mitigation: production operands are allowed only while `MERGE_HEAD` exists; deny case without it.
- **Risk: quote-aware character check admits a redirection.** Mitigation: unquoted `<`/`>` rows remain deny; `$` and backtick remain denied anywhere.
- **Risk: mirror drift or batch-budget overrun.** Mitigation: byte-copy mirrors after each batch; parity and push-down contract tests in the gate list.
- **Risk: coverage evidence for new modules not collected by the MCP runner.** Mitigation: register `CodeCoverage.Path` entries and, if the MCP runner ignores them, invoke the self-hosted PoshQC module directly and record the artifact.
- **Rollback.** Revert the PR.

## Rollout & Follow-up

- **Rollout.** Standalone PR to `main`; the push-down bundle picks up the mirrors on the next extension release.
- **Follow-ups to file.** Codex gate-4 and gate-5 epic-scope fixes (D1); the completion-consistency Edit path that resolves on-disk content from the literal relative checkpoint path instead of `file_path`.
- **Manual verification.** Rerun the #655 sequence from its provenance block on the next live epic and record zero denials.
- **Links.** Issue #663; consolidated #657, #662, #664; related #554, #573, #673 (PR #695), #687 (PR #691), #688 (PR #689); research `research/research.2026-09-25T08-35.md`.
