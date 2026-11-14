# Code Review: Get-EpicProgressReport dev-tools script (#1080), Re-audit after Remediation Cycle 3

**Review Date:** 2026-11-06
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-04-epic-progress-report-script-1080`
**Base Branch:** `main` (merge base `02fb8aada3b10aaf3ac6812e29400c2302a3b372`)
**Head Branch:** `feature/epic-progress-report-script` @ `468a8d43cc16cc5147d9473a43aa9670f6b3aacf`
**Review Type:** Re-audit (remediation cycle 3, final); prior reviews `code-review.2026-11-05T23-23.md`, `code-review.2026-11-06T00-11.md`, `code-review.2026-11-06T12-43.md`

---

## Executive Summary

Cycle 3 changed three change-set files (`git diff deee4394b HEAD -- scripts tests`): `ConvertFrom-EpicProgressKickoffRow` in the logic file, one help sentence in the script, and seven new tests in the logic test file. NB-1, NB-2, and NB-3 from `remediation-inputs.2026-11-06T12-43.md` are resolved. At HEAD the formatter reports 0 differences and PSSA 0 findings with the repository settings, 106 of 106 tests pass, and line coverage is 91.18% (93/102) and 100% (227/227).

Verification performed independently by the reviewer:

- Code reading: every table line is trimmed once (`$trimmed = $line.Trim()`), and that value feeds the header match, the end-of-table test, the row match, and the split. The cell count subtracts the leading empty element and, when the trimmed line ends in `|`, the trailing one. The post-loop check throws only when the header was never seen and the text contains a non-whitespace character.
- Probes: a tab-indented row, CRLF text, a five-cell row without a trailing pipe, and a six-cell row are read correctly. A four-cell row, a blank plan cell, an `Issue #` header, prose-only text, and git error text each throw with a message naming the cause.
- Sweep: the HEAD parser over the nine `docs/features/epics/*/epic-kickoff.md` files and the kickoffs on `origin/epic/documentation-estate-tooling-integration`, `origin/epic/enforcement-hook-precision-integration`, and `origin/epic/subagentstop-envelope-integration` returned 85 rows, 0 empty plan paths, 0 errors; per-file counts equal the cycle-2 sweep.
- Mutants on a scratch copy: 9 of 9 killed (details in the policy audit, section 4B.2); the restored copy passes 74/74.

The whole change set was reviewed again. No blocking finding exists. This pass found one new non-blocking Minor item (NB-4, at the report level rather than in the parser) and records the advisory-tier file-size Warning for the logic test file.

**Top 3 risks:**
1. NB-4: with `-EpicIssue` supplied, an unreadable kickoff (mistyped `-KickoffPath`, wrong `-IntegrationBranch`, or a branch not yet fetched) produces a 0-of-0 report without an error and records a 0-done sample in the state file, which would distort recent velocity on the next correct run.
2. The logic test file is at 702 lines; further parser tests would move it toward the 800-line hard limit.
3. An escaped pipe (`\|`) in a feature title raises a wave-cell error that names a title fragment rather than the escaped pipe.

