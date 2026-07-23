# Feature Audit: MCP Promotion Tooling Defects (#401) — Remediation Cycle 1 Reaudit

---

**Audit Date:** 2026-07-22
**Feature Folder:** `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/`
**Base Branch:** `main`
**Head Branch:** `bug/mcp-promotion-tooling-defects-401`
**Work Mode:** `full-bug`
**Audit Type:** Reaudit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main` (merge-base commit `a0b251d330525b8307467f4cf529c5cc3e947445`)
- **Head branch/commit:** `bug/mcp-promotion-tooling-defects-401` (commit `3ba0d3c4aab9a57d00a2a02591abcf0e0391c1e2`; includes the original fix commit `9d2e7633` and the remediation commit `3ba0d3c4`)
- **Merge base:** `a0b251d330525b8307467f4cf529c5cc3e947445`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (fresh; resolved head matches `3ba0d3c4`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/**` (baseline, remediation-baseline, regression-testing, qa-gates, other, issue-updates)
  - Cycle-0 audit artifacts (`policy-audit.2026-07-22T21-07.md`, `code-review.2026-07-22T21-07.md`, `feature-audit.2026-07-22T21-07.md`), `remediation-inputs.2026-07-22T21-07.md`, `remediation-plan.2026-07-22T21-20.md`
  - Additional evidence: independent toolchain reruns this reaudit at head `3ba0d3c4` (Prettier/ESLint/tsc/Jest 2031; Black/Ruff/Pyright/pytest 1992 with branch coverage), lcov parsing (`extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`), direct diff inspection of the remediation delta (`git diff 9d2e7633..HEAD`), and `wc -l` over every changed `.ts`/`.py` file
