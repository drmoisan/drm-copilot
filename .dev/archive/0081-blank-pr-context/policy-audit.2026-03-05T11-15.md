# Policy Compliance Audit: blank-pr-context (Issue #81)

**Audit Date:** 2026-03-05  
**Code Under Test:**
- `extensions/scaffold-extension/resources/templates/collect_pr_context.py`
- `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts`
- `extensions/scaffold-extension/test/extension.integration.test.ts`

**Feature folder selection rule:** User supplied explicit folder `docs/features/active/2026-03-05-blank-pr-context-81`; it also matches branch suffix `-81`, so it was selected as authoritative.

---

## Executive Summary

Overall status is **⚠️ PARTIALLY COMPLIANT** for merge readiness.

What passed:
- PR-context artifacts were refreshed against `development`.
- Focused check-only toolchain for changed scope passed:
  - TS: Prettier check, ESLint, TSC, Jest.
  - Python: Black check, Ruff, Pyright.
- No IDE diagnostics in changed files.

What did not fully pass:
- Acceptance-criteria enforcement via tests is incomplete. Current regression tests validate placeholder detection logic on hardcoded strings rather than validating real generated artifact payloads end-to-end.

**Policy documents evaluated:**
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md`
- [✅] `python-code-change.instructions.md`
- [✅] `python-unit-test.instructions.md`
- [N/A] PowerShell policy docs (no PowerShell files changed)

---

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence | [✅] [PASS] | Tests are isolated Jest cases with per-test setup/reset (`beforeEach`, `afterEach`) in both changed TS test files. |
| Isolation | [✅] [PASS] | Each test targets one command behavior path (branch selection, args, non-zero exit, artifact assertions). |
| Fast Execution | [✅] [PASS] | `npm run test` completed 3 suites / 36 tests in ~0.306s. |
| Determinism | [✅] [PASS] | Extensive mocking of process/fs/vscode dependencies; no network calls. |
| Readability & Maintainability | [✅] [PASS] | Descriptive test names and grouped scenarios per command behavior. |
| Coverage and scenario completeness | [⚠️] [PARTIAL] | Positive and error paths are covered, but placeholder-regression assertion is not wired to actual command output artifacts. See `extension.collect-pr-context.test.ts:373-406` and `extension.integration.test.ts:363-393`. |
| External dependency avoidance | [✅] [PASS] | Tests rely on mocked child processes and fixtures; no external API/database usage. |

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Clarify objective | [✅] [PASS] | Objective and bug context documented in feature `issue.md`, `spec.md`, and `user-story.md` for issue #81. |
| Read existing plan/docs | [✅] [PASS] | Existing plan `plan.2026-03-05T10-42.md` and scoping docs present and referenced. |
| Simplicity and targeted scope | [✅] [PASS] | Change is localized to collector template + two tests. |
| Separation of concerns | [✅] [PASS] | Collector code separates git execution, range resolution, summary/appendix rendering, and CLI handling. |
| File size under 500 lines | [✅] [PASS] | Line counts: `collect_pr_context.py` 298; `extension.collect-pr-context.test.ts` 408; `extension.integration.test.ts` 395. |
| Naming/docs/comments quality | [✅] [PASS] | Added function/class docstrings and clearer function names in changed Python file. |
| Toolchain loop evidence | [⚠️] [PARTIAL] | Focused changed-scope checks passed in this review session; full-repo loop not rerun in this post-implementation audit pass. |

---

## 3. Language-Specific Compliance

### 3A. Python

| Requirement | Status | Evidence |
|---|---|---|
| Black formatting | [✅] [PASS] | `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py` → unchanged, exit 0. |
| Ruff linting | [✅] [PASS] | `poetry run ruff check extensions/scaffold-extension/resources/templates/collect_pr_context.py` → all checks passed. |
| Pyright typing | [✅] [PASS] | `poetry run pyright extensions/scaffold-extension/resources/templates/collect_pr_context.py` → 0 errors. |
| Strong typing / broad ignores | [✅] [PASS] | No `Any`; no new broad `type: ignore`. Only one policy-conformant `# noqa: S603` with runtime validation via `shutil.which`. |
| Error handling and contracts | [✅] [PASS] | Specific exceptions (`FileNotFoundError`, `CalledProcessError`, `RuntimeError`) handled with deterministic non-zero exits. |

### 3B. TypeScript Tests (repo general policy)

| Requirement | Status | Evidence |
|---|---|---|
| Formatting check | [✅] [PASS] | `npm exec -- prettier --check ...` in `extensions/scaffold-extension` passed. |
| Linting | [✅] [PASS] | `npm run lint` passed. |
| Type-checking | [✅] [PASS] | `npm run typecheck` passed. |
| Tests | [✅] [PASS] | `npm run test` passed all 36 tests. |
| Regression assertion quality | [❌] [FAIL] | Placeholder-regression tests do not validate command-generated artifact quality robustly; currently accepts placeholder fixture content with weak line-count check. |

---

## 4. Gaps and Exceptions

### Identified Gaps

1. **Regression test false-confidence risk (Major):**
   - `extension.collect-pr-context.test.ts` introduces `isPlaceholderOnlyArtifact` and assertions on hardcoded strings (`lines 386-406`), not artifacts produced by command execution.
2. **Integration test allows placeholder payload:**
   - `extension.integration.test.ts` writes placeholder text (`lines 365, 369`) then only checks line count `> 1` (`lines 392-393`), which does not enforce substantive content.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

- [⚠️] [PARTIAL] Manual destination-workspace extension-host repro was not re-run during this audit execution; evidence is static from prior artifacts.

---

## 5. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

**Recommendation:** **Needs revision** before PR merge readiness.

Rationale: code and focused toolchain checks are clean, but acceptance criteria requiring placeholder-regression enforcement are not fully satisfied by current tests.

---

## Appendix A: Commands executed in this review (check-only preferred)

- `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
- `npm exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` (cwd: `extensions/scaffold-extension`)
- `npm run lint` (cwd: `extensions/scaffold-extension`)
- `npm run typecheck` (cwd: `extensions/scaffold-extension`)
- `npm run test` (cwd: `extensions/scaffold-extension`)
- `poetry run black --check extensions/scaffold-extension/resources/templates/collect_pr_context.py`
- `poetry run ruff check extensions/scaffold-extension/resources/templates/collect_pr_context.py`
- `poetry run pyright extensions/scaffold-extension/resources/templates/collect_pr_context.py`

## Appendix B: Baseline context evidence

- Canonical summary artifact: `artifacts/pr_context.summary.txt`
- Canonical appendix artifact: `artifacts/pr_context.appendix.txt`
- Base branch used: `development`
- Merge-base range from summary: `024c0176ddb550485bcba2f6011bdfbbeb9767ba..024c0176ddb550485bcba2f6011bdfbbeb9767ba`
