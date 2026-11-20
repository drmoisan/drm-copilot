# Policy Compliance Audit: orchestration-enforcement-hardening (Issue #253)

---

**Audit Date:** 2026-06-26 (R4 re-audit after additive AC8 commit)
**Base branch (resolved):** `origin/main`
**Merge-base SHA:** `1ea8d87c5ffb9daf671eb33bc22b6d56be4d0ec6`
**Head SHA:** `05a44de0706e5535a665ef3894f9a5c5aad79c3c`
**Range:** `1ea8d87..05a44de` (two commits: `ebd4293` original hardening + `05a44de` AC8 reconciliation)
**Work mode (from issue.md):** `full-feature` — AC sources: `spec.md` (AC1–AC8) and `user-story.md` (AC1–AC7)

**Code Under Test (production files in branch diff):**
- Python: `scripts/dev_tools/_orchestrator_state_routing.py`, `scripts/dev_tools/validate_orchestrator_state.py`
- PowerShell: `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1` (new), `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/validate-orchestrator-output.ps1`
- PowerShell mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/{enforce-completion-consistency,enforce-completion-helpers,enforce-orchestration-preimplementation-gate,validate-orchestrator-output}.ps1`
- JSON: `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json`
- Tests (Python): `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, `test_validate_orchestration_artifacts.py`, `test_validate_orchestrator_state_routing_contract.py`
- Tests (PowerShell): `tests/scripts/claude-hooks/{enforce-completion-consistency,validate-orchestrator-output,enforce-orchestration-preimplementation-gate}.Tests.ps1`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Post-Change Coverage | New/Changed Code Coverage | Verdict |
|----------|--------------|-------|-------------|---------------------|---------------------------|---------|
| Python | 2 prod + 3 test | 51 targeted | PASS, 0 fail | repo-wide 85.7% line / 75.0% branch (`artifacts/python/lcov.info`) | `_orchestrator_state_routing.py` 91.3% line / 82.4% branch; `validate_orchestrator_state.py` 97.3% line / 92.7% branch | PASS |
| PowerShell | 4 prod + 3 test (+4 mirror) | 95 | PASS, 0 fail | `enforce-completion-consistency.ps1` 91.7% line; `enforce-completion-helpers.ps1` 93.0% line; `enforce-orchestration-preimplementation-gate.ps1` 87.3% line; `validate-orchestrator-output.ps1` 87.0% line (`artifacts/pester/feature253-review-coverage.xml`) | all four hooks >= 87% line / >= 88% command-coverage proxy | PASS |
| JSON | 2 files | N/A | PASS (byte-identical parity test) | N/A (config files) | N/A (config files) | PASS (config-only) |

**Note (Pester branch coverage):** Pester's JaCoCo output emits no BRANCH counter; PowerShell branch coverage is reported via INSTRUCTION (command) coverage as the documented proxy (>= 88% for all four hooks).

### Coverage Evidence Checklist

- TypeScript: `N/A — zero TypeScript files in branch diff`
- C#: `N/A — zero C# files in branch diff`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (regenerated during execution, timestamp 2026-06-26T20:07; inspected, not re-run)
- PowerShell post-change coverage artifact: `artifacts/pester/feature253-review-coverage.xml` (combined coverage across all three changed hook test files). The canonical `artifacts/pester/powershell-coverage.xml` does NOT contain the four changed hooks (verified: all four reported NOT PRESENT). This split is a known condition for this feature (see agent memory `project-powershell-hook-coverage-artifact`). The combined scoped artifact is authoritative for the changed hooks.

**Non-negotiable verdict rule:** Both in-scope toolchain languages (Python, PowerShell) have explicit numeric post-change coverage that meets thresholds; both receive `PASS`. JSON is config-only with byte-identical parity verified. No language with changed files received `N/A`, `UNVERIFIED`, or "informational only".

**Fail-closed rule:** No required coverage artifact is missing. The evidence-location validator (`validate_evidence_locations.py --root .`) exits 0.

---

## Executive Summary

This branch closes five diagnosed orchestration-enforcement gaps (Gaps 1–5; Gap 6 explicitly deferred), reconciles the routing-matrix agent names, and — in the second commit `05a44de` — removes `collect_commit_context` from the `large` route's `required_mcp_tools` to satisfy AC8. The change spans Python validators in `scripts/dev_tools/` and PowerShell completion-gate hooks in `.claude/hooks/`, with byte-identical bundled mirrors under `extensions/drm-copilot/resources/`.

