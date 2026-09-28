# Policy Compliance Audit: mergeable-project-file-overlaps (Issue #643)

**Audit Date:** 2026-09-07
**Timestamp clock:** UTC (`2026-09-07T18-08` = 2026-09-07 18:08Z). Recorded explicitly because the executor's evidence artifacts under `evidence/` use a different clock; see Gap G-3.
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643`
**Base Branch:** `main` @ `ef83a2e0e26fc8486d6b9be259bf195f0a8e29c9` (merge base, resolved per `.claude/skills/pr-base-branch-merge-base/SKILL.md`)
**Head Branch:** `feature/mergeable-project-file-overlaps-643` @ `515bf1547dcebf029238d3c04ac764ea0462876d`
**Range audited:** `ef83a2e0..515bf154` — 166 files changed, 10,860 insertions, 334 deletions, 11 commits
**Work Mode:** `full-feature` (marker read from `issue.md` line 10)

**Code Under Test (production, non-fixture, non-doc):**

| Language | Added | Modified |
|---|---|---|
| Python | `scripts/dev_tools/_blast_radius_mergeable.py` | `scripts/dev_tools/_blast_radius_conflicts.py`, `scripts/dev_tools/compute_blast_radius.py` |
| PowerShell | `.claude/lib/blast-radius/BlastRadiusConflict.psm1`, `.claude/lib/project-file-merge/ProjectFileMerge.psm1`, `.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1`, `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` (+ 4 published mirrors) | `.claude/lib/blast-radius/BlastRadius.psm1` (+ mirror), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (+ mirror) |
| TypeScript | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` |
| JSON / config | — | `config/blast-radius.json` (+ published mirror), `pack-manifests/core.json`, `extensions/drm-copilot/jest.config.cjs`, `.gitattributes` |
| C# | none | none |
| Bash | none | none |

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 3 prod + 5 test | 4,278 collected | 4,273 pass, 1 fail (pre-existing, C4-exempt), 5 skipped | 92.71% lines / 85.30% branch (pytest-cov) | 92.72% lines / 85.32% branch (pytest-cov); 92.90% / 85.52% on the reviewer's lcov re-parse | `_blast_radius_mergeable.py` 96.43% lines / 92.86% branch |
| TypeScript | 2 prod + 7 test | 2,990 | ✅ 2,990 pass, 0 fail | 96.72% lines / 90.17% branch | 96.88% lines / 90.45% branch (reviewer-parsed lcov) | `claude-blast-radius-derive-manifests.ts` 100% lines / 95.65% branch |
| PowerShell | 5 prod (+5 mirrors) + 8 test | 4,008 | ✅ 4,008 pass, 0 fail, 9 skipped | 94.80% lines | 94.85% lines (reviewer-parsed JaCoCo) | 86.15%–100% per new file (see §1.2.1) |
| JSON | 4 files | n/a | ✅ parses; parity assertions pass | n/a (config files) | n/a (config files) | n/a |
| C# | 0 files | n/a | N/A | N/A | N/A | N/A |
| Bash | 0 files | n/a | N/A | N/A | N/A | N/A |

C# and Bash rows are retained rather than deleted so the zero-changed-file basis for their `N/A`
verdicts is explicit. `git ls-files "*.cs"` returns 0 across the whole repository; the 37 `.csproj`
and 9 `.config` paths in the diff are all inert text fixtures under
`tests/fixtures/project_file_merge/` (verified: 0 non-fixture project files in the diff).
`git diff --name-only ef83a2e0..515bf154 -- '*.sh'` returns 0 paths.

### Coverage Evidence Checklist

Required evidence lines, one per language plus the comparison pointer. Paths are repo-relative.

