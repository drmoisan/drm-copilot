# Feature Audit: F1 — TypeScript Shared Subprocess and Utility Layer (Issue #240)

**Audit Date:** 2026-06-25
**Feature Folder:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
**Base Branch:** `main` @ `38a9c11ee34895e92b6e38ea5400e7dd07cddc9d`
**Head Branch:** `feat/ts-port-shared-utilities-240` @ `b7ca64197c13884e8ed9833ee6937b3a9d827c80`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `38a9c11ee34895e92b6e38ea5400e7dd07cddc9d`)
- **Head branch/commit:** `feat/ts-port-shared-utilities-240` (commit `b7ca64197c13884e8ed9833ee6937b3a9d827c80`)
- **Merge base:** `38a9c11ee34895e92b6e38ea5400e7dd07cddc9d`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (noted stale; see code-review Info finding)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and authoritative `git diff 38a9c11..b7ca641`
  - Feature evidence: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/evidence/**`
  - Additional evidence: independent toolchain re-run (Prettier, ESLint, tsc, Jest+coverage)
- **Feature folder used:** `docs/features/active/2026-06-25-port-python-commands-to-typescript-240`
- **Requirements source:** F1 plan "Acceptance Criteria Checklist (F1)" in `plans/F1-shared-utilities.plan.md` (task-authorized AC source) and the epic AC in `issue.md`.
- **Work mode resolution note:** `issue.md:11` declares `- Work Mode: full-feature`, which per the acceptance-criteria contract resolves AC sources to `spec.md` and `user-story.md`. Neither file exists in this feature folder. Per the caller's explicit authorization and the absence of those files, the F1 plan checklist is used as the operative AC source for this feature audit, supplemented by the epic `issue.md` AC for epic-level context. The missing `spec.md`/`user-story.md` is recorded as a Major gap in the policy audit and code review.
- **Scope note:** Audit scope is the full branch diff (`38a9c11..b7ca641`), not a plan subset. Only TypeScript files changed; Python/PowerShell/C# have zero changed files.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `plans/F1-shared-utilities.plan.md` — operative AC source (F1 feature scope), checkbox-backed.
- `issue.md` — epic-level AC, checkbox-backed (most items are epic-wide, beyond F1 scope).

### Acceptance criteria — F1 plan "Acceptance Criteria Checklist (F1)"

1. `subprocess-runner.ts` exists, exports `CommandResult`, `CommandRunner`, and `SubprocessRunner`; uses `node:child_process` with `Buffer` capture decoded via `buffer.toString("utf8")`; returns typed `{ stdout, stderr, code }`; throws on non-zero exit when `allowError` is false with the message format matching `git.py`.
2. `file-system.ts` exists, exports a `FileSystem` interface and `RealFileSystem` implementation enabling injectable, hermetic file I/O.
3. `prompt-mode-contract.ts` replicates `prompt_mode_contract.py` behavior exactly (functions, constants, error and reason strings).
4. `markdown-label-formatter.ts` replicates `markdown_label_formatter.py` pure-logic and I/O behavior (I/O via injected `FileSystem`); CLI glue intentionally deferred.
5. `json-config.ts` replicates `json_config.py` constants and `iterGovernedFiles` semantics via injected `FileSystem`.
6. All four Jest test files exist under `test/lib/` mirroring the Python test scenarios, plus `subprocess-runner.test.ts` and `file-system.test.ts`.
7. All tests use Jest conventions, AAA structure, and are hermetic (no real subprocess, no temp files).
8. No file exceeds 500 lines.
9. `npm run format`, `npm run lint`, `npm run typecheck` all pass with 0 errors from `extensions/drm-copilot/`.
10. Tests pass with line coverage >= 85% and branch coverage >= 75% for `src/lib/**`.
11. `repo-automation-service.ts`, `command-runtime.ts`, MCP handlers, and policy files are unmodified.
12. All evidence artifacts written under `<FEATURE>/evidence/<kind>/` with required schema fields.

### Acceptance criteria — epic `issue.md` (epic-wide, for context)

E1. Every Python command script invoked by the extension or MCP server has a TypeScript equivalent with parity of behavior.
E2. Test coverage for the TypeScript ports is equal to or better than the Python tests (line >= 85%, branch >= 75%).
E3. The extension and MCP server invoke the TypeScript implementations, not Python.
E4. No remaining runtime dependency on a `python` interpreter for command execution.
E5. All CI gates pass.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | subprocess-runner exports + throw format | PASS | `subprocess-runner.ts:12-16,38-40,87-141` export `CommandResult`/`CommandRunner`/`SubprocessRunner`; throw format matches `git.py:79-81`; tests assert exact message. | `npx tsc -p ./ --noEmit`; `node run-jest.cjs test/lib/subprocess-runner.test.ts` | Buffer decode + null-status handling verified. |
| 2 | file-system FileSystem + RealFileSystem | PASS | `file-system.ts:25-43` interface, `:153-227` `RealFileSystem`; both exported. | `npx tsc -p ./ --noEmit`; `node run-jest.cjs test/lib/file-system.test.ts` | Injectable; tests use in-memory fakes. |
| 3 | prompt-mode-contract parity | PASS | `prompt-mode-contract.ts` mirrors Python functions, constants, error and reason strings; tests assert literals. | `node run-jest.cjs test/lib/prompt-mode-contract.test.ts` | 100% line / 96.29% branch. |
| 4 | markdown-label-formatter parity + injected I/O; CLI deferred | PASS | `markdown-label-formatter.ts` matches `markdown_label_formatter.py:17-100` function-for-function; `readContent`/`writeOutput` take injected `FileSystem`+callbacks; CLI glue deferred per JSDoc. | `node run-jest.cjs test/lib/markdown-label-formatter.test.ts` | Minor parity nit: `splitLines` covers `\n`/`\r`/`\r\n` only (non-blocking; see code review). |
| 5 | json-config constants + iterGovernedFiles | PASS | `json-config.ts:14-31` constants match Python; `:69-105` `iterGovernedFiles` with injected `FileSystem`; parent-exclusion mirrors `path.parents`. | `node run-jest.cjs test/lib/json-config.test.ts` | 96.19% line / 83.33% branch. |
| 6 | All five test files exist | PASS | `test/lib/{subprocess-runner,file-system,prompt-mode-contract,markdown-label-formatter,json-config}.test.ts` present. | `ls extensions/drm-copilot/test/lib/` | 5 suites, 76 tests. |
| 7 | Jest conventions, AAA, hermetic | PASS | `@jest/globals` imports; `jest.mock`/`jest.fn`; `afterEach` resets; AAA comments; in-memory fakes; no temp files. | inspection; `node run-jest.cjs test/lib` | No real subprocess/filesystem. |
| 8 | No file exceeds 500 lines | PASS | Max 288 (test) / 241 (src). | `wc -l src/lib/*.ts test/lib/*.ts` | All under 500. |
| 9 | format/lint/typecheck pass, 0 errors | PASS | Prettier clean; ESLint 0 findings; tsc 0 errors (re-run by review). | `npx prettier --check ...`; `npx eslint ... src/lib test`; `npx tsc -p ./ --noEmit` | Reproduces executor evidence. |
| 10 | src/lib coverage >= 85% line, >= 75% branch | PASS | All files 97.3% line / 88.13% branch; each file at/above thresholds. | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts" test/lib` | Independently reproduced. |
| 11 | Runtime/handler/policy files unmodified | PASS | `git diff --name-only 38a9c11..HEAD` shows no changes to `command-runtime.ts`, `repo-automation-service.ts`, MCP handlers, `.claude/rules/**`, `.github/instructions/**`. | `git diff --name-only 38a9c11..HEAD` | Only src/lib, test/lib, .gitignore, docs changed. |
| 12 | Evidence artifacts under canonical path with schema fields | PASS | Evidence under `<FEATURE>/evidence/{baseline,qa-gates}/`; validator clean. | `python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0) | No non-canonical evidence paths. |
| E1 | All Python command scripts ported | PARTIAL | F1 ports 4 utilities + FS abstraction only; the epic targets the full `scripts/dev_tools/**` surface (~28,100 LoC). | n/a | Epic-wide AC; out of F1 scope by design. |
| E2 | TS coverage >= Python tests (line >=85%, branch >=75%) | PASS (for F1 modules) | F1 modules at 97.3% line / 88.13% branch. | `node run-jest.cjs --coverage ...` | Epic-wide completion is pending remaining features. |
| E3 | Extension/MCP invoke TS, not Python | FAIL (epic, out of F1 scope) | F1 explicitly does NOT modify `command-runtime.ts`/handlers; no wiring change made. | `git diff --name-only` | Deferred to a later feature per F1 plan constraint. |
| E4 | No runtime Python dependency | FAIL (epic, out of F1 scope) | Python interpreter probing in `command-runtime.ts` unchanged. | `git diff --name-only` | Deferred to a later feature. |
| E5 | All CI gates pass | UNVERIFIED | PR-context CI status "(not available)"; no green workflow run recorded for the branch head. | `artifacts/pr_context.summary.txt` "CI status (HEAD): (not available)" | No `.github/workflows/**` changes on branch; local toolchain passes. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

The F1 feature-scope acceptance criteria (items 1-12) are all PASS: the five modules are implemented with behavioral parity, fully typed, hermetically tested at 97.3% line / 88.13% branch, with all files under 500 lines, a clean toolchain, no out-of-scope modifications, and canonical evidence. The epic-wide criteria (E1, E3, E4) are intentionally out of F1 scope and remain unmet at the epic level; E5 is UNVERIFIED because no CI status is available for the branch head.

The "NEEDS REVISION" verdict reflects two Major policy-reconciliation gaps surfaced in the policy audit and code review, not any F1 code defect: (1) the package's Jest toolchain diverges from the Vitest mandate in `typescript.md`, and (2) the `full-feature` work mode's required AC source files (`spec.md`/`user-story.md`) are absent. F1 itself is functionally complete and mergeable once these are reconciled.

**Criteria summary:**
- **PASS:** 13 criteria (F1 items 1-12; epic E2 for F1 modules)
- **PARTIAL:** 1 criterion (E1)
- **UNVERIFIED:** 1 criterion (E5)
- **FAIL:** 2 criteria (E3, E4 — both epic-wide, out of F1 scope by design)

**Top gaps preventing PASS:**
1. Missing `full-feature` AC source files (`spec.md`/`user-story.md`) — policy/scaffolding gap.
2. Jest-vs-Vitest framework policy divergence — reconcile policy or migrate.
3. CI green-run for the branch head not available (E5 UNVERIFIED).

**Recommended follow-up verification steps:**
1. Author the epic `spec.md`/`user-story.md`, or formally designate the F1 plan checklist as the AC source for this folder.
2. Reconcile `typescript.md` to acknowledge the extension package's Jest toolchain (or schedule a Vitest migration).
3. Trigger a CI run against the branch head to resolve E5; confirm green before merge.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules:
- F1 plan items 1-12 are already marked `[x]` in `plans/F1-shared-utilities.plan.md` by the executor; this audit independently verifies them as PASS, so no checkbox change is required.
- Epic `issue.md` items E1-E5 remain unchecked. E1 (PARTIAL), E3/E4 (FAIL, out of F1 scope), and E5 (UNVERIFIED) must remain unchecked. E2 is satisfied only for the F1 modules, not epic-wide, so its `issue.md` checkbox correctly remains unchecked until the epic completes.
- No checkbox edits were made to source files in this audit: all PASS items in the F1 plan were already checked, and no epic `issue.md` item is fully satisfied at the epic level.

### AC Status Summary

- Source: `plans/F1-shared-utilities.plan.md` (operative) and `issue.md` (epic)
- Total AC items: 12 (F1 plan) + 5 (epic) = 17
- Checked off (delivered): 12 (F1 plan items, pre-checked by executor and verified PASS here)
- Remaining (unchecked): 5 (epic E1-E5)
- Items remaining: E1 (PARTIAL), E2 (epic-wide pending), E3 (FAIL/out-of-scope), E4 (FAIL/out-of-scope), E5 (UNVERIFIED)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `plans/F1-shared-utilities.plan.md` | 12 | 12 | 0 | Checkbox-backed; verified PASS; no change needed (already checked). |
| `issue.md` | 5 | 0 | 5 | Checkbox-backed epic AC; epic-wide, mostly beyond F1 scope; correctly remain unchecked. |
