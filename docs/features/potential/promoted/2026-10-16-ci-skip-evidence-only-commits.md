# ci-skip-evidence-only-commits (Issue #962)

- Date captured: 2026-10-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-skip-evidence-only-commits/ (Issue #962)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #962
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/962
- Last Updated: 2026-10-16
## Summary

Each item costs three full CI runs (about 12–19 minutes each) to reach a clean merge:
1. the run that proves the code green;
2. a run triggered by the commit that records that CI evidence (docs only);
3. a run after the branch is re-synced with main.

Run 3 is removed by the merge queue (#952). This issue removes run 2. When every file changed since the branch's last fully green CI commit is an evidence or docs path, the heavy CI jobs are skipped and only docs validation runs. Evidence documentation is still committed in full.

## Environment

- OS/version: GitHub Actions (windows-latest, ubuntu-latest)
- Python version: n/a
- Command/flags used: `.github/workflows/ci.yml` on `pull_request` events
- Data source or fixture: #953 / PR #959, which ran CI three times for one code state

## Steps to Reproduce

1. Push code to an item branch and wait for a green CI.
2. Commit the CI evidence under `docs/features/<item>/` and push.
3. Observe that a full CI run starts, although the code tree is identical to the one just tested.

## Expected Behavior

A push whose diff since the last fully green commit touches only evidence or docs paths runs docs validation only. Every required check still reports success.

## Actual Behavior

Every push runs the full matrix, about 12–19 minutes.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: PR #959 CI runs 38896856766, 38896898318 and 38899482473 cover one code state.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Design: add a first `changes` job to `ci.yml`.
- **Find the base.** Locate the newest commit on the PR head branch that has a successful, non-skipped full CI run, using the Actions API and `GITHUB_TOKEN`, read-only.
- **Ancestry.** Require that commit to be an ancestor of HEAD.
- **Diff.** Compute `git diff --name-only <green>..HEAD`.
- **Decision.** If the diff is non-empty and every path matches a configured evidence/docs allowlist (`docs/features/**`, `docs/research/**`, and others to be decided in the spec), output `code=false`. Otherwise output `code=true`.
- **Fail closed.** Missing green run, non-ancestor, API error, or any path outside the allowlist all give `code=true`.
- **Never skip** on `merge_group`, `push` to main, or `workflow_dispatch` events.

Heavy jobs then use `if: needs.changes.outputs.code == 'true'`. A job skipped by `if:` satisfies required status checks. Confirm this for reusable-workflow callers and matrix jobs, including the sharded `poshqc / PowerShell QC` aggregator from #953 and the required-check contexts of ruleset 15241672. Docs validation always runs.

Coordinate with #952, which adds the `merge_group` trigger to `ci.yml`, and with #953, which shards `_poshqc.yml`. Schedule this item after both.

The repository's own CI-gate tooling (`.claude/lib/ci-gate`, the orchestrate step 9 durable-green check) must treat skipped-by-design required checks as green. Check that it does, and fix it if not.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: the path-classification and ancestry decision logic as a testable script (bash or PowerShell, no Python), with tests for the allowlist, a non-ancestor base, a missing base, an empty diff and mixed diffs.
- [x] Integration scenario to retest: on this PR, push a docs-only evidence commit after a green run and confirm that the heavy jobs show as skipped and every required check passes. Then push a code change and confirm the full run.
- [x] Manual verification notes: record the time an evidence-commit CI takes before and after.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
