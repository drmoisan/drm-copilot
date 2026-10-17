# Policy Compliance Audit: Skill-Referenced Scripts Bundled With Their Skills (Issue #762)

---

**Audit Date:** 2026-09-28
**Code Under Test:** Full branch diff `fix/skill-bundled-scripts` against `main` (merge base `42e95e275953d3235eeab7ed5cebf26c7b019f51`, head `4606f5ab73dc8e5dabdcccc89a40b7e1ad585412`). Non-evidence files:

- Python (new): `scripts/dev_tools/skill_bundle_contract.py`, `scripts/dev_tools/skill_bundle_contract_cli.py`, `tests/scripts/dev_tools/test_skill_bundle_contract.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`
- Python (modified): `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- PowerShell (renamed): `scripts/orchestration/Invoke-CiGateParser.ps1` -> `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`; `tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1` -> `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`
- PowerShell (new): `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`; bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-CiGateParser.ps1`
- PowerShell (modified config): `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror under `extensions/drm-copilot/resources/powershell/PoshQC/settings/`
- Bash (renamed): ten `scripts/bash/cleanup*worktrees*.sh` files -> `.claude/skills/cleanup-merged-worktrees/scripts/`
- Bash (new): ten byte-identical bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/scripts/`; fixture `tests/fixtures/shell_qc/.claude/skills/demo-skill/scripts/skill_entry.sh`
- Bash (modified): `scripts/bash/shell_qc_lib.sh`; 21 bats suites under `tests/shell/`
- JSON (modified): `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- Markdown (modified, with byte-identical mirrors): `.claude/rules/shell.md`, `.claude/skills/cleanup-merged-worktrees/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`
- Feature documentation and evidence under `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/` and three promoted potential records under `docs/features/potential/promoted/`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 7 files | 42 guard tests; 5340 in CI suite | ✅ 42 pass, 0 fail (local); CI 5340 pass, 0 fail | 93.08% lines, 85.86% branches (scripts.dev_tools) | 93.11% lines, 85.92% branches (scripts.dev_tools) | 96.45% line / 95.00% branch (skill_bundle_contract.py); 92.98% line / 77.27% branch (skill_bundle_contract_cli.py) |
| PowerShell | 6 files | 17 tests (ci-gate suites) | ✅ 17 pass, 0 fail | 94.12% lines (Invoke-CiGateParser.ps1, old path) | 94.12% lines (Invoke-CiGateParser.ps1, new path); 96.11% lines repo-wide Pester report | 94.12% lines (relocated parser) |
| Bash | 43 files | 478 bats tests | ✅ CI shell-coverage job success; local 476 pass, 2 known local-only fail (KL-SHELL-2) | 93.3% lines (kcov, CI run 36494352285) | 93.3% lines (kcov, CI run 36514443218) | 86.5% to 100.0% lines per changed script |
| JSON | 1 files | 2 manifest-membership tests + 5 repo guard tests | ✅ validation | N/A (config files) | N/A (config files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/evidence/baseline/powershell-test-coverage.2026-09-28T21-52.md` (LinePercent 94.12)
- PowerShell post-change coverage artifact: `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/evidence/qa-gates/powershell-test-coverage.2026-09-28T22-17.md` and CI artifact `poshqc-test-results/powershell-coverage.xml` from run 36514443218 (head 7d8234ed), inspected by this review
- Per-language comparison summary: Section 1.2.1 of this audit and `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/evidence/qa-gates/coverage-comparison.2026-09-28T22-35.md`

---

## Executive Summary

