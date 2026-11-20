# Feature Audit: docs-enforcement-and-ci (#1034)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-enforcement-and-ci-1034-r2`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `e3e4aa551808a25c436337bf0dbcf298421a34d6`)
- **Head branch/commit:** `feature/docs-enforcement-and-ci-1034-r2` (commit `3007ef3467256e04c4a66483f72127b9b18ed5e1`)
- **Merge base:** `e3e4aa551808a25c436337bf0dbcf298421a34d6`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/**`
  - Additional evidence: review runs and probes described in `policy-audit.2026-11-07T02-24.md` and `code-review.2026-11-07T02-24.md`
- **Feature folder used:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** full feature-versus-base audit. No pull request exists, so CI-dependent criteria are pending. As in the previous audit, criteria are graded on their text; a criterion that names only a tested scenario passes on that scenario, and behavior beyond it is reported as a finding.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md` - primary (26 criteria, lines 516-519 and 523-544)
- `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/user-story.md` - primary (16 criteria, lines 65-68 and 72-83)

### Acceptance criteria

Criteria are identified by source file and line. The full wording is in the source files and is not changed here. `## Definition of Done` and `## Seeded Test Conditions` are not acceptance criteria and are not graded.

---

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence |
|---|---|---|
| spec:516 gate disabled allows; enabled denies absent, failing or other-revision receipts, and names the reason | PARTIAL | The previous probe table now denies. With the gate enabled and no receipt, an integration merge is still allowed for a selector after a redirection containing `&`, a brace selector, a `#`-led token on an integration checkout (F1), and a merge inside a compound command (F3). |
| spec:517 `surface-delta` reports an added CLI command and nothing once ledgered | PASS | Code unchanged since the previous PASS; merged run 0 failures. |
| spec:518 template requires `pwsh` only | PASS | Unchanged since the previous PASS. |
| spec:519 mirror parity for `feature-review` surfaces | PASS | Source and bundle blobs identical at head; 27 push-down tests passed. |
| spec:523 gate disabled command table, zero `gh` calls | PASS | Suite 111 passed; an absent profile allowed in a real process. |
| spec:524 mocked integration denials and allow | PASS | Suite 111 passed. The text specifies a mocked pull request resolved by the lookup. |
| spec:525 `PROFILE_UNREADABLE`, `PR_UNRESOLVED`, `MATCH_HEAD_MISMATCH`, `RECEIPT_PATH_INVALID`, envelope anomaly | PASS | Suite passed. Real processes: unparseable (empty) profile denied `PROFILE_UNREADABLE`. |
| spec:526 predicates with in-memory strings | PASS | Module unchanged; merged run 0 failures. |
| spec:527 import closure and hook contract suites | PASS | Imports unchanged by the cycle; contract suites in the merged run 0 failures, and P2-T3 records 1147 passed across seven hook suites. |
| spec:528 settings entry, identical copies, contract suites | PASS | Shared blob `a46956dd3`; merged run 0 failures. |
| spec:529 in-memory addition and ledgered cases | PASS | Unchanged; merged run 0 failures. |
| spec:530 change, line-only, null base, retained warning, shuffle with seed | PASS | Unchanged. M5 still survives on a case outside this text (N2). |
| spec:531 usage, unresolved, missing, stale and `-Json` shape | PASS | Unchanged; merged run 0 failures. |
| spec:532 envelope schema validation | PASS | Unchanged; merged run 0 failures. |
| spec:533 row under anchor, only added lines | PASS | Unchanged. Recorded deviations stand, and the criterion text remains stale (N5). |
| spec:534 revision members through a bounded `[scriptblock]` seam | PASS | Unchanged. The BOM assertion remains ineffective (N1). |
| spec:535 `init` template row, plan, write, refusal | PASS | Unchanged; merged run 0 failures. |
| spec:536 template content rules | PASS | Unchanged. |
| spec:537 section present, bundle identical, delegating files unchanged | PASS | Unchanged; blob parity re-checked for the Claude surface. |
| spec:538 push-down suites and generator check | PASS | 27 push-down tests passed here and 265 contract tests in P4-T6; generator exit 0 at head. |
| spec:539 manifest rows and bundle parity | PASS | No new file in this cycle; nine pairs share blobs at head. |
| spec:540 coverage at or above 85% | PASS | 96.89, 100.00, 100.00 and 97.33%, re-derived from `artifacts/pester/powershell-coverage.xml`. No exclusion. |
| spec:541 no new file above 500 lines | PASS | 500, 191, 292 and 221. The hook has no room left (code review N11). |
| spec:542 no Python or TypeScript file | PASS | Diff scan empty. |
| spec:543 no temporary-file tokens | PASS | Hook suite re-scanned; 0 matches. |
| spec:544 CI-dependent | PENDING-CI | No pull request or workflow run exists. Owned by S9. |
| story:65 same text as spec:516 | PARTIAL | As spec:516. |
| story:66 same text as spec:517 | PASS | As spec:517. |
| story:67 same text as spec:518 | PASS | As spec:518. |
| story:68 same text as spec:519 | PASS | As spec:519. |
| story:72 disabled allows every tested command, no `gh` call | PASS | As spec:523. |
| story:73 enabled, an integration-to-`main` merge is denied with a receipt reason | PARTIAL | As spec:516: the F1 and F3 forms are integration merges that are allowed. |
| story:74 enabled, denies "in the corresponding conditions" | PASS | F2 closed. Real processes: locked profile, empty profile and directory at the profile path deny `PROFILE_UNREADABLE`; absent profile allows. Suite rows cover `PR_UNRESOLVED` on a failed lookup, `MATCH_HEAD_MISMATCH` and `RECEIPT_PATH_INVALID`. The conditions are those listed in spec:525. Mis-bound selectors are graded under story:73. |
| story:75 registration and contract suites | PASS | As spec:527 and spec:528. |
| story:76 addition exit 1, ledgered exit 0 | PASS | As spec:517. |
| story:77 changed elements, ignored differences, absent base, bad `-Base` | PASS | As spec:530 and spec:531. |
| story:78 row under anchor, added lines only | PASS | As spec:533. |
| story:79 `init` and template rules | PASS | As spec:535 and spec:536. |
| story:80 review section and parity | PASS | As spec:537. |
| story:81 manifest, parity, generator | PASS | As spec:538 and spec:539. |
| story:82 coverage | PASS | As spec:540. |
| story:83 no Python, TypeScript or temporary files | PASS | As spec:542 and spec:543. |

---

## Summary

The surface-delta, template, registration, push-down, coverage and language criteria remain delivered. F2 is closed, so story:74 now passes. The merge gate handles the forms in the previous probe table, but it still allows an integration merge with no receipt in the forms listed in the code review.

**Overall readiness: not ready.** Three criteria are PARTIAL and one is pending CI. Remediation inputs: `remediation-inputs.2026-11-07T02-24.md`.

---

## Acceptance Criteria Check-off

Newly checked off by this audit: story:74 in `user-story.md`. The remaining PASS criteria were already checked. spec:516, story:65 and story:73 stay unchecked because they evaluate PARTIAL, and spec:544 stays unchecked for S9.

The check-off is an uncommitted edit to `user-story.md` in the worktree, together with the review artifacts.

### AC Status Summary

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/user-story.md`
- Total AC items: 42
- Checked off (delivered): 38
- Remaining (unchecked): 4
- Items remaining:
  - spec:516 and story:65: gate disabled allows; enabled denies an absent, failing or other-revision receipt.
  - story:73: an integration-to-`main` merge is denied with a receipt reason.
  - spec:544: CI-dependent checks on the pull request head.
