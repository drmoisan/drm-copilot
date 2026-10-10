# Code Review: parallel model routing admitted-item source and absent-band test (#843)

**Review Date:** 2026-10-09
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843`
**Base Branch:** `origin/main` (`git diff origin/main...HEAD`)
**Head Branch:** `bug/parallel-model-routing-admitted-item-source-and-absent-band-test-843` (`755537bc3d9cfa5a4efcb085a9bc4ed0afc529b1`)
**Review Type:** Initial review (minor-audit, reduced artifact set)
**Blocking findings:** 0

---

## Executive Summary

The change is Markdown contract text plus tests only: three Markdown runtime surfaces, their three bundled mirrors, three test files, and feature documentation and evidence. No production Python or TypeScript changed, which matches the issue's stated expectation ("No production validator code change is expected for gap 2"). The additions are minimal, consistent with existing helpers, and the tests pin the intended literals. Operator decision Option A (orchestrator-checkpoint `complexity_band` with spawn-time resolution) is recorded as accepted.

**What changed:**
- `.claude/skills/parallel-orchestrate/SKILL.md`: an admitted-item band-source paragraph added in the `**Band and receipt source.**` text and in `## Model Selection`.
- `.claude/agents/parallel-orchestrator.md`: the same rule added to the `## Delegation Model` `model` bullet.
- `.claude/skills/parallel-add/SKILL.md`: a two-line clause in step 2.
- Three byte-identical mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- Tests: four contract tests, plus an absent-band case and a receipt-band-only case in each of the Python and TypeScript routing validator test files.

**Top 3 risks:**
1. The `Resolve-DelegationModel` equivalence claim rests on research reading, not on a test that executes the resolver for an admitted item (CR-1 context, N-5).
2. `test_validate_parallel_planner_state_routing.py` is 494 lines, 6 below the 500-line limit (CR-2).
3. The admitted-item paragraph is duplicated in two sections of one skill file and can drift (CR-1).

**PR readiness recommendation:** **Go** - no blocking findings; quality gates pass; five non-blocking observations are recorded below.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (non-blocking) | `.claude/skills/parallel-orchestrate/SKILL.md` | `**Band and receipt source.**` and `## Model Selection` | CR-1: The admitted-item paragraph is duplicated verbatim in both sections (about 12 lines each) | Keep; consider a single canonical statement and a cross-reference in a later change | Required by AC-1; the contract tests assert the same token set against both copies, which mitigates drift | `feature-audit` AC-1; contract tests in `test_parallel_complexity_routing_contracts.py` |
| Minor (non-blocking) | `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py` | whole file | CR-2: File is 494 lines, 6 below the 500-line limit | Split the file before any further addition | Any addition would breach the file-size policy | `evidence/qa-gates/final-size-and-marker.2026-10-09T20-20.md` |
| Minor (non-blocking) | `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py`; `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` | AC-7 cases (`test_absent_receipt_band_with_item_band_present` and the TS equivalent) | CR-3: AC-7 cases assert inclusion (`in errors` / `arrayContaining`) rather than the full error list | Tighten to exact equality if the full list is later established | Follows the issue's stated assumption that the full list was not established; the weaker form would not catch an unrelated extra error | `issue.md` Assumptions; `evidence/regression-testing/python-routing-cases.2026-10-09T20-17.md` |
| Minor (non-blocking) | `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py` | token-presence assertions | CR-4: Tests check for token presence after whitespace collapsing (for example ``clamped to `opus` ``, ``rather than spawning without `model` ``) and are sensitive to wording changes | None; this is the established style of the file | A rephrase breaks the test without changing meaning, but the style is consistent with existing tests | `evidence/regression-testing/contract-pass-after.2026-10-09T20-22.md` |
| Minor (non-blocking) | `.claude/skills/parallel-orchestrate/SKILL.md`; `.claude/agents/parallel-orchestrator.md` | stop-when-absent phrasing | CR-5: The skill and agent use different stop phrasing ("rather than spawning without `model`" vs "stop rather than spawn without `model`") | None; semantics are identical | The tests accommodate the difference with separate token tuples | Contract tests (separate token tuples) |

No Blocker or Major findings. Blocking findings: 0.

---

## Implementation Audit

### Markdown contract text

