# Policy Compliance Audit: docs-enforcement-and-ci (#1034)

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after remediation cycle 3. Previous review set: artifacts stamped `2026-11-07T04-16`.
**Code Under Test:** `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/hooks/enforce-docs-complete-gate-target.ps1`, `.claude/lib/docs/DocsCompleteGate.psm1`, `.claude/lib/docs/DocsSurfaceDelta.psm1`, `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1`, `.claude/lib/docs/Invoke-DocsCommand.ps1`, `.claude/lib/docs/DocsProfileCommands.psm1`, `.claude/lib/docs/templates/_docs-quality.yml`, their bundle copies, `.claude/settings.json`, `core.json`, four `feature-review` surfaces with bundle copies, and twelve test files.

**Scope:** full branch diff, `origin/epic/documentation-estate-tooling-integration` at merge base `e1f4d2e54dd877929f28fd5496231304d3c5308f` to head `abb854f5346caa1d1c4054e508c90ba840bbe70e` (151 commits, 183 files, 13308 insertions, 193 deletions; 39 files outside the feature folder). `artifacts/pr_context.summary.txt` records this head and range. The merge base now equals the epic tip.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 26 files (7 production, 7 bundle copies, 12 test) | 17177 tests (merged parallel run) | PASS 17167 pass, 0 fail, 10 disabled | 95.26% lines | 95.30% lines | 98.25% |
| JSON | 4 files | N/A | PASS validation by contract suites | N/A (config files) | N/A (config files) | N/A |

Python, TypeScript, C# and Bash have zero changed files against the merge base, so no coverage verdict applies to them. The Python files that arrived through the integration merge are upstream and are outside this diff.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/policy-audit.2026-11-07T04-16.md` (merged full run before this cycle), `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/remediation-baseline/pester-coverage.2026-11-07T04-47.md` and `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/baseline/pester-coverage.2026-11-04T15-45.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are present for PowerShell, the only coverage language with changed files.

**Fail-closed rule:** every required baseline, QA and coverage artifact exists.

**Evidence rule:** figures were read from the named artifacts or from commands run in this review (Appendix B).

---

## Executive Summary

**Overall verdict: PARTIALLY COMPLIANT. Review-Verdict: REMEDIATION_REQUIRED (one autonomous finding).**

F4, F5, N12 and N14 are closed. The rows of those tables behave as required, the hook header now states its limits, and the branch is merged with the epic tip. Formatter 0 differences and analyzer 0 findings over 26 files, 17177 tests with 0 failures, repo-wide PowerShell line coverage 95.30%, helper line coverage 100.00%.

One finding remains, shown against real bash in `code-review.2026-11-07T05-55.md`:

- **F6 (Blocker).** The header and `spec.md` state that the hook denies the words `gh pr merge` or a `gh api` merge endpoint in the unquoted text. The view that test reads comes from the shared scanner, which has no comment state and does not nest quotes in a double-quoted substitution. An apostrophe or `<<` in a comment, `<<` in arithmetic, and nested double quotes each blank a merge line that bash runs. `# Merge once it's green<NL>gh pr merge 12 --merge<NL># Delete the branch now that it's merged<NL>git status` is allowed by a real hook process with the gate enabled and no receipt, and real bash passed `pr merge 12 --merge` to `gh`. This is not a regression; the same commands were allowed at the two earlier heads.

The caller's reading of the limit was tested, as recorded under `## Rejected Scope Narrowing`, and F6 lies outside it.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | The three gate suites passed 496 of 496 alone in a fresh process in a scratch copy, and inside shards of the merged run. Seeded shuffles were not run on this tree under the relayed parallel-only directive; the last shuffled runs predate cycle 2. |
| Isolation | PASS | Seams mock `gh`, file and root boundaries. The helper suite drives pure functions. |
| Fast execution | PASS | Merged run 566.3 s wall clock over 8 workers. |
| Determinism | PASS | No clock or wall-time use in the new rows. |
| Readability | PASS | Arrange, Act and Assert comments and row names that state the command and result. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | 95.26% repo-wide before the cycle (32531 covered, 1617 missed); 69.29% at the first merge base over three scan folders. |
| No Coverage Regression | PASS | Repo-wide covered lines rose by 257 and missed lines stayed at 1617; part of the rise comes from upstream suites and code in the merged tree. The hook stays 93.90% with the same five missed lines, the helper 100.00%, `Invoke-DocsCommand.ps1` 89.56% (from 89.44%), `DocsProfileCommands.psm1` 97.33%. |
| New Code Coverage at or above 85% | PASS | `enforce-docs-complete-gate.ps1` 93.90% (77/82), `enforce-docs-complete-gate-target.ps1` 100.00% (134/134), `DocsCompleteGate.psm1` 100.00% (38/38), `DocsSurfaceDelta.psm1` 100.00% (70/70), `DocsSurfaceDeltaCommands.psm1` 97.33% (73/75). |
| Repo-wide line coverage at or above 85% | PASS | 95.30% (32788 covered, 1617 missed), root LINE counter of the merged artifact, re-derived in this review. |
| Positive Flows | PASS | Allow paths for disabled gate, non-merge, non-integration target and passing receipt. |
| Negative Flows | PARTIAL | 161 rows were added this cycle. No row covers a quote or `<<` in a comment, `<<` in arithmetic, or nested double quotes in a substitution (F6). |
| Edge Cases | PASS | Redirection, descriptor, `#`, quoting, CRLF continuation and split-word forms in the helper suite. |
| Error Handling | PASS | Throwing file seam, throwing `gh` seam and throwing payload reader are tested. |
| Concurrency | N/A | No concurrent behavior in the delivered code. |
| State Transitions | N/A | The hook and commands are stateless. |

