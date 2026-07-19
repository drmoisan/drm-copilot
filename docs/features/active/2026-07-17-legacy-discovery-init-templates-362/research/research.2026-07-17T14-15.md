# Research: legacy-discovery-init-templates (issue #362)

- Timestamp: 2026-07-17T14-15
- Epic: legacy-discovery-and-parity (`docs/features/epics/legacy-discovery-and-parity/`)
- Feature scope: objective-source.md section 7, "Initialization and Templates" only.
- Upstream (planned, not yet implemented) dependencies: legacy-discovery-config-contract
  (issue 9001, objective-source.md section 3) and legacy-discovery-schemas (issue 9002,
  objective-source.md section 4). This research designs against their planned shapes and
  does not author either contract.

## 1. Existing CLI Scaffolding Precedent

Three existing `scripts/dev_tools/` modules are the canonical scaffolding precedent:

- `scripts/dev_tools/new_active_feature_folder.py` (facade, 80 lines) plus its
  decomposed siblings: `new_active_feature_folder_flow.py` (argparse + `main()` +
  orchestration, 374 lines), `_io.py` (filesystem/template copy helpers, 321 lines),
  `_markdown.py` (placeholder substitution, ~140 lines), `_models.py` (dataclasses,
  `FileSystem` Protocol, `RealFileSystem`, validation, 137 lines), `_docs.py` (not
  read in full but referenced by the facade).
- `scripts/dev_tools/new_potential_bug_entry.py` (single file, 466 lines — near the
  500-line ceiling from `.claude/rules/general-code-change.md`).

Canonical structure observed:

- **argparse usage**: a single `parse_args() -> argparse.Namespace` function per
  module/facade, with `--flag` options and one `default=None`/`action="store_true"`
  pattern per option (`new_active_feature_folder_flow.py:299-351`,
  `new_potential_bug_entry.py:396-427`).
- **`main()` signature**: `def main() -> None`, calling `parse_args()`, then the
  pure orchestration function, and converting expected exceptions
  (`ValueError`, `FileExistsError`, `FileNotFoundError`) into
  `print(...); raise SystemExit(1) from exc` (`new_active_feature_folder_flow.py:354-373`;
  `new_potential_bug_entry.py:430-461`). No bare `except Exception`.
- **Target-directory resolution**: a `workspace: Path | None = None` parameter
  defaulting to a `resolve_workspace()` helper (`Path(__file__).resolve().parents[2]`,
  `new_active_feature_folder_models.py:107-109`; `new_potential_bug_entry.py:27-28`
  uses `parents[2]` directly). Both existing tools scaffold **inside the drm-copilot
  workspace itself** (`docs/features/active/...`, `docs/features/potential/...`).
- **Template copy/instantiation**: a `FileSystem` `typing.Protocol` with `exists`,
  `ensure_dir`, `copy_file`, `copy_tree`, `read_text`, `write_text`, `move`
  (`new_active_feature_folder_models.py:46-63`), plus a `RealFileSystem` dataclass
  implementation using `shutil.copyfile` / `Path.rglob` (lines 66-104). Template
  content uses literal string placeholder tokens (e.g. `<feature-name>`, `<issue>`,
  `YYYY-MM-DD`) replaced via `str.replace` in `set_header_placeholder`
  (`new_active_feature_folder_markdown.py:126-139`) and `render_content`
  (`new_potential_bug_entry.py:150-177`) — no Jinja/templating engine dependency.
- **Fail-fast on invalid target state**: `validate_feature_name` /
  `validate_short_name` raise `ValueError` on a bad kebab/underscore slug before any
  I/O (`new_active_feature_folder_models.py:130-136`;
  `new_potential_bug_entry.py:31-56`); `create_active_folder` raises
  `FileExistsError` when the target directory already exists unless `--force`
  (`new_active_feature_folder_flow.py:142-145`); missing template directories raise
  `FileNotFoundError` (`new_active_feature_folder_flow.py:108-109`). All three are
  caught explicitly in `main()` and turned into `SystemExit(1)`.
