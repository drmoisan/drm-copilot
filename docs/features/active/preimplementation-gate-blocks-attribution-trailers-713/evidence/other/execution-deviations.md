# Execution Deviations (issue #713)

Timestamp: 2026-09-27T03-15

Source: orchestrator-directed deviations supplied with `DIRECTIVE: EXECUTE APPROVED PLAN` for `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md`. The plan design is unchanged; only the items below differ from the plan text.

## X1 - Commit and push after each phase

Commit and push after each phase (operator requirement). This overrides the plan header statement "This plan makes no commit and no push". At the end of each of Phases 0, 1, 2, 3, 4, and 5, stage the phase's paths explicitly by repository-relative path (git add <paths>, never -A; never stage anything under artifacts/), commit, and run `git push origin bug/preimplementation-gate-blocks-attribution-trailers-713`. Commit message: conventional form. The message is written to a file in the session scratchpad with the Write tool and committed with `git commit -F <that file>`. The message body ends with the two attribution lines `Co-Authored-By:` and `Claude-Session:` supplied by the orchestrator. Each commit SHA is recorded in `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/commits-log.md` (included in the next phase's commit). Because of X1, plan rule 6's clause "HEAD_NOW must equal HEAD_SHA" is replaced by: run `git merge-base --is-ancestor HEAD_SHA HEAD` (substituting the value) and record `HEAD_ANCESTOR_EXIT: <n>` plus `git log --format=%h%x20%s HEAD_SHA..HEAD` output; pass when both ancestry exits are 0 and every listed commit is one of this run's phase-boundary commits recorded in commits-log.md. The `BASE_ANCESTOR_EXIT` check is unchanged. P5-T21 remains a handoff record; its artifacts plus the plan checklist and spec.md check-offs are committed as the Phase 5 commit.

Consequence for porcelain conditions (applied by the executor, cited in each affected artifact): paths committed at an earlier phase boundary no longer appear in `git status --porcelain`. Porcelain conditions in [P2-T2], [P4-T1], [P5-T1], and [P5-T21] that name a path committed at an earlier boundary are read as satisfied when the path appears either in the porcelain output or in `git diff --name-status BASE_SHA HEAD` (committed on this branch by a recorded phase-boundary commit). The numstat conditions anchored to `BASE_SHA` compare against the worktree and are unaffected.

## X2 - BASE_SHA derivation

In P0-T3 use `git merge-base HEAD origin/main` instead of `git merge-base HEAD main`: the local `main` ref in this worktree is stale (2dce111e) and predates the #710 merge, so a merge-base against it would put #710's helpers change inside the 16/16 numstat. The expected BASE_SHA is 2d9bb87c (full SHA from git). This is a local-evidence command only; no test reads origin/main, which is what the plan's test-portability rule concerns.

## X3 - P0-T8 primary command

Timestamp: 2026-09-27T03-20

Orchestrator-approved. In [P0-T8] the primary command `git --version` is replaced by `git version`, which prints the same `git version x.y.z` line. The PreToolUse hook `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` denied `git --version` (PARALLEL_WORKTREE_REMOVAL_BLOCKED, empty worktree path); that is recorded as a hook false positive and as a follow-up entry in `evidence/other/follow-ups.md`. `GIT_VERSION` is recorded from `git version`; the original denial text is kept in `evidence/baseline/p0-git-trailer-support.md` as history. No other spelling was tried.

## Note - timestamp correction (not a plan deviation)

Timestamp: 2026-09-27T03-38

Several artifact timestamps written during Phases 0 to 2 of this run were entered ahead of the wall clock. They were corrected to times calibrated against the phase-boundary commit times (Phase 0 at 03-31, Phase 1 at 03-34), and the fail-before exception dossier was renamed from `fail-before-exception.2026-09-27T03-46.md` to `fail-before-exception.2026-09-27T03-34.md` with `git mv` so that its file name matches its write time. No artifact content other than the `Timestamp:` line and that file name changed.

## X4 - Trailer check command (remediation cycle 1)

Timestamp: 2026-09-27T05-01

Orchestrator-approved. Plan: `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-plan.2026-09-27T05-05.md`. In [P0-T11], [P1-T5], [P2-T7], [P3-T8], and [P4-T17], the command `git log -1 --format=%H%n%(trailers:only,unfold)` is replaced by two plain commands, each in its own Bash call: `git rev-parse HEAD` and `git log -1 --format=%B`. The worktree-isolation PreToolUse guard refused the original spelling as too complex to verify (denial text recorded in `evidence/other/remediation-c1-commits-log.md`). Acceptance is unchanged: the message body printed by the second command ends with the `Co-Authored-By:` and `Claude-Session:` lines of plan rule 3. Each affected artifact cites X4. No other spelling was tried.
