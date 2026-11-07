# Code Review: Process-Reduction Ledger, Stage A (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `123f8335cb2954eb1355b1d3cceb20f5efbb2c30`
**Review Type:** Initial review

---

## Executive Summary

The branch adds `docs/engineering/process-reductions/README.md`, the 547-line module `scripts/dev-tools/ProcessReductionLedger.psm1`, 75 Pester cases in two files, the review-side standing rule in six skill copies, and a one-expression test fix. Evidence reviewed: the PR-context artifacts, the full diff, the plan, the gate artifacts, `artifacts/pester/`, and 20 direct behavior probes of the module.

The implementation is sound. The parser is fence-aware, fails closed on an unclosed fence, and keeps the pure functions separate from the single read seam. The in-memory revert refuses every input that would give a silent wrong result. Every behavior the `[A]` criteria name was confirmed by a probe or a test.

**What changed:**
The ledger now has a machine-checked format. `Test-ProcessReductionLedger` validates the index, each entry, and stored patches, and the real folder is checked on every Pester run. The feature-review skill now requires a ledger entry for any reduction.

**Top 3 risks:**
1. Python coverage was not measured on this branch, so the mandatory check is open (Blocker, F1). The change is test-only, so no figure is expected to move.
2. The structure check verifies form, not whether a revert block can still apply: `Current` text can drift from its target after later edits, and paths are not constrained. The first real entries arrive at stage C, so the gaps are cheap to close now.
3. The empty ledger means `PRL-REAL-LEDGER-AGREES` iterates no entry until stage C. The plan's mitigation holds: the same function fails in memory in `PRL-LEDGER-INCOMPLETE-ENTRY-FAILS`, and a reviewer probe validated a real two-entry folder.

**PR readiness recommendation:** **Needs Revision** — one Blocker, resolved by a single coverage run with no expected code change.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `artifacts/python/lcov.info` | absent | F1. Python has a changed file on the branch and no coverage artifact exists. The gate ran `pytest -n auto` without `--cov`, and the plan's `Coverage` Pre-Mortem bullet declined a Python coverage task. | Run `poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing` once from the worktree root, and record repo-wide line and branch figures in a QA gate artifact. | The review contract makes coverage verification mandatory for every language with changed files and states no test-only exception. | The worktree `artifacts/` folder holds only `orchestration/` and `pester/`. `pyproject.toml` `addopts` has `--cov-report` but no `--cov`. |
| Minor | `scripts/dev-tools/ProcessReductionLedger.psm1` | line 153 | A `### Revert Block:` path is not checked as repository-relative. `C:/Users/x/a.md` and `../../outside.md` both validate. | Reject a rooted path, a drive prefix, and a `..` segment in `Get-ProcessReductionPriorTextError`, with a test. | D1 and the README state a repository-relative path. A host path in an entry would not work on another machine and records host data. | Probes P5 and P5b returned `IsValid` true. |
| Minor | `scripts/dev-tools/ProcessReductionLedger.psm1` | lines 302-336 | `## Revert Steps` labels are found anywhere in the section text, including inside a fence. A section holding only a fenced list validates. | Scan `Get-ProcessReductionPlainLine` output so fenced text does not count. | The labels exist so an agent follows the steps months later. The self-review noted the related quoted-label case. | Probe P12 returned `IsValid` true. |
| Minor | `scripts/dev-tools/ProcessReductionLedger.psm1` | lines 389-390 | The `## Stored Patch` lookahead rejects a path followed by sentence punctuation. `Apply patches/0001-a.patch.` fails with "must name", which misdescribes the problem. | Allow trailing punctuation in the lookahead, or state in the README that the path is written in backticks. | The failure is safe but misleading to the author of an otherwise correct entry. No test covers this boundary. | Probe P1. |
| Minor | `docs/engineering/process-reductions/README.md` | line 16 | The `## Summary` format omits the date and the issue. `issue.md` says each entry states "what was reduced, the date, the issue, and the merge commit", and research section 1 lists them under `## Summary`. They exist only in the index row. | Add `Date:` and `Issue:` lines to the format and the worked example, or record in `spec.md` that the index row satisfies this. | An entry read alone months later does not show when or why it was made. The `[A]` criteria do not name this, so it does not block. | `issue.md` `### 1. Reduction ledger`; README `## Entry Format`. |
| Minor | `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1` | n/a | Three parser rules execute but no test would fail if they were broken: a fence line carrying an info string does not close a fence (module line 79), the first of two repeated labels wins (line 168), and a level-one heading ends a section (line 109). | Add one in-memory case for each. | Line coverage is 100%, yet deleting any of these conditions leaves every fixture passing. This is the class the plan's Pre-Mortem names. | Fixture inspection: each fixture's inner fences are shorter or bare, no block repeats a label, and no section is followed by a level-one heading. Not run as a mutant, under the Testing Rule. |
| Nit | `scripts/dev-tools/ProcessReductionLedger.psm1` | line 531 | A file in `patches/` that no entry names goes unreported, although a row without a file is reported. | Report an orphan patch in `Test-ProcessReductionLedger`. | Keeps the two directions of the ledger check symmetric. | Probe P11. |
| Nit | `scripts/dev-tools/ProcessReductionLedger.psm1` | `Get-ProcessReductionFence` | Tilde fences are not recognized, so `## ` inside one ends a section. | State in the README that entries use backtick fences only. | The README already prescribes backticks, so this cannot arise in a conforming entry. | Probe P13. |
| Nit | `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` | line 113 | `PRL-READ-THROWS-ON-MISSING-README` relies on `tests/scripts/dev-tools` having no `README.md`. Separately, `PRL-ENTRY-REVERT-STEP-ORDER`, `PRL-INDEX-MISSING-TABLE`, and `PRL-REVERT-THROWS-WHEN-CURRENT-ABSENT` each hold more than one act. | Mock `Test-Path` for the first; split the others if the file is touched. | The PowerShell rule asks for one behavior per `It`. | Source inspection. |

