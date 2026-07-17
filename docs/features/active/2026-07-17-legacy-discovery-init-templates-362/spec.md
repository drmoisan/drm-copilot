# legacy-discovery-init-templates — Spec

- **Issue:** #362
- **Parent (optional):** epic `legacy-discovery-and-parity` (child feature; epic manifest placeholder issue 9005)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17
- **Status:** Draft
- **Version:** 0.2

## Overview

### Problem

The `legacy-discovery-and-parity` epic (`docs/features/epics/legacy-discovery-and-parity/objective-source.md`)
requires a domain-neutral capability that lets a repository migrating a legacy
application (for example `drmoisan/TaskMaster`, migrating to `drmoisan/TMW`) perform
agentic discovery of its own behavior. That capability depends on every consumer
repository authoring, in a consistent shape, a domain-profile configuration and
instances of the seven discovery schemas (Feature Contract, Coverage Ledger, Runtime
Characterization Scenario, Parity Matrix, Unspecified Behavior Record, Product
Decision Record, Evidence Reference). Without a repeatable initialization command
and a set of artifact templates, each consumer repository would hand-author the
directory layout, the domain-profile configuration, and the seven artifact
instances independently, which is error-prone, inconsistent across consumers, and
duplicative work.

### Goal

Provide a domain-neutral scaffolding command, `dev.discovery.init`, and a matching
set of generic artifact templates, so any consumer repository can deterministically
initialize its discovery workspace in a single invocation. This feature implements
only objective-source.md section 7, "Initialization and Templates."

### Non-Goals (this feature)

- Does not author the seven JSON schema files themselves (feature
  `legacy-discovery-schemas`, issue 9002).
- Does not author the domain-profile config-contract loader/parser (feature
  `legacy-discovery-config-contract`, issue 9001).
- Does not implement any analyzer, validator, hook, agent, skill, MCP tool, or VS
  Code command; those belong to other epic children (issues 9003, 9004, 9006, 9007,
  9008, 9009, 9010, 9011, 9014).
- Does not encode any TaskMaster/TMW/Outlook/VSTO/email/task-management-specific
  behavior into the framework or its templates. TaskMaster/TMW appear in this
  document only as an illustrative consumer example.

## Upstream Dependencies (planned contracts)

This feature is Wave 1, complexity C2, and depends on two Wave 0 features that are
planned in parallel and not yet implemented at the time this spec is authored. This
feature designs against their planned shapes, cites them explicitly, and does not
redefine either contract.

### `legacy-discovery-config-contract` (issue 9001)

Per `objective-source.md` section 3, the domain-profile config is authored by the
consumer repository to declare its legacy source location, target location,
technology stack, and artifact conventions. Feature 9001 has not yet resolved
whether the parser is real PyYAML or the repository's existing hand-rolled
frontmatter regex convention (`objective-source.md` line 140; confirmed unresolved
by research).

To remain valid under either outcome, the starter domain-profile template this
feature scaffolds is authored as a **flat, single-level `key: value` YAML-syntax
document** — no nested maps, no lists — because the repository's hand-rolled parser
(`scripts/dev_tools/codex_native_converter/parser.py:76-98`, `_parse_frontmatter()`)
only supports flat `key: value` lines, while `yaml.safe_load` accepts the same
document as a strict subset of full YAML. Placeholder token values are used in
place of real paths/stack names.

**Forward dependency (recorded, not resolved by this feature):** if feature 9001's
final config contract requires a nested structure (for example a list of stack
identifiers), the starter template will need a follow-up edit once 9001's contract
is finalized. This feature's plan and acceptance criteria do not attempt to guess
9001's final schema.

### `legacy-discovery-schemas` (issue 9002)

Per `objective-source.md` section 4, feature 9002 owns the seven versioned JSON
schemas and the single schema-versioning convention (directory layout, version
field, `$schema` self-reference), reusing `scripts/dev_tools/validate_json.py`'s
existing governed-glob and `$schema` resolution machinery. No schema files exist in
the repository as of this writing.

Each of the seven artifact templates this feature scaffolds references its schema
via a **relative, scheme-less `$schema` path**, resolved by `validate_json.py`'s
`_load_schema()` no-scheme branch (`base_path.parent / uri`,
`scripts/dev_tools/validate_json.py:130-164`). For example, if 9002 places schemas
at `docs/discovery/schemas/v1/feature-contract.schema.json`, the template at
`docs/discovery/templates/artifacts/feature-contract.template.json` sets
`"$schema": "../../schemas/v1/feature-contract.schema.json"`. This mechanism
requires no new schema-loading code.

