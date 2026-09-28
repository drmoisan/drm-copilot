# Scope: Builder Hunks ([P9-T3])

Timestamp: 2026-09-26T22-29

Command: `git diff -U0 b67453837646fd2dd4f5ac692f76e6f7703fe798 -- extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts extensions/drm-copilot/src/lib/pr-context/autoclose.ts scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/autoclose.py`

EXIT_CODE: 0

Output Summary:
- Hunk headers (verbatim):
  - `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`: `@@ -235,0 +236,2 @@ export function buildCloseCandidatesSection(params: {`
  - `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`: `@@ -274,0 +277,4 @@ export function buildIssuesToAutocloseSection(params: {`
  - `scripts/dev_tools/pr_context/render_pr_helpers.py`: `@@ -258,0 +259,3 @@ def build_issues_to_autoclose_section(`
  - `scripts/dev_tools/pr_context/render_pr_helpers.py`: `@@ -284,0 +288,4 @@ def build_issues_to_autoclose_section(`
- Hunks appear only in `<TS_BUILDER_FILE>` (`autoclose.ts`, PARAM-ONLY) and `<PY_BUILDER_FILE>` (`render_pr_helpers.py`, PARAM-ONLY). No hunk in `render-pr-helpers.ts` or `autoclose.py`.
- Containment (old side = sync-SHA tree; count 0, so the span is `<start>` alone): TS 235 and 274 lie within `TS_BUILDER_RANGE: 228-287` (235 is inside the builder's doc comment, which opens at 228; the hunk-context label names the preceding function because the doc comment follows it); Python 258 and 284 lie within `PY_BUILDER_RANGE: 237-298`.
- Every hunk has old-side count 0; the diff contains no removed line (no `-` line other than `---` headers), matching the PARAM-ONLY pure-insertion rule.
- Consequently no removed line contains either available-state fallback string, `formatList(`, `format_list(`, `AUTOCLOSE_UNVERIFIED_ANNOTATION`, `pendingPrimaryExcluded`, or `pending_primary_excluded`. The non-empty rendering and #622's exclusion and annotation code are unmodified.
