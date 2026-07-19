# Policy Compliance Audit: legacy-discovery-publishing (Issue #372)

**Audit Date:** 2026-07-19
**Code Under Test:** All files changed between `origin/epic/legacy-discovery-and-parity-integration` (merge-base `a6dd7d4591ef80f4d351cea4b0488ce08568286e`) and `HEAD` (`e64efcd136929f45febca53aec359e46e384f64e`) — one commit (`e64efcd1`).
**Feature folder:** `docs/features/active/2026-07-17-legacy-discovery-publishing-372/`
**Work mode:** `full-feature` (marker `- Work Mode: full-feature` in `issue.md`)
**Template note:** the MCP server tool `resolve_policy_audit_template_asset` is not exposed in this execution environment. This artifact was authored directly from the bundled template on disk at `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, preserving its canonical major headings. Documented environmental assumption, not a scope deviation, consistent with the precedent recorded in `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/policy-audit.2026-07-19T00-43.md`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 (both new test files) | 2069 (full repo suite) | PASS 2069/2069 | line 89.29%, branch 80.09% (repo-wide, independently re-run) | line 89.29%, branch 80.09% (unchanged; zero production code changed) | N/A — new files are test files, excluded from the coverage denominator per `.claude/rules/general-unit-test.md` |
| TypeScript | 0 | 137 (`test/lib/push-down/**`, pre-existing, unmodified) | PASS 137/137 (verified from an alternate, unaffected checkout; see Coverage Verification) | N/A — zero changed TS files | N/A — zero changed TS files | N/A |
| PowerShell | 0 | N/A | N/A | N/A — zero changed files | N/A — zero changed files | N/A |
| C# | 0 | N/A | N/A | N/A — zero changed files | N/A — zero changed files | N/A |
| JSON | 0 (both `core.json` manifests confirmed byte-unmodified) | N/A | N/A | N/A | N/A | N/A |
| Markdown (docs/evidence) | 34 | N/A | N/A | N/A (documentation) | N/A | N/A |

### Coverage Evidence Checklist

- Python coverage artifact: `artifacts/python/lcov.info` (present; parsed first-hand by this reviewer via a full repo-wide `poetry run pytest --cov --cov-branch --cov-report=term-missing` run, independent of the executor's narrower push-down-scoped runs)
- TypeScript coverage artifact: `coverage/lcov.info` under `extensions/drm-copilot/` — not produced in this worktree (Jest test-discovery environment defect; see Coverage Verification). N/A for the mandatory-coverage gate because TypeScript has **zero changed files** on this branch (independently verified: `git diff --name-only origin/epic/legacy-discovery-and-parity-integration...HEAD -- "*.ts" "*.tsx"` returns 0 lines).
- PowerShell / C# coverage artifacts: N/A — zero changed files in both languages.
- Per-language comparison summary: see Coverage Verification below.

---

## Executive Summary

This feature (`legacy-discovery-publishing`, issue #372) is the publishing/mirroring step for the `legacy-discovery-and-parity` epic. Its Phase 1 reconciliation step found **zero** mirror gaps between the repo-root `.claude`/`.codex`/`.agents` trees and the `extensions/drm-copilot/resources/` bundle — every upstream epic-child asset (#365 agent-roles, #366 hooks, #367 skills, and conditionally #359 schemas / #362 init-templates) was already fully mirrored by earlier epic waves before this branch point. This reviewer independently re-verified the zero-gap claim by direct filesystem diff (`.claude/agents`, `.claude/skills`, `.claude/hooks`, `.codex/agents`, `.agents/skills` all byte-identical between repo-root and bundle) and by re-running the Python push-down contract test suite (13/13 passed). Consequently this feature made **zero** production-code changes and **zero** `pack-manifests/core.json` edits (independently confirmed: `git diff` on both `core.json` files is empty). The only substantive change is two new, real-filesystem Python test modules that close a manifest-completeness gap on the Python/Codex side, plus documentation (`spec.md`/`user-story.md`/`plan.md` AC check-offs, evidence artifacts).

**What was independently verified by this reviewer (not merely trusted from the executor's report):**
- Byte-identical mirror completeness for `.claude/agents`, `.claude/skills`, `.claude/hooks`, `.codex/agents`, `.agents/skills` (direct `diff`/`ls` comparison, zero differences).
- Zero diff on both `pack-manifests/core.json` files across the full branch-vs-base range.
- Zero diff on `mapping.py`/`classifier.py`/`inventory.py` (Codex-native converter).
- Schemas (`schemas/discovery/v1/*.schema.json`) and init-templates (`docs/discovery/templates/**`, `scripts/dev_tools/discovery/init_*.py`) verified present at the documented non-mirrored roots.
- Domain-neutrality: full-diff case-insensitive grep for `TaskMaster|TMW|Outlook|VSTO` returns matches only inside plan/spec prose that names the terms as things being checked for — zero occurrences in production or test code.
- Python toolchain: `black --check`, `ruff check`, `pyright` all exit 0; full push-down suite (114 tests, as executed by the executor) and full repo suite (2069 tests, re-run independently by this reviewer) both pass.
- Python coverage: repo-wide 89.29% line / 80.09% branch (parsed first-hand from `artifacts/python/lcov.info` after an independent full-suite re-run), both above the 85%/75% uniform thresholds. (Repo-wide branch is 80.09% not 89.29%; see note under Coverage Verification — this exceeds the 75% branch floor.)
- The Codex-side manifest-completeness test's large "pre-existing, unrelated" exception list (26 agents, 13 hooks, 34 skills) was independently spot-checked: the missing-agent set computed directly against the on-disk manifest matches the documented exception list exactly, and one exception entry (`atomic-planning.toml`) was confirmed absent from `core.json` at the merge-base commit — i.e., genuinely pre-existing, not introduced by this feature.
- The TypeScript Jest test-discovery failure (`No tests found`, 0 matches) was independently reproduced in this worktree, and the root cause (a literal backslash injected into an otherwise forward-slash-normalized `testMatch` glob, specific to this worktree's dot-prefixed path segment `.claude/worktrees/...`) was independently confirmed via `npx jest --showConfig`. This reviewer additionally ran the identical, byte-identical (confirmed via `git diff --stat main...HEAD` = empty for `extensions/drm-copilot/{src,test}/lib/push-down`) push-down TypeScript test suite from the main repository checkout (no dot-segment in its path) and confirmed all 12 suites / 137 tests pass.

**Policy documents evaluated:**
- PASS `general-code-change.instructions.md` / `.claude/rules/general-code-change.md`
- PASS `general-unit-test.instructions.md` / `.claude/rules/general-unit-test.md`

**Language-specific policies evaluated:**
- PASS `python-code-change.instructions.md` + `python-unit-test.instructions.md` / `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- N/A `powershell-*` — zero changed PowerShell files
- N/A `typescript-*` — zero changed TypeScript files (toolchain re-verified as still green against the unchanged tree; see Coverage Verification for the test-suite discussion)
- N/A `csharp-*` — zero changed C# files
- N/A Bash — no Bash scripts changed
- N/A JSON: `format_json`/`validate_json` — no JSON files changed (`core.json` manifests confirmed byte-unmodified)

**Temporary artifacts cleanup:**
- PASS — no temporary/one-time scripts were created by this feature that require deletion; the two new test modules are permanent, policy-compliant additions to `tests/scripts/dev_tools/`.

---

## Rejected Scope Narrowing

None detected in the delegation prompt. The caller explicitly instructed this reviewer to independently verify the mirror-gap and TypeScript-defect claims rather than trust them, and to reach an independent judgment on blocking status rather than defer to the executor's framing — this is a request for rigor, not a scope-narrowing instruction. No caller text attempted to mark any language "out of scope," "plan scope only," or "informational only" when that language had changed files on the branch. TypeScript, PowerShell, and C# are legitimately N/A for the mandatory-coverage gate because each has **zero** changed files on this branch, independently confirmed by this reviewer via `git diff --name-only` restricted to each language's extensions, not because the caller asserted it.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | The two new modules (`test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`) each define independent, real-filesystem-reading functions with no shared mutable state or fixture ordering dependency; re-run individually and as part of the 114-test and 2069-test suites with identical results. |
| **Isolation** | PASS | Each `def test_*` function asserts a single behavior: "every bundled file is listed in some manifest" and (Claude side) "documented exceptions remain absent," (Codex side) "no documented exception is stale on disk." |
| **Fast Execution** | PASS | Both modules combined execute in well under 1 second as part of the 114-test push-down run (3.93s total) and the 2069-test full-repo run (10.65s total), independently re-timed by this reviewer. |
| **Determinism** | PASS | No randomness, wall-clock reads, or network calls. Both modules read only committed, on-disk repository files (`extensions/drm-copilot/resources/**`, `pack-manifests/*.json`). |
| **Readability & Maintainability** | PASS | Descriptive function names (`test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_documented_exceptions_remain_absent_from_every_manifest`, `test_bundled_codex_files_are_listed_in_some_pack_manifest`, `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list`); module docstrings explain purpose, scope, and pre-existing-exception provenance in detail. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-push-down-suite-baseline.2026-07-19T05-20.md` (P0-T14) records the pre-change push-down-subsystem baseline. |
| **No Coverage Regression** | PASS | `coverage-delta-final.2026-07-19T06-30.md` and this reviewer's independent full-repo re-run confirm byte-identical per-module coverage before/after (zero production files changed). Repo-wide: 89.29% line / 80.09% branch, matching the figure independently confirmed in the prior sibling feature's audit (#369) for the same base commit lineage. |
| **New Code Coverage ≥90%** | N/A | The only new files are two test modules. Per `.claude/rules/general-unit-test.md` ("Configure coverage tooling to exclude test files... so metrics reflect application code, not tests"), test files are excluded from the coverage denominator; there is no new production code in this feature. |
| **Comprehensive Coverage** | PASS | Both new test modules exercise 100% of their own logic (each has 2 test functions covering the positive completeness assertion and the exception-staleness/negative-membership assertion); independently confirmed passing via direct `pytest -v` invocation. |
| **Positive Flows** | PASS | `test_bundled_claude_files_are_listed_in_some_pack_manifest` / `test_bundled_codex_files_are_listed_in_some_pack_manifest` assert the real bundle's on-disk state satisfies manifest completeness (excluding documented exceptions). |
| **Negative Flows** | PASS | `test_documented_exceptions_remain_absent_from_every_manifest` / `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list` assert the exception list has not silently drifted stale in either direction (an exception later added to a manifest, or an exception that no longer exists on disk). |
| **Edge Cases** | PASS | Zero-count categories are treated as first-class, valid outcomes throughout the plan and the Phase-1 gap inventories (documented, not silently skipped). |
| **Error Handling** | N/A | The two new tests are pure assertions over deterministic, already-present filesystem state; no error-path branching is part of their contract. |
| **Concurrency** | N/A | Not applicable — single-threaded, read-only filesystem checks. |
| **State Transitions** | N/A | Not applicable — no stateful component under test. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline 89.29% line / 80.09% branch (repo-wide, this reviewer's independent full-suite re-run against the merge-base-equivalent state, since this feature changed zero production files) -> Post-change 89.29% line / 80.09% branch. Change: 0.00% (no regression; matches the prior sibling audit's repo-wide baseline for the same commit lineage). New/changed-code coverage: N/A (test files only, excluded per policy). Disposition: PASS. Evidence: `artifacts/python/lcov.info` (regenerated by this reviewer), `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/regression-testing/coverage-delta-final.2026-07-19T06-30.md`.
- TypeScript: `N/A - out of scope` (zero changed files on this branch). Evidence: `git diff --name-only origin/epic/legacy-discovery-and-parity-integration...HEAD -- "*.ts" "*.tsx"` (0 results, independently re-run by this reviewer).
- PowerShell / C#: `N/A - out of scope` (zero changed files on this branch in either language).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Both modules use f-string assertion messages that print the actual list of missing/stale paths (e.g., `f"Bundled .claude files missing from every manifest: {missing}"`). |
| **Arrange-Act-Assert Pattern** | PASS | Each test enumerates on-disk state (Arrange/Act via helper functions `enumerate_bundled_*_relative_paths`/`union_of_manifest_paths`) then asserts (Assert) a single condition. |
| **Document Intent** | PASS | Module-level docstrings (24 and 36 lines respectively) explain purpose, scope, and the pre-existing-exception rationale in detail; function docstrings follow Google-style with `Returns`/`Raises`/`Side Effects`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or subprocess calls; only `pathlib`/`json` reads of committed repository files. |
| **Use Mocks/Stubs** | N/A | Both modules are intentionally real-filesystem tests (documented in their docstrings as the deliberate design choice, matching the TypeScript twin's real-filesystem approach), not unit tests over fakes. |
| **Environment Stability** | PASS | No temporary files created; no global/mutable state; `REPO_ROOT` is derived deterministically from `Path(__file__).resolve().parents[N]`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, `code-review.2026-07-19T07-10.md`, and `feature-audit.2026-07-19T07-10.md` constitute the required policy review for this branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md`, `spec.md` (13 ACs), and `user-story.md` (5 ACs) fully scope the objective before execution; `spec.md` explicitly documents the "Preparation-Mode Note" acknowledging the upstream assets did not exist at spec-authoring time. |
| **Read existing change plans** | PASS | `plan.2026-07-17T15-30.md` Phase 0 (P0-T1–P0-T8) required reading all seven policy files in order before any implementation task; `phase0-instructions-read.md` records this. |
| **Document the plan** | PASS | `plan.2026-07-17T15-30.md` is an approved, preflight-cleared atomic plan (per the task context) with 13-AC traceability mapping in its final section. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The two new test modules are direct, minimal real-filesystem checks with no unnecessary abstraction; each is a near-literal Python twin of the pre-existing TypeScript `claude-pack-manifest-completeness.test.ts` pattern. |
| **Reusability** | PASS | Both modules share an identical structural pattern (`enumerate_bundled_*_relative_paths`, `union_of_manifest_paths`) without introducing a shared abstraction that would be premature for two call sites; this is a defensible design choice given the differing path shapes (`.claude` vs `.codex`/`.agents`). |
| **Extensibility** | N/A | No public API surface introduced. |
| **Separation of concerns** | PASS | Pure filesystem enumeration/parsing logic is fully separated from assertion logic (helper functions vs `test_*` functions). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Each new file has a single, clearly stated purpose (manifest-completeness check for one bundle side). |
| **Under 500 lines** | PASS | `test_push_down_claude_pack_manifest_completeness.py` = 177 lines; `test_push_down_codex_and_agents_pack_manifest_completeness.py` = 276 lines. Both within the 500-line limit. |
| **Public vs internal** | N/A | Test modules; no public API surface. |
| **No circular dependencies** | PASS | Both modules import only `json`, `pathlib`, `typing` — no circular or cross-test-module imports. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `enumerate_bundled_claude_relative_paths`, `union_of_manifest_paths`, `PRE_EXISTING_UNRELATED_EXCEPTIONS` — all self-describing. |
| **Docs/docstrings** | PASS | Full Google-style docstrings with `Purpose`, `Returns`, `Raises`, `Side Effects` on every function; module docstrings document scope and provenance. |
| **Comment why, not what** | PASS | Inline comments explain rationale for iteration ("Enumerate every bundled agent-persona markdown file", "Union the `paths` array of every manifest file so a path registered in any single manifest counts as covered") rather than narrating trivial lines. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` — exit 0, "324 files would be left unchanged" (independently re-run). |
| **2. Linting** | PASS | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` — exit 0, "All checks passed!" (independently re-run). |
| **3. Type checking** | PASS | `poetry run pyright scripts/dev_tools tests/scripts/dev_tools` — "0 errors, 0 warnings, 0 informations" (independently re-run). |
| **4. Testing** | PASS | Full push-down suite (114/114) and full repo suite (2069/2069) both pass (independently re-run by this reviewer). |
| **Full toolchain loop** | PASS | Single clean pass; `final-qc-rerun-confirmation.2026-07-19T06-32.md` records pass count 1 for the Python loop (P8-T1–P8-T4). |
| **Explicit reporting** | PASS | All commands and exit codes documented in `evidence/qa-gates/*` and independently reproduced in this audit. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | `spec.md` and `user-story.md` both carry updated AC check-offs reflecting the delivered (zero-mirror-gap) outcome; `plan.md` records the actual (mostly no-op) task outcomes. |
| **Design choices explained** | PASS | `spec.md` documents the Codex-native converter determination, pack-manifest placement rationale, and the resolved schema/init-template placement decision in dedicated sections. |
| **Update supporting documents** | PASS | `spec.md`'s new `## Schema/Init-Template Placement — Resolved` section and updated AC check-offs across `spec.md`/`user-story.md`/`plan.md`. |
| **Provide next steps** | PASS | The plan and evidence artifacts document the open, out-of-plan-scope infrastructure defect (Jest worktree-path `testMatch` bug) and recommend concrete follow-up outside this feature's authorized scope; see Gaps and Exceptions. Documenting the next step satisfies this requirement — the underlying defect itself is tracked as an Advisory gap (see Section 8), not a failure of this requirement. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` — exit 0 (re-run). |
| **Linting with Ruff** | PASS | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` — exit 0 (re-run). |
| **Type checking with Pyright** | PASS | `poetry run pyright scripts/dev_tools tests/scripts/dev_tools` — 0 errors (re-run). |
| **Testing with Pytest** | PASS | 114/114 (push-down scope) and 2069/2069 (full repo) both pass (re-run). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Both new modules use `from __future__ import annotations`, fully typed function signatures (`-> list[str]`, `-> frozenset[str]`, `-> None`), and explicit `cast(...)` narrowing for untyped `json.loads` output rather than bare `Any`. |
| **Dataclasses for value objects** | N/A | No value objects introduced; the modules are pure functions plus constant `frozenset` data. |
| **Protocols/ABCs for interfaces** | N/A | No interface abstraction required for this scope. |
| **Avoid utility classes** | PASS | Both modules use free functions, not static-method-only classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | N/A | No exception handling is introduced; assertions are the only control-flow-relevant statements, consistent with test-code conventions. |
| **Logging over print** | N/A | Test modules use `assert` with descriptive messages, not logging or print, consistent with `general-unit-test.md`. |
| **Invariants at construction** | N/A | No class construction in these modules. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | Both new modules use bare `def test_*` functions, collected and run by Pytest without any custom fixtures beyond module-level constants. |
| **Coverage expectation** | PASS | Repo-wide 89.29% line / 80.09% branch (independently re-verified), both above the uniform 85%/75% thresholds; no regression (zero production files changed). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | Each function tests exactly one completeness/staleness condition. |
| **Mocking sparingly** | PASS | Zero mocking used; deliberate real-filesystem design (documented rationale in both docstrings). |
| **Organization** | PASS | `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` mirrors `scripts/dev_tools/push_down_claude_customizations.py`'s subsystem; `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` mirrors the Codex analogue — consistent with the sibling `test_push_down_*` modules already in that directory. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_documented_exceptions_remain_absent_from_every_manifest`, etc. — descriptive, behavior-first names. |
| **Docstrings/comments** | PASS | Every test function has a docstring explaining the scenario and rationale (see 1.3 above). |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -v` — 4/4 passed (re-run). |
| **No Alternative Test Runners** | PASS | Only Pytest used. |

---

## 5. Test Coverage Detail

### `test_push_down_claude_pack_manifest_completeness.py` (2 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_bundled_claude_files_are_listed_in_some_pack_manifest` | Positive (completeness) | PASS |
| `test_documented_exceptions_remain_absent_from_every_manifest` | Negative (exception-staleness) | PASS |

**Coverage:** 100% of the module's own logic exercised by its own tests plus by import-time execution of the two `union_of_manifest_paths`/`enumerate_bundled_claude_relative_paths` helper functions.

### `test_push_down_codex_and_agents_pack_manifest_completeness.py` (2 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_bundled_codex_files_are_listed_in_some_pack_manifest` | Positive (completeness, with 73 documented pre-existing exceptions) | PASS |
| `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list` | Negative (exception-staleness, reverse direction) | PASS |

**Not covered:** None within these modules' own scope. **Independently verified finding:** the Codex-side exception list (26 `.codex/agents/*.toml`, 13 `.codex/hooks/*`, 34 `.agents/skills/*/SKILL.md`) is real and pre-existing — this reviewer computed the missing-agent set directly from the on-disk `core.json` union and it matches the documented 26-entry list exactly; one entry (`atomic-planning.toml`) was independently confirmed absent from `core.json` at the merge-base commit `a6dd7d45`, proving the gap predates this feature. This is a genuine, transparently-disclosed manifest-completeness gap on the Codex side that this feature does not introduce and does not close (see Gaps and Exceptions and the code-review Findings Table for a follow-up recommendation).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (push-down scope, executor's command) | 114 | PASS |
| Total Tests (full repo, this reviewer's independent re-run) | 2069 | PASS |
| Tests Passed | 2069/2069 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time (full repo) | 10.65s | PASS (fast) |
| Execution Time (push-down scope) | 3.93s | PASS (fast) |
| New test functions | 4 | PASS |
| Test File Size | 177 and 276 lines | PASS (maintainable, under 500) |
| Python repo-wide coverage | 89.29% line / 80.09% branch | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` | 324 files unchanged | PASS |
| Ruff Linting | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` | All checks passed | PASS |
| Pyright Type Checking | `poetry run pyright scripts/dev_tools tests/scripts/dev_tools` | 0 errors, 0 warnings | PASS |
| Pytest Tests (full repo) | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 2069 passed | PASS |

**For TypeScript (informational — zero changed files; re-verified against the unchanged tree):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npx prettier --check "src/lib/push-down/**/*.ts" "test/lib/push-down/**/*.ts"` (in `extensions/drm-copilot`) | exit 0 | PASS |
| ESLint | `npx eslint --no-error-on-unmatched-pattern src/lib/push-down test/lib/push-down` (in `extensions/drm-copilot`) | exit 0 | PASS |
| TSC typecheck | `npm run typecheck` (in `extensions/drm-copilot`) | exit 0 | PASS |
| Jest (`node run-jest.cjs --coverage --testPathPattern "test/lib/push-down"`), this worktree | (as above) | `No tests found`, exit 1 | FAIL — worktree-path environment defect (see Coverage Verification) |
| Jest, identical byte-for-byte suite, main repo checkout | `node run-jest.cjs --testPathPattern "test/lib/push-down"` | 12 suites / 137 tests passed, exit 0 | PASS (alternate-environment corroboration) |

