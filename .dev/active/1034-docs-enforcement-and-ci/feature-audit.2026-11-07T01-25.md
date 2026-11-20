# Feature Audit: docs-enforcement-and-ci (#1034)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-enforcement-and-ci-1034-r2`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `e3e4aa551808a25c436337bf0dbcf298421a34d6`)
- **Head branch/commit:** `feature/docs-enforcement-and-ci-1034-r2` (commit `48892dc051bf9ad257f8e7a3dd2ed0e0c9c073da`)
- **Merge base:** `e3e4aa551808a25c436337bf0dbcf298421a34d6`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/**`
  - Additional evidence: review runs and probes described in `policy-audit.2026-11-07T01-25.md` and `code-review.2026-11-07T01-25.md`
- **Feature folder used:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** full feature-versus-base audit. No pull request exists yet, so CI-dependent criteria are pending. Criteria are graded on their text; a criterion that names only a tested scenario passes on that scenario, and behavior beyond it is reported as a finding.

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
| spec:516 gate disabled allows; enabled denies absent, failing or other-revision receipts, and names the reason | PARTIAL | Disabled path and named denials pass. Enabled, an integration merge with no receipt is allowed for a branch-name selector, a GraphQL node identifier and a chained second merge (F1), and an unreadable profile yields allow (F2). |
| spec:517 `surface-delta` reports an added CLI command and nothing once ledgered | PASS | Real process: exit 1 with `DOCS_SURFACE_UNLEDGERED_ADDITION`, then exit 0 with `result.added` holding the element. |
| spec:518 template requires `pwsh` only | PASS | `DocsInitTemplate.DocsWorkflow.Tests.ps1` 17 passed; template read; actionlint exit 0. |
| spec:519 mirror parity for `feature-review` surfaces | PASS | Four source and bundle pairs share blob identifiers; push-down suites pass. |
| spec:523 gate disabled command table, zero `gh` calls | PASS | Suite 41 passed; real hook returned allow for a merge with the gate disabled. |
| spec:524 mocked integration denials and allow | PASS | Suite 41 passed. The text specifies a mocked pull request resolved by the lookup. |
| spec:525 `PROFILE_UNREADABLE`, `PR_UNRESOLVED`, `MATCH_HEAD_MISMATCH`, `RECEIPT_PATH_INVALID`, envelope anomaly | PASS | Suite passed; probes confirmed space and equals forms; real `gh` with no remote gave `PR_UNRESOLVED`. The text limits `PROFILE_UNREADABLE` to text that does not parse. |
| spec:526 predicates with in-memory strings | PASS | Suite 35 passed; M1, M2 and M3 killed. |
| spec:527 import closure and hook contract suites | PASS | Imports read; 683, 25 and 33 passed; those suites are not in the diff. |
| spec:528 settings entry, identical copies, contract suites | PASS | Shared blob `a46956dd3`; 10, 86, 194 and 15 passed. |
| spec:529 in-memory addition and ledgered cases | PASS | 17 and 15 passed. |
| spec:530 change, line-only, null base, retained warning, shuffle with seed | PASS | Suite passed; M4 killed. M5 survived on a case outside this text (N2). |
| spec:531 usage, unresolved, missing, stale and `-Json` shape | PASS | Suite 15 passed; real runs confirmed exit 2, base unresolved and stale. |
| spec:532 envelope schema validation | PASS | `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'` in `DocsSurfaceDeltaCommands.Tests.ps1`. |
| spec:533 row under anchor, only added lines | PASS | Recorded deviations: the anchor is `# --- 1034: surface-delta ---`, and 8 whitespace-only lines are required by the analyzer. Verified 8 removed lines, 0 with `--ignore-all-space`. The criterion text remains stale (N5). |
| spec:534 revision members through a bounded `[scriptblock]` seam | PASS | Suite 23 passed; M11 killed. The BOM assertion is ineffective (N1); the return value itself is correct. |
| spec:535 `init` template row, plan, write, refusal | PASS | Suite passed; real `init -Write` listed and wrote the destination. |
| spec:536 template content rules | PASS | Suite passed; template read. |
| spec:537 section present, bundle identical, delegating files unchanged | PASS | One heading in each of four files, blob parity, and no diff for the delegating files. |
| spec:538 push-down suites and generator check | PASS | 98 passed; generator exit 0; Copilot pair blob `1018219a1` identical. |
| spec:539 manifest rows and bundle parity | PASS | Each of five new files listed once; blobs identical; 7, 104 and 6 passed. |
| spec:540 coverage at or above 85% | PASS | 100.00, 100.00, 97.33 and 93.59%. No exclusion. Figures are in `evidence/qa-gates/`, because `evidence/coverage/` is not a canonical path. |
| spec:541 no new file above 500 lines | PASS | 191, 292, 221 and 289. |
| spec:542 no Python or TypeScript file | PASS | Diff scan empty; the classification table is in the plan. |
| spec:543 no temporary-file tokens | PASS | Re-scanned 10 test files; 0 matches. |
| spec:544 CI-dependent | PENDING-CI | No pull request exists. Owned by S9. |
| story:65 same text as spec:516 | PARTIAL | As spec:516. |
| story:66 same text as spec:517 | PASS | As spec:517. |
| story:67 same text as spec:518 | PASS | As spec:518. |
| story:68 same text as spec:519 | PASS | As spec:519. |
| story:72 disabled allows every tested command, no `gh` call | PASS | As spec:523. |
| story:73 enabled, an integration-to-`main` merge is denied with a receipt reason | PARTIAL | Not stated as a mocked scenario, and F1 shows integration merges that are allowed. |
| story:74 enabled, denies "in the corresponding conditions" | PARTIAL | An existing profile that cannot be read returns allow (F2). |
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

The surface-delta, template, registration, push-down, coverage and language criteria are delivered. The merge gate works for numeric and URL selectors but is not reliable for every merge form, and it allows the merge when the profile cannot be read.

**Overall readiness: not ready.** Four criteria are PARTIAL and one is pending CI. Remediation inputs: `remediation-inputs.2026-11-07T01-25.md`.

---

## Acceptance Criteria Check-off

Four criteria were checked on arrival and are reverted to unchecked by this audit, because they evaluate PARTIAL: spec:516, story:65, story:73 and story:74. The remaining PASS criteria were already checked, so no new check-offs were made. spec:544 stays unchecked for S9.

The reverted boxes are uncommitted edits to `spec.md` and `user-story.md` in the worktree, together with the review artifacts.

### AC Status Summary

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md`, `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/user-story.md`
- Total AC items: 42
- Checked off (delivered): 37
- Remaining (unchecked): 5
- Items remaining:
  - spec:516 and story:65: gate disabled allows; enabled denies an absent, failing or other-revision receipt.
  - story:73: an integration-to-`main` merge is denied with a receipt reason.
  - story:74: denies with `PROFILE_UNREADABLE`, `PR_UNRESOLVED`, `MATCH_HEAD_MISMATCH` or `RECEIPT_PATH_INVALID` in the corresponding conditions.
  - spec:544: CI-dependent checks on the pull request head.
