# Policy Compliance Audit: F7 ts-potential-to-issue (Issue #240)

**Audit Date:** 2026-06-26
**Code Under Test:** F7 feature diff against base `main` at merge-base `cfba7414203f8abff8be3a038e8df32f1f95d73e`. Head `f45cb5ea67e9fb677ed2c9c9e247ebafb3f73997`. TypeScript only.

Production files (new): `extensions/drm-copilot/src/lib/potential-to-issue/{content.ts, gh-client.ts, promotion.ts, promotion-filesystem.ts, potential-to-issue-service-call.ts}`

Production files (modified): `extensions/drm-copilot/src/repo-automation-service.ts`

Test files (new): `content.test.ts`, `gh-client.test.ts`, `promotion.test.ts`, `promotion.missing-label.test.ts`, `potential-to-issue-service-call.test.ts`, and the shared helper `promotion-test-support.ts` under `extensions/drm-copilot/test/lib/potential-to-issue/`.

Test files (modified): `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`, `extensions/drm-copilot/test/extension.integration.test.ts`.

Evidence/plan files (new): plan and `evidence/**` artifacts under the feature folder.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| TypeScript | 5 production + 6 test | 908 tests | 908 pass, 0 fail | `src/lib/**` per F7 baseline evidence (`evidence/baseline/f7-ts-test-baseline.md`) | `src/lib/**` 97.52% lines, 90.66% branches | `lib/potential-to-issue` 99.41% lines, 84.00% branches |

**Note:** No Python, PowerShell, C#, Bash, or JSON production files changed in the F7 diff. Those languages have zero changed files on this branch; their coverage verdicts are N/A on that basis (acceptable per the coverage-verdict rule only because they have zero changed files). The retained Python sources `potential_to_issue.py`/`potential_to_issue_content.py` are unmodified (removal is F11).

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `evidence/baseline/f7-ts-test-baseline.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (regenerated this audit) and `evidence/qa-gates/f7-final-test-coverage.md`
- Coverage-delta artifact: `evidence/qa-gates/f7-coverage-delta.md`
- Python / PowerShell / C# coverage: `N/A - no files changed`

**Non-negotiable verdict rule:** Numeric baseline and post-change coverage are present for the only in-scope language (TypeScript).

### Per-file new-code coverage (TypeScript)

| File | Line% | Branch% | Tier (new) | Verdict |
|------|-------|---------|------------|---------|
| `src/lib/potential-to-issue/content.ts` | 99.16 | 88.70 | new | PASS |
| `src/lib/potential-to-issue/gh-client.ts` | 100.00 | 79.31 | new | PASS |
| `src/lib/potential-to-issue/promotion.ts` | 98.85 | 81.96 | new | PASS |
| `src/lib/potential-to-issue/promotion-filesystem.ts` | 100.00 | 85.71 | new | PASS |
| `src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 100.00 | 81.25 | new | PASS |

All new files meet line >= 85% and branch >= 75%. `repo-automation-service.ts` (modified) is exercised by the existing extension suite; the modified hunk is a single delegation. Repo-wide `src/lib/**` 97.52% line / 90.66% branch — no regression.

**TypeScript coverage verdict: PASS.**

---

## Rejected Scope Narrowing

The caller prompt did not attempt to narrow the audit scope. It explicitly instructed the reviewer to "Determine scope yourself per the SKILL invariant" and to audit the full branch diff. No narrowing language ("plan scope only," "out of scope," "informational only," or a per-language skip) was present. The audit scope is the full branch diff against `main` at merge-base `cfba7414203f8abff8be3a038e8df32f1f95d73e`. No rejection record is required.

---

## Evidence Location Compliance

`scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 (no violations). All evidence artifacts are written under the canonical `<FEATURE>/evidence/<kind>/` scheme:
- `evidence/baseline/` — Phase 0 baseline and policy-read artifacts.
- `evidence/qa-gates/` — final format/lint/typecheck/test-coverage/coverage-delta/scope-verification artifacts.
- `evidence/regression-testing/` — port behavior-parity capture.

No file in the branch diff was written under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/evidence/`, or `artifacts/regression-testing/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` records were required.

---

## Executive Summary

