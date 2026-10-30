# docs-coverage-ledger-and-receipt (Issue #1023) - Research

- Feature: 900005 of epic #1019 (documentation-estate-tooling), wave 1, band C4
- Branch: `feature/docs-coverage-ledger-and-receipt-1023`
- Mode: preparation research only; no source, configuration or test file was changed.
- Sources read: `docs/features/epics/documentation-estate-tooling/epic.md` (`## Shared Design`,
  `### Decisions recorded during preparation of 1020 (binding on later children)`, assumptions
  A1-A6, `### 900005 - docs-coverage-ledger-and-receipt (wave 1, C4)`, and the 900007/900008
  sections that consume this feature), this feature's `issue.md` and `spec.md`, the #1020 `spec.md`,
  `plan.2026-10-30T16-08.md` and research file, `.claude/skills/execution-environment/SKILL.md`, and
  every repository file cited below.
- Timestamp note: the task-researcher tool set has no shell or clock tool. The filename stamp was
  taken from a public UTC time service (`timeapi.io`, UTC zone) immediately before the write.
- Dependency status: #1020 is planned, not executed. Every `drm_copilot_docs` symbol, schema field
  and test named below as "planned by #1020" does not exist in the tree and is cited from the #1020
  spec and plan. This research proposes nothing that re-creates a #1020 file.
- Assumption status: A1-A6 are provisional and unapproved. This feature relies on A5 (package
  `packages/docs-runtime`, import `drm_copilot_docs`) and A6 (MCP tools delivered by 900007 only).
  If A5 changes, every module path below changes with it.
- Source of the requirement: one consumer repository, where documentation drift was measured by
  hand (epic `## Goal`).

## 1. Current State Analysis

### 1.1 Contracts planned by #1020 that this feature consumes

All items in this subsection are planned by #1020 (`spec.md` sections named in parentheses).

Package and registration (`## Implementation Strategy`, AC8):

- Package `packages/docs-runtime`, distribution `drm-copilot-docs`, import `drm_copilot_docs`,
  version `1.0.0`, `__version__ = "1.0.0"` in `__init__.py`, `py.typed`.
- Package `pyproject.toml` declares its own `[tool.poetry.scripts]` with `dev.docs.init` and
  `dev.docs.validate-profile`, and is asserted by `test_package_pyproject_matches_runtime_contract`
  in `tests/docs_runtime/test_docs_package_contract.py`.
- Root `pyproject.toml` (append only): path dependency
  `drm-copilot-docs = { path = "packages/docs-runtime", develop = true }`; scripts
  `"dev.docs.init" = "drm_copilot_docs.cli:main_init"` and
  `"dev.docs.validate-profile" = "drm_copilot_docs.cli:main_validate_profile"` placed after
  `"dev.discovery.doctor"`; `"packages/docs-runtime/src"` appended to `[tool.coverage.run] source`
  and `[tool.pyright] include`. Asserted by `test_root_pyproject_registers_docs_console_scripts`
  and `test_root_tooling_includes_docs_runtime_for_coverage_and_pyright`.
- `quality-tiers.yml`: `packages/docs-runtime` classified `T2`.
- Wheel: `scripts/dev_tools/build_docs_runtime.py` stages only the schema files listed in
  `packages/docs-runtime/resource-manifest.json` into `drm_copilot_docs/_resources/` and builds
  `dist/docs/drm_copilot_docs-1.0.0-py3-none-any.whl`. Python modules are packaged by
  `packages = [{ include = "drm_copilot_docs", from = "src" }]`, so new 900005 modules ship in the
  wheel with no builder change.
- Tests: `tests/docs_runtime/__init__.py` exists (planned), so test modules import as
  `docs_runtime.test_*`; colliding basenames carry a `docs_` prefix
  (`test_docs_schema_validation.py`, `test_docs_resources.py`).
- Neutrality: `tests/docs_runtime/test_neutrality.py` scans every file under
  `packages/docs-runtime/src/` and `schemas/docs/`, so 900005 modules are scanned automatically.

Schema identity (`### Schema identity and reference conventions`): `$id`
`urn:drm-copilot:docs:1.0.0:<name>`; artifact header `$schema`, `schema_version` (`"1.0.0"`),
`artifact_kind`, `id` (discovery `identifier`), `extensions`; closed objects; inapplicable fields
are `null`; formats limited to `date-time` and `uri`.

Docs `common` definitions used here (`### Docs common $defs`): `element-kind` (six kinds),
`element-id` (`<kind>-<64 hex>`), `disposition` (`documented`, `excluded`, `deferred`),
`parity-dimension` (five), `parity-state` (`pass`, `fail`, `not-assessed`, `not-applicable`),
`artifact-pin` (`artifact_kind`, `path`, `sha256`), `page-binding` (`page_path`, `anchor`),
`actor` (`kind` in `human`/`agent`/`tool`, `id`), `finding` (key set equal to
`drm_copilot_discovery.findings.Finding.to_dict`), `docs-artifact-kind` (the six artifact kinds).

Artifact schemas, field level:

| Schema | Fields (beyond the header) |
|---|---|
| `surface-inventory-snapshot` | `repository`, `revision` (revision or `null`), `profile_sha256`, `analyzers[{id, version}]`, `inputs[{path, sha256, size}]`, `elements[]`, `diagnostics[]`, `captured_at`. Element: `element_id`, `kind`, `path`, `declaration`, `name`, `parent_id`, `analyzer_id`, `source_sha256`, `line_range` (`{start, end}` or `null`), `properties[{name, value}]`, `extensions`. |
| `docs-coverage-ledger` | `repository`, `snapshot_ref` (artifact-pin, kind const `surface-inventory-snapshot`), `entries[]`. Entry: `element_id`, `kind`, `disposition`, `page_bindings[]`, `rationale`, `owner`, `target`, `updated_by` (actor), `extensions`. Companion rules: `documented` needs at least one binding and null rationale/owner/target; `excluded` needs rationale text, no bindings; `deferred` needs owner and target, no bindings, rationale optional. Completeness is explicitly left to 900005. |
| `docs-parity-matrix` | `repository`, `snapshot_ref`, `ledger_ref` (kind const `docs-coverage-ledger`), `rows[]`. Row: `element_id`, `kind`, `page_path`, `dimensions` (exactly the five keys, each `{state, rationale, evidence_pin_ids}`; `fail` and `not-applicable` require rationale text), `extensions`. |
| `docs-evidence-pin` (collection) | `repository`, `pins[]` sorted by `pin_id`. Pin: `pin_id` (identifier), `element_id`, `element_kind`, `page_path`, `symbol` (the pinned declaration), `source_path`, `source_sha256` ("900005 compares it with the current snapshot element to mark the bound page stale"), `revision` (revision or `null`), `claim` (text or `null`), `pinned_at`, `pinned_by` (actor). |
| `docs-validation-receipt` | `mode` (`profile`, `ledger`, `matrix`, `docs-complete`), `repository`, `revision` (non-null; 900008 matches it against the head revision), `inputs[]` (artifact-pin), `counts` (`elements_total`, `undocumented`, `stale_pages`, `by_disposition` with exactly the three dispositions, `by_kind` with exactly the six kinds), `validation_result` (`pass`/`fail`), `findings[]` (docs finding), `issued_at`, `writer` (`{tool: "drm-copilot-docs", version}`). `pass` forbids an `error` finding; `fail` requires one. |

Profile fields this feature reads (`### Artifact schema: docs-profile`; `profile_models.py` names
`CompletionGates`, `DocsCompleteGate`, `IntegrationPrGate`, `ArtifactPaths`, `PageOwner`):

