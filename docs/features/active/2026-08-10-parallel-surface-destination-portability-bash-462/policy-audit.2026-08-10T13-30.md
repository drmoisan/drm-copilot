# Policy Compliance Audit: parallel-surface-destination-portability-bash (Issue #462)

**Audit Date:** 2026-08-10
**Code Under Test:** 164 files changed against merge-base `a26286e87137780ee9e5f59ba2753c2307617572` (`origin/main`), head `aec5e539338851b5e6c1eb2eb347dd897fecd683`. Production surfaces: nine new bash files under `.claude/lib/bash/` plus byte-identical bundled mirrors; `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (modified) and `claude-routing-merge.ts` (new); `scripts/bash/shell_qc_lib.sh` and `scripts/bash/cleanup_worktrees_lib.sh` (modified); `.claude/settings.json`, two parallel agent definitions, three parallel skills, `.claude/rules/shell.md`, `core.json`, two bundled `config/` files, `.gitignore`, `.github/workflows/_shell-coverage.yml`. Test surfaces: two pytest parity suites, eleven bats suites (nine new, two extended), three Jest test files, 73 fixture files.

**Template source:** copied from the bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the identical file the MCP template resolver maps to for selector `template` (see `extensions/drm-copilot/src/policy-audit-template-assets.ts`).

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files (both test-only) | 3774 tests | ✅ 3774 pass, 0 fail, 5 skip (documented) | 92.30% lines, 89.46% branches | 92.30% lines, 84.68% branches (lcov BRH/BRF; pytest-cov term accounting reports 89.48%) | N/A - test-only Python change; test files are excluded from coverage measurement per policy |
| TypeScript | 5 files (2 production, 3 test) | 2495 tests | ✅ 2495 pass, 0 fail | 96.55% lines, 89.86% branches | 96.57% lines, 89.90% branches | 98.05% lines, 87.50% branches (claude-routing-merge.ts, new); 100% lines, 93.55% branches (claude-customizations.ts, modified) |
| Bash | 21 .sh files + 11 .bats files | 245 bats tests | ✅ 245 pass, 0 fail (CI run 31411775305) | 91.5% lines (no branch measurement; kcov limitation) | 92.4% lines (no branch measurement; kcov limitation) | 92.4% lines merged report; the 2,043 new library lines entered the kcov denominator and overall coverage rose +0.9 points, so the new library is covered above the pre-existing average |
| PowerShell | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A (no changed files) |
| JSON | 76 files | N/A | ✅ validation (Jest byte-pin and completeness suites green) | N/A (config files) | N/A (config files) | N/A (config files) |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/baseline/typescript-baseline.2026-08-10T14-57.md
- TypeScript post-change coverage artifact: extensions/drm-copilot/coverage/lcov.info (regenerated at head by this review, 2026-08-10T13-21) plus docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/qa-gates/final-ts-test.2026-08-10T16-45.md
- PowerShell baseline coverage artifact: N/A - out of scope (zero PowerShell files changed on this branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero PowerShell files changed on this branch)
- Per-language comparison summary: section 1.2.1 of this audit

**Non-negotiable verdict rule:** numeric baseline and post-change coverage metrics are recorded above and in section 1.2.1 for every language in scope.

**Fail-closed rule:** all required baseline, QA, and coverage-comparison artifacts exist under the feature `evidence/` tree; none is absent.

**Evidence rule:** every metric above was either re-derived by this review (pytest, Jest, lcov totals, gh run view) or read from a named committed evidence artifact.

---

## Rejected Scope Narrowing

None detected. The caller prompt explicitly framed its six examination items as "additions to your audit, not narrowings of it" and delegated scope determination to this agent. The audit scope used is the full branch diff `a26286e8..aec5e539` against `origin/main`.

---

## Evidence Location Compliance

- `git diff --name-only a26286e8..aec5e539 | grep -E "^artifacts/(baselines|qa|evidence|coverage)/"` — zero matches. No branch file is written under a non-canonical evidence path.
- `python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no violations reported.
- All 22 evidence artifacts on the branch live under `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/<kind>/`, the canonical location.

**Verdict: PASS.**

---

## Executive Summary

