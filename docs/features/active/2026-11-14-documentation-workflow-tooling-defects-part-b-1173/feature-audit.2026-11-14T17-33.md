# Feature Audit: Documentation Workflow Tooling Defects, Part B (#1173)

**Audit Date:** 2026-11-14
**Feature Folder:** `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173`
**Base Branch:** `main`
**Head Branch:** `feature/documentation-workflow-tooling-defects-1173`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (origin/main at commit `d7ef763637319b2aa2f886ecdab7a11be0044491`)
- **Head branch/commit:** `feature/documentation-workflow-tooling-defects-1173` (commit `ec00c5389f10be134de8390cf839365fea5c5687`, PR #1185)
- **Merge base:** `d7ef763637319b2aa2f886ecdab7a11be0044491`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-14 17:22:21 UTC at the reviewed head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/evidence/**`
  - Additional evidence: canonical coverage artifacts `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`; reviewer byte comparison of bundle copies; `gh pr checks 1185`; reviewer gate reruns at the head after the Stop hook reported the reports stale or absent (`evidence/qa-gates/review-jest-gate.2026-11-14T17-45.md`, `review-pytest-gate.2026-11-14T17-45.md`, `review-pester-gate.2026-11-14T17-58.md`: 5687, 16951 and 26688 tests, 0 failures, changed-file coverage unchanged)
- **Feature folder used:** `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources.
- **Scope note:** Full branch diff against the merge base (282 files). The head is a merge of origin/main made after the final gates; the reviewer confirmed the merge changed no branch production logic file and that the overlapping Markdown, `core.json`, and fixture files parse and keep the branch additions. CI on the head was running at review time.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/spec.md` — primary source (26 items)
- `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/user-story.md` — secondary source (16 items)

### From spec.md

1. B1: `docs-role-contract.ps1` accepts a `docs-architect` report with a valid profile, a repository-relative `docs-snapshot` path that does not exist, and `docs-result: PASS`, and still rejects a non-relative `docs-snapshot` value; a first-run regression test covers both cases.
2. B1: every M-SKILL copy of `documentation-workflow` contains a root `inventory -Write` step before the inventory role is delegated, and every M-BRIEF copy states that `docs-snapshot` is checked for relative form only; skill-text tests assert both.
3. B2: `update-ledger -Operations <path>` and `update-ledger -Operations -` (standard input) apply an operations document with one load, one introduced-error comparison and one write, and the written ledger, matrix and pins are byte-identical to sequential single-operation application of the same operations; an equivalence test and a partition property test pass.
4. B2: a batch containing an item with an introduced error, an invalid target, an unknown key, or a `sync-refs` operation writes nothing and reports the item index; supplying `-Operation` with `-Operations` exits 2.
5. B2: `bind-page-refs` sets `documented` and the union of page bindings for every snapshot element referenced in page `surface_refs`, warns on unknown ids, removes no binding, and is idempotent; tests cover each rule.
6. B2: MCP `update_docs_ledger` accepts an `operations` array, rejects it together with `operation`, validates each item, and forwards the serialized document as standard input with `-Operations -`; Jest tests cover the new module at 85% line and 75% branch, and its `jest.docs-coverage.json` entry exists.
7. B2: a measured CLI run of `update-ledger -Operations` on an estate of at least 3,000 elements with at least 15,000 operations exits 0 in at most 10 minutes, recorded under the feature `evidence/other/` folder with a clock-read timestamp, command, exit code, counts and elapsed time.
8. B2: every M-SKILL copy of `docs-reconcile-behavior` and every M-AGENT copy of `docs-reconciler` document `-Operations`, `bind-page-refs`, the all-or-nothing rule, and that `sync-refs` is not a batch item.
9. B3: every M-SKILL copy of `docs-reconcile-behavior` and every M-AGENT copy of `docs-reconciler` state that `pin` must precede `set-dimension accurate pass` for the same element and page; a skill-text test asserts it.
10. B3: a batch `set-dimension accurate pass` item with a `claim` produces a pin and no introduced error; without a claim or prior pin the batch is rejected with `DOCS_MATRIX_ACCURACY_UNPINNED`; a claim on any other item is rejected.
11. B4: every `docs-author-page` template copy in every M-SKILL root declares `audience: ["<audience-id>"]`, and a test running each template's substituted front matter through `Test-DocsPageFrontMatter` reports no `DOCS_PAGE_AUDIENCE_INVALID`.
12. B5: `generate-reference` splits a family page whose rendered size exceeds the split budget into an index page and group pages (and ordinal parts for an oversize group), every emitted page is at or below the budget, output is deterministic, and a family at or below the budget is byte-identical to the current output; `DocsReferenceSplit.Tests.ps1` covers each rule.
13. B5: `generate-reference -PathPrefix` and MCP `path_prefixes` restrict elements by ordinal path prefix without a filtered snapshot copy, and a non-relative prefix exits 2.
14. B6: `validate-profile` and `init` report `DOCS_PROFILE_SOURCE_ROOT_MISSING` for a source root that lists no files, and `init` selects `src`, else the `pyproject.toml` package directory, else retains `src` (which then reports `DOCS_PROFILE_SOURCE_ROOT_MISSING`); tests cover each branch.
15. B7: `check` on a page whose link target is not a repository-relative path exits 1 with `DOCS_PAGE_LINK_BROKEN` instead of exiting 3, and the starter profile documentation root defaults to `docs/guide`; tests cover both.
16. B8: inventory skips paths with a default-excluded segment or a `.pyc` or `.pyo` extension without reading them or emitting a diagnostic, and still includes a near-miss path; tests cover each list entry.
17. B9: the native recognizer and the scanner emit `cli-command` and `cli-option` elements for subcommands registered through a `subparsers` parameter in another module, emit identical elements for the shared fixture, and keep `CLI_UNBOUND_REGISTRATION` for an unresolvable caller.
18. B10: the refuted verdict is recorded, no production change is made for it, and a Pester parity test (text versus JSON diagnostic count including `DOCS_INPUT_NOT_UTF8`) and a Jest pass-through test pass.
19. B11: `Get-DocsTextSha256Hex` returns equal values for LF, CRLF and lone-CR forms of a text and the raw-byte value for LF content, every listed artifact-reference and conflict-check site uses it, and `update-ledger` over CRLF-encoded estate bytes reports no reference drift.
20. B12: every M-SKILL copy of `docs-plan-ia` and `docs-author-page` and every M-AGENT copy of `docs-author` document the runtime naming restriction and the root fallback; a skill-text test asserts it.
21. B13: `init` emits a distinct `ci-workflow <path>` line and a `ci_workflow` result field in dry-run and write modes, and every M-SKILL copy of `docs-init` states in Steps and Result that init adds the CI workflow; tests cover the line, the field, the `null` case and the skill text.
22. Every new `.claude/lib/docs` module is listed in `core.json` and bundled byte-identically, and the mirror, push-down contract, pack-manifest and Codex generator parity checks pass.
23. Every item B1-B13 has at least one regression test that fails before the change and passes after it (for B10, the parity tests that prove the verdict).
24. Each changed PowerShell file has at least 85% line coverage and each changed TypeScript or Python file has at least 85% line and 75% branch coverage, with no regression on changed lines.
25. The full seven-stage toolchain loop passes in a single pass with parallel-only test runs and no test-order dependence.
26. CI is green on the final pull request head.

### From user-story.md

27. Consumer (B1): a docs-architect report on a first run (profile present, snapshot not yet persisted, relative snapshot path, `PASS`) is accepted by the stop hook on the first attempt, and the documentation-workflow skill directs the root to run `inventory -Write` before delegating the inventory role.
28. Consumer (B6): `validate-profile` and `init` report `DOCS_PROFILE_SOURCE_ROOT_MISSING` for a source root with no files, and `init` selects `src`, else the `pyproject.toml` package directory, else retains `src` (which then reports `DOCS_PROFILE_SOURCE_ROOT_MISSING`).
29. Consumer (B7): `check` reports a malformed link target as `DOCS_PAGE_LINK_BROKEN` with exit 1 instead of exiting 3, and a starter profile uses `docs/guide` as its documentation root.
30. Consumer (B8): inventory does not read or report bytecode caches, VCS directories, or the other default-excluded tool directories.
31. Consumer (B10): a Pester parity test shows the CLI text and JSON outputs report the same diagnostic count including `DOCS_INPUT_NOT_UTF8`, and a Jest test shows the MCP handler returns those diagnostics unchanged.
32. Consumer (B11): estate artifact hashes are equal for LF and CRLF forms of the same content, LF estates keep their stored hashes, and `update-ledger` over CRLF-encoded estate bytes reports no reference drift.
33. Consumer (B13): `init` reports the CI workflow on a distinct `ci-workflow <path>` line and in a `ci_workflow` result field, and the docs-init skill states in Steps and Result that init adds it.
34. Reconciler (B2): `update-ledger -Operations` (file or standard input) and MCP `update_docs_ledger.operations` apply a batch with one load and one write, produce output byte-identical to sequential application, and write nothing when any item is invalid.
35. Reconciler (B2): `bind-page-refs` binds every snapshot element referenced in page `surface_refs` as `documented` with the union of its pages, without removing bindings, and is idempotent.
36. Reconciler (B2): a measured CLI batch run on an estate of at least 3,000 elements with at least 15,000 operations completes in at most 10 minutes and is recorded as feature evidence.
37. Reconciler (B3): the reconcile skill and reconciler agent state that `pin` precedes `set-dimension accurate pass`, and a batch `accurate pass` item with a `claim` is applied without `DOCS_MATRIX_ACCURACY_UNPINNED`.
38. Author (B4): every page template declares `audience` as a list and passes the page front-matter checker after placeholder substitution.
39. Author (B5): generated reference families above the split budget are emitted as an index page plus group pages that each pass the page size bound, and `-PathPrefix` (CLI) and `path_prefixes` (MCP) filter elements without a snapshot copy.
40. Author (B9): subcommands and options registered through a `subparsers` parameter in another module appear as `cli-command` and `cli-option` elements in both analyzer paths.
41. Author (B12): the docs-plan-ia and docs-author-page skills and the docs-author agent document the runtime naming restriction and the root fallback.
42. Every item B1-B13 has a regression test, mirror and bundle copies stay in parity, the full toolchain loop passes, and CI is green on the final pull request head.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | B1 hook accepts first-run snapshot, rejects non-relative | PASS | `docs-role-contract.ps1` `-SkipExistence` on `docs-snapshot` only; `tests/scripts/claude-hooks/docs-role-contract.Tests.ps1` (+27 lines); task-check P1 records | `git diff <merge-base>..HEAD -- .claude/hooks/` | Hook file 100% line coverage |
| 2 | B1 skill and brief text | PASS | One `inventory -Write` step in each of the three documentation-workflow roots; `docs-authoring-roles.WorkflowText.Tests.ps1`; six brief copies share one digest | `grep -c` over the three skill roots | Bundle copies byte-identical |
| 3 | B2 batch one load, one comparison, one write, byte-identical | PASS | `Invoke-DocsLedgerBatch` calls `LoadDocument` and `CompareRule` once; one `Invoke-DocsArtifactWrite`; equivalence and partition property suites | Inspection of `DocsLedgerBatch.psm1` and `DocsLedgerCommands.psm1` | Final Pester 0 failures |
| 4 | B2 rejection rules and exit 2 | PASS | `ConvertFrom-DocsLedgerOperationItem` rejects unknown key and `sync-refs`; `Test-DocsLedgerBatchArgument` rejects `-Operation` with `-Operations`; findings carry `/operations/<i>` | Inspection; `DocsLedgerBatch.Tests.ps1` | |
| 5 | B2 bind-page-refs rules | PASS | `DocsLedgerBindRefs.psm1` (100% lines); `DocsLedgerBindRefs.Tests.ps1` | Inspection | |
| 6 | B2 MCP operations array | PASS | `mcp-tool-inputs-docs-ledger-batch.ts` 100% lines and branches; `jest.docs-coverage.json` entry; stdin forwarded in `repo-automation-execute-docs.ts` | Reviewer lcov parse | Circular import recorded as a separate policy finding; behavior unaffected |
| 7 | B2 measured 3,000-element run | PASS | `evidence/other/b2-batch-performance.2026-11-14T11-41.md`: 3000 elements, 15000 operations, exit 0, 250 s | Evidence read | |
| 8 | B2 reconcile skill and agent text | PASS | Mirror and skill tests pass; bundle copies byte-identical | `cmp` of 78 bundle files | |
| 9 | B3 pin-before-accurate text | PASS | `.claude/agents/docs-reconciler.md` line 46 and mirrors; skill-text test | `grep` | |
| 10 | B3 claim produces a pin | PASS | Claim step added before the item in `Invoke-DocsLedgerBatch`; claim on other items rejected | Inspection; `DocsLedgerBatch.Tests.ps1` | |
| 11 | B4 template audience lists | PASS | 24 template copies in the three source roots declare `audience: ["<audience-id>"]`; `docs-authoring-roles.Templates.Tests.ps1` | `grep -l` over templates | Bundle copies identical |
| 12 | B5 split rules | PASS | `DocsReferenceSplit.psm1` 100% lines; `DocsReferenceSplit.Tests.ps1`, properties and writer split suites | Reviewer JaCoCo parse | |
| 13 | B5 PathPrefix and path_prefixes | PASS | `PathPrefix = 'multi'` command option; MCP `path_prefixes` row; `DocsReferenceWriter.PathPrefix.Tests.ps1`, `mcp-tool-inputs-docs.reference.test.ts` | Inspection | |
| 14 | B6 source-root detection | PASS | `DocsProfileSourceRoot.psm1` 97.83%; `DocsProfileSourceRoot.Tests.ps1`, `DocsProfileCommands.Tests.ps1` | Reviewer JaCoCo parse | |
| 15 | B7 malformed link and docs/guide | PASS | `Get-DocsPageExternalTarget` filters non-relative paths; `DocumentationRoot = 'docs/guide'`; `DocsPageCheck.MalformedLink.Tests.ps1` | Inspection | |
| 16 | B8 default exclusions | PASS | `Test-DocsInventoryDefaultExcludedPath` applied before profile exclusions; `DocsInventorySnapshot.Tests.ps1` | Inspection | |
| 17 | B9 cross-module subparsers | PASS | `cli_argparse.py` provisional roles and handoffs; scanner changes; corpus fixtures; Python and Pester parity suites | Reviewer lcov parse (cli_argparse 100% lines, 99.12% branches) | |
| 18 | B10 refuted verdict and parity tests | PASS | `evidence/other/b10-verdict.2026-11-14T10-05.md`; `Invoke-DocsCommand.InventoryParity.Tests.ps1`; Jest handler pass-through test | Evidence read | No production change for B10 |
| 19 | B11 line-ending stable hashes | PASS | `Get-DocsTextSha256Hex` used at every site listed by spec B11 (ledger commands, validation, receipt, mutation, validate commands, reference writer, surface delta, analyzer registry); `DocsHashLineEnding.Tests.ps1`, `DocsJson.Tests.ps1` | `grep` of call sites | |
| 20 | B12 naming restriction text | PASS | Skill and agent text in all roots; `docs-authoring-roles.WorkflowText.Tests.ps1` | Mirror tests | |
| 21 | B13 ci-workflow line and field | PASS | `DocsProfileCommands.psm1` line 212 emits `ci-workflow <path>`; result field; skill text | Inspection; `DocsProfileCommands.Tests.ps1` | |
| 22 | core.json and parity checks | PASS | `core.json` lists the four new modules; 78 bundle files byte-identical (reviewer `cmp`); Codex generator check exit 0 | `cmp`; `evidence/qa-gates/parity-and-size.2026-11-14T17-15.md` | |
| 23 | Regression tests fail before, pass after | PASS | Task-check records under `evidence/other/` record fail-before runs per defect | Evidence read | |
| 24 | Coverage thresholds and no regression | PASS | Lowest PowerShell 90.91%; lowest Python 99.29% lines, 98.44% branches; lowest TypeScript branch 93.33%; no missed line on a changed line | Reviewer parse of the three canonical artifacts | |
| 25 | Full seven-stage loop in a single pass | UNVERIFIED | Stages 1-6 passed in the final QC; stage 7 (integration) runs in CI, which was pending on the head at review time | `gh pr checks 1185` | Pending CI; check off at S9 |
| 26 | CI green on the final head | UNVERIFIED | poshqc, quality-checks7 and shell-coverage jobs pending at review time | `gh pr checks 1185` | Pending CI; a remediation cycle will move the final head |
| 27 | Consumer B1 | PASS | Same evidence as rows 1 and 2 | | |
| 28 | Consumer B6 | PASS | Same evidence as row 14 | | |
| 29 | Consumer B7 | PASS | Same evidence as row 15 | | |
| 30 | Consumer B8 | PASS | Same evidence as row 16 | | |
| 31 | Consumer B10 | PASS | Same evidence as row 18 | | |
| 32 | Consumer B11 | PASS | Same evidence as row 19 | | |
| 33 | Consumer B13 | PASS | Same evidence as row 21 | | |
| 34 | Reconciler B2 batch | PASS | Same evidence as rows 3, 4 and 6 | | |
| 35 | Reconciler B2 bind-page-refs | PASS | Same evidence as row 5 | | |
| 36 | Reconciler B2 measured run | PASS | Same evidence as row 7 | | |
| 37 | Reconciler B3 | PASS | Same evidence as rows 9 and 10 | | |
| 38 | Author B4 | PASS | Same evidence as row 11 | | |
| 39 | Author B5 | PASS | Same evidence as rows 12 and 13 | | |
| 40 | Author B9 | PASS | Same evidence as row 17 | | |
| 41 | Author B12 | PASS | Same evidence as row 20 | | |
| 42 | Regression tests, parity, toolchain, CI green | UNVERIFIED | Regression tests and parity pass; toolchain stage 7 and CI pending | `gh pr checks 1185` | Pending CI; check off at S9 |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

All functional acceptance criteria are delivered and verified. Readiness is NEEDS REVISION because the policy audit records one blocking finding (circular TypeScript import between the MCP input modules), and three CI-dependent criteria remain pending.

**Criteria summary:**
- **PASS:** 39 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 3 criteria (pending CI on the final head)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. Blocking policy finding: circular import between `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts` and `extensions/drm-copilot/src/mcp-tool-inputs-docs-ledger-batch.ts` (see the remediation inputs).
2. CI-dependent criteria 25, 26 and 42 await CI on the final pull request head.

**Recommended follow-up verification steps:**

1. After the remediation cycle, rerun the TypeScript static stages and the Jest coverage gate and confirm the new and changed MCP input modules stay at or above 85% line and 75% branch coverage.
2. At S9, confirm CI green on the final head and check off criteria 25, 26 and 42.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

No source-file checkbox change was made by this review: every PASS criterion was already checked by the executor, and the three UNVERIFIED (pending-CI) criteria are already unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/spec.md`, `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/user-story.md`
- Total AC items: 42
- Checked off (delivered): 39
- Remaining (unchecked): 3
- Items remaining: "The full seven-stage toolchain loop passes in a single pass with parallel-only test runs and no test-order dependence." and "CI is green on the final pull request head." (spec.md); "Every item B1-B13 has a regression test, mirror and bundle copies stay in parity, the full toolchain loop passes, and CI is green on the final pull request head." (user-story.md)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 26 | 24 | 2 | Checkbox-backed; the two unchecked items are pending CI |
| `user-story.md` | 16 | 15 | 1 | Checkbox-backed; the unchecked item is pending CI |
