# Policy Audit: fix-csharp-push-down-pack-name (Issue #256)

**Audit Date:** 2026-06-27
**Timestamp:** 2026-06-27T14-33
**Base Branch:** `main`
**Merge-base SHA:** `40304077ddbf7b300e3a94944c082596dc72d912` (committed 2026-06-27T12:22:43-04:00)
**Head SHA:** `7dfdd6f7e4f08c8eb5bdd738143677c27f92394a` (committed 2026-06-27T14:31:45-04:00)
**Feature Folder:** `docs/features/active/2026-06-27-fix-csharp-push-down-pack-name-256`
**Work Mode:** `minor-audit`

> Template note: The MCP tool `mcp__drm-copilot__resolve_policy_audit_template_asset` is not available in this review session. This artifact reproduces the canonical major sections required by `policy-audit-template-usage` (Executive Summary, sections 1–10, Appendix A, Appendix B). MCP template resolution unavailability is recorded as a procedural note, not a content gap; all required sections are present.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 2 source (1 new, 1 modified) | 1396 tests | ✅ 1396 pass, 0 fail | 96.75% lines, 88.17% branches | 96.76% lines, 88.18% branches | 100% (new module 56/56 lines, 8/8 branches) |
| Python | 0 files | N/A | N/A | N/A - no changed files of this language in the diff | N/A - no changed files of this language in the diff | N/A - no changed files of this language in the diff |
| PowerShell | 0 files | N/A | N/A | N/A - no changed files of this language in the diff | N/A - no changed files of this language in the diff | N/A - no changed files of this language in the diff |
| C# | 0 files | N/A | N/A | N/A - no changed files of this language in the diff | N/A - no changed files of this language in the diff | N/A - no changed files of this language in the diff |

Per-file TypeScript coverage (numeric evidence; source `extensions/drm-copilot/coverage/lcov.info`):

| File | Change Type | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage | Disposition |
|------|-------------|-------|-------------|-------------------|---------------------|-------------------|-------------|
| `src/lib/push-down/claude-pack-name-translation.ts` | new | included in suite | ✅ pass | 0% (new file, not present at baseline) | 100% lines (56/56), 100% branches (8/8) | 100% (56/56 lines, 8/8 branches) | PASS |
| `src/repo-automation-command-registration-admin.ts` | modified | included in suite | ✅ pass | 94.7% lines (pre-change region unchanged) | 94.7% lines (340/359), 88.2% branches (45/51) | 100% on changed region (lines 197-213 covered) | PASS |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-06-27-fix-csharp-push-down-pack-name-256/evidence/qa-gates/coverage-comparison.md` (baseline extension repo-wide line 96.75% / branch 88.17%); lcov at `extensions/drm-copilot/coverage/lcov.info`.
- TypeScript post-change coverage artifact: `docs/features/active/2026-06-27-fix-csharp-push-down-pack-name-256/evidence/qa-gates/final-test-coverage.md` (post-change extension repo-wide line 96.76% / branch 88.18%); lcov at `extensions/drm-copilot/coverage/lcov.info`.
- PowerShell baseline coverage artifact: N/A - no changed files of this language in the diff.
- PowerShell post-change coverage artifact: N/A - no changed files of this language in the diff.
- Per-language comparison summary: Section 1.2.1 (per-language and per-file comparison lines below).

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 96.75% lines -> Post-change: 96.76% lines. Change: +0.01% lines (branch +0.01%, 88.17% -> 88.18%). New/changed-code coverage: 100%. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/qa-gates/coverage-comparison.md`, `evidence/qa-gates/final-test-coverage.md`.
- `src/lib/push-down/claude-pack-name-translation.ts` (new): Baseline: 0% lines (file absent at baseline) -> Post-change: 100% lines. Change: +100% lines (branch 0% -> 100%). New/changed-code coverage: 100%. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`.
- `src/repo-automation-command-registration-admin.ts` (modified): Baseline: 94.7% lines -> Post-change: 94.7% lines. Change: +0% lines (no regression on changed lines; branch 88.2%). New/changed-code coverage: 100%. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`.
- Python: Baseline: N/A - no changed files of this language in the diff -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A - no changed files of this language in the diff. Disposition: N/A. Evidence: N/A - no changed files of this language in the diff.
- PowerShell: Baseline: N/A - no changed files of this language in the diff -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A - no changed files of this language in the diff. Disposition: N/A. Evidence: N/A - no changed files of this language in the diff.
- C#: Baseline: N/A - no changed files of this language in the diff -> Post-change: N/A. Change: N/A. New/changed-code coverage: N/A - no changed files of this language in the diff. Disposition: N/A. Evidence: N/A - no changed files of this language in the diff.

