# Policy Compliance Audit: parallel-surface-destination-portability-bash (Issue #462) — Remediation Cycle 1 Re-Audit (R4)

**Audit Date:** 2026-08-10
**Code Under Test:** Full branch diff `a26286e87137780ee9e5f59ba2753c2307617572..8c12ea8c9b708ce04f0fdb0d63fcc5a1b1dad132` (180 files, +13657/-166). Production surfaces: 9 new bash library files under `.claude/lib/bash/` plus 9 byte-identical bundled mirrors; `scripts/bash/shell_qc_lib.sh` and `scripts/bash/cleanup_worktrees_lib.sh` (modified); 5 TypeScript files (`claude-customizations.ts` modified, `claude-routing-merge.ts` new, 3 test files); 2 new Python parity test files; `.claude/settings.json` and bundled mirror; 2 agent definitions and mirrors; 3 skill definitions and mirrors; `.claude/rules/shell.md` and mirror; `.github/workflows/_shell-coverage.yml`; `.gitignore`; `core.json`; 2 bundled config files; 76 JSON fixtures; 11 bats files.

**Template source note:** The MCP tool `resolve_policy_audit_template_asset` is not available in this review session. The template was read directly from the bundled asset path `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the exact file the MCP resolver serves per `extensions/drm-copilot/src/policy-audit-template-assets.ts`. This is a documented best-effort substitution, not a template deviation.

**Re-audit context:** The prior review (`policy-audit.2026-08-10T13-30.md`) returned FULLY COMPLIANT at head `f7711fb4`. Remediation cycle 1 (`remediation-plan.2026-08-10T21-03.md`, RI-1 through RI-5) followed at user direction. This re-audit covers the full feature-vs-base diff at head `8c12ea8c`, with specific adjudication of the five remediation items.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Bash | 11 production .sh (9 new, 2 modified) + 11 .bats | 245 bats | ✅ pass (CI runs 31436071256 and 31436665265) | 92.429% lines (1343/1453) pre-cycle-1; 91.5% pre-feature | 92.266% lines (1348/1461) | N/A - kcov aggregate only; new library included in the repo-wide figure (feature-wide +0.9pp with 2,043 new lines in denominator) |
| Python | 2 files (both test files; zero production files) | 3774 pytest (+109) | ✅ pass (executor evidence; reviewer re-ran parity/contract subset: 119 passed) | 92.30% lines, 89.46% branches | 92.30% lines, 89.48% branches | N/A - test-only change, no production Python |
| TypeScript | 5 files (2 production, 3 test) | 2495 jest (+23) | ✅ pass (executor evidence; CI green at head) | 96.55% lines, 89.86% branches | 96.57% lines, 89.90% branches | 98.05% lines / 87.50% branches (new `claude-routing-merge.ts`); 100% lines / 93.55% branches (modified `claude-customizations.ts`) |
| JSON | 84 files (settings, config, manifests, fixtures) | N/A | ✅ validation (reviewer re-ran `node -e "JSON.parse(...)"` on both settings.json) | N/A (config files) | N/A (config files) | N/A |
| PowerShell | 0 files | N/A | N/A | N/A - zero changed files on branch | N/A - zero changed files on branch | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed files on branch | N/A - zero changed files on branch | N/A |

Per-language PASS/FAIL verdicts: Bash **PASS** (0.163pp cycle-1 delta adjudicated in Section 8, G-1), Python **PASS**, TypeScript **PASS**, JSON **PASS**. PowerShell and C# have zero changed files on the branch, so N/A is the applicable verdict for both.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/baseline/typescript-baseline.2026-08-10T14-57.md`
- TypeScript post-change coverage artifact: `evidence/qa-gates/final-ts-test.2026-08-10T16-45.md`; on-disk `extensions/drm-copilot/coverage/lcov.info` (reviewer-parsed: 40958/42412 lines = 96.57%, 5822/6476 branches = 89.90%)
- Python baseline coverage artifact: `evidence/baseline/python-baseline.2026-08-10T14-57.md`
- Python post-change coverage artifact: `evidence/qa-gates/final-python-test.2026-08-10T16-39.md`; on-disk `artifacts/python/lcov.info` (reviewer-parsed: 13288/14396 lines = 92.30%)
- Shell baseline coverage artifact: `evidence/baseline/shell-baseline.2026-08-10T15-05.md` (91.5%); remediation baseline `evidence/remediation-baseline/shell-ci-baseline.2026-08-10T21-40.md` (92.4% at `f7711fb4`)
- Shell post-change coverage artifact: `evidence/qa-gates/shell-coverage-dispatch.2026-08-10T22-05.md` (92.3% at `f8d82e1e`, the last production commit; only evidence/docs commits follow it — reviewer-verified via `git diff --stat f8d82e1e..HEAD`: 3 evidence/plan files)
- PowerShell baseline coverage artifact: `N/A - out of scope` (zero changed PowerShell files on the branch)
- PowerShell post-change coverage artifact: `N/A - out of scope` (zero changed PowerShell files on the branch)
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-08-10T16-52.md` plus the Gate Evaluation table in `shell-coverage-dispatch.2026-08-10T22-05.md`

**Non-negotiable verdict rule:** satisfied — numeric baseline and post-change metrics are present above for every language in scope.

---

## Executive Summary

This is the remediation cycle 1 re-audit (R4) for issue #462 at branch head `8c12ea8c`, against merge base `a26286e8` on `main`. The prior audit at `f7711fb4` found the feature fully compliant; this audit verifies the full branch diff again after five user-directed remediation items (RI-1 spec clause removal, RI-2 Bash allowlist narrowing, RI-3 SC2015 suppression removal, RI-4 `.gitignore` anchoring, RI-5 issue filing #464/#465).

All policy gates pass. The RI-3 rewrite is semantically equivalent at all eight sites (verified by diff inspection; every rewritten middle command is an array append or scalar assignment that cannot return non-zero, so the deleted `|| true` was not load-bearing). Zero `shellcheck disable=SC2015` directives remain under `scripts/bash/`; the only remaining directives are pre-existing SC1091 source-following annotations. The narrowed three-entry Bash grant is present and byte-identical in all six locations, covers every prescribed invocation (61/61 permission/surface/parity contract tests pass, re-run by this reviewer), and no sourceable library is invoked as a command anywhere under `.claude/`. The `.gitignore` anchoring introduced no tracking change. The 0.163pp bash coverage delta is adjudicated below as a measurement-fidelity change, not a coverage regression; the verdict for the bash lane is PASS.

**Policy documents evaluated:**
- ✅ `CLAUDE.md` (policy compliance reading order, tone policy)
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/shell.md` (primary language rule for this diff)
- ✅ `.claude/rules/typescript.md` (via prior audit; TS surface unchanged this cycle)
- ✅ `.claude/rules/python.md` (via prior audit; Python surface unchanged this cycle)
- ✅ `.claude/rules/parallel-orchestration.md` (schema-freeze constraint, AC17)
- ✅ `.claude/rules/quality-tiers.md` (uniform coverage thresholds)
- ✅ `.claude/rules/ci-workflows.md` (workflow diff inspection)
- ✅ `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- ✅ Bash: shfmt + shellcheck + bats + kcov (CI-authoritative per `.claude/rules/shell.md`)
- ✅ Python: black + ruff + pyright + pytest
- ✅ TypeScript: prettier + eslint + tsc + jest
- ✅ JSON: `JSON.parse` validation + repo/bundle hash parity
- N/A PowerShell, C#: zero changed files

**Temporary artifacts cleanup:**
- ✅ No temporary or one-time scripts remain in the diff; all shell files are production library/test files under toolchain coverage.
- ✅ Working tree is clean (`git status --porcelain` empty at review time).

---

## Rejected Scope Narrowing

None detected. The caller prompt for this re-audit explicitly affirmed full feature-vs-base scope ("Same inputs and same scope as the original review at `f7711fb4` — no scope narrowing") and framed its own pre-verified findings as non-binding ("offered so you can spend effort elsewhere, not as claims you must accept"). The six "matters requiring your specific judgment" are additions to the audit, not narrowings. All caller-supplied findings were independently re-verified in this session; none was accepted on assertion.

---

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` → EXIT_CODE 0 (no violations).
- `git diff --name-only a26286e8..HEAD | grep -E "^artifacts/"` → no matches (exit 1). Zero evidence files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 34 evidence artifacts in the diff live under `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/<kind>/` (baseline, remediation-baseline, qa-gates, regression-testing, other) — canonical per `evidence-and-timestamp-conventions`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no caller instruction supplied a non-canonical path.