Branch coverage: Pester measures no branch counter, so no branch gate applies to PowerShell (`.claude/rules/powershell.md`).

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.26% lines -> Post-change: 95.30% lines. Change: +0.04% lines. New/changed-code coverage: 98.25%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/qa-gates/coverage-delta.2026-11-07T05-35.md`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/regression-testing/pester-parallel.2026-11-07T05-35.md`.

Both figures are root LINE counters of a merged full run. The new-code figure is 392 of 399 lines across the five new production files.

Artifact freshness: the merged artifact was written at 2026-11-07T05:31Z. The last commit that changes a path outside the feature folder is `082c74d0b` at 05:00Z, so the artifact describes head production code. `artifacts/pester/pester-junit.xml` holds 17177 tests, 0 failures, 0 errors and 10 disabled. These figures were re-derived from the XML in this review.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Arrange-Act-Assert | PASS | New rows follow the three-part structure. |
| Clear failure messages | PASS | Row names state the command and the expected result. |
| Assertions able to fail | PASS | 8 of 10 mutants of the cycle 3 lines killed. K8 and K10 survive and are recorded as N16. The BOM assertion from N1 is deferred. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| No external services | PASS | `gh` is reached only through `Invoke-DocsOnlyGhExe` in tests. |
| No temporary files | PASS | Zero matches for the prohibited tokens in the three gate suites, re-run in this review. |
| No mutable global state | PASS | The suites remove imported modules in `AfterAll`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Audit produced | PASS | This artifact. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Policies read in order | PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T04-47.md`. |
| Baseline captured | PASS | `evidence/remediation-baseline/`; `evidence/regression-testing/fail-before.2026-11-07T04-56.md`. |

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| Simplicity | PASS | The after-word check is removed. The candidate test adds one loop over two forms of the command. |
| Reusability | PASS | Reuses the scanner, the walk, the flag tables, the scope predicate and the bounded `gh` seam. |
| Separation of concerns | PASS | The helper holds function definitions and pure string logic only; I/O stays in the hook seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| File size | PASS | Largest covered file 669 logical lines (hook suite); largest production file 552. No covered file is at or above 700 lines. `config/file-size-baseline.json` is not in the diff. |
| Test location | PASS | Mirrors `tests/scripts/`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Naming | PASS | Approved verbs; 0 analyzer findings. |
| Help text | PARTIAL | Comment-based help on every function, and the two sentences the previous audit reported are corrected. The header paragraph `What it establishes` is not accurate at head for the F6 forms. `Invoke-DocsCompleteGateEntryPoint` says every anomaly is already a deny decision, which N19 does not match. |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|---|---|---|
| Formatting | PASS | 0 differences over 26 files, re-run at head. |
| Linting | PASS | 0 findings over 26 files, re-run at head. |
| Type checking | N/A | Not applicable to PowerShell. |
| Architecture boundary | PASS | Contract suites inside the merged run: 0 failures. |
| Unit tests | PASS | 17177 tests, 0 failures, one `Invoke-PoshQCParallelTest` run. |
| Contract | PASS | 265 Python contract tests passed with `-n auto` (executor); Jest manifest 24 passed (executor); Codex generator check exit 0 here. |
| Integration | PARTIAL | Real hook processes confirmed every F4 and F5 denial and found the F6 allows. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Deviations recorded | PASS | `evidence/other/owner-waiver.2026-11-07T01-51.md`; `evidence/qa-gates/self-review.2026-11-07T05-40.md`. The post-plan `spec.md` sentence is in commit `abb854f53` and is accurate. |
| Requirement text current | PARTIAL | N5 is deferred. The limit statement overstates the group it denies (F6), and spec:540 names an evidence path that does not exist (N17). |

Error handling (`## Error Handling and Logging`): **PARTIAL** for "Do not silently ignore errors". A parameter-binding error from the shared reader reaches stderr and the hook still returns a decision, with no catch at the entry point (N19). The fail-closed intent of the gate is not met for F6, recorded as a finding against the gate.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|---|---|---|
| PowerShell 7+ | PASS | Analyzer settings; real runs on 7.6. |
| PoshQC settings | PASS | `pssa.settings.psd1`, CRLF normalized before comparison. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|---|---|---|
| Advanced functions | PASS | `CmdletBinding` throughout, including the helper. |
| Seams | PASS | `Invoke-DocsOnlyGhExe`, file seam, root seam, `[scriptblock]` payload parameter. |
| Failures raised, no silent handling | PARTIAL | As N19; everything else unchanged since the previous audit. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Cohesion | PASS | Five single-purpose new files. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Format, analyze, test | PASS | Appendix B. The MCP PoshQC tools are outside this agent's tool set, so the module cmdlets were called directly with the repository settings. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|---|---|---|
| Valid JSON | PASS | Contract suites report 0 failures. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|---|---|---|
| Entry placement | PASS | Both settings copies share blob `a46956dd3`. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|---|---|---|
| Pester and location | PASS | `*.Tests.ps1` under `tests/scripts/`. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|---|---|---|
| Wrapper mocked, not executable | PASS | `Invoke-DocsOnlyGhExe`, with a stand-in that answers per selector. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | Scenario-named `It` blocks. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Suites at head | PASS | Appendix A. |