## Executive Summary

This branch fixes a defect in the "Push Down Claude Customizations" VS Code command where the literal pack name `csharp` was forwarded to the push-down service while only variant-qualified manifests (`csharp-modern.json`, `csharp-legacy.json`) exist. The fix introduces a pure translation helper (`translateSelectedPackNames`) and wires it into the command handler, and adds output-channel logging of service failures before re-throw.

The full branch diff against the merge-base touches TypeScript source and tests plus feature-folder documentation/evidence. There are no Python, PowerShell, or C# source-file changes in the branch diff (the `.json` manifest fixture edits inside a test file are TypeScript test fixtures, not C# source). TypeScript is therefore the only language with changed files requiring coverage verdicts.

All recorded toolchain gates (format, lint, type-check, test, coverage) pass. Reviewer verification of the existing coverage artifacts confirms 100% line/branch coverage for the new module and that the changed lines in the modified file are covered. Overall verdict: **PASS**. No blocking findings; remediation is not required.

## Scope

Languages with changed files in the branch diff:

| Language | Changed source files | Coverage verdict required |
|---|---|---|
| TypeScript | 2 source (1 new, 1 modified) + 3 test (1 modified, 2 new) | Yes |
| Python | 0 | No |
| PowerShell | 0 | No |
| C# | 0 | No |

Changed files (full branch diff vs merge-base):

- A `extensions/drm-copilot/src/lib/push-down/claude-pack-name-translation.ts` (new, TypeScript source)
- M `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` (modified, TypeScript source)
- M `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts` (modified, TypeScript test)
- A `extensions/drm-copilot/test/lib/push-down/claude-pack-name-translation.test.ts` (new, TypeScript test)
- A `extensions/drm-copilot/test/repo-automation-command-registration-admin.test.ts` (new, TypeScript test)
- A (x12) feature-folder docs and evidence under `docs/features/active/2026-06-27-fix-csharp-push-down-pack-name-256/` (issue.md, plan, baseline/qa-gate evidence)

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope below the full feature-vs-base diff. The caller explicitly directed a full-contract, no-narrowing audit. No `## Rejected Scope Narrowing` entries are required. This section is retained per the scope invariant to record that the full branch diff was audited.

## Evidence Location Compliance

