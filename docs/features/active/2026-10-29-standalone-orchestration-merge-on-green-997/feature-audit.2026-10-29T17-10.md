# Feature Audit: Standalone orchestration merge on green (#997)

---

**Audit Date:** 2026-10-29
**Feature Folder:** `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997`
**Base Branch:** `main`
**Head Branch:** `bug/standalone-orchestration-merge-on-green-997`
**Work Mode:** `full-bug`
**Audit Type:** Initial audit of the full branch diff

---

## Scope and Baseline

- **Base branch:** `main` (merge base `fd4fe5b2985f3caaaffb60d9dc393584e7750c3a`; `origin/main` resolves to the same commit)
- **Head branch/commit:** `bug/standalone-orchestration-merge-on-green-997` (commit `98c851059de5aaa048b4a3578f678f1bc1ac05c5`)
- **Merge base:** `fd4fe5b2985f3caaaffb60d9dc393584e7750c3a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-29 17:01:02 UTC for head `98c851059de5aaa048b4a3578f678f1bc1ac05c5`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997/evidence/**`
  - Additional evidence: reviewer Pester run of eight merge-gate suites (229 passed); reviewer full Python suite with branch coverage (7429 passed); reviewer parses of `artifacts/pester/powershell-coverage.xml` and `artifacts/python/coverage.json`; PSScriptAnalyzer over nine changed PowerShell files; Black, Ruff, Pyright; Codex generator `--check`; `check_quality_tiers`; `cmp` mirror parity; evidence-location validator; logical line counts; source reads of the consumed helpers
