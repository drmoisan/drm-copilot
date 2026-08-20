# claude-resource-parity-enumerates-gitignored-state (Potential Bug)

- Date captured: 2026-08-19
- Author: Dan Moisan
- Status: Draft
- Severity: Medium — a green suite fails spuriously once any PowerShell write occurs in a session

## Summary

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
enumerates repository `.claude/**` with `Path.rglob("*")` and does not read `.gitignore`. The
gitignored, session-scoped file `.claude/state/powershell-batch-budget.<session_id>.json` is
therefore enumerated and reported as missing from the bundle, failing the suite for a reason
unrelated to the mirrors it exists to verify.

## Root cause

The walk excludes only `.claude/settings.local.json` and `.claude/agent-memory/**`. `.claude/state/`
is gitignored but not excluded from the walk. `.claude/hooks/enforce-powershell-batch-budget.ps1`
creates `.claude/state/powershell-batch-budget.<session_id>.json` on the first PowerShell write of a
session, so any session that touches a `.ps1`, `.psm1`, or `.psd1` file causes the suite to fail on
its next run with `Repo file missing from bundle: .claude/state/...json`.

## Reproduction

1. In a clean worktree, confirm the suite passes:

   ```
   poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
   ```

2. Cause any PowerShell production or test file to be written through the Write or Edit tool, so the
   batch-budget hook creates its state file. Confirm it exists with `ls .claude/state/`.
3. Re-run the suite. It now fails, naming the state file as missing from the bundle.
4. Delete `.claude/state/powershell-batch-budget.<session_id>.json` and re-run. It passes again.

Observed during issue #491 preflight. `.claude/state/` did not exist in the worktree at the time of
observation, which is why the suite was green at baseline.

## Impact

- Any feature that writes PowerShell and then runs this parity suite in the same session hits a
  spurious failure. The message names a file that is correctly absent from the bundle, which
  misdirects diagnosis toward the mirror work actually under test.
- Because the remedy looks like "delete a file", the natural response is a per-plan workaround rather
  than a repository fix, so the defect recurs for every future PowerShell-touching feature.
- The state file is session-scoped runtime state and is gitignored. It is never distributable, so
  including it in a distribution-parity assertion is incorrect on its own terms.

## Workaround in use

Issue #491's plan deletes `.claude/state/powershell-batch-budget.<session_id>.json` as an explicit
precondition of every task that runs this suite. That unblocks the feature but does not remove the
recurrence for later work.

## Proposed Fix

Exclude `.claude/state/**` from the walk, exactly as `.claude/agent-memory/**` is already excluded.
The two are the same category: session-local or machine-local runtime state that is deliberately not
part of the distributed payload.

A broader alternative is to have the walk honor `.gitignore`, which would generalize to any future
gitignored runtime path under `.claude/`. That is the more durable change, but it widens the suite's
behavior and should first be evaluated for whether it could mask a genuinely missing tracked file.

## Test Conditions to Consider

- [ ] The suite passes with `.claude/state/powershell-batch-budget.<session_id>.json` present.
- [ ] The suite still fails when a genuinely tracked, distributable `.claude` file is missing from the
      bundle, so the exclusion does not weaken the assertion it protects.
- [ ] The exclusion covers nested paths under `.claude/state/`, not only direct children.
- [ ] `.claude/settings.local.json` and `.claude/agent-memory/**` remain excluded.

## Next Step

- [ ] Promote to GitHub issue (bug template)
- [ ] Check whether the TypeScript and Python pack-manifest completeness suites share the same
      unfiltered-walk exposure for gitignored runtime paths.
