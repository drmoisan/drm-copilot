# Feature Audit: Preimplementation Gate Attribution Trailers (#713) - Remediation Cycle 1 Reaudit

**Audit Date:** 2026-09-27
**Timestamp:** 2026-09-27T06-40
**Branch:** `bug/preimplementation-gate-blocks-attribution-trailers-713` @ `19d0a7046825f5c96fb6deaad518b35a60486421`
**Base:** merge-base `2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d` (`origin/main`)
**Work mode:** `full-bug` (marker `- Work Mode: full-bug` in `issue.md`)
**AC source:** `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/spec.md`, section `## Acceptance Criteria` (AC1 to AC11)

---

## Scope and Baseline

- **Baseline behaviour (base `2d9bb87c`).** With no ready feature checkpoint, the staging exemption denied:
  - any `$` or backtick in any quote state;
  - any `git commit` option other than `-m`, `--message`, `--message=`, and `-m<value>`.

  The base admitted the S4 `#'` comment-desynchronization line.
- **Post-change behaviour (head `19d0a704`).**
  - `--trailer` and `--trailer=` are admitted on `git commit` only.
  - `$` and backtick are admitted inside straight single quotes.
  - An unquoted `#` is denied.
  - New in remediation cycle 1: any of U+2018 to U+201E anywhere in the command text makes the line unresolvable, so the exemption is withheld.
  - Every other base denial is unchanged.
- **Scope source.** The full branch diff `2d9bb87c..19d0a704` (92 files):
  - 4 helper copies;
  - 1 new test file;
  - 4 skill documents;
  - 83 feature-folder Markdown files.

  The reviewer regenerated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` for head `19d0a704`; the previous copies were generated at `0ccba6b3`.
- **Cycle-1 inputs.** `remediation-inputs.2026-09-27T05-05.md` contains F1 (CR-1) and F2 (CR-3). The plan is `remediation-plan.2026-09-27T05-05.md`, with decisions R1 to R8. R1 treats any of the seven characters anywhere as unresolvable. R7 unchecks AC6 until CI passes on the new head.
- **Deviations.** X1 to X4 in `evidence/other/execution-deviations.md` cover commit cadence, the base derivation, the `git version` substitution, and the trailer-check command spelling. None changes the design or an acceptance criterion.
- **Issue checkboxes.** In `full-bug` mode the five `issue.md` items are not the AC source. The spec traceability line maps them to AC1 to AC10.

---

## Acceptance Criteria Inventory

### Acceptance criteria

| ID | Summary | Source checkbox state at review |
|---|---|---|
| AC1 | `--trailer` (separate-value and `=` forms, repeated, commit only) admitted by both gates at the decision seam | `[x]` |
| AC2 | One-paragraph multi-`-m` form admitted by both gates (pass-before pin) | `[x]` |
| AC3 | `$`/backtick inside single quotes admitted; `<`/`>` inside quotes still admitted; `$`/backtick inside double quotes still denied (D2) | `[x]` |
| AC4 | Relaxation opens no bypass; enumerated deny classes at predicate level, one row each | `[x]` |
| AC5 | Pre-existing `#` comment bypass closed; quoted `#` still admitted | `[x]` |
| AC6 | Four helper copies SHA256-identical; Parity and legacy-codex suites pass; skill pairs identical; push-down contracts pass in CI | `[ ]` (R7) |
| AC7 | Helper at most 500 lines and not longer than before; diff confined to the named regions; `Split-OrchestrationCommandLine` and gate files unmodified; test file at most 500 lines | `[x]` |
| AC8 | Skill documents and mirrors document the required items; helper comments state the rules | `[x]` |
| AC9 | Fail-before and pass-after evidence under `evidence/regression-testing/` | `[x]` |
| AC10 | PowerShell toolchain single pass; helper line coverage at or above 85%; no regression on changed lines; existing suites pass | `[x]` |
| AC11 | New suite hygiene; deny rows at predicate level | `[x]` |

