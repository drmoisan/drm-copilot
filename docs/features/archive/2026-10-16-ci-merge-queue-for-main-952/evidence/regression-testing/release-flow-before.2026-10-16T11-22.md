# Release Flow Before (P5-T4, expect-fail)

Timestamp: 2026-10-16T11-22
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/dev-tools]
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: Command exited with code 14.
Baseline (P0-T10 t-dev-tools): GREEN

Error text (verbatim summary field): Command exited with code 14.
The MCP result also carried a `stderr_excerpt` made of stderr lines from the pre-existing release-publish verifier suites under the same folder (messages about tag 'mcp-server-v0.0.2' returning NO_RUN, STEP_SKIPPED and UNRESOLVED). Those lines are printed by tests that pass. They are not related to this change.

Supporting check: `git grep -n -F -e "function Wait-ForPullRequestMerged" -- scripts/dev-tools` exited 1 with no output (the wait function does not exist pre-change).

Informational observation (not an acceptance input): the local PoshQC JUnit output of the same run (`artifacts/pester/pester-junit.xml`, gitignored) lists exactly 14 failed testcases, which equal the 14 rows attributed below.

RowAttribution:
- tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1, all 12 Appendix H.3 cases: expected FAIL pre-change. Reason: `Wait-ForPullRequestMerged` is absent (git grep above), so cases W-1 to W-8 fail with a command-not-found error. W-9 to W-12 fail because the pre-change script merges with `--delete-branch`, which the H.3 gh mock does not match, and it never reads merge state.
  - W-1 returns 0 after a pending snapshot followed by a merged snapshot, sleeping once for the poll interval
  - W-2 returns 0 on the first poll with no sleep when the pull request is already merged
  - W-3 returns 1 after polling floor(timeout / interval) + 1 times when every snapshot is pending
  - W-4 returns 1 with a not-queued message when the pull request is open and neither merged nor queued
  - W-5 returns 1 with a closed message when the pull request is closed
  - W-6 returns 1 when the merge-state read fails
  - W-7 returns 1 with the parser message when the snapshot is malformed
  - W-8 reads merge state with the exact gh api graphql argument list
  - W-9 flow: merges with no --delete-branch, waits for the merge, then checks out, pulls, and pushes the tag
  - W-10 flow: stops before checkout, pull, and tag push when the merge wait times out
  - W-11 flow: stops before checkout, pull, and tag push when the pull request is not queued
  - W-12 flow: stops before checkout, pull, and tag push when the pull request is closed
- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:
  - `opens the release PR, waits for checks, merges, pulls main, and invokes tag push`: expected FAIL. Reason: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:403` still passes `--delete-branch`, so the gh call list does not match the updated four-call expectation (no `pr merge 291 --merge`, no `api graphql` call).
  - `stops before checkout, pull, and tag push when merge fails`: expected FAIL. Reason: the updated mock fails only `pr merge 291 --merge`; the script's `--delete-branch` call falls through to the default exit 0, so the flow continues past the merge.
- No case of `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`, `Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` or `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` is expected to fail. The AdditionalFailurePaths `^api graphql ` branch is not reached pre-change, and its other cases are unchanged.

CI job relied on later: poshqc / PowerShell QC.