**Verdict: PASS.**

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | bats suites use checked-in fixtures and stub binaries via the `SHELL_QC_<TOOL>_BIN` seam; pytest parity suites parametrize over the committed corpus with no shared state; Jest push-down suites use in-memory filesystems. Reviewer re-ran the four pytest contract/parity modules in isolation: 119 passed, 61 passed. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One bats case per invariant/fixture (e.g., `parallel_manifest_validate.bats` per M-rule); pytest parity tests assert one fixture per parametrized case. |
| **Fast Execution** | ✅ PASS | Reviewer-observed: 119 parity tests in 0.35s; 61 contract tests in 0.23s. CI shell job completed in 3m18s including kcov instrumentation. |
| **Determinism** | ✅ PASS | `LC_ALL=C` guard in `parallel-common.sh`; `sort -n` for numeric ordering; no associative-array iteration reaches output (spec Data & State section, enforced in `parallel-cohorts.sh`); no wall-clock or RNG use in any new test. |
| **Readability & Maintainability** | ✅ PASS | Descriptive bats case names; parity-suite headers document the two declared divergence classes (M1 PyYAML text; non-printable repr escapes). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Python 92.30%/89.46%, TS 96.55%/89.86%, shell 91.5% captured pre-development (`evidence/baseline/*.2026-08-10T14-57.md`, `shell-baseline.2026-08-10T15-05.md`); cycle-1 shell baseline 92.429% (`shell-ci-baseline.2026-08-10T21-40.md`). |
| **No Coverage Regression** | ✅ PASS (adjudicated) | Python flat at 92.30%; TS +0.02pp lines / +0.04pp branches; shell +0.9pp feature-wide. The cycle-1 shell delta 92.429% → 92.266% (-0.163pp) is adjudicated as measurement fidelity, not regression — see Section 8 finding G-1. Covered line count rose (1343 → 1348); no test removed or weakened. |
| **New Code Coverage** | ✅ PASS | TS new file `claude-routing-merge.ts`: 98.05% lines / 87.50% branches (reviewer-parsed from `extensions/drm-copilot/coverage/lcov.info`). New bash library: inside the kcov include pattern; overall shell coverage rose 0.9pp while the library's 2,043 lines entered the denominator, so the library is covered above the pre-existing average. Python new files are tests (excluded from the denominator per policy). |
| **Comprehensive Coverage** | ✅ PASS | 245 bats (+143), 3774 pytest (+109), 2495 jest (+23). Parity corpora: 31 cohort fixtures + 43 manifest fixtures asserted by both lanes with fixture-count floors. |
| **Positive Flows** | ✅ PASS | Valid cohort graphs, valid manifests (`manifest_valid_*.json`), accessor-present cases, merge/copy happy paths in Jest. |
| **Negative Flows** | ✅ PASS | `cohorts_error_*` fixtures (duplicate key, self-loop, unknown endpoints, negative variants); `manifest_m1_*` through `manifest_m7_*` error fixtures; `max_concurrency < 1` rejection with exact Python message; Jest fail-fast on unparseable destination. |
| **Edge Cases** | ✅ PASS | Empty graph, single item, zero/negative keys, tie-breaking, permuted-input equivalence; LF/CRLF/CR line endings; boolean-rejected `max_concurrency`; empty-items manifest. |
| **Error Handling** | ✅ PASS | Validation-ordering parity (duplicate-key before edge errors; self-loop before unknown-endpoint; M1 fence before identity); exit-code contracts asserted in bats. |
| **Concurrency** | N/A | All new bash functions are pure computations over CLI input; no concurrent execution surface. |
| **State Transitions** | N/A | No stateful component added; the checkpoint cache doctrine is untouched (AC17). |

