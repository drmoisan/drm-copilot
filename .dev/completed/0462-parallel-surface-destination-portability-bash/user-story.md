# `parallel-surface-destination-portability-bash` — User Story

- Issue: #462
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-08-10T09-55

## Story Statement

- As a maintainer of a destination repository that has received the `.claude` push-down
  payload, I want `/parallel-plan` to run end-to-end using only bash, pwsh, and Node, so that
  I do not need to provision Python or Poetry to use the parallel orchestration surface.
- As the drm-copilot maintainer, I want the bash ports bound to the Python authority through a
  shared committed parity corpus asserted by both CI lanes, so that a second runtime port
  cannot drift silently from the schema contract the way an unbound port could.
- As a destination repository operator with locally customized orchestration routes, I want
  the push-down of `orchestration-routing.json` to add the `parallel` and `preparation` routes
  without removing or overwriting my destination-local routes, so that receiving the payload
  never breaks my existing configuration.
- As a reviewer of this repository, I want the pack manifest and its completeness test to
  enumerate `rules/`, `lib/`, and the published `config/` tree, so that the class of omission
  that caused blocker 4 cannot recur unnoticed.

## Problem / Why

`/parallel-plan` halts before fan-out in a destination repository that has received the
`.claude` push-down payload. The planner correctly reports four blocking findings, and all four
were verified against this repository:

1. **`compute_cohorts` is unreachable.** The Welsh-Powell cohort computation exists only as
   `scripts/dev_tools/parallel_cohort_computation.py`, which is outside the push-down payload.
   Unlike blast-radius and model-routing, it has no `.claude/lib/` destination-runtime port and
   no TypeScript MCP port. Without it a destination cannot seed `cohorts[]` and cannot run the
   P5 recomputation-parity check.
2. **Manifest-contract validation is unreachable.** `scripts/dev_tools/parallel_manifest_contract.py`
   is deliberately not an MCP `artifact_type` (per `.claude/rules/parallel-orchestration.md`), so
   it has no TypeScript surface and no destination-runtime port.
