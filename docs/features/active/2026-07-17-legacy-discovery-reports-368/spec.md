# legacy-discovery-reports — Spec

- **Issue:** #368
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T15-03
- **Status:** Draft
- **Version:** 0.2

## Overview

The legacy-discovery-and-parity capability produces machine-readable discovery artifacts
(a Coverage Ledger and a Parity Matrix). Consumers migrating a legacy application need
deterministic, human-readable reports derived from those artifacts to review coverage,
source-to-target parity, and aggregate completion readiness. Without a reporting layer,
the machine-readable artifacts are not directly consumable by reviewers.


## Behavior

Deterministic report generation from the machine-readable discovery artifacts:

- A coverage report rendered from the Coverage Ledger.
- A parity report rendered from the Parity Matrix.
- A completion report presenting aggregate readiness across the discovery artifacts.

Given the same input artifacts, the report output is byte-identical (stable ordering,
sorted keys, no wall-clock or RNG in rendered output unless injected via clock/seed).

Reports render generically from the discovery artifacts. The reporting framework is
domain-neutral: no TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior.

Input artifacts are validated via the legacy-discovery validators before rendering, so a
malformed artifact fails fast rather than producing a misleading report.

Ship `dev.discovery.*` Python CLI entry point(s) for report generation as Poetry
console-scripts in root `pyproject.toml` `[tool.poetry.scripts]`, mapping to
`scripts.dev_tools.<module>:main` with `def main(argv=None) -> int` and an argparse parser.


## Inputs / Outputs

- **Inputs (CLI flags, files, env vars):**
  - `--input <path>` (required, repeatable where a command consumes more than one artifact):
    path to an artifact JSON file (Coverage Ledger for the coverage report; Parity Matrix for
    the parity report; both Coverage Ledger and Parity Matrix for the completion report).
  - `--output <path>` (optional): path to write the rendered report text; when omitted, the
    report is written to stdout.
  - No environment variables are read by report rendering or CLI argument parsing. No wall
    clock or RNG source is read implicitly; a `Clock`/seed callable may be injected only where
    a future report field explicitly requires it (none is required for v1).
- **Outputs (artifacts, logs, telemetry):**
  - A single deterministic report text file (or stdout stream) per invocation: a coverage
    report, a parity report, or a completion report.
  - On validation failure, human-readable error lines (one per validator-reported error) are
    written to stderr; no report is written.
  - No telemetry emission is introduced by this feature.
- **Config keys and defaults:** None. This feature introduces no configuration file or config
  keys; all behavior is controlled by CLI flags. The upstream artifact's own `$schema` field
  (once `legacy-discovery-schemas`, #9002, defines it) is read by the injected validator, not by
  this feature's rendering code.
- **Versioning or backward-compatibility constraints:** The report layer does not re-derive
  schema version; it accepts a parsed artifact dict whose shape may vary by version and routes
  to the correct field mapping via a `resolve_field_mapping(artifact: dict) -> FieldMapping`
  dispatcher keyed on the version indicator field `legacy-discovery-schemas` defines. Exact
  field names and the version-indicator field name are an upstream-dependency assumption (see
  Constraints & Risks) pending #9002/#9003.

## API / CLI Surface

Three Poetry console-script entry points under the `dev.discovery.*` namespace, consistent with
the repository's hyphenated-script-key convention
(`research/research.2026-07-17T15-10.md` Section 1.2):

```
[tool.poetry.scripts]
"dev.discovery.coverage-report" = "scripts.dev_tools.discovery.coverage_report:main"
"dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"
"dev.discovery.completion-report" = "scripts.dev_tools.discovery.completion_report:main"
```

Each module exposes `def main(argv: Sequence[str] | None = None) -> int` with an
`argparse`-based `parse_args`, matching the repository's canonical CLI shape (e.g.
`scripts/dev_tools/format_json.py`, `scripts/dev_tools/validate_json.py`).

- **Example invocations with expected outputs (concise):**
  - `poetry run dev.discovery.coverage-report --input coverage-ledger.json --output
    coverage-report.txt` — reads and validates the Coverage Ledger, writes the rendered
    coverage report to `coverage-report.txt`, returns exit code `0`.
  - `poetry run dev.discovery.parity-report --input parity-matrix.json` — reads and validates
    the Parity Matrix, writes the rendered parity report to stdout, returns exit code `0`.
  - `poetry run dev.discovery.completion-report --input coverage-ledger.json --input
    parity-matrix.json` — reads and validates both artifacts, writes the aggregate readiness
    report to stdout, returns exit code `0`.
  - `poetry run dev.discovery.coverage-report --input malformed.json` — the injected
    `validate_coverage_ledger_text` returns one or more error strings; the CLI prints each
    error to stderr and returns exit code `1`; no report is rendered or written.