### 1.2.1 Per-Language Coverage Comparison

- Bash: Baseline: 92.429% lines (pre-cycle-1; pre-feature 91.5%) -> Post-change: 92.266% lines. Change: -0.163pp lines vs pre-cycle-1 (adjudicated measurement fidelity, finding G-1) and +0.766pp vs pre-feature. New/changed-code coverage: N/A - kcov aggregate only; the new library is inside the include pattern and the aggregate rose +0.9pp feature-wide. Disposition: PASS. Evidence: `evidence/qa-gates/shell-coverage-dispatch.2026-08-10T22-05.md`; `evidence/qa-gates/coverage-delta.2026-08-10T16-52.md`. Branch coverage is not measurable by kcov; no bash branch gate per `.claude/rules/shell.md`.
- Python: Baseline: 92.30% lines / 89.46% branches -> Post-change: 92.30% lines / 89.48% branches. Change: 0.00pp lines / +0.02pp branches. New/changed-code coverage: N/A - test-only change. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (reviewer-parsed); `evidence/qa-gates/final-python-test.2026-08-10T16-39.md`.
- TypeScript: Baseline: 96.55% lines / 89.86% branches -> Post-change: 96.57% lines / 89.90% branches. Change: +0.02pp lines / +0.04pp branches. New/changed-code coverage: 98.05% lines / 87.50% branches (new file); 100% lines / 93.55% branches (modified file). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` (reviewer-parsed); `evidence/qa-gates/final-ts-test.2026-08-10T16-45.md`.
- PowerShell: N/A - out of scope (zero changed files on the branch).
- C#: N/A - out of scope (zero changed files on the branch).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Parity suites diff expected-vs-actual strings per fixture; bats assertions name the failing fixture and invariant. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | bats cases arrange fixtures/stubs, invoke the entry point, assert stdout/stderr/exit code; pytest parametrized cases follow the same shape. |
| **Document Intent** | ✅ PASS | Suite headers document parity scope and declared divergence classes; case names describe the scenario. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, DB, or remote API in any new test. The payload-only bats case uses checked-in stub coreutils under `tests/fixtures/parallel_payload_path/`. |
| **Use Mocks/Stubs** | ✅ PASS | `SHELL_QC_<TOOL>_BIN` seam with checked-in stubs; Jest in-memory filesystem for push-down. |
| **Environment Stability** | ✅ PASS | No temporary files created by tests (policy prohibition); fixtures are checked in, including `tests/fixtures/shell_qc/.claude/lib/bash/lib_entry.sh` (whose prior silent exclusion motivated RI-4). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document (re-audit R4), plus `code-review.2026-08-10T22-21.md` and `feature-audit.2026-08-10T22-21.md`, before PR #463 merge. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #462; `spec.md` v0.2; remediation cycle scoped by `remediation-inputs.2026-08-10T21-03.md` (RI-1..RI-5). |
| **Read existing change plans** | ✅ PASS | `plan.2026-08-10T09-36.md` (original) and `remediation-plan.2026-08-10T21-03.md` (cycle 1); policy reads recorded in `evidence/baseline/phase0-instructions-read.md` and `evidence/remediation-baseline/phase0-instructions-read.2026-08-10T21-39.md`. |
| **Document the plan** | ✅ PASS | Both plans checked off task-by-task with per-task acceptance and evidence pointers. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | RI-3 replaced a lint-suppressed idiom with plain `if` statements — strictly simpler. The bash port uses only builtins plus coreutils; no `yq`, no new dependency. |
| **Reusability** | ✅ PASS | Shared helpers concentrated in `parallel-common.sh` (pythonRepr, enum_error, error accumulation); scanner/emitter split reused by both validators. |
| **Extensibility** | ✅ PASS | Entry points are thin CLIs over sourceable libraries; routing merge is a decorator at the existing `ExcludingFileSystem` seam, not an engine change. |
| **Separation of concerns** | ✅ PASS | Pure computation (cohorts, validation) separated from CLI I/O; push-down merge logic isolated in `claude-routing-merge.ts`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Eight-file decomposition matches the spec's Implementation Strategy table. |
| **Under 500 lines** | ✅ PASS | Reviewer-verified `wc -l`: largest new file `parallel-yaml-emit.sh` 340; `shell_qc_lib.sh` 379; `cleanup_worktrees_lib.sh` 479; all .bats <= 222. All under 500. |
| **Public vs internal** | ✅ PASS | Three CLI entry points public; six libraries sourced internally (and the narrowed grant now encodes exactly this boundary). |
| **No circular dependencies** | ✅ PASS | Source chain is linear: entry points → validate/cohorts → items/emit → scan → common. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Kebab-case entry points matching spec CLI surface; function names match the Python authority (`compute_cohorts`, `manifest_mode`). |
| **Docs/docstrings** | ✅ PASS | Every shell function carries a purpose/args/returns comment block; `.claude/rules/shell.md` prose updated for the new discovery root. |
| **Comment why, not what** | ✅ PASS | RI-3 preserved each site's intent comment; the incorrect "mandated idiom" justification blocks were deleted with the suppressions. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Shell: `shfmt` diff-clean locally (`shell-local-precheck.2026-08-10T21-55.md`) and in CI (`Run shell-qc check` step green, shfmt 3.8.0). Python: `poetry run black .` clean (`final-python-format`); reviewer re-ran `black --check` on the two changed test files: unchanged. TS: `final-ts-format`. |
| **2. Linting** | ✅ PASS | Shell: shellcheck green in CI at `f8d82e1e` with zero SC2015 suppressions present (authoritative per Constraint 2 — local shellcheck 0.11.0 cannot reproduce the CI finding). Python: ruff clean (reviewer re-ran on changed files: "All checks passed!"). TS: eslint clean (`final-ts-lint`). |
| **3. Type checking** | ✅ PASS | Python: pyright clean (`final-python-typecheck`). TS: tsc clean (`final-ts-typecheck`). Bash: no type-check stage per `.claude/rules/shell.md`. |
| **4. Testing** | ✅ PASS | bats 245 green in CI; pytest 3774 green; jest 2495 green; RI-2 contract gate 61/61 (`ri2-pytest-gate.2026-08-10T22-08.md`, re-run by reviewer). |
| **Full toolchain loop** | ✅ PASS | Cycle-1 loop completed in one CI pass (run 31436071256, both verification steps green); full CI at head 8c12ea8c green (run 31436665265). |
| **Explicit reporting** | ✅ PASS | Every gate has a schema-conformant evidence artifact with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | 14 conventional commits; PR #463 body at `artifacts/pr_body_462.md`. |
| **Design choices explained** | ✅ PASS | Spec records rejected alternatives (yq, Node validation, `scripts/bash/parallel/` mirror layout); the disclosure artifact records the narrowing rationale and history. |
| **Update supporting documents** | ✅ PASS | `.claude/rules/shell.md` prose, skill/agent wiring, bundle `config/` asymmetry documented. |
| **Provide next steps** | ✅ PASS | Residual destination gaps (drift/mutation CLIs) recorded as non-goals; defects filed as #464/#465 (RI-5). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh check` (CI, shfmt 3.8.0 diff stage)<br>**Result:** green at `f8d82e1e` (run 31436071256); CI 3.8.0 accepts the expanded `if` form with no diff. |
| **Linting with shellcheck** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh check` (CI, apt-packaged shellcheck)<br>**Result:** green with both file-wide SC2015 directives deleted and no replacement suppression of any scope. Reviewer-verified: `grep -rn "SC2015" scripts/bash/` → zero matches; only pre-existing SC1091 source-following directives remain (`cleanup-worktrees.sh:17,20,23`, `coverage_demo.sh:5`, `shell-qc.sh:13`). |
| **Testing with bats** | ✅ PASS | **Command:** `bash scripts/bash/shell-qc.sh test --coverage` (CI)<br>**Result:** 245 tests green, coverage 92.3% printed. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | All new files use `#!/usr/bin/env bash`. |
| **Error handling** | ✅ PASS | Entry points use `set -euo pipefail`. RI-3 verification (reviewer, diff inspection of all 8 sites): every rewritten middle command is an array append (`roots+=`, `dirs+=`) or a scalar assignment (`exit_code=$rc`, `rc=$crc`) — none can return non-zero, so the deleted `|| true` was redundant, not load-bearing, and the `if` form is semantically identical under `set -e` (a false `if` condition does not trigger `set -e`). The two retained `\|\| true` sites at `shell_qc_lib.sh:267` (grep no-match tolerance feeding an explicit `[[ -n $match ]] \|\| return 1`) and `:369` (best-effort canonical-path copy of an already-merged report) are genuine capture/tolerance sites in the `\|\| rc=$?` family that `.claude/rules/shell.md` mandates for tools that legitimately return non-zero; both retained verbatim. |
| **Under 500 lines** | ✅ PASS | Max 479 (`cleanup_worktrees_lib.sh`); see 2.3. |

