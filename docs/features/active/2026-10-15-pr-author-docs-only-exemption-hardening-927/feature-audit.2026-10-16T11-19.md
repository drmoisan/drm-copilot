# Feature Audit: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T11-19
- Reviewer: feature-review agent (R4 re-audit after remediation cycle 2)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `d7b4da0759cff1d47c302019122f3cac33cb3457`

## Scope and Baseline

- Resolved base branch: `main` (`origin/main`); merge-base `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`; range `5bdf22d0f..d7b4da075` (176 files, +13698/-290).
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` record head `d7b4da075` and merge base `5bdf22d0f`; current.
- Work mode: `full-bug` (`issue.md` line 9). AC source: `spec.md` (version 1.3) section `## Acceptance Criteria` (47 checkbox items). No `user-story.md`.
- Pull request: none exists for the branch (`gh pr list --head ... --state all` returned `[]`). CI run `38890377723` (`workflow_dispatch`, head `7b43fddd5`, conclusion success, 17 of 17 jobs success) ran on a commit whose item files are identical to HEAD; it supports the CI-dependent criteria but is not the PR-head run the spec names.
- Test evidence used: `evidence/qa-gates/r2-pa1r-route-b.2026-10-16T10-53.md` (full-population local run, tests=10606, failures=0, errors=0; reviewer read of the `pester-junit.xml` root matches), `evidence/qa-gates/r2-coverage-delta.2026-10-16T10-53.md`, `evidence/qa-gates/r2-ac-reverification.2026-10-16T11-11.md`, and the reviewer's parse of the local coverage XML and of the CI artifact of run `38890377723`.
- Independent reviewer checks: mirror and helper identity (`git hash-object`), line counts (`wc -l`), scope listings (`git diff --name-status`), source read of the R2 production hunk and test hunks, coverage XML parses (local and CI), CI run metadata, evidence-location validator.

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
| AC-M1 | PASS | Gate placement unchanged since the prior review (hashes `28cfd3bb2`, `b9ef9c3f8` unchanged); allow rows in `enforce-epic-merge-gate.DocsOnly.Tests.ps1` and `codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` pass in the full-population run (failures=0). R2 adds process disposal to the bounded runner without changing any decision path. |
| AC-M2 | PASS | Reviewer `git hash-object`: `64d472beb` at all four helper paths; the helper still contains no `Import-Module` or dot-source. |
| AC-M3 | PASS | `hook-docs-only-diff.Tests.ps1` unchanged in R2; passes in the full-population run. |
| AC-M4 | PASS | Seam rows unchanged; runner rows now also assert disposal (`BoundedNative.Tests.ps1:85, 104, 118, 137, 165`; `codex-hooks/hook-docs-only-diff.Tests.ps1:215`). |
| AC-M5 | PASS | `enforce-epic-merge-gate.DocsOnly.Tests.ps1` allow row unchanged; passes. |
| AC-M6 | PASS | MergeExemption shape rows unchanged; pass. |
| AC-M7 | PASS | MergeExemption root rows unchanged; pass. |
| AC-M8 | PASS | MergeExemption lookup rows unchanged; pass. |
| AC-M9 | PASS | MergeExemption base rows unchanged; pass. |
| AC-M10 | PASS | MergeExemption head-commit rows unchanged; reviewer read confirms no `fetch` invocation in the helper. |
| AC-M11 | PASS | MergeExemption diff rows unchanged; pass. |
| AC-M12 | PASS | Deny-composition rows unchanged; pass. |
| AC-M13 | PASS | No-call rows unchanged; pass. |
| AC-M14 | PASS | Codex allow row passes; `.codex/hooks/enforce-epic-merge-gate.ps1:403` passes `-RepositoryRoot $repositoryRoot` (reviewer read). |
| AC-M15 | PASS | Codex deny rows pass. |
| AC-M16 | PASS | `evidence/other/p4-merge-gate-suite-set.2026-10-16T03-31.md`; the member suites are unchanged in R2 and pass in the full-population run. |
| AC-M17 | PASS | `enforce-pr-author-skill.docs-only.ps1` unchanged (hash `f3e3300e9`). |
| AC-M18 | PASS | Guarded dot-sources unchanged; guard suites pass in the full-population run. |
| AC-M19 | PASS | Reviewer `git hash-object` on the merge-gate pairs (`28cfd3bb2`, `e83cd0af5`, `b9ef9c3f8`); `evidence/qa-gates/r2-qc-pytest-contracts.2026-10-16T10-23.md` passed. |
| AC-M20 | PASS | Manifests unchanged since the prior review; one added line per manifest in the branch diff. |
| AC-M21 | PASS | Headers unchanged in R2 apart from the help sentence in the runner; no `.claude/rules/` path in the diff. |
| AC-M22 | PASS | Reviewer `wc -l`: helper 484 at both canonical paths; Claude gate 491; Codex gate 411; resolution 278; new and edited suites at most 467. |
| AC-M23 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting: local format and analyze passes with empty porcelain status (`r2-qc-format.2026-10-16T10-21.md`, `r2-qc-analyze.2026-10-16T10-22.md`); the five named suites pass in the full-population run; CI run `38890377723` `poshqc / PowerShell QC` success. |
| AC-M24 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting (reviewer parse of run `38890377723`): both helper copies 97.54% line; every added executable line of the Claude gate (82, 419-423, 425, 431), the resolution sibling (272-274, 277), and the Codex gate (29, 196-200, 202, 208) has `ci` > 0; Codex line 403 is the named entry-point exception. |
| AC-M25 | PASS | `p0-f901-locator.2026-10-16T00-11.md` and `p5-f901-locator.2026-10-16T04-01.md`; no archive path in the diff. |
| AC-1 | PASS | `enforce-pr-author-skill.DocsOnly.Tests.ps1` rows unchanged since the prior review; pass. |
| AC-2 | PASS | Repository-override rows unchanged; pass. |
| AC-3 | PASS | `DocsOnly.Decision.Tests.ps1` end-to-end row unchanged; pass. |
| AC-4 | PASS | Accept rows unchanged; pass. |
| AC-5 | PASS | Create-side E3 text unchanged (file hash `f3e3300e9`). |
| AC-6 | PASS | NUL guard rows unchanged; pass. |
| AC-7 | PASS | `Invoke-PrAuthorDocsOnlyGitExe` unchanged. |
| AC-8 | PASS | Seam rows unchanged; `r2-qc-test-purity.2026-10-16T10-22.md` 0 matches in the R2-edited suites. |
| AC-9 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting (reviewer parse of run `38890377723`): lines 78, 79, 82, 84 of `enforce-pr-author-skill.docs-only.ps1` have `ci` 2, 1, 1, 4. |
| AC-10 | PASS | Create-side diff argument list unchanged (file hash unchanged). |
| AC-11 | PASS | Create-side documentation unchanged. |
| AC-12 | PASS | Reviewer `git hash-object`: `f3e3300e9` and `c7c8af60b` pairs identical. |
| AC-13 | PASS | `evidence/other/pa-n3-commit-confirmation.2026-10-16T04-02.md`. |
| AC-14 | PASS | #901 evidence edits unchanged in R2. |
| AC-15 | PASS | `p1-poshqc-direct-run.2026-10-12T19-50.md` records `EXIT_CODE: NOT_OBSERVED`. |
| AC-16 | PASS | `git diff --name-status 5bdf22d0f..HEAD -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` lists 14 `M` entries only. |
| AC-17 | PASS | #901 `issue.md` Evidence Checklist with citations; unchanged in R2. |
| AC-18 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting: local format and analyze passes; DocsOnly suites pass; CI run `38890377723` PoshQC jobs success. |
| AC-19 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting: run `38890377723` reports success for `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` (reviewer `gh run view`). |
| AC-20 | PASS | Reviewer `wc -l`: docs-only 224, pr-author 358, DocsOnly suites 243, 261, 163; mirrors identical. |
| AC-21 | UNVERIFIED | [CI-dependent] pending the PR-head run. Supporting (run `38890377723`): `enforce-pr-author-skill.docs-only.ps1` 100.00%, `enforce-pr-author-skill.ps1` 92.98%. |
| AC-22 | PASS | Reviewer `git diff --name-status` listing: no `hook-command-invocation*.ps1`, no `enforce-pr-author-skill-helpers.ps1`; `.codex/` paths are the gate and helper only. |

