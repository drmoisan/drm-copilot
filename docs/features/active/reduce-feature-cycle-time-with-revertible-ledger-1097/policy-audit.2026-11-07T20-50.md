# Policy Compliance Audit: Stage R Re-audit, Revertible Ledger Chain (Issue #1097)

**Audit Date:** 2026-11-07
**Branch:** `feature/reduce-feature-cycle-time` @ `2195ec4e01c54aa4fd28181f0b536de7379de4a7`
**Base:** `main`; merge base `12825cb0018a001a058aade4f65cc022f0a9ca6e` (the merge commit of PR #1112, issue #1096), which equals `origin/main` after `git fetch`. `git merge-tree --write-tree origin/main HEAD` exits 0. `artifacts/pr_context.summary.txt` was generated 2026-11-07 20:36:49 UTC for this head and resolves the range `12825cb00..2195ec4e0`.
**Work Mode:** full-feature (AC sources: `spec.md` and `user-story.md`)
**Review type:** Re-audit of PR R (stage R per `## Delivery Stages`) after two remediation cycles: `remediation-inputs.2026-11-07T18-49.md` (design: F1 and RN1, RN2) and `remediation-inputs.2026-11-07T19-38.md` (proportionate: merge of `origin/main` after PR #1112, and the later-landing revert order).
**Code Under Test:**
- `scripts/dev-tools/ProcessReductionChain.psm1` (new, 572 logical lines, T4 under `quality-tiers.yml`).
- `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` (new, 497) and `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` (new, 99).
- `docs/engineering/process-reductions/`: README (`## Entry Format` later-landing paragraph, `## Revert Order`), entries `0001`, `0004`, `0005`, `0006`, and stored patches `0001` and `0006`.
- Feature-folder records: spec, user story, plans, remediation records, and evidence.

The branch diff against the merge base is 45 files over 51 commits, one of them a merge (`d48ea60ce`). This audit covers all of them.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| PowerShell | 1 production (new), 2 test (new) | 16045 | 0 failed, 0 errors, 10 disabled | 94.01% lines repo-wide, stage R cycle 3 Phase 0 baseline reference | 94.16% lines repo-wide (24808 of 26348) | 100% on `ProcessReductionChain.psm1` (230 of 230) |
| Python | 0 files | 16213 passed, 6 skipped | 0 failed | 96.99% lines, 94.17% branches (Phase 0 baseline reference) | 96.99% lines (32456 of 33464), 94.17% branches (11828 of 12560) | N/A - zero changed Python files |
| TypeScript | 0 files | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A |
| C# | 0 files | N/A | N/A | N/A - zero changed C# files | N/A - zero changed C# files | N/A |
| Bash | 0 files | N/A | N/A | N/A - zero changed Bash files | N/A - zero changed Bash files | N/A |

PowerShell verdict: PASS. Python, TypeScript, C#, and Bash have zero changed files on the branch. Thresholds: the root `CLAUDE.md` states no coverage figure, so the defaults of 85% line and 75% branch govern. Pester measures no branch figure, so no branch threshold applies to PowerShell.

### Coverage Evidence Checklist

- PowerShell baseline coverage artifact: `evidence/baseline/stage-r-cycle3-baseline-reference.2026-11-07T19-55.md` (refers to the stage R Phase 0 baseline `evidence/baseline/stage-r-powershell-test-baseline.2026-11-07T18-01.md`, 94.01% repo-wide).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` in the item worktree, written 2026-11-07T20:21:36Z by the cycle 3 `Invoke-PoshQCParallelTest` run, parsed by the reviewer (root LINE 24808 covered, 1540 missed; `ProcessReductionChain.psm1` 230 covered, 0 missed; `ProcessReductionLedger.psm1` 195 of 195).
- Python baseline coverage artifact: `evidence/baseline/stage-r-python-test-baseline.2026-11-07T18-06.md` via the cycle 3 baseline reference.
- Python post-change coverage artifact: `artifacts/python/lcov.info`, recorded by `evidence/qa-gates/stage-r-cycle3-python-test.2026-11-07T20-25.md`.
- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files.
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files.
- Per-language comparison summary: section 1.2.1 of this audit.
- Artifact provenance note: the last commit that changes a path outside the feature folder is the merge `d48ea60ce` (committed 20:12:46 UTC). Both gate runs started after it (Pester 20:14 to 20:21 UTC, pytest 20:21 to 20:25 UTC), and every later commit changes only feature-folder paths, so the coverage files describe this head's code. The reviewer did not re-run a suite: the owner's test rule allows one run per gate, and the review skill directs the reviewer to inspect the executor's artifacts.

---

## Executive Summary

Both remediation cycles landed what their inputs required:

- **Cycle 2 (F1, RN1, RN2).** Entry `0001` step 1 now defers to README `## Revert Order` and names no entry. The `0006` hunk that adds the step was regenerated in the same commit under both tokens. The README states the keep-later-entries route. The unreachable created-path end-state branch was removed.
- **Cycle 3 (merge with PR #1112).** The merge keeps both sides of `0001`. It introduces `### Later Landing: #N`, which is reverted first within the entry's turn, and the rule that a later landing may not edit a region a higher-numbered entry records. The `0001` and `0006` stored patches were rebased under their tokens.

Reviewer checks at this head:

| Probe (reviewer, this head) | Result |
|---|---|
| `Invoke-ProcessReductionChain` over `Read-ProcessReductionChainInput` | `IsValid` true, 0 errors, 298 paths |
| Same chain with `-StopBefore` `0001` and `0006` | `IsValid` true each |
| Each created file of the `0001` patch at the `0001` turn (`-StopBefore 0001` state) | Equals its create hunk (`parallel-gate-wording.Tests.ps1`, `feature-review-coverage-narrowing-parity.Tests.ps1`) |
| `git apply -R --check` of the `0006` patch on the live tree | exit 0 |
| Search of every entry's `## Revert Steps` for a higher entry number | 0 matches in all six entries |
| Control: one line edited inside a modify hunk of the `0001` patch | 1 error naming `0001` and the path |
| **Probe: four-line-style edit appended to a file the `0001` patch creates** | **`IsValid` true, 0 errors** |
| **Probe: the same created file deleted** | **`IsValid` true, 0 errors** |
| `git log` of two attribution paths with and without `--full-history --no-merges` | Only the second form lists PR #1108's `3b21425f6`; the chain end state equals the file at `3b21425f6` and the `0001` merge's first parent equals `3b21425f6~1` |

On the caller's two points:

1. **`--full-history --no-merges` in the git-level chain gate: accepted.** The gate is item evidence, not a repository test, and it adds no ledger entry. The change corrects a measurement and does not reduce a gate. Default history simplification followed one same-content parent at the cycle 3 merge and hid PR #1108's token-free commit. The reviewer reproduced this on two of the four paths and confirmed the end-state equality that the evidence claims. The attribution test still requires a token-free non-merge commit that touched the path.
2. **The in-memory chain does not compare a created file's content: a gap, Blocking (F1), class `autonomous`.** The current ledger is consistent. Both created files match their create hunks at the `0001` turn, and the git-level gate passed. The gap is in enforcement. An unrecorded edit to a created file, or its deletion, leaves the chain test green on CI. Yet `git apply -R --check` of the stored patch then fails, and that failure is atomic for the whole patch. PR #1113 did exactly this within a day, and only the item's evidence-only git gate saw it. AC R5 says an edit inside a region fails the chain until the record is updated. README `## Revert Order` says the chain test catches such an edit on CI. Both statements are false for create hunks, so R5 is PARTIAL.

Under the owner's condition, entry `0001` would still revert months later through its fallback of hand-applied hunks. But the stored patch is the entry's primary record for about 190 paths. CI would let it decay silently on the two created files that other work keeps editing. The fix is local: compare the chain-state text with the create hunk's `Current` before the create step sets the path absent.

Non-blocking items are in the code review: RN5 (a later landing's own entry-text edit inside a higher entry's hunk), RN6 (the atomic `git apply -R` and the "hunk applied by hand" sentence), RN7 (the `0006` post-image carries the stage R pointer), and the carried RN3, RN4, N2, N3.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md`
- ✅ `.claude/rules/general-unit-test.md`
- ✅ `.claude/rules/quality-tiers.md` (`quality-tiers.yml` exists; `scripts/dev-tools` is T4)
- ✅ `.claude/rules/tonality.md`
- ✅ Process-reduction ledger standing rule (entry edits carry their tokens; no reduction made)
- ❌ Owner Condition 1 enforcement, AC R5: created-file content is not compared by the chain (F1)

**Language-specific policies evaluated:**
- ✅ `.claude/rules/powershell.md`
- N/A Python, TypeScript, C#, Bash (zero changed files)

**Temporary artifacts cleanup:**
- ✅ `git status --short` at head was empty before the reviewer's checks. Afterwards it lists this review's artifacts and the R1 and R5 checkbox changes in `spec.md` and `user-story.md`.
- ✅ Reviewer probes ran in memory through `pwsh -NoProfile -Command`. No test, production, or ledger file was modified, and no file was written to the repository.

---

## Rejected Scope Narrowing

The audit covers the full diff `12825cb00..2195ec4e0`. Caller statements considered:

- "`plan.2026-11-07T12-43.md` is the next stage's plan and is not part of this delivery." The file is in the branch diff. It was inventoried and checked for policy effect. It is a Markdown plan with no code and no AC check-off, owes no criterion in this PR, and changes no verdict.
- "Owner rule for tests: tests run in parallel only, one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate. No single-process, seeded-shuffle, reversed-order, or comparison runs are expected or to be requested." This matches `spec.md` `## Testing Rule`. It removes no toolchain stage and no coverage check. The reviewer ran no suite and judged discrimination with in-memory probes of the shipped module.
- "`ci.yml` is dispatched on this head as run 42411868745, whose result the orchestrator reads from `gh`; you need not wait for it." Recorded. No stage R criterion is CI-dependent, so the run is pending-CI and is not a finding.

No statement narrowed the audit, and none was applied as a narrowing.

---

## Process-Reduction Ledger Compliance

`docs/engineering/process-reductions/` exists, so the standing rule applies.

- **No reduction is made.** Stage R adds a check, README rules, and record corrections. The cycle 3 change to the item's git-level gate is a one-off correction of this item's evidence, not a standing reduction, so it takes no entry.
- **Entry-editing commits carry their tokens.** On the first-parent history: `670ae17ea`, `03b4d808a`, `80622f8e7` (`0001`); `9bfb86306`, `cfa2f0468`, `fc0caf3a7` (`0006`); `09b99a1f1` (`0004`); `62762acc6` (`0005`); `c117b0e04` (`0001` and `0006`, step 1 and its `0006` hunk); and the merge `d48ea60ce` (`0001` and `0006`). Commits `741ab9924`, `2b53d8016`, and `2eb502657` edit only the README among ledger files, and the README is not an entry.
- **Chain.** `PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-SUBCHAIN-HOLDS` pass in the gate run. The reviewer reproduced `IsValid` true at this head.
- **Revert steps name no dependants.** No entry's `## Revert Steps` names a higher-numbered entry. `0001` `## Partial Revert` names `0006`, as spec D12 requires.
- **Created-file content (F1, FAIL).** See the Executive Summary.

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire. The branch diff against the merge base contains no path under `.github/workflows/`, `scripts/benchmarks/`, or `.github/actions/`. The `_poshqc.yml` change in the merge `d48ea60ce` arrived from `main` (PR #1112) and is not in the diff against the merge base.

## Evidence Location Compliance

A scan of the branch diff found no path under `artifacts/` at all, so none under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `poetry run python -m scripts.dev_tools.validate_evidence_locations --root .` in the item worktree exited 0. Stage R evidence lies under `<FEATURE>/evidence/baseline/`, `other/`, and `qa-gates/`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | Fixtures are built per `It`; the ledger suite reads tracked files read-only; both suites passed in the parallel gate. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One `PRC-` identifier per behavior; 46 fixture cases and 5 committed-ledger cases. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | The reviewer's in-memory chain over 298 paths completes in seconds. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, process, or network; text compared after line-ending normalization. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Named `PRC-` cases with Arrange-Act-Assert comments on multi-step cases. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Stage R Phase 0 baselines, referenced by `stage-r-cycle3-baseline-reference.2026-11-07T19-55.md`. |
| **No Coverage Regression** | ✅ PASS | PowerShell 94.01% to 94.16%; `ProcessReductionLedger.psm1` 100% to 100%. |
| **New Code Coverage** | ✅ PASS | `ProcessReductionChain.psm1` 100% (230 of 230). |
| **Modified Files** | ✅ PASS | No existing production file changed against the merge base. |
| **Comprehensive Coverage** | ⚠️ PARTIAL | Every line is covered, but `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` pins as valid a created file edited after creation, which is the F1 gap. |
| **Positive Flows** - Valid inputs | ✅ PASS | `PRC-HUNK-PARSES-SECTIONS`, `PRC-CHAIN-NEWEST-FIRST`, `PRC-LANDING-SPLITS-PRIOR-TEXT`, `PRC-LEDGER-CHAIN-HOLDS`. |
| **Negative Flows** - Invalid inputs | ⚠️ PARTIAL | `PRC-CHAIN-REPORTS-UNLEDGERED-CONTEXT-EDIT`, `PRC-CHAIN-LATER-LANDING-OVER-HIGHER-ENTRY-FAILS`, `PRC-LANDING-EMPTY-THROWS` cover modify hunks and landings. No case rejects an unrecorded edit to, or the absence of, a created file (F1). |
| **Edge Cases** - Boundary conditions | ✅ PASS | Spaced path, no-newline marker, equal-distance tie, fenced landing heading, `-StopBefore` unknown name. |
| **Error Handling** - Error paths | ✅ PASS | Step failures are recorded with entry, landing label, and path. |
| **Concurrency** - If applicable | N/A | Pure in-memory functions. |
| **State Transitions** - If applicable | ✅ PASS | `PRC-CHAIN-ENTRY-TEXT-FROM-CHAIN-STATE`; landings parsed from chain-state entry text. |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 94.01% repo-wide lines (stage R Phase 0 baseline) -> Post-change: 94.16% repo-wide lines. Change: +0.15 points. New/changed-code coverage: 100% on the new `ProcessReductionChain.psm1` (230 of 230), above the 85% line threshold for a new file; `ProcessReductionLedger.psm1` unchanged at 100%. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/baseline/stage-r-cycle3-baseline-reference.2026-11-07T19-55.md`, `evidence/qa-gates/stage-r-cycle3-powershell-test.2026-11-07T20-21.md`.
- Python: Baseline: 96.99% repo-wide lines and 94.17% repo-wide branches -> Post-change: 96.99% repo-wide lines and 94.17% repo-wide branches. Change: 0.00 points for both. No Python file is in the branch diff. Disposition: PASS. Evidence: `artifacts/python/lcov.info`, `evidence/qa-gates/stage-r-cycle3-python-test.2026-11-07T20-25.md`.
- TypeScript: zero changed files; no comparison is owed.
- C#: zero changed files; no comparison is owed.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Ledger assertions join chain errors into `-Because`; each error names entry, landing, path, and reason. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Comments on multi-step cases. |
| **Document Intent** | ✅ PASS | File synopses; `It` names state the behavior. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No git, process, or network call. |
| **Use Mocks/Stubs** | ✅ PASS | `PRC-READ-COLLECTS-INPUT` mocks the read cmdlets inside the module scope. |
| **Environment Stability** | ✅ PASS | No file is created; paths are joined from the repository root. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit, with `code-review.2026-11-07T20-50.md` and `feature-audit.2026-11-07T20-50.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Remediation inputs 18-49 and 19-38 and their plans. |
| **Read existing change plans** | ✅ PASS | `remediation-plan.2026-11-07T18-49.md` and `remediation-plan.2026-11-07T19-38.md`. |
| **Document the plan** | ✅ PASS | Both remediation plans state their decisions, including the RN2 removal. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Landings are split by one heading rule; the chain loop gains one inner loop. |
| **Reusability** | ✅ PASS | `Invoke-ProcessReductionBlockStep` is reused for later landings. |
| **Extensibility** | ✅ PASS | Any number of later landings per entry; `-StopBefore` serves the sub-chain test. |
| **Separation of concerns** | ✅ PASS | `Read-ProcessReductionChainInput` remains the only I/O. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | The chain is its own module. |
| **At or below the 800-line hard limit** | ✅ PASS | Logical counts: 572, 497, 99. No covered file reaches 700. `config/file-size-baseline.json` is not in the diff. |
| **Public vs internal** | ✅ PASS | Six exported functions; helpers private. |
| **No circular dependencies** | ✅ PASS | The chain imports the ledger module only. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | Approved verbs, descriptive nouns. |
| **Docs/docstrings** | ❌ FAIL | README `## Revert Order` states that the chain test catches an edit inside a recorded region on CI; for a create hunk it does not (F1). |
| **Comment why, not what** | ✅ PASS | Help text states landing order and the `-StopBefore` contract. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | `stage-r-cycle3-powershell-format-lint.2026-11-07T20-13.md`: three files already formatted. |
| **2. Linting** | ✅ PASS | PSScriptAnalyzer 0 findings with `pssa.settings.psd1`. |
| **3. Type checking** | N/A | Does not apply to PowerShell. |
| **4. Testing** | ✅ PASS | Pester 16045 tests, 0 failed; pytest 16213 passed, 0 failed. |
| **Full toolchain loop** | ✅ PASS | One pass with no file changed. |
| **Explicit reporting** | ✅ PASS | Each artifact carries timestamp, command, exit code, and summary. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Section 9. |
| **Design choices explained** | ✅ PASS | README `## Revert Order`; `stage-r-cycle3-landing-order.2026-11-07T19-59.md`; `stage-r-cycle3-merge.2026-11-07T20-12.md`. |
| **Update supporting documents** | ⚠️ PARTIAL | README, entries, and patches updated consistently, except the README claim covered by F1. |
| **Provide next steps** | ✅ PASS | Section 10. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

No Python file is in the branch diff. The pytest gate ran as the plan's comparison with the Phase 0 baseline.

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | Already formatted (cycle 3 gate). |
| **Linting with PSScriptAnalyzer** | ✅ PASS | 0 findings. |
| **Fix all findings** | ✅ PASS | None open. |
| **PowerShell 7+ compatible** | ✅ PASS | Tests carry `#Requires -Version 7.0`; analyzer settings report no compatibility finding. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | `CmdletBinding` and `OutputType` on every function. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyString`, `AllowEmptyCollection`, `ValidateSet`. |
| **Avoid global state** | ✅ PASS | No script- or global-scope variable. |
| **Error handling** | ✅ PASS | `throw` with specific messages; each `catch` records entry and path; `-StopBefore` rejects an unknown name. |
| **ShouldProcess for state-changing actions** | N/A | No function writes state outside its return value. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and at or below the 800-line hard limit** | ✅ PASS | 572 logical lines. |
| **Approved verbs** | ✅ PASS | ConvertTo, Get, Invoke, Add, Test, Merge, Read. |
| **Comment why** | ✅ PASS | Comment-based help. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | Cycle 3 gate. |
| **Step 2: Analyze** | ✅ PASS | Cycle 3 gate. |
| **Step 3: Type check** | N/A | Does not apply to this language. |
| **Step 4: Test** | ✅ PASS | One `Invoke-PoshQCParallelTest` run, `ExitCode` 0. |
| **Rerun loop if needed** | ✅ PASS | No stage failed or changed a file. |

### Section 3C: TypeScript Code Change Policy Compliance

No TypeScript file is in the branch diff.

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

No Python test changed.

### Section 4B: PowerShell Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v6.x** | ✅ PASS | Run under the repository Pester through PoshQC. |
| **Use PoshQC Configuration** | ✅ PASS | `Invoke-PoshQCParallelTest`. |
| **Focused Unit Tests** | ✅ PASS | One behavior per `It`. |
| **Organization / File Naming** | ✅ PASS | `tests/scripts/dev-tools/` mirrors `scripts/dev-tools/`; `*.Tests.ps1`. |
| **Use PoshQCTest Command** | ✅ PASS | No direct `Invoke-Pester`. |

### Section 4C: TypeScript Unit Test Policy Compliance

No TypeScript test changed.

---

## 5. Test Coverage Detail

| Subject | Tests | Scenario Types | Status |
|---------|-------|----------------|--------|
| Patch parsing | `PRC-HUNK-PARSES-SECTIONS`, `PRC-HUNK-REJECTS-UNSUPPORTED` | Two hunks, spaced path, create, delete, marker; binary, quoted, malformed | ✅ |
| Hunk revert | `PRC-HUNK-REVERT-*` | Pre-image restored, line alignment, nearest occurrence, tie, absent | ✅ |
| Derived paths | `PRC-DERIVED-MAPS-<Case>` | Bundle prefixes, skill mirrors, generated variants, non-identical copy | ✅ |
| Landings | `PRC-LANDING-*`, `PRC-CHAIN-LATER-LANDING-*`, `PRC-CHAIN-STOP-BEFORE` | Split and order, empty landing, own-patch overlap, block entry, higher-entry violation | ✅ |
| Chain | `PRC-CHAIN-*` | Order, missing later record, outside edit, chain-state entry text, block consistency, derived skip, pre-images, unledgered context edit | ✅ |
| Created files | `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` | Asserts a created file edited after creation is valid and ends absent | ❌ (F1: pins the gap) |
| Committed ledger | `PRC-LEDGER-*`, `PRC-README-REVERT-ORDER-STATED` | Chain, sub-chains, end state, README rules, no exception list | ✅ |

**Reviewer probes.** In-memory chain and sub-chains at head; a created file edited and deleted in `LiveText`; a control edit inside a modify hunk; created-file equality at the `0001` turn; `## Revert Steps` search for higher entry numbers; `git log` with and without `--full-history --no-merges` on two attribution paths, with end-state equality against `3b21425f6`; `git apply -R --check` of the `0006` patch; conflict-marker scan; coverage XML parsing.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Pester Tests | 16045 (baseline 15675; merged `main` suites and eight new chain tests) | ✅ |
| Pester Failed | 0 failures, 0 errors, 10 disabled | ✅ |
| Pester Wall-clock | 440.05 s, 8 workers | ✅ |
| Pytest | 16213 passed, 6 skipped, 0 failed | ✅ |
| PowerShell line figure | 94.16% repo-wide (baseline 94.01%) | ✅ |
| Python line and branch figures | 96.99% and 94.17% repo-wide (baseline equal) | ✅ |

---

## 7. Code Quality Checks

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-PoshQCFormat` check mode | 3 of 3 already formatted | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 findings | ✅ |
| Pester Tests | `Invoke-PoshQCParallelTest` | 16045 tests, 0 failed | ✅ |

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Pytest Tests | `poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing` | 16213 passed, 0 failed | ✅ |

Reviewer checks at this head: `validate_evidence_locations` exit 0; `git merge-tree --write-tree origin/main HEAD` exit 0; chain probes as listed in section 5.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **F1 (Blocking, autonomous): the chain does not compare a created file with its create hunk.** The create branch of `Invoke-ProcessReductionPatchStep` sets the path absent without reading it. An unrecorded edit to `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1` or `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, or the deletion of either, leaves CI green and makes `git apply -R` of the `0001` patch fail as a whole. AC R5 is PARTIAL.
2. **RN5, RN6, RN7 (Minor and Nit, non-blocking):** in the code review.
3. **RN3, RN4, N2, N3 (carried):** in the code review.
4. **CI on this head.** `ci.yml` run 42411868745 was dispatched on this head; the orchestrator reads its result. No stage R criterion is CI-dependent, so this is recorded as pending-CI, not as a finding.

### Approved Exceptions

**None.**

### Removed/Skipped Tests

**None removed.**

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. `8fcbff40b` to `1baf2ab96`: plan revision, preflight fixes, Phase 0 baselines.
2. `09b99a1f1`, `62762acc6`, `fc0caf3a7`, `28c254038`: merge-commit back-fills.
3. `d08a7e5bd`, `a36d27974`, `48a6461b2`, `7183fb8a2`, `5ac41cfd7`: chain module and tests.
4. `741ab9924`, `670ae17ea`, `9bfb86306`, `cfa2f0468`, `03b4d808a`, `80622f8e7`: README order rule, check sentences, and brief rebase.
5. `c117b0e04`, `2b53d8016`, `bebafb7d2`: cycle 2 (step 1, keep-later route, RN2 removal).
6. `2eb502657`, `d48ea60ce`: cycle 3 (later-landing order and the merge of `origin/main`).
7. Remaining commits: feature-folder records, gates, and self-reviews.

### Files Modified

1. `scripts/dev-tools/ProcessReductionChain.psm1` and two test files (new).
2. `docs/engineering/process-reductions/`: README, entries `0001`, `0004`, `0005`, `0006`, and the `0001` and `0006` patches.
3. Feature folder: spec, user story, plans, remediation records, evidence.

---

## 10. Compliance Verdict

### Overall Status: ❌ FAIL (remediation required)

One blocking finding, F1, class `autonomous`, scope `contained`. Every other section passes.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design, structure, toolchain loop
- ❌ README claim that the chain catches every in-region edit on CI (F1)

#### Language-Specific Code Change Policy (Section 3)
- ✅ PowerShell

#### General Unit Test Policy (Section 1)
- ✅ Core principles, coverage artifacts, and baseline comparison
- ⚠️ No negative case for a created file (F1)

#### Language-Specific Unit Test Policy (Section 4)
- ✅ PowerShell

### Metrics Summary

- ✅ 16045 Pester tests, 0 failed; 16213 pytest passed, 0 failed
- ✅ 94.16% PowerShell repo-wide lines; new module 100%
- ✅ Chain and sub-chains valid at head; `0006` patch reverse-checks on the live tree
- ❌ Created-file edits pass the chain undetected (two probes)

### Recommendation

**Not ready to merge.** Fix F1 in `Invoke-ProcessReductionPatchStep`: before a create hunk sets the path absent, record an error when the path is absent at that step or when its chain-state text differs from the create hunk's `Current`. Replace the pinning case `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` with cases for an unchanged, an edited, and an absent created file. Then re-review.

---

## Appendix A: Test Inventory

Pester (new): `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` (46 tests), `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` (5 tests).

Pester (unchanged, in the gate): `ProcessReductionLedger.Tests.ps1` (72), `ProcessReductionLedger.Index.Tests.ps1` (15), `ProcessReductionLedger.Replay.Tests.ps1` (4).

---

## Appendix B: Toolchain Commands Reference

Run by the reviewer against the item worktree:

```sh
git -C <worktree> fetch origin main
git -C <worktree> diff --stat 12825cb00 HEAD
git -C <worktree> log --oneline 12825cb00..HEAD
git -C <worktree> merge-tree --write-tree origin/main HEAD
git -C <worktree> apply -R --check docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch
git -C <worktree> grep -n -e '^<<<<<<< ' -e '^>>>>>>> ' -- docs/engineering/process-reductions
git -C <worktree> log --format='%h %s' 278bb7047..HEAD -- <path>
git -C <worktree> log --full-history --no-merges --format='%h %s' 278bb7047..HEAD -- <path>
poetry run python -m scripts.dev_tools.validate_evidence_locations --root .
pwsh -NoProfile -Command '<in-memory chain probe>'
```

Reviewer probes, run in memory with `pwsh -NoProfile -Command` from the worktree root:

- `Read-ProcessReductionChainInput` then `Invoke-ProcessReductionChain` at head, with `-StopBefore` for `0001` and `0006`.
- The same chain with `LiveText` copies in which a created file has a line appended, in which it is `$null`, and in which one line inside a modify hunk of `test_single_pass_preflight_contracts.py` is changed.
- Created-file text at the `-StopBefore 0001` state compared with each create hunk's `Current`.
- `Get-ProcessReductionSection` of each entry's `## Revert Steps`, searched for a higher entry number.
- Chain end state of `fix_all_branches_extra.py` and `qc_toolchain.py` compared with `git show 3b21425f6:<path>` and `3b21425f6~1:<path>`.
- Parsing of `artifacts/pester/powershell-coverage.xml`; logical line counts with `@(Get-Content -LiteralPath <path>).Count`.

Template note: the bundled template asset was not resolved through MCP in this session, because the resolver tool is not available to this agent. The structure follows `policy-audit.2026-11-07T18-49.md`, and the MCP validator checked this file.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-11-07
**Policy Version:** Current (as of audit date)