F7 ports the Python `potential_to_issue` promotion command (gh CLI workflow + content/metadata helpers) to in-process TypeScript under `extensions/drm-copilot/src/lib/potential-to-issue/**` and rewires `RepoAutomationService.potentialToIssue()` to call the extracted `potential-to-issue-service-call.ts` helper instead of spawning the bundled Python script. The reviewer independently re-ran the full TypeScript toolchain (format check, lint, typecheck, full test suite with coverage) against the working tree. All stages passed: Prettier check clean (all files "unchanged", working tree confirmed clean afterward), ESLint 0 errors, `tsc --noEmit` 0 errors, 908/908 Jest tests passing across 78 suites. Coverage for every new `src/lib/potential-to-issue/*.ts` file meets line >= 85% and branch >= 75%; repo-wide `src/lib/**` is 97.52% line / 90.66% branch with no regression.

The scope is TypeScript-only. No Python source, `command-runtime.ts`, `executeScript`, the `"python"` runtime branch, or `resources/**/*.py` file was modified, consistent with the F7 plan (Python removal is deferred to F11). The diff touches exactly one service method (`potentialToIssue`).

**Policy documents evaluated:**
- PASS `general-code-change.md`
- PASS `general-unit-test.md`

**Language-specific policies evaluated:**
- N/A `python-*` (no Python production files changed)
- N/A `powershell-*` (no PowerShell files changed)
- PASS `typescript.md` + `typescript-suppressions.md`
- N/A C# (no C# files changed)
- N/A Bash, JSON (no such files changed)

Coverage, toolchain, file size, and architecture-related (no host-bound imports in domain code) checks all pass. The TypeScript test framework is Jest, not Vitest; this is the documented accepted divergence D1 (spec.md), a pre-existing package-wide condition, not introduced by F7.

---

## 1. Toolchain Compliance

All commands run from `extensions/drm-copilot/`.

| Stage | Command | Result | Verdict |
|-------|---------|--------|---------|
| Format | `npm run format` (Prettier) | All files reported "unchanged"; `git status --porcelain` clean afterward | PASS |
| Lint | `npm run lint` (ESLint, `src test`) | 0 errors, 0 warnings | PASS |
| Type check | `npm run typecheck` (`tsc -p ./ --noEmit`) | 0 errors | PASS |
| Tests | `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` | 78 suites pass, 908/908 tests pass | PASS |
| Coverage | (same command) | new files all >= 85% line / >= 75% branch; repo-wide `src/lib/**` 97.52% / 90.66% | PASS |

Architecture-boundary check: this package has no `.dependency-cruiser.cjs` and no `depcruise` npm script (dependency-cruiser runs at repo CI, not in this package locally). The reviewer verified by inspection that the F7 domain modules (`content.ts`, `promotion.ts`) perform no host-bound or filesystem/subprocess access; all external interaction is isolated to injectable seams (`PotentialFileSystem`, `GhClient`) with `node:child_process`/`node:fs` confined to injectable production defaults (`SpawnSyncGhCommandRunner`, `defaultGhPathLookup`, `RealPotentialFileSystem`). This satisfies the separation-of-concerns and I/O-boundary requirements of `general-code-change.md`. Verdict: PASS (by inspection).

## 2. File Size Compliance (500-line limit)

