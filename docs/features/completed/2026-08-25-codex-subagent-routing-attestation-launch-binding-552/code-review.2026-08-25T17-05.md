# Code Review: Routed-subagent launch binding (Issue #552)

**Review Date:** 2026-08-25
**Reviewer:** feature-reviewer-c3
**Feature Folder:** `docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552`
**Base Branch:** `main` at `66c648db3ecae063ef873b3e76b00ca0d9fb7944`
**Head Branch:** `bug/codex-subagent-routing-attestation-launch-binding-552` at `cacb27f3af2c0c2d56aeb9b9663fbe15b67a8865`
**Review Type:** Initial feature-branch review

## Executive Summary

The reviewed commit establishes the required pre-launch contract in the routing skill and generated orchestrator profiles, keeps root and bundled customizations synchronized, and excludes runtime-only `.codex/state/**` paths from payload publication. The implementation is narrowly scoped and backed by targeted Pester/pytest tests plus recorded final QA.

Current review checks passed for diff whitespace, Black, Ruff, Pyright, and generated-profile drift. The checked-in final evidence records a passing PowerShell/Python toolchain loop and 60 passing final pytest tests. No blocker, major, minor, or nit finding was identified.

**PR readiness recommendation:** **Go** — the requested range is internally consistent, acceptance evidence is complete, and no remediation trigger was found.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | Reviewed range | All changed implementation and test paths | No actionable findings. | Continue through normal PR review. | The pre-launch receipt requirements, bundle synchronization, and regression coverage match the feature specification. | Current review checks; feature evidence listed below. |

No Blocker or Major findings.

## Implementation Audit

### Python implementation audit

#### What changed well

- `ExcludingFileSystem` filters only source-relative `.codex/state/**` entries, preserving `.codex/config.toml` and `.agents/**` publication.
- The predicate is applied at `list_files`, before payload selection, and its behavior is tested both in the publisher unit test and root/bundle contract test.

#### Typing and API notes

- The new predicate is a private, typed method with a `bool` return. No public Python API surface was added.

#### Error handling and logging

- Existing source-root resolution behavior is retained. The change does not add a broad exception handler or a fail-open publish path.

### PowerShell implementation audit

#### What changed well

- The Pester configuration adds the routing-attestation hook to coverage selection exactly once.
- New test cases exercise exact task-researcher C3 receipt admission and mismatch rejection paths.

#### API and safety notes

- The behavioral contract remains fail-closed: generic aliases, absent/late receipts, profile mismatches, and invalid attestations cannot authorize a routed child.

#### Error handling and logging

- No production PowerShell error-handling change is included; the test assertions verify existing explicit denial behavior.

### Configuration and generated-profile audit

- The root routing skill and six orchestrator TOML profiles carry the durable-receipt contract.
- SHA-256 comparison during this review confirmed equality between each changed root routing asset and its bundled copy.
- `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` passed in the current checkout.

## Test Quality Audit

### Reviewed test and QA artifacts

- `evidence/regression-testing/pester-start-only-attestation.2026-08-25T16-51-37.md` — 9 passing Pester tests for start-only validity and rejection scenarios.
- `evidence/regression-testing/pytest-nested-c3-selection.2026-08-25T16-46-02.md` — three passing resolver-selection scenarios.
- `evidence/regression-testing/pytest-source-bundle-parity.2026-08-25T16-52-03.md` — 31 passing source/bundle and runtime-state-exclusion checks.
- `evidence/qa-gates/final-qa-single-pass.2026-08-25T17-00-43.md` — final restarted single-pass QA loop with all seven steps exiting 0.

- **Determinism:** test inputs are fixed payloads, receipt objects, in-memory filesystem content, and fixed expected profile values.
- **Isolation:** each added test focuses on a defined routing, binding, or publishability behavior.
- **Speed:** the scoped checks and recorded aggregate suite complete within the repository’s normal test workflow; no network dependency is used.
- **Diagnostics:** named scenarios identify the exact rejected receipt or routing condition.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection found only routing policy, configuration, tests, and feature evidence. |
| No unsafe subprocess or command construction | PASS | The Python implementation change is a path predicate; no process invocation was added. |
| Input validation at boundaries | PASS | Existing source-root relativity logic is reused; routing profiles prescribe fail-closed profile and receipt validation. |
| Error handling remains explicit | PASS | The new policy text requires rejection for invalid persistence, aliases, mismatches, and `routing_valid: false`. |
| Configuration / path handling is safe | PASS | The exclusion applies only when a candidate path is source-relative and begins with `.codex/state/`; parity tests retain valid customization paths. |

## Research Log

No external research was required. The canonical PR context, appendixed diff, feature specification, plan, and repository evidence were sufficient.

## Verdict

The implementation is ready for normal PR flow. The repository’s final QA evidence and the independent check-only verification performed during this review support a Go recommendation. No remediation input or remediation plan is required.