All four required toolchains were executed check-only and pass:
- Python: Black `--check` (clean, 3 files unchanged), Ruff (`All checks passed!`), Pyright (`0 errors, 0 warnings`), Pytest (51 targeted pass: parity, routing-contract, validator, artifacts CLI suites).
- PowerShell: PSScriptAnalyzer (Warning+Error severities: `NO WARNINGS OR ERRORS`), Pester (95 pass / 0 fail across the three changed hook test files).

The routing-config parity test passes; both routing JSON files are byte-identical (SHA256 `d29b3a64...720` on both). The four PowerShell hooks and their bundled mirrors are byte-identical. The evidence-location validator exits 0.

All changed production files are under the 500-line limit (largest: `_orchestrator_state_routing.py` at 477 lines; `validate_orchestrator_state.py` at 470).

**AC8 verification (the R4 delta):** `collect_commit_context` is confirmed absent from both routing JSON files and confirmed absent from the orchestrator MCP allow list in `.claude/settings.json` (allow list contains `collect_pr_context`, `validate_orchestration_artifacts`, lifecycle tools, PoshQC tools, but not `collect_commit_context`). The routing-contract positive test (`test_validate_orchestrator_state_routing_contract.py`) builds a complete large-route checkpoint from the live matrix and asserts an empty error list, confirming a fully-exercised large-route checkpoint passes `validate_routing_contract` with no unsatisfiable receipt.

**Policy documents evaluated:**
- PASS `general-code-change.md` (simplicity, separation of concerns, file-size, fail-fast, naming)
- PASS `general-unit-test.md` (independence, isolation, determinism, AAA, coverage)
- PASS `python.md`, `python-suppressions.md`
- PASS `powershell.md`
- PASS `quality-tiers.md` (uniform line >= 85% / branch >= 75%; T2 classification for both `scripts/dev_tools/` and the completion-gate hooks)
- PASS `tonality.md` (artifact and commit-message tone neutral and factual)

**Language-specific policies evaluated:**
- PASS Python: `python-code-change` + `python-unit-test`
- PASS PowerShell: `powershell-code-change` + `powershell-unit-test`
- PASS JSON: routing-matrix byte-identical parity verified
- N/A TypeScript, C#, Bash, GitHub Actions: no changed files of these types in the branch diff

---

## Rejected Scope Narrowing

None. The caller prompt instructed a full-branch-diff audit against the merge-base and explicitly directed self-determination of scope per the workflow scope invariant. No attempt to narrow scope to a plan, task, phase, file subset, or to mark any language out of scope was present. The audit covers the full `1ea8d87..05a44de` diff (both commits).

---

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exits 0 (no violations).

Branch-diff scan for non-canonical evidence paths (`artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`): no matching files in the diff. All feature evidence is written under the canonical `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/<kind>/` tree (baseline, qa-gates, regression-testing, issue-updates, other).

Verdict: PASS — no evidence-location violations.

---

## 1. General Unit Test Policy Compliance

PASS.

- **Independence / Isolation:** Python validator functions are pure (return error lists; no `sys.exit`, no disk writes except optional matrix load through an injectable seam). PowerShell hooks expose injectable scriptblock seams (`Invoker`, `CheckpointReader`, `FolderExistsCheck`) so tests run without spawning subprocesses or touching the real checkpoint.
- **Determinism:** No wall-clock, RNG, or sleep usage in changed code or tests. Subprocess and file-read paths are mocked via seams.
- **No temp files:** Tests use in-memory state and mock seams; no temporary-file creation observed in the changed test files.
- **AAA structure & scenario completeness:** Routing-contract tests cover positive (clean large-route → empty errors) and negative (unknown route, missing receipts, incomplete phases) flows. Sentinel-rejection matrix covers `n/a`, `none`, `tbd`, empty, whitespace, and non-digit values for `issue-num`, plus sentinel and non-`docs/features/active/` values for `feature-folder`. Edit read-then-validate covers missing-file and non-matching-patch allow paths.
- **Test file location:** All test files live under `tests/scripts/...` mirroring source; no colocation.

## 2. General Code Change Policy Compliance

PASS.

