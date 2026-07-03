# Issue 196 — Bundled Validator Resync Research

**Date:** 2026-06-17
**Issue:** 196
**Feature branch:** feature/remove-worktrees (current branch; fix is independent and can land on a separate branch)

---

## 1. Current State Analysis

### 1.1 The bundled monolith

File: `extensions/drm-copilot/resources/scripts/dev_tools/validate_orchestration_artifacts.py`
Line count: 554 (verified via grep count)
Last substantive change date: described in the problem statement as 2026-05-01

This file is a single-module monolith that contains every validator inline:
`validate_plan_text`, `validate_policy_audit_text`, `validate_code_review_text`,
`validate_feature_audit_text`, and `validate_orchestrator_state_text`.

It is invoked by the MCP wrapper at:
`extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py`

The wrapper (lines 36–51) calls `_ensure_bundled_scripts_import_path()` which prepends
`extensions/drm-copilot/resources/scripts` to `sys.path`, then imports
`dev_tools.validate_orchestration_artifacts` by module name. The wrapper owns no
validation logic.

### 1.2 Known behavioral divergences (monolith vs. repo source)

All three bugs below are confirmed by reading `VALID_STEP_STATUS` and the receipt
dispatch in both files.

**Bug 1 — Missing step statuses.**
Monolith `VALID_STEP_STATUS` (line 82): `{"not-applicable", "pending", "delegated", "verified", "blocked"}`
Repo source `VALID_STEP_STATUS` (validate_orchestrator_state.py line 63–72):
adds `"not_started"`, `"in_progress"`, `"completed"`.
Consequence: any checkpoint that uses `completed` (the natural post-execution value)
is rejected by the MCP tool.

**Bug 2 — List-only delegation receipts.**
Monolith (lines 453–474) enforces `receipts is not None and not isinstance(receipts, list)` → error.
Repo source (validate_orchestrator_state.py lines 378–393) accepts both `list` and `dict`
(the `delegation_receipts.promotion.*` object namespace). Any checkpoint using the
namespaced form is rejected by the MCP tool.

**Bug 3 — Missing `human_interaction` and `remediation_loop` invariants.**
The monolith has no `REMEDIATION_LOOP_KEY`, no `HUMAN_INTERACTION_KEY`, and no dispatch
to those validators (confirmed by reading the entire monolith). Both invariant sets
were added in the 2026-06-16 refactor and documented in `.claude/rules/orchestrator-state.md`.

### 1.3 Repo-source module structure (post-refactor)

Five modules under `scripts/dev_tools/`:

| File | Lines | Role |
|---|---|---|
| `validate_orchestration_artifacts.py` | 246 | Stable CLI dispatcher; imports the four below |
| `validate_orchestrator_state.py` | 426 | Checkpoint validation; imports `_orchestrator_state_human_interaction` |
| `_orchestrator_state_human_interaction.py` | 127 | `human_interaction` block invariants |
| `validate_orchestration_review_artifacts.py` | 107 | Code-review and feature-audit validators; re-exports `validate_policy_audit_text` |
| `validate_policy_audit_artifact.py` | 448 | Policy-audit parsing and validation |

All five are under the 500-line limit. `validate_policy_audit_artifact.py` at 448 lines is
closest to the limit but within it.

---

## 2. Bundle Import Convention

### 2.1 The verified rewrite rule

**Source tree** imports use the `scripts.dev_tools.*` prefix because the repo root is on
`sys.path` (enforced by `tests/conftest.py` line 57–61).

**Bundle tree** imports use the `dev_tools.*` prefix because
`extensions/drm-copilot/resources/scripts` is prepended to `sys.path` at runtime by every
wrapper template. That directory contains `dev_tools/` as a package, making
`dev_tools.X` the correct import path inside the bundle.

Evidence — `scripts/dev_tools/new_active_feature_folder.py` line 5:
```python
from scripts.dev_tools.new_active_feature_folder_docs import (
```
Corresponding bundle `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder.py` line 5:
```python
from dev_tools.new_active_feature_folder_docs import (
```
The rewrite rule is a uniform prefix substitution:
`scripts.dev_tools.` → `dev_tools.`

