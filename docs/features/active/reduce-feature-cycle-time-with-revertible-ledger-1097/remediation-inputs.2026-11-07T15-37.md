# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T15-37
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: light
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T15-37.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T15-37.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T15-37.md`
Head reviewed: `377c187bcc4dd3acc190c7b78f4a26c204c660bd` (merge base `bad886e304990d26af56d6bcabc9d543518492e9`)

This file supersedes `remediation-inputs.2026-11-07T13-39.md`, whose findings F1 and N1 are closed at this head. It is the combined review of stage E, its remediation, and stage E2.

Light-path conditions, as read by the reviewer: one finding, `autonomous`, contained; the fix touches a mirror family of a file in the branch diff, one test file in the branch diff, and ledger entry `0006` with its stored patch; no spec criterion, public interface, validator contract, hook decision, or production logic changes; the cycle is opened by this review; the prior cycle (`remediation-plan.2026-11-07T13-39.md`) was proportionate, not light.

## Findings requiring remediation

### F1 — The Codex executor family lacks the stage E2 comparison sentence

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix copies one existing sentence into a hand-edited Codex profile, regenerates its variants and bundles with the repository generator, adds a token to three existing test rows, and updates ledger entry 0006; no owner decision, external system, or CI result is needed.
Finding-Scope: contained

- Files: `.codex/agents/atomic-executor.toml`; generated variants `.codex/agents/atomic-executor-c1.toml`, `-c2.toml`, `-c3.toml`, `-c3-elevated.toml`, `-c4.toml`; their six bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`; `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`; `docs/engineering/process-reductions/0006-test-suite-baseline-restored.md` and `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch`.
- Problem: stage E2 added to `.claude/agents/atomic-executor.md` `## Toolchain Commands` the sentence "The Phase 0 baseline and the final gate are each one run of these gates, and the final gate is compared with the `Phase 0 baseline`: no new failing test and no per-file or repo-wide coverage drop." The Codex base has the same section, identical apart from that sentence, and was not changed. The E2 plan's B9 row names Codex bases and generated variants. The test rows `EXEC-CLAUDE` and `EXEC-CODEX` are a pinned pair, but neither requires `Phase 0 baseline`, so the gap passes every gate.
- Required change: see `## Light Fix Tasks`. All of it in one commit whose subject carries `reduction: 0006`.
- Verification required: the `## Toolchain Commands` sections of `.claude/agents/atomic-executor.md` and `.codex/agents/atomic-executor.toml` are identical; `generate_codex_agent_variants --check` exits 0; each bundle equals its source; `Test-ProcessReductionLedger` valid; `git apply -R --check` of the regenerated `0006` patch exits 0; one `Invoke-PoshQCParallelTest` run with 0 failures, compared with `evidence/baseline/stage-e2-powershell-test-baseline.2026-11-07T14-22.md`; one `pytest -n auto` run with coverage, 0 failures, compared with `evidence/baseline/stage-e2-python-test-baseline.2026-11-07T14-25.md` (the Codex generator and bundle contract tests are Python); re-review.

## Light Fix Tasks

- [ ] [P0-T1] F1: in `.codex/agents/atomic-executor.toml` `## Toolchain Commands`, insert the sentence quoted under F1, byte-identical to `.claude/agents/atomic-executor.md`, with its blank line, after "Run toolchain in order: format, lint, type-check, test. Restart from step 1 if any step fails or changes files."; then run `scripts/dev_tools/generate_codex_agent_variants.py` in module form and again with `--check`, so the five variants and six bundle copies carry it.
- [ ] [P0-T2] F1: in `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, add `'Phase 0 baseline'` to the `Required` lists of rows `EXEC-CLAUDE`, `EXEC-CLAUDE-BUNDLE`, and `EXEC-CODEX`; leave every forbidden list and the sweep tokens unchanged.
- [ ] [P0-T3] F1: in `docs/engineering/process-reductions/0006-test-suite-baseline-restored.md` `## Files Changed`, add the twelve Codex executor paths of F1 with their kind (hand-edited Codex agent, generated variant, bundle); regenerate `patches/0006-test-suite-baseline-restored.patch` with `git diff --binary --no-renames` from the first parent of the `reduction: 0006` partial-revert commit over the full path set; commit P0-T1 to P0-T3 together with `reduction: 0006` in the subject; then run the gates named under F1 and record them under `FEATURE/evidence/qa-gates/` with the `stage-e2-` prefix.

## Non-remediation items (record only)

From `code-review.2026-11-07T15-37.md`. None stops the merge.

- N1, Minor: `spec.md` and `user-story.md` carry no E2 row or criterion. Amendment is a planning-agent or owner action; the reviewer may not add criteria. Class if made blocking: `human_decision_required`.
- N2, Minor: the restored "no repo-wide coverage drop" rule compares raw totals, and Python branch arc 395 to 362 of the unchanged `scripts/dev_tools/atomic_executor/cli_copilot_runtime.py` is timing-dependent (11765, 11766, 11765 across three runs of the same file text). Recommended for the owner: state the comparison precision or keep repo-wide totals threshold-only. The light cycle's gates may meet the same one-branch difference; it is not a regression of the branch.
- N3, Nit: the partial revert took two `reduction: 0006` commits because the first omitted the five template sources. No action.
- N4, Nit: the baseline-part inventory predates the restore. No action.

## CI

CI run 42386503847, `workflow_dispatch` on head `377c187bc`, was `in_progress` when this review was written. The orchestrator reads its result; S9 owns `ci_gate.conclusion` at the final head.

## Constraints for the next step

- These review artifacts are uncommitted in the item worktree and lie inside the feature folder.
- Entries `0004`, `0005`, and `0006` read `Merge commit: pending (PR #1097)`. The orchestrator replaces the number after the pull request opens; that file lies outside the feature folder, so CI and `ci_gate.head_sha` must then be read at the new head.
- Tests run in parallel only, per `spec.md` `## Testing Rule`: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix; no single-process, seeded-shuffle, reversed-order, or comparison run.
- No Epic #1019 folder, admitted plan, or other plan file in this folder is edited.
