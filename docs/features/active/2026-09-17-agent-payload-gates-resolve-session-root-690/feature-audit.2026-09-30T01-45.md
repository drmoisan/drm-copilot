# Feature Audit: agent-payload-gates-resolve-session-root (#690)

---

**Audit Date:** 2026-09-30
**Feature Folder:** `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`
**Base Branch:** `main`
**Head Branch:** `bug/agent-payload-gates-resolve-session-root-690`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `0d698d6f3edb59546ccf7b661f432274209e92bf`)
- **Head branch/commit:** `bug/agent-payload-gates-resolve-session-root-690` (commit `c47504ae770b5716aa93c572fbb82f3655b27118`)
- **Merge base:** `91805f15ddc5930759d877cf6147467096ad91fe`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-09-30 01:42:29 UTC, head `c47504ae`, merge base `91805f15`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence/**` (baseline, qa-gates, regression-testing, other)
  - Additional evidence: reviewer-run check-only commands recorded in the Verification command(s) column below, and `artifacts/pester/powershell-coverage.xml` (generated 2026-09-30 01:15 UTC, after the last production PowerShell commit `e5549ee1` at 01:05 UTC)
- **Feature folder used:** `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` line 10 carries the explicit marker `- Work Mode: full-bug`; per the work-mode contract, `spec.md` is the sole acceptance-criteria source. `user-story.md` states that it does not duplicate the criteria and maps its scenarios to `spec.md` sections. The `issue.md` "Acceptance Criteria (early draft)" checkboxes are not authoritative in this mode and are not evaluated here.
- **Scope note:** The audit covers the full branch diff against the merge base (242 files; 95 outside `evidence/`). The PR context artifacts were deleted by another session at about 01:40 UTC and regenerated at 01:42 UTC; the regenerated summary was re-read and carries the same head SHA and merge base. Criterion numbers AC-01 to AC-63 follow the order of `spec.md` `## Acceptance Criteria` and match the numbering used in `evidence/other/ac-checkoff.2026-09-30T01-37.md`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md` — only source (63 checkbox items)

### Acceptance criteria

Reproduction
1. (AC-01) Reproduction, admitted: a Pester test models a session root `W_session` holding no epic checkpoint and a separate live worktree `W_epic` holding a ready `epic-orchestrator-state.json` (`route_id: "epic"`, `integration_branch: epic/repro-integration`); an `Agent(orchestrator)` payload carrying the epic kickoff line `Epic mode: true. epic_feature_folder: repro. integration_branch: epic/repro-integration. ...` is allowed by `enforce-orchestration-preimplementation-gate.ps1`, and the readiness read is asserted to target the path under `W_epic`.
2. (AC-02) Reproduction, admitted at the barrier: the same payload and topology is allowed by `enforce-epic-wave-barrier.ps1` when the checkpoint's wave state permits the delegation, with the read asserted to target the path under `W_epic`.
3. (AC-03) Reproduction, denied: the same payload with no live worktree holding an epic checkpoint is denied by `enforce-orchestration-preimplementation-gate.ps1` with a reason containing `PREIMPLEMENTATION_GATE_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`, and by `enforce-epic-wave-barrier.ps1` with a reason containing `EPIC_WAVE_BARRIER_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`.

Run-resolution module
4. (AC-04) `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` exists and exports `Find-WorktreeRunIdentitySignal`, `Get-WorktreeRunCheckpointText`, `Resolve-WorktreeEpicTarget`, `Resolve-WorktreeParallelTarget`, and `Resolve-WorktreeRunTargetByRecord`.
5. (AC-05) Every resolver in the module returns an object with `Status` (one of `SessionRoot`, `OtherWorktree`, `NoTarget`, `Ambiguous`), `WorktreeRoot`, `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode`, and `Detail`, built through `New-WorktreeResolutionTargetResult`, with `ReasonCode` equal to `TARGET_WORKTREE_NOT_DERIVABLE` for `NoTarget` and `TARGET_WORKTREE_AMBIGUOUS` for `Ambiguous`, obtained from the existing accessors.
6. (AC-06) `Find-WorktreeRunIdentitySignal` returns the integration branch from the literal `integration_branch: <name>` inside the epic kickoff sentence (including when followed by `.`), the slug from `epic_feature_folder: <slug>`, and the slug from `parallel_slug: <slug>`, matched case-sensitively, and returns `$null` fields when a literal is absent.
7. (AC-07) `Resolve-WorktreeEpicTarget` returns `NoTarget` for an empty branch and for zero matching live roots, resolves a single match, and returns `Ambiguous` when a supplied `-EpicSlug` disagrees with a match's `epic_feature_folder`.
8. (AC-08) Tie-break: with matching epic checkpoints at the session root and at a second live worktree, `Resolve-WorktreeEpicTarget` resolves `OtherWorktree` to the worktree that has the integration branch checked out; when no match or more than one match has the branch checked out, it returns `Ambiguous` with a `Detail` that names `artifacts/orchestration/handoff/` as the remedy.
9. (AC-09) A live root whose checkpoint text is absent, empty, unparseable, a JSON array, has a `route_id` other than the expected run kind, or has a different `integration_branch`/`parallel_slug` is never counted as a match.
10. (AC-10) `Resolve-WorktreeParallelTarget` resolves exactly one matching live root by `route_id -ceq 'parallel'` and `parallel_slug`, and returns `Ambiguous` when more than one live root matches.
11. (AC-11) `Resolve-WorktreeRunTargetByRecord` resolves epic checkpoints by `epic_merge_pr.pr_number` or `features[].pr_number`, epic checkpoints by `features[].worktree_path`, and parallel checkpoints by `items[].pr_number` or `items[].worktree_path`, with the same zero/one/many rule; `worktree_path` comparison is insensitive to separator style and trailing slashes.
12. (AC-12) `Get-WorktreeRunCheckpointText` is the module's only filesystem read, and no function in the module starts a subprocess, reads the payload `cwd`, reads a wall clock, reads an environment variable, or accesses the network.
13. (AC-13) `ConvertTo-WorktreeItemResolvedResult` is exported from `WorktreeItemResolution.psm1`, and `WorktreeRunResolution.psm1` uses it for `SessionRoot`/`OtherWorktree` labelling rather than a second implementation.

Preimplementation gate
14. (AC-14) Epic-mode delegations resolve through `Resolve-WorktreeEpicTarget` keyed on the payload's `integration_branch:` value, after the existing declared-path cross-check, and read `epic-orchestrator-state.json` beneath the resolved root.
15. (AC-15) Parallel-mode delegations resolve through `Resolve-WorktreeParallelTarget` keyed on `parallel_slug:`, and read `parallel-orchestrator-state.json` beneath the resolved root.
16. (AC-16) Single-feature `Agent` delegations to an allow-listed implementation agent, and non-mode `Agent(orchestrator)` delegations, resolve through `Resolve-WorktreeItemTarget` and read `orchestrator-state.json` beneath the resolved root; `NoTarget` and `Ambiguous` deny with `PREIMPLEMENTATION_GATE_BLOCKED:` and the accessor reason code.
17. (AC-17) A `Write`/`Edit` whose absolute `file_path` lies inside a worktree other than the session root is evaluated against that worktree's `orchestrator-state.json`, and is allowed when that checkpoint is ready and denied when it is absent or not ready.
18. (AC-18) A Bash command leg with a `git -C <dir>` selector inside another worktree is evaluated against that worktree's checkpoint; a command with no selector is evaluated against the session root.
19. (AC-19) `Get-CheckpointContent`, `Get-EpicCheckpointContent`, and `Get-ParallelCheckpointContent` take a mandatory absolute path, and no relative checkpoint literal is passed to `Test-Path` or `Get-Content` by the gate or its dot-sourced siblings.
20. (AC-20) Bound `-CheckpointRaw`, `-EpicCheckpointRaw`, and `-ParallelCheckpointRaw` values bypass resolution, and the existing preimplementation suites pass unchanged in their assertions.

Epic-scope resolution
21. (AC-21) `Resolve-EpicScopeCheckpoint` composes its checkpoint path from the root returned by `Resolve-WorktreeEpicTarget` for the matched branch, not from the session root, and a test shows an epic-scope command leg on the integration branch resolving the checkpoint held by a different live worktree.
22. (AC-22) When no live worktree holds a matching epic checkpoint, `Resolve-EpicScopeCheckpoint` returns `IsEpicScope = $false` with reason `epic-checkpoint-absent-or-unparseable`; when resolution is ambiguous, it returns `IsEpicScope = $false` with reason `target-worktree-ambiguous`; in both cases callers fall through to their existing per-feature resolution.
23. (AC-23) The epic-scope suites for `enforce-model-routing-receipt.ps1` and `enforce-pr-author-skill.ps1` pass, and neither hook file is edited.

Epic wave barrier and parallel cohort barrier
24. (AC-24) `enforce-epic-wave-barrier.ps1` resolves its epic checkpoint through `Resolve-WorktreeEpicTarget` keyed on `integration_branch:`, reads it beneath the resolved root through its existing read seam, and denies `NoTarget`/`Ambiguous` with `EPIC_WAVE_BARRIER_BLOCKED:` and the accessor reason code.
25. (AC-25) `enforce-parallel-cohort-barrier.ps1` resolves its parallel checkpoint through `Resolve-WorktreeParallelTarget` keyed on `parallel_slug:`, reads it beneath the resolved root through its existing read seam, and denies `NoTarget`/`Ambiguous` with its existing leading token and the accessor reason code.
26. (AC-26) `Find-EpicWaveBarrierFeatureFolderFromPrompt` is unchanged (issue #565 scope).

Merge gate
27. (AC-27) Epic branch: `gh pr merge --merge <PR>` with an explicit PR number resolves the epic checkpoint through `Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField pr_number`, and a test shows the merge allowed when the matching ready epic checkpoint is only in a worktree other than the session root.
28. (AC-28) Parallel branch: `gh pr merge --merge <PR>` with an explicit PR number resolves the parallel checkpoint through `Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number`, and a test shows the merge allowed when the matching checkpoint is only in a worktree other than the session root.
29. (AC-29) Child branch: when the session-root per-feature checkpoint records `pr_gate.pr_number` and it differs from the command's PR number, the child branch declines; when they are equal, the existing child-branch decision is unchanged.
30. (AC-30) A bare `gh pr merge --merge` with no PR number is evaluated against the session root exactly as before.
31. (AC-31) When the epic and parallel branches resolve `NoTarget` or `Ambiguous` and no other allow condition applies (including standalone-merge authorization), the gate denies with its existing leading token and the accessor reason code.

Worktree-removal gates
32. (AC-32) `enforce-epic-worktree-removal-gate.ps1` resolves the run checkpoint for `git worktree remove <path>` through `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path`, allows the removal when the resolved checkpoint (in a worktree other than the session root) authorizes it, and denies `NoTarget`/`Ambiguous` with its existing leading token and the accessor reason code.
33. (AC-33) `enforce-parallel-worktree-removal-gate.ps1` resolves the run checkpoint through `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path` with the same allow and deny behaviour.

Parallel drift gate
34. (AC-34) `enforce-parallel-drift-gate.ps1`, for a payload inside its existing scope filter, resolves the parallel checkpoint through `Resolve-WorktreeParallelTarget` keyed on `parallel_slug:`, reads it beneath the resolved root, and denies `NoTarget`/`Ambiguous` with its existing leading token and the accessor reason code.

Import failure (fail-closed)
35. (AC-35) In each converted gate, a failure to import `WorktreeRunResolution.psm1` or `WorktreeItemResolution.psm1` produces a deny decision that names the module, the entry point emits the decision JSON and exits 0, and a Pester test per converted gate simulates the failure through the recorded-failure state without deleting or renaming any file.
36. (AC-36) Fail-closed handling of pre-existing imports and dot-sources, and of hooks this change does not convert, is out of scope; a potential entry recording it exists under `docs/features/potential/`.

Plain single-worktree regression guards
37. (AC-37) A `Write`/`Edit` to a path inside the session worktree, and a Bash command with no `-C` selector, are evaluated against the session root's `orchestrator-state.json` with the same decision as before this change.
38. (AC-38) An epic or parallel kickoff whose only matching checkpoint is at the session root resolves `SessionRoot` and yields the same decision as before this change in the preimplementation gate, the wave barrier, and the cohort barrier.
39. (AC-39) A stale matching epic checkpoint at the session root does not win over the worktree that has the integration branch checked out (no session-root-first fast path).

Identity contract (documented callers)
40. (AC-40) `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency` requires the canonical issue-number line and a `branch: <name>` label on delegations to `python-typed-engineer`, `powershell-typed-engineer`, `typescript-engineer`, `csharp-typed-engineer`, and on non-mode `Agent(orchestrator)` delegations, and names `enforce-orchestration-preimplementation-gate.ps1` among the gates that identify the item from those lines.
41. (AC-41) `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/skills/parallel-orchestrate/SKILL.md` state that the typed-engineer identity lines apply to their child runs, and that the gates key epic runs on `integration_branch:` and parallel runs on `parallel_slug:`.
42. (AC-42) Each `.claude/skills/invoke-*-engineer/SKILL.md` that delegates to an allow-listed implementation agent documents the canonical issue-number line and `branch:` label in its delegation prompt.
43. (AC-43) The contract text changes land no later than the commit that wires the preimplementation gate.

Registration, mirrors, and guard test
44. (AC-44) Each `.claude` file created or changed by this work has a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
45. (AC-45) `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` appears once in the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and any new dot-sourced hook sibling created by this work is also listed there.
46. (AC-46) `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` lists `WorktreeRunResolution.psm1` in each of its module lists and passes, including the on-disk registration row and the SHA-256 mirror row.
47. (AC-47) `WorktreeRunResolution.psm1` is added to `CodeCoverage.Path` in both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and the two copies remain text-identical.
48. (AC-48) `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` guards `Get-WorktreeRunCheckpointText` as well as `Get-EpicScopeCheckpointText`, its pinned read-count assertion matches the new `Resolve-EpicScopeCheckpoint` contract, each suite it guards that reaches the new seam mocks it `$null`, and the suite passes.

Tests and determinism
49. (AC-49) Each converted gate has Pester rows for (a) a checkpoint present only in a synthetic target worktree that differs from the session root, allowed or evaluated against that checkpoint, (b) a target with no checkpoint anywhere, denied with `TARGET_WORKTREE_NOT_DERIVABLE`, and (c) an ambiguous target, denied with `TARGET_WORKTREE_AMBIGUOUS`.
50. (AC-50) Gate and library tests use the PR #695 seam (a mocked live-root enumeration with committed fixtures, or a mocked single text-read function); no test creates, writes, or deletes a file, and no test uses `TestDrive:`.
51. (AC-51) Every existing suite for a converted gate mocks the new resolution seam in `BeforeAll` so that no existing row enumerates live worktrees on the host, and every existing row passes.
52. (AC-52) Line coverage for `WorktreeRunResolution.psm1` is at or above 85%, read per file from the Pester coverage report, and changed lines in converted files show no coverage regression against the baseline recorded under `evidence/baseline/`.
53. (AC-53) `WorktreeRunResolution.psm1` satisfies `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with the new module in its scan scope.

File size
54. (AC-54) `WorktreeResolution.psm1` and `enforce-orchestration-preimplementation-gate-helpers.ps1` are byte-unchanged.
55. (AC-55) `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-orchestration-preimplementation-gate-modes.ps1`, `enforce-epic-merge-gate-authorization.ps1`, `enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `WorktreeRunResolution.psm1`, and every other production or test file created or edited by this work are at or below 500 lines.
56. (AC-56) `enforce-orchestration-preimplementation-gate-modes.ps1` gains no identity-parsing logic, and the preimplementation gate's resolution glue and `Get-CheckpointContent` live in `enforce-orchestration-preimplementation-gate-epic-scope.ps1`.

Rollout safety
57. (AC-57) The commit that adds `WorktreeRunResolution.psm1` (with its export change, mirror, `core.json` entry, manifest test, runsettings entries, and library tests) changes no hook file, and no hook imports the module at that commit.
58. (AC-58) Each gate is wired by a single complete `Write` of each hook file it changes (no sequence of partial `Edit` calls on a live hook), followed by that gate's Pester suites before the next gate is wired; the order of writes and each suite result is recorded under `evidence/qa-gates/` in this feature folder.
59. (AC-59) Before the preimplementation gate commit, the executor confirms and records under `evidence/qa-gates/` that the session's own pending implementation delegations carry the canonical issue-number line and `branch:` label.
60. (AC-60) Each gate is committed together with its dot-sourced siblings and mirrors, so no commit leaves a hook importing a function that is absent at that commit.

Toolchain and follow-ups
61. (AC-61) The PowerShell toolchain (PoshQC format, then analyze, then test) completes in a single pass with no failure and no modified file, and the observed output is recorded under `evidence/qa-gates/`.
62. (AC-62) No file under `.codex/` is changed, no Python file is changed except the frozen-surface digest pin in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (re-baselined for the intended AC-41 edit to `.claude/skills/epic-orchestrate/SKILL.md`), and neither `validate-orchestrator-output.ps1` nor `Find-EpicWaveBarrierFeatureFolderFromPrompt` is changed.
63. (AC-63) Potential entries under `docs/features/potential/` record the session-relative read in `validate-orchestrator-output.ps1` (SubagentStop) and the merge-gate child-branch residual for routes without `pr_gate.pr_number`.

---

## Acceptance Criteria Evaluation

Reviewer runs referenced below:
- **RV-PESTER-CHANGED**: Pester over all 45 added or modified `*.Tests.ps1` files plus `ClaudeLibModuleConvention.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`: 1139 total, 1139 passed, 0 failed.
- **RV-PESTER-NEW**: Pester over the 12 added suites: 138/138 passed (per-suite counts in the policy audit Appendix A).
- **RV-PESTER-FULL**: Pester over `tests/scripts/claude-hooks` (2150/2150 passed), `tests/scripts/claude-lib`, and `tests/scripts/claude-runtime` (results in the policy audit section 6).
- **RV-QC**: `Invoke-Formatter` comparison and `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the 72 added or modified `.ps1`/`.psm1`/`.psd1` files: 0 formatting differences, 0 diagnostics, 0 files over 500 lines.
- **RV-MIRROR**: SHA-256 of each of the 19 changed `.claude` files against its bundle mirror: 19 equal, 0 unequal; the two runsettings copies are equal.
- **RV-COV**: parse of `artifacts/pester/powershell-coverage.xml` against `git diff -U0 91805f15..HEAD`.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01 reproduction admitted (preimplementation gate) | PASS | `enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1` row R1 asserts `Get-EpicCheckpointContent` is invoked once with `-Path /synthetic-worktrees/w-epic/...` | RV-PESTER-NEW | 15/15 rows pass in that suite |
| 2 | AC-02 reproduction admitted at the wave barrier | PASS | `enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1` (9/9); `evidence/regression-testing/wave-worktree-resolution.2026-09-29T23-58.md` | RV-PESTER-NEW | |
| 3 | AC-03 reproduction denied with `TARGET_WORKTREE_NOT_DERIVABLE` in both hooks | PASS | Preimplementation row R2 (read seam invoked 0 times); wave barrier suite rows W1/W2 per `ac-checkoff` record | RV-PESTER-NEW | |
| 4 | AC-04 module exists with the five exports | PASS | `WorktreeRunResolution.psm1` lines 486-493 export the five named functions plus `Get-WorktreeRunCheckpointPath` and `Resolve-WorktreeOperandTarget` | `git diff 91805f15 HEAD -- .claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | Two additional exports are supporting surface, not a conflict with the criterion |
| 5 | AC-05 result shape and reason codes via accessors | PASS | Module uses `New-WorktreeResolutionTargetResult` for NoTarget/Ambiguous and `ConvertTo-WorktreeItemResolvedResult` for resolved results; `WorktreeRunResolution.Record.Tests.ps1` rows X1, C1 | RV-PESTER-NEW | |
| 6 | AC-06 signal extraction | PASS | `WorktreeRunResolution.Signal.Tests.ps1` 16/16; patterns at module lines 47-49 with trailing `.` removal at line 68 | RV-PESTER-NEW | A prompt naming two distinct values yields `$null` (fail-closed) |
| 7 | AC-07 epic resolver zero/one/slug-disagreement | PASS | `WorktreeRunResolution.Tests.ps1` rows E1-E6 | RV-PESTER-NEW | |
| 8 | AC-08 tie-break and handoff remedy | PASS | Rows E7-E9; module lines 294-305 name `artifacts/orchestration/handoff/` | RV-PESTER-NEW | |
| 9 | AC-09 non-matching checkpoint shapes | PASS | Rows E10-E15, R4-R7; `ConvertFrom-WorktreeRunCheckpointText` uses `-NoEnumerate` and a PSCustomObject type check | RV-PESTER-NEW | |
| 10 | AC-10 parallel resolver | PASS | Rows R1-R3 | RV-PESTER-NEW | |
| 11 | AC-11 record resolver | PASS | `WorktreeRunResolution.Record.Tests.ps1` 27/27 (B1-B12); `Test-WorktreeRunPathEqual` normalises separators and trailing slashes | RV-PESTER-NEW | Case-insensitivity applies to drive-letter paths only (see code review CR-4) |
| 12 | AC-12 single filesystem read, no subprocess/cwd/clock/env/network | PASS | Module inspection: only `Get-WorktreeRunCheckpointText` calls `Test-Path`/`ReadAllText`; no `$env:`, `Get-Date`, `Start-Process`, or `&` invocation; AST test U1-U3 | RV-PESTER-NEW; module read | |
| 13 | AC-13 shared labelling function | PASS | `WorktreeItemResolution.psm1` export change; module calls `ConvertTo-WorktreeItemResolvedResult` at lines 226, 290, 299, 469, 479, 482 | `git diff 91805f15 HEAD -- .claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | |
| 14 | AC-14 epic-mode delegation resolution | PASS | `Resolve-OrchestrationGateTarget` epic branch; gate reads via `Read-OrchestrationGateCheckpoint` only when `-EpicCheckpointRaw` is unbound | RV-PESTER-CHANGED; diff read | |
| 15 | AC-15 parallel-mode delegation resolution | PASS | Row R4 asserts the parallel read path beneath the other worktree | RV-PESTER-NEW | |
| 16 | AC-16 single-feature Agent leg resolution and deny | PASS | Rows R7-R10; R8 asserts no live-root enumeration on a delegation without identity lines | RV-PESTER-NEW | Behaviour change for untargeted delegations is documented in spec Backward-compatibility |
| 17 | AC-17 Write/Edit path leg | PASS | `enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` 10/10 | RV-PESTER-NEW | |
| 18 | AC-18 Bash `git -C` leg | PASS | OperandResolution suite; `Resolve-OrchestrationGateTarget` passes `Get-OrchestrationEpicScopeSelector` output to `Resolve-WorktreeOperandTarget` | RV-PESTER-NEW | |
| 19 | AC-19 mandatory absolute path on read seams | PASS | All three seams declare `[Parameter(Mandatory)][ValidatePattern('^([A-Za-z]:[\\/]|/)')]`; `$script:CheckpointPath` literal removed from the gate | diff read | |
| 20 | AC-20 injection bypass and existing suites unchanged | PASS | Rows R13-R15 assert `Resolve-OrchestrationGateTarget` invoked 0 times; modified preimplementation suites pass | RV-PESTER-CHANGED | Existing-suite edits are default-mock additions (1-4 lines each) |
| 21 | AC-21 epic-scope checkpoint from resolved root | PASS | `EpicScopeResolution.RunTarget.Tests.ps1` 4/4 | RV-PESTER-NEW | |
| 22 | AC-22 NoTarget/Ambiguous reasons in epic scope | PASS | RunTarget rows N1-N3; `EpicScopeResolution.Tests.ps1` passes | RV-PESTER-CHANGED | |
| 23 | AC-23 caller suites pass, caller hooks unedited | PASS | `enforce-model-routing-receipt.ps1` and `enforce-pr-author-skill.ps1` changed=0; their EpicScope suites pass | RV-QC protected-file check; RV-PESTER-CHANGED | |
| 24 | AC-24 wave barrier conversion | PASS | Wave barrier WorktreeResolution suite 9/9; changed executable lines 14/14 covered | RV-PESTER-NEW; RV-COV | |
| 25 | AC-25 cohort barrier conversion | PASS | Cohort WorktreeResolution suite 7/7 | RV-PESTER-NEW | |
| 26 | AC-26 `Find-EpicWaveBarrierFeatureFolderFromPrompt` unchanged | PASS | The function appears only as diff context lines; `evidence/qa-gates/wave-folder-function-final.2026-09-30T01-36.md` records FUNCTION-TEXT-EQUAL=True | `git diff 91805f15 HEAD -- .claude/hooks/enforce-epic-wave-barrier.ps1` | |
| 27 | AC-27 merge gate epic branch by PR number | PASS | Merge WorktreeResolution suite 10/10 (M1-M9) | RV-PESTER-NEW | |
| 28 | AC-28 merge gate parallel branch by PR number | PASS | Same suite | RV-PESTER-NEW | |
| 29 | AC-29 child-branch `pr_gate.pr_number` binding | PASS | `Test-ChildCheckpointPrGateBinding` in `enforce-epic-merge-gate-resolution.ps1` lines 152-189; suite rows | RV-PESTER-NEW | Residual for routes without `pr_gate` recorded as a potential entry |
| 30 | AC-30 bare merge evaluated at session root | PASS | Gate sets `$epicRoot`/`$parallelRoot` to the session worktree when `$commandPrNumber` is null | diff read; RV-PESTER-NEW | |
| 31 | AC-31 unresolved run branches deny with reason code | PASS | `Get-EpicMergeGateUnresolvedReason` prefix on the standalone deny | RV-PESTER-NEW | |
| 32 | AC-32 epic removal gate by worktree_path | PASS | Epic removal WorktreeResolution suite 6/6; `evidence/qa-gates/coverage-erem.2026-09-30T01-17.md` | RV-PESTER-NEW | |
| 33 | AC-33 parallel removal gate by worktree_path | PASS | Parallel removal WorktreeResolution suite 6/6 | RV-PESTER-NEW | |
| 34 | AC-34 drift gate conversion | PASS | Drift WorktreeResolution suite 6/6 | RV-PESTER-NEW | Drift-gate marker forwarding remains unverified upstream, as stated in the spec risks |
| 35 | AC-35 import-failure fail-closed per gate | PASS | Rows O7-O8, W7, C5, M10, V6, Y6, D6; each gate checks its recorded-failure variable before other logic | RV-PESTER-CHANGED | Rows mock `Import-Module`; no file is renamed or deleted |
| 36 | AC-36 potential entry for pre-existing imports | PASS | `docs/features/potential/2026-09-29-hook-preexisting-imports-fail-open.md` added | `git diff --name-status 91805f15 HEAD -- docs/features/potential` | |
| 37 | AC-37 plain single-worktree Write/Edit/Bash unchanged | PASS | Rows R11-R12 and OperandResolution session rows; existing suites pass | RV-PESTER-CHANGED | |
| 38 | AC-38 session-root-only kickoff unchanged | PASS | Row R11 (preimplementation), wave W5-W6, cohort C4 | RV-PESTER-CHANGED | |
| 39 | AC-39 no session-root-first fast path | PASS | Row R12 asserts the read targets `w-epic` over a stale session-root copy; resolver enumerates all live roots | RV-PESTER-NEW | |
| 40 | AC-40 orchestrate skill contract | PASS | Added paragraph in `.claude/skills/orchestrate/SKILL.md` names the four typed engineers, `atomic-executor`, non-mode orchestrator delegations, and the gate | `git diff 91805f15 HEAD -- .claude/skills/` | |
| 41 | AC-41 epic and parallel skill contract | PASS | Added paragraphs in `epic-orchestrate` and `parallel-orchestrate` skills | same | |
| 42 | AC-42 invoke-*-engineer contract | PASS | `## Delegation Identity Lines` added to the Python, PowerShell, and C# invoke skills | same | No `invoke-typescript-engineer` skill exists in `.claude/skills/`; the criterion scopes to skills that exist |
| 43 | AC-43 contract text before gate wiring | PASS | Commit `0dcb1cf5` (19:41 local) precedes `25069b47` (19:53 local) | `git log --format="%h %cI %s" 91805f15..HEAD` | |
| 44 | AC-44 mirrors byte-identical and bundle contract test passes | UNVERIFIED | Mirror half verified (RV-MIRROR 19/19 equal). The named pytest node fails locally with `Repo file missing from bundle: .claude\state\current-session-id`; that path is gitignored (`.gitignore:68`), is host session state, and the same node failed identically at baseline (`evidence/baseline/python-parity.2026-09-29T23-11.md`) | `poetry run pytest -q -rf tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py ...` (1 failed, 52 passed) | Cannot pass in this environment (issue #510 pattern); requires a green CI run on the PR head. Left unchecked |
| 45 | AC-45 core.json registration | PASS | `WorktreeRunResolution.psm1` count 1; the two new `-resolution.ps1` siblings count 2 | `grep -c` on `pack-manifests/core.json` | |
| 46 | AC-46 manifest test | PASS | `WorktreeResolution.Manifest.Tests.ps1` modified and passing | RV-PESTER-CHANGED | |
| 47 | AC-47 runsettings entries and parity | PASS | Entries present at lines 48, 51, 324 of the repo copy; both copies hash-equal | RV-MIRROR | |
| 48 | AC-48 isolation guard extension | PASS | Guard predicate moved to `EpicStateIsolation.Helpers.ps1` and extended to `Get-WorktreeRunCheckpointText`; suite passes | RV-PESTER-CHANGED | |
| 49 | AC-49 per-gate other-worktree / NoTarget / Ambiguous rows | PASS | Eight gate WorktreeResolution suites (G1A, G1B, G2-G7) all pass | RV-PESTER-NEW | |
| 50 | AC-50 no file-writing tests, no `TestDrive:` | PASS | Added test lines contain no `TestDrive`, `New-TemporaryFile`, `Set-Content`, `Out-File`, `New-Item`, `Remove-Item`, `Start-Sleep`, or `$env:`; the one `Get-Date` token is an AST assertion literal | `git diff -U0 91805f15 HEAD -- tests/ \| grep -nE ...` | |
| 51 | AC-51 default seam mocks, existing rows pass | PASS | claude-hooks tree 2150/2150 | RV-PESTER-FULL | |
| 52 | AC-52 WRR coverage >= 85% and no changed-line regression | PASS | `evidence/qa-gates/coverage-lib.2026-09-30T01-17.md` (WRR 146/146 = 100%); `changed-line-coverage.2026-09-30T01-18.md`; RV-COV confirms the 10 modified production files at 92.86%-100% with changed-line coverage 93.94%-100% | RV-COV | WRR and the two new hook siblings are absent from the canonical artifact (see policy audit gap G-2); WRR figure is taken from the executor QA record |
| 53 | AC-53 module convention and no-Python scan | PASS | Both suites included in RV-PESTER-CHANGED and passing | RV-PESTER-CHANGED | |
| 54 | AC-54 two files byte-unchanged | PASS | `git diff --name-only` count 0 for both | RV-QC protected-file check | |
| 55 | AC-55 500-line limit | PASS | 0 of 72 PowerShell files over 500; the changed Python file is a short constants module | RV-QC | |
| 56 | AC-56 modes file gains no parsing; glue in epic-scope sibling | PASS | `enforce-orchestration-preimplementation-gate-modes.ps1` not in the diff; `Get-CheckpointContent` and resolution glue in the epic-scope sibling | `git diff --name-only 91805f15 HEAD` | |
| 57 | AC-57 module commit changes no hook | PASS | `d120a539` touches 0 files under `hooks/` | `git show --name-only --format= d120a539` | |
| 58 | AC-58 single-Write wiring and recorded order | PASS | `evidence/qa-gates/gate-wiring-order.md` records write order and suite results | file read | Write-versus-Edit method is attested by the executor record; the reviewer cannot observe tool calls |
| 59 | AC-59 pending delegation identity confirmed | PASS | `evidence/qa-gates/pending-delegation-identity.2026-09-29T23-42.md` | file read | |
| 60 | AC-60 gate commits include siblings and mirrors | PASS | Each gate commit (`25069b47`, `db6a075d`, `83d89c60`, `a696d710`, `ad2f8f41`, `8f566bfb`, `06e7b653`, `dd39cef8`) contains the hook, its new sibling where one exists, and the mirrors | `git show --name-only` per commit | |
| 61 | AC-61 PowerShell toolchain single pass | PASS | `powershell-format.2026-09-30T01-06.md`, `powershell-analyze.2026-09-30T01-06.md`, `powershell-mcp-test.2026-09-30T01-17.md`; reviewer RV-QC reproduces 0 format changes and 0 diagnostics | RV-QC | |
| 62 | AC-62 no `.codex` change; only the pin among Python files | PASS | `.codex` changed=0; the only `.py` file in the diff is `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | `git diff --name-status 91805f15 HEAD` | Criterion amended 2026-09-30 per the spec Change Log |
| 63 | AC-63 potential entries for follow-ups | PASS | `2026-09-29-validate-orchestrator-output-session-relative-read.md` and `2026-09-29-merge-gate-child-branch-without-pr-gate.md` added | same | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

The delivered behaviour satisfies 62 of 63 criteria on inspected evidence. The one open criterion (AC-44) depends on a CI run. The readiness verdict is NEEDS REVISION rather than PASS because the policy audit records a mandatory coverage-evidence FAIL for Python (no `artifacts/python/lcov.info` for a branch that changes a Python file). That finding is an evidence gap, not a behaviour defect.

**Criteria summary:**
- **PASS:** 62 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-44: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` cannot pass locally because of gitignored host state (`.claude/state/current-session-id`); a green CI run on the PR head is required.
2. Policy audit: Python coverage artifact `artifacts/python/lcov.info` is absent although one Python file changed.
3. Policy audit (non-blocking): the canonical PowerShell coverage artifact omits the three new production files, so their coverage figures rest on executor QA records.

**Recommended follow-up verification steps:**

1. Generate `artifacts/python/lcov.info` at the branch head with `poetry run pytest --cov --cov-branch` and record repo-wide Python line and branch percentages under `evidence/qa-gates/`.
2. After the PR is opened, record the CI result of `test_bundled_claude_payload_contains_all_repo_runtime_contracts` on the head SHA, then check off AC-44.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md`
- Total AC items: 63
- Checked off (delivered): 62
- Remaining (unchecked): 1
- Items remaining: AC-44 "Each `.claude` file created or changed by this work has a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 63 | 62 | 1 | Checkbox-backed; authoritative for `full-bug` |
| `issue.md` | 4 (early draft) | 4 | 0 | Not authoritative in `full-bug` mode; checked by the executor, not evaluated here |

No source-file checkbox change was made in this review: every criterion evaluated PASS was already checked by the executor (`evidence/other/ac-checkoff.2026-09-30T01-37.md`), and AC-44 remains unchecked because it is UNVERIFIED.