**Suppression policy verdict (RI-3):** PASS. The rule permits suppressions "only when justified inline"; the removed file-wide directives cited a rule (`\|\| rc=$?` capture) that does not cover the `A && B \|\| true` idiom, so no exception was defensible. The fix removes the finding class entirely on every shellcheck version rather than suppressing it. Zero suppressions of any scope were added.

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Validation** | ✅ PASS | **Command:** `node -e "JSON.parse(require('fs').readFileSync('.claude/settings.json','utf8'))"` and the bundled mirror — reviewer re-ran: "both settings.json valid". |
| **Repo/bundle parity** | ✅ PASS | Reviewer-computed SHA-256: all three edited pairs (settings.json, parallel-planner.md, parallel-orchestrator.md) byte-identical; all nine `.claude/lib/bash/*.sh` files MATCH their bundled mirrors. Executable form: `test_push_down_claude_resource_contracts.py` green (61/61 gate). |

#### 3D.2 Permission-surface change (RI-2 adjudication)

| Check | Status | Evidence |
|---|---|---|
| Three entry-point grants replace the single wildcard in all six locations | ✅ PASS | `.claude/settings.json:8-10` and bundled mirror `:8-10`; both agent frontmatters (planner `:17-19`, orchestrator `:18-20`) and their prose sections; hash parity above. |
| Old wildcard eliminated from production surfaces | ✅ PASS | `git grep -n 'bash \.claude/lib/bash/\*)' -- ':!docs/features/**'` → zero matches. Remaining occurrences are historical records under the feature folder only. |
| No under-permitting | ✅ PASS | `git grep -n "bash .claude/lib/bash" -- '.claude/skills' '.claude/agents'` → every prescribed invocation names one of the three entry points; each is covered by the matching prefix grant. The permission-contract pytest asserts uncovered = 0 (61/61, re-run by reviewer). |
| No library invoked as a command | ✅ PASS | The only `lib/bash` references outside the three entry points are shellcheck `source=` annotations inside the library files and prose in `shell.md`/`parallel-plan/SKILL.md`; none is a command invocation. |
| Disclosure artifact accuracy | ✅ PASS (one precision nit, non-blocking) | `evidence/other/permission-surface-callout.2026-08-10T17-08.md` amended: describes the three-entry grant, retains the historical record of the earlier inaccurate claim, and states the residual scope. The nested-subdirectory and pre-filename traversal claims are correct as stated. Precision nit recorded as code-review finding CR-2: a traversal segment appended *after* the fixed filename (e.g., `compute-cohorts.sh/../x.sh`) does match the string pattern, but cannot resolve on a POSIX filesystem because the entry point is a regular file (ENOTDIR), so it is not executable; the artifact's effective claim holds. |

