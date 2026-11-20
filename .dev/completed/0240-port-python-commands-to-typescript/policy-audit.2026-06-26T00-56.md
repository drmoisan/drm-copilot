# Policy Compliance Audit: F4 ts-collect-commit-context (Issue #240)

---

**Audit Date:** 2026-06-26
**Audit Cycle:** F4 review (feature branch `feat/ts-port-collect-commit-context-240`)
**Code Under Test:** TypeScript port of `extensions/drm-copilot/resources/templates/collect_commit_context.py` to `extensions/drm-copilot/src/lib/collect-commit-context.ts`; the in-process service wiring of `RepoAutomationService.collectCommitContext()` via a new `runCollectCommitContext` helper in `extensions/drm-copilot/src/repo-automation-service-support.ts`; the addition of `FileSystem.ensureDir` in `extensions/drm-copilot/src/lib/file-system.ts`; and mirrored/updated Jest tests under `extensions/drm-copilot/test/**`.

**Base branch:** `main` (resolved `origin/main`)
**Merge-base SHA:** `a23c2b32c1b953a396a095235dac509a5f42b857`
**Head SHA:** `5d181223d4223da8e902c95431b8dcffc004852b`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|---------------------------|
| TypeScript | 21 files (1 new src, 3 modified src, 17 new/modified test) | 641 | PASS 641 pass, 0 fail, 56 suites | 97.3% lines, 88.13% branch (src/lib/** prior baseline) | 97.96% lines, 90.84% branch (src/lib/**) | collect-commit-context.ts 100% line / 96.96% branch (new); file-system.ts 96.83% line / 86.66% branch (modified; ensureDir fully covered) |
| Python | 0 files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files |
| PowerShell | 0 files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files |
| C# | 0 files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files |

**Coverage verdicts:** TypeScript = PASS (only language with changed files; numeric metrics above exceed line >= 85% / branch >= 75%). Python, PowerShell, C# = N/A (zero changed files on this branch).

**Note on scope classification:** The `artifacts/pr_context.summary.txt` artifact is stale and misclassified this branch as "Core logic changes: 0 files / Docs/templates/agents/tooling: 11 files," omitting all TypeScript source and test changes. The authoritative scope was determined from `git diff --name-status a23c2b32..HEAD`, which is the SKILL-mandated basis (full branch diff vs. resolved base). Only TypeScript has changed source files; the `.md` files are feature docs and evidence artifacts, not a measured language. `N/A` is the acceptable coverage verdict for Python, PowerShell, and C# precisely because those languages have zero changed files on this branch. The one language with changed files (TypeScript) carries an explicit numeric PASS.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/f4-ts-test-baseline.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/f4-final-test-coverage.md`
- PowerShell baseline coverage artifact: N/A - no changed files
- PowerShell post-change coverage artifact: N/A - no changed files
- Per-language comparison summary: section `### 1.2.1 Per-Language Coverage Comparison` in this artifact
- TypeScript coverage-delta artifact: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/f4-coverage-delta.md`
- TypeScript independent re-run (this audit): `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` from `extensions/drm-copilot/`, EXIT 0, all suites green.

**Non-negotiable verdict rule:** This audit reports PASS and includes numeric baseline and post-change coverage for the only language in scope (TypeScript), plus new-file and modified-file coverage.

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.3% line / 88.13% branch (src/lib/** prior baseline). Post-change: 97.96% line / 90.84% branch (src/lib/**). New/changed-code coverage: 100% line / 96.96% branch (collect-commit-context.ts); 96.83% line / 86.66% branch (file-system.ts, ensureDir fully covered). Change: +0.66% line / +2.71% branch, no regression on changed lines. Disposition: PASS. Evidence: `evidence/qa-gates/f4-final-test-coverage.md`, `evidence/qa-gates/f4-coverage-delta.md`, and the independent re-run in Appendix B.
- Python: Baseline: N/A. Post-change: N/A. Change: none (no changed files). Disposition: N/A. Evidence: no Python source files in the branch diff.
- PowerShell: Baseline: N/A. Post-change: N/A. Change: none (no changed files). Disposition: N/A. Evidence: no PowerShell files in the branch diff.
- C#: Baseline: N/A. Post-change: N/A. Change: none (no changed files). Disposition: N/A. Evidence: no C# files in the branch diff.

---

## Executive Summary

This review evaluates the F4 feature branch `feat/ts-port-collect-commit-context-240` (head `5d18122`) against base `main` (merge-base `a23c2b32`). The branch ports the Python `collect_commit_context.py` template to an in-process TypeScript module (`src/lib/collect-commit-context.ts`), rewires `RepoAutomationService.collectCommitContext()` from a Python subprocess spawn to the in-process port via a new `runCollectCommitContext` helper in `repo-automation-service-support.ts`, adds an `ensureDir` method to the shared F1 `FileSystem` interface, and adds/updates Jest tests.

The full TypeScript toolchain was rerun independently for this audit and passed in a single pass:

- Prettier format check (`prettier --check "src/**/*.ts" "test/**/*.ts"`): EXIT 0, "All matched files use Prettier code style!"
- ESLint (`npm run lint`): EXIT 0, 0 errors.
- TypeScript compiler (`npm run typecheck`, `tsc -p ./ --noEmit`): EXIT 0, 0 errors.
- Jest with coverage (`node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`): EXIT 0, 641/641 tests passing across 56 suites; `src/lib/**` aggregate 97.96% line / 90.84% branch.

The new file `collect-commit-context.ts` reports 100% line / 96.96% branch coverage. The modified `file-system.ts` reports 96.83% line / 86.66% branch; the added `ensureDir` method is fully covered (uncovered lines are pre-existing glob helpers unrelated to F4). Both exceed the uniform thresholds (line >= 85%, branch >= 75%).

The port is a faithful translation of the Python source: identical git argument lists in source order, identical `allowError` semantics per call, byte-identical section headers, placeholder strings, the `.py` file filter, the last-commit header formatting, and the editable change-intent block. The service return contract (`tool`, `workspaceRoot`, `summary`, `artifacts`) is preserved. The library function is host-neutral, uses the injected F1 `CommandRunner` and `FileSystem`, and emits the printed line through an injected `log` callback rather than `console.log`.

No file exceeds the 500-line limit. Two large test files (`extension.integration.test.ts` at 573 lines, `extension.workflow-commands.test.ts` at 880 lines) exceed 500 but were already over the limit at baseline (658 and 957 lines respectively) and were reduced by this branch; this branch does not introduce or worsen the condition. This is recorded as a pre-existing condition, not an F4-introduced finding.

No blocking findings were identified.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`

**Language-specific policies evaluated:**
- PASS `typescript.md` + `typescript-suppressions.md` (with accepted divergence D1: Jest in lieu of Vitest, and the related `test/` directory layout — both pre-existing, package-wide conditions, not introduced by F4)
- PASS (no changed files) Python `python.md` (no Python source files changed)
- PASS (no changed files) PowerShell (no PowerShell files changed)
- PASS (no changed files) C# (no C# files changed)

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts were created by this branch; the diff contains only the TS source edits, mirrored/updated tests, and feature-folder docs/evidence.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope to a plan, task, phase, or file subset, and no instruction attempted to mark any language with changed files as out of scope, informational only, or not applicable. The caller provided F4 scope context and explicitly directed: "Determine scope yourself per the SKILL invariant," which is consistent with a full feature-vs-base audit. No verbatim narrowing text needs to be recorded.

The caller did note that `artifacts/pr_context.summary.txt` "may misclassify TS files as tooling; the appendix git name-status and direct git diff are authoritative." This is a correction toward the full diff, not a narrowing; it was honored by deriving scope from the authoritative git diff.

---

## Evidence Location Compliance

The branch diff was scanned for files written under the forbidden non-canonical evidence paths (`artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, `artifacts/post-change/`).

