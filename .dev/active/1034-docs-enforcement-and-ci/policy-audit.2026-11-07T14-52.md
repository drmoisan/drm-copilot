# Policy Compliance Audit: docs-enforcement-and-ci (#1034)

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after remediation cycle 4. Previous review set: artifacts stamped `2026-11-07T05-55`.
**Code Under Test:** `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/hooks/enforce-docs-complete-gate-target.ps1`, `.claude/lib/docs/DocsCompleteGate.psm1`, `.claude/lib/docs/DocsSurfaceDelta.psm1`, `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1`, `.claude/lib/docs/Invoke-DocsCommand.ps1`, `.claude/lib/docs/DocsProfileCommands.psm1`, `.claude/lib/docs/templates/_docs-quality.yml`, their bundle copies, `.claude/settings.json`, `core.json`, four `feature-review` surfaces with bundle copies, and twelve test files.

**Scope:** full branch diff, `origin/epic/documentation-estate-tooling-integration` at merge base `e1f4d2e54dd877929f28fd5496231304d3c5308f` to head `709dcf95bf09b29bfd77482da29425f5a172517b` (169 commits, 208 files, 15053 insertions, 196 deletions; 39 files outside the feature folder). The PR context pair recorded the previous head `abb854f53`, so this review regenerated it; both files now record head `709dcf95b` and merge base `e1f4d2e54`.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 26 files (7 production, 7 bundle copies, 12 test) | 17177 tests (merged parallel run) | PASS 17167 pass, 0 fail, 10 disabled | 95.30% lines | 95.30% lines | 98.25% |
| JSON | 4 files | N/A | PASS validation by contract suites | N/A (config files) | N/A (config files) | N/A |

Python, TypeScript, C# and Bash have zero changed files against the merge base, so no coverage verdict applies to them. Cycle 4 changed no executable line: the only production file edited is the hook, and both of its hunks lie inside the comment-based help block.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/baseline/pester-parallel.2026-11-07T14-15.md` (merged full run before cycle 4) and `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/policy-audit.2026-11-07T05-55.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are present for PowerShell, the only coverage language with changed files.

**Fail-closed rule:** every required baseline, QA and coverage artifact exists.

**Evidence rule:** figures were read from the named artifacts or from commands run in this review (Appendix B).

---

## Executive Summary

**Overall verdict: COMPLIANT. Review-Verdict: PASS (no blocking finding).**

F6 is closed by text, the route the owner chose. The hook header and the `spec.md` residual-limits paragraph now say the hook denies the merge words "in the text the shared scanner reads as unquoted", state the three scanner behaviours that cause the F6 allows, and name each F6 group and each N15 form. This review checked the text against the code and found it accurate in substance; one clause is broader than the code (N20, non-blocking). Every named form allows at head, as the text now states, and the controls are unchanged.

Cycle 4 edited only comment text in the hook and its byte-identical bundle copy, `spec.md` and `user-story.md`. The helper and the four shared scanner files are unchanged. Analyzer 0 findings and formatter 0 differences on the hook, re-run here. The final parallel Pester run has 17177 tests and 0 failures; the final `pytest -n auto` run has 16350 passed and 0 failures. Repo-wide PowerShell line coverage 95.30%.

Under the owner review standard supplied with this re-audit, a shell form the hook does not model is non-blocking when the limit text names it.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | Gate suites pass inside shards of the merged parallel run. Single-process, seeded-shuffle and ordering checks are waived by owner directive and were not required. |
| Isolation | PASS | Seams mock `gh`, file and root boundaries. The helper suite drives pure functions. |
| Fast execution | PASS | Final merged run 493.66 s over 8 workers. |
| Determinism | PASS | Baseline and final runs give the same totals and an empty failure set. |
| Readability | PASS | Unchanged in this cycle; no test file changed. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | 95.30% repo-wide in the cycle 4 baseline run; hook 93.9% (77 covered, 5 missed). |
| No Coverage Regression | PASS | Root LINE counter 32788 covered, 1617 missed, equal to the previous review. Hook unchanged at 77 of 82; the 11 added hook lines are comments. |
| New Code Coverage at or above 85% | PASS | `enforce-docs-complete-gate.ps1` 93.90% (77/82), `enforce-docs-complete-gate-target.ps1` 100.00% (134/134), `DocsCompleteGate.psm1` 100.00% (38/38), `DocsSurfaceDelta.psm1` 100.00% (70/70), `DocsSurfaceDeltaCommands.psm1` 97.33% (73/75). |
| Repo-wide line coverage at or above 85% | PASS | 95.30% (32788 covered, 1617 missed), root LINE counter of the merged artifact, re-derived in this review. |
| Positive Flows | PASS | Allow paths for disabled gate, non-merge, non-integration target and passing receipt. |
| Negative Flows | PASS | The F6 forms are now stated limits under the owner standard, so they are not required deny rows. |
| Edge Cases | PASS | Redirection, descriptor, `#`, quoting, CRLF continuation and split-word forms in the helper suite. |
| Error Handling | PASS | Throwing file seam, throwing `gh` seam and throwing payload reader are tested. |
| Concurrency | N/A | No concurrent behavior in the delivered code. |
| State Transitions | N/A | The hook and commands are stateless. |

