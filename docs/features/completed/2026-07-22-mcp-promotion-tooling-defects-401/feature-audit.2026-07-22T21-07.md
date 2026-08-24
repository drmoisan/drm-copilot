# Feature Audit: MCP Promotion Tooling Defects (#401)

---

**Audit Date:** 2026-07-22
**Feature Folder:** `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/`
**Base Branch:** `main`
**Head Branch:** `bug/mcp-promotion-tooling-defects-401`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (merge-base commit `a0b251d330525b8307467f4cf529c5cc3e947445`)
- **Head branch/commit:** `bug/mcp-promotion-tooling-defects-401` (commit `9d2e7633bdb461e2c34b37a784e1f06f9628c73e`)
- **Merge base:** `a0b251d330525b8307467f4cf529c5cc3e947445`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated this audit for base `a0b251d3` → head `9d2e7633`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/evidence/**` (baseline, regression-testing, qa-gates, other, issue-updates)
  - Additional evidence: independent toolchain reruns this audit (Prettier/ESLint/tsc/Jest; Black/Ruff/Pyright/pytest) and lcov parsing (`extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`)
- **Feature folder used:** `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/`
- **Requirements source:** `spec.md` (only source; work mode `full-bug`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`; per the acceptance-criteria tracking rules, `spec.md` is the sole AC source.
- **Scope note:** The PR-context artifacts were missing at review start and were regenerated with the repo collector (`python -m scripts.dev_tools.pr_context.collector --base a0b251d3... --head HEAD`). Audit scope is the full branch diff vs the merge-base (65 files, +1851/−147). The feature is single-version (docs at feature root).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/spec.md` — only source (`full-bug`)

### Acceptance criteria

1. AC-1 (Defect B regression): a Jest test in `extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts` proves that a bug potential with populated bug-template sections, promoted with `work_mode=minor-audit`, produces an issue body headed by the bug sections (`Summary`, `Environment`, `Steps to Reproduce`, `Expected Behavior`, `Actual Behavior`, `Logs / Screenshots`, `Impact / Severity`) containing the authored content — not minor-audit/feature-oriented placeholder sections — and recording `- Work Mode: minor-audit` on the first body line. Test passes.
2. AC-2 (Defect B matrix preserved): Jest tests confirm unchanged routing for the verified-correct matrix cells: (feature|refactor|epic, minor-audit) → `buildMinorAuditBody`; (bug, full-bug) and (bug, full) → `buildBugBody`; (feature|refactor|epic, full-feature|full) → `buildBody`; invalid combinations ((bug, full-feature), (non-bug, full-bug)) still throw before body build. Tests pass.
3. AC-3 (Defect B Python lockstep): `scripts/dev_tools/potential_to_issue.py` receives the identical branch reorder in the same change set, and a pytest regression case in `tests/scripts/dev_tools/test_potential_to_issue.py` proves the (bug, minor-audit) promotion yields a bug-headed body. All pytest cases in `tests/scripts/dev_tools/test_potential_to_issue*.py` pass.
4. AC-4 (Defect A fail-closed): a Jest test proves that resolving any affected tool input with `workspace_root` omitted and no explicit fallback argument throws (is rejected) with an actionable message naming `workspace_root`, rather than silently resolving to `process.cwd()`. Existing fallback-default tests are inverted accordingly. Tests pass.
5. AC-5 (Defect A schema): every tool in `REPO_AUTOMATION_TOOLS` (all 28) lists `workspace_root` in its `inputSchema.required` array, and `workspaceRootProperty.description` no longer advertises a `process.cwd()` default; both facts are asserted by Jest tests in `test/mcp-repo-automation-tool-definitions.test.ts` (and discovery-definitions coverage). Tests pass.
6. AC-6 (Defect A potential_path): a Jest test proves that a workspace-relative `potential_path` passed to `resolvePotentialToIssueToolInput` resolves against the supplied `workspace_root` (not `process.cwd()`), and that an absolute `potential_path` is preserved. `promotion-filesystem.ts` (`RealPotentialFileSystem`) is unmodified. Tests pass.
7. AC-7 (VS Code surface intact): the extension command-surface tests (`test/extension.potential-to-issue.test.ts`, `test/extension.new-potential-bug-entry-inprocess.test.ts`) pass unchanged in behavior — the explicit `getWorkspaceRoot()` path continues to work with no new errors.
8. AC-8 (Failure envelope): the omitted-`workspace_root` error surfaces to MCP callers as a structured `ok: false` result through the existing `toFailureToolResult` path, preserving the `RepoAutomationMcpToolResult` envelope shape; asserted by test.
9. AC-9 (Parity header correction): the stale parity-header reference in `promotion.ts` (`resources/scripts/dev_tools/potential_to_issue.py`) is corrected to `scripts/dev_tools/potential_to_issue.py`, and the `buildIssueBody` routing-table docblock reflects the new branch order.
10. AC-10 (TypeScript toolchain): full TypeScript toolchain passes in a single pass from `extensions/drm-copilot/` (and repo root if touched): `npm run format` (Prettier), `npm run lint` (ESLint), `npm run typecheck` (tsc), `npm run test` (Jest), with `npm run test:coverage` showing line coverage >= 85% and branch coverage >= 75%.
11. AC-11 (Python toolchain): full Python toolchain passes in a single pass: black, ruff, pyright, pytest, with coverage thresholds (line >= 85%, branch >= 75%) preserved for the changed module.
12. AC-12 (No out-of-scope behavior change): no behavior changes outside the defined scope — `content.ts`, `potential_to_issue_content.py`, `promotion-filesystem.ts`, `prompt-mode-contract.ts` validation semantics, the Python CLI workspace default, and the feature/refactor/epic promotion outputs are unchanged; confirmed by the existing suites passing without semantic modification beyond the documented inversions in AC-4.
13. AC-13 (Docs updated): in-repo skill/agent documentation that instructs calling the affected MCP tools is updated to state that `workspace_root` is required, and no in-repo doc still claims a `process.cwd()` default for these tools.
14. AC-14 (File-size limit): no production or test file exceeds 500 lines after the change; if `mcp-tool-inputs.ts` (currently 499 lines) exceeds the limit, the `potential_path` normalization is extracted to a sibling module following the `mcp-tool-inputs-push-down.ts` precedent.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Defect B regression (bug, minor-audit) | PASS | New `describe("promotePotential — bug promotion in minor-audit mode (AC-1)")` asserts bug headings with authored content, first line `- Work Mode: minor-audit`, zero placeholders. Fail-before recorded (`expect-fail-ts-bug-minor-audit.2026-07-22T15-53.md`, exit 1); passes in full Jest run this audit. | `node run-jest.cjs` (2031/2031 pass) | Assertions match the criterion text exactly (diff inspection). |
| 2 | AC-2 Matrix preserved | PASS | `promotion.matrix.test.ts` (NEW): minor-audit non-bug routing, (bug, full-bug/full) → bug body, full-feature routing, invalid combos throw; partial-sections placeholder edge case. | `node run-jest.cjs` | All cells green in full run. |
| 3 | AC-3 Python lockstep | PASS | Identical branch reorder verified in `git diff` (bug-first `if`/`elif`/`else` mirrors TS); new `test_promote_potential_bug_minor_audit_uses_bug_body`; fail-before recorded (`expect-fail-py-bug-minor-audit...`, exit 1). | `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue_content.py tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py -q --no-cov` → 38 passed (this audit) | Same change set (single commit `9d2e7633`); parity contract honored. |
| 4 | AC-4 Fail-closed workspace_root | PASS | Six new `normalizeWorkspaceRoot` cases (throw on omitted/no-fallback, explicit fallback preserved, valid/invalid/empty/whitespace) + resolver-level cases in `mcp-tool-inputs.workspace-root.test.ts`; inversions across omission tests in `mcp-tool-inputs.test.ts`, `mcp-tool-inputs-discovery.test.ts`, dispatch suites; fail-before recorded (`expect-fail-ts-defect-a...`, exit 1). | `node run-jest.cjs` | Error message names `workspace_root` with corrective action. |
| 5 | AC-5 Schema required + description | PASS | AC-5 Jest describe pins list length to `REPO_AUTOMATION_TOOLS` and asserts `required` contains `workspace_root` for every tool; description asserted to not contain `process.cwd()`. Independent count: 21 + 7 = 28 required entries match 21 + 7 tool names; base mirror 18/18. | `grep -c '"workspace_root"' src/mcp-*-tool-definitions.ts`; `node run-jest.cjs` | Discovery definitions covered by parametrized both-files assertions and the discovery describe block. |
| 6 | AC-6 potential_path resolution | PASS | `mcp-tool-inputs.workspace-root.test.ts` asserts relative→`C:/ws/...` join and absolute passthrough; summary form pinned in `potential-to-issue-service-call.test.ts`; `promotion-filesystem.ts` absent from `git diff --name-status` (re-verified this audit). | `git diff --name-status a0b251d3..HEAD`; `node run-jest.cjs` | Resolver-layer placement per spec; `RealPotentialFileSystem` untouched. |
| 7 | AC-7 VS Code surface intact | PASS | `vscode-surface-intact.2026-07-22T20-17.md` (targeted run, exit 0); both suites included in this audit's full 2031-test green run; neither test file semantically modified for the explicit-workspace path. | `node run-jest.cjs` | Explicit `getWorkspaceRoot()` fallback path preserved by design (two-argument signature retained). |
| 8 | AC-8 Failure envelope | PASS | `mcp-tools.workspace-root.test.ts` (NEW) asserts `ok:false`, envelope keys (`ok`, `tool`, `workspace_root`, `summary`), and summary containing `workspace_root is required`; `mcp-server.test.ts` updated accordingly. | `node run-jest.cjs` | Error flows through pre-existing `toFailureToolResult`; envelope shape unchanged. |
| 9 | AC-9 Parity header + docblock | PASS | Diff shows header corrected to `scripts/dev_tools/potential_to_issue.py` and the routing-table docblock reordered (bug first, then non-bug minor-audit, then default). | `git diff a0b251d3..HEAD -- extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` | Verified directly in the diff hunks. |
| 10 | AC-10 TypeScript toolchain + coverage | PASS | Independent rerun this audit: Prettier check exit 0; `npm run lint` exit 0; `npm run typecheck` exit 0; full Jest 2031/2031 exit 0. Coverage from `coverage/lcov.info`: 96.34% lines / 89.21% branches (>= 85/75); no regression vs baseline 96.30/89.22. | `npx prettier --check ...`; `npm run lint`; `npm run typecheck`; `node run-jest.cjs`; lcov parse | Executor qa-gates evidence (2026-07-22T20-17) concurs. |
| 11 | AC-11 Python toolchain + coverage | PARTIAL | Toolchain: black/ruff/pyright/pytest all exit 0 on independent rerun. Coverage for the changed module `potential_to_issue.py`: line 91.00% (>= 85%) with zero regression (identical 200/18/66/21 counts vs baseline) — but branch coverage is 68.18% (45/66), below the criterion's stated 75% floor. The shortfall is pre-existing at merge-base and unchanged by this branch. The executor's `coverage-delta-py` evidence computed the branch check against the overall measured set (87.3%) rather than the changed module. | `poetry run black --check ...`; `poetry run ruff check ...`; `poetry run pyright ...`; `poetry run pytest ... --no-cov`; lcov parse of `artifacts/python/lcov.info` | Left unchecked in spec.md. Gap routed to remediation (R2, Major/non-blocking). "Preserved" (no-regression) holds; the absolute branch threshold for the module does not. |
| 12 | AC-12 No out-of-scope behavior change | PASS | `content.ts`, `promotion-filesystem.ts`, `prompt-mode-contract.ts`, `potential_to_issue_content.py` absent from the 65-file diff (re-verified); targeted grep confirms Python CLI workspace default untouched; matrix tests prove feature/refactor/epic outputs unchanged. | `git diff --name-status a0b251d3..HEAD`; `evidence/qa-gates/scope-integrity.2026-07-22T20-17.md` | Documented AC-4 test inversions are the only semantic test changes. |
| 13 | AC-13 Docs updated | PASS | Doc sweep evidence with SearchScope/SearchPatterns/SearchResult; four SKILL.md copies + both READMEs updated in the diff; this audit's residual grep for `Defaults to process.cwd` outside historical feature docs returns 0. | `grep -rn "Defaults to process.cwd" --include="*.md" --include="*.ts" .` (0 in-scope hits) | Residual `workspace_root` mentions describe it as required. |
| 14 | AC-14 File-size limit | FAIL | The targeted extraction was delivered (`mcp-tool-inputs.ts` 477 + sibling 60), but the criterion "no production or test file exceeds 500 lines after the change" is violated: `mcp-repo-automation-tool-definitions.ts` = **504 lines**, grown from **490 at merge-base by this branch** (+26/−12) — a new violation the executor's line-count evidence did not measure. Pre-existing overages also grew: `potential_to_issue.py` 634→639, `test_potential_to_issue.py` 1017→1076. | `wc -l extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (504); `git show a0b251d3:<file> \| wc -l` (490) | Left unchecked in spec.md. Blocking finding; remediation R1. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 12 criteria (AC-1..AC-10, AC-12, AC-13)
- **PARTIAL:** 1 criterion (AC-11)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 1 criterion (AC-14)

**Top gaps preventing PASS:**

1. AC-14 (Blocking): `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` exceeds the 500-line production-file limit (504 lines; 490 at merge-base) — a new violation introduced by this branch's schema `required` insertions. Requires a precedented sibling-module extraction and reaudit (remediation R1).
2. AC-11 (Major, non-blocking): `scripts/dev_tools/potential_to_issue.py` branch coverage 68.18% < 75% uniform floor — pre-existing at merge-base with zero regression; changed lines fully exercised. Recommended closure via added branch-coverage pytest cases (remediation R2).
3. Evidence accuracy: `coverage-delta-py.2026-07-22T20-17.md` computed the AC-11 branch threshold against the overall measured set instead of the changed module; correct during remediation.

**Recommended follow-up verification steps:**

1. After R1: rerun `wc -l` over every changed production/test file, re-run the full TypeScript toolchain (format → lint → typecheck → Jest → coverage), and pin the counts in a new qa-gates evidence artifact.
2. After R2 (if executed): rerun `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term` and confirm `potential_to_issue.py` branch coverage >= 75% from per-module counts.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 14 criteria were found pre-checked by the executor. This review verified AC-1..AC-10, AC-12, AC-13 as PASS (their `[x]` state stands) and **unchecked AC-11 and AC-14 in `spec.md`** to reflect the verified PARTIAL/FAIL states, documenting the gaps above.

### AC Status Summary

- Source: `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/spec.md`
- Total AC items: 14
- Checked off (delivered): 12
- Remaining (unchecked): 2
- Items remaining: AC-11 (Python toolchain — module branch coverage 68.18% < 75%, pre-existing, no regression); AC-14 (File-size limit — `mcp-repo-automation-tool-definitions.ts` 504 > 500, new violation)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-22-mcp-promotion-tooling-defects-401/spec.md` | 14 | 12 | 2 | Checkbox-backed; AC-11 and AC-14 unchecked by this review (executor had checked them; evidence did not support the check-off) |
