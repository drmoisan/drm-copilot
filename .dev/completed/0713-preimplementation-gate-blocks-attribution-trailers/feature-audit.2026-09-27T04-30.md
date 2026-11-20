# Feature Audit: Preimplementation Gate Attribution Trailers (#713)

**Audit Date:** 2026-09-27
**Timestamp:** 2026-09-27T04-30
**Branch:** `bug/preimplementation-gate-blocks-attribution-trailers-713` @ `586e9037255b17d75c01d9c5f3e7b87b42aa4333`
**Base:** merge-base `2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d` (`origin/main`)
**Work mode:** `full-bug` (marker `- Work Mode: full-bug` in `issue.md`)
**AC source:** `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/spec.md`, section `## Acceptance Criteria` (AC1 to AC11)

---

## Scope and Baseline

- **Baseline behaviour (base `2d9bb87c`).** With no ready feature checkpoint, the staging exemption denied:
  - any `$` or backtick in any quote state;
  - any option on `git commit` other than `-m`, `--message`, `--message=`, and `-m<value>`.

  A `--trailer` form, and a single-quoted message containing `$` or a backtick, were therefore denied. An inline `Co-Authored-By: Name <email>` inside quotes was already admitted by #663. The base also admitted the S4 `#'` comment-desynchronization line (fail-before evidence).
- **Post-change behaviour (head `586e9037`).**
  - `--trailer` and `--trailer=` are admitted on `git commit` only.
  - `$` and backtick are admitted inside single quotes.
  - An unquoted `#` is denied.
  - Every other base denial is unchanged.
- **Scope source.** The full branch diff `git diff 2d9bb87c...HEAD`: 55 files. There are 4 helper copies, 1 new test, 4 skill documents, and 46 feature-folder Markdown files. `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent, and the generator is not in this agent's tool set, so scope was taken from git directly.
- **Approvals and deviations.** Operator approval (2026-09-26) covers spec D1 to D13 and planner P1 to P6. Orchestrator deviations X1 to X3 (`evidence/other/execution-deviations.md`) change the commit cadence, the base derivation, and one version command. None changes the design or an acceptance criterion.
- **Issue checkboxes.** `issue.md` carries five unchecked `## Acceptance Criteria` items. In `full-bug` mode they are not the AC source. The spec maps each of them to AC1 to AC10 in its traceability line, so they are not evaluated separately here.

---

## Acceptance Criteria Inventory

### Acceptance criteria

| ID | Summary | Source checkbox state at review |
|---|---|---|
| AC1 | `--trailer` (separate-value and `=` forms, repeated, commit only) admitted by both gates at the decision seam | `[x]` |
| AC2 | One-paragraph multi-`-m` form admitted by both gates (pass-before pin) | `[x]` |
| AC3 | `$`/backtick inside single quotes admitted; `<`/`>` inside quotes still admitted; `$`/backtick inside double quotes still denied (D2) | `[x]` |
| AC4 | Relaxation opens no bypass; eight deny classes at predicate level, one row each | `[x]` |
| AC5 | Pre-existing `#` comment bypass closed; fail-before shows it admitted on base; quoted `#` still admitted | `[x]` |
| AC6 | Four helper copies SHA256-identical; Parity and legacy-codex suites pass; skill pairs identical; push-down contracts pass in CI | `[ ]` |
| AC7 | Helper at or under 500 lines and not longer than before; diff confined to named functions; `Split-OrchestrationCommandLine` and gate files unmodified; test file at or under 500 lines | `[x]` |
| AC8 | Skill documents and mirrors document the five required items; helper comments state the new rules | `[x]` |
| AC9 | Fail-before and pass-after evidence under `evidence/regression-testing/`, with the D13 statement | `[x]` |
| AC10 | PowerShell toolchain single pass; helper line coverage at or above 85%, no regression on changed lines; existing suites pass | `[x]` |
| AC11 | New suite hygiene: no temp files, git process, `origin/main`, gitignored state, or drive letters; deny rows at predicate level | `[x]` |

