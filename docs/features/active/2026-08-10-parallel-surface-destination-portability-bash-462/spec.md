# parallel-surface-destination-portability-bash — Spec

- **Issue:** #462
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-10T09-55
- **Status:** Draft
- **Version:** 0.2

## Overview

`/parallel-plan` halts before fan-out in a destination repository that has received the
`.claude` push-down payload. The planner correctly reports four blocking findings, and all four
were verified against this repository (re-verified by the research artifact
`research/2026-08-10T09-45-parallel-destination-portability-bash-research.md`):

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
Poetry to run `/parallel-plan`. After this feature, the parallel surface at a destination runs
on bash + pwsh + Node (MCP), with Python and Poetry fully removed from the runtime path.

## Behavior

Close the destination-runtime gap without changing the parallel schema or its enum set. The
fix has four parts.

### 1. Bash destination-runtime layer

Add a bash library under `.claude/lib/bash/` covering the two capabilities with no existing
port, mirroring the `.claude/lib/blast-radius/*.psm1` precedent:

- **Cohort computation.** Port both public functions of
  `scripts/dev_tools/parallel_cohort_computation.py`: `compute_cohorts` (Welsh-Powell
  ordering, greedy smallest-free-index assignment, ascending inner-list output) and
  `compute_concurrency_batches` (ascending consecutive chunking, `max_concurrency >= 1`
  rejection with the exact Python message). Porting only `compute_cohorts` would leave
  `/parallel-run` with the same class of destination gap this feature closes for
  `/parallel-plan`; `.claude/skills/parallel-orchestrate/SKILL.md` names
  `compute_concurrency_batches` as the execution-phase slot-filling mechanism.
- **Manifest-contract validation.** Port `validate_parallel_manifest_text` (invariants M1-M7)
  and the default-resolving accessors `manifest_mode` (default `closed`) and
  `manifest_max_concurrency` (default `4`) from
  `scripts/dev_tools/parallel_manifest_contract.py` and its helper
  `scripts/dev_tools/_parallel_state_common.py`. YAML frontmatter is parsed by a hand-written
  bash parser restricted to the machine-authored manifest subset (block-style mappings and
  lists, plain/quoted scalars, lexical type classification); any construct outside the subset
  is rejected fail-closed. External YAML tools (`yq`) and Node-based validation are rejected —
  the first reintroduces destination provisioning, the second violates the F3 boundary and the
  no-schema-change constraint.

The Python modules under `scripts/dev_tools/` remain the repository authority and the parity
reference. In both this repository and destinations, the bash entry points are the agent
runtime invocation; the Python modules are exercised by pytest, not by agent runtime
instructions, which eliminates a dual-instruction drift surface.

### 2. Push-down config carriage

- Add the bundled subtree `extensions/drm-copilot/resources/claude-customizations/config/`
  containing `orchestration-routing.json` (canonical routes, including `parallel` and
  `preparation`) and a **repo-agnostic** `blast-radius.json` default.
- Extend `ROOT_FOLDERS` in `claude-customizations.ts` to `[".claude", "config"]` (`config`
  appended after `.claude`; enumeration order is the summary-artifact contract). The constant
  is Claude-entry-local; the Copilot and Codex entry points do not read it, so their published
  sets are unaffected.
- Add a destination-aware merging publish for the single path
  `config/orchestration-routing.json`, implemented as a Claude-side filesystem decorator (the
  seam `ExcludingFileSystem` already occupies) — not in the shared engine and not in
  `rewriteReferences`, which receives source text only. Merge rule:
  1. Destination file absent → write the source text unchanged.
  2. Destination file present → start from the destination document; the source `parallel`
     route is source-authoritative (overwrite or insert); any other source route absent at the
     destination (including `preparation`) is added; any route present at the destination is
     preserved verbatim; top-level non-`routes` blocks are added when absent and preserved
     when present.
  3. Pushing twice must be byte-stable (idempotent).
  4. An unparseable destination file fails that file with an explicit error in the run
     summary; it is never clobbered.