### Sections 3A (Python) and 3B (PowerShell)

- Python: production code unchanged this feature (test-only additions); prior-audit findings stand; black/ruff/pyright/pytest all green (Section 2.5).
- PowerShell: no changed files. Section not applicable.

### TypeScript

- Production surface (`claude-customizations.ts`, `claude-routing-merge.ts`) unchanged in cycle 1; prior audit PASS stands, re-confirmed by green CI at head (run 31436665265) and reviewer-parsed lcov (Section 1.2.1).

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Both parity suites are pytest, parametrized over the committed corpora with fixture-count floors. |
| **Coverage expectation** | ✅ PASS | Repo-wide 92.30% lines / 89.48% branches (>= 85 / >= 75). Test-only change; no production denominator change. |
| **Focused unit tests / organization** | ✅ PASS | Tests under `tests/scripts/dev_tools/` mirroring the authority modules' location; one behavior per parametrized case. |
| **Naming and readability** | ✅ PASS | Suite headers document parity scope and the declared divergence classes. |
| **Toolchain** | ✅ PASS | `poetry run pytest` green (3774); reviewer re-ran the four parity/contract modules: 119 passed, 5 skipped (fixtures that deliberately declare no accessor expectation — parametrization design, not disabled tests). |

### Section 4 (Bash / bats)

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Tests in `tests/shell/*.bats` mirroring `scripts/bash/` and library** | ✅ PASS | Nine new suites plus two extended discovery/commands suites; layout per `.claude/rules/shell.md`. |
| **No temporary files; checked-in fixtures and stubs** | ✅ PASS | Corpora under `tests/fixtures/parallel_cohorts/` and `parallel_manifest_bash/`; stub binaries under `tests/fixtures/parallel_payload_path/`; discovery fixture `tests/fixtures/shell_qc/.claude/lib/bash/lib_entry.sh` (now protected by the RI-4 anchoring). |

### TypeScript (Jest)

- 15-case `claude-config-carriage.test.ts` covering copy, merge, stale-`parallel` overwrite, local-route preservation, idempotency, fail-fast; completeness-test enumeration extended to `rules/*.md`, `lib/**`, bundled `config/`. Green in CI at head. PASS.

---

## 5. Test Coverage Detail

### Bash lane — cycle-1 delta detail (the adjudicated surface)