**Open cross-feature question (owned by 9002, recorded here, not resolved by this
feature):** `dev.discovery.init` writes artifact instances into a **consumer
repository's** discovery workspace, a path outside `drm-copilot`. A `$schema` value
that is a relative path computed against the `drm-copilot`-local schema location
will not resolve from inside the consumer repository unless the consumer's
workspace also vendors a copy of the schemas, or the reference is instead an
absolute/versioned URI. This feature's templates copy whatever relative-path
convention 9002 establishes verbatim; they do not invent a second convention. This
question must be resolved by feature 9002 or by a later coordination decision
before templates are considered final for cross-repository use.

## Module Decomposition

Per the research (`research/research.2026-07-17T14-15.md`, sections 1-3), this
feature follows the repository's existing scaffolding-tool precedent
(`new_active_feature_folder_flow.py`, `new_potential_bug_entry.py`) and its
package-style CLI precedent (`scripts/dev_tools/atomic_executor/`,
`scripts/dev_tools/pr_context/`).

### Python package: `scripts/dev_tools/discovery/`

A nested package (not a flat module), because five other Wave 1+ sibling features
(9006, 9007, 9009, 9010, 9014) will each add their own `dev.discovery.*` command
under the same namespace, and a shared package gives every sibling command a
common, non-colliding home.

- `scripts/dev_tools/discovery/init_cli.py` — argparse `parse_args()` and
  `main() -> None`. Thin CLI wiring only: parses arguments, calls
  `init_flow.create_discovery_workspace(...)`, converts the expected exceptions
  (`ValueError`, `FileExistsError`, `FileNotFoundError`, `NotADirectoryError`) into
  `print(...); raise SystemExit(1) from exc`. No bare `except Exception`. This is
  the Poetry console-script target: `scripts.dev_tools.discovery.init_cli:main`.
- `scripts/dev_tools/discovery/init_flow.py` — pure orchestration function
  `create_discovery_workspace(target_dir, template_root, fs) -> None` (or
  equivalent signature). Performs fail-fast validation of the target path and the
  template set, then scaffolds the directory layout, the starter domain-profile
  file, and the seven starter artifact files, all via the injected `FileSystem`.
  Contains no `argparse` or `print` calls, so it is directly unit-testable.
- `scripts/dev_tools/discovery/init_models.py` — the `FileSystem` `typing.Protocol`
  (`exists`, `ensure_dir`, `copy_file`, `read_text`, `write_text`, or the minimal
  subset this feature needs) and a `RealFileSystem` implementation. Duplicates the
  established six-method shape from `new_active_feature_folder_models.py` locally
  rather than importing across an unrelated scaffolding module, to avoid a
  cross-cutting dependency between two independent docs-scaffolding tools.

No file in this package may exceed 500 lines
(`.claude/rules/general-code-change.md`, "File Size Limit"); if `init_flow.py`
approaches the limit, split it further by responsibility (for example a separate
module for directory-layout construction versus template substitution), following
the `new_active_feature_folder_*` five-file decomposition precedent.

### Template location: `docs/discovery/templates/`

A new, domain-neutral, capability-scoped location, distinct from
`docs/features/templates/` (which is scoped to this repository's own
feature-planning lifecycle, not to a reusable discovery capability consumed by
external repositories):

```
docs/discovery/templates/
  domain-profile/
    domain-profile.yaml            # starter profile, flat key:value, placeholder tokens
  artifacts/
    feature-contract.template.json
    coverage-ledger.template.json
    runtime-characterization-scenario.template.json
    parity-matrix.template.json
    unspecified-behavior-record.template.json
    product-decision-record.template.json
    evidence-reference.template.json
```

Placing the seven JSON artifact templates under `docs/discovery/templates/artifacts/*.json`
means they fall under `scripts/dev_tools/json_config.py`'s existing
`GOVERNED_GLOBS` entry for `docs/**/*.json`, so they are automatically covered by
`validate_json.py` once each template's `$schema` resolves, with no change to
`json_config.py`.

### Template rendering mechanism

Literal placeholder-token substitution via `str.replace` on a fixed set of tokens
(for example `<legacy-source-path>`, `<target-path>`, `<technology-stack>`,
`<artifact-output-dir>`), matching every existing scaffolding tool in this
repository (`set_header_placeholder`, `render_content`). A templating engine (for
example Jinja2) is rejected: it would introduce a new dependency not currently
approved for `scripts/dev_tools/`, has no precedent in this repository's
dev-tooling, and is unnecessary for the fixed-shape substitution this feature
requires.

## Behavior

