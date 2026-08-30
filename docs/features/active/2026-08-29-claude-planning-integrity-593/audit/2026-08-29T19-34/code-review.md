# Code Review: Claude Planning Integrity (#593)

**Review Date:** 2026-08-29  
**Reviewer:** Codex feature reviewer  
**Feature Folder:** `docs/features/active/2026-08-29-claude-planning-integrity-593`  
**Base Branch:** `main` at `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`  
**Head Branch:** `feature/claude-planning-integrity-593` at `881469fc96cc029e1797159075b97d8782a32094`  
**Review Type:** Post-remediation full branch re-review

## Executive Summary

The full feature range was reviewed using the fresh PR-context pair, the base diff, current toolchain results, coverage artifacts, feature requirements, and canonical/bundle parity inspection. The revised planner output validator now requires an exact bounded record with passing dimensions, repository-relative citations, one-to-one AC mappings, and an explicit `UNRESOLVED-GAPS: NONE` disposition.

The implementation has no blocking functional finding. The branch is not PR-ready because a changed Python test fails Black check and five committed evidence files fail `git diff --check` due to a blank line at EOF.

**PR readiness recommendation:** **Needs Revision** — correct the formatting and whitespace findings, then rerun the complete toolchain.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | whole file | Black reports that the changed test file would be reformatted. | Run Black on the file and commit the resulting formatting-only change. | The required formatting gate is failing. | `poetry run black --check ...` exit code 1. |
| Major | `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/remediation-baseline/planner-review-python-*.2026-08-29T14-41.md` | EOF in five files | `git diff --check main...HEAD` reports a new blank line at EOF in five evidence files. | Remove the extra final blank line and rerun `git diff --check main...HEAD`. | The branch-wide whitespace gate is failing. | Current diff-check output. |

## Implementation Audit

### Python implementation audit

The changed Python scope is contract-test coverage. Ruff and Pyright pass, and 33 focused tests plus the 4,220-test full suite pass. The only Python issue is formatting.

### PowerShell implementation audit

`Get-PlannerInternalReviewValidation` enforces all fields required by the planner contract and rejects malformed record variants. The canonical and bundled hooks match exactly. The full-root PoshQC run passes and measures the modified planner hook at 96.28% line coverage.

## Test Quality Audit

- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` covers valid bounded records and missing, duplicate, blank, blocked, out-of-bounds, and invalid-path records.
- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` statically verifies the canonical planner record contract and focused fixture inventory.
- `artifacts/pester/powershell-coverage.xml` records 94.78% repository line coverage after the current full-root PoshQC run.
- `artifacts/python/lcov.info` was refreshed by the current full Python coverage run, which completed 4,220 passed and 5 skipped at 93% repository coverage.

Tests are deterministic repository contract checks with inline payloads and mocks where file-boundary behavior is isolated. No external service is required.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in changed source | PASS | Diff inspection found no credentials or environment files. |
| No unsafe subprocess construction | PASS | Reviewed hook validation uses parsing and filesystem checks without `Invoke-Expression`. |
| Input validation at boundaries | PASS | The planner validator rejects malformed JSON, absent paths, invalid record structure, and invalid citation paths. |
| Error handling remains explicit | PASS | Rejections return specific diagnostic messages. |
| Configuration and path handling | PASS | Canonical and bundled runtime copies are identical for the revised hook. |

## Research Log

No external research was required. The review used repository-local requirements, PR context, diff evidence, current toolchain output, and coverage artifacts.

## Verdict

The implementation and acceptance behavior are sufficient for the documented feature requirements, but the branch does not meet the repository's clean formatting and whitespace gates. Remediation is required before normal PR flow.
