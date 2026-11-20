# legacy-discovery-reports (Issue #368)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-reports/ (Issue #368)
- Epic: legacy-discovery-and-parity (child feature; epic manifest placeholder issue 9010)
- Integration branch: epic/legacy-discovery-and-parity-integration
- Depends on: legacy-discovery-schemas (Coverage Ledger, Parity Matrix), legacy-discovery-validators

- Issue: #368
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/368
- Last Updated: 2026-07-17
- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity capability produces machine-readable discovery artifacts
(a Coverage Ledger and a Parity Matrix). Consumers migrating a legacy application need
deterministic, human-readable reports derived from those artifacts to review coverage,
source-to-target parity, and aggregate completion readiness. Without a reporting layer,
the machine-readable artifacts are not directly consumable by reviewers.

## Proposed Behavior

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

## Scope Boundaries

- In scope: coverage report, parity report, completion report; deterministic rendering;
  input validation via the validators; `dev.discovery.*` CLI entry point(s); tests per
  quality-tier policy.
- Out of scope: MCP tool exposure and VS Code command exposure of these commands (owned by
  feature legacy-discovery-mcp-vscode, #9011).

## Acceptance Criteria (early draft)

- [ ] A coverage report is rendered deterministically from a Coverage Ledger artifact.
- [ ] A parity report is rendered deterministically from a Parity Matrix artifact.
- [ ] A completion report presents aggregate readiness across the discovery artifacts.
- [ ] Given identical input artifacts, report output is byte-identical across runs.
- [ ] Input artifacts are validated (via the validators) before rendering; a malformed
      artifact fails fast with a clear error and non-zero exit code.
- [ ] Report generation is exposed as `dev.discovery.*` Poetry console-script CLI entry
      point(s) following the repository substrate convention.
- [ ] The reporting framework contains no domain-specific identifiers.
- [ ] Tests satisfy quality-tier policy (line >= 85%, branch >= 75%).

## Constraints & Risks

- Determinism: no wall-clock time or RNG in rendered output unless injected via a
  clock/seed per `.claude/rules/general-unit-test.md`.
- Evidence output under `<FEATURE>/evidence/<kind>/` only.
- Upstream contract dependency: report input shapes are defined by the Coverage Ledger and
  Parity Matrix schemas (legacy-discovery-schemas) and the schema-versioning convention;
  validation is delegated to legacy-discovery-validators.

## Test Conditions to Consider

- [ ] Unit coverage: rendering each report type from conforming artifacts.
- [ ] Determinism: repeated runs on identical input produce byte-identical output.
- [ ] Negative: malformed / non-conforming artifact fails fast before rendering.
- [ ] CLI: `dev.discovery.*` entry points return correct exit codes for success and failure.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-reports/` folder from the template