**PR readiness recommendation:** **Go.** No blocking finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/dev-tools/Get-EpicProgressReport.ps1` | `Invoke-EpicProgressReport`, line 385 | NB-4 (non-blocking; Remediability: autonomous; pre-existing): the kickoff is read with `git show <branch>:<path>`, and `Invoke-GitExe` discards stderr. When that read fails, the text is empty, which the parser correctly treats as no rows. Without `-EpicIssue` the existing epic-issue error stops the run; with `-EpicIssue` supplied the report prints a 0-of-0 report and writes a 0-done sample to the state file. | After the kickoff read, throw when `Get-EpicProgressLastExitCode` is non-zero or the text is blank, naming the branch and path (for example "could not read <path> on <branch>"); add a script-suite test with the `Invoke-GitExe` mock returning no kickoff text and `-EpicIssue` supplied, asserting the error and that `Write-EpicProgressState` is not called. | The failure is triggered only by a wrong argument or an unfetched branch, and the printed "0 of 0 tasks" is visible to the operator, so it does not meet the bar for must-not-merge. The state-file sample is the less visible effect. Not part of NB-1, which required empty text to return no rows. | Stubbed run (all seams replaced, git returns no output with exit code 128, `-EpicIssue 9`, `-KickoffPath docs/typo/epic-kickoff.md`): printed "Epic #9 is at 0 of 0 tasks (0%). None of the 0 features is done yet." and called the state write. Same run without `-EpicIssue`: "The epic issue number could not be resolved ...". |
| Warning | `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` | whole file | Advisory file-size tier: 702 logical lines (`@(Get-Content -LiteralPath).Count`), at or above 700 and below the 800-line hard limit. | Consider splitting the kickoff-parser `Describe` into its own test file in later work on this tool. | `.claude/rules/general-code-change.md` `## File Size Limit`: non-blocking Warning at 700 lines; no gate fails. | Reviewer line count; executor `file-size.2026-11-06T13-16.md` agrees. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | `ConvertFrom-EpicProgressKickoffRow` | A feature-summary header followed by no feature row (header and separator only) returns zero rows without an error. | None required. | The table is present and explicitly empty; this differs from NB-1, where the table is not found. No repository kickoff has an empty feature table. | Probe `header-only`: 0 rows. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | `ConvertFrom-EpicProgressKickoffRow`, split on `\|` | An escaped pipe in a title (`A \| B`) shifts the cells; the row then raises "non-numeric wave cell 'B'". The run stops, so no total is understated, but the message names a title fragment. | None required. | Fail-loud behavior is preserved; no repository kickoff uses an escaped pipe in a feature row. | Probe `escaped-pipe-title`. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | `ConvertFrom-EpicProgressKickoffRow` | A row ending in a blank plan cell without a trailing pipe (`\| 5 \| A \| 1 \| small \|   `) is reported as "has 4 cells" rather than "blank plan cell", because trimming makes it indistinguishable from a four-cell row. | None required. | Both messages stop the run and name the issue; Markdown cannot distinguish the two forms. | Probe `blank-plan-no-trailing-pipe`. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | header match | Carried forward: the `Issue` spelling also selects any earlier table whose first header cell is `Issue`. | None required. | Required by CR-1; no repository kickoff has such a table. | `code-review.2026-11-06T12-43.md`. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` | wave parse | Carried forward: an all-digit wave cell above Int32 is reported as "non-numeric". | None required. | Pinned by a test. | `code-review.2026-11-06T12-43.md`. |
| Info | `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` | `returns the last native exit code` | Carried forward: the assertion proves pass-through only. | None required. | Real-seam behavior verified in an earlier review. | `code-review.2026-11-06T00-11.md`. |
| Info | `scripts/dev-tools/Get-EpicProgressReport.ps1` | fetch warning | Carried forward: with `$LASTEXITCODE` `$null` (git absent) the warning prints an empty code. | None required. | Without git the report cannot run. | Code inspection. |

File-size measurement of covered files in the branch diff: `Get-EpicProgressReport.ps1` 477, `Get-EpicProgressReport.Logic.ps1` 688, `Get-EpicProgressReport.Tests.ps1` 455, `Get-EpicProgressReport.Logic.Tests.ps1` 702. One file at or above 700 (Warning above); none above 800; `config/file-size-baseline.json` is not in the branch diff.

### Remediation verification of cycle-3 findings

