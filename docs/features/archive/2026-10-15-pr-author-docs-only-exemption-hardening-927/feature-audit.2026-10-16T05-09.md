# Feature Audit: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T05-09
- Reviewer: feature-review agent
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `e4521e5a8e1ef211d8e81e686e8f9bcaf4dbf9f9`

## Scope and Baseline

- Resolved base branch: `main` (`origin/main`); merge-base `afa951ac0207eae934ac695e7340f18b3cf77522`; range `afa951ac0..e4521e5a8` (97 files, +8520/-290).
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-10-16 05:01:43 UTC for head `e4521e5a8`; current.
- Work mode: `full-bug` (`issue.md` line 9). AC source: `spec.md` section `## Acceptance Criteria` (47 checkbox items). No `user-story.md`.
- Pull request: none exists for the branch (`gh pr list --head ... --state all` returned `[]`), so no PR-head CI run exists. Criteria marked **[CI-dependent]** in the spec, and the analyzer halves of AC-18 and AC-M23, cannot be verified in this review.
- Test evidence used: `evidence/qa-gates/p6-pester.2026-10-16T04-43.md` (loop pass 2) and the reviewer's read of `artifacts/pester/pester-junit.xml` (root: tests=7155, failures=0, errors=0; file mtime after the last code commit `1cfb6a919`).
- Independent reviewer checks: mirror and helper identity (`git hash-object`), line counts (`wc -l`), scope listings (`git diff --name-status`), source reads of every production hunk, test-purity search, coverage XML parse, evidence-location validator.

## Acceptance Criteria Inventory

