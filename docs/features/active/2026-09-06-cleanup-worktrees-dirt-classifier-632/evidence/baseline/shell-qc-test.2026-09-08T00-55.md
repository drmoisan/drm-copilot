# Baseline — bats suite (plan task P0-T4)

Timestamp: 2026-09-08T00-55
Tree state: branch `bug/cleanup-worktrees-dirt-classifier-632-r2` at HEAD
`4ffe680ebcebaabbba10faaa490e46a717686535`.

## Route taken (recorded per EA-1 and EA-4)

The plan's P0-T4 block names the preparation worktree and the bare `wsl` form,
which EA-1 forbids and this isolated worktree denies. EA-4's preference order was
applied: the orchestrator's own context first, then a CI dispatch. `kcov` has no
local route and the coverage headline in P0-T5 comes from the same run, so the
canonical capture is the CI dispatch. Per EA-1, the CI dispatch is canonical on
any local/CI disagreement.

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`
Run: <https://github.com/drmoisan/drm-copilot/actions/runs/34174142684>
Run id: 34174142684
Event: `workflow_dispatch`
headSha: `4ffe680ebcebaabbba10faaa490e46a717686535`
Conclusion: `success`
EXIT_CODE: 0

The workflow runs `shell-qc check` and then `shell-qc test --coverage` on
`ubuntu-latest`, installing `bats` via apt and building `kcov` v43 from source.

## Output Summary

Read from the run log via `gh run view 34174142684 --log`, not from the uploaded
artifact (the upload step publishes `artifacts/pester/kcov/**` only, so no
per-test TAP artifact exists).

- TAP plan line: `1..343`
- `ok` lines: 343
- `not ok` lines: 0

No `not ok` line appeared. The run did NOT take the
`bats not installed; skipping shell tests.` path: 343 tests are enumerated in the
log, and that path emits no TAP output at all while still returning 0, so the
enumerated plan line is what distinguishes a real pass from the skip.

## Independent local corroboration

A second, independent capture was run from the orchestrator's own context in this
worktree, using the npm-published bats rather than the CI runner's apt-installed
one:

Command: `npx --yes bats --recursive tests/shell/`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`
bats version: 1.13.0 (the same version the CI runner carries)
EXIT_CODE: 0

Result: 343 `ok` lines, 0 `not ok` lines.

The two captures agree exactly on both the test count and the failure count, on
different machines with separately obtained bats binaries. Per EA-1 the CI
dispatch remains canonical, but there is no disagreement to resolve here.

## Note on the parent-supplied reference figure

The kickoff prompt cited run `34148603116` at integration commit `6dff80ed` with
321 bats tests. That figure is superseded and was not reused: issue 631 merged
into the integration branch after it and added test files. The re-captured figure
at this run's actual base is 343 tests.

## Verdict

bats baseline is GREEN at 343 tests, 0 failures.
