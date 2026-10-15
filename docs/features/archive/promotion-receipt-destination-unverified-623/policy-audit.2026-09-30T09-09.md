# Policy Compliance Audit: promotion-receipt-destination-unverified (#623)

---

**Audit Date:** 2026-09-30
**Timestamp:** 2026-09-30T09-09
**Branch:** `bug/promotion-receipt-destination-unverified-623` at `2597e26d78b11eb03be0ad13c750360bd7793443` (pushed; `origin/bug/promotion-receipt-destination-unverified-623` resolves to the same SHA)
**Base:** `main` / `origin/main` at `6e6ccd62792e0838bee7459a2b468de83ad5d408`; merge-base `6e6ccd62792e0838bee7459a2b468de83ad5d408` (verified with `git merge-base HEAD origin/main`)
**Work Mode:** `full-bug` (marker `- Work Mode: full-bug` in `issue.md`); AC source `spec.md`
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the file the MCP policy-audit template selector `template` serves. The MCP resolver tool is not in this agent's tool allowlist, so the bundled asset file was read directly. This is recorded as an assumption.

**Code Under Test (non-documentation files in the branch diff, 10 files):**

- `extensions/drm-copilot/jest.config.cjs` (modified)
- `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` (modified)
- `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts` (modified)
- `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` (modified)
- `extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts` (modified)
- `extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts` (new)
- `scripts/dev_tools/potential_to_issue.py` (modified)
- `scripts/dev_tools/potential_to_issue_filesystem.py` (new)
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` (new)
- `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py` (new)

The remaining 53 changed files are Markdown under `docs/features/active/promotion-receipt-destination-unverified-623/` (issue, spec, plan, research, evidence).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 4 files (2 production, 2 test) | 5708 tests (11 new) | ✅ 5708 pass, 0 fail, 6 skipped | 93.35% lines, 86.31% branches | 93.41% lines, 86.43% branches | 100.00% (changed lines 469-472 of `potential_to_issue.py`; new module 100.00% lines, 100.00% branches) |
| TypeScript | 6 files (1 production, 1 config, 4 test) | 3318 tests (3 new) | ✅ 3318 pass, 0 fail | 97.02% lines, 91.17% branches | 97.02% lines, 91.17% branches | 100.00% (changed lines 443-447 of `promotion.ts`, both outcomes of line 443) |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |

### Coverage Evidence Checklist

`<FEATURE>` below and in Section 1.2.1 denotes the active feature folder `docs/features/active/promotion-receipt-destination-unverified-623`. The prefix is used because the placeholder guard in `scripts/dev_tools/validate_policy_audit_artifact.py` rejects any checklist or comparison line containing the substring that appears in this feature's slug.

- TypeScript baseline coverage artifact: `<FEATURE>/evidence/baseline/ts-test-coverage.2026-09-30T08-26.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (written 2026-09-30 08:47, after the last TypeScript change in commit `7ea47dec`), summarized in `<FEATURE>/evidence/qa-gates/ts-test-coverage.2026-09-30T08-46.md`
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files in the branch diff)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files in the branch diff)
- Python baseline coverage artifact: `<FEATURE>/evidence/baseline/py-test-coverage.2026-09-30T08-26.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (written 2026-09-30 08:54, Phase 8 pass 2, after the eighth filesystem test was added), summarized in `<FEATURE>/evidence/qa-gates/py-test-coverage.2026-09-30T08-54.md`
- Per-language comparison summary: Section 1.2.1 of this document

---

## Executive Summary

The branch adds a post-move destination existence check to the promotion workflow in both the TypeScript source (`promotePotential` in `promotion.ts`) and the Python parity source (`promote_potential` in `potential_to_issue.py`). When the destination is absent after the move, both emit `Promoted file missing after move: <dest>` and return exit code 1 with no destination. The Python `FileSystem` Protocol and `RealFileSystem` adapter were moved verbatim to a new module `potential_to_issue_filesystem.py` and re-exported, reducing `potential_to_issue.py` from 639 to 559 lines. Regression tests were added in both languages, and the service-call test fake was replaced so the #487 receipt guard keeps true-branch coverage.

The reviewer independently re-ran check-only toolchain stages (Black check, Ruff, Pyright, Prettier check, ESLint, `tsc --noEmit`, targeted Pytest and Jest suites) at HEAD; all passed. Coverage was verified by parsing the existing lcov artifacts rather than regenerating them. All coverage thresholds are met for every changed production file and repo-wide in both languages. No blocking findings were identified. Three non-blocking observations are recorded in Section 8.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- ✅ `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- ✅ Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- ✅ TypeScript: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`
- N/A PowerShell (zero changed files)
- N/A C# (zero changed files)
- N/A Bash (zero changed files)
- N/A JSON (zero changed files)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts were committed. The reviewer's own read-only helper scripts were written to the session scratchpad outside the repository.
- ✅ No new tooling scripts were added to the repository.

---

## Rejected Scope Narrowing

None detected. The caller prompt stated "Scope determination is yours." and supplied the resolved base, merge-base, head, feature folder, AC source, and plan path. It described one executor deviation (the eighth test in `test_potential_to_issue_filesystem.py`) and asked for it to be evaluated on its merits; this is an evaluation request, not a scope restriction. The audit scope is the full branch diff `6e6ccd62792e0838bee7459a2b468de83ad5d408...2597e26d78b11eb03be0ad13c750360bd7793443` (63 files).

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no `VIOLATION:` lines.
- A scan of `git diff --name-only 6e6ccd62...HEAD` for paths beginning `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` returned an empty list.
- All 49 evidence files are under `docs/features/active/promotion-receipt-destination-unverified-623/evidence/{baseline,regression-testing,qa-gates,other}/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries were required.

