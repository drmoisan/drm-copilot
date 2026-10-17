# Feature Audit: Epic-planner per-feature receipt-checks key gate (#543)

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
**Base Branch:** `main`
**Head Branch:** `bug/epic-planner-receipt-checks-key-gate-543`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`)
- **Head branch/commit:** `bug/epic-planner-receipt-checks-key-gate-543` (commit `5e338716153fcf29c2d9e3c3ba23d16906220cd4`)
- **Merge base:** `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-16 01:29:15 UTC at head `5e3387161`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/**` (57 files)
  - Additional evidence: reviewer re-runs of Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (68 passed), targeted Jest (68 passed), and the AC13 / AC11 / AC12 git diff checks, all against `adb9aa5f0..5e3387161`
- **Feature folder used:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 12 reads `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (67 files). AC18 is CI-dependent and is evaluated as pending CI; it is checked off at S9 by the item orchestrator.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` - only source (`## Acceptance Criteria`, 18 checkbox items)

### Acceptance criteria

1. **Python regression (fail-before / pass-after).** `test_ready_gate_skips_feature_receipts_when_keys_absent` builds a Claude-shaped ready checkpoint, validates with `require_ready_for_execution=True` and no Codex flag, and asserts `errors == ["Execution-ready planner validation requires repository context."]`; recorded failing pre-fix and passing post-fix.
2. **TypeScript regression (fail-before / pass-after).** The twin test in `epic-planner-state-feature-receipts.test.ts` asserts the same single-error result; recorded failing pre-fix and passing post-fix.
3. **Codex flags keep the checks unconditional.** `test_codex_flag_keeps_feature_receipts_unconditional` (each flag alone) and its TypeScript `it.each` twin assert both `features[0]` `must be an object.` errors.
4. **Present-`null` key is still validated.** `test_ready_gate_validates_present_null_feature_receipt` (both keys) and its twin assert the exact `must be an object.` string.
5. **Independent per-key gating.** `test_ready_gate_gates_each_feature_receipt_independently` and its twin assert the `logical_agent` error and no `features[0].topology_receipt` error.
6. **Feature index preserved.** `test_ready_gate_preserves_feature_index_when_receipts_skipped` and its twin assert the `features[1].topology_receipt` error and no `features[0]` receipt error.
7. **Byte-identical error strings across runtimes.** Asserted literals match between the two new test files, recorded under `evidence/qa-gates/`.
8. **Defect-pinning test updated.** `test_readiness_requires_resolved_child_model_receipt` passes a Codex flag and asserts the exact model-receipt string.
9. **MCP-level threading.** `it("threads the Codex flags into epic-planner-state")` asserts both receipt errors under each Codex flag and none in the key-gated result.
10. **Gating predicate implemented as specified.** Both functions gate each block on the Codex-derived gate or key membership, inside the per-feature loop; call sites pass `key_gated=key_gated` / `requireLaunchPaths`; non-Codex checks are not conditioned.
11. **No error string added, removed, or reworded.** Verified by review of the production diff recorded under `evidence/qa-gates/`.
12. **Pre-existing tests pass unmodified.** Listed Python tests and TypeScript suites pass without modification.
13. **Out-of-scope paths unchanged.** `git diff main -- <listed paths>` produces no output.
14. **In-file documentation updated.** Docstrings and comments in both runtimes state the key-gating rule.
15. **500-line limit.** Every listed file is at most 500 lines, recorded under `evidence/qa-gates/`.
16. **Python toolchain clean pass.** Black, Ruff, Pyright exit 0; coverage run exits 0 with >= 85% line and >= 75% branch for `validate_epic_planner_state.py`, no regression on changed lines.
17. **TypeScript toolchain clean pass.** Prettier, lint, typecheck exit 0; `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` exits 0 with the `epic-planner-state-core.ts` row >= 85% line and >= 75% branch, no regression, both outcomes of each conditional exercised.
18. **PR closes the issue (CI-dependent; checked off at S9).** The PR body states `Closes #543`, and CI on the final PR head completes with conclusion `success`.

(Items are abbreviated for the table; the full text is in `spec.md` and is unchanged.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Python regression (fail-before / pass-after) | PASS | `evidence/regression-testing/fail-before-python.2026-10-16T00-41.md` (exit 1), `pass-after-python.2026-10-16T00-45.md` (exit 0); test at line 127 asserts `errors == [REPOSITORY_CONTEXT_ERROR]` | `poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py::test_ready_gate_skips_feature_receipts_when_keys_absent" -vv` | Reviewer re-run of the file passed. |
| 2 | TypeScript regression (fail-before / pass-after) | PASS | `evidence/regression-testing/fail-before-typescript.2026-10-16T00-42.md` (exit 1), `pass-after-typescript.2026-10-16T00-48.md` (exit 0); test asserts `toEqual([REPOSITORY_CONTEXT_ERROR])` | `node run-jest.cjs test/lib/validate/epic-planner-state-feature-receipts.test.ts` | Reviewer re-run passed. |
| 3 | Codex flags keep the checks unconditional | PASS | Python parametrize over both flags (lines 135-152); TypeScript `it.each(codexFlagCases)` | `npm --prefix extensions/drm-copilot test -- <5 suites>`; `poetry run pytest --no-cov -q <4 files>` | |
| 4 | Present-`null` key is still validated | PASS | Python lines 155-173; TypeScript `it.each(presentNullCases)` | same | |
| 5 | Independent per-key gating | PASS | Python lines 176-186; TypeScript "gates each per-feature receipt independently" | same | |
| 6 | Feature index preserved | PASS | Python lines 189-204; TypeScript "preserves the feature index when receipts are skipped" | same | |
| 7 | Byte-identical error strings | PASS | `evidence/qa-gates/byte-identical-strings.2026-10-16T01-04.md`; reviewer comparison of the seven constants in both files found identical literals | Read both test files | |
| 8 | Defect-pinning test updated | PASS | Diff of `tests/scripts/dev_tools/test_validate_epic_planner_state.py` lines 181-193 adds `require_codex_model_routing=True` and `assert expected in errors` | `git diff adb9aa5f0..HEAD -- tests/scripts/dev_tools/test_validate_epic_planner_state.py` | |
| 9 | MCP-level threading | PASS | Six added `expect` lines in `validate-orchestration-service-call.test.ts` lines 212-225 | `npm --prefix extensions/drm-copilot test -- test/lib/validate/validate-orchestration-service-call.test.ts` | |
| 10 | Gating predicate implemented as specified | PASS | Source: Python lines 285-293 and call site 364; TypeScript `if (!keyGated \|\| "model_routing_receipt" in feature)`, `if (!keyGated \|\| "topology_receipt" in feature)`, call `validateReadyFeatures(featureResult.features, requireLaunchPaths)`; `evidence/qa-gates/gating-predicate.2026-10-16T01-01.md` | Source reading; `git diff adb9aa5f0..HEAD -- <2 production files>` | Non-Codex checks (issue_num, paths, statuses) remain unconditioned. |
| 11 | No error string added, removed, or reworded | PASS | `evidence/qa-gates/error-strings-unchanged.2026-10-16T01-03.md`; reviewer check found every removed string line matched by an identical added line | `git diff -U0 adb9aa5f0..HEAD -- <2 production files> \| grep -E "^[-+][^-+]" \| grep -E "Epic planner\|must be\|must match"` paired comparison (no unpaired lines) | |
| 12 | Pre-existing tests pass unmodified | PASS | `evidence/regression-testing/preserved-tests.2026-10-16T01-05.md`; reviewer `git diff --stat` on the launch-binding and readiness test files returned no output; targeted suites passed | `git diff --stat adb9aa5f0..HEAD -- <4 preserved test files>` | |
| 13 | Out-of-scope paths unchanged | PASS | Reviewer run produced no output | `git diff --stat adb9aa5f0..HEAD -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | |
| 14 | In-file documentation updated | PASS | Python `validate_epic_planner_state_text` docstring, `key_gated` comment, `_validate_ready_features` docstring; TypeScript `requireLaunchPaths` comment and `validateReadyFeatures` JSDoc; `evidence/qa-gates/docs-updated.2026-10-16T01-06.md` | Source reading | |
| 15 | 500-line limit | PASS | 397, 488, 429, 204, 199, 246 lines | `evidence/qa-gates/line-counts-final.2026-10-16T01-17.md` | TypeScript source has 12 lines of headroom (code-review CR-4). |
| 16 | Python toolchain clean pass | PASS | `final-python-format/lint/typecheck` evidence; coverage 92.55% line / 86.00% branch (baseline 91.76 / 84.38), confirmed from `artifacts/python/lcov.info` (LH 174/LF 188, BRH 86/BRF 100) | `poetry run black --check`, `ruff check`, `pyright` (reviewer re-run: exit 0) | |
| 17 | TypeScript toolchain clean pass | PASS | `final-typescript-format/lint/typecheck` evidence; `final-typescript-test-coverage.2026-10-16T01-13.md` text row 98.36% lines / 94.06% branch (baseline 98.31 / 93.8); both outcomes of each conditional exercised (`coverage-delta-verification.2026-10-16T01-16.md`) | `npx prettier --check`, `npm run lint`, `npm run typecheck` (reviewer re-run: exit 0) | The criterion specifies text reporters and is met as written. The separate policy requirement for an `lcov.info` artifact is not met (policy-audit PA-1). |
| 18 | PR closes the issue (CI-dependent) | UNVERIFIED | No PR exists yet; `pr_context.summary.txt` reports CI status "(not available)" | `gh pr checks` after PR creation | Pending CI; checked off at S9 by the item orchestrator. Not a review defect. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 17 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC18, pending CI by design)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Policy-audit PA-1 / code-review CR-1: the TypeScript coverage artifact (`lcov.info`) is absent. This is a policy finding outside the acceptance criteria; all non-CI criteria pass.
2. AC18 awaits the PR and CI on its final head (S9).

**Recommended follow-up verification steps:**

1. Run `npm --prefix extensions/drm-copilot run test:coverage`, confirm `extensions/drm-copilot/coverage/lcov.info` exists, and record the artifact-derived figures for `src/lib/validate/epic-planner-state-core.ts` and repo-wide under `evidence/qa-gates/`.
2. After the PR is opened, confirm the body contains `Closes #543` and CI concludes `success` on the final head, then check off AC18 at S9.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md`
- Total AC items: 18
- Checked off (delivered): 17
- Remaining (unchecked): 1
- Items remaining: **PR closes the issue (CI-dependent; checked off at S9).** The pull request body states `Closes #543`, and CI on the final PR head completes with conclusion `success`.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` | 18 | 17 | 1 | Checkbox-backed; AC18 pending CI |

No source-file checkbox change was made by this review: all 17 PASS criteria were already checked by the executor (commit `5e3387161`, `evidence/qa-gates/acceptance-checkoff.2026-10-16T01-18.md`; reviewer `grep -c -e '^- \[x\] ' spec.md` returned 17 and `grep -c -e '^- \[ \] ' spec.md` returned 1). AC18 stays unchecked.
