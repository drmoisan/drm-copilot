# Policy Compliance Audit: bootstrap-json-bash-toolchains-devcontainer-55

**Audit Date:** 2026-02-24  
**Base Branch:** `main` (assumed because `${input:PRBaseBranch}` was not provided)  
**Feature Folder:** `docs/features/active/2026-02-23-bootstrap-json-bash-toolchains-devcontainer-55`  
**Feature folder selection rule:** Multiple active feature folders appeared in PR context; selected folder whose suffix matches current branch issue marker `#55`.

## Executive Summary

Overall status is **⚠️ PARTIALLY COMPLIANT (Needs revision)**.

What passed:
- Repo toolchain checks executed successfully in this session for Python, JSON, shell, and PowerShell analyze/test.
- Feature-specific shell tests passed.
- No unexpected tracked-file mutations were introduced by verification commands.
- `issue.md` scope now aligns to QC/devcontainer objectives and no longer references out-of-scope host scripts.

What did not fully comply:
- Scope hygiene is weak for a feature-focused PR: refreshed PR context range includes substantial unrelated feature content (not just #55).
- Direct local Docker + Codespaces open-success proof is still partial in this review session.

Policy documents evaluated:
- ✅ `general-code-change.instructions.md`
- ✅ `general-unit-test.instructions.md`
- ✅ Python + Python test policies
- ✅ PowerShell + PowerShell test policies
- ✅ Bash/JSON quality conventions via repo QC commands

## Coverage Metrics by Language

| Language | Files Changed (branch range) | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---:|---:|---|---|---|---|
| Python | 19 | 798 collected | ✅ 798 passed | Not re-measured in this review run | 81% (from pytest run) | UNVERIFIED |
| PowerShell | 5 | 224 discovered | ✅ 217 passed / 7 skipped | Not re-measured in this review run | 44.23% cmds (reported by Pester run) | UNVERIFIED |
| Bash | 7 | 14 bats tests | ✅ 14 passed | N/A | N/A | N/A |
| JSON | 7 | N/A | ✅ validate command passed | N/A | N/A | N/A |

## Compliance Findings

### 1) General Code Change Policy

| Requirement | Status | Evidence |
|---|---|---|
| Clarify objective and planning present | ✅ PASS | `issue.md` + `plan.2026-02-23T20-42.md` in feature folder document objective and atomic tasks. |
| Follow design principles (simplicity/reuse/separation) | ✅ PASS | `.github/codex/codex-web-setup.sh` refactor introduces helper functions (`apt_update`, `apt_install`, retry wrappers) and single `main` orchestration. |
| Toolchain executed and reported | ✅ PASS | Commands executed this audit run: `black --check`, `ruff check`, `pyright`, `pytest --cov`, `validate_json`, `shell-qc check`, `shell-qc test`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCTest`; all exit success. |
| Supporting docs updated | ✅ PASS | Feature evidence artifacts and plan updates exist under feature folder. |
| Scope control for feature PR | ⚠️ PARTIAL | Refreshed `artifacts/pr_context.summary.txt` shows broad branch diff containing major additional feature scope beyond #55. |

### 2) General Unit Test Policy

| Requirement | Status | Evidence |
|---|---|---|
| Independence / isolation / determinism | ✅ PASS | Python and PowerShell suites pass; shell tests are deterministic and local (`14 tests, 0 failures`). |
| Positive/negative/edge/error scenarios | ✅ PASS | Shell test files include retry behavior, connectivity handling, source safety guard, and naming/tool parity assertions. |
| External dependency control | ✅ PASS | Shell tests validate script content and controlled invocations; no external network dependency in bats test execution observed. |
| Coverage expectations | ⚠️ PARTIAL | Overall Python coverage reported at 81% (meets repo-wide floor), but feature-specific new-code coverage for this review run is not isolated and therefore UNVERIFIED. |

### 3) Language-Specific Policy Checks

#### Python
- ✅ PASS: `poetry run black --check .` (no changes)
- ✅ PASS: `poetry run ruff check` (all checks passed)
- ✅ PASS: `poetry run pyright` (0 errors)
- ✅ PASS: `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` (798 passed)

#### PowerShell
- ⚠️ PARTIAL: Check-only preference applied; executed analyze + tests directly via PoshQC commands.
- ✅ PASS: `Invoke-PoshQCAnalyze -Root .` (no findings)
- ✅ PASS: `Invoke-PoshQCTest -Root .` (217 passed, 7 skipped)
- N/A in this review run: formatter command intentionally not re-run to avoid mutation during audit-only execution.

#### Bash / JSON
- ✅ PASS: `poetry run python -m scripts.dev_tools.validate_json`
- ✅ PASS: `poetry run shell-qc check`
- ✅ PASS: `poetry run shell-qc test` (14 passed)

## Gaps and Exceptions

### Gaps
1. **Feature PR scope sprawl**: Base→head range includes substantial unrelated feature payload, reducing auditability for #55-only merge intent.
2. **Coverage isolation gap**: New/changed code coverage for #55-specific paths not isolated in this review execution.
3. **Environment-open proof gap**: Evidence for successful open in both local Docker and Codespaces remains partial in this session.

### Approved Exceptions
- None recorded.

## Recommendation

**Needs revision** before PR merge for a strict #55 feature-scope review.

Minimum actions:
1. Reduce PR scope to #55-only changes (or explicitly declare/approve multi-feature merge intent).
2. Add focused verification evidence that isolates #55-delivered paths.
3. Add explicit evidence for successful devcontainer open/startup in both local Docker and Codespaces.

## Appendix B: Commands Executed in This Audit Run

- `poetry run python -m scripts.dev_tools.pr_context.collector --base main`
- `git rev-parse --abbrev-ref HEAD`
- `git rev-parse --abbrev-ref --symbolic-full-name '@{u}'`
- `git status --short`
- `poetry run black --check .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- `poetry run python -m scripts.dev_tools.validate_json`
- `poetry run shell-qc check`
- `poetry run shell-qc test`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
