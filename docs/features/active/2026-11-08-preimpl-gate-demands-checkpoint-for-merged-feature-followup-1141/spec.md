# preimpl-gate-demands-checkpoint-for-merged-feature-followup (Spec)

- **Issue:** #1141
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T19-30
- **Status:** Approved
- **Version:** 1.0

## Context
When an agent performs a follow-up on a feature whose PR has already merged into an epic integration branch, the preimplementation gate demands a readiness checkpoint for that feature. No documented, gate-recognized path exists, so agents hand-author a readiness checkpoint (`lifecycle_ready` plus receipts) to pass the gate. Impact: High.

Environment: Windows 11 Pro, Claude Code CLI; PowerShell hooks; `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08. Authoritative analysis of current behavior: `research/research.2026-11-08T19-00.md`.

## Repro & Evidence
1. Run an epic until feature F has merged into `epic/<slug>-integration` (`merge_status` `merged` or `worktree_removed`).
2. In the integration worktree, before fan-in is complete, attempt a follow-up for F, for example `git commit -F <abs>/msg.txt -- docs/features/active/<F>/evidence/other/x.md`, or a pathless `git commit -m <msg>` after staging only paths under F's folder.
3. Actual: deny with the `merge-in-progress` readiness-failure text (epic scope) or the single-feature `PREIMPLEMENTATION_GATE_BLOCKED` text (item worktree). Expected: the epic-scope call is admitted through a narrow, auditable allowance derived from the epic checkpoint, with no hand-authored checkpoint.

## Root Cause Analysis
In epic scope, `Get-EpicCommandLegReadinessFailure` returns `merge-in-progress` for every structurally valid epic checkpoint when no `MERGE_HEAD` exists. The only lift is the #1136 post-fan-in allowance (fan-in complete; status document and `artifacts/pr_body_<N>.*` only). The #539 bookkeeping exemption does not model `-F`/`--file`, pathless commits, or `docs/features/completed/`. The gate has no state for "feature already merged; follow-up in progress", so agents fall back to the item worktree and hand-author a checkpoint that `Test-OrchestrationReady` accepts.

## Scope & Non-Goals
- In scope: an epic-scope merged-feature follow-up allowance on the Claude and Codex gates; skill and brief documentation; mirrors and pins.
- Out of scope:
  - Standalone (non-epic) merged features. After merge, no gate-trusted record of the merge remains (the item checkpoint lives in a normally removed worktree and is gitignored), and the explicit-pathspec `-m` docs follow-up forms already pass there today. Code corrections go through a normal orchestrated run.
  - Finding 9 (stop hook validating the wrong worktree's checkpoint).
  - Changes to the single-feature path, the #539 exemption, or any deny text.

## Proposed Fix

### Design summary
Research design (A). Add a merged-feature follow-up allowance read only from the epic checkpoint, plugged in as a second disjunct of the `-ReadinessFailure` scriptblock of `Get-OrchestrationEpicScopeDecision` on both surfaces, guarded by the exact readiness failure `merge-in-progress` (`-ceq`). Fan-in completeness is not required. The allowance reuses `hook-epic-fan-in.ps1`; no fan-in code is duplicated.

### Qualifying feature state
A `features[]` entry of the resolved epic checkpoint qualifies only when all hold:
- `merge_status` is `merged` or `worktree_removed` (reuse `$script:EpicFanInTerminalMergeStatuses`).
- `feature_folder` basename, after stripping an optional `docs/features/active/` or `docs/features/completed/` prefix, matches `$script:EpicFanInSlugPattern` (plain slug; no `/`, `\`, `..`).
- `merge_commit_sha` is a string of exactly 40 or 64 lowercase hex characters.
- `pr_number` is a JSON integer greater than 0 (strings, floats, booleans, null rejected).

The epic-orchestrate skill merge-mirror step already records `merge_commit_sha` and `pr_number` per feature (verified by the orchestrator on a real epic checkpoint: all 17 `worktree_removed` entries carry both). No new producer is added; the skill text must state that the step records them.

### Allowed paths and calls
Allowed roots per qualifying feature: `docs/features/active/<basename>/` and `docs/features/completed/<basename>/` (trailing slash required), plus the epic status document from `Get-EpicFanInStatusDocRelativePath`.
- Write/Edit: every path, relative to `Scope.WorktreeRoot`, lies under an allowed root.
- `git [-C <abs>] add [--] <p...>`: every operand under an allowed root.
- `git [-C <abs>] commit`: options limited to `-m`, `--message`, `-F`, `--file`, `--trailer`; and either `-- <p...>` with every operand under an allowed root, or no pathspec with a non-empty staged index (`Get-OrchestrationGateStagedIndex`) whose every entry lies under an allowed root.
- Denied (unchanged deny text): any path outside the roots (including code), `-a`/`--all`, `--amend`, `-A`, any other flag, globs, `..` segments, backslashes, chained non-git segments, sibling-prefix folders (`<basename>-x/`), entries with non-terminal status, missing or malformed provenance, or a basename that fails the slug pattern.

### Provenance rule
The epic checkpoint entry is the only evidence. A per-item `artifacts/orchestration/orchestrator-state.json` (including a hand-authored one with `lifecycle_ready`) is never read or accepted by this allowance.

### Implementation strategy
- `hook-epic-fan-in.ps1` (all four byte-identical copies): generalize `Get-EpicFanInShapeDetail`/`Test-EpicFanInCommitShape` and `Test-EpicFanInStagedIndex` from one status-doc path to an allowed-path predicate (the #1136 behavior becomes the one-path case); add `Get-EpicMergedFeatureRoots` and `Get-EpicMergedFeatureFollowUpAllowance -Scope -FilePath -Command -StagedIndexReader`. Pure; no file reads or processes.
- Claude `enforce-orchestration-preimplementation-gate-epic-scope.ps1` and Codex twin (plus bundles): add the disjunct. If `hook-epic-fan-in.ps1` would exceed 500 lines, move root derivation into a new sibling and add manifest entries.
- Rollback: revert the disjunct; the allowance is allow-side only.

### Documented path
Follow-ups on a merged epic child are made in the integration worktree on the integration branch via this allowance. Code corrections are not follow-ups and go through a new orchestrated child. Agents never hand-author a readiness checkpoint.

## Assumptions, Constraints, Dependencies
- Assumes the epic checkpoint is written by the epic orchestrator (same trust source as #1136).
- Constraints: PowerShell only; no new Python (the only Python change is the `PINNED_FROZEN_SURFACE_HASHES` constant); parallel test gates only; Linux hook-suite rules (forward slashes, no drive letters, exact case).

## Test Strategy
- Unit: `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1` rows for root derivation, generalized predicates, and unchanged #1136 rows.
- Gate level: new `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1` (pattern of `...EpicFanIn.Tests.ps1`, mocks only, synthetic `/synthetic-worktrees/...` roots, no files); Codex rows in `tests/scripts/codex-hooks/` (existing epic-fan-in file or a new sibling).
- Gates: one `Invoke-PoshQCParallelTest` run; one `pytest -n auto` run; `Invoke-PoshQCLeakScan`; Codex generator `--check`.

## Acceptance Criteria
- [x] Fail-before evidence: the new gate-level test file is run against the unmodified hooks and the rows `git commit -F <abs>/msg.txt -- docs/features/active/<F>/evidence/other/x.md` and pathless `git commit -m msg` (index entirely under F's folder) both deny with the `merge-in-progress` text; the run is recorded under `evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`.
- [x] After the fix, in epic scope with readiness failure `merge-in-progress` and fan-in incomplete, Write/Edit, `git add`, `git commit -- <paths>`, and pathless `git commit` (with `-m`, `--message`, `-F`, `--file`, `--trailer`) whose paths all lie under `docs/features/active/<basename>/` or `docs/features/completed/<basename>/` of a qualifying feature, or the epic status document, are allowed on both Claude and Codex surfaces (test rows on each).
- [x] A feature qualifies only when `merge_status` is `merged` or `worktree_removed`, the `feature_folder` basename (after prefix stripping) matches `$script:EpicFanInSlugPattern`, `merge_commit_sha` is 40 or 64 lowercase hex, and `pr_number` is a JSON integer > 0; unit rows cover each conjunct's pass and fail cases (including uppercase hex, wrong length, string/zero/negative/null `pr_number`).
- [x] A follow-up whose epic entry lacks `merge_commit_sha` is denied with the unchanged deny text, on both surfaces.
- [x] A follow-up whose epic entry lacks `pr_number` is denied with the unchanged deny text, on both surfaces.
- [x] A follow-up for a feature with non-terminal `merge_status` (for example `pr_open`) is denied with the unchanged deny text.
- [x] With a hand-authored per-item `artifacts/orchestration/orchestrator-state.json` (`lifecycle_ready: true`) present in the integration worktree, a write or commit outside the allowance (for example `scripts/x.ps1`) is still denied with the unchanged deny text, and the new allowance code reads no per-item checkpoint.
- [x] Denied with unchanged text: paths outside the allowed roots, sibling-prefix folders (`<basename>-x/`), `..` segments, backslashes, `-a`/`--all`, `--amend`, `-A`, any commit flag other than the five listed, a pathless commit with an empty index, and a pathless commit whose index mixes allowed and disallowed entries.
- [x] The allowance applies only when the readiness failure is exactly `merge-in-progress`; a row with any other readiness failure (for example an in-progress merge) stays denied with its existing text.
- [x] Non-regression: every call admitted before the change stays admitted, including the #1136 post-fan-in allowance rows and the #539 bookkeeping exemption rows, asserted by existing tests that pass unchanged.
- [x] Non-regression: every existing deny text (single-feature `PREIMPLEMENTATION_GATE_BLOCKED`, `merge-in-progress`, `target-not-ready`) is byte-unchanged, and the single-feature deny outside epic scope is unchanged; asserted by test rows.
- [x] `hook-epic-fan-in.ps1` implements the allowance by generalizing `Get-EpicFanInShapeDetail`/`Test-EpicFanInCommitShape` and `Test-EpicFanInStagedIndex` to an allowed-path predicate and adding `Get-EpicMergedFeatureFollowUpAllowance` in the same file; no fan-in logic is duplicated, and existing #1136 unit rows pass unchanged.
- [x] Each new or changed function has unit rows in `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1`; new code reaches >= 90% line coverage and no touched file's line coverage drops versus baseline (`artifacts/pester/powershell-coverage.xml`).
- [x] All four `hook-epic-fan-in.ps1` copies are byte-identical; Claude and Codex epic-scope siblings match their bundle copies; if a hook file is added, its bundle copies and pack manifest entries are added and dependency-closure tests pass.
- [x] `epic-orchestrate/SKILL.md` (`.claude`, `.agents`, and both bundle copies under `extensions/drm-copilot/resources/`) documents, beside the post-fan-in allowance paragraph: the merged-feature follow-up allowance and its allowed paths and commands; that the merge-mirror step records `merge_commit_sha` and `pr_number` per feature; that code corrections go through a new orchestrated child; and the explicit rule that agents never hand-author a readiness checkpoint.
- [x] `orchestrate/SKILL.md` (`.claude`, `.agents`, and both bundle copies) carries a pointer paragraph to the follow-up path, the never-hand-author rule, and that standalone merged features use the explicit-pathspec `-m` docs form or a new orchestrated run. No `.github` copy exists for either skill; none is created.
- [x] The `Post-fan-in allowance (#1136)` bullet in `## Hook Execution Context` of the execution-environment brief is extended with the merged-feature follow-up allowance in all six copies, which remain byte-identical.
- [x] `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` carries the new digest of `.claude/skills/epic-orchestrate/SKILL.md` with a dated comment in the established style.
- [x] Push-down contract tests (resource parity, pack manifest, dependency closure, surface expectations, `hook-dependency-guard-completeness.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `concurrent-review-skill-contract.Tests.ps1`) and the Codex generator `--check` pass.
- [x] Verification uses one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, both passing; no serial or single-process run is used as evidence; no new Python file is added.

## Residual Risks / Out of Scope
- Pre-existing: `Test-OrchestrationReady` on the single-feature path accepts any checkpoint carrying the four required fields, including a hand-authored one. This change does not alter that path; the new allowance accepts no item checkpoint as evidence. Track separately.
- A same-session writer can edit the epic checkpoint; this is a policy-level control, as with #1136.
- File size: `hook-epic-fan-in.ps1` approaches the 500-line guidance and the Codex epic-scope sibling exceeds 440 lines; measure before and after.
- Destinations receive the change through a push-down refresh after the extension release; outside this item.
