# Policy Compliance Audit: legacy-discovery-init-templates (#362) — R4 Re-Audit, Remediation Cycle 1

**Audit Date:** 2026-07-18
**Audit Type:** Post-remediation re-audit (R4 of the R1–R5 remediation loop, cycle 1). Supersedes `policy-audit.2026-07-18T13-00.md` (initial review, 4 Blocking findings). Note on timestamps: session clocks in this feature folder are not mutually consistent (evidence exists at `T12-18`, `T13-00`, and `T15-31` for work performed in that order); this artifact's `T12-56` reflects the reviewing session's wall clock and is the newest review artifact regardless of lexical sort.
**Branch:** `feature/legacy-discovery-init-templates-362` (HEAD `7610bf2539f62bba5e4489f559ed486fb368043a`)
**Base:** `epic/legacy-discovery-and-parity-integration`
**Merge-base:** `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`
**Audit scope:** full branch diff `git diff f18c1c16..7610bf25` — 51 files changed (+1800/−95): 4 production Python modules (`scripts/dev_tools/discovery/{__init__,init_cli,init_flow,init_models}.py`), 5 test modules, 8 template files under `docs/discovery/templates/`, `.gitignore`, `pyproject.toml`, and feature-folder docs/evidence. Includes both commits `48d16f6f` (feature) and `7610bf25` (remediation).
**Code Under Test:** `scripts/dev_tools/discovery/__init__.py` (modified), `scripts/dev_tools/discovery/init_cli.py` (new), `scripts/dev_tools/discovery/init_flow.py` (new), `scripts/dev_tools/discovery/init_models.py` (new), `docs/discovery/templates/domain-profile/domain-profile.yaml` (new), `docs/discovery/templates/artifacts/*.template.json` (7 new), `.gitignore` (modified), `pyproject.toml` (modified), tests under `tests/scripts/dev_tools/discovery/` (5 files).
**Template source note:** The MCP template-asset resolver is not available to this subagent session; the repository canonical template `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (the same content the MCP asset bundles) was used as the authoritative structure source.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 6 files | 1708 tests | ✅ 1708 pass, 0 fail, 0 skipped | 88.16% lines, 78.90% branches | 88.17% lines, 78.90% branches | 100% lines |

TypeScript, PowerShell, C#, Bash, and GitHub Actions workflows have zero changed files on this branch (verified via `git diff --name-status f18c1c16..HEAD`); per policy those languages require no coverage or toolchain verdict on this diff. JSON template files are data (validated via `dev.validate-json`, exit 0), not executable code.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - out of scope (zero changed TypeScript files on this branch)
- TypeScript post-change coverage artifact: N/A - out of scope (zero changed TypeScript files on this branch)
- PowerShell baseline coverage artifact: N/A - out of scope (zero changed PowerShell files on this branch)
- PowerShell post-change coverage artifact: N/A - out of scope (zero changed PowerShell files on this branch)
- Per-language comparison summary: see section 1.2.1 below; Python lcov at `artifacts/python/lcov.info`, delta record at `evidence/qa-gates/r1c1-coverage-delta.2026-07-18T12-18.md`

---

## Rejected Scope Narrowing

None. The delegating prompt explicitly instructed the opposite of narrowing: "review the full diff against the merge-base, not just the remediation delta" and "no scope narrowing." The full feature-vs-base diff (`f18c1c16..7610bf25`) was audited.

---

## Executive Summary

This is the independent re-audit of the remediated branch. All four Blocking findings from the initial review (`policy-audit.2026-07-18T13-00.md`, `remediation-inputs.2026-07-18T13-00.md`) were re-verified independently — not accepted from the executor's self-report — and all four are resolved:

- **R1 (templates not committed): RESOLVED.** `git ls-tree -r HEAD --name-only | grep docs/discovery` returns all 8 template files. `.gitignore:6` is now root-anchored (`/artifacts`); `git check-ignore -v docs/discovery/templates/artifacts/feature-contract.template.json` exits 1 (not ignored). A fresh detached checkout (`git -c core.longpaths=true worktree add --detach <tmp> 7610bf25`) contains all 8 files under `docs/discovery/templates/`.
- **R2 (domain-profile template does not parse): RESOLVED.** The template is now the nested #360 shape (`profile_version`, `legacy_source.root`, `target.root`, `technology_stack.legacy[]`, `artifacts.root`). Reviewer ran the real `parse_domain_profile_text` against both the raw template text and the rendered scaffold output; both parse with `profile_version == 1` and no `DomainProfileError`.
- **R3 (artifact templates fail schema validation): RESOLVED.** Reviewer scaffolded a workspace through the real `create_discovery_workspace` against an in-memory `FileSystem` and ran `jsonschema.validate` on each of the seven rendered artifact instances against its real schema under `schemas/discovery/v1/`; all seven validate. Each template's `"$schema"` (`../../../../schemas/discovery/v1/<name>.schema.json`) resolves to an existing schema file per `validate_json.py`'s no-scheme `_load_schema` rule (`base_path.parent / uri`), and `poetry run dev.validate-json` exits 0. The previously skipped `test_schema_conformance_pending_issue_9002` was replaced by the implemented, passing `test_generated_artifacts_conform_to_real_schemas`.
- **R4 (public re-export surface removed): RESOLVED.** `poetry run python -c "from scripts.dev_tools.discovery import DomainProfile, DomainProfileError, load_domain_profile, parse_domain_profile_text, DEFAULT_PROFILE_FILENAME"` succeeds. `__init__.py` restores the full #360 re-export block plus `__all__`, and the new regression suite `tests/scripts/dev_tools/discovery/test_package_exports.py` guards it.

The full Python toolchain was independently re-run at HEAD and is clean in a single pass: Black, Ruff, Pyright, and Pytest (1708 passed, 0 failed, 0 skipped) all exit 0. Repo-wide coverage is 88.17% lines / 78.90% branches, above the uniform gates (>= 85% / >= 75%) with no regression versus baseline.

**One Minor, non-blocking gap** was identified that the initial review missed: seven `# noqa: ARG001` suppressions in test code (`test_init_models.py`, `test_init_cli.py:79`) do not exactly match a pre-authorized pattern in `.claude/rules/python-suppressions.md` (which authorizes `ARG002` for test mocks with a required reason comment, not bare `ARG001`). The fact pattern is the authorized one (test stubs matching a known interface signature), so this is classified Minor, not Blocking. See section 8.