This branch closes the four verified destination-runtime blockers that halt `/parallel-plan` in a workspace that received the `.claude` push-down payload: it adds a nine-file bash library under `.claude/lib/bash/` (cohort computation, concurrency batching, manifest-contract validation) with byte-identical bundled mirrors, extends the Claude push-down to carry `config/` with a merging publish for `orchestration-routing.json`, corrects the core pack manifest, extends the pack-completeness test enumeration, and widens Shell-QC discovery and kcov measurement to `.claude/lib/bash/**`. The parallel schema surface is untouched (verified against the diff, not against the executor's assertion: zero changed files under `scripts/dev_tools/`, `extensions/drm-copilot/src/lib/validate/`, repo-root `config/`, and `.claude/rules/parallel-orchestration.md`).

All toolchain stages that can run in this environment were re-executed at head by this review and pass: Black, Ruff, Pyright, pytest (3774 pass), tsc, ESLint, Jest (2495 pass). The bash toolchain is CI-only per `.claude/rules/shell.md`; this review independently verified via `gh run view 31411775305` that a `_shell-coverage.yml` run with `headSha` equal to the branch head concluded `success` with `Bash coverage (lines): 92.4%` in its log, which also discharges the `modified-workflow-needs-green-run` policy rule for the `.github/workflows/_shell-coverage.yml` diff.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`

**Language-specific policies evaluated:**
- ✅ `.claude/rules/python.md` + `.claude/rules/python-suppressions.md` (test-only Python change)
- N/A PowerShell (zero changed files)
- ✅ Bash: `.claude/rules/shell.md` (shfmt + shellcheck + bats + kcov, via CI)
- ✅ `.claude/rules/typescript.md` + `.claude/rules/typescript-suppressions.md`
- ✅ JSON: settings/manifests/config validated by Jest byte-pin, completeness, and membership suites
- ✅ `.claude/rules/ci-workflows.md` (one added workflow step reviewed)
- ✅ `.claude/rules/parallel-orchestration.md` (enum-consumption and schema-freeze constraints)

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts remain in the diff; working tree is clean at head.
- ✅ Ongoing tooling additions (`.claude/lib/bash/*`, `scripts/bash/shell_qc_lib.sh` extension) are fully tested (245 bats tests) and policy-compliant.
- Checked-in PATH shims under `tests/fixtures/parallel_payload_path/` and the discovery fixture `tests/fixtures/shell_qc/.claude/lib/bash/lib_entry.sh` are deliberate committed test fixtures, not leftovers.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Pytest parity suites parametrize over read-only committed fixtures with no shared mutable state. Bats suites resolve `REPO_ROOT` per-test in `setup()` and source libraries fresh. Jest suites use in-memory filesystem fakes. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One parametrized case per fixture (pytest); one bats `@test` per contract clause; Jest cases split the merge rule into six named behaviors (copy, merge, overwrite, preserve, idempotency, fail-fast). |
| **Fast Execution** - Tests complete quickly | ✅ PASS | pytest full run 17.81s for 3774 tests; Jest 6.97s for 2495 tests; CI bats lane completes within the shell-coverage job. |
| **Determinism** - Consistent results | ✅ PASS | No wall-clock, RNG, or network access in any new test. Bash determinism hazards are countered by `LC_ALL=C` enforcement (`pc_enforce_c_locale`), `sort -n`, and a strict integer-token regex; the parity corpus pins exact bytes. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | All four parity-suite headers carry an identical verified-scope statement naming the two declared divergence classes; every pytest helper has a Google-style docstring; bats tests are named as behavior sentences. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-development):** Python 92.30% lines, 89.46% branches; TypeScript 96.55% lines, 89.86% branches; Bash 91.5% lines.<br>**Commands:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`; `npm --prefix extensions/drm-copilot run test:coverage`; CI run 31401325490.<br>**Timestamp:** 2026-08-10T14-57 (Python/TS), T15-05 (shell), recorded under `evidence/baseline/`. |
| **No Coverage Regression** | ✅ PASS | Python 92.30% → 92.30% lines (0.00); TypeScript 96.55% → 96.57% lines (+0.02), 89.86% → 89.90% branches (+0.04); Bash 91.5% → 92.4% lines (+0.9) while 2,043 new lines entered the denominator. Re-derived at head by this review. |
| **New Code Coverage ≥90%** | ✅ PASS | `claude-routing-merge.ts` (new, 308 LF): 302/308 = 98.05% lines, 42/48 = 87.50% branches. New bash library: covered inside the merged 92.4% kcov report with a +0.9-point rise over baseline. New Python files are tests, excluded from measurement per policy. |
| **Comprehensive Coverage** | ✅ PASS | Cohort corpus: 30 fixtures (21 coloring incl. empty graph, single item, disjoint, triangle, star, square cycle, tie-breaking, permutation equivalence, zero/negative keys, 7 error cases; 9 batching incl. zero/negative concurrency). Manifest corpus: 43 fixtures spanning M1–M7, CR/CRLF endings, accessor defaults, field-order multiplicity. |
| **Positive Flows** - Valid inputs | ✅ PASS | `manifest_valid_full`, `manifest_valid_two_items`, `manifest_valid_empty_items`; all coloring/batching success fixtures; Jest copy/merge/idempotency happy paths. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Duplicate keys, self-loops, unknown endpoints, `max_concurrency` 0 and -3 with exact Python messages; M1–M7 rejection fixtures; leading-zero lexical rejection asserted in `parallel_cohorts.bats`; Jest fail-fast on unparseable destination. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Empty graph, empty cohort, cap-exceeds-size, exact-multiple batching, `max_concurrency` bounds 1/8, boolean-rejected cap, CR and CRLF frontmatter, self-loop-precedes-unknown-endpoint ordering. |
| **Error Handling** - Error paths | ✅ PASS | Exit-code contract (0/1/2) asserted per entry point; `RoutingMergeError` path asserts untouched destination bytes; out-of-subset YAML refusal (exit 2) asserted. |
| **Concurrency** - If applicable | N/A | All new code paths are pure single-process computations. |
| **State Transitions** - If applicable | N/A | No stateful component added; the checkpoint schema is untouched. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.30% lines, 89.46% branches -> Post-change: 92.30% lines (13288/14396), 84.68% branches (4476/5286, lcov BRH/BRF accounting; the pytest-cov terminal accounting used by the baseline artifact reports 89.48%). Change: +0.00% lines, no regression. New/changed-code coverage: N/A - test-only Python change (test files are excluded from measurement per policy). Disposition: PASS. Evidence: artifacts/python/lcov.info (regenerated at head by this review); evidence/baseline/python-baseline.2026-08-10T14-57.md; evidence/qa-gates/final-python-test.2026-08-10T16-39.md.
- TypeScript: Baseline: 96.55% lines, 89.86% branches -> Post-change: 96.57% lines (40958/42412), 89.90% branches (5822/6476). Change: +0.02% lines, +0.04% branches. New/changed-code coverage: 98.05% lines and 87.50% branches for src/lib/push-down/claude-routing-merge.ts (new); 100% lines and 93.55% branches for src/lib/push-down/claude-customizations.ts (modified). Disposition: PASS. Evidence: extensions/drm-copilot/coverage/lcov.info (regenerated at head by this review); evidence/baseline/typescript-baseline.2026-08-10T14-57.md; evidence/qa-gates/final-ts-test.2026-08-10T16-45.md.
- Bash: Baseline: 91.5% lines -> Post-change: 92.4% lines (kcov measures line coverage only; there is no bash branch gate per .claude/rules/shell.md). Change: +0.9% lines while 2,043 new library lines entered the include pattern. New/changed-code coverage: 92.4% merged-report lines with the new library inside the denominator; the rise over baseline shows the new files are covered above the pre-existing average. Disposition: PASS. Evidence: CI run https://github.com/drmoisan/drm-copilot/actions/runs/31411775305 (headSha aec5e539, success, log line `Bash coverage (lines): 92.4%`, re-verified by this review via gh run view); evidence/baseline/shell-baseline.2026-08-10T15-05.md; evidence/qa-gates/final-shell-gate-head.2026-08-10T17-00.md.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Pytest guards raise typed errors naming the dotted fixture path; the corpus-floor assertion explains how to restore or deliberately lower the floor. Bats parity loops echo `fixture <name>: status/output/expected` on divergence. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Pytest cases mark Arrange/Act/Assert explicitly; bats cases arrange via `setup()` and fixture reads, act via `run`, assert on `$status`/`$output`. |
| **Document Intent** | ✅ PASS | Every new suite opens with a purpose header; every pytest function has a docstring stating the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, database, or external service in any new test. `python3` in the bats parity suites is a harness dependency for reading committed JSON fixtures, declared in the suite headers; the destination-portability property itself is asserted by `parallel_payload_only.bats` under a PATH exposing only four coreutils shims. |
| **Use Mocks/Stubs** | ✅ PASS | Jest uses in-memory `PushDownFileSystem` fakes; bats uses checked-in PATH shims (`tests/fixtures/parallel_payload_path/`) and the `SHELL_QC_<TOOL>_BIN` seam; pytest parity suites need no mocks (pure functions over fixtures). |
| **Environment Stability** | ✅ PASS | No temporary files are created by any new test (a repository prohibition); all fixtures are committed and read-only; `LC_ALL=C` is enforced in the bash suites. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This artifact, plus `code-review.2026-08-10T13-30.md` and `feature-audit.2026-08-10T13-30.md` in the same folder, constitute the required review set. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #462; feature folder `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/` with issue.md, spec.md (17 AC), user-story.md (17 AC). |
| **Read existing change plans** | ✅ PASS | Research artifact `research/2026-08-10T09-45-parallel-destination-portability-bash-research.md` re-verified all four blockers before planning. |
| **Document the plan** | ✅ PASS | Atomic plan `plan.2026-08-10T09-36.md` (259 lines) with phase/task structure traceable in the evidence artifacts. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The routing merge is a single-path decorator rather than engine logic; the bash library is decomposed by concern (scan/emit/validate/cohorts/common) with thin CLI entry points. |
| **Reusability** | ✅ PASS | `parallel-common.sh` centralizes pythonRepr, enum-error templates, and error accumulation for both validators; the merge decorator reuses the existing `PushDownFileSystem` seam that `ExcludingFileSystem` already occupies. |
| **Extensibility** | ✅ PASS | `RoutingMergeFileSystem` takes the merge-target path as a constructor parameter; `ROOT_FOLDERS` extension is additive and Claude-entry-local. |
| **Separation of concerns** | ✅ PASS | Pure merge logic (`mergeRoutingDocuments`) is separated from I/O (the decorator); bash parsing (yaml-scan) is separated from validation (manifest/items-validate) and from rendering (yaml-emit). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each of the nine bash files has a single stated purpose in its header; `claude-routing-merge.ts` holds exactly the merge rule and its decorator. |
| **Under 500 lines** | ✅ PASS | Largest new shell file `parallel-yaml-emit.sh` = 340 lines; `parallel-yaml-scan.sh` = 335; `claude-routing-merge.ts` = 308; largest new test file `test_parallel_cohort_bash_parity.py` = 376. All under 500 (verified from the diff stat). |
| **Public vs internal** | ✅ PASS | Bash internals use `pcoh_`/`pm_`/`pc_` prefixes and are sourced, never executed; only the three CLI entry points are documented as invocable and allowlisted. |
| **No circular dependencies** | ✅ PASS | Bash source graph is a DAG (entry points -> cohorts/manifest-validate -> scan/emit -> common); `claude-routing-merge.ts` depends only on the filesystem-adapter type. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `mergeRoutingDocuments`, `RoutingMergeFileSystem`, `cc_require_integer`, `pm_validate_text`; kebab-case TS filenames per rule. |
| **Docs/docstrings** | ✅ PASS | Every exported TS symbol carries a JSDoc block with purpose/params/throws; every bash function has a purpose comment; pytest helpers use Google-style docstrings. |
| **Comment why, not what** | ✅ PASS | Comments explain rationale (for example why the merge is a decorator, why leading-zero tokens are rejected fail-closed, why destination key order is preserved). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Commands:** `poetry run black --check .` (415 files unchanged, exit 0, re-run by this review); `npm --prefix extensions/drm-copilot run format` (executor evidence T16-45); shfmt diff mode green in CI run 31411775305 `check` step. |
| **2. Linting** | ✅ PASS | **Commands:** `poetry run ruff check .` (all checks passed, re-run by this review); `npm --prefix extensions/drm-copilot run lint` (clean, re-run by this review); shellcheck green in CI run 31411775305. |
| **3. Type checking** | ✅ PASS | **Commands:** `poetry run pyright` (0 errors, re-run by this review); `npm --prefix extensions/drm-copilot run typecheck` (clean, re-run by this review). N/A for bash. |
| **4. Testing** | ✅ PASS | **Commands:** `poetry run pytest --cov --cov-branch -q` (3774 pass, 5 documented skips, re-run by this review); `npm --prefix extensions/drm-copilot run test:coverage` (2495 pass, re-run by this review); bats 245 pass in CI at head. |
| **Full toolchain loop** | ✅ PASS | All re-run stages passed in a single pass at head. Architecture-boundary stage: no dependency-cruiser configuration exists in this repository (pre-existing disposition recorded in `evidence/qa-gates/final-ts-arch.2026-08-10T16-45.md`, citing the 2026-07-26 adjacent finding). Contract stage: the schema-freeze diff check stands in (section 8 note). |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded here and in the 17 executor evidence artifacts under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Eleven conventional commits (4 feat, 4 fix, 3 docs), each scoped with `(462)`. |
| **Design choices explained** | ✅ PASS | spec.md records the rejected alternatives (yq, Node validation, `scripts/bash/parallel/` third copy) and the decorator-vs-engine rationale. |
| **Update supporting documents** | ✅ PASS | `.claude/rules/shell.md` discovery/coverage prose updated with byte-identical bundle mirror; skill and agent wiring repointed; the `config/` bundle asymmetry documented in spec.md. |
| **Provide next steps** | ✅ PASS | Permission-surface PR callout text prepared at `evidence/other/permission-surface-callout.2026-08-10T17-08.md` for the PR author. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python production code changed; the two new files are pytest suites. Toolchain evidence:

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .` **Result:** 415 files would be left unchanged, exit 0 (re-run by this review at head). |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check .` **Result:** all checks passed (re-run by this review). No new suppression added. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright` **Result:** 0 errors (re-run by this review). Both suites are fully annotated with typed guard helpers instead of `Any`. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch -q` **Result:** 3774 passed, 5 skipped (each skip names its accessor-free fixture). |

### Section 3B: PowerShell Code Change Policy Compliance

N/A — zero PowerShell files changed on this branch.

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh check` (shfmt diff stage), CI-only per `.claude/rules/shell.md`. **Result:** green in run 31411775305 at head (verified via `gh run view`). |
| **Linting with shellcheck** | ✅ PASS | **Command:** same `check` step. **Result:** green at head. The step demonstrated real gate behavior during Phase 3 (three failed dispatches on genuine findings before passing). |
| **Testing with bats** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh test --coverage`. **Result:** 245 ok, 0 not ok; `Bash coverage (lines): 92.4%` at head. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | All entry points use `#!/usr/bin/env bash`; the four PATH shims use absolute `#!/bin/sh` with an in-file justification (restricted-PATH test cannot resolve `env`). |
| **Error handling** | ✅ PASS | Entry points begin with `set -euo pipefail`; exit-code contract 0/1/2 documented per file; source-guard pattern re-exits main's return code explicitly. |
| **Under 500 lines** | ✅ PASS | Maximum 340 lines (`parallel-yaml-emit.sh`). |

**Suppression review (caller examination item 2).** Two file-wide `# shellcheck disable=SC2015` directives were added to `scripts/bash/shell_qc_lib.sh` and `scripts/bash/cleanup_worktrees_lib.sh`, each with a stated reason, to resolve the eight pre-existing SC2015 findings (`<test> && <assign> || true`) surfaced when the new CI `check` step first ran over these files. Assessment: the eight flagged sites are all the benign `A && B || true` capture idiom, which is genuinely required under `set -e` (a false test as a function's final command would otherwise propagate non-zero); the suppression does not mask a live defect. `.claude/rules/shell.md` permits suppressions "only when justified inline with a `# shellcheck disable=SCxxxx` comment stating the reason" — the reason is stated, so the letter of the rule is met, but the file-wide scope is broader than necessary and would also silence a future genuine `A && B || C` if-then-else confusion in these two files. Recorded as a Minor, non-blocking finding in `code-review.2026-08-10T13-30.md` with a per-line or `if`-rewrite follow-up recommendation. The justification comment's claim that shell.md "mandates" this idiom slightly overstates the rule, which mandates non-zero-exit capture and names `|| rc=$?` as its example.

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | `.claude/settings.json` and `core.json` diffs are single-entry additions preserving existing style; the two bundled `config/` documents are byte-pinned to canonical sources by Jest (`claude-config-carriage.test.ts` three-copy pin). |
| **Schema validation** | ✅ PASS | The bundled `orchestration-routing.json` is asserted byte-identical to the repo-root canonical file (which is unchanged in this diff); the merge serializer output is round-trip tested for idempotency. |
| **Strict JSON only** | ✅ PASS | All 73 new fixture JSON files parse under `json.loads` in the pytest lane and `JSON.parse`/python3 in the other lanes. |

### Section 3E: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting — Prettier** | ✅ PASS | **Command:** `npm --prefix extensions/drm-copilot run format` **Result:** clean (executor evidence `final-ts-format.2026-08-10T16-45.md`; lint re-run clean by this review). |
| **Linting — ESLint** | ✅ PASS | **Command:** `npm --prefix extensions/drm-copilot run lint` **Result:** clean (re-run by this review). No new suppression comment appears in the TS diff. |
| **Type checking — TSC** | ✅ PASS | **Command:** `npm --prefix extensions/drm-copilot run typecheck` **Result:** clean (re-run by this review). One `as JsonObject` assertion at `claude-routing-merge.ts:123` sits behind explicit null/object/array narrowing; noted as a Nit in the code review. |
| **Strong typing / ES modules / naming** | ✅ PASS | Recursive `JsonValue` type instead of `any`; ES module syntax; kebab-case filenames; `RoutingMergeError` extends `Error` with a typed `path` field. |
| **Error handling** | ✅ PASS | Parse failures throw `RoutingMergeError` naming the offending path; the destination file's bytes are never written on failure (Jest-asserted). |
| **Dependencies** | ✅ PASS | Zero new runtime dependencies (verified: no `package.json` change in the diff). |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Both parity suites use pytest parametrization keyed by fixture stem; no alternative runner. |
| **Coverage expectation** | ✅ PASS | Repo-wide 92.30% lines / 84.68% branches (lcov accounting) against the uniform >= 85% / >= 75% thresholds; no regression (baseline 92.30% lines). |
| **Focused unit tests** | ✅ PASS | One fixture per parametrized case; batching and coloring fixtures routed by an explicit marker key. |
| **Mocking sparingly** | ✅ PASS | Zero mocks; the reference implementation is exercised directly on committed fixtures. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`, per the universal test-location rule. |
| **Naming conventions** | ✅ PASS | `test_corpus_meets_the_declared_floor`, `test_reference_implementation_reproduces_the_fixture` with fixture-stem ids. |
| **Toolchain** | ✅ PASS | `poetry run pytest` exit 0 at head (re-run by this review). |

### Section 4B: PowerShell Unit Test Policy Compliance

N/A — zero PowerShell files changed on this branch. (The pre-existing `BlastRadius.Manifest.Tests.ps1` pattern is followed by the new bats membership suite instead, keeping the bash library's tests in the bash lane.)

### Section 4C: Bash Test Compliance (bats)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Tests in `tests/shell/*.bats` mirroring sources** | ✅ PASS | Nine new suites in `tests/shell/`; discovery/commands suites extended in place. |
| **No temporary files** | ✅ PASS | All suites read committed fixtures; the payload-only suite uses checked-in PATH shims rather than generated stubs. |
| **Fixture-count floors** | ✅ PASS | Cohort floor 20 (30 on disk), manifest floor 24 (43 on disk), asserted independently in both the pytest and bats lanes, plus a `checked >= floor` re-assertion after each iteration loop so a silently skipping loop cannot pass. |

### Section 4D: TypeScript Unit Test Compliance (Jest)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Jest, `*.test.ts`, AAA** | ✅ PASS | `claude-config-carriage.test.ts` (489 lines, 15 cases), completeness and customizations suites extended; no snapshot tests; in-memory fakes only. |
| **No host runtime / external deps** | ✅ PASS | All I/O through the `PushDownFileSystem` fake; no network or real filesystem writes outside Jest temp-free fakes. |

---

## 5. Test Coverage Detail

### Bash library — cohort computation (`parallel-cohorts.sh`, `compute-cohorts.sh`, `compute-concurrency-batches.sh`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `parallel_cohorts.bats` (222 lines of cases: lexis, usage, exact error strings) | Positive/Negative/Edge | entry-point arg parsing, token validation, error paths | ✅ |
| `parallel_cohorts_parity.bats` (30-fixture corpus loop + floor) | Parity/Positive/Negative | full coloring and batching paths | ✅ |
| `test_parallel_cohort_bash_parity.py` (31 cases) | Parity (Python side) | reference implementation against the same corpus | ✅ |

**Coverage:** inside the merged kcov 92.4% report; per-file breakdown in the CI kcov Cobertura artifact (`artifacts/pester/kcov/cov.xml` on the runner).

### Bash library — manifest validation (`parallel-yaml-scan.sh`, `parallel-yaml-emit.sh`, `parallel-manifest-validate.sh`, `parallel-items-validate.sh`, `parallel-common.sh`, `validate-parallel-manifest.sh`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `parallel_yaml_subset.bats` (181 lines) | Positive/Negative/Edge | scanner subset acceptance and fail-closed rejection | ✅ |
| `parallel_manifest_validate.bats` (165 lines) | Positive/Negative | M1–M7 orchestration and accessors | ✅ |
| `parallel_items_validate.bats` (187 lines) | Negative/Edge | item-record, merge-status consistency, blast-radius block | ✅ |
| `parallel_common.bats` (167 lines) | Positive/Edge | pythonRepr, enum-error templates, locale guard | ✅ |
| `parallel_manifest_parity.bats` (43-fixture corpus loop + floor) | Parity | full validator path byte-parity | ✅ |
| `test_parallel_manifest_bash_parity.py` (83 cases, 5 documented skips) | Parity (Python side) | reference contract against the same corpus | ✅ |

### Push-down config carriage (`claude-customizations.ts`, `claude-routing-merge.ts`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `claude-config-carriage.test.ts` (15 cases) | Positive/Negative/Edge | publish, pack-scoped publish, merge rule (6 behaviors), byte pins, Copilot/Codex non-regression | ✅ |
| `claude-pack-manifest-completeness.test.ts` (extended) | Negative-prevention | rules/lib/config enumeration with two-file floor | ✅ |
| `parallel_bash_manifest_membership.bats` (89 lines) | Structural | core.json membership + bundled byte-mirror, nine-file floor, reverse check | ✅ |

**Coverage:** `claude-routing-merge.ts` 98.05% lines / 87.50% branches; `claude-customizations.ts` 100% lines / 93.55% branches (lcov, regenerated at head).

### Destination-portability end-to-end

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `parallel_payload_only.bats` (113 lines) | End-to-end | all three entry points from a payload-only directory with `python`, `python3`, `poetry` positively unreachable | ✅ |
| `test_shell_qc_discovery.bats` / `test_shell_qc_commands.bats` (extended) | Structural | `.claude/lib/bash` discovery root, count 5 -> 6 with pinned ordering | ✅ |

**Not covered:** the six uncovered lines of `claude-routing-merge.ts` (302/308) and 2/31 branches of `claude-customizations.ts`; both files exceed thresholds regardless.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (all lanes) | 3774 (pytest) + 2495 (Jest) + 245 (bats) = 6514 | ✅ |
| Tests Passed | 6514 (100%; 5 pytest skips are documented accessor-free fixtures) | ✅ |
| Tests Failed | 0 | ✅ |
| Execution Time | pytest 17.81s; Jest 6.97s; bats within the CI shell-coverage job | ✅ Fast |
| Coverage (Python) | 92.30% lines, 84.68% branches (lcov) | ✅ |
| Coverage (TypeScript, extension lane) | 96.57% lines, 89.90% branches | ✅ |
| Coverage (Bash) | 92.4% lines (kcov; no branch measurement) | ✅ |
| New-file line counts | max 340 (shell), 308 (TS) — all under 500 | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | 415 files unchanged, exit 0 | ✅ |
| Ruff Linting | `poetry run ruff check .` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest --cov --cov-branch -q` | 3774 passed, 5 skipped | ✅ |

**For TypeScript (extension lane):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Typecheck | `npm --prefix extensions/drm-copilot run typecheck` | clean | ✅ |
| ESLint | `npm --prefix extensions/drm-copilot run lint` | clean | ✅ |
| Jest + coverage | `npm --prefix extensions/drm-copilot run test:coverage` | 183 suites, 2495 tests pass | ✅ |

**For Bash (CI-only per `.claude/rules/shell.md`):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt + shellcheck | `bash scripts/bash/shell-qc.sh check` (CI step) | green in run 31411775305 at head | ✅ |
| bats + kcov | `bash scripts/bash/shell-qc.sh test --coverage` (CI step) | 245 ok; 92.4% lines | ✅ |

**Notes:**
All checks above marked "re-run by this review" were executed against head `aec5e539` on 2026-08-10. The bash lane was verified through `gh run view 31411775305 --json headSha,conclusion` (headSha equals the branch head, conclusion success) and its log's printed coverage line, not inferred from the run badge alone.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Architecture-boundary stage not executable:** no dependency-cruiser configuration exists in this repository (pre-existing condition, recorded in `evidence/qa-gates/final-ts-arch.2026-08-10T16-45.md` and in the 2026-07-26 adjacent finding). The layer-separation intent was reviewed manually: the new TS code stays inside the push-down module boundary and adds no cross-layer import.
- **Skill-referenced validator script absent (pre-existing, outside this diff):** `.claude/skills/feature-review-workflow/SKILL.md:75` names `scripts/feature-review/Test-ModifiedWorkflowNeedsGreenRun.ps1`, which does not exist in the repository. The rule was discharged manually in this audit via `gh run view`. Recommend filing a docs-drift issue.
- **Seeded test condition left unchecked (deliberate, evaluated and upheld):** the spec's Seeded Test Conditions bullet ending "and generation handling" remains `[ ]`. Independent assessment: `compute_cohorts` accepts no generation input — `scripts/dev_tools/parallel_cohort_computation.py` documents `generation`/`current_cohort` as caller-owned state the library never produces, increments, or accepts (its "Caller-owned fields" section, unchanged by this branch), and the bash port mirrors that contract. There is no library boundary at which "generation handling" could be unit-tested, and adding one would alter a contract this feature is forbidden to change. The clause predates the design. Not a delivery gap; the other five clauses of the bullet are delivered (`cohorts_empty_graph`, `cohorts_single_item`, `cohorts_disjoint_items`, `cohorts_fully_connected_triangle`, `cohorts_tie_breaking_equal_degrees` fixtures plus `parallel_cohorts.bats`).

### Approved Exceptions

- **M1 YAML-parse-failure divergence class:** parity for that single fixture is scoped to the message prefix plus single-element error-list shape, because PyYAML exception text is not reproducible in bash. Declared in spec.md, recorded identically in all four parity-suite headers, and consistent with the TypeScript port's verified-scope precedent in `.claude/rules/parallel-orchestration.md`.
- **Bash branch coverage:** kcov measures line coverage only; `.claude/rules/shell.md` explicitly records that there is no bash branch-coverage gate. Not a threshold exception — the rule defines the gate.

### Removed/Skipped Tests

**None removed.** The 5 pytest skips are parametrized accessor cases over fixtures that declare no accessor expectation; each skip message names its fixture.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **16ecb9d2** - docs(462): add feature docs, research, and atomic plan for parallel destination portability
2. **970bc7bb** - feat(462): extend shell-qc reach to .claude/lib/bash and add parity corpora
3. **ca4c2815** - feat(462): add the destination-portable parallel bash library and shell tests
4. **91c9cc43** - fix(462): make the parallel bash library shellcheck-clean
5. **c1b535af** - fix(462): use an ANSI-C quoted backslash in the YAML scanner
6. **9fcdb300** - fix(462): declare the parallel library associative arrays globally
7. **c8f906cb** - fix(462): un-ignore the Shell-QC discovery fixture and source the locale guard
8. **944d58d3** - feat(462): carry the config tree through push-down and close the manifest gaps
9. **90c79fd1** - feat(462): repoint the destination-runtime parallel path off poetry
10. **ec226b2b** - docs(462): record the final QA gates and check off all 17 acceptance criteria
11. **aec5e539** - docs(462): record the terminal head-SHA-matched shell gate

### Files Modified

1. **`.claude/lib/bash/*` (9 NEW)** — destination-portable cohort computation, concurrency batching, and manifest-contract validation; byte-identical bundled mirrors verified by this review (`diff -r` clean).
2. **`extensions/drm-copilot/src/lib/push-down/claude-customizations.ts` (MODIFIED) / `claude-routing-merge.ts` (NEW)** — `ROOT_FOLDERS` gains `config`; single-path merging publish decorator for `orchestration-routing.json`.
3. **`extensions/drm-copilot/resources/claude-customizations/config/*` (2 NEW), `pack-manifests/core.json` (MODIFIED)** — bundled routing (byte-pinned to repo root) and generic blast-radius default; 13 new manifest entries.
4. **`scripts/bash/shell_qc_lib.sh` (MODIFIED)** — third discovery root and third kcov include root; file-wide SC2015 suppression with reason. **`scripts/bash/cleanup_worktrees_lib.sh` (MODIFIED)** — SC2015 suppression only.
5. **`.claude/settings.json`, `.claude/agents/parallel-{planner,orchestrator}.md` (MODIFIED)** — one new allowlist pattern `Bash(bash .claude/lib/bash/*)` in three places plus wiring prose; mirrored into the bundle (byte-verified).
6. **`.claude/skills/parallel-{plan,orchestrate,add}/SKILL.md`, `.claude/rules/shell.md` (MODIFIED)** — destination-runtime wiring repointed to the bash/PowerShell ports; discovery-contract prose updated.
7. **`.gitignore` (MODIFIED)** — fourth `lib/` negation pair re-including `tests/fixtures/shell_qc/.claude/lib/**` with an explanatory comment; verified effective (`git check-ignore` exit 1; fixture tracked).
8. **`.github/workflows/_shell-coverage.yml` (MODIFIED)** — one added `check` step; reviewed against `.claude/rules/ci-workflows.md` (genuine pass/fail gate, no deliberately-failing nested command, no exit-code reset needed).
9. **Tests and fixtures** — 73 fixture JSONs, 2 pytest suites, 9 new + 2 extended bats suites, 3 Jest files.
10. **Feature docs and evidence** — issue/spec/user-story/plan/research plus 22 evidence artifacts under the canonical `evidence/` tree.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

Every measurable gate passes at head: format, lint, and type checks are clean in all three executable lanes; 6514 tests pass with zero failures; coverage exceeds the uniform thresholds in every measured language with no regression; the schema freeze holds against the diff; evidence locations are canonical; and the modified workflow has an independently verified green run at the branch head. The advisory findings (file-wide suppression scope, permission-callout wording, template-drift in the skill) are Minor/Info severity and are catalogued in the code review; none blocks merge.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: issue, research, spec, plan all present and traceable
- ✅ Design Principles: decorator seam, shared bash common library, pure/IO separation
- ✅ Module & File Structure: max 340-line shell file; DAG dependencies
- ✅ Naming, Docs, Comments: JSDoc/docstring coverage complete
- ✅ Toolchain Execution: all executable stages re-run clean at head
- ✅ Summarize & Document: commits, spec, PR callout prepared

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: test-only change; toolchain clean
- ✅ Bash: CI toolchain green at head; suppression scope flagged as Minor advisory
- ✅ TypeScript: strict typing, zero new dependencies, one narrow justified-by-context assertion
- ✅ JSON: byte-pinned bundled config; strict JSON fixtures

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, fast, deterministic
- ✅ Coverage & Scenarios: thresholds exceeded, no regression, corpus floors in both lanes
- ✅ Test Structure: AAA with diagnostic failure output
- ✅ External Dependencies: none; no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python: pytest-only, mirrored location, parametrized
- ✅ Bash: bats in `tests/shell/`, committed fixtures, floors
- ✅ TypeScript: Jest, in-memory fakes, no snapshots

### Metrics Summary

- ✅ 6514/6514 tests passing (100%)
- ✅ Python 92.30% lines / 84.68% branches (thresholds 85/75)
- ✅ TypeScript 96.57% lines / 89.90% branches
- ✅ Bash 92.4% lines (threshold 85; no branch gate)
- ✅ New TS file 98.05% lines; modified TS file 100% lines
- ✅ All new files under the 500-line cap
- ✅ All code quality checks passing at head

### Recommendation

**Ready for merge.** Follow-ups (non-blocking): narrow or per-line the two SC2015 suppressions; correct two overstated narrowness claims in the permission-surface PR callout before pasting it into the PR body; file the skill docs-drift issue for the absent `Test-ModifiedWorkflowNeedsGreenRun.ps1`. Note the caveat in `final-shell-gate-head.2026-08-10T17-00.md`: any further commit to this branch invalidates the head-SHA-matched shell-gate discharge and requires one fresh `_shell-coverage.yml` dispatch.

---

## Appendix A: Test Inventory

Full inventory is impractical to inline at 6514 tests; the authoritative enumerations are the suite files themselves. New/extended suites introduced by this branch:

**Pytest (Python lane):**
- tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py::test_corpus_meets_the_declared_floor
- tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py::test_reference_implementation_reproduces_the_fixture[30 fixture ids]
- tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py (83 cases: floor + per-fixture contract + accessor cases, 5 documented skips)

**Bats (shell lane, CI):**
- tests/shell/parallel_cohorts.bats › lexis, usage, exact-message cases
- tests/shell/parallel_cohorts_parity.bats › floor, python3 availability, corpus loop
- tests/shell/parallel_manifest_parity.bats › floor, python3 availability, corpus loop
- tests/shell/parallel_manifest_validate.bats › M1–M7 orchestration and accessors
- tests/shell/parallel_items_validate.bats › item-record and consistency checks
- tests/shell/parallel_yaml_subset.bats › scanner subset accept/reject
- tests/shell/parallel_common.bats › pythonRepr, enum templates, locale guard
- tests/shell/parallel_payload_only.bats › payload-only workspace, interpreter-free PATH
- tests/shell/parallel_bash_manifest_membership.bats › core.json membership + bundle byte-mirror
- tests/shell/test_shell_qc_discovery.bats › `.claude/lib/bash` root discovered (count 6, pinned order)
- tests/shell/test_shell_qc_commands.bats › shellcheck call count 6

**Jest (TypeScript lane):**
- test/lib/push-down/claude-config-carriage.test.ts › 15 cases (publish, pack-scope, merge behaviors, byte pins, Copilot/Codex non-regression)
- test/lib/push-down/claude-pack-manifest-completeness.test.ts › rules/lib/config enumeration walks
- test/lib/push-down/claude-customizations.test.ts › ROOT_FOLDERS contract update

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Formatting
poetry run black --check .

# Linting
poetry run ruff check .

# Type checking
poetry run pyright

# Testing with coverage
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**For TypeScript (extension lane):**
```bash
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run test:coverage
```

**For Bash (CI-only per .claude/rules/shell.md):**
```bash
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-08-10T09-25
gh run view 31411775305 --json headSha,conclusion,url
gh run view 31411775305 --log | grep "Bash coverage (lines)"
```

**Review-specific verification:**
```bash
git diff --name-only a26286e8..aec5e539 -- scripts/dev_tools/ extensions/drm-copilot/src/lib/validate/ config/ .claude/rules/parallel-orchestration.md packages/
diff -r .claude/lib/bash extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash
python scripts/dev_tools/validate_evidence_locations.py --root .
git check-ignore -v tests/fixtures/shell_qc/.claude/lib/bash/lib_entry.sh
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-08-10
**Policy Version:** Current (as of audit date)