- `config/blast-radius.json` is a plain overwrite, matching every other pushed file. The
  generic default carries: `version: 1`; `shared_surfaces` limited to paths the push-down
  itself guarantees (`.claude/settings.json`, `config/orchestration-routing.json`,
  `config/blast-radius.json`); empty `shared_surface_globs`; structure-guaranteed `modules`
  only (`claude-runtime`, `config`, `docs`, `tests`); `over_breadth_fraction: 0.25`. The
  contention relation fails closed on path overlap, so a sparse config never hides contention.
- This repository's richer root `config/blast-radius.json` is unchanged. The bundled generic
  default and the repo-root file are intentionally different documents — unlike the `.claude`
  tree, no bundle-parity byte-equality holds for `config/`, and this asymmetry is documented
  so a future parity test does not assert it.

### 3. Pack-manifest correction

- Add to `core.json` `paths`: `.claude/rules/parallel-orchestration.md`, every new
  `.claude/lib/bash/` file, and `config/orchestration-routing.json` plus
  `config/blast-radius.json` (pack-scoped publishes filter all enumerated files against the
  manifest union, so unlisted config files would be dropped under `--packs`).
- Extend `claude-pack-manifest-completeness.test.ts` — whose enumeration currently walks only
  `agents/*.md`, `hooks/*.ps1`, and `skills/*/SKILL.md` — to also enumerate `rules/*.md`, all
  files under `lib/**` recursively (not extension-filtered), and the bundled `config/` tree,
  so this omission class cannot recur.
