# Policy Compliance Audit: Issue #552 routed-subagent attestation re-review

**Audit Date:** 2026-08-26
**Code Under Test:** Branch `bug/codex-subagent-routing-attestation-launch-binding-552` at `5697e55979ad9834a001ca2fe06f0ea66e64b983`, compared with `origin/main` at `b5a7490b685a08584ab618a1debfed7ba4417a32` from merge base `66c648db3ecae063ef873b3e76b00ca0d9fb7944`.

## Executive Summary

The review covers the full feature-vs-base range: 158 changed files, including Python, PowerShell, TypeScript, TOML, and JSON changes. Existing final QA evidence was inspected rather than rerun, consistent with the requested no-replay constraint. Python, PowerShell, and TypeScript format, lint, type, test, and coverage evidence passed; source/bundle parity and `git diff --check` also passed.

The audit is **PARTIALLY COMPLIANT** because modified test file `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` has 541 lines. The cross-language policy sets a 500-line maximum for test files. This structural violation requires remediation despite otherwise passing functional evidence.

**Policy documents evaluated:**

- [PASS] `AGENTS.md` general code-change and unit-test policies.
- [PASS] `.agents/skills/python/SKILL.md`.
- [PASS] `.agents/skills/powershell/SKILL.md`.
- [PASS] `.agents/skills/typescript/SKILL.md`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---:|---|---|---|---|---|
| Python | 9 | 41 focused pytest | PASS | 93% combined | 93% combined; resolver 100%, generator 89% | N/A: no new executable module |
| PowerShell | 1 test and 2 settings copies | 3,585 Pester passed | PASS | 96.14% lines | 96.14% lines | N/A: no new executable module |
| TypeScript | 3 | 195 suites, 2,660 Jest tests | PASS | 96.66% repository lines | 96.66% repository; changed validator 95.67% | 95.67% changed validator |
| TOML/JSON/Markdown | 145 | Static/parity checks | PASS | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/remediation-baseline/mcp-validator-parity-typescript-test-coverage.2026-08-25T22-29.md`
- TypeScript post-change coverage artifact: `evidence/qa-gates/claude-config-carriage-typescript-unit-coverage.2026-08-25T22-43.md`
- PowerShell baseline coverage artifact: `evidence/baseline/powershell-test-coverage.2026-08-25T15-25.md`
- PowerShell post-change coverage artifact: `evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md`
- Per-language comparison summary: `evidence/qa-gates/coverage-comparison.2026-08-25T17-00-20.md` and the three current QA coverage artifacts cited above.

## 1. General Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Independence, isolation, determinism, readability | PASS | Focused pytest cases isolate resolver and generator selections; Pester and Jest suites passed with no external-service dependency reported in the reviewed evidence. |
| Positive, negative, and boundary scenarios | PASS | `model-profile-attestation.Tests.ps1` covers durable exact receipt and absent/generic/mismatched receipt rejection; resolver tests cover standalone, nested, and C3-elevated selection. |
| Baseline and post-change coverage documented | PASS | Python: `evidence/qa-gates/commit-steward-routing-python-test-coverage.2026-08-25T22-08.md`; PowerShell: `evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md`; TypeScript: `evidence/qa-gates/claude-config-carriage-typescript-unit-coverage.2026-08-25T22-43.md`. |
| Test file size <=500 lines | FAIL | `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` is 541 lines in the reviewed head; the repository-wide limit applies to test files. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93% combined lines -> Post-change: 93% combined lines. Change: +0% combined lines. New/changed-code coverage: 100% resolver lines; 89% generator lines. Disposition: PASS. Evidence: `evidence/qa-gates/commit-steward-routing-python-test-coverage.2026-08-25T22-08.md`.
- PowerShell: Baseline: 96.14% lines -> Post-change: 96.14% lines. Change: +0.00% lines. New/changed-code coverage: N/A (no new executable module). Disposition: PASS. Evidence: `evidence/baseline/powershell-test-coverage.2026-08-25T15-25.md` and `evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md`.
- TypeScript: Baseline: 96.66% repository lines -> Post-change: 96.66% repository lines. Change: +0.00% repository lines. New/changed-code coverage: 95.67% validator lines. Disposition: PASS. Evidence: `evidence/remediation-baseline/mcp-validator-parity-typescript-test-coverage.2026-08-25T22-29.md` and `evidence/qa-gates/claude-config-carriage-typescript-unit-coverage.2026-08-25T22-43.md`.

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Scoped objective and documented plan | PASS | Issue #552 `spec.md`, `plan.2026-08-25T14-58.md`, and `remediation-plan.2026-08-25T17-20.md` describe exact-profile routing, registry carriage, and verification boundaries. |
| Simplicity, separation of concerns, and explicit failures | PASS | The resolver family list is extended consistently across Python, TypeScript, configuration, generated profiles, and bundle manifest; hooks retain fail-closed validation. |
| No new dependency or public API expansion | PASS | Diff inspection found no dependency additions and no public CLI/API expansion. |
| Files <=500 lines | FAIL | Modified test file `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` is 541 lines. |
| No secret-like assignment added | PASS | `git diff --unified=0` search for added password, secret, token, or API-key assignments produced no results. |
| Whitespace and conflict markers | PASS | `git diff --check 66c648db3ecae063ef873b3e76b00ca0d9fb7944..HEAD` exited 0. |

## 3. Language-Specific Code Change Policy Compliance

### Python

| Requirement | Status | Evidence |
|---|---|---|
| Black, Ruff, Pyright, pytest | PASS | Final evidence records Black unchanged, Ruff pass, Pyright 0 errors/warnings/information, and pytest 41 passed. |
| Strong typing and explicit failures | PASS | `resolve_codex_deployment.py` preserves typed receipt selection and explicit invalid-routing rejection tests. |
| Modified test file size | FAIL | `test_push_down_codex_and_agents_customizations.py` is 541 lines. |

### PowerShell

| Requirement | Status | Evidence |
|---|---|---|
| PoshQC format and analyzer | PASS | `powershell-format.2026-08-25T21-47.md` and `powershell-analyze.2026-08-25T21-47.md` record exit code 0 and zero diagnostics. |
| Pester coverage | PASS | `powershell-test-coverage.2026-08-25T21-51.md` records 3,585 passed and 96.14% line coverage. |
| Source/bundle settings parity | PASS | Current SHA-256 comparison confirms both `pester.runsettings.psd1` copies are identical. |

### TypeScript

| Requirement | Status | Evidence |
|---|---|---|
| Prettier, ESLint, typecheck, build, Jest coverage | PASS | Final TypeScript evidence at `evidence/qa-gates/claude-config-carriage-typescript-*.2026-08-25T22-4*.md` records exit code 0 for each step. |
| Typed routing validation | PASS | `orchestrator-state-codex-model-routing.ts` adds `commit-steward` to the generated-family set and its dedicated Jest test passes with 95.67% line coverage. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Status | Evidence |
|---|---|---|
| Python | PARTIAL | Behavioral coverage and toolchain pass, but the changed pytest file exceeds the 500-line test-file limit. |
| PowerShell | PASS | Pester start-time routing coverage and full PoshQC Pester coverage passed. |
| TypeScript | PASS | Dedicated deployment and checkpoint validator cases pass in the full 195-suite coverage run. |

## 5. Test Coverage Detail

Coverage requirements are met for all changed languages. The Python generator's 89% line coverage is compliant because it is a modified existing module, its combined baseline and post-change coverage are both 93%, and policy requires >=80% with no regression for modified files. No new executable module is below the 90% target.

## 6. Test Execution Metrics

| Metric | Value | Status |
|---|---:|---|
| Python focused tests | 41 passed | PASS |
| PowerShell Pester | 3,585 passed; 0 failed; 9 skipped | PASS |
| TypeScript Jest | 195 suites; 2,660 passed; 0 failed | PASS |
| Full QA replay in this re-review | Not run | Intentional: completed exact-head QA evidence was inspected under the no-replay constraint. |

## 7. Code Quality Checks

| Check | Command / evidence | Status |
|---|---|---|
| Python format/lint/type/test | `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest` evidence at `commit-steward-routing-python-*.2026-08-25T22-08.md` | PASS |
| PowerShell format/analyze/test | PoshQC evidence at `powershell-*.2026-08-25T21-*.md` | PASS |
| TypeScript format/lint/type/test | `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:coverage` evidence at `claude-config-carriage-typescript-*.2026-08-25T22-4*.md` | PASS |
| Root/bundle parity | Current SHA-256 comparison of generated profile, routing JSON triplet, and Pester settings mirror | PASS |
| File-size limit | Current line-count inspection | FAIL |

## 8. Gaps and Exceptions

### Identified Gaps

- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` is 541 lines. Split the test coverage into cohesive files without weakening assertions, then rerun the affected Python format, lint, type, test, and coverage loop.