No file reaches the 700-line advisory tier, so no `Warning` row applies. Only F1 blocks.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The one-expression change moves the excluded-name test below the repository root, so a checkout under a `worktrees` folder keeps its six copies and a nested worktree stays excluded. A direct check from the worktree found 0 copies with the old expression and 6 with the new one. No other test filters absolute path parts on `worktrees`.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- No change.

### PowerShell implementation audit

#### What changed well

- `Get-ProcessReductionLine` is one walker for all parsing, so section, block, and table reads agree on what is fenced.
- `Invoke-ProcessReductionRevert` throws on a null, empty, absent, or repeated `Current` and on a null `Prior`. Overlapping text is caught (`aa` in `aaa`).
- An unclosed fence fails closed: it consumes the following sections, which are then reported missing.

#### API and safety notes

- All functions use `CmdletBinding` and `OutputType`. Nothing writes, so ShouldProcess does not apply. PSScriptAnalyzer reports 0 findings. The formatter reports no difference.
- The six plan notes for reviewer confirmation are confirmed: `Read-ProcessReductionLedger` and `Test-ProcessReductionLedger` are justified additions; info-string labels work; the extra throws are correct; empty `Prior` is valid and replays; the six labels are enforced; and the review rule matches D1.

#### Error handling and logging

- Errors name the section, block path, or row. There is no catch block.

---

## Test Quality Audit

75 Pester cases pass within the recorded gate of 14537 tests. New-module line coverage is 100%. All 44 test names in the plan exist. The in-memory ledger tests and the real-folder test share one function, which is the correct way to avoid a vacuous pass on an empty ledger.

### Reviewed test and QA artifacts

- `artifacts/pester/pester-junit.xml` — 14537 tests, 0 failures, 75 `PRL-` cases. It holds the cases added by the head commit, which proves the run covered that content.
- `artifacts/pester/powershell-coverage.xml` — root LINE 23440 of 24959; module LINE 192 of 192. The denominator grew by exactly the module's 192 lines.
- `evidence/qa-gates/python-test.2026-11-07T04-05.md` — 16099 passed, 0 failed, no coverage options.
- `evidence/qa-gates/self-review.2026-11-07T04-05.md` — reports no FAIL row. Its coverage row covers PowerShell only, so it did not surface F1.

### Quality assessment prompts

- **Determinism:** no clock, randomness, sleep, or network.
- **Isolation:** one `Describe` per function; each test builds its own fixture.
- **Speed:** about one second per suite in the recorded run.
- **Diagnostics:** validity assertions pass the error list through `-Because`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected. |
| No unsafe subprocess or command construction | N/A | No process is started. |
| Input validation at boundaries | ⚠️ PARTIAL | Mandatory parameters and folder checks are present; revert block paths are not constrained (Minor). |
| Error handling remains explicit | ✅ PASS | `throw` with context; no catch. |
| Configuration / path handling is safe | ✅ PASS | `Join-Path` and `-LiteralPath`; the module writes nothing. |

---

## Research Log

No external research was required.

---

## Verdict

**Needs Revision.** One Blocker, F1, classified `autonomous`. The Minor and Nit findings do not block. They are small and related to this item, so the same cycle is the efficient place to close them, before the first real entry lands at stage C.
