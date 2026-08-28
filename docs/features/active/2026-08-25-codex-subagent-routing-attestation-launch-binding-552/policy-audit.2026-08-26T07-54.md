# Policy Compliance Audit: routed-subagent attestation launch binding (#552)

**Audit Date:** 2026-08-26
**Code Under Test:** Full branch range `66c648db3ecae063ef873b3e76b00ca0d9fb7944..62972ab13b1917b019a70c20ed62b75cab6127c0`, including Python, PowerShell, TypeScript, TOML, JSON, configuration, generated-profile, and bundled-customization changes.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 11 files | 9 remediation tests | 9 pass, 0 fail | 93.48% lines | 93.48% lines | 93.48% lines |
| PowerShell | 3 files | 3,585 Pester tests | 3,585 pass, 0 fail | 96.14% lines | 96.14% lines | 96.14% lines |
| TypeScript | 3 files | 2,660 Jest tests | 2,660 pass, 0 fail | 96.66% lines | 96.66% lines | 95.67% lines |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/qa-gates/mcp-validator-parity-typescript-unit-coverage.2026-08-25T22-34.md`
- TypeScript post-change coverage artifact: `evidence/qa-gates/claude-config-carriage-typescript-unit-coverage.2026-08-25T22-43.md`
- PowerShell baseline coverage artifact: `evidence/qa-gates/final-powershell-test-coverage.2026-08-25T16-57-53.md`
- PowerShell post-change coverage artifact: `evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md`
- Per-language comparison summary: Section 1.2.1

## Executive Summary

**PASS.** This exit re-review covers the full feature-versus-`origin/main` range, using `artifacts/pr_context.summary.txt` as primary evidence and `artifacts/pr_context.appendix.txt` as the diff appendix. The prior 541-line Python test-file finding has been remediated at the current head by a cohesive in-memory test split. All changed executable files are at most 500 lines. The branch has two commits not yet present on its remote PR branch; that publication state is outside this policy verdict.

Policy documents evaluated: `AGENTS.md`; the cross-language code-change and unit-test sections in `AGENTS.md`; `.agents/skills/python/SKILL.md`; `.agents/skills/powershell/SKILL.md`; and `.agents/skills/typescript/SKILL.md`.

| Language | Files Changed | Test Result | Coverage evidence | Verdict |
|---|---:|---|---|---|
| Python | 11 | 9 remediation tests passed; prior aggregate 60 passed | Modified publisher: 93.48% lines, equal to baseline; prior aggregate: 93% | PASS |
| PowerShell | 3 | 3,585 passed; 0 failed | 96.14% lines | PASS |
| TypeScript | 3 | 195 suites, 2,660 tests passed | Repository: 96.66%; changed validator: 95.67% lines | PASS |

## 1. General Unit Test Policy Compliance

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 93.48% lines -> Post-change: 93.48% lines. Change: 0.00% lines. New/changed-code coverage: 93.48%. Disposition: PASS. Evidence: `evidence/remediation-baseline/python-test-coverage.2026-08-26T07-26.md`; `evidence/qa-gates/python-test-coverage.2026-08-26T07-26.md`.
- PowerShell: Baseline: 96.14% lines -> Post-change: 96.14% lines. Change: 0.00% lines. New/changed-code coverage: 96.14%. Disposition: PASS. Evidence: `evidence/qa-gates/final-powershell-test-coverage.2026-08-25T16-57-53.md`; `evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md`.
- TypeScript: Baseline: 96.66% lines -> Post-change: 96.66% lines. Change: 0.00% lines. New/changed-code coverage: 95.67%. Disposition: PASS. Evidence: `evidence/qa-gates/mcp-validator-parity-typescript-unit-coverage.2026-08-25T22-34.md`; `evidence/qa-gates/claude-config-carriage-typescript-unit-coverage.2026-08-25T22-43.md`.

| Requirement | Status | Evidence |
|---|---|---|
| Independence, isolation, determinism, and readability | PASS | New Python test support uses an in-memory filesystem; targeted tests remain single-behavior pytest/Pester/Jest cases with descriptive names. |
| No temporary files or external test dependencies | PASS | Diff inspection of changed tests shows in-memory test support and no temporary-file fixture or network dependency. |
| Scenario coverage | PASS | Pester covers exact, absent, generic, model, reasoning, path, and SHA mismatches. Python and TypeScript tests cover generated commit-steward routing, bundle parity, and payload exclusion. |
| Coverage thresholds and no regression | PASS | Python remediation evidence records 93.48% lines equal to baseline; PowerShell records 96.14%; TypeScript records 96.66% repository and 95.67% changed validator coverage. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Scoped and documented objective | PASS | Issue #552 `spec.md`, plan, PR context, and audited commits define exact-profile routing and customization payload boundaries. |
| Separation of concerns and explicit failures | PASS | Resolver inventory, profile generation, publisher filtering, validator inventory, and test support have distinct responsibilities; enforcement remains fail-closed. |
| No unapproved dependency or public API expansion | PASS | Full diff inspection found no dependency changes or public API addition. |
| File-size limit | PASS | Current line-count inspection covered every changed executable/configuration file; maximum is 453 lines for `orchestrator-state-codex-model-routing.ts`. The split Python files are 77, 218, and 174 lines. |
| Whitespace/conflict errors | PASS | `git diff --check 66c648db3ecae063ef873b3e76b00ca0d9fb7944..HEAD` exited 0. |

## 3. Language-Specific Code Change Policy Compliance

### Python

| Requirement | Status | Evidence |
|---|---|---|
| Black, Ruff, Pyright, and pytest | PASS | `evidence/qa-gates/python-black.2026-08-26T07-26.md`, `python-ruff.2026-08-26T07-26.md`, `python-pyright.2026-08-26T07-26.md`, and `python-test-coverage.2026-08-26T07-26.md` record exit code 0. |
| Typed and cohesive implementation | PASS | The resolver's generated-family extension is typed; `ExcludingFileSystem` centralizes `.codex/state/` exclusion; test support centralizes in-memory fixtures. |
| File-size remediation | PASS | `push_down_customizations_test_support.py` is 77 lines; the two split test modules are 218 and 174 lines. |

### PowerShell

| Requirement | Status | Evidence |
|---|---|---|
| Formatting, analyzer, and Pester | PASS | Recorded PoshQC format/analyze results are clean; Pester evidence records 3,585 passed, 0 failed, and 96.14% line coverage. |
| Start-time routing enforcement coverage | PASS | `model-profile-attestation.Tests.ps1` tests valid start, absent receipt, generic alias, model, reasoning, profile-path, and SHA mismatch paths. |

### TypeScript

| Requirement | Status | Evidence |
|---|---|---|
| Prettier, ESLint, typecheck, build, and Jest coverage | PASS | `claude-config-carriage-typescript-*.2026-08-25T22-4*.md` records exit code 0; the full Jest suite has 195 passing suites and 2,660 passing tests. |
| Exact-family validator support | PASS | The validator admits the configured `commit-steward` generated family and dedicated tests exercise valid and invalid receipts. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Status | Evidence |
|---|---|---|
| Python | PASS | Deterministic in-memory tests, final remediation loop, coverage equality to baseline, and all changed test/support files under 500 lines. |
| PowerShell | PASS | Pester start-time routing coverage and full PoshQC coverage passed. |
| TypeScript | PASS | Full unit-coverage run passes with direct deployment and checkpoint-validator coverage. |

## 5. Test Coverage Detail

- Python baseline and post-remediation publisher coverage are both 93.48% line and 87.50% branch coverage: `evidence/remediation-baseline/python-test-coverage.2026-08-26T07-26.md` and `evidence/qa-gates/python-test-coverage.2026-08-26T07-26.md`.
- PowerShell post-change coverage is 96.14%: `evidence/qa-gates/powershell-test-coverage.2026-08-25T21-51.md`.
- TypeScript repository coverage is 96.66%; the changed routing validator is 95.67% line and 93.81% branch coverage: `evidence/qa-gates/claude-config-carriage-typescript-unit-coverage.2026-08-25T22-43.md`.

## 6. Test Execution Metrics

| Metric | Value | Status |
|---|---:|---|
| Python remediation scope | 9 passed; 0 failed | PASS |
| Python aggregate scope | 60 passed | PASS |
| PowerShell Pester | 3,585 passed; 0 failed; 9 skipped | PASS |
| TypeScript Jest | 195 suites; 2,660 passed; 0 failed | PASS |
| Re-review execution | No QA replay | PASS: approved constraint met by inspecting current-head evidence committed at `62972ab1`. |

## 7. Code Quality Checks

| Check | Status | Evidence |
|---|---|---|
| Python final remediation loop | PASS | Black, Ruff, Pyright, pytest coverage evidence at `evidence/qa-gates/python-*.2026-08-26T07-26.md`. |
| PowerShell final loop | PASS | PoshQC evidence at `evidence/qa-gates/powershell-*.2026-08-25T21-*.md`. |
| TypeScript final loop | PASS | TypeScript evidence at `evidence/qa-gates/claude-config-carriage-typescript-*.2026-08-25T22-4*.md`. |
| Root/bundle/config mirror parity | PASS | Current SHA-256 checks match for the commit-steward profile pair, all routing-config copies, and both Pester settings copies. |
| Diff integrity | PASS | `git diff --check` exit code 0. |

## 8. Gaps and Exceptions

**None.** The prior test-file size finding is resolved. No policy exception is required.

## 9. Summary of Changes

The branch adds `commit-steward` as a generated deployment family, ships its C1-C4 profile variants and bundle entries, validates the family in Python and TypeScript, covers attestation rejection paths in Pester, excludes ephemeral `.codex/state/` content from customization payloads, and splits the previously oversized Python test file without removing assertions.

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All policy findings in the prior re-review are resolved. This is a policy go for the normal PR push and CI stages; it is not merge authorization.

## Appendix A: Test Inventory

- `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1` — start-time exact receipt and mismatch rejection coverage.
- `tests/scripts/dev_tools/test_resolve_codex_deployment.py` — generated profile selection.
- `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` — generated profile and bundle parity.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` and `test_push_down_codex_and_agents_variant_packs.py` — customization exclusion and pack behavior.
- `extensions/drm-copilot/test/lib/validate/codex-deployment.test.ts` and `orchestrator-state-codex-model-routing.test.ts` — TypeScript validator coverage.

## Appendix B: Toolchain Commands Reference

```text
poetry run black <remediation Python scope>
poetry run ruff check <remediation Python scope>
poetry run pyright <remediation Python scope>
poetry run pytest <remediation Python scope> --cov=scripts.dev_tools.push_down_codex_filesystem --cov-branch --cov-report=term-missing
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test
npm run format
npm run lint
npm run typecheck
npm run test:coverage
git diff --check 66c648db3ecae063ef873b3e76b00ca0d9fb7944..HEAD
```