## Summary

- 41 of 47 criteria PASS on reviewer-verified evidence; all 41 were already checked in `spec.md`.
- 6 criteria are UNVERIFIED pending the PR-head CI run, all marked **[CI-dependent]** in spec version 1.3: AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24. Each is supported by CI run `38890377723` on a commit whose item files are identical to HEAD. None is FAIL or PARTIAL on available evidence.
- PRIMARY criterion AC-M1: PASS.
- Review verdict: PASS. The prior blocking finding PA-1R is closed by the full-population local coverage artifact (repo-wide line 90.33%, every changed hook file at or above 85%). Non-blocking observations are listed in `code-review.2026-10-16T11-19.md`.

## Acceptance Criteria Check-off

- No criterion was newly checked off in this review: every PASS criterion was already `- [x]` in `spec.md`, and the six CI-dependent criteria remain `- [ ]`.
- The six CI-dependent criteria are owned by the item's orchestrator run at S9, after the PR-head CI run.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`
- Total AC items: 47
- Checked off (delivered): 41
- Remaining (unchecked): 6
- Items remaining: AC-M23 (merge-side toolchain, CI-dependent), AC-M24 (merge-side coverage, CI-dependent), AC-9 (seam statement coverage, CI-dependent), AC-18 (create-side toolchain, CI-dependent), AC-19 (CI test pass, CI-dependent), AC-21 (create-side coverage threshold, CI-dependent)
