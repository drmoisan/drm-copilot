# 2026-10-08-pr-author-and-merge-gates-read-session-root-files (Spec)

- **Issue:** #850
- **Parent (optional):** Epic #852 (enforcement-hook-precision), child C3 (residual session-root reads)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-30
- **Status:** Approved for planning
- **Version:** 1.0
- **Work Mode:** full-bug (`spec.md` is the sole acceptance-criteria source; `user-story.md` is absent by design)
- **Bundled issues:** #788, #789, #851 (closed by the same pull request)
- **Integration branch:** `epic/enforcement-hook-precision-integration`
- **Inputs:** `issue.md` (including `## Bundled Issues`), `research/research.2026-10-08T14-00.md`, `docs/features/epics/enforcement-hook-precision/epic.md`

## Context

- Summary: Two Claude PreToolUse gates read PR-authoring and merge-authorization files relative to the session root rather than the worktree that owns the pull request. `enforce-pr-author-skill.ps1` reads `artifacts/pr_context.summary.txt`, `artifacts/pr_body_<N>.md`, and `artifacts/pr_body_<N>.receipt.json` (including the receipt-freshness comparison) from the hook process directory. The standalone-merge branch of `enforce-epic-merge-gate.ps1` reads the per-feature checkpoint from the session worktree. This is the remainder of closed #690, which converted the checkpoint reads but left these paths session-relative.
- Bundled defects delivered by this child:
  - #788: the merge gate's child branch binds the command's pull request number only when the checkpoint records `pr_gate.pr_number`.
  - #789 CR-4: `Test-WorktreeRunPathEqual` compares UNC paths case-sensitively.
  - #789 CR-5: the parallel worktree removal gate's final deny carries the `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token twice. The epic worktree removal gate carries the same construct and is corrected in this child.
  - #851: the epic worktree removal gate's deny text does not record enough to classify an unreproduced deny. Diagnostics only.
