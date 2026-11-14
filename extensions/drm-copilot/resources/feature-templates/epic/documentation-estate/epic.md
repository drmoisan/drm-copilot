---
epic: documentation-estate
integration_branch: epic/documentation-estate-integration
# Replace created_at with the UTC time at which this epic is created, in the same form.
created_at: 2026-01-01T00:00:00Z
intent:
  epic_type: enabler
  business_outcome_hypothesis: A repository that adopts the documentation-estate tooling keeps its reference and narrative pages in correspondence with its code, proven by a passing docs-complete receipt at the head revision instead of manual review of drift.
  leading_indicators:
    - The inventory snapshot of the repository is pinned to a full revision and every element has a ledger disposition.
    - Generated reference pages are byte-identical when regenerated from the same snapshot.
    - The docs-complete validation of the integration branch head passes without deferred entries.
  nfrs:
    - The docs-complete receipt passes at the head revision of the integration branch before the epic closes.
    - No consumer identifier appears in documentation produced by the framework; repository specificity lives in the docs profile.
    - Linting is optional; the page check is the required page gate.
    - PowerShell 7.4 or later is the only required runtime for the helpers.
# PLANNING STATE: issue_num values 900001 to 900011 are placeholders. /epic-plan back-fills the
# real issue numbers when each child is promoted; depends_on uses issue_num values.
features:
  - issue_num: 900001
    feature_folder: docs-profile-and-init
    depends_on: []
  - issue_num: 900002
    feature_folder: docs-information-architecture
    depends_on: []
  - issue_num: 900003
    feature_folder: docs-page-templates
    depends_on: []
  - issue_num: 900004
    feature_folder: docs-page-metadata
    depends_on: []
  - issue_num: 900005
    feature_folder: docs-ci
    depends_on: []
  - issue_num: 900006
    feature_folder: docs-reference-pages
    depends_on: [900001, 900002, 900003, 900004, 900005]
  - issue_num: 900007
    feature_folder: docs-how-to-pages
    depends_on: [900001, 900002, 900003, 900004, 900005]
  - issue_num: 900008
    feature_folder: docs-tutorial-pages
    depends_on: [900001, 900002, 900003, 900004, 900005]
  - issue_num: 900009
    feature_folder: docs-explanation-pages
    depends_on: [900001, 900002, 900003, 900004, 900005]
  - issue_num: 900010
    feature_folder: docs-architecture-pages
    depends_on: [900001, 900002, 900003, 900004, 900005]
  - issue_num: 900011
    feature_folder: docs-complete-exit-gate
    depends_on: [900006, 900007, 900008, 900009, 900010]
---

# documentation-estate - Epic

- Issue: assigned by `/epic-plan`
- Owner: replace with the epic owner
- Last Updated: replace with the date of the first edit

## Goal

Build a documentation estate for this repository: a docs profile, an information architecture,
reference pages generated from the inventoried code surface, narrative how-to, tutorial,
explanation and architecture pages, and a coverage ledger that records a disposition for every
documentable element. The epic closes when `validate -Mode docs-complete` passes at the head
revision of the integration branch and its receipt is pinned to that revision.

## Scope

- Initialize the docs profile and the page-check configuration with `init -Write`.
- Plan the information architecture and the page templates and metadata the pages share.
- Deliver the docs CI workflow that `init` writes.
- Generate reference pages with `generate-reference -Write` and author the narrative page families.
- Record every element in the coverage ledger with `update-ledger` and pin the pages that document it.
- Pass `validate -Mode docs-complete` at the head revision.

## Non-Goals

- Building a documentation site or choosing a site generator.
- Adopting a Markdown or prose linter as a required gate; linting stays optional.
- Changing the code surface in order to make it easier to document.

## Shared Design

- Roles and skills: the agents `docs-architect`, `docs-author`, `docs-reconciler` and
  `docs-coverage-reviewer`, and the skills `documentation-workflow`, `docs-init`,
  `docs-inventory-surface`, `docs-plan-ia`, `docs-author-page`, `docs-reconcile-behavior`,
  `docs-review-coverage` and `docs-validate`. The sequence is inventory, plan, author, reconcile,
  review and validate.
