# Feature Audit: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T09-23
- Reviewer: feature-review agent (R4 re-audit after remediation cycle 1)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `65c068515b561ba8b965e189d870efbd31fcdb37`

## Scope and Baseline

- Resolved base branch: `main` (`origin/main`); merge-base `4776ccd9366d8f580ac9ac0fe164d75306785218`; range `4776ccd93..65c068515` (146 files, +12067/-290).
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` record head `65c068515` and merge base `4776ccd93`; current.
- Work mode: `full-bug` (`issue.md` line 9). AC source: `spec.md` (version 1.3) section `## Acceptance Criteria` (47 checkbox items). No `user-story.md`.
- Pull request: none exists for the branch (`gh pr list --head ... --state all` returned `[]`). CI run `38876469175` (`workflow_dispatch`, head `7966e1564`, conclusion success, 17 of 17 jobs success) ran on a commit whose code is identical to the branch HEAD; it supports the CI-dependent criteria but is not the PR-head run the spec names.
- Test evidence used: `evidence/qa-gates/r1-qc-pester.2026-10-16T08-45.md` (R1 loop pass 2, tests=7183, failures=0, errors=0; reviewer read of the `pester-junit.xml` root matches), `evidence/qa-gates/r1-ac-reverification.2026-10-16T09-12.md`, and the reviewer's parse of the CI artifacts of runs `38876469175` and `38852748136`.
- Independent reviewer checks: mirror and helper identity (`git hash-object`), line counts (`wc -l`), scope listings (`git diff --name-status`), source reads of every R1 production hunk and the new suite, coverage XML parses, CI run metadata, evidence-location validator.

## Acceptance Criteria Inventory