---

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence (verified by reviewer unless noted) |
|---|---|---|
| AC1 | PASS | Unchanged since the previous audit. Admit rows 1 to 3, 7, 8, and 12 pass predicate-then-decision (`allow`) on both runtimes (`remediation-c1-pass-after-typographic-quotes.md`, 74/74; full JUnit AttributionTrailer `tests=74 failures=0 errors=0`). Helper lines 402 and 410 are unchanged in cycle 1. |
| AC2 | PASS | Admit row 4 (the `[char]10` paragraph) passes on both runtimes. |
| AC3 | PASS | Re-verified at the new head. Line 140 (`$openQuote -ne "'"`) is unchanged. The single-quoted `$`/`$(x)` and backtick admit rows pass on both runtimes. The quoted `<`/`>` admit row passes. The double-quoted `$`, `$(date)`, and backtick deny rows pass. Under R1, a line carrying a typographic quote is denied because of that character, not because of the `$`, so "`$` and backtick inside a single-quoted span no longer cause a denial on their own" still holds. |
| AC4 | PASS | Re-verified. The 22 original deny rows and the 3 cycle-1 typographic-quote deny rows pass at predicate level on both runtimes (`Test-ExemptOrchestrationStagingCommand` false, `Test-ImplementationCommand` true). The cycle-1 fail-before run shows that the 3 new rows failed against the pre-fix helper (6 FAILED), which proves that the fix closes CR-1. CR-2 (brace expansion) is pre-existing, outside AC4's enumerated classes, and out of scope by coordinator ruling. |
| AC5 | PASS | Unchanged. Line 35 includes `#` in `OutsideQuoteCommandCharacters`, and line 156 denies it outside quotes. The S4, `# note`, and mid-word `#` deny rows pass. The quoted-`#` admit rows pass. |
| AC6 | PARTIAL (non-blocking; CI clause pending per R7) | Local clauses verified by the reviewer: the four helper copies share SHA256 `dc4e7da5...035b0d65` and blob `4df8e074`; the skill pairs are byte-identical (epic-plan blob `5659c2bf` x2, parallel-plan blob `63fd74fd` x2). Parity 2/2 and legacy-codex 43/43 pass (`remediation-c1-final-pester-full.md`, `remediation-c1-parity-and-legacy-contracts.md`). Locally, `test_push_down_claude_resource_contracts.py` fails only on the known gitignored-state case (#510, `remediation-c1-final-pytest-push-down.md`). The clause "passes in CI" requires a CI run on head `19d0a704` and is pending. Not a blocking finding. |
| AC7 | PASS | Re-verified. `wc -l` gives 497 for the helper, and 497 for both base and the pre-edit head `0ccba6b3`. The helper is therefore not longer than its pre-edit count and within 500. Diff hunks against base appear only in the constants block (28-36), `Test-OrchestrationCommandTextUnresolvable` (112-156), `Test-ExemptOrchestrationSegmentToken` (393-410), and the comment lines 467-468 of `Test-ExemptOrchestrationStagingCommand`. Neither gate file appears in the branch name list, and `Split-OrchestrationCommandLine` has no hunk. The test file has 102 lines. |
| AC8 | PASS | Both skill pairs keep the "Attribution trailers (issue #713)" subsection with all required items, and now add the typographic-quote sentence. The constants comment (lines 30-33), the function help (lines 115-120), and the row-12 comment (lines 467-468) state the current rule. CR-3 is resolved. |
| AC9 | PASS | Original evidence is `fail-before-attribution-trailer.md`, `pass-after-attribution-trailer.md`, and `fail-before-exception.2026-09-27T03-34.md`. Cycle 1 adds `remediation-c1-fail-before-typographic-quotes.md` (exit 1 as expected; 6 FAILED) and `remediation-c1-pass-after-typographic-quotes.md` (74 passed). |
| AC10 | PASS | Re-verified at the new head. Format reports 0 changed of 531. Analyze reports no findings. Full Pester: 5309 passed, 0 failed, 9 skipped; JUnit 5318 tests, 0 failures, 0 errors; all 18 HRS suites at `failures=0 errors=0`. Scoped coverage is 98.26% per canonical copy (169/172; baseline at base 97.08%, pre-cycle 98.25%), and all 7 changed executable lines are executed. The reviewer re-read `artifacts/pester/powershell-coverage.xml`: helper `LINE missed=3 covered=169` in both entries, and repo-wide PowerShell lines 10040/10457 = 96.01%. The single pass is recorded in `remediation-c1-final-seven-stage-loop.md`. The code-bearing tree at `3e006ccd` equals `19d0a704`, because the final commit touches only the feature folder. |
| AC11 | PASS | The reviewer read the 102-line suite. It contains no temp-file API, no `git` invocation, and no `origin/`, `artifacts/`, or `.claude/state` reference. Paths come from `$PSScriptRoot`. There are 0 non-ASCII bytes, because the new characters are built with `[char]0x....`. All 25 deny rows call only the two predicates. `remediation-c1-test-portability-inspection.md` records matches=0. |

---

## Summary

- **Result.** 10 of 11 acceptance criteria PASS on verified evidence at head `19d0a704`. AC6 is PARTIAL only because its CI clause awaits a CI run on the new head (decision R7). Its local clauses are met, so it is non-blocking. No criterion FAILs. Blocking findings in this audit: 0.
- **Remediation findings.**
  - F1 / CR-1 is RESOLVED. No `$` or backtick admission path through U+2018 to U+201E remains, and a straight-single-quoted `$` is still admitted.
  - F2 / CR-3 is RESOLVED.
- **Exit-gate checks.**
  - The four helper copies are byte-identical.
  - The helper is 497 lines, which is at most 500 and not longer than 497.
  - The helper and test file are ASCII-only.
  - AC3, AC4, AC6 (local), AC7, and AC10 were re-verified against the new head.
- **Non-blocking follow-ups.**
  - New Nit: deny rows for U+201A, U+201B, and U+201E. See `code-review.2026-09-27T06-40.md`.
  - New Nit: line 131 length (optional).
  - Out of scope by coordinator ruling:
    - CR-2 (brace-expansion exempt-path bypass, pre-existing);
    - CR-4 (`--trailer --` test);
    - `.agents/skills/epic-plan/SKILL.md` trailer forms;
    - heredoc support;
    - the `enforce-parallel-worktree-removal-gate.ps1` false positive on `git --version`.
- **Housekeeping.** Two feature-folder files are modified but uncommitted: the Phase 4 row of `evidence/other/remediation-c1-commits-log.md` and the `[P4-T17]` check-off in the remediation plan. Commit them with these review artifacts.

---

## Acceptance Criteria Check-off

Reviewer check-off actions against `spec.md`:

- AC1, AC2, AC3, AC4, AC5, AC7, AC8, AC9, AC10, AC11: evaluated PASS. They are already `[x]` in `spec.md`, so no change was needed.
- AC6: evaluated PARTIAL, with the CI clause pending per R7. It is left `[ ]` under the acceptance-criteria-tracking protocol. The orchestrator checks it off after the CI run on head `19d0a704` (or a later head) passes, including `test_push_down_claude_resource_contracts.py`.
- No criterion text was modified, and no criterion was added. The reviewer made no edit to `spec.md`.

### AC Status Summary

### Acceptance Criteria Status
- Source: `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/spec.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: AC6: "After the change, the four helpers copies ... are byte-identical by SHA256 ... and `test_push_down_claude_resource_contracts.py` passes in CI." (local clauses verified; CI clause pending on the new head, decision R7)
