# Policy Compliance Audit: Pre-Implementation Gate False Positives (Issue #1160)

**Audit Date:** 2026-11-13
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `4767fe8a35e9a1b8f404ff827f009098b7ed9855` (PR #1174)
**Base:** `main`; merge base `18520b3fce8b6273ac63a16fef03816f7119dcad`. `origin/main` was fetched at review time and equals the merge base, and `git merge-tree --write-tree origin/main HEAD` exits 0. `artifacts/pr_context.summary.txt` (generated 2026-11-13 17:34:34 UTC) names head `4767fe8a3`, so it is current for this head.
**Work Mode:** full-bug (AC source: `spec.md`)
**Review type:** First review, `review_mode: concurrent` (CI on PR #1174 runs in parallel with this review, issue #1097).
**Code Under Test:** `18520b3fc..4767fe8a3`, 56 files: two modified gate files and their two bundle copies, two new sibling hook files in four byte-identical copies each, six execution-environment brief copies, two orchestrate skill copies, two pack manifests, nine new Pester files, and feature-folder records and evidence.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 modified gate files and 2 new siblings (plus 6 byte-identical bundle copies); 9 new test files | 22233 testcases | 22223 passed, 0 failed, 10 skipped | 95.80% lines repo-wide (37558 of 39203, Phase 0) | 95.85% lines repo-wide (38123 of 39772) | 98.68% lines lowest new file (75 of 76); 100.00% of changed gate lines |
| Python | 0 files | 68 contract tests | 68 passed, 0 failed | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern; Pester measures no branch figure, so no branch threshold applies to PowerShell. Spec AC-22 sets a stricter 90% line figure for the four new sibling copies, which they meet. Python, TypeScript, C#, and Bash have zero changed files.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester-gate.2026-11-10T04-19.md` (95.80% repo-wide lines, 37558 of 39203; Claude gate 96.32%, Codex gate 100.00%).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-13 17:26 UTC by the single parallel gate run recorded in `evidence/qa-gates/pester-gate.2026-11-13T17-27.md`. The reviewer parsed its counters: root LINE 38123 of 39772 (95.85%); `.claude/hooks` and `.codex/hooks` commands sibling 75 of 76 each; bookkeeping sibling 78 of 78 each; Claude gate 162 of 168; Codex gate 178 of 178. Every figure equals `evidence/qa-gates/coverage-comparison.2026-11-13T17-27.md`.
- Python baseline coverage artifact: N/A - zero changed Python files.
- Python post-change coverage artifact: N/A - zero changed Python files.
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: the gate run started after the last merge of `origin/main` (commit `3acd52007`, 17:11 UTC); the four later commits (`bcba50e66`, `7f12ba527`, `1841f9e2d`, `4767fe8a3`) change only feature-folder Markdown, so the coverage figures describe the head's production files. The worktree was clean at review start.

---

## Executive Summary

The branch adds a stage-2 confirmation to `Test-ImplementationCommand` on the Claude and Codex gates (a stage-1 regex hit is dropped when every governed word is an operand of a mention host) and a bookkeeping staging leg that allows `git add` and `git commit` of `.claude/agent-memory/` paths without a ready checkpoint. All new logic lives in two byte-identical siblings with four copies each; the gate files gain guarded dot-sources and three short edits. Documentation and pack manifests are updated.

Recorded gates are clean: format and analyzer 0 findings on 19 files, one parallel Pester run with 22233 tests and 0 failures, leak scan 0 failures, six push-down contract files 68 passed, Codex generator check exit 0. Reviewer checks: four-copy SHA256 identity of both siblings, gate bundle identity, real-process probes of the shipped Claude gate in a scratch repository (agent-memory add, pathless commit, and `-F` commit allow; `src/` staging, mixed index, and `pytest -q` deny; invalid and `[]` configuration deny), and identical Claude and Codex classification on 28 probe commands.

One blocking finding (F1, related to issue #1160, autonomous, design scope): the stage-2 rule judges each record alone, so a mention host whose output is piped into an executing consumer is now unclassified. `pwsh -NoProfile -Command "Get-ChildItem tests/scripts/run.ps1 | ForEach-Object { & $_.FullName }"`, `pwsh -NoProfile -Command "Get-Command pytest | ForEach-Object { & $_ }"`, and `echo pytest | xargs env` are classified by the merge-base gate and are not classified at head. They are real invocations, not mentions. Detail in `code-review.2026-11-13T17-44.md`.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on `main`; no new project folder is added, so no tier entry is owed)
- ✅ `.claude/rules/tonality.md`
- ✅ `.claude/rules/powershell.md`
- ✅ Hook-path language rule (no Python in the hook path): no `.py` file added; no interpreter invocation in either gate or sibling

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md` (gate files, siblings, test files)
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --porcelain` at head was empty before the reviewer's checks.
- ✅ Reviewer probes ran from launchers in the session scratchpad, against the worktree hooks, a `git archive` copy of the merge-base hooks, and a scratch repository; no worktree file was written other than the review artifacts.

---

## Rejected Scope Narrowing

The caller prompt names the full branch diff (merge base `18520b3fc`, head `4767fe8a3`), the PR context artifacts, `spec.md` as the AC source, and the newest gate evidence files. The instruction to read gate results from the evidence files and not re-run format, lint, or tests limits re-execution, not scope; every changed file and language is covered by this audit. No statement narrows the audit to a plan, task, phase, subset of files, or language.

---

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `validate_evidence_locations.py --root <item worktree>` exited 0 with no reported path. Evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, `qa-gates/`, and `regression-testing/`. The executor recorded `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ (spec AC-22) replaced with <FEATURE>/evidence/qa-gates/`; `evidence/coverage/` is not a canonical sub-path in `evidence-and-timestamp-conventions`, so the substitution is correct.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Rows are data-driven; each `It` loads its own sibling copy; no shared mutable state. All suites passed inside 8 parallel shards. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One corpus row or one function case per `It`; unit suites per sibling, decision-level leg suites per surface. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pure string logic behind mocked seams; no process or file I/O in the new suites. |
| **Determinism** - Consistent results | ✅ PASS | `Get-OrchestrationGateStagedIndex` and `Get-OrchestrationGateBookkeepingConfigText` are mocked wherever the leg is reached; no clock or randomness. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Corpus held in one data file (`Classification.Cases.ps1`) with FP, ED, and NG row identifiers; runners are short. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester-gate.2026-11-10T04-19.md`. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 95.80% to 95.85%; Claude gate 96.32% to 96.43%; Codex gate 100.00% to 100.00%. |
| **New Code Coverage** | ✅ PASS | Commands sibling 98.68% (both copies), bookkeeping sibling 100.00% (both copies). |
| **Modified Files** | ✅ PASS | Changed lines of both gate files: 9 of 9 executable lines covered on each surface. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | The corpus covers 17 false-positive rows, 42 existing-denial rows, and 9 non-goal rows, but no row pipes a mention host into an executing consumer; see F1. |
| **Positive Flows** - Valid inputs | ✅ PASS | FP rows and agent-memory allow rows on both surfaces. |
| **Negative Flows** - Invalid inputs | ✅ PASS | ED rows; deny rows for `git add .`, `-A`, globs, `..`, backslash, `--amend`, `-a`, chained runners, unreadable index. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Configuration entries: trailing slash, leading slash, `//`, `.` and `..` segments, duplicates, unknown keys, `[]`. |
| **Error Handling** - Error paths | ✅ PASS | Unreadable configuration and invalid JSON yield the `BOOKKEEPING_CONFIG_INVALID` suffix after the cleanup suffix. |
| **Concurrency** - If applicable | N/A | Stateless hook decision. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% repo-wide lines (37558 of 39203) -> Post-change: 95.85% repo-wide lines (38123 of 39772). Change: +0.05 points. New/changed-code coverage: 98.68% (commands sibling, both copies), 100.00% (bookkeeping sibling, both copies), 100.00% of changed executable lines in each gate file. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-comparison.2026-11-13T17-27.md`.
- Python: zero changed files; no comparison is owed.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Row identifiers appear in each `It` name (`does not classify false-positive row FP-01`). |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange, Act, Assert comments in the unit and leg suites. |
| **Document Intent** | ✅ PASS | Suite headers cite the decisions (D2, D5, D14, D15) each group pins. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No git, filesystem, or process call in the new suites; the staged-index and configuration seams are mocked. |
| **Use Mocks/Stubs** | ✅ PASS | `Mock Get-OrchestrationGateStagedIndex`, `Mock Get-OrchestrationGateBookkeepingConfigText`; injected `-ConfigReader` and `-StagedIndexReader` script blocks. |
| **Environment Stability** | ✅ PASS | `Invoke-PoshQCLeakScan`: 759 files, 0 failures; search of the eight new suites for temporary-file APIs found 0 matches. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-13T17-30.md`; this audit with `code-review.2026-11-13T17-44.md` and `feature-audit.2026-11-13T17-44.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1160; spec decisions D1 to D15. |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-09T16-36.md`, all tasks checked; preflight and shared-file re-read records under `evidence/other/`. |
| **Document the plan** | ✅ PASS | Plan with phases, task checks, and decisions D14 and D15 recorded at execution. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Stage 1 is unchanged; stage 2 is one function over the shared invocation iterator. |
| **Reusability** | ✅ PASS | Reuses `Read-CommandLineInvocationSegment`, `Get-EpicFanInAllowance`, `Test-EpicMergedFeaturePath`, and `Test-ExemptOrchestrationSelector` without editing them. |
| **Extensibility** | ✅ PASS | Mention-host table is data behind a getter; declared roots are configuration. |
| **Separation of concerns** | ✅ PASS | One I/O seam (`Get-OrchestrationGateBookkeepingConfigText`); parsing and decisions are pure. |
| **Correctness of the classification rule** | ❌ FAIL | F1: per-record judgment declassifies pipelines that feed a mention host's output into an executing consumer. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Commands sibling: classification only; bookkeeping sibling: configuration and leg only. |
| **At or below the 800-line hard limit** | ✅ PASS | Largest covered files: Codex gate 499, Claude gate 485, bookkeeping sibling 290, bookkeeping unit suite 278 logical lines; none at 700 or above. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | The gate function inventory `$script:SharedGateFunction` is unchanged; new functions live in the siblings. |
| **No circular dependencies** | ✅ PASS | Siblings call shared helpers at call time and are dot-sourced after them. |
| **Project classification (tiers)** | ✅ PASS | No new project folder; the siblings lie in the existing hook folders. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Test-OrchestrationGateInvocationConfirmed`, `Get-OrchestrationBookkeepingStagingResult`, `ConvertFrom-OrchestrationGateBookkeepingConfig`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on every function; file headers state rules, schema, default, opt-out, and suffix. |
| **Comment why, not what** | ✅ PASS | Gate comments name issue #1160 and the stage-2 purpose at each edit. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Non-writing `Invoke-Formatter` comparison: 0 of 19 files differ (`evidence/qa-gates/powershell-static.2026-11-13T17-15.md`). |
| **2. Linting** | ✅ PASS | PSScriptAnalyzer 0 findings on 19 files; leak scan 0 failures. |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Testing** | ✅ PASS | Pester 22233 tests, 0 failed (`evidence/qa-gates/pester-gate.2026-11-13T17-27.md`); contract tests 68 passed (`evidence/qa-gates/contract-and-scope.2026-11-13T17-29.md`). |
| **Full toolchain loop** | ✅ PASS | One clean static pass and one clean parallel test pass on the merged head. |
| **Explicit reporting** | ✅ PASS | Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Gate and sibling headers; brief bullet; orchestrate paragraph. |
| **Design choices explained** | ✅ PASS | Spec D1 to D15, research file. |
| **Update supporting documents** | ✅ PASS | Six execution-environment copies carry the same bullet; the orchestrate skill and its bundle are byte-identical. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python file changed or added. The contract-and-scope evidence records a search of both gate files and both siblings for interpreter invocations with 0 invocation matches.

### Section 3B: PowerShell Code Change Policy Compliance

Advanced functions with `CmdletBinding` and `OutputType`; approved verbs (`Get-`, `Test-`, `ConvertFrom-`); ordinal string comparisons; `ConvertFrom-Json -NoEnumerate`; no `StrictMode` or preference assignment in the dot-sourced siblings, which the headers justify (a dot-sourced file changes its caller's scope). Guarded dot-source in the `try { . ... } catch { Add-HookDependencyFailure ... }` form on both gates. Formatter and analyzer clean.

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test changed. The five push-down contract files and `test_execution_environment_brief_contracts.py` pass (68 tests).

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `BeforeAll`, `Describe`/`Context`/`It`, `-ForEach`, `Should -Invoke`. |
| **Use PoshQC Configuration** | ✅ PASS | One `Invoke-PoshQCParallelTest` run per gate. |
| **Focused Unit Tests** | ✅ PASS | One row or case per `It`. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, beside the existing gate suites. |
| **Mock the wrapper, not the executable** | ✅ PASS | The git staged-index reader and the configuration reader are mocked at their PowerShell wrappers. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Classification corpus, both surfaces | `Classification.Tests.ps1`, `-classification.Tests.ps1` (128 each) | FP-01 to FP-17 allow, ED-01 to ED-42 deny with byte-equal text, NG-01 to NG-09 unclassified | ⚠️ no pipeline-to-executor row (F1) |
| Stage-2 function and host table | `-commands.Tests.ps1` (71) | Table pin, fallbacks (Unbalanced, Opaque, evaluator, `rg --pre`, `git -O`, `ForEach-Object`, `find`, `::`, `.Invoke`), stage-1-miss | ✅ |
| Configuration and leg unit | `-bookkeeping.Tests.ps1` (126) | Parser rules, seam path, root helper, anchor, selector, leg results | ✅ |
| Decision-level leg, both surfaces | `.BookkeepingLeg.Tests.ps1` (46), `-bookkeeping-leg.Tests.ps1` (47) | AC-6 allow rows, D14 mixed rows, AC-8 deny rows, `[]` and invalid suffix ordering | ✅ |
| Four-copy parity | `-commands.Parity.Tests.ps1`, `-bookkeeping.Parity.Tests.ps1` (2 each) | SHA256 identity, fewer than 500 lines | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester (final gate, merged head) | 22233 testcases, 0 failed, 10 skipped | ✅ |
| Fail-before (unfixed gates) | 68 failures, exactly the FP rows on both surfaces | ✅ |
| Contract tests (pytest, six files) | 68 passed | ✅ |
| Reviewer classification probes, head versus merge base | 44 commands at head (28 compared Claude with Codex, identical); 16 compared with the merge base; 7 real-invocation forms classified at base and unclassified at head | ❌ (F1) |
| Reviewer real-process probes (scratch repository) | 9 cases, all as specified | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format and analyzer | static artifact 2026-11-13T17-15 | 0 format differences, 0 findings over 19 files | ✅ |
| Codex generator check | `generate_codex_agent_variants --check` (executor) | Exit 0 | ✅ |
| Sibling four-copy identity | reviewer `sha256sum` | One digest per sibling | ✅ |
| Gate bundle identity | reviewer `cmp` | Both gate files equal their bundle copies | ✅ |
| Brief and orchestrate mirrors | reviewer comparison | Same bullet in all six brief copies; orchestrate base equals bundle | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <item worktree>` (reviewer) | Exit 0 | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` | pass | 22233 testcases, 0 failed, 95.85% lines | `4767fe8a3` | `evidence/qa-gates/pester-gate.2026-11-13T17-27.md`; `artifacts/pester/powershell-coverage.xml` |
| `poshqc / PowerShell hook suites (Linux)` | pass | new and existing gate suites 0 failed | `4767fe8a3` | `evidence/qa-gates/pester-gate.2026-11-13T17-27.md` |
| `poshqc / PowerShell QC static` | pass | 0 analyzer findings, 0 format differences | `4767fe8a3` | `evidence/qa-gates/powershell-static.2026-11-13T17-15.md` |
| `quality-checks7 / Code Quality & Tests (3.11, 3.12, 3.13)` | pass | push-down contract files 68 passed | `4767fe8a3` | `evidence/qa-gates/contract-and-scope.2026-11-13T17-29.md` |

At 17:44 UTC, `gh pr checks 1174` showed these four check groups pending at head `4767fe8a3`; build, docs validation, extension tests, and root TypeScript tests (windows-latest) had passed. The local outcome column records the executor's evidence; the orchestrator compares these rows with CI at the join. No finding depends on a pending CI result, so none is classified `awaiting_ci`.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. F1 (blocking, related to issue #1160, autonomous, design scope): pipeline-fed executing consumers are declassified by stage 2.
2. Non-blocking items N1 to N4 are recorded in the code review.
3. No finding unrelated to issue #1160 was identified.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None removed.** Skipped count equals the baseline (10).

---

## 9. Summary of Changes

Stage-2 confirmation in `Test-ImplementationCommand` and a bookkeeping staging leg in `Invoke-OrchestrationPreimplementationGateDecision` on both gates; new siblings `enforce-orchestration-preimplementation-gate-commands.ps1` and `enforce-orchestration-preimplementation-gate-bookkeeping.ps1` in four copies each; both gate bundle copies; both `core.json` manifests; six execution-environment brief copies; two orchestrate copies; nine new Pester files; feature-folder records and evidence.

---

## 10. Compliance Verdict

### Overall Status: ❌ REMEDIATION REQUIRED

One blocking finding (F1). All toolchain, coverage, parity, and contract checks pass. AC-24 (CI green on the PR head) is pending CI and is not a finding.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ❌ Correctness of the stage-2 classification rule (F1); structure, parity, size, and documentation pass

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell

#### General Unit Test Policy (Section 1)
- ✅ Coverage and baseline comparison
- ⚠️ Scenario completeness: no corpus row for a mention host piped into an executing consumer (F1)

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 0 failures in Pester (22233) and contract tests (68)
- ✅ PowerShell 95.85% repo-wide lines, above the 95.80% Phase 0 figure; new siblings 98.68% and 100.00%
- ✅ Four-copy identity, bundle identity, generator check exit 0

### Recommendation

Remediate F1 through a recorded spec decision (D16) that confirms a stage-1 hit when a record downstream of a carrying record in the same pipeline is an executing consumer, with corpus rows on both surfaces. Then re-review. Check off AC-24 at S9.

---

## Appendix A: Test Inventory

New: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (data), `.Classification.Tests.ps1`, `-commands.Tests.ps1`, `-commands.Parity.Tests.ps1`, `-bookkeeping.Tests.ps1`, `-bookkeeping.Parity.Tests.ps1`, `.BookkeepingLeg.Tests.ps1`; `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1`, `-bookkeeping-leg.Tests.ps1`. No existing test file is modified.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <item worktree> fetch origin main
git -C <item worktree> merge-tree --write-tree origin/main HEAD
git -C <item worktree> diff --name-status 18520b3fc..HEAD
git -C <item worktree> archive 18520b3fc .claude/hooks .claude/lib .codex/hooks   # merge-base copy for probes
sh <scratchpad>/run1.sh      # Test-ImplementationCommand over a case list, head Claude gate
sh <scratchpad>/run1c.sh     # same, head Codex gate
sh <scratchpad>/run1b.sh     # same, merge-base Claude gate
sh <scratchpad>/run2.sh      # shipped Claude gate via pwsh -File with JSON payloads in a scratch repository
sha256sum <four copies of each sibling>
poetry -C <item worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>
gh pr checks 1174
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-13
**Policy Version:** Current (as of audit date)
