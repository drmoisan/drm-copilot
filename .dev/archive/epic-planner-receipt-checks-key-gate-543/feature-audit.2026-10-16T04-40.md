# Feature Audit: Epic-planner per-feature receipt-checks key gate (#543), re-audit after remediation cycle 1

---

**Audit Date:** 2026-10-16
**Feature Folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
**Base Branch:** `main`
**Head Branch:** `bug/epic-planner-receipt-checks-key-gate-543`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1 (prior audit `feature-audit.2026-10-16T01-36.md`)

---

## Scope and Baseline

- **Base branch:** `main` (merge base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`; `origin/main` is at `de4f91294daa230cebc0df0434c6e2873001d927`, 53 commits ahead, with no overlap on the 14 code files changed here)
- **Head branch/commit:** `bug/epic-planner-receipt-checks-key-gate-543` (commit `c99c528a9bbba77fa3678014f9a3b0f7f669a409`)
- **Merge base:** `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-16 04:32:35 UTC at head `c99c528a9`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/epic-planner-receipt-checks-key-gate-543/evidence/**` (including the cycle-1 `rc1-*` and `remediation-baseline/` sets)
  - Coverage artifacts: `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info` (present, git-ignored, both written after the last code commit)
  - Additional evidence: reviewer re-runs of Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (97 passed), targeted Jest (89 passed), and the AC11 / AC12 / AC13 git diff checks against `adb9aa5f0..c99c528a9`
- **Feature folder used:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` reads `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base (142 files). Cycle 1 changed four production files beyond the spec's file list (CR-5 extension; see code-review CR-7); each AC is re-evaluated against the current head. AC18 is CI-dependent and is evaluated as pending CI; it is checked off at S9 by the item orchestrator.

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
| 1 | Python regression (fail-before / pass-after) | PASS | `evidence/regression-testing/fail-before-python.2026-10-16T00-41.md` (exit 1), `pass-after-python.2026-10-16T00-45.md` (exit 0) | `poetry run pytest --no-cov -q <8 files>` (reviewer: 97 passed) | Test file unchanged in cycle 1. |
| 2 | TypeScript regression (fail-before / pass-after) | PASS | `evidence/regression-testing/fail-before-typescript.2026-10-16T00-42.md` (exit 1), `pass-after-typescript.2026-10-16T00-48.md` (exit 0) | `node run-jest.cjs <8 suites>` (reviewer: 89 passed) | Test file unchanged in cycle 1. |
| 3 | Codex flags keep the checks unconditional | PASS | Python parametrized test and TypeScript `it.each` in the receipt test files; cycle 1 adds a shifted-index Codex-flag test in each runtime | same | |
| 4 | Present-`null` key is still validated | PASS | Receipt test files, both runtimes | same | |
| 5 | Independent per-key gating | PASS | Receipt test files, both runtimes | same | |
| 6 | Feature index preserved | PASS | Receipt test files, both runtimes; cycle 1 strengthens index preservation for non-object entries (`*-feature-indices` test files) | same | |
| 7 | Byte-identical error strings | PASS | `evidence/qa-gates/byte-identical-strings.2026-10-16T01-04.md`, `rc1-byte-identical-strings.2026-10-16T04-07.md`, `rc1-git-byte-identical-strings.2026-10-16T04-09.md`; reviewer constant comparison across the three twin pairs found 0 mismatches | Reviewer script comparing named string constants in each Python / TypeScript pair | |
| 8 | Defect-pinning test updated | PASS | `tests/scripts/dev_tools/test_validate_epic_planner_state.py` diff adds `require_codex_model_routing=True` and the exact-string assertion; not touched in cycle 1 | `git diff adb9aa5f0..HEAD -- tests/scripts/dev_tools/test_validate_epic_planner_state.py` | |
| 9 | MCP-level threading | PASS | `validate-orchestration-service-call.test.ts` added assertions; suite passes | `node run-jest.cjs test/lib/validate/validate-orchestration-service-call.test.ts` (included in reviewer run) | |
| 10 | Gating predicate implemented as specified | PASS | Python `_validate_ready_features` lines 291-299 (`if not key_gated or "<key>" in feature:` inside `for index, feature in indexed_features:`), call `_validate_ready_features(indexed_features, key_gated=key_gated)`; TypeScript `if (!keyGated \|\| "<key>" in feature)` inside `indexedFeatures.forEach`, call `validateReadyFeatures(featureResult.indexedFeatures, requireLaunchPaths)`; `evidence/qa-gates/rc1-gating-predicate.2026-10-16T04-08.md` | Source reading | Cycle 1 changed the first argument to indexed pairs; the predicate and the passed gate value are unchanged. Non-Codex checks remain unconditioned. |
| 11 | No error string added, removed, or reworded | PASS | `evidence/qa-gates/error-strings-unchanged.2026-10-16T01-03.md`, `rc1-error-strings-unchanged.2026-10-16T04-08.md`; reviewer paired comparison over all six production files found 0 unpaired added and 0 unpaired removed lines | `git diff -U0 adb9aa5f0..HEAD -- scripts/dev_tools extensions/drm-copilot/src` filtered for `Epic planner\|must be\|must match`, paired by stripped text | The check was extended to the four cycle-1 files. |
| 12 | Pre-existing tests pass unmodified | PASS | Reviewer `git diff --stat` on `test_validate_epic_planner_state_launch_binding.py`, `test_epic_planner_readiness.py`, `test_epic_planner_git_integrity.py`, `epic-planner-state-core.test.ts`, `epic-planner-state-launch-binding.test.ts`, `epic-planner-readiness-integrity.test.ts`, `epic-planner-git-integrity.test.ts`: no output; all included in the passing reviewer runs | `git diff --stat adb9aa5f0..HEAD -- <7 preserved test files>` | |
| 13 | Out-of-scope paths unchanged | PASS | Reviewer run produced no output | `git diff --stat adb9aa5f0..HEAD -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | The cycle-1 files are not in the excluded list. |
| 14 | In-file documentation updated | PASS | Python `validate_epic_planner_state_text` docstring, `key_gated` comment, `_validate_ready_features` docstring; TypeScript `requireLaunchPaths` comment and `validateReadyFeatures` JSDoc; cycle 1 adds the original-index sentence to both; `evidence/qa-gates/rc1-docs.2026-10-16T04-08.md` | Source reading | |
| 15 | 500-line limit | PASS | Listed files: 407, 495, 429, 204, 199, 246 lines; cycle-1 files: 305, 310, 331, 338, 201, 139, 169, 107 | reviewer `wc -l`; `evidence/qa-gates/rc1-line-counts-final.2026-10-16T04-25.md` | `epic-planner-state-core.ts` has 5 lines of headroom (code-review CR-4). |
| 16 | Python toolchain clean pass | PASS | `rc1-final-python-format/lint/typecheck` evidence; `validate_epic_planner_state.py` 94.24% line / 88.00% branch from `artifacts/python/lcov.info` (LH 180/LF 191, BRH 88/BRF 100), up from 92.55 / 86.00; 0 uncovered added lines | `poetry run black --check`, `ruff check`, `pyright` on 7 files (reviewer re-run: exit 0) | |
| 17 | TypeScript toolchain clean pass | PASS | `rc1-final-typescript-format/lint/typecheck` evidence; `epic-planner-state-core.ts` 98.38% line / 94.12% branch from `extensions/drm-copilot/coverage/lcov.info` (LH 487/LF 495, BRH 112/BRF 119), up from 98.36 / 94.07; 0 uncovered added lines | `npx prettier --check`, `npm run lint`, `npm run typecheck` (reviewer re-run: exit 0) | The criterion names a `text`-reporter command; the figures are now also artifact-verified via the configured `test:coverage` script, which closes prior PA-1. |
| 18 | PR closes the issue (CI-dependent) | UNVERIFIED | No PR exists yet; `pr_context.summary.txt` reports "no PR exists yet for this branch" | `gh pr checks` after PR creation | Pending CI; checked off at S9 by the item orchestrator. Not a review defect. |

---

## Summary

**Overall Feature Readiness:** READY

**Criteria summary:**
- **PASS:** 17 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC18, pending CI by design)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC18 awaits the PR and CI on its final head (S9). This is a CI-dependent criterion, not a review defect.

**Recommended follow-up verification steps:**

1. Rebase onto `main` (53 commits ahead; no overlap on changed code files), then open the PR with `Closes #543` in the body and a note on the cycle-1 CR-5 scope extension and pairing consequence (code-review CR-7).
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

No source-file checkbox change was made by this review: all 17 PASS criteria were already checked (reviewer count: 18 checkbox items, one unchecked at line 238, AC18). AC18 stays unchecked.