Branch coverage: Pester measures no branch counter, so no branch gate applies to PowerShell (`.claude/rules/powershell.md`).

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.30% lines -> Post-change: 95.30% lines. Change: +0.00% lines. New/changed-code coverage: 98.25%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/qa-gates/coverage-delta.2026-11-07T14-35.md`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/regression-testing/pester-parallel.2026-11-07T14-35.md`.

Both figures are root LINE counters of a merged full run. The new-code figure is 392 of 399 lines across the five new production files.

Artifact freshness: the merged artifact and `artifacts/pester/pester-junit.xml` were written at 2026-11-07T14:35Z. The last commit that changes a path outside the feature folder is `0fdbcc437` (hook help text), which precedes the run. The JUnit file holds 17177 tests, 0 failures, 0 errors and 10 disabled. These figures were re-derived from the XML in this review.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Arrange-Act-Assert | PASS | Unchanged; no test file changed in this cycle. |
| Clear failure messages | PASS | Row names state the command and the expected result. |
| Assertions able to fail | PASS | Unchanged from the previous audit. K8 and K10 still survive (N16, non-blocking). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| No external services | PASS | `gh` is reached only through `Invoke-DocsOnlyGhExe` in tests. |
| No temporary files | PASS | No test file changed in this cycle; the previous scan stands. |
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
| Policies read in order | PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T14-02.md`. |
| Baseline captured | PASS | `evidence/baseline/pester-parallel.2026-11-07T14-15.md`, `evidence/baseline/pytest-parallel.2026-11-07T14-22.md`, `evidence/remediation-baseline/pssa.2026-11-07T14-04.md`. |

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| Simplicity | PASS | Text-only cycle; no logic changed. |
| Reusability | PASS | Unchanged. |
| Separation of concerns | PASS | Unchanged. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| File size | PASS | Hook 353 logical lines (from 342), helper 334. No covered file is at or above 700 lines. `config/file-size-baseline.json` is not in the diff. |
| Test location | PASS | Mirrors `tests/scripts/`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Naming | PASS | Approved verbs; 0 analyzer findings. |
| Help text | PASS | The `What it establishes` paragraph now matches the code for the F6 forms. One clause, "reads << as a heredoc opener wherever it appears", is broader than the code, which reads `<<` only outside quotes and treats `<<<` as a here-string (N20, non-blocking; the overstatement widens the stated limit and does not claim a denial that does not occur). |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|---|---|---|
| Formatting | PASS | Hook and bundle copy: 0 differences, re-run in this review. |
| Linting | PASS | Hook and bundle copy: 0 findings, re-run in this review. |
| Type checking | N/A | Not applicable to PowerShell. |
| Architecture boundary | PASS | Contract suites inside the merged run: 0 failures. |
| Unit tests | PASS | 17177 tests, 0 failures, one `Invoke-PoshQCParallelTest` run; 16350 passed, 0 failures, one `pytest -n auto` run. |
| Contract | PASS | `test_push_down_claude_resource_contracts.py` 14 tests, 0 failures inside the pytest run. |
| Integration | PASS | Named-form driver over the real hook decision function: R1 to R9 allow, controls as before (`named-form-decisions.2026-11-07T14-25.md`); confirmed by this review's own predicate probe. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Deviations recorded | PASS | `evidence/qa-gates/self-review.2026-11-07T14-43.md`; parallel-only directive recorded in each gate artifact. |
| Requirement text current | PASS | The limit statement matches the code (N20 aside). spec:540 now names `evidence/qa-gates/`, a canonical evidence kind that holds the figures (N17 closed). N5 stays deferred. |

Error handling (`## Error Handling and Logging`): N19 is unchanged and non-blocking, as recorded in the previous audit.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|---|---|---|
| PowerShell 7+ | PASS | Analyzer settings; review runs on PowerShell 7. |
| PoshQC settings | PASS | `pssa.settings.psd1`, CRLF normalized before formatter comparison. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|---|---|---|
| Advanced functions | PASS | Unchanged. |
| Seams | PASS | Unchanged. |
| Failures raised, no silent handling | PASS | N19 unchanged and non-blocking. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Cohesion | PASS | Unchanged. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|---|---|---|
| Format, analyze, test | PASS | Appendix B. The MCP PoshQC tools are not in this agent's tool set, so the module cmdlets were called directly with the repository settings. |

