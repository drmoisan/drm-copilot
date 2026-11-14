# Code Review: Prepared-Item Admission for /parallel-add and /parallel-plan (#1047)

---

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue 1047 in the branch name.
**Base Branch:** `main` (resolved `origin/main` merge base `01706c697f3ad4a53b4a771d99d851afc7417ea9`)
**Head Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `ae6ff1f05`
**Review Type:** Remediation re-audit after cycle 3 (previous sets `*.2026-11-03T18-43.md`, `*.2026-11-03T21-04.md`, and `*.2026-11-03T21-58.md`)

---

## Executive Summary

Cycle 3 (commit `ae6ff1f05`) resolves the one Minor finding of `code-review.2026-11-03T21-58.md` (item B1 of `remediation-inputs.2026-11-03T22-32.md`):

- In `Invoke-ParallelAdmissionAssess` (line 421 of `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`), the `IsNullOrWhiteSpace` test on the receipt `base_commit` is replaced by `[string]$baseCommit -cnotmatch '\A(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})\z'`. A value that does not match takes the existing `merge-base <main> <branch>` fallback, so it never reaches `Get-ParallelAdmissionAssessStaleness` (lines 365-373: `merge-base --is-ancestor`, `diff --name-only`, `cat-file -e`). A matching value is used unchanged.
- `Invoke-ParallelAdmission.Tests.ps1` folds two `assess` Its into one six-row table-driven It and replaces the non-hex `receipt999` placeholder with valid hex values. The file stays at 695 logical lines.
- The bundle copy is byte-equal.

Evidence reviewed: the cycle 3 diff (`fb83d2f05..ae6ff1f05`) and the full merge-base diff (190 files), both canonical coverage artifacts (parsed by this review), the cycle 3 evidence under `evidence/`, a review re-run of the touched suites plus the module-convention and file-size suites (294/294, all six new rows pass), PSScriptAnalyzer and formatter re-checks over 17 changed PowerShell files (0 findings, 0 differences), mirror comparison (12/12 byte-equal), and the PR #1064 check list at `ae6ff1f05`. The PR-context artifacts were last refreshed at `16f6b0460`; the review used `git diff` against the merge base for the current head, as the caller directed.

**What changed:**
Cycle 3 changes one condition, adds one comment line, and edits one help sentence in the CLI script and its bundle copy; it changes three Its in `Invoke-ParallelAdmission.Tests.ps1`; and it adds the cycle plan, inputs, and evidence.

**Top 3 risks:**
1. `reuse-edges` runs no fetch by design and reads whatever `origin/parallel/<slug>-plan` the last fetch left; the skill sequences it after `assess` (unchanged from the previous review).
2. The Layer 2 Python orchestrator-state validator still does not check `precedence[]` (documented gap D2, unchanged).
3. CI at `ae6ff1f05` is in progress at review time (7 passed, 16 pending, 0 failed); the S9 gate owns the final result.

