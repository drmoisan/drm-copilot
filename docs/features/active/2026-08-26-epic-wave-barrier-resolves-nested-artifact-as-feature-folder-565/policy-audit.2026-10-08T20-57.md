# Policy Compliance Audit: Shared feature-folder resolver for the enforcement hooks (#565, bundles #568 and #696)

---

**Audit Date:** 2026-10-08
**Branch:** `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-exec-565` @ `fee3a782f03f51a512bbb997521472ccf0005484`
**Base:** `origin/epic/enforcement-hook-precision-integration` @ `33fc0b20231e74ae88be38a5c912102901bd04cc`; merge-base `991aae0a180a09d504b59bc9460ec4b00b85d11b`
**Diff anchor:** `git -C <worktree> diff origin/epic/enforcement-hook-precision-integration...HEAD` (198 files, +8527/-807)
**Review pass:** 2 (remediation cycle 1 re-audit of the full branch, not only the remediation delta)
**Prior pass:** `policy-audit.2026-10-08T19-24.md` (head `2aa326cc`)
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, read from the repository resources folder; the template instruction block is removed.
**PR context:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`. The copies present at the start of this review were bound to `ce4ed08b` (stale); this review regenerated both with `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration ...`. Both now carry `2026-10-09 00:54:10 UTC` and `Head SHA: fee3a782...` (pair identity and head binding verified).

**Code Under Test:**

- PowerShell production (new): `.claude/hooks/feature-folder-resolution.ps1`, `.codex/hooks/feature-folder-resolution.ps1`
- PowerShell production (modified): `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, `.claude/hooks/enforce-parallel-drift-gate.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-feature-folder-order.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` (the two gate main files are new to the write set in remediation cycle 1)
- Bundled mirrors (11 hook files) under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`
- JSON: both `pack-manifests/core.json` files
- PowerShell tests (new): 8 files; (modified): `enforce-feature-folder-order.Tests.ps1`, `enforce-parallel-drift-gate.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`
- Feature documentation and evidence under `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/` (spec.md check-offs only, plan, remediation plan, prior review artifacts, 156 evidence files)

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 22 files (11 production, 11 test) plus 11 bundled mirrors | 6782 Pester cases full suite (executor, 20:44); 1386 cases in 41 targeted and existing suites re-run by this review | PASS 6770 pass, 2 fail (identical to baseline), 10 skipped; review re-run 1386 pass, 0 fail | 84.33% repo-wide command coverage (branch baseline run 2026-10-08T17-44); per-file line 91.11% to 100.00% for the nine modified files | 84.89% repo-wide line (13560/15973), 84.61% command; per-file line 91.67% to 100.00% for all eleven production files | 100.00% for each new resolver copy (111/111); 97.49% of changed executable lines across all eleven files (350/359; the 9 uncovered lines are dot-source catch bodies) |
| JSON | 2 files (pack manifests) | 32 bundle-contract pytest cases | PASS 32 pass | N/A - configuration data | N/A - configuration data | N/A - configuration data |
| Markdown | 163 files (spec check-offs, plans, review artifacts, evidence) | N/A | N/A | N/A - documentation | N/A - documentation | N/A - documentation |
| TypeScript | 0 files | N/A | N/A | N/A - no TypeScript file changed | N/A - no TypeScript file changed | N/A - no TypeScript file changed |
| Python | 0 files | N/A | N/A | N/A - no Python file changed | N/A - no Python file changed | N/A - no Python file changed |
| C# | 0 files | N/A | N/A | N/A - no C# file changed | N/A - no C# file changed | N/A - no C# file changed |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero TypeScript files changed on the branch
- TypeScript post-change coverage artifact: N/A - zero TypeScript files changed on the branch
- PowerShell baseline coverage artifact: `evidence/baseline/pester-full-selfhosted.2026-10-08T17-44.md` (84.33% command), `evidence/baseline/coverage-perfile.2026-10-08T17-54.md` (per-file line), and the remediation baseline `evidence/remediation-baseline/coverage-perfile.2026-10-08T20-19.md` (adds both gate main files: 96.73% and 100.00%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo, written 2026-10-08 20:44:39 local by the final self-hosted run, after the last code commit `7e63f252` at 20:34:12); parsed independently by this review; recorded by the executor in `evidence/qa-gates/coverage-perfile.rem1-1.2026-10-08T20-47.md` and `evidence/qa-gates/coverage-changed-lines.rem1-1.2026-10-08T20-47.md`
- Per-language comparison summary: section 1.2.1 of this audit; comparison artifacts `evidence/qa-gates/coverage-comparison.3.2026-10-08T19-13.md` and `evidence/qa-gates/coverage-comparison.rem1-1.2026-10-08T20-47.md`

---

## Executive Summary

The branch replaces longest-match feature-folder selection in five prompt resolvers with a pure shared resolver (`feature-folder-resolution.ps1`, byte-identical on the Claude and Codex surfaces and in both bundles), fixes integer `depends_on` edges in the epic wave barrier, makes `enforce-feature-folder-order.ps1` work-mode aware with timestamped plan matching (#568), and adds direct coverage of `Get-PrdFeatureCheckpointFolder` (#696). Remediation cycle 1 restricted the `-modes.ps1` tie-break to the keyed issue number on both surfaces (prior CR-1), which required a two-line change in each `enforce-orchestration-preimplementation-gate.ps1` main file, reworded the barrier import-failure deny reason (prior CR-4), and moved the superseded failing analyzer artifact out of the collected evidence folders (prior PA-3).

**Policy documents evaluated:**
- PASS `CLAUDE.md` and `.claude/rules/tonality.md`
- PASS `.claude/rules/general-code-change.md`
- PASS `.claude/rules/general-unit-test.md` (branch-attributable coverage gates; the repo-wide PowerShell aggregate is recorded in section 8 as pre-existing)
- PASS `.claude/rules/quality-tiers.md` (`quality-tiers.yml` maps `.claude/hooks` and `.codex/hooks` to T3; no property-test or mutation obligation)

**Language-specific policies evaluated:**
- PASS `.claude/rules/powershell.md` (format, analyzer, Pester, 500-line cap, no temporary files)
- N/A Python, TypeScript, C# (zero changed files)
- PASS JSON pack manifests (bundle-contract tests)

**Constraint checks (all re-verified by this review):**
- PASS No Python in enforcement hooks: no `.py` file under `.claude/hooks/` or `.codex/hooks/` in the diff; `evidence/qa-gates/no-python.rem1-1.2026-10-08T20-48.md` reports PYTHON-ADDED=0 for the remediation write set.
- PASS 500-line cap: production maximum 496 (Claude `-modes.ps1`), test maximum 497 (`legacy-codex-hook-contracts.Tests.ps1`), re-counted by this review.
- PASS Line coverage >= 85% on every changed PowerShell production file (minimum 91.67%).
- PASS Claude/Codex/bundle mirror parity: 11 of 11 SHA256 pairs equal; both resolver copies `2fe999cd...`.
- PASS No temporary files in tests.
- PASS Tests under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`.

