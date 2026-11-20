# [P5-T1] Specification reconciliation and the four criterion amendments

Timestamp: 2026-11-06T23-47
Command: `git grep -c -e InvokeInterpreter -e Get-DocsDeclarationDigest -e AnalyzerIds -- FEATURE/spec.md`; `git grep -w -c PYTHON_NATIVE_UNAVAILABLE -- FEATURE/spec.md`; the added and removed lines beginning with `- [` in `git diff HEAD` of FEATURE/spec.md and FEATURE/user-story.md
EXIT_CODE: 0
Output Summary: the banned-token search printed nothing; PYTHON_NATIVE_UNAVAILABLE word count 6; the checkbox-line diff of spec.md is exactly the S4 and S13 pairs and that of user-story.md exactly the U4 and U13 pairs, each keeping `- [x]`. Owner decision 1031-ac-text-s4-s13 option (a) is applied.

## Edited headings of spec.md

- `### Fallback rules (auto)`
- `### Element and identity rules`
- `### Interpreter discovery and invocation`
- `### Native-provider function`
- `### Helper protocol (protocol version 1)`
- `## Implementation Strategy`
- `## Artifact Classification`
- `## Upstream Dependencies (assumed, not yet on the branch)`
- `## Decisions Later Children Must Honor`
- `## Acceptance Criteria`: S4 and S13 only

## Amended criteria

- S4 and U4 now name one `information`-severity `PYTHON_NATIVE_UNAVAILABLE` snapshot diagnostic with `analyzer_id` `docs-inventory` (original plan deviation 4).
- S13 and U13 now name the four 1020-form rows under the anchor `# --- 1031: Python-native analyzers ---` (original plan deviation 1).
