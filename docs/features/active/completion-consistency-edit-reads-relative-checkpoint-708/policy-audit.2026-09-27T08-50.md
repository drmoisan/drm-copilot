# Policy Compliance Audit: Completion-Consistency Edit Reads Relative Checkpoint (#708)

---

**Audit Date:** 2026-09-27
**Branch:** `bug/completion-consistency-edit-reads-relative-checkpoint-708` @ `d21195cd1da4917c6ce965cc1f032606c72da12c`
**Base:** `origin/main` @ `74b2ca0a2bdf8a0bf9a032433fef20831707b574` (merge-base equals the base commit; diff command `git diff 74b2ca0a2bdf8a0bf9a032433fef20831707b574...HEAD`)
**Work Mode:** full-bug (acceptance-criteria source: `spec.md` only)
**Code Under Test:**
- `.claude/hooks/enforce-completion-consistency.ps1` (MODIFIED, canonical, +16/-8)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` (MODIFIED, byte-identical bundled copy, +16/-8)
- `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1` (NEW, test, 227 lines)
- 9 Markdown files under `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/` (issue, spec, plan, research, evidence)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 files (2 production copies, 1 new test) | 12 new tests; 1999 tests in the scoped `tests/scripts/claude-hooks` run | PASS: 1999 passed, 0 failed, 0 skipped | 91.34% lines for the canonical hook (116/127) | 92.13% lines for the canonical hook (117/127) | 100% (2 of 2 changed executable lines: 308, 374) |

Languages with zero changed files on the branch (Python, TypeScript, C#, Bash, JSON, YAML): no coverage verdict required. Markdown files are documentation and carry no coverage obligation.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript files changed on this branch)
- TypeScript post-change coverage artifact: N/A (no TypeScript files changed on this branch)
- PowerShell baseline coverage artifact: `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/baseline/baseline.md` section P0-T8 (91.34% lines for the canonical hook)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (scoped run of `tests/scripts/claude-hooks`, written after fix commit `29a8d7d0`) and `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/qa-gates/qa-gates.md` sections P4-T4 and P4-T5 (92.13% lines for the canonical hook)
- Per-language comparison summary: see Section 1.2.1; PowerShell is the only coverage language with changed files, disposition PASS

---

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller instructions to treat spec decisions D1-D11 and planner decisions P1-P6 as approved design, and to evaluate acceptance criterion 9 as PENDING-CI, concern acceptance-criteria evaluation and design disposition. They do not narrow the file set, exclude a language, or waive a toolchain or coverage check. The audit covers the full branch diff against `74b2ca0a2bdf8a0bf9a032433fef20831707b574`.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.
- `git diff --name-only 74b2ca0a2bdf8a0bf9a032433fef20831707b574...HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All branch evidence is under `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/evidence/<kind>/` (`baseline/`, `qa-gates/`, `regression-testing/`, `other/`).
- Verdict: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entries were required.

---

## Executive Summary

The branch changes the Edit branch of the Claude completion-consistency hook so that `Resolve-EditedCheckpointContent` reads the checkpoint at the Edit's `tool_input.file_path` (passed as a new mandatory `-CheckpointPath` parameter) instead of a hard-coded relative literal. The bundled copy is byte-identical (SHA-256 `F9CA16BF...F07A5` for both, reviewer `cmp` confirmed). A new 12-test Pester file drives `Invoke-CompletionConsistencyDecision` through an injected path-keyed reader.

