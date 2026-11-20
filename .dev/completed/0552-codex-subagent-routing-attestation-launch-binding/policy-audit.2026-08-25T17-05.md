# Policy Compliance Audit: Issue #552 routed-subagent launch binding

**Audit Date:** 2026-08-25
**Reviewed range:** `main` (`66c648db3ecae063ef873b3e76b00ca0d9fb7944`) to `cacb27f3af2c0c2d56aeb9b9663fbe15b67a8865`
**Code Under Test:** routing skill and generated orchestrator profiles; `scripts/dev_tools/push_down_codex_filesystem.py`; Pester run settings; associated Python and PowerShell regression tests.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------:|-------|-------------|-------------------|----------------------|-------------------|
| Python | 1 production, 4 test files | pytest | PASS: 60 passed | 93% aggregate headline | 94.16% lines, 87.50% branches | 100% resolver; 93.48% push-down lines |
| PowerShell | 1 settings, 1 test file | Pester | PASS: 9 passed | 0.00% (0/0 configured target lines) | 0.00% (0/0 configured target lines) | N/A: no PowerShell production lines changed |
| TOML/Markdown | 21 routing/configuration files | parity/drift checks | PASS | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `N/A - out of scope`
- TypeScript post-change coverage artifact: `N/A - out of scope`
- PowerShell baseline coverage artifact: `evidence/baseline/powershell-test-coverage.2026-08-25T15-25.md`
- PowerShell post-change coverage artifact: `evidence/qa-gates/final-powershell-test-coverage.2026-08-25T16-57-53.md`
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-08-25T17-00-20.md`

## Executive Summary

**Status: PASS.** The review found policy-compliant implementation and test changes. The branch records a final restarted single-pass QA loop with all required PowerShell and Python gates passing. Independent review checks on the requested commit also passed: `git diff --check`, scoped Black, Ruff, Pyright, and generated-profile drift verification.

Policies evaluated: `AGENTS.md`; general code-change and unit-test policy in `AGENTS.md`; `.agents/skills/python/SKILL.md`; `.agents/skills/powershell/SKILL.md`; `.agents/skills/codex-model-routing/SKILL.md`.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence, isolation, determinism, and readability | PASS | New pytest tests use in-memory filesystems and explicit routing inputs; Pester tests use fixed payload/checkpoint objects. |
| Positive and negative scenarios | PASS | Pester covers valid receipt admission and absent, alias, model, reasoning, path, and SHA rejection; pytest covers standalone, epic, and C4 resolver selection. |
| No temporary test files | PASS | Inspected test diff uses `RecordingFileSystem` and `Path` values only; no temporary-file API was added. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | The publish exclusion is a small source-relative predicate in `ExcludingFileSystem`; tests keep payload-contract assertions separate from publishing behavior. |
| Explicit failure behavior | PASS | Routing policy continues to require rejection of late receipts, aliases, validation/persistence failure, and `routing_valid: false`; no fail-open path was introduced. |
| File-size limit | PASS | Changed non-Markdown code/test/config files are 87–460 lines; all are below 500 lines. |
| Diff integrity | PASS | `git diff --check 66c648db3ecae063ef873b3e76b00ca0d9fb7944 cacb27f3af2c0c2d56aeb9b9663fbe15b67a8865` exited 0. |

## 3. Language-Specific Code Change Policy Compliance

### Python

| Requirement | Status | Evidence |
|---|---|---|
| Formatting | PASS | Review command: `poetry run black --check` over the eight scoped Python files; 8 files unchanged. |
| Linting | PASS | Review command: `poetry run ruff check` over the same files; all checks passed. |
| Type checking | PASS | Review command: `poetry run pyright` over the same files; 0 errors, warnings, or information messages. |
| Coverage | PASS | `evidence/qa-gates/coverage-comparison.2026-08-25T17-00-20.md`: changed push-down module 93.48% line coverage; changed resolver 100% line and branch coverage. |

### PowerShell

| Requirement | Status | Evidence |
|---|---|---|
| Formatting and analysis | PASS | `evidence/qa-gates/final-powershell-format.2026-08-25T16-56-46.md` and `final-powershell-analyze.2026-08-25T16-57-09.md` each record `EXIT_CODE: 0`. |
| Testing | PASS | `evidence/qa-gates/final-powershell-test-coverage.2026-08-25T16-57-53.md` records 9 Pester tests passing with no failures, errors, or skips. |
| Coverage interpretation | PASS | The hook had no changed production lines; baseline and final coverage both report the configured target as 0/0. The numeric baseline/final record is present and non-regressing. |

## 4. Language-Specific Unit Test Policy Compliance

| Area | Status | Evidence |
|---|---|---|
| Python regression tests | PASS | Final aggregate pytest evidence records 60 passing tests and 94.16% aggregate line coverage. |
| PowerShell regression tests | PASS | The dedicated Pester evidence records 9 passing tests and covers start-only routing-attestation decision paths. |
| Source/bundle parity | PASS | Generated-profile drift check exited 0; root and bundled SHA-256 hashes for the seven changed routing assets matched during this review. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93% aggregate headline -> Post-change: 94.16% lines, 87.50% branches. Change: +1.16% lines. New/changed-code coverage: 100% resolver lines/branches and 93.48% push-down lines. Disposition: PASS. Evidence: `evidence/baseline/python-test-coverage.2026-08-25T15-58.md`; `evidence/qa-gates/final-python-test-coverage.2026-08-25T16-59-34.md`; `evidence/qa-gates/coverage-comparison.2026-08-25T17-00-20.md`.
- PowerShell: Baseline: 0.00% (0/0 configured hook target lines) -> Post-change: 0.00% (0/0 configured hook target lines). Change: +0.00%. No PowerShell production lines changed. Disposition: PASS. Evidence: `evidence/baseline/powershell-test-coverage.2026-08-25T15-25.md`; `evidence/qa-gates/final-powershell-test-coverage.2026-08-25T16-57-53.md`; `evidence/qa-gates/coverage-comparison.2026-08-25T17-00-20.md`.

## 5. Test Coverage Detail

| Language | Baseline | Post-change | Changed/new-code coverage | Verdict |
|---|---:|---:|---:|---|
| Python | 93% reported aggregate headline | 94.16% lines, 87.50% branches | resolver 100% lines/branches; push-down 93.48% lines | PASS |
| PowerShell | 7 passed; 0/0 configured hook target lines | 9 passed; 0/0 configured hook target lines | No PowerShell production lines changed | PASS |

Evidence: `evidence/baseline/python-test-coverage.2026-08-25T15-58.md`, `evidence/qa-gates/final-python-test-coverage.2026-08-25T16-59-34.md`, and `evidence/qa-gates/coverage-comparison.2026-08-25T17-00-20.md`.

## 6. Test Execution Metrics

| Metric | Result | Status |
|---|---|---|
| Final Python aggregate | 60 passed | PASS |
| Final PowerShell Pester | 9 passed, 0 failed, 0 errors, 0 skipped | PASS |
| Final QA sequence | P6-T1 through P6-T7 all exited 0 after one documented restart | PASS |

## 7. Code Quality Checks

| Check | Result | Status |
|---|---|---|
| Git diff whitespace | Current review command exited 0 | PASS |
| Black / Ruff / Pyright | Current review checks passed | PASS |
| Generated-profile drift | Current `generate_codex_agent_variants --check` exited 0 | PASS |
| Final PowerShell QA | Recorded final format, analyze, and test commands exited 0 | PASS |

## 8. Gaps and Exceptions

None. The preserved earlier aggregate pytest failure is explicitly identified as superseded diagnostic evidence in `evidence/other/acceptance-criteria-reconciliation.2026-08-25T16-53-17.md`; it is not a final-QA failure.

## 9. Summary of Changes

- `cacb27f3af2c0c2d56aeb9b9663fbe15b67a8865` — `fix(codex): bind routed subagents to exact profiles`.
- Adds a durable, exact pre-launch routing-receipt contract to the routing skill and root/generated orchestrator profiles, synchronized to the extension bundle.
- Excludes ephemeral `.codex/state/**` paths from customization payloads while retaining publishable `.codex/**` and `.agents/**` paths.
- Adds Pester and pytest regression coverage for launch binding, resolver selection, source/bundle parity, and runtime-state exclusion.

## 10. Compliance Verdict

**Overall Status: FULLY COMPLIANT (PASS).** Required baseline, regression, coverage-comparison, and final-QA artifacts are present. No policy FAIL or meaningful PARTIAL finding was identified; remediation is not required.

## Appendix A: Test Inventory

- `model-profile-attestation.Tests.ps1` — exact receipt admission; absent/late receipt, generic alias, model, reasoning, profile-path, and SHA mismatch rejection.
- `test_resolve_codex_deployment.py` — standalone C3 and elevated C3 selection by context and ceiling.
- `test_codex_agent_wrapper_contracts.py` — durable receipt/profile contract and root/bundle equality.
- `test_push_down_codex_and_agents_customizations.py` and `test_push_down_codex_and_agents_resource_contracts.py` — ephemeral state exclusion and parity.

## Appendix B: Toolchain Commands Reference

```powershell
git diff --check 66c648db3ecae063ef873b3e76b00ca0d9fb7944 cacb27f3af2c0c2d56aeb9b9663fbe15b67a8865
poetry run black --check <scoped-python-files>
poetry run ruff check <scoped-python-files>
poetry run pyright <scoped-python-files>
poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test
```

**Audit Completed By:** feature-reviewer-c3
**Policy Version:** Current as of 2026-08-25