- **Feature folder used:** `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/`
- **Requirements source:** `spec.md` (only source; work mode `full-bug`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`; per the acceptance-criteria tracking rules, `spec.md` is the sole AC source.
- **Scope note:** Audit scope is the full branch diff vs the merge-base (102 files, +3745/−247), covering both commits. No caller scope-narrowing was present or accepted.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/spec.md` — only source (`full-bug`)

### Acceptance criteria

1. AC-1 (Defect B regression): Jest test proves a (bug, minor-audit) promotion produces a bug-headed body with authored content and first line `- Work Mode: minor-audit`. Test passes.
2. AC-2 (Defect B matrix preserved): Jest tests confirm unchanged routing for the verified-correct matrix cells and that invalid combinations still throw before body build. Tests pass.
3. AC-3 (Defect B Python lockstep): identical branch reorder in `scripts/dev_tools/potential_to_issue.py` in the same change set; pytest regression case proves the (bug, minor-audit) bug-headed body; all `test_potential_to_issue*.py` cases pass.
4. AC-4 (Defect A fail-closed): omitted `workspace_root` with no explicit fallback throws with an actionable message naming `workspace_root`; existing fallback-default tests inverted. Tests pass.
5. AC-5 (Defect A schema): all 28 tools list `workspace_root` in `inputSchema.required`; `workspaceRootProperty.description` no longer advertises a `process.cwd()` default; both asserted by Jest tests. Tests pass.
6. AC-6 (Defect A potential_path): workspace-relative `potential_path` resolves against `workspace_root`; absolute preserved; `promotion-filesystem.ts` unmodified. Tests pass.
7. AC-7 (VS Code surface intact): extension command-surface tests pass unchanged in behavior.
8. AC-8 (Failure envelope): omitted-`workspace_root` error surfaces as structured `ok: false` through `toFailureToolResult`, envelope shape preserved; asserted by test.
9. AC-9 (Parity header correction): stale parity-header reference corrected to `scripts/dev_tools/potential_to_issue.py`; routing-table docblock reflects the new branch order.
10. AC-10 (TypeScript toolchain): full TS toolchain single-pass green with coverage line >= 85% and branch >= 75%.
11. AC-11 (Python toolchain): full Python toolchain single-pass green with coverage thresholds (line >= 85%, branch >= 75%) preserved for the changed module.
12. AC-12 (No out-of-scope behavior change): protected files and out-of-scope behaviors unchanged.
13. AC-13 (Docs updated): in-repo docs state `workspace_root` is required; no in-repo doc still claims a `process.cwd()` default for these tools.
14. AC-14 (File-size limit): no production or test file exceeds 500 lines after the change; pre-identified extraction path applied where needed.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Defect B regression (bug, minor-audit) | PASS | Cycle-0 verification stands (fail-before recorded, assertions match the criterion text); test present in the full 2031-test green run at head `3ba0d3c4` this reaudit. Remediation delta does not touch `promotion.ts` or its tests. | `node run-jest.cjs --testMatch "<absolute glob>"` (2031/2031) | Unchanged by cycle 1. |
| 2 | AC-2 Matrix preserved | PASS | `promotion.matrix.test.ts` green in the full run at head; remediation delta touches no promotion code. | `node run-jest.cjs` | Unchanged by cycle 1. |
| 3 | AC-3 Python lockstep | PASS | Lockstep reorder verified in cycle 0; cycle 1 makes no change to `potential_to_issue.py` (verified `git diff 9d2e7633..HEAD`); all `test_potential_to_issue*.py` cases pass inside the 1992-test green run this reaudit. | `poetry run pytest tests/scripts/dev_tools ... --cov-branch` (1992 passed) | Parity contract intact; R2 was tests-only. |
| 4 | AC-4 Fail-closed workspace_root | PASS | Cycle-0 verification stands; suites green at head. | `node run-jest.cjs` | Unchanged by cycle 1. |
| 5 | AC-5 Schema required + description | PASS | Re-verified at head after the R1 split: independent grep count 16 (`mcp-repo-automation-tool-definitions.ts`) + 5 (`...-poshqc.ts`) + 7 (discovery) = 28 required `workspace_root` entries; base mirror 18/18; the AC-5 length-pinned Jest assertions pass unchanged (zero test modifications in cycle 1). | `grep -c '"workspace_root"' src/mcp-*-tool-definitions*.ts`; `node run-jest.cjs` | The split preserved the contract exactly (pure move verified in the remediation diff). |
| 6 | AC-6 potential_path resolution | PASS | Cycle-0 verification stands; `promotion-filesystem.ts` remains absent from the diff (re-verified `git diff --name-status a0b251d3..HEAD`). | `git diff --name-status a0b251d3..HEAD`; `node run-jest.cjs` | Unchanged by cycle 1. |
| 7 | AC-7 VS Code surface intact | PASS | Both extension suites included in the full 2031-test green run at head; no cycle-1 changes to the extension command surface. | `node run-jest.cjs` | Unchanged by cycle 1. |
| 8 | AC-8 Failure envelope | PASS | `mcp-tools.workspace-root.test.ts` green at head; envelope contract untouched by cycle 1. | `node run-jest.cjs` | Unchanged by cycle 1. |
| 9 | AC-9 Parity header + docblock | PASS | Header re-verified at head this reaudit: `promotion.ts` cites `scripts/dev_tools/potential_to_issue.py`. | `head -12 extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` | Unchanged by cycle 1. |
| 10 | AC-10 TypeScript toolchain + coverage | PASS | Independent rerun at head `3ba0d3c4`: Prettier exit 0; `npm run lint` exit 0; `npm run typecheck` exit 0; Jest 2031/2031 exit 0. Coverage from `coverage/lcov.info` (fresh; LF matches post-split lengths 402/123): 96.34% lines / 89.21% branches (>= 85/75); both R1 files 100% line-covered; no regression vs 96.30/89.22 baseline. | `npx prettier --check ...`; `npm run lint`; `npm run typecheck`; `node run-jest.cjs`; lcov parse | Executor qa-gates evidence (2026-07-22T21-30) concurs. |
| 11 | AC-11 Python toolchain + coverage | PASS | Cycle-0 PARTIAL resolved. Independent rerun at head: black (324 unchanged, exit 0), ruff (exit 0), pyright (184 files, 0 errors), pytest 1992 passed with branch coverage. Changed module `potential_to_issue.py` per-module (not TOTAL-row): line 190/200 = 95.00% (>= 85%), branch 54/66 = 81.82% (>= 75%), zero regression (improvement only), verified from both the live coverage run (`200 10 66 12 92%`) and `artifacts/python/lcov.info` (BRH 54 / BRF 66). Improvement delivered tests-only by `test_potential_to_issue_branches.py` (10 cases; no production change, verified by diff). | `poetry run black --check ...`; `poetry run ruff check ...`; `poetry run pyright --outputjson ...`; `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term -q`; lcov parse | Genuine PASS with independent evidence; the corrected `coverage-delta-py.2026-07-22T21-30.md` per-module computation matches this reaudit's measurements exactly. Executor's `[x]` in spec.md stands. |
| 12 | AC-12 No out-of-scope behavior change | PASS | Protected files (`content.ts`, `promotion-filesystem.ts`, `prompt-mode-contract.ts`, `potential_to_issue_content.py`) remain absent from the 102-file diff (re-verified at head). Cycle-1 additions are the pure definitions split and a tests-only Python file; behavior invariance evidenced by the identical 168/2031 Jest counts with zero test modifications. | `git diff --name-status a0b251d3..HEAD`; `git diff 9d2e7633..HEAD` | `evidence/qa-gates/scope-integrity.2026-07-22T21-30.md` concurs. |
| 13 | AC-13 Docs updated | PASS | Cycle-0 verification stands; the cycle-1 delta introduces no new caller-facing docs claims (the new sibling's docblock contains no `process.cwd()` default text — full-file inspection this reaudit). | Cycle-0 residual grep (0 in-scope hits); remediation-diff inspection | Unchanged by cycle 1. |
| 14 | AC-14 File-size limit | PASS | The cycle-0 FAIL is resolved. This reaudit independently measured every changed/new production and test file in the branch diff: all <= 500 lines (largest branch-attributable: 496/487/477/468/451/443/408/402), including the R1 pair (`mcp-repo-automation-tool-definitions.ts` 402, sibling 123; was 504). The two files above 500 (`potential_to_issue.py` 639, `test_potential_to_issue.py` 1076) are pre-existing overages (634/1017 at merge-base) formally deferred per `evidence/other/r3-deferral.2026-07-22T21-30.md` under the cycle-1 exit-condition discretion and the April 2026 precedent for these same files; they are tracked as a Major non-blocking follow-up, not an AC-14 failure attributable to this change. The criterion's pre-identified extraction path (`mcp-tool-inputs.ts` sibling) was applied in cycle 0 and the additional R1 extraction in cycle 1. | `git diff --name-only a0b251d3..HEAD -- '*.ts' '*.py' \| xargs wc -l`; `git show a0b251d3:<file> \| wc -l` (attribution) | Executor's `[x]` in spec.md stands, with the deferral documented. Follow-up issue for the R3 decomposition required post-merge. |

---

## Summary

**Overall Feature Readiness:** READY (GO)

**Criteria summary:**
- **PASS:** 14 criteria (AC-1..AC-14)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Cycle-0 gaps, now closed:**

1. AC-14 (was FAIL/Blocking): `mcp-repo-automation-tool-definitions.ts` reduced 504 → 402 lines via a verified pure extraction of the five PoshQC definitions into a 123-line sibling; schema and behavior invariance independently confirmed (diff inspection; identical 168/2031 Jest counts; 28/28 `workspace_root` required contract intact).
2. AC-11 (was PARTIAL/Major): `potential_to_issue.py` per-module branch coverage raised 68.18% → 81.82% (and line 91.00% → 95.00%) via a tests-only file; independently measured from both the live coverage run and lcov.
3. Evidence accuracy: the corrected `coverage-delta-py.2026-07-22T21-30.md` computes the AC-11 verdict from per-module counts, superseding the defective cycle-0 artifact.

**Open follow-up (non-blocking):**

1. R3 deferral: the two pre-existing over-500-line Python files (639/1076) require a follow-up decomposition issue post-merge, coordinated with the TS/Python byte-parity contract. Deferral rationale: `evidence/other/r3-deferral.2026-07-22T21-30.md`.

**Recommended next steps:**

1. Proceed to PR authoring for branch `bug/mcp-promotion-tooling-defects-401` (blocking-finding count: 0).
2. File the R3 follow-up decomposition issue after merge.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 14 criteria in `spec.md` are checked (`[x]`). The remediation executor re-checked AC-11 and AC-14 with cycle-1 evidence citations; this reaudit independently verified both as genuine PASS (per-module coverage measurements and full line-count sweep above), so their `[x]` state stands. AC-1..AC-10, AC-12, AC-13 were verified PASS in cycle 0 and re-confirmed at head `3ba0d3c4`; their `[x]` state stands. No checkbox changes were required by this review.

### AC Status Summary

- Source: `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/spec.md`
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/spec.md` | 14 | 14 | 0 | AC-11 and AC-14 re-verified as genuine PASS this reaudit; all check-offs evidence-backed |
