# Policy Audit — Worktree Naming Bug Fix

**Feature:** `2026-04-26-worktree-naming-bug`
**Branch:** `feature/20260426193133-wt-bug`
**Base:** `main`
**Reviewer:** Feature Review Agent
**Audit timestamp:** 2026-04-26T00-00
**Work mode:** `full-bug` (source: `plan.md` line 3)
**AC source:** `spec.md` only

---

## Policy Reading Order Compliance

Policy files were read in the required order before this audit:

1. `CLAUDE.md` — tone, architecture, compliance reading order
2. `.claude/rules/general-code-change.md` — design principles, toolchain loop, 500-line limit
3. `.claude/rules/general-unit-test.md` — coverage thresholds, AAA structure, independence
4. `.claude/rules/typescript.md` — TypeScript toolchain, coding standards, coverage
5. `.claude/rules/typescript-suppressions.md` — suppression authorization policy
6. `.claude/rules/powershell.md` — PowerShell toolchain, coding standards, coverage

---

## Rejected Scope Narrowing

No caller-supplied scope narrowing was detected. The audit was conducted against the full branch diff between `feature/20260426193133-wt-bug` and `main`.

---

## Branch Diff Summary

Files changed on this branch (production and test):

| File | Role | Status |
|------|------|--------|
| `extensions/drm-copilot/src/claude-worktree-session.ts` | TS pure helpers | Modified |
| `extensions/drm-copilot/src/extension.ts` | VS Code command handler | Modified |
| `scripts/dev-tools/new-claude-worktree-session.ps1` | PS1 standalone script | Modified |
| `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1` | PS1 template | Modified |
| `extensions/drm-copilot/test/claude-worktree-session.test.ts` | TS unit tests | Modified |
| `extensions/drm-copilot/test/extension.workflow-commands.test.ts` | TS integration tests | Modified |
| `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` | Pester tests | Modified |

Languages with changed files: **TypeScript**, **PowerShell**.

---

## Toolchain Compliance

### TypeScript

Evidence source: `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/`

| Step | Command | Exit Code | Verdict |
|------|---------|-----------|---------|
| Formatting (Prettier) | `npm run format` | 0 | PASS |
| Linting (ESLint) | `npm run lint` | 0 | PASS |
| Type checking (TSC) | `npm run typecheck` | 0 | PASS |
| Testing (Jest) | `node run-jest.cjs --coverage` | 0 | PASS |

All four TypeScript toolchain steps pass in a single clean pass. PASS.

**Note:** The test command used was `node run-jest.cjs --coverage` rather than `npm run test:unit:coverage` because the latter script does not exist in `package.json`. This is a pre-existing condition and not introduced by this branch.

### PowerShell

Evidence source: `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/`

| Step | Command | Exit Code | Verdict |
|------|---------|-----------|---------|
| Formatting (PoshQC) | `mcp__drmCopilotExtension__run_poshqc_format` | 0 | PASS |
| Linting (PSScriptAnalyzer) | `mcp__drmCopilotExtension__run_poshqc_analyze` | 0 | PASS |
| Testing (Pester) | `mcp__drmCopilotExtension__run_poshqc_test` | 0 | PASS |

All three PowerShell toolchain steps pass. PASS.

---

## Coverage Verification

### TypeScript

Coverage artifact `coverage/lcov.info` was not found at the canonical path. However, Jest coverage output was captured in the QA-gate evidence artifact (`evidence/qa-gates/ts-qa-test-coverage.md`), which reports numeric per-file and overall coverage values produced during the QA-gate run.

**Finding:** The canonical coverage artifact path (`coverage/lcov.info`) is absent. Coverage figures were verified from the QA-gate evidence artifact, not from the canonical lcov file. This is an UNVERIFIED condition by strict artifact-path rules, but the QA-gate evidence provides equivalent line-coverage data.

**Coverage values reported (from QA evidence):**

| Scope | Baseline | Post-change | Delta | Threshold | Verdict |
|-------|----------|-------------|-------|-----------|---------|
| Repo-wide (lines) | 94.95% | 94.95% | 0.00% | >= 80% | PASS |
| `claude-worktree-session.ts` (lines) | 100% | 100% | 0.00% | >= 90% (modified file) | PASS |

**Overall TypeScript coverage verdict: PASS** (with the caveat that the canonical `coverage/lcov.info` artifact is absent; no regression is detectable from available evidence).

### PowerShell

Coverage artifact: `artifacts/pester/powershell-coverage.xml` — present and parsed.

The coverage scope defined in `pester.runsettings.psd1` is `.claude/hooks/` only. The file `new-claude-worktree-session.ps1` (and the template equivalent) are **not included in the Pester coverage scope** per the repository's test settings. This is a pre-existing configuration, not introduced by this branch.

**Coverage values from `artifacts/pester/powershell-coverage.xml` (hooks scope):**

| Scope | Lines Covered | Lines Total | Percentage | Threshold | Verdict |
|-------|--------------|-------------|------------|-----------|---------|
| `.claude/hooks` repo-wide | 275 | 284 | 96.8% | >= 80% | PASS |