---

## 5. Test Coverage Detail

### enforce-docs-complete-gate.ps1 (149 tests) and enforce-docs-complete-gate-target.ps1 (138 tests), with the compound suite (209 tests)

Hook 93.90%, helper 100.00% of lines. As with F4, line coverage of the helper does not show that the candidate test is sound: every line ran, and F6 is in the input the shared scanner receives.

### DocsCompleteGate.psm1, DocsSurfaceDelta.psm1, DocsSurfaceDeltaCommands.psm1, Invoke-DocsCommand.ps1

Unchanged by this branch in this cycle, apart from the merge result in `Invoke-DocsCommand.ps1`, whose added lines are all covered. Mutants M5 and M10 from an earlier review still survive, because N1 and N2 are deferred.

---

## 6. Test Execution Metrics

| Run | Passed | Failed | Skipped | Duration |
|---|---|---|---|---|
| Executor, merged parallel run (P4-T3) | 17167 | 0 | 10 | 566.3 s |
| Executor, Python contract suites with `-n auto` (P4-T6) | 265 | 0 | 0 | 4.65 s |
| Executor, Jest manifest suite (P4-T8) | 24 | 0 | 0 | not recorded |
| Review, three gate suites, mutant control in a scratch copy | 496 | 0 | 0 | not recorded |

This review did not repeat the full Pester run or a full pytest run. Under the relayed parallel-only directive the final gates are the single P4-T3 and P4-T6 runs, and the review inspects their artifacts. The scratch runs were mutant checks, not gates.

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| Invoke-Formatter | PASS | 0 differences over 26 files. |
| PSScriptAnalyzer | PASS | 0 findings over 26 files, including `.claude/lib`. |
| Quality tiers | PASS | `check_quality_tiers.py`: 30 entries, 30 discovered projects. |
| Mirror parity | PASS | Ten source and bundle pairs and the three other `feature-review` pairs share blob identifiers at head, including the hook (`e3d11dac0`) and the helper (`31e2736e9`). |
| Shared gate files | PASS | `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-payload.ps1` and `enforce-epic-merge-gate-command.ps1` have no diff against the merge base. |
| Evidence locations | PASS | `validate_evidence_locations.py --root <worktree>` exit 0. |

### Evidence Location Compliance

