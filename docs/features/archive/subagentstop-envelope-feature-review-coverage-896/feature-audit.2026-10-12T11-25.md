# Feature Audit: subagentstop-envelope-feature-review-coverage (Issue #896)

- Timestamp: 2026-10-12T11-25
- Reviewer: feature-review agent
- Work mode: `full-bug` (marker `- Work Mode: full-bug` in `issue.md` line 10); AC source: `spec.md` only

## Scope and Baseline

- Base branch: `origin/epic/subagentstop-envelope-integration` @ `486e8c06e52977b83dec5307806c5be8a90ab8f9`; merge-base `486e8c06e52977b83dec5307806c5be8a90ab8f9`.
- Head: `f1dc01c3c528155db68d21056c75dbf1ac014d90` (local `exec-896-ac7`; remote branch `bug/subagentstop-envelope-feature-review-coverage-exec-896`).
- AC `<base>` recorded by AC-1: `ebf4504ae6f881c5b34b91082b3df474c04d13f2` (integration tip at Phase 0); the integration ref later advanced to `486e8c06e` and was merged into the branch at `8258fd2f1` with no change to any file in this feature's scope (`evidence/other/corpus-rule-changes.2026-10-12T06-02.md` line 12).
- Diff: `git diff origin/epic/subagentstop-envelope-integration...HEAD`, 118 files, 21 commits.
- PR context: `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt`, generated 2026-10-12 11:17 UTC at head `f1dc01c3c` (current).
- Plan: `plan.2026-10-11T07-58.md` (all tasks checked).
- Reviewer verification: 1117 Pester tests and 87 pytest tests rerun (all passed); PSScriptAnalyzer and formatter rerun (clean); coverage XML parsed independently; mirror SHA256 parity recomputed; scope and policy diffs rerun.

## Acceptance Criteria Inventory