---

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence (verified by reviewer unless noted) |
|---|---|---|
| AC1 | PASS | Admit rows 1 to 3, 7, 8, and 12 call `Invoke-OrchestrationPreimplementationGateDecision` for both runtimes and assert `permissionDecision` `allow`. Helper lines 402 and 410 add `--trailer`; `git add` is rejected by the line-399 guard. Fail-before: these rows failed on base for both runtimes; pass-after: 68/68 (`evidence/regression-testing/`). |
| AC2 | PASS | Admit row 4 builds the second `-m` value with `[char]10` and passes on both runtimes, before and after the fix (pass-before pin per D13). `Split-OrchestrationCommandLine` keeps a quoted newline inside the segment (helper lines 79-85). |
| AC3 | PASS | Line 140 skips the interpolation check only when `$openQuote` is `'`. Admit rows 5 and 6 (single-quoted backtick, `$5` and `$(x)`) pass; admit row 11 (quoted `<`/`>`) passes; deny rows 4 to 6 (double-quoted `$`, `$(date)`, backtick) pass. D2 narrows issue AC2 to single quotes for these two characters. |
| AC4 | PASS | Deny rows cover each enumerated class on both runtimes and assert both predicates: redirection (row 1); substitution and expansion outside or in double quotes, including the heredoc recipe and `$'...'` (rows 2 to 8); chaining (rows 9, 10); non-exempt path with `--trailer` (11); pathless (12); `git add --trailer` (13); dangling `--trailer` (14); `-F`, `--file=`, `-F - <<'EOF'` (15 to 17). Reviewer note: the code review records two non-blocking items outside AC4's enumerated classes. CR-1 is a conditional PowerShell-interpreter quote desynchronization on the Codex surface. CR-2 is a pre-existing brace-expansion operand bypass not introduced by this branch. Neither contradicts an AC4 clause as written. |
| AC5 | PASS | Line 36 adds `#` to `OutsideQuoteCommandCharacters`, and line 156 denies it outside quotes. Deny rows 18 (the S4 `#'` line), 19 (`# note`), and 20 (mid-word `#`) pass. The fail-before run records row 18 as FAILED on base for both runtimes, with a `PRE_EXISTING_BYPASS` statement. Admit rows 9 and 10 (quoted `#`) pass. |
| AC6 | PARTIAL (non-blocking; CI clause pending) | Local clauses are met. The reviewer recomputed SHA256 `9e84af14...f1bae7` for all four helper copies, and all four committed blobs are `c3510b7f`. Parity 2/2 and legacy-codex 43/43 pass (`evidence/qa-gates/final-pester-full.md`). Skill pairs are byte-identical (epic-plan `69655fde...`, parallel-plan `92577726...`, recomputed). Locally, `test_push_down_claude_resource_contracts.py` fails only on the known gitignored-state case, issue #510 (`evidence/qa-gates/final-pytest-push-down.md`). The clause "passes in CI" cannot be observed until the PR exists. Per caller direction, it is recorded as pending and is not a blocking finding. |
| AC7 | PASS | `wc -l`: helper 497 (base 497 via `git show 2d9bb87c:...`); test file 99. Diff hunks sit only in the constants block (lines 28-36), `Test-OrchestrationCommandTextUnresolvable` (112-156), and `Test-ExemptOrchestrationSegmentToken` (393-410). Neither gate file appears in `git diff --name-status`, and `Split-OrchestrationCommandLine` has no hunk. |
| AC8 | PASS | The "Attribution trailers (issue #713)" subsection in both `.claude/skills/{epic-plan,parallel-plan}/SKILL.md` and both mirrors states five things: the `--trailer` form; the one-paragraph multi-`-m` form, including that separate `-m` trailer values do not form one trailer block; the single-quote rule for `$` and backtick; the unquoted-`#` denial; and the non-admitted `$(cat <<'EOF' ...)`, `-F - <<'EOF'`, `-F <file>`, and `--file=<file>` forms. The helper constants comment (lines 30-34) and the `Test-OrchestrationCommandTextUnresolvable` help (lines 115-120) state the new rules. Code review CR-3 notes one stale inline comment elsewhere (lines 467-468), which AC8 does not require. |
| AC9 | PASS | `evidence/regression-testing/fail-before-attribution-trailer.md` (exit 1; 20 failed: the ten predicted names x 2 runtimes, covering single-quoted `$`/backtick, `--trailer`, `#'`, and mid-word `#`). `pass-after-attribution-trailer.md` (68 passed). `fail-before-exception.2026-09-27T03-34.md` states that the inline angle-bracket case cannot fail before, because of #663, and is a pass-before pin. |
| AC10 | PASS | Format: 0 changed of 531. Analyze: no findings. Full Pester: 5303 passed, 0 failed; JUnit 5312, 0 failures, 0 errors. Scoped coverage: 98.25% per canonical helper copy (baseline 97.08%), with changed lines 36, 140, 156, 402, and 410 executed. The reviewer re-read `artifacts/pester/powershell-coverage.xml`: helper `LINE missed=3 covered=168` in both entries, and repo-wide PowerShell 10038/10455 = 96.01%. The single pass is recorded in `evidence/qa-gates/final-seven-stage-loop.md`. |
| AC11 | PASS | The reviewer read the 99-line suite: no temp-file API, no `git` invocation, no `origin/` or `artifacts/` or `.claude/state` reference, and no drive-letter path; paths come from `$PSScriptRoot`. Deny rows (lines 67-98) call only `Test-ExemptOrchestrationStagingCommand` and `Test-ImplementationCommand`. `evidence/qa-gates/test-portability-inspection.md` shows all hygiene tokens at matches=0. |