The validator exited 0 against the worktree, and the branch diff holds no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`.

### Policy Rule: modified-workflow-needs-green-run

Not triggered. The diff has no path under `.github/workflows/`, `.github/actions/` or `scripts/benchmarks/`.

### Documentation Surface Check

Not applicable: `docs/documentation-estate/docs-profile.json` is absent on the branch head.

## Rejected Scope Narrowing

The caller stated: "Notes N1 to N5 are deferred by owner directive relayed by the coordinator, and are not blocking." and "With the gate enabled, the design is a fail-closed allowlist with a stated limit: the hook reads command text and is not a shell parser. A form the limit statement names or falls within, and which the hook does not deny, is a stated limit of this policy-level control, which is the standard F5 set (\"each form denies or is named in the residual limits\")."

These statements describe the cycle and the design. They were not applied as limits on this audit, which covers the full branch diff. N1 to N5 stay non-blocking, as in earlier reviews, so the deferral does not affect the verdict.

The second statement was applied as the grading standard for forms outside the group the hook claims to deny, so the forms in code review N15 are not blocking. Its words "or falls within" differ from the F5 standard they cite, which says "named". They were not extended to F6, for this reason: the limit statement says the hook denies the words `gh pr merge` in the unquoted text, and reserves its limit for "any other way of causing a merge". A form the statement says it denies cannot also fall within that limit. If the catch-all sentence covered such a form, every missed command would pass by definition and the review could not fail.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F6 (section 10 and `remediation-inputs.2026-11-07T05-55.md`).
- The CI-dependent criterion is pending: no pull request and no workflow run exist for this branch. The S9 CI green gate remains responsible for it.
- N1 to N5 and N13 are open and deferred or accepted. N15 to N19 are new and non-blocking.
- F6 also reaches the epic merge gate through the shared scanner. That gate is outside this branch's diff and was not assessed.

### Approved Exceptions

- Plan deviation for spec criterion T11: 8 whitespace-only lines in `New-DocsCommandContext`, carried from the previous audit.
- Relayed owner waiver, `evidence/other/owner-waiver.2026-11-07T01-51.md`, and the relayed parallel-only directive. They reached this review through the coordinator; their origin with the owner was not confirmed independently. They govern which plan tasks ran. They were not used to set any verdict in this audit.

### Removed/Skipped Tests

None on this branch. The 10 disabled tests in the merged run are not in the diff.

---

## 9. Summary of Changes

### Commits in This PR/Branch

151 commits against the merge base. Thirty-one commits follow the previously reviewed head `1e8c35e37`. The source changes are `4ad00fca2` (integration merge), `d617b61cb`, `19217f809`, `8c4c6c406` and `082c74d0b`. `abb854f53` is the orchestrator's one-sentence `spec.md` correction after the executor finished.

### Files Modified

- Cycle 3: the hook header and helper with bundle copies, the compound and helper suites, `spec.md`, the remediation plan and evidence.
- Branch: 5 new PowerShell production files, 2 edited, 1 YAML template, each with a byte-identical bundle copy; both settings copies and `core.json`; 4 `feature-review` files with bundle copies; 8 new suites and 4 edited test files.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PARTIAL. Gates are clean. The limit statement overstates what the hook denies (F6), and one error path has no handling (N19).

#### Language-Specific Code Change Policy (Section 3)

PARTIAL, for N19 only.

#### General Unit Test Policy (Section 1)

PARTIAL. Coverage is compliant; negative scenarios are incomplete for F6.

#### Language-Specific Unit Test Policy (Section 4)

PASS.

### Metrics Summary

| Metric | Value | Verdict |
|---|---|---|
| PowerShell repo-wide line coverage | 95.30% | PASS |
| PowerShell new-file line coverage | 98.25% combined, 93.90% lowest | PASS |
| PowerShell modified-file line coverage | 89.56% and 97.33%, no regression | PASS |
| Python, TypeScript, C#, Bash coverage | zero changed files | N/A |

### Recommendation

Do not open the pull request yet. Close F6, by a helper change for the comment forms and a change to the limit text, then re-audit.

---

## Appendix A: Test Inventory

### Complete Test List

| Suite | Result |
|---|---|
| Merged `Invoke-PoshQCParallelTest` run, 8 shards | 17177 tests, 0 failures, 0 errors, 10 disabled |
| `enforce-docs-complete-gate.Tests.ps1` within that run | 149 tests, 0 failures |
| `enforce-docs-complete-gate-compound.Tests.ps1` within that run | 209 tests, 0 failures |
| `enforce-docs-complete-gate-target.Tests.ps1` within that run | 138 tests, 0 failures |
| Python contract module set (`-n auto`) | 265 passed |

## Appendix B: Toolchain Commands Reference

Commands ran against the worktree or a scratch copy of it. The MCP template resolver is not available to this agent, so this artifact follows `docs/features/templates/policy_audit/` and the headings in `scripts/dev_tools/validate_policy_audit_artifact.py`.

```text
# Formatting and linting: per changed .ps1 and .psm1 file
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <LF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# File size: logical lines
@(Get-Content -LiteralPath <file>).Count

# Tests: gate results read from the executor's merged run, not repeated
artifacts/pester/pester-junit.xml

# Contract and policy checks, cwd = worktree
python -m scripts.dev_tools.generate_codex_agent_variants --check
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
python scripts/dev_tools/check_quality_tiers.py

# Coverage: read from the existing artifact, not regenerated
artifacts/pester/powershell-coverage.xml (root and per-file LINE counters)

# Parity
git rev-parse HEAD:<source> and HEAD:<bundle copy>

# Hook probes, session-scoped, described in code-review.2026-11-07T05-55.md
Invoke-DocsCompleteGateDecision on 95 commands at head, and on 29 of them at 1e8c35e37 and 3007ef346
Real hook process: pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1 with the envelope on standard input, enabled, disabled and absent profiles
Real bash with a stand-in gh that records its arguments
Mutants K1 to K10: scratch copy of the helper, three gate suites per mutant
```