Confirmed identically for `potential_to_issue.py`:
Source line 13: `from scripts.dev_tools.potential_to_issue_content import ...`
Bundle line 13: `from dev_tools.potential_to_issue_content import ...`

`new_active_feature_folder_flow.py` (bundle) line 9:
`from dev_tools.new_active_feature_folder_docs import ...` (source uses `scripts.dev_tools.`).

The private module `_orchestrator_state_human_interaction.py` follows the same rule:
source import in `validate_orchestrator_state.py` line 34:
`from scripts.dev_tools._orchestrator_state_human_interaction import ...`
Bundle equivalent must be:
`from dev_tools._orchestrator_state_human_interaction import ...`
The leading underscore in the module name is kept as-is; Python allows `import dev_tools._orchestrator_state_human_interaction` when the file is `dev_tools/_orchestrator_state_human_interaction.py`.

### 2.2 Dual-import fallback pattern (observed in push_down_claude_customizations.py)

`extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py`
(and its source counterpart) use a `try/except ModuleNotFoundError` block that attempts
`from scripts.dev_tools.*` first and falls back to `from dev_tools.*`. This allows the
same file to run in both the repo-root context (where `scripts.dev_tools` is importable)
and the bundled context (where only `dev_tools` is importable). The fallback guard checks
`error.name.startswith("scripts")` to avoid masking unrelated `ModuleNotFoundError` exceptions.

The validator modules do NOT use this dual-import pattern and are not expected to; the
bundled copies are separate files from their repo-source counterparts. The dual-import
pattern is only relevant for files that ARE the same physical file in both contexts.

---

## 3. Sync Mechanism

### 3.1 No automated sync script for the validator

The bundled dev_tools package is NOT produced by an automated copy or rewrite script.
Evidence:

- `scripts/dev_tools/agentic_sync.py` (bundle copy also present): synchronizes shared
  `.github` governance documents between two workspaces. It does not reference
  `resources/scripts/dev_tools` and does not perform Python import rewrites.
- `esbuild-mcp-server.cjs`: bundles `out/mcp-server.js` (the TypeScript MCP server) into
  a self-contained Node.js file. It does not touch Python files.
- `package.json` npm scripts: `compile`, `build`, `bundle:mcp-server`, `format`, `lint`,
  `typecheck`, `test`. None reference Python file copying or `resources/scripts`.
- The five `push_down_*.py` scripts in `scripts/dev_tools/` push `.github` or `.claude`
  content to consumer workspaces; they do not copy `scripts/dev_tools/` files into
  `extensions/drm-copilot/resources/scripts/dev_tools/`.
- No Makefile exists at the repo root.

**Conclusion:** The bundle is maintained by hand-mirroring with manual import rewriting.
There is no automated sync tool. This is the source of the drift.

### 3.2 The existing multi-module bundles are correctly hand-mirrored

`new_active_feature_folder.py` and its siblings were correctly hand-mirrored with the
`dev_tools.*` import prefix. `potential_to_issue.py` and `potential_to_issue_content.py`
are likewise correctly mirrored. The validator bundle was simply never updated after the
2026-06-16 refactor split it into five modules.

---

## 4. Parity Guard Gap

### 4.1 No parity test for the validator bundle currently exists

Searched `tests/extensions/drm_copilot/` for any file containing `validate_orchestration`:
no results. Searched all `tests/` for files matching that pattern: only
`tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` and related files are
found. None of those test the bundled copy; they all import from `scripts.dev_tools.*`.

### 4.2 The existing parity test pattern (PoshQC)

`tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (read in full):
- Defines `POSHQC_PARITY_PATHS` — a tuple of repo-root-relative paths.
- `read_repo_text(relative_path)` reads from `REPO_ROOT / relative_path`.
- `read_bundle_text(relative_path)` derives the bundle path by applying a string
  replacement: `"scripts/powershell/PoshQC/"` → `"extensions/drm-copilot/resources/powershell/PoshQC/"`.
- The single test `test_poshqc_bundled_module_files_match_repo_root_sources` iterates
  the tuple and asserts exact byte-identical text for each pair.

This pattern is exact-match (byte-level string equality). It is appropriate for files
whose content is truly identical between repo-source and bundle (i.e., no import rewriting
is performed). The PoshQC PowerShell modules are the same physical file content in both
locations.

**The PoshQC exact-match pattern does NOT apply to the Python validator bundle**, because
the bundle's import statements differ from the source (prefix substitution). A functional
equivalence test is required instead.

### 4.3 The functional parity test pattern (extension templates)

`tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py` and
`test_new_active_feature_folder.py` demonstrate the established pattern for testing
bundled Python modules that use the `dev_tools.*` import namespace:

1. Define `BUNDLED_SCRIPTS_DIR = ROOT / "extensions" / "drm-copilot" / "resources" / "scripts"`.
2. Insert `str(BUNDLED_SCRIPTS_DIR)` into `sys.path[0]` to make `dev_tools.*` importable.
3. Use `importlib.util.spec_from_file_location` to load the bundled module by file path
   with a unique `module_name` registered in `sys.modules`.
4. Call the bundled module's functions directly to assert behavior.
5. Clean up `sys.path` and `sys.modules` in `finally` blocks.

`_load_bundled_runtime_module` in `test_potential_to_issue.py` (lines 57–73) loads the
bundled module with `dev_tools.*` importable, then calls its functions with fake/mock
collaborators to assert end-to-end behavior.

This is the correct pattern for a new acceptance test of the bundled validator.

### 4.4 Codex handoff parity pattern

`tests/scripts/dev_tools/test_codex_handoff_contract_parity.py` tests text-level
contracts (fragment presence) in bundled Codex agent files. It uses
`@pytest.mark.skipif` for paths that are gitignored in CI. This pattern is not directly
applicable to the validator test.

---

## 5. MCP Path Test Structure

### 5.1 Template wrapper tests

`tests/extensions/drm_copilot/resources/templates/test_new_active_feature_folder.py`
(lines 51–62, 66–95) tests:
- `test_imports_bundled_module`: loads the wrapper template via `importlib.util.spec_from_file_location`,
  asserts it has a `main` attribute. This exercises the import chain transitively.
- `test_ensure_path_adds_scripts_dir_to_sys_path`: directly calls `_ensure_bundled_scripts_import_path`
  and asserts `sys.path[0]` matches the expected scripts dir.
- `test_main_invokes_bundled_entrypoint_and_returns_zero`: patches the bundled module's
  `main` with a `MagicMock` and asserts the wrapper calls it.

The MCP template `validate_orchestration_artifacts.py` (template wrapper) would need
analogous tests for its `_ensure_bundled_scripts_import_path` and its `main` delegation.

### 5.2 Bundled module acceptance test design

The gap is an acceptance test that:
1. Prepends `BUNDLED_SCRIPTS_DIR` to `sys.path`.
2. Loads `dev_tools.validate_orchestration_artifacts` from the bundled file path.
3. Calls the bundled `validate_orchestrator_state_text` with a JSON checkpoint using:
   - `step_status` values of `"completed"` and `"in_progress"`.
   - `delegation_receipts` as an object with the `promotion` namespace.
   - A `human_interaction` block with valid `requirements`.
   - A `remediation_loop` with a cycle having `exit_condition_met: true` and `blocking_count: 0`.
4. Asserts `errors == []`.

This directly exercises the three known bugs in the bundled monolith and will fail
until all four resync files are in place.

---

## 6. Recommended Approach

### 6.1 Bundle files to add/replace

The monolith at `extensions/drm-copilot/resources/scripts/dev_tools/validate_orchestration_artifacts.py`
must be **replaced** with four new files mirroring the repo-source structure. The bundled
`validate_orchestration_artifacts.py` becomes the thin dispatcher (same role as the
repo-source dispatcher).

Files to create or update:

**A. Replace** `extensions/drm-copilot/resources/scripts/dev_tools/validate_orchestration_artifacts.py`
with content copied from `scripts/dev_tools/validate_orchestration_artifacts.py` with
import prefix substitution:
- `from scripts.dev_tools.validate_orchestration_review_artifacts import`
  → `from dev_tools.validate_orchestration_review_artifacts import`
- `from scripts.dev_tools.validate_orchestrator_state import`
  → `from dev_tools.validate_orchestrator_state import`
- `from scripts.dev_tools.validate_policy_audit_artifact import`
  → `from dev_tools.validate_policy_audit_artifact import`

**B. Add** `extensions/drm-copilot/resources/scripts/dev_tools/validate_orchestrator_state.py`
copied from `scripts/dev_tools/validate_orchestrator_state.py` with:
- `from scripts.dev_tools._orchestrator_state_human_interaction import`
  → `from dev_tools._orchestrator_state_human_interaction import`

**C. Add** `extensions/drm-copilot/resources/scripts/dev_tools/_orchestrator_state_human_interaction.py`
copied from `scripts/dev_tools/_orchestrator_state_human_interaction.py` — no import
changes required (this module imports only from stdlib `typing`).

**D. Add** `extensions/drm-copilot/resources/scripts/dev_tools/validate_orchestration_review_artifacts.py`
copied from `scripts/dev_tools/validate_orchestration_review_artifacts.py` with:
- `from scripts.dev_tools.validate_policy_audit_artifact import`
  → `from dev_tools.validate_policy_audit_artifact import`

**E. Add** `extensions/drm-copilot/resources/scripts/dev_tools/validate_policy_audit_artifact.py`
copied from `scripts/dev_tools/validate_policy_audit_artifact.py` — no import changes
required (this module imports only from stdlib `re`).

The MCP wrapper template (`extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py`)
requires no changes.

### 6.2 Sync approach: hand-mirror with parity test (no new sync tool)

Introducing an automated sync script adds toolchain complexity that the rest of the
bundle (new_active_feature_folder, potential_to_issue, PoshQC) does not use. The
correct durable solution is the same approach the repo already uses: hand-mirror the
files with a CI-enforced parity test.

For the validator, the parity test cannot use exact byte-level equality (the import
prefix differs). It must use functional equivalence. The functional parity test is
defined in section 6.3 below.

### 6.3 Parity test design

New file: `tests/scripts/dev_tools/test_validate_orchestration_artifacts_bundle_parity.py`

Location rationale: this test exercises both the repo-source module (already tested in
`test_validate_orchestration_artifacts.py`) and the bundled module. It belongs in
`tests/scripts/dev_tools/` (not the extension tree) because it is testing a
source-to-bundle contract rather than the extension wrapper. The PoshQC parity test
follows the same placement pattern.

Design:
1. Define `BUNDLED_SCRIPTS_DIR` as the absolute path to `extensions/drm-copilot/resources/scripts`.
2. Define a helper that temporarily inserts `BUNDLED_SCRIPTS_DIR` into `sys.path[0]` and
   pops the bundled modules from `sys.modules` before and after import to prevent
   cross-test contamination.
3. For each test case, load `dev_tools.validate_orchestration_artifacts` from the bundled
   file via `importlib.util.spec_from_file_location` (the same pattern as
   `test_potential_to_issue.py` lines 57–73).
4. Collect assertions:
   - `test_bundled_validator_accepts_completed_step_status`: checkpoint with
     `step7_status: "completed"` → `errors == []`.
   - `test_bundled_validator_accepts_namespaced_delegation_receipts`: checkpoint with
     `delegation_receipts: {"promotion": {...}}` → `errors == []`.
   - `test_bundled_validator_accepts_human_interaction_block`: checkpoint with a valid
     `human_interaction.requirements` list → `errors == []`.
   - `test_bundled_validator_accepts_remediation_loop_with_cleared_preflight`: checkpoint
     with a `remediation_loop.cycles` array whose single cycle has
     `exit_condition_met: true`, `blocking_count: 0`, and
     `preflight: {"final_status": "clear"}` → `errors == []`.
   - `test_bundled_validator_rejects_unknown_promotion_namespace_key`: checkpoint with
     `delegation_receipts: {"promotion": {...}, "extra": {}}` → error contains
     `"unsupported key: extra"`.

5. Each test restores `sys.path` and cleans `sys.modules` in a `finally` block.

This test will FAIL on the current monolith (bugs 1–3 confirmed) and PASS after the
five files are resync'd, providing a regression gate for all future drift.

### 6.4 MCP path acceptance test design

New file: `tests/extensions/drm_copilot/resources/templates/test_validate_orchestration_artifacts.py`

Design mirrors `test_new_active_feature_folder.py`:
1. `test_imports_bundled_module`: load the wrapper template via `importlib.util.spec_from_file_location`,
   assert it has a `main` attribute. This exercises the full import chain including the
   four new bundled modules transitively. This test is the most direct regression guard
   for the MCP entry point.
2. `test_ensure_path_adds_scripts_dir_to_sys_path`: call `_ensure_bundled_scripts_import_path`
   and assert `sys.path[0]` matches expected scripts dir.
3. `test_main_delegates_to_bundled_module`: patch `importlib.import_module` to return a
   `MagicMock` whose `main()` returns `0`, call the wrapper `main()`, assert it returns `0`.

Test 1 is the load-time smoke test that fails immediately if any bundled import is
broken. Tests 2 and 3 lock the wrapper contract. Together with the parity test in
section 6.3, these provide two-layer CI coverage: bundled-module behavioral correctness
and MCP-wrapper delegation correctness.

---

## 7. Testing Implications

The existing `test_validate_orchestration_artifacts.py` (460 lines, `tests/scripts/dev_tools/`)
tests the repo-source modules and must not be modified.

New tests:
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_bundle_parity.py` — parity gate
- `tests/extensions/drm_copilot/resources/templates/test_validate_orchestration_artifacts.py` — MCP path smoke

