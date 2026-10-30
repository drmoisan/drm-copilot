# docs-coverage-ledger-and-receipt — Spec

- **Issue:** #1023
- **Parent (optional):** #1019 (epic documentation-estate-tooling, child 900005, wave 1, band C4)
- **Depends on:** #1020 (docs-profile-and-artifact-schemas; planned, not executed)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2
- **Research:** `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/research/2026-10-30T20-59-docs-coverage-ledger-and-receipt-research.md`

## Overview

A destination repository can inventory its documentable surface, but nothing records whether each
surface element is documented, nothing binds elements to pages, and nothing detects that a page
describes code that has since changed. In one consumer repository a feature epic changed 138 `src/`
files while only 4 of 79 documentation pages were edited, and the gap was measured by hand.

This feature is the correspondence core of the documentation-estate epic: the coverage ledger, the
parity matrix, evidence pins with staleness detection, and the `docs-complete` validation receipt.
Two later features depend on its command contracts: 900007 wraps the three commands in MCP tools,
and 900008 consumes the persisted receipt in a CI workflow and an opt-in hook. The command
contracts, the receipt contents and the write boundary below are therefore normative for those
features.

The naming contract in the epic `## Shared Design` section and the schemas, models and CLI planned
by #1020 are consumed as written. This specification cites #1020 contracts by file and symbol and
does not re-specify or re-create them.

## Behavior

Add to `packages/docs-runtime/src/drm_copilot_docs/`:

- Ledger models and rules (`ledger_models.py`, `ledger_rules.py`): completeness, disposition
  companions, duplicates, orphans, kind agreement and snapshot reference checks over a
  `docs-coverage-ledger` document.
- The parity matrix (`parity_models.py`, `parity_rules.py`, `parity_scoring.py`): row binding,
  evidence references, `exists` and `owner_assigned` consistency, and integer per-dimension
  scoring.
- Evidence pins and staleness (`evidence_pins.py`, `staleness.py`): pin creation from a current
  snapshot element, pin self-consistency, and digest-based staleness per pin and per page.
- The receipt (`receipt.py`) and validation (`validation.py`) with modes `profile`, `ledger`,
  `matrix` and `docs-complete`.