- `completion_gates.docs_complete`: `required_dispositions_complete` (const `true`),
  `allow_deferred` (boolean), `max_stale_pages` (integer minimum 0), `required_parity_dimensions`
  (unique parity dimensions).
- `artifact_paths`: `inventory_snapshot`, `coverage_ledger`, `parity_matrix`, `evidence_pins`,
  `validation_receipt` (relative paths). The #1020 spec states that 900005 reads
  `completion_gates.docs_complete` and these paths.
- `page_owners[{path_or_glob, owner}]` (used for the `owner_assigned` consistency check).

Python API planned by #1020:

| Symbol | Signature (as planned) | Pure |
|---|---|---|
| `surface_models.ElementKind`, `ELEMENT_KINDS` | `Literal[...]`; tuple in contract order | yes |
| `surface_models.element_identifier` | `(*, kind: ElementKind, path: str, declaration: str) -> str` (`stable_id(kind, row(kind=..., path=..., declaration=...))`) | yes |
| `surface_models.SurfaceElement` | frozen `kw_only` dataclass; `__post_init__` recomputes and enforces `element_id` | yes |
| `surface_models.element_to_json` | `(element: SurfaceElement) -> JsonObject` | yes |
| `profile.parse_profile` | `(content: bytes, *, format: Literal["json", "yaml"], artifact_path: str, registry=None) -> ProfileLoadResult` (`profile`, `findings`, `ok`) | yes |
| `schema_validation.validate_artifact` | `(value: JsonValue, *, artifact_kind: str, artifact_path: str, resources: Mapping[str, bytes] \| None = None) -> tuple[Finding, ...]` (code `SCHEMA_INVALID`) | pure when `resources` is supplied; reads installed resources when `None` |
| `schema_validation.DOCS_SCHEMA_NAMES`, `docs_schema_id`, `build_registry` | as named | yes |
| `cli.run_cli` | `(command, argv, *, ports, stdout, stderr) -> int`; argparse with `SystemExit` caught; exits 0/1/2/3 | I/O through ports |

Gap noted for planning: #1020 plans `element_to_json` but no inverse (no snapshot loader and no
`element_from_json`); 900003's file list (`snapshot_builder.py`) writes snapshots and does not
read them. 900005 needs a reader (section 4.1).

### 1.2 Discovery runtime pieces (verified in tree)

All modules are under `packages/discovery-runtime/src/drm_copilot_discovery/`.

| Symbol | Signature | Pure | Use in 900005 |
|---|---|---|---|
| `findings.Finding` | frozen `kw_only` dataclass: `code`, `message`, `next_action`, `severity="error"`, `artifact_path=None`, `pointer=""`, `related_ids=()`, `related_paths=()`; `to_dict()` | yes | Import. `related_ids` must match `[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*`; docs element ids (`cli-command-<hex>`) and `pin-<hex>` satisfy it. |
| `findings.FindingCollector` | `(*, limit: int = 100)`; `add`, `findings` (sorted, bounded, `FINDINGS_LIMIT` marker) | yes (private buffer) | Import. |
| `findings.ordered_findings` | `(findings, *, limit=100) -> tuple[Finding, ...]` | yes | Import. |
| `findings.finding_key`, `child_pointer`, `validate_finding_path` | ordering key; `(pointer, part) -> str`; `(path) -> None` raising `ValueError` | yes | Import. |
| `models.JsonObject`, `JsonValue`, `canonical_json`, `to_plain_value`, `ParseLimits`, `ParsedDocument` | `canonical_json(value) -> bytes` (sorted keys, compact, LF); `ParsedDocument.value`, `.findings`, `.source_sha256` | yes | Import. `ParsedDocument.source_sha256` gives the raw-input digest for receipt `inputs`. |
| `parsing.parse_document` | `(content: bytes \| str, *, format: Literal["json", "yaml"], artifact_path=None, limits=None) -> ParsedDocument` | yes | Import (bounded parse, duplicate-key rejection). |
| `analyzer.findings.row`, `stable_id` | `row(**values) -> JsonObject`; `stable_id(prefix: str, value: JsonValue) -> str` (`prefix-<sha256 of canonical_json>`) | yes | Import for `pin_id` and receipt `id`. Importing it loads `analyzer/__init__.py`, which imports `analyzer.registry` (pure imports, no I/O). |
| `revision_rules.is_full_revision` | `(value: JsonValue) -> bool` (literal 40- or 64-hex lowercase) | yes | Import for `--revision` and pin `revision` checks. |
| `revision_rules.validate_revisions`, `RevisionInputs` | `(snapshot: DiscoverySnapshot, *, index=None) -> RevisionValidation` | yes, but typed on `DiscoverySnapshot` | Do not import; imitate. |
| `evidence_rules.assess_evidence`, `validate_evidence`, `EvidenceAssessment` | `(inputs: RevisionInputs, record: ArtifactRecord)`; `(snapshot: DiscoverySnapshot, *, index=None)` | yes, but typed on discovery records | Do not import; imitate. |
| `schema_validation.is_rfc3339_timestamp` | `(value: object) -> bool` | yes | Optional import (schema `date-time` already uses `discovery_format_checker`). |
| `coverage_rules.validate_coverage` | `(snapshot: DiscoverySnapshot, *, complete=False, index=None, evidence=None, claims=None) -> CoverageValidation` | yes | Do not import; imitate. |
| `parity_rules.validate_parity` | `(snapshot: DiscoverySnapshot, *, complete=False, ...)` | yes | Do not import; imitate. |
| `mutation_io.commit_mutation`, `GuardedMutationWriter`, `MutationWriter`, `MutationPrimitives`, `MutationArtifact`, `MutationResult` | `commit_mutation(plan: MutationPlan, *, writer: MutationWriter, dry_run=False) -> MutationResult` | core is pure over injected protocols | Do not import; imitate. |
| `mutation_filesystem.LocalMutationPrimitives` | `(*, workspace_root, lock_path, open_directory=None, lock=None, metadata=None, nonce=None, document_bytes=...)` | no (native I/O) | Do not import. |
| `cli.CliPorts`, `cli.run_cli`, `cli._emit`, `cli._write` | `run_cli(command, argv, *, ports, stdout, stderr, limits) -> int` | I/O through ports | Imitate. |

Why the rule modules cannot be imported:

- `revision_rules.RevisionInputs.__post_init__` indexes `snapshot.manifest.files` and
  `snapshot.repository_files`; `validate_revisions` reads `snapshot.profile.repository` and
  dispatches on discovery artifact kinds (`inventory-snapshot`, `coverage-ledger`,
  `parity-matrix`, `source-snapshot-manifest`). A docs snapshot is not a `DiscoverySnapshot`.
- `evidence_rules.assess_evidence` raises `ValueError` unless `record.kind == "evidence-reference"`
  and resolves bytes through `RevisionInputs.content`.
- `coverage_rules` and `parity_rules` depend on `claim_rules.ClaimContext`,
  `coverage_scope_rules.select_coverage_scope`, `references.index_references` and the discovery
  ledger row shape (`component_id`, `components`).
- `mutation_io.GuardedMutationWriter.atomic_write` revalidates through
  `path_policy.PathPolicy(current.snapshot.profile, ...)`, compares `snapshot.sha256`, and
  `commit_mutation` re-plans through `mutation_plan.plan_mutation` and re-validates through
  `validation.validate_snapshot`. `LocalMutationPrimitives` requires an absolute external
  `lock_path` and `path_models.ResolvedPath` targets carrying write grants.

Patterns to imitate (verified):

