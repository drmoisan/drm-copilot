# Remediation Inputs — Issue 1105

Timestamp: 2026-11-07T15-37
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/policy-audit.2026-11-07T15-37.md`
- `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/code-review.2026-11-07T15-37.md`
- `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/feature-audit.2026-11-07T15-37.md`
Head reviewed: `98028900a19973e8467846b5962170488529c5b1` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`)
Remediation plan target: `docs/features/active/2026-11-07-hooks-read-main-checkout-not-item-worktree-1105/remediation-plan.2026-11-07T15-37.md`

## Findings requiring remediation

### F1 — Gate-admitted prompt shapes do not resolve in the SubagentStop helper

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The change is confined to the helper and the coverage hook message, both already in the branch diff, plus new test cases; it needs no external party, policy decision, owner input, or CI result, and `Resolve-HookTargetWorktree` stays unchanged.

- Files: `.claude/hooks/subagentstop-target-worktree.ps1` (`Resolve-SubagentStopTargetWorktree`, lines 176-186), `.claude/hooks/validate-feature-review-coverage.ps1` (unresolved-target message), their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1`, `tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1`, and one artifact-hook `*.TargetWorktree.Tests.ps1`.
- Problem: the helper passes the full delegation prompt to `Resolve-HookTargetWorktree` without a `CheckpointIssueReader`. That resolver collects every `branch:` token and cannot place an issue line without a reader. The model-routing gate (`Resolve-WorktreeItemTarget`) admits the same prompts: it reads only the first `branch:` occurrence, which `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency` defines as the item label, and it places an issue-only prompt through the worktree checkpoints. Real-process reviewer probes:
  - an issue-line-only prompt returned `TARGET_WORKTREE_NOT_DERIVABLE` ("issue 1 cannot be placed without a checkpoint issue reader");
  - `branch: feature/x-1` followed by `base branch: main` returned `TARGET_WORKTREE_AMBIGUOUS` ("the prompt names 2 different branches").

  With `stop_hook_active` true in a main-checkout session, the coverage hook returned a repairable block for relative paths. For absolute paths inside the session root it returned the location-rule block. The review therefore cannot stop cleanly, although it passed before this branch. In an item-worktree session the five artifact hooks fall back to the session root for these shapes, which is the defect #1105 fixes.
- Required change:
  1. In `Resolve-SubagentStopTargetWorktree`, build the `DelegationPrompt` argument from the first `branch:` label (same pattern as the gate's `Find-WorktreeResolutionBranchSignal`) and the canonical issue line or lines, not from the whole prompt.
  2. Supply a `CheckpointIssueReader` so an issue-line-only prompt resolves as it does at the gate. Reuse the existing checkpoint issue reader in `.claude/lib/worktree-resolution/` behind a guarded import. Do not add a resolver, and do not edit `Resolve-HookTargetWorktree`, `Resolve-WorktreeItemTarget`, or `subagentstop-envelope.ps1`. Keep the reader injectable as a `[scriptblock]` parameter so tests read no file.
  3. Correct the coverage hook's unresolved-target message so it does not advise absolute paths when the target would resolve to the session root. Keep the `validate-feature-review-coverage:` stem and the reason code in the text.
  4. Keep the session-root case unchanged: a prompt with no identity, a branch label naming the session root's branch, and an absolute path inside the session root must still return the session root with the advertised value unchanged.
- Verification required:
  (a) Helper suite cases: issue-line-only prompt with an injected reader resolves to the item root; a reader that finds no worktree gives `TARGET_WORKTREE_NOT_DERIVABLE`; `branch: <item>` followed by `base branch: main` resolves to the item root.
  (b) A coverage-suite case for each shape in a main-checkout session with `stop_hook_active` true, showing the review can pass when its artifacts exist.
  (c) One artifact-hook case for the second-`branch:` shape in an item-worktree session, showing the item copy is read.
  (d) The pre-existing suites still pass with no `ParameterFilter` edits.
  (e) The bundle copies stay byte-identical (`cmp`), and the guard suites pass.
  (f) Format, analyze, then one `Invoke-PoshQCParallelTest` run; the helper stays at or above 85% line coverage.

## Non-remediation items (record only; recommended for the same cycle)

These come from `code-review.2026-11-07T15-37.md`. Neither stops the merge.

- F2, Minor: `Get-ExecutorOutputBlockDecision` in `validate-executor-output.ps1` reads the transcript head twice for a relative `plan-path` (resolution, then `Test-IsPreflightRun`). `spec.md` sets one 50-line read per invocation. Read once and pass the lines to both.
- F3, Nit: `Resolve-SubagentStopArtifactPath` joins a relative value with `..` segments beneath the item root unchanged. The class pre-dates the branch; optionally reject `..` segments before the shape rules.

## Constraints

- Enforcement hooks stay PowerShell only and invoke no Python.
- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run, and one `pytest -n auto` run, which the mirror contracts need.
- Tests create no files. Every transcript, worktree list, checkpoint, git, and file read goes through a mockable function or a declared `[scriptblock]` parameter, and fixture roots stay `/`-rooted forward-slash paths.
- No edited file exceeds 800 logical lines (`validate-planner-output.ps1` is at 469; the helper at 292).
- Keep the hook, bundle, manifest, and brief copies in step. If the brief text changes, update all six byte-identical copies.
- Any code commit makes this review stale, so a re-review follows. Criterion 16 stays unchecked until S9.