| ID | Area | Summary | Source state at review start |
|---|---|---|---|
| AC-1 | Upstream dependency | Upstream-merge check with 13-item E1 comparison and verdict | checked |
| AC-2 | Claude transport | E1 helper guarded dot-source; no `CLAUDE_HOOK_INPUT`/`Write-Error`/`exit 1` (`E4-ST1`) | checked |
| AC-3 | Claude transport | `E4-TR1` stdin envelope without tokens exits 2 | checked |
| AC-4 | Claude transport | `E4-TR2`, `E4-TR3`, `E4-TR3b` block paths exit 2 | checked |
| AC-5 | Claude transport | `-InputText` only (`E4-ST2`); dependency decision unchanged; TG1-TG3 | checked |
| AC-6 | Claude transport | Four suites free of `CLAUDE_HOOK_INPUT` and `-RawPayload`; pass | checked |
| AC-7 | CR-4 | `E4-TR4a` defaults on absent file; `E4-TR4` unreadable blocks | checked |
| AC-8 | CR-4 | Help text on absent/unreadable (`E4-ST3`); `falls back independently` | checked |
| AC-9 | CR-8 | `-metrics` and `-rules` files, function lists (`E4-ST4`), manifest | checked |
| AC-10 | CR-8 | Six production files under 500 lines, recorded | checked |
| AC-11 | CR-9 | `E4-TR5` positive and negative resolver rows | checked |
| AC-12 | CR-9 | `E4-TR6` source labels; `E4-ST5` help forms | checked |
| AC-13 | CR-6 | Shared mock helper; `E4-ST6` AST check | checked |
| AC-14 | Codex | Thresholds copy hash parity (`E4-PX2`) and rows on Codex copy | checked |
| AC-15 | Codex | Guarded dot-source; no `.claude/` path; no fixed 80 (`E4-ST7`) | checked |
| AC-16 | Codex | `E4-TR7`, `E4-TR8`, `E4-TR9` | checked |
| AC-17 | Codex | Transport/continuation contract suites pass; config unchanged | checked |
| AC-18 | Codex | Manifest entry; `$script:SharedModuleNames`; legacy suite < 500 lines | checked |
| AC-19 | Codex | Floor parity suite `E4-PX1` (85, 70, 92) | checked |
| AC-20 | Texts | `test_feature_review_texts_name_claude_md_floor_source` over 8 copies | checked |
| AC-21 | Texts | `STEP_EIGHT_COPIES` and `EXPECTED_LISTED_COPY_COUNT` | checked |
| AC-22 | Texts | No change under `.github/instructions` or `.claude/rules` | checked |
| AC-23 | Mirrors | Byte-identical mirrors; parity tests; mirror log | checked |
| AC-24 | Verification | Fail-first on base and pass on head for TR1, TR4, TR5-P, TR7 | checked |
| AC-25 | Verification | Baseline and final per-file coverage, >= 85% for six files | checked |
| AC-26 | Verification | Constraint checks (no `.py` in hooks, no Python invocation, token count, no temp files) | checked |
| AC-27 | Verification | Out-of-scope files untouched | checked |
| AC-28 | Verification | Full toolchain single pass recorded | checked |
| AC-29 | Issue closure | PR body `Refs #884`, `Refs #897`, no closing keyword for them | unchecked |
| AC-30 | E1 consumer policy | Re-entry policy `E4-TR10` a-d | checked |
| AC-31 | E1 consumer policy | Dependency handling; guard completeness; `E4-TG4` | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | `evidence/other/upstream-merge-check.2026-10-11T23-30.md`: `Base: ebf4504ae...`, `E1Merged: yes`, `HelperFunctions: 3`, `Verdict: PROCEED`, `MergeOutcome: CLEAN`. |
| AC-2 | PASS | Entry line 59 guarded dot-source (mirror byte-identical); reviewer grep finds no `CLAUDE_HOOK_INPUT`, `Write-Error`, or `exit 1` in the three Claude hook files; `E4-ST1` in `validate-feature-review-coverage.Tests.ps1` passed (27/27 suite). |
| AC-3 | PASS | `E4-TR1` passed in reviewer run (Coverage suite 72/72); base failure recorded in `evidence/regression-testing/fail-first.2026-10-12T00-05.md`. |
| AC-4 | PASS | `E4-TR2`, `E4-TR3`, `E4-TR3b` passed in reviewer run; no exit-1 assertion remains (grep for `exit 1` in hook files is empty; Coverage suite passes). |
| AC-5 | PASS | Entry lines 66-70: only `-InputText`; first two statements are the S6 guard; `E4-ST2` passed; ThresholdsGuard suite 8/8 passed (TG1-TG3, `E4-TG4`, both copies). |
| AC-6 | PASS | Reviewer grep over the four suites: only `Should -Not -Contain 'RawPayload'` (the `E4-ST2` assertion), no `-RawPayload` argument and no `CLAUDE_HOOK_INPUT`; `evidence/qa-gates/claude-suites-transport-grep.2026-10-12T06-43.md`; suites pass. |
| AC-7 | PASS | Metrics lines 41-62 and entry lines 161-165; `E4-TR4a` and `E4-TR4` passed; base failure recorded. |
| AC-8 | PASS | Entry help lines 33-38 and Codex help lines 23-30; `E4-ST3` passed; `test_push_down_issue_824_follow_ups.py` passed. |
| AC-9 | PASS | Both files exist with the assigned functions; `E4-ST4` passed; Claude `core.json` lines 72-73; manifest completeness test passed (87-test pytest run). |
| AC-10 | PASS | Reviewer `wc -l`: 205, 180, 195, 85, 316, 85; `evidence/qa-gates/file-size.2026-10-12T08-37.md`. |
| AC-11 | PASS | `feature-review-coverage-thresholds.Tests.ps1` 21/21 passed (both copies); base failure of six positive rows recorded. |
| AC-12 | PASS | Rules lines 111-112, 180, 189 add the source label; `E4-TR6` and `E4-ST5` passed. |
| AC-13 | PASS | Issue824 suite 17/17 passed; `E4-ST6` passed. |
| AC-14 | PASS | Reviewer SHA256: all four thresholds copies share prefix `7c22eda2c4fe`; `E4-PX2` passed in Codex thresholds suite (21/21). |
| AC-15 | PASS | Codex line 49 guarded dot-source from `$PSScriptRoot`; `E4-ST7` passed (Codex Coverage suite 34/34). |
| AC-16 | PASS | `E4-TR7`, `E4-TR8`, `E4-TR9` passed; base failure of `E4-TR7` recorded. |
| AC-17 | PASS | Legacy contracts 43/43, Codex dependency failure 76/76, bundle probe 3/3 passed; `git diff --name-only ... -- .codex/config.toml <bundle copy>` printed nothing. |
| AC-18 | PASS | Codex `core.json` line 47; legacy suite line 30 lists the module; legacy suite 497 lines; tests pass. |
| AC-19 | PASS | `feature-review-coverage-floor-parity.Tests.ps1` 3/3 passed (`E4-PX1`). |
| AC-20 | PASS | Parametrized test present and passing in the 87-test pytest run. |
| AC-21 | PASS | `test_every_follow_up_copy_exists` and `test_review_workflow_step_eight_uses_governing_thresholds` pass in the same run. |
| AC-22 | PASS | Reviewer `git diff --name-only ... -- .github/instructions .claude/rules` printed nothing; `evidence/qa-gates/policy-files-unchanged.2026-10-12T07-24.md`. |
| AC-23 | PASS | Reviewer SHA256: 9 of 9 source and mirror pairs match, including `.github/skills/feature-review-workflow/SKILL.md`; parity tests pass; `evidence/other/mirror-log.2026-10-12T07-27.md`. |
| AC-24 | PASS | `evidence/regression-testing/fail-first.2026-10-12T00-05.md` (9 fail on base, 9 pass on head) and `evidence/qa-gates/fail-first-head-run.2026-10-12T08-39.md`. |
| AC-25 | PASS | Baseline `evidence/baseline/pester-coverage.2026-10-11T23-30.md`; final `evidence/qa-gates/final-pester-coverage.2026-10-12T08-31.md`; reviewer parse reproduces 98.82%, 100.00%, 98.88%, 100.00%, 100.00%, 100.00%. |
| AC-26 | PASS | `evidence/qa-gates/constraints.2026-10-12T08-41.md` and the three `constraints-*` artifacts; reviewer no-python suite 32/32 and temp-file grep with zero matches. |
| AC-27 | PASS | Reviewer scope diff over the listed paths printed nothing; `evidence/qa-gates/scope-boundary.2026-10-12T08-43.md`. |
| AC-28 | PASS | `evidence/qa-gates/final-qc-loop.2026-10-12T08-33.md` (clean pass 3: format 0, PSSA 0, full Pester 10217/0, pytest 87 and 26 passed); reviewer reruns agree. |
| AC-29 | UNVERIFIED | No pull request exists for this branch yet (`Auto-close issues: None (no PR exists yet for this branch)` in the PR context). The criterion is verified from `gh pr view <number> --json body` after PR creation; handoff in `evidence/other/ac-29-handoff.2026-10-12T08-44.md`. |
| AC-30 | PASS | Entry lines 189-192 and rules `Repairable` flags; `E4-TR10` a-d passed. Wording of the mixed case noted as a Minor code-review finding (not an AC requirement). |
| AC-31 | PASS | Entry lines 59, 69-70, 198-200; guard completeness 598/598; `E4-TG4` passed for both copies. |

