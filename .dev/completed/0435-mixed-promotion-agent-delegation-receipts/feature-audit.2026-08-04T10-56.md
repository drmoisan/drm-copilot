# Feature Audit: mixed-promotion-agent-delegation-receipts (#435)

**Audit Date:** 2026-08-04
**Feature Folder:** `docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435`
**Base Branch:** `main`
**Head Branch:** `bug/mixed-promotion-agent-delegation-receipts-435` / `483ec00b`
**Work Mode:** `full-bug`
**Audit Type:** Post-remediation acceptance verification.

## Scope and Baseline

- **Base branch:** `main` at `8a3807b80683883e7fc1d3db22ae99f52a7d5715`.
- **Head branch/commit:** `483ec00b1e0154b9619f1fc7cac8dccc96db667a`.
- **Merge base:** `8a3807b80683883e7fc1d3db22ae99f52a7d5715`.
- **Evidence sources:** primary `artifacts/pr_context.summary.txt`, secondary `artifacts/pr_context.appendix.txt`, direct `main...HEAD` diff, feature `evidence/**`, fresh Python/TypeScript toolchain checks, generator/parity verification, and strict Python completion validation.
- **Primary PR-context evidence:** fresh target-worktree pair, resolving `origin/main` at `8a3807b8` and head at `483ec00b`.
- **Requirements source:** `docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/spec.md`.
- **Work mode resolution note:** `issue.md` explicitly states `full-bug`; therefore `spec.md` is the sole authoritative AC source.

## Acceptance Criteria Inventory

1. Python state validation accepts canonical mixed agents/promotion and strict readers consume nested agents.
2. The TypeScript MCP validator and strict readers accept and consume the same canonical mixed object.
3. Legacy top-level strict-agent list and promotion-only object remain accepted.
4. Invalid agents/promotion/namespaces/strict receipts fail with explicit errors.
5. Focused Python and TypeScript regression tests cover success, compatibility, strict-reader behavior, and invalid boundaries.
6. A complete mixed large-route checkpoint passes strict completion, topology, and model-routing validation on Python and MCP paths.
7. Runtime documentation, generated profiles, and bundled copies pass generator/parity checks.
8. Required Python and TypeScript formatting, linting, type-checking, and test toolchain passes complete without errors.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| 1 | Python canonical mixed object | PASS | Python validator/reader diffs; focused regression evidence. | `poetry run pytest --cov --cov-report=term-missing` | Strict Python completion fixture passed. |
| 2 | TypeScript MCP parity | PASS | TypeScript validator/reader diffs and full test suite. | `npm run test:coverage` | Locally built MCP completion evidence passed; installed MCP predates the branch. |
| 3 | Legacy compatibility | PASS | Parametrized Python tests and matching TypeScript suites. | Python and TypeScript full test suites | Both legacy representations remain accepted. |
| 4 | Invalid boundaries | PASS | Explicit invalid-shape tests in both implementations. | Python and TypeScript full test suites | Errors remain structural and specific. |
| 5 | Regression coverage | PASS | Fail-before/pass-after evidence for both batches and both languages. | Focused evidence commands recorded under `evidence/regression-testing/` | Covers required reader gates. |
| 6 | Complete mixed checkpoint | PASS | `python-complete-mixed-checkpoint` and local-MCP evidence. | `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts ... --require-complete --require-model-routing --require-codex-topology --require-codex-model-routing` | Fresh CLI rerun passed. |
| 7 | Runtime/profile parity | PASS | `runtime-generator-parity.2026-08-04T10-36.md`; fresh generator check and six SHA-256 matches. | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | All root/bundle pairs match. |
| 8 | Toolchain completion | PASS | Fresh Python and configured TypeScript checks; coverage comparison. | `black --check`, Ruff, Pyright, pytest, ESLint, TSC, Jest coverage | Both language thresholds remain satisfied. |

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

The feature behavior is fully evidenced against the current canonical PR context, committed diff, feature evidence, and fresh toolchain checks.

**Recommended follow-up verification steps:**

1. Obtain live GitHub PR and CI status when the GitHub CLI is available.

## Acceptance Criteria Check-off

No checkbox change was made. All eight authoritative `spec.md` criteria were already checked and are independently evaluated as PASS above.

### AC Status Summary

- Source: `docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/spec.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|---|---:|---:|---:|---|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed, no review change required. |
