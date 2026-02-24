# Remediation Inputs — 2026-02-23T14-24

Feature: `docs/features/active/2026-02-23-minor-audit-planning-58`  
Base branch: `main`

## Required fixes (numbered, minimal scope)

1. **Fix PowerShell indentation violations in updated test file**
   - **Files:** `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`
   - **Locations:** Lines reported by analyzer: 257–267
   - **Expected behavior:** `Invoke-PoshQCAnalyze -Root .` completes with no findings.
   - **Acceptance criteria:** No `PSUseConsistentIndentation` warnings remain in this file.
   - **Verification:**
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`

2. **Implement insiders-aware command preference to satisfy failing Pester test**
   - **Files:** `scripts/dev-tools/new-potential-entry.ps1`
   - **Related test:** `tests/scripts/dev-tools/new-potential-entry.Tests.ps1` (failing scenario starts at line 249)
   - **Current mismatch:** test expects `code-insiders` in insider session when both commands are available; implementation only checks/launches `code`.
   - **Expected behavior:** `Invoke-VSCodeOpen` deterministically prefers `code-insiders` when insider session signal is present and command exists; otherwise falls back to `code`.
   - **Acceptance criteria:** `Invoke-PoshQCTest -Root .` passes the previously failing test; no regressions in existing VS Code open tests.
   - **Verification:**
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

3. **Re-run full quality gates after PowerShell fixes**
   - **Files:** Entire touched workspace (validation only)
   - **Expected behavior:** all policy gates pass in one final pass for impacted toolchains.
   - **Acceptance criteria:**
     - Python: Black/Ruff/Pyright/Pytest all pass
     - JSON validate passes
     - PowerShell analyze + Pester pass
   - **Verification:**
     - `poetry run black --check .`
     - `poetry run ruff check .`
     - `poetry run pyright`
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
     - `poetry run python -m scripts.dev_tools.validate_json`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

## Do-not-do list

- Do **not** widen scope beyond the two PowerShell files above unless strictly required by tests.
- Do **not** relax/disable lint or test rules.
- Do **not** add suppression comments to bypass `PSUseConsistentIndentation`.
- Do **not** modify policy files under `.github/instructions/`.
- Do **not** skip failing checks silently; every failing gate must be rerun and documented.

## Unmet acceptance criteria and minimum changes required

- **Criterion:** Feature validation treated as full-process work across touched surfaces.  
  - **Current status:** PARTIAL (PowerShell analyze/test failed).  
  - **Minimum changes:** Apply fixes #1 and #2 above, then complete fix #3 with all gates passing.
