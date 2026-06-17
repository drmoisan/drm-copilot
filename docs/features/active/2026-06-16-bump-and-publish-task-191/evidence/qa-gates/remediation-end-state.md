# Remediation End State — Issue #191

Timestamp: 2026-06-17T00-18

## Per-finding status (executor scope)

- F1 (BLOCKING — `modified-workflow-needs-green-run`): RESOLVED at executor scope.
  - `.github/workflows/publish-mcp-npm.yml` `on:` block now contains both the unchanged `push: tags: - "mcp-server-v*"` trigger and an added `workflow_dispatch:` trigger.
  - The `Publish to npm` step carries `if: github.event_name == 'push'` (only that step), so a `workflow_dispatch` verification run exercises the changed steps without publishing. `run: npm publish --provenance --access public`, `working-directory: packages/mcp-server`, `env.NODE_AUTH_TOKEN`, and the job-level `permissions: { id-token: write, contents: read }` are unchanged.
  - actionlint: EXIT 0, zero findings (P1-T4 and P2-T4).
  - Green-run placeholder created at `evidence/qa-gates/workflow-green-run.md` with the orchestrator-responsibility note and four labeled placeholder fields (Workflow, Head SHA, Run URL, Conclusion). The actual green `workflow_dispatch` run against branch head is the orchestrator's responsibility (executor has no `gh` access).

- F2 (PARTIAL — branch-coverage metric): RESOLVED at executor scope.
  - `evidence/qa-gates/coverage-delta.md` records the policy-sanctioned tooling-limitation exception: the Pester/CoverageGutters output emits no `type="BRANCH"` counter (count = 0 in both baseline and post-change artifacts), so there is no branch-coverage regression; new-code line coverage is 88.0% (>= 85% PASS); line coverage plus per-branch enumeration is the accepted standard for this PowerShell toolchain.
  - A full per-branch enumeration maps each decision point in `Invoke-FullReleaseGuarded` and `Get-NpmVersion` to its covering test.

## Toolchain results (Phase 2)
- PoshQC format: EXIT 0, no PowerShell file reformatted.
- PoshQC analyze: EXIT 0, zero PSScriptAnalyzer findings.
- PoshQC test (with coverage): EXIT 0, tests=608, failures=0, errors=0; repo-wide LINE 96.83% (at/above baseline).
- actionlint: EXIT 0, zero findings.
- Loop completed in a single clean pass; no restart required.

## Constraints honored
- No release tag (`mcp-server-v*`) was pushed.
- No artifact was published to npm or the Marketplace.
- The branch was not pushed and `gh` was not invoked by the executor.
- No policy document under `.claude/rules/` or `.github/instructions/`, and no `quality-tiers.yml`, was modified. No coverage threshold was lowered (confirmed in `evidence/qa-gates/policy-untouched.md`).
- All evidence written under `docs/features/active/2026-06-16-bump-and-publish-task-191/evidence/<kind>/`.
- The six acceptance criteria in `issue.md` and their checked state are unchanged.
