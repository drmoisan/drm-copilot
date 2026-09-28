# Code Review: Portable Prepared Orchestration Handoff (#614)

**Review Date:** 2026-09-03  
**Reviewer:** feature-review delegation `s9-final-feature-review-614-001`  
**Feature Folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/`  
**Feature Folder Selection Rule:** Issue 614 matches the branch suffix and the only materially changed active feature folder.  
**Base Branch:** `origin/main` at `9f3514bf5da84110f23617382cbbeabf54f27427`  
**Head Branch:** `feature/portable-prepared-orchestration-handoff-614` at `541e8d89250bdc9a49f78c4ac4fcb6217799a4dd`  
**Review Type:** Final full base-to-head feature review

## Executive Summary

The complete 193-file diff was reviewed against its merge base using the fresh canonical PR-context summary and appendix, the issue, specification, user story, original plan, prior remediation records, implementation and test sources, and final-head QA evidence. The branch implements the provider-neutral envelope, Python and TypeScript contract layers, extension MCP tools, source archival and checkpoint materialization, provider projections, semantic MCP normalization, published consumer resources, scheduler boundaries, and bidirectional TaskMaster #469 fixtures.

The three prior valid findings are resolved. Canonical existing and creatable path containment is shared by the authority and materializer; the authority service has 259/265 covered lines (97.74%); and both raw TaskMaster plan fixtures are 101,998 bytes with SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f` in the working tree, index, and simulated Windows and Linux checkout representations. The focused final-head fixture test passed 2/2 without any hydration mechanism.

One new P1/Major correctness finding remains. The published authority request contains only workspace root, envelope path/hash, and destination provider. `resolvePortableHandoffAuthority` then supplies repository, branch, issue, feature, and work-mode values to `collectHandoffValidationFailures` by reading the same envelope being validated and supplies `sourceHeadRelationshipValid: true`. These comparisons cannot detect a handoff bound to another repository, branch lineage, issue, feature, work mode, or source HEAD. A direct no-write reproduction changed all six bindings and still received `status: "validated"`. The transition materializer calls this authority and can therefore proceed without the required independent binding checks.

**What changed:** The final commit made both raw plan fixtures binary-preserved through path-specific Git attributes, retained the pinned CRLF provenance bytes in both directions, and added final clean-head evidence. No production or test implementation changed after the canonical containment remediation.

**Top risks:**

1. FR-614-005 permits a correctly hashed but contextually wrong envelope to pass the published authority and reach destination materialization.
2. The public request schema cannot express the expected repository, branch, issue, feature, work mode, or source-HEAD relationship, so callers cannot make the omitted comparisons through the supported MCP contract.
3. Existing contract-unit tests exercise mismatched contexts only by calling the generic validator directly; production authority and transition tests do not prove those contexts are independently observed.

**PR readiness recommendation:** **Blocked.** Remediate FR-614-005, rerun the full toolchain, and repeat the full feature review before PR creation.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (P1) | `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-handoff.ts`; `extensions/drm-copilot/src/mcp-handlers/orchestration-handoff-handlers.ts`; `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts`; `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` | definitions 10-24 and 66-80; handler 75-95; authority 227-246; materializer 19-28 and 259-278 | **FR-614-005:** published authority and transition validation use envelope-derived values as the expected repository, branch, issue, feature, and work mode and unconditionally accept the source-HEAD relationship. These checks are tautological and do not bind the handoff to the destination checkout or caller expectation. | Extend the supported request/observation boundary so these values are independent of the envelope, validate actual branch/HEAD lineage and repository identity, validate objective bindings against independent expected or source-checkpoint state, propagate the context through both authority tools and transition, and add fail-closed production-path tests before any write. | Spec AC1, AC8, and AC10 and user-story criteria 1, 7, 8, and 10 require independent binding validation before continuation and materialization. A matching envelope digest proves only which bytes were selected; it does not prove those bytes describe the intended checkout and objective. | Direct reproduction at exact HEAD changed `repository_id`, `branch`, `source_head_sha`, `issue_number`, `feature_folder`, and `work_mode` and received `status: validated` with no failure code. Static anchors show each expected value is copied from `envelope` and `sourceHeadRelationshipValid` is hard-coded `true`. The focused four-suite Jest run passed 61/61 but the authority test contains no repository, branch, source-HEAD, issue, feature, or work-mode rejection case. |
| Info | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-path-boundary.ts` | 1-205 | **FR-614-001 resolved:** governed existing and creatable paths use canonical filesystem containment and reject reparse/symlink escape before I/O. | Preserve the shared path boundary during remediation. | The original containment defect no longer reproduces. | Recorded focused containment evidence passed; current implementation inspection confirms the production authority and materializer both use `createNodeHandoffPathBoundary`. |
| Info | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts` | current LCOV record | **FR-614-003 resolved:** the new authority service exceeds the new-code line threshold. | Preserve coverage while adding independent binding cases. | Current line coverage is 259/265 = 97.735849%, above 90%. | `evidence/qa-gates/typescript-unit-coverage.2026-09-02T22-17.md`. |
| Info | `.gitattributes`; both `tests/fixtures/orchestration-handoff/taskmaster-469/*/plan.2026-08-29T12-22.md` files | `.gitattributes` 1-3; complete fixture bytes | **FR-614-004 resolved:** both fixture directions preserve identical pinned raw bytes without hydration. | Preserve path-specific `-text -eol` attributes and raw-byte assertions. | Exact provenance must remain stable on Windows and Linux checkouts. | Direct final-head check: working tree, `git show HEAD`, index/filter with `core.autocrlf=true`, and index/filter with `core.autocrlf=false` are each 101,998 bytes and SHA-256 `54c971...`; focused pytest passed 2 with 54 deselected. |