**Notes:**
The Jest failure in this worktree is a pre-existing, worktree-path-specific defect (see Coverage Verification), not a regression caused by this feature (zero TypeScript files changed). It is documented here for transparency but does not affect the TypeScript coverage verdict, which is legitimately N/A because TypeScript has zero changed files on this branch.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **TypeScript push-down Jest suite could not be executed from this worktree.** Root cause: this worktree's absolute path contains the dot-prefixed segment `.claude/worktrees/agent-a66ce225a2ded5e52`, which breaks Jest's `testMatch` glob resolution (`npx jest --showConfig` shows a literal backslash injected immediately before `.claude` in an otherwise forward-slash-normalized glob: `C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/.../test/**/*.test.ts`, which matches 0 of the 353 real test files). This reviewer independently reproduced the failure and independently confirmed (a) the root cause via `--showConfig`, (b) that zero TypeScript files were changed by this feature, (c) that `extensions/drm-copilot/{src,test}/lib/push-down` is byte-identical between `main` and this feature branch (`git diff --stat main...HEAD` empty for those paths), and (d) that the identical suite passes 12/12 suites, 137/137 tests when run from the main repository checkout (no dot-segment). **Disposition: not treated as a Blocking finding for this feature** — see `feature-audit.2026-07-19T07-10.md` for the full reasoning. Recommended follow-up: a separate, repo-wide infrastructure issue against `extensions/drm-copilot/jest.config.cjs`'s `testMatch`/`rootDir` handling (or the Jest/micromatch version), and re-verification of the TypeScript twin tests from CI or a non-dotted-path checkout before the epic-level capability is declared fully closed.
2. **Codex-side pack-manifest completeness has a large, pre-existing, undisclosed-until-now gap** (26 agent `.toml` files, 13 hook files, 34 skill `SKILL.md` files never registered in any Codex-side manifest). This feature's new `test_push_down_codex_and_agents_pack_manifest_completeness.py` documents this gap transparently as an out-of-scope exception list rather than silently masking it, and independent verification confirms the gap predates this feature (see Section 5). **Disposition: Advisory, not Blocking** — this feature did not introduce the gap and its own newly-mirrored assets (zero-count) are unaffected. Recommended follow-up: a separate remediation cycle to register the 73 pre-existing Codex-side assets in the appropriate pack manifest(s), as the executor's completion report already recommends.

