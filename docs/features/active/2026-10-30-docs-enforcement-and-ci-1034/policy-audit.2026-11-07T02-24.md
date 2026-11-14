# Policy Compliance Audit: docs-enforcement-and-ci (#1034)

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after remediation cycle 1. Previous review set: artifacts stamped `2026-11-07T01-25`.
**Code Under Test:** `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/lib/docs/DocsCompleteGate.psm1`, `.claude/lib/docs/DocsSurfaceDelta.psm1`, `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1`, `.claude/lib/docs/Invoke-DocsCommand.ps1`, `.claude/lib/docs/DocsProfileCommands.psm1`, `.claude/lib/docs/templates/_docs-quality.yml`, their bundle copies, `.claude/settings.json`, `core.json`, four `feature-review` surfaces with bundle copies, and ten test files.

**Scope:** full branch diff, `origin/epic/documentation-estate-tooling-integration` at merge base `e3e4aa551808a25c436337bf0dbcf298421a34d6` to head `3007ef3467256e04c4a66483f72127b9b18ed5e1` (85 commits, 121 files, 7856 insertions, 165 deletions; 35 files outside the feature folder). The merge base equals the fetched epic tip. `artifacts/pr_context.summary.txt` records this head and range.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 22 files (6 production, 6 bundle copies, 10 test) | 16701 tests (merged parallel run) | PASS 16691 pass, 0 fail, 10 disabled | 95.25% lines | 95.26% lines | 97.97% |
| JSON | 4 files | N/A | PASS validation by contract suites | N/A (config files) | N/A (config files) | N/A |

Python, TypeScript, C# and Bash have zero changed files on the branch, so no coverage verdict applies to them.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/policy-audit.2026-11-07T01-25.md` (merged full run before this cycle) and `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/baseline/pester-coverage.2026-11-04T15-45.md` (merge base, three scan folders)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are present for PowerShell, the only coverage language with changed files.

**Fail-closed rule:** every required baseline, QA and coverage artifact exists.

**Evidence rule:** figures were read from the named artifacts or from commands run in this review (Appendix B).

---

## Executive Summary

**Overall verdict: PARTIALLY COMPLIANT. Review-Verdict: REMEDIATION_REQUIRED (two autonomous findings).**

F2 is closed. Its fix was confirmed in real processes with the profile and the receipt locked. The six F1 commands in the previous probe table now behave as required, and 26 of 28 mutants of the cycle's code were killed.

F1 is not closed, and one new finding is recorded. Both were found by running commands outside the previous probe table:

- **F1, remaining forms (Blocker).** A selector that the hook loses or misreads still falls through to a lookup of a different pull request. `gh pr merge 2>&1 12`, `gh pr merge >log 2>&1 12`, `gh pr merge &>log 12` and `gh pr merge {12..12}` look up the current branch and are allowed, although real bash passes `12` to `gh`. From an integration checkout, `gh pr merge #99` looks up pull request 99 and is allowed, although bash treats `#99` as a comment and merges the current branch. That last form is a regression of this cycle: the previous hook denied it.
- **F3 (Blocker).** A merge inside a shell compound command is never admitted to scope, so the gate allows it with no lookup. `if gh pr checks 12; then gh pr merge 12 --merge; fi` and `for n in 12; do gh pr merge "$n" --merge; done` returned `allow` from a real hook process. The hook header's residual limits do not list this case.

