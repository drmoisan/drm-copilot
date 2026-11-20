# Research: legacy-discovery-config-contract (#360)

- Timestamp: 2026-07-17T10-40
- Epic: legacy-discovery-and-parity (Wave 0, complexity C3)
- Scope: repository-local domain-profile configuration contract, typed dataclass loader,
  PyYAML-vs-regex specification decision, `dev.discovery.*` CLI entry point, tests.
- Out of scope (owned elsewhere): JSON schema files (#9002 / legacy-discovery-schemas),
  standalone validators (#9003 / legacy-discovery-validators).

## 1. Current State Analysis (verified substrate)

### 1.1 PyYAML is declared but unused

- `pyproject.toml` line 19 declares `PyYAML = ">=6.0"` under `[tool.poetry.dependencies]`.
- A repository-wide grep for `import yaml` / `from yaml` across all `*.py` files returns
  zero matches. PyYAML is a declared but currently-unused runtime dependency. Adopting it
  adds no new dependency.

### 1.2 Existing hand-rolled frontmatter parsing — two precedents

**Precedent A — `scripts/dev_tools/push_down_claude_filesystem.py` (lines 66–142).**
Three regexes: `_FRONTMATTER_PATTERN` (lines 66–68) isolates the leading `---` block with
`re.DOTALL`; `_METADATA_BLOCK_PATTERN` (lines 72–75) captures the indented block under a
column-zero `metadata:` key; `_SCOPE_LEAF_PATTERN` (lines 78–81) reads one scalar leaf,
stripping inline comments and matching quotes (lines 133–139). Capabilities: exactly one
two-level scalar leaf (`metadata.scope`), fail-safe default on any miss. The module's own
docstring (lines 89–91) states the design intent: "a narrow `re`-based parser. This avoids
adding a runtime YAML dependency (PyYAML) while reading only the single leaf the push-down
scope filter requires." The rationale is explicitly scoped to single-leaf extraction.

**Precedent B — `scripts/dev_tools/codex_native_converter/parser.py` (lines 76–98).**
`_parse_frontmatter` scans lines between `---` boundaries; every line containing `:` is
`partition`-ed into a flat `dict[str, str]` with quote stripping (line 96). Limitations
verified from the code:

- Nesting is destroyed: an indented child key (`  root: x`) is stored as a top-level key
  indistinguishable from its parent; the parent key (`legacy_source:`) is stored with an
  empty-string value.
- YAML list items (`- foo`) contain no `:` and are silently skipped (line 93–94).
- No typed scalars: everything is `str`; no int/bool/null distinction.
- No block scalars, anchors, multi-line values, or syntax-error reporting.

Neither precedent can represent a nested mapping with lists — both were built for flat or
single-leaf frontmatter, not structured configuration.

### 1.3 `dev.*` console-script convention

`pyproject.toml` `[tool.poetry.scripts]` (lines 47–69): every `dev.*` alias maps to
`scripts.dev_tools.<module-or-package.module>:main`. Subpackage precedents exist:
`"dev.pr-context" = "scripts.dev_tools.pr_context.collector:main"` (line 65) and
`"dev.atomic-executor" = "scripts.dev_tools.atomic_executor.cli:main"` (line 56).

Module convention, verified in `scripts/dev_tools/format_json.py`:

- `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace` with its own
  `argparse.ArgumentParser` (lines 95–118).
- `def main(argv: Sequence[str] | None = None) -> int` returning 0/1 (lines 121–155).
- Terminates with `if __name__ == "__main__": sys.exit(main())` (lines 158–159).
  (Other modules use `raise SystemExit(main())`; both forms exist; the issue text names the
  `raise SystemExit(main())` form — use that.)

Subparser-style CLI precedent (relevant to #9003, not required here):
`scripts/dev_tools/validate_orchestration_artifacts.py` `build_parser()` (lines 144–168)
with `add_subparsers(dest="artifact_type", required=True)`.

### 1.4 Test conventions

- Tests mirror sources: `tests/scripts/dev_tools/test_<module>.py`; subpackages mirror too
  (`tests/scripts/dev_tools/codex_native_converter/...`).
- Temp files are prohibited. The repo's replacement is the `mem_fs_path` fixture defined in
  `tests/conftest.py` (line 146): an in-memory filesystem `Path` compatible with `pathlib`
  APIs, explicitly created "to enforce repository policy against temporary file usage in
  unit tests" (lines 150–153).
- `tests/scripts/dev_tools/test_format_json.py` demonstrates the full pattern: pure-logic
  tests via in-memory stores/monkeypatch (lines 15–41), `parse_args` unit tests (lines
  141–172), and `main()` end-to-end tests over `mem_fs_path` asserting exit codes and
  `capsys` output (lines 175–335).

### 1.5 Toolchain constraints relevant to this feature

- Pyright runs in `strict` mode (`pyproject.toml` line 125) over `scripts`, `src`, `tests`.
- Ruff enables the bandit ruleset `S` (`pyproject.toml` line 88): `yaml.load` without a
  safe loader triggers S506; `yaml.safe_load` does not.
- Coverage source already includes `scripts/dev_tools` (`pyproject.toml` line 103), so a
  new `scripts/dev_tools/discovery/` package is measured automatically.
- Dataclass style precedent: `frozen=True` appears 43 times across 24 files under
  `scripts/dev_tools`; `.claude/rules/python.md` line 26 directs `@dataclass` for value
  objects, `frozen=True` where appropriate, invariants in `__post_init__`.
- Explicit stub-package precedent: `types-beautifulsoup4`, `types-requests` in the dev
  group (`pyproject.toml` lines 44–45).
- No existing `discovery` name in Python: grep for `discovery` under `scripts/` matches
  only unrelated identifiers (`plan_discovery.py`, PoshQC, etc.). The `dev.discovery.*`
  namespace and `scripts/dev_tools/discovery/` package name are free.

## 2. Specification Decision: PyYAML vs hand-rolled regex

### 2.1 What the profile must express

The contract (section 3 of the epic objective) requires nested mappings (legacy source
location with options, target location, artifact conventions), lists of strings
(technology stack, include/exclude globs), and at least one typed scalar
(`profile_version`). See the field set in section 3 below.

### 2.2 Evaluation

| Criterion | PyYAML (`yaml.safe_load`) | Hand-rolled regex (repo precedent) |
|---|---|---|
| Nested maps | Native | Precedent B flattens/corrupts nesting (parser.py 92–96); Precedent A supports exactly one hardcoded leaf |
| Lists | Native | Precedent B silently drops `- item` lines (no `:`) |
| Typed scalars (int/bool/null) | Native | Everything is `str` |
| Syntax-error reporting | `yaml.YAMLError` with line/column marks | None; malformed input silently yields partial dicts |
| Dependency cost | Zero new — declared at pyproject.toml line 19 | Zero |
| Security | `safe_load` constructs only plain Python types; passes ruff S506 | n/a |
| Pyright strict | typeshed ships PyYAML stubs; Pyright bundles typeshed third-party stubs as fallback, and the repo has precedent for explicit `types-*` dev stubs (lines 44–45) | Pure stdlib |
| Maintenance | Parsing delegated; loader tests target semantics, not tokenization | A general nested-map+list parser would be a new mini-YAML implementation — high test surface, contradicts simplicity-first (`.claude/rules/general-code-change.md` Design Principles #1) |
| Repo-precedent fit | The single documented reason to avoid PyYAML ("avoids adding a runtime YAML dependency ... reading only the single leaf", push_down_claude_filesystem.py 89–91) does not apply: the dependency already exists and the profile is not a single leaf | Precedents were built for flat/single-leaf frontmatter only |

### 2.3 Recommendation (final)

**Adopt PyYAML via `yaml.safe_load`.** Justification: (a) the profile structurally requires
nested maps, lists, and typed scalars, which both regex precedents demonstrably cannot
express; (b) PyYAML is already a declared Poetry dependency, so the only cost the existing
precedent avoided — adding a runtime dependency — is already paid; (c) `safe_load` is the
bandit/ruff-clean loader; (d) extending the regex convention to full nested structure would
amount to writing an untyped YAML parser by hand, violating simplicity-first and inflating
the test surface. This makes the loader the first `import yaml` in the repository; that is
the intended outcome of the epic's explicit specification decision.

**Pyright note.** `yaml.safe_load` returns `Any`. Keep strict-mode cleanliness by isolating
the untyped boundary in one helper, e.g.
`_load_yaml_mapping(text: str, source: str) -> dict[str, object]` that calls `safe_load`,
`isinstance`-checks the result is a `dict`, and rejects non-mapping documents with a
specific error. Type resolution: Pyright bundles typeshed's third-party PyYAML stubs as a
fallback, so `import yaml` is expected to type-check without changes; if the
implementation-stage `poetry run pyright` pass surfaces a missing-stub diagnostic, add
`types-PyYAML` to the dev group — consistent with the `types-beautifulsoup4` /
`types-requests` precedent — but flag it in the plan as a new dev dependency requiring
approval (`.claude/rules/python.md` Prohibited Behaviors: no new dependencies without
explicit instruction).

### 2.4 Rejected alternatives (brief)

- **Extend the hand-rolled regex convention**: cannot express the required structure
  without becoming a bespoke YAML parser; rejected per the table above.
- **JSON profile instead of YAML**: stdlib `json` would avoid the parser decision, but the
  profile is a human-authored config where comments and readability matter, the epic frames
  the decision as PyYAML-vs-regex over a YAML-style contract, and JSON schema validation of
  the profile remains available to #9003 regardless of the authoring syntax.
- **`tomllib`/TOML profile**: stdlib on 3.11+, but the repo floor is Python 3.10
  (pyproject.toml line 17) where `tomllib` is absent, and no repo precedent exists.

## 3. Proposed Domain-Profile Field Set (contract)

Default filename authored at the consumer repository root: `discovery-profile.yaml`
(expose as a module constant `DEFAULT_PROFILE_FILENAME`; #9005 init-templates scaffolds
it; the CLI defaults to it).

All names are domain-neutral. No field name or enum value references
TaskMaster/TMW/Outlook/VSTO/email/task-management concepts; stack identifiers are
free-form strings supplied by the consumer.

```yaml
profile_version: 1                # required, int. Only 1 accepted; gate for evolution.
profile_name: "my-migration"      # optional, str. Label used by reports; no semantics.

legacy_source:                    # required mapping
  root: "../TaskMasterCheckout"   # required, non-empty str. Path to legacy source
                                  # (absolute, or relative to the profile file's directory).
  description: "..."              # optional str
  include: ["src/**"]             # optional list[str] of glob patterns; default: all
  exclude: ["**/bin/**"]          # optional list[str] of glob patterns; default: none

target:                           # required mapping
  root: "../TMWCheckout"          # required, non-empty str
  description: "..."              # optional str

technology_stack:                 # required mapping
  legacy: ["csharp", "vsto"]      # required, non-empty list of non-empty str (free-form)
  target: ["typescript"]          # optional list of non-empty str; default: empty

artifacts:                        # required mapping
  root: "discovery/"              # required, non-empty str. Workspace root (relative to
                                  # the consumer repo) where discovery artifacts are written.
  conventions:                    # optional mapping str -> non-empty str. Artifact-kind
    feature-contract: "contracts/"    # keys are free-form here; the kind vocabulary and
    coverage-ledger: "coverage.json"  # per-kind schemas are owned by #9002/#9005, so the
                                      # loader stores the mapping without validating kinds.
```

Contract rules:

- **Required**: `profile_version`, `legacy_source.root`, `target.root`,
  `technology_stack.legacy`, `artifacts.root`.
- **Optional with defaults**: `profile_name` (None), `legacy_source.description` (None),
  `legacy_source.include` (empty), `legacy_source.exclude` (empty), `target.description`
  (None), `technology_stack.target` (empty), `artifacts.conventions` (empty mapping).
- **Unknown keys are rejected** at the top level and inside each known section, with an
  error naming the offending key and listing the allowed keys. Rationale: fail-fast typo
  protection; `profile_version` is the forward-compatibility gate, so strictness does not
  block evolution.
- **The loader validates shape and types only.** It does not check that `root` paths
  exist. Existence/reachability is a runtime concern for validators (#9003) and analyzers
  (#9006); keeping the parse layer pure keeps it deterministic and I/O-free per the I/O
  Boundaries rule. The CLI may resolve and display absolute paths without asserting
  existence.
- **Layering for #9002/#9003**: the field set above is expressible as a JSON schema
  (mappings, string lists, int enum), and `parse_domain_profile_text(text, source)` gives
  #9003 a text-in interface aligned with the canonical
  `validate_<artifact>_text(text) -> list[str]` pattern (see
  `validate_orchestration_artifacts.py` lines 255–320). This feature must not ship a
  schema file or a `validate_*_text` validator.

## 4. Loader Design

### 4.1 Module: `scripts/dev_tools/discovery/domain_profile.py`

Dataclasses (all `frozen=True`, matching the 43-use repo precedent and
`.claude/rules/python.md` line 26):

```python
@dataclass(frozen=True)
class LegacySourceConfig:
    root: str
    description: str | None = None
    include: tuple[str, ...] = ()
    exclude: tuple[str, ...] = ()

@dataclass(frozen=True)
class TargetConfig:
    root: str
    description: str | None = None

@dataclass(frozen=True)
class TechnologyStackConfig:
    legacy: tuple[str, ...]
    target: tuple[str, ...] = ()

@dataclass(frozen=True)
class ArtifactsConfig:
    root: str
    conventions: tuple[tuple[str, str], ...] = ()   # ordered pairs; keeps the frozen
                                                    # dataclass hashable; expose a
                                                    # conventions_map property -> dict[str, str]

@dataclass(frozen=True)
class DomainProfile:
    profile_version: int
    legacy_source: LegacySourceConfig
    target: TargetConfig
    technology_stack: TechnologyStackConfig
    artifacts: ArtifactsConfig
    profile_name: str | None = None
```

Lists are normalized to tuples so frozen instances are truly immutable; `conventions` as a
tuple of pairs avoids a mutable `dict` field inside a frozen dataclass (a `dict` field
breaks hashability and mutability guarantees).

### 4.2 Fail-fast validation approach

Two layers, per `.claude/rules/general-code-change.md` (enforce invariants at
construction) and the collect-then-raise pattern that gives actionable CLI errors:

1. **Parse layer (primary)** — module functions:
   - `parse_domain_profile_text(text: str, source: str = "<string>") -> DomainProfile` —
     pure; wraps `yaml.YAMLError` into `DomainProfileError` with the source label and the
     YAML mark; rejects non-mapping documents; walks the mapping section-by-section
     collecting **all** field errors (missing required, wrong type, empty string, empty
     list, unknown key, unsupported `profile_version`) into `list[str]`; raises a single
     `DomainProfileError` whose message enumerates every error with its dotted field path
     (e.g. `legacy_source.root: expected non-empty string, got int`).
   - `load_domain_profile(path: Path) -> DomainProfile` — thin I/O wrapper:
     `read_text(encoding="utf-8")` then delegate to the text function; wraps
     `FileNotFoundError`/`OSError` into `DomainProfileError` with the path in the message.
2. **Dataclass `__post_init__` (defense-in-depth)** — each dataclass re-asserts its local
   invariants (non-empty `root`, non-empty `legacy` tuple, `profile_version == 1`,
   non-empty convention keys/values) and raises `DomainProfileError` on violation, so a
   direct constructor call cannot produce an invalid instance.

Exception type: one module-level `class DomainProfileError(ValueError)` — a specific,
catchable type per the fail-fast rule; `ValueError` base matches the repo's existing
user-facing validation errors (e.g. `new_active_feature_folder_models.validate_feature_name`,
lines 130–136). No broad `except Exception` anywhere; the CLI boundary catches only
`DomainProfileError`.

### 4.3 Pyright-strict and domain-neutrality tactics

- Isolate `Any` at one seam: `_load_yaml_mapping(text, source) -> dict[str, object]`
  (isinstance-narrowing after `yaml.safe_load`); all downstream extraction helpers take
  `object` values and narrow with `isinstance` before use — no `cast` chains, no
  `# type: ignore`.
- Small typed extraction helpers (`_require_str`, `_optional_str`, `_str_list`,
  `_require_mapping`) shared across sections keep branching flat and the file small.
- Domain neutrality: no domain identifier appears in code, field names, defaults, error
  messages, or docstrings. Add a contract test (see 6.3) that scans the module source for
  banned substrings (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`)
  case-insensitively — the same style as existing `test_*_contracts.py` tests.

## 5. CLI Design

### 5.1 Naming and wiring

- Console script (one line in `[tool.poetry.scripts]`, alphabetical within the
  `# Dev Tools Aliases` block):
  `"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"`
- Package layout follows the `pr_context`/`atomic_executor` subpackage precedent
  (pyproject lines 56, 65). Placing this feature's modules in a
  `scripts/dev_tools/discovery/` package reserves a coherent home for later
  `dev.discovery.*` commands shipped by sibling features (#9005, #9006, #9010, ...), each
  adding its own module + script line per the epic's shared design.

### 5.2 Argparse surface (module `profile_cli.py`)

- `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace`:
  - positional `profile_path`, `nargs="?"`, default `discovery-profile.yaml`
    (via the `DEFAULT_PROFILE_FILENAME` constant) — "load and show" is one action, so a
    flat parser suffices; subparsers are not warranted for a single verb (the subparser
    pattern belongs to #9003's multi-artifact validator).
  - `--json`: emit the resolved profile as JSON (`dataclasses.asdict` + `json.dumps`,
    sorted keys) for machine consumption; default output is aligned `key: value` text of
    the resolved profile (declared values plus applied defaults — this is the "resolved"
    part).
- `main(argv: Sequence[str] | None = None) -> int`:
  - success: print resolved profile, return `0`.
  - `DomainProfileError` (missing file, unreadable, malformed YAML, failed validation):
    print the full multi-error message to `stderr`, return `1`.
  - usage errors exit `2` via argparse's built-in behavior (unchanged).
- Ends with `if __name__ == "__main__": raise SystemExit(main())` per the issue's stated
  convention (issue.md line 33).

## 6. Testing Approach

### 6.1 Layout (mirrors production tree)

- `tests/scripts/dev_tools/discovery/__init__.py` — not needed (pytest rootdir config);
  match whatever the existing `tests/scripts/dev_tools/codex_native_converter/` directory
  does (it has test modules directly).
- `tests/scripts/dev_tools/discovery/test_domain_profile.py`
- `tests/scripts/dev_tools/discovery/test_profile_cli.py`

### 6.2 No-temp-file strategy (repo policy)

- **Parse-layer tests need no filesystem at all**: feed inline YAML strings to
  `parse_domain_profile_text`. This is the dominant test surface and is pure.
- **`load_domain_profile` and CLI `main` tests** use the `mem_fs_path` in-memory
  filesystem fixture (`tests/conftest.py` line 146), exactly as
  `test_format_json.py` does (lines 175–335): write profile text to
  `mem_fs_path / "discovery-profile.yaml"`, invoke `main([str(path)])`, assert exit code
  and `capsys` output. Do not use pytest `tmp_path`.

### 6.3 Scenario matrix (drives >= 85% line / >= 75% branch)

Parse layer (`test_domain_profile.py`):

- Positive: full profile (every optional present); minimal profile (defaults applied —
  assert each default value).
- Negative, parametrized (`pytest.mark.parametrize` per python.md line 81): each of the
  five required fields missing (5 cases, each asserting its dotted path appears in the
  error); type mismatches (string where list, list where string, string
  `profile_version`, non-mapping section); empty-string roots; empty `legacy` list;
  unsupported `profile_version: 2`; unknown top-level key; unknown key in each section;
  malformed YAML syntax (assert source label in message); non-mapping document
  (`- just\n- a list`); duplicate-free multi-error message (one malformed profile with 3
  defects → all 3 reported in a single raise).
- Direct-construction invariants: constructing each dataclass with an invalid value raises
  `DomainProfileError` (covers `__post_init__` branches).
- `load_domain_profile`: happy path and missing-file path via `mem_fs_path`.
- Domain-neutrality contract test: read `domain_profile.py` and `profile_cli.py` source
  (production files read at test time — same pattern as existing contract tests) and
  assert no banned domain substring appears.

CLI layer (`test_profile_cli.py`):

- `parse_args`: default path, explicit path, `--json` flag.
- `main`: success text output (capsys, exit 0); `--json` output parses via `json.loads`
  and round-trips expected keys (exit 0); missing profile file → exit 1, message on
  stderr; malformed profile → exit 1, all field errors on stderr; default-filename path
  resolution.

Every validation branch in the parse helpers is reachable from the parametrized negative
matrix, which is what carries branch coverage past 75%; the pure-text interface means no
mocking is needed for the bulk of the suite (python.md line 83: mock sparingly).

## 7. File-Size Limit and Module Layout

The 500-line production/test file limit is confirmed in
`.claude/rules/general-code-change.md` (File Size Limit). Recommended split:

| File | Content | Size estimate |
|---|---|---|
| `scripts/dev_tools/discovery/__init__.py` | Empty or re-export of `DomainProfile`, `DomainProfileError`, `load_domain_profile` | < 30 |
| `scripts/dev_tools/discovery/domain_profile.py` | Exception, five dataclasses, typed extraction helpers, `parse_domain_profile_text`, `load_domain_profile`, `DEFAULT_PROFILE_FILENAME` | ~300–380 with repo-style docstrings |
| `scripts/dev_tools/discovery/profile_cli.py` | `parse_args`, rendering (text/JSON), `main` | ~120–170 |
| `tests/scripts/dev_tools/discovery/test_domain_profile.py` | Parse + load + neutrality tests | ~350–450 (split into `_part2` if it approaches 500, per repo precedent `test_..._part2.py`) |
| `tests/scripts/dev_tools/discovery/test_profile_cli.py` | CLI tests | ~200–300 |

The loader/CLI split is required by separation-of-concerns (pure parsing vs I/O+argparse)
and keeps each file comfortably under the limit. If the docstring-heavy house style pushes
`domain_profile.py` toward 500, move the dataclasses into
`discovery/domain_profile_models.py` (precedent: `new_active_feature_folder_models.py`).

## 8. Requirements Mapping (acceptance criteria → design)

| Acceptance criterion (issue.md lines 37–43) | Design element |
|---|---|
| Contract documented with required/optional fields | Section 3 field set → carried into the feature spec.md; module docstring restates it |
| Dataclass-based typed loader | Section 4.1 dataclasses + `parse_domain_profile_text` / `load_domain_profile` |
| Fail-fast, specific errors on malformed/missing | `DomainProfileError` with dotted-path, collect-all-then-raise (4.2) |
| Parser decision made and justified in spec.md | Section 2 recommendation: PyYAML `yaml.safe_load` |
| `dev.discovery.*` CLI loads and shows resolved profile | `dev.discovery.profile` → `scripts.dev_tools.discovery.profile_cli:main` (5.1–5.2) |
| No domain-specific identifiers in loader | Neutral field vocabulary (3) + neutrality contract test (6.3) |
| pytest, line >= 85% / branch >= 75% | Scenario matrix (6.3), inline-string parse tests + `mem_fs_path` CLI tests |

## 9. Risks and Open Points for Planning

- **Pyright/PyYAML stubs**: expected to resolve via Pyright's bundled typeshed third-party
  stubs; if the strict-mode run flags a missing stub, adding `types-PyYAML` to the dev
  group is the fix but is a new dev dependency requiring explicit approval (python.md
  Prohibited Behaviors). Surface this as a conditional step in the plan.
- **First `import yaml` in the repo**: no code risk, but reviewers should expect the
  previously-unused declared dependency to become load-bearing.
- **Convention keys are unvalidated by design**: the artifact-kind vocabulary belongs to
  #9002/#9005; document this boundary in spec.md so feature-review does not read the
  free-form mapping as a gap.
- **Windows paths**: profile `root` values may contain backslashes when authored on
  Windows; the loader stores strings verbatim and performs no normalization — note in the
  contract docs that forward slashes are recommended for portability (no code behavior
  depends on it in this feature).
