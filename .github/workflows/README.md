# GitHub Actions Workflows

This directory contains the repository's GitHub Actions workflows. `ci.yml` is a thin
orchestrator that composes nine reusable per-stage workflows (the `_<name>.yml` files
below) via `workflow_call`. Each reusable workflow can also be dispatched independently
via `workflow_dispatch` for targeted re-runs without triggering the full `ci.yml` suite.

## Triggers

`ci.yml` runs on four triggers:

- `push` to `main` and `development`.
- `pull_request` into `main`, `development`, and `epic/**`.
- `workflow_dispatch`.
- `merge_group` (`types: [checks_requested]`, no branch or path filter), which serves a merge queue on `main`: when a queue is enabled, every required check is produced by a `merge_group` run of `ci.yml` (issue #952).

The `epic/**` pattern is included so that epic child PRs targeting `epic/<slug>-integration` run the full CI gate, because every epic child PR targets its epic's integration branch rather than `main` (issue #658).

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
| `_root-typescript-tests.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _root-typescript-tests.yml` |
| `_npm-audit-gate.yml` | `workflow_call`, `workflow_dispatch` | `gh workflow run _npm-audit-gate.yml` |

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

This extraction does not, by itself, change job-DAG concurrency. The seven jobs it extracted from
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

## Change-Scope Decision (Issue #962)

`ci.yml` starts every run with the `changes` job (check name `Change scope`). The job decides whether the heavy CI steps run for the commit under test and publishes the decision as the job output `code` (`true` or `false`).

### Decision

On a `pull_request` event from this repository, `scripts/ci/Invoke-CiChangeScope.ps1` reads the newest 50 successful `ci.yml` runs on the pull request branch, selects the newest one whose `CI full run` job concluded `success`, checks that its head commit is present and is an ancestor of the current head, and lists the files changed between the two commits with `git diff --name-only -z --no-renames`. When every changed file is on the allowlist, the decision is `code=false`; otherwise it is `code=true`. The step logs `code=<true|false> reason=<REASON>` and writes the reason and the base commit to the job summary.

Merge-base fallback (issue #973): when the green-run step ends with `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, or `BASE_NOT_ANCESTOR`, and the pull request's base ref (`BASE_REF`, from `github.base_ref`) is exactly `main`, the script falls back to the pull request's merge base with `main`. It takes the payload base SHA (`BASE_SHA`, from `github.event.pull_request.base.sha`), checks that the commit is present with `git cat-file -e`, runs `git merge-base <base sha> <head sha>`, and accepts the output only when it is exactly one full SHA. It then runs a two-dot diff from that merge base to the head with the same arguments as the green-run diff. Rename detection is off in both diffs, so both the old and the new path of a rename are listed and classified. An all-allowlisted diff gives `code=false` with the reason `DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>`, and the job summary records the merge base. The base ref is only compared with `main` and is never passed to git. Pull requests into `development` or `epic/**` keep the green-run decision only. `RUN_LIST_FAILED`, `JOB_LIST_FAILED`, `ANCESTRY_CHECK_FAILED`, and every green-run diff outcome end the decision without a fallback.

Reason codes: `EVENT_NOT_PULL_REQUEST`, `FORK_PULL_REQUEST`, `RUN_LIST_FAILED`, `JOB_LIST_FAILED`, `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, `BASE_NOT_ANCESTOR`, `ANCESTRY_CHECK_FAILED`, `MERGE_BASE_UNRESOLVED`, `DIFF_FAILED`, `EMPTY_DIFF`, `NON_ALLOWLISTED_PATH: <first path>`, `DOCS_ONLY_SINCE_<base sha>`, `DOCS_ONLY_SINCE_MERGE_BASE_<merge base sha>`, and `UNEXPECTED_ERROR`. `DIFF_FAILED`, `EMPTY_DIFF`, and `NON_ALLOWLISTED_PATH: <first path>` can come from either diff; on the merge-base path the summary records the merge base as the base commit.

### Allowlist

`config/ci-docs-only-paths.json` holds the allowlist. A path is allowlisted only when it starts with an include prefix (`docs/features/active/`, `docs/features/archive/`, `docs/features/completed/`, `docs/features/epics/`, `docs/features/parallel/`, `docs/features/potential/`, or `docs/research/`), does not start with an exclude prefix (`docs/features/templates/` or `docs/features/potential/template.md`), ends in one of the extensions `.md`, `.txt`, `.log`, `.json`, or `.xml` (compared case-insensitively), and contains no `..` segment, no backslash, and no leading `/`. Prefixes are compared case-sensitively. A change to the allowlist file itself is not allowlisted.

### Fail-closed rules

The decision is `code=true` (a full run) for every event other than `pull_request` (`merge_group`, `push`, and `workflow_dispatch`), for a pull request from a fork, when the run list or a job list cannot be read or parsed, when the pull request's base ref is not `main` and either no successful run with a successful `CI full run` job is found or that run's head commit is missing or is not an ancestor of the head, when the merge-base fallback applies but the merge base cannot be resolved (`MERGE_BASE_UNRESOLVED`: a blank base SHA, a base commit missing from the checkout, a failed `git merge-base`, or output that is not exactly one full SHA), when the ancestry check or the diff fails, when the diff is empty, when any changed path is outside the allowlist, and on any unexpected error. The decision step uses `continue-on-error: true`, and the callers compare the output with `!= 'false'`, so a failed or missing decision also gives a full run.

### The `run-heavy` input

`_quality-checks.yml`, `_security-scan.yml`, `_build-check.yml`, `_poshqc.yml`, `_shell-coverage.yml`, and `_drm-copilot-extension-tests.yml` declare a boolean input `run-heavy` (default `true`) under both `workflow_call` and `workflow_dispatch`. `ci.yml` passes `run-heavy: ${{ needs.changes.outputs.code != 'false' }}`. When the input is `false`, each required job still starts under its full-run name and every step is skipped, so the job reports `success`. In `_poshqc.yml`, the `poshqc` job, which reports `poshqc / PowerShell QC`, runs with every step gated, and every other job is skipped at job level; when the file has the sharded shape of #953, `poshqc` is the aggregator and keeps `if: always()`. A job skipped at job level keeps its step conditions unchanged. A standalone dispatch, or a caller that omits the input, runs in full. `root-typescript-tests` and `npm-audit-gate` are skipped at job level when `code` is `false`, and `docs-validation` always runs. The `CI full run` job runs only when `code` is not `false`; it marks a run as a valid base for later decisions and is not a required check.

### Required contexts under a docs-only run

| # | Required context (ruleset 15241672) | Behaviour when `code=false` | Reported conclusion |
|---|---|---|---|
| 1 | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | job and matrix start; every step skipped by `inputs.run-heavy` | `success` |
| 2 | `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)` | same as row 1 | `success` |
| 3 | `docs-validation / Documentation Validation` | unchanged; runs in full | `success` on a passing docs check |
| 4 | `poshqc / PowerShell QC` | the `poshqc` job runs with every step gated (as the aggregator with `if: always()` in the sharded shape); every other `_poshqc.yml` job skipped at job level | `success` |
| 5 | `shell-coverage / Shell Coverage (Bats + kcov)` | job runs; every step skipped, including the upload step | `success` |
| 6 | `security-scan / Security Scanning` | job runs; every step skipped | `success` |
| 7 | `quality-checks7 / Code Quality & Tests (3.11)` | matrix expands; every step skipped | `success` |
| 8 | `quality-checks7 / Code Quality & Tests (3.12)` | same as row 7 | `success` |
| 9 | `quality-checks7 / Code Quality & Tests (3.13)` | same as row 7 | `success` |
| 10 | `build-check / Build Package` | job runs; every step skipped | `success` |

Non-required jobs under `code=false`: `Change scope` reports `success`, `CI full run` is `skipped`, and the `root-typescript-tests` and `npm-audit-gate` callers are `skipped`.

### Security scan

On a full run, `security-scan / Security Scanning` installs the Poetry export plugin, exports the locked dependencies, and runs `safety check` under `bash` with `pipefail`, so the scan reads every locked package. The scan step carries `continue-on-error: true` and does not fail the required check: the first full run of issue #962 reported 101 pre-existing findings in 14 packages of `poetry.lock` (listed in the issue #962 feature folder, `evidence/other/security-scan-findings.2026-10-17T01-18.md`), and the step stays non-blocking until those dependencies are upgraded. Findings and export errors remain visible in the step log.