### Approved Exceptions

**None.** No exceptions were requested or required beyond the two identified gaps above, both of which are pre-existing and out of this feature's authorized plan scope (`extensions/drm-copilot/resources/**`, `scripts/dev_tools/**`, `tests/scripts/dev_tools/**`).

### Removed/Skipped Tests

**None.** All planned tests (P6-T1–P6-T10) were implemented and pass.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **`e64efcd1`** — test(discovery): add manifest-completeness verification for Python side

### Files Modified

1. **`tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`** (NEW, 177 lines) — real-filesystem manifest-completeness check, Claude side.
2. **`tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`** (NEW, 276 lines) — real-filesystem manifest-completeness check, Codex side, with a documented pre-existing-exception list.
3. **`docs/features/active/2026-07-17-legacy-discovery-publishing-372/spec.md`** (MODIFIED, +62/-18) — AC check-offs, new "Schema/Init-Template Placement — Resolved" section.
4. **`docs/features/active/2026-07-17-legacy-discovery-publishing-372/user-story.md`** (MODIFIED, +19/-8) — AC check-offs.
5. **`docs/features/active/2026-07-17-legacy-discovery-publishing-372/plan.2026-07-17T15-30.md`** (MODIFIED, +61/-61) — task check-offs and outcome annotations.
6. **~30 evidence artifacts** (NEW) under `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/{baseline,other,regression-testing,qa-gates}/` — all under the canonical evidence location.

