# Code Review: Claude Planning Integrity (#593)

**Review Date:** 2026-08-29
**Reviewer:** Codex feature reviewer
**Feature Folder:** `docs/features/active/2026-08-29-claude-planning-integrity-593`
**Base Branch:** `main` at `25d4cb8b9ba81ae4a786924cd98a02c6d8e76d2b`
**Head Branch:** `feature/claude-planning-integrity-593` at `4c87251f2783c0e4383fe33545fd8b8df5eded53`
**Review Type:** Initial feature review

## Executive Summary

The branch adds the requested Claude-runtime contracts and their published mirrors, plus focused PowerShell and Python tests. Recorded toolchain evidence is clean, and the 14 changed canonical runtime files match their bundle mirrors.

The numeric-provenance enforcement is incomplete. A matching `Cross-check Count` is accepted as proof of an independent cross-check even though the record contains no second search method, query, or independently derived member set. This permits the single-pass failure mode that the feature is intended to prevent.

**PR readiness recommendation:** **Needs Revision** — add enforceable independent-derivation evidence and rejection coverage before PR creation.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/validate-prd-feature-output.ps1` and `.claude/hooks/validate-task-researcher-output.ps1` | `Test-NumericDerivationEvidence` | The hooks accept a `Cross-check Count` equal to `Primary Count` without requiring any distinct cross-check search or independently derived member set. | Require primary and cross-check derivation fields that describe separate search strategies and member-set comparison; reject missing or non-distinct evidence. Add Pester and Python rejection fixtures, then mirror changed runtime files. | Equal numeric values alone cannot establish that the second derivation is independent, so a single narrow search can be restated as two fields and approved. | Static inspection of both hook functions; focused tests cover only missing labels and unequal counts. |

## Implementation Audit

### PowerShell implementation audit

- The new counter is a small pure function and correctly stops at the next equal-or-shallower Markdown heading.
- Hooks use strict mode, explicit path checks, and explicit rejection messages.
- The blocker is limited to numeric-provenance validation and does not affect the section counter or planner/preflight controls.

### Python implementation audit

- The Python tests are straightforward text-contract checks and pass according to recorded QA evidence.
- `test_claude_planning_integrity_contracts.py` does not assert independent derivation evidence, so it would not detect the blocker.

## Test Quality Audit

- `evidence/qa-gates/powershell-toolchain.2026-08-29T12-07.md` — formatting and analysis clean; 65 focused tests passed.
- `evidence/qa-gates/powershell-coverage.2026-08-29T12-07.md` — new PowerShell files meet or exceed 90% line coverage.
- `evidence/qa-gates/python-toolchain.2026-08-29T12-07.md` — Black, Ruff, Pyright, and full Pytest succeeded with 93% coverage.
- `evidence/qa-gates/claude-bundle-parity-remediation.2026-08-29T12-07.md` — all 14 changed runtime paths are byte-identical to mirrors.

The test suites are deterministic and use inline data. The missing test is behavioral: an otherwise complete record with a copied or undocumented cross-check count must be rejected.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Reviewed diff contains no credentials or environment secret access. |
| No unsafe subprocess construction | PASS | Reviewed hook and counter changes invoke no subprocesses. |
| Input validation at boundaries | PARTIAL | Payload and path validation are explicit; provenance validation is insufficiently specific. |
| Error handling remains explicit | PASS | Hooks return clear error messages for malformed payloads and missing files. |
| Configuration / path handling is safe | PASS | `Test-Path -LiteralPath` and repository-relative contract paths are used. |

## Research Log

No external research was required. Repository contracts, the exact PR context pair, the feature plan, and recorded QA evidence are authoritative for this review.

## Verdict

The implementation is not ready for PR flow. The required correction is narrow but blocking: require and validate evidence of two independently constructed derivations, test that a count-only duplicate is rejected, mirror the corrected Claude runtime files, and rerun the affected QA and coverage gates.