**Verdict: PASS.**

## Workflow-Modification Rule (`modified-workflow-needs-green-run`)

`git diff --name-only 6e6ccd62...HEAD -- .github/workflows scripts/benchmarks .github/actions` returned zero files. The rule does not fire. **Verdict: N/A (no trigger paths changed).**

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Every new test builds its own fake (`DroppingMovePotentialFileSystem`, `FakePotentialFileSystem`, `InMemoryFileSystem`, `DroppingMoveFileSystem`, `LateBlockedPathPotentialFileSystem`) inside the test body. `monkeypatch` restores patched `Path` methods and `shutil.move` after each test. No module-level mutable state is shared. |
| **Isolation** - Each test targets single behavior | ✅ PASS | Each `RealFileSystem` method has one test; each workflow outcome (missing destination, present destination) has one test per language. The eighth Python test calls all seven Protocol members in one test; it targets one property (Protocol placeholder bodies return None) and is discussed in Section 8. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Reviewer run: 60 Python promotion tests in 0.90 s; 9 Jest suites (118 tests) in the promotion directories completed within the default run. Full Python suite 76.82 s for 5708 tests; full Jest 237 suites (evidence). |
| **Determinism** - Consistent results | ✅ PASS | No clock, RNG, network, subprocess, or disk access in the new tests. gh is replaced by `FakeGhClient` / `StubGhClient`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive test names that state the scenario and outcome; `# Arrange`, `# Act`, `# Assert` markers; docstrings on every Python test and fake. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Python baseline 93.35% lines (15811/16937), 86.31% branches (5270/6106); `potential_to_issue.py` 95.00% lines, 81.82% branches. TypeScript baseline 97.02% lines, 91.17% branches; `promotion.ts` 98.87% lines, 83.08% branches. Recorded 2026-09-30T08-26 under `evidence/baseline/`. |
| **No Coverage Regression** | ✅ PASS | Python 93.41% lines (+0.06), 86.43% branches (+0.12); `potential_to_issue.py` 99.44% lines (+4.44), 90.74% branches (+8.92). TypeScript 97.02% lines (0.00), 91.17% branches (0.00); `promotion.ts` 98.89% lines (+0.02), 83.82% branches (+0.74); `potential-to-issue-service-call.ts` unchanged at 100.00% / 85.00%. |
| **New Code Coverage** (policy: line >= 85%, branch >= 75%) | ✅ PASS | New module `potential_to_issue_filesystem.py`: 31/31 lines (100.00%), 14/14 branches (100.00%). Changed Python lines 469-472: 4/4 executed; `BRDA:469` records both arcs (to 470 and to 472) hit. Changed TypeScript lines 443-447: 4/4 executed; line 444-445 true path hit 2 times, line 447 false path hit 37 times. |
| **Comprehensive Coverage** | ✅ PASS | `promotePotential` new branch: 2 direct tests plus 1 service-call test. `promote_potential` new branch: 2 tests. `RealFileSystem` 7 methods: 7 tests. `FileSystem` Protocol: 1 test. Re-export identity: 1 test. |
| **Positive Flows** - Valid inputs | ✅ PASS | `returns exit code 0 with the destination when the promoted file exists after the move` (TS); `test_promote_potential_returns_destination_when_move_succeeds` (Python); all seven `RealFileSystem` delegation tests. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `returns exit code 1 without a destination when the promoted file is missing after the move` (TS); `test_promote_potential_returns_exit_1_when_destination_missing_after_move` (Python). |
| **Edge Cases** - Boundary conditions | ✅ PASS | `throws when the promoted destination is absent` covers the case where the workflow check passes and the receipt-time check fails (`LateBlockedPathPotentialFileSystem`). |
| **Error Handling** - Error paths | ✅ PASS | `throws with the exit code, issue URL, and missing-path line when the workflow move check fails` asserts `Command exited with code 1.`, the issue URL, and the new message in the thrown error. Existing tests continue to cover a move that raises on an absent source. |
| **Concurrency** - If applicable | N/A | The workflow is synchronous and single-threaded; no concurrency behavior was introduced. |
| **State Transitions** - If applicable | ✅ PASS | The file-state transition (source present, move, destination present or absent) is asserted in both languages, including `fs.exists(DEST_TS)` and `EXPECTED_DEST in fs.files` on the success path. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.35% lines, 86.31% branches -> Post-change: 93.41% lines, 86.43% branches. Change: +0.06% lines, +0.12% branches. New/changed-code coverage: 100.00% lines (changed lines 469-472 of `potential_to_issue.py`; `potential_to_issue_filesystem.py` 100.00% lines and 100.00% branches); modified file `potential_to_issue.py` 99.44% lines, 90.74% branches. Disposition: PASS. Evidence: `<FEATURE>/evidence/baseline/py-test-coverage.2026-09-30T08-26.md`, `<FEATURE>/evidence/qa-gates/py-test-coverage.2026-09-30T08-54.md`, `<FEATURE>/evidence/qa-gates/py-coverage-delta.2026-09-30T08-55.md`, `artifacts/python/lcov.info`.
- TypeScript: Baseline: 97.02% lines, 91.17% branches -> Post-change: 97.02% lines, 91.17% branches. Change: +0.00% lines, +0.00% branches. New/changed-code coverage: 100.00% lines (changed lines 443-447 of `promotion.ts`); modified file `promotion.ts` 98.89% lines, 83.82% branches; `potential-to-issue-service-call.ts` 100.00% lines, 85.00% branches. Disposition: PASS. Evidence: `<FEATURE>/evidence/baseline/ts-test-coverage.2026-09-30T08-26.md`, `<FEATURE>/evidence/qa-gates/ts-test-coverage.2026-09-30T08-46.md`, `<FEATURE>/evidence/qa-gates/ts-coverage-delta.2026-09-30T08-55.md`, `extensions/drm-copilot/coverage/lcov.info`.