No file under `extensions/drm-copilot/resources/`, `scripts/dev_tools/codex_native_converter/`, or either `pack-manifests/core.json` was changed (independently confirmed).

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All applicable policy gates pass. The feature's actual code-change footprint (two new, well-formed Python test modules) is fully compliant with `general-code-change.md`, `general-unit-test.md`, and `python.md`. The one open item (TypeScript twin test verification) is an independently-corroborated, worktree-path-specific environment defect outside this feature's own change footprint and outside its authorized plan scope; it is documented as an Advisory gap, not a policy violation.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PASS Summarize & Document (including a documented next-steps item for an out-of-scope follow-up; not a gap in this feature's own work)

#### Language-Specific Code Change Policy (Section 3)
**For Python:**
- PASS Tooling & Baseline
- PASS Python Design & Typing
- N/A Error Handling (no exception-handling surface introduced)

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)
**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 2069/2069 full-repo tests passing (100%), independently re-run
- PASS 4/4 new test functions passing, independently re-run
- PASS 89.29% line / 80.09% branch coverage repo-wide, independently re-verified
- PASS Proper file organization: new tests live under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`
- PASS All Python code quality checks passing (Black, Ruff, Pyright)
- PASS Test execution time: 10.65s full repo (fast)

---

### Recommendation

**Ready for merge.**

No Blocking findings. The TypeScript twin-test verification gap is documented, independently corroborated as a pre-existing worktree-path defect unrelated to this feature's (zero) TypeScript changes, and recommended for a separate infrastructure follow-up rather than blocking this feature.

---

## Coverage Verification

Coverage was verified by (a) inspecting the executor's pre-existing on-disk evidence artifacts and (b) independently regenerating `artifacts/python/lcov.info` via a full, unscoped `poetry run pytest --cov --cov-branch --cov-report=term-missing` run from this worktree, then parsing the `LF`/`LH`/`BRF`/`BRH` totals directly from the resulting lcov file.

### Python — PASS (mandatory: 2 changed files, both test files)

- Repo-wide, parsed first-hand from `artifacts/python/lcov.info`: line coverage 89.29% (11138/12474) exceeds the 85% threshold (PASS); branch coverage 80.09% (3628/4530) exceeds the 75% threshold (PASS).
- No regression: this feature added zero production Python files and modified zero existing production Python files (`git diff --name-only` restricted to `scripts/dev_tools/` is empty). The two new files are test files, correctly excluded from the coverage denominator per `.claude/rules/general-unit-test.md`, so there is no "new file" coverage threshold obligation.
- Coverage artifact present: `artifacts/python/lcov.info` (regenerated by this reviewer; the executor's own scoped runs also wrote to this path per `python-test-final.2026-07-19T06-15.md`).

Python coverage verdict: **PASS**.

### TypeScript — N/A (zero changed files; coverage artifact absent but not mandatory)

- `git diff --name-only origin/epic/legacy-discovery-and-parity-integration...HEAD -- "*.ts" "*.tsx"` returns 0 results (independently re-run). Per `.claude/skills/feature-review-workflow/SKILL.md`, "N/A ... acceptable only for languages with zero changed files on the branch" — this condition is met.
- `coverage/lcov.info` under `extensions/drm-copilot/` was not produced in this worktree because `node run-jest.cjs --coverage --testPathPattern "test/lib/push-down"` fails with "No tests found" before any coverage instrumentation runs. This reviewer independently reproduced this failure and traced its root cause via `npx jest --showConfig`, which shows the resolved `testMatch` value contains a literal backslash immediately before the `.claude` path segment (`C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a66ce225a2ded5e52/extensions/drm-copilot/test/**/*.test.ts`), amid an otherwise forward-slash-normalized absolute-path glob — this prevents any match against the 353 real (forward-slash) test files Jest's own crawler discovers ("353 files checked... testMatch: ... 0 matches").
- Independent corroborating evidence: `git diff --stat main...HEAD -- extensions/drm-copilot/src/lib/push-down extensions/drm-copilot/test/lib/push-down` is empty (byte-identical trees), and running `node run-jest.cjs --testPathPattern "test/lib/push-down"` from the main repository checkout (`C:\Users\DanMoisan\repos\drm-copilot`, no dot-prefixed path segment) passes 12/12 suites, 137/137 tests, exit code 0. (Note: adding `--coverage` in the main checkout run additionally triggers unrelated, pre-existing per-file `coverageThreshold` failures for files entirely outside `src/lib/push-down` — e.g. `src/mcp-tool-inputs.ts`, `src/lib/subagent-tree/**` — because `jest.config.cjs`'s `coverageThreshold` gates apply globally to `collectCoverageFrom: ["src/**/*.ts", ...]` regardless of the `--testPathPattern` scope; this is a separate, pre-existing configuration property unrelated to both this feature and the worktree-path defect, confirmed by inspecting `jest.config.cjs` directly.)
- Because TypeScript has zero changed files, this reviewer does not flag the absent coverage artifact as FAIL. This is consistent with the explicit skill contract ("If no coverage artifact exists for a language that has changed files, flag as FAIL" — conditioned on changed files, which TypeScript does not have here).