| Scope | Baseline (f7711fb4) | Head-adjacent (f8d82e1e) | Delta |
|---|---|---|---|
| Whole bash surface | 1343/1453 = 92.429% | 1348/1461 = 92.266% | +5 covered, +8 total, -0.163pp |
| `scripts/bash/cleanup_worktrees_lib.sh` | 179/192 = 93.23% | 180/193 = 93.26% | improved |
| `scripts/bash/shell_qc_lib.sh` | 156/178 = 87.64% | 160/185 = 86.49% | -1.15pp (see G-1) |
| Every other file | unchanged | unchanged | 0 |

The three newly uncovered lines in `shell_qc_lib.sh` (per-line hit-map diff recorded in `shell-coverage-dispatch.2026-08-10T22-05.md`, sites verified by this reviewer against the current file):
- `:250` — split of an already-uncovered statement (no coverage lost);
- `:352` and `:363` — `exit_code=$rc` bodies reachable only when `kcov` itself exits non-zero, which no test forces; previously masked because the assignment shared a physical line with its condition.

### TypeScript — changed production files

| File | Lines | Branches | Status |
|---|---|---|---|
| `src/lib/push-down/claude-routing-merge.ts` (NEW) | 302/308 = 98.05% | 42/48 = 87.50% | ✅ |
| `src/lib/push-down/claude-customizations.ts` (MODIFIED) | 276/276 = 100% | 29/31 = 93.55% | ✅ |

### Python — changed files

Both changed files are tests (`test_parallel_cohort_bash_parity.py`, `test_parallel_manifest_bash_parity.py`); excluded from the coverage denominator per policy. Repo-wide 92.30%/89.48%.

**Not covered:** `shell_qc_lib.sh:352,363` (kcov-failure error branches — pre-existing untested behavior newly made visible; see G-1). No other new uncovered production code.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total tests (all lanes) | 245 bats + 3774 pytest + 2495 jest = 6514 | ✅ |
| Tests Passed | 6514 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Reviewer-observed subset runtime | 119 parity tests 0.35s; 61 contract tests 0.23s | ✅ Fast |
| CI shell job runtime | 3m18s (run 31436071256) | ✅ |
| Code Coverage | Bash 92.266% lines; Python 92.30%/89.48%; TS 96.57%/89.90% | ✅ |

---

## 7. Code Quality Checks

