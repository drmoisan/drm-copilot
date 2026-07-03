# 2026-07-03-parallel-ci-subworkflows — Spec

- **Issue:** #294
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-03T18-07
- **Status:** Draft
- **Version:** 0.2

## Overview

`.github/workflows/ci.yml` defines seven jobs (`quality-checks7` with a 4-way Python matrix,
`security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`,
`drm-copilot-extension-tests` with a 2-way OS matrix). A full-file read confirms zero `needs:`
edges across all seven jobs: GitHub Actions already schedules all 11 resulting job runs as an
independent, concurrently-eligible DAG. This feature does not change that DAG's concurrency —
the jobs were already concurrent before this change and remain concurrent after it. Extraction
by itself produces no wall-clock improvement claim; any such improvement would come from a
separate, measurable follow-on (for example cache warming for `shell-coverage`, or trimming the
`quality-checks7` Python matrix), not from this refactor.

What this feature does change is architecture conformance and operability. `CLAUDE.md` and
`.claude/skills/orchestrate/SKILL.md` already document a target shape — every CI gate ships as a
callable reusable workflow (`_<name>.yml`, declaring both `workflow_call` and `workflow_dispatch`)
invoked by a thin orchestrator with no inline `steps:` — and this repository already applies that
shape once, in production, via `_npm-audit-gate.yml` / `npm-audit-gate.yml`. `ci.yml` is the one
remaining CI file that does not conform. Extracting its seven jobs into `_<name>.yml` callees and
rewriting `ci.yml` into a thin orchestrator closes that conformance gap, gives each gate an
independent `workflow_dispatch` re-run entry point (a maintainer can re-run `_shell-coverage.yml`
alone without re-running the other six), and reduces the blast radius of a single malformed YAML
edit, since a syntax error in one gate's file no longer risks the entire `ci.yml` file.

## Behavior

Approach A (recommended in research, Section 2): extract each of the seven current `ci.yml` jobs
into its own reusable workflow file, and rewrite `ci.yml` into a thin orchestrator.

- Seven new files, each declaring both `on: workflow_call:` and `on: workflow_dispatch:`,
  mirroring `_npm-audit-gate.yml`'s shape:
  - `.github/workflows/_quality-checks.yml` — retains the 4-way `python-version` matrix
    (`"3.10"`, `"3.11"`, `"3.12"`, `"3.13"`) declared inline in the callee job, unchanged.
  - `.github/workflows/_security-scan.yml`
  - `.github/workflows/_docs-validation.yml`
  - `.github/workflows/_build-check.yml`
  - `.github/workflows/_poshqc.yml`
  - `.github/workflows/_shell-coverage.yml`
  - `.github/workflows/_drm-copilot-extension-tests.yml` — retains the 2-way `os` matrix
    (`windows-latest`, `ubuntu-latest`) declared inline in the callee job, unchanged.
- Each callee's job steps are lifted verbatim from the corresponding job in the current
  `ci.yml` — no step-content, command, or tool-invocation changes. GitHub Actions supports
  `strategy.matrix` inside a `workflow_call`-invoked job (confirmed by both GitHub's
  documentation and the existing `_npm-audit-gate.yml` precedent in this repository), so the two
  matrix strategies stay declared inside their respective callees rather than being flattened,
  parameterized, or hoisted to the caller.
- `ci.yml` is rewritten to retain its existing `push`/`pull_request`/`workflow_dispatch`
  triggers, containing only seven job bodies, each solely `uses:
  ./.github/workflows/_<name>.yml`, with no `needs:` between any of the seven (they are
  independent gates today and remain independent), and no inline `steps:`.
- `.github/workflows/README.md` (currently absent — confirmed by direct `Glob` of
  `.github/workflows/*`, which returns only `_npm-audit-gate.yml`, `ci.yml`,
  `npm-audit-gate.yml`, `publish-extension.yml`, `publish-mcp-npm.yml`) is created, documenting
  the new per-stage `workflow_dispatch` entry points and the required-status-check rename
  procedure (see Implementation Strategy).
- Zero cross-job filesystem dependencies exist among the seven jobs today (confirmed by a full
  read of all seven job bodies), so no new `actions/upload-artifact` /
  `actions/download-artifact` pairing is introduced. The two existing uploads (`poshqc`,
  `shell-coverage`, each uploading Pester/coverage artifacts for its own job) carry over
  unchanged into their respective `_<name>.yml` files.
