# `docs-coverage-ledger-and-receipt` — User Story

- Issue: #1023
- Parent: #1019 (epic documentation-estate-tooling, wave 1, band C4)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Version: 0.3 (PowerShell design; replaces the withdrawn Python design)
- Specification: `spec.md` in this folder (version 0.3)

## Story Statement

- As a repository maintainer, I want to measure how much of my inventoried surface is documented,
  deferred, excluded or stale with one read-only subcommand, so that I can see the documentation gap
  without measuring it by hand.
- As a repository maintainer, I want to record a disposition, a page binding, an evidence pin or a
  parity result through one subcommand that previews its changes by default, so that ledger, matrix
  and pin edits are validated and written in one controlled way.
- As a repository maintainer whose surface is analyzed by a PowerShell text scanner, I want each
  construct the scanner cannot classify to be recorded as a deferred ledger entry with an owner and a
  target, so that the scanner's precision limit is visible and accounted for instead of silently
  ignored.
- As a CI pipeline, I want to prove `docs-complete` for a specific revision and persist a receipt,
  so that a merge can be gated on documentation that corresponds to the code at that revision.
- As a downstream tool author (MCP tools or the integration hook), I want stable arguments, exit
  codes, a schema-validated JSON envelope and a receipt with a fixed shape and a gate decision
  function, so that my tool can wrap the subcommands and consume the receipt without parsing text.

## Problem / Why

