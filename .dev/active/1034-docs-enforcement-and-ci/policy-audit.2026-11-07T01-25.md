# Policy Compliance Audit: docs-enforcement-and-ci (#1034)

**Audit Date:** 2026-11-07
**Code Under Test:** `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/lib/docs/DocsCompleteGate.psm1`, `.claude/lib/docs/DocsSurfaceDelta.psm1`, `.claude/lib/docs/DocsSurfaceDeltaCommands.psm1`, `.claude/lib/docs/Invoke-DocsCommand.ps1`, `.claude/lib/docs/DocsProfileCommands.psm1`, `.claude/lib/docs/templates/_docs-quality.yml`, their bundle copies, `.claude/settings.json`, `core.json`, four `feature-review` surfaces with bundle copies, and ten test files.

**Scope:** full branch diff, `origin/epic/documentation-estate-tooling-integration` at merge base `e3e4aa551808a25c436337bf0dbcf298421a34d6` to head `48892dc051bf9ad257f8e7a3dd2ed0e0c9c073da` (65 commits, 104 files, 5992 insertions, 169 deletions). The merge base equals the fetched epic tip. `artifacts/pr_context.summary.txt` records this head and range.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 22 files (6 production, 6 bundle copies, 10 test) | 16631 tests (merged parallel run) | PASS 16621 pass, 0 fail, 10 disabled | 69.29% lines | 72.28% lines | 97.32% |
| JSON | 4 files | N/A | PASS validation by contract suites | N/A (config files) | N/A (config files) | N/A |

Python, TypeScript, C# and Bash have zero changed files on the branch, so no coverage verdict applies to them.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files
- PowerShell baseline coverage artifact: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/baseline/pester-coverage.2026-11-04T15-45.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`
- Per-language comparison summary: section 1.2.1

**Non-negotiable verdict rule:** numeric baseline and post-change metrics are present for PowerShell, the only coverage language with changed files.

**Fail-closed rule:** every required baseline, QA and coverage artifact exists.

**Evidence rule:** figures were read from the named artifacts or from commands run in this review (Appendix B).

---

## Executive Summary

**Overall verdict: PARTIALLY COMPLIANT. Review-Verdict: REMEDIATION_REQUIRED (two autonomous findings).**

Toolchain and coverage results are clean and were re-measured at head: formatter 0 differences and analyzer 0 findings over 22 files, 1401 touched and contract Pester tests passing, 98 push-down contract tests passing, repo-wide PowerShell line coverage 95.25%, and every new file at or above 93.59%.

Two defects were found by running the hook, and neither is visible in coverage or in the suites:

- **F1 (Blocker).** With the gate enabled and no receipt, the hook allows the merge of an integration pull request when the command does not resolve to the pull request it is about to merge: a branch-name selector, a GraphQL node identifier, or a second merge in the same command.
- **F2 (Blocker).** With the gate enabled, a profile that exists but cannot be read makes the hook return `allow`. This violates the fail-fast rule in `.claude/rules/general-code-change.md`.

Both sit in the enforcement path that is the purpose of this feature.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
|---|---|---|
| Independence | PASS | Seeded shuffles at seeds 1034, 20261106 and 777: 432 passed, 0 failed (`evidence/regression-testing/pester-isolation.2026-11-07T01-02.md`). |
| Isolation | PASS | Seams mock `gh`, file and process boundaries; pure predicates take strings. |
| Fast execution | PASS | 1401 tests in 83.5 s in this review. |
| Determinism | PASS | No clock or wall-time use; the shuffle test uses a fixed printed seed. |
| Readability | PASS | Arrange, Act and Assert comments and descriptive names in the new suites. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline Coverage Documented | PASS | 69.29% lines (19519 covered, 8652 missed), three scan folders, P0-T5. |
| No Coverage Regression | PASS | Three-folder 72.28%; `Invoke-DocsCommand.ps1` 87.74% to 89.44%; `DocsProfileCommands.psm1` 97.30% to 97.33%. The uncovered lines (214-230 and 253-255; 168-169) are not changed lines. |
| New Code Coverage at or above 85% | PASS | `DocsCompleteGate.psm1` 100.00% (38/38), `DocsSurfaceDelta.psm1` 100.00% (70/70), `DocsSurfaceDeltaCommands.psm1` 97.33% (73/75), `enforce-docs-complete-gate.ps1` 93.59% (73/78). |
| Repo-wide line coverage at or above 85% | PASS | 95.25% (32398 covered, 1617 missed, 344 files), root LINE counter of the merged artifact. |
| Positive Flows | PASS | Allow paths for disabled gate, non-merge, non-integration target and passing receipt. |
| Negative Flows | PARTIAL | Each reason code is tested with a numeric selector. No test covers a branch-name selector, a GraphQL node identifier, a chained merge, or a read failure on the profile (F1, F2). |
| Edge Cases | PASS | Revision case and length mismatch, `--match-head-commit`, unresolved base, absent base snapshot, stale snapshot, option-injection base. |
| Error Handling | PARTIAL | No test drives a throwing file seam (F2). |
| Concurrency | N/A | No concurrent behavior in the delivered code. |
| State Transitions | N/A | The hook and commands are stateless. |

Branch coverage: Pester measures no branch counter, so no branch gate applies to PowerShell (`.claude/rules/powershell.md`).

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 69.29% lines -> Post-change: 72.28% lines. Change: +2.99% lines. New/changed-code coverage: 97.32%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/qa-gates/coverage-delta.2026-11-07T00-07.md`.