**For Bash (CI-authoritative per `.claude/rules/shell.md`):**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt (diff) | `bash scripts/bash/shell-qc.sh check` | no diff (CI 3.8.0; local 3.12.0 precheck clean) | ✅ |
| shellcheck | `bash scripts/bash/shell-qc.sh check` | clean with zero SC2015 suppressions present | ✅ |
| bats + kcov | `bash scripts/bash/shell-qc.sh test --coverage` | 245 green; 92.3% printed | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check <changed files>` (reviewer) | 2 files unchanged | ✅ |
| Ruff | `poetry run ruff check <changed files>` (reviewer) | All checks passed | ✅ |
| Pyright | `poetry run pyright` (executor evidence) | clean | ✅ |
| Pytest | `poetry run pytest` (executor evidence; reviewer subset re-run) | 3774 green / 119+61 green | ✅ |

**For TypeScript:** prettier/eslint/tsc/jest all green per `final-ts-*.2026-08-10T16-45.md` and CI run 31436665265 at head.

**Workflow rules:**
- `modified-workflow-needs-green-run`: TRIGGERED (`.github/workflows/_shell-coverage.yml` modified, +3 lines adding the `shell-qc check` step). SATISFIED: green `CI` run 31436665265 at branch head `8c12ea8c` (reviewer-verified via `gh run view`: conclusion success, headSha match; `ci.yml:26-27` invokes the modified reusable workflow), plus green `workflow_dispatch` run 31436071256 at `f8d82e1e` (last production commit).
- `.claude/rules/ci-workflows.md` (deliberately-failing nested command): NOT TRIGGERED — the added step runs `bash scripts/bash/shell-qc.sh check`, a positive-path check with no intentionally failing nested command and no `pwsh` exit-code residue.
- `.claude/rules/benchmark-baselines.md`: NOT TRIGGERED — no `scripts/benchmarks/**` change.

**Notes:** No pre-existing failures encountered. `git ls-files -ci --exclude-standard` reports two tracked-but-ignore-matching files (`.claude/settings.local.json`, `tests/fixtures/shell_qc/scripts/node_modules/skip_me.sh`); both were tracked at the merge base and match rules unrelated to the RI-4 `lib/` anchoring — pre-existing condition, not introduced by this branch.

---

## 8. Gaps and Exceptions

### Identified Gaps

**G-1 — Bash headline coverage delta, adjudicated PASS (reviewer ruling on the escalated finding).** The cycle-1 rewrite moved bash line coverage 92.429% → 92.266% (-0.163pp), so the remediation plan's literal "no regression against baseline" condition is not strictly met. This reviewer independently assessed the executor's measurement-fidelity explanation and **concurs; this is not a genuine coverage regression**:
1. The covered-line count *rose* (1343 → 1348); no test was removed, disabled, or weakened (bats suite byte-identical between the two runs).
2. The two newly uncovered lines (`shell_qc_lib.sh:352`, `:363`) are `exit_code=$rc` branch bodies that were never executed in either form — before the rewrite they shared a physical line with their condition, and kcov counted that line covered whenever the condition was *evaluated*. The baseline figure therefore overstated true coverage; 92.266% is the more accurate measurement of the same tested behavior. The third line (`:250`) is a re-split of an already-uncovered statement.
3. The policy intent ("no regression on changed lines" per `general-unit-test.md`) is not violated: no changed line that was executed before is unexecuted now.
4. The absolute value clears the uniform 85% floor by 7.27 points, and `cleanup_worktrees_lib.sh` improved outright.
Residual: the two kcov-failure error branches are genuinely untested (pre-existing, newly visible). Recorded as non-blocking code-review finding CR-1 with a follow-up recommendation; not a remediation trigger.

### Approved Exceptions

**None.** No suppression, no coverage exclusion, no policy exception was added anywhere in the diff. (The M1 PyYAML-text parity divergence is a spec-declared scope boundary recorded in AC3, not a policy exception.)

### Removed/Skipped Tests

**None removed.** The 5 pytest skips in `test_parallel_manifest_bash_parity.py` are parametrization design (fixtures that declare no accessor expectation), present since the original review, not disabled tests.

---

## 9. Summary of Changes

### Commits in This PR/Branch (14, `a26286e8..8c12ea8c`)

1. **16ecb9d2** — docs(462): add feature docs, research, and atomic plan
2. **970bc7bb** — feat(462): extend shell-qc reach to .claude/lib/bash and add parity corpora
3. **ca4c2815** — feat(462): add the destination-portable parallel bash library and shell tests
4. **91c9cc43** — fix(462): make the parallel bash library shellcheck-clean
5. **c1b535af** — fix(462): use an ANSI-C quoted backslash in the YAML scanner
6. **9fcdb300** — fix(462): declare the parallel library associative arrays globally
7. **c8f906cb** — fix(462): un-ignore the Shell-QC discovery fixture and source the locale guard
8. **944d58d3** — feat(462): carry the config tree through push-down and close the manifest gaps
9. **90c79fd1** — feat(462): repoint the destination-runtime parallel path off poetry
10. **ec226b2b** — docs(462): record the final QA gates and check off all 17 acceptance criteria
11. **aec5e539** — docs(462): record the terminal head-SHA-matched shell gate
12. **f7711fb4** — docs(462): record feature-review artifacts and correct permission-surface scope
13. **f8d82e1e** — fix(parallel): narrow bash allowlist, drop SC2015 suppressions, anchor gitignore (remediation cycle 1 production commit)
14. **8c12ea8c** — docs(462): record remediation cycle 1 evidence and complete the plan checklist

### Files Modified (remediation cycle 1 production delta, `f7711fb4..f8d82e1e`)

1. **`.claude/settings.json` + bundled mirror** (MODIFIED) — three entry-point-specific grants replace the single wildcard (RI-2).
2. **`.claude/agents/parallel-planner.md`, `.claude/agents/parallel-orchestrator.md` + bundled mirrors** (MODIFIED) — frontmatter `tools:` lists and prose updated to the three grants (RI-2).
3. **`scripts/bash/shell_qc_lib.sh`** (MODIFIED) — file-wide SC2015 directive and justification block deleted; seven `A && B \|\| true` sites rewritten as `if` statements (RI-3).
4. **`scripts/bash/cleanup_worktrees_lib.sh`** (MODIFIED) — same treatment, one site (RI-3).
5. **`.gitignore`** (MODIFIED) — `lib/` → `/lib/`, `lib64/` → `/lib64/`, eight lib-related negation lines and their comment scaffolding deleted (RI-4).
6. **`spec.md`** (MODIFIED) — unwritable `, and generation handling` clause deleted from the seeded-test-conditions bullet; box checked (RI-1).
7. **`evidence/other/permission-surface-callout.2026-08-10T17-08.md`** (MODIFIED) — amended to describe the delivered three-entry grant with historical record retained (RI-2).

The full-feature file inventory (180 files) is unchanged from the prior audit's Section 9 and the PR-context appendix.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All five remediation items are delivered and verified. The full feature-vs-base diff at head `8c12ea8c` passes every applicable policy gate: toolchain loops green in all lanes (bash lane CI-authoritative, both verification steps green at the last production commit and full CI green at the branch head), coverage above uniform thresholds in every language with changed files, zero suppressions and zero coverage exclusions added, schema freeze (AC17) proven across the full diff, evidence locations canonical, and the permission-surface change narrowed, disclosed, and executably verified.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objectives, plans, and policy reads documented for both cycles
- ✅ Design Principles: simplification (RI-3), no new dependencies, decorator seam reuse
- ✅ Module & File Structure: all files under 500 lines; linear dependency chain
- ✅ Naming, Docs, Comments: intent comments preserved; false justification text removed
- ✅ Toolchain Execution: single-pass green in all lanes at cycle end
- ✅ Summarize & Document: commits, PR body, disclosure artifact current

#### Language-Specific Code Change Policy (Section 3)
- ✅ Bash Tooling & Baseline: CI-authoritative gates green; suppression policy satisfied by removal
- ✅ Bash Design: `set -euo pipefail`; RI-3 rewrite semantically equivalent at all 8 sites; the 2 retained `|| true` sites are genuinely load-bearing
- ✅ JSON: valid, byte-parity across all repo/bundle pairs
- ✅ TypeScript / Python: unchanged this cycle; prior PASS re-confirmed at head

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: deterministic, isolated, fast
- ✅ Coverage & Scenarios: thresholds met in all lanes; G-1 adjudicated PASS
- ✅ Test Structure: AAA, fixture-count floors, declared divergence classes
- ✅ External Dependencies: none; no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python: pytest-only, mirrored layout, parametrized corpus
- ✅ Bash: bats mirrored layout, checked-in fixtures and stubs
- ✅ TypeScript: Jest in-memory push-down suites, completeness enumeration extended

### Metrics Summary

- ✅ 6514/6514 tests passing across bats, pytest, and Jest
- ✅ Bash 92.266% lines (floor 85%); Python 92.30%/89.48%; TypeScript 96.57%/89.90%
- ✅ New TS file 98.05%/87.50%; modified TS file 100%/93.55%
- ✅ Zero lint suppressions added; two file-wide suppressions removed
- ✅ Green CI at branch head: run 31436665265 (conclusion success, headSha `8c12ea8c`)
- ✅ Evidence-location validator exit 0

### Recommendation

**Ready for merge.** No remediation is triggered. Two non-blocking observations are recorded in `code-review.2026-08-10T22-21.md` (CR-1 follow-up test suggestion for the kcov-failure branches; CR-2 precision nit on the disclosure artifact's traversal claim).

---

## Appendix A: Test Inventory

New/changed test surfaces on the branch (suite level; full per-case lists live in the suite files):

- `tests/shell/parallel_cohorts.bats` (cohort computation unit cases: empty graph, single item, disjoint, clique, tie-breaking, zero/negative keys, permuted-input equivalence, error ordering)
- `tests/shell/parallel_cohorts_parity.bats` (bash↔Python corpus parity, fixture-count floor)
- `tests/shell/parallel_common.bats` (pythonRepr, type predicates, enum_error/item_context, LC_ALL guard)
- `tests/shell/parallel_yaml_subset.bats` (fence extraction M1, LF/CRLF/CR, restricted-subset fail-closed)
- `tests/shell/parallel_items_validate.bats` (M6 item records, merge-status consistency, blast-radius shape)
- `tests/shell/parallel_manifest_validate.bats` (M1-M7 orchestration, accessors present/absent/invalid)
- `tests/shell/parallel_manifest_parity.bats` (bash↔Python manifest parity, declared M1 divergence)
- `tests/shell/parallel_bash_manifest_membership.bats` (core.json entry + bundled counterpart per repo file)
- `tests/shell/parallel_payload_only.bats` (payload-only workspace clears all four blockers; stub coreutils PATH)
- `tests/shell/test_shell_qc_discovery.bats`, `test_shell_qc_commands.bats` (extended: `.claude/lib/bash` root, count updates 5→6)
- `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` (pytest lane of the cohort corpus)
- `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` (pytest lane of the manifest corpus)
- `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` (15 cases: copy/merge/overwrite/preserve/idempotency/fail-fast/pack-scope/Copilot+Codex non-regression)
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (enumeration extended: rules/*.md, lib/**, bundled config/)
- Contract gates re-run this cycle: `test_parallel_orchestrator_permission_contracts.py`, `test_parallel_orchestrator_surface_contracts.py`, `test_parallel_planner_surface_contracts.py`, `test_push_down_claude_resource_contracts.py` (61 cases)

---

## Appendix B: Toolchain Commands Reference

**Bash (CI-authoritative; run under WSL locally or `ubuntu-latest` in CI):**
```bash
bash scripts/bash/shell-qc.sh format        # shfmt write mode
bash scripts/bash/shell-qc.sh check         # shfmt -d + shellcheck per file
bash scripts/bash/shell-qc.sh test          # bats
bash scripts/bash/shell-qc.sh test --coverage   # bats under kcov; prints "Bash coverage (lines): NN.N%"
gh workflow run _shell-coverage.yml --ref <branch>   # CI dispatch (the verification path from win32)
```

**Python:**
```bash
poetry run black --check .
poetry run ruff check
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**TypeScript (extension-scoped):**
```bash
npm --prefix extensions/drm-copilot run format
npm --prefix extensions/drm-copilot run lint
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run test:coverage
```

**Review-session verification commands (this audit):**
```bash
git diff --name-only a26286e8..HEAD | grep -E "^(scripts/dev_tools/|extensions/drm-copilot/src/lib/validate/)"   # AC17: exit 1
git grep -n 'bash \.claude/lib/bash/\*)' -- ':!docs/features/**'   # old wildcard: exit 1
grep -rn "SC2015" scripts/bash/                                    # zero matches
grep -rnE '&&.*\|\| true' scripts/bash/ .claude/lib/bash/          # zero matches
sha256sum <repo file> <bundled mirror>                             # parity: all pairs MATCH
git check-ignore -v <five formerly-negated paths>                  # exit 1 (unignored)
git ls-files -ci --exclude-standard                                # two pre-existing entries, unrelated to lib rules
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .   # exit 0
poetry run pytest tests/scripts/dev_tools/test_parallel_*_parity.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py   # 119 + 61 green
gh run view 31436665265 --json url,conclusion,headSha              # success @ 8c12ea8c
awk '...' artifacts/python/lcov.info extensions/drm-copilot/coverage/lcov.info   # lcov totals
```

---

**Audit Completed By:** feature-review agent (Claude Code)
**Audit Date:** 2026-08-10
**Policy Version:** Current (as of audit date)