Branch-diff evidence written by this feature is located under the canonical `docs/features/active/2026-06-27-fix-csharp-push-down-pack-name-256/evidence/<kind>/` tree (`baseline/`, `qa-gates/`, `other/`). The branch diff contains zero files written under non-canonical `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.

- `git diff --name-only <merge-base>..<head> | grep '^artifacts/(baselines|qa|evidence|coverage)/'` → no matches.

`scripts/dev_tools/validate_evidence_locations.py --root .` reports pre-existing violations under `artifacts/evidence/baseline/2026-04-18T17-15/`, `artifacts/evidence/baseline/2026-04-18T21-20/`, `artifacts/evidence/baseline/2026-04-25T18-15/`, `artifacts/evidence/post-change/2026-04-18T21-20/`, and `artifacts/evidence/post-change/2026-04-25T18-15/`. These paths carry April 2026 timestamps, are NOT part of this branch diff, and are out of scope for this feature-vs-base audit. They are recorded here for traceability only and are not findings against issue #256. Verdict for this feature's evidence locations: **PASS**.

## 1. General Unit Test Policy Compliance

**Verdict: PASS**

- Independence/Isolation: New tests target single units. `claude-pack-name-translation.test.ts` exercises the pure function directly; `repo-automation-command-registration-admin.test.ts` captures the registered handler and invokes it with a mocked VS Code host.
- Determinism: No wall-clock, RNG, `setTimeout`, or sleep usage. Mocks reset via `afterEach(() => { jest.resetAllMocks(); })` in the admin test.
- No external dependencies: VS Code host mocked virtually; no network, no real filesystem, no temporary files.
- Arrange–Act–Assert: Tests are structured with explicit Arrange/Act/Assert comments.
- Test file location: Tests live under `extensions/drm-copilot/test/` mirroring the source tree (`test/lib/push-down/...` mirrors `src/lib/push-down/...`); no colocation in `src/`.
- Scenario completeness: positive flows (AC1, AC2, AC3), order preservation, input non-mutation, and the negative/fail-fast path (AC4 throw) are covered. The AC5 logging seam is covered by the admin handler test.

## 2. General Code Change Policy Compliance

**Verdict: PASS**

- Simplicity: The fix is the minimal change addressing the defect — one small pure helper plus a translate call and a try/catch logging seam.
- Separation of concerns: Pure translation logic is isolated in a module with no `vscode` import and no I/O, host wiring stays in the command-registration module.
- Fail-fast/error handling: `translateSelectedPackNames` throws an explicit, descriptive `Error` when `csharp` is selected without a resolved variant. The new catch block adds context (output-channel log) and re-throws; it does not swallow the error.
- File size: `claude-pack-name-translation.ts` is 56 lines; `repo-automation-command-registration-admin.ts` is 359 lines. Both under the 500-line limit.
- Naming: descriptive, kebab-case filename, camelCase functions/locals, PascalCase type alias (`CsharpVariant`).
- Dependencies: no new runtime dependencies introduced.

## 3. Language-Specific Code Change Policy Compliance

**TypeScript — Verdict: PASS**

- Strong typing: `translateSelectedPackNames(packs: ReadonlyArray<string>, csharpVariant: CsharpVariant): string[]` has intentional public types. `CsharpVariant` is a discriminated `"modern" | "legacy" | undefined` alias. No `any`.
- ES modules: ES import/export syntax used throughout; no CommonJS in the changed source.
- Error handling: `catch (error: unknown)` narrows via `error instanceof Error` before re-throw — compliant with the fail-fast/add-context rule.
- Type assertions: none introduced in the changed source.
- Architecture boundaries: the new module is host-neutral (no `vscode`, no Office.js, no Graph). No layer-boundary violation.
- Suppressions: none introduced (lint evidence reports "No suppressions introduced").

## 4. Language-Specific Unit Test Policy Compliance

**TypeScript — Verdict: PASS (with one documented framework observation)**

- Naming: test files use the `*.test.ts` suffix.
- Mocking: `jest.fn` / `jest.mock` (virtual) for the VS Code host; mocks reset in `afterEach`.
- No Outlook/host runtime required.

Documented observation (not a finding): `.claude/rules/typescript.md` names Vitest as the unit-test framework, but the `extensions/drm-copilot` package is wired to Jest (`ts-jest`, `@jest/globals`, custom `run-jest.cjs`, `coverageProvider: v8`). The new and modified tests correctly follow the package's established Jest convention rather than introducing a second framework. The general-unit-test rule's "follow established conventions" intent and the test-file-location rule are both satisfied. This Jest-vs-Vitest divergence is pre-existing at the package level and is outside the scope of issue #256; it is noted for repository-level rule reconciliation, not charged against this branch.

## 5. Test Coverage Detail

**Verdict: PASS**

Coverage artifacts inspected (not regenerated): `extensions/drm-copilot/coverage/lcov.info` and `coverage/lcov.info`, plus the executor evidence `evidence/qa-gates/final-test-coverage.md` and `evidence/qa-gates/coverage-comparison.md`.

Reviewer extraction from `extensions/drm-copilot/coverage/lcov.info`:

| File | Change Type | Tier | LF/LH (line) | Line % | BRF/BRH (branch) | Branch % | Verdict |
|---|---|---|---|---|---|---|---|
| `src/lib/push-down/claude-pack-name-translation.ts` | new | new code | 56/56 | 100% | 8/8 | 100% | PASS (>=85% line, >=75% branch) |
| `src/repo-automation-command-registration-admin.ts` | modified | modified | 359/340 | 94.7% | 51/45 | 88.2% | PASS (>=85% line, >=75% branch, no regression on changed lines) |

- Repo-wide (extension package, "All files"): line 96.76%, branch 88.18% — both >= thresholds. **PASS.**
- New file threshold (line >= 85%, branch >= 75%): met at 100%/100%.
- Modified file threshold (line >= 85%, branch >= 75%, no regression on changed lines): met at 94.7%/88.2%. The v8 uncovered line set in the modified file (95-99, 110-115, 232-233, 241-242, 251-252, 276-277) is entirely pre-existing unrelated command handlers; the changed region (lines 197-213: translation call and try/catch logging) is covered.
- Coverage comparison vs baseline: overall line +0.01 (96.75→96.76), branch +0.01 (88.17→88.18). No regression.

TypeScript coverage verdict: **PASS**. Python/PowerShell/C# coverage: not applicable (zero changed files for those languages on the branch).

## 6. Test Execution Metrics

**Verdict: PASS**

- Command (executor): `npm test -- --coverage` (wraps `node run-jest.cjs --coverage`, `coverageProvider: v8`), run from `extensions/drm-copilot/`. EXIT_CODE 0.
- Result: 118 suites passed / 118 total; 1396 tests passed / 1396 total; 0 failed.
- Source: `evidence/qa-gates/final-test-coverage.md`.

## 7. Code Quality Checks

**Verdict: PASS**

| Stage | Command | Result | Source |
|---|---|---|---|
| Formatting | `npm run format` (prettier --write) | EXIT 0; `prettier --check` confirms "All matched files use Prettier code style!" | `evidence/qa-gates/final-format.md` |
| Linting | `npm run lint` (eslint src test) | EXIT 0; zero errors, zero warnings; no suppressions introduced | `evidence/qa-gates/final-lint.md` |
| Type checking | `npm run typecheck` (tsc --noEmit) | EXIT 0; zero type errors | `evidence/qa-gates/final-typecheck.md` |
| Tests | `npm test -- --coverage` | EXIT 0; 1396 passed | `evidence/qa-gates/final-test-coverage.md` |

## 8. Gaps and Exceptions

- MCP template-asset resolution (`mcp__drm-copilot__resolve_policy_audit_template_asset`) and the MCP validator (`mcp__drm-copilot__validate_orchestration_artifacts`) were not available as tools in this review session. This artifact reproduces the canonical major sections manually. This is a tooling-availability note; it does not change any verdict.
- Jest-vs-Vitest framework divergence at the `extensions/drm-copilot` package level (see section 4) is a pre-existing repository-rule reconciliation item, not a defect in this branch.

## 9. Summary of Changes

- New pure module `claude-pack-name-translation.ts` translating a selected `csharp` pack name to `csharp-modern` / `csharp-legacy`, returning non-C# entries unchanged in order, and throwing fail-fast when `csharp` is selected without a resolved variant.
- `repo-automation-command-registration-admin.ts`: calls `translateSelectedPackNames` before forwarding packs to the service, and wraps the service call in a try/catch that logs the failure to the output channel before re-throwing.
- Integration test fixture updated to seed `csharp-legacy.json` (variant-qualified) instead of the obsolete `csharp.json`, providing integration-level evidence for AC4.
- New unit tests for the translation helper (AC1–AC4) and the output-logging seam (AC5).

## 10. Compliance Verdict

**Overall: PASS.** All toolchain gates pass, coverage thresholds are met for the new and modified files and repo-wide, evidence is in canonical locations, and no policy rule is violated. The `modified-workflow-needs-green-run` rule does not fire (no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` paths in the branch diff). No blocking findings. Remediation is not required.