### Section 3D: JSON Configuration Policy Compliance

#### 3D.1 JSON Tooling

| Requirement | Status | Evidence |
|---|---|---|
| Valid JSON | PASS | Unchanged in this cycle; contract suites 0 failures. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|---|---|---|
| Entry placement | PASS | Unchanged. |

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
| Wrapper mocked, not executable | PASS | `Invoke-DocsOnlyGhExe`. |

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

Hook 93.90%, helper 100.00% of lines, both unchanged. The cycle added only comment lines to the hook.

### DocsCompleteGate.psm1, DocsSurfaceDelta.psm1, DocsSurfaceDeltaCommands.psm1, Invoke-DocsCommand.ps1, DocsProfileCommands.psm1

Unchanged in this cycle: 100.00%, 100.00%, 97.33%, 89.56% and 97.33%.

---

## 6. Test Execution Metrics

| Run | Passed | Failed | Skipped | Duration |
|---|---|---|---|---|
| Executor, merged parallel Pester run (P2-T4) | 17167 | 0 | 10 | 493.66 s |
| Executor, `pytest -n auto` (P2-T6) | 16350 | 0 | 6 | 226.50 s |
| Review, candidate predicate probe (17 rows) | 17 | 0 | 0 | not timed |

Under the owner's parallel-only directive the final gates are the single P2-T4 and P2-T6 runs; this review inspected their artifacts and did not repeat them. Baseline and final runs report the same totals and an empty failure set.

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| Invoke-Formatter | PASS | 0 differences on the hook and its bundle copy. |
| PSScriptAnalyzer | PASS | 0 findings on the hook and its bundle copy. |
| Quality tiers | PASS | Unchanged since the previous audit; no project added. |
| Mirror parity | PASS | Hook and bundle copy share blob `8a3715abe`; helper and bundle copy share `31e2736e9`. |
| Shared gate files | PASS | `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-payload.ps1` and `enforce-epic-merge-gate-command.ps1` have no diff against the merge base, in `.claude/hooks/`, `.codex/hooks/` and both bundle trees. The helper has no diff since the previous review. |
| Evidence locations | PASS | `validate_evidence_locations.py --root <worktree>` exit 0. |

### Evidence Location Compliance

