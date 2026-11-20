# Policy Compliance Audit: docs-enforcement-and-ci (#1034)

**Audit Date:** 2026-11-07
**Audit Type:** Re-audit after remediation cycle 2. Previous review set: artifacts stamped `2026-11-07T02-24`.
**Code Under Test:** `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/hooks/enforce-docs-complete-gate-target.ps1`, `.claude/lib/docs/DocsCompleteGate.psm1`, `.claude/lib/docs/DocsSurfaceDelta.psm1`, `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1`, `.claude/lib/docs/Invoke-DocsCommand.ps1`, `.claude/lib/docs/DocsProfileCommands.psm1`, `.claude/lib/docs/templates/_docs-quality.yml`, their bundle copies, `.claude/settings.json`, `core.json`, four `feature-review` surfaces with bundle copies, and twelve test files.

**Scope:** full branch diff, `origin/epic/documentation-estate-tooling-integration` at merge base `e3e4aa551808a25c436337bf0dbcf298421a34d6` to head `1e8c35e37bbd38cb26f081936071e9a2d971f930` (120 commits, 155 files, 10601 insertions, 187 deletions; 39 files outside the feature folder). `artifacts/pr_context.summary.txt` records this head and range. The epic tip has moved to `e1f4d2e54` since the previous review; see note N12.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 26 files (7 production, 7 bundle copies, 12 test) | 16928 tests (merged parallel run) | PASS 16918 pass, 0 fail, 10 disabled | 95.26% lines | 95.26% lines | 98.22% |
| JSON | 4 files | N/A | PASS validation by contract suites | N/A (config files) | N/A (config files) | N/A |

Python, TypeScript, C# and Bash have zero changed files on the branch, so no coverage verdict applies to them.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/policy-audit.2026-11-07T02-24.md` (merged full run before this cycle), `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/remediation-baseline/pester-coverage.2026-11-07T03-28.md` and `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/baseline/pester-coverage.2026-11-04T15-45.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are present for PowerShell, the only coverage language with changed files.

**Fail-closed rule:** every required baseline, QA and coverage artifact exists.

**Evidence rule:** figures were read from the named artifacts or from commands run in this review (Appendix B).

---

## Executive Summary

**Overall verdict: PARTIALLY COMPLIANT. Review-Verdict: REMEDIATION_REQUIRED (two autonomous findings).**

The commands in the previous F1 and F3 tables now behave as required. The hook is 325 lines, the helper is 290, notes N8, N9, N10 and N11 are closed, and toolchain and coverage results are clean.

Two findings remain. Both were found by running commands outside the previous tables and comparing them with real bash, and both are shown in `code-review.2026-11-07T04-16.md`:

- **F4 (Blocker).** The plain-command proof reads text in which a backslash-newline has already been replaced with a space, so a comment ending in a backslash hides the next line. In bash that next line runs. `gh pr merge 34 # x\<newline>gh pr merge 12` reads as one plain merge of 34 and is allowed, and real bash passed both `pr merge 34` and `pr merge 12` to `gh`. The hook at the previous head denied this command, so it is a deny-to-allow regression of cycle 2. A real hook process with the gate enabled and no receipt returned `allow` for two forms of this defect.
- **F5 (Blocker).** The header states that a merge in any form other than one plain `gh pr merge` denies, and that is not true for three unlisted groups: a quoted payload under a leading word that is not a transparent wrapper (`if true; then sh -c 'gh pr merge 12'; fi`, `! sh -c ...`, `exec sh -c ...`), quoted text piped into a shell (`echo 'gh pr merge 12' | sh`), and backslash inside a command word (`g\h pr merge 12`). Each is allowed with the gate enabled and no receipt. The cycle's required action was that an unhandled form goes in the residual limits; these do not.

