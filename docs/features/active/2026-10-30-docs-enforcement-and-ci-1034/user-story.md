# `docs-enforcement-and-ci` — User Story

- Issue: #1034
- Parent epic: #1019 (documentation-estate-tooling, child `docs-enforcement-and-ci`, anchor label `900008`, wave 2)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Specification: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md` (authoritative for design, owner questions and upstream contract notes)

## Story Statement

- As an epic owner in a destination repository, I want the epic integration-to-`main` merge to be denied unless a passing `docs-complete` receipt pins the pull request head revision, so that documentation correspondence is proven before the epic lands.
- As a destination repository maintainer, I want the merge gate to be opt-in and disabled by default, so that adopting the documentation tooling does not block any merge until I enable it in the docs profile.
- As a feature developer, I want `surface-delta -Base <ref>` to list surface elements I added or changed without a ledger change, so that I can update the coverage ledger before review.
- As a destination repository maintainer, I want `init` to write a reusable `_docs-quality.yml` workflow that needs only `pwsh`, so that CI runs the page check and `docs-complete` validation without a Python or Node.js runtime.
- As a reviewer, I want `feature-review` to raise a Blocking finding when a branch changes documentable surface without surface-delta evidence of a matching ledger change, so that drift is caught at review rather than found by hand.
- As a framework maintainer, I want every new file mirrored to the push-down trees and listed in the core pack manifest, so that destination repositories receive the hook, its library and its registration together.

## Problem / Why

The documentation-estate tooling of epic #1019 can check pages and emit a `docs-complete`
receipt, but nothing enforces either result. A destination repository can change its documentable
surface (for example, add a CLI command) without changing its coverage ledger, and an epic
integration branch can merge to `main` without a passing receipt for its head revision. In one
consumer repository, a feature epic changed 138 `src/` files while only 4 of 79 documentation
pages were edited, and the gap was found by hand. The correspondence half of the epic needs a CI
surface, a merge gate, and a review check that act on the tooling's results.

## Personas & Scenarios

- Persona: Epic owner in a destination repository
  - Runs epics through an `epic/<slug>-integration` branch created from `origin/main`.
  - Cares that the documentation estate is complete when the epic merges.
  - Constraint: the destination has PowerShell 7.4 and the pushed-down Claude core pack; no Python or Node.js is required.
  - Frustration: documentation drift across many source files is found only by manual counting.
- Persona: Feature developer
  - Adds or changes CLI commands, routes, configuration keys or public symbols.
  - Wants a fast, local signal of which elements still need a ledger disposition.
- Persona: Reviewer (`feature-review` on the Claude, Codex or Copilot surface)
  - Inspects pre-existing evidence and does not rerun tooling.
  - Needs a deterministic rule for when a surface change without a ledger change blocks the review.

- Scenario: Gated integration merge
  1. The epic owner sets `completion_gates.integration_pr_gate.enabled` to `true` in `docs/documentation-estate/docs-profile.json`.
  2. At the integration branch head, the owner runs `validate -Mode docs-complete` with the write-receipt switch, which persists the receipt at `artifact_paths.validation_receipt`.
  3. The owner runs `gh pr merge` for the integration-to-`main` pull request.
  4. The hook resolves the pull request head with one bounded `gh pr view` call, reads the receipt, and allows the merge because the receipt passes and its revision equals the head.
  5. If a later commit is pushed and the receipt is not regenerated, the hook denies with `DOCS_COMPLETE_GATE_BLOCKED: RECEIPT_REVISION_MISMATCH` naming both revisions; the owner regenerates the receipt and retries.
- Scenario: Disabled default
  1. A maintainer installs the core pack and runs `init`; the starter profile sets the gate to `false`.
  2. Every Bash call, including `gh pr merge`, is allowed, and the hook makes no `gh` call.
- Scenario: Surface delta before review
  1. A developer adds a CLI command and regenerates the inventory snapshot.
  2. `surface-delta -Base origin/main` exits 1 with `DOCS_SURFACE_UNLEDGERED_ADDITION` naming the new element.
  3. The developer records a disposition with `update-ledger`, reruns `surface-delta`, and it exits 0.
  4. The developer records the run as `<FEATURE>/evidence/qa-gates/docs-surface-delta.<timestamp>.md`; `feature-review` reads that artifact.
