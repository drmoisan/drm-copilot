# docs-coverage-ledger-and-receipt (Issue #1023)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-coverage-ledger-and-receipt/ (Issue #1023)
- Parent epic: #1019 (`docs/features/epics/documentation-estate-tooling/epic.md`, wave 1, band C4)
- Depends on: #1020 (docs profile and artifact schemas)

- Issue: #1023
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1023
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

A destination repository can inventory its documentable surface, but nothing records whether each
surface element is documented, nothing binds elements to pages, and nothing detects that a page
describes code that has since changed. In one consumer repository a feature epic changed 138 `src/`
files while only 4 of 79 documentation pages were edited, and the gap was measured by hand. This
feature is the correspondence core of the documentation-estate epic: the coverage ledger, the parity
matrix, evidence pins with staleness detection, and the `docs-complete` validation receipt that
later features expose through MCP tools (900007) and enforce in CI and hooks (900008).

## Proposed Behavior

Add to `packages/docs-runtime/src/drm_copilot_docs/` the ledger models and rules
(`ledger_models.py`, `ledger_rules.py`), the parity matrix (`parity_models.py`, `parity_rules.py`,
`parity_scoring.py`), evidence pins and staleness (`evidence_pins.py`, `staleness.py`), the receipt
(`receipt.py`), validation with modes `profile`, `ledger`, `matrix` and `docs-complete`
(`validation.py`), a single write boundary following discovery `mutation_io` (`mutation.py`), a
coverage report (`coverage_report.py`), and three console commands: `dev.docs.coverage`
(`cli_coverage.py`), `dev.docs.update-ledger` (`cli_ledger.py`) and `dev.docs.validate`
(`cli_validate.py`). Ledger dispositions are `documented` (requires at least one page binding),
`excluded` (requires a rationale) and `deferred` (requires an owner and a target). Parity
dimensions are `exists`, `accurate`, `example_present`, `owner_assigned` and `diataxis_mode`. The
models build on the schemas and surface model delivered by #1020 and reuse
`drm_copilot_discovery` revision, evidence and mutation patterns as a library without changing
discovery behavior. Pure cores take in-memory inputs; I/O stays in the thin CLI modules.

## Acceptance Criteria (early draft)

- [ ] A ledger missing a disposition for any inventoried element fails validation naming the element; `excluded` without rationale and `deferred` without owner or target fail.
- [ ] A pin whose recorded digest differs from the current snapshot marks the bound page stale.
- [ ] `dev.docs.validate --mode docs-complete` emits a receipt on success; with one undocumented element and one stale page it exits non-zero and the message names both.
- [ ] Ledger and matrix writes happen only through `mutation.py`; `dev.docs.update-ledger` is the only CLI that mutates the ledger.
- [ ] Line coverage >= 85% and branch coverage >= 75%.

## Constraints & Risks

- Builds on contracts planned by #1020 (not yet executed); execution waits until #1020 merges.
- Append-only conflicts in the root `pyproject.toml` `[tool.poetry.scripts]` table with other wave-1 children.
- Framework code stays domain-neutral; no consumer identifier appears in source.
- Tests create no temporary files.

## Test Conditions to Consider

- [ ] Unit coverage areas: ledger rules, parity rules and scoring, pins and staleness, receipt, validation modes, mutation boundary
- [ ] Integration scenarios: docs-complete validation over an in-memory fixture with one undocumented element and one stale page
- [ ] CLI/API examples: `dev.docs.coverage`, `dev.docs.update-ledger`, `dev.docs.validate --mode docs-complete`

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/docs-coverage-ledger-and-receipt/` folder from the template