**Policy documents evaluated:**
- ✅ `general-code-change.instructions.md` (via `.claude/rules/general-code-change.md`)
- ✅ `general-unit-test.instructions.md` (via `.claude/rules/general-unit-test.md`)

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (via `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`)
- N/A `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (zero changed files)
- N/A Bash (zero changed files)
- ✅ JSON: `dev.validate-json` exit 0 (templates fall under the `docs/**/*.json` governed glob)

**Temporary artifacts cleanup:**
- ✅ Reviewer verification scripts and scaffold outputs were confined to the session scratchpad and the detached verification worktree, both outside the repository tree; the detached worktree was removed after verification.
- ✅ No temporary or one-time scripts from the executor remain in the branch diff.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | All 5 test modules use function-local `FakeFileSystem` instances, `monkeypatch`, or pure reads of committed in-repo files; no shared mutable state between tests. Full suite passes as a whole and the discovery subset passes in isolation (`poetry run pytest tests/scripts/dev_tools/discovery/ -v`, 84 passed). |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per test: e.g. `test_target_parent_missing_raises`, `test_partial_template_set_raises`, `test_package_all_exposes_the_expected_public_surface`. CLI tests stub `create_discovery_workspace` so they exercise only wiring. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Discovery subset: 84 tests in 0.24s. Full suite: 1708 tests in 8.80s. |
| **Determinism** - Consistent results | ✅ PASS | No wall-clock, RNG, network, or environment reads in any new test; inputs are in-memory dicts and committed repo files. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names plus one-line docstrings on every test; AAA structure throughout. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | **Baseline (pre-remediation):** 88.16% lines (9951/11287), 78.90% branches (3350/4246)<br>**Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`<br>**Timestamp:** 2026-07-18T12-18 (`evidence/remediation-baseline/r1c1-phase0-pytest-baseline.2026-07-18T12-18.md`) |
| **No Coverage Regression** | ✅ PASS | **Post-change coverage:** 88.17% lines (9954/11290), 78.90% branches (3350/4246)<br>**Change:** +0.01% lines, +0.00% branches<br>**Status:** No regression. Reviewer re-ran the command at HEAD and reproduced these exact totals from `artifacts/python/lcov.info`. |
| **New Code Coverage ≥90%** | ✅ PASS | **New/modified files:** `init_cli.py` 20/20 lines (100%), `init_flow.py` 36/36 lines (100%) and 22/22 branches (100%), `init_models.py` 32/32 lines (100%), `__init__.py` 3/3 lines (100%)<br>**Calculation method:** per-file `LH/LF` and `BRH/BRF` records parsed from `artifacts/python/lcov.info` after the reviewer's own pytest run at HEAD. |
| **Comprehensive Coverage** | ✅ PASS | All new functions tested: `parse_args`, `main` (7 tests), `validate_template_set`, `validate_target_path`, `substitute_placeholders`, `create_discovery_workspace` (11 tests), `RealFileSystem` + path constants + `resolve_default_template_root` (3 tests), package exports (2 tests), domain neutrality (2 tests). Untested: none (the 6 unhit branch records in `init_models.py` are phantom `return from function` branches on `typing.Protocol` ellipsis stubs; see 1.2.1). |
| **Positive Flows** - Valid inputs | ✅ PASS | `test_create_discovery_workspace_success_full_layout`, `test_create_discovery_workspace_template_root_override`, `test_target_non_empty_with_force_succeeds`, `test_main_success_path_invokes_create_discovery_workspace`, `test_main_honors_template_root_override`, `test_domain_profile_template_parses_with_real_loader`, `test_generated_artifacts_conform_to_real_schemas`. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `test_target_path_not_a_directory_raises`, `test_target_parent_missing_raises`, `test_target_non_empty_without_force_raises`, `test_missing_template_root_raises`, `test_partial_template_set_raises`, `test_parse_args_requires_target_dir`, `test_main_exits_1_on_fail_fast_exception` (4 parametrized exception types). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Partial template set (exactly one file removed, error names it), non-empty-target vs `force=True` boundary, `tokens=None` vs populated token mapping in `substitute_placeholders`. |
| **Error Handling** - Error paths | ✅ PASS | Every fail-fast exception type (`FileExistsError`, `FileNotFoundError`, `NotADirectoryError`, `ValueError`) asserted to produce `SystemExit(1)` with the message on stderr; negative flow tests additionally assert no file was written (`set(fs.files) == pre_seeded_files`). |
| **Concurrency** - If applicable | N/A | One-shot, single-threaded scaffolding CLI; no concurrent behavior exists in scope. |
| **State Transitions** - If applicable | N/A | No stateful component; the flow is a pure validate-then-write pass over injected `FileSystem`. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 88.16% lines / 78.90% branches -> Post-change: 88.17% lines / 78.90% branches. Change: +0.01% lines, +0.00% branches. New/changed-code coverage: 100% lines across all four new/modified production files (`init_cli.py`, `init_flow.py`, `init_models.py`, `__init__.py`); `init_flow.py` also 100% branches. Disposition: PASS. Evidence: `artifacts/python/lcov.info` (reviewer re-run at HEAD) and `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r1c1-coverage-delta.2026-07-18T12-18.md`. Note: `init_models.py` reports 6/12 branch records because coverage.py emits a phantom `return from function` branch for each of the six `typing.Protocol` method stubs (`...` bodies, lines 13-23), which are structurally unexecutable; `.claude/rules/general-unit-test.md` explicitly clarifies that Protocol-only stubs with no executable behavior are a measurement artifact, and every executable line and branch in the file is covered.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Assertions carry contextual messages where non-obvious (e.g. `f"Disallowed token found in template {relative_path}"`, `f"missing re-export: {name}"`); `pytest.raises(...)` blocks additionally assert message content (`assert str(missing_relative) in str(excinfo.value)`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Consistent AAA in all 5 modules; `test_package_exports.py` labels the phases with comments. |
| **Document Intent** | ✅ PASS | Every test has a one-line docstring stating scenario and expected outcome; the schema-conformance and loader-parse tests carry multi-line docstrings explaining exactly what real contracts they pin. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No database, network, subprocess, or external-process dependency in any new test. The only filesystem access is reading committed in-repo template/schema/`pyproject.toml` files. |
| **Use Mocks/Stubs** | ✅ PASS | In-memory `FakeFileSystem` doubles for the `FileSystem` protocol; `monkeypatch.setattr` on `pathlib.Path` methods for `RealFileSystem` delegation; `create_discovery_workspace` stubbed in CLI-wiring tests. |
| **Environment Stability** | ✅ PASS | No temporary files or directories created by any test (grep for `tempfile`, `tmp_path`, `NamedTemporaryFile` over `tests/scripts/dev_tools/discovery/`: zero hits); no environment-variable or mutable-global reads. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the R4 re-audit; together with `code-review.2026-07-18T12-56.md` and `feature-audit.2026-07-18T12-56.md` it completes the required pre-PR review set for the remediated branch. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #362; `issue.md`, `spec.md` v0.2, `user-story.md` in the feature folder define the objective; the remediation cycle's objective is defined by `remediation-inputs.2026-07-18T13-00.md`. |
| **Read existing change plans** | ✅ PASS | `plan.2026-07-17T14-05.md` (original) and `remediation-plan.2026-07-18T13-00.md` (cycle 1) exist and are fully checked off in the diff. |
| **Documented plan** | ✅ PASS | Both plans committed in the feature folder; commit messages `48d16f6f` and `7610bf25` reference the feature and the remediation respectively. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Three small modules with a single responsibility each; literal `str.replace` token substitution instead of a templating engine (rejected Jinja2 documented in spec). |
| **Reusability** | ✅ PASS | Follows the established `FileSystem`-protocol scaffolding precedent (`new_active_feature_folder_models.py`); path constants shared between flow and tests via `init_models`. |
| **Extensibility** | ✅ PASS | `FileSystem` protocol permits alternate implementations; `create_discovery_workspace(..., *, force: bool = False)` uses keyword-only extension; `--template-root` override supports packaged/mirrored template sets. |
| **Separation of concerns** | ✅ PASS | `init_cli.py` (argparse/print/SystemExit only) / `init_flow.py` (pure orchestration, no argparse or print) / `init_models.py` (protocol, I/O wrapper, constants). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Package decomposition matches the spec's module plan exactly. |
| **Under 500 lines** | ✅ PASS | `__init__.py` 38, `init_cli.py` 67, `init_flow.py` 91, `init_models.py` 82, `test_init_cli.py` 129, `test_init_flow.py` 276, `test_init_models.py` 95, `test_domain_neutrality.py` 77, `test_package_exports.py` 48. All well under 500. |
| **Public vs internal** | ✅ PASS | `__init__.py` `__all__` declares the loader surface explicitly; test doubles are module-private (`_FakeFileSystem`/`FakeFileSystem` in test files only). |
| **No circular dependencies** | ✅ PASS | `init_cli` -> `init_flow` -> `init_models`; `__init__` -> `domain_profile`/`domain_profile_models`. Strictly acyclic; Pyright and pytest import cleanly. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `create_discovery_workspace`, `validate_template_set`, `EXPECTED_TEMPLATE_RELATIVE_PATHS`, `resolve_default_template_root` — snake_case functions, PascalCase types, UPPER_SNAKE constants per policy. |
| **Docs/docstrings** | ✅ PASS | Module and function docstrings on every public item in the three production modules and the package `__init__`. |
| **Comment why, not what** | ✅ PASS | Comments explain rationale (e.g. `OUTPUT_RELATIVE_PATHS[0]` non-JSON note in `test_init_flow.py`; docstring in `init_flow.py` explains the no-partial-scaffold guarantee). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** exit 0, "281 files would be left unchanged" (reviewer re-run at HEAD). |
| **2. Linting** | ✅ PASS | **Command:** `poetry run ruff check .`<br>**Result:** exit 0, "All checks passed!" (reviewer re-run at HEAD). |
| **3. Type checking** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** exit 0, 0 errors (reviewer re-run at HEAD). |
| **4. Testing** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`<br>**Result:** exit 0, 1708 passed, 0 failed, 0 skipped (reviewer re-run at HEAD). |
| **Full toolchain loop** | ✅ PASS | All four stages clean in a single reviewer pass at HEAD; matches executor evidence under `evidence/qa-gates/r1c1-*.2026-07-18T12-18.md`. Architecture-boundary, contract/schema, and integration stages: no dedicated gates configured for `scripts/dev_tools`; the contract-level check that exists (`dev.validate-json` over governed globs, which now includes the seven templates) exits 0, and the schema-conformance pytest is implemented and passing. |
| **Explicit reporting** | ✅ PASS | Commands and results recorded here (Appendix B) and in the executor's QA-gate evidence files. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 below; commit messages describe both commits. |
| **Design choices explained** | ✅ PASS | Spec documents the package decomposition, template-location choice, rejected Jinja2 alternative, and the resolved #360/#359 contract adoption. |
| **Update supporting documents** | ✅ PASS | `spec.md` and `user-story.md` were updated in the remediation commit to reflect the merged nested #360 contract and the real `schemas/discovery/v1/` location. |
| **Provide next steps** | ✅ PASS | This re-audit's recommendation: proceed to PR creation (section 10). |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | **Command:** `poetry run black --check .`<br>**Result:** exit 0, no reformatting needed. |
| **Linting with Ruff** | ✅ PASS | **Command:** `poetry run ruff check .`<br>**Result:** exit 0, no findings. |
| **Type checking with Pyright** | ✅ PASS | **Command:** `poetry run pyright`<br>**Result:** exit 0, 0 errors, 0 warnings. |
| **Testing with Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`<br>**Result:** exit 0, 1708 passed, 0 skipped. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations on all production functions; `from __future__ import annotations` + `TYPE_CHECKING` imports for type-only names; no `Any` in production code (the single `Any` in `test_init_cli.py` types a heterogeneous call-recording dict in a test stub). |
| **Dataclasses for value objects** | ✅ PASS | `RealFileSystem` is a `@dataclass`; path constants are module-level immutable tuples of `Path`. |
| **Protocols/ABCs for interfaces** | ✅ PASS | `FileSystem` is a `typing.Protocol` with six methods, mirroring the established scaffolding-tool precedent. |
| **Avoid utility classes** | ✅ PASS | Pure functions in `init_flow.py`; no static-method-only classes. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `init_flow` raises `FileNotFoundError` / `NotADirectoryError` / `FileExistsError` with specific messages; `init_cli.main` catches exactly the four expected types and re-raises as `SystemExit(1) from exc`; no bare or broad `except`. |
| **Logging over print** | ✅ PASS | Single `print(..., file=sys.stderr)` on the CLI fail-fast path, matching the documented precedent for `scripts/dev_tools` scaffolding CLIs; no logging framework required by the precedent tools. |
| **Invariants at construction** | ✅ PASS | Validation (`validate_template_set`, `validate_target_path`) executes before any write, enforcing the no-partial-scaffold invariant at operation start. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with jq** | ✅ PASS | **Command:** `poetry run dev.validate-json` (governance run)<br>**Result:** exit 0; templates conform to the governed formatting conventions. |
| **Schema validation** | ✅ PASS | **Command:** `poetry run dev.validate-json`<br>**Result:** exit 0. The seven templates fall under the `docs/**/*.json` governed glob; each `$schema` resolves through `_load_schema`'s no-scheme branch to an existing `schemas/discovery/v1/*.schema.json` file and each instance validates (independently reproduced by the reviewer with direct `jsonschema.validate` calls). |
| **Required $schema** | ✅ PASS | All seven templates carry a `$schema` property (relative, scheme-less, four-level `../../../../schemas/discovery/v1/...` paths verified to resolve from the templates' committed location). |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strict JSON only** | ✅ PASS | `json.loads` succeeds on all seven templates (no comments or trailing commas); reviewer parsed each during schema verification. |
| **Deterministic key order** | ✅ PASS | `dev.validate-json` governance run exits 0 with no ordering findings. |

Sections 3B (PowerShell) and 3C (Bash) omitted: zero changed files in those languages on this branch.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | All tests are pytest functions using `monkeypatch`, `capsys`, and `pytest.raises`; no other framework. |
| **Coverage expectation** | ✅ PASS | New production code at 100% line coverage; repo-wide 88.17% lines / 78.90% branches, above the uniform gates (>= 85% / >= 75%). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | Single behavior per test; parametrization for the four fail-fast exception types. |
| **Mocking sparingly** | ✅ PASS | Doubles only at the I/O boundary (`FileSystem` protocol, `pathlib.Path` monkeypatching) and at the CLI/flow seam. |
| **Organization** | ✅ PASS | `tests/scripts/dev_tools/discovery/` mirrors `scripts/dev_tools/discovery/` exactly; no colocated tests in the production tree. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<unit>_<scenario>` throughout, e.g. `test_target_non_empty_without_force_raises`. |
| **Docstrings/comments** | ✅ PASS | One-line docstrings on all tests; multi-line docstrings on the two contract-pinning tests. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | **Command:** `poetry run pytest --cov --cov-branch --cov-report=term-missing`<br>**Result:** 1708 passed, 0 failed, 0 skipped, exit 0. |
| **No Alternative Test Runners** | ✅ PASS | Only pytest is configured and used. |

Section 4B (PowerShell) omitted: zero changed files.

---

## 5. Test Coverage Detail

### `init_flow.py` — `create_discovery_workspace` / `validate_template_set` / `validate_target_path` / `substitute_placeholders` (11 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_substitute_placeholders_no_tokens_returns_unchanged | Positive | 58-65 | ✅ |
| test_substitute_placeholders_replaces_every_occurrence | Positive | 58-65 | ✅ |
| test_create_discovery_workspace_success_full_layout | Positive | 68-91 | ✅ |
| test_create_discovery_workspace_template_root_override | Positive | 68-91 | ✅ |
| test_target_path_not_a_directory_raises | Negative | 39-49 | ✅ |
| test_target_parent_missing_raises | Negative | 39-44 | ✅ |
| test_target_non_empty_without_force_raises | Negative | 39-55 | ✅ |
| test_target_non_empty_with_force_succeeds | Edge Case | 39-55, 68-91 | ✅ |
| test_missing_template_root_raises | Negative | 23-36 | ✅ |
| test_partial_template_set_raises | Edge Case | 23-36 | ✅ |
| test_domain_profile_template_parses_with_real_loader / test_generated_artifacts_conform_to_real_schemas | Contract | 58-91 | ✅ |

**Coverage:** 100% lines (36/36), 100% branches (22/22).
**Not covered:** None.

### `init_cli.py` — `parse_args` / `main` (7 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_parse_args_requires_target_dir | Negative | 20-46 | ✅ |
| test_parse_args_defaults_template_root_and_force | Positive | 20-46 | ✅ |
| test_parse_args_parses_template_root_and_force | Positive | 20-46 | ✅ |
| test_main_success_path_invokes_create_discovery_workspace | Positive | 49-63 | ✅ |
| test_main_honors_template_root_override | Positive | 49-63 | ✅ |
| test_main_exits_1_on_fail_fast_exception (x4) | Error Handling | 64-66 | ✅ |
| test_console_script_registered_in_pyproject | Contract | n/a (pyproject) | ✅ |

**Coverage:** 100% lines (20/20).
**Not covered:** None.

### `init_models.py` — `FileSystem` / `RealFileSystem` / path constants (3 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_real_file_system_delegates_to_pathlib | Positive | 26-47 | ✅ |
| test_expected_template_relative_paths_has_eight_entries | Contract | 50-76 | ✅ |
| test_resolve_default_template_root_returns_expected_path | Positive | 79-81 | ✅ |

**Coverage:** 100% lines (32/32). Branch records 6/12: the 6 unhit records are phantom `return from function` branches coverage.py emits on the six `typing.Protocol` ellipsis stubs (lines 13-23); they have no executable alternative path. All executable behavior covered.
**Not covered:** None (executable).

### `__init__.py` — package re-export surface (2 tests, `test_package_exports.py`)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_package_reexports_are_identical_to_submodule_objects | Contract | 14-26 | ✅ |
| test_package_all_exposes_the_expected_public_surface | Contract | 28-38 | ✅ |

**Coverage:** 100% lines (3/3).
**Not covered:** None.

### Templates — domain neutrality and contract conformance (4 tests)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_domain_neutrality_templates_contain_no_disallowed_tokens | Contract | template data | ✅ |
| test_domain_neutrality_rendered_output_contains_no_disallowed_tokens | Contract | rendered data | ✅ |
| test_domain_profile_template_parses_with_real_loader | Contract | template data | ✅ |
| test_generated_artifacts_conform_to_real_schemas | Contract | rendered data | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (repo) | 1708 | ✅ |
| Tests Passed | 1708 (100%) | ✅ |
| Tests Failed | 0 | ✅ |
| Tests Skipped | 0 (the previously skipped schema-conformance placeholder was replaced by an implemented test) | ✅ |
| Execution Time | 8.80s total (full suite); 0.24s (discovery subset, 84 tests) | ✅ Fast |
| Functions/Classes Tested | 8/8 new production functions/classes (100%) | ✅ |
| Test File Size | 129 / 276 / 95 / 77 / 48 lines | ✅ Maintainable |
| Code Coverage | 88.17% lines, 78.90% branches (repo-wide); 100% lines (new code) | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | exit 0, 281 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check .` | exit 0, all checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright` | exit 0, 0 errors | ✅ |
| Pytest Tests | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | exit 0, 1708 passed | ✅ |

**For JSON:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Governed validation | `poetry run dev.validate-json` | exit 0 | ✅ |

**Evidence-location compliance:** `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exit 0.

**Notes:**
No pre-existing failures encountered. All results independently reproduced by the reviewer at HEAD `7610bf25`; they match the executor's evidence under `evidence/qa-gates/r1c1-*.2026-07-18T12-18.md` (1708 passed, 88.17%/78.90%).

---

## Evidence Location Compliance

**PASS.** All feature evidence in the branch diff lives under the canonical `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/<kind>/` tree (`baseline/`, `qa-gates/`, `remediation-baseline/`, `regression-testing/`, `other/`). `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0. The branch diff contains no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (verified against `git diff --name-status f18c1c16..HEAD`). The `.gitignore` change (`artifacts` -> `/artifacts`) keeps the top-level orchestration `artifacts/` directory ignored while un-ignoring the nested `docs/discovery/templates/artifacts/` path; the working tree remained clean after the change (no unrelated nested `artifacts` directories became visible).

---

## 8. Gaps and Exceptions

### Identified Gaps

- **Suppression comment-format deviation (Minor, non-blocking):** seven `# noqa: ARG001` directives in test code (`tests/scripts/dev_tools/discovery/test_init_models.py` lines 20, 24, 28, 32, 35, 41; `tests/scripts/dev_tools/discovery/test_init_cli.py` line 79) suppress the unused-argument rule on stub functions that must match `pathlib.Path` / `create_discovery_workspace` signatures. `.claude/rules/python-suppressions.md` pre-authorizes this exact fact pattern under `ARG002` ("test mock/stub implementations that must match interface signatures", tests-only) with a required reason comment such as `- match [InterfaceName] API`; because these stubs are standalone monkeypatch functions rather than methods, Ruff classifies them `ARG001`, which the rule file does not list, and the comments omit the required reason suffix. Classified Minor: tests-only, matches the authorized fact pattern in substance, no effect on production behavior or coverage. Recommended fix (may be handled during PR polish; does not require another remediation cycle): amend each to `# noqa: ARG001 - match pathlib.Path API` / `- match create_discovery_workspace API`, and separately consider adding `ARG001` to the pre-authorized list (a policy-document change owned by the repository owner, not by this feature). Note: the initial review (`policy-audit.2026-07-18T13-00.md`, "Suppressions" section) reported zero suppression directives; that statement was inaccurate — these directives were present in commit `48d16f6f`. This re-audit corrects the record.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

1. **`test_schema_conformance_pending_issue_9002`** — Removed/replaced in commit `7610bf25`.
   - **Reason:** its skip premise ("no schema files exist in the repository yet") was factually wrong; the R3 remediation replaced it with the implemented `test_generated_artifacts_conform_to_real_schemas`.
   - **Impact:** none lost — the replacement asserts strictly more (real `jsonschema.validate` against all seven merged schemas).
   - **Justification:** required by remediation item R3; the suite now has 0 skipped tests.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **48d16f6f** - feat(discovery): add dev.discovery.init command and workspace templates
2. **7610bf25** - fix(discovery): resolve blocking review findings for init templates

### Files Modified

1. **scripts/dev_tools/discovery/init_cli.py** (NEW) — argparse wiring and `main()` for `dev.discovery.init`; fail-fast exceptions converted to stderr message + `SystemExit(1)`.
2. **scripts/dev_tools/discovery/init_flow.py** (NEW) — pure orchestration: validate template set and target path before any write, then scaffold 8 files via injected `FileSystem`.
3. **scripts/dev_tools/discovery/init_models.py** (NEW) — `FileSystem` protocol, `RealFileSystem`, template/output path constants, default template-root resolver.
4. **scripts/dev_tools/discovery/__init__.py** (MODIFIED) — restores the #360 public re-export surface (`DomainProfile`, `DomainProfileError`, `load_domain_profile`, `parse_domain_profile_text`, `DEFAULT_PROFILE_FILENAME`, config dataclasses) with `__all__`, plus the `dev.discovery.*` namespace docstring.
5. **docs/discovery/templates/domain-profile/domain-profile.yaml** (NEW) — starter profile in the nested #360 shape with placeholder tokens.
6. **docs/discovery/templates/artifacts/*.template.json** (7 NEW) — one template per discovery schema, each with resolvable `$schema`, `schema_version: "1.0.0"`, and all schema-required fields with placeholder values.
7. **.gitignore** (MODIFIED) — `artifacts` anchored to `/artifacts` so nested template directories are no longer silently ignored (R1 fix).
8. **pyproject.toml** (MODIFIED) — one `[tool.poetry.scripts]` line: `"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"` (alphabetically placed).
9. **tests/scripts/dev_tools/discovery/** (5 files: test_init_cli, test_init_flow, test_init_models, test_domain_neutrality NEW in 48d16f6f; test_package_exports NEW in 7610bf25; test_init_flow extended in 7610bf25) — 84 tests total in the discovery subset.
10. **docs/features/active/2026-07-17-legacy-discovery-init-templates-362/** — spec/user-story/plan updates, cycle-1 review artifacts, remediation plan/inputs, and canonical evidence files.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT (with one Minor, non-blocking gap recorded in Section 8)

All four Blocking findings from the initial review are independently verified as resolved at HEAD `7610bf25`. The full Python toolchain is clean in a single pass; repo-wide and new-code coverage exceed the uniform gates with no regression; evidence locations are canonical; the JSON governance gate passes. The single identified gap (suppression comment format in test code) is Minor and does not block PR creation.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: objective, plans, and remediation inputs documented
- ✅ Design Principles: simple, layered, protocol-based design
- ✅ Module & File Structure: all files under 500 lines, acyclic
- ✅ Naming, Docs, Comments: compliant
- ✅ Toolchain Execution: clean single pass, independently reproduced
- ✅ Summarize & Document: spec/user-story updated with resolved contracts

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: Black/Ruff/Pyright/Pytest all exit 0
- ✅ Python Design & Typing: full annotations, Protocol + dataclass
- ✅ Error Handling: specific exceptions, no broad catches

#### General Unit Test Policy (Section 1)
- ✅ Core Principles: independent, isolated, fast, deterministic, readable
- ✅ Coverage & Scenarios: gates met, no regression, scenario matrix complete
- ✅ Test Structure: AAA with clear diagnostics
- ✅ External Dependencies: in-memory doubles only, zero temp files
- ✅ Policy Audit: this document

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ⚠️ Framework & Scope / Test Style: compliant except the Minor `ARG001` suppression comment-format gap (Section 8)
- ✅ Naming & Readability: compliant
- ✅ Toolchain: pytest only, clean

### Metrics Summary

- ✅ 1708/1708 tests passing (100%), 0 skipped
- ✅ 8/8 new functions/classes tested (100%)
- ✅ 88.17% repo line coverage, 78.90% repo branch coverage; 100% new-code line coverage
- ✅ Test tree mirrors production tree
- ✅ All code-quality checks passing (Black, Ruff, Pyright, Pytest, validate-json, evidence locations)
- ✅ Test execution time: 8.80s full suite (fast)

### Recommendation

**Ready for merge** (PR creation may proceed). Remediation cycle 1 exit condition is met: 0 Blocking findings remain. The single Minor gap (suppression comment format, Section 8) may be addressed during PR polish or as a follow-up; it does not require remediation cycle 2.

---

## Appendix A: Test Inventory

- tests/scripts/dev_tools/discovery/test_init_cli.py::test_parse_args_requires_target_dir
- tests/scripts/dev_tools/discovery/test_init_cli.py::test_parse_args_defaults_template_root_and_force
- tests/scripts/dev_tools/discovery/test_init_cli.py::test_parse_args_parses_template_root_and_force
- tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_success_path_invokes_create_discovery_workspace
- tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_honors_template_root_override
- tests/scripts/dev_tools/discovery/test_init_cli.py::test_main_exits_1_on_fail_fast_exception[raised_exception0..3]
- tests/scripts/dev_tools/discovery/test_init_cli.py::test_console_script_registered_in_pyproject
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_substitute_placeholders_no_tokens_returns_unchanged
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_substitute_placeholders_replaces_every_occurrence
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_create_discovery_workspace_success_full_layout
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_create_discovery_workspace_template_root_override
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_target_path_not_a_directory_raises
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_target_parent_missing_raises
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_target_non_empty_without_force_raises
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_target_non_empty_with_force_succeeds
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_missing_template_root_raises
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_partial_template_set_raises
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_domain_profile_template_parses_with_real_loader
- tests/scripts/dev_tools/discovery/test_init_flow.py::test_generated_artifacts_conform_to_real_schemas
- tests/scripts/dev_tools/discovery/test_init_models.py::test_real_file_system_delegates_to_pathlib
- tests/scripts/dev_tools/discovery/test_init_models.py::test_expected_template_relative_paths_has_eight_entries
- tests/scripts/dev_tools/discovery/test_init_models.py::test_resolve_default_template_root_returns_expected_path
- tests/scripts/dev_tools/discovery/test_domain_neutrality.py::test_domain_neutrality_templates_contain_no_disallowed_tokens
- tests/scripts/dev_tools/discovery/test_domain_neutrality.py::test_domain_neutrality_rendered_output_contains_no_disallowed_tokens
- tests/scripts/dev_tools/discovery/test_package_exports.py::test_package_reexports_are_identical_to_submodule_objects
- tests/scripts/dev_tools/discovery/test_package_exports.py::test_package_all_exposes_the_expected_public_surface

(Pre-existing discovery-package tests from #360 — `test_domain_profile.py`, `test_profile_cli.py`, `test_domain_profile_models` coverage — continue to pass and are unchanged by this branch except as exercised through the restored `__init__.py`.)

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

**Feature-specific verification (this re-audit):**
```bash
# R1: committed presence + clean checkout
git ls-tree -r HEAD --name-only | grep docs/discovery
git check-ignore -v docs/discovery/templates/artifacts/feature-contract.template.json  # exit 1 = not ignored
git -c core.longpaths=true worktree add --detach <tmp> 7610bf25 && find <tmp>/docs/discovery -type f

# R2/R3/R4: loader parse, schema validation, re-export surface
poetry run python -c "from scripts.dev_tools.discovery import DomainProfile, DomainProfileError, load_domain_profile, parse_domain_profile_text, DEFAULT_PROFILE_FILENAME"
# plus a reviewer script driving create_discovery_workspace against an in-memory FileSystem and
# jsonschema.validate for each rendered artifact against schemas/discovery/v1/*.schema.json

# Governance and evidence locations
poetry run dev.validate-json
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .

# CLI end-to-end (scratchpad target, outside the repo)
poetry run dev.discovery.init <scratch>/ws362           # exit 0, 8 files
poetry run dev.discovery.init <scratch>/no-such-parent/ws  # exit 1, no writes
```

---

**Audit Completed By:** feature-review agent (Claude, R4 re-audit)
**Audit Date:** 2026-07-18
**Policy Version:** Current (as of audit date)