3. **`config/` is never published.** The Claude push-down publishes only the `.claude` root
   (`ROOT_FOLDERS = [".claude"]` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`).
   Neither `config/blast-radius.json` nor `config/orchestration-routing.json` reaches a
   destination, so the destination has no blast-radius config and no `parallel` route.
4. **`.claude/rules/parallel-orchestration.md` is not in the core pack manifest.** The file
   exists in this repository but is absent from the `paths` list in
   `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, so
   pack-selected push-down never publishes it.

A further constraint applies: the dev scripts a destination runtime needs for the parallel
surface must be **bash**, so a destination repository is not required to provision Python or
Poetry to run `/parallel-plan`.

## Personas & Scenarios

- Persona: **Destination repository maintainer.**
  - Operates a repository that consumes the drm-copilot push-down payload but is not the
    drm-copilot repository itself.
  - Cares about running the pushed orchestration surface with minimal provisioning; already
    has bash, pwsh, and Node (for the MCP server) available; does not want to install Python
    or Poetry.
  - Constraint: cannot modify the drm-copilot source; receives whatever the payload carries.
  - Goal: run `/parallel-plan` and `/parallel-run` against local work items. Frustration:
    today the planner halts on four blocking findings before fan-out.
- Persona: **drm-copilot repository maintainer / reviewer.**
  - Owns the Python authority modules, the push-down engine, and the parity discipline
    already established for the PowerShell and TypeScript ports.
  - Cares about: no silent drift between runtimes; no widening of the permission surface
    without explicit review; no change to the frozen parallel schema and its nine enums.
  - Constraint: cannot execute the bash toolchain in the win32 agent environment; verification
    is CI dispatch only.

- Scenario: **Running `/parallel-plan` at a destination after this feature.**
  - The destination maintainer refreshes the push-down payload. The publish now carries
    `config/orchestration-routing.json` (merged — the `parallel` and `preparation` routes are
    added, local routes preserved), a generic `config/blast-radius.json`,
    `.claude/rules/parallel-orchestration.md`, and the bash library under
    `.claude/lib/bash/`.
  - The maintainer invokes `/parallel-plan`. The planner resolves the `parallel` route, reads
    the blast-radius config, computes cohorts through
    `bash .claude/lib/bash/compute-cohorts.sh`, discharges the P5 recomputation-parity check,
    and validates the manifest through `bash .claude/lib/bash/validate-parallel-manifest.sh`.
  - No Python or Poetry is invoked at any step. The planner proceeds past all four previously
    reported blockers to fan-out.
- Scenario: **Verifying the bash port from this repository.**
  - An agent implements the bash library and parity corpora on a feature branch. Because no
    local delegate can run shfmt/shellcheck/bats/kcov on the win32 host, the agent pushes the
    branch and dispatches `gh workflow run _shell-coverage.yml --ref <branch>`, then polls the
    run to completion.
  - The agent records the run URL, conclusion, and the `Bash coverage (lines): NN.N%` log
    line under the feature's `evidence/qa-gates/` folder. The pytest lane asserts the same
    committed corpora locally, so a corpus change that breaks parity fails at least one lane.
  - The reviewer inspects the permission-surface diff (`parallel-planner.md`,
    `parallel-orchestrator.md`, `.claude/settings.json`) called out in the PR description, and
    confirms the schema surface (Python validators, TypeScript parity port, nine enums) is
    unchanged.

## Acceptance Criteria

- [x] A bash cohort-computation entry point exists under `.claude/lib/bash/` and, for every
      fixture in the shared corpus `tests/fixtures/parallel_cohorts/`, produces the same
      cohort partition (compact JSON, ascending inner lists, Welsh-Powell index assignment)
      and the same error messages as `scripts/dev_tools/parallel_cohort_computation.py`.
      Evidence: green `tests/shell/parallel_cohorts_parity.bats` in the `_shell-coverage.yml`
      lane and green `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` in the
      pytest lane, both enforcing a fixture-count floor.
- [x] A bash `compute_concurrency_batches` entry point exists under `.claude/lib/bash/`,
      chunks a cohort into consecutive ascending slices of at most `max_concurrency`, and
      rejects `max_concurrency < 1` with the exact Python error message. Evidence: batching
      fixtures in the shared corpus asserted by both parity suites.
- [x] A bash manifest-contract validator exists under `.claude/lib/bash/` and reproduces the
      M1-M7 error strings of `scripts/dev_tools/parallel_manifest_contract.py` byte-for-byte —
      including the `Parallel manifest` context prefix and Python `repr` quoting — for every
      fixture in `tests/fixtures/parallel_manifest_bash/`, with one documented exception: for
      the M1 YAML-parse-failure case, parity is scoped to the prefix
      `Parallel manifest frontmatter is not valid YAML: ` plus single-element error-list
      shape. Evidence: both parity suites green with the divergence class recorded in their
      headers.
- [x] The bash validator exposes default-resolving accessors for `mode` (default `closed`)
      and `max_concurrency` (default `4`) matching `manifest_mode` and
      `manifest_max_concurrency`. Evidence: bats cases covering present, absent, and invalid
      values.
- [x] Every new `.claude/lib/bash/` file has a byte-identical bundled mirror under
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/`. Evidence: a
      manifest-membership test following the `BlastRadius.Manifest.Tests.ps1` pattern that
      discovers the repo files and asserts, for each, a `core.json` entry and a bundled
      counterpart.
- [x] The Claude push-down publishes `config/orchestration-routing.json` and
      `config/blast-radius.json` to a destination workspace, including under pack-scoped
      publishes. Evidence: Jest cases against the push-down service-call path.
- [x] The publish of `config/orchestration-routing.json` merges with a pre-existing
      destination file: the source `parallel` route is source-authoritative; the
      `preparation` route (and any other source route absent at the destination) is added;
      destination-local routes are preserved verbatim; a second push is byte-stable; an
      unparseable destination file fails with a reported error and is not overwritten.
      Evidence: Jest cases for copy, merge, stale-`parallel` overwrite, local-route
      preservation, idempotency, and fail-fast.
- [x] The published `blast-radius.json` default contains no drm-copilot-only entries:
      `shared_surfaces` limited to payload-guaranteed paths, `shared_surface_globs` empty,
      structure-guaranteed `modules` only, `over_breadth_fraction` 0.25; this repository's
      root `config/blast-radius.json` is unchanged. Evidence: Jest assertion on the published
      content plus diff review.
- [x] The Copilot and Codex push-down published sets are unchanged. Evidence: Jest
      non-regression cases for both entry points.
- [x] `core.json` lists `.claude/rules/parallel-orchestration.md`, every new
      `.claude/lib/bash/` path, `config/orchestration-routing.json`, and
      `config/blast-radius.json`. Evidence: the extended completeness test passes against the
      final tree.
- [x] `claude-pack-manifest-completeness.test.ts` enumerates `rules/*.md`, all files under
      `lib/**` recursively, and the bundled `config/` tree, so an unlisted file in any of
      those locations fails the test. Evidence: the extended enumeration is visible in the
      test diff and the suite is green.
- [x] The Shell-QC discovery contract and kcov include pattern cover `.claude/lib/bash/**`:
      search roots and include pattern extended in `scripts/bash/shell_qc_lib.sh`,
      `.claude/rules/shell.md` prose updated, and the existing shell-qc bats tests extended.
      Evidence: the CI coverage report enumerates the new library files.
- [x] shfmt, shellcheck, and bats pass on all new and modified shell files, and bash line
      coverage is >= 85%. Evidence: a green `_shell-coverage.yml` run against the branch
      head, with the run URL, conclusion, and the `Bash coverage (lines): NN.N%` log line
      recorded under
      `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/qa-gates/`.
- [x] Destination-runtime references in the `parallel-plan`, `parallel-orchestrate`, and
      `parallel-add` skills and the `parallel-planner` and `parallel-orchestrator` agents
      invoke the bash entry points (blast-radius references invoke the existing PowerShell
      port); the Python modules are cited only as repository authority and parity reference.
      Evidence: no `poetry run` invocation remains on the `/parallel-plan`
      destination-runtime path (grep over `.claude/`).
- [x] Bash allowlist entries permitting execution of the `.claude/lib/bash` entry points are
      added to `parallel-planner.md`, `parallel-orchestrator.md`, and
      `.claude/settings.json`, and the pull request identifies them as a deliberate
      permission-surface change. Evidence: diff review of the three files and the PR
      description.
- [x] A payload-only workspace with no Python and no Poetry clears all four reported
      blockers. Evidence: Jest in-memory push-down assertions for payload content, plus a
      bats case on `ubuntu-latest` invoking the published bash entry points from a directory
      containing only the payload.
- [x] No parallel-surface schema field, enum member, or validator invariant is added,
      removed, or altered: the Python validators, `_parallel_state_*` helpers, and the
      TypeScript parity port are unchanged by this feature. Evidence: diff scope review.

## Non-Goals

- **The parallel state validators.** Already ported to TypeScript and reachable through the
  MCP `validate_orchestration_artifacts` tool (`parallel-orchestrator-state`,
  `parallel-planner-state`, `parallel-kickoff`). No bash port and no new MCP
  `artifact_type`.
- **Blast-radius computation.** Already has a pushed-down PowerShell port under
  `.claude/lib/blast-radius/`; the user explicitly declined replacing the PowerShell ports
  with bash. Only the wiring is repointed at the existing port.
- **`parallel_drift_detection_cli` and `parallel_mutation_abandon_cli`.** Execution-phase
  concerns (F8 and F6 respectively), not `/parallel-plan` blockers. They remain Python-only
  at destinations and are recorded as known residual destination gaps.
- **Two pre-existing defects, recorded but not fixed here:**
  `scripts/dev_tools/validate_orchestrator_state.py` has no `__main__` guard, so its
  documented CLI form is a silent no-op; and `poetry run python -c` with a multi-line string
  silently no-ops in this environment. Both are adjacent defects to file separately.
