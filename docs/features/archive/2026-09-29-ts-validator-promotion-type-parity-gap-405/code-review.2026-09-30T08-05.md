# Code Review: issue #405

- Timestamp: 2026-09-30T08-05
- Diff: `cbb53d7a..HEAD`
- Verdict: APPROVE (no blocking findings)

## Executive Summary

Verdict APPROVE. No blocking or remediation-required findings. Three Info-level observations are recorded in the findings table. The review covers the production changes, the tests, and the corpus readers described below.

## Production changes

1. `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts` (new, 51 lines)
   - Correctness: substitution only when `state["promotion-type"] !== "bug"` is false, using strict equality. This matches the spec: no trim, no case folding, hyphenated key only, `null` and non-string values unchanged. Returns a new array in both branches (no aliasing, no mutation). Order preserved via `map`.
   - Design: no imports, no I/O; exported constants avoid magic strings. Route-agnostic no-op for lists lacking the feature tool.
   - Style: JSDoc on all exports, single responsibility, extensible for #509 without touching routing.ts.
2. `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` (+5/-1)
   - The resolved list is computed once (`requiredMcpTools`) and feeds both the `stateList` equality check and the receipt loop, as spec requires. Error text and order untouched. The file remains 455 lines (< 500).
3. `extensions/drm-copilot/jest.config.cjs` (+7)
   - Adds a per-file 85/75 threshold entry for the new module with an explanatory comment. No exclusion added.

## Tests

- `orchestrator-state-promotion-type-parity.test.ts`: read in full. Guarded corpus loading (required keys, `name` equals stem, non-blank notes and errors), minimum-size and on-disk count guards, both-verdict guard, real `config/orchestration-routing.json` matrix, ordered `toEqual`. Read-only fs access, resolved from `__dirname`.
- `orchestrator-state-promotion-tools.test.ts` (194 lines) and `orchestrator-state-routing.promotion-type.test.ts` (177 lines): grep-checked for temp files and banned timing APIs (none). Evidence shows the expect-fail run against the unfixed validator failed for the four bug cases only, then passed after the fix, which demonstrates the tests are discriminating.
- Python and Pester readers mirror the same corpus with the same guards (Pester 15 tests, 0 failures; Python 15 tests pass).
- Corpus: 12 JSON files covering all spec cases plus an extra `null` case.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `orchestrator-state-promotion-tools.test.ts` | line 155 | Fixed-grid invariant test stands in for a property test because `fast-check` is not an approved dependency. | Acceptable; revisit if the dependency is later approved. | No-new-dependency rule and spec constraint. | Test file read; `package.json` has no `fast-check`. |
| Info | `evidence/other/spec-ac-checkoff.2026-09-30T08-00.md` | traceability note | Traceability note admits some AC-to-artifact mappings were by subject proximity. | No action required. | Content is accurate on re-derivation. | Re-derived in `feature-audit.2026-09-30T08-05.md`. |
| Info | `evidence/qa-gates/ps-test-coverage.2026-09-30T07-56.md` | Pester exit code | Pester exit 1 is from two documented pre-existing failures, unchanged by this branch. | No action required. | Failures are identical by name to the baseline. | Baseline and post-change Pester evidence. |

No blocking or remediation-required findings.