Toolchain and coverage results are clean: formatter 0 differences and analyzer 0 findings over 22 files, 16701 tests with 0 failures, repo-wide PowerShell line coverage 95.26%, hook line coverage 96.89%.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | The hook suite passed 111 of 111 alone in a fresh process in this review and 111 of 111 inside a shard of the merged run. Seeded shuffles (P4-T8) were waived for this cycle; the last shuffled runs are from before the cycle. |
| Isolation | PASS | Seams mock `gh`, file and root boundaries. |
| Fast execution | PASS | Merged run 496.49 s wall clock over 8 workers. |
| Determinism | PASS | No clock or wall-time use in the new rows. |
| Readability | PASS | Arrange, Act and Assert comments and row names that state the command and result. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | 95.25% repo-wide before the cycle (32398 covered, 1617 missed); 69.29% at the merge base over three scan folders. |
| No Coverage Regression | PASS | Repo-wide covered lines rose by 83 and missed lines stayed at 1617. `Invoke-DocsCommand.ps1` 89.44% and `DocsProfileCommands.psm1` 97.33%, unchanged from the previous audit. |
| New Code Coverage at or above 85% | PASS | `enforce-docs-complete-gate.ps1` 96.89% (156/161), `DocsCompleteGate.psm1` 100.00% (38/38), `DocsSurfaceDelta.psm1` 100.00% (70/70), `DocsSurfaceDeltaCommands.psm1` 97.33% (73/75). |
| Repo-wide line coverage at or above 85% | PASS | 95.26% (32481 covered, 1617 missed, 344 files), root LINE counter of the merged artifact. |
| Positive Flows | PASS | Allow paths for disabled gate, non-merge, non-integration target and passing receipt. |
| Negative Flows | PARTIAL | 53 F1 rows and 4 F2 rows were added. No row covers a redirection that contains `&` before the selector, a brace or comment selector, or a merge inside a compound command (F1, F3). |
| Edge Cases | PASS | Revision case and length mismatch, uppercase head revision, `--match-head-commit`, option-injection base. |
| Error Handling | PASS | Throwing file seam, throwing `gh` seam and throwing payload reader are tested; locked-file behavior was confirmed in real processes. |
| Concurrency | N/A | No concurrent behavior in the delivered code. |
| State Transitions | N/A | The hook and commands are stateless. |

Branch coverage: Pester measures no branch counter, so no branch gate applies to PowerShell (`.claude/rules/powershell.md`).

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.25% lines -> Post-change: 95.26% lines. Change: +0.01% lines. New/changed-code coverage: 97.97%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/regression-testing/pester-parallel.2026-11-07T02-05.md`.

Both figures are root LINE counters of a merged full run. The P0-T4, P4-T3 and P4-T4 three-folder comparison was waived, so no three-folder figure exists for this head, and no full-run figure exists for the merge base.

Artifact freshness: the merged artifact was written at 2026-11-07T02:03Z. The last commit that changes a path outside the feature folder is `dd43e6d7f` at 2026-11-07T01:53Z, so the artifact describes head production code. `artifacts/pester/pester-junit.xml` holds 16701 tests, 0 failures, 0 errors and 10 disabled. Its hook file figures were re-derived from the XML in this review.

The hook's five uncovered lines (471, 495, 496, 497, 500) are the `ReadPayload` default and the process tail. Real hook processes in this review ran the tail and emitted one decision line with exit 0.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Arrange-Act-Assert | PASS | New rows follow the three-part structure. |
| Clear failure messages | PASS | Row names state the command and the expected result. |
| Assertions able to fail | PARTIAL | 26 of 28 mutants killed. The unknown-flag row does not discriminate (A17). The BOM assertion from N1 is deferred and still cannot fail. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| No external services | PASS | `gh` is reached only through `Invoke-DocsOnlyGhExe` in tests. |
| No temporary files | PASS | Zero matches for the five prohibited tokens in the hook suite, re-run in this review. |
| No mutable global state | PASS | The suite removes imported modules in `AfterAll`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Audit produced | PASS | This artifact. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Policies read in order | PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T01-46.md`. |
| Baseline captured | PASS | `evidence/remediation-baseline/`; `evidence/regression-testing/fail-before.2026-11-07T01-51.md` records 58 rows failing against the unmodified hook. |

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| Simplicity | PASS | The readers are small and closed-table. Several long single-line statements are noted in the code review. |
| Reusability | PASS | Reuses the scanner, the flag table, the scope predicate and the bounded `gh` seam. |
| Separation of concerns | PASS | Target binding is pure; I/O stays in the seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| File size | PASS | Largest covered file 589 logical lines (hook suite); largest production file 535. No covered file is at or above 700 lines. `config/file-size-baseline.json` is not in the diff. |
| Test location | PASS | Mirrors `tests/scripts/`. |

The hook is exactly 500 logical lines, the limit of spec:541. Any further line in it fails that criterion, so the next fix needs a helper file or a reduction.

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Naming | PASS | Approved verbs; 0 analyzer findings. |
| Help text | PARTIAL | Comment-based help on every function. The header's residual limits omit the F3 case, and `spec.md` lines 254-255 and 265-267 still describe the previous lookup and limits (P2-T5 waived; note N8). |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|---|---|---|
| Formatting | PASS | 0 differences over 22 files, re-run at head. |
| Linting | PASS | 0 findings over 22 files, re-run at head. |
| Type checking | N/A | Not applicable to PowerShell. |
| Architecture boundary | PASS | Contract suites inside the merged run: 0 failures. |
| Unit tests | PASS | 16701 tests, 0 failures, one `Invoke-PoshQCParallelTest` run. |
| Contract | PASS | 265 Python contract tests passed with `-n auto` (executor); 27 push-down tests passed with `-n auto` here; Codex generator check exit 0 here. |
| Integration | PARTIAL | Real-process runs confirmed F2 closed and found F3. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Deviations recorded | PASS | `evidence/other/owner-waiver.2026-11-07T01-51.md` lists the waived tasks. |
| Requirement text current | PARTIAL | `spec.md` is unchanged in this cycle, so N5 and N8 remain open. |

