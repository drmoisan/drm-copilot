---
epic: enforcement-hook-precision
integration_branch: epic/enforcement-hook-precision-integration
created_at: 2026-10-08T08:30
intent:
  epic_type: enabler
  business_outcome_hypothesis: Agents stop losing remediation rounds to enforcement-hook false denies, and no enforcement hook fails open on an import error, a stdout write, an unnormalized operand, or a session-root read.
  leading_indicators:
    - The reproduction commands recorded in #824, #742 and #733 are allowed, and every currently gated invocation is still denied without an authorizing checkpoint.
    - A delegation prompt that cites a nested artifact or an upstream folder resolves to the declared target feature folder in every hook that resolves one.
    - A two-worktree topology test passes for every gate that reads a run checkpoint, PR context, or merge authorization.
    - An import-failure seam produces a deny decision in every hook that imports a module.
  nfrs:
    - Enforcement hooks gain no Python legs.
    - No production file exceeds the 500-line cap.
    - Line coverage >= 85% for every changed PowerShell file.
    - Claude, Codex, and bundled copies of each changed hook stay byte-identical where they are required to be.
features:
  - issue_num: 824
    feature_folder: promotion-hook-raw-containment-false-positive-deny-824
    depends_on: []
  - issue_num: 565
    feature_folder: 2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565
    depends_on: []
  - issue_num: 736
    feature_folder: 2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736
    depends_on: []
  - issue_num: 732
    feature_folder: 2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732
    depends_on: [824, 565]
  - issue_num: 850
    feature_folder: 2026-10-08-pr-author-and-merge-gates-read-session-root-files-850
    depends_on: [824]
  - issue_num: 787
    feature_folder: 2026-09-29-validate-orchestrator-output-session-relative-read-787
    depends_on: [565]
  - issue_num: 786
    feature_folder: 2026-09-29-hook-preexisting-imports-fail-open-786
    depends_on: [732, 850, 787]
  - issue_num: 737
    feature_folder: 2026-09-27-hook-test-isolation-remaining-gaps-737
    depends_on: [736, 732, 850]
---

# Epic: Enforcement Hook Precision

Epic issue: #852.

> **Manifest status.** Resolved on 2026-10-08. Each child is keyed by its primary existing issue,
> and every `feature_folder` value was back-filled from the prepared child's active folder at
> fan-in. C1a's folder carries no date prefix, and its branch is
> `bug/promotion-hook-raw-containment-false-positive-deny-824-r2` because an earlier local #824
> branch exists.

## Goal

Make the enforcement hooks under `.claude/hooks/`, their Codex copies under `.codex/hooks/`, and
their bundled mirrors under `extensions/drm-copilot/resources/` decide on precise evidence: the
invocation the hook governs, the feature folder the delegation targets, the worktree that owns the
run, and the fully resolved path of each operand. Remove the fail-open paths that let a hook exit
without a decision.

## Children

Each child is one independently mergeable feature with its own feature folder and pull request.
The primary issue keys the child in the manifest; the secondary issues are delivered by the same
child and are closed by its pull request. No new child issues are created.

| Child | Primary | Secondary issues | Wave | Band |
| --- | --- | --- | --- | --- |
| C1a command-invocation matching | #824 | #742, #733 | 1 | C3 |
| C2 feature-folder resolution | #565 | #568, #696 | 1 | C3 |
| C5a completion-consistency parity | #736 | none | 1 | C2 |
| C1b preimplementation operand and scope precision | #732 | #738, #745, #735 | 2 | C4 |
| C3 residual session-root reads | #850 | #788, #789, #851 | 2 | C3 |
| C6 SubagentStop output validator | #787 | #840 | 2 | C3 |
| C4 hooks that fail open on import errors | #786 | #792 | 3 | C3 |
| C5b test hermeticity and parity | #737 | #746 | 3 | C2 |

Waves are numbered from 1 in this narrative; the manifest computation numbers them from 0.

## Scope