The branch relocates the ten `cleanup-merged-worktrees` bash scripts into the skill folder, relocates the CI gate parser into `.claude/lib/ci-gate/`, mirrors both into the Claude customization bundle, lists them in `core.json`, extends Shell QC discovery and kcov scope to `.claude/skills/`, and adds a pytest-run guard (`skill_bundle_contract.py` plus CLI) that fails when a skill references an unbundled script. The review covered the full feature-versus-base diff. No blocking policy findings were identified.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (mirrored by `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (mirrored by `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (via `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- ✅ Bash: shfmt + shellcheck + bats + kcov (via `.claude/rules/shell.md`)
- ✅ JSON: `core.json` parsed by the guard, Pester manifest test, and the push-down pack completeness tests

Toolchain results: Python black/ruff/pyright were re-run by this review on the seven changed Python files and passed; the four guard suites plus bundle-contract suites were re-run locally (93 passed, 1 failed; the single failure is the documented local-only issue #510 on the gitignored `.claude/state/current-session-id`, which does not occur in CI). CI run 36514443218 on head `7d8234ed` concluded `success` on all 16 jobs; head `4606f5ab` differs from `7d8234ed` only in feature-folder documentation.

Template source: the review artifacts were built from the bundled template files under `extensions/drm-copilot/resources/templates/policy_audit/`, which are the files the MCP template asset resolver serves; the MCP tool itself was not in this subagent's tool set.

**Temporary artifacts cleanup:**
- ✅ All temporary/one-time scripts created during development have been deleted (executor scratch scripts lived in the session scratchpad; `git status` is clean and no scratch file is in the diff)
- ✅ Any ongoing tooling scripts are fully tested and compliant with repo policies (`skill_bundle_contract.py` and `skill_bundle_contract_cli.py` are production tooling with 42 tests)
- Review-time scratch parsers (`lcov.py`, `jacoco.py`) were written only to the session scratchpad and are not part of the repository.

---

## Rejected Scope Narrowing

None detected. The caller prompt supplied the base branch, merge base, head SHA, feature folder, and AC source, and did not narrow scope to a plan, task, phase, file subset, or language subset. The audit covers the full branch diff.

## Evidence Location Compliance

- `git diff --name-only 42e95e27..HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (grep exit 1).
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0.
- All executor evidence lives under `docs/features/active/2026-09-28-skill-referenced-scripts-not-bundled-762/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Verdict: PASS.

## Modified-Workflow Green-Run Rule

The branch diff modifies no path under `.github/workflows/**`, `.github/actions/**`, or `scripts/benchmarks/**` (grep exit 1). The `modified-workflow-needs-green-run` rule is not triggered. A green `workflow_dispatch` run (36514443218) exists regardless.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Python guard units build inline `SkillBundleInputs` per test; repository tests read the checkout only. Pester manifest test reads `core.json` in `BeforeAll`. Bats suites use checked-in stubs and fixtures. No shared mutable state. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per test: e.g. `test_extract_reads_pwsh_file_form`, `test_evaluate_reports_not_in_skill_pack_for_pack_specific_skill`, `test_main_returns_one_for_stale_exception`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 42 guard tests in 0.57s (evidence `python-test-coverage-new`); local re-run of 94 tests in 0.56s. |
| **Determinism** - Consistent results | ✅ PASS | Pure functions with inline data; repository tests read committed files; the CI gate parser tests use an injected `-NowProvider` clock. No wall-clock, randomness, or network. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Arrange/Act/Assert comments, descriptive names, module docstrings in every new test file. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Python 93.08% lines / 85.86% branches; Pester parser 94.12% lines; bash 93.3% lines. Evidence under `evidence/baseline/` (timestamp 2026-09-28T21-52). |
| **No Coverage Regression** | ✅ PASS | Python 93.08 -> 93.11 lines, 85.86 -> 85.92 branches; parser 94.12 -> 94.12; bash 93.3 -> 93.3 with every per-file line-rate unchanged. |
| **New Code Coverage** (uniform >= 85% line, >= 75% branch) | ✅ PASS | `skill_bundle_contract.py` 136/141 lines = 96.45%, 57/60 branches = 95.00%; `skill_bundle_contract_cli.py` 53/57 lines = 92.98%, 17/22 branches = 77.27%. Measured by this review from `artifacts/python/lcov.info`. |
| **Comprehensive Coverage** | ✅ PASS | All public functions tested: `parse_allowed_tools` (5 tests), `extract_script_references` (12 test functions, several parametrized), `evaluate_skill_bundle` (8), `find_violations` (1 unit + repo), `find_stale_exceptions` (2 unit + repo), `load_repository_inputs` (repo tests), `main` (4). Uncovered: CLI error branches at lines 59, 96, 127, 129 and core lines 109, 225, 254-255, 263. |
| **Positive Flows** - Valid inputs | ✅ PASS | Each invocation form extracted; core-listed and pack-listed references accepted; script outside skill folder accepted when bundled; CLI returns 0 when clean. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `missing-file`, `not-in-bundle` (two cases), `not-in-skill-pack`, skill-folder file absent from packs; CLI returns 1 with violation lines. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Placeholders, globs, backticked citations, leading `./`, dedup/sort, scalar `allowed-tools`, missing frontmatter, unparseable description. |
| **Error Handling** - Error paths | ✅ PASS | Unterminated frontmatter raises `ValueError`; unknown bucket raises in the parser suite. Invalid manifest and missing-folder branches in the CLI are untested (recorded as a Minor code-review finding). |
| **Concurrency** - If applicable | ✅ PASS | Not relevant: all code is synchronous and single-threaded. |
| **State Transitions** - If applicable | ✅ PASS | Not relevant: no stateful components introduced. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.08% lines, 85.86% branches -> Post-change: 93.11% lines, 85.92% branches. Change: +0.03% lines, +0.06% branches. New/changed-code coverage: 96.45% line and 95.00% branch (skill_bundle_contract.py); 92.98% line and 77.27% branch (skill_bundle_contract_cli.py). Disposition: PASS. Evidence: `evidence/baseline/python-test-coverage.2026-09-28T21-52.md`, `evidence/qa-gates/python-test-coverage-total.2026-09-28T22-17.md`, `evidence/qa-gates/python-test-coverage-new.2026-09-28T22-17.md`, `artifacts/python/lcov.info` (parsed by this review: 93.11% line, 85.92% branch).
- PowerShell: Baseline: 94.12% lines (parser at old path, 32/34) -> Post-change: 94.12% lines (parser at new path, 32/34). Change: +0.00% lines. New/changed-code coverage: 94.12% lines. Repo-wide Pester report line coverage 96.11% (10487/10911). Disposition: PASS. Evidence: `evidence/baseline/powershell-test-coverage.2026-09-28T21-52.md`, `evidence/qa-gates/powershell-test-coverage.2026-09-28T22-17.md`, CI artifact `poshqc-test-results/powershell-coverage.xml` from run 36514443218.
- Bash: Baseline: 93.3% lines (kcov, CI run 36494352285) -> Post-change: 93.3% lines (kcov, CI run 36514443218). Change: +0.0% lines. New/changed-code coverage: 86.5% (shell_qc_lib.sh) and 87.0% to 100.0% for the ten relocated scripts. Disposition: PASS. Evidence: `evidence/baseline/shell-coverage-ci.2026-09-28T21-52.md`, `evidence/qa-gates/shell-coverage-files.2026-09-28T22-35.md`, CI artifact `shell-coverage/cov.xml` from run 36514443218 (parsed by this review).

Coverage verdicts by changed language:

- Python coverage verdict: PASS (repo-wide lcov 93.11% line >= 85%, 85.92% branch >= 75%; both new modules above both floors; no regression).
- PowerShell coverage verdict: PASS (parser 94.12% line >= 85%, no regression; Pester reports line coverage only, so the branch threshold does not apply to PowerShell per `.claude/rules/powershell.md`).
- Bash coverage verdict: PASS (kcov 93.3% line >= 85%, every changed script >= 85%, no per-file regression; kcov is line-only).

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Repository guard renders `<skill> \| <path> \| <reason>` lines; fail-before output recorded in `evidence/regression-testing/guard-before-fix.2026-09-28T22-02.md`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Explicit `# Arrange`, `# Act`, `# Assert` comments in Python tests; Pester tests annotate the phases. |
| **Document Intent** | ✅ PASS | Docstring per test function; Pester `.SYNOPSIS`/`.DESCRIPTION` header in `CiGate.Manifest.Tests.ps1`. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network, database, or subprocess in new tests. Repository tests read committed files. |
| **Use Mocks/Stubs** | ✅ PASS | CLI tests inject a `loader` callable returning inline inputs; bats suites use the checked-in git and scan stubs. |
| **Environment Stability** | ✅ PASS | Grep over the new test files for `tmp_path`, `tempfile`, `mkdtemp`, `TestDrive`, `mktemp`, `BATS_TEST_TMPDIR` returned no matches. No temporary files. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the feature-review policy audit for issue #762. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md` and `spec.md` (issue #762) define the rule and scope; follow-ups #763 and #764 split out. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-09-28T21-52.md`. |
| **Document the plan** | ✅ PASS | `plan.2026-09-28T19-03.md`, `plan.2026-09-28T23-50.md`, research `research/2026-09-28T19-15-skill-bundle-audit-research.md`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Relocation is `git mv` plus path-string edits; the guard is a set of pure functions plus one thin I/O module. |
| **Reusability** | ✅ PASS | The parser is shared by `orchestrate` and `epic-orchestrate` from one bundled location. |
| **Extensibility** | ✅ PASS | Invocation forms are a tuple of patterns; exceptions are a typed registry; `find_violations` takes keyword-only `exceptions`. |
| **Separation of concerns** | ✅ PASS | `skill_bundle_contract.py` performs no I/O; `skill_bundle_contract_cli.py` is the boundary; `main` accepts an injectable `loader`. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Pure evaluation vs. I/O boundary split; tests split across four files by concern. |
| **Under 500 lines** | ✅ PASS | Largest changed files: `cleanup_worktrees_lib.sh` 496, `skill_bundle_contract.py` 495, `cleanup_worktrees_dirt_lib.sh` 495, `cleanup_worktrees_preserve_lib.sh` 492, `test_cleanup_worktrees_preserve.bats` 471. All at or under 500. |
| **Public vs internal** | ✅ PASS | Helpers are `_prefixed`; public surface is the six functions named in the spec plus the dataclasses. |
| **No circular dependencies** | ✅ PASS | CLI imports core; core imports only `re`, `dataclasses`, `typing`, `yaml`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `evaluate_skill_bundle`, `find_stale_exceptions`, `KnownUnbundledReference`, `PUBLISHED_ROOT_FOLDERS`. |
| **Docs/docstrings** | ✅ PASS | Module, class, and function docstrings with Args/Returns/Raises in both new modules. |
| **Comment why, not what** | ✅ PASS | Loop and branch intent comments present (e.g. "Bundle membership is decided first: a path outside the published roots can never be carried"). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check <7 changed Python files>`<br>**Result:** 7 files would be left unchanged (re-run by this review). Shell: `shell-qc format` left the tree unchanged (`evidence/qa-gates/shell-format...`). PowerShell: PoshQC format produced no hash change (`evidence/qa-gates/powershell-format...`). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check --no-fix <7 files>`<br>**Result:** All checks passed (re-run). Shell: `shell-qc check` exit 0. PSScriptAnalyzer: 0 findings on the four PowerShell files. |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright <7 files>`<br>**Result:** 0 errors, 0 warnings (re-run). PowerShell has no type-check stage. |
| **4. Testing** | ✅ PASS | **Command:** `poetry run pytest -q <guard + bundle contract suites>`<br>**Result:** 93 passed, 1 local-only failure (#510, gitignored state file). CI run 36514443218: all 16 jobs success. |
| **Full toolchain loop** | ✅ PASS | Executor recorded loop restarts (Python format, file-size split, digest re-baseline) and a final clean pass (`evidence/qa-gates/python-test-coverage-total...`). |
| **Explicit reporting** | ✅ PASS | Commands and exit codes recorded in each evidence file and in Appendix B. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit messages and Section 9. |
| **Design choices explained** | ✅ PASS | Spec "Proposed Fix" and research artifact explain the bundle definition and the relocation choice. |
| **Update supporting documents** | ✅ PASS | `.claude/rules/shell.md` discovery contract, three `SKILL.md` files, and their bundle mirrors updated. |
| **Provide next steps** | ✅ PASS | Follow-ups #763 (Python CLI ports) and #764 (validator citation and root-folder divergence). |

---

## 3. Language-Specific Code Change Policy Compliance

---

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check`<br>**Result:** 7 files unchanged |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check --no-fix`<br>**Result:** All checks passed |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** 0 errors, 0 warnings |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest`<br>**Result:** 42/42 guard tests pass; CI suite 5340 passed, 6 skipped |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations; no `Any`; `cast` used to narrow YAML/JSON `object` values. No `# type: ignore` or `# noqa`. |
| **Dataclasses for value objects** | ✅ PASS | `SkillBundleViolation`, `KnownUnbundledReference`, `SkillBundleInputs` are frozen dataclasses. |
| **Protocols/ABCs for interfaces** | ✅ PASS | Not required: one implementation; seam is the injectable `loader` callable. |
| **Avoid utility classes** | ✅ PASS | Module-level functions; no static-only classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `ValueError` for malformed frontmatter/manifest and unknown reason; `FileNotFoundError` for absent folders; YAML error re-raised with `from`. |
| **Logging over print** | ✅ PASS | CLI writes report lines to stderr as its documented output contract; no `print`. |
| **Invariants at construction** | ✅ PASS | `SkillBundleViolation.__post_init__` rejects undocumented reasons. |

---

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_format` on `.claude/lib/ci-gate`, `tests/scripts/claude-lib/ci-gate`, `scripts/powershell/PoshQC/settings`<br>**Result:** no file hash changed (`evidence/qa-gates/powershell-format.2026-09-28T22-17.md`) |
| **Linting with PSScriptAnalyzer** | ✅ PASS | **Command:** `mcp__drm-copilot__run_poshqc_analyze`<br>**Result:** 0 findings (`evidence/qa-gates/powershell-analyze.2026-09-28T22-17.md`) |
| **Fix all findings** | ✅ PASS | No findings. |
| **PowerShell 7+ compatible** | ✅ PASS | CI `poshqc / PowerShell QC` job success on run 36514443218. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | Parser content unchanged apart from its `.EXAMPLE` help path (R099 rename). |
| **Parameter validation** | ✅ PASS | Unchanged from base. |
| **Avoid global state** | ✅ PASS | New manifest test uses `$script:` variables set once in `BeforeAll`. |
| **Error handling** | ✅ PASS | Unchanged parser fail-fast on unknown bucket values. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | Parser 330 lines; manifest test 39 lines. |
| **Approved verbs** | ✅ PASS | `Invoke-CiGateParser` (unchanged). |
| **Comment why** | ✅ PASS | `pester.runsettings.psd1` entry carries a comment explaining the per-file allow-list rationale. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | ✅ PASS | No type-check stage exists for this language; skipped per policy. |
| **Step 4: Test** | ✅ PASS | 17/17 Pester tests pass (15 parser + 2 manifest). |
| **Rerun loop if needed** | ✅ PASS | Single pass after the relocation. |

---

### Section 3C: Bash Script Policy Compliance

#### 3C.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with shfmt** | ✅ PASS | **Command:** `shell-qc format`<br>**Result:** tree unchanged (`evidence/qa-gates/shell-format.2026-09-28T22-17.md`) |
| **Linting with shellcheck** | ✅ PASS | **Command:** `shell-qc check`<br>**Result:** exit 0 (`evidence/qa-gates/shell-lint.2026-09-28T22-17.md`) |
| **Testing with bats** | ✅ PASS | **Command:** `shell-qc test`<br>**Result:** 478 planned; CI shell-coverage job success. Locally two KL-SHELL-2 negative-control tests (TAP 282, 304) fail identically at baseline and are WSL-only. |

#### 3C.2 Bash Script Design

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Portable shebang** | ✅ PASS | Relocated files are renames with shebangs unchanged. |
| **Error handling** | ✅ PASS | Content unchanged except `# shellcheck source=` directives and path comments; library resolution uses `$SCRIPT_DIR` / library-relative paths, so relocation does not change behavior. |
| **Under 500 lines** | ✅ PASS | Maximum 496 (`cleanup_worktrees_lib.sh`). |

---

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting** | ✅ PASS | `core.json` addition follows the existing two-space array style; parsed by `ConvertFrom-Json` and `json.loads` in tests. |
| **Schema validation** | ✅ PASS | `test_push_down_claude_pack_manifest_completeness.py` and the guard's `_load_pack_paths` validate the `paths` list shape; both pass. |
| **Required $schema** | ✅ PASS | Unchanged manifest header. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | No comments or trailing commas added. |
| **Deterministic key order** | ✅ PASS | No keys added; only array entries. |

---

## 4. Language-Specific Unit Test Policy Compliance

---

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Plain pytest functions; `pytest.mark.parametrize` for invocation verbs and operators; `capsys` for stderr. |
| **Coverage expectation** | ✅ PASS | New modules 96.45% / 92.98% line and 95.00% / 77.27% branch; lcov total 93.11% line, 85.92% branch. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | One behavior per test function. |
| **Mocking sparingly** | ✅ PASS | Only the CLI `loader` seam is substituted. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | e.g. `test_evaluate_accepts_script_outside_skill_folder_when_bundled`. |
| **Docstrings/comments** | ✅ PASS | Docstring per test; AAA comments. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest`<br>**Result:** see Section 6 |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

---

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `BeforeAll`, `Describe`/`It`, `Should -Contain`, `Should -Be`. |
| **Use PoshQC Configuration** | ✅ PASS | **Config:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` gains `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` in the coverage allow-list, keeping the relocated file in the denominator; the bundled PoshQC copy is byte-identical. |
| **PowerShell 7+ Compatible** | ✅ PASS | CI poshqc job success. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | Manifest suite: membership and uniqueness in two `It` blocks. |
| **Test Behavior Over Implementation** | ✅ PASS | Asserts the published manifest contract. |
| **Mocking Used Sparingly** | ✅ PASS | No mocks in the new suite. |
| **Organization** | ✅ PASS | **Test file:** `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`<br>**Code file:** `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`<br>Mirrors the `claude-lib` convention used by other `.claude/lib` suites. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | `CiGate.Manifest.Tests.ps1`, `Invoke-CiGateParser.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | 1 Describe, 2 It (manifest); parser suite unchanged. |
| **Logical Grouping** | ✅ PASS | Manifest tests grouped under one Describe. |
| **Docstrings/Comments** | ✅ PASS | Comment-based help header. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | **Result:** 17 passed, 0 failed (`evidence/qa-gates/powershell-test-coverage.2026-09-28T22-17.md`); CI poshqc success |
| **No Alternative Test Runners** | ✅ PASS | Pester only. |

---

## 5. Test Coverage Detail

### skill_bundle_contract.py (38 tests across unit and repository suites)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_parse_allowed_tools_*` (5) | Positive/Edge Case/Error Handling | 174-263 | ✅ |
| `test_extract_*` (13) | Positive/Edge Case | 266-339 | ✅ |
| `test_evaluate_*` (8) | Positive/Negative | 342-424 | ✅ |
| `test_find_violations_suppresses_known_exceptions`, `test_find_stale_exceptions_*` (3), `test_known_unbundled_references_cite_issue_763` | Positive/Negative | 427-495 | ✅ |

**Coverage:** 96.45% lines (136/141), 95.00% branches (57/60)

**Not covered:** line 109 (unknown-reason `ValueError` raise), 225 (continuation break path), 254-255 (YAML error re-raise), 263 (non-list, non-string `allowed-tools` value).

---

### skill_bundle_contract_cli.py (4 CLI tests + 5 repository tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| `test_main_returns_zero_when_clean` | Positive | 168-215 | ✅ |
| `test_main_returns_one_and_prints_violation_lines` | Negative | 168-215 | ✅ |
| `test_main_returns_one_for_stale_exception` | Negative | 168-215 | ✅ |
| `test_main_prints_nothing_to_stderr_when_clean` | Positive | 168-215 | ✅ |
| Repository tests via `load_repository_inputs` | Positive | 44-165 | ✅ |

**Coverage:** 92.98% lines (53/57), 77.27% branches (17/22)

**Not covered:** line 59 (missing folder in `_files_under`), 96 (invalid manifest `ValueError`), 127 and 129 (`FileNotFoundError` for absent skills/manifest folders), partial branch 138->140.

---

### Invoke-CiGateParser.ps1 (15 parser tests + 2 manifest tests)

**Coverage:** 94.12% lines (32/34), unchanged from baseline.

---

### Relocated cleanup-worktrees scripts and shell_qc_lib.sh (478 bats tests total)

**Coverage:** per-file kcov line-rates 0.976, 0.953, 1.000, 0.942, 0.924, 0.954, 0.870, 0.906, 0.890, 0.875; `shell_qc_lib.sh` 0.865. All identical to baseline.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (guard, local) | 42 | ✅ |
| Tests Passed (guard, local) | 42 (100%) | ✅ |
| Tests Failed (guard, local) | 0 | ✅ |
| CI Python suite (3.12) | 5340 passed, 6 skipped | ✅ |
| Pester ci-gate suites | 17 passed, 0 failed | ✅ |
| Bats (CI shell-coverage job) | success | ✅ |
| Execution Time (guard) | 0.57s | ✅ Fast |
| Functions Tested (new Python public API) | 6/6 (100%) | ✅ |
| Largest new test file | 282 lines | ✅ Maintainable |
| Code Coverage (new Python) | 94% combined lines, 90% combined branches | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <7 files>` | 7 unchanged | ✅ |
| Ruff Linting | `poetry run ruff check --no-fix <7 files>` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright <7 files>` | 0 errors | ✅ |
| Pytest Tests | `poetry run pytest -q <7 suites>` | 93 passed, 1 local-only (#510) | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `mcp__drm-copilot__run_poshqc_format` | no changes | ✅ |
| PSScriptAnalyzer | `mcp__drm-copilot__run_poshqc_analyze` | 0 findings | ✅ |
| Pester Tests | Pester with coverage via PoshQC settings | 17/17 | ✅ |

**For Bash:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| shfmt | `shell-qc format` | no changes | ✅ |
| shellcheck | `shell-qc check` | exit 0 | ✅ |
| bats + kcov | CI `shell-coverage` job | success, 93.3% lines | ✅ |

**Notes:**
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails locally on the gitignored `.claude/state/current-session-id`. This is pre-existing issue #510, unrelated to this branch, and does not occur in CI.
- KL-SHELL-2 (bats TAP 282 and 304) fail only under local WSL and fail identically at baseline.
- `quality-tiers.yml` is absent from the repository root at both base and head; this is a pre-existing condition not introduced by the branch.

---

## 8. Gaps and Exceptions

### Identified Gaps
- The canonical local PowerShell coverage path `artifacts/pester/powershell-coverage.xml` is absent in the worktree. The equivalent file published by CI run 36514443218 (head `7d8234ed`, code-identical to `4606f5ab`) was downloaded and parsed by this review (parser 94.12%, report total 96.11%). Recorded as Info; no coverage verdict depends on an unread artifact.
- CLI error branches (missing folder, invalid manifest) are untested; branch coverage of `skill_bundle_contract_cli.py` is 77.27%, above the 75% floor. Recorded as a Minor code-review finding.

### Approved Exceptions
- `KNOWN_UNBUNDLED_REFERENCES` registers two Python CLI references (`parallel-orchestrate`, `parallel-remove`) tracked by #763, as specified by spec AC7; a staleness test guards the registry.

### Removed/Skipped Tests
**None.** All planned tests implemented. One existing pinned digest (`.claude/skills/epic-orchestrate/SKILL.md` in `parallel_orchestrator_surface_expectations.py`) was re-baselined with an issue #762 comment, following the file's documented precedent.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **7e881b20** - docs(762): promote skill bundle audit, research, spec, plan, baselines, and follow-ups 763 and 764
2. **0c770946** - test(762): add skill bundle guard and fail-before regression tests
3. **4e0c1275** - fix(762): bundle cleanup-worktrees scripts with the cleanup-merged-worktrees skill
4. **1c501f1f** - fix(762): relocate the CI gate parser into the bundled .claude/lib tree
5. **08a3ec44** - fix(762): mirror relocated scripts into the Claude bundle and core manifest
6. **e0c5bb55** - fix(762): discover and cover bash scripts bundled under .claude/skills
7. **f7603cd7** - docs(762): record final QA evidence
8. **7d8234ed** - docs(762): check off acceptance criteria
9. **4606f5ab** - docs(762): check off acceptance criteria

### Files Modified

1. **`.claude/skills/cleanup-merged-worktrees/scripts/*.sh`** (RENAMED x10) - relocated from `scripts/bash/`; only `source=` directives and path comments changed.
2. **`.claude/lib/ci-gate/Invoke-CiGateParser.ps1`** (RENAMED) - relocated from `scripts/orchestration/`; `.EXAMPLE` path updated.
3. **`scripts/dev_tools/skill_bundle_contract.py`**, **`skill_bundle_contract_cli.py`** (NEW) - guard logic and I/O boundary.
4. **`scripts/bash/shell_qc_lib.sh`** (MODIFIED) - `.claude/skills` added to discovery roots and kcov include pattern.
5. **`pack-manifests/core.json`** (MODIFIED) - 11 new paths.
6. **Three `SKILL.md` files and `.claude/rules/shell.md`** (MODIFIED) plus byte-identical bundle mirrors.
7. **`pester.runsettings.psd1`** (MODIFIED, both copies) - relocated parser added to coverage allow-list.
8. **Tests** - four new Python suites, one new Pester suite, one moved Pester suite, 21 bats suites updated, one bats fixture added, one digest re-baselined.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All toolchain stages pass for Python, PowerShell, and bash; coverage for every changed language is at or above the uniform thresholds with no regression; files are within the 500-line limit; no suppressions were added; evidence is in canonical locations.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan present
- ✅ Design Principles: pure/I-O split, shared bundled parser
- ✅ Module & File Structure: all files <= 500 lines
- ✅ Naming, Docs, Comments: complete docstrings and intent comments
- ✅ Toolchain Execution: clean, re-verified by review for Python
- ✅ Summarize & Document: follow-ups #763 and #764 filed

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: black, ruff, pyright clean
- ✅ Python Design & Typing: frozen dataclasses, full typing
- ✅ Error Handling: specific exceptions

**For PowerShell:**
- ✅ Tooling & Baseline: format and analyze clean
- ✅ PowerShell Design & Safety: parser logic unchanged
- ✅ Structure & Naming: within limits
- ✅ Toolchain: 17/17 Pester

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: met
- ✅ Coverage & Scenarios: thresholds met, no regression
- ✅ Test Structure: AAA and docstrings
- ✅ External Dependencies: none; no temporary files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope: pytest
- ✅ Test Style & Structure: focused
- ✅ Naming & Readability: descriptive
- ✅ Toolchain: pass

**For PowerShell:**
- ✅ Framework & Scope: Pester 5
- ✅ Test Style & Structure: focused
- ✅ Naming & Readability: `*.Tests.ps1`
- ✅ Toolchain: pass

---

### Metrics Summary

- ✅ 42/42 guard tests passing (100%); CI 5340 passed
- ✅ 17/17 Pester tests passing
- ✅ 6/6 new public Python functions tested
- ✅ Python lcov 93.11% line, 85.92% branch; new modules 96.45% and 92.98% line
- ✅ Bash kcov 93.3% line; parser Pester 94.12% line
- ✅ All code quality checks passing
- ✅ Guard execution time 0.57 seconds (fast)

---

### Recommendation

**Ready for merge**

No blocking findings. Non-blocking recommendations are listed in `code-review.2026-09-28T23-11.md`.

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/dev_tools/test_skill_bundle_contract.py`: `test_parse_allowed_tools_returns_list_entries`, `test_parse_allowed_tools_returns_empty_without_frontmatter`, `test_parse_allowed_tools_raises_on_unterminated_frontmatter`, `test_parse_allowed_tools_ignores_unparseable_description`, `test_parse_allowed_tools_splits_scalar_string_value`, `test_extract_reads_bash_allowed_tools_pattern`, `test_extract_reads_bash_sh_and_source_forms[*]`, `test_extract_reads_pwsh_file_form`, `test_extract_reads_call_operator_and_dot_source_forms[*]`, `test_extract_reads_import_module_path_form`, `test_extract_reads_import_module_join_path_form`, `test_extract_reads_python_path_form`, `test_extract_resolves_python_module_form`, `test_extract_normalizes_leading_dot_slash`, `test_extract_ignores_placeholder_paths`, `test_extract_ignores_glob_paths`, `test_extract_ignores_backticked_citation_without_invocation`, `test_extract_deduplicates_and_sorts_references`
- `tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py`: `test_evaluate_reports_missing_file`, `test_evaluate_reports_not_in_bundle_for_unpublished_root`, `test_evaluate_reports_not_in_bundle_when_bundle_lacks_file`, `test_evaluate_reports_not_in_skill_pack_for_pack_specific_skill`, `test_evaluate_accepts_reference_listed_in_core`, `test_evaluate_accepts_reference_listed_in_every_skill_pack`, `test_evaluate_accepts_script_outside_skill_folder_when_bundled`, `test_evaluate_reports_skill_folder_file_missing_from_packs`, `test_find_violations_suppresses_known_exceptions`, `test_find_stale_exceptions_reports_unmatched_exception`, `test_find_stale_exceptions_returns_empty_when_all_match`, `test_known_unbundled_references_cite_issue_763`
- `tests/scripts/dev_tools/test_skill_bundle_contract_cli.py`: `test_main_returns_zero_when_clean`, `test_main_returns_one_and_prints_violation_lines`, `test_main_returns_one_for_stale_exception`, `test_main_prints_nothing_to_stderr_when_clean`
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`: `test_every_skill_script_reference_is_bundled`, `test_ci_gate_parser_skills_invoke_bundled_parser`, `test_every_skill_folder_file_is_carried_by_skill_packs`, `test_known_unbundled_references_are_not_stale`, `test_published_root_folders_match_typescript_root_folders`
- `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`: CiGate core.json manifest membership > lists the CI gate parser path in core.json paths; lists the CI gate parser path exactly once
- `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`: 15 existing parser tests (moved)
- `tests/shell/test_shell_qc_discovery.bats`: new case `discover_shell_scripts finds a .sh file under the .claude/skills root`; updated sort/dedup case
- `tests/shell/test_shell_qc_commands.bats`: updated shellcheck-call count and kcov include-pattern assertion
- 19 `tests/shell/test_cleanup_worktrees_*.bats` suites: path updates only

---

## Appendix B: Toolchain Commands Reference

Commands re-run by this review (check-only):

```bash
git -C <repo> diff --stat 42e95e275953d3235eeab7ed5cebf26c7b019f51..HEAD
git -C <repo> diff --name-status -M 42e95e275953d3235eeab7ed5cebf26c7b019f51..HEAD
git -C <repo> range-diff 42e95e27..HEAD 5d0b93a0..670577f2
poetry run black --check <7 changed Python files>
poetry run ruff check --no-fix <7 changed Python files>
poetry run pyright <7 changed Python files>
poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run python -m scripts.dev_tools.skill_bundle_contract_cli   # exit 0
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .   # exit 0
git grep -n -E "scripts/bash/cleanup[-_]worktrees|scripts/orchestration/Invoke-CiGateParser|tests/scripts/orchestration/Invoke-CiGateParser" -- . ':(exclude)docs/features'
cmp -s <.claude file> <bundle mirror file>   # 15 files and pester.runsettings.psd1: identical
gh run list --repo drmoisan/drm-copilot --branch fix/skill-bundled-scripts
gh run view 36514443218 --json headSha,conclusion,jobs
gh run download 36514443218 -n poshqc-test-results ; gh run download 36514443218 -n shell-coverage
```

Executor commands (recorded in feature evidence):

```powershell
mcp__drm-copilot__run_poshqc_format ; mcp__drm-copilot__run_poshqc_analyze
Pester with coverage: -TestPath tests/scripts/claude-lib/ci-gate -CoveragePath .claude/lib/ci-gate/Invoke-CiGateParser.ps1
```

```bash
bash scripts/bash/shell-qc.sh format ; bash scripts/bash/shell-qc.sh check ; bash scripts/bash/shell-qc.sh test
poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-09-28
**Policy Version:** Current (as of audit date)
