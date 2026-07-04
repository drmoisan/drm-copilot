# Policy Compliance Audit: Codex Push-Down Language Packs (#269)

**Audit Date:** 2026-07-02
**Feature Folder:** `docs/features/active/2026-07-02-codex-push-down-language-packs-269`
**Base Branch:** `main`
**Base Ref:** `origin/main @ 51867789325248793a241886033c3ce86681f9ad`
**Head Branch:** `feature/codex-push-down-language-packs-269`
**Head Ref:** `4fd8353e7997b51f20942d4de11bc2ec28d24537`
**Merge Base:** `51867789325248793a241886033c3ce86681f9ad`
**Scope:** Full branch diff, not a plan subset.

**Code Under Test:** 72 changed files, including Python push-down scripts, TypeScript extension push-down implementation, MCP definitions, JSON pack manifests, TOML agent variants, documentation, tests, and feature evidence.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 6 `.py` files | Pytest | PASS, 1174 passed | 86% | 85.97% from `artifacts/python/lcov.info`; reported final summary 86% | 96.41% |
| TypeScript | 24 `.ts` files | Jest | PASS, 1416 passed | 96.76% | 96.80% from package-local `extensions/drm-copilot/coverage/lcov.info`; reported final summary 96.79% | FAIL for new file `codex-pack-selection.ts` at 85.43%; other changed TypeScript files range from 93.11% to 100% |
| JSON | 6 `.json` files | Resource and TypeScript tests | PASS | N/A | N/A | N/A |
| TOML | 2 `.toml` files | Resource and TypeScript tests | PASS | N/A | N/A | N/A |
| Markdown | 34 `.md` files | Artifact and line-count checks | PARTIAL | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/baseline/typescript-jest-coverage-baseline.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/typescript-jest-coverage-final.md`
- TypeScript lcov artifact inspected: `extensions/drm-copilot/coverage/lcov.info` (package-local `coverage/lcov.info`)
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed in the branch diff
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed in the branch diff
- Python baseline coverage artifact: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/baseline/python-pytest-coverage-baseline.md`
- Python post-change coverage artifact: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/python-pytest-coverage-final.md`
- Python lcov artifact inspected: `artifacts/python/lcov.info`
- Per-language comparison summary: `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/python-coverage-delta.md`; `docs/features/active/2026-07-02-codex-push-down-language-packs-269/evidence/qa-gates/typescript-coverage-delta.md`

## Executive Summary

The implementation and QA evidence show passing Python and TypeScript toolchains and coverage above repository thresholds. The review still finds policy non-compliance requiring remediation before PR readiness:

- `python scripts/dev_tools/validate_evidence_locations.py --root .` failed because `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md` exists outside the canonical feature-folder evidence/research locations.
- Two modified TypeScript production files exceed the 500-line file-size limit: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` is 501 lines and `extensions/drm-copilot/src/workflow-command-arguments.ts` is 662 lines.
- The documented C# CLI/API selection path uses `--packs core,csharp --csharp-variant legacy`, but the Python and TypeScript pack selectors accept `csharp-modern` and `csharp-legacy` instead of `csharp`.
- The Copilot MCP schema was expanded with Codex-specific `packs`, `csharp_variant`, and `memory_mode` fields even though the feature scope is Codex push-down.