Both new test files must follow existing patterns:
- `sys.path` manipulation is done via `sys.path.insert(0, ...)` with restoration in `finally`.
- `sys.modules` cleanup uses `sys.modules.pop(name, None)` for each module loaded by the test.
- No temporary files.
- Arrange–Act–Assert structure.
- Each test must import the bundled module under a unique `module_name` key to prevent
  cross-test `sys.modules` contamination.

---

## 8. Automation Feasibility

This is a local repository tooling fix. All affected files are Python source files under
`extensions/drm-copilot/resources/scripts/dev_tools/` and `tests/`. No third-party UI
interaction, no VS Code API calls, no subprocess invocations, and no network access is
required. The fix is:
1. Write/replace five bundled Python files (content copy with import prefix substitution).
2. Write two new test files.
3. Run the Python toolchain (format, lint, type-check, test) to verify.

Full autonomous implementation is achievable.

---

## Rejected Alternatives

**Automated sync script (e.g., extend `agentic_sync.py` or add a new `sync_validator_bundle.py`).**
Rejected. The repo has no precedent for an automated Python-import-rewriting sync step.
The only other multi-module bundles (new_active_feature_folder, potential_to_issue) are
hand-mirrored without automation and protected by tests. Adding a sync script adds a
novel toolchain dependency, requires its own tests, and solves the same problem as a
parity test at higher complexity. The functional parity test is the lower-complexity
durable solution.

**Exact byte-level parity test (PoshQC pattern).**
Rejected. The import prefix differs between source and bundle, so byte-level equality
would require the source files to carry dual-namespace imports, which would break the
`scripts.dev_tools.*` import contract used by all existing tests and callers. The
functional equivalence test is appropriate.
