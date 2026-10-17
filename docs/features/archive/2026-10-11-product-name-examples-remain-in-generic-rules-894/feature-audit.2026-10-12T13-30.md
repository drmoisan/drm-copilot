# Feature Audit (minor-audit) - Issue #894

## Scope and Baseline

- AC source: `issue.md`, section `## Acceptance Criteria` (work mode `minor-audit`). `spec.md` and `user-story.md` are absent from the feature folder, as required.
- Baseline: origin/main, merge-base 5dd9d1f33d1c0ccb01a6c34f6fefd959e020aa74. Head fd54844d28af843d235e35bb200a58296193d697.
- Scope: full branch diff against the baseline.

## Acceptance Criteria Inventory

Seven criteria, AC-1 through AC-7, in `issue.md` under `## Acceptance Criteria`:

- AC-1: `src/TaskMaster.Domain` removed from `parallel-orchestration.md` and its mirror.
- AC-2: `No-COM` removed from `typescript.md`, `csharp.md`, and mirrors, including the frontmatter `description`.
- AC-3: the `typescript.md` cross-reference names the current heading.
- AC-4: (#797 CR-2) former item 7 sits under a correct lead-in.
- AC-5: the three mirrors are byte-identical; the bundle parity test passes.
- AC-6: `PRE_EXISTING_NAME_EXCEPTIONS` is replaced by pinned exact counts, with negative tests and the staleness check kept.
- AC-7: black, ruff, pyright, and pytest are clean; no file exceeds 500 lines.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 `src/TaskMaster.Domain` removed from `parallel-orchestration.md` and mirror | PASS | Diff shows line 411 now `src/<Product>.Domain`. Search for `TaskMaster\|No-COM` over source and mirror: zero matches. `evidence/qa-gates/structural-checks.2026-10-12T12-58.md` item (2) lists the placeholder at line 411 in both files. |
| AC-2 `No-COM` removed from `typescript.md`, `csharp.md`, and mirrors, including frontmatter `description` | PASS | Diff of `csharp.md` shows `description` now ends "(xUnit)." and the body says "a host-neutral .NET foundation". Search over all four files: zero matches. `paths:` unchanged. |
| AC-3 `typescript.md` cross-reference names the current heading | PASS | `typescript.md` line 57 cites "Host-Neutral Architecture Rules (enforceable assertions)". `architecture-boundaries.md:17` carries exactly that heading. |
| AC-4 (#797 CR-2) former item 7 under a correct lead-in | PASS | Diff shows item 7 removed from the numbered list and re-stated as a paragraph attributing the drop to the file-shape classifier that runs before write-intent extraction. Item 6 keeps its period. Applied identically to the mirror (byte-identical). |
| AC-5 three mirrors byte-identical; bundle parity test passes | PASS | `cmp` identical for all three pairs (independent check). `evidence/qa-gates/python-pytest-bundle-parity.2026-10-12T12-57.md`: named test 1 passed, file 14 passed. |
| AC-6 `PRE_EXISTING_NAME_EXCEPTIONS` replaced by pinned exact counts; negative tests; staleness check kept | PASS | Test file read in full: the old name is absent; `PINNED_NAME_OCCURRENCES` is empty; in-memory tests cover unpinned and pinned new occurrences plus removed occurrence; `test_pinned_name_entries_are_pushed_files_with_positive_counts` retained. Fail-before evidence: `regression-testing/expect-fail-pinned-name-counts.2026-10-12T12-44.md` (1 failed, six files reported); pass-after evidence: `pass-after-pinned-name-counts.2026-10-12T12-48.md` (62 passed). |
| AC-7 black, ruff, pyright, pytest clean; no file over 500 lines | PASS | Black unchanged, ruff all checks passed, pyright 0 errors, guard 62 passed, regression set 65 passed (equal to baseline). `wc -l` of the test file: 499. Markdown rule files are exempt from the size limit. |

Notes: I did not rerun pytest, black, ruff, or pyright. Their results rely on the timestamped evidence files, which are consistent with the independently verified file state (zero token matches, byte-identical mirrors, line count). Coverage is not applicable to the change set: no production source file changed, only Markdown rule files and one test file.

## Summary

All 7 of 7 acceptance criteria evaluated PASS. AC failures: 0. Blocking findings: 0. Remediation required: none.

Verdict: PASS

## Acceptance Criteria Check-off

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-11-product-name-examples-remain-in-generic-rules-894/issue.md`
- Total AC items: 7
- Checked off (delivered): 7
- Remaining (unchecked): 0
- Newly checked off by this review: none (all were already checked and each is confirmed PASS).
- Items remaining: none