- `git diff --name-only a23c2b32..HEAD | grep -E "artifacts/(baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change)/"` returned no matches.
- `python scripts/dev_tools/validate_evidence_locations.py --root .` returned EXIT 0 (no violations).

All F4 evidence artifacts are written under the canonical `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/<kind>/` scheme (baseline, qa-gates, regression-testing). PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events occurred during this review.

---

## 1. General Unit Test Policy Compliance

**Verdict: PASS**

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | Each test constructs its own in-memory `CommandRunner` and `FileSystem` fakes; no shared mutable state across tests. |
| Isolation | PASS | One behavior per test; AAA structure with explicit Arrange/Act/Assert comments in `test/lib/collect-commit-context.test.ts`. |
| Fast execution | PASS | Full suite (56 files, 641 tests) completes in ~2.0s. |
| Determinism | PASS | No wall-clock, no RNG, no real subprocess/filesystem; routed fakes return fixed values keyed off git argument lists. |
| Readability | PASS | Descriptive `describe`/`it` names mirror the Python scenarios (`test_collect_commit_context.py`); helpers documented. |

**Coverage requirements:** PASS. `src/lib/**` aggregate 97.96% line / 90.84% branch; new `collect-commit-context.ts` 100% line / 96.96% branch; modified `file-system.ts` 96.83% line / 86.66% branch with `ensureDir` fully exercised. No regression on changed lines.

