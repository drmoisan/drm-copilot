# Policy Compliance Audit: Orchestration Test Cadence, Task Check and Phase Gate (Issue #1167)

**Audit Date:** 2026-11-12
**Branch:** `bug/orchestration-test-cadence-targeted-per-task-1167` @ `d789aa821f900b36dfc884952ffc45126e15a042` (PR #1168)
**Base:** `main`; merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e` (`origin/main`). `artifacts/pr_context.summary.txt` (generated 2026-11-12 04:38:55 UTC) names head `d789aa821`, so it is current for this head.
**Work Mode:** full-bug (AC source: `spec.md`)
**Review type:** Initial review, `review_mode: concurrent` (CI on PR #1168 runs in parallel with this review).
**Code Under Test:** `228e6f8c4..d789aa821`, 149 files, four commits (`b824b9a96`, `ad91a8067`, `9b99051ae`, `d789aa821`). This audit covers all 149 files.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 0 production; 1 new test file (`tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`) | 21446 testcases | 21436 passed, 0 failed, 10 skipped | 95.80% lines repo-wide (37558 of 39203, Phase 0) | 95.80% lines repo-wide (37558 of 39203) | N/A - no PowerShell production file changed |
| Python | 0 files | 16604 collected | 16598 passed, 0 failed, 6 skipped | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | 5493 root, 5476 extension | 0 failed | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. The only changed PowerShell file is a test file, which is outside the coverage denominator; the repo-wide line figure is unchanged and above 85%. Python, TypeScript, C#, and Bash have zero changed files. The remaining 148 changed files are Markdown, TOML, and plan templates. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester.2026-11-12T03-25.md` (95.80% repo-wide lines, 37558 of 39203).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-12 04:49 UTC. The reviewer parsed its root counters: LINE 37558 covered, 1645 missed (95.80%); INSTRUCTION 63698 covered, 3542 missed. Recorded run: `evidence/qa-gates/pester.2026-11-12T04-19.md`.
- Python baseline coverage artifact: `evidence/baseline/pytest.2026-11-12T03-29.md` (97.11% lines, 94.37% branches).
- Python post-change coverage artifact: `artifacts/python/lcov.info`, which the reviewer summed to 34334 of 35355 lines (97.11%) and 12668 of 13424 branches (94.37%), equal to `evidence/qa-gates/pytest.2026-11-12T04-23.md`. No Python file changed.
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: the head commit `d789aa821` was committed at 04:38 UTC and edits one line of the ledger entry; `9b99051ae` carries the change that the gates measured. The Pester coverage file was written at 04:49 UTC, after the last commit, and the worktree is clean.

---

## Executive Summary

The branch adds `## Test Cadence (Mandatory)` to the six `atomic-plan-contract` copies, replaces every per-task full-run prescription with one reference sentence on the Claude, Codex, `.agents`, Copilot, and bundle surfaces, adds a `[phase-gate]` task to the three plan templates, updates the six execution-environment brief copies, adds a 499-line Pester 6 contract suite, and records process-reduction entry `0011`. No production code changes and no Python file is added.

Reviewer checks pass: the new suite and seven related suites pass (454 tests, 0 failed), the Codex generator `--check` exits 0, mirror blob ids are equal, the evidence-location validator exits 0, and the ledger chain suites pass.

One blocking design finding (F1, see the code review): the canonical phase-gate rule requires a clean full-suite gate at the end of every phase between Phase 0 and the final QA phase, but gives no rule for a phase that ends with an `[expect-fail]` test still failing. The bug plan template places the `[expect-fail]` regression test in its own Phase 2; under the shipped rule that phase needs a gate that cannot pass, and the template itself omits the gate from Phases 1 and 2, contradicting the rule it cites. Every full-bug orchestration that follows the template meets this conflict.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on `main`; no new project folder is added, so no tier entry is owed)
- ✅ `.claude/rules/tonality.md`
- ✅ `.claude/rules/powershell.md`
- ✅ Process-reduction ledger standing rule (entry `0011` added with its index row in the same commit)
- ⚠️ Policy-document edit authorization: `CLAUDE.md` names `.github/instructions/` canonical and not to be modified; spec decision D13 records the owner's authorization for issue #1167 scoped to the cadence edits. The edits found are within that scope. Recorded for owner visibility in the PR description.

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md` (one new test file)
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --porcelain` at head was empty before the reviewer's checks.
- ✅ Reviewer probes ran from a launcher in the session scratchpad; no worktree file was written other than the four review artifacts.