Reviewer verification (check-only, 2026-09-27):
- The new test file plus the three existing suites (`enforce-completion-consistency.Tests.ps1`, `.Payload.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`) passed 81 of 81 against HEAD.
- The new test file run against the base-commit hook (exported with `git archive` into the session scratchpad) produced 4 passed and 8 failed, with 0 failed blocks and 0 failed containers. The failed set matches `evidence/regression-testing/edit-target-fail-before.md` exactly.
- PSScriptAnalyzer with repository settings reported 0 findings on both changed PowerShell files; `Invoke-Formatter` produced no change on either file.
- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`: 14 passed.

No new enforcement-hook bypass was found (see Section 8 and the code review). Findings: 0 Blocking, 0 Major, 1 Minor (repo-wide PowerShell coverage is established by derivation rather than by a full-run artifact on this branch).

Policies read for this audit: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`. `quality-tiers.yml` is absent at the repository root; this is pre-existing and not changed by the branch. The hook is treated as T4 (dev tooling) for tier-dependent gates; uniform gates apply regardless.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| **Independence** | PASS | Each `It` builds its own reader closure and envelope; shared `$script:` values in `BeforeAll` are immutable strings. No test mutates shared state. |
| **Isolation** | PASS | Each test targets one behavior of the Edit branch (decision source, path hand-off, or one fail-semantics row). |
| **Fast execution** | PASS | No I/O in test bodies; the full 81-test reviewer run completed within one command. |
| **Determinism** | PASS | Fixture paths are pure strings; the reader is an in-memory hashtable lookup; no clock, RNG, or working-directory dependency. |
| **Readability** | PASS | Descriptive `It` names; Arrange/Act/Assert comments in every test. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|---|---|---|
| **Baseline Coverage Documented** | PASS | 91.34% lines (116/127) for `.claude/hooks/enforce-completion-consistency.ps1`; `evidence/baseline/baseline.md` P0-T8. |
| **No Coverage Regression** | PASS | Post-change 92.13% (117/127); +0.79 percentage points. `artifacts/pester/powershell-coverage.xml` reviewer parse: LINE missed=10 covered=117. |
| **New Code Coverage** (policy: >= 85% line, uniform tier rule) | PASS | Changed executable lines 308 (`& $CheckpointReader $CheckpointPath`) and 374 (`-CheckpointPath $filePath`) both have `ci=1`. |
| **Positive flows** | PASS | Deny for a completion-asserting patch at the absolute target; allow for a non-completion patch. |
| **Negative flows** | PASS | Reader returns `$null`; empty targeted content; absent `old_string`; no `old_string` supplied. |
| **Edge cases** | PASS | Relative, absolute POSIX, and backslash spellings reach the reader unchanged; differing content at the relative literal is ignored. |
| **Error handling** | PASS | Envelope-anomaly deny is covered by the unmodified `enforce-completion-consistency.Payload.Tests.ps1` (7 tests, passing). |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 91.34% lines for the canonical hook (116/127) -> Post-change: 92.13% lines for the canonical hook (117/127). Change: +0.79 percentage points; no changed-line regression. New/changed-code coverage: 100% (2 of 2 changed executable lines). Repo-wide: derived as non-decreasing (the branch adds no executable line outside the hook and raises the hook by one covered line). Disposition: PASS. Evidence: `evidence/baseline/baseline.md` P0-T8, `evidence/qa-gates/qa-gates.md` P4-T4 and P4-T5, `artifacts/pester/powershell-coverage.xml`.

