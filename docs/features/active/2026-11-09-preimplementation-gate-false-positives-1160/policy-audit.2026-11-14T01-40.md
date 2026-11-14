# Policy Compliance Audit: Pre-Implementation Gate False Positives (Issue #1160), Re-audit After Remediation Cycle 3

**Audit Date:** 2026-11-14
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `25cc3ffce7b3ab58c716b724451ca395fe9e4425` (PR #1174)
**Base:** `main`; merge base `eb73f1dff52e7175228a03740b53281c81e1c00c` (`git merge-base origin/main HEAD` after `git fetch origin main`). `git merge-tree --write-tree origin/main HEAD` exits 0. The PR context artifacts were stale (head `762a9c9e1`) and were regenerated for head `25cc3ffce` against `origin/main @ eb73f1dff`.
**Work Mode:** full-bug (AC source: `spec.md`)
**Review type:** Third review of PR #1174 (re-audit after remediation cycle 3), `review_mode: concurrent`. Prior review artifacts: `*.2026-11-13T17-44.md` (F1, resolved) and `*.2026-11-13T19-53.md` (F2). Cycle 3 inputs: `remediation-inputs.2026-11-13T19-53.md` and `remediation-inputs.2026-11-14T00-18.md`; plan executed: `remediation-plan.2026-11-13T19-53.md`.
**Review standard:** owner directive OD-1 (class `scope_narrowing`) and spec decision D18. Stage 2 is judged at the policy level: an ordinary, non-obfuscated real invocation that stage 2 declassifies is a blocking defect; a construct that is only a further obfuscation variant is recorded as a non-blocking note with the disposition "out of scope under OD-1 / D18".
**Code Under Test:** `eb73f1dff..25cc3ffce`, 123 files: two modified gate files and their two bundle copies, two new sibling hook files in four byte-identical copies each, six execution-environment brief copies, two orchestrate skill copies, two pack manifests, ten new Pester files, one promoted potential record, and feature-folder records and evidence.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 2 modified gate files and 2 new siblings (plus 6 byte-identical bundle copies); 10 new test files | 23215 testcases | 23205 passed, 0 failed, 10 skipped | 95.80% lines repo-wide (37558 of 39203, Phase 0) | 95.88% lines repo-wide (39146 of 40828) | 99.01% lines lowest new file (201 of 203); changed gate lines at or above baseline |
| Python | 0 files | 130 contract tests | 130 passed, 0 failed | N/A - zero changed Python files | N/A - zero changed Python files | N/A |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern; Pester measures no branch figure, so no branch threshold applies to PowerShell. Spec AC-22 sets a stricter 90% line figure for the four new sibling copies, which they meet. Python, TypeScript, C#, and Bash have zero changed files.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/pester-gate.2026-11-10T04-19.md` (95.80% repo-wide lines, 37558 of 39203).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-14 01:28 UTC by the single parallel gate run recorded in `evidence/qa-gates/pester-gate.2026-11-14T01-28.md`. The reviewer parsed its counters: root LINE 39146 of 40828 (95.88%); `.claude/hooks` and `.codex/hooks` commands sibling 201 of 203 each (99.01%); bookkeeping sibling 78 of 78 each; Claude gate 162 of 168 (96.43%); Codex gate 178 of 178. Every figure equals `evidence/qa-gates/coverage-comparison.2026-11-14T01-33.md`.
- Python baseline coverage artifact: N/A - zero changed Python files.
- Python post-change coverage artifact: N/A - zero changed Python files.
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: the production change of cycle 3 is commit `eba32a2dd` (committed 01:01 UTC); the gate run started at 01:18 UTC, and every later commit adds feature-folder Markdown only, so the figures describe the head's production files. The worktree was clean at review start.

---

## Executive Summary

The branch adds a stage-2 confirmation to `Test-ImplementationCommand` on the Claude and Codex gates and a bookkeeping staging leg for `.claude/agent-memory/` paths. Remediation cycle 3 added decision D17, a closed modelled-command rule: a stage-1 hit is dropped only when the whole command consists of allowlisted constructs, every carrying record is a mention-host operand, and every pipeline mate before or after the carrier is an accepted consumer. It also added `--hostname-bin` to the `rg` executing options, the `git` short-option bundle check for `O`, the `$_` clause at every payload depth, and decision D18 (deliberately obfuscated commands are a non-goal, per OD-1).

Re-verification of F2: the reviewer re-ran the sixteen F2 forms, ED-94 to ED-96, and FP-01 to FP-17 through `Test-ImplementationCommand` on both surfaces. All F2 forms and ED-94 to ED-96 are classified at head; FP-01 to FP-17 stay unclassified. F2 is resolved. Recorded gates are clean: format and analyzer 0 findings over 7 files, one parallel Pester run with 23215 tests and 0 failures, leak scan 0 failures, seven contract files 130 passed, generator check exit 0.

One blocking finding (F3, related to issue #1160, autonomous, contained scope). `Test-OrchestrationGateMentionHostRecord` selects the subcommand of a subcommand-scoped host (`git`, `npm`, `pip`, `pip3`, `poetry`) as the first token after the command word that does not start with `-`. The value of a value-taking global option is therefore read as the subcommand. When that value equals a host subcommand name, an ordinary runner invocation is declassified: `npm -w search run lint`, `npm --prefix search run lint`, `poetry -C search run pytest`, and `poetry --directory search run pytest` are classified at the merge base and unclassified at head on both surfaces. These are plain, non-obfuscated forms of the workspace and directory options, so the OD-1 standard makes this a defect. The mechanism has been present since cycle 1; earlier reviews recorded only its conservative direction (`git -C . log --grep pytest` stays classified). Detail in `code-review.2026-11-14T01-40.md`.

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
- ✅ Reviewer probes ran from launchers in the session scratchpad against the worktree hooks; the merge-base decision was reproduced by replacing the stage-2 function with one that always confirms, which equals the merge-base `Test-ImplementationCommand` because stage 1 is unchanged. The only worktree writes are the regenerated (gitignored) PR context files, the owner-directive decision file, and these review artifacts.

---

## Rejected Scope Narrowing

The caller prompt names the whole branch diff from the merge base and `spec.md` as the AC source. Owner directive OD-1 narrows the standard used to judge stage-2 findings (obfuscation-only variants are non-blocking), which is recorded spec decision D18; it does not narrow the audited files, languages, or checks. No statement narrows the audit to a plan, task, phase, subset of files, or language, so no narrowing was rejected.

---

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `validate_evidence_locations.py --root <item worktree>` exited 0 with no reported path. Evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, `qa-gates/`, `regression-testing/`, and `remediation-baseline/`. The AC-22 location override (`evidence/coverage/` replaced with `evidence/qa-gates/`) recorded in the first review stands. Cycle 3 added files only; no earlier evidence file was modified or deleted (`git diff --name-status 762a9c9e1..HEAD -- docs` shows only additions and the `spec.md` edit). The executor disclosed thirteen filename stamps that differ from the write minute by one minute (`evidence/other/evidence-stamp-disclosure.2026-11-14T01-36.md`); the disclosure is accurate in kind, no content depends on the stamps, and the append-only rule was kept, so it is recorded as a non-blocking note.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Data-driven rows; each `It` loads its own sibling copy; all suites passed inside 8 parallel shards. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One corpus row or one function case per `It`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Pure string and AST logic behind mocked seams. |
| **Determinism** - Consistent results | ✅ PASS | Both I/O seams mocked wherever the leg is reached; the PowerShell parser is called with `ParseInput` and never executes. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Corpus in one data file with FP, ED, and NG identifiers; D17 cases in a separate `Modelled` suite. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | `evidence/baseline/pester-gate.2026-11-10T04-19.md`; cycle baseline `evidence/remediation-baseline/baseline-reference.2026-11-14T00-38.md`. |
| **No Coverage Regression** | ✅ PASS | Repo-wide 95.80% (Phase 0) to 95.88%; commands sibling 98.96% to 99.01%; gate files unchanged in figure. |
| **New Code Coverage** | ✅ PASS | Commands sibling 99.01% (both copies), bookkeeping sibling 100.00% (both copies). |
| **Modified Files** | ✅ PASS | Claude gate 96.43%, Codex gate 100.00%; gate files unchanged in cycle 3. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | ED-51 to ED-96 and 39 D17 cases cover the construct classes; no row covers a value-taking global option before the subcommand of a subcommand-scoped host; see F3. |
| **Positive Flows** - Valid inputs | ✅ PASS | FP rows, three D17 guards, and agent-memory allow rows on both surfaces. |
| **Negative Flows** - Invalid inputs | ✅ PASS | ED rows; D16 and D17 confirm cases; leg deny rows. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `$_` at depth 0 versus payload depth, `-CommandWithArgs` trailing words, abbreviation of executing options, scriptblock bodies of hosts. |
| **Error Handling** - Error paths | ✅ PASS | Fail-closed fallbacks; parse errors unmodelled; invalid configuration suffix. |
| **Concurrency** - If applicable | N/A | Stateless hook decision. |
| **State Transitions** - If applicable | N/A | No stateful component. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.80% repo-wide lines (37558 of 39203) -> Post-change: 95.88% repo-wide lines (39146 of 40828). Change: +0.08 points. New/changed-code coverage: 99.01% (commands sibling, both copies, 201 of 203), 100.00% (bookkeeping sibling, both copies), 106 of 107 lines added by D17 covered. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-comparison.2026-11-14T01-33.md`, `evidence/qa-gates/pester-gate.2026-11-14T01-28.md`.
- Python: zero changed files; no comparison is owed.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Row identifiers and construct names in `It` names. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Arrange, Act, Assert in the unit and leg suites. |
| **Document Intent** | ✅ PASS | Suite headers cite D2, D5, D14, D15, D16, and D17. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No git, filesystem, or process call in the new suites. |
| **Use Mocks/Stubs** | ✅ PASS | `Mock Get-OrchestrationGateStagedIndex`, `Mock Get-OrchestrationGateBookkeepingConfigText`. |
| **Environment Stability** | ✅ PASS | Leak scan: 772 files, 0 failures, with a non-vacuous per-file control (`evidence/qa-gates/leak-scan.2026-11-14T01-31.md`). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | Executor self-review `evidence/qa-gates/self-review.2026-11-14T01-35.md`; this audit with `code-review.2026-11-14T01-40.md` and `feature-audit.2026-11-14T01-40.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #1160; spec decisions D1 to D18. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-13T19-53.md`; task checks under `evidence/other/`. |
| **Document the plan** | ✅ PASS | D17 and D18 recorded in `spec.md` before implementation (commit order P1 then P2). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | D17 is an allowlist of constructs; anything outside it keeps the hit, which removes the need to enumerate executing shapes. |
| **Reusability** | ✅ PASS | `Test-OrchestrationGateAcceptedConsumer` serves the forward and backward walks. |
| **Extensibility** | ✅ PASS | Host table remains data behind a getter. |
| **Separation of concerns** | ✅ PASS | Pure classification; I/O only in the bookkeeping seams. |
| **Correctness of the classification rule** | ❌ FAIL | F3: subcommand selection reads the value of a value-taking global option as the subcommand. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Commands sibling: classification only; bookkeeping sibling: configuration and leg only. |
| **At or below the 800-line hard limit** | ✅ PASS | Reviewer logical-line counts (`@(Get-Content).Count`): Codex gate 499, commands sibling 489, Claude gate 485, commands unit suite 361, bookkeeping sibling 290; none at 700 or above. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | `$script:SharedGateFunction` unchanged; new functions live in the siblings. |
| **No circular dependencies** | ✅ PASS | Siblings call shared helpers at call time. |
| **Project classification (tiers)** | ✅ PASS | No new project folder. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Test-OrchestrationGateCommandModelled`, `Test-OrchestrationGatePosixTextModelled`, `Test-OrchestrationGatePowerShellPayloadModelled`, `Test-OrchestrationGateAcceptedConsumer`. |
| **Docs/docstrings** | ✅ PASS | Header rules 1 to 6, comment-based help per function, and the D18 sentence. |
| **Comment why, not what** | ✅ PASS | Walk comments state the D16 and D17 rationale. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Non-writing `Invoke-Formatter` comparison: 0 differences over 7 files (`evidence/qa-gates/powershell-static.2026-11-14T01-17.md`). |
| **2. Linting** | ✅ PASS | PSScriptAnalyzer 0 findings; leak scan 0 failures. |
| **3. Type checking** | N/A | Not applicable to PowerShell. |
| **4. Testing** | ✅ PASS | Pester 23215 tests, 0 failed (`evidence/qa-gates/pester-gate.2026-11-14T01-28.md`); contract tests 130 passed (`evidence/qa-gates/contract-tests.2026-11-14T01-32.md`). |
| **Full toolchain loop** | ✅ PASS | Clean static pass, clean parallel test pass, and fail-before evidence for exactly the 256 expected D17 tests (`evidence/regression-testing/fail-before-modelled-command.2026-11-14T00-57.md`). |
| **Explicit reporting** | ✅ PASS | Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Sibling header, brief bullet, orchestrate paragraph. |
| **Design choices explained** | ✅ PASS | D17 states the conditions, both allowlists, the bound and cost, N1, and the FP analysis; D18 states the non-goal. |
| **Update supporting documents** | ✅ PASS | Six brief copies share one SHA256 (`4dd9db4baf9a...`), each carrying the D18 sentence once. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python file changed or added. No `python` token in the four sibling copies.

### Section 3B: PowerShell Code Change Policy Compliance

Advanced functions with `CmdletBinding` and `OutputType`; approved verbs; ordinal string comparisons; no `StrictMode` or preference assignment in the dot-sourced siblings (justified in the headers); the AST is obtained with `Parser::ParseInput`, which does not execute. Formatter and analyzer clean.

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
| Classification corpus, both surfaces | `Classification.Tests.ps1`, `-classification.Tests.ps1` | FP-01 to FP-17 allow, ED-01 to ED-96 deny with byte-equal text, NG-01 to NG-09 unclassified | ⚠️ no row with a value-taking global option before a host subcommand (F3) |
| Stage-2 function and host table | `-commands.Tests.ps1` | Table pin (with `--hostname-bin`), fallbacks, D16 cases, stage-1-miss | ✅ |
| D17 modelled-command rule | `-commands.Modelled.Tests.ps1` | 36 classified cases and 3 guards per surface | ✅ |
| Configuration and leg unit | `-bookkeeping.Tests.ps1` | Parser rules, seam path, anchor, selector | ✅ |
| Decision-level leg, both surfaces | `.BookkeepingLeg.Tests.ps1`, `-bookkeeping-leg.Tests.ps1` | AC-6, D14, AC-8 rows, suffix ordering | ✅ |
| Four-copy parity | `-commands.Parity.Tests.ps1`, `-bookkeeping.Parity.Tests.ps1` | SHA256 identity, fewer than 500 lines | ✅ |

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester (final gate) | 23215 testcases, 0 failed, 10 skipped | ✅ |
| Fail-before (cycle 3, unfixed sibling) | 256 failures, exactly the expected D17 set | ✅ |
| Contract tests (pytest, seven files) | 130 passed | ✅ |
| Reviewer F2 re-probe, both surfaces | 16 F2 forms and ED-94 to ED-96 classified at head | ✅ |
| Reviewer FP re-probe, both surfaces | FP-01 to FP-17 unclassified at head | ✅ |
| Reviewer ordinary-invocation probes, head versus merge-base decision, both surfaces | 62 commands; Claude and Codex identical on all; 12 runner invocations with a value-taking global option classified at base and unclassified at head | ❌ (F3) |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format and analyzer | static artifact 2026-11-14T01-17 | 0 format differences, 0 findings over 7 files | ✅ |
| Codex generator check | `generate_codex_agent_variants --check` (executor) | Exit 0 | ✅ |
| Sibling four-copy identity | reviewer `sha256sum` | One digest (`c39100dc8993f104...`) for the commands sibling, one (`55e6e9200b258924...`) for the bookkeeping sibling | ✅ |
| Gate bundle identity | reviewer `sha256sum` | Claude gate and bundle `dac488c00aa99b79...`; Codex gate and bundle `b18c92f4e4be8881...` | ✅ |
| D18 sentence | reviewer `grep -cF` | 1 occurrence in each of the four sibling copies and the six brief copies | ✅ |
| Protected files | reviewer `git diff --name-status <merge base>..HEAD` over the spec's protected list | 0 paths | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <item worktree>` (reviewer) | Exit 0 | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC` | pass | 23215 testcases, 0 failed, 95.88% lines | `25cc3ffce` | `evidence/qa-gates/pester-gate.2026-11-14T01-28.md`; CI queued at review time |
| `poshqc / PowerShell QC static` | pass | 0 analyzer findings, 0 format differences | `25cc3ffce` | `evidence/qa-gates/powershell-static.2026-11-14T01-17.md`; CI job skipped at review time |
| `quality-checks7 / Code Quality & Tests (3.11, 3.12, 3.13)` | pass | contract files 130 passed | `25cc3ffce` | `evidence/qa-gates/contract-tests.2026-11-14T01-32.md`; CI queued at review time |

At review time `gh pr view 1174` showed head `25cc3ffce`, `MERGEABLE`, `Change scope` and `docs-validation` passed, and the test jobs queued. The outcome column records the local evidence. No finding depends on a pending CI result, so none is classified `awaiting_ci`.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. F3 (blocking, related to issue #1160, autonomous, contained scope): subcommand-scoped hosts read the value of a value-taking global option as the subcommand, which declassifies ordinary invocations such as `npm -w search run lint` and `poetry -C search run pytest`.
2. Non-blocking items are recorded in the code review (N1 to N5), including two notes dispositioned out of scope under OD-1 / D18.
3. No finding unrelated to issue #1160 was identified.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None removed.** Skipped count equals the baseline (10).

---

## 9. Summary of Changes

Stage-2 confirmation in `Test-ImplementationCommand` (decisions D2, D16, and D17) and a bookkeeping staging leg on both gates; two new siblings in four copies each; both gate bundle copies; both `core.json` manifests; six brief copies; two orchestrate copies; ten new Pester files; feature-folder records and evidence. Cycle 3 changed `spec.md` (D17, D18), the four commands sibling copies, the corpus data file (ED-51 to ED-96), the commands unit suite (one assertion), the new `Modelled` suite, and the six brief copies.

---

## 10. Compliance Verdict

### Overall Status: ❌ REMEDIATION REQUIRED

F2 is resolved. One blocking finding (F3). All toolchain, coverage, parity, documentation, and contract checks pass. AC-24 (CI green on the PR head) is pending CI and is not a finding.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ❌ Correctness of the stage-2 classification rule (F3); structure, parity, size, and documentation pass

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell

#### General Unit Test Policy (Section 1)
- ✅ Coverage and baseline comparison
- ⚠️ Scenario completeness: no corpus row for a value-taking global option before a host subcommand (F3)

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 0 failures in Pester (23215) and contract tests (130)
- ✅ PowerShell 95.88% repo-wide lines, above the 95.80% Phase 0 figure; new siblings 99.01% and 100.00%
- ✅ Four-copy identity, protected files unchanged, generator check exit 0

### Recommendation

Remediate F3 through a recorded spec decision (D19) under which a subcommand-scoped host is a host only when its listed subcommand is the first token after the command word, so any option before the subcommand keeps the hit. Add ED rows for the probe forms on both runners and a named case in the commands suite, with fail-before evidence. Then re-review. Check off AC-24 at S9.

---

## Appendix A: Test Inventory

New: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (data), `.Classification.Tests.ps1`, `-commands.Tests.ps1`, `-commands.Modelled.Tests.ps1`, `-commands.Parity.Tests.ps1`, `-bookkeeping.Tests.ps1`, `-bookkeeping.Parity.Tests.ps1`, `.BookkeepingLeg.Tests.ps1`; `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1`, `-bookkeeping-leg.Tests.ps1`. No existing test file is modified.

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <item worktree> fetch origin main
git -C <item worktree> merge-base origin/main HEAD
git -C <item worktree> merge-tree --write-tree origin/main HEAD
git -C <item worktree> diff --name-status <merge base>..HEAD
poetry -C <item worktree> run python -m scripts.dev_tools.pr_context.collector --base origin/main --repo-root <item worktree> ...
sh <scratchpad>/run.sh <case list>   # Test-ImplementationCommand at head, and with stage 2 forced to confirm (merge-base decision), both surfaces
sh <scratchpad>/cov.sh               # coverage counters and logical line counts
sha256sum <four sibling copies, gate and bundle copies, six brief copies>
poetry -C <main checkout> run python <item worktree>/scripts/dev_tools/validate_evidence_locations.py --root <item worktree>
gh pr view 1174 --json headRefOid,mergeable,statusCheckRollup
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-14
**Policy Version:** Current (as of audit date)