Toolchain results: formatter 0 differences and analyzer 0 findings over 26 files, 16928 tests with 0 failures, repo-wide PowerShell line coverage 95.26%, helper line coverage 100.00%.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | The three gate suites passed 335 of 335 alone in a fresh process in a scratch copy, and inside shards of the merged run. Seeded shuffles were not run on this tree under the relayed parallel-only directive; the last shuffled runs predate cycle 1. |
| Isolation | PASS | Seams mock `gh`, file and root boundaries. The helper suite drives pure functions. |
| Fast execution | PASS | Merged run 656.5 s wall clock over 8 workers. |
| Determinism | PASS | No clock or wall-time use in the new rows. |
| Readability | PASS | Arrange, Act and Assert comments and row names that state the command and result. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | 95.26% repo-wide before the cycle (32481 covered, 1617 missed); 69.29% at the merge base over three scan folders. |
| No Coverage Regression | PASS | Repo-wide covered lines rose by 50 and missed lines stayed at 1617. The hook percentage fell from 96.89% to 93.90% only because four covered functions moved to the helper; its five missed lines are the same five statements, now 296, 320, 321, 322 and 325. `Invoke-DocsCommand.ps1` 89.44% and `DocsProfileCommands.psm1` 97.33%, unchanged. |
| New Code Coverage at or above 85% | PASS | `enforce-docs-complete-gate.ps1` 93.90% (77/82), `enforce-docs-complete-gate-target.ps1` 100.00% (129/129), `DocsCompleteGate.psm1` 100.00% (38/38), `DocsSurfaceDelta.psm1` 100.00% (70/70), `DocsSurfaceDeltaCommands.psm1` 97.33% (73/75). |
| Repo-wide line coverage at or above 85% | PASS | 95.26% (32531 covered, 1617 missed), root LINE counter of the merged artifact, re-derived in this review. |
| Positive Flows | PASS | Allow paths for disabled gate, non-merge, non-integration target and passing receipt. |
| Negative Flows | PARTIAL | 186 helper and compound rows were added. No row covers a comment that ends in a backslash, a quoted payload under a leading word, text piped into a shell, or a backslash in a command word (F4, F5). |
| Edge Cases | PASS | Redirection, descriptor, `#` and quoting forms in the helper suite; revision case and length mismatch; uppercase head revision. |
| Error Handling | PASS | Throwing file seam, throwing `gh` seam and throwing payload reader are tested. |
| Concurrency | N/A | No concurrent behavior in the delivered code. |
| State Transitions | N/A | The hook and commands are stateless. |

Branch coverage: Pester measures no branch counter, so no branch gate applies to PowerShell (`.claude/rules/powershell.md`).

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.26% lines -> Post-change: 95.26% lines. Change: +0.01% lines (95.258 to 95.265). New/changed-code coverage: 98.22%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/qa-gates/coverage-delta.2026-11-07T03-57.md`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/regression-testing/pester-parallel.2026-11-07T03-57.md`.

Both figures are root LINE counters of a merged full run. The new-code figure is 387 of 394 lines across the five new production files.

Artifact freshness: the merged artifact was written at 2026-11-07T03:56Z. The last commit that changes a path outside the feature folder is `36ddf81ab` at 03:45Z, so the artifact describes head production code. The missed line numbers in the XML map onto the committed hook. `artifacts/pester/pester-junit.xml` holds 16928 tests, 0 failures, 0 errors and 10 disabled. These figures were re-derived from the XML in this review.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Arrange-Act-Assert | PASS | New rows follow the three-part structure. |
| Clear failure messages | PASS | Row names state the command and the expected result. |
| Assertions able to fail | PASS | 25 of 29 helper mutants killed; the four survivors are equivalent or nearly so, as listed in the code review. A17 is now killed, which closes N10. The BOM assertion from N1 is deferred. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| No external services | PASS | `gh` is reached only through `Invoke-DocsOnlyGhExe` in tests. |
| No temporary files | PASS | Zero matches for the five prohibited tokens in the three gate suites, re-run in this review. |
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
| Policies read in order | PASS | `evidence/remediation-baseline/phase0-instructions-read.2026-11-07T03-27.md`. |
| Baseline captured | PASS | `evidence/remediation-baseline/`; `evidence/regression-testing/fail-before.2026-11-07T03-32.md`. |

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| Simplicity | PASS | The allowlist replaces the earlier list of forms and removes two functions. One after-word check in the plain reader is redundant (note N14). |
| Reusability | PASS | Reuses the scanner, the walk, the flag tables, the scope predicate and the bounded `gh` seam. |
| Separation of concerns | PASS | The helper holds function definitions and pure string logic only; I/O stays in the hook seams. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| File size | PASS | Largest covered file 669 logical lines (hook suite); largest production file 535. No covered file is at or above 700 lines. `config/file-size-baseline.json` is not in the diff. |
| Test location | PASS | Mirrors `tests/scripts/`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Naming | PASS | Approved verbs; 0 analyzer findings. |
| Help text | PARTIAL | Comment-based help on every function. The header sentence "a merge in any form other than one plain gh pr merge denies PR_UNRESOLVED" and the helper sentence "a form the grammar does not model can never lose its selector" are not accurate at head (F4, F5). |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|---|---|---|
| Formatting | PASS | 0 differences over 26 files, re-run at head. |
| Linting | PASS | 0 findings over 26 files, re-run at head. |
| Type checking | N/A | Not applicable to PowerShell. |
| Architecture boundary | PASS | Contract suites inside the merged run: 0 failures. |
| Unit tests | PASS | 16928 tests, 0 failures, one `Invoke-PoshQCParallelTest` run. |
| Contract | PASS | 265 Python contract tests passed with `-n auto` (executor); 98 push-down tests passed with `-n auto` here; Codex generator check exit 0 here. |
| Integration | PARTIAL | Real hook processes confirmed the compound denial and found the F4 and F5 allows. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Deviations recorded | PASS | `evidence/other/owner-waiver.2026-11-07T01-51.md`; the self-review records the cycle's loop restart. |
| Requirement text current | PARTIAL | N8 is closed: `spec.md` carries the final lookup and the helper, and its line count is preserved. N5 is deferred, and the residual limits omit the F5 forms. |

