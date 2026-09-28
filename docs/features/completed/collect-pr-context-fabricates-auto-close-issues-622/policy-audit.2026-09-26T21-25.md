# Policy Compliance Audit: PR-Context Collector Fabricates Auto-Close Issues (#622)

**Audit Date:** 2026-09-26
**Branch:** `bug/collect-pr-context-fabricates-auto-close-issues-622` at `690db2d6`
**Base:** `main`; merge base and scope anchor `ae8d2ce32c95cf03d55ffb544f2514d83ebfc620`
**Scope:** full branch diff `git diff ae8d2ce3...HEAD` (99 files, +5553/-1122). 30 code, test, and configuration files; the remaining 69 files are feature-folder documents and evidence.
**Work Mode:** `full-bug` (`issue.md:9`); AC source `spec.md` only
**#588 branch taken:** N588 (`evidence/baseline/588-detection.2026-09-25T23-29.md`)
**Code Under Test (production):**
- New: `scripts/dev_tools/pr_context/autoclose.py`, `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`
- Modified (Python): `collector.py`, `feature_docs.py`, `models.py`, `render_feature_excerpts.py`, `render_pr_helpers.py` (all under `scripts/dev_tools/pr_context/`)
- Modified (TypeScript): `collector-core.ts`, `feature-docs-parsers.ts`, `models.ts`, `render-feature-excerpts.ts`, `render-pr-helpers.ts` (all under `extensions/drm-copilot/src/lib/pr-context/`)
- Configuration: `extensions/drm-copilot/jest.config.cjs` (five per-file threshold entries)
- Tests: Python 4 new files, 7 modified or split files; TypeScript 3 new files, 3 modified files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 6 production (1 new, 5 modified) + 11 test files | 4508 pytest tests (executor full run); 4420 dev_tools tests (reviewer run) | PASS 4508 passed, 5 skipped, 1 deselected (#510 local-only) | 92.38% lines / 82.08% branches (pr_context package, 1455/1575, 522/636) | 93.03% lines / 83.44% branches (pr_context package, 1496/1608, 534/640; reviewer parse of artifacts/python/lcov.info) | 100.00% lines / 100.00% branches (autoclose.py); 20 of 20 added executable lines in modified files executed |
| TypeScript | 6 production (1 new, 5 modified) + jest.config.cjs + 6 test files | 3098 Jest tests (executor full run); 362 pr-context tests (reviewer run) | PASS 3098 passed, 0 failed | 96.85% lines / 90.55% branches repo-wide (48119/49681, 6884/7602) | 96.88% lines / 90.68% branches repo-wide (48311/49866, 6928/7640; reviewer parse of extensions/drm-copilot/coverage/lcov.info) | 98.66% lines / 95.56% branches (autoclose.ts); 79 of 79 added lines with DA entries have hits > 0 |
| PowerShell | 0 files | N/A | N/A | N/A - no PowerShell changed | N/A - no PowerShell changed | N/A - no PowerShell changed |
| C# | 0 files | N/A | N/A | N/A - no C# changed | N/A - no C# changed | N/A - no C# changed |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/baseline/typescript-coverage-baseline.2026-09-25T23-29.md
- TypeScript post-change coverage artifact: extensions/drm-copilot/coverage/lcov.info (written 2026-09-26 20:25 local, after the last code commit 67b71d21 at 20:21) summarized in docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/qa-gates/typescript-coverage-final.2026-09-25T23-29.md and typescript-coverage-delta.2026-09-25T23-29.md
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files in the branch diff)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files in the branch diff)
- Python baseline coverage artifact: docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/baseline/python-coverage-baseline.json
- Python post-change coverage artifact: artifacts/python/lcov.info (written 2026-09-26 20:23 local, after the last code commit) and docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/qa-gates/python-coverage-final.json
- Per-language comparison summary: section 1.2.1 of this audit

---

## Rejected Scope Narrowing