- **Bundled-template override**: both tools accept `--template-root` (`Path | None`)
  that overrides the workspace-relative `docs/features/templates/...` default
  (`new_active_feature_folder_flow.py:104-107,345-349,357`;
  `new_potential_bug_entry.py:369-379,422-425,453`). This is the mechanism that lets
  the same Python module be invoked from a packaged extension/bundle context, not
  only from a drm-copilot checkout — directly relevant to `dev.discovery.init`,
  because that command scaffolds a workspace **outside** drm-copilot (a consumer
  repository), so the template source and the scaffold target are two independent
  paths, neither of which is `resolve_workspace()`.
- **File-size/module-decomposition norm**: no file exceeds 500 lines
  (`.claude/rules/general-code-change.md` "File Size Limit"); the active-feature-folder
  facade is decomposed into 5 files by responsibility (flow/io/markdown/models/docs)
  once the single-file version would have exceeded a manageable size. This is the
  precedent to follow if `dev.discovery.init`'s implementation approaches the limit.
- **Package-style CLI precedent**: `scripts/dev_tools/atomic_executor/` (18 files:
  `cli.py` + `cli_*.py` submodules + `__init__.py`) and `scripts/dev_tools/pr_context/`
  (`collector.py` + helper modules + `__init__.py`) show that a Poetry script may
  point at `scripts.dev_tools.<package>.cli:main` inside a nested package rather than
  a flat module. This is the precedent for a `scripts/dev_tools/discovery/` package
  (see section 2).

## 2. Poetry Console-Script Registration

Root `pyproject.toml` `[tool.poetry.scripts]` (lines 47-69) has two registration
styles:

1. **Bare short names** (no dots), e.g. `shell-qc = "scripts.dev_tools.shell_qc:main"`,
   `atomic-executor = "scripts.dev_tools.atomic_executor.cli:main"`.
2. **`dev.` dotted aliases** under the `# Dev Tools Aliases` comment block, e.g.
   `"dev.new-active-feature" = "scripts.dev_tools.new_active_feature_folder:main"`,
   `"dev.new-potential-bug" = "scripts.dev_tools.new_potential_bug_entry:main"`,
   `"dev.validate-json" = "scripts.dev_tools.validate_json:main"`. Dotted keys are
   quoted TOML keys (`"dev.foo-bar"`) because bare dotted keys are not valid TOML
   identifiers.

The epic's naming convention (`objective-source.md` line 101, epic.md line 87) is
`dev.discovery.*` — a **two-level** dotted namespace, one level deeper than any
existing `dev.<verb>-<noun>` alias. No existing script key has two dots. This is
consistent with the existing quoted-key mechanism (TOML allows arbitrarily many dots
in a quoted key) and requires no new tooling.

**Recommendation**: register

```toml
"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"
```

in the `# Dev Tools Aliases` block, alphabetically ordered with the other `dev.*`
entries (after `"dev.collect-commit-context"` and before `"dev.fix-all"` if strict
alpha order is preserved — the existing list is already alphabetically sorted by key,
so `dev.discovery.init` sorts between `dev.collect-commit-context` and `dev.fix-all`).

**Module-path recommendation**: `scripts/dev_tools/discovery/` as a **nested package**,
consistent with the `atomic_executor/` and `pr_context/` precedent (section 1), because:
- This feature is Wave 1 of a 14-feature epic; five other features (9006 analyzer
  framework, 9007 agent roles, 9009 acceptance scenarios, 9010 reports, 9014
  .NET/VSTO analyzers) will each add their own `dev.discovery.*` command under the
  same namespace, per `epic.md`'s "CLI-before-MCP-before-VS-Code" shared design.
  A shared `scripts/dev_tools/discovery/` package gives every sibling feature a
  common, non-colliding home (e.g. `discovery/init_cli.py`,
  `discovery/analyze_cli.py`, ...) instead of crowding flat `scripts/dev_tools/`
  with `discovery_init_*.py`, `discovery_analyze_*.py`, etc.