The baseline and post-change figures use the same three scan folders. The repo-wide figure from the merged full run is 95.25%, and no equivalent full-run baseline was recorded.

Artifact freshness: the merged artifact was written at 2026-11-07T00:58Z at `c36fdbf9e`, and `artifacts/pester/pester-junit.xml` holds 16631 tests with 0 failures. Every commit from `339a8df23` (the last source change) to head changes only the feature folder, so the artifact describes head production code.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|---|---|---|
| Arrange-Act-Assert | PASS | New suites follow the three-part structure. |
| Clear failure messages | PASS | `-Because` carries the seed in the shuffle test. |
| Assertions able to fail | PARTIAL | The BOM assertion cannot fail; see code review finding N1. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|---|---|---|
| No external services | PASS | `gh` and `git` are reached only through seams in tests. |
| No temporary files | PASS | Zero matches for the five prohibited tokens in the 10 new or edited test files, re-run in this review. |
| No mutable global state | PASS | Suites remove imported modules in `AfterAll`. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|---|---|---|
| Audit produced | PASS | This artifact. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|---|---|---|
| Policies read in order | PASS | `evidence/baseline/phase0-instructions-read.2026-11-04T03-15.md`. |
| Baseline captured | PASS | `evidence/baseline/`. |

### 2.2 Design Principles

| Principle | Status | Evidence |
|---|---|---|
| Simplicity | PASS | Pure predicates, thin hook. |
| Reusability | PASS | Reuses the epic gate scope predicate, the bounded `gh` seam and the payload readers. |
| Separation of concerns | PASS | I/O is limited to hook seams and the command context. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|---|---|---|
| File size | PASS | Largest production file 535 lines; no covered file is at or above 700 lines. `config/file-size-baseline.json` is not in the diff. |
| Test location | PASS | Mirrors `tests/scripts/`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|---|---|---|
| Naming | PASS | Approved verbs; 0 analyzer findings. |
| Help text | PASS | Comment-based help on every function; hook header lists residual limits, although F1's cases are not among them. |

### 2.5 After Making Changes - Toolchain Execution

| Stage | Status | Evidence |
|---|---|---|
| Formatting | PASS | 0 differences over 22 files. |
| Linting | PASS | 0 findings over 22 files. |
| Type checking | N/A | Not applicable to PowerShell. |
| Architecture boundary | PASS | `hook-dependency-guard-completeness.Tests.ps1` 683 passed. |
| Unit tests | PASS | 1401 passed here; 16631 tests, 0 failures in the merged run. |
| Contract | PASS | 98 push-down tests passed; Codex generator check exit 0. |
| Integration | PARTIAL | Real-process runs in this review found F2 and confirmed the surface-delta path; the branch's suites contain no real-process hook run. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|---|---|---|
| Deviations recorded | PASS | `plan.2026-10-30T18-40.md` `## Notes`. |
| Requirement text current | PARTIAL | `spec.md` still states `900008` anchors, provisional OQ-1 and `<FEATURE>/evidence/coverage/` (code review finding N5). |