| ID | Criterion (short form) | State before review |
|---|---|---|
| AC-M1 | PRIMARY: both merge gates allow a docs-only merge of an unrecorded PR under fail-closed rules | checked |
| AC-M2 | Helper exists at four paths, byte-identical, no import/dot-source | checked |
| AC-M3 | Shared pure functions rows pass | checked |
| AC-M4 | Shared seam rows pass through test-local scriptblocks | checked |
| AC-M5 | Claude end-to-end allow row with argument assertions | checked |
| AC-M6 | M1 shape denials with no seam call | checked |
| AC-M7 | M2 blank and nonexistent root denials | checked |
| AC-M8 | M3 lookup denials and matching head pin | checked |
| AC-M9 | M4 base ref denial, no diff call | checked |
| AC-M10 | M5 head commit denial, no fetch anywhere | checked |
| AC-M11 | M6 to M9 diff rows and allow | checked |
| AC-M12 | Claude deny composition order | checked |
| AC-M13 | Claude no seam call for resolved/ambiguous targets and bare command | checked |
| AC-M14 | Codex allow row; entry point passes `-RepositoryRoot` | checked |
| AC-M15 | Codex deny rows | checked |
| AC-M16 | Existing merge-gate suites carry baseline seam mocks and pass | checked |
| AC-M17 | Create side consumes the shared helper | checked |
| AC-M18 | Guarded dot-sources; guard suites pass | checked |
| AC-M19 | Merge-gate mirrors byte-identical; contract pytest passes | checked |
| AC-M20 | Pack manifests list the helper; tests pass | checked |
| AC-M21 | Merge-side header documentation; no `.claude/rules/` edit | checked |
| AC-M22 | Merge-side files under 500 lines | checked |
| AC-M23 | [CI-dependent] merge-side toolchain: format, analyze, test | unchecked |
| AC-M24 | [CI-dependent] merge-side coverage | unchecked |
| AC-M25 | #901 folder locator; no archive edit | checked |
| AC-1 | CR-1 B clusters denied before git | checked |
| AC-2 | CR-1 repository overrides denied before git | checked |
| AC-3 | CR-1 end-to-end `--repo` deny | checked |
| AC-4 | CR-1 no false denial for accept shapes | checked |
| AC-5 | E3 message names every rejected form | checked |
| AC-6 | CR-2 NUL guard and empty-diff rows | checked |
| AC-7 | `-GitInvoker` declaration and capture statement | checked |
| AC-8 | Seam rows; no forbidden test constructs | checked |
| AC-9 | [CI-dependent] seam statement coverage | unchecked |
| AC-10 | CR-3 diff argument list unchanged | checked |
| AC-11 | Create-side documentation | checked |
| AC-12 | Create-side mirrors byte-identical | checked |
| AC-13 | PA-N3 commit confirmation recorded first | checked |
| AC-14 | PA-N3 timestamp rows reconstructed | checked |
| AC-15 | PA-N3 unobserved exit code corrected | checked |
| AC-16 | PA-N3 no rename | checked |
| AC-17 | PA-N2 Evidence Checklist checked with citations | checked |
| AC-18 | [CI-dependent] create-side toolchain: format, analyze, test | unchecked |
| AC-19 | [CI-dependent] CI test pass on both PowerShell jobs | unchecked |
| AC-20 | Create-side files under 500 lines | checked |
| AC-21 | [CI-dependent] create-side coverage threshold | unchecked |
| AC-22 | Scope constraints | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-M1 | PASS | Gate placement unchanged in R1 (`enforce-epic-merge-gate.ps1:418-426`, `.codex/hooks/enforce-epic-merge-gate.ps1:195-203`); allow rows in `enforce-epic-merge-gate.DocsOnly.Tests.ps1` (suite C, 14 passed) and `codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (suite E, 9 passed). R1 adds a fail-closed time bound to every process call on this path (`hook-docs-only-diff.ps1:155-223`). |
| AC-M2 | PASS | Reviewer `git hash-object`: `e04723f27` at all four helper paths; the bounded runner uses only `System.Diagnostics.Process`, and the helper still imports and dot-sources nothing. |
| AC-M3 | PASS | `hook-docs-only-diff.Tests.ps1` (suite A, 30 passed). |
| AC-M4 | PASS | Seam rows in `hook-docs-only-diff.Tests.ps1`; R1 adds default-invoker routing rows and bounded-runner rows (`hook-docs-only-diff.BoundedNative.Tests.ps1`, Codex copy rows `codex-hooks/hook-docs-only-diff.Tests.ps1:197-237`). |
| AC-M5 | PASS | `enforce-epic-merge-gate.DocsOnly.Tests.ps1` allow row with `pr view 5 --json baseRefName,headRefOid` and exact diff argument assertions; suite unchanged in R1. |
| AC-M6 | PASS | MergeExemption shape rows (13 prior plus `--auto=true`), zero seam invocations. |
| AC-M7 | PASS | MergeExemption blank and nonexistent root rows. |
| AC-M8 | PASS | MergeExemption lookup rows, now including the equals-form head pin (matching and mismatching), a `[]` lookup result, and an exit-124 lookup. |
| AC-M9 | PASS | MergeExemption base rows, now including an exit-124 rev-parse. |
| AC-M10 | PASS | MergeExemption head-commit rows; the fetch guard mock throws; no `'fetch'` constant in the helper. |
| AC-M11 | PASS | MergeExemption diff rows, now including an exit-124 diff. |
| AC-M12 | PASS | `enforce-epic-merge-gate.DocsOnly.Tests.ps1` deny-composition rows; unchanged in R1. |
| AC-M13 | PASS | `enforce-epic-merge-gate.DocsOnly.Tests.ps1` no-call rows; unchanged in R1. |
| AC-M14 | PASS | Codex allow row; reviewer read of `.codex/hooks/enforce-epic-merge-gate.ps1:403` shows `-RepositoryRoot $repositoryRoot`. |
| AC-M15 | PASS | Codex deny rows; suite E 9 passed. |
| AC-M16 | PASS | `evidence/other/p4-merge-gate-suite-set.2026-10-16T03-31.md`; reviewer diff shows only +2 baseline-mock lines in each member; no R1 change to these suites. |
| AC-M17 | PASS | `enforce-pr-author-skill.docs-only.ps1` unchanged in R1 (hash `f3e3300e9`); prior reviewer read stands. |
| AC-M18 | PASS | Guarded single-statement dot-sources at Claude gate line 82 and Codex gate line 29; guard rows J14 pass (`r1-qc-pester.2026-10-16T08-45.md`). |
| AC-M19 | PASS | Reviewer `git hash-object` on the merge-gate pairs (`28cfd3bb2`, `e83cd0af5`, `b9ef9c3f8`); `r1-qc-pytest-contracts.2026-10-16T08-45.md` 27 passed. |
| AC-M20 | PASS | Manifests unchanged in R1; one added line per manifest in the branch diff. |
| AC-M21 | PASS | Reviewer read of the three headers; R1 adds the working-directory residual limit and the time-limit paragraph; no `.claude/rules/` path in the diff. |
| AC-M22 | PASS | Reviewer `wc -l`: maximum production 491 (`enforce-epic-merge-gate.ps1`), helper 478, new suite 188; every new or edited suite under 500. |
| AC-M23 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting: local format and analyze passes with empty porcelain status (`r1-qc-format`, `r1-qc-analyze` at 08-32); five named suites pass; CI run 38876469175 `Format PowerShell`, `Analyze PowerShell`, and `Test PowerShell` steps success. |
| AC-M24 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting (reviewer parse of run 38876469175): both helper copies 97.52% line; Claude gate, resolution sibling, and Codex gate at 99.29%, 95.65%, 88.41%. |
| AC-M25 | PASS | `p0-f901-locator.2026-10-16T00-11.md` and `p5-f901-locator.2026-10-16T04-01.md`; no archive path in the diff. |
| AC-1 | PASS | `enforce-pr-author-skill.DocsOnly.Tests.ps1:68-90`; the `-B=main` and new `-dB=other` rows now carry `--base main`, so they discriminate the letter rule (prior CR-3). |
| AC-2 | PASS | R-separate, attached, cluster, `--repo`, `--repo=`, global `-R`, global `--repo`, and `GH_REPO=` rows; zero-invocation `-R` row in `DocsOnly.Exemption.Tests.ps1`. |
| AC-3 | PASS | `DocsOnly.Decision.Tests.ps1` end-to-end `--repo` row; unchanged in R1. |
| AC-4 | PASS | Accept rows in `DocsOnly.Tests.ps1`; suite B 43 passed. |
| AC-5 | PASS | Create-side E3 text unchanged in R1. |
| AC-6 | PASS | NUL guard rows unchanged; pass in R1 loop pass 2. |
| AC-7 | PASS | `Invoke-PrAuthorDocsOnlyGitExe` unchanged in R1 (decision D-R1-3). |
| AC-8 | PASS | Seam rows unchanged; `r1-qc-test-purity.2026-10-16T08-45.md` 0 matches. |
| AC-9 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting (reviewer parse of run 38876469175): lines 78, 79, 82, 84 of `enforce-pr-author-skill.docs-only.ps1` have `ci` 2, 1, 1, 4. |
| AC-10 | PASS | Create-side diff argument list unchanged (file hash unchanged since the prior review, which verified the list). |
| AC-11 | PASS | Create-side documentation unchanged in R1; prior reviewer read stands. |
| AC-12 | PASS | Reviewer `git hash-object`: `f3e3300e9` and `c7c8af60b` pairs identical. |
| AC-13 | PASS | `evidence/other/pa-n3-commit-confirmation.2026-10-16T04-02.md`. |
| AC-14 | PASS | #901 evidence edits unchanged in R1. |
| AC-15 | PASS | `p1-poshqc-direct-run.2026-10-12T19-50.md` records `EXIT_CODE: NOT_OBSERVED`. |
| AC-16 | PASS | `git diff --name-status 4776ccd93..HEAD -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` lists 14 `M` entries only. |
| AC-17 | PASS | #901 `issue.md` Evidence Checklist with citations; unchanged in R1. |
| AC-18 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting: local format and analyze passes; DocsOnly suites pass; CI run 38876469175 PoshQC steps success. |
| AC-19 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting: run 38876469175 reports success for `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` (reviewer `gh run view`). |
| AC-20 | PASS | Reviewer `wc -l`: docs-only 224, pr-author 358, DocsOnly suites 243, 261, 163; mirrors identical. |
| AC-21 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting (run 38876469175): `enforce-pr-author-skill.docs-only.ps1` 100.00%, `enforce-pr-author-skill.ps1` 92.98%. |
| AC-22 | PASS | Reviewer `git diff --name-status` listing: no `hook-command-invocation*.ps1`, no `enforce-pr-author-skill-helpers.ps1`; `.codex/` paths are the gate and helper only. |

## Summary

- 41 of 47 criteria PASS on reviewer-verified evidence; all 41 were already checked in `spec.md`.
- 6 criteria are UNVERIFIED pending the PR-head CI run, all marked **[CI-dependent]** in spec version 1.3: AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24. Each is supported by CI run 38876469175 on a commit with identical code. None is FAIL or PARTIAL on available evidence.
- PRIMARY criterion AC-M1: PASS.
- Review verdict: REMEDIATION_REQUIRED, driven by policy audit PA-1R (contract-designated PowerShell coverage artifact still scoped and incomplete), which is independent of the acceptance criteria. Non-blocking observations CR-R1 to CR-R6 are listed in `code-review.2026-10-16T09-23.md`.

## Acceptance Criteria Check-off

- No criterion was newly checked off in this review: every PASS criterion was already `- [x]` in `spec.md`, and the six CI-dependent criteria remain `- [ ]`.
- The six CI-dependent criteria are owned by the item's orchestrator run at S9, after the PR-head CI run.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`
- Total AC items: 47
- Checked off (delivered): 41
- Remaining (unchecked): 6
- Items remaining: AC-M23 (merge-side toolchain, CI-dependent), AC-M24 (merge-side coverage, CI-dependent), AC-9 (seam statement coverage, CI-dependent), AC-18 (create-side toolchain, CI-dependent), AC-19 (CI test pass, CI-dependent), AC-21 (create-side coverage threshold, CI-dependent)