## Appendix A: Test Inventory

| Test file | Scope | Cases |
|---|---|---|
| `test/lib/push-down/claude-pack-name-translation.test.ts` | Pure translation helper | AC1 (csharp→csharp-modern), AC2 (csharp→csharp-legacy), AC3 (non-C# unchanged/order), AC1/AC3 combined order, AC4 (throw on unresolved variant), input non-mutation |
| `test/repo-automation-command-registration-admin.test.ts` | Command handler logging seam | AC5 (service failure written to output channel before re-throw) |
| `test/extension.push-down-claude-customizations.test.ts` (modified) | Integration | C# variant prompt resolves variant-qualified manifest (`csharp-legacy.json`) — integration evidence for AC4 |

## Appendix B: Toolchain Commands Reference

Commands referenced from executor evidence (run from `extensions/drm-copilot/`); reviewer inspected the resulting artifacts rather than regenerating coverage:

- Format: `npm run format` → `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- Lint: `npm run lint` → `eslint --no-error-on-unmatched-pattern src test`
- Type-check: `npm run typecheck` → `tsc -p ./ --noEmit`
- Test + coverage: `npm test -- --coverage` → `node run-jest.cjs --coverage` (coverageProvider v8) → artifacts `extensions/drm-copilot/coverage/lcov.info`, `coverage/lcov.info`
- Evidence-location scan: `python scripts/dev_tools/validate_evidence_locations.py --root .`
- Diff scope: `git diff --name-status 40304077ddbf7b300e3a94944c082596dc72d912 7dfdd6f7e4f08c8eb5bdd738143677c27f92394a`