- Python baseline coverage artifact: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`
- Python post-change coverage artifact: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-python-pytest-coverage.2026-09-07T18-40.md` (machine-readable source parsed by the reviewer: `artifacts/python/lcov.info`)
- TypeScript baseline coverage artifact: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-jest-coverage.2026-09-07T15-20.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-typescript-jest-coverage.2026-09-07T18-54.md` (machine-readable source parsed by the reviewer: `extensions/drm-copilot/coverage/lcov.info`)
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/powershell-poshqc-test.2026-09-07T15-25.md`
- PowerShell post-change coverage artifact: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/final-powershell-poshqc-test.2026-09-07T19-25.md` (machine-readable source parsed by the reviewer: `artifacts/pester/powershell-coverage.xml`)
- C# baseline coverage artifact: N/A - out of scope; zero C# source files exist in the repository (`git ls-files "*.cs"` returns 0)
- C# post-change coverage artifact: N/A - out of scope; zero C# source files exist in the repository
- Bash baseline coverage artifact: N/A - out of scope; zero bash files changed on the branch
- Bash post-change coverage artifact: N/A - out of scope; zero bash files changed on the branch
- Per-language comparison summary: section 1.2.1 of this audit, corroborated by `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/coverage-delta.2026-09-07T19-35.md` and `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa-gates/post-rebase-qa.2026-09-07T17-56.md`

Reviewer confirmations:

- [x] Coverage artifact located for every language with changed files
- [x] Repo-wide per-language line coverage >= 85%
- [x] Repo-wide per-language branch coverage >= 75% for branch-capable languages
- [x] Every new production file >= 85% line coverage
- [x] Every modified production file >= 85% line coverage and no regression
- [x] Coverage figures independently re-parsed by the reviewer from the artifacts, not copied from executor evidence
- [x] No production path excluded from coverage measurement

---

## Executive Summary

The branch adds an optional `mergeable_paths` class to the blast-radius truth table and applies it at
exactly one point per runtime — inside the Python `conflicts` relation and inside the PowerShell
`Test-BlastRadiusConflict` — so a path overlap on a project file contributes no `path_overlap` edge
while the path itself stays in every recorded radius. It also removes the .NET manifest family from
module derivation at push-down and adds a three-file PowerShell library that resolves a conflict
confined to project files as a keyed union, with a never-drop post-condition and an all-or-nothing
escalation contract.

All seven applicable toolchain stages pass. The reviewer independently re-ran format, lint, and type
check for Python and TypeScript, the feature's Python and Jest suites, and the full PowerShell
blast-radius and project-file-merge Pester suites; all passed. Coverage was verified by parsing the
three pre-existing coverage artifacts directly rather than by re-running generation, and every
repo-wide and per-file threshold is met with margin. No suppression token (`type: ignore`, `noqa`,
`eslint-disable`, `@ts-expect-error`, `as any`, `SuppressMessage`) appears anywhere in the added
lines. No changed file exceeds the 500-line ceiling. Every published mirror is byte-equal to its
self-hosted source. `validate_evidence_locations.py --root .` exits 0.

**Overall verdict: FULLY COMPLIANT.** Zero Blocking findings. Four advisory findings are recorded in
§8; none of them changes the verdict or requires remediation before PR.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | ✅ PASS | The Python modules build every input from a module-level literal or a committed fixture; the Pester suites use `BeforeAll`-scoped `$script:` fixtures and mock `Invoke-GitExe`; the Jest suites inject an observation array rather than reading a directory. Targeted runs in isolation (166 Python, 192 Jest, 488 + 6 Pester) all pass, which they could not do if they depended on sibling-test order. |
| Isolation | ✅ PASS | Each `It` / `it` / `def test_` names one behavior. Example: `test_config_mergeable_paths_rejects_a_blank_entry` exercises only the reader's validation branch. |
| Fast execution | ✅ PASS | Targeted Python modules 0.38 s; targeted Jest suites 0.85 s; blast-radius + project-file-merge Pester 26.2 s (dominated by the pre-existing 16.3 s `BlastRadius.Parity.Tests.ps1`). |
| Determinism | ✅ PASS | No wall-clock read, no RNG, no network. `Resolve-MergeableConflict.Tests.ps1` mocks the single git seam. Ordering is ordinal throughout (`[StringComparer]::Ordinal`, `compareOrdinal`, `sorted()`), which is what makes cross-runtime parity assertions reproducible. |
| Readability / maintainability | ✅ PASS | Arrange/Act/Assert comments are present in the added Jest and Pester cases; every added Python test carries a docstring. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|---|---|---|
| Line coverage >= 85% (all tiers) | ✅ PASS | Python 92.90%, TypeScript 96.88%, PowerShell 94.85% — all reviewer-parsed. |
| Branch coverage >= 75% (branch-capable languages) | ✅ PASS | Python 85.52%, TypeScript 90.45%. PowerShell exempt (Pester measures command and line coverage only). |
| No regression on changed lines | ✅ PASS | `evidence/qa-gates/coverage-delta.2026-09-07T19-35.md` records every run-level metric rising, not falling; reviewer re-parse reproduces the final values. |
| Positive flows | ✅ PASS | Keyed-union resolution for all five MSBuild item types in both syntactic forms; `packages.config` and `app.config` union and higher-version selection. |
| Negative flows | ✅ PASS | Non-list `mergeable_paths`, blank entry, absent key, empty list, ungrammatical hunk line, unterminated hunk, unparseable version, same key at same version with differing attributes, invalid UTF-8, non-mergeable path in the conflict set. |
| Edge cases / boundaries | ✅ PASS | Root-level file against a `**/`-anchored pattern; a declared glob that would contain a mergeable path still contends; BOM preservation; CRLF terminator preservation; `diff3`/`zdiff3` hunk style. |
| Error handling | ✅ PASS | Every escalation path returns `{"result":"escalate"}` with `escalate_paths` and writes nothing; asserted in `Resolve-MergeableConflict.Tests.ps1`. |
| Concurrency | N/A | No concurrent code paths introduced. |
| State transitions | ✅ PASS | The all-or-nothing pending/write split is asserted: no partially merged worktree is reachable. |

### 1.2.1 Per-Language Coverage Comparison

Reviewer verification method: parse the pre-existing coverage artifacts. Coverage generation was NOT
re-run.

One comparison bullet per in-scope language that carries coverage requirements. JSON, C#, and Bash
carry none on this branch and are recorded as out of scope in the checklist above rather than here.

- Python: Baseline: 92.71% statements / 85.30% branch -> Post-change: 92.72% statements / 85.32% branch. Change: +0.01 percentage points statements, +0.02 percentage points branch, both upward. New/changed-code coverage: 96.43% lines and 92.86% branch on the new module `_blast_radius_mergeable.py`; 100% lines and 100% branch on both modified modules. Disposition: PASS. Evidence: `evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`, `evidence/qa-gates/final-python-pytest-coverage.2026-09-07T18-40.md`, `evidence/qa-gates/coverage-delta.2026-09-07T19-35.md`; reviewer re-parse of `artifacts/python/lcov.info` yields 92.90% lines and 85.52% branch on the wider lcov denominator, which spans `src` as well as `scripts/dev_tools`.
- TypeScript: Baseline: 96.72% lines / 90.17% branch -> Post-change: 96.88% lines / 90.45% branch. Change: +0.16 percentage points lines, +0.28 percentage points branch, both upward. New/changed-code coverage: 100% lines and 95.65% branch on the new module `claude-blast-radius-derive-manifests.ts`; 100% lines and 97.50% branch on the modified `claude-blast-radius-derive-core.ts`, whose branch figure rose from 95.83%. Disposition: PASS. Evidence: `evidence/baseline/typescript-jest-coverage.2026-09-07T15-20.md`, `evidence/qa-gates/final-typescript-jest-coverage.2026-09-07T18-54.md`, `evidence/qa-gates/post-rebase-qa.2026-09-07T17-56.md`; reviewer re-parse of `extensions/drm-copilot/coverage/lcov.info` reproduces 47881/49421 lines and 6839/7561 branches.
- PowerShell: Baseline: 94.80% lines -> Post-change: 94.85% lines. Change: +0.05 percentage points lines, upward; Pester emits no `BRANCH` counter for these sources, so no branch percentage exists to compare and the branch threshold does not apply. New/changed-code coverage: 86.15% lines at the lowest new file (`Resolve-MergeableConflict.ps1`, 56/65) and 100% at the highest (`ProjectFileMerge.psm1`, 124/124); the modified `BlastRadius.psm1` holds at 100%. Disposition: PASS. Evidence: `evidence/baseline/powershell-poshqc-test.2026-09-07T15-25.md`, `evidence/qa-gates/final-powershell-poshqc-test.2026-09-07T19-25.md`, `evidence/qa-gates/coverage-delta.2026-09-07T19-35.md`; reviewer re-parse of `artifacts/pester/powershell-coverage.xml` yields report-level `LINE` 7777/8199.

Evidence paths in the three bullets above are relative to
`docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/`; the coverage artifacts are
repo-relative. The per-language tables that follow give the same figures in full.

**Python — `artifacts/python/lcov.info`**

| Scope | Lines | Branch | Threshold | Verdict |
|---|---|---|---|---|
| Repo-wide (187 files) | 14681/15803 = 92.90% | 4921/5754 = 85.52% | >= 85 / >= 75 | ✅ PASS |
| `_blast_radius_mergeable.py` (new) | 27/28 = 96.43% | 13/14 = 92.86% | >= 85 / >= 75 | ✅ PASS |
| `_blast_radius_conflicts.py` (modified) | 62/62 = 100.00% | 22/22 = 100.00% | >= 85 / >= 75, no regression | ✅ PASS |
| `compute_blast_radius.py` (modified) | 72/72 = 100.00% | 10/10 = 100.00% | >= 85 / >= 75, no regression | ✅ PASS |

**TypeScript — `extensions/drm-copilot/coverage/lcov.info`**

| Scope | Lines | Branch | Threshold | Verdict |
|---|---|---|---|---|
| Repo-wide (200 files) | 47881/49421 = 96.88% | 6839/7561 = 90.45% | >= 85 / >= 75 | ✅ PASS |
| `claude-blast-radius-derive-manifests.ts` (new) | 200/200 = 100.00% | 22/23 = 95.65% | >= 85 / >= 75 | ✅ PASS |
| `claude-blast-radius-derive-core.ts` (modified) | 380/380 = 100.00% | 39/40 = 97.50% | >= 85 / >= 75, no regression (branch rose from 95.83%) | ✅ PASS |

The canonical artifact path in the skill table is `coverage/lcov.info`. In this repository the sole
TypeScript project root is `extensions/drm-copilot/`, and `jest.config.cjs` writes its coverage there;
`extensions/drm-copilot/coverage/lcov.info` is therefore the project-relative instance of the same
artifact, not a non-canonical substitute. Recorded here so the path difference is auditable.

**PowerShell — `artifacts/pester/powershell-coverage.xml` (JaCoCo `LINE` counters)**

| Scope | Lines | Threshold | Verdict |
|---|---|---|---|
| Report-level | 7777/8199 = 94.85% | >= 85 | ✅ PASS |
| `BlastRadiusConflict.psm1` (new) | 42/43 = 97.67% | >= 85 | ✅ PASS |
| `ProjectFileMergeGrammar.psm1` (new) | 121/122 = 99.18% | >= 85 | ✅ PASS |
| `ProjectFileMerge.psm1` (new) | 124/124 = 100.00% | >= 85 | ✅ PASS |
| `Resolve-MergeableConflict.ps1` (new) | 56/65 = 86.15% | >= 85 | ✅ PASS |
| `BlastRadius.psm1` (modified) | 97/97 = 100.00% | >= 85, no regression | ✅ PASS |

No branch column is evaluated for PowerShell. The report carries `INSTRUCTION`, `LINE`, `METHOD`, and
`CLASS` counters and no `BRANCH` counter, because Pester measures command and line coverage only.
Per `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md` this is a threshold
exemption on an unevaluable metric, not a file exclusion: all five PowerShell production files of
this feature are in the denominator.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Arrange–Act–Assert | ✅ PASS | Explicit `// Arrange` / `// Act` / `// Assert` comments in the added Jest cases and `# Arrange` markers in the added Python tests; Pester cases follow the same three-part shape. |
| Actionable failure messages | ✅ PASS | Escalation reasons carry the offending key and the 1-based hunk line (`'the hunk opening at line {0} is outside the merge grammar'`); the corpus-floor guards print discovered-versus-expected counts. |
| Descriptive names / docstrings | ✅ PASS | Names encode the scenario (e.g. `test_conflicts_still_contends_for_a_declared_glob_entry`). |
| Logical grouping | ✅ PASS | `describe("issue #643: manifest suffix families")`, `describe("issue #643: multi-project .NET classification")`, and equivalent Pester `Describe` blocks. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| No external services | ✅ PASS | Grep over the added test files found no network, database, or remote-API access. |
| Mocks/stubs at seams | ✅ PASS | `Invoke-GitExe` is the single executable seam and is mocked; the Jest suites inject a directory-observation list instead of scanning disk. |
| No temporary files | ✅ PASS | Grep for `temp`, `TEMP`, `New-TemporaryFile`, `GetTempPath`, `tmp_path`, `tempfile`, `TestDrive` across the added test files returned only comment lines asserting that no temporary file is created. The single write-path case runs `Write-MergedFile ... -WhatIf` and then asserts `Test-Path ... | Should -BeFalse`. |
| No mutable global state | ✅ PASS | Module-scope state is read-only constants; the reader and matcher are pure. |

