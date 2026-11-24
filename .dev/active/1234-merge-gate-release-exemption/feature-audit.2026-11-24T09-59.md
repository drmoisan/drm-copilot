# Feature Audit: Release Merge Leg of the Epic Merge Gates (#1234)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1234-merge-gate-release-exemption/`
**Base Branch:** `main`
**Head Branch:** `feature/merge-gate-release-exemption-1234`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `feature/merge-gate-release-exemption-1234` (commit `134a59879`, PR #1236)
- **Merge base:** `a4ebf96688106d9bcd0baf51d237a6b77c055560`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 09:52:37 UTC for head `134a59879`) and `git diff a4ebf9668..134a59879`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1234-merge-gate-release-exemption/evidence/**`, with `evidence/qa-gates/self-review.2026-11-24T09-49.md` as the authoritative self-review
  - Additional evidence: reviewer re-parse of `artifacts/pester/powershell-coverage.xml`; reviewer run of `Invoke-HarnessGeneration.ps1 -Check` (exit 0, no drift); reviewer SHA-256 comparison of all tree and bundle copies; `validate_evidence_locations.py --root .` (exit 0); `gh pr view 1236 --json statusCheckRollup` at review time
- **Feature folder used:** `.dev/active/1234-merge-gate-release-exemption/`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are authoritative; the early-draft list in `issue.md` is not an AC source.
- **Scope note:** Full branch diff against `main`; no scope narrowing was supplied. The reviewer did not run the full test suite (owner directive: full suite only at the baseline and final QA gates); test results come from the executor's final gates and targeted inspection of the new suites.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1234-merge-gate-release-exemption/spec.md` — primary (AC-01 to AC-40)
- `.dev/active/1234-merge-gate-release-exemption/user-story.md` — secondary (US-AC-01 to US-AC-13)

### From spec.md

1. AC-01: Claude gate admits the checkpoint-free release merge under all conditions; decision-level row.
2. AC-02: Codex gate admits the same merge; decision-level row.
3. AC-03: step 1 declines with no config read and no `gh` call.
4. AC-04: step 2 absent file declines with no `gh` call; three `RELEASE_MERGE_CONFIG_INVALID` cases.
5. AC-05: step 3 `RELEASE_MERGE_CHECKPOINT_PRESENT`, Claude and Codex decision rows.
6. AC-06: step 4 `RELEASE_MERGE_COMMAND_NOT_MODELLED` for seven forms.
7. AC-07: step 5 `RELEASE_MERGE_MATCH_HEAD_MISSING` for four cases.
8. AC-08: step 6 `RELEASE_MERGE_PR_UNRESOLVED` cases and exact `gh pr view` arguments.
9. AC-09: step 7 `RELEASE_MERGE_PR_NOT_OPEN`.
10. AC-10: step 8 `RELEASE_MERGE_CROSS_REPOSITORY`.
11. AC-11: step 9 `RELEASE_MERGE_HEAD_MISMATCH`.
12. AC-12: step 10 `RELEASE_MERGE_FILES_TRUNCATED`.
13. AC-13: step 11 `RELEASE_MERGE_CHANGE_NOT_MODELLED` and modelled types pass.
14. AC-14: step 12 branch, empty-diff, path codes, and no combination.
15. AC-15: steps 13-14 `CI_UNREADABLE`, `CI_MISSING`, `-HeadSha` binding.
16. AC-16: step 15 `CI_EVENT_NOT_ALLOWED`.
17. AC-17: step 16 `CI_NOT_GREEN`.
18. AC-18: single suffix for the first failing step only.
19. AC-19: process-call bands.
20. AC-20: caught error with `Write-Debug`.
21. AC-21: Claude deny text byte-identical and process counts unchanged without the file.
22. AC-22: Codex deny text byte-identical and process counts unchanged without the file.
23. AC-23: release suffix is the last term in each gate.
24. AC-24: leg runs only after the docs-only branch declines; earlier branches unchanged.
25. AC-25: review guard unchanged and passes without a process call.
26. AC-26: allowance parsing and matching only through the #1201/#1231 helpers.
27. AC-27: shape, flags, `gh`, and CI runs only through existing helpers.
28. AC-28: five helper files unchanged; pure file `.NOTES` only; parity suites pass.
29. AC-29: Codex copies byte-identical; identity test lists both.
30. AC-30: bundle copies byte-identical.
31. AC-31: pack manifests list new files; push-down contract tests pass.
32. AC-32: no hook registration; parity matrix unchanged.
33. AC-33: no allowance file shipped.
34. AC-34: generated documentation through sources; no drift.
35. AC-35: rule disclosure and retained tokens; pr-author heading retained.
36. AC-36: size limits measured and recorded.
37. AC-37: Pester suites cover every row with injected seams and no temporary files.
38. AC-38: leg at least 85% line coverage.
39. AC-39: no Python or Poetry in hooks.
40. AC-40: toolchain loop clean; evidence append-only; full suite only at baseline and final QA.

### From user-story.md

41. US-AC-01: Claude gate merges the release pull request.
42. US-AC-02: Codex gate merges the same pull request.
43. US-AC-03: pre-`gh` denials with their codes.
44. US-AC-04: pull-request-level denials with their codes.
45. US-AC-05: CI-level denials with their codes.
46. US-AC-06: first failing check only, as the last deny term.
47. US-AC-07: unexpected error leaves the deny in place.
48. US-AC-08: no change without the allowance file.
49. US-AC-09: existing branches and the review guard unchanged.
50. US-AC-10: reuse of existing parsers and helpers; schema unchanged.
51. US-AC-11: byte-identical copies, manifests, and generated docs.
52. US-AC-12: policy-level control disclosure.
53. US-AC-13: Pester coverage, 85% leg coverage, no Python.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01 Claude allow | PASS | Gate call line after the docs-only block returns `Get-EpicMergeGateAllowDecision`; row `allows a checkpoint-free release merge without a review-guard process call (AC-01, AC-25)` in `enforce-epic-merge-gate.Release.Tests.ps1:148` | `git diff a4ebf9668..HEAD -- .claude/hooks/enforce-epic-merge-gate.ps1` | None. |
| 2 | AC-02 Codex allow | PASS | Codex call line returns `$null` (allow); row at `codex-hooks/enforce-epic-merge-gate-release.Tests.ps1:120` | `git diff` of the Codex gate | None. |
| 3 | AC-03 step 1 | PASS | Leg line 242; four data rows (`null`, 0, -1, blank root) asserting no reader and no `gh` call | inspection | None. |
| 4 | AC-04 step 2 | PASS | Leg lines 244-246; absent-file row with zero `gh` calls; three `CONFIG_INVALID` data rows | inspection | None. |
| 5 | AC-05 step 3 | PASS | Leg lines 247-249; Claude row `:164` and Codex row `:136` | inspection | None. |
| 6 | AC-06 step 4 | PASS | Leg lines 250-259; six shape data rows plus the `--admin` row | inspection | None. |
| 7 | AC-07 step 5 | PASS | Leg lines 260-266; four data rows (absent, no value, uppercase, 39 characters) | inspection | None. |
| 8 | AC-08 step 6 | PASS | `Get-EpicMergeGateReleasePullRequestViolation`; nine data rows; argument-list row asserts `pr view <N> --json headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files` | inspection | None. |
| 9 | AC-09 step 7 | PASS | Leg line 272; `-ForEach` row over `MERGED`, `CLOSED`, `open` | inspection | None. |
| 10 | AC-10 step 8 | PASS | Leg line 273; cross-repository row with a matching branch | inspection | None. |
| 11 | AC-11 step 9 | PASS | Leg lines 274-277 (ordinal compare); mismatch row | inspection | None. |
| 12 | AC-12 step 10 | PASS | Leg lines 278-282; rows for 101/101 and 2/1, plus a 100/100 pass row | inspection | None. |
| 13 | AC-13 step 11 | PASS | `Get-EpicMergeGateReleaseChangedPath`; `RENAMED`, `COPIED`, blank-path rows; pass row for the four modelled types | inspection | None. |
| 14 | AC-14 step 12 | PASS | Leg lines 286-294; branch, empty-diff, path, and no-combination rows | inspection | None. |
| 15 | AC-15 steps 13-14 | PASS | `Get-EpicMergeGateReleaseCiFailure` lines 191-194; `CI_UNREADABLE`, `CI_MISSING`, and `--commit` binding rows | inspection | None. |
| 16 | AC-16 step 15 | PASS | Lines 195-198; `push` and `workflow_dispatch` rows over an older green `pull_request` run | inspection | None. |
| 17 | AC-17 step 16 | PASS | Lines 199-203; in-progress and failure rows | inspection | None. |
| 18 | AC-18 first failure only | PASS | Linear early returns; row `reports only the earlier code when two steps fail` | inspection | None. |
| 19 | AC-19 call bands | PASS | Three `Should -Invoke ... -Exactly` row sets in the Ci suite (none; one `pr view`; one `pr view` and one `run list`) | inspection | Header comment says "13 to 16" for the run list; code review Nit. |
| 20 | AC-20 caught error | PASS | Lines 299-302; caught-error row asserting the debug record and empty suffix | inspection | None. |
| 21 | AC-21 Claude unchanged without file | PASS | Rows `:89` (exact deny string) and `:101` (exact `gh`/`git` counts); existing merge-gate suites passed in the final gate | `evidence/qa-gates/pester.2026-11-24T09-35.md` | None. |
| 22 | AC-22 Codex unchanged without file | PASS | Rows `:72` and `:85` in the Codex suite | same | None. |
| 23 | AC-23 suffix order | PASS | Claude deny line ends `+ $docsOnlySuffix + $greenCi.Suffix + $release.Suffix)`; Codex ends `+ $docsOnlySuffix + $release.Suffix`; order rows in both suites | `git diff` of both gates | None. |
| 24 | AC-24 placement | PASS | Call lines placed after the docs-only block; docs-only admit and epic-child rows in both suites; bare-command deny not in the diff | `git diff` of both gates | None. |
| 25 | AC-25 review guard | PASS | `enforce-epic-merge-gate-review.ps1` and `-regeneration.ps1` not in the diff; allow rows assert zero review-guard process calls | `git diff --name-only` (count 0) | None. |
| 26 | AC-26 allowance reuse | PASS | Leg calls `Get-ReleasePullRequestConfigState` and `Get-ReleasePullRequestPathDecision` only; no JSON parser or matcher defined | inspection of the leg file | None. |
| 27 | AC-27 helper reuse | PASS | Leg calls `Get-DocsOnlyMergeShapeViolation`, `Test-CommandLineFlag`, `Get-CommandLineFlagValue`, `Invoke-DocsOnlyGhExe`, `Get-EpicMergeGateChildCiRunList`, `Select-EpicMergeGateChildCiRun`, `Test-EpicMergeGateChildCiObjectId` | inspection | None. |
| 28 | AC-28 helpers unchanged | PASS | None of the five helper files is in the diff; the Claude pure-file diff is in `.NOTES` only (100% coverage unchanged, 0 executable lines added) | `git diff --name-only a4ebf9668..HEAD` filter (count 0) | None. |
| 29 | AC-29 Codex copies | PASS | Leg and pure-file SHA-256 identical across `.claude/hooks/` and `.codex/hooks/`; both names added to `$script:IdenticalHelpers` | `sha256sum` | None. |
| 30 | AC-30 bundle copies | PASS | All six hook files identical to their bundle copies | `sha256sum` | None. |
| 31 | AC-31 manifests | PASS | Claude `core.json` adds one entry, Codex `core.json` adds two; contract and completeness tests passed in the executor pytest gate | `git diff` of both manifests; `evidence/qa-gates/pytest.2026-11-24T09-45.md` | None. |
| 32 | AC-32 no registration | PASS | `config/harness-parity-matrix.json`, `.claude/settings.json`, `.codex/config.toml` not in the diff; reviewer `-Check` no drift | `git diff --name-only` filter | None. |
| 33 | AC-33 no allowance file | PASS | `git ls-files` match count 0 | `git ls-files \| grep -c release-commit-allowance.json` | None. |
| 34 | AC-34 generated docs | PASS | Changes in `scripts/harness-generation/sources/rules/orchestrator-state.md` and `.agents/skills/{execution-environment,pr-author}/SKILL.md`; generated targets and bundles identical; reviewer `-Check`: no drift | `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` | None. |
| 35 | AC-35 disclosure and tokens | PASS | `.claude/rules/orchestrator-state.md` contains `RELEASE_EXEMPTION_`, `RELEASE_DELEGATION_`, `RELEASE_RECEIPT_`, `policy-level control`, `destination-owned`, `RELEASE_MERGE_`; pr-author heading present | `grep -c` per token | None. |
| 36 | AC-36 sizes | PASS | Claude gate 500, Codex gate 456, leg 303, pure file 119; recorded before and after in `evidence/baseline/powershell-static.2026-11-24T04-46.md` and `evidence/qa-gates/contract-scope.2026-11-24T09-47.md` | logical line count per file | None. |
| 37 | AC-37 suites | PASS | Four named suites plus the Ci suite present; synthetic roots; no temp-file API; leak scan 0 failures | `grep` for temp-file APIs; `evidence/qa-gates/powershell-static.2026-11-24T09-20.md` | None. |
| 38 | AC-38 leg coverage | PASS | 95/95 lines per copy | reviewer parse of `artifacts/pester/powershell-coverage.xml` | None. |
| 39 | AC-39 no Python | PASS | No `python`/`poetry` text in the leg or pure-file copies; parity rows assert it | `grep -i` over the new hook files | None. |
| 40 | AC-40 toolchain and evidence | PASS | Restarted final loop clean; all evidence newly added under `evidence/<kind>/`; full suite run only at P0 and P4 | `evidence/qa-gates/*`; `validate_evidence_locations.py --root .` exit 0 | Timestamp irregularities disclosed append-only. |
| 41 | US-AC-01 | PASS | AC-01 | see row 1 | None. |
| 42 | US-AC-02 | PASS | AC-02, AC-29 | see rows 2, 29 | None. |
| 43 | US-AC-03 | PASS | AC-04 to AC-07, AC-19 | see rows 4-7, 19 | None. |
| 44 | US-AC-04 | PASS | AC-08 to AC-14 | see rows 8-14 | None. |
| 45 | US-AC-05 | PASS | AC-15 to AC-17 | see rows 15-17 | None. |
| 46 | US-AC-06 | PASS | AC-18, AC-23 | see rows 18, 23 | None. |
| 47 | US-AC-07 | PASS | AC-20 | see row 20 | None. |
| 48 | US-AC-08 | PASS | AC-21, AC-22 | see rows 21, 22 | None. |
| 49 | US-AC-09 | PASS | AC-24, AC-25 | see rows 24, 25 | None. |
| 50 | US-AC-10 | PASS | AC-26 to AC-28 | see rows 26-28 | None. |
| 51 | US-AC-11 | PASS | AC-29 to AC-31, AC-34 | see rows 29-31, 34 | None. |
| 52 | US-AC-12 | PASS | AC-35; leg header lines 52-54 | see row 35 | None. |
| 53 | US-AC-13 | PASS | AC-37 to AC-39 | see rows 37-39 | None. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 53 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the poshqc (including the Linux hook-suite job), quality-checks7, and shell-coverage CI jobs on PR #1236 complete green at head `134a59879`.
2. Optionally correct the leg header's run-list step range (code review Nit).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `.dev/active/1234-merge-gate-release-exemption/spec.md`, `.dev/active/1234-merge-gate-release-exemption/user-story.md`
- Total AC items: 53
- Checked off (delivered): 53
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1234-merge-gate-release-exemption/spec.md` | 40 | 40 | 0 | Checkbox-backed; already checked by the executor |
| `.dev/active/1234-merge-gate-release-exemption/user-story.md` | 13 | 13 | 0 | Checkbox-backed; already checked by the executor |

No source-file checkbox change was made by this review: every criterion evaluated as PASS was already checked in its source file at head `134a59879`. The spec's Definition of Done and Seeded Test Conditions checklists are not acceptance criteria and were left unchanged.