**Blocking findings in this artifact: 0** (FAIL: 0; blocking PARTIAL: 0). Non-blocking: PA-2 (PARTIAL, estimated evidence timestamps from the first execution pass), PA-4 (awaiting CI, spec AC item 30), PA-6 (PARTIAL, spec scope text not updated for the gate main file edits; cross-referenced as CR-9 in the code review). PA-3 is resolved. The repo-wide PowerShell aggregate (prior PA-1) is recorded under "Pre-existing and out-of-scope items" in section 8 with the reasoning required by the caller.

**Temporary artifacts cleanup:**
- PASS No scratch or one-time script is committed on the branch; executor scratch scripts are cited as `<scratchpad>/...` and are not in the diff.
- PASS No new tooling script was added outside the tested hook files listed above.

---

## Rejected Scope Narrowing

No scope narrowing was applied. Caller directives evaluated:

- "Re-review the full branch (not only the delta)" - consistent with the scope invariant; the audit covers the full diff from merge-base `991aae0a`.
- "For PA-1 ... evaluate it against the policy as it applies to this change - changed-file coverage and no regression on changed lines - and record the repo-wide pre-existing shortfall in a pre-existing/out-of-scope section with its baseline and post-change numbers, unless you judge that this branch itself violates a rule" - evaluated as a classification directive, not a narrowing: it does not remove PowerShell from scope, skip a coverage check, or request a non-PASS/FAIL language verdict. This audit still parses and reports the repo-wide figure, issues an explicit PowerShell verdict, and states its own reasoning in section 8.
- "spec.md AC item 30 remains pending PR CI; record it as awaiting CI" - a classification directive; the local results for the same suites were checked (`evidence/qa-gates/pytest-bundle-contracts.rem1-1.2026-10-08T20-38.md`, 32 pass; `codex-epic-runtime-contracts.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` passed in this review's re-run).

---

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path.
- `git diff --name-only origin/epic/enforcement-hook-precision-integration...HEAD` lists no path under `artifacts/`. No file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` is part of the branch diff.
- All committed evidence files live under `<FEATURE>/evidence/{baseline,regression-testing,qa-gates,other,remediation-baseline}/`; the superseded analyzer artifact is at `evidence/remediation-baseline/superseded/analyze-selfhosted.1.2026-10-08T19-50.md` with a `Superseded:` line.

Result: PASS. No EVIDENCE_LOCATION_OVERRIDE_REJECTED entry was required.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | PASS | Each `It` builds its checkpoint from literal JSON; import-failure cases restore the flag in `finally`; the new M10-M12 and M8h/M8m cases use per-call fixtures. |
| **Isolation** - Each test targets single behavior | PASS | One prompt form per `It` (W, C, D, M, F, K, P, S-H series). |
| **Fast Execution** - Tests complete quickly | PASS | 41 suites, 1386 cases, completed in one run by this review. |
| **Determinism** - Consistent results | PASS | Literal fixtures, mocked worktree and checkpoint seams, synthetic absolute paths; no clock, RNG, or network. |
| **Readability & Maintainability** - Clear structure | PASS | Suite synopses map cases to the spec matrix; CR-1 contexts are labelled `issue #565 CR-1`. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `evidence/baseline/coverage-perfile.2026-10-08T17-54.md` (before the first code commit) and `evidence/remediation-baseline/coverage-perfile.2026-10-08T20-19.md` (before the remediation code commits). |
| **No Coverage Regression** | PASS | No previously covered line became uncovered. Missed counts in remediation: equal to the remediation baseline for all seven remediation files (`coverage-comparison.rem1-1`). Whole-file percentages for six files modified in pass 1 are 0.72 to 2.58 points below their branch baseline because each file gained a new guard catch body that runs only on a load failure; every file remains at or above 91.67%. |
| **New Code Coverage at or above threshold** | PASS | Both resolver copies 100.00% (111/111). Changed executable lines 350/359 (97.49%). |
| **Comprehensive Coverage** | PASS | Every public resolver function exercised directly; every hook leg at decision level; `-KeyedOnly` exercised by M12a-c. |
| **Positive Flows** | PASS | W1-W3, C1-C3, D1-D3, M1-M3, M11p/M11e, M8h, F7-F9, F19, K1. |
| **Negative Flows** | PASS | W5-W8b, C5, C6, D5, D6, M5, M6b, M10p/M10e, M8m, F10-F17, K2-K6. |
| **Edge Cases** | PASS | Trailing punctuation, backslash and absolute tokens, lifecycle prefixes, dependency cycles, both orders and either-longer slugs (O01). |
| **Error Handling** | PASS | Simulated dot-source failure per hook (W9, C7, D7, M9, F18, P3) with AST guard assertions; W9/C7/D7 now also assert the reworded reason. |
| **Concurrency** | N/A | Synchronous hook logic. |
| **State Transitions** | PASS | `merged` vs `pr_open`/`not_started` transitions in the wave barrier, the 621 fixture, and the CR-1 cross fixture. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 84.33% repo-wide command coverage at the branch baseline; per-file line 99.01% wave barrier, 98.68% cohort barrier, 99.12% drift gate, 98.51% Claude modes, 98.48% Codex modes, 91.11% feature-folder-order, 96.61% prd helpers, 96.73% Claude gate main, 100.00% Codex gate main -> Post-change: 84.89% repo-wide line (13560/15973), 84.61% command (18865/22297); per-file line 96.70%, 96.10%, 98.23%, 97.81%, 97.78%, 91.67%, 94.92%, 96.75%, 100.00%, and 100.00% for each resolver copy. Change: +0.28 points repo-wide command coverage; gate main files +0.02 and 0.00 points; pass-1 files -2.31 to +0.56 points from new guard catch bodies only. New/changed-code coverage: 100.00% new files; 97.49% of changed executable lines (350/359), with all 8 changed executable lines in the two gate main files covered. Disposition: PASS for new-file, modified-file, and changed-line gates. The repo-wide line figure of 84.89% is below the 85% floor; it was below the floor before this branch and this branch raises it, so it is recorded in section 8 as pre-existing and not attributable to this branch. Evidence: `evidence/baseline/pester-full-selfhosted.2026-10-08T17-44.md`, `evidence/baseline/coverage-perfile.2026-10-08T17-54.md`, `evidence/remediation-baseline/coverage-perfile.2026-10-08T20-19.md`, `evidence/qa-gates/coverage-perfile.rem1-1.2026-10-08T20-47.md`, `evidence/qa-gates/coverage-changed-lines.rem1-1.2026-10-08T20-47.md`, `evidence/qa-gates/coverage-comparison.rem1-1.2026-10-08T20-47.md`, `artifacts/pester/powershell-coverage.xml`.

Coverage verdicts per language with changed files: PowerShell PASS (new files PASS; modified files PASS; changed lines PASS; repo-wide aggregate below 85% recorded as pre-existing in section 8). TypeScript, Python, and C# have zero changed files.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | `-Because` on hash and AST guard assertions; `Should -Match` on deny tokens, predicate names, and candidate names. |
| **Arrange-Act-Assert Pattern** | PASS | Explicit AAA comments in guard and K1 cases; other cases are single-expression arrange-act-assert. |
| **Document Intent** | PASS | Each suite has a synopsis; new contexts name the finding they cover. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | `Resolve-OrchestrationGateTarget`, `Resolve-EpicWaveBarrierTarget`, and checkpoint-read seams are mocked; checkpoints are passed as raw strings. |
| **Use Mocks/Stubs** | PASS | `Get-FeatureFolderIssueContent` mocked at Describe scope; K-cases mock `Test-Path`/`Get-Content` with exact `-LiteralPath` filters. |
| **Environment Stability** | PASS | `evidence/qa-gates/test-purity.rem1-1.2026-10-08T20-48.md` (five PURITY-CLEAN); pass-1 search of the 11 test files returned no temp-file API. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This document is the pass-2 policy audit. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `spec.md` Context, Root Cause Analysis, Proposed Fix R1-R6; `remediation-inputs.2026-10-08T19-24.md`. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.2026-10-08T17-32.md`; `evidence/remediation-baseline/phase0-instructions-read.2026-10-08T20-07.md`. |
| **Document the plan** | PASS | `plan.2026-10-08T13-52.md` and `remediation-plan.2026-10-08T19-24.md`, all tasks checked. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The CR-1 fix is a switch plus one parameter per predicate; no new function. |
| **Reusability** | PASS | One resolver replaces five length-sorting implementations. |
| **Extensibility** | PASS | `-KeyedOnly` keeps the default return unchanged for existing callers. |
| **Separation of concerns** | PASS | Resolver is pure (purity search); reads stay in hook seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | Resolver holds only selection and work-mode logic. |
| **Under 500 lines** | PASS | Re-counted by this review (`wc -l`): production 373, 373, 376, 348, 454, 496, 493, 467, 489, 280, 343; tests 245, 374, 273, 176, 186, 441, 97, 274, 271, 274, 497. |
| **Public vs internal** | PASS | Public resolver API matches the spec Functions table. |
| **No circular dependencies** | PASS | The resolver dot-sources nothing. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | Approved verbs; `-KeyedOnly` and `-FallbackIssueNumber` describe their roles. |
| **Docs/docstrings** | PASS | Help text updated for `-KeyedOnly` and both predicates. |
| **Comment why, not what** | PASS | Gate main comment states why only the keyed value breaks a tie. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `evidence/qa-gates/format-check.rem1-1.2026-10-08T20-36.md` (12 FORMAT-CLEAN); `format-mcp.rem1-1` unchanged hashes. |
| **2. Linting** | PASS | `evidence/qa-gates/analyze-selfhosted.rem1-1.2026-10-08T20-38.md` (Findings=0). |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Architecture-boundary tests** | N/A | No architecture tool configured for hooks; resolver purity verified by search. |
| **5. Unit tests** | PASS | Full suite 6770 pass, 2 fail identical to baseline (`junit-failing-set.rem1-1`; confirmed by this review from `artifacts/pester/pester-junit.xml`: tests=6782, failures=2, disabled=10); this review re-ran 41 suites: 1386 pass, 0 fail. |
| **6. Contract / schema checks** | PASS | `pytest-bundle-contracts.rem1-1` 32 pass; both PowerShell contract suites pass in this review's re-run. CI confirmation pending (PA-4). |
| **7. Integration tests** | PASS | Decision-level hook invocations with the Claude nested envelope and the Codex flat tool_input. |
| **Full toolchain loop** | PASS | `evidence/qa-gates/qc-loop-rem1.2026-10-08T20-49.md`: one iteration, no file changed by any gate. |
| **Explicit reporting** | PARTIAL | Every gate artifact carries Timestamp, Command, EXIT_CODE; remediation artifacts are clock-read; pass-1 artifacts from Phase 1 to Phase 10 iteration 2 carry estimated timestamps (PA-2). PA-3 resolved: the regenerated PR context has 113 pass rows and 0 fail rows. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | One commit per phase in both cycles (`e3328c2b` to `fee3a782`). |
| **Design choices explained** | PASS | Spec R1-R6; remediation plan "R1 semantics after the fix" and write-set note. |
| **Update supporting documents** | PARTIAL | Both manifests list the resolver. Spec line 76 still lists both `enforce-orchestration-preimplementation-gate.ps1` main files as "Explicitly excluded systems" although the branch now edits them; the rationale exists only in the remediation plan (PA-6). |
| **Provide next steps** | PASS | `evidence/other/follow-ups-remediation-1.2026-10-08T20-35.md`. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Invoke-Formatter clean** | PASS | `format-check.rem1-1` and `format-mcp.rem1-1`. |
| **PSScriptAnalyzer clean** | PASS | `analyze-selfhosted.rem1-1` Findings=0. |
| **PowerShell 7+ compatible** | PASS | Analyzer compatibility rules pass. |
| **Advanced functions with CmdletBinding** | PASS | All new and edited functions keep `[CmdletBinding()]` and `[OutputType()]`. |
| **No silent catch-alls** | PASS | Each new catch records a named import-failure flag that produces a deny. |
| **No Invoke-Expression or hard-coded paths** | PASS | None introduced. |
| **Change budget routing** | PASS | Orchestrated large path in both cycles. |
| **No Python in enforcement hooks** | PASS | `no-python.rem1-1`; re-checked by this review. |
| **Mirror parity** | PASS | SHA256 equal for 8 Claude pairs and 3 Codex pairs (this review). |

### Section 3G: JSON Pack Manifests

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Registration of new shared file** | PASS | One added line in each `core.json`; bundle contract tests pass. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5** | PASS | `#Requires -Modules` Pester 5 in each new suite. |
| **Test location** | PASS | `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`; no colocated test. |
| **Naming `*.Tests.ps1`** | PASS | All new files. |
| **Mock wrappers, not executables** | PASS | Seams and built-ins only. |
| **No temporary files** | PASS | See section 1.4. |
| **Line coverage >= 85%** | PASS | Minimum 91.67% across the eleven production files. |
| **Changed-line regression is blocking** | PASS | No previously covered line lost coverage; the 9 uncovered changed lines are newly added guard catch bodies (PA-5). |

---

## 5. Test Coverage Detail

### `.claude/hooks/feature-folder-resolution.ps1` and `.codex/hooks/feature-folder-resolution.ps1`

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| S01-S09 Find-FeatureFolderCandidate | Positive, edge, negative | PASS |
| B01 ConvertTo-FeatureFolderBasename | Edge | PASS |
| R01-R08 Find-FeatureFolderRecord | Positive, negative | PASS |
| T01-T12, O01 Select-FeatureFolderTarget | Positive, negative, edge, ordering | PASS |
| M01, P01, H01 | Work mode, prerequisites, hash equality | PASS |

**Coverage:** 100.00% lines (111/111) per copy.

### Hook suites

| Suite | Cases | Status |
|-------|-------|--------|
| `enforce-epic-wave-barrier.FolderResolution.Tests.ps1` | W1-W10 (W9 asserts the reworded reason) | PASS |
| `enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1` | C1-C8 (C7 asserts the reworded reason) | PASS |
| `enforce-parallel-drift-gate.FolderResolution.Tests.ps1` | D1-D8 (D7 asserts the reworded reason) | PASS |
| Claude and Codex `...-mode-resolution.TargetFolder.Tests.ps1` | M1-M9, M10p, M10e, M11p, M11e, M12a-c, M8h, M8m each | PASS |
| `enforce-feature-folder-order.Tests.ps1` | F1-F19, E1-E3 plus pre-existing cases | PASS |
| `enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1` | K1-K6, P1-P4 | PASS |
| 18 existing preimplementation-gate suites (both surfaces) | unchanged | PASS |

**Coverage:** see section 1.2.1. **Not covered:** 9 catch-body lines (one per dot-source guard).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Full Pester suite (self-hosted, remediation final) | 6770 pass, 2 fail (pre-existing), 10 skipped | PASS |
| JUnit failing set vs baseline | identical 2 cases | PASS |
| Suites re-run by this review | 1386 pass, 0 fail (41 files) | PASS |
| Bundle-contract pytest | 32 pass | PASS |
| Largest changed file | 497 lines | PASS |
| Changed-line coverage | 97.49% | PASS |

---

## 7. Code Quality Checks

| Check | Command | Result |
|-------|---------|--------|
| Format | self-hosted `Invoke-Formatter` comparison and `run_poshqc_format` (executor) | PASS |
| Analyze | `Invoke-ScriptAnalyzer` with `pssa.settings.psd1` (executor) | PASS, 0 findings |
| Pester re-run | `Invoke-Pester` on 41 suites (this review) | PASS, 1386 |
| Pester full | `Invoke-PoshQCTest -Root .` (executor) | PASS vs baseline |
| Mirror parity | `sha256sum` on 11 pairs (this review) | PASS |
| Evidence locations | `validate_evidence_locations.py --root .` (this review) | PASS, exit 0 |
| PR-context fail rows | count of `Normalized result:` values in the regenerated summary (this review) | PASS, 113 pass, 0 fail |

**Notes:** The two failing Pester cases (`enforce-pr-author-skill.Tests.ps1` body-file case and `codex-pretooluse-integration.Tests.ps1` matcher case) appear verbatim in `evidence/baseline/junit-failing-set.2026-10-08T17-53.md`; neither suite nor its subject is in the write set.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **PA-2 (PARTIAL, non-blocking): estimated evidence timestamps from execution pass 1.** Per `evidence/other/timestamp-correction.2026-10-08T18-46.md`, artifacts from Phase 1 through Phase 10 iteration 2 carry estimated timestamps up to 75 minutes ahead of the actual time. Commands, exit codes, and outputs are unaffected; every remediation cycle 1 artifact reviewed carries a clock-read timestamp consistent with its commit time. Keep the correction record referenced in the PR description.
- **PA-3: resolved.** The superseded analyzer artifact is at `evidence/remediation-baseline/superseded/analyze-selfhosted.1.2026-10-08T19-50.md` (content-preservation check in `evidence/other/pa3-relocation.2026-10-08T20-35.md`); the regenerated PR context has 0 fail rows.
- **PA-4 (awaiting CI, non-blocking): spec AC item 30.** The seven contract suites must pass in CI on the pull request; they pass locally. Remediability class: `awaiting_ci`. An epic-child PR may need a manual `workflow_dispatch` of `ci.yml`.
- **PA-5 (Info): uncovered guard catch bodies.** Nine newly added lines are catch bodies of the resolver dot-source guards; their flags are driven directly (W9, C7, D7, M9, F18, P3) and AST assertions prove each catch assigns the flag.
- **PA-6 (PARTIAL, non-blocking): spec scope text not updated.** Spec line 76 lists both `enforce-orchestration-preimplementation-gate.ps1` main files under "Explicitly excluded systems"; remediation cycle 1 edits both (+5/-3 lines each) to pass the keyed and fallback issue numbers separately. The remediation plan's write-set note justifies the edit against spec line 173 only. The edit is small, covered (4/4 changed executable lines per file), mirrored, and the 18 existing preimplementation suites pass. Recommended: record the deviation (spec amendment or an evidence record matching the CR-3 record) before the PR is opened. See code-review CR-9.

### Pre-existing and out-of-scope items

- **Repo-wide PowerShell line coverage below 85% (prior PA-1).** Baseline: 84.33% repo-wide command coverage at the branch baseline (`evidence/baseline/pester-full-selfhosted.2026-10-08T17-44.md`; the baseline run recorded the command figure only) and 84.6% command at the remediation baseline. Post-change: 84.89% repo-wide line (13560/15973) and 84.61% command (18865/22297), parsed by this review from `artifacts/pester/powershell-coverage.xml`.
  - Reasoning: `.claude/rules/general-unit-test.md` requires line coverage >= 85% and no reduction in coverage for changed lines; `.claude/rules/quality-tiers.md` applies the 85% line floor uniformly. Applied to this change, the attributable obligations are: every new file >= 85% (both resolver copies 100.00%, which also clears the reviewer's 90% new-file trigger), every modified file >= 85% (minimum 91.67%), and no previously covered changed line uncovered (none; 350/359 changed executable lines covered, the 9 uncovered lines being newly added guard catch bodies). All three pass. The branch raised the repo-wide command figure from 84.33% to 84.61%; it excludes no file from measurement and removes no test. The shortfall is therefore caused by files outside this branch, and no rule is violated by this branch. The repo-wide figure is also above the reviewer procedure's 80% remediation trigger.
  - Classification: pre-existing, not attributable to this branch, not counted as a blocking finding. It remains a repository-level follow-up (recorded in `evidence/other/follow-ups-remediation-1.2026-10-08T20-35.md`, item 3).
- **Two full-suite Pester failures** (`enforce-pr-author-skill.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`): identical to the branch baseline; outside the write set.

### Approved Exceptions

- None required for this branch. The repo-wide aggregate is classified as pre-existing on the reasoning above, not under an exception.

### Removed/Skipped Tests

- `enforce-parallel-drift-gate.Tests.ps1` case "accepts a backslash-separated token and returns the longest match" was rewritten to expect `Ambiguous`, as spec AC item 12 requires. No test was skipped or removed in remediation cycle 1 (`evidence/qa-gates/test-scope.rem1-1.2026-10-08T20-48.md`: 146 insertions, 0 deletions under `tests/`).

---

## 9. Summary of Changes

### Commits in This Branch (since merge-base)

1. `e3328c2b` to `2aa326cc` - execution pass (11 commits; see `policy-audit.2026-10-08T19-24.md` section 9)
2. `25c9c3c1` - docs(565): add feature-review artifacts and remediation inputs (cycle 1)
3. `afb772f4`, `da2dc7d5` - remediation plan and preflight deltas
4. `c729f881` - docs(565): capture remediation cycle 1 baseline
5. `ceb51b05` - test(565): add keyed-only tie-break regression cases on both surfaces
6. `29269337` - fix(565): restrict the -modes tie-break to the keyed issue number
7. `7e63f252` - fix(565): name a failed barrier import as a dependency
8. `ce4ed08b` - docs(565): relocate the superseded analyzer artifact and record CR-3 and follow-ups
9. `81694de5`, `fee3a782` - final QC loop and plan check-off

### Files Modified

1. `feature-folder-resolution.ps1` (NEW, Claude and Codex) - R1-R6 resolver and work-mode parser.
2. Epic wave barrier, cohort barrier, drift gate (MODIFIED) - delegate to the resolver; guarded dot-source; reworded import-failure reason.
3. Both `-modes.ps1` (MODIFIED) - resolver delegation; `-KeyedOnly`; `-FallbackIssueNumber` on both readiness predicates.
4. Both `enforce-orchestration-preimplementation-gate.ps1` main files (MODIFIED, cycle 1) - pass keyed and fallback issue numbers separately.
5. `enforce-feature-folder-order.ps1`, `enforce-prd-feature-before-planner-helpers.ps1` (MODIFIED).
6. Eleven bundled hook mirrors and two pack manifests; test files as listed in the header; feature docs and evidence.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT with non-blocking items (0 blocking findings)

All branch-attributable PowerShell gates pass: format, analyzer, Pester (failing set identical to baseline), line coverage on every new and modified file, changed-line coverage, size, purity, mirror parity, and the no-Python constraint. The repo-wide PowerShell aggregate is below 85% before and after this branch and is not attributable to it. Code-level findings are reported in `code-review.2026-10-08T20-57.md`.

**Blocking count: 0** (FAIL: 0, blocking PARTIAL: 0). Non-blocking: PA-2, PA-4, PA-5, PA-6.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure (maximum 497 lines)
- PASS Naming, Docs, Comments
- PARTIAL Toolchain reporting (PA-2; non-blocking)
- PARTIAL Summarize & Document (PA-6; non-blocking)

#### Language-Specific Code Change Policy (Section 3)

**For PowerShell:**
- PASS Formatting, analyzer, compatibility, advanced functions, error handling, mirrors, no Python

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios (repo-wide aggregate pre-existing, section 8)
- PASS Test Structure
- PASS External Dependencies: no temporary files
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For PowerShell:**
- PASS Framework, location, naming, mocking, coverage

---

### Metrics Summary

- PASS 6770 Pester cases passing; 2 failures identical to baseline
- PASS 1386/1386 cases re-run by this review
- PASS New-code coverage 100.00%; modified files 91.67% minimum; changed lines 97.49%
- PRE-EXISTING Repo-wide PowerShell line 84.89% (raised by this branch; not attributable)
- PASS Mirror parity 11/11

---

### Recommendation

**Policy-compliant; merge readiness depends on PR CI for AC item 30. Record the gate-main scope deviation (PA-6) before opening the PR.**

---

## Appendix A: Test Inventory

### Complete Test List

- `tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1` and the Codex twin: S01-S09, B01, R01-R08, T01-T12, O01, M01, P01, H01
- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1`: W1-W10
- `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1`: C1-C8
- `tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1`: D1-D8
- Claude and Codex `...-mode-resolution.TargetFolder.Tests.ps1`: M1-M9, M10p, M10e, M11p, M11e, M12a, M12b, M12c, M8h, M8m
- `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1`: F1-F19, E1-E3, pre-existing cases
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1`: K1-K6, P1-P4
- `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`: rewritten ambiguity case
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`: `SharedModuleNames` extended

---

## Appendix B: Toolchain Commands Reference

**Commands run by this review (check-only):**

```bash
git -C <worktree> fetch origin epic/enforcement-hook-precision-integration
git -C <worktree> diff --name-status origin/epic/enforcement-hook-precision-integration...HEAD
git -C <worktree> diff 2aa326cc..HEAD -- .claude/hooks .codex/hooks tests
git -C <worktree> merge-base origin/epic/enforcement-hook-precision-integration HEAD
poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/enforcement-hook-precision-integration --out artifacts/pr_context.summary.txt --appendix-out artifacts/pr_context.appendix.txt
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
sha256sum <11 hook/mirror pairs>
wc -l <22 changed PowerShell files>
python -I <scratchpad>/cov565r.py <worktree> artifacts/pester/powershell-coverage.xml 991aae0a   # per-file LINE and changed-line coverage
sh <scratchpad>/run565r.sh <scratchpad>/pester565r.ps1   # Invoke-Pester on 41 suites: Passed=1386 Failed=0
sh <scratchpad>/run565r.sh <scratchpad>/probe565r.ps1    # tie-break probe on both surfaces (code-review CR-1, CR-8, CR-10)
```

**Executor commands (from evidence):**

```bash
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path
Invoke-ScriptAnalyzer -Path <changed paths> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
poetry run pytest <bundle-contract and manifest suites>
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-10-08
**Policy Version:** Current (as of audit date)