**External dependencies / temp files:** PASS. Tests inject `CommandRunner` and `FileSystem` fakes (`InMemoryFileSystem`, routed runner). No real git, no `node:fs` writes, no temp files. The `InMemoryFileSystem` records `ensureDir` and `writeTextFile` in memory.

**Test file location:** PASS with documented condition. Unit tests for `src/lib/collect-commit-context.ts` live at `test/lib/collect-commit-context.test.ts`, mirroring the source tree under `test/`. The general-unit-test rule states the universal layout requirement using a `tests/` directory; this package uses a singular `test/` directory as a pre-existing, package-wide convention (all prior F1/F2 tests and the baseline tree use `test/`). The mirror requirement (tests mirror production structure, no colocation in `src/`) is satisfied. This naming divergence is package-wide and not introduced by F4.

**Scenario completeness:** PASS. The test set covers positive output (file written), parent-directory creation, all thirteen section headers, every placeholder branch (`(no upstream)`, `(no staged changes)`, `(no unstaged changes)`, `(no untracked files)`, `(no changes)`, `(no Python files changed)`, `(no previous commits)`), the `.py` filter, last-commit formatting, the `log` callback, the `runGit` success/strip path, the mandatory-call throw path (`allowError: false`), and the `allowError: true` non-zero/empty paths.

---

## 2. General Code Change Policy Compliance

**Verdict: PASS**

| Principle | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | The port is a direct, linear translation of the Python source; the service method delegates to one thin helper. |
| Reusability | PASS | Reuses the F1 `CommandRunner` and `FileSystem` seams; adds one shared `ensureDir` method rather than duplicating directory logic. |
| Extensibility | PASS | `CollectCommitContextOptions` uses keyword-style object parameters with an optional `log` callback. |
| Separation of concerns | PASS | Pure gathering/formatting logic in `src/lib/collect-commit-context.ts` is separate from I/O (injected runner/filesystem) and from service wiring (`repo-automation-service-support.ts`). |

**Mandatory toolchain loop:** PASS. Format → lint → typecheck → tests all pass in a single independent pass (see Appendix B).

**File size limit (500 lines):** PASS for all files modified or added by this branch.