### `dev.discovery.init` CLI

**Inputs:**

- A required, explicit **target-directory** CLI argument naming the consumer
  repository's discovery-workspace root. This is a caller-supplied path, never
  `resolve_workspace()` or any other drm-copilot-workspace-relative default,
  because `dev.discovery.init` scaffolds a workspace **outside** `drm-copilot`, in
  an independent consumer repository.
- An optional **template-root override** CLI argument, consistent with the existing
  `--template-root` precedent in `new_active_feature_folder_flow.py` and
  `new_potential_bug_entry.py`. When omitted, the template root defaults to the
  bundled `docs/discovery/templates/` location resolved relative to this package's
  own file location. When supplied, it overrides that default, which is the
  mechanism that lets the same Python module scaffold from a packaged/mirrored
  template set rather than only from a `drm-copilot` checkout.

**Success behavior:** a single invocation of `dev.discovery.init <target-dir>`
scaffolds, in one pass:

1. The discovery-workspace directory layout under the target directory.
2. A starter domain-profile config (copied and placeholder-substituted from
   `domain-profile/domain-profile.yaml`) at the target's domain-profile location.
3. Starter instances of all seven discovery artifacts (each copied and
   placeholder-substituted from its template under `artifacts/`) at the target's
   artifact location.

There is no ordering dependency among the domain profile and the seven artifacts;
each is an independent file within one scaffold operation.

**Fail-fast behavior:** the following conditions MUST be detected and MUST raise
before any file is written to the target directory (no partial scaffold is ever
left on disk):

- The target path exists and is not a directory (`NotADirectoryError` or
  equivalent), or the target path exists and is non-empty without an explicit
  override to proceed.
- The target path's parent directory does not exist (`FileNotFoundError` or
  equivalent).
- The resolved template root (bundled default or `--template-root` override) is
  missing, or is missing one or more of the eight expected template files (the
  domain-profile template plus the seven artifact templates) — a partial template
  set fails the same way a fully-missing template root fails
  (`FileNotFoundError`), consistent with the existing
  `create_active_folder`/template-directory precedent. Partial writes based on
  whichever templates happen to be present are not permitted.

`init_cli.py` converts each of these into `print(...); raise SystemExit(1) from exc`
in `main()`; `init_flow.py` raises the underlying exception type without printing or
exiting, so it remains directly testable.

## Inputs / Outputs

- **Inputs:** target-directory CLI argument (required); `--template-root` CLI
  argument (optional, `Path | None`); no environment variables; no interactive
  input.
- **Outputs:** the scaffolded directory layout, the starter domain-profile file,
  and the seven starter artifact files, all written under the target directory.
  `main()` prints only on the fail-fast error path, before `SystemExit(1)`.
- **Config keys and defaults:** none introduced by this feature beyond the
  `[tool.poetry.scripts]` entry described below; the bundled template root has a
  fixed default computed relative to the package's own file location.
- **Versioning / backward-compatibility constraints:** the starter domain-profile
  template's flat shape is a forward dependency on feature 9001 (see "Upstream
  Dependencies" above); the seven artifact templates' `$schema` reference mechanism
  is a forward dependency on feature 9002's versioning convention.

## API / CLI Surface

- **Poetry console-script registration** (root `pyproject.toml`
  `[tool.poetry.scripts]`, `# Dev Tools Aliases` block, alphabetically ordered with
  the existing `dev.*` entries):

  ```toml
  "dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
  ```

  This is a two-level dotted alias (`dev.discovery.init`), one level deeper than
  any existing `dev.<verb>-<noun>` alias; TOML's quoted-key syntax supports this
  with no new tooling.

- **Example invocation:**

  ```
  poetry run dev.discovery.init /path/to/consumer-repo/discovery-workspace
  poetry run dev.discovery.init /path/to/consumer-repo/discovery-workspace --template-root /path/to/mirrored/templates
  ```

- **Contracts and validation rules:** see "Behavior" above for the full fail-fast
  contract. `init_flow.create_discovery_workspace(...)` is the pure orchestration
  contract exercised directly by unit tests, independent of `argparse`.

## Data & State

- **Data transformations:** literal placeholder-token substitution
  (`str.replace`) applied to each copied template file's text content. No template
  file is ever executed as code.
- **Caching or persistence:** none; this is a one-shot scaffolding operation with
  no persisted state of its own.
- **Migration or backfill requirements:** none. This feature does not modify any
  existing consumer-repository workspace; it only creates a new one at the
  caller-supplied target path.

## Domain-Neutrality Requirement and Verification