**`new-claude-worktree-session.ps1` coverage:** Not in coverage scope per `pester.runsettings.psd1`. The QA-gate evidence artifact (`ps-qa-test.md`) states the overall coverage is 97% for the hooks files, consistent with the XML parse. The script files modified by this branch are outside the configured scope.

**Finding:** Coverage for `new-claude-worktree-session.ps1` and its template cannot be verified from any artifact because neither file is in the Pester coverage scope. Per Coverage Verification policy, a language that has changed files but has no coverage artifact for those specific files must be flagged. The canonical PowerShell coverage artifact (`artifacts/pester/powershell-coverage.xml`) exists but does not cover the changed production files. This is recorded as a PARTIAL coverage finding.

**Overall PowerShell coverage verdict: PARTIAL** — repo-wide (hooks) coverage is 96.8% (PASS), but `new-claude-worktree-session.ps1` and its template are excluded from coverage scope. No regression is detectable, but new-file coverage cannot be confirmed >= 90%.

---

## Evidence Location Compliance

`validate_evidence_locations.py --root .` was executed. The script produced no output (exit 0), indicating no evidence files were written to non-canonical paths.

Evidence produced by the executing agent is located under:
`docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/` and
`docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/`

Both paths conform to the canonical `<FEATURE>/evidence/<kind>/` pattern defined in the evidence-and-timestamp-conventions skill. No violations found.

**Verdict: PASS**

---

## File Size Limit

Policy: no production code, test code, or reusable script file may exceed 500 lines.

| File | Lines on `main` | Lines on branch | Verdict |
|------|----------------|-----------------|---------|
| `claude-worktree-session.ts` | Not checked (new in prior work) | 157 | PASS |
| `extension.ts` | 538 | 673 | FAIL |
| `new-claude-worktree-session.ps1` (standalone) | Not changed line count measurably | 232 | PASS |
| `new-claude-worktree-session.ps1` (template) | Not changed line count measurably | 232 | PASS |
| `claude-worktree-session.test.ts` | N/A | 257 | PASS |
| `extension.workflow-commands.test.ts` | 399 | 722 | FAIL |
| `new-claude-worktree-session.Tests.ps1` | N/A | 280 | PASS |

**`extension.ts`:** 538 lines on `main` (already a pre-existing violation), 673 lines after this branch (worsened by 135 lines). The branch adds the `newClaudeWorktreeSession` handler expansion plus new imports and the `pyprojectHasPoetry` helper. The pre-existing violation predates this feature; however, the branch increases the violation rather than reducing it.

**`extension.workflow-commands.test.ts`:** 399 lines on `main`, 722 lines on branch. The branch added substantial new test coverage for the `newClaudeWorktreeSession` handler scenarios. This file crossed the 500-line threshold on this branch.

**Verdict: PARTIAL** — two files exceed the 500-line limit. Both violations involve the VS Code extension handler and its test file. The `extension.ts` violation was pre-existing and worsened; `extension.workflow-commands.test.ts` is a new violation introduced on this branch.

---

## Suppression Audit

**TypeScript suppressions:** No `eslint-disable`, `@ts-ignore`, or `@ts-nocheck` directives were introduced in any changed TypeScript file. No `@ts-expect-error` directives found. **PASS.**

**PowerShell suppressions:** No `[Diagnostics.CodeAnalysis.SuppressMessageAttribute]` or equivalent analyzer suppressions were introduced. **PASS.**

---

## Tone Compliance

All evidence artifacts reviewed (`ac-verification.md`, `ts-qa-test-coverage.md`, `ps-qa-test.md`, etc.) use professional, factual, neutral language consistent with `.claude/rules/tonality.md`. No humor, hyperbole, or decorative language was detected. **PASS.**

---

## Policy Audit Summary

| Policy Gate | Verdict | Notes |
|-------------|---------|-------|
| Policy reading order followed | PASS | All six required files read |
| TypeScript toolchain (format/lint/typecheck/test) | PASS | All four steps exit 0 |
| PowerShell toolchain (format/analyze/test) | PASS | All three steps exit 0 |
| TypeScript coverage (repo-wide >= 80%) | PASS | 94.95%, no regression |
| TypeScript coverage (changed module >= 90%) | PASS | `claude-worktree-session.ts` 100% |
| TypeScript coverage artifact existence | PARTIAL | `coverage/lcov.info` absent; QA evidence used |
| PowerShell coverage (in-scope files >= 80%) | PASS | 96.8% (hooks scope) |
| PowerShell coverage (changed production files) | PARTIAL | `new-claude-worktree-session.ps1` outside coverage scope |
| Evidence location compliance | PASS | `validate_evidence_locations.py` exit 0 |
| File size limit | PARTIAL | `extension.ts` (673 lines), `extension.workflow-commands.test.ts` (722 lines) exceed 500-line limit |
| Suppression compliance | PASS | No unauthorized suppressions |
| Tone compliance | PASS | All artifacts use professional tone |

**Overall audit result: PARTIAL** — two file-size limit findings require attention. Coverage gaps for PowerShell production files are a pre-existing scope configuration, not a branch regression. No blocking correctness or security findings.