- **Simplicity & separation of concerns:** Pure routing-validation logic lives in `_orchestrator_state_routing.py`; PowerShell helpers extracted to `enforce-completion-helpers.ps1` to keep the consistency hook under 500 lines while isolating reusable predicates.
- **Reusability:** `_selected_route_id` shared by `route_requires_pr_gate` and `validate_route_membership`. `Test-IsValidIssueNum` / `Test-IsValidFeatureFolder` are reusable testable predicates.
- **Fail-fast:** Hooks return explicit named block messages (`ROUTING_CONTRACT_BLOCKED: ...`, `COMPLETION_CONSISTENCY_BLOCKED: ...`) rather than silently allowing.
- **File-size limit:** All changed production files under 500 lines (max 477).
- **No PowerShell reimplementation of Python routing logic:** `Invoke-RoutingContractValidation` delegates to the authoritative Python validator via subprocess seam.
- **Backward compatibility:** `requires_pr_gate` defaults false when absent; `MANDATORY_ROUTE_PHASES` omits routes with no defined set; strict route-membership opt-in preserved.

## 3. Language-Specific Code Change Policy Compliance

PASS.

- **Python:** Type annotations present on new functions; `cast` used for narrowed dict access; Pyright clean (0 errors). Black and Ruff clean. Docstrings follow the Purpose/Args/Returns/Raises/Side-Effects convention.
- **PowerShell:** `[CmdletBinding()]`, `[OutputType()]`, parameter validation present; comment-based help on new functions; PSScriptAnalyzer clean at Warning+Error severities.

## 4. Language-Specific Unit Test Policy Compliance

PASS.

- **Python (Pytest):** Routing-contract, route-membership, route-driven `pr_gate`, phase-completeness, and CLI `--require-complete` subprocess tests present. 51 targeted tests pass.
- **PowerShell (Pester):** Subprocess-seam block/allow, sentinel matrix, Edit read-then-validate, and routing-matrix `pr_gate` lookup tests present. 95 tests pass.

## 5. Test Coverage Detail

| File | Line Coverage | Branch/Command Coverage | Threshold | Verdict |
|------|---------------|-------------------------|-----------|---------|
| `scripts/dev_tools/_orchestrator_state_routing.py` (modified) | 91.3% (179/196) | 82.4% (84/102) branch | line >=85% / branch >=75% | PASS |
| `scripts/dev_tools/validate_orchestrator_state.py` (modified) | 97.3% (144/148) | 92.7% (76/82) branch | line >=85% / branch >=75% | PASS |
| Python repo-wide | 85.7% (7425/8661) | 75.0% (2326/3102) branch | line >=85% / branch >=75% | PASS |
| `.claude/hooks/enforce-completion-consistency.ps1` (modified) | 91.7% (110/120) | 93.4% command (141/151) | line >=85% / branch >=75% | PASS |
| `.claude/hooks/enforce-completion-helpers.ps1` (new) | 93.0% (40/43) | 94.5% command (52/55) | line >=85% / branch >=75% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified) | 87.3% (62/71) | 88.1% command (74/84) | line >=85% / branch >=75% | PASS |
| `.claude/hooks/validate-orchestrator-output.ps1` (modified) | 87.0% (80/92) | 88.9% command (144/162) | line >=85% / branch >=75% | PASS |

No regression on changed lines: all changed files exceed both thresholds with margin; the threshold check is absolute, so no baseline at or below post-change figures can show regression. Repo-wide Python branch coverage sits exactly at the 75.0% floor — PASS but with no margin (see Section 8).

## 6. Test Execution Metrics

- Python: 51 targeted tests, 0 failures, ~0.08s (parity + routing-contract + validator + artifacts CLI suites).
- PowerShell: 95 tests, 0 failures, ~3.2s across three changed hook test files.

## 7. Code Quality Checks

| Check | Command | Result |
|-------|---------|--------|
| Python format | `python -m black --check scripts/dev_tools/{_orchestrator_state_routing,validate_orchestrator_state,validate_orchestration_artifacts}.py` | PASS (3 files unchanged) |
| Python lint | `python -m ruff check <same files>` | PASS (All checks passed!) |
| Python type | `npx pyright <same files>` | PASS (0 errors, 0 warnings) |
| Python test | `python -m pytest tests/scripts/dev_tools/{parity,routing_contract,state,artifacts}.py -q` | PASS (51 passed) |
| PowerShell analyze | `Invoke-ScriptAnalyzer -Severity Warning,Error` (4 hooks) | PASS (NO WARNINGS OR ERRORS) |
| PowerShell test | `Invoke-Pester` (3 changed hook test files) | PASS (95 passed) |
| JSON parity | `pytest test_orchestration_routing_config_parity.py` + `diff` + SHA256 | PASS (byte-identical) |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | PASS (exit 0) |
| File-size limit | `wc -l` on changed production files | PASS (max 477 < 500) |

## 8. Gaps and Exceptions