| File | Lines | Status |
|---|---|---|
| `src/lib/collect-commit-context.ts` (new) | 261 | PASS |
| `src/lib/file-system.ts` (modified) | 253 | PASS |
| `src/repo-automation-service.ts` (modified) | 500 | PASS (at limit, not exceeded; baseline 500) |
| `src/repo-automation-service-support.ts` (modified) | 136 | PASS |
| `test/lib/collect-commit-context.test.ts` (new) | 350 | PASS |
| `test/lib/collect-commit-context.run-git.test.ts` (new) | 84 | PASS |
| `test/lib/collect-commit-context.test-helpers.ts` (new) | 119 | PASS |
| `test/collect-commit-context-test-support.ts` (new) | 114 | PASS |
| `test/extension.collect-commit-context-inprocess.test.ts` (new) | 143 | PASS |
| `test/extension.collect-commit-context.integration.test.ts` (new) | 235 | PASS |
| `test/extension-test-harness.ts` (modified) | 398 | PASS |
| `test/lib/file-system.test.ts` (modified) | 193 | PASS |
| `test/repo-automation-dispatch.test.ts` (modified) | 500 | PASS (at limit, not exceeded; baseline 490) |
| `test/extension.integration.test.ts` (modified) | 573 | OVER LIMIT — pre-existing (baseline 658), reduced by this branch; not an F4-introduced finding |
| `test/extension.workflow-commands.test.ts` (modified) | 880 | OVER LIMIT — pre-existing (baseline 957), reduced by this branch; not an F4-introduced finding |

The two over-limit test files were already over 500 at the merge-base and were made smaller by this branch. F4 does not introduce or worsen the violation. Remediating these pre-existing oversize files is out of F4 scope; it is recorded here for visibility (see Section 8).

**Error handling and logging:** PASS. The library function fails fast: mandatory git calls (`allowError: false`) propagate the runner's thrown error; the function does not silently swallow errors. The printed message flows through an injected `log` callback (no ad-hoc `console.log`), satisfying the logging-pattern requirement.

**Dependencies:** PASS. No new runtime dependencies; only `node:path` and the existing F1 lib modules are imported.

**I/O boundaries:** PASS. All filesystem and subprocess I/O is behind injected interfaces; the core logic is testable without touching disk or spawning processes.

---

## 3. Language-Specific Code Change Policy Compliance (TypeScript)

**Verdict: PASS** (with accepted divergence D1)

| Standard | Status | Evidence |
|---|---|---|
| Prettier formatting | PASS | `prettier --check` EXIT 0. |
| ESLint | PASS | `npm run lint` EXIT 0, 0 errors. |
| TSC type-check, avoid `any` | PASS | `tsc --noEmit` EXIT 0; no `any` in the new/modified source; `type`-only imports used for `CommandRunner`/`FileSystem`. |
| ES modules | PASS | ES import/export only; no `require`/`module.exports` in the new source. |
| Strong typing | PASS | `CollectCommitContextOptions` and `CollectCommitContextResult` are explicit interfaces; no type assertions in the port. |
| Naming | PASS | `camelCase` functions/locals, `PascalCase` types, no `I` prefix. |
| File naming | PASS | kebab-case (`collect-commit-context.ts`). |
| Separation of concerns | PASS | Pure logic separate from host-bound I/O. |
| Error handling | PASS | Fail-fast; no catch-all without rethrow. |
| Suppressions | PASS | No new `eslint-disable` or `@ts-expect-error`/`@ts-ignore` introduced (verified by lint clean and source read). |

**Accepted divergence D1 (from spec.md):** The `extensions/drm-copilot` package uses Jest (`ts-jest`, `run-jest.cjs`), while `.claude/rules/typescript.md` text references Vitest. This is a pre-existing, package-wide condition recorded as accepted decision D1. The actual runnable and CI-exercised toolchain is Jest. F4 follows the real Jest toolchain. `.claude/rules/**` was not modified. This is a policy-reconciliation matter, not an F4 defect.

**Architecture boundaries:** PASS. The new code introduces no VSTO/Office.js/Graph/COM references and does not cross layer boundaries; `collect-commit-context.ts` is a host-neutral lib module consuming only other lib seams.

---

## 4. Language-Specific Unit Test Policy Compliance (TypeScript)

**Verdict: PASS** (with accepted divergence D1)