No scope narrowing was present in the caller prompt. The caller named the full diff `git diff ae8d2ce3...HEAD` as the scope, which matches the authoritative scope. The operator approval of the spec decisions (D1, D4, and the others) is accepted as design context and is not a narrowing of the audit scope; those decisions are not raised as findings.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no output (run by this reviewer).
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. PASS.
- All feature evidence is under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/regression-testing/`, `<FEATURE>/evidence/qa-gates/`, and `<FEATURE>/evidence/other/`. The spec (Test Strategy) explicitly rejects the non-canonical `evidence/coverage/` path, and no file was written there.

---

## Executive Summary

The branch fixes the fabricated auto-close list in both runtimes:

- **Extraction (RC1, D1, D6).** One bare-number pattern `(?<!\w)#\d+(?!\w)` is defined once per runtime (`models.py:26` with `re.ASCII`; `models.ts:55` as a `u`-flag literal). All six extractors use it. JIRA-style tokens such as `ISO-8601` and `CR-1` are no longer extracted.
- **Prose citations are mentions only (RC2, RC3, D2).** The collectors no longer copy referenced issues into author-asserted. `build_close_candidates_section` / `buildCloseCandidatesSection` list `author_asserted` alone as author auto-close and list `referenced - verified - author_asserted` as detected.
- **Pending-primary verification (D3, D5).** New pure modules `autoclose.py` and `autoclose.ts` hold the moved classification loop and a new `select_pending_primary` / `selectPendingPrimary`. With gh available, a pending primary is kept only when it classifies as an issue whose state is open (case-insensitive). Fetched details are reused, so each issue is fetched at most once per run.
- **Unverified rendering (D4, D10).** With gh unavailable and a non-empty list, the list is kept and `AUTOCLOSE_UNVERIFIED_ANNOTATION` is appended as a non-bullet line.

Reviewer verification:

- Python: Black check, Ruff, and Pyright (0 errors) pass on the changed trees. `pytest tests/scripts/dev_tools` gives 4420 passed, 5 skipped, 1 failed. The failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, which fails on the gitignored `.claude/state/python-batch-budget.*.json` file (issue #510) and is unrelated to this diff.
- TypeScript: Prettier check, `npm run lint`, and `npm run typecheck` are clean. Jest `test/lib/pr-context` gives 21 suites and 362 tests passed.
- Coverage was parsed independently from `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info`. Every changed production file in both runtimes meets 85% line and 75% branch.
- End-to-end check: the reviewer ran the fixed Python collector against this branch with gh available (`artifacts/pr_context.summary.txt`). `Auto-close issues (author asserted):` renders `None (author has not asserted autoclose issues)`. The autoclose section renders the non-PASS fallback. None of the prose citations in this item's own documents (`#468`, `#584`, `#ISO-8601`, `#CR-1`) appears in any autoclose-labelled output.

No blocking finding was identified. The non-blocking observations are listed in section 8 and in the code review. **Overall verdict: COMPLIANT.**

**Policy documents evaluated:**
- ✅ `CLAUDE.md`
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- ✅ `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- N/A PowerShell, C# (no changed files)

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed. The reviewer's lcov parser is in the session scratchpad only.
- ✅ No new ongoing tooling script was added.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Python tests build their doubles per test (`_gh_double`, `FakePendingIssueClient`) and use `monkeypatch`. TypeScript tests call `jest.restoreAllMocks()` in `afterEach` (`collector-core-autoclose.test.ts:274-276`). |
| **Isolation** | ✅ PASS | `test_autoclose.py` / `autoclose.test.ts` test the selection and classification functions directly. Builder tests call the builder only. Collector tests are separate files. |
| **Fast Execution** | ✅ PASS | 91 new Python tests ran in 0.12 s; the 362 pr-context Jest tests ran in 0.9 s (reviewer runs). |
| **Determinism** | ✅ PASS | No clock read, randomness, sleep, or real timer. The TypeScript collector test injects `clock: () => new Date(Date.UTC(2026, 8, 25, 23, 29, 0))`. |
| **Readability & Maintainability** | ✅ PASS | Descriptive names that match the spec, docstrings, and Arrange/Act/Assert comments. Two Python builder tests use a name-binding alias (code review NB-2). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/python-coverage-baseline.*`, `evidence/baseline/typescript-coverage-baseline.2026-09-25T23-29.md`. |
| **No Coverage Regression** | ✅ PASS | Package and repo-wide totals increased in both runtimes. Two file-level decreases (`collector.py` 93.55% to 93.45% lines, 86.36% to 84.00% branches; `render-pr-helpers.ts` 88.77% to 87.52% lines) come from moving covered code into `autoclose.*` (D7). Every added executable line is covered (`python-coverage-delta`, `typescript-coverage-delta`). The changed lines did not regress. |
| **New Code Coverage >= 85%** | ✅ PASS | `autoclose.py` 100.00% / 100.00%; `autoclose.ts` 98.66% / 95.56% (reviewer parse). |
| **Comprehensive Coverage** | ✅ PASS | `render_feature_excerpts.py` rose from 83.33% / 69.44% (below both floors at baseline) to 86.11% / 75.00%. |
| **Positive Flows** | ✅ PASS | Open / `OPEN` pending primary kept; bare-number acceptance matrix; open primary listed at collector level. |
| **Negative Flows** | ✅ PASS | 13-input rejection matrix for all three extractors in both runtimes; closed, `(unknown)`, `pull`, and `None` primaries excluded. |
| **Edge Cases** | ✅ PASS | `#12-3`, `#12é`, `#١٢`, `abc#12`, `#`, empty text, mixed outcomes, and a duplicate `#7 and #7`. |
| **Error Handling** | ✅ PASS | `classify_entity` returning `None` excludes without raising; `issue_details` is never called for a non-issue (`test_select_pending_primary_excludes_pull_request`, `..._unclassified_ref`, `test_collector_fetches_each_issue_once`). |
| **Concurrency** | N/A | Single-threaded collectors. |
| **State Transitions** | N/A | No stateful component was added. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.38% lines / 82.08% branches (pr_context package) -> Post-change: 93.03% lines / 83.44% branches (pr_context package). Change: +0.65% lines, +1.36% branches; per-file increases except collector.py (93.55% -> 93.45% lines, 86.36% -> 84.00% branches, caused by relocating covered code to autoclose.py). New/changed-code coverage: 100.00% lines for autoclose.py; 100.00% of 20 added executable lines in modified files. Disposition: PASS. Evidence: evidence/baseline/python-coverage-baseline.json, evidence/qa-gates/python-coverage-final.json, evidence/qa-gates/python-coverage-delta.2026-09-25T23-29.md, artifacts/python/lcov.info (reviewer parse).
- TypeScript: Baseline: 96.85% lines / 90.55% branches repo-wide -> Post-change: 96.88% lines / 90.68% branches repo-wide. Change: +0.03% lines, +0.13% branches; render-pr-helpers.ts 88.77% -> 87.52% lines from relocating the builders to autoclose.ts, all other changed files flat or higher. New/changed-code coverage: 98.66% lines for autoclose.ts; 100.00% of 79 added lines with DA entries. Disposition: PASS. Evidence: evidence/baseline/typescript-coverage-baseline.2026-09-25T23-29.md, evidence/qa-gates/typescript-coverage-final.2026-09-25T23-29.md, evidence/qa-gates/typescript-coverage-delta.2026-09-25T23-29.md, extensions/drm-copilot/coverage/lcov.info (reviewer parse).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Python assertions carry messages (for example `f"{token} leaked into:\n{surface}"`, `test_autoclose_collector.py:317`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | `# Arrange`, `# Act`, `# Assert` in every new test body. |
| **Document Intent** | ✅ PASS | Module docstrings name the decisions each file pins (D1-D12). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | gh and git are in-process doubles (`_StubGit`, `_gh_double`, `ScriptRunner`, `jest.spyOn(GhClient.prototype, ...)`). |
| **Use Mocks/Stubs** | ✅ PASS | As above. |
| **No temporary files** | ✅ PASS | The Python collector tests use the `mem_fs_path` in-memory fixture; the TypeScript tests use `TreeFileSystem`. |
| **Linux depth-1 CI hermeticity** | ✅ PASS | Reviewer grep over the added test lines for `tmp_path`, `tempfile`, `mkdtemp`, `os.tmpdir`, `origin/`, `child_process`, `spawnSync`, `execSync`, `subprocess`, `process.cwd`, `.git/`, and drive-root paths found only three benign hits: an import of the `subprocess-runner` type module, the POSIX in-memory output paths `/repo/artifacts/...`, and `Path(__file__).resolve().parents[4]`, which reads the tracked `models.ts` for the spec-mandated literal parity check. No remote ref, gitignored state, or Windows path is used. |

### 1.5 Coverage Exclusion Policy

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No production exclusion added** | ✅ PASS | `jest.config.cjs` gains only `coverageThreshold` entries. `pyproject.toml` is unchanged. The eight excluded lines in `autoclose.py` (`if TYPE_CHECKING:` and Protocol `...` bodies) come from the existing `exclude_lines` patterns. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` (RC1-RC4, D1-D14). |
| **Read policies** | ✅ PASS | `evidence/baseline/phase0-instructions-read.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-09-25T23-29.md`, all tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Pattern replacement plus a two-line close-candidates change; pending selection is a single loop. |
| **Reusability** | ✅ PASS (observation) | One shared pattern replaces six regex copies. `autoclose.ts` adds a seventh private `compareCodePoint` copy in `src/lib/pr-context/` (code review NB-4; pre-existing duplication pattern). |
| **Extensibility** | ✅ PASS | New builder parameters are keyword-only (Python) or optional (TypeScript), with behavior-preserving defaults. `ReferenceClassifier` / `PendingIssueClient` Protocols and `Pick<GhClient, ...>` narrow dependencies. |
| **Separation of concerns** | ✅ PASS | `autoclose.*` is pure logic over an injected client; I/O stays in the gh clients. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Under 500 lines** | ✅ PASS | Reviewer `wc -l`: `collector.py` 461, `render_pr_helpers.py` 315, `autoclose.py` 161, `collector-core.ts` 396, `render-pr-helpers.ts` 417, `autoclose.ts` 298, `collector-output.ts` 494 (unchanged). Largest test files: `test_collect_pr_context_part4.py` 497 (down from 1026 on the base), `test_collect_pr_context.py` 480, `test_autoclose_collector.py` 458. |
| **Public vs internal** | ✅ PASS | `extract_issue_references` and `extractIssueReferences` keep their names and signatures and are still exported (`collector.py:87`, `index.ts:51`). The builders are re-exported from `render-pr-helpers.ts:310-315`. |
| **No circular dependencies** | ✅ PASS | `autoclose.ts` imports only `./models` and the type-only `./gh-client-core`. `tsc` and ESLint are clean. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `select_pending_primary`, `PendingPrimarySelection`, `AUTOCLOSE_PENDING_NOT_OPEN_TEXT`. |
| **Docs/docstrings** | ✅ PASS | Every changed extractor and builder documents bare-number extraction and the new parameters. A grep for `ABC-123` and the JIRA character class across the production modules matches only the untracked-status artifact `render.py,cover`, which the spec lists as out of scope. |
| **Comment why, not what** | ✅ PASS | Comments cite the decision IDs (for example `render_pr_helpers.py:217-218`). |

### 2.5 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Reviewer: `black --check` (303 files unchanged); Prettier check (all matched files formatted). Executor: `qa-gates/py-black`, `ts-prettier`. |
| **2. Linting** | ✅ PASS | Reviewer: `ruff check` (all checks passed); `npm run lint` (clean). |
| **3. Type checking** | ✅ PASS | Reviewer: Pyright strict, 0 errors; `npm run typecheck` clean. |
| **4. Architecture boundaries** | ✅ PASS (observation) | dependency-cruiser is not configured anywhere in the repository (`git ls-files` finds no config). The executor recorded this in `qa-gates/ts-dependency-cruiser`. This is a pre-existing gap, not introduced by this branch (NB-9). |
| **5. Unit tests** | ✅ PASS | Executor: pytest 4508 passed; Jest 3098 passed. Reviewer: the results in the Executive Summary. |
| **6. Contract / schema** | N/A | No schema or contract file changed. The MCP tool schema and CLI flags are unchanged. |
| **7. Integration** | ✅ PASS | The collector-level tests exercise `collect_and_write` / `collectAndWrite` end to end with in-process doubles. The reviewer's live collector run is recorded in the Executive Summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Conventional commits with the `(#622)` suffix. |
| **Design choices explained** | ✅ PASS | spec D1-D14; plan "Branch-specific decisions" section. |
| **Provide next steps** | ✅ PASS (observation) | The spec Rollout section names the extension rebuild and bundle confirmation. The branch is behind `origin/main` (NB-1). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | Reviewer `poetry run black --check scripts/dev_tools/pr_context tests/scripts/dev_tools`. |
| **Linting with Ruff** | ✅ PASS | Reviewer `poetry run ruff check ...`. |
| **Type checking with Pyright** | ✅ PASS | 0 errors, 0 warnings. |
| **Testing with Pytest** | ✅ PASS | See section 6. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations; `re.Pattern[str]`; `Sequence` imported under `TYPE_CHECKING`. |
| **Dataclasses for value objects** | ✅ PASS | `PendingPrimarySelection` is a frozen dataclass. It holds a mutable list and dict (NB-7, informational). |
| **Protocols for interfaces** | ✅ PASS | `ReferenceClassifier`, `PendingIssueClient`. |
| **Keyword-only parameters** | ✅ PASS | `build_issues_to_autoclose_section(*, ..., gh_available: bool = True, pending_primary_excluded: bool = False)` at `render_pr_helpers.py:237-244`. `classify_references` and `select_pending_primary` are keyword-only. |
| **Suppressions** | ✅ PASS | No `noqa`, `type: ignore`, `pyright: ignore`, or `pragma: no cover` in added lines (reviewer grep). |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions / no silent swallow** | ✅ PASS | No new exception handling. `classify_entity`'s existing `None` result is handled explicitly as an exclusion. |

### Section 3B: TypeScript Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Prettier** | ✅ PASS | Reviewer check. |
| **ESLint** | ✅ PASS | `npm run lint` clean. |
| **tsc** | ✅ PASS | `npm run typecheck` clean. |
| **Jest** | ✅ PASS | See section 6. |

#### 3B.2 TypeScript Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No `any` / escape hatches** | ✅ PASS | No `any`, `as unknown as`, `@ts-ignore`, or `eslint-disable` in added lines (reviewer grep). |
| **Readonly results** | ✅ PASS | `PendingPrimarySelection` fields are `readonly`; `fetchedDetails` is a `ReadonlyMap`. |
| **Shared regex safety** | ✅ PASS | `ISSUE_REFERENCE_PATTERN` has no `g` flag. Each extractor builds `new RegExp(ISSUE_REFERENCE_PATTERN, "gu")`, so no `lastIndex` state is shared (spec Technical specifications). |

### Section 3C: Quality Tier

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Tier classification** | ✅ PASS | No new project was added, so `quality-tiers.yml` needs no change. Uniform coverage gates are met. The spec records that property-test libraries are not dependencies of these projects and uses parametrized boundary matrices instead. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Location mirrors source** | ✅ PASS | `scripts/dev_tools/pr_context/autoclose.py` -> `tests/scripts/dev_tools/pr_context/test_autoclose.py`. |
| **Parametrized boundary matrices** | ✅ PASS | `test_issue_reference_pattern.py` (13 x 3 reject, 6 x 3 accept); `test_autoclose_builder.py` (five D12 rows exactly). |
| **Fail-first regression** | ✅ PASS | `evidence/regression-testing/py-fail-first.2026-09-25T23-29.md`: 37 failed on pre-fix production code, including `#ISO-8601`, `#CR-1`, and collector cases C1-C4. |
| **Relocated tests preserved** | ✅ PASS | Collection counts before and after the splits match (`other/relocation-counts-p2`: 24 = 21 + 5 - 2 moved; `relocation-counts-p6`: 58 = 58). |

### Section 4B: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Location** | ✅ PASS | `extensions/drm-copilot/test/lib/pr-context/autoclose.test.ts` mirrors `src/lib/pr-context/autoclose.ts`. |
| **`it.each` matrices** | ✅ PASS | `issue-reference-pattern.test.ts:70, 80`; `autoclose.test.ts:348`; `collector-core-autoclose.test.ts:339, 363`. |
| **Fail-first regression** | ✅ PASS | `evidence/regression-testing/ts-fail-first.2026-09-25T23-29.md`: 34 failed pre-fix, including T1-T4. |
| **No real timers** | ✅ PASS | No `setTimeout`, `Date.now`, or `Math.random` in the new test files (reviewer grep). |

---

## 5. Test Coverage Detail

### scripts/dev_tools/pr_context (Python; reviewer parse of artifacts/python/lcov.info)

| File | Status | Lines | Branches |
|---|---|---|---|
| `autoclose.py` | New | 45/45 = 100.00% | 16/16 = 100.00% |
| `collector.py` | Modified | 157/168 = 93.45% | 42/50 = 84.00% |
| `feature_docs.py` | Modified | 157/168 = 93.45% | 80/92 = 86.96% |
| `models.py` | Modified | 125/126 = 99.21% | 13/14 = 92.86% |
| `render_feature_excerpts.py` | Modified | 124/144 = 86.11% | 54/72 = 75.00% |
| `render_pr_helpers.py` | Modified | 125/130 = 96.15% | 61/64 = 95.31% |

### src/lib/pr-context (TypeScript; reviewer parse of extensions/drm-copilot/coverage/lcov.info)

| File | Status | Lines | Branches |
|---|---|---|---|
| `autoclose.ts` | New | 294/298 = 98.66% | 43/45 = 95.56% |
| `collector-core.ts` | Modified | 388/396 = 97.98% | 52/57 = 91.23% |
| `feature-docs-parsers.ts` | Modified | 313/323 = 96.90% | 55/62 = 88.71% |
| `models.ts` | Modified | 337/337 = 100.00% | 36/36 = 100.00% |
| `render-feature-excerpts.ts` | Modified | 437/452 = 96.68% | 81/93 = 87.10% |
| `render-pr-helpers.ts` | Modified | 365/417 = 87.53% | 75/80 = 93.75% |

---

## 6. Test Execution Metrics

| Run | Command | Result |
|---|---|---|
| Executor Python full | `poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch ... --deselect <#510 node>` | 4508 passed, 5 skipped, 1 deselected |
| Executor TypeScript full | `node run-jest.cjs --coverage ...` | 223 suites, 3098 tests passed; thresholds met (exit 0) |
| Reviewer Python new tests | `poetry run pytest <4 new files> -v` | 91 passed in 0.12 s |
| Reviewer Python dev_tools | `poetry run pytest tests/scripts/dev_tools -q` | 4420 passed, 5 skipped, 1 failed (#510 gitignored-state node; not branch-related) |
| Reviewer TypeScript pr-context | `npm --prefix extensions/drm-copilot test -- test/lib/pr-context` | 21 suites, 362 tests passed |

---

## 7. Code Quality Checks

| Check | Result |
|---|---|
| File-size limit (500) | PASS (section 2.3) |
| Suppressions / escape hatches | PASS (none added) |
| Scope boundary (AC 21) | PASS. The reviewer's `git diff --stat` over `github.py`, `gh-client-*.ts`, the pr-author contract files, `resources/`, `executable-resolver.ts`, `pr-context-service-call.ts`, `collector-output.ts`, and `render.*` is empty. |
| #588-owned literal | PASS. `None (GitHub CLI unavailable; closing issues not verified)` appears in no production or test file (reviewer grep exit 1). |

---

## 8. Gaps and Exceptions

### Identified Gaps

None blocking.

### Observations (non-blocking)

- NB-1: The branch is behind `origin/main` (`b924a9e2`, which adds the #697, #528, and #513 merges). `jest.config.cjs` changed on main in a different hunk (line 225 versus line 42). Integrate by merge (spec D13) and rerun the toolchain before PR creation.
- NB-9: dependency-cruiser is not configured in the repository; the architecture-boundary stage has no tool to run.
- NB-10: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails locally on gitignored `.claude/state` content (issue #510). It is not caused by this branch.
- NB-11: The Python coverage artifact `artifacts/python/lcov.info` is scoped to the `scripts.dev_tools.pr_context` package. That package contains every changed Python production file. A repository-wide Python percentage is not present in that artifact.
- NB-13: `scripts/dev_tools/pr_context/github.py` is 549 lines. It predates this branch and is excluded from this item's scope by the spec.
- Further items in the code review (NB-2 to NB-8, NB-12).

### Approved Exceptions

- The operator approved spec decisions D1-D14, including D1 (bare-number-only extraction) and D4 (keep the list and annotate it when gh is unavailable).
- The D7 contingency was taken for TypeScript only (builders moved to `autoclose.ts`, with a re-export). The plan's branch-specific decision 1 records the reason.

### Removed/Skipped Tests

- No test was removed. The rewritten tests are `test_build_close_candidates_section_lists_referenced_issues_as_detected_only` and `keeps referenced issues out of author auto-close`. The JIRA-positive assertions were inverted. Two collector tests moved to `test_autoclose_collector.py` (C7, C8), and class `TestResolveFeatureDir` moved to `test_render_resolve_feature_dir.py`. Collection counts are preserved.

---

## 9. Summary of Changes

### Commits in This PR/Branch

Code commits: `f61dfd9f` (shared literals), `148a9a31` (fail-first tests), `3738726c` (Python fix), `6fda4b51` (TypeScript fix), `a79d30e0` and `67b71d21` (tests). The other 16 commits carry documentation and evidence (research, spec, plan, preflight revisions, baselines, QA evidence, AC check-off).

### Files Modified

30 code, test, and configuration files, listed under Code Under Test above and in `evidence/qa-gates/ac21-changed-files.2026-09-25T23-29.md`. The remaining 69 files are under the feature folder.

---

## 10. Compliance Verdict

### Overall Status: ✅ COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
PASS. Two observations: the duplicated `compareCodePoint` helper, and dependency-cruiser not being configured.

#### Language-Specific Code Change Policy (Section 3)
PASS for Python and TypeScript.

#### General Unit Test Policy (Section 1)
PASS. The new tests are hermetic and deterministic, and coverage is at or above the floors.

#### Language-Specific Unit Test Policy (Section 4)
PASS.

### Metrics Summary

- Blocking findings: 0
- Python changed-file minimum: 86.11% lines / 75.00% branches (`render_feature_excerpts.py`)
- TypeScript changed-file minimum: 87.53% lines (`render-pr-helpers.ts`) / 87.10% branches (`render-feature-excerpts.ts`)

### Recommendation

Merge `origin/main` into the branch (D13), rerun the toolchain, and proceed to PR authoring.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py`: `test_extractors_reject_non_bare_number_tokens` (39 cases), `test_extractors_accept_bare_number_tokens` (18 cases), `test_issue_reference_pattern_matches_typescript_literal`, `test_autoclose_literals_match_typescript_source`
- `tests/scripts/dev_tools/pr_context/test_autoclose.py`: 12 selection and classification tests
- `tests/scripts/dev_tools/pr_context/test_autoclose_builder.py`: 3 named builder tests and 5 precedence rows
- `tests/scripts/dev_tools/pr_context/test_autoclose_collector.py`: C1-C8 (13 cases)
- `extensions/drm-copilot/test/lib/pr-context/issue-reference-pattern.test.ts`, `autoclose.test.ts`, `collector-core-autoclose.test.ts`
- Modified: `test_collect_pr_context.py`, `_part2.py`, `_part4.py`, `_part5.py` (new split), `test_feature_docs.py`, `test_render.py`, `test_render_resolve_feature_dir.py` (new split), `feature-docs.test.ts`, `render-pr-helpers.test.ts`, `collector-core.test.ts`

## Appendix B: Toolchain Commands Reference

```
# Reviewer commands (this audit)
poetry run black --check scripts/dev_tools/pr_context tests/scripts/dev_tools
poetry run ruff check scripts/dev_tools/pr_context tests/scripts/dev_tools
poetry run pyright scripts/dev_tools/pr_context tests/scripts/dev_tools/pr_context <changed test files>
poetry run pytest tests/scripts/dev_tools -q
npx --prefix extensions/drm-copilot prettier --check <pr-context src and test globs> extensions/drm-copilot/jest.config.cjs
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot test -- test/lib/pr-context
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt

# Executor commands: recorded in evidence/qa-gates/*.2026-09-25T23-29.md
```