Per the epic's domain-neutrality invariant (`objective-source.md`, "Architectural
Boundaries"), every template file (the starter domain-profile and the seven
artifact templates) and every file `dev.discovery.init` writes MUST contain only
generic placeholder tokens (for example `<legacy-source-path>`, `<target-path>`,
`<technology-stack>`) and MUST NOT contain any TaskMaster/TMW/Outlook/VSTO- or
email/task-management-specific identifier or example value.

**Verification:** a dedicated domain-neutrality regression test reads every
template file under `docs/discovery/templates/` and the rendered output of
`create_discovery_workspace(...)` against an injected fake `FileSystem` target, and
asserts that none of a fixed disallowed-token list (`TaskMaster`, `TMW`,
`Outlook`, `VSTO`, plus any additional case-insensitive email/task-management terms
agreed at plan time) appears, via a compiled case-insensitive regex. This is a
deterministic, fast, isolated pytest test with no filesystem/network dependency
beyond reading in-repo template files and fake-`FileSystem`-captured in-memory
output; it introduces no temporary files, per the "no temp files in tests" rule.

## Constraints & Risks

- **Domain neutrality invariant:** templates must be generic scaffolds with
  placeholder tokens, never domain-specific instances. Verified by the
  domain-neutrality regression test above.
- **Upstream dependency risk:** feature 9001's parser decision and feature 9002's
  schema-versioning convention are both unresolved as of this feature's
  preparation. This feature's starter domain-profile template and the seven
  artifact templates' `$schema` mechanism are designed to remain valid under
  either likely 9001 outcome and under 9002's stated convention, with two
  explicitly recorded forward dependencies (see "Upstream Dependencies").
- **Out of scope:** authoring the schema files themselves (feature 9002) and the
  config-contract loader (feature 9001).
- **Quality tier:** `quality-tiers.yml` does not yet exist at the repository root
  (a pre-existing, cross-cutting gap not introduced by this feature). In its
  absence, the tier *definitions* in `.claude/rules/quality-tiers.md` still apply
  directly: this feature's `scripts/dev_tools/discovery/` package is
  **T4 — Scaffolding** (build scripts, dev tooling). T4 status relaxes only the
  tier-dependent gates (no property-test-density, mutation-score, or golden-test
  obligation); the uniform gates (format, lint, type-check, architecture = 0
  violations; line coverage >= 85%, branch coverage >= 75%) apply in full,
  unchanged.

## Implementation Strategy

- **Implementation scope:** add the `scripts/dev_tools/discovery/` package
  (`init_cli.py`, `init_flow.py`, `init_models.py`, `__init__.py`); add
  `docs/discovery/templates/domain-profile/domain-profile.yaml` and the seven
  `docs/discovery/templates/artifacts/*.template.json` files; add one
  `[tool.poetry.scripts]` line to root `pyproject.toml`; add the corresponding
  pytest suite under `tests/scripts/dev_tools/discovery/`.
- **New classes/functions/commands:** `init_cli.parse_args`, `init_cli.main`,
  `init_flow.create_discovery_workspace`, `init_models.FileSystem` (Protocol),
  `init_models.RealFileSystem`; the `dev.discovery.init` console script.
- **Dependency changes:** none. This feature introduces no new third-party
  dependency (see "Module Decomposition — Template rendering mechanism" above for
  the rejected Jinja2 alternative).
- **Logging/telemetry additions:** none beyond the existing `print`-to-`stderr`/
  `SystemExit(1)` fail-fast pattern already used by the precedent scaffolding
  tools; this feature introduces no new logging framework usage.
- **Rollout plan:** no feature flag or staged deploy; this is a new, additive CLI
  command with no existing callers to migrate.

## Test Plan

- **Location:** `tests/scripts/dev_tools/discovery/`, mirroring
  `scripts/dev_tools/discovery/` exactly, per `.claude/rules/general-unit-test.md`
  ("Test File Location") and the `atomic_executor`/`pr_context` test-package
  precedent (`tests/scripts/dev_tools/discovery/test_init_cli.py`,
  `test_init_flow.py`, `test_init_models.py`, with an `__init__.py`).
