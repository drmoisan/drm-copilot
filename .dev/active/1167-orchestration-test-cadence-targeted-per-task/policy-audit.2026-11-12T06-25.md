# Policy Compliance Audit: Orchestration Test Cadence, Task Check and Phase Gate (Issue #1167)

**Audit Date:** 2026-11-12
**Branch:** `bug/orchestration-test-cadence-targeted-per-task-1167` @ `b9a97e86590e0d2a0a026d29d63b3ef6cba145de` (PR #1168)
**Base:** `main`; merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e`. `origin/main` was fetched at review time and equals the merge base, and `git merge-tree --write-tree origin/main HEAD` exits 0. `artifacts/pr_context.summary.txt` (generated 2026-11-12 06:12:14 UTC) names head `b9a97e865`, so it is current for this head.
**Work Mode:** full-bug (AC source: `spec.md`)
**Review type:** Re-review after remediation cycle R1 (inputs `remediation-inputs.2026-11-12T04-53.md`), `review_mode: concurrent` (CI on PR #1168 runs in parallel with this review).
**Code Under Test:** `228e6f8c4..b9a97e865`, 168 files, five commits (`b824b9a96`, `ad91a8067`, `9b99051ae`, `d789aa821`, `b9a97e865`). This audit covers all 168 files; the R1 commit `b9a97e865` changes 58 of them.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 0 production; 1 new test file (`tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`) | 21447 testcases | 21437 passed, 0 failed, 10 skipped | 95.80% lines repo-wide (37558 of 39203, Phase 0) | 95.80% lines repo-wide (37558 of 39203) | N/A - no PowerShell production file changed |
| Python | 0 files | 16604 collected | 16598 passed, 0 failed, 6 skipped | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | 5493 root, 5476 extension | 0 failed | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. The only changed PowerShell file is a test file, which is outside the coverage denominator; the repo-wide line figure is unchanged and above 85%. Python, TypeScript, C#, and Bash have zero changed files. The remaining 167 changed files are Markdown, TOML, and plan templates. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester.2026-11-12T03-25.md` (95.80% repo-wide lines, 37558 of 39203).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-12 06:21 UTC, after the head commit (06:11 UTC). The reviewer parsed its root counter: LINE 37558 covered, 1645 missed (95.80%). Recorded run: `evidence/qa-gates/pester.2026-11-12T05-59.md`.
- Python baseline coverage artifact: `evidence/baseline/pytest.2026-11-12T03-29.md` (97.11% lines, 94.37% branches).
- Python post-change coverage artifact: `artifacts/python/lcov.info`, which the reviewer summed to 34334 of 35355 lines (97.11%) and 12668 of 13424 branches (94.37%), equal to `evidence/qa-gates/pytest.2026-11-12T06-02.md`. No Python file changed.
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: the worktree is clean at `b9a97e865`; no production file changed in any commit on the branch, so the coverage figures do not depend on which commit the gate measured.

---

## Executive Summary

The branch adds `## Test Cadence (Mandatory)` to the six `atomic-plan-contract` copies, replaces every per-task full-run prescription with one reference sentence on the Claude, Codex, `.agents`, Copilot, and bundle surfaces, adds `[phase-gate]` tasks to the three plan templates, updates the six execution-environment brief copies, adds a 541-line Pester 6 contract suite, and records process-reduction entry `0011`. No production code changes and no Python file is added.

Remediation cycle R1 resolves the prior blocking finding F1. The canonical section now carries an `Expect-fail phase` bullet (the gate's unit stage accepts only the plan's named `[expect-fail]` failures, each confirmed failing) and a `No-change phase` bullet (a phase that changes no tracked file needs no gate). The planner surfaces restate both provisions, the bug template marks Phase 1 as a no-change phase and gates Phase 2 under the expect-fail provision, and the suite pins all of it. CR1 (ledger summary), CR2 (the `all seven stages` sentence), and CR3 (sweep roots) are also resolved.

Reviewer checks pass: the new suite and seven related suites pass (455 tests, 0 failed); five mutation probes of the template, planner, and canonical rows were run in a scratch copy and the four material mutants were detected; a replay of all 74 `0011` revert blocks restores all 49 non-identical sources to their merge-base content; the Codex generator `--check` exits 0; mirror blob ids are equal; the evidence-location validator exits 0. No blocking finding remains. Three informational items are recorded in the code review.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on `main`; no new project folder is added, so no tier entry is owed)
- ✅ `.claude/rules/tonality.md`
- ✅ `.claude/rules/powershell.md`
- ✅ Process-reduction ledger standing rule (entry `0011` and its index row; the R1 commit carries `reduction: 0011`)
- ⚠️ Policy-document edit authorization: `CLAUDE.md` names `.github/instructions/` canonical and not to be modified; spec decision D13 records the owner's authorization for issue #1167 scoped to the cadence edits, and D15 extends it to the CR2 wording edit. The edits found are within that scope. Recorded for owner visibility in the PR description.

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md` (one new test file)
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --porcelain` at head was empty before the reviewer's checks.
- ✅ Reviewer probes ran from launchers in the session scratchpad against a `git archive` copy; no worktree file was written other than the four review artifacts.

