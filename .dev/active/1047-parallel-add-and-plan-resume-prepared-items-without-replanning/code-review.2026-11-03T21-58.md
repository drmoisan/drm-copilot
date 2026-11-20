# Code Review: Prepared-Item Admission for /parallel-add and /parallel-plan (#1047)

---

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue 1047 in the branch name.
**Base Branch:** `main` (resolved `origin/main` @ `01706c697f3ad4a53b4a771d99d851afc7417ea9`, equal to the merge base)
**Head Branch:** `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `22af34134`
**Review Type:** Remediation re-audit after cycle 2 (previous sets `*.2026-11-03T18-43.md` and `*.2026-11-03T21-04.md`)

---

## Executive Summary

Cycle 2 (commit `22af34134`) resolves both Minor findings of `code-review.2026-11-03T21-04.md`:

- N1: `Get-ParallelAdmissionUsageError` (lines 191-194 of `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`) loops over `Branch`, `Main`, and `Ref` and returns `-<name> must not begin with '-'; got '<value>'.` for a non-empty value with a leading `-` (ordinal comparison). The check runs for every subcommand before dispatch, so no git call is made with such a value. The parametrized usage It now takes a `Subcommand` column and carries one row per option.
- N2: `spec.md` `## Implementation Strategy` names `ParallelAdmissionJson.psm1` (JSON parse and serialize helpers); the `## Acceptance Criteria` section is unchanged.

Evidence reviewed: the PR-context summary (generated 2026-11-03 21:57 UTC for head `22af3413`), the cycle 2 diff, both canonical coverage artifacts (parsed by this review), the cycle 2 evidence under `evidence/`, a review re-run of the touched suites plus the module-convention and file-size suites (290/290), PSScriptAnalyzer and formatter re-checks over 17 changed PowerShell files (0 findings, 0 differences), mirror comparison (12/12 byte-equal), and real CLI calls with option-shaped and valid ref values.

**What changed:**
Cycle 2 adds four lines to the CLI script (one comment and a three-line loop) and its bundle copy, changes three lines and adds three rows in `Invoke-ParallelAdmission.Tests.ps1`, edits one spec line, and adds the cycle evidence.

**Top 3 risks:**
1. The receipt's `base_commit` value, read from a committed file on the item branch, reaches `git merge-base --is-ancestor <base> <main>` and `git diff --name-only --no-renames <base> <main>` as a bare argument without a format check. It is written by the preparation child, not supplied on the command line, so the exposure is lower than the N1 case. Recorded as a Minor finding.
2. `reuse-edges` runs no fetch by design and reads whatever `origin/parallel/<slug>-plan` the last fetch left; the skill sequences it after `assess` (unchanged from the previous review).
3. The Layer 2 Python orchestrator-state validator still does not check `precedence[]` (documented gap D2, unchanged).

**PR readiness recommendation:** **Ready** - zero Blocker or Major findings; the remaining items are Minor or Info and do not block the PR.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 365-366 (`Get-ParallelAdmissionAssessStaleness`), 419-420 (`assess` receipt read) | The receipt field `base_commit` is passed to `git merge-base --is-ancestor` and to `git diff --name-only --no-renames <base> <main>` without a format check; a value that begins with `-` would be parsed by git as an option. N1 closed the same gap for the command-line options only. | Validate a receipt `base_commit` as a 40- or 64-character hex object name (or at least reject a leading `-`), and treat an invalid value like an absent receipt field, with one CLI test. | Defense in depth; the receipt is agent-written branch content, and `merge-base --is-ancestor` already tolerates failure by returning a non-zero exit. Not a regression introduced by cycle 2. | Code inspection at HEAD; `grep -n base_commit` shows no validation |
| Info | `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` | whole file | 695 logical lines, 5 below the 700-line advisory tier; no Warning applies. | Place further CLI cases in a sibling suite. | The next addition of six lines would cross the advisory tier. | `@(Get-Content -LiteralPath).Count` |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 31-33 (script `param` block) | Through `pwsh -File`, a bare `-Ref -p` is consumed by the PowerShell parameter binder (ambiguous parameter name, exit 1) before the new check runs; `-Ref:-p` and `-Ref --output=x` reach the check and exit 2. Either way no git call is made. | None. | Records the two rejection routes for later readers of the usage contract. | Review CLI probes |
| Info | `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` | lines 73-74, 86, 328, 618, 622-624 | Eight lines are uncovered: the real git call, the real file read, one defensive return in `Get-ParallelAdmissionPlannerItem`, and the guarded entry body. File coverage 96.48%, above its 96.44% baseline; the new lines 192-193 are covered. | None. | The seam bodies are mocked by design; the review exercised the guarded entry body through `pwsh -File`. | `artifacts/pester/powershell-coverage.xml` |
| Info | Full-tree Pester on this Linux host | `evidence/qa-gates/pester-coverage.2026-11-03T21-51.md` | 409 single-process failures, all in suites the branch does not add or change; the 97 distinct failure lines are identical to the cycle 1 run, which was shown to be pre-existing at the merge base. | File the PATH leak at `tests/scripts/dev-tools/run-actionlint.Tests.ps1` line 497 as a separate test-isolation issue; rely on the `windows-latest` CI shards at S9. | Pre-existing and unrelated to the feature; not a finding against this branch. | `policy-audit.2026-11-03T21-58.md` Section 8 |

