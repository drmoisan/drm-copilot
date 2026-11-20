# Policy Compliance Audit: F5 ts-resolve-prompts (Issue #240)

---

**Audit Date:** 2026-06-26
**Audit Cycle:** F5 review (feature branch `feat/ts-port-resolve-prompts-240`)
**Code Under Test:** TypeScript port of the bundled `resolve_hard_lock_prompt.py` and `resolve_file_prompt.py` into `extensions/drm-copilot/src/lib/resolve/**` (`hard-lock-prompt.ts`, `file-prompt-core.ts`, `file-prompt-variables.ts`, `file-prompt-transforms.ts`, `resolve-prompts-service-call.ts`); the in-process wiring of `RepoAutomationService.resolveExecuteHardLockPrompt()` and `resolveAtomicPlanPrompt()` via `runResolveExecuteHardLockPrompt` / `runResolveAtomicPlanPrompt` helpers in `repo-automation-service-workflows.ts`; and mirrored/updated Jest tests under `extensions/drm-copilot/test/**`.

**Base branch:** `main` (resolved `origin/main`)
**Merge-base SHA:** `c82de735740fc4b02ee8e69abac135efbfe9cb42`
**Head SHA:** `f2425fb46b293a0373dbdda32a666f4175791d40`
**Range:** `c82de735740fc4b02ee8e69abac135efbfe9cb42..f2425fb46b293a0373dbdda32a666f4175791d40`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|---------------------------|
| TypeScript | 21 files (5 new src, 2 modified src, 4 new test, 4 modified test, plus 6 evidence/plan docs) | 698 | PASS 698 pass, 0 fail, 60 suites | n/a (resolve dir new; src/lib/** aggregate prior) | 96.3% line / 88.06% branch (All files); src/lib/resolve aggregate 96.8% line / 83.79% branch | hard-lock-prompt.ts 94.33% line / 83.58% branch; file-prompt-core.ts 98.67% line / 84% branch; file-prompt-variables.ts 95.25% line / 75.75% branch; file-prompt-transforms.ts 100% line / 86.66% branch; resolve-prompts-service-call.ts 100% line / 100% branch |
| Python | 0 files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files |
| PowerShell | 0 files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files |
| C# | 0 files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files | N/A - no changed files |

**Coverage verdicts:** TypeScript = **PASS** (the only language with changed files; every new `src/lib/resolve/**` file meets line >= 85% and branch >= 75%, and repo-wide All-files coverage is 96.3% line / 88.06% branch). Python, PowerShell, C# = N/A (zero changed files on this branch; these verdicts are acceptable only because those languages have no changed files in the branch diff).

**Note on scope classification:** `artifacts/pr_context.summary.txt` is stale and misclassified this branch as "Core logic changes: 0 files / Docs/templates/agents/tooling: 11 files," omitting all TypeScript source and test changes. The authoritative scope was determined from `git diff --name-status c82de73..f2425fb` (the SKILL-mandated full branch diff vs. resolved base). Only TypeScript has changed source files; the `.md` entries are feature docs / evidence artifacts, not a measured language.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/baseline/f5-ts-test-baseline.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/f5-final-test-coverage.md`
- TypeScript coverage-delta artifact: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/qa-gates/f5-coverage-delta.md`
- Python / PowerShell / C# coverage artifacts: N/A - no changed files
- TypeScript independent re-run (this audit): `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` from `extensions/drm-copilot/`, EXIT 0, 60 suites / 698 tests green.

**Non-negotiable verdict rule:** This audit reports an explicit PASS with numeric post-change and per-new-file coverage for the only language in scope (TypeScript). No language with changed files is marked N/A, UNVERIFIED, or informational only.

### Per-Language Coverage Comparison

- TypeScript: Post-change repo-wide (All files) 96.3% line / 88.06% branch. `src/lib/resolve` aggregate 96.8% line / 83.79% branch. New-file coverage: `hard-lock-prompt.ts` 94.33% line / 83.58% branch; `file-prompt-core.ts` 98.67% line / 84% branch; `file-prompt-variables.ts` 95.25% line / 75.75% branch; `file-prompt-transforms.ts` 100% line / 86.66% branch; `resolve-prompts-service-call.ts` 100% line / 100% branch. The two modified source files (`repo-automation-service.ts`, `repo-automation-service-workflows.ts`) are excluded from the `--collectCoverageFrom="src/lib/**/*.ts"` denominator by design; their changed lines are single-delegation wiring exercised by the reworked extension/service tests (all green). Disposition: **PASS** (each new file exceeds line >= 85% and branch >= 75%; `file-prompt-variables.ts` branch at 75.75% clears the 75% floor with a thin margin). Evidence: `evidence/qa-gates/f5-final-test-coverage.md`, `evidence/qa-gates/f5-coverage-delta.md`, and the independent re-run in Appendix B.
- Python: Baseline / Post-change / Change: none (no changed files). Disposition: N/A. Evidence: no Python source files in the branch diff.
- PowerShell: none (no changed files). Disposition: N/A.
- C#: none (no changed files). Disposition: N/A.

---

## Executive Summary

This review evaluates the F5 feature branch `feat/ts-port-resolve-prompts-240` (head `f2425fb`) against base `main` (merge-base `c82de73`). The branch ports the bundled `resolve_hard_lock_prompt.py` and `resolve_file_prompt.py` into in-process TypeScript modules under `extensions/drm-copilot/src/lib/resolve/`, and rewires `RepoAutomationService.resolveExecuteHardLockPrompt()` and `resolveAtomicPlanPrompt()` from Python subprocess spawns to in-process calls via two thin helpers in `repo-automation-service-workflows.ts`.

The full TypeScript toolchain was rerun independently for this audit and passed in a single pass:

- Prettier format check (`npx prettier --check "src/**/*.ts" "test/**/*.ts"`): EXIT 0, "All matched files use Prettier code style!"
- ESLint (`npm run lint`): EXIT 0, 0 errors.
- TypeScript compiler (`npm run typecheck`, `tsc -p ./ --noEmit`): EXIT 0, 0 errors.
- Jest with coverage (`node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"`): EXIT 0, 698/698 tests passing across 60 suites; All-files aggregate 96.3% line / 88.06% branch.

The five new resolver files report: `hard-lock-prompt.ts` 94.33% line / 83.58% branch; `file-prompt-core.ts` 98.67% line / 84% branch; `file-prompt-variables.ts` 95.25% line / 75.75% branch; `file-prompt-transforms.ts` 100% line / 86.66% branch; `resolve-prompts-service-call.ts` 100% line / 100% branch. All exceed the uniform thresholds (line >= 85%, branch >= 75%).

The port is host-neutral: all file I/O flows through the injected F1 `FileSystem`; work-mode resolution reuses `prompt-mode-contract.ts`; clipboard and stdout are injectable seams defaulted so no real OS clipboard, subprocess, or process stdout runs on the quiet/MCP path or in unit tests. The hard-lock `quiet`-without-`output` guard throws the verbatim message `resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.` at the service-call layer before any file work. Service return contracts are preserved exactly (hard-lock: tool/workspaceRoot/summary/artifacts; atomic-plan: tool/workspaceRoot/summary with no artifacts).

File-size check: every changed file is at or under 500 lines. `repo-automation-service.ts` is exactly 500 lines (the limit is "may not exceed 500," so 500 is compliant). The largest new file is `hard-lock-prompt.ts` at 494 lines.

No blocking findings were identified. One informational (non-blocking) finding is recorded: the `RunCodexNativeConverterInput` interface was relocated from `repo-automation-service.ts` to `repo-automation-service-workflows.ts` (still exported and re-imported into the service file). This is a slight expansion beyond the plan's "two method bodies + import changes only" statement, but it is a behavior-neutral move that serves the 500-line invariant and changes no public surface.

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`

**Language-specific policies evaluated:**
- PASS `typescript.md` + `typescript-suppressions.md` (with accepted divergence D1: Jest in lieu of Vitest, and the related `test/` directory layout — both pre-existing, package-wide conditions, not introduced by F5; no suppressions were added by this branch)
- PASS (no changed files) Python `python.md`
- PASS (no changed files) PowerShell
- PASS (no changed files) C#

**Temporary artifacts cleanup:**
- PASS No temporary or one-time scripts were created by this branch; the diff contains only TS source edits, mirrored/updated tests, and feature-folder docs/evidence.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope to a plan, task, phase, or file subset, and no instruction attempted to mark any language with changed files as out of scope, informational only, or not applicable. The caller explicitly directed: "Determine scope yourself per the SKILL invariant," which is consistent with a full feature-vs-base audit.

The caller noted that `artifacts/pr_context.summary.txt` "may misclassify TS files as tooling; use the appendix git name-status and direct `git diff` as authoritative." This is a correction toward the full diff, not a narrowing; it was honored by deriving scope from `git diff --name-status c82de73..f2425fb`. No verbatim narrowing text needs to be recorded.

---

## Evidence Location Compliance

The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, or `artifacts/coverage/`.

- Command: `git diff --name-only c82de73..f2425fb | grep -E '^artifacts/(baselines|baseline|qa|qa-gates|evidence|coverage)/'` → no matches (NO_PROHIBITED_ARTIFACT_PATHS).
- Validator: `python scripts/dev_tools/validate_evidence_locations.py --root .` → EXIT 0 (no violations).
- All F5 evidence artifacts are written under the canonical scheme `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/<kind>/` (`baseline/`, `qa-gates/`, `regression-testing/`).

Verdict: **PASS**. No evidence-location violations. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` was required.

---

## modified-workflow-needs-green-run

The branch diff was scanned for paths matching `.github/workflows/**`, `scripts/benchmarks/**`, and `.github/actions/**`.

- Command: `git diff --name-only c82de73..f2425fb | grep -E '\.github/workflows/|scripts/benchmarks/|\.github/actions/'` → NO_WORKFLOW_CHANGES.

The rule does not fire. No green-run evidence is required. Verdict: **PASS (not applicable)**.

---

## Section 1 — General Code Change Policy (`general-code-change.md`)

| # | Rule | Verdict | Evidence |
|---|------|---------|----------|
| 1.1 | Simplicity first | PASS | Each resolver module has a single concern (`hard-lock-prompt.ts` hard-lock; `file-prompt-variables.ts`/`file-prompt-transforms.ts` pure helpers; `file-prompt-core.ts` orchestrator + CLI shell; `resolve-prompts-service-call.ts` wiring). No deep indirection. |
| 1.2 | Reusability | PASS | F1 `FileSystem`, `toPosixPath`, and `prompt-mode-contract.ts` (`resolveSelectedWorkMode`, `buildFallbackReason`) are reused, not re-ported. `file-prompt-transforms.ts` is a deliberate extraction from `file-prompt-variables.ts` to share transforms and respect the 500-line limit. |
| 1.3 | Extensibility | PASS | Clipboard and log are optional injectable seams with safe defaults; `templateKind` defaults to `execute`. Functions take explicit typed inputs. |
| 1.4 | Separation of concerns | PASS | Pure variable/transform logic is isolated from I/O; all disk access flows through the injected `FileSystem`; the service-call module is the only place that composes paths from `extensionRoot`. |
| 1.5 | Mandatory toolchain loop | PASS | Format/lint/typecheck/test rerun independently this audit, all EXIT 0 in a single pass (Appendix B). |
| 1.6 | File size <= 500 lines | PASS | Max new file 494 lines (`hard-lock-prompt.ts`); `repo-automation-service.ts` exactly 500 (compliant); all test files <= 407. Counts in Appendix B. |
| 1.7 | Error handling, fail-fast | PASS | Command shells return explicit exit-1 with specific error strings; the service-call layer rethrows non-zero outcomes as Errors carrying the emitted text; `replaceAllVariables` raises on unresolved placeholders. No silent error swallowing (the two `catch` blocks fail closed with a fixed reason that mirrors the Python OSError branch and is documented inline). |
| 1.8 | Naming | PASS | camelCase functions/locals, PascalCase types/interfaces, kebab-case filenames; no `I` prefix. |
| 1.9 | Public API compatibility | PASS | Service method signatures and return contracts unchanged; `RunCodexNativeConverterInput` relocated but still exported and referenced identically (informational finding F-1). |
| 1.10 | Dependencies | PASS | No new runtime dependencies; only `node:path` (path-string math) and existing F1 imports added. |
| 1.11 | I/O boundaries | PASS | No direct `node:fs` in resolver libs (the only `node:fs` token is in a doc comment); core logic testable without disk/network. |

---

## Section 2 — General Unit Test Policy (`general-unit-test.md`)

| # | Rule | Verdict | Evidence |
|---|------|---------|----------|
| 2.1 | Independence / isolation / determinism | PASS | Tests use `@jest/globals` with `Map`-backed in-memory `FileSystem` fakes and `jest.fn()` spies; no shared mutable global state; no real clock/RNG. |
| 2.2 | Fast execution | PASS | Full suite 698 tests in ~2.2s. |
| 2.3 | Readability / AAA | PASS | One behavior per test, Arrange-Act-Assert structure (spot-checked `hard-lock-prompt.test.ts`, `file-prompt-variables.test.ts`). |
| 2.4 | Coverage >= 85% line / >= 75% branch | PASS | All new `src/lib/resolve/**` files meet both thresholds (table above); repo-wide 96.3% line / 88.06% branch. |
| 2.5 | No regression on changed lines | PASS | New files; modified service files are single-delegation wiring covered by reworked extension/service tests (all green). |
| 2.6 | No coverage exclusion of production paths | PASS | No `exclude` entries targeting `src/` production code were added. |
| 2.7 | External dependencies isolated; no temp files | PASS | No real clipboard, subprocess, or temp files; clipboard seam defaults to a no-op returning false; all I/O via injected fake `FileSystem`. |
| 2.8 | Scenario completeness | PASS | Positive, negative (template/target not found, unresolved variable), edge (versioned `v*` parent fallback, fail-closed modes, absolute vs relative output), and guard (`quiet` without `output`) cases present. |
| 2.9 | Test file location mirrors source | PASS | New tests live under `test/lib/resolve/` mirroring `src/lib/resolve/`; not colocated in `src/`. |

---

## Section 3 — TypeScript Policy (`typescript.md`, `typescript-suppressions.md`)

| # | Rule | Verdict | Evidence |
|---|------|---------|----------|
| 3.1 | Formatting (Prettier) | PASS | `prettier --check` EXIT 0. |
| 3.2 | Linting (ESLint) | PASS | `npm run lint` EXIT 0, 0 errors. |
| 3.3 | Type checking (TSC), avoid `any` | PASS | `tsc --noEmit` EXIT 0; no `any` in resolver libs (grep: NO_ANY). |
| 3.4 | Testing framework | PASS (with D1) | Package uses Jest (`run-jest.cjs`, `ts-jest`); `typescript.md` text names Vitest. Accepted divergence D1 in `spec.md`; no Vitest APIs used (grep: NO_VITEST). This is the runnable, CI-exercised toolchain. |
| 3.5 | ES modules | PASS | ES `import`/`export` throughout; no `require`/`module.exports`. |
| 3.6 | Strong typing | PASS | Exported functions/interfaces fully typed; no `as` assertions in resolver libs. |
| 3.7 | Suppressions | PASS | No new ESLint/TS suppressions introduced. |
| 3.8 | Architecture boundaries | PASS | dependency-cruiser is part of lint config; resolver libs depend only on sibling `lib/**` and `node:path`; no host/COM/Office.js imports. |

---

## Section 4 — Scope Containment

The change set matches the plan's allowed list. Verified untouched (grep over diff name-list): `command-runtime.ts`, the `"python"` runtime branch, `resources/templates/*.py`, `resources/scripts/dev_tools/*.py`, `scripts/dev_tools/**`, `src/mcp-handlers/resolve-execute-hard-lock-prompt-handler.ts`, `src/mcp-tools.ts`, `src/mcp-tool-inputs.ts`, `repo-automation-args.ts`. `resolve_execute_plan_prompt.py` (tkinter) was not ported. Verdict: **PASS**. Removal of Python remains F11.

---

## Findings Summary

- Blocking findings: 0
- Material (FAIL/PARTIAL) findings: 0
- Informational findings: 1 (F-1: `RunCodexNativeConverterInput` relocation; behavior-neutral, supports 500-line invariant)

Remediation is NOT triggered by this policy audit. See the code review and feature audit for corroborating verdicts.

---

## Appendix A — Resolved Scope (authoritative, from git diff)

New source (5): `src/lib/resolve/file-prompt-core.ts`, `file-prompt-transforms.ts`, `file-prompt-variables.ts`, `hard-lock-prompt.ts`, `resolve-prompts-service-call.ts`.
Modified source (2): `src/repo-automation-service.ts`, `src/repo-automation-service-workflows.ts`.
New tests (4): `test/lib/resolve/file-prompt-core.test.ts`, `file-prompt-variables.test.ts`, `hard-lock-prompt.test.ts`, `resolve-prompts-service-call.test.ts`.
Modified tests (4): `test/extension.resolve-atomic-plan-prompt.test.ts`, `test/extension.resolve-hard-lock-prompt.test.ts`, `test/repo-automation-hard-lock-prompt.test.ts`, `test/repo-automation-service.resolve-atomic-plan-prompt.test.ts`.
Docs/evidence (6): F5 plan + evidence artifacts under the feature folder.

## Appendix B — Command Reference (independent re-run this audit)

| Stage | Command (cwd `extensions/drm-copilot/`) | Exit | Result |
|-------|------------------------------------------|------|--------|
| Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` | 0 | All files formatted |
| Lint | `npm run lint` (`eslint --no-error-on-unmatched-pattern src test`) | 0 | 0 errors |
| Typecheck | `npm run typecheck` (`tsc -p ./ --noEmit`) | 0 | 0 errors |
| Test+Coverage | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` | 0 | 60 suites / 698 tests pass; All-files 96.3% line / 88.06% branch |
| File sizes | `wc -l` over all changed TS files | 0 | Max 500 (`repo-automation-service.ts`); max new 494 (`hard-lock-prompt.ts`) |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | 0 | No violations |
| Scope/no-fs/no-any | grep over diff + resolver libs | 0 | Prohibited paths untouched; no direct `node:fs`; no `any` |