TypeScript coverage verdict: **N/A (zero changed files)** — with the underlying test suite independently corroborated as passing via an alternate, byte-identical-tree environment.

### PowerShell, C# — N/A (zero changed files)

Both languages have zero changed files on this branch (`git diff --name-only ... | grep -c '\.ps1$'` = 0; `... | grep -c '\.cs$'` = 0).

---

## Evidence Location Compliance

- Branch diff scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: none found (`git diff --name-only origin/epic/legacy-discovery-and-parity-integration...HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` — zero matches).
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0 (independently re-run).
- All feature evidence is under the canonical `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/{baseline,other,regression-testing,qa-gates}/` tree.

Verdict: **PASS**.

## Modified-Workflow-Needs-Green-Run Rule

The branch diff modifies no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (`git diff --name-only origin/epic/legacy-discovery-and-parity-integration...HEAD | grep -E '(\.github/workflows/|scripts/benchmarks/|\.github/actions/)'` — zero matches). Rule does not fire.

Verdict: **PASS (rule not triggered)**.

## Benchmark-Baseline / CI-Workflow / Orchestrator-State Rules

No files under `scripts/benchmarks/**`, no `pwsh` steps added or modified in any workflow, and no `artifacts/orchestration/orchestrator-state.json` edits are part of this branch diff. `.claude/rules/benchmark-baselines.md`, `.claude/rules/ci-workflows.md`, and `.claude/rules/orchestrator-state.md` are not triggered.