Zero Blocker and zero Major findings. No covered file is at or above 700 logical lines, so no file-size Warning row applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python change in cycles 1 or 2; the two fragment-pin tuples from the initial delivery remain and pass in the contract set.

#### Typing and API notes

- No new Python API surface.

#### Error handling and logging

- Not applicable; data only.

### PowerShell implementation audit

#### What changed well

- The check sits in the single validation function every subcommand passes through, so it covers `assess`, `record`, `reuse-edges`, and any subcommand that later accepts these options.
- `IsNullOrEmpty` leaves an omitted option to its default (`origin/main` for `-Main`), and the ordinal `StartsWith` avoids culture-sensitive comparison.
- The message names the option and echoes the value, matching the format of the existing `-Band` and `-IssueNum` usage errors.
- The test change generalizes the existing parametrized It rather than adding a new block, which keeps the file below the advisory tier.

#### API and safety notes

- No option, subcommand, or output field was added; the exit-code contract (0, 1, 2) is unchanged.
- The permission rule `Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1*)` is unchanged.
- Receipt-supplied `base_commit` remains unchecked; see the Minor finding.

#### Error handling and logging

- Usage errors exit 2 with the `parallel admission usage error:` prefix before any I/O.

---

## Test Quality Audit

The review re-ran the touched suites on Linux at HEAD with coverage disabled: 290 tests, 0 failures (hook 62, CLI 81, integration 12, manifest 5, admission 56, JSON 12, precedence 51, module convention 6, file-size gate 5).

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` - `exits 2 on <Subcommand> <Name> <Value>` with six rows (three existing `reuse-edges` rows, now with an explicit `PlanHash`, and the three new `-Branch`, `-Main`, `-Ref` rows); assertions use `-BeExactly` on the prefixed message.
- `evidence/qa-gates/pester-targeted.2026-11-03T21-29.md` - 228/228 with per-row JUnit status.
- `evidence/regression-testing/pester-shuffle.2026-11-03T21-30.md` - seeds 11, 23, 47; executed order matches seeded order.
- `evidence/qa-gates/pester-coverage.2026-11-03T21-51.md` - per-function missed-line table; figures match the artifact read by this review.

### Quality assessment prompts

- **Determinism:** the new rows return before any seam is called.
- **Isolation:** each row is independent row data in one It.
- **Speed:** 290 tests in 11.7 s.
- **Diagnostics:** exact-message assertions name the option and value.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no tokens, keys, or host paths. |
| No unsafe subprocess or command construction | ✅ PASS | `& git @GitArgs` with an argument array; option-shaped command-line refs now rejected. Receipt `base_commit` recorded as Minor. |
| Input validation at boundaries | ✅ PASS | `-Branch`, `-Main`, `-Ref` leading-dash check in addition to the existing `-Slug`, `-IssueNum`, `-Band`, `-Floor` checks. |
| Error handling remains explicit | ✅ PASS | Exit codes 0, 1, 2; prefixed stderr lines. |
| Configuration / path handling is safe | ✅ PASS | No path handling changed in cycle 2. |

---

## Research Log

No external research was required. Findings derive from the branch diff, repository rules, the canonical coverage artifacts, and local re-runs.

---

## Verdict

Cycle 2 resolves both findings of the previous review. The one new Minor finding (receipt `base_commit` reaches git unchecked) and the Info items do not block the PR. The branch is ready for the PR creation gate.