**PR readiness recommendation:** **Ready** - zero Blocker or Major findings; the remaining items are Minor or Info and do not block the PR.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` (and bundle copy) | line 421 | The edited line reads `{ $baseCommit =[string[]](Invoke-ParallelAdmissionGitChecked ...` with no space after `=`; the replaced line had `= [string[]]`. The repository PSSA settings do not enable `PSUseConsistentWhitespace` `CheckOperator`, so the formatter and analyzer gates pass; a review probe with that option enabled flags the line. | Restore the space the next time the file is edited; no separate cycle is warranted. | Style consistency only; no behavior effect. Non-blocking. | Cycle 3 diff; review PSSA probe |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | line 421 | The format check is applied to `[string]$baseCommit`. A non-string JSON value (number, array, object) casts to a string that cannot match the anchored pattern, so it also takes the fallback; this is the intended absent-field behavior. | None. | Confirms the cast does not open a bypass. | Code inspection |
| Info | `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` | whole file | 695 logical lines, 5 below the 700-line advisory tier; no Warning applies. | Place further CLI cases in a sibling suite. | The next addition of six lines would cross the advisory tier. | `@(Get-Content -LiteralPath).Count` |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 73-74, 86, 328, 619, 623-625 | Eight lines are uncovered: the real git call, the real file read, one defensive return in `Get-ParallelAdmissionPlannerItem`, and the guarded entry body. File coverage 96.48%, equal to its baseline; the line numbers after 420 shifted by one for the added comment, and no missed line is in `Invoke-ParallelAdmissionAssess`. | None. | The seam bodies are mocked by design. | `artifacts/pester/powershell-coverage.xml` |
| Info | Full-tree Pester on this Linux host | `evidence/qa-gates/pester-coverage.2026-11-03T23-05.md` | 409 single-process failures, all in suites the branch does not add or change; the 97 distinct failure lines are identical to the cycle 2 run. | Rely on the `windows-latest` CI shards at S9; the host failures are tracked separately (#1066, #1067). | Pre-existing and unrelated to the feature; not a finding against this branch. | `policy-audit.2026-11-03T23-13.md` Section 8 |

Zero Blocker and zero Major findings. No covered file is at or above 700 logical lines, so no file-size Warning row applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python change in cycles 1 to 3; the two fragment-pin tuples from the initial delivery remain and pass in the contract set.

#### Typing and API notes

- No new Python API surface.

#### Error handling and logging

- Not applicable; data only.

### PowerShell implementation audit

#### What changed well

- The check sits at the single point where the receipt value is read, so every downstream git call (`merge-base --is-ancestor`, `diff`, `cat-file`) is protected without touching `Get-ParallelAdmissionAssessStaleness`.
- A rejected value reuses the existing absent-field fallback rather than introducing a new error path, so the output contract is unchanged.
- The anchored pattern (`\A...\z`) rejects a trailing newline, and the case-sensitive operator with a two-case character class accepts both lowercase and uppercase hex. Both SHA-1 (40) and SHA-256 (64) object-name lengths are accepted.
- The test table asserts, per row, both the emitted value and the count of `merge-base` or `diff` calls receiving the receipt value (`-ccontains`), which directly verifies that a rejected value never reaches git.

#### API and safety notes

- No option, subcommand, or output field was added; the exit-code contract (0, 1, 2) is unchanged.
- The permission rule `Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*)` is unchanged.

#### Error handling and logging

- A rejected receipt value is silent by design: it is treated as absent, and the emitted `base_commit` shows the merge base that was used.

---

## Test Quality Audit

The review re-ran the touched suites on Linux at HEAD with coverage disabled: 294 tests, 0 failures (hook 62, CLI 85, integration 12, manifest 5, admission 56, JSON 12, precedence 51, module convention 6, file-size gate 5).

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` - `takes the receipt base commit only when it is a full object name: <Case>` with rows `40-char lowercase hex`, `64-char uppercase hex`, `option-shaped`, `short hex`, `40-char non-hex`, `empty`; all six pass in the review run.
- `evidence/qa-gates/pester-targeted.2026-11-03T22-44.md` - targeted JUnit run with per-row status.
- `evidence/regression-testing/pester-shuffle.2026-11-03T22-44.md` - seeds 11, 23, 47; executed order matches seeded order.
- `evidence/qa-gates/pester-coverage.2026-11-03T23-05.md` - per-function missed-line table; figures match the artifact read by this review.
- `evidence/other/mirror-hashes.2026-11-03T22-43.md` - equal SHA256 for the script pair; the review's `cmp` agrees.

### Quality assessment prompts

- **Determinism:** each row sets its git response inside the It and uses the Describe `BeforeEach` mock.
- **Isolation:** each row is independent row data in one It.
- **Speed:** 294 tests in 10.5 s.
- **Diagnostics:** `-BeExactly` on the emitted value and exact call-count assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no tokens, keys, or host paths. |
| No unsafe subprocess or command construction | ✅ PASS | `& git @GitArgs` with an argument array; option-shaped command-line refs rejected (cycle 2); receipt `base_commit` restricted to a full hex object name (cycle 3). |
| Input validation at boundaries | ✅ PASS | Command-line options and the receipt value that reaches git are both validated. |
| Error handling remains explicit | ✅ PASS | Exit codes 0, 1, 2; prefixed stderr lines. |
| Configuration / path handling is safe | ✅ PASS | No path handling changed in cycle 3. |

---

## Research Log

No external research was required. Findings derive from the branch diff, repository rules, the canonical coverage artifacts, and local re-runs.

---

## Verdict

Cycle 3 resolves the one finding of the previous review. The remaining Minor style note and the Info items do not block the PR. Zero blocking findings; the branch is ready for the CI green gate.