Error handling (`## Error Handling and Logging`): **FAIL** for "Do not silently ignore errors": F2 converts a read failure into an allow decision.

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|---|---|---|
| PowerShell 7+ | PASS | Analyzer settings; real runs on 7.x. |
| PoshQC settings | PASS | `pssa.settings.psd1`, CRLF normalized before comparison, per the PoshQC procedure. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|---|---|---|
| Advanced functions | PASS | `CmdletBinding` throughout. |
| Seams | PASS | `Invoke-DocsOnlyGhExe`, file seam, root seam, `[scriptblock]` process parameter. |
| Failures raised, no silent handling | FAIL | F2: `Get-DocsCompleteGateFileText` has no handling and the hook does not set `$ErrorActionPreference`, so the exception does not stop the decision. |

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
| Valid JSON | PASS | `claude-settings.Tests.ps1` 10 passed; `core.json` parsed in this review. |

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
| Wrapper mocked, not executable | PASS | `Invoke-DocsOnlyGhExe` and the process parameter. |

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

### enforce-docs-complete-gate.ps1 (41 tests)

Uncovered lines 261 and 284-289 are the default payload seam and the process tail. A real-process run in this review exercised the tail: the hook emitted one decision line and exited 0 for allow and deny.

### DocsCompleteGate.psm1 (35 tests)

All lines covered. Mutants M1 (ignore-case revision), M2 (any base) and M3 (truthy enabled) were killed.

### DocsSurfaceDelta.psm1 (17 tests)

All lines covered. M4 (pin change ignored) was killed; M5 (no retained-entry check) survived (finding N2).

### DocsSurfaceDeltaCommands.psm1 (15 tests)

Lines 96-97 (non-object artifact) are uncovered. M6 and M7 are inconclusive because the control run of this suite failed in the scratch copy. Worktree runs pass 15 of 15, and the real-process run confirmed both behaviors.

### Invoke-DocsCommand.ps1 revision context (23 tests)

M11 (`--end-of-options` dropped) was killed; M10 (BOM removal deleted) survived (finding N1).

---

## 6. Test Execution Metrics

| Run | Passed | Failed | Skipped | Duration |
|---|---|---|---|---|
| Review, 20 touched and contract suites at head | 1401 | 0 | 0 | 83.5 s |
| Review, five push-down Python suites | 98 | 0 | 0 | 1.34 s |
| Executor, merged parallel run at `c36fdbf9e` | 16621 | 0 | 10 | 567.89 s |

The executor's single-process run has two failures in `Enter-DrmCopilotShell.Tests.ps1`. The evidence records the same tests failing at the merge base on this host, and they are outside the diff. The difference between that run and the parallel run was not investigated.

---

## 7. Code Quality Checks

| Check | Result | Evidence |
|---|---|---|
| Invoke-Formatter | PASS | 0 differences. |
| PSScriptAnalyzer | PASS | 0 findings. |
| actionlint on the template | PASS | Exit 0. |
| Quality tiers | PASS | `check_quality_tiers.py`: 30 entries, 30 projects. `.claude/hooks` and `.claude/lib/docs` are T3, so no property-test or mutation gate applies. |
| Evidence locations | PASS | `validate_evidence_locations.py` exit 0. |

### Evidence Location Compliance

