# Feature Audit: Release Exemption for the Checkpoint-Free Pull Request Path (#1231)

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1231-pr-author-release-exemption/`
**Base Branch:** `main`
**Head Branch:** `feature/pr-author-release-exemption-1231`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `feature/pr-author-release-exemption-1231` (commit `a857d3f47`, PR #1232)
- **Merge base:** `3d905ca0bb80f12061f6ff7d3a0d79c0c53046bf`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated for head `a857d3f47`) and `git diff 3d905ca0b..a857d3f47`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1231-pr-author-release-exemption/evidence/**`
  - Additional evidence: reviewer re-parse of `artifacts/pester/powershell-coverage.xml`; reviewer run of `Invoke-HarnessGeneration.ps1 -Check` (exit 0, no drift); reviewer `cmp` of all bundle copies; `validate_evidence_locations.py --root .` (exit 0); `gh pr checks 1232` at review time
- **Feature folder used:** `.dev/active/1231-pr-author-release-exemption/`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are authoritative; the early-draft list in `issue.md` is not an AC source.
- **Scope note:** Full branch diff against `main`; no scope narrowing was supplied. The reviewer did not run the full test suite (owner constraint); test results come from the executor's final gates and the targeted inspection of the new suites.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1231-pr-author-release-exemption/spec.md` — primary (AC-01 to AC-23)
- `.dev/active/1231-pr-author-release-exemption/user-story.md` — secondary (US-AC-01 to US-AC-08)

### From spec.md

1. AC-01: checkpoint-free structural `gh pr create` on a matching branch with an all-listed diff passes the preflight; receipt checks still run and deny a missing or mismatched receipt.
2. AC-02: each `RELEASE_EXEMPTION_*` code keeps the deny, with Pester rows including `gh pr edit`, repeated `--head`, missing `--base`, `--head=`, `--head owner:branch`, and `--repo`.
3. AC-03: Leg 1 reason appended as `; release exemption not applied: <CODE>: <detail>` after the docs-only and cleanup reasons.
4. AC-04: Leg 1 runs only in the non-epic branch; docs-only diffs still exempted by #901 first.
5. AC-05: checkpoint-free `Agent(pr-author)` with one `branch:` and one `base:` label and an all-listed diff is allowed.
6. AC-06: each `RELEASE_DELEGATION_*` code keeps the deny with the suffix after `$docsSuffix`.
7. AC-07: checkpoint-free receipt Write beneath R on a matching branch is allowed.
8. AC-08: each `RELEASE_RECEIPT_*` code keeps the deny; other paths decline with an empty suffix.
9. AC-09: `Get-OrchestrationReleaseAllowanceResult` occurs once after the parallel records call; the final deny line ends with `+ $release.DenySuffix)` preceded by the Leg 3 term; the #1201 parity test passes unchanged.
10. AC-10: without the allowance file, deny text of all three gates is byte-identical and the leg makes no git call.
11. AC-11: an unexpected leg error declines with an empty suffix, the deny stands, and `Write-Debug` is written.
12. AC-12: every leg reuses the #1201 parser, matcher, and file seams; #1201 files unchanged; schema unchanged.
13. AC-13: no new or changed hook file invokes Python.
14. AC-14: no `.codex/` file or Codex bundle copy changed.
15. AC-15: hook files byte-identical to bundle copies; `core.json` lists new files; push-down contract and dependency-guard tests pass.
16. AC-16: no `.claude/release-commit-allowance.json` in the repository, bundles, or manifests.
17. AC-17: rule, brief, skill, and agent docs describe the legs and are produced from their sources by the generator with no drift.
18. AC-18: the orchestrator-state rule retains `destination-owned` and the #1201 Write/Edit/delegation statement and adds the policy-level-control disclosure.
19. AC-19: new hook files below 500 lines; no changed file above 800; helpers and #1201 context files not edited; sizes recorded.
20. AC-20: five new Pester suites with synthetic roots, mocked seams, no temporary files, clean leak scan.
21. AC-21: each new hook file at least 85% line coverage.
22. AC-22: existing affected suites pass and their dispositions are recorded in the plan.
23. AC-23: PowerShell toolchain loop completes in one clean pass with evidence under the feature folder.

### From user-story.md