Error handling (`## Error Handling and Logging`): **PASS** for "Do not silently ignore errors". The fail-closed intent of the gate is not met for F4 and F5, and those are recorded as findings against the gate, not against this rule.

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
| Advanced functions | PASS | `CmdletBinding` throughout, including the helper. |
| Seams | PASS | `Invoke-DocsOnlyGhExe`, file seam, root seam, `[scriptblock]` payload parameter. |
| Failures raised, no silent handling | PASS | Unchanged since the previous audit. An empty-string word binds through the walk without a parameter error; `gh pr merge 12 --subject ""` reaches its lookup. |

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
| Valid JSON | PASS | One `core.json` row added in this cycle; contract suites report 0 failures. |

#### 3D.2 JSON Structure

| Requirement | Status | Evidence |
|---|---|---|
| Entry placement | PASS | The helper row follows the hook row, once. Both settings copies share blob `a46956dd3`. |

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

### enforce-docs-complete-gate.ps1 (149 tests) and enforce-docs-complete-gate-target.ps1 (115 tests), with the compound suite (71 tests)

Hook 93.90%, helper 100.00% of lines. Line coverage of the helper does not show that the plain proof is sound: every line of `Read-DocsCompleteGatePlainCommand` ran, and F4 is in that function's input, not in an unexecuted line.

### DocsCompleteGate.psm1, DocsSurfaceDelta.psm1, DocsSurfaceDeltaCommands.psm1, Invoke-DocsCommand.ps1

Unchanged in this cycle. Figures match the previous audit. Mutants M5 and M10 from an earlier review still survive, because N1 and N2 are deferred.

---

## 6. Test Execution Metrics

| Run | Passed | Failed | Skipped | Duration |
|---|---|---|---|---|
| Executor, merged parallel run (P4-T3) | 16918 | 0 | 10 | 656.5 s |
| Executor, Python contract suites with `-n auto` (P4-T6) | 265 | 0 | 0 | 8.60 s |
| Review, three gate suites, mutant control in a scratch copy | 335 | 0 | 0 | not recorded |
| Review, five push-down suites with `-n auto` | 98 | 0 | 0 | 3.64 s |

This review did not repeat the full Pester run. Under the relayed parallel-only directive the final gate is the single P4-T3 run, and the review inspects its artifacts. The scratch runs were mutant checks, not gates.

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| Invoke-Formatter | PASS | 0 differences over 26 files. |
| PSScriptAnalyzer | PASS | 0 findings over 26 files. |
| Quality tiers | PASS | `check_quality_tiers.py`: 30 entries, 30 projects. `.claude/hooks` and `.claude/lib/docs` are T3, so no property-test or mutation gate applies. |
| Mirror parity | PASS | Ten source and bundle pairs and the three other `feature-review` pairs share blob identifiers at head, including the hook (`040b04541`) and the helper (`4b142ab07`). |
| Manifest | PASS | The helper appears once in `core.json`. |
| Shared gate file | PASS | `enforce-epic-merge-gate-command.ps1` has no diff against the merge base in either hook tree (executor evidence `mirror-hashes.2026-11-07T03-57.md`; `git diff --stat` of the branch lists no such path). |
| Evidence locations | PASS | `validate_evidence_locations.py --root <worktree>` exit 0. |

### Evidence Location Compliance

