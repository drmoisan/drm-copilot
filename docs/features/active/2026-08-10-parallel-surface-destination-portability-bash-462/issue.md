# parallel-surface-destination-portability-bash (Issue #462)

- Date captured: 2026-08-10
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-surface-destination-portability-bash/ (Issue #462)

- Issue: #462
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/462
- Last Updated: 2026-08-10
- Work Mode: full-feature

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

Two reported blockers are already covered and are explicitly out of scope. The parallel state
validators are reachable through the shipped TypeScript MCP surface
(`validate_orchestration_artifacts` accepts `parallel-orchestrator-state`,
`parallel-planner-state`, and `parallel-kickoff`), and blast-radius computation already has a
pushed-down PowerShell port under `.claude/lib/blast-radius/`.

## Proposed Behavior

Close the destination-runtime gap without changing the parallel schema or its enum set.

- Add a bash destination-runtime layer under `.claude/lib/bash/` covering the two capabilities
  that have no existing port: cohort computation and manifest-contract validation. The Python
  modules remain the repository authority and the parity reference, matching the precedent
  `CLAUDE.md` already documents for `.claude/lib/blast-radius/` and `.claude/lib/model-routing/`.
- Extend the Claude push-down payload to carry `config/`, with a merge strategy for
  `orchestration-routing.json` that adds the `parallel` route without clobbering
  destination-local routes, and a repo-agnostic default for `blast-radius.json` that does not
  hard-code drm-copilot-only module roots (`scripts/dev_tools`, `packages/mcp-server`,
  `poetry.lock`, `package-lock.json`).
- Add the missing `.claude/rules/parallel-orchestration.md` entry, and the new bash paths, to the
  core pack manifest.
- Point the destination-runtime instructions in the parallel skills and agents at the bash entry
  points, leaving the repository-local Python invocations unchanged.

## Acceptance Criteria (early draft)

- [ ] A bash `compute_cohorts` entry point exists under `.claude/lib/bash/` and produces output
      identical to `scripts/dev_tools/parallel_cohort_computation.py` for a shared fixture corpus.
- [ ] A bash manifest-contract validator exists under `.claude/lib/bash/` and emits the same M1-M7
      error strings as `scripts/dev_tools/parallel_manifest_contract.py` for a shared fixture corpus.
- [ ] A parity test binds the bash output to the Python output so the two cannot drift silently.
- [ ] The Claude push-down publishes `config/blast-radius.json` and `config/orchestration-routing.json`
      to a destination workspace.
- [ ] Push-down of `orchestration-routing.json` adds the `parallel` route without removing or
      overwriting routes already present at the destination.
- [ ] The published `blast-radius.json` default contains no drm-copilot-only module roots.
- [ ] `core.json` lists `.claude/rules/parallel-orchestration.md` and every new
      `.claude/lib/bash/` path.
- [ ] A destination workspace that has received the payload can run `/parallel-plan` past all four
      reported blockers with no Python or Poetry installed.
- [ ] The bash toolchain (shfmt, shellcheck, bats) passes on the new shell files, and line
      coverage meets the uniform >= 85% threshold.
- [ ] No parallel-surface schema field, enum member, or validator invariant is added, removed, or
      altered.

## Constraints & Risks

- **Bash verification is CI-only.** Per `.claude/rules/shell.md`, the toolchain runs under WSL
  locally and on `ubuntu-latest` in CI. No delegate in this environment can execute it, so CI
  dispatch is the verification path for every shell change. This lengthens each iteration.
- **YAML frontmatter parsing in bash.** The manifest contract validates a frontmatter block whose
  `items[]` entries carry a nested `blast_radius` object. Parsing nested YAML in pure bash is the
  principal technical risk and needs a decided approach before planning.
- **Exact-parity requirement.** Planner invariant P5 and the M1-M7 error strings mean the bash
  output must match the Python byte-for-byte, including the `pythonRepr` quoting convention. The
  three known TypeScript divergence classes recorded in `.claude/rules/parallel-orchestration.md`
  are a map of where a second port is likely to diverge.
- **Push-down blast radius.** Adding a second root folder to the push-down engine affects the
  Copilot and Codex push-down paths that share the engine; the change must not alter their
  published sets.
- **Merge semantics are new.** Push-down is currently a copy. A merging publish for
  `orchestration-routing.json` introduces a behavior the engine does not have today.
- **500-line file cap** applies to the new shell files, so the cohort and manifest ports will
  likely split across several files plus a shared library.

## Test Conditions to Consider

- [ ] bats unit coverage for the bash cohort computation: empty graph, single item, disjoint
      items, fully connected items, deterministic tie-breaking, and generation handling.
- [ ] bats unit coverage for the bash manifest validator: each of M1-M7, plus LF/CRLF/CR
      frontmatter extraction and the `mode`/`max_concurrency` default-resolving accessors.
- [ ] Parity fixtures shared by the bash and Python suites, asserting identical output.
- [ ] Jest coverage for the push-down config carriage: config published, routing merged, existing
      destination routes preserved, and the Copilot/Codex published sets unchanged.
- [ ] A pack-manifest test asserting every `.claude/rules/*.md` and `.claude/lib/**` file on disk
      has a `core.json` entry, so this class of omission cannot recur.
- [ ] An end-to-end check that a payload-only workspace clears all four reported blockers.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-surface-destination-portability-bash/` folder from the template
