# docs-prose-markdown-lint (Issue #1219)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1219-docs-prose-markdown-lint/ (Issue #1219)
- Epic: #1217 (documentation-estate-families), wave 0, complexity C3, no dependencies

- Issue: #1219
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1219
- Last Updated: 2026-11-23
## Problem / Why

The workflow template that docs init writes, `.claude/lib/docs/templates/_docs-quality.yml`, copies `.vale.ini` and `.markdownlint.json` into a consumer repository but never runs either tool, so prose and Markdown defects in documentation pages are not reported in CI. The default Vale style set carries no rules tied to the repository tonality policy, and documentation pages have no counted placeholder for content that still needs subject-matter-expert input.

## Proposed Behavior

- Add a Markdown lint step and a Vale step to the init-written `_docs-quality.yml`. Vale is a pinned release downloaded and verified against a pinned SHA-256 before it runs. The workflow follows `.claude/rules/ci-workflows.md` (actions pinned to full commit SHAs, least-privilege `permissions`, and the other rules there).
- Add tonality Vale rules (Certainty, Exclamation, Filler, Hyperbole, Intensifiers) to the default style set that docs init writes. The rules are domain-neutral and are tied to the repository tonality policy (`.claude/rules/tonality.md`). The reference implementation is `styles/RgfTonality/` in the rgf-forecast repository.
- Define the placeholder token `SME input required`. Docs coverage counts its occurrences in page bodies and reports the count in its output (`DocsCoverageReport.psm1`, and the coverage MCP tool output shape if needed). The counter sits in its own function and output section, because the docs-family-gate-and-ia child of the same epic also edits `DocsCoverageReport.psm1`.

## Acceptance Criteria (early draft)

- [ ] The init-written `_docs-quality.yml` runs Markdown lint against the docs pages using the written `.markdownlint.json`.
- [ ] The init-written `_docs-quality.yml` downloads a pinned Vale release, verifies its SHA-256, fails on a mismatch, and runs Vale with the written `.vale.ini`.
- [ ] The default style set written by docs init contains the five tonality rules, and a page containing a hyperbole term produces a Vale error.
- [ ] Docs coverage output reports the count of `SME input required` occurrences in page bodies.
- [ ] Codex, Claude, and Copilot surfaces and bundle copies stay in parity per `config/harness-parity-matrix.json`.

## Constraints & Risks

- No new Python. Implementation is PowerShell 7.4 (the docs library) or bash; TypeScript only for MCP or extension command surfaces.
- Framework code is domain-neutral; repository specificity is runtime configuration.
- `DocsCoverageReport.psm1` is also edited by docs-family-gate-and-ia; keep the change in its own function and section.
- The hook docs-only exemptions admit `.github/workflows/_docs-quality.yml` as the one non-docs path; the workflow destination must not change.
- File-size tiers 500/700/800; no temporary files in tests.

## Test Conditions to Consider

- [ ] Pester tests for the placeholder counter (zero, one, several occurrences; front matter and code fences).
- [ ] Pester content tests for the workflow template (pinned actions, permissions, Vale version and SHA-256, lint steps).
- [ ] Pester tests that docs init writes the tonality style files.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/docs-prose-markdown-lint/` folder from the template