- **Feature folder used:** `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997`
- **Requirements source:** `spec.md` `## Acceptance Criteria` (authoritative for `full-bug`)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; `spec.md` is the only AC source and no `user-story.md` applies.
- **Scope note:** PR context was current for the head SHA and was not regenerated. The full branch diff (52 files) was reviewed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997/spec.md`: only authoritative source (full-bug); 32 checkbox items, AC-01 to AC-32

### From spec.md

1. AC-01: Standalone green checkpoint, NoTarget run targets, single structural merge, and matching live head -> allow.
2. AC-02: Allow also holds with an equal `--match-head-commit` and an equal `pr_gate.head_sha`.
3. AC-03: Stale live head declines with `GREEN_CI_HEAD_STALE`.
4. AC-04: Non-`success` or non-object `ci_gate` declines.
5. AC-05: `step9_status` not exactly `passed` declines.
6. AC-06: `pr_gate.pr_number` absent, null, non-integer, or different declines; an authorization record does not bind.
7. AC-07: Missing or unreadable checkpoint, or ambiguous item target, declines.
8. AC-08: Bare `gh pr merge` declines with the final deny text.
9. AC-09: Unresolved live head declines with `GREEN_CI_LIVE_HEAD_UNRESOLVED`; wrapper returns `$null` for five failure outcomes.
10. AC-10: Differing `--match-head-commit` declines with `GREEN_CI_MATCH_HEAD_MISMATCH`.
11. AC-11: `epic_mode` true, or non-boolean, declines in 3b.
12. AC-12: Malformed `ci_gate.head_sha` or differing `pr_gate.head_sha` declines.
13. AC-13: Parallel child declines on layers 1a, 1b, and 2, each paired with a NoTarget allow.
14. AC-14: Non-structural commands decline (chain, wrapper, `-R`, `--repo`, URL, environment prefix, `--auto`, `gh api`).
15. AC-15: Sibling load failure yields the `Add-HookDependencyFailure` deny.
16. AC-16: No live-head call when stages A to C decline.
17. AC-17: Existing branches behave as before; `Test-ChildCheckpointAllowsEpicMerge` unedited.
18. AC-18: Final deny text updated and pinned in three suites; prior text absent.
19. AC-19: Python documentation and push-down contract tests pass.
20. AC-20: `orchestrate/SKILL.md` S9 standalone merge addition and `pr_merge` schema entry.
21. AC-21: PR Creation Gate condition 7 standalone alternative; condition 2 unedited.
22. AC-22: `parallel-orchestrate/SKILL.md`, `orchestrator-state.md`, `parallel-orchestration.md` prose; no claim of a mechanically closed exclusion.
23. AC-23: Hook headers list 3b and the residual window.
24. AC-24: Byte-identical mirrors and `core.json` entry; listed files not edited.
25. AC-25: Gate at most 500 physical lines.
26. AC-26: Sibling and new suites at most 500 physical lines.
27. AC-27: Authorization helper unchanged at 443 lines; `enforce-epic-merge-gate.Tests.ps1` unchanged; `session-root-reads-850.Constraints.Tests.ps1` passes.
28. AC-28: PowerShell toolchain loop passes with counts from JUnit; evidence under `<FEATURE>/evidence/`.
29. AC-29: Line coverage at least 85% for the sibling and the gate.
30. AC-30: Seeded shuffles show no order dependence; no temp files or `gh` starts.
31. AC-31: (pending-CI) CI on the PR head is green with `ci_gate.head_sha` equal to the final head.
32. AC-32: (pending live verification, deferred) post-merge live check of standalone self-merge and parallel non-merge.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01: allow case | PASS | `GreenCiDecision.Tests.ps1` "allows a standalone merge with a green S9 gate and a matching live head" (asserts one live-head call) | reviewer `Invoke-Pester` over eight suites: 229 passed | — |
| 2 | AC-02: allow with pin and `pr_gate.head_sha` | PASS | Two allow rows in the same suite | same | — |
| 3 | AC-03: stale head | PASS | `GREEN_CI_HEAD_STALE` row; sibling line 317 reports a stale head before a pin mismatch | same; source read | — |
| 4 | AC-04: `ci_gate` cases | PASS | `GreenCi.Tests.ps1` "declines ci_gate case" rows; `-ceq 'success'` and the PSCustomObject type check at sibling lines 119-121 | same | — |
| 5 | AC-05: `step9_status` cases | PASS | "declines step9_status case" rows; `-ceq 'passed'` at line 117 | same | — |
| 6 | AC-06: PR binding | PASS | "declines pr_gate.pr_number case" rows; binding reads `pr_gate` only (lines 124-128) | same | — |
| 7 | AC-07: checkpoint and item target | PASS | NoTarget, Ambiguous, absent, and unparseable rows, each with zero live-head calls | same | — |
| 8 | AC-08: bare command | PASS | Bare-command row asserts the exact final deny text; `$itemTarget` is `$null` for a bare command, so stage A declines | same; source read of gate lines 356-361 | — |
| 9 | AC-09: unresolved live head | PASS | Decision row for `GREEN_CI_LIVE_HEAD_UNRESOLVED`; wrapper rows for exit 1, 124, -1, unparseable JSON, malformed oid | same | — |
| 10 | AC-10: pin mismatch | PASS | `GREEN_CI_MATCH_HEAD_MISMATCH` row | same | A valueless flag also declines this way (code review, Info). |
| 11 | AC-11: `epic_mode` | PASS | Rows for `true`, string `"false"`, number 1; `Test-EpicMergeGateGreenCiNotParallel` accepts only absent, null, or boolean false | same | — |
| 12 | AC-12: `head_sha` | PASS | "ci_gate.head_sha case" rows (absent, blank, uppercase, short, 64-character allowed) and the differing `pr_gate.head_sha` row | same | — |
| 13 | AC-13: parallel exclusion layers | PASS | Layer 1a (parallel OtherWorktree, epic Ambiguous), 1b (recorded, throw), 2 (`parallel_mode`, `parallel_slug`) rows, each paired with the NoTarget allow row | same | Best-effort by design; see code review Low row on unreadable parallel checkpoints. |
| 14 | AC-14: command shape | PASS | Eight command-shape rows | same | `--admin` is accepted (code review, Low); not within AC-14's list. |
| 15 | AC-15: dependency failure | PASS | `hook-dependency-failure.SpecialCases.Tests.ps1` row C9 | same | — |
| 16 | AC-16: stage ordering | PASS | Three stage-ordering rows assert `Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly` | same | — |
| 17 | AC-17: regression | PASS | `GreenCiRegression.Tests.ps1` five rows; unchanged `enforce-epic-merge-gate.Tests.ps1`, Authorization, MergeQueue, DocsOnly pass; `Test-ChildCheckpointAllowsEpicMerge` absent from the diff | reviewer Pester run; `git diff origin/main...HEAD -- .claude/hooks/enforce-epic-merge-gate.ps1` | — |
| 18 | AC-18: deny-text pins | PASS | Diff of the three suites changes only the pinned constant; `qa-gates/deny-text-pins.2026-10-29T16-56.md` records no match for the prior text | reviewer diff read | — |
| 19 | AC-19: Python contract tests | PASS | All named modules pass within the reviewer full suite (7429 passed, 0 failed); `qa-gates/python-dev-tools.2026-10-29T16-38.md` | `poetry run pytest --cov --cov-branch -q -p no:cacheprovider --cov-report=json:artifacts/python/coverage.json` | — |
| 20 | AC-20: orchestrate S9 prose | PASS | Step 7 states the four applicability conditions, the `--match-head-commit` command, the confirmation procedure, `pr_merge`, the `preparation` exclusion, and that a parallel item never merges itself; step 6 text unchanged; `pr_merge` listed in the checkpoint schema | reviewer read of `.claude/skills/orchestrate/SKILL.md` lines 305-316 and diff | — |
| 21 | AC-21: PR Creation Gate | PASS | Condition 7 keeps the `epic_merge.merge_commit_sha` sentence and appends the standalone alternative; condition 2 absent from the diff | reviewer diff read | — |
| 22 | AC-22: parallel and rule prose | PASS | Retained "not modified by this feature" sentence plus the #997 amendment sentence; kickoff instruction for `parallel_mode`/`parallel_slug`; merge-gate paragraph order; `orchestrator-state.md` subsection with the unvalidated-keys sentence and "Honest disclosure" paragraph; Enforcement bullets updated | reviewer diff read; `grep -rniE "mechanically (closed|excluded|enforced)"` over the six files returns no match | One sentence at `parallel-orchestrate/SKILL.md:254` is worded more absolutely (code review, Info). |
| 23 | AC-23: hook headers | PASS | Gate header lists 3b, rewrites the standalone sentence, and states the residual window; sibling header states it | reviewer read | — |
| 24 | AC-24: mirrors and manifest | PASS | `cmp`: 6 of 6 identical; `core.json` entry beside the merge-gate entries; `git diff --name-only` empty for `epic-orchestrate/SKILL.md`, `.claude/settings.json`, `.codex`, `enforce-epic-merge-gate-authorization.ps1`, `hook-docs-only-diff.ps1` | `cmp <file> extensions/drm-copilot/resources/claude-customizations/<file>` | — |
| 25 | AC-25: gate size | PASS | 476 lines | reviewer logical line count | — |
| 26 | AC-26: sibling and suite sizes | PASS | Sibling 321; suites 267, 288, 109 | same | — |
| 27 | AC-27: unchanged files | PASS | Authorization helper and `enforce-epic-merge-gate.Tests.ps1` absent from the diff; `session-root-reads-850.Constraints.Tests.ps1` passes in the full Pester run (0 failures) | `git diff --name-only`; `qa-gates/pester-full.2026-10-29T16-54.md` | — |
| 28 | AC-28: toolchain loop | PASS | `qa-gates/ps-format`, `pssa`, `boundary-contract-stages`, `pester-full` (JUnit 12198 tests, 0 failures); reviewer PSScriptAnalyzer 0 findings | read of evidence; reviewer runs | — |
| 29 | AC-29: coverage | PASS | Reviewer parse: sibling 56/56 (100.00%), gate 132/132 (100.00%) | parse of `artifacts/pester/powershell-coverage.xml` | Artifact from a full single-process run. |
| 30 | AC-30: isolation | PASS | `regression-testing/isolation.2026-10-29T16-55.md` (three seeds, 172 passed each); `qa-gates/test-hygiene.2026-10-29T16-40.md` | read of evidence | — |
| 31 | AC-31: CI green on the PR head | UNVERIFIED | No pull request exists for the branch yet | — | Pending CI; CI-dependent criterion owned by the item's own orchestrator run at S9. Not a review defect. |
| 32 | AC-32: post-merge live verification | UNVERIFIED | Cannot run before merge; hooks in an isolated subagent run `main`'s copies | — | Deferred by design in the spec; not claimed as passed. Not a review defect. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 30 criteria (AC-01 to AC-30)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (AC-31 pending CI; AC-32 deferred post-merge live check)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. AC-31 is a CI-dependent criterion that cannot be verified before the pull request exists, and AC-32 is a post-merge verification that the spec defers by design.

**Recommended follow-up verification steps:**

1. At S9, confirm `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head, then check off AC-31 from the item's own run.
2. After merge, perform the AC-32 live check from a non-isolated run on the merged tree: a standalone run merges its own green PR, and a parallel child is declined.
3. Consider a follow-up hardening item for the two Low code-review observations (`--admin` acceptance; unreadable parallel checkpoint treated as no record).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997/spec.md`
- Total AC items: 32
- Checked off (delivered): 30
- Remaining (unchecked): 2
- Items remaining: AC-31 "(pending-CI): CI on the PR head is green, including the Linux hook-suite job over `tests/scripts/claude-hooks` and the Python documentation and push-down contract jobs, with `ci_gate.head_sha` equal to the final PR head."; AC-32 "(pending live verification, deferred): After merge, a non-isolated run from the merged tree shows a standalone orchestration merging its own green PR and a parallel child not doing so."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 32 | 30 | 2 | AC-01 to AC-30 were already checked by the executor and each evaluated PASS in this audit. AC-31 is pending CI and AC-32 is deferred; both remain unchecked. |

No source-file checkbox change was made in this review, because every PASS criterion was already checked and the two unchecked criteria are not verifiable before the pull request exists or the merge occurs.