---

## Rejected Scope Narrowing

The caller prompt names the full branch diff (merge base `228e6f8c4`, head `d789aa821`), the PR context artifacts, `spec.md` as the AC source, and the coverage reports. No statement narrows the audit to a plan, task, phase, subset of files, or language, and none was applied as a narrowing.

---

## Process-Reduction Ledger Compliance

`docs/engineering/process-reductions/` exists, so the standing rule applies.

- Entry `docs/engineering/process-reductions/0011-task-check-cadence.md` and its `README.md` index row are both in commit `9b99051ae`, whose subject carries `reduction: 0011`.
- The reviewer ran `ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionChain.Tests.ps1`, `ProcessReductionLedger.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1`, and `ProcessReductionLedger.Replay.Tests.ps1` at head: 149 tests, 0 failed.
- `d789aa821` changes the `Merge commit:` line to `pending (PR #1168)`. The `## Summary` paragraph still says the line carries the canonical issue number as a stand-in (non-blocking CR1 in the code review).
- A remediation of F1 edits the canonical section, so the `0011` revert blocks for the six contract copies must be refreshed in the same commit.

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `validate_evidence_locations.py --root <item worktree>` exited 0 with no reported path. Evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, and `qa-gates/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Rows read tracked files only and share no mutable state; the suite passed inside the parallel shards and in the reviewer run. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One surface file per row; each check reads the narrowest heading or bullet that holds its requirement. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 135 rows, file reads only. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, network, or environment read; paths from `$PSScriptRoot` with `Join-Path`. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Rows generated from base lists by `Get-TcwRow`; `TCW-<group>-<copy>` identifiers; AAA comments. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester.2026-11-12T03-25.md`, `evidence/baseline/pytest.2026-11-12T03-29.md`. |
| **No Coverage Regression** | ✅ PASS | PowerShell 95.80% to 95.80%; Python 97.11% and 94.37%, equal. |
| **New Code Coverage** | N/A | No production code added. |
| **Modified Files** | N/A | No production file modified. |
| **Comprehensive Coverage** | ✅ PASS | Every surface family of D7 to D9 has a row group; the sweep covers the harness roots and bundles. |
| **Positive Flows** - Valid inputs | ✅ PASS | All rows pass on the edited tree. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Forbidden-token checks on every row; the sweep tokens occur in 30 or more surface files at the merge base (reviewer `git grep` count), so `TCW-SWEEP-SURFACES` would fail on the base tree. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Fenced headings ignored in section reads; template rows require exactly one gate line followed by a phase heading. |
| **Error Handling** - Error paths | ✅ PASS | A missing section or bullet is returned as a named problem; an unmapped bundle path throws at discovery. |
| **Concurrency** - If applicable | N/A | Read-only text checks. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% repo-wide lines (37558 of 39203) -> Post-change: 95.80% repo-wide lines (37558 of 39203). Change: 0.00 points. No PowerShell production file changed; the one new file is a test file outside the denominator. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/pester.2026-11-12T04-19.md`.
- Python: zero changed files; no comparison is owed. The repo-wide figures equal the Phase 0 figures (97.11% lines, 94.37% branches).
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Problem strings name the token and the scope, for example `missing '<token>' in <heading>`. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Every `It` carries Arrange, Act, Assert comments. |
| **Document Intent** | ✅ PASS | File header states the issue #1167 contract; every helper has comment help. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No process, network, or temporary file. |
| **Use Mocks/Stubs** | N/A | Files are read in place; nothing to mock. |
| **Environment Stability** | ✅ PASS | `Invoke-PoshQCLeakScan` 0 failures (`evidence/qa-gates/powershell-static.2026-11-12T04-08.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-12T04-24.md`; this audit with `code-review.2026-11-12T04-53.md` and `feature-audit.2026-11-12T04-53.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1167, spec D1 to D14. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-11T19-25.md`, 21 tasks, all checked; preflight fixes recorded. |
| **Document the plan** | ✅ PASS | Plan with `## Size Justification` for 21 tasks. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | One canonical section and one reference sentence per surface. |
| **Reusability** | ✅ PASS | The same reference sentence on every surface. |
| **Extensibility** | ✅ PASS | A new surface adds one base entry to a row group. |
| **Separation of concerns** | ⚠️ PARTIAL | The definition is in one place, but it is incomplete for `[expect-fail]` phases and the bug template contradicts it (F1). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One test file for one contract. |
| **At or below the 800-line hard limit** | ✅ PASS | The only covered file in the diff is `test-cadence-wording.Tests.ps1` at 499 logical lines; none at 700 or above. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | N/A | No module API. |
| **No circular dependencies** | N/A | No module dependency. |
| **Project classification (tiers)** | ✅ PASS | No new project folder; the new file lies under `tests/`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Get-TcwSection`, `Get-TcwBullet`, `Get-TcwCheckProblem`; vocabulary "task check" and "task's test selection". |
| **Docs/docstrings** | ✅ PASS | Comment help on every helper. |
| **Comment why, not what** | ✅ PASS | Comments explain why tokens are row data and why sections are read narrowly. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Black check clean; PoshQC format drift 0 on 37 files. |
| **2. Linting** | ✅ PASS | Ruff clean; PSScriptAnalyzer 0 findings; leak scan 0 failures. |
| **3. Type checking** | ✅ PASS | Pyright 0 errors; PowerShell not applicable. |
| **4. Testing** | ✅ PASS | Pester 21446, 0 failed; pytest 16598 passed, 0 failed; Jest 5493 and 5476 passed. |
| **Full toolchain loop** | ✅ PASS | Phase gate `evidence/qa-gates/phase-gate.P1.2026-11-12T04-07.md`, one clean pass; final QA loop `[P2-T1]` to `[P2-T4]`. |
| **Explicit reporting** | ✅ PASS | Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Ledger `0011` `## Summary` and `## Files Changed`. |
| **Design choices explained** | ✅ PASS | Spec D1 to D14; ledger `## Reason and Evidence`. |
| **Update supporting documents** | ✅ PASS | Execution-environment brief, six byte-identical copies (one blob id). |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python file changed or added.

