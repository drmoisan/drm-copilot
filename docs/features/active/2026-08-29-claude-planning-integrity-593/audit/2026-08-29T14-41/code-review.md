# Code Review: Claude Planning Integrity (#593)

**Review Date:** 2026-08-29
**Reviewer:** Codex feature reviewer
**Feature Folder:** `docs/features/active/2026-08-29-claude-planning-integrity-593`
**Feature Folder Selection Rule:** The fresh PR context names this folder and its `issue.md` specifies `full-feature`.
**Base Branch:** `main` at `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`
**Head Branch:** `feature/claude-planning-integrity-593` at `3658effcc58c946ee430c758fce666a5d451686c`
**Review Type:** Post-remediation full branch re-review

## Executive Summary

The complete three-commit branch was reviewed, including original behavior and both remediation cycles. Numeric provenance enforcement, named-section counters, parallel-intake guidance, canonical/bundle parity, and the dedicated `prd-feature` stop-hook registration are implemented and tested. The exact registration is independently parsed from both settings files by PowerShell and Python tests, including complete-omission, broad-only, duplicate, extra-command, wrong-path, wrong-type, wrong-matcher, and divergence fixtures.

One blocker remains in the original planner-review implementation. The hook claims to require citation enumeration and traceability but checks only token presence. The direct check `Test-HasPlannerInternalReview -AgentOutput 'PLANNER-INTERNAL-REVIEW: citation-to-tree; acceptance-criterion-to-implementation; scope-boundary'` returned `True`, although the string has no results, citations, mappings, or unresolved-gap record.

**PR readiness recommendation:** **Needs Revision** — AC2 cannot remain checked until the runtime validator and focused tests enforce the complete planner self-review record.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/validate-planner-output.ps1` | `Test-HasPlannerInternalReview`, lines 113-120 | The validator accepts a bare declaration containing the three required labels. It does not validate results, citation enumeration, AC-to-implementation mapping, or unresolved-gap disposition. | Parse the review record and reject each absent or blocked component; add isolated Pester and Python-contract rejection fixtures. Mirror the changed hook and tests as required. | The feature plan P2-T3 explicitly requires rejection of missing citation enumeration or traceability, and AC2 requires a recorded self-review before preflight. | Direct invocation returned `True` for the bare declaration; the current Pester file only tests missing dimension labels. |

## Implementation Audit

### Python implementation audit

The Python contract tests correctly parse canonical and bundled settings independently and compare full bytes. They use distinct complete-omission and broad-only fixture construction, plus duplicate, extra-command, wrong-path, wrong-type, wrong-matcher, and divergence cases. No new public Python API is introduced.

### PowerShell implementation audit

The generated-document counter is pure, takes a named heading, and terminates at equal-or-shallower headings. The PRD and research validators provide explicit rejection messages for numeric-provenance failures. The planner hook is the exception: it does not implement the complete record contract its error message asserts.

## Test Quality Audit

- Focused Pester: 77 passed, 0 failed, 0 skipped.
- Focused pytest: 31 passed.
- Recorded full Python QA: 4,218 passed, 5 skipped, 93% coverage.
- `claude-settings.Tests.ps1` and `test_claude_planning_integrity_contracts.py` independently parse both settings documents and cover all requested invalid registration fixtures.
- `GeneratedDocumentCounters.Tests.ps1` uses unrelated checkboxes before and after `## Acceptance Criteria`, including nested and following equal-level headings.

The remaining test-quality gap is specific: the planner-review fixtures do not create a declaration with all three labels but missing the required supporting record fields.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in changed source | PASS | Diff inspection found no credentials or `.env` content. |
| No unsafe subprocess construction | PASS | Reviewed hooks use PowerShell parsing and file reads; no `Invoke-Expression`. |
| Input validation at boundaries | PARTIAL | Numeric and settings paths are validated. Planner-review record validation is incomplete. |
| Error handling remains explicit | PASS | Validators return specific rejection messages. |
| Configuration and path handling | PASS | Settings registration is exact and bundle parity was verified for all listed Claude resources. |

## Research Log

No external research was required. The review relied on the fresh canonical PR-context pair, the branch diff, feature evidence, direct runtime inspection, and focused checks.

## Verdict

The branch is not ready for a normal PR flow. Remediate the planner validator and tests, verify canonical/bundle parity and the focused/full QA evidence again, then re-review AC2 before restoring its checkboxes.