- Revision semantics (`revision_rules`): pins are literal full revisions only
  (`repository_reader.full_revision`, pattern `(?:[0-9a-f]{40}|[0-9a-f]{64})`); staleness is
  decided by comparing bytes or digests, not revisions (`_selected`: "Documentation-only HEAD
  changes preserve matching pinned source bytes"); `RevisionValidation.remote_freshness` is always
  `"unknown"`, so no rule claims remote freshness.
- Evidence semantics (`evidence_rules`): provenance is separate from claim truth
  (`EvidenceAssessment.locally_verified` versus "Callers still assess observation truth");
  author identity is `{kind: human|agent|tool, id}`; a present revision must be full
  (`EVIDENCE_PIN`); a checksum is compared with the exact captured bytes (`EVIDENCE_CHECKSUM`).
- Coverage accounting (`coverage_rules._CoverageRules.ledger`): exact-once accounting with
  `COVERAGE_DUPLICATE` per repeated row and `COVERAGE_MISSING` when `complete=True` and selected
  items are absent; draft validation (`complete=False`) does not demand completeness.
- Defensive JSON traversal (`coverage_scope_rules.object_rows`, `isinstance` checks) so semantic
  rules still run and name elements when the schema check has also failed.
- Mutation (`mutation_io`): plan, then commit; dry run performs fresh reads and no writes; a new
  file is created exclusively (`create_exclusive`) and an existing file is replaced only when its
  digest equals the planned original digest (`replace_if_digest`, `MUTATION_PRECONDITION`);
  stop at the first failure; report `MutationArtifact` (`path`, `artifact_kind`, `artifact_id`,
  `sha256`, `status` in `planned`/`created`/`updated`/`skipped`/`conflict`) and
  `uncertain_paths`; failures become one `MUTATION_FAILED` finding.
- Native adapter testing without temporary files (`tests/discovery_runtime/test_mutation_filesystem.py`):
  `monkeypatch.setattr(os, "open", ...)`, `os.write`, `os.fsync`, `os.close`, `os.unlink`.
- Glob matching uses `fnmatch.fnmatchcase` (`coverage_scope_rules`, `analyzer/input_capture.py`
  `exclusion_reason`).

### 1.3 Discovery CLI conventions (verified)

- `cli.py`: zero-argument wrappers `main_<command>() -> int` forward to `run_installed_cli`, which
  builds a frozen `CliPorts` and calls `run_cli(command, argv, *, ports, stdout, stderr, limits)`.
  Parsing is the custom bounded parser in `cli_arguments.py` (`parse_cli_arguments`, `CliHelp`,
  `CliError`); #1020 deliberately uses `argparse` for the docs CLI, and 900005 follows #1020.
- Exit codes: `DiscoveryResult.exit_code: Literal[0, 1, 2, 3]` (`service_contracts.py`);
  `_failure` returns 2 (invocation) or 3 (runtime); a top-level `except Exception` with
  `# noqa: BLE001` writes a fixed stderr line and returns 3; `_emit` writes one canonical LF JSON
  document to stdout and, on a non-zero exit, a fixed line to stderr.
- Tests inject in-memory content: `tests/discovery_runtime/cli_test_support.py` (`memory_ports`,
  `invoke` returning `(exit, stdout, stderr)` from `io.StringIO` streams);
  `tests/discovery_runtime/test_cli_errors.py` traps providers with `monkeypatch` and asserts they
  are never called on help or argument errors.
- AST scan precedent: `tests/discovery_runtime/test_package_contract.py`
  (`test_canonical_modules_do_not_import_repository_tooling`) parses source with `ast.parse` and
  walks `ast.ImportFrom`/`ast.Import` nodes; `_public_definitions` walks top-level definitions.
- Enumerated property precedent: the same module uses `itertools.permutations` in
  `pytest.mark.parametrize` (`test_v1_profile_is_invariant_under_mapping_order`).

### 1.4 Root tooling (verified)

- `pyproject.toml` `[tool.poetry.scripts]`: keys are quoted, `"dev.<family>.<command>"`, mapped to
  `module:function`; entries are roughly alphabetical (`dev.collect-commit-context`, then the
  `dev.discovery.*` block, then `dev.fix-all`). #1020 appends its two docs entries after
  `"dev.discovery.doctor"`.
- `[tool.pytest.ini_options]`: `testpaths = ["tests"]`, `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`.
- `[tool.coverage.run]`: `source = ["src", "scripts/dev_tools", "packages/discovery-runtime/src"]`
  today; `omit` excludes tests; #1020 appends `packages/docs-runtime/src`.
- `[tool.ruff.lint]` selects `E, F, I, B, UP, S, TID, TCH`; `tests/**/*` ignores `S101`; `S311`
  is ignored only for four named test files, so `random` in new tests would need another
  `pyproject.toml` edit.
- `quality-tiers.yml`: `packages/discovery-runtime` is `T2` today; `packages/docs-runtime` is not
  present yet (added by #1020).
- `tests/__init__.py` does not exist; `tests/discovery_runtime/` has no `__init__.py`, and it
  already holds `test_coverage_report.py`, `test_parity_models.py` and `test_parity_rules.py`.

## 2. Candidate Approaches

### 2.1 Rule engine: import discovery rules versus docs-native rules

- A. Wrap docs artifacts as a `DiscoverySnapshot` and call `validate_revisions`,
  `validate_evidence`, `validate_coverage`. Rejected: the docs kinds are not in the fixed discovery
  catalog (`catalog.SchemaCatalog.__post_init__` requires the fixed identity set, per #1020
  research), and the rules dispatch on discovery field names.
- B (recommended). Docs-native pure rule modules over parsed `JsonObject` values and #1020
  dataclasses, importing only the generic discovery primitives in section 1.2 and imitating the
  rule semantics. This keeps discovery unchanged (epic non-goal) and avoids importing private
  discovery internals.

### 2.2 Write boundary: reuse discovery mutation adapters versus a docs-owned boundary

- A. Reuse `mutation_io.GuardedMutationWriter` and `mutation_filesystem.LocalMutationPrimitives`.
  Rejected: both require discovery snapshot capture, `PathPolicy`, write grants and an external
  lock path.
- B (recommended). `mutation.py` owns a small plan/commit protocol modelled on `mutation_io`:
  pure planning, an injected `ArtifactStore` protocol with exclusive create and digest-checked
  replace, dry-run by default, and a local adapter in the same module tested through
  monkeypatched `os` functions.

### 2.3 Receipt persistence

- A. `dev.docs.validate` always writes the receipt file. Rejected: it would make
  `validate_docs_artifacts` (900007) a mutating tool, contradicting the 900007 criterion that
  `update_docs_ledger` is the only mutating tool.
- B (recommended). `dev.docs.validate` always prints the receipt in its JSON output and writes the
  receipt file only with `--write-receipt`, through `mutation.py`. 900007 does not expose
  `--write-receipt`; the CI template (900008) uses it. Flagged for epic confirmation (section 9).

## 3. Behavior Semantics

### 3.1 Data model mapping

| Concept | Artifact (planned by #1020) | 900005 module |
|---|---|---|
| Coverage ledger | `docs-coverage-ledger` | `ledger_models.py`, `ledger_rules.py` |
| Parity matrix | `docs-parity-matrix` | `parity_models.py`, `parity_rules.py`, `parity_scoring.py` |
| Evidence pins | `docs-evidence-pin` (one collection) | `evidence_pins.py`, `staleness.py` |
| Receipt | `docs-validation-receipt` | `receipt.py`, `validation.py` |
| Current surface | `surface-inventory-snapshot` | read through `snapshot_view.py` (proposed refinement) |

Gaps against the #1020 schemas (none changes #1020 scope):

1. No snapshot reader in #1020 (section 1.1). Handled in 900005 by a new module
   `snapshot_view.py` that builds `SurfaceElement` values from a validated snapshot `JsonObject`;
   constructing `SurfaceElement` re-checks each `element_id` (planned `__post_init__`), so a
   tampered identifier becomes a finding. File-list refinement within the epic rule.
2. Meaning of element `source_sha256` is not defined by #1020 (whole-file digest or declaration
   digest). The snapshot already carries file digests in `inputs[].sha256`. Epic-level decision
   required, because 900003/900004 populate the field. Recommendation: the SHA-256 of the
   declaration's source span (the bytes of `line_range` lines) when `line_range` is not `null`,
   otherwise the file digest. 900005 treats the value as opaque and compares equality only, so
   its code does not change with the decision; only fixture meaning does.
3. Receipt `id` derivation is not specified. Handled in `receipt.py`:
   `stable_id("docs-validation-receipt", row(mode=..., repository=..., revision=..., inputs=..., validation_result=...))`;
   `issued_at` is excluded so the identity is time-independent (the `stable_id` docstring rule).
4. Page content is not bindable in receipt `inputs` (`artifact-pin.artifact_kind` admits only the
   six docs artifact kinds). The receipt therefore pins profile, snapshot, ledger, matrix and pin
   collection, not the page set. Page existence is still checked (section 3.3). Report-only gap;
   an epic-level decision is needed only if the receipt must bind page bytes.
5. No schema for the CLI JSON output envelope. Handled as a Python-level contract with tests
   (section 3.4); a `docs-command-result` schema would be a #1020-family change and is flagged.
6. The package `pyproject.toml` also declares console scripts (consumer wheel). The epic lists only
   the root `pyproject.toml` for 900005; the three scripts must be appended to both files, and
   `test_package_pyproject_matches_runtime_contract` and
   `test_root_pyproject_registers_docs_console_scripts` (planned by #1020) must tolerate appended
   entries. Planning must read those tests after #1020 merges and record their disposition.

### 3.2 Staleness semantics

- Pin creation (`evidence_pins.pin_from_element`): copies `element.element_id`, `element.kind`
  (to `element_kind`), `element.declaration` (to `symbol`), `element.path` (to `source_path`),
  `element.source_sha256`, and `snapshot.revision` (to `revision`, possibly `null`); `pin_id` is
  `stable_id("pin", row(element_id=..., page_path=..., symbol=...))`, so re-pinning the same
  element and page replaces, not duplicates, the pin.
- Assessment (`staleness.assess_pin`), per pin against the current snapshot elements indexed by
  `element_id`:
  - `element-missing`: no current element has the pin's `element_id`. Because the identifier is
    derived from kind, path and declaration, a rename, move or signature change lands here.
  - `digest-changed`: the element exists and `pin.source_sha256 != element.source_sha256`.
  - `current`: the element exists and digests are equal.
  - Pin self-consistency is checked separately: `element_identifier(kind=pin.element_kind,
    path=pin.source_path, declaration=pin.symbol)` must equal `pin.element_id`
    (`DOCS_PIN_INCONSISTENT`, error).
- A page is stale when at least one pin with that `page_path` is not `current`. `stale_pages`
  returns one record per page (sorted by `page_path`) with the non-current pin ids, element ids and
  reasons.
- Revision handling follows `revision_rules`: a non-null pin `revision` must satisfy
  `is_full_revision` (also enforced by the schema pattern); a revision difference alone never marks
  a page stale; staleness is digest-based only, and no remote freshness is inferred.
- Provenance is separate from accuracy (imitating `evidence_rules`): a `current` pin proves only
  that the pinned declaration bytes are unchanged; whether the prose is correct is the matrix
  `accurate` dimension, judged by the reviewer role (epic non-goal on prose correctness).

### 3.3 Validation modes

`validation.validate(inputs, *, mode, revision, issued_at, resources=None) -> ValidationOutcome`
(`receipt: JsonObject`, `findings: tuple[Finding, ...]`, `ok: bool`). Every mode emits a receipt.
Each mode includes the checks of the modes listed before it in its row.

| Mode | Inputs read | Checks |
|---|---|---|
| `profile` | profile | `profile.parse_profile` findings (planned by #1020). |
| `ledger` | profile, snapshot, ledger | `profile`; schema validation of snapshot and ledger (`validate_artifact`); snapshot elements rebuild (`snapshot_view`); `ledger_rules` (completeness, companions, duplicates, orphans, kind agreement, snapshot reference). |
| `matrix` | + matrix, pin collection, set of existing page paths | `ledger`; schema validation of matrix and pins; `parity_rules`; pin consistency; staleness reported as warnings. |
| `docs-complete` | same as `matrix` | `matrix`; gate evaluation from `completion_gates.docs_complete`; staleness severity per `max_stale_pages`; revision binding. |

Finding codes (all `DOCS_` prefixed except reused codes; severity in parentheses):

| Code | Raised by | Condition |
|---|---|---|
| `SCHEMA_INVALID` (error) | `validate_artifact` (#1020) | schema violation. |
| `DOCS_INPUT_UNREADABLE` (error) | `validation` | an artifact path from the profile is absent from the inputs. |
| `DOCS_SNAPSHOT_ELEMENT_INVALID` (error) | `snapshot_view` | `SurfaceElement` construction fails (identifier mismatch, parent rule, line range). |
| `DOCS_LEDGER_MISSING_DISPOSITION` (error) | `ledger_rules` | an inventoried element has no entry; message names kind, declaration and element id; `related_ids` holds the element id, `related_paths` its path. |
| `DOCS_LEDGER_DUPLICATE_ENTRY` (error) | `ledger_rules` | two entries for one element id. |
| `DOCS_LEDGER_ORPHAN_ENTRY` (error) | `ledger_rules` | an entry names an element absent from the snapshot. |
| `DOCS_LEDGER_KIND_MISMATCH` (error) | `ledger_rules` | entry `kind` differs from the element kind. |
| `DOCS_LEDGER_BINDING_REQUIRED` (error) | `ledger_rules` | `documented` with no page binding. |
| `DOCS_LEDGER_RATIONALE_REQUIRED` (error) | `ledger_rules` | `excluded` without rationale text. |
| `DOCS_LEDGER_OWNER_REQUIRED`, `DOCS_LEDGER_TARGET_REQUIRED` (error) | `ledger_rules` | `deferred` without owner or target. |
| `DOCS_LEDGER_SNAPSHOT_REF` (warning) | `ledger_rules` | `snapshot_ref.sha256` differs from the current snapshot bytes digest. |
| `DOCS_MATRIX_LEDGER_REF` (warning) | `parity_rules` | `ledger_ref.sha256` differs from the current ledger digest. |
| `DOCS_MATRIX_UNBOUND_ROW` (error) | `parity_rules` | a row whose element is not `documented` with a binding to `page_path`. |
| `DOCS_MATRIX_ROW_MISSING` (error) | `parity_rules` | a documented binding has no row. |
| `DOCS_MATRIX_DUPLICATE_ROW` (error) | `parity_rules` | two rows for one element and page. |
| `DOCS_MATRIX_PIN_UNKNOWN` (error) | `parity_rules` | `evidence_pin_ids` names an absent pin or a pin for another element or page. |
| `DOCS_MATRIX_ACCURACY_UNPINNED` (error) | `parity_rules` | `accurate` is `pass` with no evidence pin. |
| `DOCS_MATRIX_EXISTS_INCONSISTENT` (error) | `parity_rules` | `exists` is `pass` but the page path is not in the page set. |
| `DOCS_MATRIX_OWNER_INCONSISTENT` (error) | `parity_rules` | `owner_assigned` is `pass` but no `page_owners` entry matches (`fnmatch.fnmatchcase`). |
| `DOCS_PIN_INCONSISTENT` (error) | `evidence_pins` | pin identity fields do not reproduce `element_id`, or `pin_id` differs from its derivation. |
| `DOCS_PAGE_STALE` (warning in `matrix`; in `docs-complete` error when the stale-page count exceeds `max_stale_pages`, otherwise warning) | `staleness` | one finding per stale page; message names the page and each non-current element. |
| `DOCS_PAGE_MISSING` (error, `docs-complete`) | `validation` | a bound page path is not in the page set. |
| `DOCS_DEFERRED_NOT_ALLOWED` (error, `docs-complete`) | `validation` | a `deferred` entry while `allow_deferred` is false. |
| `DOCS_PARITY_REQUIRED_DIMENSION` (error, `docs-complete`) | `validation` | a required dimension is `fail` or `not-assessed` for a documented binding (`pass` and `not-applicable` satisfy it). |
| `DOCS_REVISION_MISMATCH` (error) | `validation` | snapshot `revision` is non-null and differs from `--revision`. |
| `DOCS_SNAPSHOT_UNPINNED` (error, `docs-complete`) | `validation` | snapshot `revision` is `null` (working copy); fail closed so a receipt never claims a revision its snapshot did not capture. Flagged for epic confirmation. |

Receipt contents (`receipt.build_receipt`):

- `mode`; `repository` (profile `repository.id`); `revision` (the validated `--revision`).
- `inputs`: one `artifact-pin` per artifact read, `sha256` from `ParsedDocument.source_sha256`
  (raw bytes), sorted by `artifact_kind` then `path`.
- `counts`: `elements_total` (snapshot elements), `undocumented` (elements without a ledger entry),
  `stale_pages`, `by_disposition` (entries matching current elements), `by_kind` (snapshot
  elements). In `profile` mode every count is 0 and every key is present.
- `validation_result`: `fail` when any `error` finding exists, otherwise `pass`, satisfying the
  schema binding; `findings` are `Finding.to_dict()` values ordered by `finding_key` and
  deduplicated (the schema requires `uniqueItems`).
- `issued_at` from an injected clock; `writer` `{tool: "drm-copilot-docs", version: drm_copilot_docs.__version__}`.
- The built receipt is validated with `validate_artifact(artifact_kind="docs-validation-receipt")`
  before it is returned; a failure is a defect guard (exit 3).

Downstream consumption: 900007 parses the JSON output (exit code, findings, receipt). 900008 reads
the file at `artifact_paths.validation_receipt` and allows a merge only when `mode` is
`docs-complete`, `validation_result` is `pass`, and `revision` equals the head revision.

### 3.4 CLI contracts

Shared conventions (following #1020 `cli.py` and discovery `cli.py`):

- Wrappers `main_coverage`, `main_update_ledger`, `main_validate` (zero arguments, return `int`)
  delegate to `run_coverage_cli`, `run_ledger_cli`, `run_validate_cli`, each
  `(argv: Sequence[str], *, ports: DocsCliPorts, stdout: TextIO, stderr: TextIO) -> int`.
- `argparse`; `SystemExit` caught; a top-level `except Exception  # noqa: BLE001` writes a fixed
  stderr line and returns 3.
- Common options: `--profile <relative path>` (default `docs/documentation-estate/docs-profile.json`,
  the #1020 default) and `--format text|json` (default `text`, matching `dev.docs.validate-profile`).
  900007 passes `--format json`.
- Exit codes: 0 success or help; 1 validation failure (any `error` finding); 2 invocation error
  (unknown flag, missing value, invalid identifier, path not POSIX-relative, invalid `--revision`);
  3 runtime or output failure (unreadable input, resource failure, write conflict, defect guard).
- JSON output: one canonical LF document (`canonical_json`) on stdout:
  `{"command": "<dev.docs.*>", "ok": bool, "exit_code": int, "findings": [...], "result": {...}}`.
  On exit 2 or 3, `result` is `null` and `findings` holds one fixed finding (`DOCS_CLI_ARGUMENTS`
  or `DOCS_CLI_RUNTIME`), imitating discovery `_failure`. Text output prints one line per finding
  (`<severity> <code> <artifact_path><pointer>: <message>`) and a summary line.

`dev.docs.coverage` (`cli_coverage.py`, read-only):

- Arguments: `--profile`, `--format`.
- Reads profile, snapshot, ledger, matrix and pins (paths from `artifact_paths`) and the page-path
  set; builds `coverage_report.build_coverage_report(...)`.
- `result`: `{"totals": counts as in the receipt, "undocumented": [{element_id, kind, declaration, path}], "deferred": [{element_id, owner, target}], "stale_pages": [{page_path, element_ids, reasons}], "parity": {<dimension>: {pass, fail, not_assessed, not_applicable, score_basis_points}}}`.
- Exit 0 when the report is built (gaps are reported, not failed); 1 when an input fails schema
  validation so no report can be built; 2; 3.

`dev.docs.update-ledger` (`cli_ledger.py`, the only mutating ledger command):

- `--operation` one of `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`,
  `sync-refs`; `--element <element-id>`; `--disposition documented|excluded|deferred`;
  `--page <relative path>[#anchor]` (repeatable for `documented`); `--rationale`, `--owner`,
  `--target`; `--dimension <name>`, `--state <parity-state>`; `--claim`; `--actor-kind
  human|agent|tool` and `--actor-id <identifier>` (required for every operation; written to
  `updated_by` or `pinned_by`); `--write` (without it the command plans and prints the writes and
  changes nothing, matching discovery `--write` and 900006).
- Every operation produces the full new document, which is validated against its schema and the
  ledger or matrix rules before planning; an operation that would introduce an `error` finding
  exits 1 and writes nothing.
- `sync-refs` re-pins `snapshot_ref` and `ledger_ref` to the current bytes digests.
- `result`: `{"dry_run": bool, "writes": [{"path", "artifact_kind", "artifact_id", "sha256", "status"}]}`
  with status `planned`, `created`, `updated`, `skipped` or `conflict` (the `MutationArtifact`
  vocabulary).
- Writes the ledger, matrix and pin collection through `mutation.py` only. The 900007 tool
  `update_docs_ledger` maps onto this command; ledger, matrix and pin edits all route here, which
  keeps 900007's "only mutating tool" criterion satisfiable.

`dev.docs.validate` (`cli_validate.py`):

- `--mode profile|ledger|matrix|docs-complete` (required), `--revision <full revision>` (required;
  checked with `is_full_revision`), `--profile`, `--format`, `--write-receipt`.
- `result`: the receipt document. Emitted on pass and on fail; exit 0 on `pass`, 1 on `fail`.
- With `--write-receipt` the receipt is written to `artifact_paths.validation_receipt` through
  `mutation.py` (create or digest-checked replace).

`DocsCliPorts` (frozen, `kw_only`): `read_bytes: Callable[[str], bytes]` (raises
`FileNotFoundError`), `list_pages: Callable[[Sequence[str]], tuple[str, ...]]` (documentation roots
to existing relative page paths), `store: ArtifactStore`, `clock: Callable[[], datetime]`. If the
#1020 `ports` type for `cli.py` already provides a reader, planning reuses it rather than defining
a parallel one; its name is not stated in the #1020 spec.

## 4. Requirements Mapping

### 4.1 Proposed modules (all under `packages/docs-runtime/src/drm_copilot_docs/`)

| Module | Public symbols (proposed) | Pure | Estimated lines |
|---|---|---|---|
| `snapshot_view.py` (refinement) | `SnapshotView` (frozen: `repository`, `revision`, `elements` by id, `sha256`), `snapshot_view(value: JsonObject, *, artifact_path: str, source_sha256: str) -> tuple[SnapshotView \| None, tuple[Finding, ...]]` | yes | 120 |
| `ledger_models.py` | `PageBinding`, `Actor`, `ArtifactPinRef`, `LedgerEntry`, `CoverageLedger`, `ledger_from_json`, `ledger_to_json` (entries sorted by `element_id`) | yes | 200 |
| `ledger_rules.py` | `validate_ledger(value: JsonObject, *, snapshot: SnapshotView, artifact_path: str) -> tuple[Finding, ...]`, `apply_disposition(...)`, `remove_entry(...)` | yes | 300 |
| `parity_models.py` | `PARITY_DIMENSIONS`, `DimensionResult`, `ParityRow`, `ParityMatrix`, `matrix_from_json`, `matrix_to_json` | yes | 180 |
| `parity_rules.py` | `validate_matrix(value, *, ledger, pins, snapshot, page_paths, page_owners, artifact_path) -> tuple[Finding, ...]`, `set_dimension(...)` | yes | 320 |
| `parity_scoring.py` | `DimensionScore`, `score_matrix(matrix: ParityMatrix) -> tuple[DimensionScore, ...]` (integer counts and basis points; no floats) | yes | 90 |
| `evidence_pins.py` | `EvidencePin`, `PinCollection`, `pin_identifier`, `pin_from_element`, `pins_from_json`, `pins_to_json`, `validate_pins(...)` | yes | 220 |
| `staleness.py` | `PinStatus`, `PinAssessment`, `StalePage`, `assess_pin`, `stale_pages` | yes | 140 |
| `receipt.py` | `receipt_identifier`, `receipt_counts`, `build_receipt` | yes | 160 |
| `validation.py` | `ValidationMode`, `ValidationInputs` (raw bytes per artifact plus page paths), `ValidationOutcome`, `validate` | yes (with `resources` supplied) | 350 |
| `coverage_report.py` | `build_coverage_report`, `render_coverage_text` | yes | 200 |
| `mutation.py` | `ArtifactStore` (Protocol: `read`, `create_exclusive`, `replace_if_digest`), `PlannedArtifactWrite`, `ArtifactWriteResult`, `MutationOutcome`, `plan_artifact_writes`, `commit_artifact_writes(plans, *, store, dry_run=True)`, `LocalArtifactStore` (`os.open` with `O_EXCL`; staged replace with `os.replace` after a digest check) | core pure; adapter is I/O | 300 |
| `cli_support.py` (refinement) | `DocsCliPorts`, `emit_result`, `load_inputs`, shared argparse helpers, exit-code constants | I/O through ports | 220 |
| `cli_coverage.py`, `cli_ledger.py`, `cli_validate.py` | wrappers and `run_*_cli` | I/O through ports | 120, 300, 150 |

`cli_support.py` and `snapshot_view.py` are file-list refinements (the epic permits refining file
names, not the naming contract). They avoid triplicated port and parsing code and fill gap 1.

### 4.2 Required file changes

Create: the modules above. Edit (append only): root `pyproject.toml` `[tool.poetry.scripts]`
with `"dev.docs.coverage" = "drm_copilot_docs.cli_coverage:main_coverage"`,
`"dev.docs.update-ledger" = "drm_copilot_docs.cli_ledger:main_update_ledger"`,
`"dev.docs.validate" = "drm_copilot_docs.cli_validate:main_validate"` after the #1020 docs entries;
the same three entries in `packages/docs-runtime/pyproject.toml` (gap 6). No edit to
`[tool.coverage.run]`, `[tool.pyright]`, `quality-tiers.yml`, `poetry.lock` (no new dependency;
only stdlib `hashlib`, `os`, `fnmatch`, `argparse`, `datetime` plus `drm_copilot_discovery` and
`drm_copilot_docs`), any schema, or any discovery file.

### 4.3 Single write boundary and its proof

- Enforcement design: only `mutation.py` contains filesystem write calls; `cli_ledger.py` and
  `cli_validate.py` call `commit_artifact_writes`; `ledger_rules.py`, `parity_rules.py` and
  `evidence_pins.py` return new documents and never write.
- Test `tests/docs_runtime/test_write_boundary.py` (AST scan, read-only, following
  `test_canonical_modules_do_not_import_repository_tooling`):
  1. For every `.py` file under `packages/docs-runtime/src/drm_copilot_docs/` (recursive,
     excluding `__pycache__`), parse with `ast.parse` and collect write primitives: calls to
     `open`/`os.open`/`io.open` whose mode or flags are not read-only, attribute calls named
     `write_bytes`, `write_text`, `replace`, `rename`, `unlink`, `mkdir`, `os.write`, and any
     `shutil` call. Assert the set of modules containing them is a subset of an explicit allowlist:
     `mutation.py`, plus `cli.py` (the #1020 `dev.docs.init --output` port) and
     `reference/writer.py` (900006) if present. The allowlist is a module-level tuple with one
     reason per entry.
  2. Assert that `commit_artifact_writes` and `LocalArtifactStore` are referenced only from
     `cli_ledger.py` and `cli_validate.py`.
  3. Assert that the ledger and matrix artifact kinds are written only by `cli_ledger.py`: in
     `cli_validate.py` and `cli_coverage.py` the AST contains no reference to `ledger_to_json`,
     `matrix_to_json` or `pins_to_json`, and `cli_validate.py` plans only the
     `docs-validation-receipt` kind (behavioral test with a recording `ArtifactStore`).
  4. A positive control: the scan helper applied to an in-memory source string containing
     `Path(p).write_text(x)` reports it, so the scan cannot pass vacuously.
- Behavioral complement: CLI tests use a recording in-memory `ArtifactStore`; `dev.docs.coverage`
  and `dev.docs.validate` without `--write-receipt` record zero calls; `dev.docs.update-ledger`
  without `--write` records zero calls.

## 5. Testing Implications

Test modules (`tests/docs_runtime/`, which #1020 makes a package): `test_snapshot_view.py`,
`test_ledger_models.py`, `test_ledger_rules.py`, `test_docs_parity_models.py`,
`test_docs_parity_rules.py`, `test_parity_scoring.py`, `test_evidence_pins.py`,
`test_staleness.py`, `test_receipt.py`, `test_validation.py`, `test_mutation.py`,
`test_docs_coverage_report.py`, `test_cli_support.py`, `test_cli_coverage.py`,
`test_cli_ledger.py`, `test_cli_validate.py`, `test_ledger_properties.py` (ledger and staleness
properties), `test_write_boundary.py`, `test_docs_complete_integration.py`. The `docs_` prefix is
applied to the three basenames that exist in `tests/discovery_runtime/`, following the #1020
precedent.

- Isolation: pure cores take `Mapping[str, bytes]` and `JsonObject` values; CLI tests use
  `io.StringIO` streams, a dictionary-backed `read_bytes`, a fixed `list_pages`, a recording
  `ArtifactStore`, and a fixed clock. `LocalArtifactStore` is tested by monkeypatching `os.open`,
  `os.write`, `os.fsync`, `os.close`, `os.replace` and `os.unlink`, as
  `tests/discovery_runtime/test_mutation_filesystem.py` does. No temporary files.
- Schema resources: tests pass `resources=` built from the canonical schema bytes (read-only reads
  of `schemas/docs/v1/` and `schemas/discovery/v2/common.schema.json`, as #1020's tests do), so no
  installed-resource dependency.
- Property tests (T2: at least one per pure function), using `itertools` only (no `random`, which
  would need an `S311` ignore; no `hypothesis`):
  - Ledger completeness: for every subset of a fixed six-element snapshot (`itertools.combinations`
    over all sizes), the missing-disposition findings name exactly the complement.
  - Disposition companions: `itertools.product` over the three dispositions and the presence of
    bindings, rationale, owner and target; the finding set equals the companion table.
  - Order invariance: `itertools.permutations` of ledger entries, matrix rows and pins yield
    byte-identical `canonical_json` output and identical findings.
  - Staleness: product of {element present, absent} and {digest equal, different} gives exactly
    `current`, `digest-changed`, `element-missing`; a page is stale exactly when any of its pins is
    not current.
  - Pin and receipt identity: determinism and injectivity over enumerated inputs; receipt identity
    is independent of `issued_at`.
  - Scoring: counts per dimension sum to the row count for every enumerated state assignment.
- Integration (`test_docs_complete_integration.py`): an in-memory fixture with one undocumented
  element and one stale page runs `run_validate_cli` with `--mode docs-complete --format json`;
  asserts exit 1, a `fail` receipt that validates against the schema, and findings naming the
  element declaration and the page path; after adding the ledger entry and re-pinning, exit 0 and a
  `pass` receipt.
- Coverage: `--cov=drm_copilot_docs --cov-branch --cov-report=json:<path>` (dotted package form);
  per-file line and branch figures read from the JSON report for each new module.
- Isolation evidence: a reversed-order single-process run of the new test modules (no TypeScript or
  PowerShell is touched, so the Jest and Pester shuffles are not applicable).

## Numeric Derivation Evidence

- Numeric spec.md acceptance criterion: the root `pyproject.toml` gains 3 console scripts for this feature (epic `Files (edit): pyproject.toml (three scripts)`).

Console commands owned by 900005:

- Complete Family: dev.docs.coverage, dev.docs.update-ledger, dev.docs.validate
- Exhaustive Search Scope: entire worktree, all of the epic manifest naming contract and feature sections, this feature's issue.md and spec.md, and the whole repository tree for existing dev.docs entries
- Inclusion Rules: console commands the epic naming contract assigns to 900005
- Exclusion Rules: dev.docs.init and dev.docs.validate-profile (1020), dev.docs.check (900002), dev.docs.inventory (900003), dev.docs.generate-reference (900006), dev.docs.surface-delta (900008)
- Primary Search Strategy or Query Expression: read the epic `### Naming contract (fixed for all children)` Console commands bullet, which assigns dev.docs.coverage, dev.docs.update-ledger, dev.docs.validate to 900005
- Primary Member Set: dev.docs.coverage, dev.docs.update-ledger, dev.docs.validate
- Primary Count: 3
- Cross-check Search Strategy or Query Expression: read the issue.md `## Proposed Behavior` paragraph pairing dev.docs.coverage with cli_coverage.py, dev.docs.update-ledger with cli_ledger.py and dev.docs.validate with cli_validate.py, plus a Grep for `dev\.docs\.` in pyproject.toml returning no existing entry
- Cross-check Member Set: dev.docs.coverage, dev.docs.update-ledger, dev.docs.validate
- Cross-check Count: 3
- Member-set Comparison: the normalized primary and cross-check member sets are equal

Validation modes (supporting enumeration, not an acceptance count): primary source the epic 900005
`Files (create)` entry for `validation.py` (`profile`, `ledger`, `matrix`, `docs-complete`);
cross-check the #1020 spec receipt `mode` enum (`profile`, `ledger`, `matrix`, `docs-complete`);
4 members each, sets equal. Dispositions (3) and parity dimensions (5) were compared between the
epic naming contract and the #1020 `common` definitions; sets equal.

## 6. Risks

- Dependency on unexecuted #1020: symbol, field or path names may change during #1020 execution or
  review. Mitigation: execution waits until #1020 merges; the first plan task re-reads the merged
  `surface_models.py`, `profile_models.py`, `schema_validation.py`, `cli.py`, the six docs schemas
  and `tests/docs_runtime/test_docs_package_contract.py`, and records any renamed symbol in the plan
  before code is written. A changed schema field is an epic-level change, not a local divergence.
- Append-only conflicts: `[tool.poetry.scripts]` in both `pyproject.toml` files is appended to by
  900002, 900003, 900006 and 900008 in the same region (after the #1020 docs entries). Conflicts
  are adjacent-line text conflicts resolved in the later child's remediation loop; the contract
  tests assert presence, not position.
- `source_sha256` semantics (gap 2) are decided outside this feature; a whole-file digest would
  make every pin in a file stale on any edit. 900005 code is unaffected, but its fixtures and
  documentation must state the decided meaning.
- Receipt persistence versus 900007 (section 2.3) and the working-copy snapshot rule
  (`DOCS_SNAPSHOT_UNPINNED`) need epic confirmation; both are isolated to `cli_validate.py` and
  `validation.py`.
- Batch budget: about 17 non-test production Python files are created. Direct mode denies the
  fourth (`PYTHON_LARGE_PATH_REQUIRED`); execution needs the `large` route in the item worktree
  that holds the orchestration checkpoint.
- Finding volume: `FindingCollector` defaults to 100 findings; a large estate with many undocumented
  elements truncates with `FINDINGS_LIMIT`. The receipt counts remain exact because they are
  computed separately from findings.

## Pre-Mortem

- **Review checklists**: a reviewer can flag a missing finding name for an element, a receipt that does not validate against its schema, or a CLI that writes without `--write`; the plan must carry the named-element assertions, the schema validation of every emitted receipt, and the zero-call recording-store tests.
- **Coverage**: `LocalArtifactStore` and the three CLI modules could fall below 85% line or 75% branch because they hold I/O; the plan must inject ports, monkeypatch `os` functions for the adapter, measure with `--cov=drm_copilot_docs --cov-branch`, and read per-file branch figures from the JSON report.
- **Mirror parity**: not applicable as a mirror surface, because this feature edits no `.claude`, `.github`, `.codex`, `.agents` or bundled resource file and changes no fact in the execution-environment brief; the one duplicated declaration is the script list in the root and package `pyproject.toml`, which the plan must update together and assert with the #1020 contract tests.
- **File size**: `validation.py`, `parity_rules.py` and `cli_ledger.py` are the largest candidates (estimates 300-350 lines); the plan must keep the module split in section 4.1 and route growth into a new module with its own test file before 500 lines.
- **Test isolation**: basenames shared with `tests/discovery_runtime/` and process-wide schema registry caches could leak; the plan must use the `docs_` prefixes, pass explicit `resources` mappings, create no temporary files, and record a reversed-order single-process run of the new modules under the feature evidence folder.
- **CI-only behavior**: Linux path handling and an out-of-sync `poetry.lock` fail only in CI; the plan must use POSIX relative paths without drive letters in fixtures, add no dependency (so `poetry.lock` is unchanged), and run `poetry check --lock` after the `pyproject.toml` append.
- **Evidence**: gate artifacts written outside `<FEATURE>/evidence/<kind>/` or with plan-time stamps are rejected; the plan must write baseline, QA-gate and regression evidence under the canonical folders with write-time UTC stamps and record `SCRATCH` instead of host paths.

## Automation Feasibility

No human interaction is expected. Evidence: every input is a repository file read through injected
ports; every command is non-interactive (`argparse`, no prompts; discovery `cli.py` likewise has no
interactive path); `--revision` is supplied by the caller rather than read interactively; the
toolchain (Black, Ruff, Pyright, pytest with coverage) runs through Poetry, which the executor can
invoke (execution-environment brief, `## Tool Routes by Agent`). The open decisions in section 9
are owner or epic decisions that can be resolved before execution; they do not require interaction
during execution. Confirming merged #1020 names needs only file reads.

## 7. Rejected Alternatives (summary)

- Importing discovery `revision_rules`, `evidence_rules`, `coverage_rules`, `parity_rules` or
  `mutation_io` rule entry points: typed on discovery snapshots and records (section 1.2).
- Always writing the receipt from `dev.docs.validate`: conflicts with the 900007 mutating-tool
  criterion.
- Subcommand-style `dev.docs.update-ledger <operation>`: equivalent; a single `--operation` option
  was chosen for a flat argument grammar that 900007 can map from structured input.

## 8. Cited Paths and Symbols

| Path or symbol | Status |
|---|---|
| `docs/features/epics/documentation-estate-tooling/epic.md` | verified-in-tree |
| `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/issue.md`, `spec.md` | verified-in-tree |
| `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md`, `plan.2026-10-30T16-08.md`, `research/2026-10-30T20-30-docs-profile-and-artifact-schemas-research.md` | verified-in-tree |
| `.claude/skills/execution-environment/SKILL.md` | verified-in-tree |
| `.claude/hooks/validate-task-researcher-output.ps1` (`Test-IsValidResearchFileName`, `Test-NumericDerivationEvidence`) | verified-in-tree |
| `drm_copilot_discovery.findings`: `Finding`, `Finding.to_dict`, `FindingCollector`, `ordered_findings`, `finding_key`, `child_pointer`, `validate_finding_path`, `MAX_FINDINGS` | verified-in-tree |
| `drm_copilot_discovery.models`: `JsonObject`, `JsonValue`, `canonical_json`, `to_plain_value`, `ParseLimits`, `ParsedDocument` | verified-in-tree |
| `drm_copilot_discovery.parsing.parse_document` | verified-in-tree |
| `drm_copilot_discovery.analyzer.findings`: `row`, `stable_id`, `diagnostic`, `source_reference`, `seed_component` | verified-in-tree |
| `drm_copilot_discovery.analyzer.__init__` (imports `analyzer.registry`) | verified-in-tree |
| `drm_copilot_discovery.revision_rules`: `is_full_revision`, `RevisionInputs`, `RevisionValidation`, `validate_revisions`, `_selected` | verified-in-tree |
| `drm_copilot_discovery.repository_reader.full_revision` | verified-in-tree |
| `drm_copilot_discovery.evidence_rules`: `EvidenceAssessment`, `EvidenceValidation`, `assess_evidence`, `validate_evidence` | verified-in-tree |
| `drm_copilot_discovery.schema_validation`: `discovery_format_checker`, `is_rfc3339_timestamp`, `validate_document` | verified-in-tree |
| `drm_copilot_discovery.coverage_rules`: `CoverageValidation`, `_CoverageRules.ledger`, `validate_coverage` | verified-in-tree |
| `drm_copilot_discovery.coverage_scope_rules`: `object_rows`, `select_coverage_scope`, `fnmatchcase` use | verified-in-tree |
| `drm_copilot_discovery.parity_rules.validate_parity`; `parity_models.py` | verified-in-tree |
| `drm_copilot_discovery.mutation_io`: `capture_workspace`, `MutationWriter`, `MutationPrimitives`, `GuardedMutationWriter`, `MutationArtifact`, `MutationResult`, `commit_mutation` | verified-in-tree |
| `drm_copilot_discovery.mutation_filesystem.LocalMutationPrimitives`; `mutation_plan.py`; `validation.py` | verified-in-tree |
| `drm_copilot_discovery.analyzer.input_capture.exclusion_reason` | verified-in-tree |
| `drm_copilot_discovery.cli`: `CliPorts`, `run_cli`, `run_installed_cli`, `_failure`, `_emit`, `_write`, `main_*` | verified-in-tree |
| `drm_copilot_discovery.cli_arguments`: `parse_cli_arguments`, `CliHelp`, `CliError` | verified-in-tree |
| `drm_copilot_discovery.service_contracts`: `DiscoveryResult.exit_code`, `ServiceRuntimeError` | verified-in-tree |
| `schemas/discovery/v2/validation-receipt.schema.json`, `evidence-reference.schema.json`, `common.schema.json` (`identifier`, `revision`, `sha256`, `path-or-glob`, `validation-outcome`) | verified-in-tree |
| `tests/discovery_runtime/cli_test_support.py` (`memory_ports`, `invoke`), `test_cli_errors.py`, `test_package_contract.py`, `test_mutation_filesystem.py` | verified-in-tree |
| `tests/discovery_runtime/test_coverage_report.py`, `test_parity_models.py`, `test_parity_rules.py` | verified-in-tree |
| Root `pyproject.toml` (`[tool.poetry.scripts]`, `[tool.pytest.ini_options]`, `[tool.coverage.run]`, `[tool.ruff.lint.per-file-ignores]`, `[tool.pyright]`) | verified-in-tree |
| `quality-tiers.yml` (`packages/discovery-runtime` T2) | verified-in-tree |
| `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`, `scripts/dev_tools/check_python_coverage_thresholds.py`, `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`, `config/file-size-baseline.json` | verified-in-tree |
| `tests/__init__.py`, `tests/discovery_runtime/__init__.py` | not-found (absence confirmed) |
| `packages/docs-runtime/` and `pyproject.toml`, `resource-manifest.json`, `drm_copilot_docs/__init__.py` (`__version__`) | planned-by-1020 |
| `drm_copilot_docs.surface_models`: `ElementKind`, `ELEMENT_KINDS`, `element_identifier`, `SurfaceElement`, `SurfaceDiagnostic`, `element_to_json` | planned-by-1020 |
| `drm_copilot_docs.profile_models`: `DocsProfile`, `CompletionGates`, `DocsCompleteGate`, `IntegrationPrGate`, `ArtifactPaths`, `PageOwner` | planned-by-1020 |
| `drm_copilot_docs.profile`: `parse_profile`, `ProfileLoadResult` | planned-by-1020 |
| `drm_copilot_docs.schema_validation`: `DOCS_SCHEMA_NAMES`, `docs_schema_id`, `build_registry`, `validate_artifact` | planned-by-1020 |
| `drm_copilot_docs.cli`: `run_cli`, `main_init`, `main_validate_profile` | planned-by-1020 |
| `schemas/docs/v1/common.schema.json`, `docs-coverage-ledger`, `docs-parity-matrix`, `docs-evidence-pin`, `docs-validation-receipt`, `surface-inventory-snapshot`, `docs-profile` schemas | planned-by-1020 |
| `tests/docs_runtime/__init__.py`, `test_docs_package_contract.py` (`test_root_pyproject_registers_docs_console_scripts`, `test_package_pyproject_matches_runtime_contract`), `test_neutrality.py` | planned-by-1020 |
| `drm_copilot_docs` snapshot reader or `element_from_json` | not-found (not planned by #1020; gap 1) |

## 9. Items for the Orchestrator or Owner to Confirm

- Epic-level: meaning of snapshot element `source_sha256` (declaration span digest recommended).
- Epic-level: receipt persistence through `dev.docs.validate --write-receipt`, not exposed by the
  900007 MCP tool.
- Epic-level: `docs-complete` fails on a working-copy snapshot (`revision: null`).
- Planning: whether a CLI result-envelope schema is wanted (currently a Python-level contract).
- After #1020 merges: the exact names of the #1020 CLI port type and of the two contract tests
  that read the script tables, and whether those tests assert presence or exact sets.