- Reusable-workflow nesting: this refactor introduces exactly one level of nesting
  (`ci.yml` orchestrator → `_<name>.yml` callee), within both this repository's documented
  self-imposed cap of 4 and GitHub's actual platform cap of 10 total levels.
- `publish-extension.yml` and `publish-mcp-npm.yml` are unaffected: both already maintain their
  own `needs:`-chained test-then-publish sequencing, and neither references `ci.yml` or any of
  the seven jobs in scope.

## Inputs / Outputs

- Inputs: none required. Each `_<name>.yml` declares `on: workflow_call:` and
  `on: workflow_dispatch:` with no `inputs:` block, since none of the seven current jobs accept
  caller-supplied parameters today. This mirrors the minimum contract already used by
  `_npm-audit-gate.yml` (which does declare one input, `audit-level`, because its caller
  supplies one — the seven gates in this feature have no equivalent caller-supplied value).
- Outputs: the existing Pester/coverage artifacts produced by `poshqc` and `shell-coverage` via
  `actions/upload-artifact@v7`, unchanged in content and unchanged in which job produces them.
  Beyond those two artifact sets, the observable output of each gate is its own
  `workflow_call`/`workflow_dispatch` run status (pass/fail), surfaced as a GitHub Actions
  check run.
- Config keys and defaults: none introduced. No new environment variables, secrets, or
  repository variables are added.
- Versioning or backward-compatibility constraints: the compatibility surface most affected by
  this change is required-status-check names configured in branch protection. Because a job
  invoked via `uses:` may compose a different check-run display name than the same job did when
  defined inline in `ci.yml`, branch protection's required-checks list must be re-verified and,
  if necessary, updated after the extraction lands (see Implementation Strategy for the exact
  procedure). No other backward-compatibility surface exists — this is a `.github/workflows/**`
  -only change with no public API, package, or schema affected.

## API / CLI Surface

This is not an application CLI or API change; the operational surface introduced is the set of
per-gate manual dispatch entry points and the branch-protection maintenance commands.

- Per-gate manual re-run: `gh workflow run _<name>.yml` for any of the seven new files (for
  example `gh workflow run _shell-coverage.yml`), which runs that single gate in isolation
  without triggering the other six.
- Branch-protection required-check inspection and rename, run once after the extraction lands
  and produces a green run against the branch head:
  - `gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs` — read the actual composed
    check-run names GitHub produced for each extracted job (not an assumed naming format).
  - `gh api repos/{owner}/{repo}/branches/{branch}/protection/required_status_checks` (GET) —
    read the current required-check contexts configured in branch protection.
  - `gh api repos/{owner}/{repo}/branches/{branch}/protection/required_status_checks` (PATCH,
    with an updated `checks` array of `{ "context": string, "app_id": integer|null }` entries) —
    replace stale pre-extraction context strings with the confirmed post-extraction strings.
- Contracts and validation rules: each `_<name>.yml` must be valid YAML and pass `actionlint`,
  matching the existing validation applied to `_npm-audit-gate.yml`. Each callee's
  `workflow_call`/`workflow_dispatch` triggers carry no required `inputs:`, so no caller is
  obligated to supply parameters when invoking any of the seven gates.

## Data & State

No application data, storage, or persistence changes. State changes are limited to:

- `.github/workflows/**` YAML file structure (seven new files, one rewritten file, one new
  `README.md`).
- A one-time, post-merge branch-protection required-status-check configuration update (not a
  file in this repository; a GitHub repository-settings change applied via the `gh api`
  commands documented above and in `README.md`).

No data transformations, caching, or migration/backfill requirements apply — no job's actual
test/build/lint invocation changes, and the two existing artifact uploads are carried over with
identical content and identical retention behavior.

## Constraints & Risks

- GitHub Actions runner-concurrency limits (plan-dependent) bound how much wall-clock benefit
  parallelization yields; this repository's per-trigger job count (11) is below the lowest
  published account-tier concurrent-job cap (20, Free tier), so the seven gates are not expected
  to be concurrency-throttled against each other under normal conditions — this was already true
  before this change and is unaffected by the extraction.