Error handling (`## Error Handling and Logging`): **PASS** for "Do not silently ignore errors". F2's read failure now denies. The fail-closed intent of the gate is not met for F1 and F3, and those are recorded as findings against the gate, not against this rule.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|---|---|---|
| PowerShell 7+ | PASS | Analyzer settings; real runs on 7.x. |
| PoshQC settings | PASS | `pssa.settings.psd1`, CRLF normalized before comparison. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|---|---|---|
| Advanced functions | PASS | `CmdletBinding` throughout. |
| Seams | PASS | `Invoke-DocsOnlyGhExe`, file seam, root seam, `[scriptblock]` payload parameter. |
| Failures raised, no silent handling | PASS | `Get-DocsCompleteGateFileText` maps only a missing file or parent to `$null`; other failures reach a deny. An empty profile and a directory at the profile path both deny in a real process. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Cohesion | PASS | Four single-purpose new files. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Format, analyze, test | PASS | Appendix B. The MCP PoshQC tools are outside this agent's tool set, so the module cmdlets were called directly with the repository settings. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|---|---|---|
| Valid JSON | PASS | Unchanged in this cycle; contract suites in the merged run report 0 failures. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|---|---|---|
| Entry placement | PASS | Hook entry follows `enforce-epic-merge-gate.ps1`. Both settings copies share blob `a46956dd3`. |

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

### enforce-docs-complete-gate.ps1 (111 tests)

96.89% lines. The fail-before evidence shows 58 rows failing against the unmodified hook. Mutants A1 to A28 are listed in the code review: 26 killed, A3 and A17 survived. The behavior behind both was confirmed correct at head by direct probe.

### DocsCompleteGate.psm1, DocsSurfaceDelta.psm1, DocsSurfaceDeltaCommands.psm1, Invoke-DocsCommand.ps1

Unchanged in this cycle. Figures match the previous audit. Mutants M5 and M10 from the previous review still survive, because N1 and N2 are deferred.

---

## 6. Test Execution Metrics

| Run | Passed | Failed | Skipped | Duration |
|---|---|---|---|---|
| Executor, merged parallel run (P4-T9) | 16691 | 0 | 10 | 496.49 s |
| Executor, Python contract suites with `-n auto` (P4-T6) | 265 | 0 | 0 | 3.34 s |
| Review, hook suite control in a scratch copy | 111 | 0 | 0 | not recorded |
| Review, four push-down suites with `-n auto` | 27 | 0 | 0 | 4.74 s |

This review did not repeat the full Pester run. Under the relayed parallel-only directive the final gate is the single P4-T9 run, and the review inspects its artifacts. The scratch hook-suite runs were mutant checks, not gates.

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| Invoke-Formatter | PASS | 0 differences. |
| PSScriptAnalyzer | PASS | 0 findings. |
| Quality tiers | PASS | `check_quality_tiers.py`: 30 entries, 30 projects. `.claude/hooks` and `.claude/lib/docs` are T3, so no property-test or mutation gate applies. |
| Mirror parity | PASS | Nine source and bundle pairs share blob identifiers at head, including the hook (`0292ef9ed`). |
| Shared gate file | PASS | `enforce-epic-merge-gate-command.ps1` is blob `94d2145cd` in `.claude/hooks`, `.codex/hooks` and the merge base. |
| Evidence locations | PASS | `validate_evidence_locations.py --root <worktree>` exit 0. |

### Evidence Location Compliance

The validator exited 0 against the worktree, and the branch diff holds no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. A first run from the main checkout exited 1 on two files under its `artifacts/research/`; those are not on this branch and are not findings.

### Policy Rule: modified-workflow-needs-green-run

Not triggered. The diff has no path under `.github/workflows/`, `.github/actions/` or `scripts/benchmarks/`.

### Documentation Surface Check

Not applicable: `docs/documentation-estate/docs-profile.json` is absent on the branch head.

## Rejected Scope Narrowing

The caller stated: "Remediation cycle 1 covers F1 and F2 only." and "Notes N1 to N5 are deferred by owner directive and are not blocking."

