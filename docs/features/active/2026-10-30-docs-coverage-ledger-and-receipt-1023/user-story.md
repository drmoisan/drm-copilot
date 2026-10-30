# `docs-coverage-ledger-and-receipt` — User Story

- Issue: #1023
- Parent: #1019 (epic documentation-estate-tooling, child 900005)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30

## Story Statement

- As a repository maintainer, I want to measure how much of my inventoried surface is documented,
  deferred, excluded or stale with one read-only command, so that I can see the documentation gap
  without measuring it by hand.
- As a repository maintainer, I want to record a disposition, a page binding, an evidence pin or a
  parity result through one command that previews its changes by default, so that ledger, matrix
  and pin edits are validated and written in one controlled way.
- As a CI pipeline, I want to prove `docs-complete` for a specific revision and persist a receipt,
  so that a merge can be gated on documentation that corresponds to the code at that revision.
- As a downstream tool author (MCP tools or the integration hook), I want stable command
  arguments, exit codes, a JSON output envelope and a receipt with a fixed shape, so that my tool
  can wrap the commands and consume the receipt without parsing free text.

## Problem / Why

A destination repository can inventory its documentable surface, but nothing records whether each
surface element is documented, nothing binds elements to pages, and nothing detects that a page
describes code that has since changed. In one consumer repository a feature epic changed 138 `src/`
files while only 4 of 79 documentation pages were edited, and the gap was measured by hand. This
feature is the correspondence core of the documentation-estate epic: the coverage ledger, the parity
matrix, evidence pins with staleness detection, and the `docs-complete` validation receipt that
later features expose through MCP tools (900007) and enforce in CI and hooks (900008).

## Personas & Scenarios

- Persona: Repository maintainer
  - Maintains a repository that has adopted the documentation estate tooling and has a docs
    profile and a surface inventory snapshot.
  - Cares that every surface element has an explicit disposition and that pages describing changed
    code are identified.
  - Constraints: works from a local checkout; edits ledger artifacts only through the provided
    command; needs to preview a change before writing it.
  - Goals: a coverage measurement and a clean ledger. Frustration: findings that do not name the
    element or page concerned.
  - Context: after a feature changes the surface, before opening a pull request.
- Persona: CI pipeline
  - A non-interactive workflow (delivered by 900008) running on a pull request head revision.
  - Cares that the receipt it persists pins the exact revision it validated and that the result is
    machine-readable.
  - Constraints: no prompts; relies on exit codes and on the persisted receipt file.
  - Goals: a `pass` receipt for the head revision, or a failing exit with named causes.
  - Context: the epic integration pull request and consumer pull requests.
- Persona: Downstream tool author
  - Implements the MCP tools (900007) or the opt-in integration hook (900008).
  - Cares that arguments, exit codes, the output envelope and receipt fields are written down and
    stable.
  - Constraints: the MCP validation tool must not mutate files; only the ledger update tool may.
  - Goals: map structured tool input onto command arguments and read structured results.
    Frustration: contracts implied rather than stated.
  - Context: wave-2 features of the epic.

- Scenario: Maintainer measures coverage
  - Actor: repository maintainer.
  - Trigger: a feature added CLI commands and changed several public symbols.
  - Steps: refreshes the surface inventory snapshot; runs `dev.docs.coverage`; reads the
    undocumented elements, deferred entries, stale pages and per-dimension parity scores.
  - Obstacles and decisions: no ledger exists yet; the command treats it as empty and lists every
    element as undocumented rather than failing.
  - Outcome: the maintainer has a list of the elements and pages that need work; no file changed.
- Scenario: Maintainer records a disposition
  - Actor: repository maintainer.
  - Trigger: the coverage report lists an undocumented CLI command.
  - Steps: runs `dev.docs.update-ledger --operation set-disposition --element <id> --disposition
    documented --page <page> --actor-kind human --actor-id <id>`; reviews the planned writes; repeats
    with `--write`; pins the element to the page with `--operation pin`; records parity results with
    `--operation set-dimension`.
  - Obstacles and decisions: the maintainer first marks another element `excluded` without a
    rationale; the command exits 1, names the missing rationale and writes nothing; the maintainer
    adds `--rationale`.
  - Outcome: the ledger, matrix and pin collection are updated through the single write boundary.