### Section 3B: PowerShell Code Change Policy Compliance

The new file uses `Set-StrictMode -Version Latest`, advanced functions with `CmdletBinding` and `OutputType`, approved `Get-` verbs, ordinal string comparison, and no global state. Formatter and analyzer clean.

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test changed. The push-down resource contracts, brief contracts, single-pass preflight contracts, TypeScript toolchain instruction contracts, and `test_plan_templates_carry_premortem_skeleton` pass in the one `pytest -n auto` run.

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
| Canonical section, six copies | `TCW-CANONICAL-*`, `TCW-CANONICAL-REF-*` | Required tokens, forbidden tokens, next heading | ✅ |
| Referring surfaces | `TCW-POLICY`, `REMEDIATION`, `DELEGATION`, `EXECUTOR`, `PLANNER`, `RULE`, `QAGATE`, `PROMPT`, `BRIEF` rows | Anchor in the narrowest scope, forbidden #1094 tokens | ✅ |
| Templates | `TCW-TEMPLATE-*` | One gate line, last task of an intermediate phase | ✅ (does not check the `[expect-fail]` phase, F1) |
| Sweep | `TCW-SWEEP-SURFACES`, `TCW-SWEEP-HELPER` | Seven tokens across roots; in-memory detection; count pinned at 7 | ✅ |
| Copilot byte identity | `TCW-BUNDLE-*` | Five files against bundles | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester (final gate) | 21446 testcases, 21436 passed, 0 failed, 10 skipped | ✅ |
| pytest (final gate) | 16598 passed, 0 failed, 6 skipped | ✅ |
| Reviewer Pester run (new suite, #1094 and #1097 wording suites, five ledger suites) | 454 tests, 454 passed | ✅ |
| Jest (phase gate) | root 5493, extension 5476, 0 failed | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format and analyzer | static artifact 2026-11-12T04-08 | Drift 0, 0 findings over 37 files | ✅ |
| Python static | static artifact 2026-11-12T04-09 | Black, Ruff, Pyright 0 findings | ✅ |
| Codex generator check | `generate_codex_agent_variants --check` (reviewer) | Exit 0 | ✅ |
| Mirror parity | `git ls-files -s` blob ids (reviewer) | Contract base equals bundle; six brief copies share one blob id | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <item worktree>` (reviewer) | Exit 0 | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` | pass | 21446 testcases, 0 failed, 95.80% lines | `d789aa821` | `evidence/qa-gates/pester.2026-11-12T04-19.md`; `artifacts/pester/powershell-coverage.xml`; reviewer run of the new and related suites |
| `poshqc / PowerShell QC static` | pass | 0 analyzer findings, 0 format drift | `d789aa821` | `evidence/qa-gates/powershell-static.2026-11-12T04-08.md` |
| `quality-checks7 / Code Quality & Tests (3.11, 3.12, 3.13)`, including `Enforce Python coverage thresholds` | pass | 16598 passed, 97.11% lines, 94.37% branches | `d789aa821` | `evidence/qa-gates/pytest.2026-11-12T04-23.md`; `artifacts/python/lcov.info` |
| `root-typescript-tests` and `drm-copilot-extension-tests` | pass | 5493 and 5476 tests, 0 failed | `d789aa821` | `evidence/qa-gates/phase-gate.P1.2026-11-12T04-07.md` |

At the time of writing, `gh pr checks 1168` showed every check passed except `poshqc / PowerShell QC shard 1` and `shard 2`, which were pending. The orchestrator compares these rows with CI at the join.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **F1 (blocking, design):** the phase-gate rule has no provision for a phase that ends with an `[expect-fail]` test failing, and the bug plan template contradicts the rule. See the code review and `remediation-inputs.2026-11-12T04-53.md`.
2. **CR1, CR2, CR3 (non-blocking):** recorded in the code review.

### Approved Exceptions

**None.** The policy-file edits are covered by spec decision D13.

### Removed/Skipped Tests

**None removed.** Skipped counts equal the baseline (Pester 10, pytest 6).

---

## 9. Summary of Changes

Canonical `## Test Cadence (Mandatory)` in six `atomic-plan-contract` copies; reference sentences in the four general code-change texts, the orchestrate skill (R3 and delegation), executor and planner surfaces (Claude, Codex base and regenerated variants, `.agents`, Copilot), three hard-lock prompts, five language rules and four `.agents` language skills, eight QA-gate skills, and their bundles; a `[phase-gate]` task in the bug, feature, and refactor plan templates; six execution-environment brief copies; the new Pester suite; ledger entry `0011` and its index row; feature-folder records and evidence.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ REMEDIATION REQUIRED

One blocking design finding (F1). All toolchain, coverage, parity, and ledger checks pass.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ⚠️ Design completeness of the phase-gate rule (F1); structure, parity, and documentation pass

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell

#### General Unit Test Policy (Section 1)
- ✅ Coverage, baseline comparison, scenario completeness

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 0 failures in Pester, pytest, and Jest
- ✅ PowerShell 95.80% lines, equal to Phase 0; Python 97.11% and 94.37%, equal to Phase 0
- ✅ Ledger chain valid; generator check exit 0

### Recommendation

**Remediate F1** in a full remediation cycle: state in the canonical section how a phase that ends with an `[expect-fail]` test is gated, align the three plan templates and the planner surfaces with that rule, extend `TCW-CANONICAL` and `TCW-TEMPLATE` to pin it, and refresh the `0011` revert blocks. Fold CR1 into the same cycle.

---

## Appendix A: Test Inventory

New: `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` (135 rows). No existing test file is modified; `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` is unchanged.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <item worktree> log --oneline 228e6f8c4..HEAD
git -C <item worktree> diff --stat 228e6f8c4..HEAD
git -C <item worktree> grep -c -i -F -e "<sweep token>" 228e6f8c4 --
git -C <item worktree> ls-files -s <contract and brief copies>
env -u VIRTUAL_ENV poetry -C <item worktree> run python -m scripts.dev_tools.generate_codex_agent_variants --check
env -u VIRTUAL_ENV poetry -C <item worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>
sh <scratchpad>/run-pester.sh   # New-PesterConfiguration, Run.Path = the eight suites, Run.Exit = $true
gh pr checks 1168 --repo drmoisan/drm-copilot
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-12
**Policy Version:** Current (as of audit date)
