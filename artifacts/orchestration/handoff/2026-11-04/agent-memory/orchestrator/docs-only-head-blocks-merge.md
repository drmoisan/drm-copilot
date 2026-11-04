---
name: docs-only-head-blocks-merge
description: A docs-only final PR head leaves 8 of 20 required contexts unreported (matrix jobs skipped under unexpanded names) so the PR stays BLOCKED; plus merge-gate and completion-hook gotchas seen at S9
metadata:
  type: project
---

Seen 2026-11-03 on PR #1064 (issue 1047). Ruleset 15241672 now requires 20 contexts, including the three `NPM Audit Gate / npm audit (...)`, the two `root-typescript-tests / Root TypeScript Tests (...)`, and `poshqc / PowerShell QC shard 1-3`. When `ci.yml` takes the docs-only path (every file changed since the last green full run is allowlisted), those matrix jobs are skipped at job level and report under unexpanded names such as `poshqc / PowerShell QC shard ${{ matrix.shard }}`. The expanded required contexts never report, so `mergeStateStatus` stays `BLOCKED`. Reported to the coordinator; not filed.

**Why:** the S9 acceptance-criterion check-off commit and the re-audit record commit are both docs-only, so the final head of a normal run hits this.

**How to apply:**
- Make sure the final PR head gets a full run. Legitimate ways: commit docs while a code-commit CI run is still in progress (the base stays the older green run), or merge `origin/main` last when main has moved.
- An empty commit does not help.
- Codespace tokens cannot `gh workflow run` (HTTP 403).
- The green-CI merge gate rejects `--repo` and any `cd ... &&` prefix. Run the bare `gh pr merge <N> --merge --match-head-commit <sha>` from a checkout of the same repo.
- The completion-consistency Edit hook checks `feature-folder` against the session-root checkout. In a coordinator topology it blocks `step8_status: completed` until main is pulled there.

Seen again 2026-11-04 on PR #1070 (issue 1066).
- The AC11 check-off was the final head, main had not moved, and no code run was in flight.
- `gh pr checks` showed nothing pending (11 pass, 6 skipping), so the S9 parser says success while GitHub says BLOCKED. Check `mergeStateStatus` or `isRequired` through graphql, not only the parser.
- Reverting and re-applying the check-off is circular. The revert's empty diff gets a full run, but the re-apply is docs-only again relative to it.
- The run halted with `external_dependency`.
- Plan ahead: put the check-off on the branch while the last code run is still in progress, or hold the final origin/main merge until after the check-off.

Related: [[ci-gate-polling-and-linux-only-test-failures]], [[zero-ci-checks-has-three-causes]]
