# Feature Audit: docs-enforcement-and-ci (#1034)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-enforcement-and-ci-1034-r2`
**Work Mode:** `full-feature`
**Audit Type:** Re-audit after remediation cycle 3

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (merge base and current tip `e1f4d2e54dd877929f28fd5496231304d3c5308f`)
- **Head branch/commit:** `feature/docs-enforcement-and-ci-1034-r2` (commit `abb854f5346caa1d1c4054e508c90ba840bbe70e`)
- **Merge base:** `e1f4d2e54dd877929f28fd5496231304d3c5308f`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/**`
  - Additional evidence: review runs and probes described in `policy-audit.2026-11-07T05-55.md` and `code-review.2026-11-07T05-55.md`
- **Feature folder used:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** full feature-versus-base audit. No pull request exists, so CI-dependent criteria are pending. As in the previous audits, criteria are graded on their text; a criterion that names only a tested scenario passes on that scenario, and behavior beyond it is reported as a finding.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md` - primary (26 criteria, lines 516-519 and 523-544)
- `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/user-story.md` - primary (16 criteria, lines 65-68 and 72-83)

### Acceptance criteria

Criteria are identified by source file and line. The full wording is in the source files and is not changed here. `## Definition of Done` and `## Seeded Test Conditions` are not acceptance criteria and are not graded.

### Readings the executor asked to have confirmed

`evidence/other/criteria-reevaluation.2026-11-07T05-38.md` lists two readings.

1. **spec:516 and story:65, "each form either denies or is named in the residual limits": accepted as the standard, and not met.** Named forms such as `python -c`, `curl` and `trap` are stated limits and are not findings. The caller's wider wording, a form the limit statement "names or falls within", is applied to forms outside the group the hook claims to deny. It does not apply to the F6 forms: the statement says the words `gh pr merge` in the unquoted text deny, and it reserves its limit for "any other way of causing a merge". The evidence set of the re-evaluation does not include those forms.
2. **story:73, a merge the hook reads in any non-plain form denies `PR_UNRESOLVED`, and the receipt reason and allow clause apply to the plain form: accepted.** The receipt reasons and the passing-receipt allow are verified for the plain form. The criterion stays PARTIAL because the denial does not hold for F6, as it did not for F4 and F5 in the previous audit.

---

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence |
|---|---|---|
| spec:516 gate disabled allows; enabled denies absent, failing or other-revision receipts, and names the reason | PARTIAL | Disabled clause holds in real processes for every probe, apart from the stated envelope and import exceptions. The F4 and F5 tables deny. With the gate enabled and no receipt, an integration merge is still allowed in the F6 forms (a quote or `<<` in a comment, `<<` in arithmetic, nested double quotes in a substitution), and the limit statement places those words in the group it says deny. |
| spec:517 `surface-delta` reports an added CLI command and nothing once ledgered | PASS | Code unchanged since the previous PASS; merged run 0 failures. |
| spec:518 template requires `pwsh` only | PASS | Unchanged since the previous PASS. |
| spec:519 mirror parity for `feature-review` surfaces | PASS | Source and bundle blobs identical at head for all four surfaces. |
| spec:523 gate disabled command table, zero `gh` calls | PASS | Suites passed; compound and disabled rows pass in the merged run and in real processes (`f4-f5-hook-process`). |
| spec:524 mocked integration denials and allow | PASS | Suite passed. The text specifies a mocked pull request resolved by the lookup. |
| spec:525 `PROFILE_UNREADABLE`, `PR_UNRESOLVED`, `MATCH_HEAD_MISMATCH`, `RECEIPT_PATH_INVALID`, envelope anomaly | PASS | Suite passed. The tested non-merge and non-integration rows allow. Broader forms deny by the accepted design (code review N13). |
| spec:526 predicates with in-memory strings | PASS | Module unchanged; merged run 0 failures. |
| spec:527 import closure and hook contract suites | PASS | `DocsCompleteGate.psm1` imports unchanged; contract suites in the merged run 0 failures; 265 Python contract tests passed with `-n auto` (`python-contracts.2026-11-07T05-37.md`). |
| spec:528 settings entry, identical copies, contract suites | PASS | Shared blob `a46956dd3`; merged run 0 failures. |
| spec:529 in-memory addition and ledgered cases | PASS | Unchanged; merged run 0 failures. |
| spec:530 change, line-only, null base, retained warning, shuffle with seed | PASS | Unchanged. M5 still survives on a case outside this text (N2). |
| spec:531 usage, unresolved, missing, stale and `-Json` shape | PASS | Unchanged; merged run 0 failures. |
| spec:532 envelope schema validation | PASS | Unchanged; merged run 0 failures. |
| spec:533 row under anchor, only added lines | PASS | Re-checked after the epic merge, as the previous audit required: `integration-merge.2026-11-07T04-53.md` records 0 deleted lines in both helpers, the row directly under its anchor, and no `Test-DocsCommandTable` finding. Source and bundle blobs equal `22596dd3a`. The recorded deviations stand, and the criterion text remains stale (N5). |
| spec:534 revision members through a bounded `[scriptblock]` seam | PASS | Unchanged. The BOM assertion remains ineffective (N1). |
| spec:535 `init` template row, plan, write, refusal | PASS | Unchanged; merged run 0 failures. |
| spec:536 template content rules | PASS | Unchanged. |
| spec:537 section present, bundle identical, delegating files unchanged | PASS | Unchanged; blob parity re-checked for all four surfaces. |
| spec:538 push-down suites and generator check | PASS | Generator exit 0 at head in this review; contract and Jest evidence in `python-contracts` and `jest-manifest`. |
| spec:539 manifest rows and bundle parity | PASS | Ten pairs share blobs at head. |
| spec:540 coverage at or above 85% | PASS | 93.90, 100.00, 100.00, 100.00 and 97.33%, re-derived from `artifacts/pester/powershell-coverage.xml`, counting the helper. No exclusion. No added line of `Invoke-DocsCommand.ps1` is uncovered. The figures are in `evidence/qa-gates/`, not the `evidence/coverage/` path the text names (code review N17). |
| spec:541 no new file above 500 lines | PASS | 342, 334, 191, 292 and 221. |
| spec:542 no Python or TypeScript file | PASS | Diff scan empty against the merge base. |
| spec:543 no temporary-file tokens | PASS | The three gate suites re-scanned; 0 matches. |
| spec:544 CI-dependent | PENDING-CI | No pull request or workflow run exists. Owned by S9. |
| story:65 same text as spec:516 | PARTIAL | As spec:516. |
| story:66 same text as spec:517 | PASS | As spec:517. |
| story:67 same text as spec:518 | PASS | As spec:518. |
| story:68 same text as spec:519 | PASS | As spec:519. |
| story:72 disabled allows every tested command, no `gh` call | PASS | As spec:523. |
| story:73 enabled, an integration-to-`main` merge is denied with a receipt reason | PARTIAL | Reading 2 above is accepted. The denial property fails for the F6 forms, which are allowed. |
| story:74 enabled, denies "in the corresponding conditions" | PASS | As spec:525. |
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

The surface-delta, template, registration, push-down, coverage and language criteria remain delivered. F4, F5 and the integration merge are resolved. The executor's `criteria-reevaluation.2026-11-07T05-38.md` graded spec:516, story:65 and story:73 PASS; this audit does not adopt that, because the F6 commands were outside its evidence set and are neither denied nor outside the group the limit statement says denies.

**Overall readiness: not ready.** Three criteria are PARTIAL and one is pending CI. Remediation inputs: `remediation-inputs.2026-11-07T05-55.md`.

---

## Acceptance Criteria Check-off

Newly checked off by this audit: none. The remaining PASS criteria were already checked. spec:516, story:65 and story:73 stay unchecked because they evaluate PARTIAL, and spec:544 stays unchecked for S9.

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