| ID | Criterion (short form) | State before review |
|---|---|---|
| AC-M1 | PRIMARY: both merge gates allow a docs-only merge of an unrecorded PR under fail-closed rules | checked |
| AC-M2 | Helper exists at four paths, byte-identical, defines six functions, no import/dot-source | checked |
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
| AC-M23 | Merge-side toolchain: format, analyze, test | unchecked |
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
| AC-18 | Create-side toolchain: format, analyze, test | unchecked |
| AC-19 | [CI-dependent] CI test pass on both PowerShell jobs | unchecked |
| AC-20 | Create-side files under 500 lines | checked |
| AC-21 | [CI-dependent] create-side coverage threshold | unchecked |
| AC-22 | Scope constraints | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-M1 | PASS | Reviewer source read: `enforce-epic-merge-gate.ps1:417-425` and `.codex/hooks/enforce-epic-merge-gate.ps1:194-202` call `Get-DocsOnlyMergeExemption` only after the standalone record fails and only with no recording checkpoint; allow rows in `enforce-epic-merge-gate.DocsOnly.Tests.ps1:69-81` and `codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:64-75` pass (`p6-pester` suites C 14 and E 9 passed). Non-blocking observations CR-1 and CR-2 concern runtime inputs outside the command text. |
| AC-M2 | PASS | `git hash-object` returns `b2383fee8...` for all four helper paths; six functions defined (plus the private `Get-DocsOnlyMergeShapeViolation` and `Get-DocsOnlyPullRequestTarget`); AST row `hook-docs-only-diff.Tests.ps1:301-316` asserts no `Import-Module`, no dot-source; reviewer read confirms. |
| AC-M3 | PASS | `hook-docs-only-diff.Tests.ps1:48-191`; suite A 30 passed. |
| AC-M4 | PASS | `hook-docs-only-diff.Tests.ps1:193-287` (success with argument order, non-zero, throw, blank and nonexistent root; gh location restored after success and throw; `LASTEXITCODE` reset in `BeforeEach`/`AfterEach`). |
| AC-M5 | PASS | `enforce-epic-merge-gate.DocsOnly.Tests.ps1:69-81` asserts allow, `pr view 5 --json baseRefName,headRefOid`, and the exact diff argument string. |
| AC-M6 | PASS | `hook-docs-only-diff.MergeExemption.Tests.ps1:32-57`: 13 rows covering every listed shape with zero gh and git invocations. |
| AC-M7 | PASS | `MergeExemption.Tests.ps1:61-73`. |
| AC-M8 | PASS | `MergeExemption.Tests.ps1:77-125` (gh failure, unparseable, short and uppercase oid, mismatched and valueless pin, `..` and dash-leading base, matching pin). Equals-form pin has no row (CR-4). |
| AC-M9 | PASS | `MergeExemption.Tests.ps1:137-153`. |
| AC-M10 | PASS | `MergeExemption.Tests.ps1:155-172` and `:210-216`; `BeforeEach` fetch mock throws (`:28`); AST row finds no `'fetch'` string constant in the helper. |
| AC-M11 | PASS | `MergeExemption.Tests.ps1:174-208`. |
| AC-M12 | PASS | `enforce-epic-merge-gate.DocsOnly.Tests.ps1:83-126` (non-docs, gh failure, `-R` composition with ordered regex). |
| AC-M13 | PASS | `enforce-epic-merge-gate.DocsOnly.Tests.ps1:130-197`; existing `Authorization.Tests.ps1` passes 16 rows (`p6-pester` J13). |
| AC-M14 | PASS | Codex allow row `:64-75`; reviewer read of `.codex/hooks/enforce-epic-merge-gate.ps1:402` shows `-RepositoryRoot $repositoryRoot`. |
| AC-M15 | PASS | `codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:77-158`. |
| AC-M16 | PASS | `evidence/other/p4-merge-gate-suite-set.2026-10-16T03-31.md` (two searches compared); reviewer diff shows +2 baseline-mock lines in each member and no other edit; named suites pass (`p6-pester` J13). |
| AC-M17 | PASS | Reviewer read: dot-source at `enforce-pr-author-skill.docs-only.ps1:44`; the two local helpers removed; one `Get-DocsOnlyDiffTextViolation` call; `Invoke-PrAuthorDocsOnlyGitExe` still defined and called (`:196`, `:210`); no `PR_UNRESOLVED` text; helpers file absent from the diff. |
| AC-M18 | PASS | Reviewer read: Claude gate line 81 and Codex gate line 28 use the guarded single-statement form; guard suites 598 and 10 passed (`p6-pester` J13). |
| AC-M19 | PASS | Reviewer `git hash-object` on the three merge-gate pairs; `p6-pytest-contracts.2026-10-16T04-45.md` 27 passed. |
| AC-M20 | PASS | Reviewer diff: one added line per manifest; pytest 27 passed; Jest 16 passed (`p6-jest-manifest.2026-10-16T04-45.md`). |
| AC-M21 | PASS | Reviewer read of the three headers (M1 to M9, `DOCS_ONLY_EXEMPTION_PR_UNRESOLVED`, no-fetch, OD-1 in the Codex header, OD-2, residual limits); the Claude header no longer states that the gate never calls `gh pr view`; no `.claude/rules/` path in the diff. |
| AC-M22 | PASS | Reviewer `wc -l`: maximum 490 (`enforce-epic-merge-gate.ps1`); every new suite and edited existing suite under 500. |
| AC-M23 | UNVERIFIED | Format verified (`p6-poshqc-format.2026-10-16T04-18.md`, 0 files rewritten) and test verified (five named suites 30, 36, 14, 32, 9 passed, 0 failed). Analyzer: MCP returned ok=true but the pass-2 finding count is not recorded; pending the CI `Analyze PowerShell` step. |
| AC-M24 | UNVERIFIED | [CI-dependent]; no PR-head CI run exists. Supporting local evidence: all 21 changed executable lines in the measured gate files are covered in the scoped local artifact; the helper copies are absent from it (policy audit PA-1). |
| AC-M25 | PASS | `p0-f901-locator.2026-10-16T00-11.md` and `other/p5-f901-locator.2026-10-16T04-01.md`; reviewer diff lists no archive path. |
| AC-1 | PASS | `DocsOnly.Tests.ps1:68-88` and `DocsOnly.Exemption.Tests.ps1:235-246` pass; reviewer read of `:139`. The `-B=main` row does not discriminate the new rule (CR-3); `-dB` does. |
| AC-2 | PASS | `DocsOnly.Tests.ps1:72-80` (R separate, attached, cluster, `--repo`, `--repo=`, global `-R`, global `--repo`, `GH_REPO=`); zero-invocation `-R` row `DocsOnly.Exemption.Tests.ps1:222-233`. |
| AC-3 | PASS | `DocsOnly.Decision.Tests.ps1:149-161`. |
| AC-4 | PASS | Accept rows `DocsOnly.Tests.ps1:90-103`; relocated rows pass in `hook-docs-only-diff.Tests.ps1`; DocsOnly suites 34, 19, 9 passed with no failure. |
| AC-5 | PASS | Reviewer read of `enforce-pr-author-skill.docs-only.ps1:191`; row `DocsOnly.Exemption.Tests.ps1:248-259`. |
| AC-6 | PASS | `DocsOnly.Exemption.Tests.ps1:209-220` (NUL); empty-diff row retained in the suite; shared rows in `hook-docs-only-diff.Tests.ps1:143-167`. |
| AC-7 | PASS | Reviewer read of `:70` and `:78`; call sites `:196`, `:210` pass no `-GitInvoker`. |
| AC-8 | PASS | Seam rows `DocsOnly.Tests.ps1:193-241`; reviewer purity search returned no match. |
| AC-9 | UNVERIFIED | [CI-dependent]; no PR-head CI run. The local scoped artifact has no `sourcefile` for `enforce-pr-author-skill.docs-only.ps1`. Target lines per `p6-coverage-pending-ci.2026-10-16T04-52.md`: 78, 79, 82, 84. |
| AC-10 | PASS | Reviewer read of `:210`; the range row in `DocsOnly.Exemption.Tests.ps1` is unmodified in the diff. |
| AC-11 | PASS | Reviewer read of both headers and the `Get-PrAuthorDocsOnlyBaseName` `.DESCRIPTION`. |
| AC-12 | PASS | Reviewer `git hash-object` on both pairs; pytest 27 passed. |
| AC-13 | PASS | `evidence/other/pa-n3-commit-confirmation.2026-10-16T04-02.md` precedes the #901 edit commit `ad9650cf4`. |
| AC-14 | PASS | Reviewer read of two corrected files (`local-powershell-coverage`, `p1-poshqc-direct-run`): first `Timestamp:` row set to the upper bound followed by the four annotation rows; 13 files modified as listed in Design item 6; `p1-direct-xml-regenerated-rerun` absent from the diff. |
| AC-15 | PASS | Reviewer diff of `p1-poshqc-direct-run.2026-10-12T19-50.md`: `EXIT_CODE: NOT_OBSERVED`, `EXIT_CODE_OBSERVED_IN: ...-rerun...`, summary no longer interprets exit code 0. |
| AC-16 | PASS | `git diff --name-status afa951ac0..HEAD -- docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` lists 14 `M` entries only. |
| AC-17 | PASS | Reviewer diff of #901 `issue.md` lines 49-51 with the required citations. |
| AC-18 | UNVERIFIED | Format and test halves verified (see AC-M23 and AC-4). Analyzer half pending the CI `Analyze PowerShell` step; CR-10 recommends either a direct analyzer record or a CI-dependent marker. |
| AC-19 | UNVERIFIED | [CI-dependent]; no PR-head CI run. |
| AC-20 | PASS | Reviewer `wc -l`: docs-only 224, pr-author 358, DocsOnly suites 242, 261, 163; mirrors identical. |
| AC-21 | UNVERIFIED | [CI-dependent]; no PR-head CI run. Local scoped artifact: `enforce-pr-author-skill.ps1` 92.98%; `enforce-pr-author-skill.docs-only.ps1` absent. |
| AC-22 | PASS | Reviewer `git diff --name-status` listing: no `hook-command-invocation*.ps1`, no `enforce-pr-author-skill-helpers.ps1`; `.codex/` paths are the gate and helper only; manifests are the two named files. |