Reviewer-side verification: the two lcov artifacts were parsed with a read-only script. Python `artifacts/python/lcov.info`: TOTAL 15829/16946 lines (93.41%), 5279/6108 branches (86.43%); `potential_to_issue.py` 177/178 lines, 49/54 branches; `potential_to_issue_filesystem.py` 31/31 lines, 14/14 branches. TypeScript `extensions/drm-copilot/coverage/lcov.info`: TOTAL 49787/51311 lines, 7214/7912 branches (Jest text-summary 97.02% / 91.17%); `promotion.ts` 445/450 lines, 57/68 branches; `potential-to-issue-service-call.ts` 238/238 lines, 17/20 branches, guard lines 223-226 hit 2 times (`BRDA:222,13,0,2`). All figures match the executor evidence.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions compare exact values (`exitCode`, `destination`, last message text), so a failure prints the actual versus expected value. The recorded fail-before run shows `AssertionError: assert 0 == 1` with the full `PromotionOutcome`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | All new tests carry `# Arrange`, `# Act`, `# Assert` (or `// Arrange` etc.) markers. |
| **Document Intent** | ✅ PASS | Python test docstrings state scenario and outcome; TS tests carry a `Purpose:` comment. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, gh CLI, subprocess, or filesystem access in any new or changed test. |
| **Use Mocks/Stubs** | ✅ PASS | gh: `FakeGhClient` (TS), `StubGhClient` (Python). Filesystem: map/dict-backed fakes. `RealFileSystem` tests patch `Path.expanduser`, `Path.resolve`, `Path.exists`, `Path.read_text`, `Path.write_text`, `Path.mkdir`, and `shutil.move` through `monkeypatch`. |
| **Environment Stability** | ✅ PASS | `evidence/qa-gates/test-isolation.2026-09-30T08-56.md` records zero matches for `tmp_path|tmpdir|tempfile|TemporaryDirectory|NamedTemporaryFile|mkdtemp|mkstemp|os\.tmpdir|mkdtempSync|writeFileSync|node:fs` across the six new or changed test files. The reviewer's reading of the files confirms no temporary-file use. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the pre-submission policy review for the branch. No outstanding blocking items. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` scope the work to item 2 of #623 per the 2026-09-29 consolidation comment. |
| **Read existing change plans** | ✅ PASS | `research/2026-09-29T19-15-promotion-destination-verification-research.md` evaluated causes C1-C6 and approaches; spec cites #487 artifacts. |
| **Document the plan** | ✅ PASS | `plan.2026-09-29T19-06.md` (77 tasks, all checked), with preflight evidence `evidence/other/preflight.2026-09-29T21-00.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The fix is a single `if` branch per language, placed immediately after the move, using the existing `exists` member. |
| **Reusability** | ✅ PASS | Reuses the injected filesystem abstraction and the existing emit/messages path; no new interface members. |
| **Extensibility** | ✅ PASS | The non-zero outcome flows through the service-call layer's existing non-zero path; no caller changes are required. |
| **Separation of concerns** | ✅ PASS | The filesystem seam extraction isolates disk I/O (`RealFileSystem`) in its own module, separate from orchestration logic. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | `potential_to_issue_filesystem.py` contains only the filesystem Protocol and adapter. |
| **Under 500 lines** | ⚠️ PARTIAL (non-blocking, pre-existing) | Head line counts: `promotion.ts` 450, `jest.config.cjs` 361, service-call test 434, service-call test support 160, promotion test support 194, move-verification test 91, `potential_to_issue_filesystem.py` 101, filesystem tests 235, move-verification Python tests 308. `potential_to_issue.py` is 559 lines, over the limit before this branch (639 at the merge-base) and reduced by 80 lines here. Its reduction below 500 is owned by #406 and is explicitly out of scope in `spec.md`. |
| **Public vs internal** | ✅ PASS | `FileSystem` and `RealFileSystem` remain importable from `scripts.dev_tools.potential_to_issue` as the same objects (`test_filesystem_names_are_reexported`). |
| **No circular dependencies** | ✅ PASS | `potential_to_issue_filesystem.py` imports only the standard library; `potential_to_issue.py` imports it one-way. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `DroppingMovePotentialFileSystem`, `LateBlockedPathPotentialFileSystem`, `DroppingMoveFileSystem`, `potential_to_issue_filesystem`. |
| **Docs/docstrings** | ✅ PASS | New module docstring records the extraction rationale; TS `PromotionOutcome.exitCode` doc updated. The Python `PromotionOutcome` docstring was not updated in parallel (Nit, see code review). |
| **Comment why, not what** | ✅ PASS | TS comment at `promotion.ts:440-442` explains why a non-zero outcome is used instead of a thrown error. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Executor: `poetry run black .` and `npm run format` left blast-radius files unchanged (hash comparison, `evidence/qa-gates/py-format.2026-09-30T08-54.md`, `ts-format.2026-09-30T08-46.md`). Reviewer: `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` reported 528 files unchanged; `prettier --check` on the six TS/CJS files reported all files formatted. |
| **2. Linting** | ✅ PASS | Reviewer: `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` printed `All checks passed!`; `npm run lint` exited with no findings. |
| **3. Type checking** | ✅ PASS | Reviewer: `poetry run pyright scripts/dev_tools tests/scripts/dev_tools` reported 0 errors, 0 warnings; `npm run typecheck` (`tsc -p ./ --noEmit`) exited with no output. |
| **4. Architecture-boundary tests** | ✅ PASS (stage recorded, no config) | No `.importlinter` and no `.dependency-cruiser*` configuration exists (`evidence/qa-gates/py-architecture.2026-09-30T08-54.md`, `ts-architecture.2026-09-30T08-46.md`). This is a pre-existing repository condition. |
| **5. Unit tests** | ✅ PASS | Executor full runs: Python 5708 passed, 6 skipped; Jest 3318 passed. Reviewer targeted runs: 60 Python promotion tests passed; 118 Jest tests in 9 promotion suites passed. |
| **6. Contract / schema checks** | N/A | No contract or schema files changed. The MCP tool result shape is unchanged. |
| **7. Integration tests** | N/A | No integration suite covers this path; a live promotion would create a real GitHub issue (spec lists it as optional). |
| **Full toolchain loop** | ✅ PASS | Python Phase 8 required two passes: pass 1 failed the branch threshold on the new module (7/14), a test was added, and the phase restarted from P8-T1. Pass 2 is clean. TypeScript Phase 7 passed in one pass. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded under `evidence/` and in this document. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages follow conventional-commit form scoped `(623)`; see Section 9. |
| **Design choices explained** | ✅ PASS | Spec "Proposed Fix" explains the non-zero outcome over a thrown error and the extraction to keep the Python file from growing. |
| **Update supporting documents** | ✅ PASS | No user-facing docs require change; the skill `feature-promotion-lifecycle` is explicitly unchanged. |
| **Provide next steps** | ✅ PASS | Spec "Rollout & Follow-up" lists the C3 containment guard candidate, the TaskMaster #554 date check, and #406. |

---

## 3. Language-Specific Code Change Policy Compliance

PowerShell, Bash, JSON, and C# have zero changed files on the branch; their sections are omitted.

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`: 528 files would be left unchanged. |
| **Linting with Ruff** | ✅ PASS | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`: All checks passed. The removed `Iterable` import left no unused-import finding. |
| **Type checking with Pyright** | ✅ PASS | `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`: 0 errors, 0 warnings (strict mode per `pyproject.toml`). |
| **Testing with Pytest** | ✅ PASS | Full suite 5708 passed (executor); targeted 60 passed (reviewer). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | All new functions and fakes are fully annotated; no `Any`; no new `# type: ignore` or `# pyright: ignore`. |
| **Dataclasses for value objects** | ✅ PASS | `PromotionOutcome` and `RealFileSystem` retain `@dataclass`. |
| **Protocols/ABCs for interfaces** | ✅ PASS | `FileSystem(Protocol)` moved verbatim; no members added. |
| **Avoid utility classes** | ✅ PASS | No static-method-only classes introduced. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | No new exception handling; a raising `move` still propagates unchanged. |
| **Logging over print** | ✅ PASS | The new line uses the existing `_emit` callback. |
| **Invariants at construction** | ✅ PASS | No new constructors with invariants. |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | `prettier --check` on the six changed TS/CJS files: all files use Prettier code style. |
| **Linting with ESLint** | ✅ PASS | `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`): no findings. |
| **Type checking with TSC** | ✅ PASS | `npm run typecheck`: no errors. |
| **No untyped escape hatches** | ✅ PASS | No `any`, `as unknown as`, `@ts-ignore`, or `eslint-disable` added. The service-call test narrows `unknown` with `instanceof Error`. |
| **Coverage threshold configuration** | ✅ PASS | `jest.config.cjs` adds a per-file threshold (lines 85, branches 75) for `./src/lib/potential-to-issue/promotion.ts`, added after measured coverage met it (`evidence/other/jest-threshold-decision.2026-09-30T08-45.md`). No `exclude` entry was added. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain pytest functions; `monkeypatch` fixture only. |
| **Coverage expectation** | ✅ PASS | New module 100.00% lines / 100.00% branches; modified file 99.44% / 90.74%; repo-wide 93.41% / 86.43%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One behavior per test for all `RealFileSystem` methods and workflow outcomes. |
| **Mocking sparingly** | ✅ PASS | Only the `Path` method or `shutil.move` each adapter method delegates to is patched. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<unit>_<behavior>` naming, for example `test_move_creates_parent_then_moves`. |
| **Docstrings/comments** | ✅ PASS | Every test and fake has a docstring. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `poetry run pytest tests/scripts/dev_tools -k "potential_to_issue" -q --no-cov`: 60 passed. |
| **No Alternative Test Runners** | ✅ PASS | Only pytest is used. |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | ✅ PASS | `@jest/globals` `describe`/`it`/`expect`. |
| **Organization** | ✅ PASS | `extensions/drm-copilot/test/lib/potential-to-issue/` mirrors `src/lib/potential-to-issue/`; `promotion.test.ts` (near 500 lines) was not extended, per spec. |
| **Deterministic infrastructure** | ✅ PASS | No timers, `Date.now()`, or real I/O in the new tests. |
| **Existing suites unmodified** | ✅ PASS | `git diff --name-only 6e6ccd62...HEAD` over `promotion.test.ts`, `promotion.matrix.test.ts`, `promotion-lifecycle-sequence.test.ts` returned no files (reviewer check). |

---

## 5. Test Coverage Detail

### `promotePotential` post-move branch (`promotion.ts:443-447`) (3 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `returns exit code 1 without a destination when the promoted file is missing after the move` | Negative | 443-445 | ✅ |
| `returns exit code 0 with the destination when the promoted file exists after the move` | Positive | 443, 447-449 | ✅ |
| `throws with the exit code, issue URL, and missing-path line when the workflow move check fails` | Error Handling | 443-445 (through the service call) | ✅ |

**Coverage:** `promotion.ts` 98.89% lines, 83.82% branches.

**Not covered:** None of the changed lines. The five uncovered lines in the file pre-date the branch.

### `potentialToIssueServiceCall` #487 receipt guard (`potential-to-issue-service-call.ts:219-226`) (1 changed test)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `throws when the promoted destination is absent` (now uses `LateBlockedPathPotentialFileSystem`) | Edge Case | 222-226 (true branch) | ✅ |

**Coverage:** 100.00% lines, 85.00% branches; production file unchanged (`git diff` empty).

### `promote_potential` post-move branch (`potential_to_issue.py:469-474`) (2 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_promote_potential_returns_exit_1_when_destination_missing_after_move` | Negative | 469-471 | ✅ |
| `test_promote_potential_returns_destination_when_move_succeeds` | Positive | 469, 472-474 | ✅ |

