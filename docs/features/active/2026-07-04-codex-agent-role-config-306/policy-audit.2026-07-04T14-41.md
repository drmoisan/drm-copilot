# Policy Compliance Audit: codex-agent-role-config (Issue #306)

**Audit Date:** 2026-07-04
**Code Under Test:** branch `bug/codex-agent-role-config-306` relative to `origin/main` at merge-base `f530d0e3ae7c5d0974b72cf0956e862dd94041c5`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 6 files | Jest | PASS per recorded artifact; current format check failed | Targeted overall 48.3%; `src/command-runtime.ts` 87.91% | Full suite 96.88%; `src/command-runtime.ts` 92.65% | 92.65% for changed `src/command-runtime.ts` |
| Python | 2 test files | Pytest | PASS per recorded artifact and current Black check | Targeted contract coverage 1% | Full suite 86% | N/A - test-only additions |
| TOML/JSON/Markdown | 51 files | Contract/evidence validation | PARTIAL | N/A | N/A | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/typescript-jest-coverage.baseline.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/typescript-jest-coverage.final.md`
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed
- Python baseline coverage artifact: `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/baseline/python-contract-coverage.baseline.md`
- Python post-change coverage artifact: `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/python-pytest-coverage.final.md`
- Per-language comparison summary: `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/final-coverage-comparison.md`

## Executive Summary

Policy compliance is **FAIL** for the current branch review. The PR context artifacts are current for `HEAD` `0a8e29edbebfa6fc6ebfbbd7a92abb9c39218d18`, and the recorded executor evidence shows passing TypeScript and Python coverage gates. However, current review verification found two blocking policy issues:

1. `git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD` fails on whitespace in added evidence artifacts and `spec.md`.
2. The branch adds issue-specific plan-path instructions for issue #306 to reusable orchestration skill files, which conflicts with the spec's out-of-scope boundary for orchestration delegation and checkpoint rule changes.

**Policy documents evaluated:**
- PASS `AGENTS.md`
- PASS `.agents/skills/policy-compliance-order/SKILL.md`
- PASS `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- PASS `.agents/skills/feature-review-workflow/SKILL.md`
- PASS `.agents/skills/feature-review/SKILL.md`

**Language-specific policies evaluated:**
- PASS `.agents/skills/python/SKILL.md`
- PASS `.agents/skills/typescript/SKILL.md`
- N/A PowerShell; no PowerShell files changed in the branch diff
- N/A C#; no C# files changed in the branch diff