Repo-wide derivation and its limit: the report-level `LINE` counter in `artifacts/pester/powershell-coverage.xml` is `missed=5342 covered=5304` (49.82%). That artifact comes from a PoshQC test run scoped to `tests/scripts/claude-hooks`, while the coverage denominator is every file in `pester.runsettings.psd1` `CodeCoverage.Path`; files exercised only by other test folders therefore report as uncovered (for example the `.codex/hooks` copy of the same hook reports 67/136). The 49.82% figure is not a repo-wide measurement and is not used as one. The branch changes executable lines in one measured file only, and that file's covered count rises by one with an unchanged denominator, so the branch cannot lower repo-wide PowerShell line coverage. The most recent full-run figure in the review record is 96.01% (10040/10457, #713 policy audit, on an ancestor of this base). The absolute repo-wide value at this base is established by the CI `poshqc` job's full run and uploaded coverage artifact; see Minor finding PA-1. PowerShell has no branch-coverage gate (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`), so no branch figure is evaluated.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| **Arrange-Act-Assert** | PASS | All 12 tests carry explicit Arrange/Act/Assert comments. |
| **Actionable failure messages** | PASS | `Should -BeExactly` on captured paths reports expected versus actual path; the mandatory-parameter test uses `-Because`. |
| **One behavior per It** | PASS | Each `It` asserts one decision or one captured-path property. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| **No temporary files** | PASS | Reviewer grep for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `Set-Content`, `Out-File`, `New-Item` in the new test file: 0 matches. |
| **No working-directory assumptions** | PASS | No `Set-Location`/`Push-Location`; the hook path is resolved from `$PSScriptRoot`. |
| **No gitignored state or origin/main** | PASS | The reader is injected in every test; the default reader is never invoked by the new file; no `git` call. |
| **No Windows-only paths** | PASS | No drive-letter paths; the backslash spelling is a pure string that is never resolved on disk, so it behaves the same on Windows and Linux. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| **Audit artifact produced** | PASS | This file, with code review and feature audit at the same timestamp. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| **Policy reading order recorded** | PASS | `evidence/baseline/baseline.md` P0-T1 lists 11 policy files in order; no policy file modified. |
| **Baseline captured** | PASS | P0-T3 through P0-T10 (merge-base, hashes, format, analyze, test, parity, line count). |

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| **Simplicity** | PASS | One new mandatory parameter and one changed argument; no new abstraction. |
| **Separation of concerns** | PASS | File I/O remains behind the existing `CheckpointReader` seam; patch logic stays pure. |
| **Extensibility / explicit contract** | PASS | The path is an explicit mandatory input (D2), so there is no silent fallback to the literal. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| **File size <= 500 lines** | PASS | Hook 423 lines (both copies); new test 227 lines. |
| **Test location mirrors production** | PASS | `tests/scripts/claude-hooks/` is the established location for `.claude/hooks` tests; `<hook>.<Aspect>.Tests.ps1` naming follows existing precedent. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| **Descriptive names** | PASS | `CheckpointPath` matches the existing `CheckpointReader` naming. |
| **Documentation accuracy** | PASS | Script `.DESCRIPTION` and `Resolve-EditedCheckpointContent` help now describe the read of the targeted `file_path`; the stale "are allowed by this hook" text is removed. Residual comment wording nits are recorded in the code review (Minor). |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|---|---|---|
| **1. Formatting** | PASS | `qa-gates.md` P4-T1 FORMAT_UNCHANGED=True for both files; reviewer re-run matches. |
| **2. Linting** | PASS | P4-T2 PSSA_FINDINGS=0 for both files; reviewer re-run matches. |
| **3. Type checking** | PASS (not applicable to PowerShell) | P4-T3. |
| **4. Architecture-boundary tests** | PASS (no PowerShell architecture-boundary tooling configured) | No boundary rule applies to `.claude/hooks`. |
| **5. Unit tests** | PASS | P4-T4: 1999 passed, 0 failed in the scoped claude-hooks run; reviewer targeted run 81 of 81. |
| **6. Contract / schema checks** | PASS | `PreToolUseSchema.Contract.Tests.ps1` 15 of 15 unmodified and passing; bundle-parity pytest 14 passed (P4-T7 and reviewer re-run). |
| **7. Integration tests** | PASS (none defined for this hook) | The spec records live confirmation as optional and post-merge (follow-up 5). |
| **Single clean pass** | PASS | P4-T6: before and after hashes equal; 1 pass, no restarts. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| **Evidence recorded** | PASS | `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/follow-ups.md`. |
| **Follow-ups recorded** | PASS | `evidence/other/follow-ups.md` lists 5 FOLLOW-UP entries matching spec D11. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| **PowerShell 7+ compatibility** | PASS | PSSA settings enforce compatibility; 0 findings. |
| **Advanced functions / named parameters** | PASS | `Resolve-EditedCheckpointContent` keeps `[CmdletBinding()]`; the new parameter is `[Parameter(Mandatory)] [string]`. |
| **No hard-coded paths** | PASS | The fix removes the hard-coded relative literal from the reader call. The literal remains only in `Test-IsCheckpointPath` as the activation pattern, which is its intended role. |
| **Error handling** | PASS | Fail semantics unchanged per approved decision D6; no new catch block. |
| **Change budget** | PASS | 2 production files (canonical plus byte copy), 1 test file; within the direct-mode and per-batch caps. |
| **Design seam** | PASS | Existing injectable `CheckpointReader` scriptblock seam reused; no new seam introduced. |
| **Bundled copy parity** | PASS | SHA-256 equal (P2-T6, P4-T8); reviewer `cmp` reported identical. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|---|---|---|
| **Pester v5** | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`. |
| **File naming `*.Tests.ps1`** | PASS | `enforce-completion-consistency.EditTarget.Tests.ps1`. |
| **Describe/It structure** | PASS | One `Describe`, 12 `It` blocks. |
| **Mock sparingly** | PASS | No `Mock`; the production scriptblock seam is used with a fake reader. |
| **Deterministic requirements** | PASS | No network, PATH, profile, or working-directory dependency. |
| **Suppression justified** | PASS | `PSReviewUnusedParameter` suppression carries a justification (injected stubs mirror production scriptblock signatures); the same suppression appears in 9 other claude-hooks test files. |
| **Coverage >= 85% line, no changed-line regression** | PASS | 92.13% for the hook; both changed executable lines covered. |
| **No alternative test runners** | PASS | Pester only; reviewer used `Invoke-Pester` for check-only confirmation. |

---

## 5. Test Coverage Detail

### enforce-completion-consistency.EditTarget.Tests.ps1 (12 tests)

| Test | Pre-fix | Post-fix | Behavior covered |
|---|---|---|---|
| T-A denies a completion-asserting Edit when the checkpoint exists only at the absolute targeted file_path | FAIL | PASS | Core defect: decision uses the targeted file |
| T-B derives a deny from the targeted file_path content when the relative literal holds different content | FAIL | PASS | Wrong-file content ignored (deny direction) |
| T-C derives an allow from the targeted file_path content when the relative literal holds a completion-asserting checkpoint | FAIL | PASS | Wrong-file content ignored (allow direction) |
| T-D passes an absolute POSIX file_path to the reader unchanged | FAIL | PASS | Exact path hand-off |
| T-E passes a relative file_path to the reader unchanged | PASS | PASS | Relative spelling preserved |
| T-F passes a backslash-spelled file_path to the reader unchanged | FAIL | PASS | Raw, not normalized, path hand-off |
| T-G allows an Edit when the reader returns null for the targeted file_path | PASS | PASS | D6: missing file allows |
| T-H denies a completion-asserting Edit with a relative file_path read through that relative path | PASS | PASS | Relative decisions unchanged |
| T-I allows an Edit whose old_string is absent from the targeted file_path content | FAIL | PASS | D6: absent anchor allows |
| T-J allows an Edit that supplies no old_string | PASS | PASS | D6: no old_string allows |
| T-K allows an Edit when the targeted file_path content is empty | FAIL | PASS | D6: empty file allows |
| T-L declares CheckpointPath as a mandatory parameter of Resolve-EditedCheckpointContent | FAIL | PASS | Internal contract |

Pre-fix column verified by the reviewer against the base-commit hook (4 passed, 8 failed, 0 failed blocks/containers).

---

## 6. Test Execution Metrics

| Run | Scope | Result | Source |
|---|---|---|---|
| Executor fail-before | New file vs unmodified hook | 4 passed, 8 failed | `evidence/regression-testing/edit-target-fail-before.md` P1-T2 |
| Executor pass-after | New file vs fixed hook | 12 passed, 0 failed | `edit-target-pass-after.md` P3-T1 |
| Executor existing suites | Three existing suites | 69 passed, 0 failed | `edit-target-pass-after.md` P3-T2 |
| Executor PoshQC test | `tests/scripts/claude-hooks` | 1999 passed, 0 failed, 0 skipped | `qa-gates.md` P4-T4 |
| Reviewer targeted | New file plus three existing suites vs HEAD | 81 passed, 0 failed | This audit |
| Reviewer fail-before | New file vs base-commit hook | 4 passed, 8 failed | This audit |
| Reviewer bundle parity | `test_push_down_claude_resource_contracts.py` | 14 passed | This audit |

---

## 7. Code Quality Checks

| Check | Result | Status |
|---|---|---|
| Invoke-Formatter (repo settings) | No change on both files | PASS |
| PSScriptAnalyzer (Error, Warning, Information) | 0 findings on both files | PASS |
| File size | 423 / 423 / 227 lines | PASS |
| Bundle byte parity | SHA-256 equal; `cmp` identical | PASS |
| Code Coverage | 92.13% lines for the canonical hook; 2 of 2 changed executable lines covered | PASS |

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-1 (Minor).** Repo-wide PowerShell line coverage is established by derivation, not by a full-run artifact. The only local artifact is from a scoped run whose report-level counter (49.82%) is not a repo-wide figure (see Section 1.2.1). Recommendation: confirm the repo-wide PowerShell line figure from the CI `poshqc` job's uploaded `powershell-coverage.xml` on the PR head, and record it with the acceptance criterion 9 CI result. Non-blocking: the branch cannot lower repo-wide coverage.
- Acceptance criterion 9 is PENDING-CI (bundle-parity pytest in CI). Local evidence passes. Not a finding.

### Enforcement-Hook Bypass Review

No new bypass was found. The reader can be called only with a `file_path` that already matched `(^|/)artifacts/orchestration/orchestrator-state\.json$`, and it now reads the same path string the Edit tool writes. An Edit that the hook newly allows (compared with the pre-fix hook) is one whose targeted file is missing, empty, lacks `old_string`, or whose patched content does not assert completion without evidence; in the first three cases the Edit tool itself cannot apply the patch. Details are in the code review.

### Approved Exceptions

- Spec decisions D1-D11 and planner decisions P1-P6 are operator-approved (2026-09-26, autonomous mode) and are treated as approved design. This includes D6 (fail semantics unchanged: missing, empty, or unpatchable targeted file allows) and D7 (Codex copy deferred).

### Removed/Skipped Tests

- None. The three existing suites are unmodified (`qa-gates.md` P5-T3).

---

## 9. Summary of Changes

### Commits in This PR/Branch

- `757f69a2` docs(bug): create active folder for #708
- `38a97b5c` docs(bug): add research for #708
- `5853048c` docs(bug): add spec for #708
- `a3ea7ea6` docs(bug): add atomic plan for #708
- `bba0ea69`, `b340e06c`, `3a656c15`, `76a25f15` docs(bug): apply preflight rounds 1-4 revisions to #708 plan
- `23f3794e` test(708): capture Phase 0 policy reads and baseline evidence
- `bdb35983` test(708): add failing Edit-target regression tests for completion-consistency hook
- `29a8d7d0` fix(708): read the Edit's targeted file_path in completion-consistency hook
- `3d9fa4bc` test(708): record pass-after regression and existing-suite results
- `77cf585d` test(708): record final PowerShell QA loop, coverage, and bundle parity
- `fef40690` docs(708): record scope, size, portability checks and follow-ups
- `d21195cd` docs(708): check off acceptance criteria and record handoff

### Files Modified

- `.claude/hooks/enforce-completion-consistency.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`
- `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1` (new)
- Feature folder documents and evidence (9 Markdown files)

No `.codex` path is changed (`qa-gates.md` P5-T4; reviewer diff confirmed).

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT (1 Minor evidence-method gap; acceptance criterion 9 pending CI)

### Policy-by-Policy Summary

| Policy | Verdict |
|---|---|
| General unit test policy | PASS |
| General code change policy | PASS |
| PowerShell code change policy | PASS |
| PowerShell unit test policy | PASS |
| Quality tiers (uniform gates) | PASS |
| Evidence location invariant | PASS |
| Tonality | PASS |

### Metrics Summary

- PowerShell line coverage for the canonical hook: 91.34% -> 92.13%
- Changed executable lines covered: 2 of 2 (100%)
- Repo-wide PowerShell: non-decreasing by derivation; absolute value to be confirmed from CI (PA-1)
- Findings: 0 Blocking, 0 Major, 1 Minor

### Recommendation

Proceed to PR authoring. Record the CI bundle-parity result (acceptance criterion 9) and the CI `poshqc` repo-wide PowerShell line figure (PA-1) when CI completes.

---

## Appendix A: Test Inventory

### Complete Test List

New file `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1` (12 tests, listed in Section 5 as T-A through T-L).

Existing suites run unmodified as regression: `enforce-completion-consistency.Tests.ps1` (47), `enforce-completion-consistency.Payload.Tests.ps1` (7), `PreToolUseSchema.Contract.Tests.ps1` (15).

---

## Appendix B: Toolchain Commands Reference

- Format: `Invoke-Formatter -ScriptDefinition <normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (per file; compare with input)
- Analyze: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information`
- Test (executor): `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders tests/scripts/claude-hooks`
- Test (reviewer, targeted): `Invoke-Pester -Path <four suite paths> -PassThru -Output None`
- Fail-before (reviewer): `git archive 74b2ca0a2bdf8a0bf9a032433fef20831707b574 .claude/hooks .claude/lib` extracted to the session scratchpad with the new test file placed at the mirrored `tests/scripts/claude-hooks/` path, then `Invoke-Pester` on that copy
- Bundle parity: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
- Evidence locations: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
- PR context: `poetry run python -m scripts.dev_tools.pr_context.collector --base 74b2ca0a2bdf8a0bf9a032433fef20831707b574 --head HEAD --repo-root .` (Head SHA `d21195cd` in both summary and appendix)