## Implementation Audit

### Contract and validation design

- The Python and TypeScript contract models use explicit version, identity, binding, plan, lifecycle, capability, scheduler, and history types.
- Failure precedence is deterministic and shared through generated/published resources.
- The generic TypeScript `collectHandoffValidationFailures` function correctly compares an envelope with an independent `HandoffValidationContext`.
- FR-614-005 occurs at the production authority boundary: the public request does not carry that independent context and the production service manufactures it from the untrusted envelope.

### Materialization and path safety

- Existing and creatable targets are resolved through a canonical path boundary before reads or writes.
- Source bytes are archived by digest, a destination candidate is written and validated, and the candidate is renamed to the canonical checkpoint only after the clean-worktree check.
- Dry-run returns the proposed result without invoking the write stage.
- Materialization nevertheless depends on the incomplete authority validation described in FR-614-005, so its otherwise safe write ordering does not cure the missing binding authorization.

### Provider and scheduler boundaries

- Source-provider receipts remain opaque and destination projections begin with pending destination evidence.
- Ordinary, parallel-child, and epic-child scheduler contexts preserve parent ownership and bounded return semantics.
- Provider-specific topology and routing policy selection remains separated from portable lifecycle state.

### Published MCP and consumer surface

- The three MCP operations are registered and published with explicit workspace, envelope digest, provider, and transition inputs.
- Source, extension resources, pack manifests, and installed-consumer surfaces have recorded parity coverage.
- The request shape itself is the defect: it exposes no independent context for the binding dimensions named by the acceptance criteria.

### Maintainability and policy checks

- Every changed governed production, test, and reusable-script file is at or below 500 lines; the largest observed file is 498 lines.
- No new broad suppression, `ts-ignore`, `ts-nocheck`, unsafe `any` escape, dependency, or network dependency was identified.
- I/O, validation, provider projection, path resolution, and MCP dispatch are separated into typed modules.

## Test Quality Audit

The branch has broad deterministic coverage for schemas, migration, provenance, failure precedence, path containment, source archives, projection, dirty-worktree handling, provider adapters, scheduler ownership, hook processing, consumer publication, and both TaskMaster fixture directions. Full recorded suites are green and numeric coverage exceeds policy thresholds.

The gap is scenario completeness at the production boundary. `orchestration-handoff-contract.test.ts` proves the generic validator can reject mismatched context when the test supplies one. `orchestration-handoff-authority-service.test.ts` supplies the authority request and exercises workspace mismatch but does not exercise independently wrong repository, branch, source HEAD, issue, feature, or work mode. The transition tests likewise use authority stubs/results and do not demonstrate that the production transition derives those facts independently.

### Current verification

- Focused authority/materializer/contract Jest run: 4/4 suites and 61/61 tests passed in 0.386 seconds.
- Focused raw-fixture pytest: 2/2 passed, 54 deselected, without byte mutation.
- Recorded Python full suite: 4,382 passed, 5 skipped, 0 failed; 92.86076591427847% line and 85.41811846689896% branch coverage.
- Recorded TypeScript full suite: 213/213 suites and 2,894/2,894 tests passed; 96.78% line and 90.28% branch coverage.
- Recorded PowerShell full MCP suite with `scan_folders` omitted: 3,923 active passes, 9 skipped/disabled, 0 failures/errors; 7,437/7,848 = 94.762997% line coverage.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in changed scope | PASS | Diff and fixture review found no credential material. |
| Canonical path containment | PASS | FR-614-001 is resolved; authority and materializer share the real-path boundary. |
| Raw-byte provenance portability | PASS | FR-614-004 is resolved across working, HEAD/index, Windows-filter, and Linux-filter bytes. |
| Deterministic failure precedence | PASS | Contract and cross-language compatibility suites pass. |
| Independent repository/objective/lineage binding | FAIL | FR-614-005 direct reproduction returns `validated` for six changed contextual bindings. |
| Dirty-worktree preservation | PASS | Read-only porcelain evaluation reports paths without staging, resetting, deleting, or modifying them. |
| Dependency and network scope | PASS | No dependency addition or critical-section network call was found. |

## Research Log

No external research was required. Repository requirements, source, tests, PR-context artifacts, exact-head fixtures, and committed QA evidence were sufficient.

## Verdict

The final branch resolves FR-614-001, FR-614-003, and FR-614-004 and retains green full-suite evidence. It is not ready for PR creation because FR-614-005 leaves the published consumer authority and transition unable to enforce required repository, branch-lineage, issue, feature, work-mode, and source-HEAD bindings independently of the envelope. Remediation planning is required, followed by implementation, complete QA, acceptance reconciliation, and another full review.