- Scenario: CI proves docs-complete
  - Actor: CI pipeline.
  - Trigger: a pull request is opened against the integration branch.
  - Steps: runs `dev.docs.validate --mode docs-complete --revision <head> --write-receipt --format
    json`.
  - Obstacles and decisions: one element has no disposition and one page pins a declaration whose
    digest changed; the command exits 1, the findings name the element and the page, and a `fail`
    receipt is persisted.
  - Outcome: after the maintainer fixes both, the command exits 0 and persists a `pass` receipt
    pinned to the head revision.
- Scenario: Tool author consumes the receipt
  - Actor: downstream tool author.
  - Trigger: implementing `validate_docs_artifacts` (900007) and the integration hook (900008).
  - Steps: the MCP tool runs `dev.docs.validate --format json` without `--write-receipt` and reads
    `exit_code`, `findings` and the receipt in `result`; the hook reads the persisted receipt file
    and checks `mode`, `validation_result` and `revision`.
  - Obstacles and decisions: an invalid argument returns exit 2 with one `DOCS_CLI_ARGUMENTS`
    finding and a `null` result, which the tool reports as an input error.
  - Outcome: both consumers work from the stated contracts without parsing text output.

## Acceptance Criteria

### Maintainer measuring coverage

- [ ] A maintainer running `dev.docs.coverage` receives the totals, the undocumented elements, the deferred entries, the stale pages and per-dimension parity counts and integer scores, and the command makes no write to any file.
- [ ] When the ledger, matrix or pin collection does not exist yet, `dev.docs.coverage` reports every inventoried element as undocumented and exits 0.
- [ ] A page is reported stale when a pin bound to it records a digest that differs from the current snapshot element, or when the pinned element no longer exists; a revision change alone does not make a page stale.

### Maintainer recording a disposition through update-ledger

- [ ] `dev.docs.update-ledger` without `--write` prints the planned writes and changes no file; with `--write` it writes the ledger, matrix or pin collection through `mutation.py`.
- [ ] Recording `excluded` without a rationale, or `deferred` without an owner or a target, exits non-zero, names the missing field for that element, and writes nothing; existing errors for other elements do not block a valid update.
- [ ] Re-pinning an element to the same page replaces the existing pin instead of adding a second one, and the page is no longer stale.
- [ ] If the ledger changed on disk after the command read it, the write is refused with exit 3 and the conflicting path is named.
- [ ] `dev.docs.update-ledger` is the only command that changes the ledger, matrix or pin collection, as shown by the write-boundary test.

### CI proving docs-complete

- [ ] `dev.docs.validate --mode docs-complete` emits a receipt on success; with one undocumented element and one stale page it exits non-zero and the message names both.
- [ ] A ledger missing a disposition for any inventoried element fails validation naming the element.
- [ ] With `--write-receipt`, the receipt is written to the profile's `validation_receipt` path on both pass and fail, and its `revision` equals the `--revision` argument.
- [ ] Validation of a working-copy snapshot (`revision` `null`) in `docs-complete` mode fails with `DOCS_SNAPSHOT_UNPINNED`, so no receipt claims a revision the snapshot did not capture.

### Downstream tool author consuming the receipt

- [ ] Each of the three commands, with `--format json`, prints exactly one JSON document with the keys `command`, `ok`, `exit_code`, `findings` and `result`, and returns exit 0, 1, 2 or 3 with the meanings stated in the spec.
- [ ] Every emitted receipt validates against the `docs-validation-receipt` schema, and its `id` does not change when only `issued_at` differs.
- [ ] `dev.docs.validate` without `--write-receipt` writes no file in any mode, so an MCP tool that does not pass that option is read-only.
- [ ] An invalid argument returns exit 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and a `null` result, before any input file is read.

### Quality

- [ ] Line coverage >= 85% and branch coverage >= 75% for every new module.

## Non-Goals

- Surface analyzers and snapshot production (900003, 900004); the definition of element
  `source_sha256` (an epic-level decision).
- The reference-page generator (900006) and the page quality checker (900002).
- MCP tool implementations (900007), the CI workflow template, the surface-delta command and the
  integration hook (900008).
- Judging prose correctness; the matrix `accurate` dimension records a reviewer's judgment.
- Changes to the #1020 schemas, models or CLI, or to discovery runtime behavior or files.
- Binding page content bytes in the receipt.
- Adding the `hypothesis` dependency.
