# Policy Compliance Audit: Stage G, Less Evidence and the CI Cross-check (Issue #1097)

**Audit Date:** 2026-11-08
**Branch:** `feature/reduce-feature-cycle-time` @ `3f46b17db132e54ff32e20620097250c3077eca0`
**Base:** `main`; merge base `992d6849455d54c942e69748b768c67d8cfd2fef`, which equals `origin/main` after `git fetch`. `git merge-tree --write-tree origin/main HEAD` exits 0. `artifacts/pr_context.summary.txt` (generated 2026-11-08 13:43:20 UTC) names head `3f46b17db132e54ff32e20620097250c3077eca0` and resolves `origin/main @ 992d6849455d54c942e69748b768c67d8cfd2fef`, so it is current for this head.
**Work Mode:** full-feature (AC sources: `spec.md` and `user-story.md`)
**Review type:** First review of PR G (stage G per `## Delivery Stages`), plan `plan.2026-11-07T12-43.md`, ledger entry `0009`, after the crash re-landing commits `13a1340ac` and `38517b6b3`.
**Code Under Test:** merge base `992d6849455d54c942e69748b768c67d8cfd2fef` of `main` and reviewed head `3f46b17db132e54ff32e20620097250c3077eca0`; the diff between them lists the changed files (74 files over 23 commits, two of them merges of `origin/main`). This audit covers all of them.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 3 test files (1 new, 2 modified), 0 production | 19666 | 0 failures, 0 errors, 10 disabled | 94.18% lines repo-wide (stage G Phase 0, 24954 of 26496) | 95.56% lines repo-wide (35308 of 36947) | N/A - no production PowerShell file changed |
| Python | 0 files | 16537 passed (gate run) | 0 failed, 6 skipped | 96.99% lines, 94.17% branches (stage G Phase 0) | 97.11% lines, 94.37% branches | N/A - zero changed Python files |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Python, TypeScript, C#, and Bash have zero changed files on the branch. The other changed files are Markdown, TOML agent definitions, and a stored patch, which carry no coverage obligation. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/stage-g-powershell-test-baseline.2026-11-08T03-35.md` (one `Invoke-PoshQCParallelTest` run, 16132 tests, 0 failures, 94.18% repo-wide lines).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written at 2026-11-08T13:27Z by the P3-T2 run recorded in `evidence/qa-gates/stage-g-powershell-test.2026-11-08T13-27.md`. The reviewer parsed the root LINE counter: 35308 covered, 1639 missed (95.56%).
- Python post-change artifact (no changed Python file; recorded for the repo-wide row): `artifacts/python/lcov.info`, written by the P3-T3 run recorded in `evidence/qa-gates/stage-g-python-test.2026-11-08T13-33.md`. The reviewer summed its records: 34287 of 35308 lines (97.11%) and 12645 of 13400 branches (94.37%).
- TypeScript baseline coverage artifact: N/A - no pre-change run; zero changed TypeScript files, so no Jest run is owed.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note:
  - The gate runs ran at 13:12Z to 13:33Z on the tree after the first `origin/main` merge `ed6dc022a` (PRs #1124 and #1125) and before the re-landing commits.
  - The tree after `38517b6b3` differs from the tree after `c3ac98596` only by one sentence of `0009-less-evidence.md`. The reviewer confirmed this with `git diff --stat c3ac98596 38517b6b3`.
  - The second merge `3f46b17db` (PR #1126, release 1.2.0) changes only six files: `.codex/config.toml`, its bundle copy, and the `package.json` and `package-lock.json` of `extensions/drm-copilot` and `packages/mcp-server`. It changes no PowerShell or Python file, so the gate figures describe this head's code.
  - Test-count and coverage-denominator growth between baseline and gate comes from the `ed6dc022a` merge. The executor's gate artifacts attribute it by suite: +3362 Pester tests from 126 added test files, +90 net from 9 modified ones, +10451 PowerShell lines, and +267 pytest tests with 1814 added statements. Stage G itself adds +82 Pester tests (LEC- 77, RG- 2, RGC- 1, OCR- 2) and no Python test.

---

## Executive Summary

Stage G reduces review evidence in three places and adds the CI cross-check that replaces it. The three reductions are:

- One final-QC static artifact per language replaces the per-step format, lint, and type-check artifacts, and reviewers read it instead of re-running those checks.
- The Python repo-wide total is read from the CI step `Enforce Python coverage thresholds`.
- The policy-audit `Code Under Test` list and the section 9 commit and file lists give way to the merge base and the reviewed head.

The cross-check works as follows. The reviewer writes `## CI Cross-check`. Under `review_mode: "concurrent"`, the orchestrator compares each row with CI at the join, and a mismatch becomes a synthetic `autonomous` finding that the merge guard denies with `REVIEW_GATE_NOT_PASSED`. Ledger entry `0009` records the reduction with a stored patch.

Reviewer checks at this head:

| Check (reviewer, this head) | Result |
|---|---|
| `git diff --stat c3ac98596 38517b6b3` | One file, `0009-less-evidence.md`, one line changed: the re-landing changes nothing but the history sentence |
| `git diff 992d6849455d 13a1340ac` over the 56 paths of `38517b6b3` | Empty: the withdrawal returns every reduction path, the entry, the row, and the patch to the `main` state |
| `git diff 13a1340ac 38517b6b3` against `git diff 992d6849455d HEAD`, both over those 56 paths | Same MD5: the branch delivers exactly what `38517b6b3` lands on those paths |
| Branch-diff paths outside the 56 and the feature folder | Only `EpicMergeGateReview.Cases.Helpers.ps1` and `OrchestratorStateConcurrentReview.Tests.ps1` (P1-T2 control cases, which add a test and reduce nothing) |
| Stored patch regenerated as `git diff --binary --no-renames 992d6849455d HEAD` over the 53 non-ledger paths | Byte-identical to `patches/0009-less-evidence.patch` (`cmp`) |
| `git apply -R --check` of the `0009` patch on the head tree | Exit 0 |
| In-memory `Test-ProcessReductionLedger` over `Read-ProcessReductionLedger` | `IsValid` true, 0 errors |
| In-memory `Invoke-ProcessReductionChain` over `Read-ProcessReductionChainInput` (9 entries) | `IsValid` true, 0 errors; `-StopBefore` each of `0001`, `0006`, `0008`, `0009`: `IsValid` true, 0 errors |
| Chain probe: `**CI cross-check.**` changed to `**CI crosscheck.**` in the in-memory `.claude/skills/orchestrate/SKILL.md` | `IsValid` false: `0009` hunk at +394 not found |
| Chain control: line appended to the end of the same file | `IsValid` true |
| D13: occurrences of `Phase 0 baseline`, `regression on changed lines`, `Baseline Coverage Documented`, `No Coverage Regression` across `.claude`, `.agents`, `.github`, `.codex`, `extensions`, and `docs/features/templates`, base against head | 539/539, 40/40, 2/2, 2/2 |
| Old per-step text `one final-QC artifact per QC command step` or `each final-QC step artifact` in skills, agents, bundles, and templates at head | 0 occurrences |
| Final main merge `3f46b17db` paths named in any ledger entry | None |
| `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan` on `plan.2026-11-07T12-43.md` and `plan.2026-11-07T22-28.md` | Both pass |

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists on `main`; no project is added and no production module changes, so no tier obligation is triggered)
- ✅ `.claude/rules/tonality.md`
- ✅ Process-reduction ledger standing rule (one reduction, `0009`, landed whole in `38517b6b3` with its entry)
- ✅ Owner Condition 2 and decision D13 (no baseline task, evidence, or comparison reduced)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md` (test files only)
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --short` at head was empty before the reviewer's checks.
- ✅ Reviewer probes ran from command text in the session scratchpad against in-memory copies of the ledger and live text. One `poetry -C <worktree>` call created an empty, gitignored `.venv` in the item worktree; the reviewer removed it. Afterwards `git status` lists only this review's four artifacts and the two check-off lines in `spec.md` and `user-story.md`.

---

## Rejected Scope Narrowing

The audit covers the full diff `992d6849455d..3f46b17db`. Caller statements considered:

- "This PR carries stage G per `## Delivery Stages`, with plan `plan.2026-11-07T12-43.md` and ledger entry `0009`. The diff also carries the stage H plan `plan.2026-11-07T22-28.md`, which is not part of this delivery." This statement names which acceptance criteria the PR owes; `spec.md` `## Delivery Stages` says the same. It does not exclude a file from the audit. The stage H plan is in the branch diff and was audited: it passes the Python CLI plan validator, and it owes no criterion.
- "Owner rule for tests: tests run in parallel only, one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate. No single-process, seeded-shuffle, reversed-order, or comparison runs are expected or to be requested." This matches `spec.md` `## Testing Rule`. It removes no toolchain stage and no coverage check. The reviewer made no Pester or pytest run and judged the gates from the executor's single gate runs and their artifacts. Chain checks ran as in-memory module calls, which are not test runs.
- "`ci.yml` is dispatched on this head as run 42486253596, whose result the orchestrator reads from `gh`; you need not wait for it." Recorded. `gh run view` showed the run `in_progress` on head `3f46b17db`. Most jobs had completed with success. `quality-checks7 / Code Quality & Tests (3.13)` and PowerShell QC shards 1 to 3 were still in progress. No stage G criterion is CI-dependent, so the run is pending-CI and not a finding.

No statement narrowed the audit, and none was applied as a narrowing.

---

## Process-Reduction Ledger Compliance

`docs/engineering/process-reductions/` exists, so the standing rule applies.

- **One reduction, its own commit.** `38517b6b3` (`docs(process-reductions): land less evidence whole with entry 0009 (reduction: 0009)`) carries all 53 reduction paths (skills, agents, generated Codex variants, bundles, templates, and the new contract test), entry `0009`, its `README.md` row, and its stored patch. That is 56 paths and nothing else. `git show --name-only` matches the entry's `## Files Changed` list.
- **Crash history.** `c58c16243` (`wip(1097): checkpoint ...`) carried the reduction edits without the entry. `fe81a1118` then carried the entry, row, and patch without the edits, and `3681735fc` corrected one entry sentence. `13a1340ac` reversed the stored patch and withdrew the entry, which returned all 56 paths to their `main` state. `38517b6b3` re-landed the whole reduction. No history was rewritten. The repository merges pull requests with merge commits, so `main` will keep these intermediate commits. `0009` `## Summary` names `c58c16243` and the withdrawal.
- **Token commits.** Three commits carry `reduction: 0009`: `fe81a1118`, `3681735fc`, and `38517b6b3`. Several token commits per entry follow branch precedent (`0006`, `0007`, `0008`). The entry's sentence "in the one commit whose subject carries `reduction: 0009`" reads as if one commit carried the token; the code review records this as CR1.
- **Entry structure.** `0009` carries `## Summary` (with `reduction: 0009`, `Date:`, `Issue:`, and `Merge commit: pending (PR #1097)`), `## Reason and Evidence`, `## Files Changed`, `## Stored Patch`, `## Revert Steps` with the six labels in order, and `## Revert Signals`. The reviewer's in-memory `Test-ProcessReductionLedger` reports it valid.
- **Stored patch is current.** Byte-identical regeneration; reverse check exit 0.
- **Revert chain (stage R enforcement).** Full chain and each `-StopBefore` replay valid with 9 entries. An edit inside a `0009` hunk fails the chain, and an edit outside every region does not.
- **Merge commit lines.** `0009` uses the issue number as a stand-in, because no stage G pull request exists yet (`gh pr list --head feature/reduce-feature-cycle-time` lists only merged PRs #1100 to #1123). `0008` still reads `pending (PR #1123)`, although PR #1123 merged as `e33635c14` at 2026-11-08T00:38Z. The README permits a back-fill by the next stage or a final records commit, so this is not a blocking finding; the code review records it as CR3.

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`.

## Documentation Surface Check

`docs/documentation-estate/docs-profile.json` is absent on the branch head, so the check does not apply and produces no finding.

## Evidence Location Compliance

The branch diff contains no path under `artifacts/`, so none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output. Stage G evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, and `qa-gates/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | `less-evidence-contract.Tests.ps1` reads tracked files read-only per row; the new control cases build in-memory objects; all ran in the one parallel gate. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `LEC-` row per surface and token group; one guard row; one validator function per `OCR-` case. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | 77 `LEC-` rows of text reads; in-memory cases. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, or process call in the new tests. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Row tables by surface; `-Because` messages name the path; Arrange-Act-Assert comments in the `OCR-` cases. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Stage G Phase 0: `stage-g-powershell-test-baseline.2026-11-08T03-35.md`, `stage-g-python-test-baseline.2026-11-08T03-38.md`, `stage-g-powershell-static.2026-11-08T03-28.md`, `stage-g-baseline-text.2026-11-08T03-40.md`. |
| **No Coverage Regression** | ✅ PASS | PowerShell 94.18% to 95.56% repo-wide; Python 96.99% to 97.11% lines and 94.17% to 94.37% branches. No production file changed. |
| **New Code Coverage** | ✅ PASS | No production code is added; the new file is a test. |
| **Modified Files** | ✅ PASS | The two modified PowerShell files are tests; no production file is modified. |
| **Comprehensive Coverage** | ✅ PASS | `LEC-` rows pin each reduced and each kept token on every copy; the guard row and two `OCR-` cases pin the K7 synthetic entry on the guard and both validator functions. |
| **Positive Flows** - Valid inputs | ✅ PASS | `OCR-CROSS-CHECK-SYNTHETIC-ENTRY-VALID`; `LEC-*` presence rows. |
| **Negative Flows** - Invalid inputs | ✅ PASS | `RG-`/`RGC-ci-cross-check-synthetic-after-pass` (deny); `OCR-CROSS-CHECK-SYNTHETIC-ENTRY-BLOCKS-COMPLETION`; `LEC-SCOPE-LISTING-*` absence assertions. |
| **Edge Cases** - Boundary conditions | ✅ PASS | `LEC-HELPER-REPORTS-ABSENT-TOKEN` proves the helper reports a missing token. |
| **Error Handling** - Error paths | ✅ PASS | The guard row expects `REVIEW_GATE_NOT_PASSED` with `NoProcess`. |
| **Concurrency** - If applicable | N/A | No concurrent behavior is added. |
| **State Transitions** - If applicable | ✅ PASS | The PASS-then-synthetic `review_outcomes` sequence is the transition under test. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.18% repo-wide lines (stage G Phase 0) -> Post-change: 95.56% repo-wide lines. Change: +1.38 points. The denominator grew by 10451 lines from production PowerShell added by the `ed6dc022a` main merge. No PowerShell production file changed on this branch; the three changed PowerShell files are tests. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/stage-g-powershell-test-baseline.2026-11-08T03-35.md`, `evidence/qa-gates/stage-g-powershell-test.2026-11-08T13-27.md`.
- Python: zero changed files; no comparison is owed. Recorded for completeness: Baseline: 96.99% lines and 94.17% branches -> Post-change: 97.11% lines and 94.37% branches. Change: +0.12 and +0.20 points, all from the main merge. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/baseline/stage-g-python-test-baseline.2026-11-08T03-38.md`, `evidence/qa-gates/stage-g-python-test.2026-11-08T13-33.md`.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.
- Bash: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | `-Because "$Path must ..."` on every `LEC-` assertion; the `OCR-` cases state the reason. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comments in the new `OCR-` cases. |
| **Document Intent** | ✅ PASS | The new suite's comment-based help states what it pins and that it writes nothing. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No process, network, or git call in the new tests. |
| **Use Mocks/Stubs** | ✅ PASS | The guard row runs through the existing `NoProcess` harness. |
| **Environment Stability** | ✅ PASS | No temporary file is created; tracked files are read with `Join-Path` and exact case. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-08T13-56.md` and `feature-audit.2026-11-08T13-56.md`; executor self-review `self-review.2026-11-08T13-38.md`, which predates the re-landing (CR2). |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Spec D5, D13, K7, and K9 (added in its own commit `cfe8df45f`). |
| **Read existing change plans** | ✅ PASS | `plan.2026-11-07T12-43.md`; all 20 tasks checked. |
| **Document the plan** | ✅ PASS | The plan's `## Re-derived Dispositions`, `## Surfaces and Baseline-Adjacent Places`, and `## Test Dispositions` match the diff. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Text edits beside existing lines; no hook or validator change. |
| **Reusability** | ✅ PASS | The cross-check reuses the existing `review_outcomes` shape and guard denial. |
| **Extensibility** | ✅ PASS | The cross-check acts only under the existing `review_mode` key; a sequential run is unchanged. |
| **Separation of concerns** | ✅ PASS | The reviewer writes claims; the orchestrator compares them with CI. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One new contract suite under `tests/scripts/claude-runtime/`, beside the other wording suites. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical counts of changed covered files: `EpicMergeGateReview.Cases.Helpers.ps1` 361, `OrchestratorStateConcurrentReview.Tests.ps1` 270, `less-evidence-contract.Tests.ps1` 253. No covered file reaches 700. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | No public function is added. |
| **No circular dependencies** | ✅ PASS | No import edge is added. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `LEC-STATIC-ARTIFACT-<Id>`, `ci-cross-check-synthetic-after-pass`. |
| **Docs/docstrings** | ✅ PASS | Comment-based help on the new suite and its helper. |
| **Comment why, not what** | ✅ PASS | The entry states why the older hunks are not regenerated. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `stage-g-powershell-static.2026-11-08T13-11.md`: three files `Already formatted`; read from the static artifact and not re-run. |
| **2. Linting** | ✅ PASS | Same artifact: analyzer 0 findings in each file. |
| **3. Type checking** | N/A | PowerShell has no type-check stage. |
| **4. Testing** | ✅ PASS | Pester 19666 tests, 0 failures; pytest 16537 passed, 0 failed. |
| **Full toolchain loop** | ✅ PASS | No fix followed the gates; the re-landing changed only one entry sentence outside every test and patch region. |
| **Explicit reporting** | ✅ PASS | Every artifact carries timestamp, command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9 and entry `0009`. |
| **Design choices explained** | ✅ PASS | Spec K9; entry `## Reason and Evidence` and `## Stored Patch`. |
| **Update supporting documents** | ✅ PASS | All skill, agent, and template copies and bundles updated; push-down and Codex wrapper contract tests pass in the pytest gate. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python file changed. Not applicable.

### Section 3B: PowerShell Code Change Policy Compliance

Only test files changed. Formatting: `Already formatted`; analyzer: 0 findings, both from `stage-g-powershell-static.2026-11-08T13-11.md`. No production rule applies.

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file changed. Not applicable.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test changed. Not applicable. The pytest gate ran the push-down and policy-audit validator tests that this stage relies on, and all passed.

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Run through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | `Invoke-PoshQCParallelTest`. |
| **Focused Unit Tests** | ✅ PASS | One `LEC-` row per surface; one row per guard case. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1` beside the other contract suites. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed. Not applicable.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Static artifact per language | `LEC-STATIC-ARTIFACT-<Id>` (6 contract copies, 4 planner and executor sources) | New text present | ✅ |
| CI cross-check section | `LEC-CROSS-CHECK-<Id>` (template, `AGENTS.md`, 6 workflow, 4 reviewer, 4 orchestrate copies) | Section named; join comparison inside the concurrent-review section | ✅ |
| Python total from CI | `LEC-PYTHON-TOTAL-<Id>` | CI step named on each copy that owns a repo-wide row | ✅ |
| Scope listings | `LEC-SCOPE-LISTING-<Id>` | Heading kept; both subsections absent | ✅ |
| D13 baseline text | `LEC-BASELINE-HELD-<Id>`, `LEC-KEPT-<Id>` | Baseline, comparison, preflight, self-review, check-off text present | ✅ |
| K7 synthetic finding | `RG-`/`RGC-ci-cross-check-synthetic-after-pass`, `OCR-CROSS-CHECK-SYNTHETIC-ENTRY-VALID`, `OCR-CROSS-CHECK-SYNTHETIC-ENTRY-BLOCKS-COMPLETION` | Guard denies; entry valid; completion blocked | ✅ |
| Ledger | `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-END-STATE-RECORDED`, `PRC-LEDGER-SUBCHAIN-HOLDS`, `PRL-*` | Chain with `0009`; create hunk of the new suite | ✅ |

**Reviewer probes.** In-memory chain at head with an edit inside a `0009` hunk (fails) and outside every region (passes). Base-against-head counts of baseline strings (unchanged). Absence of the superseded per-step text at head.

**Discrimination.** The `LEC-` rows fail if a pinned token is removed from any copy. They do not fail if the superseded per-step bullet is reintroduced beside the new one; the code review records this as CR4. The guard row duplicates the existing `last-remediation-after-earlier-pass` deny path with a `findings` array added (CR5).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Pester | 19666 tests, 0 failures, 10 disabled (baseline 16132, 0 failures) | ✅ |
| pytest | 16537 passed, 0 failed, 6 skipped (baseline 16270) | ✅ |
| `less-evidence-contract.Tests.ps1` | 77 `LEC-` tests, 0 failed (new) | ✅ |
| Guard and validator rows | RG- 377, RGC- 233, OCR- 27; 0 failed | ✅ |
| Ledger suites | PRL- 87, PRC- 55; 0 failed | ✅ |

---

## 7. Code Quality Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| PoshQC format (check mode) | `Invoke-PoshQCFormat` over the three changed PowerShell files | `Already formatted` (static artifact, not re-run) | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 findings (static artifact, not re-run) | ✅ |
| Plan validator | `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan` | Both feature plans pass (reviewer) | ✅ |
| Evidence locations | `validate_evidence_locations.py --root <worktree>` | Exit 0 (reviewer) | ✅ |

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| `poshqc / PowerShell QC static` | pass | 0 files needing format, 0 analyzer findings over the three changed PowerShell files | `3f46b17db` | `evidence/qa-gates/stage-g-powershell-static.2026-11-08T13-11.md` |
| `poshqc / PowerShell QC shard 1` | pass | Part of 19666 tests, 0 failures | `3f46b17db` | `evidence/qa-gates/stage-g-powershell-test.2026-11-08T13-27.md` |
| `poshqc / PowerShell QC shard 2` | pass | Part of 19666 tests, 0 failures | `3f46b17db` | `evidence/qa-gates/stage-g-powershell-test.2026-11-08T13-27.md` |
| `poshqc / PowerShell QC shard 3` | pass | Part of 19666 tests, 0 failures | `3f46b17db` | `evidence/qa-gates/stage-g-powershell-test.2026-11-08T13-27.md` |
| `poshqc / PowerShell hook suites (Linux)` | pass | `RG-` 377 and `RGC-` 233 tests, 0 failures in the local run | `3f46b17db` | `evidence/qa-gates/stage-g-powershell-test.2026-11-08T13-27.md` |
| `quality-checks7 / Code Quality & Tests (3.13)` | pass | `Enforce Python coverage thresholds`: 97.11% lines, 94.37% branches; 16537 passed, 0 failed | `3f46b17db` | `evidence/qa-gates/stage-g-python-test.2026-11-08T13-33.md`; `artifacts/python/lcov.info` |

Local evidence was produced on the tree before `3f46b17db`. The intervening commits change no PowerShell or Python file (Coverage Evidence Checklist), so each claim applies to the head named here. Under `review_mode: "concurrent"` the orchestrator compares these rows with `ci_gate` and `gh pr checks` at the join. At review time, run 42486253596 on `3f46b17db` had the static and Linux hook jobs complete with success; the three shards and the 3.13 quality job were in progress.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **No blocking finding.**
2. **CR1 (Minor, non-blocking):** the `0009` `## Summary` history sentence says the reduction landed "in the one commit whose subject carries `reduction: 0009`"; three commits carry the token.
3. **CR2 (Minor, non-blocking):** `stage-g-ledger-replay.2026-11-08T13-34.md` and `self-review.2026-11-08T13-38.md` describe `fe81a1118` as the reduction commit. No feature-folder record covers the re-landing; this review's checks are the only record of it.
4. **CR3 (Minor, non-blocking):** the `0008` merge-commit back-fill is outstanding.
5. **CR4 to CR6 (Nit):** recorded in the code review.
6. **CI on this head.** Run 42486253596 is in progress; the orchestrator reads its result. No stage G criterion is CI-dependent, so this is pending-CI, not a finding.

### Approved Exceptions

**None.** The withdrawal and re-landing commits were made by the orchestrator to meet Owner Condition 1. They are assessed in this audit, not treated as an exception.

### Removed/Skipped Tests

**None removed.** The `0009` patch deletes `less-evidence-contract.Tests.ps1` only when the entry is reverted.

---

## 9. Summary of Changes

Stage G replaces per-step final-QC static artifacts with one per language, reads the Python repo-wide total from CI, and drops the policy-audit commit and file listings, in exchange for a `## CI Cross-check` table that the orchestrator compares with CI at the join; the reduction lands whole in `38517b6b3` with ledger entry `0009`. The branch log and the diff from merge base `992d6849455d` to reviewed head `3f46b17db`, named under **Code Under Test**, carry the commits and files.

---

## 10. Compliance Verdict

### Overall Status: ✅ PASS

No blocking finding. Non-blocking items are recorded in the code review.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design, structure, documentation, toolchain loop

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell test-only; no other language changed

#### General Unit Test Policy (Section 1)
- ✅ Core principles, scenario coverage, coverage artifacts, and Phase 0 baseline comparison as stage E2 defined it

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 0 failures across Pester and pytest
- ✅ PowerShell 95.56% repo-wide lines; Python 97.11% lines and 94.37% branches
- ✅ Chain valid with `0009`; stored patch current; reduction landed whole in one commit

### Recommendation

**Ready to merge once CI is green.** The orchestrator's S9 gate reads `ci.yml` run 42486253596 on this head. CR1 to CR3 are optional follow-ups. CR1 and CR3 edit paths under `docs/engineering/`, outside the feature folder, so making either change in this PR requires a new review.

---

## Appendix A: Test Inventory

Pester (new): `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1` (77). Pester (modified): `tests/scripts/claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1` (one shared row, run as `RG-` and `RGC-ci-cross-check-synthetic-after-pass`), `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateConcurrentReview.Tests.ps1` (two cases).

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <worktree> fetch origin main
git -C <worktree> merge-base origin/main HEAD
git -C <worktree> merge-tree --write-tree origin/main HEAD
git -C <worktree> diff --stat c3ac98596 38517b6b3
git -C <worktree> diff 992d6849455d 13a1340ac -- <56 paths of 38517b6b3>
git -C <worktree> diff 13a1340ac 38517b6b3 -- <56 paths> | md5sum
git -C <worktree> diff 992d6849455d HEAD -- <56 paths> | md5sum
git -C <worktree> diff --binary --no-renames 992d6849455d HEAD -- <53 non-ledger paths>   # compared with cmp
git -C <worktree> apply -R --check docs/engineering/process-reductions/patches/0009-less-evidence.patch
gh run view 42486253596 -R drmoisan/drm-copilot --json status,conclusion,headSha,event,jobs
gh pr list -R drmoisan/drm-copilot --head feature/reduce-feature-cycle-time --state all
gh pr view 1123 -R drmoisan/drm-copilot --json mergeCommit,mergedAt
poetry run python scripts/dev_tools/validate_evidence_locations.py --root <worktree>
poetry -C <worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan path>
```

Reviewer probes:

- PowerShell 7, in memory: `Test-ProcessReductionLedger`, `Read-ProcessReductionChainInput`, and `Invoke-ProcessReductionChain` at head, full and with `-StopBefore` for each stored-patch entry, and with edited `LiveText` copies.
- `git grep` counts of baseline strings at the merge base and at head; `git grep` for the superseded per-step text at head.
- Parsing of `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info`; logical line counts.

Template note: the bundled template asset was not resolved through MCP in this session, because the resolver tool is not available to this agent. The structure follows `policy-audit.2026-11-08T00-11.md` and the stage G template changes (reduced `Code Under Test`, reduced section 9, `## CI Cross-check`), and the MCP validator checked this file.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-08
**Policy Version:** Current (as of audit date)