### 1.5 Policy Audit Requirement

✅ PASS — this artifact.

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

✅ PASS — `evidence/baseline/phase0-instructions-read.2026-09-07T15-07.md` records the mandated
policy reading order, and the 13 baseline artifacts under `evidence/baseline/` capture the
pre-change state of every gate that was later re-run.

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| Simplicity first | ✅ PASS | The exclusion is one filter applied at one call site per runtime. The merge library works on lines as opaque text and uses no XML DOM, which removes an entire class of reserialization behavior rather than compensating for it. |
| Reusability | ✅ PASS | `matches_mergeable_path` delegates its first two comparison steps to the existing `matches_mandate_read` rather than restating them; the comment states the reason (a divergence would silently split two exclusions that share a vocabulary). |
| Extensibility | ✅ PASS | `mergeable_paths` is optional and fail-closed, so a destination that has not received the published truth table behaves exactly as before — the key is itself the rollout control. `MODULE_MANIFEST_SUFFIXES` / `NON_MODULE_MANIFEST_SUFFIXES` is a declared extension point. |
| Separation of concerns | ✅ PASS | Pure logic (`ProjectFileMergeGrammar.psm1`, `ProjectFileMerge.psm1`, `_blast_radius_mergeable.py`, `claude-blast-radius-derive-manifests.ts`) is separated from I/O (`Resolve-MergeableConflict.ps1`, which owns every file read, file write, and git call). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| 500-line ceiling | ✅ PASS | Reviewer re-ran an independent `wc -l` scan over every changed `.py`/`.ps1`/`.psm1`/`.psd1`/`.ts`/`.cjs`/`.json` path outside `tests/fixtures/`: zero files over 500. Largest production file is `BlastRadius.psm1` at 438; largest test file is `BlastRadius.Conflict.Tests.ps1` at 490. |
| Test files mirror source tree | ✅ PASS | `.claude/lib/project-file-merge/*` → `tests/scripts/claude-lib/project-file-merge/*.Tests.ps1`; `scripts/dev_tools/*.py` → `tests/scripts/dev_tools/test_*.py`; `src/lib/push-down/*.ts` → `test/lib/push-down/*.test.ts`. No colocation. |
| Splits taken to stay under the ceiling | ✅ PASS | `BlastRadiusConflict.psm1` takes the two helpers relocated out of `BlastRadius.psm1`; `claude-blast-radius-derive-manifests.ts` takes the manifest vocabulary out of `claude-blast-radius-derive-core.ts`; `_blast_radius_mergeable.py` is a new leaf rather than an addition to `_blast_radius_validation.py`. |

### 2.4 Naming, Docs, and Comments

✅ PASS — `snake_case` Python functions, `camelCase` TypeScript locals with `PascalCase` types,
`Verb-Noun` PowerShell functions using approved verbs (`Get-`, `Test-`, `Merge-`, `ConvertTo-`,
`Read-`, `Write-`, `Invoke-`, `Resolve-`). Comments state the reason for a decision rather than
restating the code — for example the import-order comment in `Resolve-MergeableConflict.ps1`
explaining that reversing the two `Import-Module` calls would take the grammar commands out of
script scope.

### 2.5 After Making Changes — Toolchain Execution

Seven-stage loop, per language. Reviewer re-ran the stages marked "reviewer-verified".

