# Actionlint after the Layer C reconciliation workflow — [P5-T6]

Timestamp: 2026-08-26T01-36

Filename-stamp substitution: the plan fixes every evidence filename at `.2026-08-24T13-10.md`.
This execution ran on 2026-08-26, so the stamp `2026-08-26T01-36` was substituted into that
position. The path prefix and base name are unchanged.

Command: `pwsh ./scripts/dev-tools/run-actionlint.ps1`

EXIT_CODE: 0

## Output Summary

Actionlint reported zero diagnostics after Phase 5 created
`.github/workflows/verify-published-releases.yml`. Stdout was the single informational line
`Running actionlint...` with no diagnostic lines following it.

The Phase 0 baseline (`evidence/baseline/actionlint-baseline.*.md`) also recorded exit 0 with
zero diagnostics, so this result confirms the Phase 5 diff introduced no workflow-lint
regression. The repository-wide sweep covers both workflow files this change touches:
`.github/workflows/publish-mcp-npm.yml` (Phase 4) and
`.github/workflows/verify-published-releases.yml` (Phase 5).

A second, narrower invocation was run to confirm the new file was in scope rather than
inferring it from the repository-wide sweep:

- Command: `pwsh ./scripts/dev-tools/run-actionlint.ps1 .github/workflows/verify-published-releases.yml`
- EXIT_CODE: 0

Both invocations ran with the working directory set to the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`, which is the
directory actionlint resolves `.github/workflows/**` against.

## Phase 5 changes covered by this run

| Task | Change |
| --- | --- |
| P5-T1 | Created `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` (pure `Get-UnpublishedTagVersion` plus a dot-source guard) |
| P5-T2 | Registered that file in `CodeCoverage.Path` in both in-repo runsettings copies |
| P5-T3 | Created `tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1` |
| P5-T4 | Created `.github/workflows/verify-published-releases.yml` (schedule + workflow_dispatch + scoped pull_request) |
| P5-T5 | Created `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1` |

## Guard disposition of every step in the new workflow

No tag-dependent or registry-dependent step runs on a pull-request event, so a pull-request
run of this workflow issues no network query, publishes nothing, and cannot fail on the
pre-existing divergence the sweep is designed to surface.

| Step | Guard |
| --- | --- |
| Checkout repository | ungated (no external query) |
| Validate the reconciliation comparison offline | ungated by design — offline, in-memory literals only; this is what makes a pull-request run non-empty and green |
| Set up Node.js | `if: github.event_name != 'pull_request'` |
| Reconcile pushed tags against published versions | `if: github.event_name != 'pull_request'` |

Both `pwsh` steps satisfy the exit-code hygiene rule in `.claude/rules/ci-workflows.md`: the
offline validation step terminates with an explicit `exit 0` on success and `exit 1` on
failure, and the sweep step resets `$LASTEXITCODE = 0` after each of its two deliberately
non-zero nested commands (`git ls-remote` against a possibly empty tag set, and `npm view`
against a possibly unpublished package) and also terminates with an explicit `exit 0` or
`exit 1`.

File line count after Phase 5: `.github/workflows/verify-published-releases.yml` = 95 lines.
