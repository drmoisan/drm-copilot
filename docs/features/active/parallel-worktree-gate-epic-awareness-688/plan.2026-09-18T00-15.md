# Plan: parallel worktree gate epic awareness (Issue #688)

- Work Mode: full-bug
- Route: small (1 production file + 1 test file)
- Canonical issue number: 688

## Required References

- Spec: `docs/features/active/parallel-worktree-gate-epic-awareness-688/spec.md`
- `.claude/rules/powershell.md`, `.claude/rules/general-code-change.md`,
  `.claude/rules/general-unit-test.md`

## Phase 0 — Baseline

- [ ] [P0-T1] Capture the current Pester result for
      `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` and record the
      pass count as the regression baseline.
- [ ] [P0-T2] Record the current line coverage for
      `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.

## Phase 1 — Epic-aware branch

- [ ] [P1-T1] Add an injectable epic-checkpoint read seam to
      `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, mirroring the existing
      `Get-ParallelWorktreeRemovalGateCheckpointContent` convention, reading
      `artifacts/orchestration/epic-orchestrator-state.json`.
- [ ] [P1-T2] Add a `features[]` record lookup that matches by normalized `worktree_path`, reusing
      the gate's existing path-normalization helper rather than reimplementing it.
- [ ] [P1-T3] Insert the epic-authorization branch AFTER the existing parallel `items[]` allow and
      BEFORE the cleanup-manifest branch, allowing only when the matched record's `merge_status` is
      `merged` or `worktree_removed`. Leave the manifest branch and the final deny unchanged.
- [ ] [P1-T4] Verify a malformed or unreadable epic checkpoint yields no record and therefore falls
      through to the unchanged deny.

## Phase 2 — Tests

- [ ] [P2-T1] Add table-driven Pester cases for: epic-authorized allow; epic record with an unsafe
      `merge_status` deny; neither checkpoint covers the target deny; malformed epic checkpoint deny.
- [ ] [P2-T2] Add regression guards asserting the existing parallel cases are unchanged (parallel
      `merged` allows, parallel unmerged denies, manifest branch still authorizes its own cases).
- [ ] [P2-T3] Assert the `PARALLEL_WORKTREE_REMOVAL_BLOCKED` reason code text is unchanged for the
      deny paths.

## Phase 3 — Toolchain and QA

- [ ] [P3-T1] Run the PoshQC toolchain to green: format, analyze, test.
- [ ] [P3-T2] Confirm line coverage >= 85% for the changed file and no regression against the P0-T2
      baseline.
- [ ] [P3-T3] Confirm the changed hook stays under the 500-line cap.

## Phase 4 — Delivery

- [ ] [P4-T1] Commit, push, open the PR via `Agent(pr-author)`, and confirm CI green.
- [ ] [P4-T2] After merge, verify a real merged epic child worktree removal is allowed end to end.
