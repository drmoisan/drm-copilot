# ci-docs-only-pr-runs-full-ci (Issue #973)

- Date captured: 2026-10-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-docs-only-pr-runs-full-ci/ (Issue #973)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #973
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/973
- Last Updated: 2026-10-17
- Work Mode: full-bug

## Summary

A pull request that changes only documentation still runs the full CI suite. The #962 change-scope gate skips heavy jobs only when it can compare against an earlier full green run on the same branch, so a new docs-only PR (no prior green run) always decides `code=true reason=NO_FULL_GREEN_RUN`. Separately, the docs-only allowlist omits `docs/features/archive/`, `docs/features/parallel/` and `docs/features/epics/`, so archive moves and run-status documents never qualify.

## Environment

- OS/version: GitHub Actions runners (`.github/workflows/ci.yml` `Change scope` job)
- Python version: n/a
- Command/flags used: `scripts/ci/Invoke-CiChangeScope.ps1` with `scripts/ci/CiChangeScope.psm1` and `config/ci-docs-only-paths.json`
- Data source or fixture: PR #972 (records consolidation, docs only), run 39031193305, job 117391813610; PR #941 (archive moves)

## Steps to Reproduce

1. Branch from main and change only Markdown files under `docs/features/` (for example, move a folder from `docs/features/active/` to `docs/features/archive/`).
2. Open a pull request.
3. Read the `Change scope` job log.

## Expected Behavior

When every path changed relative to the PR's merge base with main is on the docs-only allowlist, the heavy jobs are skipped on the first run, and the 11 required status checks still report success. Archive, parallel-run and epic documentation paths are on the allowlist.

## Actual Behavior

The `Change scope` job logs `code=true reason=NO_FULL_GREEN_RUN` and every heavy job runs (PowerShell QC shards 1 to 3, the Linux hook suites, four Python legs, shell coverage). PR #972 (455 renames, 4 additions, 3 modifications, all under `docs/features/`) took a full run. With the base gap fixed, the archive renames would still fail the allowlist check (`NON_ALLOWLISTED_PATH`) because `docs/features/archive/` is not an include prefix.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `2026-10-17T12:06:13.2781666Z code=true reason=NO_FULL_GREEN_RUN` (job 117391813610)

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

- The base for the docs-only comparison is selected only from earlier full green runs on the branch (`Select-CiGreenBaseCandidates` in `scripts/ci/CiChangeScope.psm1`). When there is none, the decision falls through to `NO_FULL_GREEN_RUN` and a full run.
- `config/ci-docs-only-paths.json` `include_prefixes` lists `docs/features/active/`, `completed/`, `potential/` and `docs/research/` only.
- #962 was scoped to the evidence-commit case (the second run of the triple CI run). The new-docs-only-PR case was not covered; this is a scope gap in #962, not a regression.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: when no full green run exists on the branch, fall back to the PR merge base with main as the comparison base (main merges only after passing CI under the non-strict ruleset, and push CI on main is confirmed after every merge); decide `code=false` with a `DOCS_ONLY_SINCE_` reason only when every changed path, including both sides of each rename, is allowlisted. Add `docs/features/archive/`, `docs/features/parallel/` and `docs/features/epics/` to `include_prefixes`. Pester rows for: merge-base fallback skip, merge-base fallback with one non-allowlisted path (full run), rename whose source or destination is outside the allowlist (full run), each new prefix, and fail-closed behavior when the merge base cannot be resolved.
- [x] Integration scenario to retest: a docs-only PR (archive move) whose first CI run skips the heavy jobs with all 11 required checks green; then a commit touching a non-allowlisted path on the same PR returns to a full run.
- [ ] Manual verification notes: confirm push CI on main still runs in full after a docs-only merge, or document the intended main-push behavior.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch