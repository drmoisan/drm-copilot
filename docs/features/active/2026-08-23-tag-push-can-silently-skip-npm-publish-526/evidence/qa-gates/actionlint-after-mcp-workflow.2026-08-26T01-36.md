# Actionlint after the Layer A changes to publish-mcp-npm.yml — [P4-T6]

Timestamp: 2026-08-26T01-36

Filename-stamp substitution: the plan fixes every evidence filename at `.2026-08-24T13-10.md`.
This execution ran on 2026-08-26, so the stamp `2026-08-26T01-36` was substituted into that
position. The path prefix and base name are unchanged.

Command: `pwsh ./scripts/dev-tools/run-actionlint.ps1`

EXIT_CODE: 0

## Output Summary

Actionlint reported zero diagnostics after Phase 4 modified
`.github/workflows/publish-mcp-npm.yml`. Stdout was the single informational line
`Running actionlint...` with no diagnostic lines following it.

The Phase 0 baseline (`evidence/baseline/actionlint-baseline.*.md`) also recorded exit 0 with
zero diagnostics, so this result confirms the Phase 4 diff introduced no workflow-lint
regression.

A second, narrower invocation was run to confirm the modified file was in scope rather than
inferring it from the repository-wide sweep:

- Command: `pwsh ./scripts/dev-tools/run-actionlint.ps1 .github/workflows/publish-mcp-npm.yml`
- EXIT_CODE: 0

Both invocations ran with the working directory set to the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`, which is the
directory actionlint resolves `.github/workflows/**` against.

## Phase 4 changes covered by this run

| Task | Change to `.github/workflows/publish-mcp-npm.yml` |
| --- | --- |
| P4-T1 | Added a `pull_request` trigger scoped to `packages/mcp-server/**` and the workflow file |
| P4-T2 | Replaced the `github.event_name` publish guard with `startsWith(github.ref, 'refs/tags/mcp-server-v')` |
| P4-T3 | Added the ref-guarded tag-versus-manifest version-equality step before the publish step |
| P4-T4 | Added the ref-guarded post-publish exact-version registry poll step |
| P4-T5 | Applied `$LASTEXITCODE = 0` plus explicit `exit 0` / `exit 1` to both added `pwsh` steps |

File line count after Phase 4: `.github/workflows/publish-mcp-npm.yml` = 128 lines.