| File | Lines | Verdict |
|------|-------|---------|
| `src/lib/potential-to-issue/content.ts` | 481 | PASS |
| `src/lib/potential-to-issue/gh-client.ts` | 330 | PASS |
| `src/lib/potential-to-issue/promotion.ts` | 435 | PASS |
| `src/lib/potential-to-issue/promotion-filesystem.ts` | 91 | PASS |
| `src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 192 | PASS |
| `src/repo-automation-service.ts` (modified) | 496 | PASS (was 500; net -4) |
| `test/extension.potential-to-issue.test.ts` | 498 | PASS |
| `test/lib/potential-to-issue/content.test.ts` | 413 | PASS |
| `test/lib/potential-to-issue/gh-client.test.ts` | 258 | PASS |
| `test/lib/potential-to-issue/promotion.test.ts` | 427 | PASS |
| `test/lib/potential-to-issue/promotion.missing-label.test.ts` | 218 | PASS |
| `test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` | 199 | PASS |
| `test/lib/potential-to-issue/promotion-test-support.ts` | 125 | PASS |

No file exceeds 500 lines. `content.ts` at 481 and `extension.potential-to-issue.test.ts` at 498 are within the limit. The plan's contingent splits (`promotion-filesystem.ts` extraction) were taken to keep `promotion.ts` under 500. Verdict: PASS.

## 3. General Code-Change Policy

- Design principles: simplicity, separation of pure logic (`content.ts`) from I/O (`promotion-filesystem.ts`, `gh-client.ts`) and service glue (`potential-to-issue-service-call.ts`). PASS.
- Public-API extensibility: the port reuses the F1 `CommandRunner`/`FileSystem`/`prompt-mode-contract` surfaces without widening them; the stdin requirement is satisfied via a narrow port-local `GhCommandRunner` seam rather than modifying the shared `CommandRunner` interface (plan Parity Note choice b). PASS.
- Error handling: fail-fast `PromotionError` with byte-identical messages; the service-call helper rethrows a non-zero outcome as `Error("Command exited with code <n>.<detail>")`, preserving the prior Python-spawn failure surface. PASS.
- Dependencies: no new runtime dependencies. PASS.
- I/O boundaries: domain logic is testable without network/filesystem; tests inject in-memory fakes. PASS.

## 4. General Unit-Test Policy

- Independence/isolation/determinism: tests use `@jest/globals`, AAA structure, in-memory `FakePotentialFileSystem` and `FakeGhClient`; no real `gh`/`git`/subprocess/temp files. PASS.
- `extractLastUpdated` parses the supplied ISO timestamp deterministically (no wall-clock access), satisfying the determinism-infrastructure requirement. PASS.
- Scenario completeness: positive/negative/edge cases covered (invalid type, invalid mode, unauthenticated gh, missing file, empty file, bug/minor-audit routing, missing-label recovery with and without retry, label-specific matching). PASS.
- Test file location: tests mirror source under `test/lib/potential-to-issue/`; no colocation in `src/`. PASS.
- Coverage exclusion: no production `src/` path is excluded from coverage. PASS.

## 5. TypeScript-Specific Policy

- Strong typing, no `any` in the new source (verified by grep). PASS.
- ES modules, kebab-case filenames, no `I` prefix on interfaces. PASS.
- No new ESLint/TS suppressions introduced (lint 0 errors). PASS.
- Test framework is Jest, not Vitest — documented accepted divergence D1 (spec.md), pre-existing and package-wide. PARTIAL relative to the literal `typescript.md` text, reconciled by D1; not an F7-introduced violation. See note below.

**D1 reconciliation:** `.claude/rules/typescript.md` text names Vitest as the test framework. The `extensions/drm-copilot` package's real, CI-exercised toolchain is Jest (`jest.config.cjs`, `ts-jest`, `run-jest.cjs`). This divergence is recorded as accepted decision D1 in `spec.md` and is a policy-reconciliation matter for the whole package, not an F7 blocker.

## 6. Policy Rule: modified-workflow-needs-green-run

The branch diff modifies no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` (verified). The rule does not fire. Verdict: PASS / not applicable.

## 7. Benchmark Baseline Provenance

No benchmark baseline files are added or modified. Not applicable.

---

## Findings Summary

| # | Severity | Finding |
|---|----------|---------|
| 1 | Informational | Jest-vs-Vitest divergence (D1) is a pre-existing, documented package-wide reconciliation item, not introduced by F7. |
| 2 | Informational | `content.ts` (481) and `extension.potential-to-issue.test.ts` (498) are within but close to the 500-line limit; future additions should monitor headroom. |

**Blocking findings: 0.**
**PARTIAL/FAIL findings requiring remediation: 0.**

Overall policy verdict: **PASS.**

---

## Appendix A — Scope Determination

- Base branch: `main` (supplied and matches `pr_context.summary.txt` resolved base `origin/main @ cfba741`).
- Merge-base SHA: `cfba7414203f8abff8be3a038e8df32f1f95d73e`.
- Head SHA: `f45cb5ea67e9fb677ed2c9c9e247ebafb3f73997`.
- Scope derived from `git diff --name-status cfba741...HEAD` (authoritative per memory note: the PR-context summary misclassifies TS as tooling for epic #240; the name-status diff and direct `git diff` were used instead).
- Languages with changed files: TypeScript only.

## Appendix B — Command Reference

```
# from extensions/drm-copilot/
npm run format            # Prettier check — all unchanged
git status --porcelain    # clean after format
npm run lint              # ESLint — 0 errors
npm run typecheck         # tsc --noEmit — 0 errors
node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"   # 908/908 pass

# from repo root
git diff --name-status cfba7414203f8abff8be3a038e8df32f1f95d73e...HEAD
python scripts/dev_tools/validate_evidence_locations.py --root .       # exit 0
```