- `analysis_method`: every inventory snapshot element and every ledger entry records whether the
  element was found by the native Python analyzer (`native`) or by the PowerShell scanner
  (`scanner`). The optional python pack enables the native analyzer; without it the scanner is used.
- Linting is optional: `init -Write` writes linter configuration as data, and `check` is the required
  page gate.
- Prerequisite: PowerShell 7.4 or later on PATH as `pwsh`, locally and on the CI runner.
- Receipts: only the root session or CI persists a `docs-complete` receipt.

## Child Features

### 900001 - docs-profile-and-init

Create the docs profile and the page-check configuration.

Acceptance criteria:

- `init -Write` has written the docs profile and the page-check configuration files.
- `validate-profile` exits 0 for the committed profile.

### 900002 - docs-information-architecture

Plan the documentation roots, page families and navigation.

Acceptance criteria:

- The docs profile declares every documentation root and page owner.
- The planned page list names one owner per page.

### 900003 - docs-page-templates

Define the page templates that each page family uses.

Acceptance criteria:

- Every page family has a template whose headings follow its documentation mode.
- `check` exits 0 for a page created from each template.

### 900004 - docs-page-metadata

Define the page metadata (front matter) that every page carries.

Acceptance criteria:

- Every page template carries the metadata fields the profile requires.
- `check` reports no metadata finding for the template pages.

### 900005 - docs-ci

Deliver the docs CI workflow.

Acceptance criteria:

- The `_docs-quality.yml` workflow written by `init` runs `check` on pull requests.
- The workflow runner provides PowerShell 7.4 or later as `pwsh`.

### 900006 - docs-reference-pages

Generate the reference pages from the inventory snapshot.

Acceptance criteria:

- `inventory -Revision <full revision> -Write` has written a snapshot pinned to that revision.
- `generate-reference -Write` has written the reference pages, and a second run changes no byte.
- Every reference element has a ledger disposition and a pin to its page.

### 900007 - docs-how-to-pages

Author the how-to pages.

Acceptance criteria:

- Every planned how-to page exists and `check` exits 0 for it.
- Every element a how-to page documents has a ledger binding and a pin to that page.

### 900008 - docs-tutorial-pages

Author the tutorial pages.

Acceptance criteria:

- Every planned tutorial page exists and `check` exits 0 for it.
- Every element a tutorial page documents has a ledger binding and a pin to that page.

### 900009 - docs-explanation-pages

Author the explanation pages.

Acceptance criteria:

- Every planned explanation page exists and `check` exits 0 for it.
- Every element an explanation page documents has a ledger binding and a pin to that page.

### 900010 - docs-architecture-pages

Author the architecture pages.

Acceptance criteria:

- Every planned architecture page exists and `check` exits 0 for it.
- Every architecture component in the snapshot has a ledger disposition.

### 900011 - docs-complete-exit-gate

Prove documentation correspondence at the head revision.

Acceptance criteria:

- `validate -Mode docs-complete -Revision <head> -WriteReceipt` exits 0, and the persisted receipt
  has `validation_result` `pass` and is pinned to the head revision.
- Optional: `completion_gates.integration_pr_gate.enabled` is set to `true` in the docs profile, so
  the integration pull request is gated on that receipt.

## Decomposition Rationale

The foundation children (profile and `init`, information architecture, page templates, page
metadata, docs CI) have no dependency on each other and run in wave 0. Every page family needs all
of them: the profile and roots, the planned pages, the templates, the metadata rules and the CI
check. The page families are independent of each other and run in wave 1. The exit gate validates
the whole estate, so it depends on every page family and runs alone in the final wave.

## Planned Waves

- Wave 0: 900001, 900002, 900003, 900004, 900005
- Wave 1: 900006, 900007, 900008, 900009, 900010
- Wave 2: 900011