The validator exited 0 against the worktree, and the branch diff holds no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`.

### Policy Rule: modified-workflow-needs-green-run

Not triggered. The diff has no path under `.github/workflows/`, `.github/actions/` or `scripts/benchmarks/`.

### Documentation Surface Check

Not applicable: `docs/documentation-estate/docs-profile.json` is absent on the branch head.

## Rejected Scope Narrowing

The caller stated: "Owner review standard, binding for this re-audit: a shell form the hook does not model is non-blocking when the limit text names it. Do not open new blockers for unmodelled shell forms that fall within the named classes or \"forms not modelled\"; report any newly found unnamed form as a non-blocking note."

This sets a grading standard for one class of finding; it does not narrow the diff. The audit covered the full branch diff. The standard was applied as stated, and it is consistent with the previous audit's requirement that each form deny or be named. The text now names the F6 forms, so the earlier objection (a form placed in the group the text says denies) no longer applies.

The caller also stated: "Single-process, seeded-shuffle, reversed-order and ordering-comparison checks are waived by owner directive; do not require them and do not report their absence as a finding." This was applied. It does not remove any language from coverage verification, and PowerShell coverage carries an explicit PASS above.

---

## 8. Gaps and Exceptions

### Identified Gaps

- The CI-dependent criterion spec:544 is pending: no pull request and no workflow run exist for this branch. The S9 CI green gate owns it. It is not a finding.
- N1 to N5, N13, N16, N18 and N19 remain open and deferred or accepted; none regressed. N20 is new and non-blocking.
- The F6 scanner behaviours also reach the epic merge gate through the shared scanner. That gate is outside this branch's diff and was not assessed.

### Approved Exceptions

- Plan deviation for spec criterion T11: 8 whitespace-only lines in `New-DocsCommandContext`, carried from earlier audits.
- The owner's parallel-only test directive and the owner review standard for unmodelled forms, supplied with this re-audit.

### Removed/Skipped Tests

None on this branch. The 10 disabled tests in the merged run are not in the diff.

---

## 9. Summary of Changes

### Commits in This PR/Branch

169 commits against the merge base. Eighteen follow the previously reviewed head `abb854f53`. The non-evidence changes are `0fdbcc437` (hook help text and bundle copy), `680923fc9` (spec limit text), `8c5fcbcfb` (spec:540 path) and `b058155b9` (check-off of spec:516, story:65 and story:73).

### Files Modified

- Cycle 4: the hook help block and its bundle copy, `spec.md` (two limit lines and the spec:540 path, line-count neutral), `user-story.md` (two check-offs), the remediation plan and evidence.
- Branch: 5 new PowerShell production files, 2 edited, 1 YAML template, each with a byte-identical bundle copy; both settings copies and `core.json`; 4 `feature-review` files with bundle copies; 8 new suites and 4 edited test files.

---

## 10. Compliance Verdict

### Overall Status: COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PASS. Gates are clean, and the limit statement matches the code apart from the non-blocking N20 wording.

#### Language-Specific Code Change Policy (Section 3)

PASS.

#### General Unit Test Policy (Section 1)

PASS.

#### Language-Specific Unit Test Policy (Section 4)

PASS.

### Metrics Summary

| Metric | Value | Verdict |
|---|---|---|
| PowerShell repo-wide line coverage | 95.30% | PASS |
| PowerShell new-file line coverage | 98.25% combined, 93.90% lowest | PASS |
| PowerShell modified-file line coverage | 89.56% and 97.33%, no regression | PASS |
| Python repo-wide coverage (zero changed Python files on this branch) | 96.84% lines, 93.88% branches, from `evidence/qa-gates/pytest-parallel.2026-11-07T14-40.md` at this head | PASS |
| TypeScript, C#, Bash coverage | zero changed files | N/A |

### Recommendation

The branch may proceed to pull request creation. spec:544 is then checked off at S9 after CI is green.

---

## Appendix A: Test Inventory

### Complete Test List

| Suite | Result |
|---|---|
| Merged `Invoke-PoshQCParallelTest` run, 8 shards | 17177 tests, 0 failures, 0 errors, 10 disabled |
| `enforce-docs-complete-gate.Tests.ps1` within that run | 149 tests, 0 failures |
| `enforce-docs-complete-gate-compound.Tests.ps1` within that run | 209 tests, 0 failures |
| `enforce-docs-complete-gate-target.Tests.ps1` within that run | 138 tests, 0 failures |
| `pytest -n auto` | 16350 passed, 6 skipped, 0 failed |

## Appendix B: Toolchain Commands Reference

Commands ran against the worktree. This artifact follows `docs/features/templates/policy_audit/` and the headings in `scripts/dev_tools/validate_policy_audit_artifact.py`.

```text
# Formatting and linting: hook and bundle copy
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <LF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# File size: logical lines
@(Get-Content -LiteralPath <file>).Count

# Tests: gate results read from the executor's merged runs, not repeated
artifacts/pester/pester-junit.xml

# Policy checks
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
python -m scripts.dev_tools.pr_context.collector --base origin/epic/documentation-estate-tooling-integration --head HEAD --repo-root <worktree>

# Coverage: read from the existing artifact, not regenerated
artifacts/pester/powershell-coverage.xml (root and per-file LINE counters)

# Parity and scope
git hash-object on each hook, helper and shared scanner file and its copies
git diff e1f4d2e54 HEAD over the shared scanner files; git diff abb854f53 HEAD over the helper
git show <rev>:spec.md for the line count and the Acceptance Criteria heading position at abb854f53 and HEAD

# Predicate probe
Test-DocsCompleteGateMergeCandidate on 17 commands with the shared files and the helper dot-sourced
```
