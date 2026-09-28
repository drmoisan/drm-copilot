# Code Review: Portable Prepared Orchestration Handoff (#614)

**Review Date:** 2026-08-31
**Reviewer:** `feature-reviewer-c4` delegation `s9-feature-review-614-001`
**Feature Folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/`
**Feature Folder Selection Rule:** `issue.md` and fresh PR context identify this active full-feature folder for issue #614.
**Base Branch:** `main` (merge base `9f3514bf5da84110f23617382cbbeabf54f27427`)
**Head Branch:** `feature/portable-prepared-orchestration-handoff-614` at `b06a3516d52d1693a38106eeb33817c261983620`
**Review Type:** Initial feature-branch review

## Executive Summary

This review covers 119 changed files and the complete provider-neutral prepared-orchestration handoff implementation: schema and adapters, Python and TypeScript authorities, hooks, MCP registration, ordinary/parallel/epic ownership enforcement, publication surfaces, and test/evidence artifacts. The fresh PR-context pair matches reviewed HEAD; all 108 plan tasks are checked; 11,182 full-suite language tests pass; and recorded Python, TypeScript aggregate, PowerShell, architecture, parity, pack/install, provider, #469, #467, and #543 checks are green.

The implementation is **blocked** by one correctness/security finding and one mandatory coverage finding. The TypeScript consumer authority and materializer use lexical containment checks that do not reject symlink escape. A new TypeScript authority file is 87.02% covered against the required 90%. PowerShell is PASS: the authoritative full MCP PoshQC run omitted `scan_folders`, passed 3,932 tests, and reported 94.763% repository line coverage (7,437/7,848).

**What changed:** A versioned, digest-bound, provider-neutral handoff envelope and transition flow were added across source authority, destination validation/materialization, hooks, MCP APIs, consumer packaging, and root/bundle/pack/install test surfaces. The branch preserves raw source receipts, exact plan identity, scheduled-child ownership metadata, and provider-specific evidence boundaries in the reviewed positive paths.

**Top 2 risks:**

1. A repository-relative consumer path can traverse an in-workspace symlink to a real target outside the workspace.
2. The new TypeScript authority service does not meet the new-file coverage threshold and omits important negative branches.

**PR readiness recommendation:** **Blocked** — remediate FR-614-001 and FR-614-003, regenerate evidence, and complete post-remediation review before approval.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts`; `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-support.ts` | `44-50`; `12-29` | **FR-614-001 / P0:** workspace containment is lexical only. `path.resolve` plus prefix comparison does not reject a symlinked component whose real target is outside the workspace. Validation can read and materialization can write/archive outside the intended root. | Resolve canonical filesystem targets or inspect every path component through a deterministic injectable boundary, reject symlink/junction escape before I/O or mutation, and add validation/materialization tests. | `spec.md` AC3 explicitly requires symlink-escape rejection; AC10 and user-story criteria 8 and 10 require safe materialization and fail-closed invalid-path behavior. | TypeScript code inspection; no `realpath`, `lstat`, or `readlink` in the affected paths. Python parity implementation uses `Path.resolve(strict=True)` at `scripts/dev_tools/orchestration_handoff_contract_support.py:48-49`. |
| Major | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts` | executable lines 82-83, 88-89, 96-102, 118-119, 160-163, 166-169, 193-198 | **FR-614-003 / P1:** the new authority service is 87.02% line-covered (181/208), below the required 90%. | Add deterministic tests for uncovered validation/error paths, including FR-614-001, and regenerate LCOV. | New production files must achieve at least 90% line coverage; aggregate TypeScript coverage cannot substitute for the per-new-file gate. | Reviewer parse of `extensions/drm-copilot/coverage/lcov.info`; aggregate TypeScript remains 96.73% line / 90.23% branch. |

No Minor, Nit, or Info findings were recorded. Exact finding count: **2** — one Blocker and one Major.

## Implementation Audit

### Python implementation audit

#### What changed well

- The contract and migration layers use typed data structures, ordered failure codes, raw-byte hashing, explicit legacy-v1 evidence requirements, and strict path resolution.
- `scripts/dev_tools/orchestration_handoff_contract_support.py:43-51` resolves the root and candidate strictly before containment comparison, covering the symlink-escape requirement on the Python side.
- No added Python suppression was identified.

#### Typing and API notes

- Pyright evidence is green. Provider-neutral logical fields are separated from provider-expression evidence, and consumer adapters retain explicit required capabilities.

#### Error handling and logging

- Invalid schema, digest, history, binding, capability, plan, transition, and migration states produce structured `HANDOFF_*` outcomes with deterministic precedence. No newly added broad exception swallowing was found.

### TypeScript implementation audit

#### What changed well

- The extension exposes workspace-explicit validation, topology resolution, routing, dry-run transition, and controlled materialization through typed MCP boundaries.
- Contract and adapter types preserve raw-byte identities, provider-neutral lifecycle/complexity data, source evidence opacity, and scheduled-owner metadata.
- Root, resource, pack, and installed-consumer parity evidence is present.

#### Type safety and maintainability

- TypeScript compilation and ESLint are green; no added `any` or suppression comments were found.
- FR-614-003 indicates inadequate branch exercise in a central new authority module.

#### Error handling and logging

- Structured blocked results and primary-code ordering are implemented. FR-614-001 is a boundary-validation defect: lexical normalization is insufficient when filesystem links can change the real target.

### PowerShell implementation audit

#### What changed well

- Preparation-gate changes remain narrowly scoped to the registered semantic transition and preserve denial of ordinary shell/patch route mutation.
- Canonical and bundled hook parity is recorded; the authoritative full MCP PoshQC run passed all 3,932 Pester tests and reported 94.763% repository line coverage. Historical targeted evidence reports 91.82% changed-hook coverage.

#### API and safety notes

- Hook behavior is structured and fail-closed for malformed and unauthorized tool identifiers. Provider-neutral operation aliases are covered for hyphenated and underscore-normalized MCP transport spellings.

#### Error handling and logging

- Failure responses remain explicit. The earlier 19.00% repository reading was produced by a 637-test hook-only run paired with the full 88-file denominator. The authoritative full MCP run invalidated that repository-wide interpretation, so PowerShell is not an open finding.

## Test Quality Audit

The evidence includes full Python, TypeScript, and PowerShell suite runs; baseline/post-change coverage comparisons; contract and precedence matrices; provider adapter symmetry; legacy migration; #469 end-to-end fixtures; root/bundle/pack/install parity; consumer tests; hook-process tests; ordinary/parallel/epic ownership constraints; and #467/#543 scope regression checks. The test design is broad and recorded execution is green. It is incomplete at the TypeScript filesystem boundary because no consumer symlink-escape test exercises validation or materialization.

### Reviewed test and QA artifacts

- `evidence/qa-gates/python-pytest-coverage.2026-08-31T07-58.md` — 4,382 passed, 5 skipped; 92.86% line and 85.42% branch coverage.
- `evidence/qa-gates/typescript-jest-coverage.2026-08-31T07-58.md` — 2,868 passed; 96.73% line and 90.23% branch coverage.
- `evidence/qa-gates/powershell-pester-coverage.2026-08-31T07-58.md` — historical 637-test targeted run; its 91.82% changed-hook result remains useful, but its 19.00% repository reading is invalid because hook-only execution was combined with the full 88-file denominator.
- Authoritative PowerShell evidence — MCP `mcp__drm_copilot__run_poshqc_test({"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29"})` with `scan_folders` omitted passed 3,932/3,932 tests and covered 7,437/7,848 lines (94.763%). Direct Pester is not acceptable replacement coverage evidence.
- `evidence/qa-gates/*coverage-comparison.2026-08-31T07-58.md` — numeric merge-base comparisons for all languages.
- Remaining `evidence/qa-gates/` artifacts — architecture, contract, provider, precedence, migration, #469, parity, pack/install, hook-process, ordinary/parallel/epic ownership, and scope-boundary results.
- `evidence/other/progress-commit-*.2026-08-31T07-58.md` — linear implementation and QA checkpoints; rebased equivalents are ancestor-verified in the fresh PR context.

### Quality assessment prompts

- **Determinism:** Tests use fixed contract fixtures, byte hashes, registered operation names, and controlled provider/workspace inputs. A deterministic filesystem link seam is still required for FR-614-001.
- **Isolation:** Contract, authority, hook, materialization, provider, ownership, and publication concerns have dedicated suites.
- **Speed:** Exact full-suite durations are recorded in their QA artifacts; no timer/sleep-based new tests were identified.
- **Diagnostics:** Structured primary codes and explicit fixture assertions give actionable failures. Coverage output pinpoints untested TypeScript lines.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff and added-line inspection found no credential material. |
| No unsafe subprocess or command construction | PASS | Subprocess use remains in controlled adapters/test harnesses with structured arguments; no new shell interpolation finding was identified. |
| Input validation at boundaries | FAIL | FR-614-001: TypeScript path containment is not symlink-safe. |
| Error handling remains explicit | PASS | Structured `HANDOFF_*` results and ordered precedence are covered by evidence. |
| Configuration / path handling is safe | FAIL | Lexical prefix checks do not establish real filesystem containment. |
| Raw-byte identity and archive linkage | PASS | Schema/adapter/migration and #469 evidence pin source and plan hashes and digest-linked history. |
| No historical receipt synthesis | PASS | Adapter/projection and end-to-end evidence preserve source receipts and begin destination evidence only with new work. |
| Ordinary/parallel/epic ownership bounds | PASS | Contract and regression evidence preserves scheduler/barrier/fan-in/integration/cleanup authority at the parent. |
| Root/bundle/pack/install parity | PASS | Recorded publication and installed-consumer suites are green. |
| #467 and #543 scope boundaries | PASS | Regression evidence assigns full Codex-native parallel scheduling to #467 and the provider-specific epic-planner ready-gate defect to #543. |
| Changed file cap | PASS | Reviewer line-count check found a maximum of 498 lines. |

## Research Log

No external research was required. The authoritative repository research artifact, `research/20260831-portable-prepared-orchestration-handoff-implementation-research.md`, was inspected. It explicitly requires normalized repository-relative plan identity, rejection of symlink escape, distinct validation/materialization operations, consumer TypeScript authority, and preserved scheduler ownership.

## Verdict

`REVIEW_STATUS: REMEDIATION_REQUIRED`

The branch is not ready for normal PR flow. FR-614-001 is a blocking path-containment defect that contradicts explicit acceptance requirements and affects the safety of consumer validation and materialization. FR-614-003 independently fails the new-module coverage gate. Those two findings form the complete issue #614 remediation scope. PowerShell passes based on the authoritative full MCP run. The user has authorized continuation through remediation, PR, and exact-head CI; merge is not authorized. The other reviewed contracts — provider neutrality, receipt integrity, completed-phase replay prevention, scheduled ownership bounds, publication parity, and #467/#543 scope — have supporting evidence and must be preserved during remediation.