- **Contracts and validation rules:**
  - Every command validates its input artifact text via an injected `ArtifactValidator`
    callable (`Protocol.__call__(self, text: str) -> list[str]`) before any parsing or
    rendering occurs. A non-empty error list raises an `ArtifactValidationError` inside the I/O
    boundary function; `main()` catches it, prints the errors, and returns `1`.
  - The default validator binding imports the real upstream `validate_coverage_ledger_text` /
    `validate_parity_matrix_text` function lazily (inside the function body, not at module import
    time), so importing a report module does not hard-fail before `legacy-discovery-validators`
    (#9003) is merged. Unit tests inject a fake `ArtifactValidator` and never touch the real
    upstream module or the filesystem.
  - Report rendering only proceeds once validation returns an empty error list.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- **Data transformations and invariants:**
  - `read_artifact_text(path: Path) -> str` — thin I/O wrapper reading the artifact file as
    UTF-8 text.
  - `validate_or_raise(text: str, validator: ArtifactValidator) -> None` — invokes the injected
    validator; raises `ArtifactValidationError` on any non-empty error list.
  - `parse_<artifact>(text: str) -> dict` — parses validated JSON text into a plain dict (no
    dataclass is introduced yet, since the upstream schema is not final).
  - `build_<report>_rows(artifact: dict) -> list[...]` — pure function producing a
    deterministically sorted sequence of report rows (sort key: entry/row identifier when
    present, else a case-insensitive join of all present string fields).
  - `render_<report>(rows, summary) -> str` — pure function producing the final report string;
    holds a single fixed formatting discipline per report type (either
    `json.dumps(data, sort_keys=True, ensure_ascii=True, separators=(",", ":")) + "\n"` for a
    compact machine-oriented body, or `sort_keys=True, indent=2` for a human-readable body — not
    mixed within one report type) and joins lines with `"\n"` (LF only, no CRLF).
  - Invariant: `render_<report>(parse_<report>(text))` called twice on the same `text` produces
    byte-identical strings; no step reads wall-clock time, environment state, or random values.
  - `write_report(path: Path, content: str) -> None` — thin I/O wrapper for the optional
    `--output` flag; omitted when writing to stdout.
- **Caching or persistence details:** None. Reports are stateless renderings; no cache or
  persistent store is introduced.
- **Migration or backfill requirements (if any):** None. This feature only reads existing
  discovery artifacts; it performs no migration of data.

## Constraints & Risks

- **Determinism:** no wall-clock time or RNG in rendered output unless injected via a
  clock/seed per `.claude/rules/general-unit-test.md`. Determinism is verified by rendering the
  same synthetic artifact dict twice and asserting byte-for-byte string equality, not merely
  "renders without error."
- **Evidence output under `<FEATURE>/evidence/<kind>/` only.** Any baseline, QA gate, or
  coverage evidence produced while delivering this feature is written under this feature's own
  `evidence/` directory, never under `artifacts/baselines/`, `artifacts/qa/`, or
  `artifacts/coverage/`.
- **Upstream contract dependency (execution-time risk):** `legacy-discovery-schemas` (#9002) and
  `legacy-discovery-validators` (#9003) are not present in this worktree
  (`research/research.2026-07-17T15-10.md` Section 0). The concrete field-level shapes of the
  Coverage Ledger and Parity Matrix, the exact upstream validator module path/function names
  (`validate_coverage_ledger_text`, `validate_parity_matrix_text`), and the exact `schemas/vN/`
  directory layout are upstream-dependency assumptions derived from
  `docs/features/epics/legacy-discovery-and-parity/objective-source.md` (section 12, line 115)
  and `epic.md` "Shared Design" (lines 107-113), not from merged code. This feature designs
  against the documented contract with the injectable `ArtifactValidator` seam (API / CLI
  Surface, above) so field-level mapping can be finalized without a rewrite once #9002/#9003
  land. Cite `research/research.2026-07-17T15-10.md` for every substrate claim above.
- **Domain neutrality risk:** the reporting framework must render report labels only from
  artifact field values, never from framework-hardcoded domain vocabulary (no TaskMaster/TMW/
  Outlook/VSTO/email/task-management identifiers). A hardcoded domain label in any renderer is a
  Blocking finding under feature review.
- **File-size / decomposition risk:** a single flat module housing all three renderers plus
  shared I/O and rendering helpers would risk exceeding the 500-line limit
  (`.claude/rules/general-code-change.md` "File Size Limit"). Mitigated by the subpackage
  decomposition in Implementation Strategy, below.
- **Completion-report scope risk:** the epic names five discovery-artifact categories beyond
  Coverage Ledger and Parity Matrix (Feature Contract, Runtime Characterization Scenario,
  Unspecified Behavior Record, Product Decision Record, Evidence Reference,
  `objective-source.md` lines 72-78), but this feature's `depends_on` is scoped to
  `legacy-discovery-schemas` and `legacy-discovery-validators` only (`epic.md` line 155). The
  completion report's v1 scope is therefore restricted to aggregating over Coverage Ledger and
  Parity Matrix only, with the aggregation function structured so additional artifact
  categories can be added as parameters/inputs later without a rewrite.

## Implementation Strategy

- **Implementation scope (what changes, not sequencing):**
  - Add a new `scripts/dev_tools/discovery/` subpackage containing the pure rendering logic, the
    I/O boundary, and three CLI entry points.
  - Add three new `[tool.poetry.scripts]` entries to root `pyproject.toml`.
  - Add mirrored tests under `tests/scripts/dev_tools/discovery/`.
  - No existing module is modified; this feature is additive only.
- **New classes/functions/commands to add or update:**
  - `scripts/dev_tools/discovery/__init__.py` — subpackage marker.
  - `scripts/dev_tools/discovery/io.py` — `read_artifact_text(path)`, `write_report(path,
    content)`, the `ArtifactValidator` `Protocol`, `validate_or_raise(text, validator)`, and the
    `ArtifactValidationError` exception.
  - `scripts/dev_tools/discovery/rendering.py` — shared deterministic-formatting helpers (sort
    primitives, the fixed `json.dumps` discipline) reused by all three report modules.
  - `scripts/dev_tools/discovery/coverage_report.py` — `parse_coverage_ledger`,
    `build_coverage_rows`, `render_coverage_report`, `parse_args`, `main(argv=None) -> int` for
    `dev.discovery.coverage-report`.
  - `scripts/dev_tools/discovery/parity_report.py` — the analogous pipeline for
    `dev.discovery.parity-report`.
  - `scripts/dev_tools/discovery/completion_report.py` — aggregates coverage-report and
    parity-report outputs plus validator pass/fail results into an aggregate readiness summary;
    `parse_args`, `main(argv=None) -> int` for `dev.discovery.completion-report`.
  - This decomposition mirrors the existing `scripts/dev_tools/atomic_executor/` subpackage
    precedent (a `cli.py`/dispatch module plus decomposed helper modules) rather than one large
    combined module.
- **Dependency changes (new/removed packages) and rationale:** None. This feature uses only
  the Python standard library (`argparse`, `json`, `pathlib`) already in use by every reviewed
  CLI module; no new dependency is required or proposed.
- **Logging/telemetry additions and locations:** None beyond stderr error output on validation
  failure (API / CLI Surface, above). No structured logging or telemetry framework is
  introduced by this feature.
- **Rollout plan (feature flags, staged deploys, fallback path):** No feature flag or staged
  rollout is required; the three CLI entry points are additive Poetry console scripts with no
  effect on existing commands until invoked. No fallback path is needed because no existing
  behavior is modified.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

Mapping of each seeded test condition to acceptance criteria and design elements
(`research/research.2026-07-17T15-10.md` Section 8):

- [ ] Unit coverage: rendering each report type from conforming artifacts. Maps to AC "A
  coverage report is rendered deterministically...", "A parity report is rendered
  deterministically...", "A completion report presents aggregate readiness..." via the
  `parse -> build_rows (sorted) -> render` pure pipeline in each of `coverage_report.py`,
  `parity_report.py`, `completion_report.py`.
- [ ] Determinism: repeated runs on identical input produce byte-identical output. Maps to AC
  "Given identical input artifacts, report output is byte-identical across runs." Verified by
  calling `render_<report>` twice on the same parsed dict and asserting string equality
  (property-style, not merely "renders without error").
- [ ] Negative: malformed / non-conforming artifact fails fast before rendering. Maps to AC
  "Input artifacts are validated ... before rendering; a malformed artifact fails fast...".
  Verified by injecting a fake `ArtifactValidator` returning non-empty errors and asserting
  `main()` returns `1` without the write function ever being called.
  - [ ] Edge case: empty ledger/matrix (zero entries) renders a header/summary only, without
    raising.
- [ ] CLI: `dev.discovery.*` entry points return correct exit codes for success and failure.
  Maps to AC "Report generation is exposed as `dev.discovery.*` Poetry console-script CLI entry
  point(s)...". Verified by calling each `main(argv=[...])` directly with a monkeypatched
  validator/I-O seam and asserting the returned exit code, mirroring
  `validate_orchestration_artifacts.py`'s `main` test style rather than spawning a subprocess.
- [ ] Domain-neutrality: no test fixture or renderer emits a hardcoded domain-specific label.
  Maps to AC "The reporting framework contains no domain-specific identifiers."
- [ ] Coverage-tooling: no new `omit` entry is added for `scripts/dev_tools/discovery/**`. Maps
  to AC "Tests satisfy quality-tier policy (line >= 85%, branch >= 75%)."
