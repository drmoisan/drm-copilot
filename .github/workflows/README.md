# GitHub Actions Workflows

This directory contains the repository's GitHub Actions workflows. `ci.yml` is a thin
orchestrator that composes seven reusable per-stage workflows (the `_<name>.yml` files
below) via `workflow_call`. Each reusable workflow can also be dispatched independently
via `workflow_dispatch` for targeted re-runs without triggering the full `ci.yml` suite.

## Per-Stage Dispatch

| Reusable workflow file | Declared triggers | Standalone dispatch command |
|---|---|---|
| `_quality-checks.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _quality-checks.yml` |
| `_security-scan.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _security-scan.yml` |
| `_docs-validation.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _docs-validation.yml` |
| `_build-check.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _build-check.yml` |
| `_poshqc.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _poshqc.yml` |
| `_shell-coverage.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _shell-coverage.yml` |
| `_drm-copilot-extension-tests.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _drm-copilot-extension-tests.yml` |

Add `--ref <branch>` to any of the above commands to dispatch against a branch other
than the repository's default branch.

## Required-Status-Check Rename Procedure

Extracting each job into its own reusable workflow file can change the composed
check-run name GitHub reports for that job (the name GitHub Actions uses to compose a
check-run name is derived from the calling job and, for reusable workflows invoked via
`uses:`, the reusable workflow's own job name). Because branch protection's
`required_status_checks` list matches on the literal check-run `context` string, any
naming drift introduced by this kind of refactor must be reconciled explicitly rather
than assumed. Follow this 4-step procedure whenever a job is extracted into (or
renamed within) a reusable workflow:

1. **Land the extraction and produce a green run against the branch head.**
   Merge (or push to) the branch head so that `ci.yml`'s `push`/`pull_request` trigger
   (or a `workflow_dispatch` run of `ci.yml` itself) produces a real workflow run
   against that head SHA. Confirm all jobs conclude `success` before proceeding.

2. **Read the actual composed check-run names.**
   Query the check-runs recorded against that head SHA and record the exact `name`
   string GitHub produced for each job:

   ```bash
   gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs
   ```

3. **Update branch protection with the confirmed new context strings.**
   Read the current required-status-check configuration, then patch it with the
   confirmed post-extraction context strings, removing any stale pre-extraction
   context string that is no longer produced:

   ```bash
   gh api repos/{owner}/{repo}/branches/{branch}/protection/required_status_checks \
     --method PATCH \
     -f 'checks[][context]=<confirmed-context-string>'
   ```

   (Repeat the `-f 'checks[][context]=...'` field once per required context, or supply
   the full `checks` array via a JSON payload file with `--input`.)

4. **Document both old and new context strings plus the exact commands used.**
   Record the pre-extraction context strings, the confirmed post-extraction context
   strings, and the exact `gh api` GET/PATCH commands executed, so the change is
   auditable and reversible.

## Scope of This Refactor

This extraction does not, by itself, change job-DAG concurrency. All seven jobs in
`ci.yml` (`quality-checks7`, `security-scan`, `docs-validation`, `build-check`,
`poshqc`, `shell-coverage`, `drm-copilot-extension-tests`) already lacked `needs:`
edges between them before this change, and remain independent of one another
afterward — the refactor only changes where each job's steps live, not the DAG shape
or scheduling behavior of `ci.yml`.

The purpose of this refactor is threefold:

1. **Architecture-conformance** with the reusable-workflow pattern already established
   by `_npm-audit-gate.yml` / `npm-audit-gate.yml` in this same directory.
2. **Independent per-gate `workflow_dispatch` re-run capability**, so a single gate
   (for example `_poshqc.yml`) can be re-run in isolation without re-running the full
   `ci.yml` suite.
3. **Reduced single-file blast radius**, so a change to one gate's steps no longer
   requires editing a single monolithic `ci.yml` file that also defines the other six
   gates.