**Policy documents evaluated:**
- PASS `AGENTS.md`
- PASS `.agents/skills/policy-compliance-order/SKILL.md`
- PASS `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- PASS `.agents/skills/policy-audit-template-usage/SKILL.md`
- PASS `.agents/skills/feature-review-workflow/SKILL.md`
- PASS `.agents/skills/acceptance-criteria-tracking/SKILL.md`

**Language-specific policies evaluated:**
- PASS Python policy via `AGENTS.md`, `.agents/skills/python/SKILL.md`, `.agents/skills/python-suppressions/SKILL.md`
- PASS TypeScript policy via `AGENTS.md`, `.agents/skills/typescript/SKILL.md`, `.agents/skills/typescript-suppressions/SKILL.md`
- N/A PowerShell, C#, Bash: no changed source files in those languages

**Temporary artifacts cleanup:**
- PARTIAL. The validator found `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md`; remediation must relocate or remove the non-canonical research artifact and update references.

## Rejected Scope Narrowing

No caller-supplied scope narrowing was detected. The review used the full branch diff from merge base `51867789325248793a241886033c3ce86681f9ad` to head `4fd8353e7997b51f20942d4de11bc2ec28d24537`.

## Evidence Location Compliance

FAIL. The evidence-location validator reported a non-canonical research artifact:

| Path | Validator Result | Canonical Replacement |
|---|---|---|
| `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md` | `VIOLATION: ... use docs/features/active/<feature>/research/ or docs/research/ instead` | `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md` or `docs/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md` |

Command evidence:

```powershell
python scripts/dev_tools/validate_evidence_locations.py --root .
```

Result: exit code 1.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|---|---|---|
| Independence | PASS | Python and TypeScript tests use in-memory filesystems and isolated helper inputs in the added push-down test suites. |
| Isolation | PASS | Added test files target pack parsing, filesystem filtering, service forwarding, MCP input resolution, and command selection separately. |
| Fast Execution | PASS | Final evidence reports `1174 passed in 4.73s` for Python and `1416 passed` across 120 Jest suites. |
| Determinism | PASS | Tests use deterministic in-memory fixtures and mocked VS Code prompt results. |
| Readability and maintainability | PASS | Test names describe behavior such as selected TypeScript pack filtering, legacy C# routing, and invalid field rejection. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|---|---|---|
| Baseline Coverage Documented | PASS | Python baseline 86%; TypeScript baseline 96.76%. Evidence paths listed in the checklist. |
| No Coverage Regression | PASS | Python final 85.97% from lcov and reported 86%; TypeScript final 96.80% from lcov and reported 96.79%. TypeScript coverage increased relative to baseline. Python rounded summary stayed at 86%. |
| New Code Coverage >=90% | PARTIAL | Python changed-code coverage is 96.41%. TypeScript package lcov shows one new file, `src/lib/push-down/codex-pack-selection.ts`, at 85.43%, below the 90% new-file threshold. |
| Comprehensive Coverage | PARTIAL | Functional coverage is broad, but the documented `--packs core,csharp --csharp-variant legacy` path is not covered. Tests use `csharp-legacy` pack names directly. |
| Positive Flows | PASS | Evidence covers no-argument push-down, selected TypeScript pack, legacy C# variant routing, service forwarding, MCP input forwarding, and VS Code command selection. |
| Negative Flows | PASS | Evidence covers unknown packs, malformed and missing manifests, mutual exclusion, invalid MCP field shapes, and VS Code cancellation. |
| Edge Cases | PASS | Evidence covers omitted and empty pack selections, automatic core inclusion, variant root exclusion, and inert memory mode. |
| Error Handling | PASS | `ManifestError` paths and MCP input validation errors are covered. |
| Concurrency | N/A | No concurrent behavior is introduced. |
| State Transitions | PASS | VS Code command prompt cancellation and service invocation state are tested. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 86.00% lines. Post-change: 85.97% lines. Change: -0.03 percentage points by parsed lcov and 0.00 percentage points by rounded evidence summary. New/changed-code coverage: 96.41%. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `python-coverage-delta.md`.
- TypeScript: Baseline: 96.76% lines. Post-change: 96.80% lines. Change: +0.04 percentage points by parsed lcov. New/changed-code coverage: 85.43% for new file `src/lib/push-down/codex-pack-selection.ts`. Disposition: FAIL for new-file threshold, PASS for repo-wide threshold. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `typescript-coverage-delta.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Clear Failure Messages | PASS | Validation errors are asserted against specific messages for invalid pack, variant, and memory fields. |
| Arrange-Act-Assert Pattern | PASS | Added Python and TypeScript tests follow explicit setup, operation, and assertion structure. |
| Document Intent | PASS | Python tests include descriptive docstrings; TypeScript `it(...)` names describe the expected behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| Avoid External Dependencies | PASS | Tests use in-memory filesystem fixtures and mocked command/service boundaries. |
| Use Mocks/Stubs | PASS | VS Code prompt and push-down filesystem dependencies are mocked or stubbed. |
| Environment Stability | PASS | Final QA evidence is deterministic and completed with exit code 0. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Pre-submission Review | PASS | This artifact is the required policy review for issue #269. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | Issue #269 and feature docs define Codex language-pack and C# variant selection. |
| Read existing change plans | PASS | `plan.2026-07-02T13-20.md` is the implementation plan of record. |
| Document the plan | PASS | The implementation plan and feature docs exist in the active feature folder. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|---|---|---|
| Simplicity first | PARTIAL | New helper modules isolate pack selection, but the C# pack naming contract differs from the documented `csharp` plus `csharp_variant` API. |
| Reusability | PASS | Python and TypeScript implementations mirror existing Claude pack-selection patterns. |
| Extensibility | PARTIAL | Variant-qualified pack names reduce clarity because `csharp_variant` also exists as a separate selector. |
| Separation of concerns | PASS | Pack selection, filesystem filtering, service forwarding, command registration, and MCP input parsing are separated. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| Cohesive modules | PASS | New Python and TypeScript pack-selection modules are cohesive. |
| Under 500 lines | FAIL | `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` is 501 lines and changed from 461 baseline lines. `extensions/drm-copilot/src/workflow-command-arguments.ts` is 662 lines and changed from 579 baseline lines. |
| Public vs internal | PARTIAL | Codex selection fields were added to `push_down_copilot_customizations` MCP schemas, expanding the wrong public tool surface. |
| No circular dependencies | PASS | No circular dependency was observed in the inspected diffs. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | Names such as `compute_published_paths`, `CodexFilteringFileSystem`, and `resolveVariantSourcePath` are descriptive. |
| Docs/docstrings | PASS | New Python modules include module and function docstrings. |
| Comment why, not what | PASS | Comments are limited and mostly describe boundary behavior. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|---|---|---|
| 1. Formatting | PASS | `poetry run black .` exit 0; `npm run format` exit 0. Evidence in `python-black-final.md` and `typescript-format-final.md`. |
| 2. Linting | PASS | `poetry run ruff check .` exit 0; `npm run lint` exit 0. |
| 3. Type checking | PASS | `poetry run pyright` exit 0; `npm run typecheck` exit 0. |
| 4. Testing | PASS | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` exit 0; `npm run test:unit -- --coverage` exit 0. |
| Full toolchain loop | PASS | `full-toolchain-loop-summary.md` reports the final Python and TypeScript QA loop completed with exit code 0. |
| Explicit reporting | PASS | Command evidence is recorded under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Summarize changes | PASS | PR context and feature docs summarize the issue #269 implementation. |
| Design choices explained | PARTIAL | The default C# variant is documented, but API naming for `csharp` versus `csharp-legacy` is inconsistent. |
| Update supporting documents | PASS | README, spec, user story, and implementation plan were updated. |
| Provide next steps | PASS | Remediation inputs and remediation plan are required by this review. |

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with Black | PASS | `python-black-final.md`, exit code 0. |
| Linting with Ruff | PASS | `python-ruff-final.md`, exit code 0. |
| Type checking with Pyright | PASS | `python-pyright-final.md`, exit code 0. |
| Testing with Pytest | PASS | `python-pytest-coverage-final.md`, exit code 0, 1174 passed. |
| Strong typing | PASS | New Python modules use typed dataclasses, literals, and typed sets. |
| Dataclasses for value objects | PASS | `PackManifest` is a frozen dataclass. |
| Specific exceptions | PASS | `ManifestError` is used for manifest and selection validation failures. |

### Section 3B: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Formatting with Prettier | PASS | `typescript-format-final.md`, exit code 0. |
| Linting with ESLint | PASS | `typescript-lint-final.md`, exit code 0. |
| Type checking with TSC | PASS | `typescript-typecheck-final.md`, exit code 0. |
| Testing with Jest | PASS | `typescript-jest-coverage-final.md`, exit code 0, 1416 passed. |
| Typed public interfaces | PASS | New service and tool input fields use literal unions for `csharpVariant` and `memoryMode`. |
| File size | FAIL | Two modified TypeScript production files exceed 500 lines. |

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Use Pytest | PASS | Final evidence uses Pytest. |
| Coverage expectation | PASS | Repo-wide coverage remains above 80%; changed Python code coverage is 96.41%. |
| Focused unit tests | PASS | Tests target pack parsing, C# routing, filesystem filtering, and resource contracts separately. |
| No alternative test runners | PASS | Python evidence uses Pytest only. |

### Section 4B: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Use Jest | PASS | Final evidence uses `npm run test:unit -- --coverage`. |
| Coverage expectation | FAIL | Repo-wide coverage is above 80%, but new file `src/lib/push-down/codex-pack-selection.ts` is 85.43%, below the 90% new-file threshold. |
| Focused unit tests | PASS | Jest tests target pack selection, service forwarding, MCP definitions, MCP inputs, and VS Code command flow. |
| No alternative test runners | PASS | TypeScript evidence uses Jest only. |

## 5. Test Coverage Detail

| Module | Tests / Evidence | Coverage Status |
|---|---|---|
| `scripts/dev_tools/push_down_codex_pack_selection.py` | `tests/scripts/dev_tools/test_push_down_codex_pack_selection.py` | PASS, 83/83 lines, 100.00% |
| `scripts/dev_tools/push_down_codex_filesystem.py` | `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | PASS, 40/43 lines, 93.02% |
| `scripts/dev_tools/push_down_codex_and_agents_customizations.py` | `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | PASS, 65/69 lines, 94.20% |
| `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` | `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts` | FAIL, 170/199 lines, 85.43% |
| `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` | `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts` | PASS, 218/222 lines, 98.20% |
| TypeScript service, MCP, and command files | Jest service, MCP, and command tests | PASS for listed lcov file coverage, except file-size policy gaps noted above |

## 6. Test Execution Metrics

| Metric | Value | Status |
|---|---:|---|
| Python tests | 1174 passed | PASS |
| Python execution time | 4.73s | PASS |
| Python repo-wide coverage | 85.97% lcov / 86% reported | PASS |
| TypeScript test suites | 120 passed | PASS |
| TypeScript tests | 1416 passed | PASS |
| TypeScript repo-wide coverage | 96.80% lcov / 96.79% reported | PASS |
| TypeScript new-file coverage | `codex-pack-selection.ts`: 85.43% | FAIL |
| File-size policy | 2 modified production files over 500 lines | FAIL |

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|---|---|---|---|
| Black Formatting | `poetry run black .` | Exit 0 | PASS |
| Ruff Linting | `poetry run ruff check .` | Exit 0 | PASS |
| Pyright Type Checking | `poetry run pyright` | Exit 0 | PASS |
| Pytest Tests | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Exit 0, 1174 passed | PASS |

**For TypeScript:**

| Check | Command | Result | Status |
|---|---|---|---|
| Prettier Formatting | `npm run format` from `extensions/drm-copilot` | Exit 0 | PASS |
| ESLint | `npm run lint` from `extensions/drm-copilot` | Exit 0 | PASS |
| TSC | `npm run typecheck` from `extensions/drm-copilot` | Exit 0 | PASS |
| Jest Coverage | `npm run test:unit -- --coverage` from `extensions/drm-copilot` | Exit 0, 120 suites and 1416 tests passed | PASS |

**Notes:** Toolchain checks passed, but policy compliance fails because of file-size, evidence-location, TypeScript new-file coverage, and API-contract findings.

## 8. Gaps and Exceptions

### Identified Gaps

1. Evidence-location validator failed for `docs/features/active/2026-07-02-codex-push-down-language-packs-269/research/2026-07-02T13-23-codex-push-down-language-packs-269-research.md`.
2. Modified production files exceed the 500-line limit: `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` and `extensions/drm-copilot/src/workflow-command-arguments.ts`.
3. TypeScript new file `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` has 85.43% line coverage, below the 90% new-file threshold.
4. The documented C# CLI/API pack selector `csharp` is not accepted by Python or TypeScript pack-selection implementations.
5. Codex-specific optional fields were added to the Copilot MCP tool schemas.

### Approved Exceptions

None. No policy exceptions were identified.

### Removed/Skipped Tests

None observed in the review evidence.

## 9. Summary of Changes

### Commits in This PR/Branch

1. `4fd8353` - `feat(codex): add language pack selection for push down`

### Files Modified

The branch changes 72 files. Material production areas:

1. `scripts/dev_tools/push_down_codex_pack_selection.py` (NEW) - Python pack manifest loading, pack filtering, and C# routing.
2. `scripts/dev_tools/push_down_codex_filesystem.py` (NEW) - Python filtering filesystem wrapper.
3. `scripts/dev_tools/push_down_codex_and_agents_customizations.py` (MODIFIED) - CLI and push-down selection integration.
4. `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts` (NEW) - TypeScript pack manifest loading and C# routing.
5. `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` (MODIFIED) - TypeScript filtering integration.
6. `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` (MODIFIED) - VS Code command prompt flow.
7. `extensions/drm-copilot/src/mcp-tool-definitions.ts` and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` (MODIFIED) - MCP schema changes.
8. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/*.json` (NEW) - Codex pack manifests.
9. Python and TypeScript tests under `tests/scripts/dev_tools/` and `extensions/drm-copilot/test/` (MODIFIED/NEW).

## 10. Compliance Verdict

### Overall Status: NON-COMPLIANT

The branch has passing Python and TypeScript toolchain evidence, and most acceptance criteria have direct test coverage. It is not policy-compliant because required evidence-location validation failed, two modified production files exceed the repository line limit, one new TypeScript file is below the 90% new-file coverage threshold, and the C# selection API does not match the documented CLI/API contract.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PARTIAL Design Principles
- FAIL Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PARTIAL Summarize & Document

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline
- PASS Python Design & Typing
- PASS Error Handling

**For TypeScript:**
- PASS Tooling & Baseline
- PASS Type Safety
- FAIL File Size

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PARTIAL Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

**For TypeScript:**
- PASS Framework & Scope
- FAIL Coverage expectation for one new file
- PASS Test Style & Structure
- PASS Toolchain

### Metrics Summary

- PASS Python: 1174/1174 tests passing; repo-wide coverage 85.97%; changed-code coverage 96.41%.
- PASS TypeScript repo-wide: 1416/1416 tests passing; repo-wide coverage 96.80%.
- FAIL TypeScript new-file coverage: `src/lib/push-down/codex-pack-selection.ts` at 85.43%, below 90%.
- FAIL File size: 2 modified production files exceed 500 lines.
- FAIL Evidence location: one artifact under `artifacts/research/` violates validator policy.

### Recommendation

Needs revision. Complete remediation for evidence location, file-size compliance, TypeScript new-file coverage, and the C# pack selection API before PR readiness.

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- `extensions/drm-copilot/test/lib/push-down/codex-pack-selection.test.ts`
- `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts`
- `extensions/drm-copilot/test/lib/push-down/push-down-service-call.test.ts`
- `extensions/drm-copilot/test/mcp-tool-inputs.test.ts`
- `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts`
- `extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts`
- `extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts`
- `extensions/drm-copilot/test/repo-automation-service.push-down-codex.test.ts`

## Appendix B: Toolchain Commands Reference

```powershell
git diff --name-status 51867789325248793a241886033c3ce86681f9ad...HEAD
Get-Content -Raw artifacts/pr_context.summary.txt
Get-Content -Raw artifacts/pr_context.appendix.txt
python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
npm run format
npm run lint
npm run typecheck
npm run test:unit -- --coverage
```

**Audit Completed By:** Codex feature-review worker
**Audit Date:** 2026-07-02
**Policy Version:** Current as of audit date
