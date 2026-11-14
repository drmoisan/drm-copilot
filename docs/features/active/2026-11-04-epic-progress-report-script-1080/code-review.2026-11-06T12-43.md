# Code Review: Get-EpicProgressReport dev-tools script (#1080), Re-audit after Remediation Cycle 2

**Review Date:** 2026-11-06
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-04-epic-progress-report-script-1080`
**Base Branch:** `main` (merge base `02fb8aada3b10aaf3ac6812e29400c2302a3b372`)
**Head Branch:** `feature/epic-progress-report-script` @ `deee4394b0e859ef3c2781d053e3417bc27ddf71`
**Review Type:** Re-audit (remediation cycle 2); prior reviews `code-review.2026-11-05T23-23.md` and `code-review.2026-11-06T00-11.md`

---

## Executive Summary

Cycle 2 changed three change-set files (`git diff 79d4e3de0 HEAD -- scripts tests`): the kickoff parser in the logic file, one help sentence in the script, and three new tests plus two updated fixtures in the logic test file. CR-1 and the overflow Nit from `remediation-inputs.2026-11-06T00-11.md` are resolved. At HEAD the formatter reports 0 differences, PSSA reports 0 findings, 99 of 99 tests pass, and line coverage is 91.18% (93/102) and 100% (218/218).

CR-1 verification, performed independently by the reviewer:

- Only the feature-summary table is parsed: `$inFeatureTable` is set by a header match `^\|\s*(issue_num|issue)\s*\|` (case-insensitive by PowerShell default; logic line 54), and the first non-table line after the header ends the parse (`break`, line 57).
- Both header spellings are covered: `issue_num` in `returns only rows of the feature-summary table` (Logic.Tests line 76) and `Issue` in the other fixtures.
- Sweep: the HEAD parser over the nine `docs/features/epics/*/epic-kickoff.md` files plus the kickoffs on `origin/epic/documentation-estate-tooling-integration` (epic 1019, 11 rows), `origin/epic/enforcement-hook-precision-integration`, and `origin/epic/subagentstop-envelope-integration` returned 85 rows, 0 with an empty plan path, 0 errors. The three formerly affected files return 8, 5, and 7 rows, matching the executor's pass-after sweep.
- A stubbed `Invoke-EpicProgressReport` run (all seams replaced; no git, gh, cswap, or writes) on `cleanup-merged-worktrees-hardening` now lists 8 features in waves 0-2 and no phantom wave 4.
- Mutants on a scratch copy: table restriction removed (A), overflow handling reverted (B), header accepting only `issue` (C), only `issue_num` (D), `break` changed to `continue` (E), end-of-table check removed (F), header regex unanchored (G). 7 of 7 killed; the restored copy passes 99/99.

The whole change set was reviewed again. No blocking finding remains. This pass found three non-blocking robustness items in `ConvertFrom-EpicProgressKickoffRow` (NB-1 Minor, NB-2 and NB-3 Nit), each found by direct probes of the parser, plus two new Info items. All open items are listed below; no other finding exists in the four code files.

**Top 3 risks:**
1. NB-1: a kickoff whose feature table header is neither `issue_num` nor `Issue` (for example `Issue #` or `issue-num`) produces a report of 0 tasks and 0 features with no warning. No current kickoff is affected.
2. NB-2: an indented feature row inside the table is skipped silently, understating totals.
3. NB-3: a short feature row (fewer than five cells) yields an empty plan path, which reads the integration branch root and counts 0 tasks without an error.

**PR readiness recommendation:** **Go.** No blocking finding. NB-1 to NB-3 are optional and each is a few lines in one function plus a test.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | `ConvertFrom-EpicProgressKickoffRow`, lines 51-57 | NB-1 (non-blocking; Remediability: autonomous): when no line matches the feature-summary header, the function returns zero rows and the report prints a complete, plausible report of 0 tasks. Before cycle 2 such a kickoff still produced its rows; the header dependence was introduced by the CR-1 fix. | Throw a clear terminating error (or have `Invoke-EpicProgressReport` throw) when the kickoff text is non-empty and no feature-summary header is found, naming the accepted spellings; add a logic test for a kickoff with an unrecognized header. Keep `returns no rows for an empty kickoff` behavior or change it deliberately. | The function's own help argues that a skipped row must throw because it understates the total; skipping the whole table understates it entirely. Fail-fast rule in `.claude/rules/general-code-change.md`. Not reproduced on any repository kickoff (12 of 12 use `issue_num`, the header in `.claude/skills/epic-plan/SKILL.md`). | Reviewer probes: header `Issue #` and a headerless table each return 0 rows. Stubbed report with an `Issue #` header printed "Epic #9 is at 0 of 0 tasks (0%). None of the 0 features is done yet." and a Total row of 0, with no warning or error. |
| Nit | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | lines 54, 57, 58 | NB-2 (non-blocking; Remediability: autonomous): the end-of-table test `^\s*\|` accepts leading whitespace, but the header match and the row match both require `\|` in column 0. An indented row inside the feature table is therefore treated as part of the table and then skipped without an error; an indented header is not recognized (falls into NB-1). | Use one anchoring rule for all three matches: either allow `^\s*\|` in the header and row matches (and trim before splitting so cell indices stay correct), or require column 0 in the end-of-table test so an indented line ends the table visibly. Add a test for an indented row. | Silent understatement of the task total; inconsistent with the help text, which says any whitespace may surround each cell. Row-level behavior predates cycle 2; the header part is new. | Probe: header, separator, an indented row for issue 5, and a row for issue 6 returned only issue 6. |
| Nit | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | line 64 | NB-3 (non-blocking; Remediability: autonomous; pre-existing): a feature row with fewer than five cells returns `Band` and `PlanPath` as `$null`. The report then runs `git show <branch>:` (the branch root tree), counts 0 tasks, and reports the feature as Pending without an error. | Throw the same style of clear error when the row has fewer than the five expected cells or an empty plan cell, naming the issue; add a test. | Same understatement rationale as the wave-cell error. No repository kickoff has a short row (sweep: 0 empty plan paths). | Probe: a four-column table returned issue 5 with an empty plan path. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | line 54 | The `Issue` spelling also selects any table whose first header cell is `Issue` that appears before the feature table (for example an `Issue / Reason` table); its numeric rows would then be read as features or raise the wave error. | None required. | `Issue` support was required by CR-1 item 4 for the recovered-script fixture format; no repository kickoff has such a table. | Probe: an `Issue / Reason` table before the feature table raised "non-numeric wave cell ''". |
| Info | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | line 62 | An all-digit wave cell above Int32 (for example `2147483648`) is reported as "non-numeric". | None required. | The wording follows the remediation input ("the same clear wave-cell error") and is pinned by a test. | Probe output. |
| Info | `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | `returns the last native exit code` (line 85) | Carried forward: the assertion proves pass-through only. | None required. | Real-seam behavior was verified in the prior review. | `code-review.2026-11-06T00-11.md`. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.ps1` | `Invoke-EpicProgressReport` fetch warning | Carried forward: with `$LASTEXITCODE` `$null` (git absent) the warning prints an empty code. | None required. | Without git the report cannot run at all. | Code inspection. |

No file-size Warning: the largest covered file is 670 logical lines (below the 700-line advisory tier). A fix for NB-1 to NB-3 adds roughly 6 to 10 lines to the logic file, which stays below 700.

### Remediation verification of cycle-2 findings

| Cycle-2 finding | Status | Production change | Tests | Discrimination |
|---|---|---|---|---|
| CR-1 Blocking: phantom rows from non-feature tables | RESOLVED | Lines 51-57: header gate and end-of-table `break`; help in the function and in script `-KickoffPath` | `returns only rows of the feature-summary table` (line 76), `ignores a numeric-first row with a non-digit wave position outside the feature table` (line 99); fixtures at lines 52 and 64 gained an `Issue` header | Mutants A, C, D, E, F, G killed; sweep 85 rows, 0 empty plan paths |
| Nit: wave-cell overflow message | RESOLVED | Line 61: `[int]::TryParse` with `NumberStyles.None` and invariant culture | `throws a clear error for a wave cell beyond the Int32 range` (line 70) | Mutant B killed; `2147483647` accepted, `2147483648`, `+1`, an Arabic-Indic digit, and an empty cell rejected |

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The gate is a single loop-local boolean; the function stays pure and small.
- `NumberStyles.None` rejects signs, whitespace, and thousands separators, and the invariant culture removes locale dependence; .NET integer parsing accepts only ASCII digits, which is stricter than the former `\d` regex.
- CRLF kickoff text parses correctly (split on `\r?\n`; probe returned the row with its plan path).
- Help in both the function and the script states which table is read.

#### API and safety notes

- No parameter added or removed; the public surface is unchanged.
- No new native command; the AST constraint tests still confine executables to their wrappers.
- PSSA: 0 findings with repository settings.

#### Error handling and logging

- One terminating error covers non-digit and out-of-range wave cells.
- Absent feature table and short rows are not reported (NB-1, NB-3).

---

## Test Quality Audit

Three tests were added and two fixtures updated. Each new test was shown to fail under a targeted mutant, and the gate's two header spellings, its entry, and its exit are each pinned by at least one test. The suites remain deterministic: no temporary files, no clock reads, no process starts.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` - 67 tests; 100% line coverage of the logic file.
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` - 32 tests; unchanged this cycle.
- `evidence/regression-testing/kickoff-sweep-before.2026-11-06T00-34.md`, `kickoff-sweep-after.2026-11-06T00-38.md` - consistent with the reviewer sweep.
- `evidence/regression-testing/mutant-kickoff-table-and-overflow.2026-11-06T00-37.md` - consistent with reviewer mutants A and B.
- `evidence/qa-gates/coverage-final.2026-11-06T00-41.md` - 91.18% and 100%; its missed-line numbers predate the P2-T9 help line and are offset by one from HEAD, which `self-review.2026-11-06T12-30.md` records.
- `evidence/regression-testing/isolation-shuffle.2026-11-06T00-43.md`, `isolation-fresh-tests-scripts.2026-11-06T12-26.md` - 0 failures.

### Quality assessment prompts

- **Determinism:** fixtures are literal strings joined with LF.
- **Isolation:** each test calls the parser directly.
- **Speed:** both suites complete in about 3 seconds.
- **Diagnostics:** joined issue and wave lists make failures readable.
- **Gap:** no test for an unrecognized header, an indented row, or a short row (NB-1 to NB-3).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No tokens, host paths, or account names added. |
| No unsafe subprocess or command construction | ✅ PASS | No new native invocation. |
| Input validation at boundaries | ✅ PASS | Non-feature tables ignored; wave cells validated. Non-blocking gaps NB-1 to NB-3 noted. |
| Error handling remains explicit | ✅ PASS | Single clear error for invalid wave cells. |
| Configuration / path handling is safe | ✅ PASS | Unchanged. |
| Read-only toward repository and GitHub | ✅ PASS | Only `fetch`, `show`, `worktree list`, and `pr list`; asserted by tests. |
| No new Python | ✅ PASS | Zero `.py` paths in the branch diff. |

---

## Research Log

No external research was required. Conclusions rest on the diff, the repository and integration-branch kickoff files, the `epic-plan` skill template, local tool runs, mutation runs on a scratch copy, a stubbed report run, and the feature evidence.

---

## Verdict

CR-1 and the overflow Nit are resolved with discriminating tests, and the cycle introduced no regression in any gate. No blocking finding remains; the branch is ready for a PR. Three non-blocking parser items (NB-1 Minor, NB-2 Nit, NB-3 Nit), all autonomous, and four Info items are listed above as the complete set of open items.