---

## Summary

- 10 of 11 acceptance criteria PASS on verified evidence.
- AC6 is PARTIAL only because its CI clause is unobservable before the PR exists. Its local clauses are met, and it is non-blocking per caller direction.
- No acceptance criterion FAILs. Blocking findings in this audit: 0.
- Non-blocking follow-ups raised by this review (details in `code-review.2026-09-27T04-30.md`):
  1. **CR-1 (Major, conditional).** Decide whether the helper must deny U+2018 to U+201E quote look-alikes, or record that Codex `Bash` commands are always POSIX-interpreted. Merge with the #710 shell-dialect follow-up.
  2. **CR-2 (Major, pre-existing).** File an issue for the brace-expansion operand bypass in `Test-ExemptOrchestrationOperand`.
  3. **CR-3 (Minor).** Update the stale inline comment at helper lines 467-468.
  4. **CR-4 (Nit).** Optionally pin `--trailer` consuming a following `--` token.
- Executor-recorded follow-ups (`evidence/other/follow-ups.md`):
  - the `.agents/skills/epic-plan/SKILL.md` Integration Commit Form;
  - optional heredoc modelling;
  - the worktree-removal gate denying `git --version`.
- **Housekeeping.** The Phase 5 row of `evidence/other/commits-log.md` is modified but uncommitted, because it records the final commit's own SHA. Commit it with these review artifacts.

---

## Acceptance Criteria Check-off

Reviewer check-off actions against `spec.md`:

- AC1, AC2, AC3, AC4, AC5, AC7, AC8, AC9, AC10, AC11: evaluated PASS and already `[x]` in `spec.md`. No change was needed.
- AC6: evaluated PARTIAL (CI clause pending). Left `[ ]` per the acceptance-criteria-tracking protocol. The orchestrator checks it off after the CI run on the PR head passes, including `test_push_down_claude_resource_contracts.py`.
- No criterion text was modified, and no criterion was added.

### AC Status Summary

### Acceptance Criteria Status
- Source: `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/spec.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: AC6: "After the change, the four helpers copies ... are byte-identical by SHA256 ... and `test_push_down_claude_resource_contracts.py` passes in CI." (local clauses verified; CI clause pending the PR)