| Stage | Python | TypeScript | PowerShell |
|---|---|---|---|
| 1 Formatting | ✅ `black --check .` → 0 (reviewer-verified) | ✅ `prettier --check` → 0 (reviewer-verified) | ✅ `run_poshqc_format` → ok, tree clean (executor evidence) |
| 2 Linting | ✅ `ruff check .` → 0 (reviewer-verified) | ✅ `npm run lint` → 0 (reviewer-verified) | ✅ `run_poshqc_analyze` → ok (executor evidence) |
| 3 Type check | ✅ `pyright` → 0 errors, 0 warnings (reviewer-verified) | ✅ `npm run typecheck` → 0 (reviewer-verified) | N/A — stage skipped for PowerShell by `.claude/rules/general-code-change.md` |
| 4 Architecture boundary | ✅ parity/key-partition suites pass (reviewer-verified) | ✅ forbidden-glob guard + `PAYLOAD_MODULES` non-vacuity cases pass (reviewer-verified) | ✅ `ClaudeLibModuleConvention.Tests.ps1` 6/6 pass (reviewer-verified) |
| 5 Unit tests | ✅ 166 targeted pass (reviewer-verified); 4,273 pass full suite (executor evidence) | ✅ 192 targeted pass (reviewer-verified); 2,990 pass full suite (executor evidence) | ✅ 488 pass targeted (reviewer-verified); 4,008 pass full suite (executor evidence) |
| 6 Contract / schema | ✅ config-parity and key-partition suites pass (reviewer-verified) | ✅ `claude-config-carriage.test.ts` passes (reviewer-verified) | ✅ `BlastRadius.KeyPartition.Tests.ps1`, `ProjectFileMerge.Manifest.Tests.ps1` pass (reviewer-verified) |
| 7 Integration | ✅ `test_poshqc_bundled_parity.py` passes (reviewer-verified) | ✅ push-down pack carriage suites pass (reviewer-verified) | ✅ `BlastRadius.Parity.Tests.ps1` passes (reviewer-verified) |

Loop restarts are documented in `evidence/qa-gates/final-qa-loop-outcome.2026-09-07T19-32.md`: two
for Python, two for TypeScript, three for PowerShell, with the final pass of every stage recorded
after the last source change. The reviewer confirmed the ordering claim independently: the only
commit after the post-rebase QA re-run (`27abb7ee` → `515bf154`) adds a single documentation file,
`evidence/qa-gates/post-rebase-qa.2026-09-07T17-56.md`, and `git status --porcelain
--untracked-files=all` is empty.

### 2.6 Summarize and Document