## Summary

- 30 of 31 acceptance criteria are PASS, verified by reviewer reruns and committed evidence.
- AC-29 is UNVERIFIED because it depends on the pull request body, which does not exist yet; it is not a delivery gap in the branch.
- No AC is FAIL or PARTIAL.
- The policy audit records one Blocking finding outside the AC set: PA-1, the Python coverage artifact is absent although one Python test file changed (Remediability `autonomous`). The remediation is a verification step (generate and record Python coverage), not a code change.
- Code review: no Blocking finding; Minor 2, Nit 2, Info 4.

## Acceptance Criteria Check-off

- No checkbox was changed by this review. AC-1 to AC-28, AC-30, and AC-31 were already checked in `spec.md` and are confirmed PASS. AC-29 remains unchecked (UNVERIFIED pending the PR body).

### Acceptance Criteria Status
- Source: docs/features/active/subagentstop-envelope-feature-review-coverage-896/spec.md
- Total AC items: 31
- Checked off (delivered): 30
- Remaining (unchecked): 1
- Items remaining: AC-29 (the pull request body for this child contains `Refs #884` and `Refs #897`, no closing keyword adjacent to `#884` or `#897`, and a closing keyword for `#896` only; verified from `gh pr view <number> --json body` recorded in `evidence/issue-updates/`)
