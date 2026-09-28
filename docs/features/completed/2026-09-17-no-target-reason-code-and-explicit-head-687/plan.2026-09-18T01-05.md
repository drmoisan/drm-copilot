# Plan: NoTarget reason code and explicit --head (Issue #687)

- Work Mode: full-bug
- Route: large (module + 2 hooks + skill/agent contract + tests + bundle mirrors)
- Canonical issue number: 687

## Required References

- Spec: `docs/features/active/2026-09-17-no-target-reason-code-and-explicit-head-687/spec.md`
- `.claude/rules/powershell.md`, `.claude/rules/general-code-change.md`,
  `.claude/rules/general-unit-test.md`

## Phase 0 — Baseline

- [ ] [P0-T1] Record the current pass counts for the worktree-resolution suites and both PR-gate
      suites; these are the regression baselines.
- [ ] [P0-T2] Record current line coverage for the module and both gates.

## Phase 1 — NoTarget reason code (R1, AC-1, AC-2)

- [ ] [P1-T1] Add a distinct `NoTarget` reason-code constant and its accessor to
      `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, beside the existing
      ambiguity-code accessor.
- [ ] [P1-T2] Populate `ReasonCode` for `Status = NoTarget`, leaving it null for `SessionRoot` and
      `OtherWorktree` and unchanged for `Ambiguous`.
- [ ] [P1-T3] Add Pester cases asserting the code for each of the four states, and that the
      ambiguity code value is unchanged.

## Phase 2 — PR gates resolve against the call target (R2, AC-3..AC-7)

- [ ] [P2-T1] In `.claude/hooks/enforce-pr-author-skill.ps1`, resolve the call target through the
      module and derive the checkpoint path from the resolved worktree instead of the
      session-root-relative constant.
- [ ] [P2-T2] Deny with the resolution's `ReasonCode` when the status is `NoTarget` or `Ambiguous`
      for a `gh pr create` / `gh pr edit --body*` call.
- [ ] [P2-T3] Apply the same two changes to `.claude/hooks/enforce-model-routing-receipt.ps1`.
- [ ] [P2-T4] Preserve every existing decision when the status is `SessionRoot`, including the
      five ordered receipt checks and the `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` path.
- [ ] [P2-T5] Add Pester cases: `--head` naming a sibling worktree validates that worktree's
      checkpoint; a sibling checkpoint alone with no target denies with the NoTarget code; an
      ambiguous payload denies with the ambiguity code; standalone is unchanged; a genuinely
      missing document still denies.

## Phase 3 — pr-author passes an explicit head (R3, AC-8)

- [ ] [P3-T1] Require `--head <branch>` in `.claude/skills/pr-author/SKILL.md` where the
      `gh pr create` command is specified.
- [ ] [P3-T2] Mirror the requirement in `.claude/agents/pr-author.md`.
- [ ] [P3-T3] State the rationale briefly: the branch signal is what makes the call's target
      derivable, so the gate never has to infer an item from the session's cwd.

## Phase 4 — Bundle mirrors (AC-9)

- [ ] [P4-T1] Copy every changed `.claude/**` file to
      `extensions/drm-copilot/resources/claude-customizations/.claude/` and verify byte-identical
      SHA-256 for each pair.
- [ ] [P4-T2] Add any new file to `pack-manifests/core.json` if one is introduced.
- [ ] [P4-T3] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

## Phase 5 — Toolchain and QA

- [ ] [P5-T1] PSScriptAnalyzer per changed file: 0 errors, 0 warnings.
- [ ] [P5-T2] Pester: all changed suites pass, with no regression against the P0-T1 baselines.
- [ ] [P5-T3] Line coverage >= 85% for every changed production file.
- [ ] [P5-T4] Full `poetry run pytest` run before pushing, because the bundle-parity contract is
      enforced on the Python side and was missed on the first push for #688.
- [ ] [P5-T5] Confirm every changed file stays under the 500-line cap.

## Phase 6 — Delivery

- [ ] [P6-T1] Commit, push, open the PR, and confirm CI green.
- [ ] [P6-T2] After merge, confirm #673 can resume: its halting condition no longer holds because
      a `NoTarget` result now carries an emittable code and pr-author supplies `--head`.
