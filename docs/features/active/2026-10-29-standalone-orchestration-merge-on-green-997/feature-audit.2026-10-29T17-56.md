# Feature Audit: Standalone orchestration merge on green (#997)

---

**Audit Date:** 2026-10-29
**Feature Folder:** `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997`
**Base Branch:** `main`
**Head Branch:** `bug/standalone-orchestration-merge-on-green-997`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit of the full branch diff after a proportionate remediation cycle (prior audit `2026-10-29T17-10`)

---

## Scope and Baseline

- **Base branch:** `main` (merge base `fd4fe5b2985f3caaaffb60d9dc393584e7750c3a`; `origin/main` resolves to the same commit; the local `main` ref is stale and was not used)
- **Head branch/commit:** `bug/standalone-orchestration-merge-on-green-997` (commit `e8d649ac21f6cd2216613ddaccab9b49307568a8`)
- **Merge base:** `fd4fe5b2985f3caaaffb60d9dc393584e7750c3a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-29 17:51:49 UTC for head `e8d649ac21f6cd2216613ddaccab9b49307568a8`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997/evidence/**`
  - Additional evidence: reviewer Pester run of 13 repository suites (317 passed); reviewer adversarial probe (34 rows, scratchpad); reviewer parses of `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`, and `artifacts/python/coverage.json`; PSScriptAnalyzer and `Invoke-Formatter` over 11 PowerShell files; Black, Ruff, Pyright; seven Python contract modules (120 passed); Codex generator `--check`; `check_quality_tiers`; `cmp` mirror parity; evidence-location validator; logical line counts