| Cycle-3 finding | Status | Production change | Tests | Discrimination |
|---|---|---|---|---|
| NB-1 Minor: no recognized header returns zero rows | RESOLVED | Post-loop `if (-not $inFeatureTable -and $KickoffText -match '\S') { throw ... }`; function help and `-KickoffPath` help state the error | `throws a clear error for a kickoff whose feature-table header is not recognized`, `throws a clear error for a feature table with no header row`, `returns no rows for a whitespace-only kickoff`; `returns no rows for an empty kickoff` unchanged | Mutant A (throw disabled) fails 2 tests; mutant H (whitespace-only throws) fails 1 |
| NB-2 Nit: inconsistent anchoring | RESOLVED | `$trimmed` used for header, end-of-table, row match, and split | `reads a feature table whose header row is indented`, `reads an indented row inside the feature table` | Mutants B, F, I (each match on the untrimmed line) each fail 1 test |
| NB-3 Nit: short row or blank plan cell | RESOLVED | Cell-count check (`-lt 5`) and blank-plan check before the wave parse, each naming the issue | `throws a clear error for a feature row with fewer than five cells`, `throws a clear error for a feature row with a blank plan cell` | Mutants C, D, E, G each fail 1 test |

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- One trimmed value per line removes the anchoring inconsistency without changing cell indices.
- The cell-count arithmetic is correct with and without a trailing pipe (probed), and both new row checks run before the wave parse, so the most specific message is reported.
- The post-loop check preserves the empty-text behavior required by the remediation input and distinguishes whitespace-only text with `-match '\S'`.
- The function stays pure; no I/O, global state, or new parameter.

#### API and safety notes

- No parameter added or removed; the public surface is unchanged.
- No new native command; the AST constraint tests still confine executables to their wrappers.
- PSSA: 0 findings with repository settings.

#### Error handling and logging

- Every malformed-kickoff case reachable inside the parser now stops the run with a clear message.
- The caller does not distinguish a failed kickoff read from an empty kickoff (NB-4).

---

## Test Quality Audit

Seven tests were added. Each new check is pinned by at least one test that fails under a targeted mutant, including the arithmetic detail (trailing-pipe adjustment) and the threshold value. The suites remain deterministic: literal fixture strings, no temporary files, no clock reads, no process starts.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` - 74 tests; 100% line coverage of the logic file.
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` - 32 tests; unchanged this cycle.
- `evidence/regression-testing/kickoff-sweep-cycle3-before.2026-11-06T13-08.md`, `kickoff-sweep-cycle3-after.2026-11-06T13-13.md` - 9 files, 62 rows, consistent with the reviewer sweep of the same files.
- `evidence/regression-testing/mutant-kickoff-header-indent-short-row.2026-11-06T13-12.md` - consistent with reviewer mutants A, B, C.
- `evidence/qa-gates/coverage-final.2026-11-06T13-16.md` - 91.18% and 100%; its missed-line numbers predate the P2-T9 help edit and are two lower than at HEAD.
- `evidence/regression-testing/isolation-shuffle.2026-11-06T13-18.md`, `isolation-fresh-tests-scripts.2026-11-06T13-31.md` - 0 failures.

### Quality assessment prompts

- **Determinism:** fixtures are literal strings joined with LF.
- **Isolation:** each test calls the parser directly.
- **Speed:** both suites complete in seconds.
- **Diagnostics:** `-ExpectedMessage` patterns name the cause and the issue.
- **Gap:** no script-suite test for a failed kickoff read with `-EpicIssue` supplied (NB-4).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No tokens, host paths, or account names added. |
| No unsafe subprocess or command construction | ✅ PASS | No new native invocation. |
| Input validation at boundaries | ✅ PASS | Header, row shape, plan cell, and wave cell validated. Non-blocking report-level gap NB-4 noted. |
| Error handling remains explicit | ✅ PASS | Clear error text for each malformed-kickoff case. |
| Configuration / path handling is safe | ✅ PASS | Unchanged. |
| Read-only toward repository and GitHub | ✅ PASS | Only `fetch`, `show`, `worktree list`, and `pr list`; asserted by tests. |
| No new Python | ✅ PASS | Zero `.py` paths in the branch diff. |

---

## Research Log

No external research was required. Conclusions rest on the diff, the repository and integration-branch kickoff files, local tool runs, mutation runs on a scratch copy, a stubbed report run, and the feature evidence.

---

## Verdict

NB-1, NB-2, and NB-3 are resolved with discriminating tests, and the cycle introduced no regression in any gate. No blocking finding exists; the branch is ready for a PR. Open non-blocking items: NB-4 (Minor, autonomous), the advisory-tier Warning for the 702-line logic test file, and seven Info items requiring no action.