- Scenario: Consumer CI
  1. A maintainer runs `init -Write`, which creates `.github/workflows/_docs-quality.yml` and refuses to overwrite an existing file without `-Force`.
  2. The maintainer adds a caller job; CI runs `inventory`, `check`, `validate -Mode docs-complete` and, when a base ref is supplied, `surface-delta`, all through `pwsh`.

## Acceptance Criteria

Epic criteria:

- [ ] With the gate disabled (default) the hook allows every call; enabled, it denies when the receipt is absent, failing, or pinned to another revision, and the deny text names the reason.
- [ ] `surface-delta` reports an added CLI command with no ledger change and reports nothing when the ledger records it.
- [ ] The workflow template requires `pwsh` only.
- [ ] Mirror parity checks pass for the edited `feature-review` surfaces.

Story criteria (consistent with `spec.md` `## Acceptance Criteria`):

- [ ] With no profile, or with `completion_gates.integration_pr_gate.enabled` set to `false`, the hook allows every tested Bash command, including `gh pr merge` variants and `gh api` merge mutations, and makes no `gh` call.
- [ ] With the gate enabled, an integration-to-`main` merge is denied with `DOCS_COMPLETE_GATE_BLOCKED:` followed by `RECEIPT_ABSENT`, `RECEIPT_UNREADABLE`, `RECEIPT_MODE`, `RECEIPT_FAILING` or `RECEIPT_REVISION_MISMATCH` (naming both revisions) as applicable, and is allowed when the receipt passes and its revision equals the pull request `headRefOid`.
- [ ] With the gate enabled, the hook denies with `PROFILE_UNREADABLE`, `PR_UNRESOLVED`, `MATCH_HEAD_MISMATCH` or `RECEIPT_PATH_INVALID` in the corresponding conditions, and allows non-merge commands and merges that are not base `main` with an `epic/<slug>-integration` head.
- [ ] The hook is registered in `.claude/settings.json` and its byte-identical bundle copy, and the registered-hook contract suites (dependency guard completeness, imported-module output silence, no interpreter invocation, payload contract, dependency-failure prefixes, settings membership) pass with no new exemption.
- [ ] `surface-delta` exits 1 with `DOCS_SURFACE_UNLEDGERED_ADDITION` for an added `cli-command` element with no ledger change, and exits 0 with no `error` finding when the head ledger records that element.
- [ ] `surface-delta` reports unledgered changed elements, ignores `line_range`-only and `analysis_method`-only differences, treats an absent base snapshot as empty, rejects an option-like or `..` `-Base` with exit 2, and reports an unresolved base, a missing head snapshot and a stale head snapshot with their finding codes.
- [ ] The `surface-delta` row sits directly under the `# --- 900008: surface-delta ---` anchor, and the diff of the shared entry and init modules contains only added lines under the 900008 anchors (and the OQ-1 context members if assigned to this child).
- [ ] `init` plans `.github/workflows/_docs-quality.yml` without `-Write`, writes it with `-Write`, and refuses an existing destination without `-Force`; the template uses `shell: pwsh` for every step, runs `check` and `validate -Mode docs-complete` through `Invoke-DocsCommand.ps1`, and contains no Python, Node.js or linter step.
- [ ] `## Documentation Surface Check` is present in the procedure-bearing `feature-review` copies named in `spec.md` and each bundle copy is byte-identical; the delegating `feature-review` files are unchanged.
- [ ] Every new `.claude/lib/docs/` file and the hook are listed once in the core pack manifest and byte-identical to their bundle copies, and the push-down resource, completeness, dependency-closure and Codex generator checks pass.
- [ ] Pester line coverage is at least 85% for each new PowerShell production file, with no production file excluded from measurement.
- [ ] No Python or TypeScript file is added or modified, and no test creates a temporary file.

## Non-Goals

- No required linter (D4); no Python or Node.js step in the workflow template.
- No Codex twin of the hook (OQ-4 provisional default) and no MCP tool for `surface-delta` (OQ-7 provisional default).
- No gate on a direct `git push` to `main`.
- No change to the `check`, `inventory` or `validate` subcommands or to another child's dispatch or template rows.
- No change to this repository's own `.github/workflows/`.

## Owner Questions

The provisional defaults of OQ-1 to OQ-7 in `spec.md` `## Owner Questions` apply to this story. None is
decided beyond its provisional default, and an owner answer may change the affected acceptance criteria
in both files.
