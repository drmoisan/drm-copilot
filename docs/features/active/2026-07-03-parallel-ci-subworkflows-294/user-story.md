# `2026-07-03-parallel-ci-subworkflows` — User Story

- Issue: #294
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-03T18-07

## Story Statement

- As a maintainer merging PRs in this repository, I want each CI gate (`quality-checks7`,
  `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`,
  `drm-copilot-extension-tests`) to be an independently re-runnable, cleanly separated reusable
  workflow, so that a failure or re-run need in one gate does not require touching or re-running
  the entire `ci.yml` file, and so that this workflow's structure matches the architecture the
  repository already documents and already applies to `_npm-audit-gate.yml`.
- As someone auditing or updating branch-protection required checks after this refactor, I want
  a documented, scriptable rename procedure in `.github/workflows/README.md`, so that I can
  confirm the actual post-extraction check-run names via `gh api` and update required-status
  checks without guessing at a naming format or performing a manual, undocumented one-off change.

## Problem / Why

`.github/workflows/ci.yml` defines seven jobs (`quality-checks7` with a 4-way Python matrix,
`security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`,
`drm-copilot-extension-tests` with a 2-way OS matrix). None of the jobs declare `needs:`, so
GitHub Actions already schedules them as independent, concurrently-eligible jobs; this refactor
does not change that scheduling — it was already true beforehand. The monolithic single-file
structure does not match the target architecture already documented in `CLAUDE.md` and already
realized once in this repository for `_npm-audit-gate.yml` / `npm-audit-gate.yml`: every CI gate
should ship as a callable reusable workflow (`_<name>.yml`, declaring both `workflow_call` and
`workflow_dispatch`) invoked by a thin orchestrator with no inline `steps:` of its own. Closing
that conformance gap for `ci.yml` is the motivation for this feature — not a wall-clock CI
duration claim, which the job-DAG evidence does not support.

## Personas & Scenarios

- Persona: Repository maintainer / CI operator.
  - Who they are: a maintainer with repository admin access who reviews and merges pull
    requests, monitors CI status, and is responsible for keeping branch-protection required
    checks accurate.
  - What they care about: being able to isolate and re-run a single failing CI gate quickly,
    without re-triggering unrelated gates; keeping `.github/workflows/**` consistent with the
    architecture already documented in `CLAUDE.md`; not breaking required-status-check
    enforcement when workflow files change.
  - Their constraints: changes to `.github/workflows/**` are gated by the
    `modified-workflow-needs-green-run` policy rule, so any workflow-file change requires a
    green run against the branch head as evidence before merge; required-status-check names are
    configured in branch protection and are not automatically kept in sync with job-name changes.
  - Their goals and frustrations: frustrated by a single 325-line `ci.yml` file where a syntax
    error or an unrelated edit risks the whole file; wants each gate to be independently
    dispatchable and independently reviewable.
  - Their context and motivations: this repository already has one reusable-workflow split in
    production (`_npm-audit-gate.yml` / `npm-audit-gate.yml`); the maintainer wants `ci.yml`
    brought into line with that same pattern.

- Scenario: A pull request triggers the seven CI gates; one gate fails and is re-run in
  isolation.
  - Who is acting: the repository maintainer, reviewing a pull request against `main`.
  - What triggered the action: the PR's `pull_request` trigger fires the rewritten `ci.yml`
    orchestrator, which invokes all seven `_<name>.yml` callees (`_quality-checks.yml`,
    `_security-scan.yml`, `_docs-validation.yml`, `_build-check.yml`, `_poshqc.yml`,
    `_shell-coverage.yml`, `_drm-copilot-extension-tests.yml`) with no `needs:` between them.
  - What steps they take: the maintainer opens the PR's "Checks" tab and observes the seven
    gates running as independent job runs (with `quality-checks7`'s 4-way Python matrix and
    `drm-copilot-extension-tests`'s 2-way OS matrix each contributing their own job runs). One
    gate — `_shell-coverage.yml` — fails on a transient `kcov` build issue. Rather than
    re-running the entire `ci.yml` workflow (which would re-trigger all seven gates), the
    maintainer runs `gh workflow run _shell-coverage.yml` to re-dispatch only the failed gate.
  - What obstacles or decisions occur: the maintainer must confirm that the required-status
    check name branch protection expects for the (formerly inline) `shell-coverage` job still
    matches the name produced by the now-`workflow_call`-invoked job; if it does not, the
    maintainer consults `.github/workflows/README.md`'s documented rename procedure, reads the
    actual check-run names via `gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs`, and
    updates branch protection's required-status-check list via `gh api ... PATCH
    .../required_status_checks` with the confirmed strings.
  - What outcome they expect: the re-dispatched `_shell-coverage.yml` run completes successfully,
    the corresponding required check turns green, and the PR becomes mergeable — without having
    re-run any of the other six gates.

## Acceptance Criteria

- [x] Each current `ci.yml` job (`quality-checks7`, `security-scan`, `docs-validation`,
      `build-check`, `poshqc`, `shell-coverage`, `drm-copilot-extension-tests`) is extracted into
      its own callable reusable workflow file named `_<name>.yml` declaring both
      `workflow_call` and `workflow_dispatch` triggers.
- [x] A thin orchestrator workflow (retaining the `ci.yml` name and its existing
      `push`/`pull_request`/`workflow_dispatch` triggers, or an equivalent replacement) invokes
      each reusable workflow via `uses: ./.github/workflows/_<name>.yml` with no inline
      `steps:` and no artificial `needs:` between independent gates.
- [x] Any cross-job file dependency uses explicit `actions/upload-artifact` /
      `actions/download-artifact`; no job relies on implicit shared-filesystem state from
      another job.
- [x] Required-status-check names referenced by branch protection continue to resolve after the
      split (renamed or preserved check names are documented). See
      `evidence/other/required-status-check-names.2026-07-03T18-07.md` and
      `evidence/other/branch-protection-update.2026-07-03T18-07.md` pending executor/reviewer
      sign-off.
- [x] `.github/workflows/README.md` documents the new per-stage dispatch and the required-check
      rename procedure.
- [x] A green workflow run against the branch head is captured before merge, per the
      `modified-workflow-needs-green-run` policy rule for workflow-file changes. See
      `evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md` pending executor/reviewer
      sign-off.

## Non-Goals

- No change to `publish-extension.yml` or `publish-mcp-npm.yml`. Both already maintain their own
  `needs:`-chained test-then-publish sequencing and do not reference `ci.yml` or any of the
  seven jobs in scope; this feature does not touch either file.
- No application-level code change. This feature is scoped to `.github/workflows/**` only; no
  files under `src/` or `extensions/drm-copilot/src` change.
- No claim of, or attempt to produce, a wall-clock CI-duration improvement. The seven-job DAG is
  already concurrent (zero `needs:` edges exist today), so extraction into reusable workflows
  does not, by itself, change scheduling concurrency or total run time. Any actual duration
  improvement (for example cache warming for `shell-coverage`, or trimming the
  `quality-checks7` Python matrix) is out of scope for this feature and would be a separate,
  independently measured follow-up.
- No change to any job's actual test, lint, build, or scan commands. Every extracted job's steps
  are lifted verbatim from the current `ci.yml`; only the `on:`/wrapper shape changes (inline
  `ci.yml` job to `workflow_call`/`workflow_dispatch`-triggered callee invoked via `uses:`).
- No new `actions/upload-artifact` / `actions/download-artifact` pairing beyond what already
  exists (`poshqc` and `shell-coverage` each already upload their own artifacts; no job in
  `ci.yml` currently downloads another job's artifacts, and this feature does not introduce such
  a dependency).
