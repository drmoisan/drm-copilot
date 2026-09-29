# Execution-Time Substitutions (issue #763)

Timestamp: 2026-09-29T17-39
Plan: docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/plan.2026-09-29T14-14.md (v1.2, sha256 bd8fd85a88de3dbd2e12429a2cbde3cef2ec99c4d619ce682317aee5c5337a52 at execution start)
Source: orchestrator delegation directive (DIRECTIVE: EXECUTE APPROVED PLAN)

The plan's task text is not altered. The following substitutions apply at execution time.

1. BRANCH. Everywhere the plan names `bug/parallel-skills-invoke-unbundled-python-clis-763` as the
   branch (terms list line 110, CMD-GIT-PUSH, CMD-GH-DISPATCH, CMD-GH-LATEST, P0-T8 acceptance), the
   executed value is `bug/parallel-skills-invoke-unbundled-python-clis-exec-763`. Reason: the
   preparation branch is locked in another worktree and is already merged into the integration
   branch. The feature folder path is unchanged.
2. P0-T8 merge-base. The integration branch advanced after authoring. The expected merge-base is
   `12db46245ba7683b5d6ccb676312a4b22a39b0ce` (HEAD at execution start equals it), not the authoring
   value `d06ba5d657b75de52cad7859dda307bf9d420046`. The acceptance rule (every changed or porcelain
   path lies under FEATURE) still applies. `artifacts/orchestration/orchestrator-state.json` is
   gitignored; if it appears in porcelain it is recorded as the orchestrator checkpoint.
3. Commit trailers. Every CMD-GIT-COMMIT carries exactly two trailers:
   `--trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"` and
   `--trailer "Claude-Session: https://claude.ai/code/session_01Pij9yfzq7FBzpYvqjejUYn"`.
4. Push cadence. Commit and push at every phase boundary the plan specifies, with
   `git push -u origin bug/parallel-skills-invoke-unbundled-python-clis-exec-763`.

## Command-text spellings applied by the executor (not substitutions of plan text)

- The Bash tool's PreToolUse hook refuses a `cd ... &&` chain and refuses sed programs composed
  inside loops. Commands therefore run from the default working directory (the worktree root) with
  repository-relative paths, one plain command per call, as the plan's Shell route requires.
- SCRATCH resolves to the session scratchpad directory outside the repository; artifacts record it
  as the literal token SCRATCH.