**Temporary artifacts cleanup:**
- PASS No temporary review scripts were created.
- PASS Review artifacts are written under the active feature folder.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | Jest and Pytest suites use isolated mocks/fixtures per recorded artifacts. |
| Isolation | PASS | New Python contract tests target TOML role/config contracts; Jest tests target executable resolution and command launch behavior. |
| Fast Execution | PASS | Recorded TypeScript run: 1472 tests in 4.749s. Recorded Python run: 1280 tests in 7.13s. |
| Determinism | PASS | Tests use mocked filesystem and VS Code extension roots rather than real installed extension folders. |
| Readability & Maintainability | PASS | Test names describe role schema, transport location, installed-extension fallback, and missing-executable behavior. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | Baseline artifacts exist under `evidence/baseline/` for TypeScript and Python. |
| No Coverage Regression | PASS | `final-coverage-comparison.md` reports no regression; TypeScript final 96.88%, Python final 86%. |
| New Code Coverage >=90% | PASS | `src/command-runtime.ts` final line coverage is 92.65%; Python additions are test-only contract assertions. |
| Comprehensive Coverage | PASS | Evidence covers positive, negative, boundary, and contract scenarios named in the spec. |
| Positive Flows | PASS | Installed-extension Codex fallback and valid role/config contracts are covered. |
| Negative Flows | PASS | Missing executable and invalid role/config shapes have fail-before/pass-after evidence. |
| Edge Cases | PASS | Configured executable and PATH/PATHEXT behavior remain covered. |
| Error Handling | PASS | Missing executable still fails before terminal creation with the existing explicit error. |
| Concurrency | N/A | No concurrency behavior changed. |
| State Transitions | N/A | No runtime state machine changed. |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 48.3% lines. Post-change: 96.88% lines. Change: +48.58 percentage points. New/changed-code coverage: 92.65% lines for `src/command-runtime.ts`. Disposition: PASS. Evidence: `final-coverage-comparison.md`, `typescript-jest-coverage.final.md`.
- Python: Baseline: 1% lines. Post-change: 86% lines. Change: +85 percentage points. New/changed-code coverage: N/A - changed Python files are test-only additions. Disposition: PASS. Evidence: `final-coverage-comparison.md`, `python-pytest-coverage.final.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clear Failure Messages | PASS | Assertions name expected TOML shapes, expected transport fields, and expected command-launch behavior. |
| Arrange-Act-Assert Pattern | PASS | Jest and Pytest tests follow explicit setup, execution, and assertion structure. |
| Document Intent | PASS | Test docstrings and names state the contract being protected. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| Avoid External Dependencies | PASS | Unit tests use mocks and checked-in files. |
| Use Mocks/Stubs | PASS | VS Code extension roots and filesystem existence are mocked in Jest; Python tests parse checked-in TOML. |
| Environment Stability | PASS | Tests avoid real installed extension state; manual `codex doctor --json` evidence is recorded separately. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pre-submission Review | FAIL | This audit found remediation-required issues. |

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| Clarify the objective | PASS | Issue #306 and `spec.md` define malformed Codex role TOML and Codex executable resolution failures. |
| Read existing change plans | PASS | Plan `plan.2026-07-04T13-47.md` exists and validates through MCP. |
| Document the plan | PASS | Plan tasks P0 through P17 are checked off with evidence artifacts. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | PARTIAL | Resolver fallback is bounded and direct; reusable skill hardcoding adds issue-specific permanent rules. |
| Reusability | FAIL | Reusable orchestration skills now contain an issue #306-specific path invariant. |
| Extensibility | PARTIAL | Resolver candidate-root design is extensible; hardcoded issue path is not. |
| Separation of concerns | PARTIAL | Extension resolver work is scoped; plan-path behavior changes are outside the spec's implementation boundary. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| Cohesive modules | PARTIAL | TypeScript/Python changes are cohesive; orchestration skill changes mix issue-specific remediation into reusable workflow rules. |
| Under 500 lines | PASS | Changed non-Markdown files reviewed for the 500-line limit; no changed non-Markdown file over 500 lines was reported. |
| Public vs internal | PASS | Resolver API remains explicit; no broad public API expansion was found. |
| No circular dependencies | PASS | No new dependency cycle was identified in diff inspection. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| Descriptive names | PASS | Added resolver functions and tests use descriptive names. |
| Docs/docstrings | PASS | Package configuration wording was updated for fallback resolution. |
| Comment why, not what | PASS | Existing comments explain cross-platform path and test-harness rationale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| 1. Formatting | FAIL | Current command `Push-Location extensions/drm-copilot; npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; Pop-Location` exited 1 and reported six files with code style issues. |
| 2. Linting | PARTIAL | Recorded artifact `typescript-lint.final.md` reports PASS; current rerun was not continued after formatting failure. |
| 3. Type checking | PARTIAL | Recorded artifacts `typescript-typecheck.final.md` and `python-pyright.final.md` report PASS; current rerun was not continued after formatting failure. |
| 4. Testing | PARTIAL | Recorded coverage artifacts report PASS; current rerun was not continued after formatting failure. |
| Full toolchain loop | FAIL | Current review verification did not complete a clean single pass because formatting and `git diff --check` failed. |
| Explicit reporting | PASS | Commands and failures are recorded in this audit and remediation inputs. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| Summarize changes | PASS | PR context summary and feature evidence enumerate the branch diff. |
| Design choices explained | PASS | `spec.md`, research, and plan evidence describe resolver and role-schema choices. |
| Update supporting documents | PARTIAL | Docs were updated, but `spec.md` contains trailing whitespace and AC checkoff conflicts with review findings. |
| Provide next steps | PASS | Remediation inputs and remediation plan are required. |

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Black | PASS | Current command `poetry run black --check .` exited 0. |
| Linting with Ruff | PARTIAL | Recorded `python-ruff.final.md` reports PASS; current rerun was not needed after remediation trigger. |
| Type checking with Pyright | PARTIAL | Recorded `python-pyright.final.md` reports PASS. |
| Testing with Pytest | PARTIAL | Recorded `python-pytest-coverage.final.md` reports 1280 passed and 86% coverage. |
| Strong typing | PASS | Added tests use typed helpers and `cast` for parsed TOML. |
| Dataclasses/Protocols | N/A | Test-only Python additions do not introduce domain value objects or interfaces. |
| Error handling | PASS | Tests rely on assertions over checked-in files; no broad exception handling was added. |

### Section 3B: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting with Prettier | FAIL | Current check-only Prettier command exited 1. |
| Linting with ESLint | PARTIAL | Recorded `typescript-lint.final.md` reports PASS. |
| Type checking with TSC | PARTIAL | Recorded `typescript-typecheck.final.md` reports PASS. |
| Testing with Jest | PARTIAL | Recorded `typescript-jest-coverage.final.md` reports 1472 passed and 96.88% line coverage. |
| Type safety and maintainability | PASS | Resolver signature adds an explicit `ReadonlyArray<string>` candidate-root parameter. |
| Error handling | PASS | Missing Codex executable behavior remains explicit and pre-terminal. |

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Pytest | PASS | Recorded Pytest artifact reports 1280 passed. |
| Coverage expectation | PASS | Python final coverage is 86%, above the 80% floor. |
| Focused unit tests | PASS | Contract tests target role/config parsing and pushed-down payload requirements. |
| Mocking sparingly | PASS | No external-service mocks are required for Python contract tests. |
| Organization | PASS | Tests live under `tests/scripts/dev_tools/`. |
| Naming and readability | PASS | Test names describe expected Codex role/config contracts. |

### Section 4B: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Use Jest | PASS | Recorded Jest artifact reports 122 suites and 1472 tests passed. |
| Coverage expectation | PASS | TypeScript final line coverage is 96.88%, above the 80% floor; changed `command-runtime.ts` is 92.65%. |
| Focused unit tests | PASS | Tests target resolver fallback, command launch, and missing-executable behavior. |
| Mocking strategy | PASS | VS Code extension APIs and filesystem probes are mocked. |
| Organization | PASS | Tests remain under `extensions/drm-copilot/test/`. |

## 5. Test Coverage Detail

| Component | Test / Evidence | Scenario Type | Status |
|-----------|-----------------|---------------|--------|
| `resolveCodexExecutable` | `extensions/drm-copilot/test/extension.test.ts` | PATH fallback, configured path, installed-extension fallback, missing executable | PASS |
| `newCodexWorktreeSession` | `extensions/drm-copilot/test/codex-worktree-session-command.test.ts` | Launch through PowerShell call operator and fail-before-terminal behavior | PASS |
| `.codex/agents/orchestrator.toml` | `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` | Role skill config sequence and no role-local MCP transport | PASS |
| `.codex/config.toml` and bundled config | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | Full MCP transport retained only in config files | PASS |

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| TypeScript total tests | 1472 | PASS per recorded artifact |
| TypeScript execution time | 4.749s | PASS per recorded artifact |
| TypeScript line coverage | 96.88% overall; 92.65% `command-runtime.ts` | PASS |
| Python total tests | 1280 | PASS per recorded artifact |
| Python execution time | 7.13s | PASS per recorded artifact |
| Python line coverage | 86% | PASS |
| Current `git diff --check` | exit 1 | FAIL |
| Current check-only Prettier | exit 1 | FAIL |

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PR context freshness | `git rev-parse HEAD`; compare against `artifacts/pr_context.summary.txt` | Current `HEAD` matches PR context summary. | PASS |
| Plan validation | `mcp__drm_copilot.validate_orchestration_artifacts artifact_type=plan` | Validated plan artifact. | PASS |
| Evidence location validation | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0. | PASS |
| Git whitespace check | `git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD` | exit 1; trailing whitespace and blank-at-EOF diagnostics. | FAIL |
| TypeScript format check | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | exit 1; six files need formatting. | FAIL |
| Python format check | `poetry run black --check .` | exit 0. | PASS |
| TypeScript lint/type/test | recorded final artifacts | PASS in executor evidence, not rerun after current format failure. | PARTIAL |
| Python lint/type/test | recorded final artifacts | PASS in executor evidence; Black rerun passed. | PARTIAL |

## 8. Gaps and Exceptions

### Identified Gaps

- Current branch hygiene fails `git diff --check`.
- Current check-only TypeScript formatting fails.
- Reusable orchestration skills contain issue #306-specific plan-path text, conflicting with the feature spec's out-of-scope boundary.
- `spec.md` has checked acceptance criteria for no unintended out-of-scope behavior and full toolchain pass, but current review evidence does not support those as PASS.

### Approved Exceptions

None.

### Removed/Skipped Tests

None identified.

## 9. Summary of Changes

### Commits in This PR/Branch

1. `0a8e29e` - `fix(codex): repair agent role config and CLI resolution`

### Files Modified

The PR context summary reports 59 changed files: 6 TypeScript files, 2 Python test files, 2 TOML role/config surfaces, 1 JSON package file, and 48 Markdown feature/evidence/skill files.

Key implementation areas:
- Codex role TOML schema correction in root and bundled `.codex/agents/orchestrator.toml`.
- Codex executable resolver fallback in `extensions/drm-copilot/src/command-runtime.ts` and command wiring in `extension.ts`.
- Jest and Pytest regression coverage.
- Feature evidence and active feature documents for issue #306.
- Reusable orchestration skill edits that now require remediation.

## 10. Compliance Verdict

### Overall Status: NON-COMPLIANT

The branch is not ready for PR merge. Remediation is required because current review checks fail and because reusable orchestration skills contain issue-specific plan-path content that conflicts with the spec boundary.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- Before Making Changes: PASS
- Design Principles: PARTIAL
- Module & File Structure: PARTIAL
- Naming, Docs, Comments: PASS
- Toolchain Execution: FAIL
- Summarize & Document: PARTIAL

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- Tooling & Baseline: PARTIAL
- Python Design & Typing: PASS
- Error Handling: PASS

**For TypeScript:**
- Tooling & Baseline: FAIL
- Type Safety and Maintainability: PASS
- Error Handling: PASS

#### General Unit Test Policy (Section 1)
- Core Principles: PASS
- Coverage & Scenarios: PASS
- Test Structure: PASS
- External Dependencies: PASS
- Policy Audit: FAIL

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- Framework & Scope: PASS
- Test Style & Structure: PASS
- Naming & Readability: PASS
- Toolchain: PARTIAL

**For TypeScript:**
- Framework & Scope: PASS
- Test Style & Structure: PASS
- Naming & Readability: PASS
- Toolchain: PARTIAL

### Metrics Summary

- PASS TypeScript recorded tests: 1472/1472 passing.
- PASS Python recorded tests: 1280/1280 passing.
- PASS TypeScript recorded line coverage: 96.88%.
- PASS Python recorded line coverage: 86%.
- FAIL Current `git diff --check`.
- FAIL Current check-only TypeScript formatting.

### Recommendation

**Needs revision.** Address the reusable-skill scope violation and whitespace/formatting failures, then refresh the affected evidence and rerun review validation.

## Appendix A: Test Inventory

- `extensions/drm-copilot/test/extension.test.ts` - Codex executable resolution behavior.
- `extensions/drm-copilot/test/codex-worktree-session-command.test.ts` - New Codex worktree command launch behavior.
- `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` - Codex role wrapper contracts.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` - Pushed-down resource and transport contracts.

## Appendix B: Toolchain Commands Reference

```powershell
git rev-parse HEAD
git merge-base HEAD origin/main
git diff --name-status f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD
git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run black --check .
Push-Location extensions/drm-copilot
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
Pop-Location
```

```text
mcp__drm_copilot.validate_orchestration_artifacts artifact_type=plan artifact_path=docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md
```

**Audit Completed By:** Codex feature-review workflow
**Audit Date:** 2026-07-04
**Policy Version:** Current as of audit date