**Coverage:** `potential_to_issue.py` 99.44% lines, 90.74% branches.

**Not covered:** line 417 and four `GhClient` Protocol stub exit arcs (82-88), all pre-existing.

### `potential_to_issue_filesystem.py` (9 tests: 8 in the filesystem test file, 1 re-export identity test)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_resolve_path_expands_user_then_resolves` | Positive | `resolve_path` | ✅ |
| `test_exists_delegates_to_path_exists` | Positive | `exists` | ✅ |
| `test_read_text_reads_utf8` | Positive | `read_text` | ✅ |
| `test_write_text_writes_utf8` | Positive | `write_text` | ✅ |
| `test_write_lines_joins_lines_with_newlines` | Positive | `write_lines` | ✅ |
| `test_ensure_dir_creates_parents` | Positive | `ensure_dir` | ✅ |
| `test_move_creates_parent_then_moves` | Positive | `move` | ✅ |
| `test_file_system_protocol_members_declare_no_behavior` | Edge Case | Protocol stub bodies, lines 42-54 | ✅ |
| `test_filesystem_names_are_reexported` | Positive | re-export in `potential_to_issue.py` | ✅ |

**Coverage:** 100.00% lines (31/31), 100.00% branches (14/14).

**Not covered:** None.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (Python full suite) | 5708 passed, 6 skipped | ✅ |
| Total Tests (Jest full suite) | 3318 passed, 237 suites | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time (Python full) | 76.82 s | ✅ |
| Execution Time (Python targeted, reviewer) | 0.90 s for 60 tests | ✅ Fast |
| New tests | 11 Python, 3 TypeScript | ✅ |
| Largest new test file | 308 lines | ✅ Maintainable |
| Code Coverage (Python) | 93.41% lines, 86.43% branches | ✅ |
| Code Coverage (TypeScript) | 97.02% lines, 91.17% branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` | 528 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright scripts/dev_tools tests/scripts/dev_tools` | 0 errors, 0 warnings | ✅ |
| Pytest Tests | `poetry run pytest tests/scripts/dev_tools -k "potential_to_issue" -q --no-cov` | 60 passed | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npm --prefix extensions/drm-copilot exec -- prettier --check <six files>` | All matched files formatted | ✅ |
| ESLint | `npm --prefix extensions/drm-copilot run lint` | No findings | ✅ |
| TSC | `npm --prefix extensions/drm-copilot run typecheck` | No errors | ✅ |
| Jest | `npm --prefix extensions/drm-copilot test -- test/lib/potential-to-issue test/lib/promotion-lifecycle-sequence` | 9 suites, 118 tests passed | ✅ |

**Notes:** Full-suite and coverage runs were not repeated by the reviewer; the existing coverage artifacts post-date the last code change in each language and were parsed directly. CI status for HEAD is not available in the PR context (no PR exists yet).

---

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gaps. Non-blocking observations:

- **Coverage-motivated Protocol test (plan deviation).** `test_file_system_protocol_members_declare_no_behavior` was added after Phase 8 pass 1 measured 7/14 branches on the new module. The seven uncovered arcs are the `->exit` arcs of one-line Protocol stubs, which Black keeps on the `def` line, so the existing `exclude_lines` pattern `^\s*\.\.\.\s*$` cannot match them. The same arcs existed uncovered in the baseline module (`216->exit` through `228->exit`) and remain uncovered for `GhClient` (`82->exit` through `88->exit`). Evaluated on merits: the test performs no I/O, uses no suppression, changes no configuration, and asserts a true property of the code; it adds no behavioral assurance beyond metric satisfaction. Accepted as non-blocking. A repository-level follow-up to handle one-line Protocol stubs in coverage measurement is recommended (see code review).
- **Plan text stale after the deviation.** Plan task P5-T3 acceptance states that `grep -c -E "^def test_"` prints 7; at HEAD it prints 8, and the task remains checked. The plan header still reads "Draft (revision 1.2 ... pending validator and executor preflight round 3)". The deviation itself is recorded in `evidence/qa-gates/py-test-coverage-pass1-failed.2026-09-30T08-46.md` and `test-isolation.2026-09-30T08-56.md`.
- **File size.** `potential_to_issue.py` is 559 lines (limit 500); pre-existing, reduced by 80 lines, owned by #406.

### Approved Exceptions

- `potential_to_issue.py` over 500 lines: pre-existing condition tracked by #406; `spec.md` Scope & Non-Goals excludes it and requires only that the file not grow (AC-10).
- `quality-tiers.yml` is absent at the repository root (pre-existing); the uniform coverage gates were applied.

### Removed/Skipped Tests

**None.** All planned tests are implemented. The 6 skipped tests in the full Python run are pre-existing skips in unrelated modules (`test_blast_radius_regression_452.py`, `test_parallel_manifest_bash_parity.py`).

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **73a9f3bd** - docs(623): add feature folder and research for promotion destination verification
2. **458eda1f** - docs(623): add spec for promotion destination verification
3. **a745d5af** - docs(623): add atomic plan for promotion destination verification
4. **89198810** - docs(623): revise plan after preflight round 1
5. **f871a6d5** - docs(623): revise plan after preflight round 2
6. **0231a6fa** - docs(623): record preflight clearance for promotion destination verification plan
7. **c08c23bc** - Merge remote-tracking branch 'origin/main' into bug/promotion-receipt-destination-unverified-623
8. **e51b45b6** - docs(623): record Phase 0 policy reads and baseline evidence
9. **747df68e** - test(623): add TypeScript post-move destination regression tests
10. **14d23d1f** - test(623): add Python post-move destination regression tests
11. **3ad57fae** - fix(623): verify promoted destination exists after move in promotePotential
12. **b6749993** - refactor(623): extract promotion filesystem seam into its own module
13. **c7bac1d9** - fix(623): verify promoted destination exists after move in promote_potential
14. **7ea47dec** - test(623): gate promotion.ts behind the per-file Jest coverage threshold
15. **9f4b728f** - test(623): record final QC, coverage deltas, and structural verification
16. **2597e26d** - docs(623): check off AC-1 through AC-15 on recorded evidence

### Files Modified

1. **`extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`** (MODIFIED) - post-move `exists` check; `exitCode` doc updated.
2. **`extensions/drm-copilot/jest.config.cjs`** (MODIFIED) - per-file coverage threshold for `promotion.ts`.
3. **`extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts`** (MODIFIED) - `DroppingMovePotentialFileSystem`.
4. **`extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts`** (MODIFIED) - `BlockedPathPotentialFileSystem` replaced by `LateBlockedPathPotentialFileSystem`.
5. **`extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts`** (MODIFIED) - guard test uses the late-blocked fake; new workflow-failure test.
6. **`extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts`** (NEW) - two regression tests.
7. **`scripts/dev_tools/potential_to_issue.py`** (MODIFIED) - mirrored post-move check; filesystem classes removed and re-imported.
8. **`scripts/dev_tools/potential_to_issue_filesystem.py`** (NEW) - `FileSystem` and `RealFileSystem`, moved verbatim.
9. **`tests/scripts/dev_tools/test_potential_to_issue_filesystem.py`** (NEW) - eight tests.
10. **`tests/scripts/dev_tools/test_potential_to_issue_move_verification.py`** (NEW) - three tests.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT (with non-blocking observations)

All toolchain stages pass, coverage thresholds are met for every changed production file and repo-wide in both languages with changed files, evidence locations are canonical, and scope is confined to the spec. The only PARTIAL row (file size of `potential_to_issue.py`) is a pre-existing, tracked exception that this branch improves.

**Blocking findings: 0.**

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and preflighted plan present
- ✅ Design Principles: minimal branch, existing seam reused
- ⚠️ Module & File Structure: `potential_to_issue.py` 559 lines (pre-existing, #406, reduced)
- ✅ Naming, Docs, Comments: descriptive; one Python docstring nit
- ✅ Toolchain Execution: all stages pass
- ✅ Summarize & Document: commits and evidence complete

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black, Ruff, Pyright, Pytest pass
- ✅ Python Design & Typing: strict typing, Protocol unchanged
- ✅ Error Handling: unchanged propagation

**For TypeScript:**
- ✅ Tooling: Prettier, ESLint, TSC, Jest pass
- ✅ Type safety: no escape hatches

#### General Unit Test Policy (Section 1)
- ✅ Core Principles
- ✅ Coverage & Scenarios
- ✅ Test Structure
- ✅ External Dependencies
- ✅ Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope
- ✅ Test Style & Structure
- ✅ Naming & Readability
- ✅ Toolchain

**For TypeScript:**
- ✅ Framework, organization, determinism, unmodified existing suites

---

### Metrics Summary

- ✅ 5708/5708 Python tests passing (6 pre-existing skips); 3318/3318 Jest tests passing
- ✅ Python 93.41% lines, 86.43% branches; TypeScript 97.02% lines, 91.17% branches
- ✅ New module 100.00% lines and branches; changed lines 100.00% in both languages
- ✅ Test files mirror source layout
- ✅ All code quality checks passing

---

### Recommendation

**Ready for merge** (subject to the normal PR flow and CI gate). Non-blocking follow-ups: consider a repository-level coverage treatment for one-line Protocol stubs, after which the Protocol test can be removed; refresh plan P5-T3 text and header status when the feature folder is archived.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_promote_potential_returns_exit_1_when_destination_missing_after_move`
- `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_promote_potential_returns_destination_when_move_succeeds`
- `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_filesystem_names_are_reexported`
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_resolve_path_expands_user_then_resolves`
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_exists_delegates_to_path_exists`
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_read_text_reads_utf8`
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_write_text_writes_utf8`
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_write_lines_joins_lines_with_newlines`
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_ensure_dir_creates_parents`
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_move_creates_parent_then_moves`
- `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py::test_file_system_protocol_members_declare_no_behavior`
- `promotion.move-verification.test.ts` › promotePotential — post-move destination verification › returns exit code 1 without a destination when the promoted file is missing after the move
- `promotion.move-verification.test.ts` › promotePotential — post-move destination verification › returns exit code 0 with the destination when the promoted file exists after the move
- `potential-to-issue-service-call.test.ts` › potentialToIssueServiceCall receipt post-condition › throws when the promoted destination is absent (changed fake)
- `potential-to-issue-service-call.test.ts` › potentialToIssueServiceCall receipt post-condition › throws with the exit code, issue URL, and missing-path line when the workflow move check fails (new)

---

## Appendix B: Toolchain Commands Reference

**Python (reviewer, check-only):**
```bash
poetry run black --check scripts/dev_tools tests/scripts/dev_tools
poetry run ruff check scripts/dev_tools tests/scripts/dev_tools
poetry run pyright scripts/dev_tools tests/scripts/dev_tools
poetry run pytest tests/scripts/dev_tools -k "potential_to_issue" -q -p no:cacheprovider --no-cov
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

**Python (executor, recorded in evidence):**
```bash
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
```

**TypeScript (reviewer, check-only):**
```bash
npm --prefix extensions/drm-copilot exec -- prettier --check <six changed TS/CJS files>
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot test -- test/lib/potential-to-issue test/lib/promotion-lifecycle-sequence
```

**TypeScript (executor, recorded in evidence):**
```bash
npm --prefix extensions/drm-copilot run format
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run test:coverage
```

**Scope and coverage parsing (reviewer, read-only):**
```bash
git diff --name-status 6e6ccd62792e0838bee7459a2b468de83ad5d408...HEAD
git merge-base HEAD origin/main
git diff 6e6ccd62...HEAD -- extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts   # empty
git grep -n -F "Promoted file missing after move: " HEAD -- <promotion.ts> <potential_to_issue.py>
python <scratchpad>/lcov_summary.py extensions/drm-copilot/coverage/lcov.info <files>
python <scratchpad>/lcov_summary.py artifacts/python/lcov.info <files>
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-30
**Policy Version:** Current (as of audit date)