- A single write boundary (`mutation.py`) modelled on discovery `mutation_io`.
- A coverage report (`coverage_report.py`).
- Two file-list refinements accepted from research: `snapshot_view.py` (builds `SurfaceElement`
  values from a validated `surface-inventory-snapshot` document; #1020 plans no snapshot reader)
  and `cli_support.py` (shared ports, argument helpers, output envelope and exit-code constants).
- Three console commands: `dev.docs.coverage` (`cli_coverage.py`), `dev.docs.update-ledger`
  (`cli_ledger.py`) and `dev.docs.validate` (`cli_validate.py`).

Ledger dispositions are `documented` (requires at least one page binding), `excluded` (requires a
rationale) and `deferred` (requires an owner and a target). Parity dimensions are `exists`,
`accurate`, `example_present`, `owner_assigned` and `diataxis_mode`.

Pure cores take in-memory inputs (raw bytes keyed by POSIX relative path, parsed `JsonObject`
values and #1020 dataclasses). I/O stays in the thin CLI modules and in the local adapter inside
`mutation.py`. `drm_copilot_discovery` is used as a library: only its generic primitives are
imported (`findings.Finding`, `FindingCollector`, `ordered_findings`, `finding_key`,
`validate_finding_path`; `models.canonical_json`, `JsonObject`, `JsonValue`, `ParsedDocument`;
`parsing.parse_document`; `analyzer.findings.row`, `stable_id`; `revision_rules.is_full_revision`).
Discovery rule modules (`revision_rules.validate_revisions`, `evidence_rules`, `coverage_rules`,
`parity_rules`, `mutation_io`) are imitated, not imported, because they are typed on discovery
snapshots. No discovery file is edited and discovery behavior does not change.

## Inputs / Outputs

- Inputs:
  - The docs profile (default `docs/documentation-estate/docs-profile.json`, the #1020 default),
    loaded with `drm_copilot_docs.profile.parse_profile`. JSON, or YAML when the extension is
    `.yaml` or `.yml`, as #1020 specifies.
  - The artifacts named by the profile `artifact_paths` (`profile_models.ArtifactPaths`):
    `inventory_snapshot`, `coverage_ledger`, `parity_matrix`, `evidence_pins`,
    `validation_receipt`. Artifacts other than the profile are parsed as JSON through
    `drm_copilot_discovery.parsing.parse_document`.
  - The page-path set: every file below each `documentation_roots[*].path` of the profile, as
    sorted POSIX relative paths.
  - `completion_gates.docs_complete` (`profile_models.DocsCompleteGate`) and `page_owners`
    (`profile_models.PageOwner`).
  - CLI arguments listed in `## API / CLI Surface`. No environment variable is read.
- Outputs:
  - Standard output: one result per invocation, in text (default) or JSON (`--format json`).
  - Standard error: one fixed diagnostic line on a non-zero exit; nothing on exit 0.
  - Files, written only through `mutation.py`: the ledger, matrix and pin collection
    (`dev.docs.update-ledger --write`) and the receipt (`dev.docs.validate --write-receipt`).
    Written bytes are `canonical_json` of the document (sorted keys, compact, LF).
- Config keys and defaults: all repository specificity is profile data. No new profile field is
  introduced.
- Versioning: the artifact shapes are the #1020 schemas at `urn:drm-copilot:docs:1.0.0:<name>`.
  The CLI output envelope is a Python-level contract asserted by tests (no schema; see open
  question Q4). With the T2 classification, a breaking change to the envelope, an exit code or a
  receipt field requires an epic-level update.

## API / CLI Surface

### Shared CLI conventions (`cli_support.py`)

- Console-script wrappers `main_coverage`, `main_update_ledger`, `main_validate` take no
  arguments, return `int`, and delegate to `run_coverage_cli`, `run_ledger_cli`,
  `run_validate_cli`, each with signature
  `(argv: Sequence[str], *, ports: DocsCliPorts, stdout: TextIO, stderr: TextIO) -> int`.
- `DocsCliPorts` (frozen, `kw_only`): `read_bytes: Callable[[str], bytes]` (raises
  `FileNotFoundError` for an absent path), `list_pages: Callable[[Sequence[str]], tuple[str, ...]]`
  (documentation roots to existing relative page paths, sorted), `store: ArtifactStore`
  (`mutation.py`), `clock: Callable[[], datetime]` (timezone-aware UTC). If the merged #1020
  `cli.py` port type already provides a reader, `DocsCliPorts` reuses it rather than defining a
  parallel reader. The installed-ports factory in `cli_support.py` is the only place that
  constructs `mutation.LocalArtifactStore`.
- Parsing uses `argparse` (as #1020 `cli.py` does). `SystemExit` raised by parsing is caught and
  never escapes. A top-level `except Exception` (`# noqa: BLE001`) writes a fixed stderr line and
  returns 3.
- Common options on all three commands:

| Option | Required | Values | Default |
|---|---|---|---|
| `--profile <path>` | optional | POSIX relative path (checked with `validate_finding_path`) | `docs/documentation-estate/docs-profile.json` |
| `--format <format>` | optional | `text`, `json` | `text` |
| `-h`, `--help` | optional | flag | absent |

- `--help` prints the `argparse` help text to stdout, reads no input, and exits 0.

### Exit codes (all three commands)

| Code | Meaning |
|---|---|
| `0` | Success or help. `dev.docs.validate`: receipt `validation_result` is `pass`. `dev.docs.update-ledger`: the operation introduced no `error` finding and, with `--write`, every planned write committed. `dev.docs.coverage`: the report was built. |
| `1` | Findings. `dev.docs.validate`: at least one `error` finding (receipt `validation_result` is `fail`), or the profile does not load. `dev.docs.update-ledger`: the operation would introduce an `error` finding; nothing is written. `dev.docs.coverage`: an input is missing or fails schema or snapshot-element validation, so no report can be built. |
| `2` | Usage or input error: unknown option, missing option value, missing required option, value outside an enumeration, an option not permitted for the selected operation, `--profile` or `--page` not a POSIX relative path, `--element` outside the `element-id` grammar, `--actor-id` outside the discovery `identifier` grammar, `--revision` failing `is_full_revision`, a repeated `--page` value. No input file is read. |
| `3` | Internal or I/O error: unreadable profile, a read failure other than an absent artifact, unavailable schema resources, a mutation commit failure (digest precondition conflict or write error), a non-UTC or naive clock value, a built receipt that fails its own schema (defect guard), or any unexpected exception. |

### Output envelope (`--format json`)

Standard output receives exactly one document, `canonical_json` of:

```json
{"command": "<dev.docs.coverage|dev.docs.update-ledger|dev.docs.validate>", "ok": true, "exit_code": 0, "findings": [], "result": {}}
```

- `command`: the console command name.
- `ok`: `true` exactly when `exit_code` is 0.
- `exit_code`: the process exit code (0, 1, 2 or 3).
- `findings`: `Finding.to_dict()` values with keys `code`, `severity` (`error`, `warning`,
  `info`), `artifact_path` (relative path or `null`), `pointer` (RFC 6901), `related_ids`,
  `related_paths`, `message`, `next_action`. Ordered by `drm_copilot_discovery.findings.finding_key`,
  deduplicated, and bounded through `FindingCollector` (default limit 100, with the discovery
  `FINDINGS_LIMIT` marker when truncated). Counts in `result` are computed independently of the
  bound.
- `result`: the command-specific object below, or `null` on exit 2, on exit 3, on
  `dev.docs.coverage` exit 1, and on `dev.docs.validate` exit 1 when the profile does not load.
- On exit 2, `findings` holds exactly one `DOCS_CLI_ARGUMENTS` finding. On exit 3, `findings`
  holds exactly one finding: `DOCS_MUTATION_FAILED` for a commit failure (the conflicting path and
  any paths already written in `related_paths`), otherwise `DOCS_CLI_RUNTIME`.
- Determinism: with identical inputs, arguments and clock value, the stdout bytes are identical
  across runs.

### Text format (`--format text`, default)

- One line per finding, in envelope order:
  `<severity> <code> <artifact_path><pointer>: <message>` (`<artifact_path>` is omitted when
  `null`).
- Command-specific result lines (below), then one summary line:
  `<command>: exit=<exit_code> errors=<n> warnings=<n> infos=<n>`.

### `dev.docs.coverage` (`cli_coverage.py`, read-only)

Arguments: the common options only.

- Reads the profile, `inventory_snapshot`, `coverage_ledger`, `parity_matrix`, `evidence_pins`
  and the page-path set. An absent ledger, matrix or pin collection is treated as an empty
  document (every element undocumented). An absent snapshot yields `DOCS_INPUT_UNREADABLE` and
  exit 1.
- Builds `coverage_report.build_coverage_report(...)`. Semantic rule violations are not reported
  by this command; they are reported by `dev.docs.validate`. On exit 0, `findings` is empty.
- Never calls the `ArtifactStore`.
- `result`:
  - `totals`: the receipt `counts` object (see `### Receipt`).
  - `undocumented`: `[{element_id, kind, declaration, path}]` for elements without a ledger
    entry, sorted by `element_id`.
  - `deferred`: `[{element_id, owner, target}]`, sorted by `element_id`.
  - `stale_pages`: `[{page_path, pins: [{pin_id, element_id, status}]}]`, sorted by `page_path`
    then `pin_id`; `status` is `digest-changed` or `element-missing`.
  - `parity`: one key per parity dimension, each
    `{pass, fail, not_assessed, not_applicable, score_basis_points}`; integer counts;
    `score_basis_points` is `floor(10000 * pass / (pass + fail + not_assessed))`, or `null` when
    that denominator is 0. No floating-point value appears.
- Text result lines (`coverage_report.render_coverage_text`): a totals block, then
  `undocumented <element_id> <kind> <declaration>`, `deferred <element_id> <owner> <target>`,
  `stale <page_path> <pin_id> <status>` and `parity <dimension> <pass>/<fail>/<not_assessed>/<not_applicable> <score>`
  lines, each group in the order of the JSON arrays.

### `dev.docs.update-ledger` (`cli_ledger.py`, the only mutating ledger command)

| Option | Required | Values | Default |
|---|---|---|---|
| `--operation` | required | `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs` | none |
| `--element` | per operation | `element-id` | none |
| `--disposition` | per operation | `documented`, `excluded`, `deferred` | none |
| `--page` | per operation; repeatable only for `set-disposition` | `<relative path>[#<anchor>]` | none |
| `--rationale` | optional where permitted | text | `null` |
| `--owner` | optional where permitted | identifier | `null` |
| `--target` | optional where permitted | text | `null` |
| `--dimension` | per operation | parity dimension | none |
| `--state` | per operation | `pass`, `fail`, `not-assessed`, `not-applicable` | none |
| `--claim` | optional where permitted | text | `null` |
| `--actor-kind` | required | `human`, `agent`, `tool` | none |
| `--actor-id` | required | identifier | none |
| `--write` | optional | flag | absent (dry run) |
| `--profile`, `--format` | optional | as above | as above |

Per-operation argument rules. Any option outside the operation's required and optional sets is a
usage error (exit 2).

| Operation | Required | Optional | Documents it may change |
|---|---|---|---|
| `set-disposition` | `--element`, `--disposition` | `--page` (repeatable), `--rationale`, `--owner`, `--target` | ledger; matrix rows and pins for a removed binding |
| `remove-entry` | `--element` | none | ledger; matrix rows and pins for that element |
| `pin` | `--element`, `--page` (one, no anchor) | `--claim` | pin collection |
| `unpin` | `--element`, `--page` (one, no anchor) | none | pin collection; matrix `evidence_pin_ids` |
| `set-dimension` | `--element`, `--page` (one, no anchor), `--dimension`, `--state` | `--rationale` | matrix |
| `sync-refs` | none | none | ledger `snapshot_ref`; matrix `snapshot_ref` and `ledger_ref` |

Operation semantics:

- `set-disposition` replaces the whole entry for the element: `kind` from the current snapshot
  element, `disposition`, `page_bindings` from `--page` (anchor `null` when absent; sorted by
  `page_path` then `anchor`), `rationale`, `owner`, `target`, and `updated_by`
  `{kind: --actor-kind, id: --actor-id}`. Missing companions are not usage errors; they become
  ledger findings (`DOCS_LEDGER_BINDING_REQUIRED`, `DOCS_LEDGER_RATIONALE_REQUIRED`,
  `DOCS_LEDGER_OWNER_REQUIRED`, `DOCS_LEDGER_TARGET_REQUIRED`) and exit 1. When the new entry drops
  a page binding, matrix rows and pins for that element and page are removed in the same write
  set. An element absent from the snapshot yields `DOCS_LEDGER_ORPHAN_ENTRY` and exit 1.
- `remove-entry` removes the entry and the element's matrix rows and pins.
- `pin` builds a pin with `evidence_pins.pin_from_element` from the current snapshot element:
  `element_id`, `element_kind`, `symbol` (declaration), `source_path`, `source_sha256`, `revision`
  (snapshot revision, possibly `null`), `claim`, `pinned_at` (clock), `pinned_by` (actor). `pin_id`
  is `stable_id("pin", row(element_id=..., page_path=..., symbol=...))`, so re-pinning the same
  element and page replaces the existing pin.
- `unpin` removes the pin for the element and page and removes its id from every matrix
  `evidence_pin_ids`.
- `set-dimension` creates the row for the element and page when absent (other dimensions
  `not-assessed`, `rationale` `null`, `evidence_pin_ids` empty) and sets the named dimension's
  `state` and `rationale`; that dimension's `evidence_pin_ids` becomes the sorted ids of pins for
  the element and page.
- `sync-refs` sets the ledger and matrix `snapshot_ref` to the current snapshot bytes digest and
  the matrix `ledger_ref` to the digest of the ledger bytes as they will be written.
- `remove-entry`, `pin`, `unpin` or `set-dimension` naming an entry, binding, pin or element that
  does not exist yields `DOCS_UPDATE_TARGET_INVALID` and exit 1.
- A document created by the command (absent before) carries the #1020 artifact header with `id`
  `stable_id(<artifact_kind>, row(repository=<profile repository id>))`; an existing document keeps
  its `id`. Ledger entries are sorted by `element_id`, matrix rows by `element_id` then
  `page_path`, pins by `pin_id`.
- Validation before planning: each changed document is validated against its schema
  (`schema_validation.validate_artifact`) and its rules (`ledger_rules`, `parity_rules`,
  `evidence_pins.validate_pins`). The operation fails (exit 1, nothing planned or written) when the
  resulting `error` findings contain a finding absent before the operation; findings are compared
  on every field except `pointer`. Pre-existing errors, such as missing dispositions for other
  elements, do not block an operation.
- Without `--write`, the command plans the writes, makes no `ArtifactStore` write call, and reports
  each changed document as `planned` and each unchanged one as `skipped`. With `--write`, writes
  are committed through `mutation.commit_artifact_writes` in ascending path order, stopping at the
  first failure; earlier writes are not rolled back and are listed in the failure finding.
- `result`: `{"dry_run": bool, "writes": [{"path", "artifact_kind", "artifact_id", "sha256", "status"}]}`,
  sorted by `path`; `status` is one of `planned`, `created`, `updated`, `skipped`, `conflict`
  (the discovery `MutationArtifact` vocabulary).
- Text result lines: `<status> <artifact_kind> <path> <sha256>` per write.

### `dev.docs.validate` (`cli_validate.py`)

| Option | Required | Values | Default |
|---|---|---|---|
| `--mode` | required | `profile`, `ledger`, `matrix`, `docs-complete` | none |
| `--revision` | required | full revision (40 or 64 lowercase hex; `is_full_revision`) | none |
| `--write-receipt` | optional | flag | absent |
| `--profile`, `--format` | optional | as above | as above |

- Loads the inputs the mode needs (table in `### Validation modes`) and calls
  `validation.validate(inputs, *, mode, revision, issued_at, resources=None)`. An absent artifact
  is omitted from the inputs and reported by the core as `DOCS_INPUT_UNREADABLE`.
- `result`: the receipt document, emitted on `pass` (exit 0) and on `fail` (exit 1). When the
  profile does not load, no receipt can be built (the repository identifier is unknown): exit 1,
  `result` `null`, findings from `parse_profile`.
- Without `--write-receipt`, the command makes no `ArtifactStore` call in any mode.
- With `--write-receipt`, after a receipt is built (pass or fail), the receipt is written to
  `artifact_paths.validation_receipt` through `mutation.commit_artifact_writes`: exclusive create
  when absent, digest-checked replace when present. The command plans only the
  `docs-validation-receipt` artifact kind. A commit failure exits 3.
- Text result lines: `receipt <id> <mode> <validation_result> <revision>`.

### Downstream constraints (binding on 900007 and 900008)

- 900007 `validate_docs_artifacts` invokes `dev.docs.validate --format json` and must not pass
  `--write-receipt`, so `update_docs_ledger` (mapped onto `dev.docs.update-ledger`) remains the
  only mutating MCP tool. 900007 `run_docs_coverage` invokes `dev.docs.coverage --format json`.
- 900008's CI workflow and opt-in hook are the consumers of a persisted receipt: the workflow runs
  `dev.docs.validate --mode docs-complete --revision <head> --write-receipt`, and the hook reads
  the file at `artifact_paths.validation_receipt` and allows the gated merge only when `mode` is
  `docs-complete`, `validation_result` is `pass` and `revision` equals the head revision.

### Validation modes (`validation.py`)

`validate(inputs: ValidationInputs, *, mode: ValidationMode, revision: str, issued_at: datetime,
resources: Mapping[str, bytes] | None = None) -> ValidationOutcome`; `ValidationInputs` holds raw
bytes per artifact path plus the page-path set; `ValidationOutcome` holds `receipt: JsonObject`,
`findings: tuple[Finding, ...]`, `ok: bool`. The function is pure when `resources` is supplied.
Each mode includes the checks of the modes before it.

| Mode | Inputs read | Checks |
|---|---|---|
| `profile` | profile | `profile.parse_profile` findings. |
| `ledger` | profile, snapshot, ledger | schema validation of snapshot and ledger; `snapshot_view` element rebuild; `ledger_rules`; `DOCS_REVISION_MISMATCH`. |
| `matrix` | profile, snapshot, ledger, matrix, pin collection, page-path set | schema validation of matrix and pins; `parity_rules`; pin consistency; staleness as `warning`. |
| `docs-complete` | same as `matrix` | gate evaluation from `completion_gates.docs_complete`; staleness severity per `max_stale_pages`; `DOCS_PAGE_MISSING`; `DOCS_SNAPSHOT_UNPINNED`. |

### Finding codes

| Code | Severity | Raised by | Condition |
|---|---|---|---|
| `SCHEMA_INVALID` | error | `schema_validation.validate_artifact` (#1020) | schema violation |
| `DOCS_INPUT_UNREADABLE` | error | `validation`, `cli_coverage` | an artifact the mode needs is absent |
| `DOCS_SNAPSHOT_ELEMENT_INVALID` | error | `snapshot_view` | `SurfaceElement` construction fails (identifier mismatch, parent rule, line range) |
| `DOCS_LEDGER_MISSING_DISPOSITION` | error | `ledger_rules` | an inventoried element has no entry; message names kind, declaration and element id; `related_ids` holds the element id, `related_paths` its path |
| `DOCS_LEDGER_DUPLICATE_ENTRY` | error | `ledger_rules` | two entries for one element id |
| `DOCS_LEDGER_ORPHAN_ENTRY` | error | `ledger_rules` | an entry names an element absent from the snapshot |
| `DOCS_LEDGER_KIND_MISMATCH` | error | `ledger_rules` | entry `kind` differs from the element kind |
| `DOCS_LEDGER_BINDING_REQUIRED` | error | `ledger_rules` | `documented` with no page binding |
| `DOCS_LEDGER_RATIONALE_REQUIRED` | error | `ledger_rules` | `excluded` without rationale text |
| `DOCS_LEDGER_OWNER_REQUIRED` | error | `ledger_rules` | `deferred` without owner |
| `DOCS_LEDGER_TARGET_REQUIRED` | error | `ledger_rules` | `deferred` without target |
| `DOCS_LEDGER_SNAPSHOT_REF` | warning | `ledger_rules` | `snapshot_ref.sha256` differs from the current snapshot bytes digest |
| `DOCS_MATRIX_LEDGER_REF` | warning | `parity_rules` | `ledger_ref.sha256` differs from the current ledger bytes digest |
| `DOCS_MATRIX_UNBOUND_ROW` | error | `parity_rules` | a row whose element is not `documented` with a binding to `page_path` |
| `DOCS_MATRIX_ROW_MISSING` | error | `parity_rules` | a documented binding has no row |
| `DOCS_MATRIX_DUPLICATE_ROW` | error | `parity_rules` | two rows for one element and page |
| `DOCS_MATRIX_PIN_UNKNOWN` | error | `parity_rules` | `evidence_pin_ids` names an absent pin or a pin for another element or page |
| `DOCS_MATRIX_ACCURACY_UNPINNED` | error | `parity_rules` | `accurate` is `pass` with no evidence pin |
| `DOCS_MATRIX_EXISTS_INCONSISTENT` | error | `parity_rules` | `exists` is `pass` but the page path is not in the page-path set |
| `DOCS_MATRIX_OWNER_INCONSISTENT` | error | `parity_rules` | `owner_assigned` is `pass` but no `page_owners` entry matches (`fnmatch.fnmatchcase`) |
| `DOCS_PIN_INCONSISTENT` | error | `evidence_pins` | pin identity fields do not reproduce `element_id`, or `pin_id` differs from its derivation |
| `DOCS_PAGE_STALE` | warning in `matrix`; in `docs-complete` error when the stale-page count exceeds `max_stale_pages`, otherwise warning | `staleness` | one finding per stale page; message names the page path and, per non-current pin, the element declaration, element id and status; `related_paths` holds the page path, `related_ids` the element and pin ids |
| `DOCS_PAGE_MISSING` | error | `validation` (`docs-complete`) | a bound page path is not in the page-path set |
| `DOCS_DEFERRED_NOT_ALLOWED` | error | `validation` (`docs-complete`) | a `deferred` entry while `allow_deferred` is false |
| `DOCS_PARITY_REQUIRED_DIMENSION` | error | `validation` (`docs-complete`) | a required dimension is `fail` or `not-assessed` for a documented binding (`pass` and `not-applicable` satisfy it) |
| `DOCS_REVISION_MISMATCH` | error | `validation` | snapshot `revision` is non-null and differs from `--revision` |
| `DOCS_SNAPSHOT_UNPINNED` | error | `validation` (`docs-complete`) | snapshot `revision` is `null` (assumption A-1) |
| `DOCS_UPDATE_TARGET_INVALID` | error | `cli_ledger` | the operation names an entry, binding, pin or element that does not exist |
| `DOCS_CLI_ARGUMENTS` | error | `cli_support` | usage or input error (exit 2) |
| `DOCS_CLI_RUNTIME` | error | `cli_support` | internal or I/O error (exit 3) |
| `DOCS_MUTATION_FAILED` | error | `cli_support` | a commit failure (exit 3) |

### Staleness (`evidence_pins.py`, `staleness.py`)

- `staleness.assess_pin(pin, *, elements)` compares one pin with the current snapshot elements
  indexed by `element_id` and returns exactly one status:
  - `element-missing`: no current element has the pin's `element_id` (a rename, move or
    declaration change lands here, because the identifier derives from kind, path and
    declaration).
  - `digest-changed`: the element exists and `pin.source_sha256 != element.source_sha256`.
  - `current`: the element exists and the digests are equal.
- A page is stale exactly when at least one pin with that `page_path` is not `current`.
  `stale_pages` returns one record per stale page, sorted by `page_path`.
- Staleness is digest-based only. A revision difference between a pin and the snapshot never marks
  a page stale; no remote freshness is inferred (imitating discovery `revision_rules`).
- The digest is compared for equality only and is treated as opaque, so the behavior does not
  depend on how 900003 and 900004 define element `source_sha256` (open question Q1).
- A `current` pin proves only that the pinned declaration digest is unchanged; prose accuracy is
  the matrix `accurate` dimension, judged by the reviewer role (epic non-goal).

### Receipt (`receipt.py`)

The receipt is a `docs-validation-receipt` document as planned by #1020. Every field:

| Field | Value |
|---|---|
| `$schema` | `schema_validation.docs_schema_id("docs-validation-receipt")` |
| `schema_version` | `"1.0.0"` |
| `artifact_kind` | `"docs-validation-receipt"` |
| `id` | `receipt_identifier(...)` = `stable_id("docs-validation-receipt", row(mode=..., repository=..., revision=..., inputs=..., validation_result=...))`; `issued_at`, `counts`, `findings` and `writer` are excluded, so the identity is independent of the issue time |
| `extensions` | the empty value permitted by discovery `common` `extensions` |
| `mode` | the `--mode` value |
| `repository` | the profile `repository.id` |
| `revision` | the validated `--revision` value (the pinned revision; never `null`) |
| `inputs` | one `artifact-pin` (`artifact_kind`, `path`, `sha256`) per artifact read, `sha256` from `ParsedDocument.source_sha256` of the raw bytes; sorted by `artifact_kind` then `path`; an absent artifact is not pinned |
| `counts.elements_total` | number of snapshot elements (0 in `profile` mode) |
| `counts.undocumented` | number of snapshot elements without a ledger entry (0 in `profile` mode) |
| `counts.stale_pages` | number of stale pages (0 in `profile` and `ledger` modes) |
| `counts.by_disposition` | entries matching current elements, keyed by exactly the three dispositions |
| `counts.by_kind` | snapshot elements keyed by exactly the six element kinds |
| `validation_result` | `fail` when any `error` finding exists (evaluated before the findings bound), otherwise `pass` |
| `findings` | `Finding.to_dict()` values, deduplicated, ordered by `finding_key`, bounded as in the envelope |
| `issued_at` | the injected clock value, UTC `date-time` |
| `writer` | `{tool: "drm-copilot-docs", version: drm_copilot_docs.__version__}` |

Every built receipt is validated with
`validate_artifact(..., artifact_kind="docs-validation-receipt")` before it is returned; a failure
is a defect guard (exit 3). The receipt is always printed in `result`; it is persisted only with
`--write-receipt`, through `mutation.py`.

### Write boundary (`mutation.py`)

- `ArtifactStore` (`typing.Protocol`): `read(path) -> bytes | None`,
  `create_exclusive(path, data) -> None`, `replace_if_digest(path, data, *, expected_sha256) -> None`.
- `PlannedArtifactWrite`, `ArtifactWriteResult`, `MutationOutcome`;
  `plan_artifact_writes(...)` (pure) and
  `commit_artifact_writes(plans, *, store: ArtifactStore, dry_run: bool = True) -> MutationOutcome`.
- A new file is created exclusively; an existing file is replaced only when its current digest
  equals the digest read at planning time, otherwise the status is `conflict` and the command
  exits 3 with `DOCS_MUTATION_FAILED`.
- `LocalArtifactStore`: `os.open` with `O_CREAT | O_EXCL` for create; a staged sibling file plus
  `os.replace` after a digest re-check for replace; paths must pass `validate_finding_path` and
  are resolved against the current working directory.
- `mutation.py` is the only module of this feature containing a filesystem write primitive.
  `commit_artifact_writes` is referenced only from `cli_ledger.py` and `cli_validate.py`.
  `ledger_to_json`, `matrix_to_json` and `pins_to_json` are referenced, outside their defining
  modules and their tests, only from `cli_ledger.py` (and `coverage_report.py` is read-only).

## Data & State

- Data transformations and invariants:
  - Ledger completeness is exact-once accounting: each snapshot element has exactly one entry.
  - Element identity is `surface_models.element_identifier` (#1020); a pin is self-consistent
    when `element_identifier(kind=element_kind, path=source_path, declaration=symbol)` equals its
    `element_id`.
  - All ordering is deterministic: entries and elements by `element_id`, rows by `element_id`
    then `page_path`, pins by `pin_id`, findings by `finding_key`, receipt inputs by
    `artifact_kind` then `path`.
  - Serialization of every written artifact and of the JSON envelope is `canonical_json`.
  - Framework code contains no consumer identifier; repository specificity is profile data.
- Persistence: ledger, matrix and pin collection at their `artifact_paths`, written only by
  `dev.docs.update-ledger --write`; receipt at `artifact_paths.validation_receipt`, written only by
  `dev.docs.validate --write-receipt`. Both go through `mutation.py`.
- Caching: none beyond the #1020 schema registry cache.
- Migration or backfill: none. Absent ledger, matrix or pin documents are created on first write.

## Assumptions and Open Questions

- **A-1 (assumption pending owner confirmation).** `docs-complete` fails closed when the snapshot
  `revision` is `null` (working-copy snapshot), with `DOCS_SNAPSHOT_UNPINNED`, so a receipt never
  claims a revision its snapshot did not capture. The rule is isolated to `validation.py`.
- **A-2 (assumption).** Persisting the receipt requires `--write-receipt`; 900007 does not pass
  it. Flagged for epic confirmation by research.
- **Q1 (epic-level open question).** Meaning of snapshot element `source_sha256`: whole-file
  digest or declaration digest. Research recommends the SHA-256 of the declaration's source span
  (the bytes of the `line_range` lines) when `line_range` is not `null`, otherwise the file digest.
  900003 and 900004 populate the field. 900005 compares whatever digest the snapshot records, so
  its code is independent of the choice; only fixture meaning and documentation change. A
  whole-file digest would mark every pinned page for a file stale on any edit to that file.
- **Q2.** The receipt cannot bind page bytes: `artifact-pin.artifact_kind` admits only the six docs
  artifact kinds. Page existence is checked (`DOCS_PAGE_MISSING`); page content is not pinned.
  Report-only gap unless the epic requires page binding.
- **Q3.** After #1020 merges: the exact name of its CLI port type, and whether
  `test_root_pyproject_registers_docs_console_scripts` and
  `test_package_pyproject_matches_runtime_contract` assert presence or exact sets. The plan's
  first phase records both.
- **Q4.** Whether a `docs-command-result` schema for the envelope is wanted; it would be a
  #1020-family change. Currently a Python-level contract.
- **Decisions made in this specification (beyond research), for review:** matrix rows and pins for
  a dropped binding are removed by `set-disposition` and `remove-entry`; `set-dimension` derives
  `evidence_pin_ids` from existing pins; a newly created artifact's `id` is
  `stable_id(<artifact_kind>, row(repository=...))`; `dev.docs.coverage` treats an absent ledger,
  matrix or pin collection as empty; the page-path set is every file below the documentation
  roots; an update fails only on a newly introduced `error` finding.

## Constraints & Risks

- Dependency: execution happens after #1020 merges into
  `epic/documentation-estate-tooling-integration`. #1020 symbols, schema fields and test names may
  change during its execution; the plan's first phase re-reads the merged `surface_models.py`,
  `profile_models.py`, `profile.py`, `schema_validation.py`, `cli.py`, the docs schemas and
  `tests/docs_runtime/test_docs_package_contract.py`, and records any renamed symbol before code is
  written. A changed schema field is an epic-level change, not a local divergence.
- Reliance on provisional assumption A5 (package `packages/docs-runtime`, import
  `drm_copilot_docs`) and A6 (MCP tools in 900007 only). If A5 changes, every module path here
  changes.
- Append-only conflicts in `[tool.poetry.scripts]` of the root and package `pyproject.toml` with
  900002, 900003, 900006 and 900008; resolved in the later child's remediation loop.
- Domain-neutral code: no consumer identifier in source; the #1020 neutrality test scans the new
  modules automatically.
- Tests create no temporary files. `LocalArtifactStore` is tested by monkeypatching `os.open`,
  `os.write`, `os.fsync`, `os.close`, `os.replace` and `os.unlink`, as
  `tests/discovery_runtime/test_mutation_filesystem.py` does.
- Finding volume: `FindingCollector` truncates at 100 findings; receipt counts stay exact.
- Batch budget: more than three non-test production Python files are created, so execution runs on
  the large route in the item worktree that holds the orchestration checkpoint.
- File size: `validation.py`, `parity_rules.py` and `cli_ledger.py` are the largest candidates;
  growth goes into a new module with its own test file before 500 lines.

## Non-Functional Requirements

- Domain-neutral code; no consumer identifier appears in source, schemas, tests or fixtures.
- Pure cores take in-memory inputs; only `mutation.py` (adapter) and the CLI modules perform I/O.
- Tests create no temporary files and do not depend on installed resources (schema `resources`
  are passed explicitly from the canonical schema bytes).
- Property tests use deterministic `itertools` enumerations; `hypothesis` and `random` are not
  used.
- Line coverage >= 85% and branch coverage >= 75% for every new module.
- File size: guidance at 500 lines, advisory at 700, hard block above 800.
- The discovery runtime is used as a library without behavior change.
- No new dependency; `poetry.lock` is unchanged.

## Implementation Strategy

- Implementation scope: create under `packages/docs-runtime/src/drm_copilot_docs/`:

| Module | Public symbols | Pure |
|---|---|---|
| `snapshot_view.py` | `SnapshotView` (`repository`, `revision`, `elements` by id, `sha256`), `snapshot_view(value, *, artifact_path, source_sha256)` | yes |
| `ledger_models.py` | `PageBinding`, `Actor`, `ArtifactPinRef`, `LedgerEntry`, `CoverageLedger`, `ledger_from_json`, `ledger_to_json` | yes |
| `ledger_rules.py` | `validate_ledger(value, *, snapshot, artifact_path)`, `apply_disposition(...)`, `remove_entry(...)` | yes |
| `parity_models.py` | `PARITY_DIMENSIONS`, `DimensionResult`, `ParityRow`, `ParityMatrix`, `matrix_from_json`, `matrix_to_json` | yes |
| `parity_rules.py` | `validate_matrix(value, *, ledger, pins, snapshot, page_paths, page_owners, artifact_path)`, `set_dimension(...)` | yes |
| `parity_scoring.py` | `DimensionScore`, `score_matrix(matrix)` | yes |
| `evidence_pins.py` | `EvidencePin`, `PinCollection`, `pin_identifier`, `pin_from_element`, `pins_from_json`, `pins_to_json`, `validate_pins(...)` | yes |
| `staleness.py` | `PinStatus`, `PinAssessment`, `StalePage`, `assess_pin`, `stale_pages` | yes |
| `receipt.py` | `receipt_identifier`, `receipt_counts`, `build_receipt` | yes |
| `validation.py` | `ValidationMode`, `ValidationInputs`, `ValidationOutcome`, `validate` | yes with `resources` |
| `coverage_report.py` | `build_coverage_report`, `render_coverage_text` | yes |
| `mutation.py` | `ArtifactStore`, `PlannedArtifactWrite`, `ArtifactWriteResult`, `MutationOutcome`, `plan_artifact_writes`, `commit_artifact_writes`, `LocalArtifactStore` | core yes; adapter I/O |
| `cli_support.py` | `DocsCliPorts`, envelope emission, input loading, argument helpers, exit-code constants | I/O through ports |
| `cli_coverage.py`, `cli_ledger.py`, `cli_validate.py` | `main_coverage`, `run_coverage_cli`; `main_update_ledger`, `run_ledger_cli`; `main_validate`, `run_validate_cli` | I/O through ports |

- Edit (append only): root `pyproject.toml` `[tool.poetry.scripts]` after the #1020 docs entries,
  and the same entries in `packages/docs-runtime/pyproject.toml` (which #1020 plans to declare its
  own scripts):
  `"dev.docs.coverage" = "drm_copilot_docs.cli_coverage:main_coverage"`,
  `"dev.docs.update-ledger" = "drm_copilot_docs.cli_ledger:main_update_ledger"`,
  `"dev.docs.validate" = "drm_copilot_docs.cli_validate:main_validate"`. No edit to
  `[tool.coverage.run]`, `[tool.pyright]`, `quality-tiers.yml`, `poetry.lock`, any schema, any
  #1020 module, or any discovery file.
- Tests under `tests/docs_runtime/` (a package per #1020): `test_snapshot_view.py`,
  `test_ledger_models.py`, `test_ledger_rules.py`, `test_docs_parity_models.py`,
  `test_docs_parity_rules.py`, `test_parity_scoring.py`, `test_evidence_pins.py`,
  `test_staleness.py`, `test_receipt.py`, `test_validation.py`, `test_mutation.py`,
  `test_docs_coverage_report.py`, `test_cli_support.py`, `test_cli_coverage.py`,
  `test_cli_ledger.py`, `test_cli_validate.py`, `test_ledger_properties.py`,
  `test_write_boundary.py`, `test_docs_complete_integration.py`. The `docs_` prefix is applied to
  the three basenames that already exist in `tests/discovery_runtime/` (`test_parity_models.py`,
  `test_parity_rules.py`, `test_coverage_report.py`).
- CLI tests use `io.StringIO` streams, a dictionary-backed `read_bytes`, a fixed `list_pages`, a
  recording in-memory `ArtifactStore` and a fixed clock.
- Dependency changes: none. Standard library (`hashlib`, `os`, `fnmatch`, `argparse`, `datetime`,
  `itertools`) plus `drm_copilot_discovery` and `drm_copilot_docs`.
- Logging and telemetry: none added; CLI diagnostics go to stderr.
- Rollout: additive; consumers opt in by installing the docs wheel. New modules ship in the wheel
  through the existing `packages = [{ include = "drm_copilot_docs", from = "src" }]` entry.

## Acceptance Criteria

- [ ] A ledger missing a disposition for any inventoried element fails validation with a `DOCS_LEDGER_MISSING_DISPOSITION` error whose message names the element's kind, declaration and element id; an `excluded` entry without rationale fails with `DOCS_LEDGER_RATIONALE_REQUIRED`, and a `deferred` entry without owner or without target fails with `DOCS_LEDGER_OWNER_REQUIRED` or `DOCS_LEDGER_TARGET_REQUIRED`.
- [ ] A pin whose recorded `source_sha256` differs from the current snapshot element's `source_sha256` has status `digest-changed` and marks its bound page stale; a pin whose element is absent from the snapshot has status `element-missing` and marks its page stale; a pin with an equal digest has status `current`, and a revision difference alone does not mark a page stale.
- [ ] A property test over every combination of {element present, element absent} and {digest equal, digest different} yields exactly the statuses `current`, `digest-changed` and `element-missing`, and a page is reported stale exactly when at least one of its pins is not `current`.
- [ ] `dev.docs.validate --mode docs-complete` emits a receipt with `validation_result` `pass` and exits 0 on a complete fixture; on an in-memory fixture with one undocumented element and one stale page it exits non-zero, emits a `fail` receipt, and its output names both the undocumented element (declaration and element id) and the stale page path (`tests/docs_runtime/test_docs_complete_integration.py`).
- [ ] After the integration fixture's missing ledger entry is added and its stale pin is re-pinned, `dev.docs.validate --mode docs-complete` exits 0 with a `pass` receipt.
- [ ] Every receipt emitted by `dev.docs.validate` in each of the modes `profile`, `ledger`, `matrix` and `docs-complete`, on pass and on fail, validates against the #1020 `docs-validation-receipt` schema, and its `revision` equals the `--revision` argument.
- [ ] The receipt `id` equals `stable_id("docs-validation-receipt", row(mode=..., repository=..., revision=..., inputs=..., validation_result=...))`, and a property test shows it is unchanged when only `issued_at` differs and changes when any of those five members differs.
- [ ] The receipt `inputs` contain one `artifact-pin` per artifact read, with `sha256` equal to the SHA-256 of that artifact's raw bytes, sorted by `artifact_kind` then `path`.
- [ ] `dev.docs.validate --mode docs-complete` with a snapshot whose `revision` is `null` exits 1 and reports `DOCS_SNAPSHOT_UNPINNED`; with a non-null snapshot revision that differs from `--revision` it reports `DOCS_REVISION_MISMATCH`.
- [ ] In `docs-complete` mode, a `deferred` entry with `allow_deferred` false yields `DOCS_DEFERRED_NOT_ALLOWED`; a required parity dimension in state `fail` or `not-assessed` yields `DOCS_PARITY_REQUIRED_DIMENSION`; a bound page absent from the page-path set yields `DOCS_PAGE_MISSING`; and `DOCS_PAGE_STALE` is an `error` when the stale-page count exceeds `max_stale_pages` and a `warning` otherwise.
- [ ] Ledger and matrix writes happen only through `mutation.py`; `dev.docs.update-ledger` is the only CLI that mutates the ledger, matrix or pin collection. `tests/docs_runtime/test_write_boundary.py` proves it by an AST scan of every module under `packages/docs-runtime/src/drm_copilot_docs/` (filesystem write primitives appear only in modules on an explicit allowlist with one reason per entry, of which this feature contributes only `mutation.py`; `commit_artifact_writes` is referenced only from `cli_ledger.py` and `cli_validate.py`; `ledger_to_json`, `matrix_to_json` and `pins_to_json` are not referenced from `cli_validate.py` or `cli_coverage.py`), and a positive control in which the scan helper reports a write call in an in-memory source string.
- [ ] With a recording in-memory `ArtifactStore`, `dev.docs.coverage` makes zero store calls, `dev.docs.validate` without `--write-receipt` makes zero store calls in every mode, `dev.docs.validate --write-receipt` plans only the `docs-validation-receipt` artifact kind at `artifact_paths.validation_receipt`, and `dev.docs.update-ledger` without `--write` makes zero store write calls and reports each changed document with status `planned`.
- [ ] `dev.docs.update-ledger --write` creates an absent document exclusively and replaces an existing document only when its digest equals the digest read at planning time; a digest mismatch exits 3 with `DOCS_MUTATION_FAILED` and status `conflict`.
- [ ] `dev.docs.update-ledger` exits 1 and makes no store write call when the operation would introduce an `error` finding not present before it (for example `set-disposition --disposition excluded` without `--rationale`), and succeeds when pre-existing errors for other elements are present.
- [ ] Each of the operations `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension` and `sync-refs` produces the documented change in a CLI test, and an option outside the operation's permitted set exits 2.
- [ ] For each of `dev.docs.coverage`, `dev.docs.update-ledger` and `dev.docs.validate`, CLI tests assert exit 0 on success, exit 1 on findings, exit 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and `result` `null` on an unknown option, a missing required option and an invalid value (including an invalid `--revision`, `--element` or relative path), and exit 3 with exactly one `DOCS_CLI_RUNTIME` or `DOCS_MUTATION_FAILED` finding on an injected read or write failure; `--help` exits 0 without reading input, and no `SystemExit` escapes.
- [ ] With `--format json`, each command writes exactly one `canonical_json` document to stdout whose keys are exactly `command`, `ok`, `exit_code`, `findings` and `result`, with `ok` true exactly when `exit_code` is 0, findings carrying exactly the `Finding.to_dict` keys ordered by `finding_key`, and byte-identical output across two runs with the same inputs and clock.
- [ ] With `--format text`, each command prints one `<severity> <code> <artifact_path><pointer>: <message>` line per finding and ends with the summary line `<command>: exit=<exit_code> errors=<n> warnings=<n> infos=<n>`.
- [ ] `dev.docs.coverage --format json` returns `result` with `totals`, `undocumented`, `deferred`, `stale_pages` and `parity`, where each parity dimension's counts sum to the matrix row count and `score_basis_points` is an integer or `null` (property test over enumerated state assignments).
- [ ] Order-invariance property tests (`itertools.permutations`) show that permuting ledger entries, matrix rows and pins yields byte-identical `canonical_json` output and identical findings, and a ledger-completeness property test over every subset of a fixed snapshot (`itertools.combinations`) shows the missing-disposition findings name exactly the complement.
- [ ] A disposition-companion property test (`itertools.product` over the three dispositions and the presence of bindings, rationale, owner and target) shows the finding set equals the companion table.
- [ ] The root `pyproject.toml` and `packages/docs-runtime/pyproject.toml` `[tool.poetry.scripts]` each contain the three entries `"dev.docs.coverage" = "drm_copilot_docs.cli_coverage:main_coverage"`, `"dev.docs.update-ledger" = "drm_copilot_docs.cli_ledger:main_update_ledger"` and `"dev.docs.validate" = "drm_copilot_docs.cli_validate:main_validate"`; the #1020 contract tests in `tests/docs_runtime/test_docs_package_contract.py` pass; `poetry check --lock` exits 0 and `poetry.lock` is unchanged.
- [ ] The #1020 neutrality test `tests/docs_runtime/test_neutrality.py` passes with the new modules in its scan scope.
- [ ] No test module added by this feature imports `tempfile`, `hypothesis` or `random`, or requests the `tmp_path` or `tmp_path_factory` fixtures.
- [ ] Discovery runtime and #1020 files are unchanged: `git diff --name-only` between the merge base with the integration branch and the feature head returns no path under `packages/discovery-runtime/`, `schemas/discovery/` or `schemas/docs/`, and none of the #1020 modules `surface_models.py`, `profile_models.py`, `profile.py`, `schema_validation.py`, `resources.py`, `analyzer_contract.py` or `cli.py`.
- [ ] Line coverage >= 85% and branch coverage >= 75% for every new module, measured with `--cov=drm_copilot_docs --cov-branch` and read per file from the JSON report.
- [ ] No production or test file created by this feature exceeds 800 lines, and the file-size repository gate passes.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit, property and integration)
- [ ] Edge cases and error handling covered by tests (empty file, invalid JSON, duplicate keys, absent artifact, tampered element id, duplicate entry, orphan entry, kind mismatch, duplicate row, unknown pin, naive clock, digest conflict)
- [ ] At least one property test per pure function in the new modules (T2 obligation)
- [ ] Docs updated (`packages/docs-runtime/README.md`: the three commands, exit codes and receipt persistence)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → architecture → test → contract → integration) in a single clean pass
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: ledger rules, parity rules and scoring, pins and staleness, receipt, validation modes, mutation boundary
- [ ] Integration scenarios: docs-complete validation over an in-memory fixture with one undocumented element and one stale page
- [ ] CLI/API examples: `dev.docs.coverage`, `dev.docs.update-ledger`, `dev.docs.validate --mode docs-complete`