## Summary

- 41 of 47 criteria PASS on reviewer-verified evidence; all 41 were already checked in `spec.md`.
- 6 criteria are UNVERIFIED pending the PR-head CI run: AC-9, AC-19, AC-21, AC-M24 (marked CI-dependent), and AC-18, AC-M23 (analyzer half only). None is FAIL or PARTIAL on available evidence.
- PRIMARY criterion AC-M1: PASS.
- Review verdict: REMEDIATION_REQUIRED, driven by policy audit PA-1 (PowerShell coverage artifact scoped and incomplete), which is independent of the acceptance criteria. Non-blocking observations CR-1 to CR-10 are listed in `code-review.2026-10-16T05-09.md`.

## Acceptance Criteria Check-off

- No criterion was newly checked off in this review: every PASS criterion was already `- [x]` in `spec.md`, and the six UNVERIFIED criteria remain `- [ ]`.
- The four CI-dependent criteria (AC-9, AC-19, AC-21, AC-M24) are owned by the item's orchestrator run at S9. AC-18 and AC-M23 are not marked CI-dependent in the spec; see code-review CR-10.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`
- Total AC items: 47
- Checked off (delivered): 41
- Remaining (unchecked): 6
- Items remaining: AC-M23 (merge-side toolchain, analyzer half), AC-M24 (merge-side coverage, CI-dependent), AC-9 (seam statement coverage, CI-dependent), AC-18 (create-side toolchain, analyzer half), AC-19 (CI test pass, CI-dependent), AC-21 (create-side coverage threshold, CI-dependent)
