# Feature Audit: Epic-planner per-feature receipt-checks key gate (#543), re-audit after remediation cycle 3

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
**Base Branch:** `main` (resolved as `origin/main`)
**Head Branch:** `bug/epic-planner-receipt-checks-key-gate-543`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 3 (prior audits `feature-audit.2026-10-16T01-36.md`, `feature-audit.2026-10-16T04-40.md`, `feature-audit.2026-10-16T07-16.md`)

---

## Scope and Baseline

- **Base branch:** `main`, resolved as `origin/main` @ `c415af626c292f38b910e3a27e70ab3e1903b31a` (the local `main` ref is stale and was not used)
- **Head branch/commit:** `bug/epic-planner-receipt-checks-key-gate-543` (commit `20c1148c9a92cb7f632bc1b3daafee74564b7ed5`, which merges `origin/main`; PR #955 open)
- **Merge base:** `c415af626c292f38b910e3a27e70ab3e1903b31a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-16 08:56:25 UTC at head `20c1148c9`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/**` (including the cycle-3 `rc3-*` sets)
  - Coverage artifacts: `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info` (present, git-ignored, both written after the last code commit `24dbf128a`; the later merge commit touches none of the item's files)
  - Additional evidence: reviewer re-runs of Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (111 passed), targeted Jest (109 passed), the AC11 literal check, the AC12 and AC13 diff checks, line counts, and `gh pr checks 955`
- **Feature folder used:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` line 12 reads `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (265 files; 28 code files). Cycles 1 to 3 changed six production files beyond the spec's file list (code-review CR-7); each AC is re-evaluated against the current head. AC18 is CI-dependent and is evaluated as pending CI; it is checked off at S9 by the item orchestrator.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` - only source (`## Acceptance Criteria`, 18 checkbox items)

### Acceptance criteria

1. **Python regression (fail-before / pass-after).** `test_ready_gate_skips_feature_receipts_when_keys_absent` asserts the single repository-context error for a Claude-shaped ready checkpoint with no Codex flag; recorded failing pre-fix and passing post-fix.
2. **TypeScript regression (fail-before / pass-after).** The twin test asserts the same single-error result; recorded failing pre-fix and passing post-fix.
3. **Codex flags keep the checks unconditional.** Parametrized over each flag alone; both `features[0]` `must be an object.` errors asserted in both runtimes.
4. **Present-`null` key is still validated.** Both keys, both runtimes, exact strings.
5. **Independent per-key gating.** `logical_agent` error present; no `features[0].topology_receipt` error.
6. **Feature index preserved.** `features[1].topology_receipt` error present; no `features[0]` receipt error.
7. **Byte-identical error strings across runtimes.** Asserted literals match between the two receipt test files, recorded under `evidence/qa-gates/`.
8. **Defect-pinning test updated.** `test_readiness_requires_resolved_child_model_receipt` passes a Codex flag and asserts the exact string.
9. **MCP-level threading.** The service-call test asserts both receipt errors under each Codex flag and none in the key-gated result.
10. **Gating predicate implemented as specified.** Each block gated on the Codex-derived gate or key membership, inside the per-feature loop; call sites pass `key_gated=key_gated` / `requireLaunchPaths`; non-Codex checks unconditioned.
11. **No error string added, removed, or reworded.** Verified by review of the production diff.
12. **Pre-existing tests pass unmodified.** Listed Python tests and TypeScript suites pass without modification.
13. **Out-of-scope paths unchanged.** `git diff main -- <listed paths>` produces no output.
14. **In-file documentation updated.** Docstrings and comments state the key-gating rule.
15. **500-line limit.** Every listed file is at most 500 lines.
16. **Python toolchain clean pass.** Black, Ruff, Pyright exit 0; coverage >= 85% line and >= 75% branch for `validate_epic_planner_state.py`, no regression on changed lines.
17. **TypeScript toolchain clean pass.** Prettier, lint, typecheck exit 0; `epic-planner-state-core.ts` >= 85% line and >= 75% branch, no regression, both outcomes of each conditional exercised.
18. **PR closes the issue (CI-dependent; checked off at S9).** The PR body states `Closes #543`, and CI on the final PR head completes with conclusion `success`.

(Items are abbreviated for the table; the full text is in `spec.md` and is unchanged.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Python regression (fail-before / pass-after) | PASS | `evidence/regression-testing/fail-before-python.2026-10-16T00-41.md` (exit 1), `pass-after-python.2026-10-16T00-45.md` (exit 0) | `poetry run pytest --no-cov -q <11 files>` (reviewer: 111 passed) | Test file not edited in cycle 3. |
| 2 | TypeScript regression (fail-before / pass-after) | PASS | `evidence/regression-testing/fail-before-typescript.2026-10-16T00-42.md` (exit 1), `pass-after-typescript.2026-10-16T00-48.md` (exit 0) | `npx jest <12 suites>` from `extensions/drm-copilot` (reviewer: 109 passed) | Test file unchanged since cycle 0. |
| 3 | Codex flags keep the checks unconditional | PASS | Python parametrized test and TypeScript `it.each` in the receipt test files | same | |
| 4 | Present-`null` key is still validated | PASS | Receipt test files, both runtimes | same | |
| 5 | Independent per-key gating | PASS | Receipt test files, both runtimes | same | |
| 6 | Feature index preserved | PASS | Receipt test files, both runtimes; `*-feature-indices` test files (cycle 1); readiness `features[1]` index case (cycle 3) | same | |
| 7 | Byte-identical error strings | PASS | `evidence/qa-gates/byte-identical-strings.2026-10-16T01-04.md`; standing `test_asserted_messages_match_typescript_twin` in `test_validate_epic_planner_state_feature_receipts.py` passes on reviewer re-run, and the twin helper now fails with a named assertion if a twin is missing (CR-16) | `poetry run pytest --no-cov -q <11 files>` | |
| 8 | Defect-pinning test updated | PASS | `tests/scripts/dev_tools/test_validate_epic_planner_state.py` diff adds `require_codex_model_routing=True` and the exact-string assertion; not touched in cycles 1 to 3 | `git diff c415af626 HEAD -- tests/scripts/dev_tools/test_validate_epic_planner_state.py` | |
| 9 | MCP-level threading | PASS | `validate-orchestration-service-call.test.ts` assertions; suite passes | included in reviewer Jest run | |
| 10 | Gating predicate implemented as specified | PASS | Python `_validate_ready_features`: `if not key_gated or "model_routing_receipt" in feature:` and `if not key_gated or "topology_receipt" in feature:` inside the indexed loop; TypeScript `if (!keyGated \|\| "<key>" in feature)`; call `validateReadyFeatures(featureResult.indexedFeatures, requireLaunchPaths)` | Source reading | Neither file was edited in cycles 2 or 3. |
| 11 | No error string added, removed, or reworded | PASS | Earlier evidence `error-strings-unchanged.2026-10-16T01-03.md`, `rc1-error-strings-unchanged.2026-10-16T04-08.md`, `rc2-error-strings-moved-unchanged.2026-10-16T06-37.md`; reviewer search of the cycle-3 production diff (`bd22d5cf1..47abc8150`) for added or removed lines containing `must`, `Epic planner`, or `Execution readiness`: none | `git diff bd22d5cf1 47abc8150 -- scripts/dev_tools extensions/drm-copilot/src` | Cycle-3 rejections reuse existing messages. |
| 12 | Pre-existing tests pass unmodified | PASS | Reviewer `git diff --stat` on `test_validate_epic_planner_state_launch_binding.py`, `test_epic_planner_readiness.py`, `epic-planner-state-core.test.ts`, `epic-planner-state-launch-binding.test.ts`, `epic-planner-readiness-integrity.test.ts`: no output; the readiness files are in the passing reviewer runs | `git diff --stat c415af626 HEAD -- <5 preserved test files>` | |
| 13 | Out-of-scope paths unchanged | PASS | Reviewer run produced no output | `git diff --stat c415af626 HEAD -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | |
| 14 | In-file documentation updated | PASS | Python `validate_epic_planner_state_text` docstring, `key_gated` comment, `_validate_ready_features` docstring; TypeScript `requireLaunchPaths` comment and `validateReadyFeatures` JSDoc; `evidence/qa-gates/docs-updated.2026-10-16T01-06.md` | Source reading | |
| 15 | 500-line limit | PASS | Listed files: 407, 495, 429, 217, 199, 246 lines; all other changed code files 23 to 371 lines | reviewer `wc -l`; `evidence/qa-gates/rc3-line-counts-final.2026-10-16T08-47.md` | `epic-planner-state-core.ts` has 5 lines of headroom (code-review CR-4). |
| 16 | Python toolchain clean pass | PASS | `rc3-final-python-format/lint/typecheck` evidence; `validate_epic_planner_state.py` 100.00% line / 99.00% branch from `artifacts/python/lcov.info` (LH 191/LF 191, BRH 99/BRF 100); 0 uncovered added lines | `poetry run black --check`, `ruff check`, `pyright` on 15 files (reviewer re-run: exit 0) | |
| 17 | TypeScript toolchain clean pass | PASS | `rc3-final-typescript-format/lint/typecheck` evidence; `epic-planner-state-core.ts` 100.00% line / 96.85% branch from `extensions/drm-copilot/coverage/lcov.info` (LH 495/LF 495, BRH 123/BRF 127); 0 uncovered added lines | Prettier, `npm run lint`, `npm run typecheck` (reviewer re-run: exit 0) | Both outcomes of each key-gate conditional are exercised by the receipt suite. |
| 18 | PR closes the issue (CI-dependent) | UNVERIFIED | PR #955 is open at head `20c1148c9`; its body contains `Closes #543`; `gh pr checks 955` at review time showed 2 checks passed and 17 pending | `gh pr view 955`, `gh pr checks 955` | Pending CI; checked off at S9 by the item orchestrator. Not a review defect. |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 17 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC18, pending CI by design)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC18 awaits CI success on the final head of PR #955 (S9). This is a CI-dependent criterion, not a review defect.

**Recommended follow-up verification steps:**

1. Update the PR #955 body with the cycle-3 Python behaviour changes (drive-qualified paths rejected; `plan_path` equal to `feature_folder` reported) and current counts (code-review CR-7).
2. After CI concludes `success` on the final head, check off AC18 at S9.

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

No source-file checkbox change was made by this review: all 17 PASS criteria were already checked (reviewer reading: 18 checkbox items, one unchecked at line 238, AC18). AC18 stays unchecked.
