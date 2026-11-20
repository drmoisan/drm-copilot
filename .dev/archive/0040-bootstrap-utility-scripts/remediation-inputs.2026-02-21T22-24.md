# Remediation Inputs: bootstrap-utility-scripts (#40)

Timestamp: 2026-02-21T22-24

## Required Fixes (authoritative)

1. **Fix Python type-check scope so `poetry run pyright` is green**
   - Files: `pyproject.toml` (`[tool.pyright]`), and if needed pyright invocation wrappers in `scripts/dev_tools/fix_all.py` / `scripts/dev_tools/shell_qc.py`
   - Expected behavior: Pyright analyzes repository Python code only (not vendored Python under `node_modules`) and exits 0.
   - Acceptance criteria:
     - `poetry run pyright` exits 0.
     - No `node_modules/.../*.py` diagnostics are emitted.
   - Verification:
     - `poetry run pyright`

2. **Resolve 500-line policy violations by decomposing oversized files**
   - Files (minimum set):
     - `scripts/dev_tools/atomic_executor/cli.py` (2327)
     - `scripts/dev_tools/new_active_feature_folder.py` (1190)
     - `scripts/dev_tools/fix_all.py` (944)
     - `scripts/dev_tools/atomic_executor/qc_runner.py` (897)
     - `scripts/dev_tools/potential_to_issue.py` (762)
     - `scripts/dev_tools/pr_context/render.py` (615)
     - Oversized test files including `tests/scripts/dev_tools/atomic_executor/test_cli.py` (1635)
   - Expected behavior: All production/test/reusable-script files comply with <=500 lines while preserving behavior.
   - Acceptance criteria:
     - No tracked production/test script file exceeds 500 lines.
     - Existing tests continue to pass after decomposition.
   - Verification:
     - line-count check over changed files (scripted)
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

3. **Stabilize and document quality-gate evidence capture for this feature**
   - Files: create/update `docs/features/active/2026-02-21-bootstrap-utility-scripts-40/evidence/qa-gates/*`
   - Expected behavior: each required gate has a local evidence artifact containing command, timestamp, exit code, and concise output summary.
   - Acceptance criteria:
     - Evidence artifacts exist for Python, PowerShell, and TypeScript gates.
     - Any blocked gate records reason and remediation owner/action.
   - Verification:
     - Manual inspection of evidence files under `evidence/qa-gates/`

4. **Synchronize plan status with delivered work (baseline + final)**
   - Files: original feature plan file(s), remediation plan file
   - Expected behavior: checkboxes reflect actual delivery state at remediation start and completion.
   - Acceptance criteria:
     - Baseline sync task completed immediately after plan generation.
     - Final sync task completed at end of remediation execution.
   - Verification:
     - Diff review of plan checkbox state

## Unmet Acceptance Criteria Mapping

- **AC1 (Python chain pass): NOT MET** — pyright exits 1.
- **AC4 (completion based on successful toolchain status): NOT MET** — required Python gate is failing.
- **AC5 (evidence recorded per gate with blocked-gate rationale): PARTIALLY MET** — present in review artifacts, but missing feature-local gate evidence files.

## Do Not Do

- Do not weaken policy (no broad suppressions or policy edits).
- Do not add scope unrelated to the above acceptance gaps.
- Do not silently skip failing gates.
- Do not replace mandatory direct PoshQC commands with VS Code task wrappers for agent execution.