- **C1a (#824, #742, #733).** Replace substring containment in the raw-containment fallback of
  `.claude/hooks/hook-command-invocation.ps1` with a token-aware match of the governed invocation,
  applied to wrapper-led (`pwsh -Command`, `bash -c`) and substitution segments, keeping
  fail-closed behavior for unbalanced segments. Consumers: `enforce-promotion-mcp-only.ps1` (#824
  main defect), `enforce-epic-worktree-removal-gate.ps1` and
  `enforce-parallel-worktree-removal-gate.ps1` (#824 addendum 1, including the empty-operand false
  positive signature), the worktree isolation guard and the evidence-filename Write guard (#742),
  and `enforce-pr-author-skill.ps1` plus the `pr-author` allowlist chaining boundary (#733). **#824
  addendum 2 (the #823 follow-ups FU-823-1/2/3/5 and review notes A/B) is out of scope; it belongs
  to the concurrent parallel run.**
- **C2 (#565, #568, #696).** Anchor feature-folder resolution on the declared target folder rather
  than the longest `docs/features/active/` match, in `enforce-epic-wave-barrier.ps1`,
  `enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1`,
  `enforce-orchestration-preimplementation-gate-modes.ps1:236`, and the epic child-launch gate
  (consolidated #566, #567 and the #770 occurrence). PR #569 (#518) is the reference fix. Make
  `enforce-feature-folder-order.ps1` work-mode aware and match timestamped plan files (#568). Add
  direct coverage of `Get-PrdFeatureCheckpointFolder` (#696).
- **C5a (#736).** Make the Codex `enforce-completion-consistency.ps1` read the Edit call's target
  file, reproduce the Edit tool's single-occurrence replace semantics (honoring `replace_all`) on
  both surfaces, and fail closed on a missing or unreadable checkpoint on both surfaces. Replace the
  working-directory-dependent tests.
- **C1b (#732, #738, #745, #735).** First a research step (#735): determine which shell Codex uses
  on Windows before any Codex command parsing is changed, and record the finding. Then make
  `Test-ExemptOrchestrationOperand` (and its copies) exempt an operand only when its fully resolved
  path, after brace expansion and dot-segment normalization, lies in an exempt tree (#732); resolve
  every segment's effective `git -C` target in epic-scope resolution on both surfaces (#738); and
  close the trailer documentation and test gaps (#745).
- **C3 (#850, #788, #789, #851).** Resolve the item's worktree once in `enforce-pr-author-skill.ps1`
  and in the standalone-merge branch of `enforce-epic-merge-gate.ps1`, and read the PR context,
  body, receipt, and merge authorization beneath it (#850). Bind the merge command's pull request
  number for every route (#788). Fix the UNC case comparison in `Test-WorktreeRunPathEqual` and the
  doubled deny token (#789). **#851 has no reproduction: the child adds diagnostics only** (the
  deny text names the run kind that resolved, the checkpoint path read, and the `merge_status`
  found); it does not change the allow/deny decision.
- **C6 (#787, #840).** Make `validate-orchestrator-output.ps1` resolve the run checkpoint through
  `WorktreeRunResolution.psm1` (#787). **Operator decision for #840: port the wave-barrier Layer 2
  ordering check to PowerShell and invoke it from `validate-orchestrator-output.ps1`. No Python in
  hooks.** The port must agree with `validate_epic_orchestrator_state_text` on the
  `EPIC_WAVE_BARRIER_VIOLATION` cases, proven by a parity fixture set.
- **C4 (#786, #792).** Guard every module import and sibling dot-source in PreToolUse and
  SubagentStop hooks so a failure emits a deny decision naming the dependency (#786), and add a
  repository guard that fails when a module imported by a hook writes to the success or warning
  stream (#792). The dependency list is enumerated against the tree as it stands after waves 1 and
  2 merge.
- **C5b (#737, #746).** Make every gate suite on both surfaces hermetic against local orchestration
  state, make the structural guards discover their targets, extend the no-Python guard to
  `.codex/hooks`, add the preimplementation-gate Claude/Codex parity test and the
  `GENERATED_AGENT_FAMILIES` parity test (#737 consolidation), and apply the leading-comma fix in
  `Get-CodexPreToolUseRegistration` (#746). **#335 is closed as obsolete and is not in scope.**

Every child also updates the bundled mirrors under `extensions/drm-copilot/resources/` for each
file it changes, and keeps the bundle-parity tests green.

## Non-Goals

- #824 addendum 2 (#823 follow-ups); delivered by the concurrent parallel run.
- #335 (closed as obsolete).
- Any behavior change for #851 beyond diagnostics.
- A bash or Python port of any hook.

## Dependency Rationale

Edges are drawn only where a child consumes a contract or edits a file that an upstream child
changes.

- **#732 (C1b) depends on #824 (C1a) and #565 (C2).** C1b's per-segment target resolution (#738)
  consumes the segment and wrapper matching that C1a rewrites in `hook-command-invocation.ps1`, and
  C1b edits the preimplementation gate family (`-helpers.ps1`, `-modes.ps1`) whose folder
  resolution C2 changes at `-modes.ps1:236`.
- **#850 (C3) depends on #824 (C1a).** C3 edits `enforce-pr-author-skill.ps1`,
  `enforce-epic-worktree-removal-gate.ps1`, and `enforce-parallel-worktree-removal-gate.ps1`, all of
  which C1a changes.
- **#787 (C6) depends on #565 (C2).** #840 corrects the Layer 2 documentation in
  `enforce-epic-wave-barrier.ps1`, which C2 rewrites, and the Layer 2 port shares the epic
  checkpoint feature lookup that C2 anchors.
- **#786 (C4) depends on #732, #850, and #787.** C4 enumerates and guards every hook import; C1b,
  C3, and C6 each add or move imports (`WorktreeRunResolution.psm1` in
  `validate-orchestrator-output.ps1`, worktree resolution in the pr-author and merge gates, and the
  per-segment resolver), so the enumeration is valid only after they merge.
- **#737 (C5b) depends on #736, #732, and #850.** C5b's discovery guards and parity tests cover the
  Codex completion-consistency suite rewritten by C5a, the preimplementation gate pair changed by
  C1b, and the epic merge and removal gate suites changed by C3.

Wave computation (longest-path layering, 0-indexed): wave 0 = {824, 565, 736}; wave 1 = {732,
850, 787}; wave 2 = {786, 737}. No cycles; every reference resolves.

## Shared Design

- `hook-command-invocation.ps1` is owned by C1a. Later children consume its matching API and do
  not re-implement substring matching.
- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` is the single resolver for run
  checkpoints and item worktrees. C3 and C6 consume it; C3 owns its #789 corrections.
- Deny reasons keep their existing leading tokens so consumers that match on them are unaffected.
- Fail-closed is the repository norm for an unresolvable or ambiguous target.

## Complexity Assessment

- C1a, C3 (cross_module_contract_change): shared matcher or resolver consumed by several hooks;
  band C3.
- C2 (cross_module_contract_change): one resolution rule applied across five gates; band C3.
- C6 (cross_module_contract_change, concurrency_or_ordering): new SubagentStop check that must
  agree with the Python authority on wave ordering; band C3.
- C4 (cross_module_contract_change): every hook's import prologue plus a new repository guard;
  band C3.
- C1b (auth_or_token_handling analogue: a gate bypass, plus research on an undocumented shell);
  band C4 by judgment.
- C5a, C5b: localized to one hook pair or to test suites and one function; band C2.
