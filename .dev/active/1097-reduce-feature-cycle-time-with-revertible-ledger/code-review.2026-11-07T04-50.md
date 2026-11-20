# Code Review: Process-Reduction Ledger, Stage A (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `95d9b839ec47ee2d02c4b1b66f0d2603e92497ee`
**Review Type:** Re-audit after remediation cycle 1

---

## Executive Summary

The branch adds `docs/engineering/process-reductions/README.md`, the 551-line module `scripts/dev-tools/ProcessReductionLedger.psm1`, 86 Pester cases in two files, the review-side standing rule in six skill copies, and a one-expression test fix. Evidence reviewed: the PR-context artifacts, the full diff, the cycle 1 plan and gates, `artifacts/pester/`, `artifacts/python/lcov.info`, 11 in-memory mutants, and direct edge probes of the module.

Cycle 1 closed every prior item. F1 is closed by the Python coverage artifact. NB-1 to NB-5 are closed by code, tests, and README text. The new checks reject the inputs they target, and 10 of the 11 mutants changed a result that a Pester fixture asserts.

**What changed in cycle 1:**
A revert-block path must be repository-relative. `## Revert Steps` labels count only outside fences. A stored patch path may end a sentence with one period. Seven test names pin those rules and three earlier parser rules. The README states the date, issue, path, and patch rules.

**Top 3 risks:**
1. The ledger is still empty, so `PRL-REAL-LEDGER-AGREES` iterates no entry until stage C. The in-memory ledger tests use the same function.
2. The structure check verifies form, not whether a revert block still applies to its target. `Current` text can drift from the file after later edits. `Invoke-ProcessReductionRevert` fails loudly in that case, but only when someone runs it.
3. A worktree Python coverage run needs `PYTHONPATH` set to the worktree's `packages/discovery-runtime/src`. Without it, the shared editable install gives 49.52% lines with every test passing. Later stages will meet this again.

**PR readiness recommendation:** **Ready** — no Blocker. The findings below are non-blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1` | `PRL-ENTRY-STORED-PATCH-TRAILING-PUNCTUATION` | No fixture carries a `.patch/x` suffix. Deleting `/` from the lookahead in `Test-ProcessReductionEntry` changes behavior and leaves every Pester fixture passing. The cycle 1 plan named `.patch/x` as a form that stays rejected. | Add the `.patch/x` case beside the `.patch.bak` case. | The rule is stated in the plan and no test holds it. | Mutant M5c changed the reviewer's slash-suffix check; the test file holds only the `.patch.bak` suffix. |
| Minor | `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1` | `PRL-ENTRY-BLOCK-PATH-NOT-RELATIVE` | All four rejected paths use `/`. The `\` side of the path rule in `Get-ProcessReductionPriorTextError` has no fixture, although the README names it and Windows authors are the likely source. | Add `\docs\a.md` and `docs\..\a.md` to the `-ForEach` list. | The behavior is correct today, and nothing would report its removal. | Probes reject `docs\..\a.md`, `\docs\a.md`, and a UNC path. Fixture inspection found no backslash path. |
| Nit | `scripts/dev-tools/ProcessReductionLedger.psm1` | `Get-ProcessReductionPriorTextError` | `~/a.md` and `file:///x/a.md` pass the repository-relative check. | Reject a leading `~` and a URI scheme, or leave them, since `Invoke-ProcessReductionRevert` takes text and never opens the path. | A path of this form would not resolve in the repository. Low likelihood. | Direct probes returned `IsValid` true. |
| Nit | `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1` | `PRL-ENTRY-STORED-PATCH-TRAILING-PUNCTUATION` | The test holds two acts, as do `PRL-ENTRY-REVERT-STEP-ORDER`, `PRL-INDEX-MISSING-TABLE`, and `PRL-REVERT-THROWS-WHEN-CURRENT-ABSENT` (the last three carried from the prior review). | Split them if the file is touched. | The PowerShell rule asks for one behavior per `It`. | Source inspection. |
| Nit | `scripts/dev-tools/ProcessReductionLedger.psm1` | `Test-ProcessReductionLedger` | Carried from the prior review: a file in `patches/` that no entry names goes unreported. Tilde fences are not recognized in `Get-ProcessReductionFence`, though the README prescribes backticks. | Report an orphan patch when the function is next touched. | Keeps the two directions of the ledger check symmetric. | Prior review probes P11 and P13; the code is unchanged. |
| Nit | `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1` | `PRL-READ-THROWS-ON-MISSING-README` | Carried from the prior review: the test relies on `tests/scripts/dev-tools` having no `README.md`. | Mock `Test-Path`. | Removes a dependency on the folder's contents. | Source inspection. |