- Add a bash-library manifest-membership test following the
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` pattern: discover the
  repo `.claude/lib/bash/*.sh` files, assert each has a `core.json` entry and a byte-identical
  bundled counterpart.

### 4. Toolchain reach

Extend the Shell-QC discovery contract and the kcov include pattern in
`scripts/bash/shell_qc_lib.sh` to cover `.claude/lib/bash/**`, which is currently invisible to
shfmt/shellcheck discovery and excluded from coverage measurement. Update the Discovery
Contract and Coverage sections of `.claude/rules/shell.md` (the `**/*.sh` activation glob
already covers the new files; only prose changes). Extend the existing shell-qc bats tests for
the new root. The alternative — canonical sources under `scripts/bash/parallel/` with
`.claude/lib/bash/` as a mirror — is rejected because it introduces a third copy and
contradicts the `.claude/lib` precedent.

### Destination-runtime wiring

Repoint the destination-runtime references in `.claude/skills/parallel-plan/SKILL.md`,
`.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`,
`.claude/agents/parallel-planner.md`, and `.claude/agents/parallel-orchestrator.md` at the
bash entry points (blast-radius references repoint at the existing PowerShell port). Add Bash
allowlist entries for the `.claude/lib/bash` entry points to `parallel-planner.md`,
`parallel-orchestrator.md`, and `.claude/settings.json`. This is a deliberate, reviewable
change to the permission surface and must be called out as such in the pull request.

## Inputs / Outputs

- **Inputs:**
  - Cohort CLI: item keys and conflict edges as CLI arguments (or stdin), integers matching
    `-?[0-9]+`; leading-zero tokens are rejected or normalized per a documented lexical rule
    (bash `$((...))` treats leading zeros as octal).
  - Batch CLI: item keys plus `--max-concurrency <n>`.
  - Manifest CLI: a manifest file path; frontmatter tolerant of LF, CRLF, and CR.
- **Outputs:**
  - Cohort/batch CLIs: one compact JSON array of arrays on stdout (identical to Python's
    `json.dumps(..., separators=(",", ":"))`); exact Python error message on stderr with exit
    code 1 on invalid input.
  - Manifest CLI: validation errors one per line on stdout; exit 0 when valid, 1 when not;
    accessor subcommands print the resolved `mode` or `max_concurrency` value.
- **Config keys and defaults:** `manifest_mode` default `closed`; `manifest_max_concurrency`
  default `4`; generic `blast-radius.json` `over_breadth_fraction` 0.25.
- **Versioning / backward compatibility:** no schema or validator change; the merge rule
  preserves all destination-local routing content; Copilot and Codex published sets are
  byte-unchanged.

## API / CLI Surface

Recommended entry-point shapes (final flag spelling fixed at planning; the output and error
contracts above are fixed here):

- `bash .claude/lib/bash/compute-cohorts.sh --keys "<k1> <k2> ..." --edges "<a>:<b> ..."` →
  e.g. `[[101,103],[102]]`.
- `bash .claude/lib/bash/compute-concurrency-batches.sh --keys "<...>" --max-concurrency <n>`.
- `bash .claude/lib/bash/validate-parallel-manifest.sh <manifest-path>`, plus `--print-mode`
  and `--print-max-concurrency` subcommands.

Contract and validation rules: the Python modules are the authority. Validation ordering must
match the Python exactly — duplicate-key errors precede edge errors; the self-loop check
precedes the unknown-endpoint check for the same edge; M1 fence errors precede identity,
prohibited-key, and item errors. Error strings reproduce the `Parallel manifest ` context
prefix, the shared `enum_error` template, and Python `repr` quoting (including the
quote-selection rule the TypeScript port does not implement).

## Data & State

- **Data transformations and invariants:** the cohort port must preserve the single
  load-bearing determinism guard — the total-order composite sort key `(-degree, item_key)` —
  and the ascending-inner-list output shaping. All numeric ordering uses `sort -n` under
  `LC_ALL=C`; bash associative-array iteration order must never reach output.
- **Caching or persistence:** none. All new bash functions are pure computations over CLI
  input; the checkpoint cache doctrine of `.claude/rules/parallel-orchestration.md` is
  untouched.
- **Migration or backfill:** none. The routing merge handles pre-existing destination files;
  no destination migration step is required.

## Constraints & Risks

- **Dual-home requirement.** Production push-down reads from the bundled tree at
  `extensions/drm-copilot/resources/claude-customizations/.claude/`, not from the repo root
  (`push-down-service-call.ts` resolves `sourceRoot` to the bundle). Every new bash file needs
  both a repo copy under `.claude/lib/bash/` and a byte-identical bundled mirror, asserted by
  a manifest-membership test per the existing `.psm1` precedent.
- **Exact-parity requirement, with one scoped-out divergence class.** Planner invariant P5
  implies recomputation parity for cohorts; the manifest validator must reproduce the M1-M7
  error strings byte-for-byte, including the `Parallel manifest` context prefix and Python's
  `repr` quoting. One new divergence class is unavoidable and is explicitly scoped out of
  byte parity: the M1 YAML-parse-failure message embeds the PyYAML exception text, which bash
  cannot reproduce. For that single case the parity contract is the message prefix
  `Parallel manifest frontmatter is not valid YAML: ` plus single-element error-list shape,
  recorded as a declared divergence class in the parity-suite headers, following the
  verified-scope precedent of the TypeScript port.
- **No schema change.** No parallel-surface schema field, enum member, or validator invariant
  may be added, removed, or altered. The nine enums in
  `.claude/rules/parallel-orchestration.md` are consumed, never extended. No new MCP
  `artifact_type` is added.
- **CI-only verification for bash.** Per `.claude/rules/shell.md`, the shell toolchain runs
  under WSL locally and on `ubuntu-latest` in CI; no agent in this environment can execute
  it. This is an explicit verification constraint, not a risk to be resolved later:
  verification of every shell change is via `gh workflow run _shell-coverage.yml --ref
  <branch>` (or the PR-triggered `ci.yml` run), with the run URL, conclusion, and the
  `Bash coverage (lines): NN.N%` log line captured as evidence under
  `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/qa-gates/`.
- **500-line cap.** Applies to every new shell file. The port is decomposed into eight files
  (see Implementation Strategy); `parallel-yaml-subset.sh` carries the highest cap risk and
  has a pre-planned scanner/emitter split if it approaches the limit.
- **Coverage.** kcov reports line coverage only. The uniform >= 85% line threshold applies to
  the bash files; there is no bash branch-coverage gate.
- **Permission surface change.** New Bash allowlist entries for the `.claude/lib/bash` entry
  points in `parallel-planner.md`, `parallel-orchestrator.md`, and `.claude/settings.json`
  widen the permitted command surface. This is a deliberate, reviewable change and must be
  reviewed as such.
- **Push-down blast radius.** The `ROOT_FOLDERS` extension is Claude-entry-local (verified:
  neither the Copilot nor the Codex entry reads it); explicit Jest non-regression cases pin
  both other published sets.
- **Merge semantics are new.** Push-down is currently a copy. The merging publish is confined
  to one destination-relative path, implemented in the Claude-side decorator seam, guarded by
  idempotency and fail-fast tests.
- **Bash determinism hazards.** Lexicographic `sort` defaults, octal leading-zero arithmetic,
  locale collation, and unspecified associative-array iteration order are the known parity
  hazards; the countermeasures (strict token regex, `sort -n`, `LC_ALL=C`, no
  associative-array iteration into output) are fixed by the research artifact and binding on
  implementation.
- **Generic blast-radius default under-detects at destinations.** Module and shared-surface
  contention reasons fire less often under the sparse default until a destination enriches its
  config; path overlap remains fully derived and fail-closed, so contention is never hidden.

## Non-Goals

- **The parallel state validators.** Already ported to TypeScript and reachable through the
  MCP `validate_orchestration_artifacts` tool (`parallel-orchestrator-state`,
  `parallel-planner-state`, `parallel-kickoff`). No bash port and no new MCP surface.
- **Blast-radius computation.** Already has a pushed-down PowerShell port under
  `.claude/lib/blast-radius/`; the user explicitly declined replacing the PowerShell ports
  with bash. In-scope only to repoint destination-runtime references at the existing port.
- **`parallel_drift_detection_cli` and `parallel_mutation_abandon_cli`.** Execution-phase
  concerns (F8 and F6 respectively), not `/parallel-plan` blockers. They remain Python-only at
  destinations and are recorded here as known residual destination gaps, not covered by this
  feature.
- **Two pre-existing defects, recorded but not fixed here:**
  `scripts/dev_tools/validate_orchestrator_state.py` has no `__main__` guard, so its
  documented CLI form is a silent no-op; and `poetry run python -c` with a multi-line string
  silently no-ops in this environment. Both are adjacent defects to file separately.

## Implementation Strategy

- **Scope of change (per research summary F-A through F-E):**
  - **F-A — bash library:** eight files under `.claude/lib/bash/`, mirrored into the bundle;
    Shell-QC discovery roots and kcov include pattern extended in
    `scripts/bash/shell_qc_lib.sh`; `.claude/rules/shell.md` prose updated.
  - **F-B — parity corpora:** `tests/fixtures/parallel_cohorts/` and
    `tests/fixtures/parallel_manifest_bash/`; pytest suites
    (`tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py`,
    `test_parallel_manifest_bash_parity.py`) and bats suites
    (`tests/shell/parallel_cohorts_parity.bats`, `tests/shell/parallel_manifest_parity.bats`),
    each with a fixture-count floor and an explicit verified-scope header naming the two bash
    divergence classes (M1 PyYAML text; non-printable string-repr escapes).
  - **F-C — push-down config carriage:** bundled `config/` subtree; `ROOT_FOLDERS`
    extension in the Claude entry only; the routing-merge decorator; Jest coverage for copy,
    merge, stale-`parallel`-route overwrite, local-route preservation, idempotency, fail-fast
    on unparseable destination, pack-scoped inclusion, and unchanged Copilot/Codex sets.
  - **F-D — manifests and completeness test:** `core.json` additions; completeness-test
    enumeration extension (`rules/*.md`, `lib/**`, bundled `config/`); bash-library
    manifest-membership test with bundled-counterpart assertion.
  - **F-E — wiring:** repoint destination-runtime references per the research Q7 inventory;
    allowlist entries in the two agent definitions and `.claude/settings.json`.
- **New files (bash library decomposition, estimated lines):**

  | File | Content | Est. lines |
  | --- | --- | --- |
  | `parallel-common.sh` | pythonRepr, type predicates, `enum_error`/`item_context` builders, error accumulation, `LC_ALL=C` guard | ~200 |
  | `parallel-yaml-subset.sh` | three-terminator line splitting, fence extraction (M1), restricted block-YAML parser emitting an ordered path/type/value stream, fail-closed subset errors | ~400 |
  | `parallel-manifest-validate.sh` | M1-M7 orchestration, identity checks (M2-M5), prohibited-key scan (M7), accessors | ~300 |
  | `parallel-items-validate.sh` | `validate_items` / `validate_item_record` / merge-status consistency / blast-radius block | ~300 |
  | `parallel-cohorts.sh` | key/edge validation, adjacency and degree accounting, Welsh-Powell ordering, greedy assignment, output shaping, `compute_concurrency_batches` | ~350 |
  | `compute-cohorts.sh` | thin CLI entry | ~80 |
  | `compute-concurrency-batches.sh` | thin CLI entry | ~60 |
  | `validate-parallel-manifest.sh` | thin CLI entry plus accessor subcommands | ~90 |

- **Dependency changes:** none. No `yq`, no new npm or Python package. The bash library uses
  only POSIX/bash builtins plus coreutils (`sort`), matching the destination-provisioning goal.
- **Logging/telemetry:** CLI entry points report errors on stderr/stdout per the contracts
  above; the push-down run summary reports the merge outcome and any failed file.
- **Rollout:** no feature flag. The change is inert for destinations until the next push-down;
  the merge rule makes the first publish onto an existing destination safe.

## Acceptance Criteria

- [ ] A bash cohort-computation entry point exists under `.claude/lib/bash/` and, for every
      fixture in the shared corpus `tests/fixtures/parallel_cohorts/`, produces the same
      cohort partition (compact JSON, ascending inner lists, Welsh-Powell index assignment)
      and the same error messages as `scripts/dev_tools/parallel_cohort_computation.py`.
      Evidence: green `tests/shell/parallel_cohorts_parity.bats` in the `_shell-coverage.yml`
      lane and green `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` in the
      pytest lane, both enforcing a fixture-count floor.
- [ ] A bash `compute_concurrency_batches` entry point exists under `.claude/lib/bash/`,
      chunks a cohort into consecutive ascending slices of at most `max_concurrency`, and
      rejects `max_concurrency < 1` with the exact Python error message. Evidence: batching
      fixtures in the shared corpus asserted by both parity suites.
- [ ] A bash manifest-contract validator exists under `.claude/lib/bash/` and reproduces the
      M1-M7 error strings of `scripts/dev_tools/parallel_manifest_contract.py` byte-for-byte —
      including the `Parallel manifest` context prefix and Python `repr` quoting — for every
      fixture in `tests/fixtures/parallel_manifest_bash/`, with one documented exception: for
      the M1 YAML-parse-failure case, parity is scoped to the prefix
      `Parallel manifest frontmatter is not valid YAML: ` plus single-element error-list
      shape. Evidence: both parity suites green with the divergence class recorded in their
      headers.
- [ ] The bash validator exposes default-resolving accessors for `mode` (default `closed`)
      and `max_concurrency` (default `4`) matching `manifest_mode` and
      `manifest_max_concurrency`. Evidence: bats cases covering present, absent, and invalid
      values.
- [ ] Every new `.claude/lib/bash/` file has a byte-identical bundled mirror under
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/`. Evidence: a
      manifest-membership test following the `BlastRadius.Manifest.Tests.ps1` pattern that
      discovers the repo files and asserts, for each, a `core.json` entry and a bundled
      counterpart.
- [ ] The Claude push-down publishes `config/orchestration-routing.json` and
      `config/blast-radius.json` to a destination workspace, including under pack-scoped
      publishes. Evidence: Jest cases against the push-down service-call path.
- [ ] The publish of `config/orchestration-routing.json` merges with a pre-existing
      destination file: the source `parallel` route is source-authoritative; the
      `preparation` route (and any other source route absent at the destination) is added;
      destination-local routes are preserved verbatim; a second push is byte-stable; an
      unparseable destination file fails with a reported error and is not overwritten.
      Evidence: Jest cases for copy, merge, stale-`parallel` overwrite, local-route
      preservation, idempotency, and fail-fast.
- [ ] The published `blast-radius.json` default contains no drm-copilot-only entries:
      `shared_surfaces` limited to payload-guaranteed paths, `shared_surface_globs` empty,
      structure-guaranteed `modules` only, `over_breadth_fraction` 0.25; this repository's
      root `config/blast-radius.json` is unchanged. Evidence: Jest assertion on the published
      content plus diff review.
- [ ] The Copilot and Codex push-down published sets are unchanged. Evidence: Jest
      non-regression cases for both entry points.
- [ ] `core.json` lists `.claude/rules/parallel-orchestration.md`, every new
      `.claude/lib/bash/` path, `config/orchestration-routing.json`, and
      `config/blast-radius.json`. Evidence: the extended completeness test passes against the
      final tree.
- [ ] `claude-pack-manifest-completeness.test.ts` enumerates `rules/*.md`, all files under
      `lib/**` recursively, and the bundled `config/` tree, so an unlisted file in any of
      those locations fails the test. Evidence: the extended enumeration is visible in the
      test diff and the suite is green.
- [ ] The Shell-QC discovery contract and kcov include pattern cover `.claude/lib/bash/**`:
      search roots and include pattern extended in `scripts/bash/shell_qc_lib.sh`,
      `.claude/rules/shell.md` prose updated, and the existing shell-qc bats tests extended.
      Evidence: the CI coverage report enumerates the new library files.
- [ ] shfmt, shellcheck, and bats pass on all new and modified shell files, and bash line
      coverage is >= 85%. Evidence: a green `_shell-coverage.yml` run against the branch
      head, with the run URL, conclusion, and the `Bash coverage (lines): NN.N%` log line
      recorded under
      `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/qa-gates/`.
- [ ] Destination-runtime references in the `parallel-plan`, `parallel-orchestrate`, and
      `parallel-add` skills and the `parallel-planner` and `parallel-orchestrator` agents
      invoke the bash entry points (blast-radius references invoke the existing PowerShell
      port); the Python modules are cited only as repository authority and parity reference.
      Evidence: no `poetry run` invocation remains on the `/parallel-plan`
      destination-runtime path (grep over `.claude/`).
- [ ] Bash allowlist entries permitting execution of the `.claude/lib/bash` entry points are
      added to `parallel-planner.md`, `parallel-orchestrator.md`, and
      `.claude/settings.json`, and the pull request identifies them as a deliberate
      permission-surface change. Evidence: diff review of the three files and the PR
      description.
- [ ] A payload-only workspace with no Python and no Poetry clears all four reported
      blockers. Evidence: Jest in-memory push-down assertions for payload content, plus a
      bats case on `ubuntu-latest` invoking the published bash entry points from a directory
      containing only the payload.
- [ ] No parallel-surface schema field, enum member, or validator invariant is added,
      removed, or altered: the Python validators, `_parallel_state_*` helpers, and the
      TypeScript parity port are unchanged by this feature. Evidence: diff scope review.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or CI evidence
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (bats, pytest, Jest, and the manifest-membership test)
- [ ] Edge cases and error handling covered by tests (validation ordering, CRLF/CR, merge
      fail-fast, leading-zero and negative keys)
- [ ] Docs updated (`.claude/rules/shell.md` prose; skill and agent wiring; bundle
      `config/` asymmetry documented)
- [ ] CI evidence for the shell lane captured under `evidence/qa-gates/`
- [ ] Toolchain pass completed (format → lint → type-check → test) for the TypeScript and
      Python surfaces locally; shell surface via CI dispatch per the verification constraint

## Seeded Test Conditions (from potential)

- [ ] bats unit coverage for the bash cohort computation: empty graph, single item, disjoint
      items, fully connected items, deterministic tie-breaking, and generation handling.
- [ ] bats unit coverage for the bash manifest validator: each of M1-M7, plus LF/CRLF/CR
      frontmatter extraction and the `mode`/`max_concurrency` default-resolving accessors.
- [ ] Parity fixtures shared by the bash and Python suites, asserting identical output.
- [ ] Jest coverage for the push-down config carriage: config published, routing merged,
      existing destination routes preserved, and the Copilot/Codex published sets unchanged.
- [ ] A pack-manifest test asserting every `.claude/rules/*.md` and `.claude/lib/**` file on
      disk has a `core.json` entry, so this class of omission cannot recur.
- [ ] An end-to-end check that a payload-only workspace clears all four reported blockers.