### Approved Exceptions

None. The file-size policy has no applicable exception for this tracked test file.

### Rejected Scope Narrowing

None. The audit reviewed the full feature-vs-base range and coverage status for every changed language.

## 9. Summary of Changes

Commits reviewed: `cacb27f3 fix(codex): bind routed subagents to exact profiles`; `58e9762e docs(review): record routing attestation audit`; `62bb99f2 docs(pr): add routing attestation description`; `5697e559 feat(routing): add commit-steward deployment profiles`.

The branch adds deterministic `commit-steward` C1-C4 generated profiles and registration, mirrors those files into the bundle, includes the family in Python and TypeScript deterministic routing validators, adds exact-profile regressions, and extends Pester coverage registration for the start-time routing hook.

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

Functional and coverage gates are supported by passing exact-head QA evidence, but the modified 541-line Python test file violates the repository's mandatory 500-line limit. PR readiness requires remediation of that structural finding.

## Appendix A: Test Inventory

- `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1`: exact receipt admission and absent/generic/model/reasoning/path/SHA rejection.
- `tests/scripts/dev_tools/test_resolve_codex_deployment.py`: standalone and context/ceiling-specific C3 selection, including `commit-steward-c3`.
- `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`: generated profile and bundle parity.
- `extensions/drm-copilot/test/lib/validate/codex-deployment.test.ts`: TypeScript commit-steward selection.
- `extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts`: checkpoint receipt acceptance for `commit-steward-c3`.

## Appendix B: Toolchain Commands Reference

```text
poetry run black <changed Python scope>
poetry run ruff check <changed Python scope>
poetry run pyright <changed Python scope>
poetry run pytest <changed Python scope> --cov --cov-branch
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test
npm run format
npm run lint
npm run typecheck
npm run test:coverage
git diff --check 66c648db3ecae063ef873b3e76b00ca0d9fb7944..HEAD
```

**Audit Completed By:** feature-reviewer
**Audit Date:** 2026-08-26