These statements describe the content of the cycle. They were not applied as limits on this audit, which covers the full branch diff. N1 to N5 were non-blocking in the previous review and stay non-blocking here, so the deferral does not affect the verdict. F3 is reported because the audit scope is the branch, not the cycle.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F1 remaining forms and F3 (section 10 and `remediation-inputs.2026-11-07T02-24.md`).
- The CI-dependent criterion is pending: no pull request and no workflow run exist for this branch. The S9 CI green gate remains responsible for it.
- N1 to N5 are open and deferred; N8 is new and non-blocking.

### Approved Exceptions

- Plan deviation for spec criterion T11: 8 whitespace-only lines in `New-DocsCommandContext`, carried from the previous audit.
- Relayed owner waiver, `evidence/other/owner-waiver.2026-11-07T01-51.md`. The directive reached this review through the coordinator; its origin with the owner was not confirmed independently. It governs which plan tasks ran. It was not used to set any verdict in this audit.
- The waiver names P0-T3 and P2-T4, and both are checked in the plan, because they ran and have evidence: P0-T3 completed before the directive arrived, and P2-T4 ran under the directive's exception. Every other waived task is unchecked. This matches the waiver text.

### Removed/Skipped Tests

None on this branch. The 10 disabled tests in the merged run are not in the diff.

---

## 9. Summary of Changes

### Commits in This PR/Branch

85 commits from `c870afa77` to `3007ef346`, including three integration merges. Twenty commits follow the previously reviewed head `48892dc05`: one records that review and 19 belong to cycle 1. The source changes are `f6332ad9e`, `725d1ad23`, `6288eaa33` and `dd43e6d7f`.

### Files Modified

- Cycle 1: the hook, its bundle copy, the hook suite, the remediation plan and evidence.
- Branch: 4 new PowerShell production files, 2 edited, 1 YAML template, each with a byte-identical bundle copy; both settings copies and `core.json`; 4 `feature-review` files with bundle copies; 5 new suites and 5 edited test files.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PARTIAL. Gates are clean and the error-handling failure from the previous audit is resolved. Help text and requirement text are behind the code.

#### Language-Specific Code Change Policy (Section 3)

PASS. PowerShell failure handling is now compliant; JSON is compliant.

#### General Unit Test Policy (Section 1)

PARTIAL. Coverage is compliant; negative scenarios are incomplete for F1 and F3.

#### Language-Specific Unit Test Policy (Section 4)

PASS.

### Metrics Summary

| Metric | Value | Verdict |
|---|---|---|
| PowerShell repo-wide line coverage | 95.26% | PASS |
| PowerShell new-file line coverage | 97.97% combined, 96.89% lowest | PASS |
| PowerShell modified-file line coverage | 89.44% and 97.33%, unchanged | PASS |
| Python, TypeScript, C#, Bash coverage | zero changed files | N/A |

### Recommendation

Do not open the pull request yet. Run one more remediation cycle for F1 and F3, then re-audit.

---

## Appendix A: Test Inventory

### Complete Test List

| Suite | Result |
|---|---|
| Merged `Invoke-PoshQCParallelTest` run, 8 shards | 16701 tests, 0 failures, 0 errors, 10 disabled |
| `enforce-docs-complete-gate.Tests.ps1` within that run | 111 tests, 0 failures |
| `enforce-docs-complete-gate.Tests.ps1`, F1 Context | 53 rows |
| `enforce-docs-complete-gate.Tests.ps1`, merge target controls | 11 rows |
| `enforce-docs-complete-gate.Tests.ps1`, F2 Context | 4 rows |
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
python -m pytest --rootdir <worktree> -c <worktree>/pyproject.toml -o addopts="" -n auto -q -p no:cacheprovider <four push-down suites>

# Contract and policy checks, cwd = worktree
python -m scripts.dev_tools.generate_codex_agent_variants --check
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
python scripts/dev_tools/check_quality_tiers.py

# Coverage: read from the existing artifact, not regenerated
artifacts/pester/powershell-coverage.xml (root and per-file LINE counters, per-line ci values)

# Parity
git rev-parse HEAD:<source> and HEAD:<bundle copy> for 9 pairs

# Hook probes, session-scoped, described in code-review.2026-11-07T02-24.md
Invoke-DocsCompleteGateDecision on about 150 commands, at head and at 48892dc05
Real hook process: pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1 with the envelope on standard input
Real bash with a stand-in gh that prints its arguments
```