✅ PASS — `.claude/rules/parallel-orchestration.md` gains a "Mechanically-mergeable path class
(issue #643)" subsection stating all three bounding constraints and a ".NET manifest family is a
structure signal, not a module source" subsection; `.claude/skills/parallel-orchestrate/SKILL.md`
gains the (a)–(d) parent-side merge steps; `docs/features/templates/parallel/parallel-status.md`
gains the `## Mergeable Conflicts Resolved` projection section. All published mirrors updated.

---

## 3. Language-Specific Code Change Policy Compliance

---

### Section 3A: Python Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Black formatting | ✅ PASS | `poetry run black --check .` → `477 files would be left unchanged.`, exit 0 |
| Ruff lint, zero findings | ✅ PASS | `poetry run ruff check .` → `All checks passed!`, exit 0 |
| Pyright, zero errors | ✅ PASS | `poetry run pyright` → `0 errors, 0 warnings, 0 informations` |
| Full type annotations on public API | ✅ PASS | `config_mergeable_paths(config: Mapping[str, object]) -> tuple[str, ...]`, `matches_mergeable_path(entry: str, mergeable: Sequence[str]) -> bool`, `exclude_mergeable_paths(entries: Sequence[str], mergeable: Sequence[str]) -> tuple[str, ...]` |
| `from __future__ import annotations` + `TYPE_CHECKING` imports | ✅ PASS | `_blast_radius_mergeable.py` lines 33–41 |
| Explicit `__all__` | ✅ PASS | `_blast_radius_mergeable.py` declares four names |
| Google-style docstrings with Args/Returns/Raises/Side Effects | ✅ PASS | Every public function; module docstring carries Purpose / Responsibilities / Invariants / Side Effects |
| No suppressions | ✅ PASS | No `# type: ignore`, `# pyright: ignore`, or `# noqa` in any added Python line |
| Fail fast, no broad catch | ✅ PASS | The reader delegates validation to `config_string_list`, which raises `TypeError` / `ValueError`; no `except` clause is added anywhere in the Python diff |
| Purity / no I/O in domain logic | ✅ PASS | Module docstring states "no I/O, no subprocess, no wall-clock read"; verified by inspection |
| No new dependency | ✅ PASS | No change to `pyproject.toml` |

---

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| `Invoke-Formatter` clean | ✅ PASS | `run_poshqc_format` reported no rewrite and `git status --porcelain` empty afterwards (`evidence/qa-gates/final-powershell-poshqc-format.2026-09-07T19-20.md`); reviewer confirms the working tree is clean at head |
| PSScriptAnalyzer, zero findings | ✅ PASS | `evidence/qa-gates/final-powershell-poshqc-analyze.2026-09-07T19-22.md` → exit 0. The ten findings from an earlier iteration (`PSProvideCommentHelp` ×2, `PSUseOutputTypeCorrectly`, `PSReviewUnusedParameter` ×4, plus mirrors) were fixed rather than suppressed — no `SuppressMessageAttribute` appears in the diff |
| `Set-StrictMode -Version Latest` at module scope | ✅ PASS | All three new library files and the entry script |
| `$ErrorActionPreference = 'Stop'` at module scope | ✅ PASS | All four files |
| Sibling imports use `-ErrorAction Stop` | ✅ PASS | Every `Import-Module` in `BlastRadiusConflict.psm1`, `ProjectFileMerge.psm1`, and `Resolve-MergeableConflict.ps1` |
| Advanced functions with `[CmdletBinding()]` and `[OutputType]` | ✅ PASS | Every function in the four new files |
| Approved verbs | ✅ PASS | `Get-`, `Test-`, `Merge-`, `ConvertTo-`, `Read-`, `Write-`, `Invoke-`, `Compare-` |
| `SupportsShouldProcess` on the destructive function | ✅ PASS | `Write-MergedFile` declares `SupportsShouldProcess = $true` and guards the write with `$PSCmdlet.ShouldProcess`; the byte array is assembled before the guard so `-WhatIf` exercises the whole assembly |
| Explicit `Export-ModuleMember` | ✅ PASS | `BlastRadiusConflict.psm1` exports exactly five functions; the `BlastRadius.psm1` facade's exported set is unchanged at six, so no public surface was broken by the relocation |
| Ordinal, culture-invariant comparison | ✅ PASS | `[System.StringComparison]::Ordinal`, `[StringComparer]::Ordinal`, `ToLowerInvariant()` |
| Coverage allow-list updated for new files | ✅ PASS | All four new PowerShell paths appended to `CodeCoverage.Path` in `pester.runsettings.psd1`, with a comment stating that the list is an explicit per-file allow-list so an omitted file would be unmeasured; mirror refreshed to byte parity |

---

### Section 3C: Bash Script Policy Compliance

N/A — `git diff --name-only ef83a2e0..515bf154 -- '*.sh'` returns zero paths. `.claude/lib/bash/compute-cohorts.sh`
is exercised by the new cohort fixture but is itself unmodified.

---

### Section 3D: TypeScript Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Prettier clean | ✅ PASS | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` → `All matched files use Prettier code style!` |
| ESLint, zero findings | ✅ PASS | `npm run lint` → no diagnostic line, exit 0 |
| `tsc --noEmit`, zero errors | ✅ PASS | `npm run typecheck` → exit 0 |
| No untyped escape hatch | ✅ PASS | No `any`, `as any`, `@ts-ignore`, or `@ts-expect-error` in the added lines |
| `readonly` / `ReadonlyArray` on exported data | ✅ PASS | `MODULE_MANIFEST_SUFFIXES`, `NON_MODULE_MANIFEST_SUFFIXES`, `MANIFEST_SUFFIXES` are `ReadonlyArray<string>`; `DirectoryObservation` and `ProjectDirectoryClassification` members are `readonly` |
| TSDoc on exports | ✅ PASS | Every exported constant, interface, and function |
| Backward-compatible re-export of moved symbols | ✅ PASS | `claude-blast-radius-derive-core.ts` re-exports all eight moved names plus both moved types, so existing import paths continue to resolve |
| Per-file coverage threshold added for the new file | ✅ PASS | `jest.config.cjs` adds a `./src/lib/push-down/claude-blast-radius-derive-manifests.ts` entry at 85 lines / 75 branches, with a comment stating that the map carries no `global` key so an unlisted new file would be ungated |

---

### Section 3E: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| `mergeable_paths` byte-equal across the two truth-table copies | ✅ PASS | Reviewer diffed the key block in both files: identical. `mergeable_paths` is registered in `BYTE_EQUAL_KEYS` (`blast_radius_parity_test_support.py:112`) and in `$script:ClassOneKeys` (`BlastRadius.KeyPartition.Tests.ps1:33`), so the parity suites now gate it in both languages |
| Default list matches the specified five entries | ✅ PASS | `**/*.csproj`, `**/packages.config`, `**/app.config`, `**/*.vbproj`, `**/*.props` |
| New runtime files enumerated in `pack-manifests/core.json` | ✅ PASS | All four new PowerShell paths added |
| `.gitattributes` exemption justified in-file | ✅ PASS | The added `tests/fixtures/project_file_merge/crlf-*.csproj -text` rule carries a comment explaining that `* text=auto eol=lf` would otherwise rewrite the fixture's CRLF terminators on commit, making the CRLF-preservation test pass locally and fail on every fresh checkout including CI |

---

## 4. Language-Specific Unit Test Policy Compliance

---

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| Tests under `tests/` mirroring source | ✅ PASS | `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` etc. |
| `test_*.py` naming, `def test_*` functions | ✅ PASS | 17 cases in the new module |
| Typed test signatures | ✅ PASS | `-> None` on every added test; Pyright clean |
| Docstrings describing the scenario | ✅ PASS | Module docstring states that inputs come from a literal or committed truth table and that no temporary file is created and no external process is started |
| No `tmp_path` / `tempfile` | ✅ PASS | Grep returned no usage |
| Parametrization used where it removes duplication | ✅ PASS | Root-level-matcher and glob-entry cases are parametrized |
| Fixture corpus discovery is non-vacuous | ✅ PASS | `test_blast_radius_parity.py` asserts `MINIMUM_FIXTURE_COUNT = 30` and that the glob reaches every JSON file on disk, so the two new `tests/fixtures/blast_radius/` fixtures are automatically consumed by both parity suites without editing them |

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| `*.Tests.ps1` under `tests/scripts/` mirroring source | ✅ PASS | `tests/scripts/claude-lib/project-file-merge/` mirrors `.claude/lib/project-file-merge/` |
| Pester v5 `Describe`/`Context`/`It` | ✅ PASS | Verified by inspection and by a passing run |
| Committed fixtures, not generated files | ✅ PASS | 44 fixtures under `tests/fixtures/project_file_merge/`, including a committed invalid-UTF-8 file that covers the `DecoderFallbackException` branch |
| Single executable seam mocked | ✅ PASS | `Mock Invoke-GitExe` supplies the `:1:`/`:2:`/`:3:` stage texts for the never-drop assertions |
| `-WhatIf` used instead of a real write | ✅ PASS | `Write-MergedFile ... -WhatIf` then `Test-Path ... | Should -BeFalse` |
| Module convention suite passes | ✅ PASS | `ClaudeLibModuleConvention.Tests.ps1` — 6/6 pass (auto-discovery, strict mode, error-action guard, 500-line cap) |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| `*.test.ts` under `test/` mirroring `src/` | ✅ PASS | `test/lib/push-down/blast-radius-derive-manifests.test.ts` mirrors `src/lib/push-down/claude-blast-radius-derive-manifests.ts` |
| No real filesystem or network in unit scope | ✅ PASS | Observations are injected as an array; the module docstring states no temporary file is created and no real directory is read |
| No banned timing API | ✅ PASS | No `setTimeout`, `Date.now()`, or real wall-clock wait in the added tests |
| Re-export equivalence asserted | ✅ PASS | `isManifestFileName as coreIsManifestFileName` is imported alongside the direct export so the compatibility re-export is itself gated |

---

## 5. Test Coverage Detail

### `_blast_radius_mergeable.py` — reader, matcher, filter (17 tests)

Reader: present-key sorted return; absent key → empty tuple; non-list value rejected; blank entry
rejected. Matcher: `**/`-prefixed pattern matches a root-level file; a glob entry is never mergeable
unless it equals a configured pattern verbatim. Filter: non-matching entries survive, sorted and
deduplicated. Committed-config assertions: the list is non-empty in both copies and carries the five
default entries. Facade: `compute_blast_radius` re-exports the reader. Relation: no edge for a
`.csproj`-only overlap; the `.csproj` remains in both radii's `paths`; a declared glob still
contends; absent key and empty list produce identical results. Isolation: `validate_blast_radius`
findings identical with and without the key; `derive_blast_radius` keeps a cited `.csproj`;
`detect_escaped_paths` unaffected.

### `ProjectFileMerge.psm1` / `ProjectFileMergeGrammar.psm1` / `Resolve-MergeableConflict.ps1`

Five MSBuild item types × two syntactic forms = 10 keyed-union fixtures; `packages.config` disjoint
union and higher-version selection; `app.config` `dependentAssembly` union and `oldVersion` upper-bound
retarget; unparseable version escalation; same-key-different-attributes escalation; non-grammar line
escalation; `diff3` hunk style; BOM preservation; CRLF preservation; never-drop post-condition with
injected stage texts; invalid-UTF-8 escalation; non-mergeable path in the conflict set escalates
before any file is read; single compressed JSON object on stdout with `result`, `resolved`,
`escalate_paths`; neither stages nor commits.

### `claude-blast-radius-derive-manifests.ts`

Suffix-family split assertion; per-suffix classification (manifest yes, module manifest no);
nine-project .NET layout → zero module paths and `structureObserved = true`; nine-project layout →
`{ "config": ["config/**"] }`; nested `.sln`/`.slnx` yields no module; mixed layout keeps a non-.NET
manifest directory's module alongside `config`.

---

## 6. Test Execution Metrics

| Suite | Command | Result | Exit |
|---|---|---|---|
| Python (targeted, reviewer) | `poetry run pytest -q -p no:cacheprovider <8 modules>` | 166 passed in 0.38 s | 0 |
| Python (full, executor) | `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing -q` | 4,273 passed, 1 failed (C4-exempt), 5 skipped | 1 |
| TypeScript (targeted, reviewer) | `npx jest --silent <6 suites>` | 6 suites, 192 tests passed in 0.85 s | 0 |
| TypeScript (full, executor) | `npm run test:coverage -- --coverageReporters=text` | 216 suites, 2,990 tests passed | 0 |
| PowerShell (targeted, reviewer) | `Invoke-Pester -Path tests/scripts/claude-lib/project-file-merge,tests/scripts/claude-lib/blast-radius` | 488 passed, 0 failed, in 26.22 s | 0 |
| PowerShell (convention, reviewer) | `Invoke-Pester -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | 6 passed, 0 failed | 0 |
| PowerShell (full, executor) | `Invoke-PoshQCTest -Root (Get-Location).Path` | 4,008 passed, 0 failed, 9 skipped | 0 |

The single Python failure is
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
asserting on `.claude/state/current-session-id`. It is the pre-existing local-only failure tracked as
issue #510, is recorded identically in the `[P0-T7]` pre-change baseline
(`evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`), and is not caused by this branch.
It is not counted as a toolchain failure for this audit.

---

## 7. Code Quality Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets, tokens, or credentials introduced | ✅ PASS | Diff inspection over all added lines |
| No unsafe command construction | ✅ PASS | `& git @GitArgs` splats an array; no string-built command line, no `Invoke-Expression`, no shell interpolation. Python adds no subprocess call |
| Input validation at boundaries | ✅ PASS | `require_mapping` / `config_string_list` on the truth table; `Get-ProjectFileKind` returns `$null` for any unrecognized leaf, which the caller turns into an escalation; strict UTF-8 decode with an explicit fallback exception path |
| Error handling remains explicit | ✅ PASS | `Invoke-GitExe` throws with the joined output on non-zero `$LASTEXITCODE`; the only `catch` in the diff is a narrowly typed `[System.Text.DecoderFallbackException]` that returns `$null` for a documented escalation, not a swallow |
| Path handling is safe | ✅ PASS | `Join-Path`, `-LiteralPath`, and `[System.IO.Path]::GetFileName` throughout; conflicted paths originate from the git index rather than from user input |
| No suppression tokens | ✅ PASS | Grep over added lines for `type: ignore`, `pyright: ignore`, `noqa`, `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `: any`, `as any`, `SuppressMessage` returned zero matches |
| No production path excluded from coverage | ✅ PASS | The two coverage-configuration edits both ADD gating: four PowerShell files appended to the Pester `CodeCoverage.Path` allow-list and one TypeScript per-file `coverageThreshold` entry. No `exclude`, `coveragePathIgnorePatterns`, or `omit` entry is added anywhere in the diff |
| Public API compatibility | ✅ PASS | The PowerShell facade's exported set is unchanged; the TypeScript core re-exports every moved symbol; the Python facade gains a re-export and removes none |
| Fail-closed rollout | ✅ PASS | An absent `mergeable_paths` key reproduces pre-change behavior exactly; asserted in both Python and Pester |

---

## Evidence Location Compliance

`scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0, zero `VIOLATION:` lines.

A direct scan of the branch diff for paths under `artifacts/baselines/`, `artifacts/baseline/`,
`artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`,
`artifacts/regression-testing/`, or `artifacts/post-change/` returned zero matches. All 44 evidence
artifacts are under `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/`
in the canonical sub-kinds `baseline/`, `qa-gates/`, `other/`, and `issue-updates/`.

The executor recorded one override rejection of its own, which the reviewer confirms was handled
correctly: `evidence/issue-updates/ac-status-summary.2026-09-07T19-46.md` carries
`EVIDENCE_LOCATION_OVERRIDE_REJECTED: .../evidence/qa/ replaced with .../evidence/qa-gates/`,
because spec criterion S39 names the non-canonical `evidence/qa/`. The criterion text was not
edited and the artifacts were written to `evidence/qa-gates/`. No finding.

**Verdict: PASS.**

---

## Rejected Scope Narrowing

None. The caller prompt supplied the base branch, merge base, head SHA, feature folder, work mode,
and refreshed PR-context artifacts, and explicitly stated "Scope determination is yours per the
skill's scope invariant." No instruction attempted to narrow the audit to a plan, task, phase, or
file subset, and no instruction marked any language's coverage as out of scope, informational only,
or not applicable. The audit was performed against the full branch diff `ef83a2e0..515bf154`.

---

## Policy Rule: modified-workflow-needs-green-run

**Not triggered.** The branch diff contains no path matching `.github/workflows/**`,
`scripts/benchmarks/**`, or `.github/actions/**`. Verified against the 166-path name-status listing
in `artifacts/pr_context.appendix.txt` and by direct `git diff --name-only`. No green-run evidence is
required and no Blocking finding is emitted by this rule.

---

## 8. Gaps and Exceptions

### Identified Gaps

**G-1 (Info) — `isManifestFileName` and `MANIFEST_SUFFIXES` have no remaining `src/` consumer.**
Before this change, `claude-blast-radius-derive-core.ts` used `isManifestFileName` to classify
project directories. Classification now uses `isModuleManifestFileName` /
`isNonModuleManifestFileName`, so a grep across `extensions/drm-copilot/src/` finds
`isManifestFileName` only in the compatibility re-export list. Both symbols are still exported and
are exercised by tests. This is a deliberate backward-compatibility surface, documented in the module
docstring ("`MANIFEST_SUFFIXES` is the concatenation of the two families, so `isManifestFileName`
keeps its previous behaviour"). No action required; noted so a future cleanup has the context.

**G-2 (Minor) — `Invoke-GitExe` merges stderr into its returned line array.**
`.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1`, function `Invoke-GitExe`:
`$output = & git @GitArgs 2>&1`. On a zero exit code, any git advisory or warning written to stderr
becomes indistinguishable from stdout content in the returned `[string[]]`. For
`git diff --name-only --diff-filter=U` a stray warning line would be treated as a conflicted path and
classified as non-mergeable, and for `git show :N:<path>` it would perturb the never-drop key sets.
Both outcomes fail toward escalation rather than toward a wrong merge, so the impact is bounded and
this is not blocking. Recommended follow-up: capture stderr separately and include it only in the
throw message.

**G-3 (Nit) — evidence filename timestamps do not share one clock.**
Commit author dates on this branch run 08:36–13:57 local (`-0400`), i.e. 12:36–17:57 UTC.
`evidence/qa-gates/post-rebase-qa.2026-09-07T17-56.md` states `Timestamp: 2026-09-07T17:56Z` and is
therefore UTC. The remaining evidence artifacts carry stamps from `15-07` to `19-46`, which match
neither the local nor the UTC clock for the commits that produced them. The consequence is that
`post-rebase-qa.2026-09-07T17-56.md` sorts lexically *before* the pre-rebase QA-gate artifacts it
supersedes. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` fixes the format
`yyyy-MM-ddTHH-mm` but does not fix a timezone, so this is not a policy violation. This audit's own
artifacts use UTC and say so in their headers.

**G-4 (Nit) — two evidence artifacts were computed against the pre-rebase merge base and before the
final source change.** `evidence/qa-gates/file-size-compliance.2026-09-07T18-22.md` and
`evidence/qa-gates/scope-verification.2026-09-07T19-38.md` both record
`Command: git diff c3ffb080 ...`, the pre-rebase merge base, and the file-size artifact predates the
PowerShell iteration-3 fix; it lists `Resolve-MergeableConflict.ps1` at 226 lines where the final
tree has 229. The reviewer re-ran both checks independently against the audited range
`ef83a2e0..515bf154` and reproduced both conclusions: zero files over 500 lines, and zero changed
paths under a forbidden evidence prefix. The stale inputs did not change either conclusion.

### Approved Exceptions

**E-1 — C4 exemption for the single Python test failure.** The plan's constraint C4 exempts
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` when the failing node set is
exactly the set recorded by the pre-change baseline, the run reports exactly that many failures, and
the assertion message names a path under `.claude/state/`. All three conditions are documented as
holding in `evidence/qa-gates/final-qa-loop-outcome.2026-09-07T19-32.md`, and the reviewer confirms
the baseline artifact records the identical node. The failure is a gitignored local-state artifact
(issue #510) and is green in CI.

**E-2 — one path outside the plan's `[P8-T15]` allow list.**
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` was changed to
restore byte parity with the repo-root file the plan does authorise, after
`test_poshqc_bundled_parity.py` failed on the first final-QA run. The deviation is recorded in
`evidence/qa-gates/scope-verification.2026-09-07T19-38.md` with the exact `Copy-Item` command used.
The reviewer verified the two files are byte-identical (`sha256` match) and that the mirror contains
no content beyond a copy of the allow-listed file. Accepted.

### Removed/Skipped Tests

None. No test was deleted, skipped, or marked `-Skip` / `xit` / `@pytest.mark.skip` in this branch.
The 9 skipped Pester tests and 5 skipped Python tests are pre-existing and unchanged.

---

## 9. Summary of Changes

### Commits in This Branch

| SHA | Subject |
|---|---|
| `58a53790` | docs: promote mergeable-project-file-overlaps to issue 643 with research, spec, and user story |
| `12385696` | docs: add atomic plan for mergeable project-file overlaps (#643) |
| `4e02a53e` | docs: revise plan for #643 after preflight round 1 |
| `e2ae7b56` | docs: revise plan for #643 after preflight round 2 |
| `f4f752b1` | docs: revise plan for #643 after preflight round 3 |
| `438cb32a` | docs: record preflight round 4 all-clear for #643 |
| `04ae6c22` | feat(blast-radius): add mergeable_paths key and Python contention filter (#643) |
| `14c5bb48` | feat(blast-radius): port mergeable_paths to PowerShell and stop deriving .NET project modules (#643) |
| `1a2a3f43` | feat(parallel): add deterministic project-file merge for mergeable conflicts (#643) |
| `27abb7ee` | docs(parallel): document mergeable_paths doctrine and finish QA for #643 |
| `515bf154` | docs(mergeable-project-file-overlaps): record post-rebase QA re-run for #643 |

Conventional-commit prefixes are used throughout and each subject names the issue.

### Files Modified

166 files: 75 Markdown (44 of them evidence artifacts), 46 test fixtures under
`tests/fixtures/project_file_merge/` and `tests/fixtures/blast_radius/` and
`tests/fixtures/parallel_cohorts/`, 12 PowerShell production and mirror files, 8 PowerShell test
files, 3 Python production and 5 Python test files, 2 TypeScript production and 7 TypeScript test
files, 6 JSON, 2 PSD1, 1 CJS, 1 `.gitattributes`.

Published-mirror parity verified by SHA-256 for all 11 `.claude/` files that have a
`extensions/drm-copilot/resources/claude-customizations/` counterpart, and for the PoshQC
runsettings pair. All 12 pairs match.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

### Policy-by-Policy Summary

| Policy | Status | Notes |
|---|---|---|
| `.claude/rules/tonality.md` | ✅ PASS | Comments and documentation are factual and measured; no humor, hyperbole, or decorative metaphor in the added prose |
| `.claude/rules/general-code-change.md` — design principles | ✅ PASS | One filter, one application point per runtime; pure logic separated from the single I/O entry script |
| `.claude/rules/general-code-change.md` — 500-line ceiling | ✅ PASS | Independently re-verified; zero files over 500 |
| `.claude/rules/general-code-change.md` — seven-stage loop | ✅ PASS | All applicable stages pass in a single final pass per language; restarts documented |
| `.claude/rules/general-code-change.md` — error handling | ✅ PASS | Fail-fast throughout; the one `catch` is narrowly typed and feeds a documented escalation |
| `.claude/rules/general-code-change.md` — dependencies | ✅ PASS | No dependency added in any of the three runtimes |
| `.claude/rules/general-unit-test.md` — five core principles | ✅ PASS | §1.1 |
| `.claude/rules/general-unit-test.md` — coverage thresholds | ✅ PASS | §1.2.1, reviewer-parsed |
| `.claude/rules/general-unit-test.md` — Coverage Exclusion Policy | ✅ PASS | Both coverage-config edits add gating; no production path excluded |
| `.claude/rules/general-unit-test.md` — no temporary files | ✅ PASS | Grep clean; `-WhatIf` used for the one write-path case |
| `.claude/rules/general-unit-test.md` — test file location | ✅ PASS | `tests/` tree mirrors the production tree; no colocation |
| `.claude/rules/general-unit-test.md` — scenario completeness | ✅ PASS | §1.2 |
| `.claude/rules/quality-tiers.md` — uniform thresholds | ✅ PASS | 85/75 applied uniformly; PowerShell branch exemption applied as a capability limit, not a file exclusion |
| `.claude/rules/python.md` + `python-suppressions.md` | ✅ PASS | §3A; zero suppressions |
| `.claude/rules/typescript.md` + `typescript-suppressions.md` | ✅ PASS | §3D; zero suppressions, zero `any` |
| `.claude/rules/powershell.md` | ✅ PASS | §3B |
| `.claude/rules/csharp.md` | N/A | Zero C# source files in the repository |
| `.claude/skills/evidence-and-timestamp-conventions` | ✅ PASS | Canonical locations only; validator exits 0. Two nits recorded (G-3, G-4) |
| `feature-review-workflow` — `modified-workflow-needs-green-run` | ✅ PASS (not triggered) | No workflow, action, or benchmark path in the diff |

### Metrics Summary

| Metric | Value | Threshold | Verdict |
|---|---|---|---|
| Python repo-wide line coverage | 92.90% | >= 85% | ✅ |
| Python repo-wide branch coverage | 85.52% | >= 75% | ✅ |
| TypeScript repo-wide line coverage | 96.88% | >= 85% | ✅ |
| TypeScript repo-wide branch coverage | 90.45% | >= 75% | ✅ |
| PowerShell repo-wide line coverage | 94.85% | >= 85% | ✅ |
| Lowest new-file line coverage | 86.15% (`Resolve-MergeableConflict.ps1`) | >= 85% | ✅ |
| Lowest new-file branch coverage | 92.86% (`_blast_radius_mergeable.py`) | >= 75% | ✅ |
| Format failures | 0 | 0 | ✅ |
| Lint findings | 0 | 0 | ✅ |
| Type errors | 0 | 0 | ✅ |
| Suppression tokens added | 0 | 0 | ✅ |
| Files over 500 lines | 0 | 0 | ✅ |
| Evidence-location violations | 0 | 0 | ✅ |
| Blocking findings | 0 | 0 | ✅ |

### Recommendation

Proceed to PR. No remediation plan is required: there are zero Blocking findings, zero FAIL sections,
and zero PARTIAL sections. The four items in §8 are advisory (one Minor, one Info, two Nits) and are
appropriate as follow-up rather than as pre-merge work. G-2 is the only one with any behavioral
component, and its failure mode is bounded toward escalation rather than toward an incorrect merge.

---

## Appendix A: Test Inventory

| Suite | Location | Cases (added/changed) |
|---|---|---|
| Mergeable-path reader, matcher, filter, and relation isolation | `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` | 17 (new module) |
| Cohort behavior for `.csproj`-only overlaps | `tests/scripts/dev_tools/test_parallel_mergeable_cohort.py` | 3 (new module) |
| Checkpoint tolerance for `mergeable_conflicts_resolved` | `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py` | 2 (new module) |
| Drift recomputation inherits the exclusion | `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py` | 1 added |
| Class-1 key-partition registry | `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | `BYTE_EQUAL_KEYS` extended |
| PowerShell mergeable reader / matcher / filter | `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1` | new suite, 212 lines |
| No-edge and glob-still-contends relation cases | `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | extended |
| Class-1 key-partition mirror | `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` | `$script:ClassOneKeys` extended |
| Truth-table shape case for `mergeable_paths` | `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | extended |
| Line grammar | `tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1` | new suite, 194 lines |
| Keyed-union merge and never-drop | `tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1` | new suite, 263 lines |
| Entry script contract | `tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1` | new suite, 232 lines |
| Push-down manifest presence | `tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1` | new suite, 81 lines |
| Manifest family split and .NET module suppression | `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts` | new suite, 183 lines |
| `mergeable_paths` carriage at push-down | `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts` | new suite, 149 lines |
| Key-order and guard cases | `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts`, `blast-radius-derive.test.ts`, `claude-config-carriage.test.ts`, `config-carriage.test-helpers.ts` | extended |
| Checkpoint tolerance (TypeScript) | `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts` | 2 added |
| Fixtures | `tests/fixtures/project_file_merge/` (44), `tests/fixtures/blast_radius/` (2), `tests/fixtures/parallel_cohorts/` (1) | 47 new |

---

## Appendix B: Toolchain Commands Reference

Commands the reviewer executed. All are check-only; none mutated source or regenerated coverage.

```bash
# Base and scope
git -C <root> log --oneline --no-decorate ef83a2e0..515bf154
git -C <root> diff --stat ef83a2e0..515bf154
git -C <root> diff --name-status ef83a2e0..515bf154
git -C <root> status --porcelain --untracked-files=all
git -C <root> diff --name-only ef83a2e0..515bf154 | grep -E "^artifacts/(baselines|baseline|qa|qa-gates|evidence|coverage|regression-testing|post-change)/"
git -C <root> ls-files "*.cs"
git -C <root> diff --name-only ef83a2e0..515bf154 -- '*.sh'

# Python
poetry run black --check .          # exit 0 — 477 files would be left unchanged.
poetry run ruff check .             # exit 0 — All checks passed!
poetry run pyright                  # exit 0 — 0 errors, 0 warnings, 0 informations
poetry run pytest -q -p no:cacheprovider \
  tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py \
  tests/scripts/dev_tools/test_parallel_mergeable_cohort.py \
  tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py \
  tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py \
  tests/scripts/dev_tools/test_blast_radius_parity.py \
  tests/scripts/dev_tools/test_blast_radius_config_parity.py \
  tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py \
  tests/scripts/dev_tools/test_poshqc_bundled_parity.py   # exit 0 — 166 passed

# TypeScript (cwd extensions/drm-copilot)
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"   # exit 0
npm run lint                                                        # exit 0
npm run typecheck                                                   # exit 0
npx jest --silent test/lib/push-down/blast-radius-derive-manifests.test.ts \
  test/lib/push-down/blast-radius-derive-mergeable.test.ts \
  test/lib/push-down/blast-radius-derive-core.test.ts \
  test/lib/push-down/blast-radius-derive.test.ts \
  test/lib/push-down/claude-config-carriage.test.ts \
  test/lib/validate/parallel-orchestrator-state-core.test.ts        # exit 0 — 192 passed

# PowerShell
pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/project-file-merge,tests/scripts/claude-lib/blast-radius -Output Minimal"   # exit 0 — 488 passed
pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 -Output Minimal"                        # exit 0 — 6 passed

# Evidence location
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .   # exit 0, no output

# Acceptance-criteria counting
pwsh -NoProfile -Command "Import-Module ./.claude/lib/requirements/GeneratedDocumentCounters.psm1 -Force; Get-NamedSectionCheckboxCount -Document (Get-Content -LiteralPath <doc> -Raw) -Heading 'Acceptance Criteria'"

# Coverage verification (parse only; generation NOT re-run)
#   extensions/drm-copilot/coverage/lcov.info   -> TypeScript
#   artifacts/python/lcov.info                  -> Python
#   artifacts/pester/powershell-coverage.xml    -> PowerShell (JaCoCo LINE counters)

# Mirror parity
sha256sum <self-hosted path> extensions/drm-copilot/resources/claude-customizations/<same path>
```

Coverage generation commands (executor-run, not re-run by the reviewer):

```bash
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
npm run test:coverage -- --coverageReporters=text
mcp__drm-copilot__run_poshqc_test    # and Invoke-PoshQCTest -Root (Get-Location).Path
```

---

## Reviewer Assumptions and Limitations

Recorded per the "proceed with best-effort assumptions and document them" constraint.

1. **MCP template resolution was unavailable.** `.claude/skills/policy-audit-template-usage/SKILL.md`
   and the workflow skill require the templates to be resolved through
   `mcp__drm-copilot__resolve_policy_audit_template_asset`. That MCP tool is not present in this
   agent's tool set for this run. Fallback taken: the bundled asset was read directly from its
   on-disk source of truth at
   `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which
   is the same file the MCP tool serves. All canonical major headings of that template are present in
   this artifact and the template instruction block has been removed. The same fallback was used for
   `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md`.
2. **Artifact validation was not run through MCP.** `mcp__drm-copilot__validate_orchestration_artifacts`
   with `artifact_type: "policy-audit"` is likewise unavailable in this run. Compensating check: the
   required headings were verified against the template's own heading list, enumerated from the
   bundled asset.
3. **Full-suite test results are taken from executor evidence.** The reviewer re-ran the feature's
   own suites plus the parity, carriage, and convention suites, but did not re-run the three full
   suites, because doing so would regenerate the coverage artifacts this audit is required to
   inspect rather than reproduce. The full-suite figures are cited to their evidence artifacts and
   are corroborated by the reviewer's independent parse of the coverage artifacts those runs
   produced.
4. **GitHub CLI was unavailable when PR context was collected**, so the summary artifact lists
   author-asserted rather than API-verified autoclose issues. The canonical issue number for this
   feature is #643, as supplied by the caller and as carried by `issue.md`. The other identifiers in
   the author-asserted list (#500, #502, #510, #545, #596, and the two malformed tokens `#SHA-256`
   and `#UTF-8`) are incidental references picked up from prose in the feature documents and are not
   autoclose targets. Recorded so the PR author does not propagate them.
