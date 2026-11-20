# Acceptance-Criteria Verification (Issue #1010, P6-T1)

Timestamp: 2026-10-30T21-31
Command: per-AC review of the evidence below; git diff --merge-base origin/main -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1, every enforce-orchestration-preimplementation-gate-targets.ps1 copy, .claude/lib/worktree-resolution/HookTargetWorktree.psm1, .codex/hooks/hook-target-worktree.ps1 (0 diff lines); sed check-off of spec.md AC-01 to AC-23 (git diff --numstat: 23 insertions, 23 deletions)
EXIT_CODE: 0
Output Summary: 23 of 23 criteria PASS and are checked off in spec.md. No criterion depends on CI on the PR head, so none is pending-CI.

Source: `FEATURE/spec.md` (work mode full-bug; `## Acceptance Criteria`, 23 checkbox items).

| AC | Status | Implementing task(s) | Proving test(s) | Evidence artifact |
|---|---|---|---|---|
| AC-01 Phase 0 dependency check | PASS | P0-T2, P0-T3 | `HookTargetWorktree.Tests.ps1` (83/83), Codex `hook-target-worktree.Tests.ps1` (83/83) | `baseline/resolver-dependency.2026-10-30T20-36.md`, `baseline/codex-twin-and-manifest.2026-10-30T20-37.md` |
| AC-02 Claude git-commit leg | PASS | P1-T1, P3-T2 | B1, T4 | `regression-testing/fail-before-claude-target-worktree.2026-10-30T20-52.md`, `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-03 Claude git-add leg | PASS | P1-T1, P3-T2 | B3, T5 | `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-04 Claude later-segment selector | PASS | P1-T1, P3-T2 | B2, T6 | `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-05 Claude Write/Edit | PASS | P3-T2, P4-T1 | T1 to T3, O1, O4 to O6 | `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md`, `qa-gates/pester-coverage.2026-10-30T21-08.md` |
| AC-06 Codex Write/Edit | PASS | P3-T3, P3-T4 | C1 to C3 | `regression-testing/fail-before-codex-target-worktree.2026-10-30T20-54.md`, `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-07 Codex Bash leg | PASS | P1-T2, P3-T3 | C4 to C6 | `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-08 Codex apply_patch | PASS | P3-T3 | C7, C8 | `regression-testing/fail-before-codex-target-worktree.2026-10-30T20-54.md`, `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-09 Ambiguous denial | PASS | P3-T2, P3-T3 | T8, C8, C10 | `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-10 Not-derivable denial | PASS | P1-T1, P1-T2, P3-T2, P3-T3 | B7, B8, T9 to T11, C11 to C13 | `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-11 Session-root fallback | PASS | P3-T2, P3-T3 | T7 (3 cases), T9 relative Write, C9 (3 cases), O5 | `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-12 Agent delegation unchanged | PASS | P3-T2 | `enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1` (16/16), merge-base diff of that file empty | `qa-gates/pester-coverage.2026-10-30T21-08.md`, this artifact |
| AC-13 Strict lifecycle_ready | PASS | P3-T1, P3-T4 | P2-T5 readiness rows (both runtimes), T12, C14 | `regression-testing/fail-before-readiness-parity.2026-10-30T20-55.md`, `regression-testing/pass-after-target-worktree.2026-10-30T21-02.md` |
| AC-14 Deny wording | PASS | P3-T2, P3-T3, P3-T4 | EpicScope (22/22), EpicScopeTargets (22/22), Codex -epic-scope (54/54), -epic-scope-targets (23/23), all unchanged | `qa-gates/pester-coverage.2026-10-30T21-08.md` |
| AC-15 Epic target-mixed unchanged | PASS | none (no -targets edit) | `enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` (3/3); merge-base diff of all four -targets copies empty | `qa-gates/pester-coverage.2026-10-30T21-08.md`, this artifact |
| AC-16 Selector removed, Codex seam moved | PASS | P3-T2, P3-T3, P3-T4, P4-T2, P4-T4 | `AC-18 each gate's function names equal the shared set plus its declared per-surface set`, updated legacy rows, C15; selector token count 0 in both Claude files | `qa-gates/pester-coverage.2026-10-30T21-08.md` |
| AC-17 Test isolation | PASS | P4-T3, P4-T4 | T14, C17; three seeded shuffles; single-process run | `regression-testing/isolation-shuffle.2026-10-30T21-16.md`, `regression-testing/isolation-single-process.2026-10-30T21-29.md` |
| AC-18 Bundle parity | PASS | P1-T1, P1-T2, P3-T1 to P3-T4 | both resource-contract pytest files | `qa-gates/python-contract-tests.2026-10-30T21-10.md` |
| AC-19 Pack manifests | PASS | P0-T3, P1-T1, P1-T2 | completeness, dependency closure, generator `--check`, `hook-dependency-guard-completeness.Tests.ps1` (671/671) | `qa-gates/python-contract-tests.2026-10-30T21-10.md`, `qa-gates/codex-generator-check.2026-10-30T21-10.md` |
| AC-20 Codex twin | PASS | P0-T3 (E2-BRANCH: CONSUME), P1-T2 | C16, Codex `hook-target-worktree.Tests.ps1` unmodified (83/83); merge-base diff of both resolver files empty | `baseline/codex-twin-and-manifest.2026-10-30T20-37.md`, this artifact |
| AC-21 File size | PASS | P3-T4, P5-T7 | `keeps <File> at or under 500 lines in the repository and the bundle` | `qa-gates/file-sizes.2026-10-30T21-10.md` |
| AC-22 Toolchain and coverage | PASS | P5-T2, P5-T3, P5-T4 | all touched suites (1618/1618); coverage 93.08 / 96.74 / 88.17 / 96.40 | `qa-gates/poshqc-format.2026-10-30T21-04.md`, `qa-gates/poshqc-analyze.2026-10-30T21-04.md`, `qa-gates/pester-coverage.2026-10-30T21-08.md`, `qa-gates/coverage-delta.2026-10-30T21-09.md` |
| AC-23 Fail-before and pass-after evidence | PASS | P2-T2, P2-T4, P2-T6, P5-T1 | regression runs | the four `regression-testing/` fail-before and pass-after artifacts above |

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/spec.md`
- Total AC items: 23
- Checked off (delivered): 23
- Remaining (unchecked): 0
- Items remaining: None.
- Pending-CI: None. CI on the PR head (`poshqc / PowerShell QC` shards and `poshqc / PowerShell hook suites (Linux)`) is still expected to run the new suites; no acceptance criterion is stated against that CI result.
