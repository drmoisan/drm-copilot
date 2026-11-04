# Remediation Inputs: Issue 1024 Docs Reference Generator

Timestamp: 2026-11-04T14-13
Remediation-Mode: proportionate
Source review: code-review.2026-11-04T14-03.md, policy-audit.2026-11-04T14-03.md, feature-audit.2026-11-04T14-03.md (verdict AWAITING_CI)
Branch: feature/docs-reference-generator-1024-r2

## Context

The review recorded no autonomous blocking finding. This cycle fixes one related non-blocking finding inside the item, per the repository practice that related findings are remediated before merge rather than filed as follow-up issues. The branch head also now contains a merge of `origin/epic/documentation-estate-tooling-integration` that brings in issue 1022 (the docs surface analyzers), which auto-merged `.claude/lib/docs/Invoke-DocsCommand.ps1`, its bundle mirror, and `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; the affected suites are re-run in this cycle.

## Findings

### R1 Broad catch in the front-matter serializer fallback

- Source: code-review.2026-11-04T14-03.md (Minor, non-blocking); policy-audit.2026-11-04T14-03.md (Fail fast, no silent catch: PARTIAL, non-blocking).
- Remediability: autonomous.
- Location: `.claude/lib/docs/DocsReferenceFrontMatter.psm1`, function `ConvertTo-DocsReferenceFrontMatterText`, the `try`/`catch` around `ConvertTo-DocsCanonicalJson`; and its bundle mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.
- Rule: `.claude/rules/general-code-change.md`, Error Handling and Logging: no broad catch-all handler unless it re-raises or propagates with context.
- Required change: narrow the fallback to the documented case (canonical JSON rejecting a non-integral number inside `extensions`). Any other exception from `ConvertTo-DocsCanonicalJson` must propagate. Add Pester tests in `tests/scripts/claude-lib/docs/` proving both the fallback case and the propagation case. Keep the source and bundle mirror byte-identical.

### R2 Re-verification after the integration merge

- Remediability: autonomous.
- Required change: none to code unless a failure appears. Re-run the docs Pester suites under `tests/scripts/claude-lib/docs/`, the push-down contract pytest modules, and the analyzer and formatter over the changed files on the merged head; record the evidence.
