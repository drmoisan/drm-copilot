# Feature Audit: codex-review-coverage-hook-reads-stale-or-foreign-artifacts (#1114)

**Audit Date:** 2026-11-07
**Work Mode:** full-bug (from `issue.md`); AC source: `spec.md` `## Acceptance Criteria`.

## Scope and Baseline

- Branch `bug/codex-coverage-hook-freshness` at `ee3bffcf773e6b3238c02878a8fb97eebbdb3b50`; base `main`, merge base `c24cbd295ecec1fc759f52a42806ad991aa49478`.
- Scope: full branch diff (38 paths). PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 19:54 UTC at the same head.
- Baseline: Phase 0 artifacts under `evidence/baseline/` (Pester 15881 tests, 0 failed; PowerShell 94.06% lines; pytest 16204 passed).
- Verification sources used by this review: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (written 19:47 UTC, after the last production commit at 19:39 UTC), the evidence files, `git diff`, `cmp`, `diff`, and real-process probes of the hook.

## Acceptance Criteria Inventory

| # | Criterion (abridged) | Source state |
|---|---|---|
| 1 | Foreign-audit selection fixed; row `1114: judges the audit named by the reviewer when another item's audit is newer`; fail-before evidence | [x] |
| 2 | Recency selection removed; `Get-LatestPolicyAudit` gone; no `docs/features/active` enumeration; two rows replaced | [x] |
| 3 | Stale report in an item worktree blocks; reason names language and item root; fail-before evidence | [x] |
| 4 | Absent report in an item worktree blocks; reason names language, expected path, item root | [x] |
| 5 | Integration scenario row passes | [x] |
| 6 | D2 rows: block once; `continue = false` when the stop hook is active | [x] |
| 7 | Ambiguous or invalid audit paths block (target suite rows) | [x] |
| 8 | Extraction and selection rows (shapes, separators, labels, relative, absolute, greatest timestamp) | [x] |
| 9 | Freshness scope D1 no-probe rows | [x] |
| 10 | Freshness twin parity rows | [x] |
| 11 | Single-item fresh behaviour unchanged; parity suites pass | [x] |
| 12 | Runtime isolation: E4-ST7 and E4-ST3 pass | [x] |
| 13 | Dependency-load failures: `B1` rows pass | [x] |
| 14 | No Claude production change; no Python in hooks; Claude suites pass | [x] |
| 15 | Mirror and manifest parity (`legacy-codex-hook-contracts.Tests.ps1`) | [x] |
| 16 | Bundle contract tests and generator check | [x] |
| 17 | Brief parity and brief contract tests | [x] |
| 18 | Coverage >= 85% for the three hook files | [x] |
| 19 | Full toolchain single pass, no new failures | [x] |
| 20 | CI-dependent: `poshqc / PowerShell hook suites (Linux)` passes on the PR head | [ ] |

## Acceptance Criteria Evaluation

| # | Status | Evidence |
|---|---|---|
| 1 | PASS | Row at line 201 of `validate-feature-review-coverage.Coverage.Tests.ps1` passes in `pester-junit.xml`; `fail-before.2026-11-07T19-37.md` records it failing with the foreign audit judged. |
| 2 | PASS | `grep` for `Get-LatestPolicyAudit` and `docs/features/active` in the hook returns nothing; the two rows are absent and target-selection rows exist (lines 90, 104). |
| 3 | PASS | Row passes; asserts `*Python coverage report*is stale*` and the item root; fail-before recorded. |
| 4 | PASS | Row passes; asserts `Python has changed files`, `'artifacts/python/lcov.info'`, and the item root. |
| 5 | PASS | Row passes; fail-before recorded. |
| 6 | PASS | Both rows pass; `continue` asserted false; no recency code remains. |
| 7 | PASS | Target suite rows for `AUDIT_AMBIGUOUS`, `TARGET_WORKTREE_AMBIGUOUS`, `AUDIT_PATH_TRAVERSAL`, `AUDIT_NOT_FOUND`, and null or non-string messages pass (34 of 34). |
| 8 | PASS | Rows for both shapes, both separators, labelled and unlabelled, relative and absolute, and greatest-timestamp pass. The named rows meet the criterion; CR-1 in the code review records message shapes outside these rows (whitespace roots, trailing punctuation) that the extractor drops. |
| 9 | PASS | No-probe rows pass in the twin suite (21 of 21). |
| 10 | PASS | Parity rows pass; this review's `diff` of the function regions of the two files is empty. |
| 11 | PASS | Named rows pass; `feature-review-coverage-narrowing-parity.Tests.ps1` (66) and `feature-review-coverage-floor-parity.Tests.ps1` (4) pass. |
| 12 | PASS | `E4-ST7` and both `E4-ST3` rows pass in `pester-junit.xml`. |
| 13 | PASS | Four `B1` rows for the Codex hook pass (thresholds, `hook-target-worktree.ps1`, freshness twin, target file). |
| 14 | PASS | `git diff --name-only` of the merge base against head lists no path under `.claude/hooks`, `.claude/lib`, or their bundle mirrors; no `.py` under `.codex/hooks`; the four Claude suites pass. |
| 15 | PASS | Suite passes (43); `cmp` confirms the three bundle copies; `core.json` lists both new files. |
| 16 | PASS | `pytest-parallel.2026-11-07T19-50.md` lists the three contract tests passing; `codex-generator-check.2026-11-07T19-50.md` exit 0. |
| 17 | PASS | The six brief copies share one blob id at head; the four brief tests pass; the bullet names the hook, the message selection, the resolver file, and the twin. |
| 18 | PASS | This review's parse: hook 100.00%, twin 97.96%, target 98.51%. |
| 19 | PASS | Format, analyze, Pester, pytest gates at 19-40 to 19-50 report no new failures versus Phase 0. |
| 20 | PENDING-CI | No PR exists yet; the S9 gate owns the check-off. |

## Summary

- 19 of 20 criteria PASS on verified evidence; criterion 20 is pending CI.
- The review records one blocking code finding (CR-1) that no criterion names. It concerns extraction robustness beyond the rows that criterion 8 enumerates, so no criterion is reverted; the remediation adds rows to the target suite.
- Base drift: `origin/main` moved to `12825cb00` (PR #1112). Merge-tree is clean and the merged tree passes the leak scan; the Linux CI job on the PR head remains the deciding check for criterion 20.

## Acceptance Criteria Check-off

Criteria 1 to 19 were already checked off by the executor in `spec.md`; this review verified each one and made no change to the file. Criterion 20 stays unchecked for the S9 gate.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-07-codex-review-coverage-hook-reads-stale-or-foreign-artifacts-1114/spec.md`
- Total AC items: 20
- Checked off (delivered): 19
- Remaining (unchecked): 1
- Items remaining: CI-dependent: the `poshqc / PowerShell hook suites (Linux)` job passes on the PR head, including the three named codex-hooks suites.