---

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest`
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_bundled_codex_files_are_listed_in_some_pack_manifest`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_no_bundled_codex_file_is_absent_from_disk_and_exception_list`

(Plus the pre-existing 110 push-down-suite tests and the remaining 1955 tests across the rest of the repository, all independently re-run and passing; full listing omitted for brevity — see `poetry run pytest --collect-only` for the complete inventory.)

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
poetry run black --check scripts/dev_tools tests/scripts/dev_tools
poetry run ruff check scripts/dev_tools tests/scripts/dev_tools
poetry run pyright scripts/dev_tools tests/scripts/dev_tools
poetry run pytest --cov --cov-branch --cov-report=term-missing
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -v
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -v
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**For TypeScript (working directory `extensions/drm-copilot`):**
```bash
npx prettier --check "src/lib/push-down/**/*.ts" "test/lib/push-down/**/*.ts"
npx eslint --no-error-on-unmatched-pattern src/lib/push-down test/lib/push-down
npm run typecheck
node run-jest.cjs --coverage --testPathPattern "test/lib/push-down"   # fails in this worktree
node run-jest.cjs --testPathPattern "test/lib/push-down"              # passes from main checkout (137/137)
npx jest --showConfig                                                  # root-cause confirmation
```

**Diff/verification commands used by this reviewer:**
```bash
git diff --name-status origin/epic/legacy-discovery-and-parity-integration...HEAD
git diff origin/epic/legacy-discovery-and-parity-integration...HEAD -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
diff <(cd .claude/agents && ls *.md | sort) <(cd extensions/drm-copilot/resources/claude-customizations/.claude/agents && ls *.md | sort)
diff <(cd .claude/skills && find . -type f | sort) <(cd extensions/drm-copilot/resources/claude-customizations/.claude/skills && find . -type f | sort)
diff <(cd .claude/hooks && ls -1 | sort) <(cd extensions/drm-copilot/resources/claude-customizations/.claude/hooks && ls -1 | sort)
diff <(cd .codex/agents && ls *.toml | sort) <(cd extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents && ls *.toml | sort)
diff <(cd .agents/skills && find . -type f | sort) <(cd extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills && find . -type f | sort)
git diff origin/epic/legacy-discovery-and-parity-integration...HEAD | grep -niE "TaskMaster|TMW|Outlook|VSTO"
git diff --stat main...HEAD -- extensions/drm-copilot/src/lib/push-down extensions/drm-copilot/test/lib/push-down
git show a6dd7d4591ef80f4d351cea4b0488ce08568286e:extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-07-19
**Policy Version:** Current (as of audit date)