- **Python repo-wide branch coverage at floor:** Repo-wide Python branch coverage is 75.0%, exactly the 75% floor with no margin. This is a PASS but a single removed test elsewhere could drop it below threshold. Per-changed-file branch coverage carries margin (82.4% and 92.7%). Informational, not a finding.
- **PowerShell branch coverage proxy:** Pester JaCoCo emits no BRANCH counter; command (INSTRUCTION) coverage is used as the documented branch proxy. This is an inherent tooling limitation, not a feature defect.
- **Canonical PowerShell coverage artifact does not contain the changed hooks:** `artifacts/pester/powershell-coverage.xml` reports all four hooks NOT PRESENT; the combined `feature253-review-coverage.xml` is authoritative. Documented and resolved; not a finding.
- **Gap 6 (audit trail):** Explicitly deferred and out of scope per spec.md and user-story.md Non-Goals. Not a gap against this feature's Definition of Done.

## 9. Summary of Changes

16 core-logic files (4 PowerShell hooks + 4 mirrors, 2 Python validators, 2 JSON files + 6 test files) plus feature/evidence documentation. The R4 delta (commit `05a44de`) is a single-line removal of `collect_commit_context` from `required_mcp_tools` in each of the two routing JSON files, plus the addition of spec AC8 and prior review artifacts. No validation logic changed in the second commit; `required_mcp_tools` is read generically by the routing-contract validator.

## 10. Compliance Verdict

PASS. All required toolchains pass check-only, coverage meets thresholds for every language with changed files, file-size and byte-identical-parity invariants hold, the `"232"` literals and `ISSUE_232`/`ISSUE_232_BRANCH` constants are removed, AC8's `collect_commit_context` removal is verified against the allow list, and no policy violations were found. No blocking or partial findings. Remediation is not required.

## Appendix A: Test Inventory

Python (`tests/scripts/dev_tools/`):
- `test_orchestration_routing_config_parity.py` — byte-identical mirror guard.
- `test_validate_orchestrator_state_routing_contract.py` — clean large-route positive; unknown-route, missing-receipt, incomplete-phase negatives; `required_mcp_tools` read generically (covers AC8).
- `test_validate_orchestrator_state.py` — `validate_route_membership`, route-driven `pr_gate`, phase-completeness pass/fail.
- `test_validate_orchestration_artifacts.py` — CLI `--require-complete` subprocess entry.

PowerShell (`tests/scripts/claude-hooks/`):
- `validate-orchestrator-output.Tests.ps1` — routing-validator subprocess block/allow via mocked seam.
- `enforce-completion-consistency.Tests.ps1` — sentinel-rejection matrix, feature-folder validation, Edit read-then-validate, routing-matrix `pr_gate` lookup.
- `enforce-orchestration-preimplementation-gate.Tests.ps1` — generalized (de-#232) assertions.

## Appendix B: Toolchain Commands Reference

```
# Scope
git diff --name-status 1ea8d87c5ffb9daf671eb33bc22b6d56be4d0ec6..05a44de
git merge-base HEAD origin/main

# Parity (AC6/AC8)
diff config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json
sha256sum config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json
python -m pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py -q

# AC4 (#232 removal)
grep -n "232" .claude/hooks/enforce-completion-consistency.ps1 .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
grep -n "ISSUE_232\|232" scripts/dev_tools/validate_orchestrator_state.py

# AC8 (collect_commit_context removal + allow-list confirmation)
grep -rn "collect_commit_context" config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json
grep -n "collect_commit_context" .claude/settings.json

# Python toolchain
python -m black --check scripts/dev_tools/_orchestrator_state_routing.py scripts/dev_tools/validate_orchestrator_state.py scripts/dev_tools/validate_orchestration_artifacts.py
python -m ruff check <same files>
npx pyright <same files>
python -m pytest tests/scripts/dev_tools/{test_orchestration_routing_config_parity,test_validate_orchestrator_state_routing_contract,test_validate_orchestrator_state,test_validate_orchestration_artifacts}.py -q

# PowerShell toolchain
Invoke-ScriptAnalyzer -Path <4 hooks> -Severity Warning,Error
Invoke-Pester -Path tests/scripts/claude-hooks/{enforce-completion-consistency,validate-orchestrator-output,enforce-orchestration-preimplementation-gate}.Tests.ps1

# Coverage (inspected, not re-run)
# Python: artifacts/python/lcov.info
# PowerShell: artifacts/pester/feature253-review-coverage.xml

# Evidence locations + file-size
python scripts/dev_tools/validate_evidence_locations.py --root .
wc -l <changed production files>
```