| Standard | Status | Evidence |
|---|---|---|
| Framework | PASS (D1) | Jest via `@jest/globals` (`describe`, `it`, `expect`, `jest.fn`), consistent with the package's existing tests. |
| `*.test.ts` naming | PASS | New unit tests named `*.test.ts`. |
| AAA structure | PASS | Explicit Arrange/Act/Assert comments. |
| One behavior per test | PASS | Each `it` asserts a single behavior. |
| No external deps / temp files | PASS | In-memory fakes only. |
| Mock reset | PASS | Fresh fakes per test; no shared mutable mocks requiring reset. |
| Coverage thresholds | PASS | New-file and modified-file coverage exceed line >= 85% / branch >= 75%. |

---

## 5. Test Coverage Detail

Independent coverage run (this audit): `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`, EXIT 0.

| File | % Stmts | % Branch | % Funcs | % Lines | Tier verdict |
|---|---|---|---|---|---|
| `src/lib/collect-commit-context.ts` (new) | 100 | 96.96 | 100 | 100 | PASS (>= 85 line / >= 75 branch) |
| `src/lib/file-system.ts` (modified) | 96.83 | 86.66 | 100 | 96.83 | PASS (>= 85 line / >= 75 branch) |
| `src/lib/**` (aggregate) | 96.09 (all files) / 97.96 (lib) | 90.84 (lib) | 100 (lib) | 97.96 (lib) | PASS |

The single uncovered line reported for `collect-commit-context.ts` (line 199) is within the `.py` filter expression branch; statement and line coverage are 100% and branch coverage 96.96%, both above threshold. `file-system.ts` uncovered lines (79-83, 143-146) are pre-existing `joinPosix`/glob helper branches from F1, unrelated to the F4 `ensureDir` addition, which is fully covered.

**No-exclusion policy:** PASS. No production `src/` path is excluded from coverage measurement; `--collectCoverageFrom="src/lib/**/*.ts"` includes all lib production files.

---

## 6. Test Execution Metrics

| Metric | Value |
|---|---|
| Test suites | 56 passed / 56 total |
| Tests | 641 passed / 641 total |
| Failures | 0 |
| Snapshots | 0 |
| Wall time | ~1.95 s |
| Command | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` |
| Exit code | 0 |

---

## 7. Code Quality Checks

| Check | Command | Result |
|---|---|---|
| Format | `prettier --check "src/**/*.ts" "test/**/*.ts"` | PASS (EXIT 0) |
| Lint | `npm run lint` | PASS (EXIT 0, 0 errors) |
| Type-check | `npm run typecheck` | PASS (EXIT 0, 0 errors) |
| Tests + coverage | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` | PASS (EXIT 0) |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | PASS (EXIT 0) |
| Workflow-change gate | name-status scan for `.github/workflows/**`, `scripts/benchmarks/**`, `.github/actions/**` | Not triggered (no matching paths in diff) |

---

## 8. Gaps and Exceptions

| ID | Severity | Description | Disposition |
|---|---|---|---|
| G1 | Informational | `test/extension.integration.test.ts` (573 lines) and `test/extension.workflow-commands.test.ts` (880 lines) exceed the 500-line limit. | Pre-existing condition at merge-base (658 and 957 lines); F4 reduced both. Not introduced by F4; out of F4 scope. Recommend a separate cleanup feature to split these files below 500 lines. |
| G2 | Informational | `.claude/rules/typescript.md` mandates Vitest; package uses Jest (D1). | Accepted divergence D1 in spec.md; package-wide and pre-existing. Policy-reconciliation, not an F4 blocker. |
| G3 | Informational | General-unit-test rule wording uses `tests/`; this package uses `test/`. | Pre-existing package-wide layout convention; mirror/no-colocation requirement satisfied. |
| G4 | Informational | Parity divergence: Python `run_git` raises `FileNotFoundError` if `git` is absent on PATH (explicit pre-check); the TS port relies on the runner's spawn-failure handling. | Documented accepted parity decision in the F4 plan Parity Notes; functionally equivalent (mandatory calls still throw when git fails). |

