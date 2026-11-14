# Task Check P1-T1

Timestamp: 2026-11-14T07-21
Command: grep -n over spec.md and user-story.md for a single-dot code span, DOCS_PROFILE_SOURCE_ROOT_MISSING and a "target" example key; grep -rln of tests/ and extensions/drm-copilot/test/ for the feature folder name
EXIT_CODE: 0
Output Summary:
- Changed files: docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/spec.md, docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/user-story.md.
- Selection rule: for a changed Markdown path, the contract tests that read that path. Search of tests/ and extensions/drm-copilot/test/ for the feature folder name returned no file, so the selection is empty; no format, lint or type check applies to these Markdown files.
- Acceptance observations:
  - spec.md `### B6` rule 2 now ends the detection order with "when neither lists files, `src` is retained" and names DOCS_PROFILE_SOURCE_ROOT_MISSING (PC-1); the B6 tests bullet names "the retained `src` fallback"; the spec B6 acceptance criterion and the user-story Consumer (B6) criterion end with "else retains `src` (which then reports `DOCS_PROFILE_SOURCE_ROOT_MISSING`)". The `### B6` package-root bullet no longer offers `.`.
  - The only remaining single-dot code span in spec.md is inside the PC-1 explanation ("a `.` source root is not a valid repository-relative path"), which does not end a detection order. user-story.md has none.
  - DOCS_PROFILE_SOURCE_ROOT_MISSING count: spec.md 4 lines, user-story.md 1 line.
  - The `## API / CLI Surface` example item uses `"pages": ["docs/guide/api.md"]` instead of `"target"` (no `"target"` key remains), and `#### B2.1 Operations document` states that `pin`, `unpin` and `set-dimension` take the page in `pages` (PC-2). The plan cites the example under `### B2.1`; it is in `## API / CLI Surface`, so both places were corrected.