A destination repository can inventory its documentable surface, but nothing records whether each
surface element is documented, nothing binds elements to pages, and nothing detects that a page
describes code that has since changed. In one consumer repository a feature epic changed 138 `src/`
files while only 4 of 79 documentation pages were edited, and the gap was measured by hand. This
feature is the correspondence core of the documentation-estate epic: the coverage ledger, the parity
matrix, evidence pins with staleness detection, and the `docs-complete` validation receipt. It runs
as PowerShell modules under `.claude/lib/docs/` behind `Invoke-DocsCommand.ps1`, so a destination
repository needs PowerShell 7 only. Later features expose it through MCP tools (900007) and enforce
it in CI and an opt-in hook (#1034).

## Personas & Scenarios

- Persona: Repository maintainer
  - Maintains a repository that has adopted the documentation estate tooling and has a docs
    profile and a surface inventory snapshot.
  - Cares that every surface element has an explicit disposition and that pages describing changed
    code are identified.
  - Constraints: works from a local checkout with PowerShell 7; edits ledger artifacts only through
    the provided subcommand; needs to preview a change before writing it.
  - Goals: a coverage measurement and a clean ledger. Frustration: findings that do not name the
    element or page concerned.
  - Context: after a feature changes the surface, before opening a pull request.
- Persona: CI pipeline
  - A non-interactive workflow (delivered by #1034) running on a pull request revision.
  - Cares that the receipt it persists pins the exact revision it validated and that the result is
    machine-readable.
  - Constraints: no prompts; relies on exit codes and on the persisted receipt file; `pwsh` only.
  - Goals: a `pass` receipt for the revision, or a failing exit with named causes.
- Persona: Downstream tool author
  - Implements the MCP tools (900007) or the opt-in integration hook (#1034).
  - Cares that arguments, exit codes, the envelope and receipt fields are written down and stable.
  - Constraints: the MCP validation tool must not mutate files; only the ledger update tool may.
  - Goals: map structured tool input onto subcommand arguments and read structured results.

- Scenario: Maintainer measures coverage
  - Actor: repository maintainer.
  - Trigger: a feature added CLI commands and changed several public symbols.
  - Steps: refreshes the surface inventory snapshot; runs
    `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command coverage`; reads the
    undocumented elements, deferred entries, precision limits, stale pages and parity scores.
  - Obstacles and decisions: no ledger exists yet; the subcommand treats it as empty and lists every
    element as undocumented rather than failing.
  - Outcome: the maintainer has a list of the elements and pages that need work; no file changed.
- Scenario: Maintainer records a disposition
  - Actor: repository maintainer.
  - Trigger: the coverage report lists an undocumented CLI command.
  - Steps: runs `-Command update-ledger -Operation set-disposition -Element <id> -Disposition
    documented -Page <page> -ActorKind human -ActorId <id>`; reviews the planned writes; repeats with
    `-Write`; pins the element to the page with `-Operation pin`; records parity results with
    `-Operation set-dimension`.
  - Obstacles and decisions: the maintainer first marks another element `excluded` without a
    rationale; the subcommand exits 1, names the missing rationale and writes nothing; the maintainer
    adds `-Rationale`.
  - Outcome: the ledger, matrix and pin collection are updated through the single write boundary.
- Scenario: Maintainer records a scanner precision limit
  - Actor: repository maintainer.
  - Trigger: `coverage` lists a precision limit with `recorded` false: the scanner reported a
    dynamically registered command it cannot classify.
  - Steps: runs `-Command update-ledger -Operation set-disposition -Limit <diagnostic id>
    -Disposition deferred -Owner <id> -Target <text> -ActorKind human -ActorId <id> -Write`.
  - Outcome: the ledger holds a `deferred` entry with `analysis_method` `scanner`; `docs-complete`
    treats it like any deferred entry under the profile's `allow_deferred` setting.
- Scenario: CI proves docs-complete
  - Actor: CI pipeline.
  - Steps: runs `-Command validate -Mode docs-complete -Revision <revision> -WriteReceipt -Json`.
  - Obstacles and decisions: one element has no disposition and one page pins a declaration whose
    digest changed; the subcommand exits 1, the findings name the element and the page, and a `fail`
    receipt is persisted.
  - Outcome: after the maintainer fixes both, the subcommand exits 0 and persists a `pass` receipt
    pinned to the revision.
- Scenario: Tool author consumes the contracts
  - Actor: downstream tool author.
  - Steps: the MCP tool runs `-Command validate -Json` without `-WriteReceipt` and reads
    `exit_code`, `findings` and the receipt in `result`; the hook reads the persisted receipt and
    calls `Get-DocsReceiptGateDecision`.
  - Obstacles and decisions: an invalid argument returns exit 2 with one `DOCS_CLI_ARGUMENTS`
    finding and a null `result`, which the tool reports as an input error.
  - Outcome: both consumers work from the stated contracts without parsing text output.

## Acceptance Criteria

Pester criteria are verified by suites under `tests/scripts/claude-lib/docs/`, run with coverage on
`windows-latest` in `poshqc / PowerShell QC` (shards aggregated by that required check).

### Maintainer measuring coverage

- [ ] A maintainer running `-Command coverage` receives totals (including counts by analysis method), the undocumented elements, the deferred entries, the scanner precision limits, the stale pages and per-dimension parity counts and integer scores, and the subcommand makes no `WriteText` call (`DocsLedgerCommands.Tests.ps1`).
- [ ] When the ledger, matrix or pin collection does not exist yet, `-Command coverage` reports every inventoried element as undocumented and exits 0 (`DocsLedgerCommands.Tests.ps1`).
- [ ] A page is reported stale when a pin bound to it records a digest that differs from the current snapshot element, or when the pinned element no longer exists; a revision change alone does not make a page stale (`DocsStaleness.Tests.ps1`).

### Maintainer recording a disposition through update-ledger

- [ ] `-Command update-ledger` without `-Write` reports the planned writes and makes no `WriteText` call; with `-Write` it writes the ledger, matrix or pin collection only through `Invoke-DocsArtifactWrite` (`DocsLedgerCommands.Tests.ps1`).
- [ ] Recording `excluded` without a rationale, or `deferred` without an owner or a target, exits 1, names the missing field for that element, and writes nothing; existing errors for other elements do not block a valid update (`DocsLedgerCommands.Tests.ps1`).
- [ ] Each ledger entry records the `analysis_method` (`native` or `scanner`) of its current snapshot element (`DocsLedgerCommands.Tests.ps1`).
- [ ] Re-pinning an element to the same page replaces the existing pin instead of adding a second one, and the page is no longer stale (`DocsLedgerCommands.Tests.ps1`).
- [ ] If a document changed after the subcommand read it, the write is refused with exit 3 and one `DOCS_CLI_RUNTIME` finding naming the conflicting path (`DocsLedgerMutation.Tests.ps1`).
- [ ] `update-ledger` is the only subcommand that changes the ledger, matrix or pin collection, as shown by `DocsWriteBoundary.Tests.ps1`.

### Maintainer recording a scanner precision limit

- [ ] A precision-limit diagnostic in the snapshot without a ledger entry fails `-Command validate -Mode ledger` with `DOCS_LEDGER_LIMIT_UNRECORDED` naming the analyzer, code and path; after `-Operation set-disposition -Limit <diagnostic id> -Disposition deferred -Owner <id> -Target <text> -Write`, the ledger holds a `deferred` entry with `analysis_method` `scanner` and the finding is gone (`DocsLedgerCommands.Tests.ps1`).
- [ ] In `docs-complete` mode a precision-limit entry passes when the profile's `allow_deferred` is true and yields `DOCS_DEFERRED_NOT_ALLOWED` when it is false (`DocsValidation.Tests.ps1`).

### CI proving docs-complete

- [ ] `-Command validate -Mode docs-complete` exits 0 with a `pass` receipt on a complete fixture; with one undocumented element and one stale page it exits 1 and the findings name both; after both are fixed it exits 0 (`DocsCompleteIntegration.Tests.ps1`).
- [ ] A ledger missing a disposition for any inventoried element fails validation naming the element's kind, declaration and element id (`DocsLedger.Tests.ps1`).
- [ ] With `-Mode docs-complete -WriteReceipt`, the receipt is written to the profile's `validation_receipt` path on both pass and fail, its `revision` equals the `-Revision` argument, and `-WriteReceipt` with any other mode exits 2 (`DocsLedgerCommands.Tests.ps1`).
- [ ] Validation of a snapshot with a null `revision` in `docs-complete` mode fails with `DOCS_SNAPSHOT_UNPINNED`, so no receipt claims a revision the snapshot did not capture (`DocsValidation.Tests.ps1`).

### Downstream tool author consuming the contracts

- [ ] Each of `coverage`, `update-ledger` and `validate`, with `-Json`, prints exactly one envelope that produces no finding from `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'`, and returns exit 0, 1, 2 or 3 with the meanings stated in the spec (`DocsLedgerCommands.Tests.ps1`).
- [ ] Every emitted receipt produces no finding from `Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt'`, and its `id` does not change when only `issued_at` differs (`DocsReceipt.Tests.ps1`, `DocsValidation.Tests.ps1`).
- [ ] `-Command validate` without `-WriteReceipt` makes no `WriteText` call in any mode, so an MCP tool that does not pass that switch is read-only (`DocsLedgerCommands.Tests.ps1`).
- [ ] An invalid argument returns exit 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and a null `result`, before any context read (`DocsLedgerCommands.Tests.ps1`).
- [ ] `Get-DocsReceiptGateDecision` allows only a schema-valid `docs-complete` receipt with `validation_result` `pass` whose `revision` equals the supplied revision, and otherwise returns the reason `receipt-invalid`, `mode-not-docs-complete`, `result-fail` or `revision-mismatch` (`DocsReceipt.Tests.ps1`).

### Quality

- [ ] Every new `.claude/lib/docs/` module is mirrored byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` and listed in `pack-manifests/core.json`, and the push-down contract tests pass (`Docs.Manifest.Tests.ps1` in `poshqc / PowerShell QC`; the Python push-down contract tests in `quality-checks7 / Code Quality & Tests`).
- [ ] Every pure function in the new modules has a property test with seeded deterministic generation or exhaustive enumeration, and no test creates a temporary file.
- [ ] Pester line coverage is >= 85% for each new production file on `windows-latest` in `poshqc / PowerShell QC`.

## Non-Goals

- Surface analyzers and snapshot production (#1022, #1033, #1031); this feature only states the
  precision-limit diagnostic contract those scanners emit.
- The page quality checker (1021) and the reference-page generator (1024).
- MCP tool implementations (900007), the CI workflow template, the surface-delta subcommand and the
  integration hook (#1034).
- Judging prose correctness; the matrix `accurate` dimension records a reviewer's judgment.
- Changes to 1020 schemas or modules other than the three dispatch rows, and any change to discovery
  files or the Python discovery runtime.
- Binding page content bytes in the receipt.
- Any Python or TypeScript file, and any new PowerShell module dependency.