- Planner-checkpoint and `## Item Summary` text is retained; only appended paragraphs were added (additions-only diff, no headings added).
- Content matches AC-1/AC-2: orchestrator-checkpoint band source, no `model_routing_receipt`, `complexity_to_model` resolution with `fable` clamped to `opus` when `fable_policy` is `disabled`, explicit `model` on spawn, stop when band is absent, and the `preferred_overlay.agents` equivalence rationale (skill only).
- `parallel-add` step 2 change is a two-line clause confined to step 2; `## Constraints` untouched.
- Mirrors are byte-identical (`cmp` verified in this review).
- Correctness caveat (not a defect): the equivalence claim with `Resolve-DelegationModel` depends on `preferred_overlay.agents` excluding `orchestrator`; this is stated in the text and was taken from research, not re-derived here. The test pins the token but cannot detect a future config change. Recorded as not verified by execution, consistent with the issue's note that live spawn behavior is manual verification.

### Python implementation audit (test files only)

#### What changed well

- Constants `ASSESSMENT_BAND_VS_ABSENT`, `RECEIPT_BAND_VS_ABSENT`, `RECEIPT_BAND_ABSENT_ENUM`, `RECEIPT_BAND_ABSENT_VS_ITEM` match the AC-6/AC-7 literals exactly; `BAND_ABSENT` is the pre-existing check-1 constant.
- The AC-6 case uses `del record["complexity_band"]` on `build_routing_fields()` and asserts exact ordered equality. The AC-7 case deletes only the receipt's band via `nested(...)`.
- New contract tests use the existing `read_text`, `collapse`, `between`, and `section` helpers with Arrange/Act/Assert structure; module-level constants avoid duplication.

#### Type safety and maintainability

- Pyright reports 0 errors; no suppressions were added.

### TypeScript implementation audit (test files only)

#### What changed well

- Mirror constants and cases are identical in text to the Python ones; `delete record["complexity_band"]` and `delete nested(record, "model_routing_receipt")["complexity_band"]`.
- Branch coverage of `parallel-planner-state-routing.ts` rose from 92.59% (25/27) to 100% (27/27), closing the `sameValue` arms noted in #532.

#### Type safety and maintainability

- ESLint, `tsc`, and Prettier pass; no suppressions or `any` were added.

#### Error handling and logging

- Not applicable; test code and Markdown only.

---

## Test Quality Audit

New tests are deterministic, use no clocks, sleeps, or temporary files, and read repository Markdown only.

### Reviewed test and QA artifacts

- `evidence/qa-gates/final-pytest-routing-coverage.2026-10-09T20-20.md`: Python routing suite 31 passed (29 + 2).
- `evidence/qa-gates/final-pytest-ac8-suite.2026-10-09T20-20.md`: AC-8 suite 109 passed (103 + 6).
- `evidence/qa-gates/final-pytest-related.2026-10-09T20-20.md`: related suite 97 passed.
- `evidence/qa-gates/final-jest-routing-file.2026-10-09T20-20.md` and `final-jest-coverage.2026-10-09T20-20.md`: Jest routing file 24 passed (22 + 2); full run 256 suites, 3919 tests passed (3917 + 2).
- `evidence/regression-testing/contract-fail-before.2026-10-09T20-18.md`: 4 failed / 7 passed before the Markdown edits.
- `evidence/regression-testing/fail-before-exception.2026-10-09T20-17.md`: documents why the AC-6/AC-7 cases cannot fail before, because no production code changed.

### Quality assessment prompts

- **Determinism:** No clocks, sleeps, or temporary files; tests read repository Markdown only.
- **Isolation:** Each new case builds its own fields and mutates a fresh record.
- **Speed:** Routing suites are fast; see the evidence files above.
- **Diagnostics:** Assertions use exact literals, so a failure identifies the diverging error text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff is Markdown, tests, and evidence only |
| No unsafe subprocess or command construction | N/A | No production code |
| Input validation at boundaries | N/A | No production code |
| Error handling remains explicit | N/A | No production code |
| Permission-contract rule (no backticked lowercase-led command) | PASS | `test_every_prescribed_command_invocation_has_a_persona_bash_grant` PASSED in `evidence/qa-gates/final-pytest-ac8-suite.2026-10-09T20-20.md` |
| Mirror parity | PASS | `cmp` identical for all three pairs; `evidence/qa-gates/final-mirror-parity.2026-10-09T20-20.md` EXIT_CODE 0 |

---

## Research Log

No external research was required. The equivalence rationale was taken from `research/research.2026-10-08T22-19.md`; this review did not re-derive it.

---

## Verdict

No blocking code-quality issues. Blocking findings: 0. Non-blocking findings: 5 (CR-1 through CR-5).