- Observed environment: Windows 11 Pro; Claude Code 2.1.284; PowerShell 7 PreToolUse hooks; parallel run bug-burndown-2026-09-29.
- Customer impact and severity: Medium. Any child orchestrator whose working directory is not inside the item worktree cannot open or merge its pull request without manually copying files into the session root. The copies are gitignored, persist after the run, and can satisfy the gate for a later call (a stale summary from one item compared against another item's receipt).
- First observed: 2026-10-07, items #543 (PR #829) and #830 (PR #831).

## Repro & Evidence

- Steps to reproduce (from `issue.md`):
  1. Run an item in worktree A through a child orchestrator spawned without `isolation`, so the child's working directory is the coordinator session root B.
  2. In worktree A, run `mcp__drm-copilot__collect_pr_context` and let pr-author write `artifacts/pr_body_<N>.md` and its receipt.
  3. Issue `gh pr create --body-file artifacts/pr_body_<N>.md --head <item-branch>` from the child.
  4. After CI is green, record a `standalone_merge_authorizations` entry in worktree A's `artifacts/orchestration/orchestrator-state.json` and issue `gh pr merge <N> --merge`.
- Expected: both gates resolve the item's worktree and read the PR context summary, body, receipt, and merge-authorization checkpoint beneath it. An unresolvable or ambiguous target denies with the worktree-resolution reason codes.
- Actual: step 3 is denied with `PR_CONTEXT_MISSING` because the summary is looked up under B. Step 4 is denied with `EPIC_MERGE_GATE_BLOCKED: ... STANDALONE_MERGE_AUTHORIZATION_ABSENT` because the gate reads B's per-feature checkpoint.
- Frequency: deterministic for the stated topology.
- #851 has no reproduction; re-evaluation on main `fb413fce` returns allow.

## Scope & Non-Goals

### In scope

- #850 pr-author gate: `.claude/hooks/enforce-pr-author-skill.ps1` and `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (and a new dot-sourced sibling if the line cap requires one).
- #850 merge gate and #788: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, and an item-by-PR-number resolver in `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (or a new module in the same folder if the line cap requires one).
- #789 CR-4: in-place change to `Test-WorktreeRunPathEqual` in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`.
- #789 CR-5: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` final deny, and the same doubled-token construct in the final deny of `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`. The epic removal gate correction is outside the literal text of #789 and is included by orchestrator decision so that the #851 diagnostics are not appended to a doubled token.
- #851 diagnostics: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`.
- Byte-identical bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/` for every changed `.claude` hook, helper, and module, plus `core.json` and manifest-suite registration for any new module or dot-sourced sibling.
- Documentation alignment: `.claude/rules/orchestrator-state.md` (one sentence stating which per-feature checkpoint the merge gate consults for an explicit pull request number) and the pr-author handoff text in `.claude/skills/orchestrate/SKILL.md` (a child working outside the item worktree passes the absolute body path), with their bundled mirrors.
- New and updated Pester suites, and committed read-only fixtures where needed.

### Out of scope / non-goals

- **Codex gates.** `.codex/hooks/enforce-epic-merge-gate.ps1` and `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` are independent implementations, not copies of the Claude hooks. They import no worktree-resolution module, read checkpoints from `$PSScriptRoot`-derived roots, and the Codex merge gate's child branch has no pull request binding. No byte-parity requirement exists between them and the Claude hooks. They are not changed by this child, and their bundled mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/` are unaffected. The Codex session-root reads and the Codex equivalent of #788 are recorded as a follow-up candidate; no new GitHub issue is created by this child.
- Any change to the allow/deny decision of the epic worktree removal gate (#851 is diagnostics only).
- The stale session-root copies left by the 2026-10-07 workaround. They must not be read, modified, or deleted by any task of this child.
- Resolving `gh pr edit <N>` targets by pull request number (a pre-existing limitation: `gh pr edit` has no `--head` option). Candidate follow-up.
- #824 addendum 2 (#823 follow-ups) and every other epic child's scope.
- A bash or Python port of any hook.

## Root Cause Analysis

- Confirmed root cause (#850 pr-author): the four artifact seams (`Get-PrContextArtifactExistence`, `Get-PrContextSummaryLastWriteUtc`, `Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`) receive relative paths bound to the process directory. Target resolution (`Get-PrAuthorTargetCheckpointResolution` through `Resolve-WorktreeItemTarget`) runs after Case C (`PR_CONTEXT_MISSING`) and its resolved `WorktreeRoot` is used only to locate the checkpoint.
- Confirmed root cause (#850 merge gate): `Invoke-EpicMergeGateDecision` reads the child checkpoint beneath `Get-EpicMergeGateSessionWorktreeRoot` unconditionally. No resolver exists that locates an item checkpoint by pull request number; `Resolve-WorktreeRunTargetByRecord` accepts only the `epic` and `parallel` run kinds.
- Confirmed root cause (#788): `Test-ChildCheckpointPrGateBinding` returns `$true` when `pr_gate` or `pr_gate.pr_number` is absent.
- Confirmed root cause (#789 CR-4): `Test-WorktreeRunPathEqual` selects `OrdinalIgnoreCase` only when a side matches `^[A-Za-z]:`.
- Confirmed root cause (#789 CR-5): both removal gates build a prefix beginning with the deny token and then prepend the token again.
- #851: unverified candidate causes (a write between the resolver's read and the gate's re-read; differing path-equality rules between the resolver and the gate) are recorded in research section 5.3. The diagnostics added here are intended to distinguish them in a recurrence.
- Supporting evidence and line citations: `research/research.2026-10-08T14-00.md` sections 1 through 5. Line numbers there predate C1a and must be re-derived.

## Proposed Fix

### Design summary (what changes where)

1. **pr-author gate: single resolution before Case C.** On the `--body-file` path, `Get-PrAuthorBypassReason` resolves the artifact root once, after Cases A and B and the `gh pr edit` no-body allow and before Case C. The up-front existence probe in `Invoke-PrAuthorSkillDecision` and the `-ContextExists` parameter of `Get-PrAuthorBypassReason` and `Test-PrAuthorBypassRequired` are removed.
   - Non-epic scope: `Get-PrAuthorTargetCheckpointResolution` is extended to return `WorktreeRoot` and `Status` in addition to `CheckpointPath` and `Reason`.
   - Epic scope: `Resolve-EpicScopeCheckpoint` is called before Case C; the artifact root is the worktree that holds the epic checkpoint, derived from `CheckpointPath` by removing the `Get-EpicScopeCheckpointRelativePath` suffix.
   - An unresolvable or ambiguous target denies with the reason code carried on the target result (`TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS`, obtained through `Get-WorktreeResolutionNoTargetReasonCode` and `Get-WorktreeResolutionAmbiguityReasonCode`; the literals are never restated in hook code). This deny takes precedence over `PR_CONTEXT_MISSING`.
   - New deny precedence on the `--body-file` path: target resolution reason, then `PR_CONTEXT_MISSING`, then `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`, then Checks 1 through 6.
2. **pr-author gate: artifact reads beneath the resolved root.** The summary, body, and receipt paths are composed with `Join-WorktreeResolutionPath` beneath the resolved root and passed as absolute paths to the four seams. The summary seams gain a mandatory `-Path` parameter. Check 5 compares the receipt's `created_at` with the summary at the same root. Case C names the worktree: `PR_CONTEXT_MISSING: 'artifacts/pr_context.summary.txt' in worktree '<root>' is absent. ...` (following #690 decision D14).
3. **pr-author gate: Check 1 root binding.**
   - `Status = SessionRoot` (or epic scope whose artifact root equals the session worktree): the relative canonical literal `artifacts/pr_body_<N>.md` and the absolute canonical path beneath the session root are accepted.
   - `Status = OtherWorktree` (or epic scope whose artifact root differs from the session worktree): a relative `--body-file` is denied with `PR_BODY_PATH_NONCANONICAL`, because `gh` would read the session-root copy; the deny names the absolute canonical path the caller must pass.
   - An absolute `--body-file` must equal `Join-WorktreeResolutionPath -WorktreeRoot <resolved root> -RepoRelativePath 'artifacts/pr_body_<N>.md'` after normalization with `ConvertTo-WorktreeResolutionNormalizedPath`. Comparison is `OrdinalIgnoreCase` when either side is drive-rooted or UNC (`//`), `Ordinal` otherwise (the CR-4 rule, applied locally).
   - SessionRoot behavior is otherwise unchanged except that the seams receive absolute paths.
4. **Merge gate: item resolution by pull request number.** A new exported function `Resolve-WorktreeItemTargetByPrNumber -PrNumber <long> -SessionRoot <path>` enumerates live worktree roots through `Get-WorktreeItemLiveRoot`, reads each item checkpoint through the existing seam `Get-WorktreeItemCheckpointText`, and matches when `pr_gate.pr_number` or any `standalone_merge_authorizations[].pr_number` (positive JSON integer) equals N. Zero matches yields `NoTarget`; one yields a resolved result through `ConvertTo-WorktreeItemResolvedResult`; several yield `Ambiguous` without tie-breaking. `enforce-epic-merge-gate-resolution.ps1` imports `WorktreeItemResolution.psm1` inside its existing import guard and exposes a mockable seam `Resolve-EpicMergeGateItemTarget -PrNumber`. With an explicit PR number, `Invoke-EpicMergeGateDecision` resolves the item target once and reads the child checkpoint beneath its `WorktreeRoot`; when unresolved, the child and standalone-child slots hold `$null`. `Get-EpicMergeGateUnresolvedReason` includes the item target, so when no branch allows and the item, epic, and parallel targets are unresolved, the deny prefix carries the code (ambiguity takes precedence, per #690 D8) with the item detail first. A bare `gh pr merge` command keeps the session-root read.
5. **#788 binding.** `Test-ChildCheckpointPrGateBinding` (or its replacement, a pure function in the same file) returns:
   - `$true` when the command carries no PR number (bare command, unchanged);
   - `$false` for a `$null` checkpoint;
   - the equality result when `pr_gate.pr_number` is present (a recorded `pr_gate` is authoritative);
   - otherwise `$true` only when a `standalone_merge_authorizations` entry carries a positive JSON-integer `pr_number` equal to N;
   - otherwise `$false`.
   The gate re-checks the binding on the checkpoint it reads, so a write between the resolver's read and the gate's read cannot produce an unbound allow. When no live checkpoint records N, the deny is `EPIC_MERGE_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: <item detail naming the pull request number and both record fields>; ...` followed by the unchanged standalone reason. No new token is introduced.
6. **#789 CR-4.** `Test-WorktreeRunPathEqual` treats a side matching `^([A-Za-z]:|//)` as case-insensitive; single-slash-rooted POSIX paths stay `Ordinal`. The comment is updated. Zero net lines; no export is added.
7. **#789 CR-5.** Both removal gates build the unresolved prefix as `"<code>: <detail>. "` without the token and emit `'<TOKEN>: ' + <prefix> + <sentence>`. With a resolved target the prefix is empty and the text is byte-identical to today.
8. **#851 diagnostics.** The epic removal gate's read helper returns the checkpoint `Path` it read. A pure diagnostics builder in `enforce-epic-worktree-removal-gate-resolution.ps1` appends a clause to the final deny: for each run kind (epic, parallel), its resolution status, the checkpoint path read (or that none was read), and the `merge_status` of the matching record (`features[]` for epic, `items[]` for parallel), or that no record matched, or that the checkpoint was absent or unparseable. The allow/deny decision and the leading `EPIC_WORKTREE_REMOVAL_BLOCKED:` token are unchanged.

### Boundaries and invariants to preserve

- Every existing deny keeps its leading token (`PR_CONTEXT_MISSING`, `PR_BODY_PATH_NONCANONICAL`, `EPIC_MERGE_GATE_BLOCKED:`, `PARALLEL_WORKTREE_REMOVAL_BLOCKED:`, `EPIC_WORKTREE_REMOVAL_BLOCKED:`, and the remainder of the existing receipt-verification tokens).
- Fail closed for an unresolvable or ambiguous target (epic Shared Design).
- `WorktreeRunResolution.psm1` remains the single resolver for run checkpoints; its export set (pinned by row X1) is unchanged.
- `WorktreeItemResolution.psm1`'s only filesystem read remains the checkpoint-text seam.
- Reason-code literals are obtained only through the `WorktreeResolution.psm1` accessor functions, in hooks and in tests.
- The pr-author gate's behavior for commands without `--body-file` (Cases A and B, `gh pr edit` no-body allow) is unchanged and performs no resolution.
- The merge gate's bare-command behavior and its epic and parallel branches are unchanged.
- The removal gates' allow/deny decisions are unchanged.

### Dependencies or blocked work

- **Upstream C1a (#824, with #742 and #733).** C1a merges into the integration branch before this child's plan executes. It changes Check 1 of `enforce-pr-author-skill(-helpers).ps1` (#733/#715: quoted or absolute `--body-file` values) and the operand handling of both removal gates (#824 addendum 1). The requirements in this spec are written against the post-C1a tree. The plan must, before any edit: rebase onto the integration branch, re-read the affected hooks and `hook-command-invocation.ps1`, re-derive every line citation, confirm whether Check 1 already accepts absolute or quoted paths and relative to which root, confirm whether either removal gate's final deny or operand handling changed, re-measure line counts, and stop if a C3 region was rewritten in a way the research did not anticipate. Where C1a already accepts an absolute body path, this child binds that form to the resolved root rather than the session root.
- Downstream: C4 (#786) and C5b (#737) depend on this child.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

- `.claude/hooks/enforce-pr-author-skill.ps1` (seam `-Path` parameters, removal of the up-front probe, header text).
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (resolution before Case C, root-relative composition, Check 1 root binding, extended resolution result, header text). If the post-C1a line count plus this change would exceed the cap, artifact-root composition and Check 1 binding move to a new dot-sourced sibling (for example `enforce-pr-author-skill.artifact-root.ps1`), registered in `core.json` and mirrored.
- `.claude/hooks/enforce-epic-merge-gate.ps1` (item resolution for an explicit PR number, header text).
- `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` (guarded `WorktreeItemResolution.psm1` import, `Resolve-EpicMergeGateItemTarget`, binding function, unresolved-reason extension).
- `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (`Resolve-WorktreeItemTargetByPrNumber` and its export), or a new module in the same folder if the cap requires one.
- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (CR-4 in place only; the file is at 497 lines and no other change may touch it).
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (CR-5).
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` (single token, `Path` on the read result, diagnostics builder).
- `.claude/rules/orchestrator-state.md` and `.claude/skills/orchestrate/SKILL.md` (documentation alignment).
- Bundled mirrors of each of the above under `extensions/drm-copilot/resources/claude-customizations/`; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and the manifest-suite lists if a new module or sibling is added.

#### Functions/classes/CLI commands impacted

- `Invoke-PrAuthorSkillDecision`, `Get-PrAuthorBypassReason`, `Test-PrAuthorBypassRequired`, `Get-PrAuthorTargetCheckpointResolution`, `Get-PrContextArtifactExistence`, `Get-PrContextSummaryLastWriteUtc`, `Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, and the receipt-verification function containing Checks 1 through 5.
- `Invoke-EpicMergeGateDecision`, `Test-ChildCheckpointPrGateBinding`, `Get-EpicMergeGateUnresolvedReason`, new `Resolve-EpicMergeGateItemTarget`.
- New `Resolve-WorktreeItemTargetByPrNumber`.
- `Test-WorktreeRunPathEqual`.
- The final-deny construction of both removal gates; `Read-EpicWorktreeGateRunCheckpoint` (or the resolution-sibling read helper); new diagnostics builder.

#### Data flow and validation changes

- pr-author: command text -> single target resolution -> artifact root -> absolute artifact paths -> Case C, preflight, Checks 1 through 6. The checkpoint path consumed by the preflight and Check 6 comes from the same resolution.
- Merge gate with explicit N: N -> item target by record -> child checkpoint beneath the item root -> child branch (with binding re-check) and standalone child slot; epic and parallel branches unchanged.

#### Error handling and logging updates

- New deny texts are listed in the design summary. No new leading tokens are introduced.

#### Rollback/feature-flag considerations (if applicable)

- No feature flag. Rollback is a revert of the pull request; the bundled mirrors revert with it.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- `Resolve-WorktreeItemTargetByPrNumber` returns the target-result object constructed by `New-WorktreeResolutionTargetResult` (`Status`, `WorktreeRoot`, `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode`, `Detail`).
- `Get-PrAuthorTargetCheckpointResolution` returns `CheckpointPath`, `Reason`, `WorktreeRoot`, and `Status`.
- The epic removal gate's read helper result gains `Path`.

#### Required configuration keys and defaults

- None.

#### Backward-compatibility expectations

- **Accepted behavior change (#788).** An epic child on a route that records neither `pr_gate` nor a `standalone_merge_authorizations` entry (for example `small`) can no longer merge with an explicit PR number through the child branch; the merge gate fails closed with `EPIC_MERGE_GATE_BLOCKED:` and `TARGET_WORKTREE_NOT_DERIVABLE`. The remedy is to record `pr_gate` or a standalone record. A bare `gh pr merge --merge` is unchanged.
- **Accepted behavior change (#850 pr-author).** A `--body-file` call with an unresolvable or ambiguous target now denies with the resolution reason code instead of `PR_CONTEXT_MISSING`. Both deny.
- **Accepted behavior change (#850 pr-author).** A relative `--body-file` for an `OtherWorktree` target is denied; the caller passes the absolute canonical path named in the deny.
- `-ContextExists` is removed from in-repo dot-sourced functions; all in-repo callers (the hook and its test suites, including `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`) are updated.

#### Performance constraints (latency/throughput/memory)

- One worktree enumeration per gate decision on the affected paths. No additional network or process calls.

## Assumptions, Constraints, Dependencies

- Assumptions: C1a has merged into the integration branch before plan execution. The execution session runs on a batch-budget-exempt route (`large`, `remediation`, or `preparation`) with a non-terminal checkpoint at the batch-budget root, because this child changes more production PowerShell files than the non-exempt cap allows.
- Constraints:
  - No Python in enforcement hooks.
  - No production or test file exceeds 500 lines. `WorktreeRunResolution.psm1` receives only the in-place CR-4 change. New test rows go in new suite files where an existing suite cannot absorb them.
  - Line coverage >= 85% for every changed PowerShell file (PowerShell is exempt from the branch threshold).
  - No temporary files in tests. Tests use synthetic roots (`/synthetic-worktrees/<name>`) with mocked seams and committed read-only fixtures under `tests/fixtures/worktree-resolution/`.
  - No absolute host paths in artifacts or tests.
  - The live hooks govern the executing session; the plan uses a staged-write procedure for gate files (research section 9).
- External dependencies: none beyond PowerShell 7, Pester, and the existing Python parity harness.

## Data / API / Config Impact

- User-facing changes: deny texts listed above; callers outside the item worktree pass an absolute `--body-file`.
- Data or migration: none. Existing checkpoints are read as-is.
- Logging/telemetry: the epic removal gate deny text gains a diagnostics clause.
- Compatibility: the leading tokens of every deny are unchanged.

## Test Strategy

- New suites (names are binding for the acceptance criteria below; the plan may adjust a name only by updating this spec):
  - `tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`
  - `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`
  - `tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1`
  - `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1`
  - `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` (line-cap and test-hermeticity guard for the files changed by this child)
- Updated suites: `enforce-pr-author-skill.Tests.ps1`, `.TargetResolution.Tests.ps1`, `.WorktreeResolution.Tests.ps1` (R1, R4, header), `.OrchestratorStatePreflight.Tests.ps1`, `.EpicScope.Tests.ps1`; `OrchestratorState.Tests.ps1`; `enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1` (M3, M4, M5, M9), `hook-command-parser.AcceptanceCases.Tests.ps1` (default `Resolve-EpicMergeGateItemTarget` mock); `WorktreeRunResolution.Record.Tests.ps1` (new UNC row); `enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`; `enforce-epic-worktree-removal-gate.Tests.ps1` (exact-text row); `enforce-gate-suites.EpicStateIsolation.Tests.ps1` (new pr-author suite added to its list when it reaches `Resolve-EpicScopeCheckpoint`).
- Two-worktree topology tests are required for the pr-author gate and the merge gate's standalone branch, with the item's files absent from the session root.
- Determinism: no wall-clock reads, no temporary files, no network.
- Toolchain: PoshQC format, analyze, and test; direct Pester counts and coverage runs that print results (research section 9); `poetry run pytest` for the parity harness. MCP PoshQC results carry no output and are not used as evidence of counts or percentages.

## Acceptance Criteria

Each criterion is verified by the named Pester or parity test. The research record contains no numeric derivation evidence, and no criterion asserts a count, enumeration, or population of a family; the 500-line cap and the 85% coverage floor are repository policy thresholds.

### #850 pr-author gate

- [x] Two-worktree allow: with the process directory at the committed fixture `pr-author/item-own-not-ready` (no PR artifacts) and the target resolved `OtherWorktree` at `pr-author/item-own-ready`, `gh pr create --body-file <absolute canonical body path beneath item-own-ready> --head <branch>` is allowed. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "allows an OtherWorktree target whose artifacts exist only in the item worktree".
- [x] Two-worktree session-root files ignored: with the process directory at the committed fixture `pr-author/session-root` (all PR artifacts present) and the target resolved `OtherWorktree` at a worktree with no PR artifacts, the decision is a deny beginning with `PR_CONTEXT_MISSING` whose text names the item worktree. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "ignores session-root PR artifacts when the target is another worktree".
- [x] For an `OtherWorktree` target at `/synthetic-worktrees/item-a`, every path received by `Get-PrContextArtifactExistence`, `Get-PrContextSummaryLastWriteUtc`, `Get-PrBodyFileBytes`, and `Get-PrAuthorReceiptContent` begins with `/synthetic-worktrees/item-a/artifacts/`. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "reads summary, body, receipt and summary timestamp beneath the resolved item root".
- [x] The receipt-freshness comparison uses the summary beneath the resolved item root: a receipt older than the item root's summary is denied even when the session root's summary is older than the receipt. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "compares receipt freshness against the item worktree summary".
- [x] Target resolution runs once per `--body-file` decision, before the PR-context check, and its checkpoint path is the one passed to the preflight and Check 6 (`Resolve-PrAuthorWorktreeTarget` asserted with `-Times 1 -Exactly`). Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "resolves the target once and reuses it for artifacts, preflight and Check 6".
- [x] An unresolvable target on a `--body-file` call with no summary at the session root denies with a reason beginning with the value of `Get-WorktreeResolutionNoTargetReasonCode`, not `PR_CONTEXT_MISSING`, and the preflight is not invoked. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "denies an unresolvable target with the no-target code ahead of PR_CONTEXT_MISSING".
- [x] An ambiguous target on a `--body-file` call denies with a reason beginning with the value of `Get-WorktreeResolutionAmbiguityReasonCode`, not `PR_CONTEXT_MISSING`, and the preflight is not invoked. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "denies an ambiguous target with the ambiguity code ahead of PR_CONTEXT_MISSING".
- [x] A relative `--body-file artifacts/pr_body_<N>.md` for an `OtherWorktree` target is denied with `PR_BODY_PATH_NONCANONICAL`, and the deny text names the absolute canonical path `<resolved root>/artifacts/pr_body_<N>.md`. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "denies a relative body path for an OtherWorktree target and names the absolute path".
- [x] An absolute `--body-file` that does not equal the canonical `artifacts/pr_body_<N>.md` path beneath the resolved root (including the session root's absolute path when the target is another worktree) is denied with `PR_BODY_PATH_NONCANONICAL`. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "denies an absolute body path outside the resolved root".
- [x] An absolute canonical body path whose drive-letter or UNC prefix differs only in case from the resolved root is accepted, and a single-slash-rooted path that differs in case is denied. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "applies drive and UNC case-insensitive, POSIX case-sensitive body path comparison".
- [x] For a `SessionRoot` target, the relative canonical body literal is still allowed and the four artifact seams receive absolute paths beneath the session root. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "keeps SessionRoot behavior with absolute artifact paths".
- [x] In epic scope, the PR artifacts are read beneath the worktree that holds the epic checkpoint. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "reads epic-scope PR artifacts beneath the epic checkpoint worktree".
- [x] Commands without `--body-file` (Cases A and B and the `gh pr edit` no-body allow) return their existing decisions and do not invoke `Resolve-PrAuthorWorktreeTarget` or `Resolve-EpicScopeCheckpoint`. Verified by `enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1`, row "performs no resolution for commands without a body file".
- [x] The updated existing pr-author suites pass: `enforce-pr-author-skill.Tests.ps1`, `enforce-pr-author-skill.TargetResolution.Tests.ps1`, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` (R1 rows use the absolute body path; R4 still denies `EPIC_BASE_BRANCH_MISMATCH`), `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, `enforce-pr-author-skill.EpicScope.Tests.ps1`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1`.

### #850 merge gate

- [x] `Resolve-WorktreeItemTargetByPrNumber` resolves a live worktree whose item checkpoint records the number in `pr_gate.pr_number`. Verified by `WorktreeItemResolution.PrNumber.Tests.ps1`, row "resolves the worktree whose pr_gate records the pull request number".
- [x] `Resolve-WorktreeItemTargetByPrNumber` resolves a live worktree whose item checkpoint records the number in a `standalone_merge_authorizations[]` entry with a positive JSON-integer `pr_number`. Verified by `WorktreeItemResolution.PrNumber.Tests.ps1`, row "resolves the worktree whose standalone authorization records the pull request number".
- [x] `Resolve-WorktreeItemTargetByPrNumber` returns `NoTarget` with the no-target reason code when no live checkpoint records the number, and `Ambiguous` with the ambiguity reason code when more than one does. Verified by `WorktreeItemResolution.PrNumber.Tests.ps1`, rows "returns NoTarget when no checkpoint records the number" and "returns Ambiguous when several checkpoints record the number".
- [x] `Resolve-WorktreeItemTargetByPrNumber` reads checkpoints only through `Get-WorktreeItemCheckpointText`, and the module export set equals the prior set plus `Resolve-WorktreeItemTargetByPrNumber`. Verified by `WorktreeItemResolution.PrNumber.Tests.ps1`, rows "reads only through the checkpoint-text seam" and "exports the item-by-PR resolver".
- [x] Two-worktree standalone allow: with `/synthetic-worktrees/item-a` holding a valid standalone authorization for N and the session root `/synthetic-worktrees/session` holding none, `gh pr merge <N> --merge` is allowed and `Get-ChildOrchestratorCheckpointContent` is invoked with the item-a checkpoint path and not the session-root checkpoint path. Verified by `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "authorizes a standalone merge from the item worktree checkpoint".
- [x] Two-worktree stale session-root copy: with `/synthetic-worktrees/item-a` recording N in `pr_gate.pr_number` without a standalone authorization, and the session root holding a copied checkpoint whose standalone authorization records N, the merge is denied with `EPIC_MERGE_GATE_BLOCKED:` followed by the ambiguity reason code, so a session-root copy cannot authorize another worktree's merge. Verified by `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "does not authorize from a session-root copy of another worktree's checkpoint".
- [x] An unresolvable item target with no epic or parallel authorization denies with `EPIC_MERGE_GATE_BLOCKED:` followed by the no-target reason code and the item detail. Verified by `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "denies an unresolvable item target with the no-target code".
- [x] An ambiguous item target denies with `EPIC_MERGE_GATE_BLOCKED:` followed by the ambiguity reason code, and ambiguity takes precedence over a no-target code from the epic or parallel targets. Verified by `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "denies an ambiguous item target with the ambiguity code".
- [x] A mock of `Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution` is observed by the merge gate after dot-sourcing, proving the guarded import order. Verified by `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "observes module-scoped WorktreeItemResolution mocks".
- [x] A bare `gh pr merge --merge` (no PR number) still reads every checkpoint beneath the session root and does not invoke `Resolve-EpicMergeGateItemTarget`. Verified by `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`, row M6, and `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "does not resolve an item target for a bare merge command".
- [x] The updated existing merge-gate suites pass: `enforce-epic-merge-gate.Tests.ps1`, `enforce-epic-merge-gate.Authorization.Tests.ps1`, `enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`, `enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`, and `hook-command-parser.AcceptanceCases.Tests.ps1`.

### #788 PR-number binding

- [x] A merge command with an explicit PR number whose resolved item checkpoint records no `pr_gate` object and no matching standalone entry is denied with `EPIC_MERGE_GATE_BLOCKED:` and the no-target reason code (row M5 flipped from allow to deny). Verified by `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`, row M5, and `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "denies a merge when no checkpoint records the pull request number".
- [x] A merge command whose PR number differs from the governing checkpoint's `pr_gate.pr_number` is denied with a reason beginning `EPIC_MERGE_GATE_BLOCKED:`. Verified by `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "denies a merge whose pull request number differs from pr_gate".
- [x] The binding function returns allow for a bare command, deny for a `$null` checkpoint, the equality result when `pr_gate.pr_number` is present, allow when only a matching positive-integer standalone entry is present, and deny otherwise (including a non-integer or non-positive standalone `pr_number`). Verified by `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, context "child checkpoint pull request binding".
- [x] When the checkpoint read by the gate no longer records N although the resolver matched it, the child branch does not allow. Verified by `enforce-epic-merge-gate.ItemResolution.Tests.ps1`, row "re-checks the binding on the checkpoint the gate reads".

### #789 CR-4 UNC path comparison

- [x] UNC worktree paths recorded with different casing (`//Server/Share/x` and `//server/share/X`) resolve `OtherWorktree` through `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path`. Verified by `WorktreeRunResolution.Record.Tests.ps1`, new row B14 "compares UNC paths case-insensitively".
- [x] Drive-letter comparison stays case-insensitive and single-slash-rooted POSIX comparison stays case-sensitive, and the module export set is unchanged. Verified by `WorktreeRunResolution.Record.Tests.ps1`, rows B11, B12, and X1.

### #789 CR-5 single deny token (parallel and epic removal gates)

- [x] When both run kinds resolve `NoTarget`, the parallel worktree removal gate's deny begins with `PARALLEL_WORKTREE_REMOVAL_BLOCKED: ` and the token does not appear again in the remainder of the text. Verified by `enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`, row "emits a single leading token when both run kinds are unresolved".
- [x] The parallel gate's deny text for a resolved target is byte-identical to the pre-change text. Verified by the exact-text row of `enforce-parallel-worktree-removal-gate.Tests.ps1` and row Y3 of `enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`, both unmodified.
- [x] When both run kinds resolve `NoTarget`, the epic worktree removal gate's deny begins with `EPIC_WORKTREE_REMOVAL_BLOCKED: ` and the token does not appear again in the remainder of the text. Verified by `enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1`, row "emits a single leading token when both run kinds are unresolved".

### #851 epic worktree removal gate diagnostics

- [x] When the epic worktree removal gate denies, the deny text names, for each run kind, its resolution status and the checkpoint path read beneath the resolved root, or states that no checkpoint was read. Verified by `enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1`, row "names each run kind's status and checkpoint path".
- [x] When a matching `features[]` (epic) or `items[]` (parallel) record exists, the deny text names its `merge_status` value; when no record matches, the deny text states that no record matched; when the checkpoint is absent or unparseable, the deny text states that. Verified by `enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1`, rows "names the matched record merge_status", "states that no record matched", and "states that the checkpoint was absent or unparseable".
- [x] The diagnostics builder is a pure function in `enforce-epic-worktree-removal-gate-resolution.ps1` and the read helper's result exposes `Path`. Verified by `enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1`, context "diagnostics builder and read result".
- [x] The allow/deny decision is unchanged: the existing rows of `enforce-epic-worktree-removal-gate.Tests.ps1`, `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1`, and `CleanupWorktreeManifestGateMatrix.Tests.ps1` pass with unchanged expected decisions; only the exact-text row of `enforce-epic-worktree-removal-gate.Tests.ps1` is updated, and only to append the diagnostics clause.

### Mirrors and parity

- [ ] Every changed `.claude` hook, helper, module, rule, and skill file is byte-identical to its mirror under `extensions/drm-copilot/resources/claude-customizations/`. Verified by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- [ ] The pack manifest is complete, including any new module or dot-sourced sibling added by this child. Verified by `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`.
- [ ] Every `.claude/lib/worktree-resolution/*.psm1` module (including any new one) is registered in `core.json`, listed in the manifest suite's expected lists, and SHA-256-identical to its bundle copy. Verified by `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`.
- [ ] The Codex merge and removal gates and their bundled mirrors are unchanged. Verified by `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`.

### Constraints

- [ ] No enforcement hook invokes Python. Verified by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
- [x] No production or test PowerShell file created or changed by this child exceeds 500 lines. Verified by `session-root-reads-850.Constraints.Tests.ps1`, row "keeps every changed file within the line cap".
- [x] No suite created or changed by this child uses `TestDrive`, `GetTempPath`, `New-TemporaryFile`, or another temporary-file API, and none encodes an absolute host path. Verified by `session-root-reads-850.Constraints.Tests.ps1`, row "uses no temporary files and no host paths".
- [ ] Line coverage is at least 85% for every changed production PowerShell file, measured by a Pester code-coverage run whose `CodeCoverage.Path` names the changed files and whose per-file result is not `NA`. Verified by the Pester coverage run over the suites named in this section, recorded under `<FEATURE>/evidence/qa-gates/`.
- [x] The epic gate-suite isolation guard passes with any new pr-author suite that reaches `Resolve-EpicScopeCheckpoint` added to its list. Verified by `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`.

## Risks & Mitigations

- Risk: C1a rewrites a region this spec depends on. Mitigation: the pre-edit re-verification task in the plan; stop and revise the spec if a C3 region was rewritten unexpectedly.
- Risk: a partially written gate takes effect on the executing session's next tool call. Mitigation: staged-write procedure (research section 9).
- Risk: `WorktreeRunResolution.psm1` or `enforce-pr-author-skill-helpers.ps1` breaches the line cap. Mitigation: CR-4 in place only; move pr-author artifact-root logic to a new dot-sourced sibling if needed.
- Risk: epic children on routes without `pr_gate` lose explicit-number merges (#788). Mitigation: documented as an accepted behavior change with its remedy; `orchestrator-state.md` updated.
- Risk: the execution session hits the PowerShell batch budget. Mitigation: execute on an exempt route with a non-terminal checkpoint.

## Rollout & Follow-up

- Release: merged through the epic integration branch with the other C-wave children.
- Follow-up candidates (no issue created by this child): Codex merge and removal gate session-root reads and the Codex #788 equivalent; `gh pr edit <N>` target resolution by pull request number.
- Links: #850, #788, #789, #851, epic #852, closed #690.
