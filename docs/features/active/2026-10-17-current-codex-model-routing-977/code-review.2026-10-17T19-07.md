# Code Review: Current Codex model routing (#977)

**Review Date:** 2026-10-17T19-07 UTC
**Reviewer:** feature-reviewer-c3 specialist; actual host/model authorization recorded in review-977 checkpoint receipt.
**Feature Folder:** docs/features/active/2026-10-17-current-codex-model-routing-977
**Selection Rule:** Primary changed scoping docs and branch suffix 977.
**Base Branch:** main; merge-base f1408d0040e11432f3efbf4f7b6af4115c0b1f3d.
**Head:** feature/current-codex-model-routing-977 at c9902b54ffdb146b5039d5b7aaf4c1145afe5066.
**Review Type:** Refreshed full feature-vs-base review; original 18-47 audit set preserved.
**Template:** MCP code-review-template copied to this path, then populated.

## Executive Summary

The implementation consistently replaces active Codex model identities while retaining profile suffixes, efforts, topology decisions, ceilings and receipt validation. Generated/bundled profiles pass freshness and resource contracts. The bounded attestation addendum provides defaulted memory-test seams and preserves existing CLI, exclusive stream access, consumption, durable flush and error behavior.

No autonomous implementation Blocker or Major finding was identified. Operational readiness is HALT_NON_REMEDIABLE because the installed validator still expects former models; three final-head CI criteria remain conditional after initial S9 check-off. The report does not certify final checkpoint completion or actual installed-runtime readiness.

**Top risks:** installed-runtime mismatch; final-head CI remains outstanding; historical/current launch reconciliation must remain truthful.
**PR readiness recommendation:** Conditional Go for draft PR and CI preparation; no-go for merge or DONE until R1/R2 resolve.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | Installed MCP runtime; artifacts/orchestration/orchestrator-state.json | Codex receipts 11-16 | R1: runtime requires gpt-5.6-terra where current receipts correctly identify gpt-6.1-sol | Coordinate matching installed runtime, then validate truthful current launch evidence | external_dependency; source changes do not update installed extension | policy-audit.2026-10-17T19-07.md Appendix B preserves exact errors |
| Blocker | spec.md and user-story.md | SPEC-08, seeded CI condition, STORY-05 | R2: 26 checks pass at earlier remote head; current local acceptance check-off head still requires re-verification | Run required CI, check off at item S9, push and verify resulting head again | awaiting_ci; local results cannot satisfy final-head remote criteria | ci-initial.2026-10-17T19-05.md and live PR #978 checks; 16 checked source items include three conditional CI criteria |
| Info | evidence/qa-gates/local-vsix-readiness.2026-10-17T18-54.md | EXIT_CODE and EOF | Reviewed committed version mixed package success/MCP failure prose and had an EOF whitespace nit | Coordinator fixed integer package EXIT_CODE and separate MCP_VALIDATION_OK=false, preserving exact rejection | Nonblocking evidence-document correction; no source change | Coordinator continuation; updated evidence inspected |

## Implementation Audit

All implementation, generated-profile, test and bundle content is unchanged since the prior review. The complete main...HEAD diff still includes every changed language; earlier independent checks and raw coverage remain applicable without a duplicate broad run. New feature Markdown contains prior audits, VSIX readiness, initial CI and authorized S9 source check-offs. Fresh canonical context pair binds c9902b54ffdb146b5039d5b7aaf4c1145afe5066 at 2026-10-17 19:06:08 UTC.

Local VSIX evidence records a successful supported installation and matching build/resources; the already-running MCP remains stale. This is confirmed by a new direct validator rejection for receipts 11-16. Live PR #978 is draft/open at 6b7572ae6fcfe863d13609fe9452d5f769715209 with 26 passing checks. This proves earlier-head CI only; the check-off commit c9902b54ffdb146b5039d5b7aaf4c1145afe5066 must be pushed/reverified.

### Python implementation audit

The resolver's TypedDict profile/receipt types and typed generator interfaces remain. Constants adopt only the approved models; public arguments and diagnostic behavior remain. Generator prose now names Sol. No added Any, suppression, abstraction, dependency or logging path was found. Black, Ruff, Pyright and 142 exact routing/generator/resource/manifest/wrapper/handoff tests independently pass.

### TypeScript implementation audit

Readonly profile maps keep exact model/effort comparisons. New regression asserts rejection of stale Terra receipts independently of successful resolution. The remaining fixture updates follow current behavior and preserve negative cases. No public types or error-handling flow changed. Prettier, ESLint, both compiler populations and all 4105 Jest tests independently pass.

### PowerShell implementation audit

The resolver's selection conditions remain unchanged. Hook default delegates preserve exclusive File.Open modes, Directory.CreateDirectory, durable Flush(true), encoding and finally disposal. Command extraction preserves canonical root derivation, dot-source behavior, stdout/stderr diagnostic content and exit statuses. Existing calls remain compatible through defaulted named parameters.

New command/persistence tests exercise actual imported functions with memory streams and deterministic boundary inputs, including a real consume-once authorization check. No tests invoke git or create temporary files for the new logic. Source and actual bundled hook are byte-synchronized and independently measured. Source hook is 426 physical lines; new tests are 136/226 lines.

## Test Quality Audit

Complete final ordered executor evidence covers Python 7336 passed / 6 baseline skips, TypeScript 4105 passed, PowerShell 11310 passed / 10 baseline skips. Reviewer independently repeated Python/TypeScript formatting, lint, typing and appropriate tests, plus generator check. Pester's full recorded run and actual bundled coverage were inspected rather than repeated after unchanged executable files.

Coverage PASS for all three changed languages: Python 94.1117% line / 88.7837% branch; TypeScript 97.4117% / 92.6573%; PowerShell 92.6236% line. Every changed production file meets its 85% line and applicable 75% branch floors; new command method measures 90% source/bundle. No preserved covered-line losses. Baseline/final raw JSON/XML matches evidence.

Isolation: reversed Python modules, randomized Jest seed 977, shuffled touched Pester suites at seeds 977/1977/2977 and fresh full single-process Pester all pass. Tests name behaviors and provide exact diagnostic/state assertions. Existing skips were preserved, with no assertion removal. Evidence inventory is in the sibling policy audit and evidence/qa-gates/execution-summary.2026-10-17T18-43.md.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No introduced secrets or unsafe commands | PASS | Source delta contains literals and narrow seams; no dependency or credential changes |
| Boundary validation and fail-closed behavior | PASS | Preserved exact profile/model/effort/hash, malformed-input, topology and unavailable-model checks |
| Persistence semantics | PASS | Exclusive modes, single-use state, original durable flush and stream disposal preserved |
| Bundle consistency | PASS | Generator --check; source/bundle contracts; independently instrumented actual copies |
| Scope and historical evidence | PASS | Current asserting fixtures updated; historical receipt literals preserved; no compatibility exception |
| Installed-runtime completion | FAIL | R1 external_dependency |
| Final-head remote readiness | PARTIAL | Earlier remote head green; current local check-off head awaits required re-verification |

## Research Log

No new external research was needed to evaluate the user-authorized exact replacement table. Repository specification, supplied research, current diff, canonical context and actual test/coverage evidence were authoritative for this bounded review.

## Verdict

Local implementation is suitable for draft PR/CI preparation. Merge and final completion remain blocked by R1/R2. No autonomous remediation plan is justified; record remediation inputs with external_dependency and awaiting_ci and do not delegate a planner. Coordinator owns any supported installed-runtime work, current receipt reconciliation and final-head CI.