No file reaches the 700-line advisory tier (551, 473, 168, and 461 logical lines), so no `Warning` row applies. No finding blocks. No prior Minor finding remains open.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Cycle 1 changed no `.py` file. The one-expression filter change from stage A stands; its last commit is `286f4c154`.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- No change.

### PowerShell implementation audit

#### What changed well

- NB-1: the path rule rejects both separators, a drive prefix, and a `..` segment, and keeps `docs/..foo/a.md`, `...`, and `./docs/a.md` valid. The `..` test is a whole-segment match, so a mutant that matched any `..` run was caught.
- NB-2: `Get-ProcessReductionRevertStepError` searches `Get-ProcessReductionPlainLine` output, and reuses the existing seam. An all-fenced section reports each label as absent; an unclosed fence in the section is rejected.
- NB-3: the lookahead accepts one trailing period and still rejects `.patch.bak`, `.patch/x`, `.patch..`, and `.patch-old`. Backticks, parentheses, and a following comma are accepted.

#### API and safety notes

- All functions use `CmdletBinding` and `OutputType`. Nothing writes, so ShouldProcess does not apply. PSScriptAnalyzer reports 0 findings on the three files, and the formatter reports no difference. `git diff 123f8335c HEAD` shows no other function changed.

#### Error handling and logging

- The new error names the block path and the requirement. There is no catch block.

---

## Test Quality Audit

86 Pester cases pass within the recorded gate of 14548 tests. New-module line coverage is 100% (195 of 195). All seven names from the cycle 1 plan exist and pass.

The self-review states that each new rule has a test that fails when the rule is removed. The reviewer checked that claim instead of relying on it. Each mutant was applied in memory and exercised by direct calls that reproduce the Pester fixture, because the owner's rule excludes single-file test runs. M1, M2, M3, M3b, M4, M5, M5b, M6, M7, and M8 each changed a check that a named test asserts. M5c did not, which is the first Minor finding.

### Reviewed test and QA artifacts

- `artifacts/pester/pester-junit.xml` — 14548 tests, 0 failures, 86 `PRL-` cases.
- `artifacts/pester/powershell-coverage.xml` — root LINE 23443 of 24962; module LINE 195 of 195.
- `artifacts/python/lcov.info` — LH 32270 of LF 33367, BRH 11722 of BRF 12516, 366 source files, including 140 under `packages/discovery-runtime`.
- `evidence/qa-gates/python-coverage.2026-11-07T04-42.md` — its figures equal the reviewer's sums. It discloses a first run at 49.52% lines and the environment cause.
- `evidence/qa-gates/self-review.2026-11-07T04-43.md` — reports no FAIL row. Its falsifiability row overstates by one case, the slash suffix.

### Quality assessment prompts

- **Determinism:** no clock, randomness, sleep, or network.
- **Isolation:** one `Describe` per function; each test builds its own fixture.
- **Speed:** in-memory fixtures; the whole gate took 304.12 seconds across 8 shards.
- **Diagnostics:** validity assertions pass the error list through `-Because`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected. |
| No unsafe subprocess or command construction | N/A | No process is started. |
| Input validation at boundaries | ✅ PASS | Mandatory parameters and folder checks are present; revert block paths are now constrained, with the Nit stated above. |
| Error handling remains explicit | ✅ PASS | `throw` with context; no catch. |
| Configuration / path handling is safe | ✅ PASS | `Join-Path` and `-LiteralPath`; the module writes nothing. |

---

## Research Log

No external research was required.

---

## Verdict

**Ready.** No Blocker. Prior finding F1 and items NB-1 to NB-5 are closed. The two Minor findings are test additions that fit the first stage that touches these files.
