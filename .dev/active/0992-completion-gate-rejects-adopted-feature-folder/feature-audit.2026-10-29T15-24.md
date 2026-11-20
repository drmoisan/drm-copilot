# Feature Audit: Completion gate rejects adopted feature folder (#992)

---

**Audit Date:** 2026-10-29
**Feature Folder:** `docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992`
**Base Branch:** `main`
**Head Branch:** `bug/completion-gate-rejects-adopted-feature-folder-992`
**Work Mode:** `full-bug`
**Audit Type:** Initial audit of the full branch diff

---

## Scope and Baseline

- **Base branch:** `main` (merge base `f721222cf4eaacc799aa0c35fe54722868ef7e93`; `origin/main` resolves to the same commit)
- **Head branch/commit:** `bug/completion-gate-rejects-adopted-feature-folder-992` (commit `839bfb8242a7ecfb14ab92a3e397f95c0e089f44`)
- **Merge base:** `f721222cf4eaacc799aa0c35fe54722868ef7e93`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-29 15:20:25 UTC for head `839bfb8242a7ecfb14ab92a3e397f95c0e089f44`; current)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992/evidence/**`
  - Additional evidence: reviewer full Python suite with branch coverage; reviewer parses of `artifacts/python/coverage.json`, `extensions/drm-copilot/coverage/coverage-summary.json`, and `artifacts/pester/powershell-coverage.xml`; PSScriptAnalyzer over nine changed PowerShell files; Black, Ruff, Pyright, Prettier, ESLint, `tsc`; Codex generator `--check`; `check_quality_tiers`; `cmp` mirror parity; evidence-location validator; logical line counts; corpus count and parity minimums
- **Feature folder used:** `docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992`
- **Requirements source:** `spec.md` `## Acceptance Criteria` (authoritative for `full-bug`)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; `spec.md` is the only AC source and no `user-story.md` applies.
- **Scope note:** PR context was current for the head SHA and was not regenerated. The full branch diff (102 files) was reviewed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992/spec.md`: only authoritative source (full-bug); 22 checkbox items, AC-1 to AC-22

### From spec.md

1. AC-1: A valid `feature_folder_record` waives `new_active_feature_folder` with no adoption error and no missing-receipt line, in all three validators.
2. AC-2: Waiving without an object record yields the rule-10 string followed by the fail-closed missing-receipt line.
3. AC-3: Rules 11a-11e yield their exact strings, in rule order, identically in the three runtimes.
4. AC-4: Every other tool, including `validate_orchestration_artifacts` and case variants, still cannot be waived.
5. AC-5: Existing rule-8 messages apply on the `remediation` route, with a successful receipt, and without `potential_to_issue`.
6. AC-6: Skipping both promotion and adoption evidence still yields the missing-receipt error.
7. AC-7: The three existing non-waivable tests are updated, and none still asserts "cannot be waived" for the tool.
8. AC-8: Parity minimums raised by the number of fixtures added, independently enumerated, and passing.
9. AC-9: Hook allows when the injected invoker returns exit 0 and `tree`.
10. AC-10: Hook blocks with the repairable message on non-zero exit, empty output, other output, a throw, or exit -1.
11. AC-11: Invoker never called when not waived, for epic and parallel types, or for a failing path; the command is the fixed form.
12. AC-12: Validators perform no file-system or git access; the rule prose discloses the declaration-only boundary.
13. AC-13: Rule prose documents the field, rules 10 and 11a-11e, the closed-set sentence, the fail-closed paragraph, and the enforcement bullet; no stale "can never be waived" statement for the tool.
14. AC-14: Skill prose and bundle copies are updated, and the skill-contract and pinned-surface checks pass.
15. AC-15: Byte-equal mirrors, `core.json` entries, and the manifest, completeness, closure, and dependency-guard suites pass.
16. AC-16: No production, test, or script file exceeds 500 lines; the near-limit files are not extended.
17. AC-17: New modules meet coverage thresholds; Jest per-file entry; no production `exclude`; no changed-line regression.
18. AC-18: No real git, no temporary files, no drive-letter paths, and no gitignored-checkpoint reads; shuffled runs pass.
19. AC-19: Manual `git cat-file -t HEAD:<path>` confirmation recorded.
20. AC-20: The full seven-stage toolchain passes in a single pass for the touched surfaces.
21. AC-21: Local repro: the hook allows an adopted, committed folder with a valid record and blocks when the folder is absent or the record is missing; Python CLI `--require-complete` confirmation.
22. AC-22: (pending-CI) CI on the PR head is green for every required check.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1: valid record waives the tool | PASS | `valid-large-waives-feature-folder-with-record.json` and `valid-bug-preparation-waives-feature-folder-with-record.json` (empty `expected_errors`) pass in all three parity suites | reviewer full `poetry run pytest --cov --cov-branch`; executor Jest and full Pester runs | — |
| 2 | AC-2: rule 10 plus fail-closed line | PASS | Reworked `waives-new-active-feature-folder.json` and `waives-feature-folder-record-not-object.json`; per-runtime rule-10 unit tests; `regression-testing/fail-before.2026-10-29T14-38.md` | reviewer full Python run | The corpus orders missing-receipt lines before the rule-10 string, as stated in the spec's AC-2 clarification. |
| 3 | AC-3: rules 11a-11e strings and order | PASS | Path-format, mismatch, absent and non-string `feature-folder`, and `waives-feature-folder-record-fields-in-rule-order.json` fixtures; error constants are identical in the three record modules (reviewer read) | reviewer full Python run; source read | — |
| 4 | AC-4: closed set preserved | PASS | `waives-validate-orchestration-artifacts.json` and `case-variant-tool-name.json` unchanged (absent from `git diff --name-only`) and passing | `git diff --name-only f721222cf..HEAD -- tests/fixtures/` | — |
| 5 | AC-5: rule-8 interactions unchanged | PASS | `waives-feature-folder-on-remediation-route.json`, `waives-feature-folder-with-successful-receipt.json`, `waives-feature-folder-without-potential-to-issue.json` pass | reviewer full Python run | — |
| 6 | AC-6: skip-both stays blocked | PASS | `absent-key-large-missing-receipt.json` unchanged and passing | same | — |
| 7 | AC-7: changed existing tests | PASS | The three named tests now assert rule 10; a reviewer search of the three files finds no "cannot be waived" assertion for `new_active_feature_folder` | `grep -n "cannot be waived" <three test files>` | — |
| 8 | AC-8: parity minimums | PASS | Directory count 48; `MINIMUM_CORPUS_COUNT = 48` (Python, TypeScript) and `$minimumFixtureCount = 48` (Pester); second enumeration in `baseline/corpus-count.2026-10-29T14-21.md` and `regression-testing/fail-before.2026-10-29T14-38.md` | `ls tests/fixtures/orchestrator_state_issue_adoption/*.json \| wc -l`; `grep` of the three suites | 34 + 14 new = 48. |
| 9 | AC-9: hook allow | PASS | "allows a waived folder when git exits 0 and prints tree" and the `Invoke-OrchestratorOutputValidation` threading row | executor full Pester run (12104 cases, 0 failed); reviewer read of the suite | — |
| 10 | AC-10: hook block | PASS | `-ForEach` rows for exit 128, empty, `blob`, -1, null exit code; throwing-invoker row; each asserts `Repairable` and the exact message; `regression-testing/fail-before-hook-suite.2026-10-29T14-46.md` | same | — |
| 11 | AC-11: probe scope and command | PASS | Fixed argument row (`-C\|root\|cat-file\|-t\|HEAD:<folder>`); call count 0 for not waived, epic, parallel, failing path, and malformed `issue_adoption` | same | — |
| 12 | AC-12: declaration-only boundary | PASS | Record modules import no I/O module (Python: `re`, `typing`; TypeScript: none; PowerShell: `OrchestratorStateCheckpointValue.psm1` only); rule paragraph "The `feature_folder_record` is likewise declaration-only ..." | reviewer source read; read of `.claude/rules/orchestrator-state.md` | — |
| 13 | AC-13: rule prose | PASS | Field table row, rules 10 and 11a-11e, closed-set sentence, fail-closed paragraph, enforcement bullet naming the three modules and the hook sibling; the only "can never be waived" sentence lists the tool as waivable with a record | `grep -rn "can never be waived" .claude/rules .claude/skills .agents/skills extensions/drm-copilot/resources/` | — |
| 14 | AC-14: skill prose and pinned surfaces | PASS | Five `.claude` skills and `.agents/skills/feature-promotion-lifecycle/SKILL.md` updated with byte-equal bundle copies; `test_parallel_issue_adoption_skill_contracts.py` and `test_push_down_claude_resource_contracts.py` pass within the reviewer full run; `qa-gates/contracts.2026-10-29T15-12.md` | `cmp`; reviewer full Python run | — |
| 15 | AC-15: mirrors and manifests | PASS | `cmp`: 11 of 11 identical; `core.json` lists both new `.claude` files; completeness and closure tests pass (reviewer); `OrchestratorState.Manifest.Tests.ps1` and `hook-dependency-guard-completeness.Tests.ps1` pass in the full Pester run | `cmp <file> extensions/drm-copilot/resources/.../<file>` | No Codex agent file edited; generator `--check` exit 0 regardless. |
| 16 | AC-16: file-size limits | PASS | Reviewer logical counts: largest 497 (`jest.config.cjs`), then 484; the two near-limit files are absent from the branch diff | logical line split equivalent to `@(Get-Content -LiteralPath <path>).Count`; `qa-gates/line-counts.2026-10-29T15-00.md` | — |
| 17 | AC-17: coverage | PASS | Python new module 100%/100%, TypeScript new module 100%/100%, PowerShell new modules 100.00% and 92.59%; changed files at or above baseline; Jest per-file entry present; no `exclude`/`omit` change | reviewer parses of the three coverage artifacts | — |
| 18 | AC-18: isolation and determinism | PASS | `regression-testing/isolation.2026-10-29T15-16.md`; reviewer search of the four new suites finds no temp-file API and no real git invocation; drive-letter strings occur only as rejected inputs | `grep` of the four new suites | — |
| 19 | AC-19: manual probe confirmation | PASS | `other/probe-confirmation.2026-10-29T14-51.md`: committed folder prints `tree` with exit 0; absent and untracked paths exit 128 | read of evidence | — |
| 20 | AC-20: full toolchain | PASS | Executor QA-gate evidence for all stages in each language; reviewer re-runs of format, lint, type check, Python tests, PSScriptAnalyzer, and contract checks are clean | policy audit Section 2.5 | — |
| 21 | AC-21: local repro | PASS | Hook suite allow and block rows (folder absent from HEAD blocks); `other/cli-require-complete.2026-10-29T14-51.md`: the adopted checkpoint produces no adoption line, and the no-record checkpoint produces the rule-10 and missing-receipt lines | read of evidence; executor full Pester run | Both CLI runs exit 1 because of partial-checkpoint keys unrelated to adoption, as documented in the evidence. |
| 22 | AC-22: CI green on the PR head | UNVERIFIED | No pull request exists for the branch yet | — | Pending CI; CI-dependent criterion owned by the item's own orchestrator run at S9. Not a review defect. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 21 criteria (AC-1 to AC-21)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-22, pending CI by design)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. AC-22 is a CI-dependent criterion that cannot be verified before the pull request exists.

**Recommended follow-up verification steps:**

1. At S9, confirm `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head, then check off AC-22 from the item's own run.
2. Before DONE, record a valid `feature_folder_record` in this run's own checkpoint and confirm that the hook copy that runs contains the change (spec `### Dependencies or blocked work`).
3. After merge, confirm that a parallel or epic run with a pre-prepared folder reaches DONE without a hand-copied receipt (spec `## Rollout & Follow-up`).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-28-completion-gate-rejects-adopted-feature-folder-992/spec.md`
- Total AC items: 22
- Checked off (delivered): 21
- Remaining (unchecked): 1
- Items remaining: AC-22 "(CI, pending-CI): CI on the PR head is green for every required check, including the Python, Jest, and Pester jobs, the Linux hook-suite job, the push-down and manifest suites, and the shuffle guards."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 22 | 21 | 1 | AC-1 to AC-21 were already checked by the executor and each evaluated PASS in this audit. AC-22 is pending CI and remains unchecked. |

No source-file checkbox change was made in this review, because every PASS criterion was already checked and the one unchecked criterion is pending CI.