- **Feature folder used:** `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997`
- **Requirements source:** `spec.md` `## Acceptance Criteria` (authoritative for `full-bug`)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; `spec.md` is the only AC source and no `user-story.md` applies.
- **Scope note:** PR context was current for the head SHA and was not regenerated. The full branch diff (76 files, two commits) was reviewed, not only the remediation commit.

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
14. AC-14 (amended in the remediation cycle): Non-structural commands decline (chain, wrapper, `-R`, `--repo`, URL, environment prefix, `--auto`, `--admin`, `gh api`); `--merge`, `--squash`, `--rebase` keep their behavior.
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
27. AC-27: Authorization helper unchanged; `enforce-epic-merge-gate.Tests.ps1` unchanged; `session-root-reads-850.Constraints.Tests.ps1` passes.
28. AC-28: PowerShell toolchain loop passes with counts from JUnit; evidence under `<FEATURE>/evidence/`.
29. AC-29: Line coverage at least 85% for the sibling and the gate.
30. AC-30: Seeded shuffles show no order dependence; no temp files or `gh` starts.
31. AC-31: (pending-CI) CI on the PR head is green with `ci_gate.head_sha` equal to the final head.
32. AC-32: (pending live verification, deferred) post-merge live check of standalone self-merge and parallel non-merge.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-01: allow case | PASS | `GreenCiDecision.Tests.ps1` allow row; reviewer probe control row allows | reviewer `Invoke-Pester` over 13 suites: 317 passed | — |
| 2 | AC-02: allow with pin and `pr_gate.head_sha` | PASS | Two allow rows in the same suite | same | — |
| 3 | AC-03: stale head | PASS | `GREEN_CI_HEAD_STALE` row; probe | same | — |
| 4 | AC-04: `ci_gate` cases | PASS | `GreenCi.Tests.ps1` rows; probe (`ci_gate` absent, `failure`) | same | — |
| 5 | AC-05: `step9_status` cases | PASS | Repository rows; probe (`pending`) | same | — |
| 6 | AC-06: PR binding | PASS | Repository rows; probe (string `"42"`, number 43) | same | — |
| 7 | AC-07: checkpoint and item target | PASS | Repository rows; probe (unparseable, null) | same | — |
| 8 | AC-08: bare command | PASS | Row asserts the exact final deny text; probe | same | — |
| 9 | AC-09: unresolved live head | PASS | Decision row and five wrapper rows; probe | same | — |
| 10 | AC-10: pin mismatch | PASS | Mismatch row and the new valueless-pin row | same; `regression-testing/valueless-match-head.2026-10-29T18-20.md` | Prior Info observation resolved. |
| 11 | AC-11: `epic_mode` | PASS | Pure-function rows for `true`, string `"false"`, number 1 in branch 3b | same | Through the full gate, string `"false"` with `step9_status: passed` is allowed by pre-existing branch 1, which AC-17 keeps unedited (code review, Low). AC-11 is scoped to the green branch, which declines. |
| 12 | AC-12: `head_sha` | PASS | Repository rows; probe (uppercase, differing `pr_gate.head_sha`) | same | — |
| 13 | AC-13: parallel exclusion layers | PASS | Layer 1a, 1b, 2 rows paired with the NoTarget allow row; probe (`parallel_mode`, `parallel_slug`) | same | Best-effort by design. |
| 14 | AC-14: command shape incl. `--admin` | PASS | Command-shape table now includes `--admin`; `--admin` with a green checkpoint falls through to the unchanged branch-4 deny with zero live-head calls; `--squash`/`--rebase` allow rows; probe declines ten `--admin` spellings | same; `regression-testing/admin-fail-before.2026-10-29T18-05.md` (2 failures before the fix), `admin-pass-after.2026-10-29T18-15.md` (0 failures after) | Amended in the remediation cycle; prior Low observation resolved. |
| 15 | AC-15: dependency failure | PASS | Row C9 in `hook-dependency-failure.SpecialCases.Tests.ps1` (reviewer run) | same | — |
| 16 | AC-16: stage ordering | PASS | Stage-ordering rows and the `--admin` rows assert zero live-head calls | same | — |
| 17 | AC-17: regression | PASS | `GreenCiRegression.Tests.ps1`; unchanged `enforce-epic-merge-gate.Tests.ps1`, Authorization, MergeQueue, DocsOnly pass; `Test-ChildCheckpointAllowsEpicMerge` absent from the diff | reviewer Pester run; `git diff origin/main...HEAD -- .claude/hooks/enforce-epic-merge-gate.ps1` | — |
| 18 | AC-18: deny-text pins | PASS | Unchanged by the remediation cycle; `qa-gates/deny-text-pins.2026-10-29T16-56.md` | reviewer diff read | — |
| 19 | AC-19: Python contract tests | PASS | Seven contract modules 120 passed at head; full suite 7429 passed at `98c851059` with no `.py` change since | `poetry run python -m pytest -q -p no:cacheprovider --no-cov <modules>` | — |
| 20 | AC-20: orchestrate S9 prose | PASS | Unchanged by the remediation cycle; prior audit read | `git diff 98c851059 e8d649ac2 --name-only` | — |
| 21 | AC-21: PR Creation Gate | PASS | Unchanged by the remediation cycle | same | — |
| 22 | AC-22: parallel and rule prose | PASS | `parallel-orchestrate/SKILL.md` sentence now reads "a parallel child that records them cannot merge its own pull request through that branch; the exclusion is best-effort when the keys are omitted"; `orchestrator-state.md` condition 1 lists `--admin`; no prose claims a mechanically closed exclusion | reviewer diff read | Prior Info observation resolved. |
| 23 | AC-23: hook headers | PASS | Sibling header stage C line now names the `--admin` decline; gate header unchanged | reviewer read | — |
| 24 | AC-24: mirrors and manifest | PASS | `cmp`: 6 of 6 identical; `core.json` entry; no change to `epic-orchestrate/SKILL.md`, `.claude/settings.json`, `.codex`, the authorization helper, or `hook-docs-only-diff.ps1` | `cmp`; `git diff --name-only origin/main...HEAD` | — |
| 25 | AC-25: gate size | PASS | 476 lines | reviewer logical line count | — |
| 26 | AC-26: sibling and suite sizes | PASS | Sibling 325; suites 267, 329, 109 | same | — |
| 27 | AC-27: unchanged files | PASS | Authorization helper and `enforce-epic-merge-gate.Tests.ps1` absent from the diff; full Pester run 0 failures | `git diff --name-only`; `qa-gates/pester-full.2026-10-29T19-10.md` | — |
| 28 | AC-28: toolchain loop | PASS | `qa-gates/format.2026-10-29T18-30.md`, `analyze.2026-10-29T18-30.md`, `pester-full.2026-10-29T19-10.md`; reviewer PSScriptAnalyzer 0 findings and formatter drift 0; JUnit 12203 cases, 0 failures | read of evidence; reviewer runs | Evidence timestamps are later than the commit (code review, Low); results reproduced. |
| 29 | AC-29: coverage | PASS | Reviewer parse: sibling 57/57 (100.00%), gate 132/132 (100.00%) | parse of `artifacts/pester/powershell-coverage.xml` | Artifact from a full single-process run. |
| 30 | AC-30: isolation | PASS | `regression-testing/isolation.2026-10-29T19-20.md` (seeds 11, 23, 37; 245 passed each); new rows create no files and start no process | read of evidence; diff read | — |
| 31 | AC-31: CI green on the PR head | UNVERIFIED | No pull request exists for the branch yet (`gh pr list --head <branch>` returns none) | — | Pending CI; CI-dependent criterion owned by the item's own orchestrator run at S9. Not a review defect. |
| 32 | AC-32: post-merge live verification | UNVERIFIED | Cannot run before merge | — | Deferred by design in the spec; not claimed as passed. Not a review defect. |

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
2. After merge, perform the AC-32 live check from a non-isolated run on the merged tree.
3. Decide whether to harden branch 1 so only a JSON boolean `true` satisfies `epic_mode` (requires amending AC-17 if done in this item; otherwise a separate hardening item).

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
| `spec.md` | 32 | 30 | 2 | AC-01 to AC-30 were already checked and each evaluated PASS in this audit, including the amended AC-14. AC-31 is pending CI and AC-32 is deferred; both remain unchecked. |

No source-file checkbox change was made in this review, because every PASS criterion was already checked and the two unchecked criteria are not verifiable before the pull request exists or the merge occurs.
