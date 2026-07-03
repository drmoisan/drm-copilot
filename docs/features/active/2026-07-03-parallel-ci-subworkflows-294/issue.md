# parallel-ci-subworkflows (Issue #294)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-ci-subworkflows/ (Issue #294)

- Issue: #294
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/294
- Last Updated: 2026-07-03
- Work Mode: full-feature

## Problem / Why

The main `.github/workflows/ci.yml` workflow defines seven jobs (`quality-checks7` with a 4-way Python matrix,
`security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests` with a
2-way OS matrix). None of the jobs declare `needs:`, so GitHub Actions already schedules them as independent,
concurrently-eligible jobs. Total wall-clock time for a CI run is bounded by runner-concurrency limits and by the
single longest job (for example `shell-coverage`, which builds `kcov` from source, or the `quality-checks7` matrix).
The user has observed that CI "takes a long time... because it runs everything sequentially," which points at
constrained effective concurrency and a monolithic single-workflow-file structure that does not match the
already-documented target architecture in `CLAUDE.md` (every CI gate should ship as a callable reusable workflow
`_<name>.yml`, invoked by an orchestrator workflow that contains no inline `steps:` of its own).

## Proposed Behavior

Decompose `ci.yml` into one callable reusable workflow (`_<name>.yml`, each declaring both `on: workflow_call:` and
`on: workflow_dispatch:`) per current job, and introduce (or repurpose) a thin orchestrator workflow whose only job
bodies are `uses: ./.github/workflows/_<name>.yml` references with no `needs:` between independent gates, so that
GitHub Actions schedules them in parallel to the extent runner concurrency allows. Any reusable workflow that needs
files produced by another job must pass them explicitly via `actions/upload-artifact` + `actions/download-artifact`
(no implicit filesystem sharing across jobs). Reusable-workflow nesting stays within the repository's documented
cap of 4 levels lower. Update `.github/workflows/README.md` with the new per-stage dispatch and branch-protection
required-check rename procedure, consistent with the existing `_npm-audit-gate.yml` / `npm-audit-gate.yml` pattern
already present in the repository.

## Acceptance Criteria (early draft)

- [ ] Each current `ci.yml` job (`quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`,
      `shell-coverage`, `drm-copilot-extension-tests`) is extracted into its own callable reusable workflow file
      named `_<name>.yml` declaring both `workflow_call` and `workflow_dispatch` triggers.
- [ ] A thin orchestrator workflow (retaining the `ci.yml` name and its existing `push`/`pull_request`/
      `workflow_dispatch` triggers, or an equivalent replacement) invokes each reusable workflow via
      `uses: ./.github/workflows/_<name>.yml` with no inline `steps:` and no artificial `needs:` between
      independent gates.
- [ ] Any cross-job file dependency uses explicit `actions/upload-artifact` / `actions/download-artifact`; no job
      relies on implicit shared-filesystem state from another job.
- [ ] Required-status-check names referenced by branch protection continue to resolve after the split (renamed or
      preserved check names are documented).
- [ ] `.github/workflows/README.md` documents the new per-stage dispatch and the required-check rename procedure.
- [ ] A green workflow run against the branch head is captured before merge, per the
      `modified-workflow-needs-green-run` policy rule for workflow-file changes.

## Constraints & Risks

- GitHub Actions runner-concurrency limits (plan-dependent) bound how much wall-clock benefit parallelization
  yields; this must be measured, not assumed.
- Reusable-workflow nesting depth is capped at 4 levels in this repository; the new structure must not introduce
  additional nesting beyond the one level already documented in `CLAUDE.md`.
- Branch protection required-status-check names are tied to job names; renaming/splitting jobs can silently break
  required-check enforcement unless the rename procedure is applied and documented.
- No job may assume another job's on-disk artifacts are present without an explicit upload/download step.
- This is a CI-only (`.github/workflows/**`) change; it does not alter application behavior in `src/` or
  `extensions/drm-copilot/src`.

## Test Conditions to Consider

- [ ] Each new reusable workflow can be invoked standalone via `workflow_dispatch` and completes successfully.
- [ ] The orchestrator workflow triggers all independent reusable workflows without a `needs:` chain forcing
      sequential execution.
- [ ] A workflow run against the branch head shows reduced wall-clock time relative to the prior sequential/
      single-file baseline (or, at minimum, confirms jobs execute concurrently rather than serially).
- [ ] Required checks configured in branch protection still resolve (or are updated) against the new job/workflow
      names.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-ci-subworkflows/` folder from the template