- It matches the two existing multi-command package precedents exactly (`cli.py` as
  the package's argparse+`main()` entry, sibling modules for logic).

A **domain-neutral** internal module split for this feature specifically:
- `scripts/dev_tools/discovery/init_cli.py` — argparse + `main()` (thin CLI wiring,
  mirrors `new_active_feature_folder_flow.py`'s `parse_args`/`main`).
- `scripts/dev_tools/discovery/init_flow.py` — pure orchestration function
  (`create_discovery_workspace(...)`), fail-fast validation, target-directory
  resolution.
- `scripts/dev_tools/discovery/init_models.py` — `FileSystem` Protocol/
  `RealFileSystem` (reuse the existing Protocol shape from
  `new_active_feature_folder_models.py` rather than redefining it, if it is exposed
  for reuse; otherwise duplicate the same six-method shape locally to avoid a
  cross-cutting import into a docs-scaffolding module).
- `scripts/dev_tools/discovery/templates/` (see section 3) — the template payloads
  themselves, not Python code.

`resolve_workspace()`-equivalent note: because this package lives one directory
deeper (`scripts/dev_tools/discovery/x.py` vs `scripts/dev_tools/x.py`), any helper
that resolves the drm-copilot repo root via `Path(__file__).resolve().parents[N]`
needs `parents[3]`, not `parents[2]` — but see section 4/CLI design: the *target*
of `dev.discovery.init` is an external consumer path, not the drm-copilot repo root,
so this offset only matters for resolving the **bundled template root**, and only
when `--template-root` is not supplied.

## 3. Template Precedent and Recommended Template Location

`docs/features/templates/` (`README.md` plus `bug/`, `epic/`, `feature/`,
`refactor/`, `policy_audit/` subfolders) is the existing placeholder-token template
example:

- Each template file is plain Markdown with literal placeholder tokens:
  `<feature-name>`, `<issue>`, `<parent-id>`, `<name>`, `<yyyy-MM-ddTHH-mm>`,
  `<status>`, `<version_number>` (`docs/features/templates/feature/spec.md:1-8`).
  Filenames with variable timestamps use a literal-string convention,
  `plan.yyyy-MM-ddTHH-mm.md` (`PLAN_TIMESTAMP_TEMPLATE_NAME` in
  `new_active_feature_folder_models.py:26`), not a real templating-engine glob.
- Instantiation is copy-then-substitute: `copy_template()` copies the whole
  directory tree (`fs.copy_tree`) or a curated file list depending on
  `feature_type` (`new_active_feature_folder_io.py:85-115`), then
  `set_header_placeholder`/`render_content` does literal `str.replace` on the
  known tokens (`new_active_feature_folder_markdown.py:126-139`,
  `new_potential_bug_entry.py:150-177`). No template files are ever executed as
  code (no Jinja, no f-strings evaluated from file content).

**Recommendation for the seven discovery-artifact templates and the starter
domain-profile template**: `docs/discovery/templates/` (a new, domain-neutral,
capability-scoped location), laid out as:

```
docs/discovery/templates/
  domain-profile/
    domain-profile.yaml            # starter profile with placeholder tokens
  artifacts/
    feature-contract.template.json
    coverage-ledger.template.json
    runtime-characterization-scenario.template.json
    parity-matrix.template.json
    unspecified-behavior-record.template.json
    product-decision-record.template.json
    evidence-reference.template.json
```

Justification (evidence-based, not the `docs/features/templates/` location itself):
- `docs/features/templates/` is scoped to *this repository's own* feature-planning
  lifecycle (feature/bug/epic/refactor docs) — reusing it for a reusable,
  domain-neutral discovery-artifact capability would conflate two unrelated template
  families and their two unrelated consumers (drm-copilot's own planning workflow vs.
  a TaskMaster/TMW-style consumer repository).
- `scripts/dev_tools/json_config.py`'s `GOVERNED_GLOBS` already covers
  `docs/**/*.json` (line 13) for `validate_json.py`. Placing the seven JSON artifact
  templates under `docs/discovery/templates/artifacts/*.json` means they are
  automatically picked up by the existing governed-JSON validation machinery without
  any change to `json_config.py`, provided each template's `$schema` value resolves
  (see section 5). Placing them at a new top-level `templates/` directory would
  require widening `GOVERNED_GLOBS`, which is out of this feature's scope to decide
  unilaterally.
- `docs/discovery/` as a shared namespace root is consistent with where the schemas
  (feature 9002) are expected to land per the epic's schema-versioning convention
  (`schemas/vN/`) — recommend that 9002 places its schemas at
  `docs/discovery/schemas/vN/<artifact>.schema.json` so both features share one
  governed, domain-neutral root. This is a cross-feature coordination note for the
  spec/plan phase, not a decision this feature can make unilaterally (9002 owns the
  schema-versioning convention).

**Rejected alternative**: a brand-new top-level `templates/` directory
(`templates/discovery/...`). Rejected because it is not covered by any existing
governed glob and there is no existing top-level `templates/` precedent in this
repository (confirmed via directory listing — top-level dirs are `.agents`, `.claude`,
`.codex`, `.devcontainer`, `.github`, `.vscode`, `config`, `docs`, `extensions`,
`scripts`, `src`, `tests`).

## 4. Domain-Profile Starter Shape

From `objective-source.md` section 3 (lines 65-68) and epic.md's shared-design note
(`epic.md:104-106`), the domain-profile config is authored **by the consumer
repository** to declare, at minimum:

- **Legacy source location** — a filesystem path (or path-like reference) to the
  repository/codebase being migrated (e.g. the TaskMaster checkout root).
- **Target location** — a filesystem path to the modern implementation (e.g. the TMW
  checkout root).
- **Technology stack** — a declaration of the legacy and/or target stack(s) so
  stack-specific analyzers (9006, 9014) know which analyzer to run
  (`objective-source.md` lines 96-99 names ".NET/C#" and "VSTO/Office" as concrete
  stack analyzer targets, supplied at runtime, never hardcoded).
- **Artifact conventions** — naming/location conventions for where the discovery
  artifacts (the seven schema instances) should be written for that consumer.

**Placeholder-token representation without committing to the parser**: because
feature 9001 has not yet decided PyYAML vs. the repository's existing hand-rolled
frontmatter convention (confirmed unresolved — `objective-source.md` line 140), this
feature's starter template must be representable identically under either outcome.
Concretely:

- Verified hand-rolled convention in this repo: `_parse_frontmatter()` in
  `scripts/dev_tools/codex_native_converter/parser.py:76-98` parses a `---`-delimited
  block as flat `key: value` lines (`key.strip()` → `value.strip().strip("'\"")`), with
  **no nested structures or lists** — a strict subset of YAML.
- `PyYAML` is declared in `pyproject.toml` (`PyYAML = ">=6.0"`, line 19) but **no
  module under `scripts/` imports `yaml`** (confirmed via grep) — it is genuinely
  unused today, matching the objective's "declared but unused dependency" framing.

**Recommendation**: author the starter domain-profile template as a flat,
single-level `key: value` YAML-syntax document (valid under both `yaml.safe_load`
and the hand-rolled parser), with placeholder token values rather than nested maps
or lists, e.g.:

```yaml
legacy_source_path: "<legacy-source-path>"
target_path: "<target-path>"
technology_stack: "<technology-stack>"
artifact_output_dir: "<artifact-output-dir>"
```

If feature 9001 ultimately requires nested structure (e.g. a list of stack
identifiers), this template will need a follow-up edit once 9001's contract is
final — this feature's plan should record that as an explicit forward dependency,
not attempt to guess 9001's final schema.

## 5. Schema-Versioning Reference Mechanism

`objective-source.md` line 143 and `epic.md:107-110` state feature 9002 owns the
single schema-versioning convention: directory layout `schemas/vN/`, a version
field, and a `$schema` self-reference, reusing `validate_json.py`'s governed-glob and
`$schema` resolution machinery — **no new schema-loading code** is to be introduced.

Verified `validate_json.py` mechanics (`scripts/dev_tools/validate_json.py`):
- `validate_file()` (lines 167-225) requires every governed JSON file to declare a
  top-level `"$schema"` string (line 197-200: `False, f"{path}: missing $schema"`
  if absent).
- `_load_schema()` (lines 130-164) resolves `$schema` three ways: (a) no URI scheme
  → resolved **relative to the JSON file's own parent directory**
  (`base_path.parent / uri`, line 139); (b) `file://` scheme → absolute local path;
  (c) `http(s)://` → fetched and cached under `.cache/schemas/` keyed by a SHA-256
  hash of the URI (`_cache_path`, lines 77-79).
- `collect_targets()` (lines 244-254) defaults to `iter_governed_files(root)`
  (`json_config.GOVERNED_GLOBS`: `scripts/**/*.json`, `docs/**/*.json`,
  `examples/**/*.json`), or explicit file/dir args.
- No `schemas/` directory exists yet anywhere in the repository (confirmed via glob)
  — feature 9002 has not landed.

**Recommendation for how templates reference a versioned schema** (mechanism only,
not the schema content): each of the seven artifact templates' `$schema` field
should use a **relative, scheme-less path** resolved against the template's own
location, per `_load_schema`'s no-scheme branch — e.g. if schemas land at
`docs/discovery/schemas/v1/feature-contract.schema.json` and the template lives at
`docs/discovery/templates/artifacts/feature-contract.template.json`, the template's
`$schema` value would be `"../../schemas/v1/feature-contract.schema.json"`. This:
- Requires zero new schema-loading code (reuses `_load_schema`'s existing relative
  path branch verbatim).
- Stays valid when `validate_json.py` runs over `docs/**/*.json` without further
  configuration, because both the template and the schema are under `docs/`.
- Each generated artifact instance produced by `dev.discovery.init` inherits the
  same relative `$schema` reference from its template (the token is copied verbatim,
  not rewritten at scaffold time, since the artifact instance is scaffolded under
  the consumer repository's own workspace and the schema reference must be a
  URI/path the *consumer* can resolve — see open question below).

**Open question for the spec/plan phase (not resolved by this research, and not
this feature's decision to make unilaterally)**: `dev.discovery.init` writes
artifact instances into a **consumer repository's** discovery workspace (a path
outside drm-copilot). If `$schema` in the generated instance is a relative path
computed against the drm-copilot-local schema location, that reference will not
resolve from inside the consumer repository unless the consumer's workspace also
vendors a copy of the schemas, or the reference is instead an absolute/versioned
URI (e.g. a GitHub raw URL or a package-relative path shipped by the same
mechanism that pushes `.claude/` assets to consumers — epic.md's "Mirror contract").
This is exactly the kind of cross-feature decision the epic's `epic.md` line 107-110
assigns to feature 9002 ("the single versioning convention... reused by every schema
consumer"); this feature's templates must consume whatever answer 9002 provides
and should not invent a second convention.

## 6. Test Layout and Quality Tier

**Test location**: `.claude/rules/general-unit-test.md` ("Test File Location")
requires `tests/` to mirror `scripts/`/`src/` structure exactly. Confirmed precedent:
`scripts/dev_tools/atomic_executor/*.py` → `tests/scripts/dev_tools/atomic_executor/
test_*.py`; `scripts/dev_tools/new_potential_bug_entry.py` →
`tests/scripts/dev_tools/test_new_potential_bug_entry.py`. For the recommended
`scripts/dev_tools/discovery/` package, tests belong at
`tests/scripts/dev_tools/discovery/test_init_cli.py`,
`tests/scripts/dev_tools/discovery/test_init_flow.py`, etc., with an `__init__.py`
mirroring the `atomic_executor` test package.

**Coverage command**: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
(`.claude/rules/python.md` line 16). Root `pyproject.toml`
`[tool.coverage.run]` `source = ["src", "scripts/dev_tools"]` (line 103) already
covers any new `scripts/dev_tools/discovery/` package with no config change.
`[tool.pytest.ini_options]` `addopts` also writes an LCOV report to
`artifacts/python/lcov.info` (line 99) — this is an `artifacts/` orchestration path,
not an evidence path (see section 8); do not redirect coverage evidence there.

**Quality tier**: `quality-tiers.yml` does not exist yet anywhere in this
repository (confirmed via glob at repo root and full-tree search) — the tier
classification file described as canonical in `.claude/rules/general-code-change.md`
and `.claude/rules/quality-tiers.md` has not been created. This is a pre-existing gap
in the repository, not something introduced by this feature. In its absence, the
`.claude/rules/quality-tiers.md` tier *definitions* still apply directly: T4 —
Scaffolding is explicitly defined to include "build scripts, dev tooling... bootstrap"
(`.claude/rules/quality-tiers.md`, "Tiers" section). `dev.discovery.init` is a
one-shot scaffolding CLI command with no runtime data-loss or feature-regression
surface of its own (it copies templates and substitutes placeholder tokens) — it
matches the T4 definition.

**What T4 implies** (per the uniform-vs-tier-dependent gate matrix in
`.claude/rules/quality-tiers.md`):
- Uniform gates still apply in full: format/lint/type-check/architecture = 0
  violations; **line coverage >= 85%, branch coverage >= 75%** (uniform across all
  tiers per Authoritative Decision #2 — there is no lower T4 coverage floor).
- Tier-dependent gates relax to "none"/"unlimited": no property-test-density
  requirement, no mutation-score requirement, no golden-test requirement, unlimited
  untyped-escape-hatch allowance (not that any should be needed — Pyright strict mode
  applies regardless per `[tool.pyright]` `typeCheckingMode = "strict"`,
  `pyproject.toml:125`).

**Recommendation**: classify this feature's `scripts/dev_tools/discovery/` module as
T4 in the future `quality-tiers.yml` once that file is created (a separate,
cross-cutting gap this feature does not need to close), and hold the uniform 85%/75%
coverage bar with no property-based or mutation-test obligation.

## 7. Domain-Neutrality Verification

Confirmed baseline: a grep for `TaskMaster|TMW|Outlook|VSTO` across all of
`scripts/dev_tools/` returned zero matches — the existing dev-tooling codebase is
already domain-neutral, which is the pattern to preserve.

**Recommendation for keeping `dev.discovery.init` and its templates neutral**:
- Author every template file (domain-profile starter, seven artifact templates)
  using only generic placeholder tokens (e.g. `<legacy-source-path>`,
  `<target-path>`, `<technology-stack>`) — never a concrete example value drawn from
  TaskMaster/TMW/Outlook/VSTO/email/task-management vocabulary, consistent with the
  issue's explicit constraint ("Templates and generated artifacts contain no
  domain-specific identifiers", `issue.md` line 45).
- **Test-time assertion mechanism**: add a unit test that reads every template file
  under `docs/discovery/templates/` (and, separately, the rendered output of
  `create_discovery_workspace(...)` in a scaffolded temp target) and asserts none of
  a fixed disallowed-token list (`TaskMaster`, `TMW`, `Outlook`, `VSTO`, plus
  case-insensitive email/task-management terms agreed with the spec) appears via a
  compiled regex, mirroring how this research verified neutrality with `Grep`. This
  is a deterministic, fast, isolated pytest check with no filesystem/network
  dependency beyond reading files already present in the test's own fixture data
  (no runtime temp files needed if template fixtures are loaded as in-repo files or
  inline strings, per the "no temp files in tests" rule in
  `.claude/rules/general-unit-test.md`).
- Keep this check separate from, and in addition to, the seven-schema
  conformance tests (each rendered starter artifact must validate against its
  schema — see section 5's open question about schema-reference resolution).

## 8. Evidence Output Location

Per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, the canonical
evidence scheme for the later execution phase of this feature is
`<FEATURE>/evidence/<kind>/`, i.e.:

```
docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/
docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/
docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/regression-testing/
docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/other/
docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/issue-updates/
docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/remediation-baseline/
```

`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`,
and similar `artifacts/` sub-paths are forbidden for evidence; the only permitted
`artifacts/` use in this repository is orchestration state
(`artifacts/orchestration/`) and the pytest LCOV byproduct already configured in
`pyproject.toml` (`artifacts/python/lcov.info`), which is a coverage tool output, not
an evidence artifact — evidence summaries referencing that coverage number still
belong under `evidence/qa-gates/` per the schema in the evidence skill. No
non-canonical path was supplied to this research task, so no override rejection is
recorded.

## Candidate Approaches (Template Rendering Mechanism)

Two viable approaches for instantiating templates were compared:

1. **Literal `str.replace` on fixed placeholder tokens** (the repository's existing
   convention — `set_header_placeholder`, `render_content`). Advantages: zero new
   dependencies, matches 100% of existing scaffolding precedent, trivially testable
   with plain string assertions, no injection/templating-engine attack surface.
   Limitations: no conditional/loop logic in templates (not needed here — the seven
   artifacts and the domain profile are each a fixed shape).
2. **A templating engine (e.g. Jinja2)**. Advantages: richer substitution/conditional
   syntax. Limitations: introduces a new dependency not currently approved for
   `scripts/dev_tools/` (`.claude/rules/general-code-change.md` "Dependencies" —
   "Use only libraries already approved... unless explicitly told"); no existing
   precedent in this repository's dev-tooling; unnecessary complexity for
   flat-key placeholder substitution.

**Recommendation**: approach 1 (literal placeholder substitution), matching every
existing scaffolding tool in this repository and requiring no new dependency
approval.

## Behavior Semantics (from issue.md and objective-source.md)

- **Success**: `dev.discovery.init --target-dir <path>` (flag name to be finalized in
  spec) scaffolds the full discovery workspace directory layout, writes a starter
  domain-profile config with placeholder tokens, and writes starter instances of all
  seven discovery artifacts from templates — all in one invocation, matching
  `issue.md`'s three separate but co-occurring acceptance criteria (lines 37-44).
- **Failure / fail-fast**: initialization into a non-empty or otherwise invalid
  target path must fail before any file is written (`issue.md` line 64,
  "Negative: initialization into a non-empty or invalid target path fails fast"),
  mirroring `create_active_folder`'s `FileExistsError`-unless-`--force` gate
  (section 1). An explicit `--force` (or equivalent) override should be considered
  for the spec, consistent with existing precedent, but is a spec decision, not
  determined by this research.
- **Ordering**: no cross-artifact ordering dependency was found in the source
  documents — the seven artifact instances and the domain profile are independent
  files within one scaffold operation; there is no observed requirement that one
  artifact be written before another.
- **Edge cases**: (a) target path exists but is not a directory; (b) target path's
  parent does not exist; (c) `--template-root` override points at a missing/partial
  template set (must fail fast per the `FileNotFoundError` precedent in section 1,
  not silently skip a file). These are candidates for the spec's acceptance-criteria
  table, not fully specified in the current draft `issue.md`.

## Requirements Mapping (issue.md acceptance criteria → design)

| Acceptance criterion (issue.md) | Design element |
|---|---|
| Scaffolds directory layout in a target consumer path | `create_discovery_workspace(target_dir: Path, ...)` pure orchestration function in `init_flow.py`, target resolved from an explicit CLI arg (not `resolve_workspace()`), per section 1/4. |
| Writes starter domain-profile config, shape of feature 9001, placeholder tokens | Copy+substitute `docs/discovery/templates/domain-profile/domain-profile.yaml` (section 3/4), flat key:value shape compatible with either parser candidate (section 4). |
| Writes starter instances of the seven artifacts from templates | Copy+substitute each of the seven files under `docs/discovery/templates/artifacts/` (section 3), each carrying a relative `$schema` reference per section 5's mechanism. |
| Templates reference schema-versioning convention (9002) | Relative, scheme-less `$schema` path resolved by `validate_json.py`'s existing `_load_schema` no-scheme branch (section 5) — content of the convention itself is 9002's, not this feature's, to define. |
| No domain-specific identifiers in templates/generated artifacts | Placeholder-token-only authoring plus a dedicated neutrality unit test (section 7). |
| Tests satisfy line >= 85%, branch >= 75% | Standard pytest suite under `tests/scripts/dev_tools/discovery/`, `poetry run pytest --cov --cov-branch` (section 6); T4 tier, no property/mutation-test obligation. |

## Testing Implications

- Unit tests for the pure scaffolding logic (`init_flow.py`) using a fake
  `FileSystem` implementation (mirroring `FakeFileSystem` in
  `tests/scripts/dev_tools/test_new_potential_bug_entry.py`), avoiding any real
  filesystem I/O or temp files, per the "no temp files in tests" rule.
- A CLI-level test invoking `main()`/`parse_args()` with `monkeypatch`-injected
  `sys.argv`, matching the existing pattern of testing `parse_args()` separately from
  the pure orchestration function.
- A scenario test asserting that scaffolding into an empty target produces the full
  expected file set (issue.md test condition: "initialization into an empty target
  path produces the full layout").
- A schema-conformance test asserting each generated starter artifact is well-formed
  against its schema (issue.md test condition) — this test can only be completed
  once feature 9002's schema files exist; until then it should be written against
  the planned schema shape and marked to be finalized when 9002 lands, or deferred
  to the plan/execution phase with an explicit dependency note.
- A domain-neutrality regression test (section 7).
- A negative test for non-empty/invalid target path fail-fast behavior (issue.md
  test condition), matching the `FileExistsError`-unless-`--force` precedent.
- No integration test against a real external consumer repository is required or
  appropriate for this feature — the "consumer repository" is simulated entirely via
  the injected `FileSystem` fake and/or `tmp_path`-free fake paths, keeping tests
  fast, isolated, and independent of network/external processes.

## Rejected Alternatives (brief)

- **New top-level `templates/` directory** — rejected in favor of
  `docs/discovery/templates/` (not covered by any existing governed glob; no
  top-level `templates/` precedent exists in this repository).
- **Jinja2/templating-engine rendering** — rejected in favor of literal placeholder
  `str.replace`, matching 100% of existing scaffolding precedent and requiring no new
  dependency.
- **Flat `scripts/dev_tools/discovery_*.py` modules** — rejected in favor of a nested
  `scripts/dev_tools/discovery/` package, because five other Wave 1+ sibling
  features will add commands to the same `dev.discovery.*` namespace and a shared
  package avoids flat-namespace crowding (section 2).

## Automation Feasibility

All steps required to implement this feature are automatable CLI/file operations:
writing Python modules under `scripts/dev_tools/discovery/`, writing Markdown/YAML/
JSON template files under `docs/discovery/templates/`, editing one
`[tool.poetry.scripts]` line in `pyproject.toml`, writing pytest test files under
`tests/scripts/dev_tools/discovery/`, and running the standard
format/lint/type-check/test toolchain. There is no third-party UI interaction and no
unautomatable human step in scope for this feature.
