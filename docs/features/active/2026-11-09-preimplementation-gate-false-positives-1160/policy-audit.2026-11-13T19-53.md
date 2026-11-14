# Policy Compliance Audit: Pre-Implementation Gate False Positives (Issue #1160), Re-audit After Remediation Cycle 2

**Audit Date:** 2026-11-13
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `762a9c9e12077f974bb0bc369abbd28e289afda5` (PR #1174)
**Base:** `main`; merge base `eb73f1dff52e7175228a03740b53281c81e1c00c` (`git merge-base origin/main HEAD` after `git fetch origin main`). `git merge-tree --write-tree origin/main HEAD` exits 0. The PR context artifacts were stale (head `4767fe8a3`) and were regenerated at 2026-11-13 19:54:41 UTC for head `762a9c9e1` against `origin/main @ eb73f1dff`.
**Work Mode:** full-bug (AC source: `spec.md`)
**Review type:** Second review of PR #1174 (R4 re-audit after remediation cycle 2), `review_mode: concurrent`. Prior review artifacts: `policy-audit.2026-11-13T17-44.md`, `code-review.2026-11-13T17-44.md`, `feature-audit.2026-11-13T17-44.md`.
**Code Under Test:** `eb73f1dff..762a9c9e1`, 85 files: two modified gate files and their two bundle copies, two new sibling hook files in four byte-identical copies each, six execution-environment brief copies, two orchestrate skill copies, two pack manifests, nine new Pester files, and feature-folder records and evidence.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 modified gate files and 2 new siblings (plus 6 byte-identical bundle copies); 9 new test files | 22952 testcases | 22942 passed, 0 failed, 10 skipped | 95.80% lines repo-wide (37558 of 39203, Phase 0) | 95.86% lines repo-wide (38934 of 40614) | 98.96% lines lowest new file (95 of 96); 100.00% of changed gate lines |
| Python | 0 files | 130 contract tests | 130 passed, 0 failed | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern; Pester measures no branch figure, so no branch threshold applies to PowerShell. Spec AC-22 sets a stricter 90% line figure for the four new sibling copies, which they meet. Python, TypeScript, C#, and Bash have zero changed files.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester-gate.2026-11-10T04-19.md` (95.80% repo-wide lines, 37558 of 39203).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-13 19:42 UTC by the single post-merge parallel gate run recorded in `evidence/qa-gates/pester-gate.2026-11-13T19-43.md`. The reviewer parsed its counters: root LINE 38934 of 40614 (95.86%); `.claude/hooks` and `.codex/hooks` commands sibling 95 of 96 each; bookkeeping sibling 78 of 78 each; Claude gate 162 of 168; Codex gate 178 of 178. Every figure equals the evidence file.
- Python baseline coverage artifact: N/A - zero changed Python files.
- Python post-change coverage artifact: N/A - zero changed Python files.
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: the gate ran on merge head `ef082f4fa`; the only later commit, `762a9c9e1`, adds two feature-folder Markdown evidence files, so the figures describe the head's production files. The worktree was clean at review start.

---

## Executive Summary

The branch adds a stage-2 confirmation to `Test-ImplementationCommand` on the Claude and Codex gates and a bookkeeping staging leg for `.claude/agent-memory/` paths. Remediation cycle 2 added decision D16 (pipeline consumers): a stage-1 hit is confirmed when a later stage of the same pipeline that does not carry the governed word is not an accepted consumer. `NotHost` is now read, and `sort --compress-program` is an executing option.

Re-verification of F1: all seven F1 probe commands and the N1 form are classified at head on both surfaces, as at the merge base, and FP-01 to FP-17 remain unclassified on both surfaces. Recorded gates are clean: format and analyzer 0 findings, one parallel Pester run with 22952 tests and 0 failures on the merged head, leak scan 0 failures, seven contract files 130 passed, generator check exit 0.

One new blocking finding (F2, related to issue #1160, autonomous, design scope). The D16 Posix consumer walk stops at any same-depth delimiter other than `|`. The shared parser closes a subshell group, a brace group, or a process substitution with a `)`, `;`, or `(` delimiter at the same depth. So a pipeline that passes through `( ... )`, `{ ...; }`, `<( ... )`, or `>( ... )` is not followed. Sixteen reviewer-probed real invocations are classified by the merge-base gate and not at head, identically on both surfaces. Examples: `(echo pytest) | xargs env`, `{ echo pytest; } | xargs env`, `cat <(echo pytest) | xargs env`, `xargs env < <(echo pytest)`, and `echo pytest > >(xargs env)`. Detail in `code-review.2026-11-13T19-53.md`.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on `main`; no new project folder is added, so no tier entry is owed)
- ✅ `.claude/rules/tonality.md`
- ✅ `.claude/rules/powershell.md`
- ✅ Hook-path language rule (no Python in the hook path): no `.py` file added; no `python` token in the four sibling copies

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md` (gate files, siblings, test files)
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --porcelain` at head was empty before the reviewer's checks.
- ✅ Reviewer probes ran from launchers in the session scratchpad against the worktree hooks and a `git archive` copy of the merge-base hooks; the only worktree writes are the regenerated (gitignored) PR context files and these review artifacts.

---

## Rejected Scope Narrowing

The caller prompt names the whole branch diff from the merge base of `origin/main` and `HEAD`, `spec.md` as the AC source, and the newest gate evidence files. The instruction to read gate results from the evidence and not re-run format, lint, or tests limits re-execution, not scope. The instruction that only findings related to issue #1160 block, with unrelated findings reported separately, is the repository's remediation policy and does not narrow the audit. No statement narrows the audit to a plan, task, phase, subset of files, or language.

---

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `validate_evidence_locations.py --root <item worktree>` exited 0 with no reported path. Evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, `qa-gates/`, `regression-testing/`, and `remediation-baseline/`. The AC-22 location override (`evidence/coverage/` replaced with `evidence/qa-gates/`) recorded in the first review stands.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Data-driven rows; each `It` loads its own sibling copy; all suites passed inside 8 parallel shards. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One corpus row or one function case per `It`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pure string logic behind mocked seams. |
| **Determinism** - Consistent results | ✅ PASS | Both I/O seams mocked wherever the leg is reached; no clock or randomness. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Corpus in one data file with FP, ED, and NG identifiers; D16 cases grouped in one Context. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester-gate.2026-11-10T04-19.md`; cycle baseline `evidence/remediation-baseline/baseline-reference.2026-11-13T18-34.md`. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 95.80% (Phase 0) to 95.86%; commands sibling 98.68% to 98.96%. |
| **New Code Coverage** | ✅ PASS | Commands sibling 98.96% (both copies), bookkeeping sibling 100.00% (both copies). |
| **Modified Files** | ✅ PASS | Claude gate 96.43%, Codex gate 100.00%; changed gate lines unchanged since the first review and covered. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | ED-43 to ED-50 and 17 D16 cases cover `|`-joined pipelines; no row covers a pipeline through a group or a process substitution; see F2. |
| **Positive Flows** - Valid inputs | ✅ PASS | FP rows and agent-memory allow rows on both surfaces. |
| **Negative Flows** - Invalid inputs | ✅ PASS | ED rows; D16 confirm cases; leg deny rows. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `;` boundary, nested payload skip, wrapper nesting, NotHost precedence, PowerShell expression consumers. |
| **Error Handling** - Error paths | ✅ PASS | Fail-closed fallbacks; invalid configuration suffix. |
| **Concurrency** - If applicable | N/A | Stateless hook decision. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% repo-wide lines (37558 of 39203) -> Post-change: 95.86% repo-wide lines (38934 of 40614). Change: +0.06 points. New/changed-code coverage: 98.96% (commands sibling, both copies), 100.00% (bookkeeping sibling, both copies), 100.00% of the 20 executable lines added in cycle 2. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-comparison.2026-11-13T19-19.md`, `evidence/qa-gates/pester-gate.2026-11-13T19-43.md`.
- Python: zero changed files; no comparison is owed.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Row identifiers in `It` names; D16 case names state the boundary they pin. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange, Act, Assert in the unit and leg suites. |
| **Document Intent** | ✅ PASS | Suite headers cite D2, D5, D14, D15, and D16. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No git, filesystem, or process call in the new suites. |
| **Use Mocks/Stubs** | ✅ PASS | `Mock Get-OrchestrationGateStagedIndex`, `Mock Get-OrchestrationGateBookkeepingConfigText`. |
| **Environment Stability** | ✅ PASS | Leak scan on the merged head: 771 files, 0 failures (`evidence/qa-gates/pester-gate.2026-11-13T19-43.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-13T19-22.md`; this audit with `code-review.2026-11-13T19-53.md` and `feature-audit.2026-11-13T19-53.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1160; spec decisions D1 to D16. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-13T18-24.md`; task checks under `evidence/other/`. |
| **Document the plan** | ✅ PASS | D16 recorded in `spec.md` before implementation. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | D16 adds one consumer loop and one helper (`Test-OrchestrationGateMentionHostRecord`) shared by rule 3 and rule 5. |
| **Reusability** | ✅ PASS | One host-record helper serves both rules. |
| **Extensibility** | ✅ PASS | Host table remains data behind a getter. |
| **Separation of concerns** | ✅ PASS | Pure classification; I/O only in the bookkeeping seams. |
| **Correctness of the classification rule** | ❌ FAIL | F2: the Posix consumer walk does not follow a pipeline through a group or process substitution. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Commands sibling: classification only; bookkeeping sibling: configuration and leg only. |
| **At or below the 800-line hard limit** | ✅ PASS | Reviewer logical-line counts: Codex gate 499, Claude gate 485, commands unit suite 361, bookkeeping sibling 290, commands sibling 263; none at 700 or above. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | `$script:SharedGateFunction` unchanged; new functions live in the siblings. |
| **No circular dependencies** | ✅ PASS | Siblings call shared helpers at call time. |
| **Project classification (tiers)** | ✅ PASS | No new project folder. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Test-OrchestrationGateMentionHostRecord`, `Test-OrchestrationGateInvocationConfirmed`. |
| **Docs/docstrings** | ✅ PASS | Header rules 1 to 5 and comment-based help describe D16. |
| **Comment why, not what** | ✅ PASS | The consumer loop comment states the D16 rationale and depth handling. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Non-writing `Invoke-Formatter` comparison: 0 differences over 6 changed files (`evidence/qa-gates/powershell-static.2026-11-13T19-19.md`). |
| **2. Linting** | ✅ PASS | PSScriptAnalyzer 0 findings; leak scan 0 failures. |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Testing** | ✅ PASS | Pester 22952 tests, 0 failed on the merged head (`evidence/qa-gates/pester-gate.2026-11-13T19-43.md`); contract tests 130 passed (`evidence/qa-gates/contract-tests.2026-11-13T19-28.md`). |
| **Full toolchain loop** | ✅ PASS | Clean static pass, clean parallel test pass, and fail-before evidence for the 66 expected D16 tests. |
| **Explicit reporting** | ✅ PASS | Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Sibling header, brief bullet, orchestrate paragraph. |
| **Design choices explained** | ✅ PASS | D16 states the rule, the accepted consumers, the table changes, the rationale, and the cost. |
| **Update supporting documents** | ✅ PASS | Six brief copies share one SHA256 (`evidence/qa-gates/parity-and-scope.2026-11-13T19-19.md`). |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python file changed or added. No `python` token in the four sibling copies.

### Section 3B: PowerShell Code Change Policy Compliance

Advanced functions with `CmdletBinding` and `OutputType`; approved verbs; ordinal string comparisons; no `StrictMode` or preference assignment in the dot-sourced siblings (justified in the headers). Formatter and analyzer clean.

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test changed. Seven push-down and brief contract files pass (130 tests).

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | `Describe`/`Context`/`It`, `-ForEach`, `Should -Invoke`. |
| **Use PoshQC Configuration** | ✅ PASS | One `Invoke-PoshQCParallelTest` run per gate. |
| **Focused Unit Tests** | ✅ PASS | One row or case per `It`. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`. |
| **Mock the wrapper, not the executable** | ✅ PASS | Staged-index and configuration readers mocked at their wrappers. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Classification corpus, both surfaces | `Classification.Tests.ps1`, `-classification.Tests.ps1` | FP-01 to FP-17 allow, ED-01 to ED-50 deny with byte-equal text, NG rows unclassified | ⚠️ no group or process-substitution pipeline row (F2) |
| Stage-2 function, host table, D16 | `-commands.Tests.ps1` | Table pin, fallbacks, 15 D16 confirm cases, 5 guard cases, stage-1-miss | ✅ |
| Configuration and leg unit | `-bookkeeping.Tests.ps1` | Parser rules, seam path, anchor, selector | ✅ |
| Decision-level leg, both surfaces | `.BookkeepingLeg.Tests.ps1`, `-bookkeeping-leg.Tests.ps1` | AC-6, D14, AC-8 rows, suffix ordering | ✅ |
| Four-copy parity | `-commands.Parity.Tests.ps1`, `-bookkeeping.Parity.Tests.ps1` | SHA256 identity, fewer than 500 lines | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester (post-merge gate) | 22952 testcases, 0 failed, 10 skipped | ✅ |
| Fail-before (cycle 2, unfixed sibling) | 66 failures, exactly the expected D16 set | ✅ |
| Contract tests (pytest, seven files) | 130 passed | ✅ |
| Reviewer F1 re-probe, head versus merge base, both surfaces | 7 F1 forms and N1 classified at head and base | ✅ |
| Reviewer FP re-probe, both surfaces | FP-01 to FP-17 unclassified at head | ✅ |
| Reviewer adversarial probes, head versus merge base, both surfaces | 122 commands; Claude and Codex identical on all; 16 real invocations classified at base and unclassified at head | ❌ (F2) |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format and analyzer | static artifact 2026-11-13T19-19 | 0 format differences, 0 findings over 6 files | ✅ |
| Codex generator check | `generate_codex_agent_variants --check` (executor) | Exit 0 | ✅ |
| Sibling four-copy identity | reviewer `sha256sum` | One digest (`e32ac31e98c618d9...`) for the commands sibling | ✅ |
| Protected files | reviewer `git diff --name-only <merge base> HEAD` over the spec's protected list | 0 paths | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <item worktree>` (reviewer) | Exit 0 | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC shard 1`, `shard 2`, `shard 3` | pass | 22952 testcases, 0 failed, 95.86% lines | `762a9c9e1` | `evidence/qa-gates/pester-gate.2026-11-13T19-43.md`; CI run 43494990169 pending |
| `poshqc / PowerShell hook suites (Linux)` | pass | gate and sibling suites 0 failed | `762a9c9e1` | `evidence/qa-gates/pester-gate.2026-11-13T19-43.md`; CI run 43494990169 pending |
| `poshqc / PowerShell QC static` | pass | 0 analyzer findings, 0 format differences | `762a9c9e1` | `evidence/qa-gates/powershell-static.2026-11-13T19-19.md`; CI run 43494990169 pending |
| `quality-checks7 / Code Quality & Tests (3.11, 3.12, 3.13)` | pass | contract files 130 passed | `762a9c9e1` | `evidence/qa-gates/contract-tests.2026-11-13T19-28.md`; CI run 43494990169 pending |

CI run 43494990169 was in progress at head `762a9c9e1` at 19:53 UTC, so every row is recorded as pending in CI. The outcome column records the local evidence. No finding depends on a pending CI result, so none is classified `awaiting_ci`.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. F2 (blocking, related to issue #1160, autonomous, design scope): the D16 Posix consumer walk does not follow a pipeline through a subshell group, a brace group, or a process substitution.
2. Non-blocking items are recorded in the code review (N1 to N4).
3. No finding unrelated to issue #1160 was identified.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None removed.** Skipped count equals the baseline (10).

---

## 9. Summary of Changes

Stage-2 confirmation in `Test-ImplementationCommand` (decisions D2 and D16) and a bookkeeping staging leg on both gates; two new siblings in four copies each; both gate bundle copies; both `core.json` manifests; six brief copies; two orchestrate copies; nine new Pester files; feature-folder records and evidence. Cycle 2 changed `spec.md`, the four commands sibling copies, the corpus data file, the commands unit suite, and the six brief copies.

---

## 10. Compliance Verdict

### Overall Status: ❌ REMEDIATION REQUIRED

F1 is resolved. One new blocking finding (F2). All toolchain, coverage, parity, and contract checks pass. AC-24 (CI green on the PR head) is pending CI and is not a finding.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ❌ Correctness of the stage-2 classification rule (F2); structure, parity, size, and documentation pass

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell

#### General Unit Test Policy (Section 1)
- ✅ Coverage and baseline comparison
- ⚠️ Scenario completeness: no corpus row for a pipeline through a group or process substitution (F2)

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 0 failures in Pester (22952) and contract tests (130)
- ✅ PowerShell 95.86% repo-wide lines, above the 95.80% Phase 0 figure; new siblings 98.96% and 100.00%
- ✅ Four-copy identity, protected files unchanged, generator check exit 0

### Recommendation

Remediate F2 through a recorded spec decision (D17) that extends the D16 Posix consumer walk across group and process-substitution delimiters in both directions, with corpus rows on both surfaces and named cases in the commands suite. Then re-review. Check off AC-24 at S9.

---

## Appendix A: Test Inventory

New: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (data), `.Classification.Tests.ps1`, `-commands.Tests.ps1`, `-commands.Parity.Tests.ps1`, `-bookkeeping.Tests.ps1`, `-bookkeeping.Parity.Tests.ps1`, `.BookkeepingLeg.Tests.ps1`; `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1`, `-bookkeeping-leg.Tests.ps1`. No existing test file is modified.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <item worktree> fetch origin main
git -C <item worktree> merge-base origin/main HEAD
git -C <item worktree> merge-tree --write-tree origin/main HEAD
git -C <item worktree> diff --stat <merge base>..HEAD
git -C <item worktree> archive <merge base> .claude/hooks .claude/lib .codex/hooks   # merge-base copy for probes
poetry -C <item worktree> run python -m scripts.dev_tools.pr_context.collector --base origin/main ...
sh <scratchpad>/run.sh <case list>   # Test-ImplementationCommand: head Claude, head Codex, base Claude, base Codex
sha256sum <four commands sibling copies>
poetry -C <item worktree> run python scripts/dev_tools/validate_evidence_locations.py --root <item worktree>
gh run view 43494990169
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-13
**Policy Version:** Current (as of audit date)