The validator exited 0 against the worktree, and the branch diff holds no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`.

### Policy Rule: modified-workflow-needs-green-run

Not triggered. The diff has no path under `.github/workflows/`, `.github/actions/` or `scripts/benchmarks/`.

### Documentation Surface Check

Not applicable: `docs/documentation-estate/docs-profile.json` is absent on the branch head.

## Rejected Scope Narrowing

The caller stated: "Notes N1 to N5 are deferred by owner directive relayed by the coordinator, and are not blocking." and "Forms outside that allowlist denying rather than reaching a receipt reason is the intended behavior; the header and `spec.md` list the residual limits."

These statements describe the cycle and the design. They were not applied as limits on this audit, which covers the full branch diff. N1 to N5 were non-blocking in earlier reviews and stay non-blocking here, so the deferral does not affect the verdict. A form that denies with `PR_UNRESOLVED` is graded as the intended behavior, as the caller stated. The second sentence's claim that the residual limits are listed was tested rather than assumed, and F5 records where it does not hold.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F4 and F5 (section 10 and `remediation-inputs.2026-11-07T04-16.md`).
- The CI-dependent criterion is pending: no pull request and no workflow run exist for this branch. The S9 CI green gate remains responsible for it.
- N1 to N5 are open and deferred. N12 to N14 are new and non-blocking.

### Approved Exceptions

- Plan deviation for spec criterion T11: 8 whitespace-only lines in `New-DocsCommandContext`, carried from the previous audit.
- Relayed owner waiver, `evidence/other/owner-waiver.2026-11-07T01-51.md`, and the relayed parallel-only directive. They reached this review through the coordinator; their origin with the owner was not confirmed independently. They govern which plan tasks ran. They were not used to set any verdict in this audit.

### Removed/Skipped Tests

None on this branch. The 10 disabled tests in the merged run are not in the diff.

---

## 9. Summary of Changes

### Commits in This PR/Branch

120 commits from `c870afa77` to `1e8c35e37`, including three integration merges. Thirty-five commits follow the previously reviewed head `3007ef346`. The source changes are `557bc3ea1`, `f334e8906`, `d754b7a2f`, `93e70eb60` and `36ddf81ab`.

### Files Modified

- Cycle 2: the hook and new helper with bundle copies, `core.json`, the hook suite, two new suites, `spec.md`, the remediation plan and evidence, and the story:74 check-off from the previous review.
- Branch: 5 new PowerShell production files, 2 edited, 1 YAML template, each with a byte-identical bundle copy; both settings copies and `core.json`; 4 `feature-review` files with bundle copies; 8 new suites and 4 edited test files.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PARTIAL. Gates are clean. Two statements in the help text are not accurate at head.

#### Language-Specific Code Change Policy (Section 3)

PASS.

#### General Unit Test Policy (Section 1)

PARTIAL. Coverage is compliant; negative scenarios are incomplete for F4 and F5.

#### Language-Specific Unit Test Policy (Section 4)

PASS.

### Metrics Summary

| Metric | Value | Verdict |
|---|---|---|
| PowerShell repo-wide line coverage | 95.26% | PASS |
| PowerShell new-file line coverage | 98.22% combined, 93.90% lowest | PASS |
| PowerShell modified-file line coverage | 89.44% and 97.33%, unchanged | PASS |
| Python, TypeScript, C#, Bash coverage | zero changed files | N/A |

### Recommendation

Do not open the pull request yet. Run one proportionate remediation cycle for F4 and F5, merge the current epic tip in the same cycle (N12), then re-audit.

---

## Appendix A: Test Inventory

### Complete Test List

| Suite | Result |
|---|---|
| Merged `Invoke-PoshQCParallelTest` run, 8 shards | 16928 tests, 0 failures, 0 errors, 10 disabled |
| `enforce-docs-complete-gate.Tests.ps1` within that run | 149 tests, 0 failures |
| `enforce-docs-complete-gate-compound.Tests.ps1` within that run | 71 tests, 0 failures |
| `enforce-docs-complete-gate-target.Tests.ps1` within that run | 115 tests, 0 failures |
| `hook-dependency-failure.Claude.Tests.ps1` within that run | 195 tests, 0 failures |
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
python -m pytest --rootdir <worktree> -c <worktree>/pyproject.toml -o addopts="" -n auto -q -p no:cacheprovider <five push-down suites>

# Contract and policy checks, cwd = worktree
python -m scripts.dev_tools.generate_codex_agent_variants --check
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
python scripts/dev_tools/check_quality_tiers.py

# Coverage: read from the existing artifact, not regenerated
artifacts/pester/powershell-coverage.xml (root and per-file LINE counters, per-line ci values)

# Parity
git rev-parse HEAD:<source> and HEAD:<bundle copy>; git ls-files -s for the feature-review surfaces

# Merge readiness
git merge-tree --write-tree --name-only origin/epic/documentation-estate-tooling-integration HEAD

# Hook probes, session-scoped, described in code-review.2026-11-07T04-16.md
Invoke-DocsCompleteGateDecision on 153 commands, at head and 135 of them at 3007ef346
Real hook process: pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1 with the envelope on standard input
Real bash with a stand-in gh that records its arguments
```