---

## Rejected Scope Narrowing

The caller prompt names the full branch diff (merge base `228e6f8c4`, head `b9a97e865`), the PR context artifacts, `spec.md` as the AC source, and the coverage reports. No statement narrows the audit to a plan, task, phase, subset of files, or language, and none was applied as a narrowing. The audit covers all 168 files, not only the 58 files of the R1 commit.

---

## Process-Reduction Ledger Compliance

`docs/engineering/process-reductions/` exists, so the standing rule applies.

- Entry `docs/engineering/process-reductions/0011-task-check-cadence.md` and its `README.md` index row were added together in commit `9b99051ae`, whose subject carries `reduction: 0011`. The R1 commit `b9a97e865` refreshes the entry and carries `reduction: 0011` in its subject.
- The reviewer ran `ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionChain.Tests.ps1`, `ProcessReductionLedger.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1`, and `ProcessReductionLedger.Replay.Tests.ps1` at head together with the three wording suites: 455 tests, 0 failed.
- Independent replay: the reviewer parsed the 74 revert blocks of entry `0011` at head, required each `Current` fence to occur exactly once in its target at head, substituted the `Prior` text, and compared each result with the merge-base blob. All 49 targets match the merge base exactly.
- CR1 is resolved: the word `stand-in` no longer occurs in the entry, and `## Summary` names pull request #1168.

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `validate_evidence_locations.py --root <item worktree>` exited 0 with no reported path. Evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, and `qa-gates/`, one new file per task check and per gate run.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Rows read tracked files only and share no mutable state; the suite passed inside the parallel shards and in the reviewer run. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One surface file per row; each check reads the narrowest heading or bullet that holds its requirement. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 136 rows, file reads only. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, network, or environment read; paths from `$PSScriptRoot` with `Join-Path`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Rows generated from base lists; template layout held in one `$templateLayout` table; AAA comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester.2026-11-12T03-25.md`, `evidence/baseline/pytest.2026-11-12T03-29.md`. |
| **No Coverage Regression** | ✅ PASS | PowerShell 95.80% to 95.80%; Python 97.11% and 94.37%, equal. |
| **New Code Coverage** | N/A | No production code added. |
| **Modified Files** | N/A | No production file modified. |
| **Comprehensive Coverage** | ✅ PASS | Every surface family of D7 to D9 and D15 has a row group; the sweep now also reads `CLAUDE.md` and `.github/copilot-instructions.md`. |
| **Positive Flows** - Valid inputs | ✅ PASS | All rows pass on the edited tree. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `TCW-CANONICAL-DISCRIMINATES` removes the D15 lines in memory and asserts all six tokens are reported. Reviewer mutants in a scratch copy: removing the expected-failure clause from the bug gate, removing the no-change marker from Phase 1, restoring the pre-R1 bug template, and deleting the No-change bullet from one bundle copy each fail exactly one row. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Template rows check gate count, last-task position within the phase, a later task, the expect-fail gate count, and the no-change heading. |
| **Error Handling** - Error paths | ✅ PASS | A missing section or bullet is returned as a named problem. |
| **Concurrency** - If applicable | N/A | Read-only text checks. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% repo-wide lines (37558 of 39203) -> Post-change: 95.80% repo-wide lines (37558 of 39203). Change: 0.00 points. No PowerShell production file changed; the one new file is a test file outside the denominator. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester.2026-11-12T05-59.md`.
- Python: zero changed files; no comparison is owed. The repo-wide figures equal the Phase 0 figures (97.11% lines, 94.37% branches).
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Template problems name the gate line and the rule, for example `gate line 35 of an expect-fail phase names no expected failures` (observed in the reviewer mutant run). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Every `It` carries Arrange, Act, Assert comments, including the new discrimination row. |
| **Document Intent** | ✅ PASS | Comments cite decision D15 and findings CR2 and CR3 at the rows they add. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No process, network, or temporary file. |
| **Use Mocks/Stubs** | N/A | Files are read in place; nothing to mock. |
| **Environment Stability** | ✅ PASS | `Invoke-PoshQCLeakScan` 0 failures (`evidence/qa-gates/powershell-static.2026-11-12T05-46.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-12T06-03.md`; this audit with `code-review.2026-11-12T06-25.md` and `feature-audit.2026-11-12T06-25.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1167, spec D1 to D15. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-11T19-25.md` and `remediation-plan.2026-11-12T04-53.md`, all tasks checked; preflight fix records under `evidence/other/`. |
| **Document the plan** | ✅ PASS | Remediation plan with `## Pre-Mortem` and red-window statement. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One canonical section with two added bullets; one appended sentence per planner surface. |
| **Reusability** | ✅ PASS | The same planner sentence on all seven planner surfaces and their bundles and variants. |
| **Extensibility** | ✅ PASS | A template's gate layout is one entry in `$templateLayout`. |
| **Separation of concerns** | ✅ PASS | The definition lives in the contract; planners and templates restate only the boundary they apply. F1 is resolved. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One test file for one contract. |
| **At or below the 800-line hard limit** | ✅ PASS | The only covered file in the diff is `test-cadence-wording.Tests.ps1` at 541 logical lines; none at 700 or above. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | N/A | No module API. |
| **No circular dependencies** | N/A | No module dependency. |
| **Project classification (tiers)** | ✅ PASS | No new project folder; the new file lies under `tests/`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `$script:CanonicalD15Token`, `$templateLayout`, `ExpectFailGate`, `NoChangePhase`. |
| **Docs/docstrings** | ✅ PASS | Comment help on every helper. |
| **Comment why, not what** | ✅ PASS | Comments state which decision or finding each added check pins. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Black check clean (1060 files); PoshQC format drift 0 on 37 files. |
| **2. Linting** | ✅ PASS | Ruff clean; PSScriptAnalyzer 0 findings; leak scan 0 failures. |
| **3. Type checking** | ✅ PASS | Pyright 0 errors; PowerShell not applicable. |
| **4. Testing** | ✅ PASS | Pester 21447, 0 failed; pytest 16598 passed, 0 failed; Jest 5493 and 5476 passed. |
| **Full toolchain loop** | ✅ PASS | Phase gate `evidence/qa-gates/phase-gate.R1-P1.2026-11-12T05-45.md`, one clean pass; final QA loop `[P2-T1]` to `[P2-T4]` of the remediation plan. |
| **Explicit reporting** | ✅ PASS | Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Ledger `0011` `## Summary` names the D15 provisions and PR #1168. |
| **Design choices explained** | ✅ PASS | Spec D1 to D15; ledger `## Reason and Evidence`. |
| **Update supporting documents** | ✅ PASS | Execution-environment brief, six byte-identical copies. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python file changed or added.

### Section 3B: PowerShell Code Change Policy Compliance

The new file uses `Set-StrictMode -Version Latest`, advanced functions with `CmdletBinding` and `OutputType`, approved `Get-` verbs, ordinal string comparison (including the new `StartsWith(..., Ordinal)`), a typed `List[string]` for problem accumulation, and no global state. Formatter and analyzer clean.

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test changed. The push-down resource contracts, brief contracts, single-pass preflight contracts, TypeScript toolchain instruction contracts, `test_copilot_bundle_copies_match_canonical`, and `test_plan_templates_carry_premortem_skeleton` pass in the one `pytest -n auto` run.

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `BeforeDiscovery`, `BeforeAll`, `-ForEach`. |
| **Use PoshQC Configuration** | ✅ PASS | One `Invoke-PoshQCParallelTest` run per gate. |
| **Focused Unit Tests** | ✅ PASS | One surface per row. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-runtime/` beside the sibling contract suites. |
| **Mock the wrapper, not the executable** | N/A | No mock. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Canonical section, six copies | `TCW-CANONICAL-*`, `TCW-CANONICAL-REF-*`, `TCW-CANONICAL-DISCRIMINATES` | Required tokens including the six D15 tokens, forbidden tokens, next heading, in-memory discrimination | ✅ |
| Referring surfaces | `TCW-POLICY`, `REMEDIATION`, `DELEGATION`, `EXECUTOR`, `PLANNER`, `RULE`, `QAGATE`, `PROMPT`, `BRIEF` rows | Anchor in the narrowest scope; planner rows require `expected failures` and `no-change phase`; policy rows require `every stage it runs` and forbid `all seven stages` | ✅ |
| Templates | `TCW-TEMPLATE-*` | Gate count per template, last task of its phase, later task, expect-fail gate wording and count, no-change heading | ✅ |
| Sweep | `TCW-SWEEP-SURFACES`, `TCW-SWEEP-HELPER` | Seven tokens across roots including `CLAUDE.md` and `.github/copilot-instructions.md`; count pinned at 7 | ✅ |
| Copilot byte identity | `TCW-BUNDLE-*` | Five files against bundles | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester (final gate) | 21447 testcases, 21437 passed, 0 failed, 10 skipped | ✅ |
| pytest (final gate) | 16598 passed, 0 failed, 6 skipped | ✅ |
| Reviewer Pester run (new suite, #1094 and #1097 wording suites, five ledger suites) | 455 tests, 455 passed | ✅ |
| Reviewer mutation probes (scratch copy) | 1 control passed; 4 material mutants each failed one row; 1 partial-clause planner mutant survived (code review N1) | ✅ |
| Jest (phase gate) | root 5493, extension 5476, 0 failed | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format and analyzer | static artifact 2026-11-12T05-46 | Drift 0, 0 findings over 37 files | ✅ |
| Python static | static artifact 2026-11-12T05-46 | Black, Ruff, Pyright 0 findings | ✅ |
| Codex generator check | `generate_codex_agent_variants --check` (reviewer) | Exit 0 | ✅ |
| Mirror parity | `git ls-files -s` blob ids (reviewer) | Contract base equals bundle (`f47258725`); bug template equals bundle (`b88dde6da`) | ✅ |
| Ledger revert replay | reviewer scratch replay of 74 blocks | 49 of 49 targets equal the merge base | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <item worktree>` (reviewer) | Exit 0 | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` | pass | 21447 testcases, 0 failed, 95.80% lines | `b9a97e865` | `evidence/qa-gates/pester.2026-11-12T05-59.md`; `artifacts/pester/powershell-coverage.xml`; reviewer run of the new and related suites |
| `poshqc / PowerShell QC static` | pass | 0 analyzer findings, 0 format drift | `b9a97e865` | `evidence/qa-gates/powershell-static.2026-11-12T05-46.md` |
| `quality-checks7 / Code Quality & Tests (3.11, 3.12, 3.13)`, including `Enforce Python coverage thresholds` | pass | 16598 passed, 97.11% lines, 94.37% branches | `b9a97e865` | `evidence/qa-gates/pytest.2026-11-12T06-02.md`; `artifacts/python/lcov.info` |
| `root-typescript-tests` and `drm-copilot-extension-tests` | pass | 5493 and 5476 tests, 0 failed | `b9a97e865` | `evidence/qa-gates/phase-gate.R1-P1.2026-11-12T05-45.md` |

At 06:30 UTC, `gh pr checks 1168` showed every check passed at head `b9a97e865` except `poshqc / PowerShell QC shard 1` and `shard 2`, which were pending. `shard 3`, `PowerShell QC static`, `PowerShell hook suites (Linux)`, and all three `quality-checks7` jobs had passed. The orchestrator compares these rows with CI at the join.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. No blocking gap. F1 from the prior review is resolved; CR1, CR2, and CR3 are resolved.
2. Informational items N1 to N3 are recorded in the code review; none requires remediation in this PR.

### Approved Exceptions

**None.** The policy-file edits are covered by spec decisions D13 and D15.

### Removed/Skipped Tests

**None removed.** Skipped counts equal the baseline (Pester 10, pytest 6).

---

## 9. Summary of Changes

Canonical `## Test Cadence (Mandatory)` in six `atomic-plan-contract` copies, including the R1 expect-fail and no-change phase bullets; reference sentences in the four general code-change texts, the orchestrate skill (R3 and delegation), executor and planner surfaces (Claude, Codex base and regenerated variants, `.agents`, Copilot), three hard-lock prompts, five language rules and four `.agents` language skills, eight QA-gate skills, and their bundles; `[phase-gate]` tasks in the bug (two), feature, and refactor plan templates; six execution-environment brief copies; the new Pester suite; ledger entry `0011` and its index row; feature-folder records and evidence.

---

## 10. Compliance Verdict

### Overall Status: ✅ PASS

No blocking finding. All toolchain, coverage, parity, and ledger checks pass. AC14 (CI green on the PR head) is pending CI and is not a finding.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design completeness of the phase-gate rule (F1 resolved); structure, parity, and documentation pass

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell

#### General Unit Test Policy (Section 1)
- ✅ Coverage, baseline comparison, scenario completeness

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 0 failures in Pester, pytest, and Jest
- ✅ PowerShell 95.80% lines, equal to Phase 0; Python 97.11% and 94.37%, equal to Phase 0
- ✅ Ledger chain valid and replays to the merge base; generator check exit 0

### Recommendation

Proceed to the CI green gate. Check off AC14 at S9 once the two pending PowerShell QC shards report success on `b9a97e865` or a later head.

---

## Appendix A: Test Inventory

New: `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` (136 rows). No existing test file is modified; `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` is unchanged.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <item worktree> fetch origin main
git -C <item worktree> merge-tree --write-tree origin/main HEAD
git -C <item worktree> diff --stat 228e6f8c4..HEAD
git -C <item worktree> diff d789aa821..b9a97e865
git -C <item worktree> ls-files -s <contract and template copies>
sh <scratchpad>/checks.sh        # generate_codex_agent_variants --check; validate_evidence_locations.py --root .
sh <scratchpad>/pester-run.sh    # New-PesterConfiguration, Run.Path = the eight suites, Run.PassThru
sh <scratchpad>/mutant.sh <scratchpad> <mutant>   # git archive copy, one mutation, the cadence suite
python -I <scratchpad>/replay.py <item worktree>  # 0011 revert-block replay against the merge base
gh pr checks 1168
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-12
**Policy Version:** Current (as of audit date)