No Major or Blocking findings.

---

## 9. Summary of Changes

- New: `extensions/drm-copilot/src/lib/collect-commit-context.ts` — in-process TS port of `collect_commit_context.py`.
- Modified: `extensions/drm-copilot/src/lib/file-system.ts` — added `ensureDir` to `FileSystem` interface and `RealFileSystem`.
- Modified: `extensions/drm-copilot/src/repo-automation-service-support.ts` — added `runCollectCommitContext` helper and `CollectCommitContextResult` type.
- Modified: `extensions/drm-copilot/src/repo-automation-service.ts` — rewired `collectCommitContext` to the in-process helper; injected a `CommandRunner` (defaults to `SubprocessRunner`).
- New/modified tests under `extensions/drm-copilot/test/**` (17 files) covering the port, the service wiring, `ensureDir`, and the updated extension-integration expectations.
- Feature-folder docs and evidence artifacts under the canonical `evidence/<kind>/` scheme.

The `"python"` runtime branch in `command-runtime.ts`, the bundled Python templates, `scripts/dev_tools/**`, `mcp-handlers/collect-context-handlers.ts`, and `mcp-tool-inputs.ts` are all unmodified (verified by name-status grep), consistent with the F4 scope boundary (full Python removal is F11).

---

## 10. Compliance Verdict

**Overall: PASS**

The F4 branch satisfies the general code-change, general unit-test, and TypeScript language policies (with the pre-existing, accepted D1 Jest divergence). The full toolchain passes independently in a single pass; coverage for the new and modified files exceeds the uniform thresholds; scope is contained to the F4 boundary; evidence is in canonical locations. No Blocking or Major findings. The two oversize test files are a pre-existing condition that F4 reduced and are recorded as informational. Remediation is not required.

---

## Appendix A: Test Inventory

New/updated test files in scope:

- `test/lib/collect-commit-context.test.ts` (350) — port behavior scenarios mirroring `tests/scripts/dev_tools/test_collect_commit_context.py`.
- `test/lib/collect-commit-context.run-git.test.ts` (84) — `runGit` strip/throw/allowError paths.
- `test/lib/collect-commit-context.test-helpers.ts` (119) — routed runner + in-memory filesystem fakes.
- `test/collect-commit-context-test-support.ts` (114) — shared integration support.
- `test/extension.collect-commit-context-inprocess.test.ts` (143) — in-process (no Python spawn) assertion.
- `test/extension.collect-commit-context.integration.test.ts` (235) — section-content + no-staged assertions via mocked git.
- `test/lib/file-system.test.ts` (193, modified) — `ensureDir` positive/idempotent coverage.
- `test/extension.integration.test.ts` (573, modified) — reworked collect-commit-context cases.
- `test/extension.workflow-commands.test.ts` (880, modified) — updated runtime expectations.
- `test/repo-automation-dispatch.test.ts` (500, modified) — dispatch assertions preserved.
- `test/extension-test-harness.ts` (398, modified) — harness support.
- Additional modified test files: `test/repo-automation-orchestration-validation.test.ts`, `test/lib/json-config.test.ts`, `test/lib/markdown-label-formatter.test.ts`, `test/lib/validate/evidence-locations.test.ts`, `test/lib/validate/json-validator.test.ts`, `test/lib/validate/validate-orchestration-service-call.test.ts`.

Aggregate: 56 suites / 641 tests, all passing.

---

## Appendix B: Toolchain Commands Reference

All commands run from `extensions/drm-copilot/` unless noted.

| Stage | Command | Exit |
|---|---|---|
| Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` | 0 |
| Lint | `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`) | 0 |
| Type-check | `npm run typecheck` (`tsc -p ./ --noEmit`) | 0 |
| Test + coverage | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` | 0 |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` (repo root) | 0 |
| Scope (name-status) | `git diff --name-status a23c2b32c1b953a396a095235dac509a5f42b857..HEAD` (repo root) | 0 |
