# docs-enforcement-and-ci (Issue #1034)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/docs-enforcement-and-ci/ (Issue #1034)
- Parent epic: #1019 (documentation-estate-tooling), child `docs-enforcement-and-ci` (wave 2, C3)
- Depends on: #1021 (docs-page-quality-checker, `check` subcommand) and #1023 (docs-coverage-ledger-and-receipt, `validate -Mode docs-complete` and the persisted receipt)

- Issue: #1034
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1034
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

The documentation-estate tooling of epic #1019 can check pages and emit a `docs-complete`
receipt, but nothing enforces either result. A destination repository can change its documentable
surface (for example add a CLI command) without changing its coverage ledger, and an epic
integration branch can merge to `main` without a passing receipt for its head revision. In one
consumer repository, a feature epic changed 138 `src/` files while only 4 of 79 documentation
pages were edited, and the gap was found by hand. The epic's correspondence half needs a CI
surface, a merge gate, and a review check that act on the tooling's results.

## Proposed Behavior

- A consumer reusable workflow `_docs-quality.yml` runs `pwsh` with
  `.claude/lib/docs/Invoke-DocsCommand.ps1` `check` and `validate -Mode docs-complete`. It is
  delivered as a template row that `Invoke-DocsCommand.ps1 -Command init` writes from
  `.claude/lib/docs/templates/` (the delivery contract decided by #1020).
- A new PowerShell module `.claude/lib/docs/DocsSurfaceDelta.psm1` and the subcommand
  `surface-delta -Base <ref>` (one dispatch-table row under this child's anchor in
  `Invoke-DocsCommand.ps1`) report surface elements added or changed since a base revision that
  have no matching ledger change.
- A PowerShell hook `.claude/hooks/enforce-docs-complete-gate.ps1`, opt-in through the consumer
  profile, denies the epic integration-to-`main` merge unless a passing persisted receipt pins the
  head revision. Disabled by default.
- `.claude/settings.json` registers the hook; `.claude/agents/feature-review.md` and its Codex,
  Copilot and push-down mirrors gain a surface-change-without-ledger-change check.
- All pushed-down code is PowerShell; linting remains optional (owner decision D4).

## Acceptance Criteria (early draft)

- [ ] With the gate disabled (default) the hook allows every call; enabled, it denies when the receipt is absent, failing, or pinned to another revision, and the deny text names the reason.
- [ ] `surface-delta` reports an added CLI command with no ledger change and reports nothing when the ledger records it.
- [ ] The workflow template requires `pwsh` only.
- [ ] Mirror parity checks pass for the edited `feature-review` surfaces.

## Constraints & Risks

- Language rule (owner directive 2026-10-30, refined): pushed-down helpers, hooks and libs are
  PowerShell or bash; TypeScript only for MCP and extension commands; no new Python.
- Pure functions take strings and hashtables; tests create no temporary files.
- The hook and its registration are pushed down; mirror parity, pack-manifest completeness and
  dependency-closure contract tests apply.
- Upstream contracts (#1020, #1021, #1023) are being re-prepared concurrently; this child takes
  them from the epic document.

## Test Conditions to Consider

- [ ] Pester unit suites for `DocsSurfaceDelta.psm1` and the hook (hook suite under `tests/scripts/claude-hooks/`)
- [ ] Template-row test for the `init` workflow template
- [ ] Mirror parity tests for `feature-review` surfaces

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create the active feature folder from the template