24. US-AC-01: delegate, write the receipt, and run `gh pr create` without a checkpoint on an allowed branch; receipt checks still apply.
25. US-AC-02: any failed release precondition still denies with the specific sub-code after existing reasons.
26. US-AC-03: without the allowance file, deny texts are byte-identical.
27. US-AC-04: an unexpected leg error leaves the original deny in place.
28. US-AC-05: legs reuse the #1201 parser, matcher, and seams; schema unchanged.
29. US-AC-06: mirrored byte-identically, listed in `core.json`, documented through generator sources.
30. US-AC-07: Pester covers every allow and deny case; new files at least 85%; no Python in hooks.
31. US-AC-08: documentation states the exemption is a policy-level control, not a security control.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01 allow and receipt checks | PASS | `enforce-pr-author-skill.release.ps1:222-288`; allow and receipt-deny rows in `enforce-pr-author-skill.Release.Tests.ps1` | `git diff 3d905ca0b..a857d3f47`; inspection | Receipt checks run unchanged after the exemption in `Get-PrAuthorBypassReason`. |
| 2 | AC-02 Leg 1 codes and token forms | PASS | All 10 codes present in the suite; rows for `gh pr edit` (line 135), repeated `--head` (158), `--head=` (159), `-H` (161), missing `--base` (176), `--repo` (177); `owner:branch` rejected by `$script:ReleasePullRequestBranchRule` | `grep -o "RELEASE_EXEMPTION_[A-Z_]*" tests/scripts/claude-hooks/enforce-pr-author-skill.Release.Tests.ps1` | None. |
| 3 | AC-03 Leg 1 suffix order | PASS | `enforce-pr-author-skill.cleanup.ps1:248-267` builds `$result` with the cleanup suffix before appending the release suffix; order row in the suite | inspection of diff | None. |
| 4 | AC-04 non-epic only; docs-only first | PASS | Suite rows at lines 330-353 (`Get-PrAuthorReleaseExemption -Times 0` under epic scope; docs-only allow with no allowance read) | inspection | None. |
| 5 | AC-05 Leg 2 allow | PASS | `enforce-model-routing-receipt-release.ps1:59-103`; `enforce-model-routing-receipt.ps1:412-417` returns `$allow` | inspection | See code review Minor M1 (label not bound to worktree branch); consistent with spec. |
| 6 | AC-06 Leg 2 codes and suffix order | PASS | All 6 codes in the suite; order row asserting docs-estate suffix precedes release suffix (lines 220-232) | `grep -o "RELEASE_DELEGATION_[A-Z_]*" ...` | None. |
| 7 | AC-07 Leg 3 allow | PASS | `enforce-orchestration-preimplementation-gate-release-receipt.ps1:176-216`; decision-level allow row | inspection | None. |
| 8 | AC-08 Leg 3 codes and declines | PASS | Rows for each of the 3 codes; decline rows for blank, non-numeric `<N>`, body file, path outside `artifacts/`, nested relative and absolute paths | inspection | None. |
| 9 | AC-09 gate ordering | PASS | `enforce-orchestration-preimplementation-gate.ps1:442-444`: receipt call after parallel records and before the #1201 call; deny line ends `+ $receipt.DenySuffix + $release.DenySuffix)`; `hook-release-allowance-context.Parity.Tests.ps1` not in the diff | `git diff` of the gate | Parity suite passed in the executor gate. |
| 10 | AC-10 byte-identical deny, no git call | PASS | Exact-text rows per gate (`enforce-pr-author-skill.Release.Tests.ps1:356`, `enforce-model-routing-receipt.Release.Tests.ps1:234`, receipt suite :253) with zero-call assertions (pr-author: `Get-PrAuthorReleasePublishedHead -Times 0` and only the two pre-existing docs-only git calls; model-routing: `Invoke-DocsOnlyGitExe -Times 0`; receipt: unit row :173 asserting `Get-EpicScopeWorktreeHeadBranch -Times 0`) | inspection | For Leg 3 the zero-seam assertion is in the unit row and the exact-text assertion in the decision row. |
| 11 | AC-11 caught errors | PASS | One caught-error row per leg asserting the `Write-Debug` code, empty suffix or null reason, and no allow | inspection | None. |
| 12 | AC-12 reuse of #1201 | PASS | Legs call `Get-ReleasePullRequestConfigState`, which calls `ConvertFrom-ReleaseAllowanceConfig`; branch match via `Test-ReleaseAllowanceBranchMatch`; `hook-release-allowance-context.ps1` and `enforce-orchestration-preimplementation-gate-release.ps1` not in the diff | `git diff --name-only 3d905ca0b..HEAD` | None. |
| 13 | AC-13 no Python | PASS | No `python`/`poetry` text in the new hook files; `enforcement-hooks-no-python-invocation.Tests.ps1` passed in the executor gate | `grep -i "python\|poetry"` over the four new hook files | None. |
| 14 | AC-14 no Codex change | PASS | No `.codex/` path in the diff; the two `.agents/skills/` copies are spec-named sources | `git diff --name-only` filter | None. |
| 15 | AC-15 mirrors and manifest | PASS | `cmp` of all 12 `.claude/` files with bundle copies: identical; `core.json` diff adds the four new hook files; push-down contract tests passed in the executor pytest gate | `cmp -s` loop; `git diff` of `core.json` | None. |
| 16 | AC-16 no allowance file shipped | PASS | `git ls-files` search for `release-commit-allowance.json`: no match | `git ls-files \| grep release-commit-allowance.json` | None. |
| 17 | AC-17 generated docs | PASS | Changes in `scripts/harness-generation/sources/rules/orchestrator-state.md`, `sources/agents/pr-author.md`, `.agents/skills/execution-environment/SKILL.md`, `.agents/skills/pr-author/SKILL.md`; reviewer `-Check`: `harness-generation: no drift` | `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` | The spec names `pr-author.json`; the content lives in `pr-author.md` (plan Decisions). |
| 18 | AC-18 rule content | PASS | `sources/rules/orchestrator-state.md` adds the release pull-request paragraph and the policy-level-control disclosure; the existing `destination-owned` and Write/Edit/delegation text is retained (additive diff) | `git diff` of the rule source | None. |
| 19 | AC-19 sizes | PASS | New files 108-177 lines; largest changed file 501; helpers and #1201 context not edited; recorded in `evidence/qa-gates/contract-scope.2026-11-24T01-17.md` | `@(Get-Content -LiteralPath <path>).Count` | None. |
| 20 | AC-20 new suites | PASS | Five suites present; synthetic `/synthetic-worktrees/` roots; no temp-file API; leak scan 0 failures | `grep` for temp-file APIs; `evidence/qa-gates/powershell-static.2026-11-24T01-18.md` | None. |
| 21 | AC-21 new-file coverage | PASS | 27/27, 53/53, 28/28, 24/24 lines | reviewer parse of `artifacts/pester/powershell-coverage.xml` | None. |
| 22 | AC-22 existing suites | PASS | Dispositions in plan Decisions; full Pester gate 0 failed | `evidence/qa-gates/pester.2026-11-24T01-30.md` | None. |
| 23 | AC-23 toolchain loop | PASS | Final pass 3 clean for format, analyzer, leak scan, and Pester | `evidence/qa-gates/powershell-static.2026-11-24T01-18.md`, `pester.2026-11-24T01-30.md` | Earlier passes failed and were fixed on the branch. |
| 24 | US-AC-01 | PASS | AC-01, AC-05, AC-07 | see rows 1, 5, 7 | None. |
| 25 | US-AC-02 | PASS | AC-02, AC-03, AC-06, AC-08 | see rows 2, 3, 6, 8 | None. |
| 26 | US-AC-03 | PASS | AC-10 | see row 10 | None. |
| 27 | US-AC-04 | PASS | AC-11 | see row 11 | None. |
| 28 | US-AC-05 | PASS | AC-12 | see row 12 | None. |
| 29 | US-AC-06 | PASS | AC-15, AC-17, AC-18 | see rows 15, 17, 18 | None. |
| 30 | US-AC-07 | PASS | AC-13, AC-20, AC-21 | see rows 13, 20, 21 | None. |
| 31 | US-AC-08 | PASS | Disclosure paragraph in `orchestrator-state.md` source and generated rule | see row 18 | None. |

Decision D1 (merge gate not changed): verified. `enforce-epic-merge-gate.ps1` is not in the diff, and the spec Non-Goals, user-story Non-Goals, plan Decisions, and the orchestrator-state rule each state that merging a release pull request is out of scope.

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 31 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the poshqc (including the Linux hook-suite job), quality-checks7, and shell-coverage CI jobs on PR #1232 complete green at head `a857d3f47`.
2. Optionally consider binding the Leg 2 `branch:` label to the worktree branch (code review Minor M1).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `.dev/active/1231-pr-author-release-exemption/spec.md`, `.dev/active/1231-pr-author-release-exemption/user-story.md`
- Total AC items: 31
- Checked off (delivered): 31
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1231-pr-author-release-exemption/spec.md` | 23 | 23 | 0 | Checkbox-backed; already checked by the executor |
| `.dev/active/1231-pr-author-release-exemption/user-story.md` | 8 | 8 | 0 | Checkbox-backed; already checked by the executor |

No source-file checkbox change was made by this review: every criterion evaluated as PASS was already checked in its source file at head `a857d3f47`. The spec's Definition of Done and Seeded Test Conditions checklists are not acceptance criteria and were left unchanged.
