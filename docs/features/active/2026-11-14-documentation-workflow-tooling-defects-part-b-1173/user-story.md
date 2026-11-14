# `2026-11-14-documentation-workflow-tooling-defects-part-b` — User Story

- Issue: #1173
- Owner: drmoisan
- Status: Approved for planning
- Last Updated: 2026-11-14

## Story Statement

- As a docs-workflow consumer (the root session running `/documentation-workflow` in a repository), I want a first inventory run, starter profile, inventory, and `check` to complete without stop-hook loops, crashes, or manual profile edits, so that a new documentation estate can be created in one pass.
- As a docs reconciler (the `docs-reconciler` role and its operator), I want to apply thousands of ledger operations and bind page references in one supported call, so that reconciling an estate of about 3,000 elements takes minutes instead of days.
- As a docs author (the `docs-author` and `docs-architect` roles and the operator who plans pages), I want templates, generated reference pages, and CLI analysis to produce valid, tracked pages, and I want the naming restrictions documented, so that pages pass `check` and their accuracy is tracked without hand-written workarounds.

## Problem / Why

The first consumer run of `/documentation-workflow` (issue #1169, Part B) completed only with manual workarounds:

- The docs-architect role repeated its report for about 93 minutes because the stop hook required a snapshot the role cannot write (B1).
- One `update-ledger` call costs about 39 s and in-process merges are quadratic, so a 3,061-element estate needed hours through the supported path (B2), and the pin ordering for `accurate = pass` was undocumented (B3).
- Templates failed the page checker (B4); generated API reference exceeded the page bound (B5); the starter profile named a non-existent source root (B6) and a documentation root whose planning files crashed `check` (B7); inventory read bytecode caches (B8); the Python CLI analyzer missed cross-module subcommands (B9).
- Two observations needed verification (B10 diagnostic parity, B11 line-ending stability of hashes), a runtime guard refused a page name without explanation (B12), and docs-init added a CI workflow without saying so (B13).

## Personas & Scenarios

- Persona: Docs-workflow consumer
  - The root session (and its operator) that runs docs-init, inventory, planning, authoring, reconciliation, review and validation in a consumer repository.
  - Cares about a run that completes without loops, crashes, or hand-edited profiles.
  - Constraints: runs with no orchestration checkpoint; subagent roles hold restricted tools; the repository may use CRLF checkouts.
  - Frustration: about 93 minutes and about 652k tokens lost to a stop-hook loop with no real fault.
- Persona: Docs reconciler
  - The `docs-reconciler` role (no Write tool) and the operator who drives ledger updates.
  - Cares about throughput and about writes that are either complete or not applied.
  - Constraints: the role can pass operations inline through MCP only; the ledger must stay byte-stable and schema-valid.
  - Frustration: about 15,300 single-element calls for one estate; undocumented pin ordering rejected 2,675 operations.
- Persona: Docs author
  - The `docs-author` and `docs-architect` roles and the operator who plans the information architecture.
  - Cares about templates and generated pages that pass `check`, and about every page being tracked by `surface_refs`.
  - Constraints: page size bound of 1 MiB; subagent writes of some file names are refused by the runtime.
  - Frustration: four filtered generation runs with scratch snapshots inside the repository; a hand-written CLI reference with `surface_refs: []`.

- Scenario: First inventory run (consumer)
  1. The operator runs docs-init in a repository whose package lives at the root; init selects the package directory as the source root, uses `docs/guide` as the documentation root, and reports a distinct `ci-workflow` line.
  2. The root runs `inventory -Write`, which skips `__pycache__` and other default-excluded paths, then delegates docs-architect.
  3. The docs-architect report names the persisted snapshot; the stop hook checks its relative form and accepts the report on the first attempt.
  4. `check` reports a malformed link as `DOCS_PAGE_LINK_BROKEN` and exits 1; it does not exit 3.
- Scenario: Bulk reconciliation (reconciler)
  1. After authoring, the reconciler issues one `bind-page-refs` operation, which marks every element referenced in page `surface_refs` as `documented` with its pages.
  2. The reconciler sends one `update_docs_ledger` call with an `operations` array covering dispositions, existence, owners, and `accurate pass` items carrying a `claim`.
  3. The batch loads once, applies every operation, and writes once; one invalid item rejects the whole batch and names its index, and nothing is written.
  4. The estate's artifact hashes remain valid after the files are checked out with CRLF line endings.
- Scenario: Large reference and CLI pages (author)
  1. The author runs `generate-reference -Write` for a package with about 2,600 public symbols; the API family is emitted as an index page plus per-package group pages, each below the bound.
  2. The author narrows a run with `-PathPrefix` instead of copying a filtered snapshot.
  3. The CLI analyzer now emits commands registered through `register(subparsers)` functions in other modules, so the CLI reference page lists real `surface_refs`.
  4. The author plans file names without `report`, `summary`, `findings` or `analysis`, as the skills now state, or leaves such a page to the root.

## Acceptance Criteria

- [x] Consumer (B1): a docs-architect report on a first run (profile present, snapshot not yet persisted, relative snapshot path, `PASS`) is accepted by the stop hook on the first attempt, and the documentation-workflow skill directs the root to run `inventory -Write` before delegating the inventory role.
- [x] Consumer (B6): `validate-profile` and `init` report `DOCS_PROFILE_SOURCE_ROOT_MISSING` for a source root with no files, and `init` selects `src`, else the `pyproject.toml` package directory, else retains `src` (which then reports `DOCS_PROFILE_SOURCE_ROOT_MISSING`).
- [x] Consumer (B7): `check` reports a malformed link target as `DOCS_PAGE_LINK_BROKEN` with exit 1 instead of exiting 3, and a starter profile uses `docs/guide` as its documentation root.
- [x] Consumer (B8): inventory does not read or report bytecode caches, VCS directories, or the other default-excluded tool directories.
- [x] Consumer (B10): a Pester parity test shows the CLI text and JSON outputs report the same diagnostic count including `DOCS_INPUT_NOT_UTF8`, and a Jest test shows the MCP handler returns those diagnostics unchanged.
- [x] Consumer (B11): estate artifact hashes are equal for LF and CRLF forms of the same content, LF estates keep their stored hashes, and `update-ledger` over CRLF-encoded estate bytes reports no reference drift.
- [x] Consumer (B13): `init` reports the CI workflow on a distinct `ci-workflow <path>` line and in a `ci_workflow` result field, and the docs-init skill states in Steps and Result that init adds it.
- [ ] Reconciler (B2): `update-ledger -Operations` (file or standard input) and MCP `update_docs_ledger.operations` apply a batch with one load and one write, produce output byte-identical to sequential application, and write nothing when any item is invalid.
- [ ] Reconciler (B2): `bind-page-refs` binds every snapshot element referenced in page `surface_refs` as `documented` with the union of its pages, without removing bindings, and is idempotent.
- [ ] Reconciler (B2): a measured CLI batch run on an estate of at least 3,000 elements with at least 15,000 operations completes in at most 10 minutes and is recorded as feature evidence.
- [ ] Reconciler (B3): the reconcile skill and reconciler agent state that `pin` precedes `set-dimension accurate pass`, and a batch `accurate pass` item with a `claim` is applied without `DOCS_MATRIX_ACCURACY_UNPINNED`.
- [x] Author (B4): every page template declares `audience` as a list and passes the page front-matter checker after placeholder substitution.
- [ ] Author (B5): generated reference families above the split budget are emitted as an index page plus group pages that each pass the page size bound, and `-PathPrefix` (CLI) and `path_prefixes` (MCP) filter elements without a snapshot copy.
- [ ] Author (B9): subcommands and options registered through a `subparsers` parameter in another module appear as `cli-command` and `cli-option` elements in both analyzer paths.
- [x] Author (B12): the docs-plan-ia and docs-author-page skills and the docs-author agent document the runtime naming restriction and the root fallback.
- [ ] Every item B1-B13 has a regression test, mirror and bundle copies stay in parity, the full toolchain loop passes, and CI is green on the final pull request head.

## Non-Goals

- Part A (A1-A5) of #1169, delivered in PR #1175.
- Changing or exempting the Claude Code runtime report-file guard (B12); it is outside the repository.
- Any production change for B10 beyond the parity tests that confirm the refuted verdict.
- Changing element `source_sha256` digests (B11 refuted for them) or writing `.gitattributes` from docs-init.
- Profile schema changes (no `diataxis_policy` grouping key, no root-level exclusion list) and `-Snapshot` paths outside the repository.
- Package-root detection from `package.json` or `.csproj` (B6); the `validate-profile` error covers those layouts.