- Reusable-workflow nesting depth is capped at 4 levels in this repository (more conservative
  than GitHub's actual 10-level cap); this refactor introduces exactly one level of nesting and
  does not approach either cap.
- Branch protection required-status-check names are tied to job names; extracting an
  already-required job into a `workflow_call`-invoked callee can silently break required-check
  enforcement unless the rename procedure (Implementation Strategy) is applied and documented.
  This risk is distinct from `_npm-audit-gate.yml`'s introduction, which created a new required
  check rather than renaming an existing one.
- No job may assume another job's on-disk artifacts are present without an explicit
  upload/download step; this constraint is already satisfied today (zero cross-job filesystem
  dependencies confirmed) and must remain satisfied after extraction.
- This is a CI-only (`.github/workflows/**`) change; it does not alter application behavior in
  `src/` or `extensions/drm-copilot/src`, and does not modify `publish-extension.yml` or
  `publish-mcp-npm.yml`.

## Implementation Strategy

- Implementation scope: extract the seven jobs listed in Behavior into seven new `_<name>.yml`
  files, rewrite `ci.yml` into a thin orchestrator, and create `.github/workflows/README.md`.
  No other files change.
- Each extracted job's steps are lifted verbatim from the corresponding job block in the current
  `ci.yml` — no step-content, command, tool-version, or matrix-value changes. Behavior is
  preserved byte-for-byte; only the `on:`/wrapper shape changes (job moves from an inline
  `ci.yml` job to a `workflow_call`/`workflow_dispatch`-triggered callee invoked via `uses:`).
- No new dependencies (packages, actions, or tools) are introduced by this feature.
- No feature flags or staged rollout are needed: this is a CI-only change gated by the
  repository's existing `modified-workflow-needs-green-run` policy rule, which already requires
  a green workflow run against the branch head before any `.github/workflows/**` diff can merge.
  That gate is the rollout safeguard.
- Required-status-check rename procedure (to be documented verbatim in the new
  `.github/workflows/README.md`):
  1. Land the extraction and produce a `workflow_dispatch` or PR run against the branch head
     (already required by AC-6 / `modified-workflow-needs-green-run`).
  2. Read the actual composed check-run names via
     `gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs` — do not assume a naming
     format.
  3. `gh api repos/{owner}/{repo}/branches/{branch}/protection/required_status_checks` (PATCH)
     with the confirmed new context strings, removing stale pre-extraction context strings from
     the `checks` array once the new checks are verified present.
  4. Document both the old and new context strings, plus the exact `gh api` commands used, in
     `.github/workflows/README.md`.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos (see `user-story.md`)
- [x] Each of the seven jobs is extracted into its own `_<name>.yml` file declaring
      `workflow_call` and `workflow_dispatch`, with steps lifted verbatim
- [x] `ci.yml` is rewritten as a thin orchestrator: seven `uses:` job bodies, no `needs:` between
      independent gates, no inline `steps:`
- [x] `.github/workflows/README.md` is created, documenting per-stage dispatch and the
      required-status-check rename procedure
- [ ] Each new `_<name>.yml` file is independently exercised via its own `workflow_dispatch` and
      completes successfully
- [x] `actionlint` and YAML-parse validation pass for all seven new files and the rewritten
      `ci.yml`
- [ ] A green workflow run against the branch head is captured as evidence, satisfying
      `modified-workflow-needs-green-run`
- [ ] Required-status-check names are read from the branch-head run's actual check-runs and
      branch protection is updated (or confirmed unchanged) to match, per the rename procedure
- [x] No `src/` or `extensions/drm-copilot/src` files are touched; `publish-extension.yml` and
      `publish-mcp-npm.yml` are unmodified

## Seeded Test Conditions (from potential)

- [ ] Each new `_<name>.yml` reusable workflow can be invoked standalone via
      `gh workflow run _<name>.yml` (`workflow_dispatch`) and completes successfully, confirming
      the extraction preserved the job's pass/fail behavior byte-for-byte.
- [ ] The rewritten `ci.yml` orchestrator triggers all seven reusable workflows without any
      `needs:` chain forcing sequential execution among independent gates.
- [ ] `actionlint` and a YAML-parse check pass for every new/modified file under
      `.github/workflows/**`, matching the validation already applied to `_npm-audit-gate.yml`.
- [ ] A workflow run against the branch head confirms all seven gates execute (concurrently, as
      they did before this change) and reach a green (passing) status; this run also serves as
      the evidence required by `modified-workflow-needs-green-run`.
- [ ] `gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs` against the branch-head run
      confirms the actual composed check-run names for each of the seven extracted gates, and
      branch protection's required-status-check list is verified (and updated if needed) against
      those confirmed names.