- **Coverage command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`,
  per `.claude/rules/python.md`. Root `pyproject.toml`'s
  `[tool.coverage.run]` `source = ["src", "scripts/dev_tools"]` already covers the
  new package with no configuration change.
- **No-temp-files rule:** all tests use the injected fake `FileSystem` (mirroring
  `FakeFileSystem` in `tests/scripts/dev_tools/test_new_potential_bug_entry.py`) to
  simulate the scaffold target and the template source in memory; no test creates
  real temporary files or directories, per `.claude/rules/general-unit-test.md`
  ("External Dependencies").
- **Fake `FileSystem`:** `init_flow.create_discovery_workspace(...)` is exercised
  exclusively against the `FileSystem` Protocol, never `RealFileSystem`, in unit
  tests; a separate, thin test may exercise `RealFileSystem` directly for its own
  I/O wrapper behavior if warranted, isolated from orchestration logic.
- **Scenario coverage required:**
  - Positive: initialization into an empty target path produces the full expected
    file set (directory layout, starter domain profile, seven starter artifacts).
  - Positive: `--template-root` override is honored when it points at a complete
    template set.
  - Negative: target path exists but is not a directory.
  - Negative: target path's parent does not exist.
  - Negative: `--template-root` override points at a missing directory.
  - Negative: `--template-root` override points at a directory missing one or more
    of the eight expected template files (partial set).
  - CLI-level: `main()`/`parse_args()` invoked with `monkeypatch`-injected
    `sys.argv`, asserting the expected `SystemExit(1)` and printed message for each
    fail-fast condition, and successful exit for the success path.
  - Domain-neutrality regression test (see "Domain-Neutrality Requirement and
    Verification" above).
- **Schema-conformance test dependency:** a test asserting each generated starter
  artifact is well-formed against its schema is part of this feature's intended
  scope, but it has a hard dependency on feature 9002's schema files existing.
  Until feature 9002 lands, this test is written against 9002's planned schema
  shape and is explicitly tracked as blocked/deferred pending 9002; it must not be
  silently skipped or removed from the plan.

## Evidence Location

All evidence artifacts produced during execution and review of this feature
(baselines, QA gates, regression results, coverage) are written to
`docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/<kind>/`
per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Non-canonical
paths such as `artifacts/baselines/`, `artifacts/qa/`, or `artifacts/coverage/` must
not be used for evidence.

## Definition of Done

- [ ] Acceptance criteria documented below and mapped to tests.
- [ ] Behavior matches acceptance criteria in all documented environments.
- [ ] Tests added under `tests/scripts/dev_tools/discovery/` (unit + CLI-level).
- [ ] Edge cases and error handling covered by tests (see "Test Plan").
- [ ] Docs updated (this spec, the user story, and any links from
      `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/`).
- [ ] Toolchain pass completed (format → lint → type-check → architecture → unit
      tests → contract/schema checks → integration tests), per
      `.claude/rules/general-code-change.md`.

## Acceptance Criteria

- [ ] `dev.discovery.init <target-dir>` scaffolds the discovery workspace directory
      layout at the given target consumer path in a single invocation.
- [ ] `dev.discovery.init` accepts an explicit target-directory CLI argument (not
      the drm-copilot workspace root) and an optional `--template-root` override
      consistent with the `new_active_feature_folder`/`new_potential_bug_entry`
      precedent.
- [ ] Initialization writes a starter domain-profile config, authored as a flat
      single-level `key: value` YAML document with placeholder tokens, of the
      shape anticipated for feature 9001 (with the nested-structure forward
      dependency explicitly recorded, not resolved, by this feature).
- [ ] Initialization writes starter instances of each of the seven discovery
      artifacts (Feature Contract, Coverage Ledger, Runtime Characterization
      Scenario, Parity Matrix, Unspecified Behavior Record, Product Decision
      Record, Evidence Reference) from the templates under
      `docs/discovery/templates/artifacts/`, in the same invocation as the
      domain profile.
- [ ] Each artifact template's `$schema` field is a relative, scheme-less path
      resolvable by `validate_json.py`'s existing no-scheme `_load_schema` branch,
      per feature 9002's planned schema-versioning convention; the open question
      about resolving `$schema` from inside an external consumer repository is
      recorded in this spec and left to feature 9002, not resolved here.
- [ ] Templates and generated artifacts contain no domain-specific identifiers
      (verified by the domain-neutrality regression test).
- [ ] `dev.discovery.init` fails fast, before writing any file, when: the target
      path exists and is not a directory; the target path's parent does not
      exist; or the resolved template root is missing or has a partial template
      set.
- [ ] `dev.discovery.init` is registered and invocable as a Poetry console-script
      (`"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"` in root
      `pyproject.toml`).
- [ ] Tests under `tests/scripts/dev_tools/discovery/` satisfy repository
      quality-tier policy (line coverage >= 85%, branch coverage >= 75%), use an
      injected fake `FileSystem` with no real filesystem/temp-file I/O, and
      include the schema-conformance test tracked as dependent on feature 9002.
