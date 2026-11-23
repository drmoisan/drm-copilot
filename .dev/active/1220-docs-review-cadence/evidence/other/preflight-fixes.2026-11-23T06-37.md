# Preflight Fixes - docs-review-cadence (#1220), round two

Timestamp: 2026-11-23T06-37
Plan: .dev/active/1220-docs-review-cadence/plan.2026-11-23T00-39.md
Command: in-place task-text edits during single-pass preflight (no task added, removed, or reordered)
EXIT_CODE: 0
Output Summary: 1 trivial fix applied; 1 substantive defect returned to the planner separately. Plan validation passed through the installed MCP validator and the branch-current Python CLI (`scripts.dev_tools.validate_orchestration_artifacts plan`).

## Fixes

1. [P2-T1] | disposition completeness | Added `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` to the `Unchanged tests` line. The test discovers every `.claude/lib` module from disk (`Get-ChildItem -Recurse`), so it covers the new `DocsReviewCadence.psm1` without naming it. Its `It` blocks require a module-scope fail-fast error preference, a guarded load-time sibling import, and the convention statement in the help block. The entry names an existing test and its disposition; it adds no assertion to the plan.

## Round-One Defects Re-Checked

- (1) [P1-T2] resolved: the task adds the three `DOCS_PAGE_REVIEW_DUE_*` codes to `$script:CatalogCode` in `Describe 'DocsPageCheck finding-code catalog'` of `DocsPageCheck.Tests.ps1` (696 lines on this tree) inside the existing lines, with the reason tied to the test `finds exactly the catalog codes as DOCS_PAGE_ string literals of the page modules`.
- (2) [P3-T2, P4-T5] the byte copy to the Codex bundle folder is resolved. The four-copy SHA-256 equality asserted for `SKILL.md` is a new substantive defect; see the preflight return.
- (3) [P2-T2, P2-T3] resolved: unconditional cases use explicit `review_due` and assert a non-null receipt; profile-loading family and legacy cases are conditional on the P0-T1 `FamiliesState:` / `LegacyExclusionsState:` lines, with `CONDITIONAL-CASES-NOT-WRITTEN:` recording.
- (4) [P2-T1, P2-T3] resolved: `next_action` literal, ordinal case-sensitive matching, UTC-kind and `$null` conversion, `DocsPageFrontMatter.psm1` in the AST list, and the `ReadText` failure exit-3 `DOCS_CLI_RUNTIME` case are present. `New-DocsLedgerTestContext -ReadBytesFailure` makes `ReadText` throw for the named path and logs a `ReadText` call entry; page paths come from `ListFile`, so no earlier read of the page precedes the new `ReadText` call.