The validator exited 0 and the branch diff holds no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/` or `artifacts/coverage/`. The plan replaced the criterion's `evidence/coverage/` with `evidence/qa-gates/`; `coverage` is not a canonical sub-path in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, so that replacement is correct.

### Policy Rule: modified-workflow-needs-green-run

Not triggered. The diff has no path under `.github/workflows/`, `.github/actions/` or `scripts/benchmarks/`. The template is consumer data under `.claude/lib/docs/templates/`.

### Documentation Surface Check

Not applicable: `docs/documentation-estate/docs-profile.json` is absent on the branch head.

### Rejected Scope Narrowing

None. The caller supplied no narrowing.

---

## 8. Gaps and Exceptions

### Identified Gaps

- F1 and F2 (section 10 and `remediation-inputs.2026-11-07T01-25.md`).
- The CI-dependent criterion is pending: the branch is pushed, but no pull request exists yet. The S9 CI green gate remains responsible for it.
- `evidence/regression-testing/pester-isolation.2026-11-07T01-02.md` describes an owner directive whose origin the orchestrator could not confirm. Acceptance of P7-T8 does not rest on it, because all three runs completed.

### Approved Exceptions

- Plan deviation for spec criterion T11: 8 whitespace-only lines in `New-DocsCommandContext` are required by `PSAlignAssignmentStatement`. Verified: the diff has 8 removed lines, and 0 with `--ignore-all-space`.

### Removed/Skipped Tests

None on this branch. The 10 disabled tests in the merged run are not in the diff.

---

## 9. Summary of Changes

### Commits in This PR/Branch

65 commits from `c870afa77` to `48892dc05`, including three integration merges. A Python tokenizer fix (`1332ba34f`) was reverted in `1947cc0a3`, so no Python file is in the net diff.

### Files Modified

- Production: 4 new PowerShell files, 2 edited, 1 YAML template, each with a byte-identical bundle copy.
- Configuration: both settings copies and `core.json`.
- Review surfaces: 4 `feature-review` files, each with a bundle copy.
- Tests: 5 new suites, 5 edited files.
- Feature folder: plan, spec, user story and evidence.

---

## 10. Compliance Verdict

### Overall Status: PARTIALLY COMPLIANT

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PARTIAL. All gates are clean; the error-handling rule fails on F2.

#### Language-Specific Code Change Policy (Section 3)

PARTIAL. PowerShell failure handling fails on F2. JSON is compliant.

#### General Unit Test Policy (Section 1)

PARTIAL. Coverage is compliant; negative and error-path scenarios are incomplete for F1 and F2.

#### Language-Specific Unit Test Policy (Section 4)

PASS.

### Metrics Summary

| Metric | Value | Verdict |
|---|---|---|
| PowerShell repo-wide line coverage | 95.25% | PASS |
| PowerShell new-file line coverage | 97.32% combined, 93.59% lowest | PASS |
| PowerShell changed lines | 25 executable added lines, 0 uncovered | PASS |
| Python, TypeScript, C#, Bash coverage | zero changed files | N/A |

### Recommendation

Do not open the pull request yet. Run one remediation cycle for F1 and F2, then re-audit.

---

## Appendix A: Test Inventory

### Complete Test List

| Suite | Passed |
|---|---|
| `enforce-docs-complete-gate.Tests.ps1` | 41 |
| `hook-dependency-failure.Claude.Tests.ps1` | 194 |
| `hook-dependency-failure.SpecialCases.Tests.ps1` | 15 |
| `PreToolUsePayload.Contract.Tests.ps1` | 86 |
| `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` | 12 |
| `DocsCompleteGate.Tests.ps1` | 35 |
| `DocsSurfaceDelta.Tests.ps1` | 17 |
| `DocsSurfaceDeltaCommands.Tests.ps1` | 15 |
| `DocsInitTemplate.DocsWorkflow.Tests.ps1` | 17 |
| `DocsPageTemplates.Tests.ps1` | 9 |
| `DocsProfileCommands.Tests.ps1` | 22 |
| `Invoke-DocsCommand.Tests.ps1` | 47 |
| `Invoke-DocsCommand.RevisionContext.Tests.ps1` | 23 |
| `Docs.Manifest.Tests.ps1` | 7 |
| `DocsNeutrality.Tests.ps1` | 104 |
| `ClaudeLibModuleConvention.Tests.ps1` | 6 |
| `hook-dependency-guard-completeness.Tests.ps1` | 683 |
| `hook-imported-modules-no-stdout.Tests.ps1` | 25 |
| `enforcement-hooks-no-python-invocation.Tests.ps1` | 33 |
| `claude-settings.Tests.ps1` | 10 |

## Appendix B: Toolchain Commands Reference

Commands ran against the worktree. Probe scripts were session-scoped and are described in `code-review.2026-11-07T01-25.md`. The MCP template resolver is not available to this agent, so this artifact follows `docs/features/templates/policy_audit/` and the headings in `scripts/dev_tools/validate_policy_audit_artifact.py`.

```text
# Formatting and linting: per changed .ps1 and .psm1 file
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-Formatter -ScriptDefinition <LF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1

# Tests: plain Pester, no coverage output, so executor artifacts stay intact
New-PesterConfiguration; Run.Path = <20 suites>; Invoke-Pester -Configuration $cfg
poetry -C <worktree> run python -m pytest --rootdir <worktree> -c <worktree>/pyproject.toml -o addopts="" -q -p no:cacheprovider <five push-down suites>

# Contract and policy checks
python -m scripts.dev_tools.generate_codex_agent_variants --check
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
python scripts/dev_tools/check_quality_tiers.py
actionlint <copy of _docs-quality.yml>

# Coverage: read from the existing artifact, not regenerated
artifacts/pester/powershell-coverage.xml (root and per-file LINE counters, per-line ci values)

# Parity
git rev-parse HEAD:<source> and HEAD:<bundle copy> for 12 pairs
```
