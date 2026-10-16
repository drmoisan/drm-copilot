# Policy Compliance Audit: Issue #940 — Dependabot bumps @types/vscode past engines.vscode

**Branch:** `bug/dependabot-bumps-types-vscode-past-engines-940`
**Base:** `main`; merge-base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
**Head reviewed:** `de8ab14983bc7c8faf6b76a3ebabfa56ad8ba1ca`
**Review scope:** full branch diff `origin/main...HEAD` (28 files, +537/-0)
**Work mode:** `minor-audit` (AC source: `issue.md`, section `## Acceptance Criteria`)
**Code Under Test:** `.github/dependabot.yml` (modified, +2 lines), `tests/scripts/dev_tools/test_dependabot_config_contract.py` (new, 102 lines)

## Total Blocking Findings: 0

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 (new test module under `tests/`) | 5 new (7099 passed, 6 skipped in full suite) | PASS | 93.8% lines (17638 stmts, 1094 missed); 92% combined | 93.8% lines, 88.1% branch (5612/6368) | Not applicable: 0 production statements added; `tests/*` is in the `pyproject.toml` coverage `omit` list |
| TypeScript | 0 | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| PowerShell | 0 | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| C# | 0 | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| YAML / Markdown | 1 YAML, 26 Markdown | N/A | N/A | N/A (configuration, documentation) | N/A | N/A |

### Coverage Evidence Checklist

- Python coverage artifact `artifacts/python/lcov.info` exists. Totals computed by this review from the `LF/LH/BRF/BRH` records: lines 16544/17638 = 93.80%, branches 5612/6368 = 88.13%. Both exceed the governing 85% line and 75% branch thresholds (the root `CLAUDE.md` states none, so the defaults govern).
- Executor evidence: `evidence/qa-gates/coverage-thresholds-final.2026-10-16T00-28.md` (checker exit 0), `evidence/qa-gates/coverage-delta.2026-10-16T00-28.md` (no regression: Miss 1094 baseline and final).
- The new test module has no line in `lcov.info`, which is expected: the repository policy excludes `tests/*` from measurement. No production Python file changed, so no changed-line coverage regression is possible.
- TypeScript, PowerShell, C#: no changed files; no coverage verdict is required.

## Executive Summary

The branch adds two `@types/vscode` ignore items to `.github/dependabot.yml` (npm entries for `/` and `/extensions/drm-copilot`) and a pytest contract module that parses the real file with `yaml.safe_load`. The diff of `.github/dependabot.yml` contains exactly two single-line insertions and no removals; the `/packages/mcp-server` and `github-actions` entries are untouched. The toolchain evidence (Black, Ruff, Pyright, Pytest, coverage thresholds) records exit code 0 in the final pass. No blocking finding was identified.

**Policy documents evaluated:**
- PASS `CLAUDE.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md`
- PASS `.claude/rules/quality-tiers.md`
- PASS `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- PASS `.claude/rules/python.md` (Python code change and unit test)
- N/A TypeScript, PowerShell, C# (no changed files)

**Context sources:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (refreshed at HEAD `de8ab14983bc`), `issue.md`, `plan.2026-10-15T07-42.md`, and the evidence folder.

**Temporary artifacts cleanup:**
- PASS No temporary files are committed. The `SCRATCH/940/` token in evidence artifacts refers to session scratchpad output and no such path appears in the branch file list.

## Rejected Scope Narrowing

None detected. The caller prompt did not narrow file or language scope.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations).
- The branch file list contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- Evidence is under `evidence/baseline/`, `evidence/qa-gates/`, and `evidence/regression-testing/` (canonical kinds).
- Verdict: PASS.

## Tier Classification

`quality-tiers.yml` exists at the repository root. The branch adds no project; the new file is a test module inside the existing `tests/` tree. No classification gap arises. Verdict: PASS.

---

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | All five tests read the same committed file read-only and share no mutable state. |
| Isolation | PASS | Three behaviors, each in its own test: ignore shape, `typescript` retention, non-vacuity count. |
| Fast execution | PASS | `5 passed in 0.25s` (`evidence/qa-gates/pytest-targeted-final.2026-10-16T00-28.md`). |
| Determinism | PASS | No clock, RNG, or network use; the repository root is computed from `Path(__file__).resolve()`. |
| Readability | PASS | Descriptive names, docstrings, and assertion messages naming the directory and dependency. |
| Scenario completeness | PASS | Positive (ignore present, no `update-types`/`versions`), negative (assertion messages when absent; red run demonstrates failure), non-vacuity guard. |
| Arrange-Act-Assert | PASS | Each test separates entry lookup, item selection, and assertions. |
| No temporary files | PASS | The module reads the real file with `read_text`; no `tmp_path` or `tempfile`. |
| Test location | PASS | `tests/scripts/dev_tools/test_dependabot_config_contract.py`, inside `tests/`, alongside the sibling `test_quality_checks_workflow_contracts.py`. |
| File size <= 500 lines | PASS | 102 lines. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity / separation of concerns | PASS | I/O and the untyped `yaml.safe_load` boundary are isolated in `load_target_npm_entries`; assertions work on narrowed mappings. |
| Error handling | PASS | Failing assertions carry specific messages; no broad catch handlers. |
| Naming | PASS | `snake_case` functions, `UPPER_CASE` constants. |
| Dependencies | PASS | PyYAML is an approved dependency (`pyproject.toml`); no dependency added. |
| Mandatory toolchain loop | PASS | Final pass: Black file and repo exit 0, Ruff file and repo exit 0, Pyright file and repo 0 errors, targeted and full Pytest exit 0 (`evidence/qa-gates/`). Pass 1 reported a Black reformat, which was applied in `fe96fd9aa` and the loop restarted, as policy requires. |
| Contract / schema checks, integration tests | PASS | Not affected: no API, schema, or integration surface changed. |

## 3. Python Policy Compliance (`.claude/rules/python.md`)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black | PASS | `black --check .` exit 0, 598 files unchanged. |
| Ruff | PASS | `ruff check` exit 0. |
| Pyright | PASS | 0 errors, 0 warnings. |
| Typing of untyped boundary | PASS | `typing.cast` with string-form types applied to `yaml.safe_load` results; no `Any` or suppression comments were added. |
| Pytest | PASS | 7099 passed, 6 skipped, 0 failed. |

## 4. Coverage Exclusion Policy

No `exclude`/`omit` entry was added or changed in this branch (`pyproject.toml` is not in the diff). Verdict: PASS.

## 5. Gaps and Exceptions

- The runtime effect of a bare `dependency-name` ignore within a Dependabot group cannot be verified in-repo. `issue.md` records this as a residual risk and assigns a post-merge `@dependabot recreate` check on PRs #832 and #833. This is not an acceptance criterion and not a finding.

## 6. Compliance Verdict

### Overall Status: FULLY COMPLIANT

Blocking findings: 0. Review verdict: PASS.
